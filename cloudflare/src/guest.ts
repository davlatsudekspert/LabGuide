// Mehmon (hisobsiz) do'kon huquqlari — Apple 5.1.1(v) (D-77 addendum).
//
// Hisobga bog'liq bo'lmagan imkoniyatlar (`learner`, `lab`) uchun hisob ochish
// majburiy emas: mehmon do'konda sotib oladi yoki "Xaridlarni tiklash" ni
// bosadi; server xaridni do'kon API'si bilan tekshiradi (StoreVerifier —
// billing.ts) va SHU do'kon tranzaksiyasi + SHU qurilmaga bog'langan imzolangan
// mehmon tokenini qaytaradi. `teacher_panel` — faqat hisob bilan (ustoz hisobi
// va guruhlar hisobga bog'liq), shuning uchun mehmonda hech qachon ochilmaydi.
//
// Qoidalar:
// * Tranzaksiya allaqachon hisobga bog'langan (hisobda sotib olingan yoki
//   keyin bog'langan) — mehmonga huquq BERILMAYDI (`account_linked`,
//   "hisobga kiring"); hisobda xarid paytida qo'yilgan appAccountToken /
//   obfuscatedAccountId bo'lsa ham shunday (`sign_in_required`).
// * Hisobga kirilganda `POST /v1/billing/guest/link` xaridni hisobga o'tkazadi
//   (billing.ts `claim`), mehmon qatori `linked_user_id` oladi — shundan keyin
//   o'sha mehmon tokeni huquq bermaydi (ikki marta berilmaydi).
// * Bitta xarid ko'pi bilan [GUEST_MAX_DEVICES] qurilmaga (HMAC) bog'lanadi.
// * Bildirishnomalar (ASSN v2 / RTDN) mehmon qatorini ham yangilaydi
//   (billing.ts `applyUpdate`); token yangilashda eski qator bo'lsa do'kondan
//   qayta o'qiladi ([GUEST_RESYNC_MS]).
// * Saqlanmaydi: email, ism, xom qurilma id si. Token — HMAC imzo (server kaliti).

import { requireSession } from './auth';
import {
  acknowledgeIfNeeded,
  claim,
  configured,
  markGuestLinked,
  MAX_RESTORE,
  notConfigured,
  OFFLINE_MAX_MS,
  parsePlatform,
  parseProduct,
  parseToken,
  type Plan,
  type Platform,
  PLANS,
  snapshot,
  type Status,
  type Verified,
  verifierFor,
  verifyOne,
  BILLING_PRODUCTS,
} from './billing';
import type { Ctx } from './context';
import { iso } from './context';
import { base64url, hex, hmac, safeEqual, sha256Hex } from './crypto';
import { ApiError, badRequest, json, readJson } from './http';
import { b64urlDecode } from './jwtsign';
import { hit } from './ratelimit';
import { type Capability, TIER_CAPABILITIES } from './tiers';

/** Faqat hisob bilan ochiladigan imkoniyatlar. */
export const ACCOUNT_ONLY_CAPABILITIES: readonly Capability[] = ['teacher_panel'];
export const GUEST_MAX_DEVICES = 5;
/** Mehmon qatori shundan eski bo'lsa tokenni yangilashda do'kondan qayta o'qiladi. */
export const GUEST_RESYNC_MS = 6 * 3600_000;
const DEVICE_ID_RE = /^[A-Za-z0-9._:-]{8,128}$/;
const MAX_TOKENS = 10;

/** Reja mehmonga sotiladimi: imkoniyatlarida faqat-hisob imkoniyati yo'q (TIER_CAPABILITIES dan). */
export const guestPlanAllowed = (plan: Plan) => !TIER_CAPABILITIES[plan].some((c) => ACCOUNT_ONLY_CAPABILITIES.includes(c));

/** Mehmonga ochiladigan imkoniyatlar (reja imkoniyatlari − faqat-hisob). */
export const guestCapabilitiesOf = (plan: Plan): Capability[] =>
  TIER_CAPABILITIES[plan].filter((c) => !ACCOUNT_ONLY_CAPABILITIES.includes(c));

/** `GET /v1/billing/status` → `guest`. */
export function guestPolicy() {
  return {
    purchase_plans: PLANS.filter(guestPlanAllowed),
    account_only_capabilities: [...ACCOUNT_ONLY_CAPABILITIES],
    max_devices: GUEST_MAX_DEVICES,
  };
}

const deviceKey = async (ctx: Ctx, deviceId: string) => hex(await hmac(ctx.keys.guest, `device:${deviceId}`));

function parseDeviceId(raw: unknown): string {
  if (typeof raw !== 'string' || !DEVICE_ID_RE.test(raw)) throw badRequest('invalid_device_id');
  return raw;
}

// ------------------------------------------------------------ token
interface TokenClaims {
  p: Platform;
  o: string;
  /** device_key prefiksi. */
  d: string;
  iat: number;
}

async function signToken(ctx: Ctx, c: TokenClaims): Promise<string> {
  const payload = base64url(new TextEncoder().encode(JSON.stringify(c)));
  const sig = base64url(await hmac(ctx.keys.guest, `g1.${payload}`));
  return `g1.${payload}.${sig}`;
}

/** Imzo va qurilma mos bo'lsa — da'volar, aks holda `null`. */
async function readToken(ctx: Ctx, raw: unknown, dKey: string): Promise<TokenClaims | null> {
  if (typeof raw !== 'string' || raw.length > 2048) return null;
  const parts = raw.split('.');
  if (parts.length !== 3 || parts[0] !== 'g1') return null;
  const expected = base64url(await hmac(ctx.keys.guest, `g1.${parts[1]}`));
  if (!safeEqual(expected, parts[2])) return null;
  try {
    const c = JSON.parse(b64urlDecode(parts[1])) as TokenClaims;
    if ((c.p !== 'app_store' && c.p !== 'play_store') || typeof c.o !== 'string' || c.d !== dKey.slice(0, 32)) return null;
    return c;
  } catch {
    return null;
  }
}

// ------------------------------------------------------------ saqlash
interface GuestRow {
  platform: Platform;
  original_transaction_id: string;
  product_id: string;
  status: Status;
  period_type: string;
  auto_renew: number | null;
  started_at: number | null;
  expires_at: number | null;
  environment: string;
  latest_token: string;
  linked_user_id: string | null;
  updated_at: number;
}

type GuestState = 'active' | 'account_linked' | 'sign_in_required' | 'device_limit';

const granting = (r: { status: string; expires_at: number | null }, now: number) =>
  (r.status === 'active' || r.status === 'grace_period') && (r.expires_at == null || r.expires_at > now);

/** Xarid hisobga bog'langanmi (zanjir: original id yoki Play linkedPurchaseToken). */
async function accountOwner(ctx: Ctx, v: Verified): Promise<string | null> {
  const row = await ctx.db
    .prepare(
      `SELECT user_id FROM entitlements WHERE platform = ?1
         AND (original_transaction_id = ?2 OR latest_token IN (?3, ?4)) LIMIT 1`,
    )
    .bind(v.platform, v.originalId, v.latestToken, v.linkedToken ?? v.latestToken)
    .first<{ user_id: string }>();
  return row?.user_id ?? null;
}

async function upsertGuest(ctx: Ctx, v: Verified): Promise<GuestRow> {
  // Play yangilash/almashtirish: zanjir boshi (mavjud mehmon qatori) saqlanadi.
  let originalId = v.originalId;
  if (v.linkedToken) {
    const prev = await ctx.db
      .prepare('SELECT original_transaction_id FROM store_guest_entitlements WHERE platform = ?1 AND latest_token = ?2')
      .bind(v.platform, v.linkedToken)
      .first<{ original_transaction_id: string }>();
    if (prev) originalId = prev.original_transaction_id;
  }
  await ctx.db
    .prepare(
      `INSERT INTO store_guest_entitlements (platform, original_transaction_id, product_id, status, period_type, auto_renew,
         started_at, expires_at, environment, latest_token, event_at, created_at, updated_at)
       VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11, ?12, ?12)
       ON CONFLICT (platform, original_transaction_id) DO UPDATE SET
         product_id = excluded.product_id, status = excluded.status, period_type = excluded.period_type,
         auto_renew = excluded.auto_renew, started_at = excluded.started_at, expires_at = excluded.expires_at,
         environment = excluded.environment, latest_token = excluded.latest_token, event_at = excluded.event_at,
         updated_at = excluded.updated_at
       WHERE store_guest_entitlements.event_at <= excluded.event_at`,
    )
    .bind(
      v.platform,
      originalId,
      v.productId,
      v.status,
      v.periodType ?? 'normal',
      v.autoRenew == null ? null : v.autoRenew ? 1 : 0,
      v.startedAt,
      v.expiresAt,
      v.environment,
      v.latestToken,
      v.eventAt,
      ctx.now,
    )
    .run();
  return (await loadRow(ctx, v.platform, originalId))!;
}

const loadRow = (ctx: Ctx, platform: Platform, originalId: string) =>
  ctx.db
    .prepare('SELECT * FROM store_guest_entitlements WHERE platform = ?1 AND original_transaction_id = ?2')
    .bind(platform, originalId)
    .first<GuestRow>();

/** Qurilmani xaridga bog'laydi; limitdan oshsa `false`. */
async function bindDevice(ctx: Ctx, platform: Platform, originalId: string, dKey: string): Promise<boolean> {
  const known = await ctx.db
    .prepare('UPDATE store_guest_devices SET last_seen = ?4 WHERE platform = ?1 AND original_transaction_id = ?2 AND device_key = ?3')
    .bind(platform, originalId, dKey, ctx.now)
    .run();
  if (known.meta.changes) return true;
  const n = await ctx.db
    .prepare('SELECT COUNT(*) AS n FROM store_guest_devices WHERE platform = ?1 AND original_transaction_id = ?2')
    .bind(platform, originalId)
    .first<{ n: number }>();
  if ((n?.n ?? 0) >= GUEST_MAX_DEVICES) return false;
  await ctx.db
    .prepare(
      `INSERT INTO store_guest_devices (platform, original_transaction_id, device_key, first_seen, last_seen)
       VALUES (?1, ?2, ?3, ?4, ?4) ON CONFLICT DO NOTHING`,
    )
    .bind(platform, originalId, dKey, ctx.now)
    .run();
  return true;
}

// ------------------------------------------------------------ javob
interface GuestItem {
  row: GuestRow | null;
  productId: string;
  platform: Platform;
  state: GuestState;
  token: string | null;
}

function guestSnapshot(ctx: Ctx, items: GuestItem[], status = 200): Response {
  const caps = new Set<Capability>();
  let until: number | null = null;
  let any = false;
  for (const i of items) {
    if (i.state !== 'active' || !i.row || !granting(i.row, ctx.now)) continue;
    const plan = BILLING_PRODUCTS[i.row.product_id]?.plan ?? 'student';
    for (const c of guestCapabilitiesOf(plan)) caps.add(c);
    any = true;
    const end = i.row.expires_at ?? Number.POSITIVE_INFINITY;
    until = until == null ? end : Math.max(until, end);
  }
  const offline = any ? Math.min(ctx.now + OFFLINE_MAX_MS, until ?? ctx.now) : ctx.now;
  return json(
    {
      server_time: iso(ctx.now),
      guest: true,
      items: items.map((i) => ({
        product_id: i.row?.product_id ?? i.productId,
        platform: i.platform,
        source: 'store_guest',
        plan: BILLING_PRODUCTS[i.row?.product_id ?? i.productId]?.plan ?? 'student',
        guest_state: i.state,
        // Faol bo'lmagan holat (hisobga bog'langan, qurilma limiti) — huquq
        // bermaydigan status (ilova uni "noma'lum" deb o'qiydi).
        status: i.state === 'active' ? (i.row?.status ?? 'expired') : i.state,
        period_type: i.row?.period_type ?? 'normal',
        auto_renew: i.row?.auto_renew == null ? null : i.row.auto_renew === 1,
        started_at: iso(i.row?.started_at),
        expires_at: iso(i.row?.expires_at),
        environment: i.row?.environment ?? 'production',
        ownership: 'purchased',
        updated_at: iso(i.row?.updated_at),
      })),
      capabilities: [...caps],
      account_only_capabilities: [...ACCOUNT_ONLY_CAPABILITIES],
      guest_tokens: items.filter((i) => i.token).map((i) => i.token),
      sign_in_required: items.some((i) => i.state === 'account_linked' || i.state === 'sign_in_required'),
      offline_until: iso(offline),
    },
    status,
  );
}

async function guestLimits(ctx: Ctx, dKey: string): Promise<void> {
  await hit(ctx.db, `guest-ip:${ctx.ipTag}`, 60, 3600, ctx.now);
  await hit(ctx.db, `guest-dev:${dKey.slice(0, 32)}`, 30, 3600, ctx.now);
}

async function itemFor(ctx: Ctx, v: Verified, dKey: string): Promise<GuestItem> {
  const base = { platform: v.platform, productId: v.productId };
  // Hisobda sotib olingan (xarid belgisi qo'yilgan) yoki hisobga bog'langan — hisobga kiring.
  if (v.accountHint) return { ...base, row: null, state: 'sign_in_required', token: null };
  if (await accountOwner(ctx, v)) return { ...base, row: null, state: 'account_linked', token: null };
  const row = await upsertGuest(ctx, v);
  if (row.linked_user_id) return { ...base, row, state: 'account_linked', token: null };
  if (!(await bindDevice(ctx, v.platform, row.original_transaction_id, dKey))) {
    return { ...base, row, state: 'device_limit', token: null };
  }
  if (granting(row, ctx.now)) await acknowledgeIfNeeded(ctx, v);
  const token = await signToken(ctx, { p: v.platform, o: row.original_transaction_id, d: dKey.slice(0, 32), iat: ctx.now });
  return { ...base, row, state: 'active', token };
}

// ------------------------------------------------------------ yo'llar
/**
 * POST /v1/billing/guest/verify — mehmon xaridi yoki tiklashi (sessiyasiz).
 * `{platform, device_id, product_id?, token}` yoki `{platform, device_id, purchases: [{product_id?, token}]}`.
 */
export async function verify(ctx: Ctx): Promise<Response> {
  const body = await readJson(ctx.req);
  const platform = parsePlatform(body.platform);
  if (!configured(ctx, platform)) throw notConfigured();
  const dKey = await deviceKey(ctx, parseDeviceId(body.device_id));
  await guestLimits(ctx, dKey);
  const list = Array.isArray(body.purchases)
    ? (body.purchases as unknown[]).map((p) => {
        const o = (p ?? {}) as Record<string, unknown>;
        return { productId: parseProduct(o.product_id), token: parseToken(o.token) };
      })
    : [{ productId: parseProduct(body.product_id), token: parseToken(body.token) }];
  if (list.length === 0 || list.length > MAX_RESTORE) throw badRequest('invalid_purchases');

  const items: GuestItem[] = [];
  let lastError: ApiError | null = null;
  for (const p of list) {
    let v: Verified;
    try {
      v = await verifyOne(ctx, platform, p.token, p.productId);
    } catch (e) {
      if (e instanceof ApiError && list.length > 1 && e.status < 500) {
        lastError = e;
        continue;
      }
      throw e;
    }
    items.push(await itemFor(ctx, v, dKey));
  }
  if (items.length === 0 && lastError) throw lastError;
  return guestSnapshot(ctx, items);
}

/**
 * POST /v1/billing/guest/entitlements `{device_id, guest_tokens: [...]}` —
 * mehmon tokenlari bo'yicha joriy holat (oflayn chegarasi bilan). Yaroqsiz
 * yoki boshqa qurilmaning tokeni — e'tiborsiz (huquq bermaydi).
 */
export async function entitlements(ctx: Ctx): Promise<Response> {
  const body = await readJson(ctx.req);
  const dKey = await deviceKey(ctx, parseDeviceId(body.device_id));
  await guestLimits(ctx, dKey);
  const raw = Array.isArray(body.guest_tokens) ? body.guest_tokens : [];
  if (raw.length > MAX_TOKENS) throw badRequest('invalid_tokens');
  const items: GuestItem[] = [];
  for (const t of raw) {
    const c = await readToken(ctx, t, dKey);
    if (!c) continue;
    let row = await loadRow(ctx, c.p, c.o);
    if (!row) continue;
    if (!row.linked_user_id && ctx.now - row.updated_at > GUEST_RESYNC_MS && configured(ctx, c.p)) {
      try {
        const v = await verifierFor(ctx, c.p).verify(ctx, row.latest_token);
        const owner = await accountOwner(ctx, v);
        if (owner) {
          await markGuestLinked(ctx, v, owner, row.original_transaction_id);
        } else if (v.environment !== 'sandbox' || ctx.env.LG_BILLING_SANDBOX === 'true') {
          row = await upsertGuest(ctx, { ...v, originalId: row.original_transaction_id, linkedToken: null });
        }
        row = (await loadRow(ctx, c.p, c.o)) ?? row;
      } catch (e) {
        // Do'kon javob bermadi — saqlangan holat qoladi (huquq UZAYTIRILMAYDI: muddat o'zgarmaydi).
        console.error('guest resync', e instanceof ApiError ? e.code : e instanceof Error ? e.name : typeof e);
      }
    }
    items.push({
      row,
      platform: c.p,
      productId: row.product_id,
      state: row.linked_user_id ? 'account_linked' : 'active',
      token: row.linked_user_id ? null : (t as string),
    });
  }
  return guestSnapshot(ctx, items);
}

/**
 * POST /v1/billing/guest/link `{device_id, guest_tokens}` (sessiya bilan) —
 * mehmon xaridlarini hisobga o'tkazadi. Xarid do'kondan qayta o'qiladi va
 * `claim` qoidalari (boshqa hisobniki — `owned_by_other`) amal qiladi.
 * Javob — hisob surati (`linked` — o'tkazilganlar soni).
 */
export async function link(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const body = await readJson(ctx.req);
  const dKey = await deviceKey(ctx, parseDeviceId(body.device_id));
  await hit(ctx.db, `guest-link:${(await sha256Hex(s.userId)).slice(0, 32)}`, 20, 3600, ctx.now);
  const raw = Array.isArray(body.guest_tokens) ? body.guest_tokens : [];
  if (raw.length === 0 || raw.length > MAX_TOKENS) throw badRequest('invalid_tokens');
  let ownedByOther = false;
  for (const t of raw) {
    const c = await readToken(ctx, t, dKey);
    if (!c) continue;
    const row = await loadRow(ctx, c.p, c.o);
    if (!row) continue;
    if (row.linked_user_id) {
      if (row.linked_user_id !== s.userId) ownedByOther = true;
      continue;
    }
    if (!configured(ctx, c.p)) throw notConfigured();
    const v = await verifyOne(ctx, c.p, row.latest_token);
    if (await claim(ctx, s.userId, v)) {
      await markGuestLinked(ctx, v, s.userId, row.original_transaction_id);
    } else {
      ownedByOther = true;
    }
  }
  return snapshot(ctx, s.userId, ownedByOther);
}
