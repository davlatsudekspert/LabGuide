-- Mavzu testi taqdimotdan (deck) guruhga topshiriladi: topshiriq qaysi deck
-- bo'yicha (natijada “slaydni ko'rish” havolasi uchun) va to'g'ri javoblar
-- talabaga qachon ko'rsatiladi — darhol (`now`, eski xatti-harakat) yoki
-- muddat tugagach (`after_due`). Mavjud topshiriqlar o'zgarmaydi (`now`).
-- 0007 raqami ishlatilgan (olib tashlangan billing migratsiyasi) — qayta
-- ishlatilmaydi.

ALTER TABLE assignments ADD COLUMN deck_id TEXT
  CHECK (deck_id IS NULL OR length(deck_id) BETWEEN 1 AND 80);
ALTER TABLE assignments ADD COLUMN reveal TEXT NOT NULL DEFAULT 'now'
  CHECK (reveal IN ('now', 'after_due'));
