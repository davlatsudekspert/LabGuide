-- Pro bepul sinovi — bir telefonga bir marta (D-74). FAQAT MIGRATSIYA FAYLI:
-- production D1 ga qo'llanmagan; yo'llar LG_BILLING_ENABLED=true bo'lmaguncha
-- 404, qurilma attestatsiyasi sozlanmaguncha 503.
--
-- Qoidalar (docs/PRO_TRIAL_ABUSE_NOTES.md):
-- * Xom email, qurilma id si yoki attestatsiya tokeni SAQLANMAYDI. Faqat
--   server kaliti bilan HMAC (`email_key` — kanonik email; `device_key` —
--   platforma + attestatsiya subyekti).
-- * Bir hisobga, bir kanonik emailga va bir qurilmaga bitta sinov (unikal
--   indekslar; parallel so'rovni ham to'xtatadi).
-- * Hisob o'chirilsa qator O'CHIRILMAYDI: `user_id` NULL bo'ladi,
--   `account_deleted_at` yoziladi — qayta ro'yxatdan o'tish sinovni
--   qaytarmaydi. Qator `retain_until` (boshlanishdan 730 kun) gacha saqlanadi
--   va kunlik tozalashda o'chiriladi.
-- * `user_id` da FK YO'Q (ON DELETE CASCADE yozuvni o'chirib yuborardi).
CREATE TABLE pro_trials (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  tier TEXT NOT NULL CHECK (tier IN ('student', 'teacher', 'specialist')),
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
  email_key TEXT NOT NULL CHECK (length(email_key) = 64),
  device_key TEXT NOT NULL CHECK (length(device_key) = 64),
  started_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  account_deleted_at INTEGER,
  retain_until INTEGER NOT NULL
);
CREATE UNIQUE INDEX pro_trials_user ON pro_trials (user_id) WHERE user_id IS NOT NULL;
CREATE UNIQUE INDEX pro_trials_email ON pro_trials (email_key);
CREATE UNIQUE INDEX pro_trials_device ON pro_trials (device_key);
CREATE INDEX pro_trials_retain ON pro_trials (retain_until);

-- Attestatsiya uchun bir martalik nonce (5 daqiqa); faqat SHA-256.
CREATE TABLE pro_trial_challenges (
  nonce_hash TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  expires_at INTEGER NOT NULL
);
CREATE INDEX pro_trial_challenges_user ON pro_trial_challenges (user_id);
