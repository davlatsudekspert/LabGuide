// Xaridni server tomonda tekshirish va Pro huquqini yozish (SKELET).
//
// Hozirgi holat: to'lov YOQILMAGAN (narx tasdiqlanmagan). Funksiya har
// doim `503 {"error": "not_configured"}` qaytaradi, toki quyidagilarning
// HAMMASI secrets'da bo'lmaguncha:
//   LG_BILLING_ENABLED=true            — egasi narxni tasdiqlagach qo'yiladi;
//   APPLE_ISSUER_ID, APPLE_KEY_ID, APPLE_PRIVATE_KEY_P8, APPLE_BUNDLE_ID
//                                       — App Store Server API (In-App Purchase kaliti);
//   GOOGLE_SERVICE_ACCOUNT_JSON, GOOGLE_PACKAGE_NAME
//                                       — Google Play Developer API.
// Kalitlar faqat `supabase secrets set ...` orqali; repoda va ilovada yo'q.
//
// So'rov (foydalanuvchi JWT bilan, POST):
//   {"action": "verify",  "platform": "app_store",  "transaction_id": "..."}
//   {"action": "verify",  "platform": "play_store", "product_id": "...", "purchase_token": "..."}
//   {"action": "restore", "platform": "app_store",  "transaction_ids": ["..."]}
//   {"action": "restore", "platform": "play_store", "purchases": [{"product_id": "...", "purchase_token": "..."}]}
// Javob: {"entitlements": [...]} (my_entitlements bilan bir xil ko'rinish)
// yoki {"error": "..."}.
//
// Ilova bergan ma'lumotga ISHONILMAYDI: faqat identifikator olinadi, holat,
// muddat va mahsulot do'kon API'sidan o'qiladi va `entitlement_apply`
// (service role) orqali yoziladi. Qarang: docs/PRO_BILLING_PLAN.md.
import { createClient } from "jsr:@supabase/supabase-js@2";

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });

type Platform = "app_store" | "play_store";

/** Do'kondan tekshirilgan holat — `entitlement_apply` argumentlari. */
interface VerifiedPurchase {
  platform: Platform;
  productId: string;
  originalTransactionId: string;
  status:
    | "active"
    | "grace_period"
    | "billing_retry"
    | "paused"
    | "expired"
    | "revoked";
  startedAt: string | null;
  expiresAt: string | null;
  eventAt: string;
  ownership: "purchased" | "family_shared";
  environment: "production" | "sandbox";
}

class NotConfigured extends Error {}

const env = (name: string) => Deno.env.get(name) ?? "";

function appleConfigured() {
  return ["APPLE_ISSUER_ID", "APPLE_KEY_ID", "APPLE_PRIVATE_KEY_P8", "APPLE_BUNDLE_ID"]
    .every((k) => env(k) !== "");
}

function googleConfigured() {
  return ["GOOGLE_SERVICE_ACCOUNT_JSON", "GOOGLE_PACKAGE_NAME"].every((k) => env(k) !== "");
}

/**
 * App Store Server API: GET /inApps/v1/transactions/{transactionId}
 * (ES256 JWT, APPLE_PRIVATE_KEY_P8 bilan imzolanadi), javobdagi JWS
 * (signedTransactionInfo) Apple sertifikat zanjiri bilan tekshiriladi,
 * bundleId == APPLE_BUNDLE_ID, so'ng GET /inApps/v1/subscriptions/{originalTransactionId}
 * dan holat (1 active, 2 expired, 3 billing retry, 4 grace period, 5 revoked)
 * va expiresDate olinadi. revocationDate bo'lsa — 'revoked'.
 * inAppOwnershipType FAMILY_SHARED → ownership 'family_shared'.
 * Avval production, 4040010 bo'lsa sandbox (TestFlight) muhiti.
 */
function verifyApple(_transactionId: string): Promise<VerifiedPurchase> {
  if (!appleConfigured()) throw new NotConfigured();
  // TODO(billing): narx tasdiqlangach yoziladi (docs/PRO_BILLING_PLAN.md, 4-qadam).
  throw new NotConfigured();
}

/**
 * Google Play Developer API: purchases.subscriptionsv2.get
 * (packageName = GOOGLE_PACKAGE_NAME, token = purchaseToken; xizmat hisobi
 * OAuth). subscriptionState: ACTIVE → active, IN_GRACE_PERIOD → grace_period,
 * ON_HOLD → billing_retry, PAUSED → paused, EXPIRED/CANCELED(muddati o'tgan)
 * → expired; voided purchase (refund) → revoked. Tasdiqlanmagan xarid
 * (acknowledgementState) server tomonda acknowledge qilinadi (3 kun ichida,
 * aks holda Google pulni qaytaradi). originalTransactionId o'rniga
 * linkedPurchaseToken zanjirining birinchi tokeni ishlatiladi.
 */
function verifyGoogle(_productId: string, _purchaseToken: string): Promise<VerifiedPurchase> {
  if (!googleConfigured()) throw new NotConfigured();
  // TODO(billing): narx tasdiqlangach yoziladi (docs/PRO_BILLING_PLAN.md, 4-qadam).
  throw new NotConfigured();
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method" }, 405);
  const url = env("SUPABASE_URL");
  const anon = env("SUPABASE_ANON_KEY");
  const service = env("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !anon || !service) return json({ error: "not_configured" }, 503);

  const authorization = req.headers.get("Authorization") ?? "";
  const asUser = createClient(url, anon, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false },
  });
  const { data, error } = await asUser.auth.getUser();
  if (error || !data.user) return json({ error: "unauthorized" }, 401);
  const userId = data.user.id;

  // Narx tasdiqlanmaguncha haqiqiy to'lov yoqilmaydi.
  if (env("LG_BILLING_ENABLED") !== "true") return json({ error: "not_configured" }, 503);

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid" }, 400);
  }
  const action = body.action;
  const platform = body.platform;
  if ((action !== "verify" && action !== "restore") ||
      (platform !== "app_store" && platform !== "play_store")) {
    return json({ error: "invalid" }, 400);
  }

  // Ilovadan kelgan identifikatorlar (bir so'rovda ≤ 20 ta).
  const str = (v: unknown) => typeof v === "string" && v.length > 0 && v.length <= 4096;
  const jobs: Array<() => Promise<VerifiedPurchase>> = [];
  if (platform === "app_store") {
    const ids = action === "verify" ? [body.transaction_id] : body.transaction_ids;
    if (!Array.isArray(ids) || ids.length === 0 || ids.length > 20 || !ids.every(str)) {
      return json({ error: "invalid" }, 400);
    }
    for (const id of ids as string[]) jobs.push(() => verifyApple(id));
  } else {
    const items = action === "verify"
      ? [{ product_id: body.product_id, purchase_token: body.purchase_token }]
      : body.purchases;
    if (!Array.isArray(items) || items.length === 0 || items.length > 20) {
      return json({ error: "invalid" }, 400);
    }
    for (const p of items as Array<Record<string, unknown>>) {
      if (!str(p?.product_id) || !str(p?.purchase_token)) return json({ error: "invalid" }, 400);
      jobs.push(() => verifyGoogle(p.product_id as string, p.purchase_token as string));
    }
  }

  const admin = createClient(url, service, { auth: { persistSession: false } });
  const outcomes: string[] = [];
  try {
    for (const job of jobs) {
      const v = await job();
      const { data: result, error: applyError } = await admin.rpc("entitlement_apply", {
        p_user: userId,
        p_platform: v.platform,
        p_product_id: v.productId,
        p_original_transaction_id: v.originalTransactionId,
        p_status: v.status,
        p_started_at: v.startedAt,
        p_expires_at: v.expiresAt,
        p_event_at: v.eventAt,
        p_ownership: v.ownership,
        p_environment: v.environment,
      });
      if (applyError) return json({ error: "apply_failed" }, 500);
      outcomes.push(result as string);
    }
  } catch (e) {
    if (e instanceof NotConfigured) return json({ error: "not_configured" }, 503);
    return json({ error: "store_unreachable" }, 502);
  }

  const { data: mine, error: readError } = await asUser.rpc("my_entitlements");
  if (readError) return json({ error: "read_failed" }, 500);
  return json({
    ...(mine as Record<string, unknown>),
    // Boshqa hisobga bog'langan xarid: ilova "bu xarid boshqa hisobda" deydi.
    owned_by_other: outcomes.includes("owned_by_other"),
  });
});
