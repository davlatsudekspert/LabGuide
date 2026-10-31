// 30 kunlik bepul sinov — BIR TELEFONGA BIR MARTA (D-74; muddat D-80, egasi qarori 2026-10-31). INERT:
// * LG_BILLING_ENABLED=true bo'lmasa yo'llar umuman yo'q (app.ts → 404);
// * qurilma attestatsiyasi tekshiruvchisi (`deps.attestation`) sozlanmagan
//   bo'lsa — `503 device_attestation_not_configured` (production'da HECH
//   QANDAY haqiqiy tekshiruvchi ulanmagan: Apple App Attest / DeviceCheck va
//   Google Play Integrity kalitlari egasi tomonidan sozlanadi).
//
// Suiiste'molga qarshi qoidalar (docs/PRO_TRIAL_ABUSE_NOTES.md):
// (a) email kanonik ko'rinishda (Gmail nuqta/+teg va h.k.) — sinov kaliti;
// (b) bir qurilmaga bitta sinov: qurilma belgisi attestatsiyadan, faqat
//     HMAC (server kaliti bilan "tuzlangan") holda saqlanadi;
// (c) bir kanonik emailga va bir hisobga bitta sinov;
// (d) hisob o'chirilganda sinov yozuvi O'CHIRILMAYDI (faqat hisob id si
//     uziladi) — qayta ro'yxatdan o'tish sinovni qaytarmaydi; yozuv
//     `retain_until` gacha saqlanadi, keyin kunlik tozalashda o'chadi;
// (e) limitlar (hisob, IP);
// (f) so'ralgan daraja hisobga ruxsat etilgan bo'lishi kerak (Ustoz —
//     serverda ustoz sifatida ro'yxatdan o'tgan; Mutaxassis — tasdiqlangan
//     mutaxassis; Premium — ikkalasi ham); aks holda 403 `plan_not_allowed`;
// (g) muddat huquqni hal qilishda (`source: trial`) hisobga olinadi va
//     pullik obunani hech qachon bosib o'tmaydi (billing.ts `resolveAccess`).
//
// Holat mashinasi (D-77 addendum, faqat SERVER soati): `not_started` →
// `active` (start, 30 kun) → `expired` (server `now >= expires_at`). Qayta
// boshlanmaydi: hisob, kanonik email va qurilma bo'yicha unikal yozuv;
// mijoz yuborgan vaqt maydonlari (started_at, now va h.k.) O'QILMAYDI.
// Bitta sinov = bitta hisob uchun BITTA reja (foydalanuvchi tanlagani),
// 30 kun; keyin boshqa reja sinovi ham yo'q (`trial_already_used`).
//
// Haqiqiy tekshiruvchilar: src/attestation.ts (Play Integrity, DeviceCheck).
// Secretlar bo'lmasa — `503 trial_unavailable` (fail closed).

import { audit, emailHash, normalizeEmail, requireSession } from './auth';
import { loadAccess, PLANS, type Plan, snapshot } from './billing';
import { userHash } from './community';
import type { Ctx } from './context';
import { base64url, hex, hmac, randomBytes, sha256Hex } from './crypto';
import { ApiError, badRequest, conflict, type Env, forbidden, json, readJson } from './http';
import { attestTokenHash } from './attestation';
import { bump, hit, peek } from './ratelimit';
import { TIER_CAPABILITIES } from './tiers';

/**
 * Sinov uzunligi — HAMMA pullik reja uchun 30 kun (D-80, egasi qarori 2026-10-31;
 * D-76/D-77 dagi 7 kun almashtirildi). Bepul daraja — o'zgarmagan (doim bepul).
 * Bu faqat LabGuide SERVER sinovi; do'kon kirish taklifi (Apple/Google) uchun
 * ilova kun hisoblamaydi — do'konning o'z kvitansiya sanalariga ishonadi (D-80).
 */
export const TRIAL_DAYS = 30;
/**
 * Sinov yozuvi (faqat HMAC lar) saqlanish muddati: sinov boshlangandan
 * 730 kun (24 oy). Shundan keyin kunlik tozalash o'chiradi — o'sha qurilma
 * yoki email yana sinov ola oladi. Egasi o'zgartirishi mumkin (D-74).
 */
export const TRIAL_RETENTION_DAYS = 730;
export const CHALLENGE_TTL_SEC = 300;
export const START_PER_HOUR_USER = 5;
export const START_PER_HOUR_IP = 30;
export const CHALLENGE_PER_HOUR_USER = 20;
/**
 * "Yangi hisob → darhol sinov" oqimi (ko'p hisob ochib sinov olish): bitta
 * IP tarmog'idan (IPv4 /24, IPv6 /48) sutkasiga yaratilganiga 24 soat
 * to'lmagan hisoblar uchun shuncha MUVAFFAQIYATLI sinov. O'zbekistondagi
 * mobil operatorlar CGNAT ishlatadi (ko'p foydalanuvchi bitta IP da) —
 * shuning uchun cheklov faqat yangi hisoblarga va muvaffaqiyatli sinovlarga.
 * ASN bo'yicha cheklov ATAYLAB yo'q: bir nechta milliy operator = bir nechta
 * ASN, bu halol foydalanuvchilarni to'sib qo'yardi.
 */
export const NEW_ACCOUNT_AGE_MS = 24 * 3600_000;
export const NEW_ACCOUNT_TRIALS_PER_PREFIX_DAY = 3;
/** Har qanday hisob: bitta IP tarmog'idan sutkasiga muvaffaqiyatli sinovlar. */
export const TRIALS_PER_PREFIX_DAY = 20;
/** Attestatsiya tokeni xeshi (takrorni aniqlash) saqlanish muddati. */
export const ATTEST_TOKEN_RETENTION_MS = 30 * 86400_000;
const DAY = 86400_000;
const MAX_ATTESTATION = 16 * 1024;

// ----------------------------------------------------------- attestatsiya
export type AttestationPlatform = 'ios' | 'android';

export interface AttestationInput {
  platform: AttestationPlatform;
  /**
   * Platforma tokeni: iOS — App Attest assertion/attestation yoki DeviceCheck
   * tokeni; Android — Play Integrity token. Server uni faqat xotirada
   * tekshiradi, hech qayerga yozmaydi.
   */
  token: string;
  /** iOS App Attest kalit id si (bo'lsa). */
  keyId: string | null;
  /** Server bergan bir martalik nonce (`POST /v1/billing/trial/challenge`). */
  nonce: string;
  /**
   * Ilova darajasidagi qurilma belgisi (Android — ANDROID_ID, Play Integrity
   * nonce'iga bog'langan; iOS — Keychain'dagi tasodifiy UUID). Faqat HMAC
   * qilinib saqlanadi (`device_key`).
   */
  deviceId: string | null;
}

export type AttestationResult =
  | {
      ok: true;
      /**
       * Qurilmaning barqaror belgisi (masalan App Attest kalit id si yoki
       * platforma bergan qurilma belgisi). Faqat HMAC qilinib saqlanadi.
       */
      subject: string;
      /**
       * Platformaning o'z "qurilma bayrog'i" (DeviceCheck 2 bit / Play
       * Integrity device recall) allaqachon "sinov ishlatilgan" desa — true.
       */
      alreadyUsed?: boolean;
    }
  | { ok: false; reason: string };

/**
 * Qurilma attestatsiyasini tekshiruvchi (server). Haqiqiy: src/attestation.ts
 * (Play Integrity, DeviceCheck) — Apple/Google kalitlari (Worker secretlari)
 * bo'lmasa "sozlanmagan".
 */
export interface DeviceAttestationVerifier {
  /** Kalitlar sozlanganmi (biror platforma uchun). `false` → `503 trial_unavailable`. */
  configured(env: Env): boolean;
  /** Shu platforma uchun sozlanganmi (berilmasa — [configured]). */
  configuredFor?(env: Env, platform: AttestationPlatform): boolean;
  verify(ctx: Ctx, input: AttestationInput): Promise<AttestationResult>;
  /** Sinov berilgach platforma bayrog'ini "ishlatilgan" qilish (ixtiyoriy). */
  markUsed?(ctx: Ctx, input: AttestationInput): Promise<void>;
}

/** Standart: hech narsa sozlanmagan — har doim 503. */
export const UnconfiguredVerifier: DeviceAttestationVerifier = {
  configured: () => false,
  verify: async () => ({ ok: false, reason: 'not_configured' }),
};

const verifierOf = (ctx: Ctx): DeviceAttestationVerifier => ctx.deps.attestation ?? UnconfiguredVerifier;

const configuredOn = (ctx: Ctx, p: AttestationPlatform): boolean => {
  const v = verifierOf(ctx);
  return v.configuredFor ? v.configuredFor(ctx.env, p) : v.configured(ctx.env);
};

// ------------------------------------------------------ platforma (D-75)
/**
 * Sinov ruxsat etilgan platformalar (`TRIAL_PLATFORMS`, standart `android`).
 * iOS: Apple App Review 3.1.1 bo'yicha server bergan kartasiz sinov NOANIQ —
 * Apple yozma javobidan keyin egasi `TRIAL_PLATFORMS=android,ios` qiladi
 * (docs/APPLE_REVIEW_QUESTION_DRAFT.md). Noma'lum qiymatlar e'tiborsiz.
 */
export function trialPlatforms(env: Env): AttestationPlatform[] {
  const raw = env.TRIAL_PLATFORMS ?? 'android';
  const out = new Set<AttestationPlatform>();
  for (const p of raw.split(/[\s,]+/)) {
    const v = p.trim().toLowerCase();
    if (v === 'android' || v === 'ios') out.add(v);
  }
  return [...out];
}

export const trialPlatformAllowed = (env: Env, p: AttestationPlatform) => trialPlatforms(env).includes(p);

/**
 * Imkoniyat so'rovi (`GET /v1/billing/status` → `trial`): har platforma uchun
 * sinov hozir boshlanishi mumkinmi (platforma ruxsat etilgan VA qurilma
 * attestatsiyasi sozlangan). Ilova "Sinovni boshlash" tugmasini faqat shu
 * `true` bo'lsa ko'rsatadi.
 */
export function trialStatus(ctx: Ctx): { android: boolean; ios: boolean; platforms: AttestationPlatform[]; days: number } {
  return {
    android: configuredOn(ctx, 'android') && trialPlatformAllowed(ctx.env, 'android'),
    ios: configuredOn(ctx, 'ios') && trialPlatformAllowed(ctx.env, 'ios'),
    platforms: trialPlatforms(ctx.env),
    days: TRIAL_DAYS,
  };
}

const platformBlocked = () => new ApiError(403, 'trial_not_available_on_platform');

/** Fail closed: attestatsiya sozlanmagan — sinov yo'q (ilova tugmani yashiradi). */
function notConfigured(): ApiError {
  return new ApiError(503, 'trial_unavailable', { reason: 'device_attestation_not_configured' });
}

// ------------------------------------------------------- kanonik email
/**
 * Sinov kaliti uchun kanonik email (kirish uchun EMAS — hisob identifikatori
 * o'zgarmaydi). Faqat provayder hujjatlarida e'lon qilingan aliaslar:
 * - Gmail (`gmail.com`, `googlemail.com` → `gmail.com`): lokal qismdagi
 *   nuqtalar e'tiborsiz, `+teg` olib tashlanadi.
 * - Microsoft iste'molchi pochtasi (`outlook.com`, `hotmail.com`, `live.com`,
 *   `msn.com`): `+teg` olib tashlanadi (nuqtalar MUHIM — tegilmaydi).
 * - Yandex (`yandex.ru`, `ya.ru`, `yandex.com`, `yandex.by`, `yandex.kz`,
 *   `yandex.ua` → `yandex.ru`): bitta pochta qutisi; `+teg` olib tashlanadi.
 * Boshqa domenlar: faqat trim + kichik harf.
 */
export function canonicalEmail(raw: unknown): string | null {
  const e = normalizeEmail(raw);
  if (!e) return null;
  const at = e.lastIndexOf('@');
  let local = e.slice(0, at);
  let domain = e.slice(at + 1);
  const stripTag = () => {
    const plus = local.indexOf('+');
    if (plus > 0) local = local.slice(0, plus);
  };
  if (domain === 'googlemail.com') domain = 'gmail.com';
  if (domain === 'gmail.com') {
    stripTag();
    local = local.replace(/\./g, '');
  } else if (['outlook.com', 'hotmail.com', 'live.com', 'msn.com'].includes(domain)) {
    stripTag();
  } else if (['yandex.ru', 'ya.ru', 'yandex.com', 'yandex.by', 'yandex.kz', 'yandex.ua'].includes(domain)) {
    domain = 'yandex.ru';
    stripTag();
  }
  if (!local) return null;
  return `${local}@${domain}`;
}

const trialKey = async (ctx: Ctx, kind: 'email' | 'device', v: string) =>
  hex(await hmac(ctx.keys.trial, `${kind}:${v}`));

// ----------------------------------------------------------- yo'llar
/**
 * POST /v1/billing/trial/challenge — attestatsiya uchun bir martalik nonce
 * (5 daqiqa, shu hisobga bog'langan; serverda faqat SHA-256 saqlanadi).
 */
export async function challenge(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  if (!verifierOf(ctx).configured(ctx.env)) throw notConfigured();
  // Ixtiyoriy `{platform}` — ruxsat etilmagan platformaga nonce ham berilmaydi.
  const raw = await ctx.req.text();
  if (raw.length > 1024) throw badRequest('invalid_json');
  if (raw) {
    let platform: unknown;
    try {
      platform = (JSON.parse(raw) as Record<string, unknown>)?.platform;
    } catch {
      throw badRequest('invalid_json');
    }
    if (platform != null) {
      if (platform !== 'ios' && platform !== 'android') throw badRequest('invalid_platform');
      if (!trialPlatformAllowed(ctx.env, platform)) throw platformBlocked();
      if (!configuredOn(ctx, platform)) throw notConfigured();
    }
  }
  await hit(ctx.db, `trial-ch:${(await sha256Hex(s.userId)).slice(0, 32)}`, CHALLENGE_PER_HOUR_USER, 3600, ctx.now);
  const nonce = base64url(randomBytes(32));
  const expires = ctx.now + CHALLENGE_TTL_SEC * 1000;
  await ctx.db
    .prepare('INSERT INTO pro_trial_challenges (nonce_hash, user_id, expires_at) VALUES (?1, ?2, ?3)')
    .bind(await sha256Hex(nonce), s.userId, expires)
    .run();
  return json({ nonce, expires_at: new Date(expires).toISOString() });
}

function parseTier(raw: unknown): Plan {
  if (typeof raw !== 'string' || !(PLANS as string[]).includes(raw)) throw badRequest('invalid_tier');
  return raw as Plan;
}

function parseAttestation(raw: unknown): Omit<AttestationInput, 'nonce'> & { nonce: string } {
  const o = (raw ?? {}) as Record<string, unknown>;
  if (o.platform !== 'ios' && o.platform !== 'android') throw badRequest('invalid_attestation');
  if (typeof o.token !== 'string' || o.token.length < 1 || o.token.length > MAX_ATTESTATION) {
    throw badRequest('invalid_attestation');
  }
  if (typeof o.nonce !== 'string' || !/^[A-Za-z0-9_-]{43}$/.test(o.nonce)) throw badRequest('invalid_nonce');
  const keyId = o.key_id == null ? null : String(o.key_id);
  if (keyId != null && keyId.length > 512) throw badRequest('invalid_attestation');
  let deviceId: string | null = null;
  if (o.device_id != null) {
    if (typeof o.device_id !== 'string' || !/^[A-Za-z0-9._:-]{8,128}$/.test(o.device_id)) throw badRequest('invalid_attestation');
    deviceId = o.device_id;
  }
  return { platform: o.platform, token: o.token, keyId, nonce: o.nonce, deviceId };
}

/**
 * Daraja hisob uchun ruxsat etilganmi (D-74 (f)). Qaror serverdagi
 * yozuvlardan va reja ochadigan imkoniyatlardan (`TIER_CAPABILITIES`):
 * ustoz paneli bor reja (Ustoz, Premium) — `teacher_accounts` (serverda
 * ustoz sifatida ro'yxatdan o'tgan); Lab bor reja (Mutaxassis, Premium) —
 * hamjamiyatda hujjat bilan tasdiqlangan mutaxassis
 * (`community_members.status = 'verified'`). Talaba — har hisob. Shunday
 * qilib Premium sinovi ikkala shartni ham talab qiladi (D-76; ochiq qaror).
 */
async function planAllowed(ctx: Ctx, userId: string, tier: Plan): Promise<boolean> {
  const caps = TIER_CAPABILITIES[tier];
  if (caps.includes('teacher_panel')) {
    const t = await ctx.db.prepare('SELECT 1 AS x FROM teacher_accounts WHERE user_id = ?1').bind(userId).first();
    if (t == null) return false;
  }
  if (caps.includes('lab')) {
    const m = await ctx.db
      .prepare(`SELECT 1 AS x FROM community_members WHERE user_hash = ?1 AND status = 'verified'`)
      .bind(await userHash(ctx, userId))
      .first();
    if (m == null) return false;
  }
  return true;
}

/**
 * IP tarmog'i belgisi (IPv4 /24, IPv6 /48) — HMAC, faqat limit kaliti
 * (xom IP saqlanmaydi). `cf-connecting-ip` ni Cloudflare o'zi qo'yadi.
 */
export async function ipPrefixTag(ctx: Ctx): Promise<string> {
  const ip = (ctx.req.headers.get('cf-connecting-ip') ?? 'unknown').trim().toLowerCase();
  let prefix = ip;
  const v4 = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.\d{1,3}$/.exec(ip);
  if (v4) {
    prefix = `${v4[1]}.${v4[2]}.${v4[3]}.0/24`;
  } else if (ip.includes(':')) {
    // To'liq bo'lmagan (`::`) yozuvni kengaytirib birinchi 3 guruh (/48).
    const [head, tail = ''] = ip.split('::');
    const h = head ? head.split(':') : [];
    const t = tail ? tail.split(':') : [];
    const groups = ip.includes('::') ? [...h, ...Array(Math.max(0, 8 - h.length - t.length)).fill('0'), ...t] : h;
    prefix = `${groups.slice(0, 3).map((g) => g.replace(/^0+(?=.)/, '') || '0').join(':')}::/48`;
  }
  return hex(await hmac(ctx.keys.ip, `prefix:${prefix}`)).slice(0, 32);
}

/** Sinov holati (faqat server soati bilan). */
export type TrialState = 'not_started' | 'active' | 'expired';

export const trialStateOf = (row: { expires_at: number } | null | undefined, now: number): TrialState =>
  row == null ? 'not_started' : now < row.expires_at ? 'active' : 'expired';

function blockedDomain(env: Env, canon: string): boolean {
  const domain = canon.slice(canon.lastIndexOf('@') + 1);
  return (env.TRIAL_BLOCKED_EMAIL_DOMAINS ?? '')
    .split(/[\s,]+/)
    .map((d) => d.trim().toLowerCase())
    .filter(Boolean)
    .some((d) => domain === d || domain.endsWith(`.${d}`));
}

/**
 * GET /v1/billing/trial — hisobning sinov holati (holat mashinasi):
 * `not_started` | `active` | `expired`; vaqtlar va qolgan muddat SERVER
 * soatidan. Qurilma/email bo'yicha band ekani bu yerda oshkor qilinmaydi
 * (faqat start 409 qaytaradi).
 */
export async function state(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const row = await ctx.db
    .prepare('SELECT tier, started_at, expires_at FROM pro_trials WHERE user_id = ?1 ORDER BY started_at DESC LIMIT 1')
    .bind(s.userId)
    .first<{ tier: Plan; started_at: number; expires_at: number }>();
  const st = trialStateOf(row, ctx.now);
  return json({
    state: st,
    plan: row?.tier ?? null,
    started_at: row ? new Date(row.started_at).toISOString() : null,
    expires_at: row ? new Date(row.expires_at).toISOString() : null,
    remaining_ms: row && st === 'active' ? row.expires_at - ctx.now : 0,
    server_time: new Date(ctx.now).toISOString(),
    days: TRIAL_DAYS,
    available: trialStatus(ctx),
  });
}

/**
 * POST /v1/billing/trial/start {tier, email, attestation: {platform, token, nonce, device_id?, key_id?}}.
 * Mehmon (sessiyasiz) — 401. Javob: 201 + huquqlar surati (`source: trial`).
 * Mijoz yuborgan vaqt (masalan `started_at`, `now`) e'tiborsiz — muddat
 * faqat server soatidan.
 */
export async function start(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const verifier = verifierOf(ctx);
  if (!verifier.configured(ctx.env)) throw notConfigured();
  await hit(ctx.db, `trial-user:${(await sha256Hex(s.userId)).slice(0, 32)}`, START_PER_HOUR_USER, 3600, ctx.now);
  await hit(ctx.db, `trial-ip:${ctx.ipTag}`, START_PER_HOUR_IP, 3600, ctx.now);

  const body = await readJson(ctx.req, 24 * 1024);
  const tier = parseTier(body.tier ?? body.plan);
  const att = parseAttestation(body.attestation);
  // iOS (standart) — 403, nonce sarflanmaydi, hech narsa yozilmaydi (D-75).
  if (!trialPlatformAllowed(ctx.env, att.platform)) throw platformBlocked();
  if (!configuredOn(ctx, att.platform)) throw notConfigured();

  // Tasdiqlangan email: hisob emaili (OTP yoki provayder `email_verified`
  // bilan yaratilgan `users.email_hash`) bilan bir xil bo'lishi shart.
  const email = normalizeEmail(body.email);
  if (!email) throw badRequest('invalid_email');
  const user = await ctx.db
    .prepare('SELECT email_hash, created_at FROM users WHERE id = ?1')
    .bind(s.userId)
    .first<{ email_hash: string; created_at: number }>();
  if (!user || user.email_hash !== (await emailHash(ctx, email))) throw forbidden('email_not_verified');

  const canon = canonicalEmail(email);
  if (!canon) throw badRequest('invalid_email');
  if (blockedDomain(ctx.env, canon)) throw forbidden('email_domain_not_allowed');

  if (!(await planAllowed(ctx, s.userId, tier))) throw forbidden('plan_not_allowed');

  const { access } = await loadAccess(ctx, s.userId);
  if (access.some((i) => i.source === 'store' && i.granting && (i.expiresAt == null || i.expiresAt > ctx.now))) {
    throw conflict('already_subscribed');
  }

  const emailKey = await trialKey(ctx, 'email', canon);
  const used = await ctx.db
    .prepare('SELECT 1 AS x FROM pro_trials WHERE user_id = ?1 OR email_key = ?2 LIMIT 1')
    .bind(s.userId, emailKey)
    .first();
  if (used) throw conflict('trial_already_used');

  // IP tarmog'i: yangi hisoblar va umumiy muvaffaqiyatli sinovlar (sutka).
  const prefix = await ipPrefixTag(ctx);
  const young = ctx.now - user.created_at < NEW_ACCOUNT_AGE_MS;
  await peek(ctx.db, `trial-prefix:${prefix}`, TRIALS_PER_PREFIX_DAY, 86400, ctx.now);
  if (young) await peek(ctx.db, `trial-prefix-new:${prefix}`, NEW_ACCOUNT_TRIALS_PER_PREFIX_DAY, 86400, ctx.now);

  // Nonce: bir martalik, shu hisobniki, muddati o'tmagan.
  const consumed = await ctx.db
    .prepare('DELETE FROM pro_trial_challenges WHERE nonce_hash = ?1 AND user_id = ?2 AND expires_at > ?3 RETURNING 1 AS x')
    .bind(await sha256Hex(att.nonce), s.userId, ctx.now)
    .first();
  if (!consumed) throw badRequest('invalid_nonce');

  // Attestatsiya tokeni bir marta (DeviceCheck tokeni nonce'ni bog'lamaydi;
  // Play Integrity'da nonce baribir bog'langan). Faqat xesh saqlanadi.
  const replay = await ctx.db
    .prepare('INSERT INTO pro_trial_attest_tokens (token_hash, expires_at) VALUES (?1, ?2) ON CONFLICT DO NOTHING')
    .bind(await attestTokenHash(att.token), ctx.now + ATTEST_TOKEN_RETENTION_MS)
    .run();
  if (!replay.meta.changes) throw forbidden('device_attestation_failed');

  let result: AttestationResult;
  try {
    result = await verifier.verify(ctx, att);
  } catch (e) {
    if (e instanceof ApiError && e.status >= 500) {
      console.error('attestation verify error', e.code);
      throw e.code === 'device_attestation_unavailable' ? e : new ApiError(502, 'device_attestation_unavailable');
    }
    console.error('attestation verify error', e instanceof Error ? e.name : typeof e);
    throw new ApiError(502, 'device_attestation_unavailable');
  }
  if (!result.ok || !result.subject) {
    console.error('attestation rejected', result.ok ? 'no_subject' : result.reason);
    throw forbidden('device_attestation_failed');
  }
  const deviceKey = await trialKey(ctx, 'device', `${att.platform}:${result.subject}`);
  if (result.alreadyUsed) throw conflict('trial_already_used');
  const onDevice = await ctx.db.prepare('SELECT 1 AS x FROM pro_trials WHERE device_key = ?1').bind(deviceKey).first();
  if (onDevice) throw conflict('trial_already_used');

  const id = crypto.randomUUID();
  const expires = ctx.now + TRIAL_DAYS * DAY;
  const r = await ctx.db
    .prepare(
      `INSERT INTO pro_trials (id, user_id, tier, platform, email_key, device_key, started_at, expires_at, retain_until)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9) ON CONFLICT DO NOTHING`,
    )
    .bind(id, s.userId, tier, att.platform, emailKey, deviceKey, ctx.now, expires, ctx.now + TRIAL_RETENTION_DAYS * DAY)
    .run();
  // Parallel so'rov (bir xil hisob/email/qurilma) — unikal indeks to'xtatadi.
  if (!r.meta.changes) throw conflict('trial_already_used');
  await bump(ctx.db, `trial-prefix:${prefix}`, 86400, ctx.now);
  if (young) await bump(ctx.db, `trial-prefix-new:${prefix}`, 86400, ctx.now);
  if (verifier.markUsed) {
    try {
      await verifier.markUsed(ctx, att);
    } catch (e) {
      // Bizning yozuv baribir qurilmani bog'laydi; platforma bayrog'i qo'shimcha.
      console.error('attestation markUsed error', e instanceof Error ? e.name : typeof e);
    }
  }
  // Jurnal: hisob id, daraja, muddat. Email/qurilma (hatto HMAC) yozilmaydi.
  await audit(ctx, s.userId, 'pro_trial_started', id, {
    tier,
    until: new Date(expires).toISOString(),
    platform: att.platform,
  });
  return snapshot(ctx, s.userId, false, 201);
}

/**
 * Hisob o'chirilganda (auth.ts `deleteUserData`): sinov yozuvi qoladi, faqat
 * hisobga bog'lanish uziladi (D-74 (d)). Nonce'lar o'chiriladi.
 */
export const trialDeleteStatements = (db: D1Database, userId: string, now: number): D1PreparedStatement[] => [
  db.prepare('UPDATE pro_trials SET user_id = NULL, account_deleted_at = ?2 WHERE user_id = ?1').bind(userId, now),
  db.prepare('DELETE FROM pro_trial_challenges WHERE user_id = ?1').bind(userId),
];

/** Kunlik tozalash (faqat bayroq yoqilganda): eskirgan nonce va saqlash muddati o'tgan yozuvlar. */
export const trialCleanupStatements = (db: D1Database, now: number): D1PreparedStatement[] => [
  db.prepare('DELETE FROM pro_trial_challenges WHERE expires_at < ?1').bind(now),
  db.prepare('DELETE FROM pro_trial_attest_tokens WHERE expires_at < ?1').bind(now),
  db.prepare('DELETE FROM pro_trials WHERE retain_until < ?1').bind(now),
];
