# Medical audit of the sections added 2026-10-17 (read-only)

Scope: leukoformula auto-assessment, cytology additions, spermogram, blood group, histology, practice-protocol/topic deck data.
Method: code/content read; high-risk claims checked against sources fetched in this session; ABO logic run through all 16 combinations (Python port).

## CRITICAL (unsafe procedure in source data; `tool/slides/data/books_extra_practice.json`, protocols not yet in `assets/`)

1. **Needle recapping/manual detachment taught as routine** — line ~10983 (uz/ru/en): "When blood is drawn the cap is put on the needle, the needle is detached from the syringe and put into a special container." WHO *Guidelines on drawing blood* (2010): "DO NOT recap a needle using both hands"; avoid recapping and manual disassembly; dispose needle+syringe as a unit into a sharps container immediately (https://iris.who.int/handle/10665/44294). Fix: "Do not recap or detach the needle; discard needle and syringe as one unit straight into a puncture-proof sharps container (if recapping is unavoidable — one-hand scoop)."
2. **Implies lancet reuse** — line ~105 (all langs): "If re-used lancets or needles have become blunt, replace them…" and line ~101 "single-use where possible". WHO 2010: reusable finger-prick devices caused hepatitis B outbreaks; "single-use items should not be reused". Fix: delete the bullet; state "single-use sterile lancets only, one per patient".

## IMPORTANT

3. **Leukoformula: assessment runs on any partial count** — `diff_assessment.dart:172` only checks `total == 0`; panel shown live (`differential_screens.dart:961`). After one tap on "band", bands = 100 % → "Повышено / может указывать на сдвиг влево"; with WBC entered, early taps flag neutrophilia/lymphopenia. Controller has `isComplete` (`differential_controller.dart:137`) but it is unused. Fix: assess only when `total >= target` (100/200, WHO 2003 §9.10), otherwise show "count not complete".
4. **Leukoformula: "All normal" shown together with the referral alert** — `diff_assessment_screens.dart:66` (refer notice when blasts/"other" > 0) and `:131` (`flagged.isEmpty && !needsWbc` → "Все показатели в пределах нормы"). A smear with blasts and normal other values shows both. Fix: hide "all normal" when `a.refer`, or reword to "the listed cell types are within range".
5. **Blood group reader gives a "concordant" group despite weak forward reactions** — `bloodgroup_logic.dart:117-120`: `group` ignores `BgFlag.weakForward`, so anti-A "weak" + matching reverse shows "Учебная интерпретация: методы совпадают — A (II)". BSH 2012 §4.7.1/§4.8.1 (Milkins, Transfus Med 2013;23:3–35): anomalies (weak/mixed-field) must be repeated/investigated before group authorisation; Fig. A1 lists weak forward reactions as anomalies. Fix: treat `weakForward` like a discrepancy (no group, "investigate"). Also there is no "mixed field" option although the flag text mentions it.
6. **Biosafety slide: hand washing "10–15 seconds"** — line ~10879. WHO 2010: hand hygiene "for at least 30 seconds" (WHO hand-hygiene guidance: 40–60 s soap-and-water). Fix the number.
7. **PEP timing wording** — line ~11093: "started from 2 to 72 hours after contact". Reads as "wait 2 h". WHO 2010 Annex: start PEP as soon as possible; beyond 72 h not recommended. Fix: "as soon as possible (ideally within 2 h), not later than 72 h; 28 days".
8. **"Blow the blood into the reagent tube"** — lines ~473 and ~1186: implies mouth pipetting with a Sahli-type pipette, contradicting the safety slides. Fix: "expel the blood with a bulb/automatic pipette".
9. **Capillary site list outdated** — line ~54: "fingertip or earlobe; in newborns heel or big toe". WHO 2010 §7.1.1: finger preferred in adults; earlobe only "rarely… mass screening or research"; neonates — medial/lateral heel (posterior heel avoided; toe has less depth to bone, 2.19 mm). Fix: drop earlobe/toe as routine sites. Line ~160 "press a swab moistened with alcohol" → WHO: firm pressure with clean dry gauze.
10. **Spermogram: concentration 0 is reported as "Азооспермия"** — `spermogram_logic.dart:339-347`. WHO 2021 §2.4.8.8 (p. 35): no sperm in wet preparations → azoospermia only *suspected*; the term requires examination of a centrifuged sediment. The app shows `azooNote` but the term chip itself still says azoospermia, and the quiz (`sperm-q-azoo`) teaches the opposite rule. Fix: label "No spermatozoa in wet preparation — azoospermia suspected; examine centrifuged pellet".
11. **Topic deck d064 physiology error** — `books_extra.json:3642`: "dihydrogen:monohydrogen phosphate 1:4 in blood, 9:1 in the glomerular filtrate, 50:1 in urine". The glomerular filtrate is an ultrafiltrate of plasma, so its ratio ≈ plasma (1:4). Check against the lecture; likely "9:1 in distal tubular fluid" or the filtrate value was mis-transcribed.
12. **Cytology AGC wording incomplete** — `cytology_content.dart:1069-1097`: "usually colposcopy with endocervical sampling". ASCCP 2019: plus endometrial sampling if ≥35 y or at risk of endometrial neoplasia (https://guidelinecentral.com/guideline/308500). Add the clause.

## MINOR

13. Diff: flags use the rounded value, referral uses the raw value (`diff_assessment.dart:182-198`): n = 0.497 shows "0.50" yet triggers "< 0.5". Use the same rounded value for both.
14. Diff: eosinophil default upper 0.7 (Harrison) while MSD defines eosinophilia > 0.5; lymphocyte low 1.5 vs MSD lymphopenia < 1.0. Source-consistent but worth one line in `diffLimitsSourceNote`. Harrison table is 63-1 in the 19th ed., 64-1 in later — add the edition to the citation.
15. Russian: "Может указывать на: Нейтропения" — prefer "Возможная причина отклонения: нейтропения" or put the finding in the accusative.
16. Spermogram uz `spermogram_content.dart:1159`: "kamida 60 daqiqa ichida" (= "within at least 60 min") vs ru "не позднее 60 минут". Use "ko‘pi bilan 60 daqiqa ichida".
17. Spermogram `roundedPercents` adjusts the largest single grade; WHO §2.4.6.2 adjusts the "dominant group (immotile or motile)" and only for a sum of 99/101 (counts like 1/1/1/197 give a sum of 102 from rounding alone).
18. Necrozoospermia is triggered by vitality < 54 % alone; the WHO 2010 definition (quoted in the app) also requires a high immotile %.
19. Purity degree `cytology_content.dart:916-937`: degree II needs `lacto == many`, but its own text says "Лактобацилл меньше"; few lactobacilli + single leukocytes + mixed flora → III. Align the rule with the text, or mark it explicitly as an expert decision.
20. Protocol data, numbers from old books without an international source: haemostasis "deliver within 45 min" (CLSI H21 allows PT ≤ 24 h, aPTT ≤ 4 h); platelets "normal 180–320" next to "thrombocytopenia < 150" (gap); "Primary thrombocytosis is above 400" (primary ≠ threshold); sputum ">25 squamous cells per field" (common reject criterion > 10/LPF); kidney compensation "10–20 hours" (usually days); eye-splash "do not remove contact lenses" contradicts the chemical-splash slide (unverified).

## Verified correct (sources fetched this session)
- Harrison Table (63-1/64-1) values 1.83–7.25 / 1.5–4.0 / 0.2–0.95 / 0–0.7 / 0–0.15 (skyscape Harrison ed19 page). MSD: severe neutropenia < 0.5; eosinophilia > 0.5, moderate 1.5–5, severe > 5; Duffy / benign ethnic neutropenia note. Neutrophils = segmented + band; mapping flags → findings is consistent.
- WHO 2021 Table 8.3: every lower limit, CI, median and N in `spermLimits` matches (iris.who.int bitstream 4038e736…). pH < 7.2 text, 30/60 min, 20–37 °C, ≤ 50 min transport, 2–7 days abstinence, replicate rule, TZI formula (example 1.91), azoospermia definition — verified. Spermogram quiz keys (option 0) are correct.
- ABO: all 16 forward/reverse combinations → exactly the 4 textbook concordant patterns; every other combination → discrepancy with the right A/B-column flags. Compatibility table (red cells/plasma) correct. BSH 2012: weak D Fig. 1 (female ≤ 50 or long-term transfusion → D-negative), D-selection §7.8.3 (< 51, < 18, immune anti-D, transfusion-dependent), §4.8.2 group O red cells, §8.4.3 AB D+ control, WBIT 1:2000. WHO Module 3: plate read within 2 min, 1+ grading, rouleaux disperse with 1.5 % hypertonic saline. Blood-group quiz keys correct.
- Bethesda 2014: 8,000–12,000 / 5,000 cells, 2,000-cell discretionary floor, ≥ 10 TZ cells, > 75 % obscured, abnormal cells = satisfactory; AGC/AIS/adenocarcinoma subcategories correct. Purity-degree pH bands match the classical scheme.
- Histology: images viewed — liver (reticulin, labelled zones), kidney (H&E glomerulus/tubules), PAS glomerulus, cardiac (branching, intercalated discs), skeletal (striated, peripheral nuclei), smooth, elastic cartilage (elastin-stained), neuron (smear), transitional, simple cuboidal, simple squamous (whole mount, as the card says) — all match the cards and HISTOLOGY_SOURCES. Histology quiz keys are derived from the item id (correct by construction).
- Unverified: ASCCP HSIL/ASC-H/unsatisfactory text (primary PDF not reached; consistent with the guidelinecentral summary); Russian and Uzbek histology terms (no textbook available).

## Fix status (2026-10-17, same day)

Every cited source was re-fetched before changing text (WHO 2010 phlebotomy PDF, WHO 2021 semen manual PDF,
BSH 2012 PDF, ASCCP 2019 Perkins et al. 2020 full text, Harrison's Manual 20th ed. page, MSD pages, Geckler 1977).

| # | Status | Change |
|---|---|---|
| 1 | fixed | Recap/detach text replaced: no recapping or manual detachment, needle + syringe as one unit into a sharps container, one-hand scoop only if unavoidable (WHO 2010 §1.1 p. 3, Table 2.2 p. 12). |
| 2 | fixed | "Re-used lancets" bullet replaced; "single-use where possible" → single-use sterile lancets only, one per puncture/patient (WHO 2010 §2.1.4 p. 11, Table 2.2, §7.2.1). |
| 3 | fixed | `assessDifferential` returns `incomplete` (no comparison) while `total < target`; panel shows "N of M cells counted" hint. Blasts/"other" still trigger referral. |
| 4 | fixed | `DiffAssessment.allNormal` is false whenever `refer` is true; panel uses it. |
| 5 | fixed | Weak anti-A/anti-B and new "mixed field" option (anti-A/B/D) = anomaly: no group named, forward-group line hidden, own flag texts (BSH §4.7.1 i, iv; §4.8.1; Fig. A1). |
| 6 | fixed | Hand washing ≥ 30 s incl. wrists/between fingers, single-use towel (WHO 2010 Table 2.2). The unsourced "3–5 mL" alcohol volume was dropped. |
| 7 | fixed | PEP: as soon as possible, ideally within the first hours, no later than 72 h; 28 days (WHO 2010 Annex D p. 74, §8.5.2 p. 53). WHO says "first hours", not "2 h" — "2 h" not used. |
| 8 | fixed | "Blow the blood" (3 protocols) → expel with a rubber bulb/automatic pipette, never by mouth. |
| 9 | fixed | Sites per WHO 2010 §7.1.1/Table 7.1/§7.1.2 (finger; heel medial/lateral up to ~6 months; posterior heel avoided; earlobe only mass screening/research; toe dropped). Post-puncture: firm pressure with clean dry gauze/cotton (§7.2.2, §2.2.3). |
| 10 | fixed | Concentration 0 → "Azoospermia suspected (confirm in a centrifuged sediment)" panel; the term chip is no longer produced (WHO 2021 §2.4.8.8 p. 35 re-read). |
| 11 | fixed | d064: filtrate "9:1" and urine "50:1" removed (filtrate is a plasma ultrafiltrate; the lecture numbers could not be confirmed); kept "≈1:4 in blood" and "dihydrogen form predominates as tubular fluid is acidified". RU term "монофосфат" → "гидрофосфат". |
| 12 | fixed | AGC text per ASCCP 2019 Section G.1 (verified in Perkins 2020 full text): colposcopy + endocervical sampling; endometrial sampling at ≥ 35 y or < 35 with increased endometrial risk (AUB, chronic anovulation, obesity); atypical endometrial cells — endometrial + endocervical sampling first. |
| 13 | fixed | Referral thresholds (neutrophils < 0.5, eosinophils > 1.5) use the displayed 2-decimal value. |
| 14 | fixed (partly disagreed) | The cited URL is Harrison's Manual **20th ed. (2020)**, where the table **is** 64-1 (verified) — kept 64-1, added the edition to citation/locator/note. MSD differences (eosinophilia > 0.5; lymphocytopenia < 1.0) added to `diffLimitsSourceNote` (3 langs) and an MSD Lymphocytopenia source tile. |
| 15 | fixed | RU: "Возможная трактовка: нейтропения" (nominative, lowercase after colon). |
| 16 | fixed | uz "ko‘pi bilan 60 daqiqadan kechiktirmay"; en "no later than 60 minutes". |
| 17 | fixed | `roundedPercents` adjusts the dominant (largest) grade only when the sum is 99/101 (WHO §2.4.6.2 p. 25 re-read); x.5 ties giving 102/98 are left and the counter shows one-decimal values. |
| 18 | fixed | Necrozoospermia only with low vitality AND total motility below its lower limit (immotile > 58 %); vitality alone → info note. |
| 19 | fixed | Degree II rule aligned with its own text: single leukocytes + fewer lactobacilli and/or some mixed flora (no pathogenic flora, lactobacilli present) → II. |
| 20 | fixed / removed | Haemostasis "45 min" removed (CLSI H21 primary text not reachable → no number); platelets 180–320, "primary thrombocytosis > 400", "signs < 70 / 700–900" removed — MSD 2026 reference interval 140–440 shown as source-specific; sputum ">25 per field" kept but made specific (×100 low-power field) with Geckler 1977 (the >25 SEC/LPF cut-off is in that paper; < 10 SEC + > 25 WBC = best quality); kidney "10–20 h" removed (renal compensation "much more slowly"); blood eye-splash "do not remove contact lenses" removed → WHO Annex D flush ≥ 10 min (chemical-splash slide unchanged). Removed numbers listed in the protocol set's "not included" notes. |

## Follow-up (2026-10-18)

Independent full review of the six sections against re-opened primary sources:
`docs/AUDIT_2026-10-18_MEDICAL_REVIEW.md` (6 corrections: platelet/red-cell ratio from WHO 2003 §9.14,
BSH sample retention "post-transfusion", CDC Gram-stain wording, Paris System non-urothelial
category, LFB/Nissl wording, uz "up to six" portal tracts).
