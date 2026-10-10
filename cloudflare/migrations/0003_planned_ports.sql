-- REJA (TODO): Supabase'dagi qolgan server funksiyalari uchun sxema.
-- Jadvallar tayyor, lekin endpointlar HALI YO'Q — Worker ular uchun
-- `501 not_implemented` qaytaradi va ilova adapteri "ulanmagan" deydi.
-- Hech biri ishlayotgandek ko'rsatilmaydi. Qoidalar manbai: supabase/migrations.

-- TODO(support): "Taklif va yordam" — foydalanuvchi faqat o'z yozishmasini
-- ko'radi; javobni admin o'zi yozadi (avtomatik/AI javob yo'q).
-- Skrinshotlar: yopiq R2 bucket (PNG/JPEG <= 5 MB, kuniga 10 ta) — R2 hali
-- ulanmagan, shuning uchun `attachment_key` faqat joy.
CREATE TABLE support_threads (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  kind TEXT NOT NULL CHECK (kind IN ('suggestion', 'bug', 'question')),
  subject TEXT NOT NULL CHECK (length(trim(subject)) BETWEEN 3 AND 120),
  status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'in_review', 'answered', 'closed')),
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  last_user_message_at INTEGER NOT NULL,
  last_admin_message_at INTEGER,
  user_read_at INTEGER NOT NULL,
  admin_read_at INTEGER
);
CREATE INDEX support_threads_user ON support_threads (user_id, updated_at DESC);

CREATE TABLE support_messages (
  id TEXT PRIMARY KEY,
  thread_id TEXT NOT NULL REFERENCES support_threads (id) ON DELETE CASCADE,
  from_admin INTEGER NOT NULL DEFAULT 0,
  body TEXT NOT NULL CHECK (length(trim(body)) BETWEEN 1 AND 4000),
  attachment_key TEXT,
  created_at INTEGER NOT NULL
);
CREATE INDEX support_messages_thread ON support_messages (thread_id, created_at);

-- TODO(admin): statistika (faqat tasdiqlangan hisoblar — `users`; mehmonlar
-- serverga umuman tushmaydi), foydalanuvchilar ro'yxati (`email_masked`),
-- reviewer berish, audit o'qish. To'liq emailni "ochish" bu serverda YO'Q —
-- email saqlanmaydi (faqat HMAC). Alohida jadval kerak emas.

-- TODO(content review): tekshiruvchi qarorlari.
CREATE TABLE content_reviews (
  id TEXT PRIMARY KEY,
  item_kind TEXT NOT NULL CHECK (item_kind IN ('analyte', 'quiz')),
  item_id TEXT NOT NULL,
  content_version TEXT NOT NULL,
  reviewer_id TEXT REFERENCES users (id) ON DELETE SET NULL,
  decision TEXT NOT NULL CHECK (decision IN ('approve', 'changes')),
  comment TEXT,
  created_at INTEGER NOT NULL
);

-- TODO(partners): hamkorlar (reklama), arizalar, kunlik umumiy hisoblagich.
CREATE TABLE partners (
  id TEXT PRIMARY KEY,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'paused', 'archived')),
  data TEXT NOT NULL DEFAULT '{}', -- JSON (nom, logo URL, havolalar, joylar)
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE partner_requests (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users (id) ON DELETE SET NULL,
  data TEXT NOT NULL, -- JSON: kompaniya, aloqa, mahsulotlar, xabar
  status TEXT NOT NULL DEFAULT 'new',
  admin_reply TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Kunlik umumiy son (kim bosgani saqlanmaydi).
CREATE TABLE partner_events (
  partner_id TEXT NOT NULL REFERENCES partners (id) ON DELETE CASCADE,
  day TEXT NOT NULL,
  placement TEXT NOT NULL,
  impressions INTEGER NOT NULL DEFAULT 0,
  contacts INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (partner_id, day, placement)
);

-- TODO(entitlements): Pro huquqlari — yozish faqat do'kon tekshiruvidan
-- keyin server ichida (verify-purchase porti), ilova faqat o'qiydi.
CREATE TABLE entitlements (
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  product TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('app_store', 'google_play', 'manual')),
  expires_at INTEGER,
  updated_at INTEGER NOT NULL,
  PRIMARY KEY (user_id, product)
);
