-- Admin sessiyasi va STEP-UP (2026-10-24 auth auditi, P1-6).
--
-- Oddiy foydalanuvchi sessiyasi o'zgarmaydi (60 kun). Admin VAKOLATI esa
-- sessiya ichida qisqa:
-- * `admin_auth_at` — shu sessiyada oxirgi yangi tasdiq vaqti (email kodi
--   bilan kirish, admin TOTP yoki step-up). Undan 12 soat o'tsa admin
--   yo'llari `403 step_up_required` (reason: admin_session_expired).
-- * `admin_seen_at` — oxirgi admin so'rovi (30 daqiqa harakatsizlik — xuddi
--   shunday).
-- * `step_up_at` / `step_up_used` — xavfli amal (hisobni o'chirish,
--   to'xtatish, rol, adminlar, sessiyalarni bekor qilish, moderatsiya)
--   uchun 10 daqiqalik yangi tasdiq; `step_up_used` — shu tasdiq bilan
--   allaqachon bajarilgan "bir martalik" amal turlari (vergul bilan).
-- Eski (migratsiyadan oldingi) sessiyalarda ustunlar NULL: admin yo'li darhol
-- yangi tasdiq so'raydi, oddiy foydalanish ta'sirlanmaydi.
ALTER TABLE sessions ADD COLUMN admin_auth_at INTEGER;
ALTER TABLE sessions ADD COLUMN admin_seen_at INTEGER;
ALTER TABLE sessions ADD COLUMN step_up_at INTEGER;
ALTER TABLE sessions ADD COLUMN step_up_used TEXT NOT NULL DEFAULT '';

-- Step-up email kodi: sessiyaga (token hash) va hisobga bog'langan, faqat
-- kod HMAC i saqlanadi, 10 daqiqa, 5 urinish, bir martalik.
CREATE TABLE step_up_challenges (
  token_hash TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  code_hash TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  attempts INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX step_up_challenges_user ON step_up_challenges (user_id);
CREATE INDEX step_up_challenges_expiry ON step_up_challenges (expires_at);
