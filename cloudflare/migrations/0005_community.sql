-- Hamjamiyat (D-43): mutaxassisni tasdiqlash, savol-javob, shikoyatlar,
-- mashina tarjimasi keshi.
--
-- Maxfiylik tamoyillari:
-- * Hamjamiyat jadvallarida foydalanuvchi id si EMAS, `user_hash` =
--   HMAC(server kaliti, user_id) saqlanadi — jadvallar `users` bilan faqat
--   server secreti orqali bog'lanadi.
-- * Tasdiqlash hujjati (rasm) HECH QAYERDA saqlanmaydi: na D1, na R2, na
--   log. Faqat natija: rol, mamlakat, holat, qisqa AI sababi, sana.
-- * Qo'lda tekshirilgan (egasi) yozuvda faqat metadata: muassasa,
--   mutaxassislik kodi, malaka turi, yil — ism va hujjat raqami yo'q.
-- * Holat (`verified`) va admin vakolatini mijoz bera olmaydi: faqat server
--   (AI natijasi yoki admin amali).

CREATE TABLE community_members (
  user_hash TEXT PRIMARY KEY CHECK (length(user_hash) = 64),
  role TEXT CHECK (role IS NULL OR role IN
    ('laborant', 'biochemist', 'kdl_doctor', 'teacher', 'other', 'clinical_lab_diagnostics')),
  country TEXT CHECK (country IS NULL OR length(country) = 2),
  -- none: hujjat yo'q (oddiy a'zo); verified; rejected (AI rad etdi yoki
  -- admin bekor qildi); suspended (3 ta turli shikoyat yoki admin).
  status TEXT NOT NULL DEFAULT 'none'
    CHECK (status IN ('none', 'verified', 'rejected', 'suspended')),
  -- Admin tiklaganda qaytadigan holat (to'xtatishdan oldingi).
  prev_status TEXT CHECK (prev_status IS NULL OR prev_status IN ('none', 'verified', 'rejected')),
  method TEXT CHECK (method IS NULL OR method IN ('ai_auto', 'manual_document_review')),
  ai_reason TEXT CHECK (ai_reason IS NULL OR length(ai_reason) <= 200),
  institution TEXT CHECK (institution IS NULL OR length(institution) <= 120),
  specialty_code TEXT CHECK (specialty_code IS NULL OR length(specialty_code) <= 120),
  credential TEXT CHECK (credential IS NULL OR length(credential) <= 120),
  year INTEGER CHECK (year IS NULL OR year BETWEEN 1950 AND 2100),
  verified_at INTEGER,
  suspended_at INTEGER,
  -- Tiklashdan oldingi shikoyatlar qayta to'xtatishga sanalmaydi.
  restored_at INTEGER,
  -- Egasi hisobi: hamjamiyatda LG_OWNER_DISPLAY_NAME nomi bilan ko'rinadi.
  is_owner INTEGER NOT NULL DEFAULT 0 CHECK (is_owner IN (0, 1)),
  updated_at INTEGER NOT NULL
);
CREATE INDEX community_members_status ON community_members (status);
CREATE UNIQUE INDEX community_members_owner ON community_members (is_owner) WHERE is_owner = 1;

CREATE TABLE community_questions (
  id TEXT PRIMARY KEY,
  author_hash TEXT NOT NULL,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 10 AND 200),
  body TEXT NOT NULL CHECK (length(trim(body)) BETWEEN 10 AND 4000),
  lang TEXT NOT NULL CHECK (lang IN ('uz', 'ru', 'en')),
  -- Ixtiyoriy mavzu: 'analyte:<id>' yoki 'condition:<id>' (ilova kontentidan).
  topic TEXT CHECK (topic IS NULL OR length(topic) BETWEEN 3 AND 100),
  pinned INTEGER NOT NULL DEFAULT 0 CHECK (pinned IN (0, 1)),
  best_answer_id TEXT,
  answer_count INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);
CREATE INDEX community_questions_list ON community_questions (pinned DESC, created_at DESC);
CREATE INDEX community_questions_topic ON community_questions (topic, created_at DESC);
CREATE INDEX community_questions_author ON community_questions (author_hash, created_at DESC);

CREATE TABLE community_answers (
  id TEXT PRIMARY KEY,
  question_id TEXT NOT NULL REFERENCES community_questions (id) ON DELETE CASCADE,
  author_hash TEXT NOT NULL,
  body TEXT NOT NULL CHECK (length(trim(body)) BETWEEN 10 AND 4000),
  lang TEXT NOT NULL CHECK (lang IN ('uz', 'ru', 'en')),
  upvotes INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);
CREATE INDEX community_answers_question ON community_answers (question_id, created_at);
CREATE INDEX community_answers_author ON community_answers (author_hash);

-- Ovoz: faqat tasdiqlangan mutaxassis, bitta javobga bitta.
CREATE TABLE community_votes (
  answer_id TEXT NOT NULL REFERENCES community_answers (id) ON DELETE CASCADE,
  voter_hash TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  PRIMARY KEY (answer_id, voter_hash)
);
CREATE INDEX community_votes_voter ON community_votes (voter_hash);

-- Shikoyat: post (savol/javob) va uning muallifi; bitta odam bitta postga
-- bir marta. Ko'rinishi — faqat admin.
CREATE TABLE community_reports (
  id TEXT PRIMARY KEY,
  target_kind TEXT NOT NULL CHECK (target_kind IN ('question', 'answer')),
  target_id TEXT NOT NULL,
  target_user_hash TEXT NOT NULL,
  reporter_hash TEXT NOT NULL,
  reason TEXT NOT NULL CHECK (reason IN ('spam', 'wrong', 'abuse', 'fake_specialist', 'patient_data', 'other')),
  created_at INTEGER NOT NULL,
  UNIQUE (target_kind, target_id, reporter_hash)
);
CREATE INDEX community_reports_target_user ON community_reports (target_user_hash, created_at);

-- Mashina tarjimasi keshi: (post, til) bo'yicha bir marta.
CREATE TABLE community_translations (
  post_kind TEXT NOT NULL CHECK (post_kind IN ('question', 'answer')),
  post_id TEXT NOT NULL,
  lang TEXT NOT NULL CHECK (lang IN ('uz', 'ru', 'en')),
  title TEXT,
  body TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  PRIMARY KEY (post_kind, post_id, lang)
);
