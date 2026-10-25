-- D-77 addendum (2026-10-25): sinov attestatsiyasi takrori, obuna tafsilotlari
-- va mehmon (hisobsiz) do'kon huquqlari. FAQAT MIGRATSIYA FAYLI: production D1
-- ga qo'llanmagan; yo'llar LG_BILLING_ENABLED=true bo'lmaguncha 404.
-- 0014–0018 TAHRIRLANMAYDI.

-- ------------------------------------------------- attestatsiya tokeni takrori
-- Bitta qurilma attestatsiyasi tokeni (Play Integrity / DeviceCheck) faqat bir
-- marta qabul qilinadi. Xom token SAQLANMAYDI — faqat SHA-256; 30 kundan keyin
-- kunlik tozalashda o'chadi.
CREATE TABLE pro_trial_attest_tokens (
  token_hash TEXT PRIMARY KEY CHECK (length(token_hash) = 64),
  expires_at INTEGER NOT NULL
);
CREATE INDEX pro_trial_attest_tokens_exp ON pro_trial_attest_tokens (expires_at);

-- ------------------------------------------------------ obuna tafsilotlari
-- `period_type`: do'kon davri — `trial` (Apple intro FREE_TRIAL / Play free
-- trial bosqichi), `intro` (chegirmali kirish narxi), `normal`. Huquq bilan
-- bir xil (to'liq huquq), faqat ko'rsatish va "ikki sinov" siyosati uchun.
-- `auto_renew`: 1 — yangilanadi, 0 — bekor qilingan (davr oxirigacha huquq),
-- NULL — noma'lum. `pending_product_id`: keyingi yangilanishda o'tadigan
-- mahsulot (pastga tushirish — downgrade).
ALTER TABLE entitlements ADD COLUMN period_type TEXT NOT NULL DEFAULT 'normal'
  CHECK (period_type IN ('normal', 'trial', 'intro'));
ALTER TABLE entitlements ADD COLUMN auto_renew INTEGER CHECK (auto_renew IN (0, 1));
ALTER TABLE entitlements ADD COLUMN pending_product_id TEXT;

-- ---------------------------------------------- mehmon do'kon huquqlari
-- Apple 5.1.1(v): hisobga bog'liq bo'lmagan imkoniyatlar (learner, lab) uchun
-- hisob ochish majburiy emas. Mehmon do'konda sotib oladi yoki tiklaydi;
-- server do'kon API'si bilan tekshiradi va SHU do'kon tranzaksiyasi + qurilmaga
-- bog'langan imzolangan mehmon tokeni beradi. Hisobga kirilganda xarid hisobga
-- bog'lanadi (`linked_user_id`) — shundan keyin mehmon tokeni huquq BERMAYDI
-- (ikki marta berilmaydi). `teacher_panel` — faqat hisob bilan.
-- Saqlanadi: do'kon tranzaksiya id/token (tekshiruv uchun), holat, muddat;
-- qurilma faqat HMAC (`device_key`). Email/ism yo'q.
CREATE TABLE store_guest_entitlements (
  platform TEXT NOT NULL CHECK (platform IN ('app_store', 'play_store')),
  original_transaction_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('active', 'grace_period', 'billing_retry', 'paused', 'expired', 'revoked')),
  period_type TEXT NOT NULL DEFAULT 'normal' CHECK (period_type IN ('normal', 'trial', 'intro')),
  auto_renew INTEGER CHECK (auto_renew IN (0, 1)),
  started_at INTEGER,
  expires_at INTEGER,
  environment TEXT NOT NULL DEFAULT 'production' CHECK (environment IN ('production', 'sandbox')),
  latest_token TEXT NOT NULL,
  event_at INTEGER NOT NULL,
  -- Hisobga bog'langanda (FK yo'q: hisob o'chirilsa ham "bog'langan" qoladi —
  -- mehmon tokeni qayta huquq bermasin).
  linked_user_id TEXT,
  linked_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  PRIMARY KEY (platform, original_transaction_id)
);
CREATE INDEX store_guest_latest ON store_guest_entitlements (platform, latest_token);

-- Bitta mehmon xaridi bog'langan qurilmalar (HMAC), ko'pi bilan 5 ta.
CREATE TABLE store_guest_devices (
  platform TEXT NOT NULL,
  original_transaction_id TEXT NOT NULL,
  device_key TEXT NOT NULL CHECK (length(device_key) = 64),
  first_seen INTEGER NOT NULL,
  last_seen INTEGER NOT NULL,
  PRIMARY KEY (platform, original_transaction_id, device_key)
);
