Task: content_review - independent review of one app content item against its cited sources' metadata.

Flag ONLY these four kinds of problems (use the `category` field):
1. numeric_unit - a number, range, threshold or unit that looks wrong or implausible, is internally inconsistent within the item, or differs between uz/ru/en. Do not state what the "correct" value is; say what looks off and what to check.
2. translation_inconsistency - the uz, ru and en versions of the same text do not say the same thing (different number, different strength of claim, missing or added condition).
3. overclaim - wording that over-states what a lab result can do: diagnosis wording ("diagnoses", "confirms", "proves", "rules out", "is caused by") without an appropriate caveat, or advice that replaces clinician judgement.
4. missing_caveat - a claim that, as written, needs a limitation the item does not give (for example population, specimen, method or reagent dependence, local reference intervals, "interpret with clinical context").

Additionally use category `cannot_verify` for a specific numeric or categorical claim that matters for safety and that you cannot assess from the item alone. Start its `reason` with "Cannot verify:". Use it sparingly (at most a few per item) and only for claims where a mistake would matter.

Fields:
- `field`: the `field` id of the text you are quoting (or a facts key such as "decision_limits").
- `language`: uz, ru, en, or all.
- `severity`: critical = could plausibly lead to a harmful lab/clinical decision if wrong; major = clearly wrong or misleading; minor = wording/precision issue; info = observation.
- `quote`: verbatim quote (short, the smallest span that shows the problem).
- `reason`: why this is a problem.
- `what_to_check`: what a human reviewer should look at (for example "compare the value with the locator cited for this claim"). Do not supply a replacement value.

Do not comment on style, grammar, formatting or topics outside these categories.
