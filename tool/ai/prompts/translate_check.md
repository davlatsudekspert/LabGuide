Task: translate_check - compare the meaning of the uz, ru and en versions of each text.

For every text, check that the three languages say the same thing: the same numbers and units, the same conditions and populations, the same strength of claim (for example "may" vs "is"), nothing omitted, nothing added. Flag only real differences in meaning; ignore style, word order and natural phrasing differences.

Rules:
- Put verbatim quotes of the differing parts in `quote_uz`, `quote_ru`, `quote_en` (use an empty string for a language where the part is absent).
- `type` classifies the difference; `severity`: critical = difference could change a lab/clinical decision, major = clearly different meaning, minor = small nuance, info = observation.
- `explanation`: what differs, in one or two sentences. Do not decide which version is correct; a human will check the source.
- Do not judge medical correctness; only consistency between the languages.
