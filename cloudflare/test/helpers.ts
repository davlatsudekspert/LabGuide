import { env } from 'cloudflare:test';
import { createApp } from '../src/app';
import type { CodeSender } from '../src/email';
import { totpAt } from '../src/crypto';
import type { Env } from '../src/http';
import type { Platform, StoreVerifier } from '../src/billing';
import type { DeviceAttestationVerifier } from '../src/trial';

export function unbase32(s: string): Uint8Array {
  const A = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  let bits = 0;
  let value = 0;
  const out: number[] = [];
  for (const c of s) {
    value = (value << 5) | A.indexOf(c);
    bits += 5;
    if (bits >= 8) {
      out.push((value >>> (bits - 8)) & 255);
      bits -= 8;
    }
  }
  return new Uint8Array(out);
}

export type FetchFn = (url: string, init?: RequestInit) => Promise<Response>;

export type AiFn = (model: string, input: Record<string, unknown>) => Promise<unknown>;

export interface Sent {
  to: string;
  code: string;
  /** Xat tili (`sendCode` ga berilgan). */
  lang?: string;
}

let serverSeq = 0;
/**
 * Eski testlar uchun: `403 step_up_required` kelsa, xuddi ilovadagidek bir
 * marta step-up qilib so'rovni qaytaradi (sanaladi: `autoStepUps`). Standart
 * o'chiq; step-up ning o'z testlari (stepup.test.ts) uni yoqmaydi.
 */
let autoStepUp = false;
export const setAutoStepUp = (on: boolean) => {
  autoStepUp = on;
};
const totpSecrets = new Map<string, Uint8Array>();

/** Ilova + soxta pochta qutisi + boshqariladigan soat. */
export function makeServer(overrides: Partial<Env> = {}) {
  const outbox: Sent[] = [];
  let mailMode: 'sent' | 'not_configured' | 'failed' = 'sent';
  // Har server soati oldingisidan 2 soat keyin boshlanadi: testlar bir-birining
  // kodlari va limitlariga (umumiy D1) ta'sir qilmaydi.
  const clock = { now: Date.UTC(2026, 9, 10, 9, 0, 0) + ++serverSeq * 2 * 3600_000 };
  const sender: CodeSender = async (_env, to, code, lang) => {
    if (mailMode !== 'sent') return mailMode;
    outbox.push({ to, code, lang });
    return 'sent';
  };
  // Workers AI soxtasi: haqiqiy AI hech qachon chaqirilmaydi.
  const aiCalls: { model: string; input: Record<string, unknown> }[] = [];
  let aiImpl: AiFn = async () => {
    throw new Error('AI not mocked in this test');
  };
  // Do'kon API'lari (App Store / Google Play) soxtasi: haqiqiy tarmoq yo'q.
  const fetchCalls: { url: string; init?: RequestInit }[] = [];
  let fetchImpl: FetchFn = async (url) => {
    throw new Error(`fetch not mocked in this test: ${url}`);
  };
  // Qurilma attestatsiyasi (D-74): standart — yo'q (503); testda soxta.
  let attestationImpl: DeviceAttestationVerifier | undefined;
  // Do'kon tekshiruvchilari (D-75): standart — haqiqiy (soxta fetch bilan); testda soxta.
  const storeVerifiers: Partial<Record<Platform, StoreVerifier>> = {};
  const app = createApp({
    get attestation() {
      return attestationImpl;
    },
    storeVerifiers,
    sendCode: sender,
    now: () => clock.now,
    fetch: (async (input: RequestInfo | URL, init?: RequestInit) => {
      const url = typeof input === 'string' ? input : input instanceof URL ? input.toString() : input.url;
      fetchCalls.push({ url, init });
      return fetchImpl(url, init);
    }) as typeof fetch,
    runAi: async (_env, model, input) => {
      aiCalls.push({ model, input });
      return aiImpl(model, input);
    },
  });
  const testEnv = { ...env, ...overrides } as Env;
  let ipSeq = 0;
  const tokenEmails = new Map<string, string>();
  const autoStepUps: { method: string; path: string; action: string }[] = [];

  async function call(
    method: string,
    path: string,
    opts: {
      token?: string;
      body?: unknown;
      ip?: string;
      headers?: Record<string, string>;
      raw?: string | Uint8Array;
    } = {},
  ) {
    const headers: Record<string, string> = {
      'cf-connecting-ip': opts.ip ?? '203.0.113.7',
      ...(opts.headers ?? {}),
    };
    if (opts.token) headers.authorization = `Bearer ${opts.token}`;
    let body: string | Uint8Array | undefined;
    if (opts.raw !== undefined) {
      body = opts.raw;
    } else if (opts.body !== undefined) {
      body = JSON.stringify(opts.body);
      headers['content-type'] = 'application/json';
    }
    const res = await app.fetch(
      new Request(`https://api.test${path}`, { method, headers, body }),
      testEnv,
    );
    const text = await res.text();
    let data: any = null;
    try {
      data = text ? JSON.parse(text) : null;
    } catch {
      data = text;
    }
    if (autoStepUp && res.status === 403 && data?.error === 'step_up_required' && opts.token && tokenEmails.has(opts.token)) {
      autoStepUps.push({ method, path, action: data.action ?? data.reason });
      await stepUp(opts.token, tokenEmails.get(opts.token)!);
      return call(method, path, opts);
    }
    return { status: res.status, data, headers: res.headers, text };
  }

  /** Kod so'raydi, qutidan oladi va tasdiqlaydi. Har kirish — alohida IP. */
  async function signIn(email: string, profile?: { role?: string; language?: string }) {
    const ip = `198.51.100.${++ipSeq}`;
    const req = await call('POST', '/v1/auth/otp/request', { body: { email }, ip });
    if (req.status !== 200) throw new Error(`request ${req.status} ${req.text}`);
    const code = outbox.filter((m) => m.to === email.trim().toLowerCase()).at(-1)!.code;
    const v = await call('POST', '/v1/auth/otp/verify', { body: { email, code }, ip });
    if (v.status !== 200) throw new Error(`verify ${v.status} ${v.text}`);
    const token = v.data.token as string;
    tokenEmails.set(token, email.trim().toLowerCase());
    if (profile) {
      const p = await call('PUT', '/v1/me/profile', { token, body: profile });
      if (p.status !== 200) throw new Error(`profile ${p.status}`);
    }
    return { token, userId: v.data.user_id as string };
  }

  /** Kirish + `POST /v1/me/teacher` (ustoz sifatida ro'yxatdan o'tish). */
  async function signInTeacher(email: string) {
    const u = await signIn(email, { role: 'teacher' });
    const r = await call('POST', '/v1/me/teacher', { token: u.token });
    if (r.status !== 200) throw new Error(`teacher ${r.status} ${r.text}`);
    return u;
  }

  /** Admin: allowlist email + OTP + TOTP (aal2). */
  async function signInAdmin(email = 'boss@example.test') {
    const u = await signIn(email);
    const en = await call('POST', '/v1/auth/mfa/enroll', { token: u.token });
    let secret: Uint8Array;
    if (en.status === 200) {
      secret = unbase32(en.data.secret);
      totpSecrets.set(email, secret);
    } else if (en.status === 403 && totpSecrets.has(email)) {
      secret = totpSecrets.get(email)!;
      clock.now += 31_000; // TOTP qadami qayta ishlatilmaydi
    } else {
      throw new Error(`enroll ${en.status} ${en.text}`);
    }
    const code = await totpAt(secret, Math.floor(clock.now / 30_000));
    const v = await call('POST', '/v1/auth/mfa/verify', { token: u.token, body: { code } });
    if (v.status !== 200) throw new Error(`mfa ${v.status} ${v.text}`);
    return u;
  }

  /**
   * Admin step-up (stepup.ts): TOTP faktori bo'lsa — TOTP (soat bir qadam
   * oldinga), aks holda email kodi (qutidan). Qayta yuborish limiti — soat oldinga.
   */
  async function stepUp(token: string, email: string) {
    let r = await call('POST', '/v1/auth/step-up', { token });
    if (r.status === 429 && typeof r.data?.retry_after === 'number' && r.data.retry_after <= 60) {
      clock.now += r.data.retry_after * 1000;
      r = await call('POST', '/v1/auth/step-up', { token });
    }
    if (r.status !== 200) throw new Error(`step-up ${r.status} ${r.text}`);
    let code: string;
    if (r.data.method === 'totp') {
      const secret = totpSecrets.get(email) ?? totpSecrets.get(email.trim().toLowerCase());
      if (!secret) throw new Error('no TOTP secret for ' + email);
      clock.now += 31_000;
      code = await totpAt(secret, Math.floor(clock.now / 30_000));
    } else {
      code = outbox.filter((m) => m.to === email.trim().toLowerCase()).at(-1)!.code;
    }
    const v = await call('POST', '/v1/auth/step-up/verify', { token, body: { code } });
    if (v.status !== 200) throw new Error(`step-up verify ${v.status} ${v.text}`);
    return r.data.method as 'totp' | 'email';
  }

  return {
    app,
    stepUp,
    autoStepUps,
    aiCalls,
    fetchCalls,
    setFetch: (fn: FetchFn) => {
      fetchImpl = fn;
    },
    setAi: (fn: AiFn) => {
      aiImpl = fn;
    },
    setAttestation: (v: DeviceAttestationVerifier | undefined) => {
      attestationImpl = v;
    },
    setStoreVerifier: (p: Platform, v: StoreVerifier | undefined) => {
      if (v) storeVerifiers[p] = v;
      else delete storeVerifiers[p];
    },
    signInAdmin,
    signInTeacher,
    env: testEnv,
    outbox,
    clock,
    call,
    signIn,
    setMail: (m: typeof mailMode) => {
      mailMode = m;
    },
  };
}

let seq = 0;
/** Testlar orasida to'qnashmaydigan email. */
export const uniqueEmail = (p = 'user') => `${p}.${Date.now().toString(36)}.${++seq}@example.test`;
