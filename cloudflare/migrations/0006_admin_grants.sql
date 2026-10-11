-- Adminlar boshqaruvi (D-44): super admin (maxfiy LG_ADMIN_EMAILS dagi email)
-- ilovadan boshqa emailni admin qilib qo'shadi va olib tashlaydi.
--
-- Xavfsizlik tamoyillari:
-- * Email ochiq holda SAQLANMAYDI: `email_hmac` = HMAC(server kaliti, email) —
--   `users.email_hash` bilan bir xil kalit, shuning uchun hisob bor-yo'qligi
--   tekshiriladi; ko'rsatish uchun faqat niqoblangan ko'rinish (`ab***@gmail.com`).
-- * Yozuvni faqat server (super admin + TOTP aal2 so'rovi) yaratadi; mijoz
--   o'zini admin qila olmaydi. Hech kim o'zini qo'sha olmaydi: oddiy admin
--   qo'sha olmaydi, super admin esa allaqachon admin.
-- * Grant faqat vakolatga “ruxsatnoma”: email kod bilan tasdiqlanganda (yoki
--   hisob mavjud bo'lsa darhol) `admins` ga `granted_reason = 'admin_grant'`
--   bilan yoziladi; admin amallari baribir TOTP (aal2) talab qiladi.
-- * Olib tashlash — `revoked_at` (yozuv tarix uchun qoladi), `admins` dan
--   o'chiriladi va o'sha hisob sessiyalari aal1 ga tushiriladi.
-- * Kim berdi/oldi — `granted_by_hash` / `revoked_by_hash` (HMAC(user_id),
--   hamjamiyat kaliti); audit_log da faqat grant id si.

CREATE TABLE admin_grants (
  id TEXT PRIMARY KEY,
  email_hmac TEXT NOT NULL CHECK (length(email_hmac) = 64),
  email_masked TEXT NOT NULL,
  granted_by_hash TEXT NOT NULL CHECK (length(granted_by_hash) = 64),
  created_at INTEGER NOT NULL,
  revoked_at INTEGER,
  revoked_by_hash TEXT
);
-- Bitta email uchun bir vaqtda faqat bitta faol grant.
CREATE UNIQUE INDEX admin_grants_active ON admin_grants (email_hmac) WHERE revoked_at IS NULL;
CREATE INDEX admin_grants_created ON admin_grants (created_at DESC);
