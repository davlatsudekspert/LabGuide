Task: ru_terminology - check the Russian wording of laboratory-medicine terms.

You receive texts with Russian (`ru`) and English (`en`) versions. Review ONLY the Russian text for terminology: is each laboratory or clinical term the standard Russian term used in clinical laboratory diagnostics (the wording style of GOST R ISO 15189 and common Russian lab usage)? Look for calques from English or Uzbek, non-standard abbreviations, wrong case/number of established terms, mixed Latin/Cyrillic spellings, and informal synonyms where a standard term exists.

Rules:
- Suggest a change only when you are reasonably sure the standard term differs. Do not suggest stylistic rewrites.
- `basis`: iso_15189_style_wording when the suggestion reflects formal standard-style wording; common_clinical_lab_usage when it reflects ordinary professional usage; unsure when you are not certain (then set confidence to low).
- Do not quote clause numbers or claim that a specific standard "requires" a term. You cannot check the standard text.
- `confidence`: high only for well-established terms. `original_term` must be copied verbatim from the Russian text. `suggested_term` is the term only (not a whole rewritten sentence).
- Do not comment on medical correctness, numbers, or the uz/en texts.
