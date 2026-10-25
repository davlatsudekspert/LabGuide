// Qurilma attestatsiyasi — haqiqiy tekshiruvchilar (7 kunlik sinov, D-74/D-77).
//
// INERT: Worker secretlari bo'lmasa `configured()` = false → sinov
// `503 trial_unavailable` (ilova sinov tugmasini ko'rsatmaydi). Hech qanday
// kalit repoda yo'q; hammasi env bindinglaridan (docs/PAID_BACKEND_DEPLOY_CHECKLIST.md).
//
// ANDROID — Google Play Integrity (classic request, nonce bilan):
//   Hujjat: https://developer.android.com/google/play/integrity/classic
//           https://developer.android.com/google/play/integrity/verdicts
//   * Server: service account JWT (RS256, WebCrypto) → OAuth token (scope
//     `playintegrity`) → POST playintegrity.googleapis.com/v1/{package}:decodeIntegrityToken.
//   * Tekshiriladi: requestPackageName, nonce = H(server nonce, device_id),
//     timestampMillis yangiligi, appRecognitionVerdict = PLAY_RECOGNIZED,
//     packageName, imzo sertifikati SHA-256 (PLAY_INTEGRITY_CERT_SHA256),
//     deviceRecognitionVerdict ⊇ MEETS_DEVICE_INTEGRITY (yoki STRONG),
//     appLicensingVerdict = LICENSED.
//   * "Bir qurilmaga bir marta": Play Integrity standart/classic verdikti
//     DOIMIY QURILMA ID'SI BERMAYDI. Shuning uchun ilova ANDROID_ID ni
//     (Android 8+: ilova imzo kaliti + foydalanuvchi + qurilma bo'yicha;
//     ilovani o'chirib qayta o'rnatishda O'ZGARMAYDI, zavod sozlamasiga
//     qaytarishda (factory reset) va boshqa foydalanuvchi profilida
//     O'ZGARADI) `device_id` sifatida yuboradi va uni Integrity nonce'iga
//     bog'laydi: nonce = base64url(SHA-256("labguide-trial-v1|" + nonce + "|" + device_id)).
//     Tanilgan (PLAY_RECOGNIZED) ilova shu bog'lashni o'zgartirmasdan
//     hisoblaydi, shuning uchun device_id ni almashtirish uchun ilovani
//     buzish (→ UNRECOGNIZED) yoki root/hook (→ odatda MEETS_DEVICE_INTEGRITY
//     yo'qoladi) kerak. Qolgan xavf: factory reset = yangi ANDROID_ID = yangi
//     sinov (docs/PRO_TRIAL_ABUSE_NOTES.md §4). Play "device recall" (beta)
//     zavod sozlamasidan keyin ham saqlanadigan bitlarni va'da qiladi, lekin
//     uning API shakli shu ishda rasmiy hujjat bilan TEKSHIRILMADI — kod yo'q.
//
// iOS — Apple DeviceCheck (ikki bit, qurilma bo'yicha, Apple serverida):
//   Hujjat: https://developer.apple.com/documentation/devicecheck/accessing-and-modifying-per-device-data
//   * Server: ES256 JWT (iss = Team ID, kid = Key ID, .p8 kalit) →
//     POST api.devicecheck.apple.com/v1/query_two_bits va /v1/update_two_bits.
//   * Bit semantikasi: bit0 = "shu qurilmada LabGuide sinovi ishlatilgan",
//     bit1 = zaxira (doim 0). Sinov berilgach `markUsed` bit0=1 yozadi.
//     Apple bitlari ilova qayta o'rnatilganda saqlanadi (Apple'ning maqsadi
//     shu). Zavod sozlamasidan keyin saqlanishi rasmiy hujjat bilan shu ishda
//     TEKSHIRILMADI (NOT VERIFIED).
//   * DeviceCheck tokeni nonce'ni bog'lamaydi: takroriy ishlatishdan
//     `pro_trial_attest_tokens` (token SHA-256, bir martalik) himoya qiladi.
//   * Nega App Attest emas: App Attest kaliti ilova qayta o'rnatilganda
//     YANGILANADI (doimiy belgi bermaydi) va uning to'liq tekshiruvi (CBOR,
//     x509 zanjiri App Attest Root CA gacha, counter) shu ishda yozilmadi
//     (NOT DONE). "Bir marta" uchun doimiy mexanizm — DeviceCheck bitlari.

import type { Ctx } from './context';
import { base64url, sha256Hex } from './crypto';
import { ApiError, type Env } from './http';
import { b64urlBytes, googleServiceToken, parseServiceAccount, signJwt } from './jwtsign';
import type { AttestationInput, AttestationPlatform, AttestationResult, DeviceAttestationVerifier } from './trial';

const DEFAULT_PACKAGE = 'uz.labguide.app';
const PLAY_INTEGRITY_SCOPE = 'https://www.googleapis.com/auth/playintegrity';
/** Integrity tokeni server nonce'idan keyin shu vaqt ichida olingan bo'lishi kerak. */
export const INTEGRITY_MAX_AGE_MS = 10 * 60_000;
/** Qurilma soati biroz oldinda bo'lishi mumkin. */
const INTEGRITY_FUTURE_SKEW_MS = 60_000;

const fetchOf = (ctx: Ctx): typeof fetch => ctx.deps.fetch ?? fetch;
const unavailable = () => new ApiError(502, 'device_attestation_unavailable');
const fail = (reason: string): AttestationResult => ({ ok: false, reason });

/** `device_id` formati (ANDROID_ID — 16 hex; iOS Keychain UUID). */
export const DEVICE_ID_RE = /^[A-Za-z0-9._:-]{8,128}$/;

/**
 * Integrity nonce'i (ilova va server bir xil hisoblaydi):
 * base64url(SHA-256("labguide-trial-v1|<server nonce>|<device_id>")), padding'siz.
 */
export async function integrityNonce(serverNonce: string, deviceId: string): Promise<string> {
  const d = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(`labguide-trial-v1|${serverNonce}|${deviceId}`));
  return base64url(new Uint8Array(d));
}

/** Sertifikat barmoq izi: hex (`AB:CD:..` Play Console ko'rinishi) yoki base64url → kichik hex. */
export function normalizeDigest(raw: string): string | null {
  const s = raw.trim();
  const hexOnly = s.replace(/:/g, '');
  if (/^[0-9a-fA-F]{64}$/.test(hexOnly)) return hexOnly.toLowerCase();
  try {
    const b = b64urlBytes(s.replace(/=+$/, ''));
    if (b.length !== 32) return null;
    return [...b].map((x) => x.toString(16).padStart(2, '0')).join('');
  } catch {
    return null;
  }
}

// ------------------------------------------------------------ Play Integrity
export const playIntegrityConfigured = (env: Env) =>
  Boolean((env.PLAY_INTEGRITY_SERVICE_ACCOUNT || env.GOOGLE_PLAY_SERVICE_ACCOUNT) && configuredDigests(env).length > 0);

function configuredDigests(env: Env): string[] {
  return (env.PLAY_INTEGRITY_CERT_SHA256 ?? '')
    .split(/[\s,]+/)
    .map((d) => (d ? normalizeDigest(d) : null))
    .filter((d): d is string => d != null);
}

interface IntegrityPayload {
  requestDetails?: { requestPackageName?: string; nonce?: string; timestampMillis?: string | number };
  appIntegrity?: { appRecognitionVerdict?: string; packageName?: string; certificateSha256Digest?: string[]; versionCode?: string };
  deviceIntegrity?: { deviceRecognitionVerdict?: string[] };
  accountDetails?: { appLicensingVerdict?: string };
}

/**
 * Decode qilingan Play Integrity verdiktini tekshiradi (sof funksiya —
 * testlar sintetik yuklamalar bilan chaqiradi).
 */
export async function checkIntegrityVerdict(
  p: IntegrityPayload,
  opts: { packageName: string; digests: string[]; serverNonce: string; deviceId: string; now: number },
): Promise<AttestationResult> {
  const rd = p.requestDetails ?? {};
  if (rd.requestPackageName !== opts.packageName) return fail('package_mismatch');
  const expected = await integrityNonce(opts.serverNonce, opts.deviceId);
  if (typeof rd.nonce !== 'string' || rd.nonce.replace(/=+$/, '') !== expected) return fail('nonce_mismatch');
  const ts = Number(rd.timestampMillis);
  if (!Number.isFinite(ts) || ts > opts.now + INTEGRITY_FUTURE_SKEW_MS || ts < opts.now - INTEGRITY_MAX_AGE_MS) {
    return fail('stale_token');
  }
  const app = p.appIntegrity ?? {};
  if (app.appRecognitionVerdict !== 'PLAY_RECOGNIZED') return fail('app_not_recognized');
  if (app.packageName !== opts.packageName) return fail('package_mismatch');
  const certs = (app.certificateSha256Digest ?? []).map(normalizeDigest).filter((d): d is string => d != null);
  if (!certs.some((c) => opts.digests.includes(c))) return fail('certificate_mismatch');
  const device = p.deviceIntegrity?.deviceRecognitionVerdict ?? [];
  if (!device.includes('MEETS_DEVICE_INTEGRITY') && !device.includes('MEETS_STRONG_INTEGRITY')) {
    return fail('device_integrity');
  }
  if (p.accountDetails?.appLicensingVerdict !== 'LICENSED') return fail('unlicensed');
  return { ok: true, subject: `aid:${opts.deviceId}` };
}

export const PlayIntegrityVerifier: DeviceAttestationVerifier = {
  configured: playIntegrityConfigured,
  configuredFor: (env, platform) => platform === 'android' && playIntegrityConfigured(env),
  async verify(ctx: Ctx, input: AttestationInput): Promise<AttestationResult> {
    if (input.platform !== 'android') return fail('wrong_platform');
    if (!input.deviceId || !DEVICE_ID_RE.test(input.deviceId)) return fail('device_id_required');
    if (!/^[A-Za-z0-9_\-.=]{20,8192}$/.test(input.token)) return fail('invalid_token');
    const pkg = ctx.env.GOOGLE_PLAY_PACKAGE || DEFAULT_PACKAGE;
    const sa = parseServiceAccount(ctx.env.PLAY_INTEGRITY_SERVICE_ACCOUNT || ctx.env.GOOGLE_PLAY_SERVICE_ACCOUNT, 'attestation_key_invalid');
    const access = await googleServiceToken(ctx, sa, PLAY_INTEGRITY_SCOPE, {
      keyInvalid: 'attestation_key_invalid',
      authFailed: 'attestation_auth_failed',
      unavailable: 'device_attestation_unavailable',
    });
    let res: Response;
    try {
      res = await fetchOf(ctx)(`https://playintegrity.googleapis.com/v1/${encodeURIComponent(pkg)}:decodeIntegrityToken`, {
        method: 'POST',
        headers: { authorization: `Bearer ${access}`, 'content-type': 'application/json' },
        body: JSON.stringify({ integrity_token: input.token }),
      });
    } catch {
      throw unavailable();
    }
    // 400 — token buzilgan / boshqa ilovaniki: rad (qayta urinish foydasiz).
    if (res.status === 400) return fail('invalid_token');
    if (res.status === 401 || res.status === 403) throw new ApiError(503, 'attestation_auth_failed');
    if (!res.ok) throw unavailable();
    const body = (await res.json().catch(() => null)) as { tokenPayloadExternal?: IntegrityPayload } | null;
    if (!body?.tokenPayloadExternal) return fail('invalid_token');
    return checkIntegrityVerdict(body.tokenPayloadExternal, {
      packageName: pkg,
      digests: configuredDigests(ctx.env),
      serverNonce: input.nonce,
      deviceId: input.deviceId,
      now: ctx.now,
    });
  },
};

// ------------------------------------------------------------ DeviceCheck
export const deviceCheckConfigured = (env: Env) =>
  Boolean(env.APPLE_DEVICECHECK_KEY_ID && env.APPLE_DEVICECHECK_TEAM_ID && env.APPLE_DEVICECHECK_PRIVATE_KEY);

const deviceCheckHost = (env: Env) =>
  env.APPLE_DEVICECHECK_ENV === 'development' ? 'https://api.development.devicecheck.apple.com' : 'https://api.devicecheck.apple.com';

async function deviceCheckJwt(ctx: Ctx): Promise<string> {
  return signJwt(
    'ES256',
    ctx.env.APPLE_DEVICECHECK_PRIVATE_KEY!,
    { kid: ctx.env.APPLE_DEVICECHECK_KEY_ID },
    { iss: ctx.env.APPLE_DEVICECHECK_TEAM_ID, iat: Math.floor(ctx.now / 1000) },
    'attestation_key_invalid',
  );
}

/** DeviceCheck tokeni — standart base64 (Apple `DCDevice.generateToken` → Data). */
const DEVICECHECK_TOKEN_RE = /^[A-Za-z0-9+/=]{16,8192}$/;

async function deviceCheckCall(ctx: Ctx, path: string, body: Record<string, unknown>): Promise<Response> {
  const jwt = await deviceCheckJwt(ctx);
  try {
    return await fetchOf(ctx)(`${deviceCheckHost(ctx.env)}${path}`, {
      method: 'POST',
      headers: { authorization: `Bearer ${jwt}`, 'content-type': 'application/json' },
      body: JSON.stringify({ ...body, transaction_id: crypto.randomUUID(), timestamp: ctx.now }),
    });
  } catch {
    throw unavailable();
  }
}

export const DeviceCheckVerifier: DeviceAttestationVerifier = {
  configured: deviceCheckConfigured,
  configuredFor: (env, platform) => platform === 'ios' && deviceCheckConfigured(env),
  async verify(ctx: Ctx, input: AttestationInput): Promise<AttestationResult> {
    if (input.platform !== 'ios') return fail('wrong_platform');
    if (!input.deviceId || !DEVICE_ID_RE.test(input.deviceId)) return fail('device_id_required');
    if (!DEVICECHECK_TOKEN_RE.test(input.token)) return fail('invalid_token');
    const res = await deviceCheckCall(ctx, '/v1/query_two_bits', { device_token: input.token });
    if (res.status === 400) return fail('invalid_token');
    if (res.status === 401 || res.status === 403) throw new ApiError(503, 'attestation_auth_failed');
    if (!res.ok) throw unavailable();
    const text = await res.text();
    let bit0 = false;
    // Hech qachon yozilmagan qurilma: 200 + "Failed to find bit state" (JSON emas).
    if (text.trim() && !/failed to find bit state/i.test(text)) {
      let j: { bit0?: unknown };
      try {
        j = JSON.parse(text) as { bit0?: unknown };
      } catch {
        throw unavailable();
      }
      bit0 = j.bit0 === true;
    }
    return { ok: true, subject: `kc:${input.deviceId}`, alreadyUsed: bit0 };
  },
  async markUsed(ctx: Ctx, input: AttestationInput): Promise<void> {
    const res = await deviceCheckCall(ctx, '/v1/update_two_bits', { device_token: input.token, bit0: true, bit1: false });
    if (!res.ok) throw new Error(`devicecheck update ${res.status}`);
  },
};

// ------------------------------------------------------------ marshrutlash
/**
 * Production tekshiruvchisi (index.ts): platforma bo'yicha Play Integrity /
 * DeviceCheck. Har biri o'z secretlarisiz — "sozlanmagan".
 */
export function platformVerifier(
  byPlatform: Record<AttestationPlatform, DeviceAttestationVerifier> = { android: PlayIntegrityVerifier, ios: DeviceCheckVerifier },
): DeviceAttestationVerifier {
  const forP = (env: Env, p: AttestationPlatform) => byPlatform[p].configuredFor?.(env, p) ?? byPlatform[p].configured(env);
  return {
    configured: (env) => forP(env, 'android') || forP(env, 'ios'),
    configuredFor: forP,
    verify: (ctx, input) => byPlatform[input.platform].verify(ctx, input),
    markUsed: async (ctx, input) => {
      await byPlatform[input.platform].markUsed?.(ctx, input);
    },
  };
}

/** Attestatsiya tokenining takroriy ishlatilishini aniqlash kaliti (xom token saqlanmaydi). */
export const attestTokenHash = (token: string) => sha256Hex(`attest:${token}`);
