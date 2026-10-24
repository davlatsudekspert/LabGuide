-- Admin tomonidan berilgan Pro (D-73). FAQAT MIGRATSIYA FAYLI: production D1
-- ga qo'llanmagan; yo'llar LG_BILLING_ENABLED=true bo'lmaguncha 404.
--
-- Qoidalar:
-- * Email ochiq saqlanmaydi: faqat HMAC (`users.email_hash` bilan bir xil) va
--   niqoblangan ko'rinish. Hisob hali yo'q bo'lsa grant KUTILMOQDA
--   (`starts_at IS NULL`) va hisob ochilganda / birinchi kirishda amalga
--   oshiriladi (muddat o'sha paytdan hisoblanadi).
-- * Bir emailga bitta FAOL grant (`pro_grants_active_email`); qayta berish
--   mavjudini almashtiradi yoki uzaytiradi (aniq `mode`).
-- * Bekor qilingan qator o'chirilmaydi (`revoked_at`) — tarix; huquq darhol
--   yo'qoladi. Hisob o'chirilsa — shu emailning grantlari ham o'chadi.
-- * Do'kon obunasini hech qachon bosib o'tmaydi: huquq hal qilishda
--   (billing.ts `resolveAccess`) eng yuqori daraja / eng uzoq muddat yutadi.
CREATE TABLE pro_grants (
  id TEXT PRIMARY KEY,
  email_hmac TEXT NOT NULL,
  email_masked TEXT NOT NULL,
  tier TEXT NOT NULL CHECK (tier IN ('student', 'teacher', 'specialist')),
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
CREATE UNIQUE INDEX pro_grants_active_email ON pro_grants (email_hmac) WHERE revoked_at IS NULL;
CREATE INDEX pro_grants_email ON pro_grants (email_hmac);
