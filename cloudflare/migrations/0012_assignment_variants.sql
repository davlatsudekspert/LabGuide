-- Variantli test (D-66): "Har bir talabaga boshqa savollar". Topshiriq
-- `question_ids` da endi mavzuning savollar HOVUZI (≤ 60) saqlanadi,
-- `per_student` — har talabaga tushadigan savollar soni (NULL — oddiy test,
-- hammaga bir xil to'plam). Talaba to'plami serverda va ilovada bir xil
-- deterministik tanlanadi: SHA-256("<topshiriq id>:<user id>:<savol id>")
-- bo'yicha saralash, `pool_topics` (har savolning mavzu id si, hovuz bilan
-- parallel JSON massiv; NULL — bitta qatlam) bo'yicha navbatma-navbat.
-- `submissions.question_ids` — talabaga tushgan savollar (javoblar shu
-- tartibda); oddiy testda NULL (topshiriq tartibi). Mavjud yozuvlar o'zgarmaydi.

ALTER TABLE assignments ADD COLUMN per_student INTEGER
  CHECK (per_student IS NULL OR per_student BETWEEN 1 AND 50);
ALTER TABLE assignments ADD COLUMN pool_topics TEXT;
ALTER TABLE submissions ADD COLUMN question_ids TEXT;
