-- Pro obunalari (D-46…D-53): App Store / Google Play xaridlari serverda
-- tekshirilgandan keyingi holati. 0003 dagi `entitlements` — endpointsiz
-- bo'sh reja jadvali edi (hech qachon yozilmagan); shu sxema bilan almashtiriladi.
--
-- Qoidalar:
-- * Yozuvni faqat server yozadi: do'kon API'si (App Store Server API /
--   Play Developer API) javobidan. Ilova bergan holat yoki muddatga ishonilmaydi.
-- * Bitta xarid (platform + original_transaction_id) faqat BITTA hisobga
--   bog'lanadi — boshqa hisob uni o'ziga ololmaydi (`owned_by_other`).
-- * Eskiroq hodisa (`event_at`) yangisining ustidan yozilmaydi.
-- * Qator muddati o'tsa ham o'chirilmaydi (Pro davri tarix uchun kerak);
--   hisob o'chirilsa — qatorlar ham o'chadi (do'kondagi obuna davom etadi).
DROP TABLE IF EXISTS entitlements;

CREATE TABLE entitlements (
  platform TEXT NOT NULL CHECK (platform IN ('app_store', 'play_store')),
  -- App Store: originalTransactionId; Google Play: birinchi purchaseToken.
  original_transaction_id TEXT NOT NULL,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('active', 'grace_period', 'billing_retry', 'paused', 'expired', 'revoked')),
  started_at INTEGER,
  expires_at INTEGER,
  ownership TEXT NOT NULL DEFAULT 'purchased' CHECK (ownership IN ('purchased', 'family_shared')),
  environment TEXT NOT NULL DEFAULT 'production' CHECK (environment IN ('production', 'sandbox')),
  -- Oxirgi tranzaksiya id (App Store) yoki joriy purchaseToken (Play).
  latest_token TEXT NOT NULL,
  event_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  PRIMARY KEY (platform, original_transaction_id)
);
CREATE INDEX entitlements_user ON entitlements (user_id);
CREATE INDEX entitlements_latest ON entitlements (platform, latest_token);
