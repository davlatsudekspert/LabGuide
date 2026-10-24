# TB / HIV lab-direction cards (2026-10-24)

Status of every card below: `audit_status = NEEDS_REVIEW`, `expert_reviewed = false`.
In the app each card carries the tag "Reference · Expert reviewed: not yet"
(uz/ru/en; built from the existing status-ladder strings because
`no_draft_wording_test` (D-65) forbids "pending/expert review" wording in
ARB), missing fields read "Not added yet", and a disclaimer states the
app is an educational reference that never diagnoses and is not an operating
protocol. No images are used.

## Schema (backwards compatible)

* `assets/instruments/catalog.json`: new optional top-level key `lab_cards`
  (the 26 instrument models are untouched; files without the key still load).
* `lib/features/instruments/lab_direction_card.dart`: `LabDirectionCard` with
  `lab_direction`, `card_kind` (platform / test / method), `technology`,
  `instrument_vs_test_note`, `specimens`, `tasks`, `principle`, `limitations`,
  `qc_calibration_note`, `preanalytic_analytic_errors`, `biosafety`, `models`,
  `linked`, `sources`, `audit_status`, `expert_reviewed`. Each text field is
  uz/ru/en plus at least one source id; every source id must exist in
  `sources`, which carry `url`, `doc_ref` (version/date as shown on the page)
  and `accessed`.
* UI: `lab_direction_screens.dart` (section "TB and HIV directions" on the
  instruments screen, routes `/lab/instruments/d/:direction` and
  `/lab/instruments/lc/:id`). ARB keys prefixed `labDir` in uz/ru/en.
* Guards: `test/guards/lab_directions_guard_test.dart`.

## Cards added (6) and their sources (all accessed 2026-10-24)

| Card id | What is stated (paraphrased) | Sources |
|---|---|---|
| `tb-genexpert-platform` (platform) | Cartridge-based NAAT on the GeneXpert Instrument System; fully automated after loading. Model names: not verified (empty). | CDC Xpert page |
| `tb-xpert-mtb-rif-tests` (test) | Sputum; detects MTBC and RIF resistance in under 2 h; limitations per CDC; "trace" category is Ultra-only per WHO handbook. | CDC Xpert page; WHO TB KSP node 3147 |
| `tb-lamp-test` (test) | Detects MTBC, not RIF resistance; fresh specimen; follow-up DST. | WHO TB KSP node 3147 |
| `tb-truenat-test` (test) | MTB / MTB Plus results fall under "MTBC detected"; MTB-RIF Dx infers resistance from absent wild-type probe binding; RIF test after Truenat MTB needs reflex test on same DNA. | WHO TB KSP node 3147 |
| `hiv-agab-immunoassay-algorithm` (test) | Combination immunoassay (HIV-1/2 antibodies + p24), then antibody differentiation, then HIV-1 NAT for nonreactive/indeterminate; serum/plasma; 2014 US recommendation. | CDC/APHL 2014; CDC HIV Nexus; WHO HIV fact sheet |
| `hiv-rna-viral-load` (test) | NATs detect HIV RNA, earliest of three test types; role in the CDC algorithm. PCR technology, specimens, QC: not verified. | CDC HIV Nexus; CDC/APHL 2014 |

Platform and test are separate ids and cross-linked (`tb-genexpert-platform`
<-> `tb-xpert-mtb-rif-tests`).

Source URLs:
* https://tbksp.who.int/en/node/3147 (page shows no date/version)
* https://www.cdc.gov/tb/php/laboratory-information/xpert-mtb-rif-assay.html (page dated 2024-04-22)
* https://www.cdc.gov/hivnexus/hcp/diagnosis-testing/index.html (updated 2026-08-17)
* https://stacks.cdc.gov/view/cdc/23447 (2014-06-27)
* https://www.who.int/news-room/fact-sheets/detail/hiv-aids (updated 2026-07-27)

## Sources that could not be read (facts omitted, fields left empty)

* https://www.ncbi.nlm.nih.gov/books/NBK602012/ - browser-check page only, no content.
* https://clinicalinfo.hiv.gov/en/guidelines/hiv-clinical-guidelines-adult-and-adolescent-arv/tests-initial-assessment-follow-up (and `/laboratory-testing`) - HTTP 403 / 404.
* https://www.who.int/publications/i/item/9789240089495 and the WHO lab-diagnosis page - HTTP 500.
* Several guessed CDC URLs returned 404.

Consequences: no BD BACTEC MGIT 960 card (the WHO page mentions MGIT only in
a drug-susceptibility context), no CD4 flow cytometry card (no fetched source
describes the method; the WHO fact sheet only gives a CD4 threshold used in
the advanced-HIV definition), no CDC/NIH-quoted QC, biosafety, pre-analytic
or instrument model data.

## Still missing (rows of `LAB_DIRECTION_GAP_MATRIX.csv`)

* TB: BD BACTEC MGIT 960 liquid culture (P0); TB culture/DST (P1); TB
  microscopy ZN/fluorescence (P1); TB biosafety BSL-2/3, BSC (P1). For the
  added TB cards: specimens for LAMP/Truenat, technology, QC, biosafety, IFU
  versions and model names are empty.
* HIV: CD4 flow cytometry (P0); HIV genotypic drug resistance (P0); HIV
  confirmation algorithm detail incl. WHO strategy (P1); viral-load
  instruments m2000/Alinity m/cobas 6800/Xpert VL (P0); rapid tests/analyzers.
* Rest of the matrix (non-TB/HIV directions, e.g. neonatal screening) is out
  of scope of this batch.

## Facts that need an expert before the status can rise

* Whether the "Ultra-only trace" and RIF-confirmation statements match the
  current WHO/CDC wording and local practice in Uzbekistan.
* That the 2014 CDC/APHL HIV algorithm is the right reference for the local
  national algorithm (WHO strategies differ); the term "4th generation" was
  not found on the pages read and is not asserted.
* All "not verified" fields (technology of LAMP/Truenat/VL, specimens, QC,
  biosafety, models).
* Uz/ru translations of every card (machine-free, but not reviewed by a
  clinical-laboratory linguist).

## Update (audit-safety branch): schema v1.1 and corrections

* `LabDirection` now has 22 values (tb, hiv, virology, ... general); the app lists only directions with at least one
  PUBLIC card. ARB keys `labDir<Direction>` exist in uz/ru/en.
* `audit_status: "NEEDS_SOURCE"` cards are stubs (id, lab_direction, card_kind, name, `needs_source_reason`, optional
  `priority` P1|P2|P3, no content fields). They stay in `catalog.json` but are never shown (lists, deep links, counts).
* `sources[].type`: `official_agency | journal | manufacturer_ifu | manufacturer_marketing`. Official/journal sources must be on
  official hosts (guard); manufacturer hosts only for manufacturer types; a card needs at least one official/journal source;
  marketing sources show a "manufacturer page" note on the card.
* Status line: localized `labDirStatusNeedsReview` chosen by `auditStatus` (no raw enum token in the UI).
* TB/HIV corrections and removed statements: see `docs/LAB_CARDS_UNVERIFIED.md`. `hiv-rna-viral-load` is now a NEEDS_SOURCE stub.
* Expert sign-off items: `docs/EXPERT_SIGNOFF_REGISTRY.md`.
