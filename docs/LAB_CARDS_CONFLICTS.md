# Lab cards: dedup decisions and unresolved conflicts (2026-10-24)

Rule applied: contradictory statements are **never merged automatically**. The safer / better-sourced statement is shown (or none) and the conflict
is recorded here and in `docs/expert_signoff_registry.json` (ids `LABCARD-CONFLICT-C0x`). Nothing here is expert-reviewed.

## Dedup decisions (kept id, dropped id, reason)

| Dropped id | Kept id | Reason |
|---|---|---|
| `a1-genexpert-platform` | `tb-genexpert-platform` | duplicate of existing safety-branch card (same CDC source); existing card kept |
| `a1-xpert-mtb-rif-test` | `tb-xpert-mtb-rif-tests` | duplicate of existing safety-branch card (same CDC+WHO sources); a1 adds WHO "trace is Ultra-only" statements which the safety branch removed as unsupported; existing card kept untouched |
| `a1-ast-method` | `a3-bac-ast-method` | two EUCAST sources + FDA K201675 (a3) vs one EUCAST hub page (a1); a3 kept, a1 non-conflicting statements merged |
| `a1-maldi-tof-platform` | `a3-bac-maldi-tof-platform` | two FDA 510(k) summaries (K163536 + K181412, class-level) vs one (K163536); a3 kept |
| `a1-vitek2-platform` | `a3-bac-vitek2-platform` | a3 has QC strains + Gram-negative card scope (K201675); a1 rests on K230864 daptomycin card; a3 kept, a1 card-specific limitation merged with its source |
| `a1-mgit-960-platform` | `a3-tb-bactec-mgit960-platform` | WHO 2018 technical manual (a3) vs single journal study (a1); a3 kept, a1 M. xenopi limitation merged |
| `a1-realtime-pcr-platform` | `a3-mol-realtime-pcr-platform` | a3 uses StatPearls PCR + FDA cobas summary; a1 StatPearls PCR only; a3 kept, a1 Cq readout and cost/dye limitation merged |
| `a1-hiv-viral-load-test` | `hiv-rna-viral-load` | NEEDS_SOURCE stub; duplicate of existing id hiv-rna-viral-load (now merged public card) |
| `a1-hiv-viral-load-platform` | `a3-mol-realtime-pcr-platform` | NEEDS_SOURCE stub; duplicate of the separate real-time PCR platform card |
| `a3-mindray-ba88a-stub` | `a1-mindray-ba-88a-platform` | two identical NEEDS_SOURCE stubs for Mindray BA-88A; a1 stub kept |
| `a3-hiv-vl-pcr-test` | `hiv-rna-viral-load` | renamed onto the existing id by owner rule 1 |

Instrument/platform and test/method stay in separate, cross-linked cards. The real-time PCR platform
`a3-mol-realtime-pcr-platform` stays a separate platform card; `hiv-rna-viral-load` (test) links to it and it links back; the method card
`a1-realtime-pcr-method` links to the same platform. Platform-to-platform links (GC-MS <-> LC-MS) and an unsourced link blood culture -> MALDI-TOF were removed.
`a1-geenius-hiv-confirm-test` <-> `hiv-agab-immunoassay-algorithm` was made symmetric (link only; the algorithm card text is unchanged).
Source ids duplicated by URL were mapped to one id: {"a1-cdc-hiv-algorithm-2014": "cdc-hiv-lab-algorithm-2014", "a1-cdc-xpert": "cdc-xpert-mtb-rif", "a1-who-tbksp-alg1": "who-tbksp-alg1", "a3-statpearls-pcr": "a1-sp-pcr", "a3-fda-k163536": "a1-fda-k163536"}.

Statements merged from a dropped duplicate into the kept card (each with its own source, non-conflicting): AST (`a3-bac-ast-method`): two EUCAST limitations;
MALDI-TOF: reviewer-in-the-loop limitation; VITEK 2: daptomycin-card limitation (card-specific, FDA K230864); MGIT platform: single-centre *M. xenopi* limitation (journal);
real-time PCR platform: Cq readout task and cost/dye limitation.

## HIV viral load (`hiv-rna-viral-load`)

Existing id kept and promoted from a hidden NEEDS_SOURCE stub to a public NEEDS_REVIEW card. Content comes only from fragment `a3-hiv-vl-pcr-test`
(sources: FDA cobas HIV-1 summary, FDA Alinity m HIV-1 summary, WHO 2023 viral-suppression brief). Checked against the fetched documents on 2026-10-24:
EDTA plasma / dual-target / armored RNA internal control / three external controls (cobas); plasma + serum, supplemental use, "not first-line / donor screening",
two-level calibrators (Alinity); WHO categories >1000 unsuppressed, detected but <=1000 suppressed, not detected = undetectable, DBS named in the WHO brief.
The old stub carried no content except the name and the reason; the removed statements (NAT detects RNA earliest of three test types; NAT after nonreactive/indeterminate
differentiation) concern the qualitative diagnostic NAT and were **not** restored (see `docs/LAB_CARDS_UNVERIFIED.md`). `hiv-agab-immunoassay-algorithm` is not linked to the viral-load card for the same reason.
The A1 stubs `a1-hiv-viral-load-test` and `a1-hiv-viral-load-platform` are dropped as duplicates.

## Open conflicts (for an expert)

| Id | Cards | Statement A | Statement B | Current display |
|---|---|---|---|---|
| C-01 | `hiv-rna-viral-load` | FDA summary of cobas HIV-1: not intended as a diagnostic test to confirm HIV infection. | FDA summary of Alinity m HIV-1: labelled as a supplemental test to confirm infection after reactive immunoassays (plasma and serum). | Both shown, each attributed to its own source and flagged "labelling differs by assay"; no generalisation. Expert must decide whether to keep the Alinity statement. |
| C-02 | `hiv-rna-viral-load`, `hiv-agab-immunoassay-algorithm` | CDC/APHL 2014 algorithm: HIV-1 nucleic acid testing is a diagnostic step for specimens reactive on the first assay and nonreactive/indeterminate on differentiation. | Quantitative viral-load assay labelling (cobas) says not for diagnosis. | Cards are not linked; relation between qualitative diagnostic NAT and quantitative VL assays is left to an expert. |
| C-03 | `tb-xpert-mtb-rif-tests` (existing) vs dropped `a1-xpert-mtb-rif-test` | Safety branch removed "trace is Ultra-only" and "extrapulmonary testing limited to Ultra" as not stated by the WHO page for the standard test. | Fragment a1 repeats both as WHO statements (plus 1-5 % false RIF-susceptible, treatment-monitoring, indeterminate-RIF notes). | Existing card kept unchanged; the a1 statements were NOT merged. |
| C-04 | `a3-bac-maldi-tof-platform` vs dropped `a1-maldi-tof-platform` | a3: calibration with bacterial test standard (BTS) or E. coli ATCC 8739 (two FDA summaries). | a1: BTS is an E. coli DH5 alpha extract (3.6-17 kDa) for QC of one system (K163536). | System-specific; a3 wording kept, a1 detail not merged. |
| C-05 | `a3-bac-vitek2-platform` | a3: meropenem card needs an alternative method for some organisms before reporting (K201675). | a1: daptomycin card needs an alternative method for some drug-organism combinations (K230864). | Both shown as card-specific; must not be generalised to the whole system. |
| C-06 | all StatPearls-based cards | Fragments type StatPearls as `official_agency` (NCBI/NIH host). | Policy may prefer `journal` for a textbook chapter. | Kept as `official_agency`; owner/expert to decide. |
| C-07 | `a3-tb-bactec-mgit960-platform` | WHO 2018 manual (DST context). | a1 journal study: "monitored up to 42 days", ruthenium sensor wording, *M. xenopi* 13/44. | Only the *M. xenopi* limitation merged; the rest is a different context and was left out. |

No other contradictions between fragments or with existing cards were found when the duplicates were compared.
