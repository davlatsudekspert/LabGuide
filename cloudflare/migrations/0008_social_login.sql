-- LabGuide (Cloudflare D1): Google / Apple bilan kirish (D-56).
--
-- * `auth_identities`: tashqi kirish identifikatori (provayderning `sub` i)
--   ichki hisobga bog'lanadi. TOKEN SAQLANMAYDI (ID token, refresh token,
--   authorization code — hech biri). Email ham bu yerda emas: hisob emaili
--   `users.email_hash` (HMAC) da, bitta email = bitta hisob.
-- * `auth_replay`: bir martalik ID token belgisi (faqat SHA-256 hash, token
--   amal qilish muddatigacha) — o'g'irlangan tokenni qayta ishlatishga qarshi.
--   Kunlik tozalash bilan o'chadi (src/app.ts `scheduled`).

CREATE TABLE auth_identities (
  provider TEXT NOT NULL CHECK (provider IN ('google', 'apple')),
  provider_sub TEXT NOT NULL,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  created_at INTEGER NOT NULL,
  UNIQUE (provider, provider_sub)
);
CREATE INDEX auth_identities_user ON auth_identities (user_id);

CREATE TABLE auth_replay (
  key_hash TEXT PRIMARY KEY,
  expires_at INTEGER NOT NULL
);
CREATE INDEX auth_replay_expiry ON auth_replay (expires_at);
