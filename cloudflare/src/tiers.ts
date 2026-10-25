// Reja ↔ panel ajratish (D-74; to'rt reja va `lab` imkoniyati — D-76). INERT: LG_BILLING_ENABLED=true bo'lmasa
// `requireTier` ishlatadigan yo'llar umuman yo'q (app.ts → 404).
//
// Qoida: pullik imkoniyat qarori FAQAT serverda saqlangan huquqdan
// (do'kon obunasi / admin grant / bepul sinov — billing.ts `loadAccess`)
// olinadi. `users.role` (ilovada tanlanadigan rol, `PUT /v1/me/profile`)
// va ilovaning lokal sozlamalari hech narsa ochmaydi: rolni "Ustoz" ga
// o'zgartirgan Talaba rejasi egasi Ustoz-Pro imkoniyatini olmaydi.
//
// Bugungi BEPUL ustoz paneli (guruhlar, topshiriqlar — groups.ts,
// `teacher_accounts`) bunga TEGMAYDI va bepul qoladi: `requireTier` faqat
// kelajakdagi Pro-only yo'llar uchun.

import { requireSession } from './auth';
import { liveAccess, loadAccess, type AccessItem, type Plan, type ResolvedAccess } from './billing';
import type { Ctx, Session } from './context';
import { ApiError, billingEnabled, json } from './http';

/**
 * Pro imkoniyat TOIFALARI (funksiya emas). Hozir hech bir funksiya pullik
 * emas (ilovada `ProGatePolicy.gated` bo'sh); kelajakda yopiladigan har
 * funksiya shu toifalardan biriga biriktiriladi va daraja faqat o'z
 * to'plamidagini ocha oladi.
 * - `learner`  — talaba tomonidagi Pro (mashq, tarix va h.k.).
 * - `teacher_panel` — ustoz paneli Pro qismi (guruh/topshiriq kengaytmalari).
 * - `lab` — butun Lab bo'limi (apparatlar, yo'nalish kartalari,
 *   koagulogramma, kalibrlash, QC, kalkulyatorlar, leykoformula sanash va
 *   baholash va h.k. — D-76). Ilovada: `ProGatePolicy.plannedLabGate`.
 */
export type Capability = 'learner' | 'teacher_panel' | 'lab';
export const CAPABILITIES: readonly Capability[] = ['learner', 'teacher_panel', 'lab'];

/**
 * Daraja × imkoniyat matritsasi (D-76, egasi qarori, MA'LUMOT). Ilova
 * nusxasi: lib/core/entitlements/plan_matrix.dart (test ikkalasini
 * solishtiradi). Bu ZINAPOYA EMAS — to'plam:
 * - Ustoz = Talaba + ustoz paneli (Lab YO'Q);
 * - Mutaxassis = Talaba + butun Lab (ustoz paneli YO'Q; D-73/D-74 dagi
 *   "Mutaxassis Ustozni ham qamraydi" qoidasi BEKOR);
 * - Premium = hammasi.
 */
export const TIER_CAPABILITIES: Record<Plan, readonly Capability[]> = {
  student: ['learner'],
  teacher: ['learner', 'teacher_panel'],
  specialist: ['learner', 'lab'],
  premium: ['learner', 'teacher_panel', 'lab'],
};

export const tierAllows = (plan: Plan | null | undefined, cap: Capability): boolean =>
  plan != null && TIER_CAPABILITIES[plan].includes(cap);

/**
 * Hozir amaldagi BARCHA huquq qatorlari ochadigan imkoniyatlar (birlashma).
 * Matritsa zinapoya bo'lmagani uchun faqat "eng yuqori" rejaga qaralmaydi:
 * masalan, Ustoz obunasi + Mutaxassis admin granti = ustoz paneli + Lab.
 * Sinov amaldagi do'kon obunasi bo'lsa hisobga olinmaydi (`liveAccess`).
 */
export function accessCapabilities(items: AccessItem[], now: number): Capability[] {
  const have = new Set<Capability>();
  for (const i of liveAccess(items, now)) for (const c of TIER_CAPABILITIES[i.plan]) have.add(c);
  return CAPABILITIES.filter((c) => have.has(c));
}

export const parseCapability = (raw: unknown): Capability | null =>
  typeof raw === 'string' && (CAPABILITIES as readonly string[]).includes(raw) ? (raw as Capability) : null;

/**
 * Pro-only yo'l uchun vakolat: sessiya + serverdagi huquq + matritsa.
 * - bayroq o'chiq → 404 (yo'l yo'qdek);
 * - sessiya yo'q → 401;
 * - amaldagi huquq yo'q → 403 `plan_required`;
 * - amaldagi hech bir reja bu imkoniyatni ochmaydi → 403 `tier_insufficient`.
 */
export async function requireTier(
  ctx: Ctx,
  cap: Capability,
): Promise<{ session: Session; access: ResolvedAccess }> {
  if (!billingEnabled(ctx.env)) throw new ApiError(404, 'not_found');
  const session = await requireSession(ctx);
  const { access, resolved } = await loadAccess(ctx, session.userId);
  if (!resolved) throw new ApiError(403, 'plan_required', { capability: cap });
  if (!accessCapabilities(access, ctx.now).includes(cap)) {
    throw new ApiError(403, 'tier_insufficient', { capability: cap, plan: resolved.plan });
  }
  return { session, access: resolved };
}

/**
 * GET /v1/pro/access — serverdagi daraja va u ochadigan imkoniyat toifalari
 * (ilova faqat ko'rsatish uchun ishlatadi).
 */
export async function access(ctx: Ctx): Promise<Response> {
  const s = await requireSession(ctx);
  const { access: items, resolved } = await loadAccess(ctx, s.userId);
  return json({
    plan: resolved?.plan ?? null,
    source: resolved?.source ?? null,
    expires_at: resolved?.expiresAt == null ? null : new Date(resolved.expiresAt).toISOString(),
    capabilities: accessCapabilities(items, ctx.now),
  });
}

/**
 * GET /v1/pro/check/:capability — Pro-only yo'llar namunasi: `requireTier`
 * bilan himoyalangan inert tekshiruv (hech qanday funksiya ochmaydi).
 * `teacher_panel` uchun qo'shimcha ravishda serverda ustoz sifatida
 * ro'yxatdan o'tganlik (`teacher_accounts`) talab qilinadi — bepul ustoz
 * paneli qoidasi bilan bir xil.
 */
export async function check(ctx: Ctx, raw: string): Promise<Response> {
  const cap = parseCapability(raw);
  if (!cap) throw new ApiError(404, 'not_found');
  const { session, access: a } = await requireTier(ctx, cap);
  if (cap === 'teacher_panel') {
    const t = await ctx.db.prepare('SELECT 1 AS x FROM teacher_accounts WHERE user_id = ?1').bind(session.userId).first();
    if (!t) throw new ApiError(403, 'teacher_role_required');
  }
  return json({ allowed: true, capability: cap, plan: a.plan, source: a.source });
}
