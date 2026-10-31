// Ilova siyosati: "yangilang" / "majburiy yangilash" (egasi qarori 2026-10-31).
// GET /v1/app-policy?platform=android|ios&version=0.1.1 — ochiq, hisobsiz, hech narsa saqlanmaydi.
//
// Siyosat Worker o'zgaruvchilaridan olinadi (deploy bilan o'zgaradi, ilova qayta chiqmaydi):
//   LG_MIN_APP_VERSION     shundan eski versiyalarda yangilash MAJBURIY (bo'sh — hech kim majburlanmaydi)
//   LG_LATEST_APP_VERSION  shundan eski versiyalarga yangilash TAKLIF qilinadi (yopsa bo'ladi)
//   LG_UPDATE_URL_ANDROID / LG_UPDATE_URL_IOS  yangilash havolasi (https; bo'sh bo'lsa ilovada tugma chiqmaydi)
// Xato sozlama (noto'g'ri versiya/havola) e'tiborsiz qoldiriladi: sozlama xatosi foydalanuvchini HECH QACHON
// qulflamaydi (fail open). Siyosat bo'lmagan eski ilovalar bu yo'ldan so'ramaydi — ularga ta'sir qilib bo'lmaydi.

import type { Ctx } from './context';
import { json } from './http';

const VERSION_RE = /^\d{1,4}\.\d{1,4}\.\d{1,4}$/;

/** "1.2.3" -> [1,2,3]; noto'g'ri (yoki "+build" qismi) bo'lsa build qismi tashlanadi. */
export function parseVersion(v: string | null | undefined): [number, number, number] | null {
  const core = (v ?? '').trim().split(/[+ ]/)[0]; // "+" in a query string arrives as a space
  if (!VERSION_RE.test(core)) return null;
  const [a, b, c] = core.split('.').map(Number);
  return [a, b, c];
}

/** <0: a<b, 0: teng, >0: a>b. */
export function compareVersions(a: [number, number, number], b: [number, number, number]): number {
  for (let i = 0; i < 3; i++) if (a[i] !== b[i]) return a[i] - b[i];
  return 0;
}

function cleanUrl(u: string | undefined): string | null {
  const s = (u ?? '').trim();
  if (!s) return null;
  try {
    const p = new URL(s);
    return p.protocol === 'https:' ? p.toString() : null;
  } catch {
    return null;
  }
}

export async function appPolicy(ctx: Ctx): Promise<Response> {
  const q = new URL(ctx.req.url).searchParams;
  const platform = q.get('platform') === 'ios' ? 'ios' : q.get('platform') === 'android' ? 'android' : null;
  const min = parseVersion(ctx.env.LG_MIN_APP_VERSION);
  const latest = parseVersion(ctx.env.LG_LATEST_APP_VERSION);
  const cur = parseVersion(q.get('version'));
  const url = cleanUrl(platform === 'ios' ? ctx.env.LG_UPDATE_URL_IOS : ctx.env.LG_UPDATE_URL_ANDROID);
  const fmt = (v: [number, number, number] | null) => (v ? v.join('.') : null);
  return json({
      api: 1,
      min_version: fmt(min),
      latest_version: fmt(latest),
      update_url: url,
      // Mijoz versiyasi berilsa — tayyor javob; berilmasa false (mijoz o'zi solishtiradi).
      update_required: Boolean(cur && min && compareVersions(cur, min) < 0),
      update_available: Boolean(cur && latest && compareVersions(cur, latest) < 0),
  });
}
