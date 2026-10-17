Task: quiz_draft - draft multiple-choice questions strictly from the provided card text.

Write up to 3 questions (fewer, or none, if the text does not support good ones). Each question:
- is answerable ONLY from a single sentence that appears verbatim in the provided texts; copy that sentence into `support_quote` and name its `source_field` and `support_lang` (uz, ru or en). The quote must be an exact substring of that field in that language.
- has exactly {{N_OPTIONS}} options, exactly one correct; `correct_index` is the 0-based index of the correct option. Distractors must be plausible but clearly wrong according to the same card, never "all of the above" / "none of the above".
- gives `prompt`, every option `text`, every option `explanation` and `basis` in all three languages (uz, ru, en), with identical meaning in each language. `basis` states what the supporting sentence says. Explanations for wrong options must not introduce new medical facts that are not in the provided text.
- must not ask about anything not stated in the provided texts: no outside knowledge, no new numbers, no treatment advice, no diagnosis from a single result.
- Vary the position of the correct option across questions.

If the text cannot support a sound question, return an empty `questions` list and explain in `skipped_reason` (otherwise leave `skipped_reason` as an empty string). The output is a DRAFT for a human expert; it is never published automatically.
