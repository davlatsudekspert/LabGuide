import type { Keys } from './crypto';
import type { CodeSender } from './email';
import type { Env } from './http';
import type { Platform, StoreVerifier } from './billing';
import type { DeviceAttestationVerifier } from './trial';

export interface Deps {
  sendCode: CodeSender;
  /** Unix ms (testlarda soat almashtiriladi). */
  now: () => number;
  /**
   * Workers AI chaqiruvi (testlarda soxta). Standart: `env.AI.run`.
   * Kiruvchi ma'lumot (hujjat rasmi) hech qayerga yozilmaydi.
   */
  runAi?: (env: Env, model: string, input: Record<string, unknown>) => Promise<unknown>;
  /**
   * Tashqi so'rovlar (App Store / Google Play API). Standart: global `fetch`;
   * testlarda soxta — haqiqiy do'konga hech qachon murojaat qilinmaydi.
   */
  fetch?: typeof fetch;
  /**
   * Bepul sinov uchun qurilma attestatsiyasi tekshiruvchisi (D-74). Standart:
   * YO'Q → `503 device_attestation_not_configured`. Production (index.ts) da
   * hech narsa ulanmagan; testlarda — soxta (test/fake_attestation.ts).
   */
  attestation?: DeviceAttestationVerifier;
  /**
   * Do'kon xaridi tekshiruvchilari (D-75). Standart: haqiqiy App Store Server
   * API / Play Developer API tekshiruvchilari (kalitsiz — 503
   * `store_verifier_not_configured`); testlarda soxta (test/fake_store.ts).
   */
  storeVerifiers?: Partial<Record<Platform, StoreVerifier>>;
}

export interface Ctx {
  req: Request;
  env: Env;
  db: D1Database;
  keys: Keys;
  deps: Deps;
  now: number;
  /** HMAC(IP) ning qisqa ko'rinishi — faqat limit kaliti, saqlanmaydi. */
  ipTag: string;
}

export interface Session {
  userId: string;
  tokenHash: string;
  aal: 'aal1' | 'aal2';
  role: string;
  language: string;
  /** Kirish usuli: otp (email kodi) | google | apple. */
  via: string;
  /** Sessiya ochilgan vaqt (ms). */
  createdAt: number;
  /** Shu sessiyada oxirgi yangi tasdiq (email kodi / TOTP / step-up); NULL — yo'q. */
  adminAuthAt: number | null;
  /** Oxirgi admin so'rovi (harakatsizlik muddati uchun). */
  adminSeenAt: number | null;
  /** Oxirgi step-up tasdig'i (xavfli admin amallari uchun). */
  stepUpAt: number | null;
  /** Shu step-up bilan bajarilgan bir martalik amal turlari (`cls,` ro'yxati). */
  stepUpUsed: string;
}

export const iso = (ms: number | null | undefined): string | null =>
  ms == null ? null : new Date(ms).toISOString();
