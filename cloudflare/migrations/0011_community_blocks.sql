-- Hamjamiyat: foydalanuvchi boshqa muallifni bloklaydi (App Store 1.2,
-- D-62). Bloklangan muallifning savol va javoblari faqat SHU ko'ruvchiga
-- server ro'yxatlarida ko'rsatilmaydi (boshqa qurilmada ham).
--
-- Maxfiylik: ikkala ustun ham `user_hash` (HMAC(server kaliti, user_id)) —
-- foydalanuvchi id si yoki email emas. Ilovaga faqat `author.ref`
-- (HMAC(server kaliti, 'author-ref:' || user_hash) ning qisqa ko'rinishi)
-- chiqadi; undan muallifni tiklab bo'lmaydi.
-- Hisob o'chirilganda ikki tomondagi yozuvlar ham o'chadi.

CREATE TABLE community_blocks (
  viewer_hash TEXT NOT NULL CHECK (length(viewer_hash) = 64),
  author_hash TEXT NOT NULL CHECK (length(author_hash) = 64),
  created_at INTEGER NOT NULL,
  PRIMARY KEY (viewer_hash, author_hash),
  CHECK (viewer_hash <> author_hash)
);
CREATE INDEX community_blocks_author ON community_blocks (author_hash);
