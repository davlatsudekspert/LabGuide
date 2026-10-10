-- LabGuide (Cloudflare D1): hisoblar, email OTP, sessiyalar, vakolatlar.
--
-- Xavfsizlik tamoyillari (supabase/migrations bilan bir xil ma'noda):
-- * Email ochiq holda SAQLANMAYDI: faqat HMAC (`email_hash`, kalit Worker
--   secretida) va admin ro'yxati uchun niqoblangan ko'rinish (`da***@gmail.com`).
-- * OTP kodi faqat HMAC ko'rinishida, 10 daqiqa, 5 urinish.
-- * Sessiya tokeni faqat SHA-256 ko'rinishida (token qurilmada).
-- * Admin vakolatini hech qanday API bermaydi: `admins` ga faqat server
--   (maxfiy LG_ADMIN_EMAILS ro'yxati + OTP tasdig'i) yoki egasi qo'lda
--   (`wrangler d1 execute`) yozadi. Admin amallari TOTP (aal2) talab qiladi.
-- * Vaqtlar — Unix millisekund (INTEGER).

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email_hash TEXT NOT NULL UNIQUE,
  email_masked TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'student'
    CHECK (role IN ('doctor', 'lab', 'student', 'teacher')),
  language TEXT NOT NULL DEFAULT 'uz' CHECK (language IN ('uz', 'ru', 'en')),
  created_at INTEGER NOT NULL,
  -- Faollik KUNI (Asia/Tashkent, 'YYYY-MM-DD') — aniq vaqt/IP saqlanmaydi.
  last_seen_on TEXT
);

CREATE TABLE otp_challenges (
  email_hash TEXT PRIMARY KEY,
  code_hash TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  attempts INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE sessions (
  token_hash TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  -- 'aal1' — email kodi; 'aal2' — admin TOTP ham tasdiqlangan.
  aal TEXT NOT NULL DEFAULT 'aal1' CHECK (aal IN ('aal1', 'aal2'))
);
CREATE INDEX sessions_user ON sessions (user_id);
CREATE INDEX sessions_expiry ON sessions (expires_at);

-- Qat'iy oynali hisoblagichlar (kalitda faqat HMAC qilingan email/IP).
CREATE TABLE rate_limits (
  bucket TEXT PRIMARY KEY,
  window_start INTEGER NOT NULL,
  count INTEGER NOT NULL
);

CREATE TABLE admins (
  user_id TEXT PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  granted_at INTEGER NOT NULL,
  granted_reason TEXT NOT NULL
);

CREATE TABLE reviewers (
  user_id TEXT PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  granted_at INTEGER NOT NULL,
  granted_by TEXT
);

-- Admin TOTP: maxfiy kalit AES-GCM bilan shifrlangan (kalit Worker secretida).
CREATE TABLE totp_factors (
  user_id TEXT PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  secret_enc TEXT NOT NULL,
  verified INTEGER NOT NULL DEFAULT 0,
  last_step INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

-- Faqat qo'shiladi; hech bir API o'zgartirmaydi/o'chirmaydi. Hisob
-- o'chirilganda ham qoladi (faqat ichki id, email emas).
CREATE TABLE audit_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  at INTEGER NOT NULL,
  actor TEXT,
  action TEXT NOT NULL,
  target TEXT,
  details TEXT NOT NULL DEFAULT '{}'
);
CREATE INDEX audit_at ON audit_log (at DESC);
