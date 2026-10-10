-- Ustoz–talaba: guruh, a'zolik, mavzular, savol-javob belgilari, test
-- sessiyalari, javoblar va natijalar.
--
-- * Guruhni faqat profil roli `teacher` bo'lgan hisob yaratadi va u o'sha
--   guruhda yagona ustoz (owner). Ustoz huquqi faqat o'z guruhlariga.
-- * A'zo ismi saqlanmaydi: ixtiyoriy taxallus yoki "Talaba NN" (member_no).
-- * Test kaliti alohida jadvalda — faqat ustozga; ball serverda.

CREATE TABLE study_groups (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (length(trim(name)) BETWEEN 3 AND 80),
  join_code TEXT NOT NULL UNIQUE CHECK (length(join_code) = 8),
  next_member_no INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL
);
CREATE INDEX study_groups_owner ON study_groups (owner_id);

CREATE TABLE group_members (
  group_id TEXT NOT NULL REFERENCES study_groups (id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  member_role TEXT NOT NULL CHECK (member_role IN ('teacher', 'student')),
  member_no INTEGER NOT NULL,
  nickname TEXT CHECK (nickname IS NULL OR length(nickname) BETWEEN 2 AND 30),
  joined_at INTEGER NOT NULL,
  PRIMARY KEY (group_id, user_id)
);
CREATE INDEX group_members_user ON group_members (user_id);

-- Ustoz ochgan mavzular (o'quv rejasi kuni id si, ilova kontentidan).
CREATE TABLE group_topics (
  group_id TEXT NOT NULL REFERENCES study_groups (id) ON DELETE CASCADE,
  day_id TEXT NOT NULL CHECK (length(day_id) BETWEEN 1 AND 64),
  opened_at INTEGER NOT NULL,
  closed_at INTEGER,
  PRIMARY KEY (group_id, day_id)
);

-- Savol-javob belgilari: ustoz talabaning og'zaki/yozma javobini belgilaydi,
-- baho (1–5) ixtiyoriy. Talaba faqat o'zinikini ko'radi.
CREATE TABLE qa_marks (
  id TEXT PRIMARY KEY,
  group_id TEXT NOT NULL REFERENCES study_groups (id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  day_id TEXT NOT NULL CHECK (length(day_id) BETWEEN 1 AND 64),
  question_id TEXT NOT NULL CHECK (length(question_id) BETWEEN 1 AND 64),
  result TEXT NOT NULL CHECK (result IN ('correct', 'partial', 'incorrect', 'skipped')),
  grade INTEGER CHECK (grade IS NULL OR grade BETWEEN 1 AND 5),
  marked_at INTEGER NOT NULL,
  UNIQUE (group_id, user_id, day_id, question_id)
);
CREATE INDEX qa_marks_group ON qa_marks (group_id, day_id);
CREATE INDEX qa_marks_user ON qa_marks (user_id);

-- Test sessiyasi: ustoz ochadi (open) va yakunlaydi (closed).
CREATE TABLE assignments (
  id TEXT PRIMARY KEY,
  group_id TEXT NOT NULL REFERENCES study_groups (id) ON DELETE CASCADE,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 3 AND 120),
  day_id TEXT,
  question_ids TEXT NOT NULL, -- JSON massiv
  time_limit_minutes INTEGER CHECK (time_limit_minutes IS NULL OR time_limit_minutes BETWEEN 1 AND 180),
  due_at INTEGER,
  status TEXT NOT NULL CHECK (status IN ('draft', 'open', 'closed')),
  opened_at INTEGER,
  closed_at INTEGER,
  created_at INTEGER NOT NULL
);
CREATE INDEX assignments_group ON assignments (group_id, created_at DESC);

CREATE TABLE assignment_keys (
  assignment_id TEXT PRIMARY KEY REFERENCES assignments (id) ON DELETE CASCADE,
  correct_indexes TEXT NOT NULL -- JSON massiv
);

CREATE TABLE assignment_attempts (
  assignment_id TEXT NOT NULL REFERENCES assignments (id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  started_at INTEGER NOT NULL,
  PRIMARY KEY (assignment_id, user_id)
);

CREATE TABLE submissions (
  assignment_id TEXT NOT NULL REFERENCES assignments (id) ON DELETE CASCADE,
  user_id TEXT NOT NULL REFERENCES users (id) ON DELETE CASCADE,
  answers TEXT NOT NULL, -- JSON
  correct TEXT NOT NULL, -- JSON
  score INTEGER NOT NULL,
  total INTEGER NOT NULL,
  submitted_at INTEGER NOT NULL,
  PRIMARY KEY (assignment_id, user_id)
);
CREATE INDEX submissions_user ON submissions (user_id);
