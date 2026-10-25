-- Premium darajasi (D-76, egasi qarori 2026-10-24). FAQAT MIGRATSIYA FAYLI:
-- production D1 ga qo'llanmagan; Pro yo'llari LG_BILLING_ENABLED=true
-- bo'lmaguncha 404.
--
-- 0015 (`pro_grants`) va 0016 (`pro_trials`) dagi `tier` CHECK cheklovi
-- faqat 'student' | 'teacher' | 'specialist' ni qabul qiladi. SQLite'da CHECK
-- o'zgartirilmaydi, shuning uchun jadval qayta quriladi (0004 dagidek:
-- yangi jadval → ma'lumot nusxasi → eskisini o'chirish → nomini almashtirish
-- → indekslar qayta). 0014–0017 TAHRIRLANMAYDI (qo'llangan bo'lishi mumkin).
--
-- Ikkala jadvalga ham FK havola qilmaydi, shuning uchun qayta qurish boshqa
-- jadvallarga tegmaydi. Ustunlar va boshqa CHECK'lar 0015/0016 bilan bir xil.
-- `entitlements` da reja ustuni yo'q (reja `product_id` dan, kodda).

-- ----------------------------------------------------------------- pro_grants
CREATE TABLE pro_grants_v2 (
  id TEXT PRIMARY KEY,
  email_hmac TEXT NOT NULL,
  email_masked TEXT NOT NULL,
  tier TEXT NOT NULL CHECK (tier IN ('student', 'teacher', 'specialist', 'premium')),
  -- NULL — bekor qilinguncha. Qiymatlar (30/90/365) kodda tekshiriladi.
  duration_days INTEGER,
  -- NULL — hisob hali yo'q (kutilmoqda).
  starts_at INTEGER,
  -- NULL (starts_at bor bo'lsa) — bekor qilinguncha.
  expires_at INTEGER,
  note TEXT,
  granted_by_hash TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  revoked_at INTEGER,
  revoked_by_hash TEXT
);
INSERT INTO pro_grants_v2 (id, email_hmac, email_masked, tier, duration_days, starts_at, expires_at, note,
                           granted_by_hash, created_at, updated_at, revoked_at, revoked_by_hash)
  SELECT id, email_hmac, email_masked, tier, duration_days, starts_at, expires_at, note,
         granted_by_hash, created_at, updated_at, revoked_at, revoked_by_hash
  FROM pro_grants;
DROP TABLE pro_grants;
ALTER TABLE pro_grants_v2 RENAME TO pro_grants;
CREATE UNIQUE INDEX pro_grants_active_email ON pro_grants (email_hmac) WHERE revoked_at IS NULL;
CREATE INDEX pro_grants_email ON pro_grants (email_hmac);

-- ----------------------------------------------------------------- pro_trials
CREATE TABLE pro_trials_v2 (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  tier TEXT NOT NULL CHECK (tier IN ('student', 'teacher', 'specialist', 'premium')),
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
  email_key TEXT NOT NULL CHECK (length(email_key) = 64),
  device_key TEXT NOT NULL CHECK (length(device_key) = 64),
  started_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  account_deleted_at INTEGER,
  retain_until INTEGER NOT NULL
);
INSERT INTO pro_trials_v2 (id, user_id, tier, platform, email_key, device_key, started_at, expires_at,
                           account_deleted_at, retain_until)
  SELECT id, user_id, tier, platform, email_key, device_key, started_at, expires_at,
         account_deleted_at, retain_until
  FROM pro_trials;
DROP TABLE pro_trials;
ALTER TABLE pro_trials_v2 RENAME TO pro_trials;
CREATE UNIQUE INDEX pro_trials_user ON pro_trials (user_id) WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX pro_trials_email ON pro_trials (email_key);
CREATE UNIQUE INDEX pro_trials_device ON pro_trials (device_key);
CREATE INDEX pro_trials_retain ON pro_trials (retain_until);
