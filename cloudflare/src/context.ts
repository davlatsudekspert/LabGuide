import type { Keys } from './crypto';
import type { CodeSender } from './email';
import type { Env } from './http';

export interface Deps {
  sendCode: CodeSender;
  /** Unix ms (testlarda soat almashtiriladi). */
  now: () => number;
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
}

export const iso = (ms: number | null | undefined): string | null =>
  ms == null ? null : new Date(ms).toISOString();
