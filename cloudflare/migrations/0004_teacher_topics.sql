-- Ustoz ro'yxati, taxallus/tartib raqam va o'quv dasturi mavzulari —
-- ilova kontrakti (lib/core/backend/lab_backend.dart, FakeLabBackend,
-- supabase/migrations/20261010000100_teacher_topics.sql) bilan bir xil.
--
-- * Ustoz: email kodi bilan kirgan hisob o'zini ro'yxatdan o'tkazadi
--   (`POST /v1/me/teacher`). Bu faqat guruh ochish huquqi; admin EMAS.
--   Profil roli (`users.role = 'teacher'`) endi guruh ochishga yetmaydi.
-- * Mavzu: ochilgan, ma'ruza/savol-javob o'tilgan vaqt va mavzuga bitta
--   test (`test_assignment_id`).

CREATE TABLE teacher_accounts (
  user_id TEXT PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
  registered_at INTEGER NOT NULL
);

-- Avval guruh ochgan hisoblar ustoz sifatida saqlanadi.
INSERT INTO teacher_accounts (user_id, registered_at)
  SELECT owner_id, MIN(created_at) FROM study_groups GROUP BY owner_id;

-- group_topics qayta quriladi: mavzu id si 80 belgigacha (CHECK SQLite'da
-- o'zgartirilmaydi), dars bosqichlari va mavzu testi qo'shiladi.
CREATE TABLE group_topics_v2 (
  group_id TEXT NOT NULL REFERENCES study_groups (id) ON DELETE CASCADE,
  topic_id TEXT NOT NULL CHECK (length(topic_id) BETWEEN 1 AND 80),
  opened_at INTEGER NOT NULL,
  closed_at INTEGER,
  lecture_done_at INTEGER,
  oral_done_at INTEGER,
  test_assignment_id TEXT REFERENCES assignments (id) ON DELETE SET NULL,
  PRIMARY KEY (group_id, topic_id)
);
INSERT INTO group_topics_v2 (group_id, topic_id, opened_at, closed_at)
  SELECT group_id, day_id, opened_at, closed_at FROM group_topics;
DROP TABLE group_topics;
ALTER TABLE group_topics_v2 RENAME TO group_topics;
CREATE UNIQUE INDEX group_topics_test ON group_topics (test_assignment_id)
  WHERE test_assignment_id IS NOT NULL;
