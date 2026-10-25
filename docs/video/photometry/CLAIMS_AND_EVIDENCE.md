# Spectrophotometry — claims → evidence and epistemic status

Status of the whole video: **EXPERT_REVIEW_PENDING**. Nothing here is marked as approved; the science and
the RU/UZ wording have not been reviewed by a laboratory specialist or a native-speaker reviewer.

Real app frames: rendered from the read-only free-app checkout `/home/user/wt-audit` (branch
`fix/images-apparatus`, commit `215d3e8`) with `video_studio/flutter_walk/photometry_walk_test.dart`
(shared helpers `walk_kit.dart`). App content shown: Learn → Lecture mode → Practical protocols →
deck `fotometriya-asoslari-biokimyo` ("Basics of biochemical photometry and working with a reagent kit",
`assets/lectures/decks/fotometriya-asoslari-biokimyo.<lang>.json`, deck status `sourced`, source cited on
every slide: Aripov A.N. et al., *Klinik laborator diagnostika bo‘yicha qo‘llanma*, Toshkent 2006, ch. I).
The slides that name a commercial photometer (slides 4–6, "The instrument and where to put it") are never
opened; the walk fails if a deny-listed brand word is visible. **The video makes no statement about price,
tiers or availability.**

## 1. Claims → evidence

| # | Where (scene · line / on-screen) | Claim as shown | Evidence | Kind |
|---|---|---|---|---|
| P1 | hook · L01, big number "1.52", chip "Your standard: A 0.412" | A sample reading far above the standard | `storyboard.json → data` (computed: `MATH_APPENDIX.md` §4); badge "Illustrative data — not a patient result" | illustrative data |
| P2 | hook · L02 "Can you trust that number?" | Rhetorical question; answered in scenes 05–07 | — | hook |
| P3 | lightpath · L03, labels lamp → filter (λ) → cuvette → detector, pill "λ: one wavelength" | A photometer passes light of one (selected) wavelength through the cuvette | App diagram text ARB `imgDiagramPhotometryAlt` ("light source, filter (wavelength λ), cuvette … detector"); lecture slide "Principle" (filter transmits the required narrow spectrum); lesson 07 PH-C3 (SOURCED `hu-hl4000`) | SOURCED (app text) |
| P4 | absorbance · L04, A = log₁₀(I₀/I), in/out bars | Absorbance compares incident and transmitted light | `imgDiagramPhotometryAlt` ("A = log10(I0/I)"); bars drawn with I/I₀ = 10^−A in code (`OpticalBench.tsx`) | STANDARD_TEXTBOOK + app text |
| P5 | ladder · L05, bars 100 / 50 / 10 / 1 % | A = 1 → 10 % passes; A = 2 → 1 % | Lecture slide "About absorbance" (Aripov 2006: "If the absorbance is 1, only 10% of the light passes … 90% is absorbed"); values computed 10^−A (`MATH_APPENDIX.md` §2). The 0.3 → 50 % row is arithmetic only (the slide's "high accuracy near 0.3" is NOT claimed by the video) | SOURCED (app lecture) + computed |
| P6 | beer · L06, A = ε·ℓ·c, mint segment | Within a range absorbance is proportional to concentration (Beer–Lambert) | `imgDiagramPhotometryAlt` ("Beer–Lambert law A = ε·ℓ·c"); lesson 07 T1 | STANDARD_TEXTBOOK |
| P7 | beer · L07, coral bend above "linearity limit", "real reading: A 1.52" vs dashed proportional line | Above the method's linearity limit the curve bends and readings fall short | Textbook negative deviation; **the shape and the limit (20 a.u.) are illustrative** (labelled; badge "Real limit: from the reagent IFU"). Whether a real method reads low or behaves otherwise above its limit is method-specific | STANDARD_TEXTBOOK (principle) / **NEEDS_EXPERT** (wording "falls short" as a general statement) |
| P8 | bss · L08, three cuvettes, "zero set" | Blank sets zero, then standard, then sample | `imgDiagramPhotometryAlt` ("Measure blank, standard and sample"); lecture steps 2 and 4 (zero against water, air or reagent per the instructions) | SOURCED (app text) |
| P9 | bss · L09, C = 0.309 ÷ 0.412 × 10.0 = 7.50 a.u. | Concentration = A sample ÷ A standard × C standard | `imgDiagramPhotometryAlt`; lecture step 5; computed `MATH_APPENDIX.md` §3 (JS = Python) | SOURCED (app text) + computed |
| P10 | dilute · L10, "36.9 ✗ not valid" vs "diluted 1 in 5 → 8.40 × 5 = 42.0 ✓" | Above the limit: dilute, measure again, multiply by the dilution factor | `imgDiagramPhotometryAlt` ("Above the linearity limit: dilute, repeat and multiply by the dilution factor"); lecture step 6; numbers computed from the illustrative curve (`MATH_APPENDIX.md` §4) | SOURCED (rule) + illustrative numbers |
| P11 | app_intro · L11, frames `learn`, `list`, `fs_principle` | LabGuide's Lecture mode has a protocol on photometry basics | Route `/learn/lecture` (Learn tab row `lectureListTitle`), filter `lecture-filter-protocols`, deck row `deck-fotometriya-asoslari-biokimyo`; real frames | code + real screen |
| P12 | app_steps · L12–L13, frames `fs_blank`, `fs_calc`, `fs_lin`, `fs_abs` (rings on steps 2, 5, 6 and on "10%") | The protocol covers blank, standard and sample step by step, the calculation and the rule above the linearity limit | Deck slides found by content in the walk (`frames.json → record.slides`); full screen = the app's own `LecturePresentation` (phone turns landscape) | real screen |
| P13 | end · L14, tagline, note "A teaching protocol — the reagent IFU and your SOP always take precedence" | Wavelength, blank and limits come from the reagent IFU | `imgDiagramPhotometryAlt` ("Wavelength, blank and limits follow the reagent IFU"); lecture step 4 ("as in the instructions") | SOURCED (app text) |
| P14 | end · L15, pill | Learn → Lecture mode → Practical protocols | ARB `navLearn`, `lectureListTitle`, `lectureFilterProtocols` (EN/RU/UZ copied from the app) | app |
| P15 | audio | English synthetic narration in every edition; RU/UZ = subtitles + on-screen text | Owner decision 2026-10-25; Kokoro-82M v1.0 int8 (Apache-2.0), voice `af_heart`, `tool/tts/synth.py` unchanged. **Nobody has listened to it yet** | disclosure |

Brand rule: no third-party logo or brand name on screen (walk deny list incl. the photometer brand on deck
slide 4 and the reagent-kit maker named in other decks). OpticalBench and cuvettes are LabGuide's own
original drawings (calibration flagship). No micrographs, no stock footage, no music.

## 2. Epistemic table

| ID | Statement | Tag | Source / note |
|---|---|---|---|
| E1 | A photometer measures light of a selected wavelength after it passes the cuvette | SOURCED | PH-C3 (`hu-hl4000`, lesson 07 §8.1); lecture deck (Aripov 2006, ch. I) |
| E2 | A = log₁₀(I₀/I); A = 1 ↔ 10 % transmitted | STANDARD_TEXTBOOK / SOURCED (lecture) | definition; Aripov 2006 via deck |
| E3 | Beer–Lambert: proportional within a limited range | STANDARD_TEXTBOOK | lesson 07 T1 |
| E4 | Above the linearity limit readings are not valid; dilute, repeat, multiply | SOURCED (app text) | ARB `imgDiagramPhotometryAlt`; lecture step 6 |
| E5 | The illustrated bend ("reads low") | **NEEDS_EXPERT** | illustrative shape; real deviation is method/instrument specific |
| E6 | C = A sample ÷ A standard × C standard (single-standard, blank-corrected) | SOURCED (app text) | diagram + lecture step 5; many methods use other calibration models (factor, multi-point — see calibration flagship) |
| E7 | Wavelength, blank and limits per the reagent IFU | SOURCED (app text) | diagram footer |

Review checklist for the expert: E5 wording, whether "blank sets zero" vs "reagent blank subtracted" needs a
note for automated analyzers; RU/UZ terminology (`absorbance` = «оптическая плотность» / «optik zichlik» as in
the app deck; `linearity limit` = «граница линейности» / «chiziqlilik chegarasi»; `dilution factor` =
«степень разведения» / «suyultirish darajasi») — NEEDS_NATIVE_REVIEW.
