-- Egasi admin paneli: ilova ichidagi shikoyatlar (Apple 1.2), hisobni
-- to'xtatish, “hozir onlayn” uchun faollik daqiqasi, hamjamiyat shikoyatlari
-- holati. Taklif va yordam jadvallari 0003 da bor. To'lov/obuna bilan bog'liq
-- hech narsa yo'q (ilova hozircha to'liq bepul — egasi qarori).

-- Hisob: to'xtatilgan (sessiyalar o'chiriladi, qayta kirish rad etiladi),
-- oxirgi faollik daqiqasi (aniq vaqt emas — daqiqaga yaxlitlangan; IP yo'q).
ALTER TABLE users ADD COLUMN suspended_at INTEGER;
ALTER TABLE users ADD COLUMN last_seen_at INTEGER;
-- Kelajak uchun tayyorgarlik (ilovada ko'rinmaydi, hech bir API qaytarmaydi
-- va o'zgartirmaydi): hisob rejasi. Hozir hamma — 'free'.
ALTER TABLE users ADD COLUMN plan TEXT NOT NULL DEFAULT 'free' CHECK (plan IN ('free', 'pro'));
ALTER TABLE users ADD COLUMN pro_until INTEGER;

-- Sessiya qaysi usul bilan ochilgan: admin panel faqat email kodi (otp) bilan.
ALTER TABLE sessions ADD COLUMN via TEXT NOT NULL DEFAULT 'otp' CHECK (via IN ('otp', 'google', 'apple'));

-- Ilova ichidagi shikoyat/xabar: hisobli foydalanuvchi ham, mehmon ham
-- yuboradi (mehmonda hech qanday identifikator saqlanmaydi; limit — IP HMAC
-- bo'yicha, kalitning o'zi saqlanmaydi). Admin izoh yozadi va hal qiladi.
CREATE TABLE complaints (
  id TEXT PRIMARY KEY,
  kind TEXT NOT NULL CHECK (kind IN ('complaint', 'inappropriate', 'bug', 'ad', 'other')),
  body TEXT NOT NULL CHECK (length(trim(body)) BETWEEN 5 AND 2000),
  -- Ixtiyoriy ishora: ekran/karta/post id (masalan, 'community:question:abc').
  target_ref TEXT CHECK (target_ref IS NULL OR length(target_ref) BETWEEN 1 AND 200),
  -- Mehmon — NULL. Hisob o'chirilsa — NULL (shikoyat matni qoladi).
  user_id TEXT REFERENCES users (id) ON DELETE SET NULL,
  lang TEXT CHECK (lang IS NULL OR lang IN ('uz', 'ru', 'en')),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved')),
  admin_note TEXT CHECK (admin_note IS NULL OR length(admin_note) <= 2000),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  resolved_at INTEGER
);
CREATE INDEX complaints_status ON complaints (status, created_at DESC);
CREATE INDEX complaints_user ON complaints (user_id);

-- Hamjamiyat shikoyati holati: open — admin ko'rmagan; dismissed — asossiz
-- (avtomatik to'xtatishga ham endi sanalmaydi); resolved — chora ko'rildi.
ALTER TABLE community_reports ADD COLUMN status TEXT NOT NULL DEFAULT 'open'
  CHECK (status IN ('open', 'dismissed', 'resolved'));
ALTER TABLE community_reports ADD COLUMN handled_at INTEGER;
CREATE INDEX community_reports_status ON community_reports (status, created_at DESC);

-- Statistika va ro'yxatlar uchun indekslar.
CREATE INDEX users_created ON users (created_at);
CREATE INDEX users_last_seen ON users (last_seen_on);
CREATE INDEX users_last_seen_at ON users (last_seen_at);
CREATE INDEX support_threads_status ON support_threads (status, updated_at DESC);
