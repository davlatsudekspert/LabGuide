-- Ustoz Pro (D-78): o'z testlari (teacherTestBuilder), talabalarga/guruhga
-- topshirish va taklifnomalar (teacherTestAssign), natijalar
-- (teacherResults), talaba tomoni (teacherTests, `learner`).
--
-- FAQAT MIGRATSIYA FAYLI: production D1 ga qo'llanmagan; yo'llar
-- LG_BILLING_ENABLED=true bo'lmaguncha 404 (src/teachertests.ts). Raqam 0020:
-- 0019 parallel `paid/srv` tarmog'ida band (`0019_trial_attest_guest.sql`) —
-- birlashtirilgach raqamlar uzilishsiz bo'ladi (repo_registry_guard).
--
-- Bugungi BEPUL guruhlar (0002/0004/0010/0012: study_groups, group_members,
-- assignments, submissions) O'ZGARMAYDI — bu jadvallar faqat ularga havola
-- qiladi. Guruh o'chirilsa (ON DELETE CASCADE) yoki hisob o'chirilsa
-- (auth.ts deleteUserData + CASCADE) Pro yozuvlari ham o'chadi.
--
-- Qoidalar:
-- * Test faqat egasiniki (owner_id); talabaga kalit (correct) va izoh
--   topshirilgunga qadar berilmaydi.
-- * Topshiriq testning NUSXASI (questions) — test keyin tahrirlansa ham
--   berilgan topshiriq va natijalar o'zgarmaydi.
-- * Topshiriq doim ustozning o'z guruhi orqali: butun guruhga (user_id NULL)
--   yoki shu guruhning bitta a'zosiga. Ustoz faqat guruhga o'zi qo'shilgan
--   (kod/taklifnoma bilan rozilik bergan) talabalar natijasini ko'radi.
-- * Talaba guruhdan chiqsa (yoki chiqarilsa) — shu guruh topshiriqlaridagi
--   urinishlari o'chiriladi (groups.ts).
-- * Taklifnoma kodi xom saqlanmaydi: qidirish — HMAC (token_hash), egasiga
--   qayta ko'rsatish — shifrlangan (token_enc).

CREATE TABLE teacher_tests (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 3 AND 120),
  description TEXT CHECK (description IS NULL OR length(description) <= 1000),
  -- JSON: [{"text","options":[..],"correct":i,"explanation"?,"source"?:{"bank","id"}}]
  questions TEXT NOT NULL,
  question_count INTEGER NOT NULL CHECK (question_count BETWEEN 0 AND 100),
  time_limit_minutes INTEGER CHECK (time_limit_minutes IS NULL OR time_limit_minutes BETWEEN 1 AND 180),
  pass_percent INTEGER CHECK (pass_percent IS NULL OR pass_percent BETWEEN 1 AND 100),
  status TEXT NOT NULL CHECK (status IN ('unpublished', 'published')),
  version INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  published_at INTEGER
);
CREATE INDEX teacher_tests_owner ON teacher_tests (owner_id, updated_at DESC);

CREATE TABLE teacher_test_assignments (
  id TEXT PRIMARY KEY,
  test_id TEXT NOT NULL REFERENCES teacher_tests (id) ON DELETE CASCADE,
  owner_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  group_id TEXT NOT NULL REFERENCES study_groups (id) ON DELETE CASCADE,
  -- NULL — butun guruh (hozirgi va keyin qo'shiladigan a'zolar).
  user_id TEXT REFERENCES users (id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 3 AND 120),
  questions TEXT NOT NULL,
  question_count INTEGER NOT NULL CHECK (question_count BETWEEN 1 AND 100),
  time_limit_minutes INTEGER CHECK (time_limit_minutes IS NULL OR time_limit_minutes BETWEEN 1 AND 180),
  pass_percent INTEGER CHECK (pass_percent IS NULL OR pass_percent BETWEEN 1 AND 100),
  max_attempts INTEGER NOT NULL CHECK (max_attempts BETWEEN 1 AND 5),
  due_at INTEGER NOT NULL,
  -- `reject` — muddatdan keyin yangi urinish/topshirish yo'q;
  -- `accept` — qabul qilinadi, "kechikkan" deb belgilanadi.
  late_policy TEXT NOT NULL CHECK (late_policy IN ('reject', 'accept')),
  status TEXT NOT NULL CHECK (status IN ('active', 'closed')),
  created_at INTEGER NOT NULL,
  closed_at INTEGER
);
CREATE INDEX teacher_test_assignments_group ON teacher_test_assignments (group_id, created_at DESC);
CREATE INDEX teacher_test_assignments_owner ON teacher_test_assignments (owner_id, created_at DESC);
CREATE INDEX teacher_test_assignments_test ON teacher_test_assignments (test_id);

CREATE TABLE teacher_test_attempts (
  id TEXT PRIMARY KEY,
  assignment_id TEXT NOT NULL REFERENCES teacher_test_assignments (id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  attempt_no INTEGER NOT NULL CHECK (attempt_no BETWEEN 1 AND 5),
  started_at INTEGER NOT NULL,
  -- Vaqt chegarasi tugash vaqti (NULL — vaqtsiz test).
  time_up_at INTEGER,
  submitted_at INTEGER,
  answers TEXT,
  correct TEXT,
  score INTEGER,
  total INTEGER NOT NULL,
  late INTEGER NOT NULL DEFAULT 0 CHECK (late IN (0, 1)),
  status TEXT NOT NULL CHECK (status IN ('started', 'submitted', 'expired')),
  UNIQUE (assignment_id, user_id, attempt_no)
);
CREATE INDEX teacher_test_attempts_user ON teacher_test_attempts (user_id);
-- Bir vaqtda bitta ochiq urinish (parallel "Boshlash" ikkinchisini yaratmaydi).
CREATE UNIQUE INDEX teacher_test_attempts_open ON teacher_test_attempts (assignment_id, user_id)
  WHERE status = 'started';

CREATE TABLE teacher_invites (
  id TEXT PRIMARY KEY,
  group_id TEXT NOT NULL REFERENCES study_groups (id) ON DELETE CASCADE,
  owner_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  token_hash TEXT NOT NULL UNIQUE CHECK (length(token_hash) = 64),
  -- Kod faqat egasiga qayta ko'rsatish uchun: AES-GCM (server kaliti).
  token_enc TEXT NOT NULL,
  max_uses INTEGER NOT NULL CHECK (max_uses BETWEEN 1 AND 200),
  uses INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  expires_at INTEGER NOT NULL,
  revoked_at INTEGER
);
CREATE INDEX teacher_invites_group ON teacher_invites (group_id, created_at DESC);
