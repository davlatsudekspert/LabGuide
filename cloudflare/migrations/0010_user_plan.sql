-- Foydalanuvchi rejasi — keyingi to'liq yangilanish uchun ko'rinmas
-- tayyorgarlik. Hozirgi ilovada to'lov ham, Pro ham yo'q (D-58): bu
-- ustunlarni hech bir endpoint o'qimaydi/yozmaydi va ilova ishlatmaydi.
-- 0007_billing o'chirildi (hech qachon deploy qilinmagan; to'liq ish —
-- `pro-later` branchida); 0008/0009 boshqa ishlar uchun band.
ALTER TABLE users ADD COLUMN plan TEXT NOT NULL DEFAULT 'free'
  CHECK (plan IN ('free', 'pro'));
ALTER TABLE users ADD COLUMN pro_until INTEGER;
