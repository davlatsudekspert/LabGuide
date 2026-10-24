// 30 kunlik bepul sinov — BIR TELEFONGA BIR MARTA (D-74). INERT:
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
//     mutaxassis); aks holda 403 `plan_not_allowed`;
// (g) muddat huquqni hal qilishda (`source: trial`) hisobga olinadi va
//     pullik obunani hech qachon bosib o'tmaydi (billing.ts `resolveAccess`).

import { audit, emailHash, normalizeEmail, requireSession } from './auth';
import { loadAccess, PLANS, type Plan, snapshot } from './billing';
import { userHash } from './community';
import type { Ctx } from './context';
import { base64url, hex, hmac, randomBytes, sha256Hex } from './crypto';
import { ApiError, badRequest, conflict, type Env, forbidden, json, readJson } from './http';
import { hit } from './ratelimit';

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
 * Qurilma attestatsiyasini tekshiruvchi (server). Haqiqiy amalga oshirish
 * (Apple App Attest / DeviceCheck, Google Play Integrity) bu tarmoqda YO'Q:
 * ular Apple/Google kalitlari va ilovada native plaginlarni talab qiladi.
 */
export interface DeviceAttestationVerifier {
  /** Kalitlar sozlanganmi. `false` → 503 `device_attestation_not_configured`. */
  configured(env: Env): boolean;
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
export function trialStatus(ctx: Ctx): { android: boolean; ios: boolean; platforms: AttestationPlatform[] } {
  const att = verifierOf(ctx).configured(ctx.env);
  return {
    android: att && trialPlatformAllowed(ctx.env, 'android'),
    ios: att && trialPlatformAllowed(ctx.env, 'ios'),
    platforms: trialPlatforms(ctx.env),
  };
}

const platformBlocked = () => new ApiError(403, 'trial_not_available_on_platform');

function notConfigured(): ApiError {
  return new ApiError(503, 'device_attestation_not_configured');
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
  return { platform: o.platform, token: o.token, keyId, nonce: o.nonce };
}

/**
 * Daraja hisob uchun ruxsat etilganmi (D-74 (f)). Qaror serverdagi
 * yozuvlardan: Ustoz — `teacher_accounts` (serverda ustoz sifatida
 * ro'yxatdan o'tgan); Mutaxassis — hamjamiyatda hujjat bilan tasdiqlangan
 * mutaxassis (`community_members.status = 'verified'`). Talaba — har hisob.
 */
async function planAllowed(ctx: Ctx, userId: string, tier: Plan): Promise<boolean> {
  if (tier === 'student') return true;
  if (tier === 'teacher') {
    return (await ctx.db.prepare('SELECT 1 AS x FROM teacher_accounts WHERE user_id = ?1').bind(userId).first()) != null;
  }
  const m = await ctx.db
    .prepare(`SELECT 1 AS x FROM community_members WHERE user_hash = ?1 AND status = 'verified'`)
    .bind(await userHash(ctx, userId))
    .first();
  return m != null;
}

/**
 * POST /v1/billing/trial/start {tier, email, attestation: {platform, token, nonce, key_id?}}.
 * Mehmon (sessiyasiz) — 401. Javob: 201 + huquqlar surati (`source: trial`).
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

  // Tasdiqlangan email: hisob emaili (OTP yoki provayder `email_verified`
  // bilan yaratilgan `users.email_hash`) bilan bir xil bo'lishi shart.
  const email = normalizeEmail(body.email);
  if (!email) throw badRequest('invalid_email');
  const user = await ctx.db
    .prepare('SELECT email_hash FROM users WHERE id = ?1')
    .bind(s.userId)
    .first<{ email_hash: string }>();
  if (!user || user.email_hash !== (await emailHash(ctx, email))) throw forbidden('email_not_verified');

  if (!(await planAllowed(ctx, s.userId, tier))) throw forbidden('plan_not_allowed');

  const { access } = await loadAccess(ctx, s.userId);
  if (access.some((i) => i.source === 'store' && i.granting && (i.expiresAt == null || i.expiresAt > ctx.now))) {
    throw conflict('already_subscribed');
  }

  const canon = canonicalEmail(email);
  if (!canon) throw badRequest('invalid_email');
  const emailKey = await trialKey(ctx, 'email', canon);
  const used = await ctx.db
    .prepare('SELECT 1 AS x FROM pro_trials WHERE user_id = ?1 OR email_key = ?2 LIMIT 1')
    .bind(s.userId, emailKey)
    .first();
  if (used) throw conflict('trial_already_used');

  // Nonce: bir martalik, shu hisobniki, muddati o'tmagan.
  const consumed = await ctx.db
    .prepare('DELETE FROM pro_trial_challenges WHERE nonce_hash = ?1 AND user_id = ?2 AND expires_at > ?3 RETURNING 1 AS x')
    .bind(await sha256Hex(att.nonce), s.userId, ctx.now)
    .first();
  if (!consumed) throw badRequest('invalid_nonce');

  let result: AttestationResult;
  try {
    result = await verifier.verify(ctx, att);
  } catch (e) {
    console.error('attestation verify error', e instanceof Error ? e.name : typeof e);
    throw new ApiError(502, 'device_attestation_unavailable');
  }
  if (!result.ok || !result.subject) throw forbidden('device_attestation_failed');
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
  db.prepare('DELETE FROM pro_trials WHERE retain_until < ?1').bind(now),
];
