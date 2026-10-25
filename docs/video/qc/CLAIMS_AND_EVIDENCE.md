# Quality control (Levey–Jennings + Westgard) — claims → evidence and epistemic status

Status of the whole video: **EXPERT_REVIEW_PENDING**. Nothing here is marked as approved; the science and
the RU/UZ wording have not been reviewed by a laboratory specialist or a native-speaker reviewer.

Real app frames: free-app checkout `/home/user/wt-audit` (branch `fix/images-apparatus`, commit `215d3e8`),
`video_studio/flutter_walk/qc_walk_test.dart`. The demo test is created through the app's own form
(`/lab/qc/new`); the twelve illustrative runs are recorded with the app's own `QcController.addRun`; every
verdict, rule text, chart point and statistic in the app frames is computed by the app. The app's verdicts
(`frames.json → record.verdicts`) equal the video's JS port and the independent Python check
(`MATH_APPENDIX.md` §2). **The video makes no statement about price or tiers** (the QC module is in the free
app; the paid "QC report" export is NOT shown or mentioned).

## 1. Claims → evidence

| # | Where | Claim as shown | Evidence | Kind |
|---|---|---|---|---|
| Q1 | hook · L01, "+2.3 SD", chart runs 1–6 | This morning's control is 2.3 SD above the mean | Run 6 of `storyboard.json → data.runs` (computed z, `MATH_APPENDIX.md` §2); badge "Illustrative control data — not a real lot" | illustrative |
| Q2 | hook · L02 | "Stop the run — or report?" (the real decision) | rhetorical; answered by Q6 | hook |
| Q3 | chart · L03, ±1/2/3 SD lines | A Levey–Jennings chart plots each control result against its target mean and SD | App: `LeveyJenningsChart` (±1s/±2s/±3s, D-20 "W81 fig. 2"), ARB `qcChartTitle`, `qcIntro` | SOURCED (app + Westgard 1981) |
| Q4 | chart · L04, badge "Targets: your lab's control data (~20 values to start)" | Targets come from the laboratory's own control data — about twenty values to start | ARB `qcTargetNote` ("Westgard et al. (1981) calculate the mean and SD from the laboratory's own control measurements — initially about 20…"), `qcManufacturerWarning`, D-20 | SOURCED (app text citing Westgard 1981) |
| Q5 | zscore · L05, z = (x − x̄) ÷ SD, (5.46 − 5.00) ÷ 0.20 = +2.3 | Each result becomes a z-score | `qc_model.dart` `QcTarget.z` ("z = (x − o'rtacha) / SD"); computed | code + computed |
| Q6 | warn · L06–L07, "Warning · 1-2s", "Inspect with the other rules" | One value beyond 2 SD is 1-2s: a warning, not a rejection; inspect with the other rules | `QcRule.r12s.rejects == false`; ARB rule text `qcRuleText[r12s]` ("Warning: inspect with the other rules"); D-20; app frame `qc_warn` | SOURCED (app) |
| Q7 | random · L08, cards 1-3s, R-4s | 1-3s and R-4s point to random error → reject | `qcRuleText` r13s ("Reject the run (mostly random error)"), rR4s ("Reject (random error)") | SOURCED (app text; Westgard 1981) |
| Q8 | systematic · L09, cards 2-2s, 4-1s, 10x | 2-2s, 4-1s, 10x point to systematic error (a shift) | `qcRuleText` r22s, r41s, r10x ("Reject (systematic error)") | SOURCED (app text) |
| Q9 | card descriptions | Short paraphrases of the app's rule texts ("two in a row beyond 2 SD, same side" …) | `qcRuleText` (EN/RU/UZ) — full app wording appears in the app frames | paraphrase of app text → NEEDS_NATIVE_REVIEW (RU/UZ) |
| Q10 | shift · L10, runs 9–10 shaded, "Rejected · 4-1s", "reject the run · find the cause" | Four values in a row beyond 1 SD (across both levels): 4-1s → reject, find the cause | Engine: across-levels 4-1s (`_consecutive`, D-20); computed = app verdict (frame `qc_reject41`); "find the cause": app guide `qgRejected` subtitle ("Stop, find the cause, recheck") | computed + SOURCED (app) |
| Q11 | app_set · L11, frame `qc_new` (ring on "Source of the target mean and SD") | In LabGuide you enter each level's target mean and SD and where they came from | `QcNewSetScreen` fields, `QcTargetSource {laboratory, manufacturer}`; ARB `qcTargetSource` | code + real screen |
| Q12 | app_set · L12, frame `qc_chart` | The app draws the Levey–Jennings chart from the recorded runs | `QcSetScreen` → `LeveyJenningsChart` per level; real frame | code + real screen |
| Q13 | app_rules · L13, frames `qc_warn`, `qc_reject41` | Westgard rules are checked on every run and the broken rule is named | `evaluateRuns` (every run, all rules), latest-run notice lists `qcRuleText` of each violation; tests `test/unit/qc_rules_test.dart`, `test/widget/qc_flow_test.dart` | code + tests + real screen |
| Q14 | app_rules · L14, frames `qc_excluded`, `qc_stats` | A rejected run stays in the history but is not used in later rules or statistics | D-27; `evaluateRuns` removes rejected observations from the stream; ARB `qcRejectedExcluded`, `qcStatsExcluded`; real frames | code + real screen |
| Q15 | app_more · L15, frames `qc_csv`, `qc_guides` | Runs can be copied as a CSV table; data stays on this device | ARB `qcCopyCsv`, `qcEmptyBody` ("Data is stored only on this device"), `qcBackupBody`; the copy snackbar (which names two spreadsheet products) is NOT filmed — frame taken before the tap (brand rule) | code + real screen |
| Q16 | app_more, callout "EQA, rejected samples, critical values" | The QC module has guides on EQA, rejected QC and critical values | `QcGuide {rejected, eqa, critical}`; ARB `qgEqa` etc. The EQA guide is an explanation only — the app is not connected to an EQA programme (`docs/VIDEO_FEATURE_INVENTORY.md` §1) — the video says nothing more | code + real screen |
| Q17 | end · L16, note "A checking aid — it does not replace your laboratory's QC procedure." | A control result is a decision, not just a dot (tagline) | ARB `qcRulesSource` ("A learning and checking aid — it does not replace your laboratory's QC procedure") | tagline, bounded by app text |
| Q18 | end · L17 | Lab → Quality control | Route `/lab/qc`, Lab tab tile; ARB `navLab`, `qcTitle` | app |
| Q19 | audio | English synthetic narration (Kokoro-82M, `af_heart`); RU/UZ = subtitles + on-screen text; **nobody has listened to it** | owner decision 2026-10-25 | disclosure |

## 2. Epistemic table

| ID | Statement | Tag | Source / note |
|---|---|---|---|
| E1 | Levey–Jennings chart with ±1/2/3 SD limits; multirule 1-2s, 1-3s, 2-2s, R-4s, 4-1s, 10x | SOURCED | Westgard JO, Barry PL, Hunt MR, Groth T. Clin Chem 1981;27:493–501 (doi:10.1093/clinchem/27.3.493), read in full per app D-20 |
| E2 | 1-2s as a warning, all rejection rules checked on every run | SOURCED (app design decision) | D-20 (the 1981 procedure used 1-2s as a "gate"; the app is stricter — 4-1s can reject without a 2s value) — the video does not describe the gate |
| E3 | Random vs systematic error attribution of each rule | SOURCED (app text) / STANDARD_TEXTBOOK | `qcRuleText`; **NEEDS_EXPERT** for the short card paraphrases |
| E4 | ~20 values to establish targets | SOURCED | app `qcTargetNote` citing Westgard 1981 |
| E5 | Rejected run excluded from later rules/statistics | SOURCED (app behaviour) | D-27 — a design choice of the app ("error corrected, run repeated"), not a universal rule; the video states it as app behaviour ("In LabGuide…") |
| E6 | Illustrative data, z-designed runs | illustrative | `MATH_APPENDIX.md` |

Review checklist: E3 card wording; RU «Вестгард» transliteration (app uses «мультиправило Вестгарда»); UZ
«seriya», «siljish», «tizimli xato» — NEEDS_NATIVE_REVIEW.
