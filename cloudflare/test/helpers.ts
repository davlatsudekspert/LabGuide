import { env } from 'cloudflare:test';
import { createApp } from '../src/app';
import type { CodeSender } from '../src/email';
import type { Env } from '../src/http';

export interface Sent {
  to: string;
  code: string;
}

let serverSeq = 0;

/** Ilova + soxta pochta qutisi + boshqariladigan soat. */
export function makeServer(overrides: Partial<Env> = {}) {
  const outbox: Sent[] = [];
  let mailMode: 'sent' | 'not_configured' | 'failed' = 'sent';
  // Har server soati oldingisidan 2 soat keyin boshlanadi: testlar bir-birining
  // kodlari va limitlariga (umumiy D1) ta'sir qilmaydi.
  const clock = { now: Date.UTC(2026, 9, 10, 9, 0, 0) + ++serverSeq * 2 * 3600_000 };
  const sender: CodeSender = async (_env, to, code) => {
    if (mailMode !== 'sent') return mailMode;
    outbox.push({ to, code });
    return 'sent';
  };
  const app = createApp({ sendCode: sender, now: () => clock.now });
  const testEnv = { ...env, ...overrides } as Env;
  let ipSeq = 0;

  async function call(
    method: string,
    path: string,
    opts: { token?: string; body?: unknown; ip?: string; headers?: Record<string, string>; raw?: string } = {},
  ) {
    const headers: Record<string, string> = {
      'cf-connecting-ip': opts.ip ?? '203.0.113.7',
      ...(opts.headers ?? {}),
    };
    if (opts.token) headers.authorization = `Bearer ${opts.token}`;
    let body: string | undefined;
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

  return {
    app,
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
