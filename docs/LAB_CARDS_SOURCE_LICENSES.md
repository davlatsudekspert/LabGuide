# Lab-card sources: licences and reuse policy (2026-10-24)

Scope: every source id referenced by a card in `assets/instruments/catalog.json` `lab_cards` (46 sources). The 26 instrument-model
sources (`mr-*`, `fda-k160429`, ...) are outside this document. Licence column = what the fetched source record or page itself states;
"None stated" means no licence text was read, not that reuse is free.

## Reuse policy (all sources)

* Card statements are **paraphrases in the app's own wording** (uz/ru/en). No source text is copied. Each statement is capped at
  300 characters per language and at two English sentences (`test/guards/lab_cards_integration_test.dart`), as a crude brake against verbatim copying.
* Attribution: every card lists its sources (title, document reference, access date) on the card screen.
* Source ids marked `NC`/`ND`/`SA` below were **only summarised in original wording**.

## Paid content (Pro) - hard rule

Pro (paid) content will exist later. Material from **NC-licensed** sources (WHO CC BY-NC-SA 3.0 IGO, StatPearls CC BY-NC-ND 4.0, the
HbA1c review CC BY-NC-ND) and **ND-licensed** sources (StatPearls, the HbA1c review) must **never be copied verbatim into paid content**, and
adaptations of ND material are not permitted at all under the licence: before any of these cards or their wording is placed in a paid tier a
licence review is required. EUCAST, WHO blood-group module, Bio-Rad IFU and journal items are all-rights-reserved or unlicensed: paraphrase for
the free reference only. The free app uses non-commercial reference wording; if the app is monetised the NC position must be re-assessed by the owner.

## Paraphrase vs the app's own commentary

| Class | Where in data | Source tag | Rule |
|---|---|---|---|
| Paraphrase of a source | `technology`, `principle`, `specimens`, `tasks`, `limitations`, `qc_calibration_note`, `preanalytic_analytic_errors`, `biosafety` | at least one source id (parser rejects a text without one) | original wording; licences below apply |
| The app's own commentary | `instrument_vs_test_note`, `source_caveat`, ARB `labDir*` strings (disclaimer, status line, "class/technology reference" line, kind labels) | none (no `sources` key) | written by the app; no third-party text; not evidence |

The two classes are distinct in the schema: only the first class is a `SourcedText` (text + `sources`); the second is plain `LocalizedText`.

## Source table

| Source id | URL | Publisher | Type | Licence as stated | Used by cards |
|---|---|---|---|---|---|
| `a1-cdc-steam` | https://www.cdc.gov/infection-control/hcp/disinfection-sterilization/steam-sterilization.html | CDC | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a1-autoclave-platform` |
| `a1-eucast-dd` | https://www.eucast.org/ast_of_bacteria/disk_diffusion_methodology | EUCAST | official_agency | (c) EUCAST - all rights reserved, no reuse terms stated | `a3-bac-ast-method` |
| `a1-fda-geenius-ifu` | https://www.fda.gov/media/116818/download | Bio-Rad Laboratories (document hosted by FDA) | manufacturer_ifu | Copyright Bio-Rad Laboratories (IFU hosted by FDA); no licence for reuse | `a1-geenius-hiv-confirm-test` |
| `a1-fda-k163536` | https://www.accessdata.fda.gov/cdrh_docs/reviews/K163536.pdf | FDA | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a3-bac-maldi-tof-platform` |
| `a1-fda-k173873` | https://www.accessdata.fda.gov/cdrh_docs/reviews/K173873.pdf | FDA | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a1-blood-culture-platform` |
| `a1-fda-k230864` | https://www.accessdata.fda.gov/cdrh_docs/reviews/K230864.pdf | FDA | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a3-bac-vitek2-platform` |
| `a1-pmc-bloodculture` | https://pmc.ncbi.nlm.nih.gov/articles/PMC9333494 | Medicine (Baltimore) via PubMed Central | journal | CC BY 4.0 (stated in the source record) | `a1-blood-culture-platform` |
| `a1-pmc-mgit` | https://pmc.ncbi.nlm.nih.gov/articles/PMC2650918 | Journal of Clinical Microbiology via PubMed Central | journal | Journal copyright; no open licence recorded in the source record | `a3-tb-bactec-mgit960-platform` |
| `a1-sp-elisa` | https://www.ncbi.nlm.nih.gov/sites/books/NBK555922/ | NCBI Bookshelf (StatPearls Publishing) | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a1-elisa-method`, `a1-elisa-reader-platform` |
| `a1-sp-pcr` | https://www.ncbi.nlm.nih.gov/sites/books/NBK589663/ | NCBI Bookshelf (StatPearls Publishing) | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a1-realtime-pcr-method`, `a3-mol-realtime-pcr-platform` |
| `a1-sp-pt` | https://www.ncbi.nlm.nih.gov/sites/books/NBK544269/ | NCBI Bookshelf (StatPearls Publishing) | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a1-coagulation-analyzer-platform`, `a1-pt-inr-test` |
| `a1-who-lbm4-bsc` | https://apps.who.int/iris/handle/10665/337957 | WHO | official_agency | WHO CC BY-NC-SA 3.0 IGO (stated in the source record / WHO publication data) | `a1-bsc-class2-platform` |
| `a2-cdc-nsqap` | https://www.cdc.gov/newborn-screening/featurestory/quality-assurance-for-newborn-screening.html | Centers for Disease Control and Prevention | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a2-method-newborn-screening-dbs-qa` |
| `a2-cdc-vaccine-storage` | https://www.cdc.gov/vaccines/hcp/storage-handling/index.html | Centers for Disease Control and Prevention | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a2-platform-lab-fridge-freezer-monitoring` |
| `a2-pmc-bga-croatia` | https://pmc.ncbi.nlm.nih.gov/articles/PMC5082214/ | Biochemia Medica (hosted by NIH/NLM PubMed Central) | journal | Journal copyright; no open licence recorded in the source record | `a2-platform-blood-gas-ise-analyzer`, `a2-test-arterial-blood-gas-panel` |
| `a2-pmc-hba1c-review` | https://pmc.ncbi.nlm.nih.gov/articles/PMC9634344/ | Experimental and Therapeutic Medicine (hosted by NIH/NLM PubMed Central) | journal | CC BY-NC-ND (A2 record) | `a2-test-hba1c`, `a2-platform-hba1c-analyzer` |
| `a2-pmc-hba1c-variants` | https://pmc.ncbi.nlm.nih.gov/articles/PMC2769887/ | Journal of Diabetes Science and Technology (hosted by NIH/NLM PubMed Central) | journal | Journal copyright; no open licence recorded in the source record | `a2-test-hba1c` |
| `a2-pmc-urine-drug` | https://pmc.ncbi.nlm.nih.gov/articles/PMC6368048/ | Federal Practitioner (hosted by NIH/NLM PubMed Central) | journal | Journal copyright; no open licence recorded in the source record | `a2-test-urine-drug-immunoassay-screen` |
| `a2-who-lbm4` | https://iris.who.int/handle/10665/337956 | World Health Organization | official_agency | WHO CC BY-NC-SA 3.0 IGO (stated in the source record / WHO publication data) | `a2-platform-lab-fridge-freezer-monitoring` |
| `a2-who-led` | https://iris.who.int/handle/10665/44602 | World Health Organization | official_agency | Not recorded in the source record (WHO page; no licence read) | `a2-platform-led-fluorescence-microscope`, `a2-method-auramine-smear-microscopy-tb` |
| `a2-who-qms` | https://iris.who.int/handle/10665/44665 | World Health Organization | official_agency | WHO copyright 2011 (A2 record); no Creative Commons licence recorded | `a2-method-calibrators-control-materials`, `a2-platform-lab-fridge-freezer-monitoring` |
| `a2-who-semen6` | https://iris.who.int/handle/10665/343208 | World Health Organization | official_agency | WHO CC BY-NC-SA 3.0 IGO (stated in the source record / WHO publication data) | `a2-test-semen-analysis-who6`, `a2-platform-casa` |
| `a3-cdc-mmwr-rr2-2003` | https://www.cdc.gov/mmwr/preview/mmwrhtml/rr5202a1.htm | CDC | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a3-hiv-cd4-flow-method` |
| `a3-eucast-dd-qc` | https://www.eucast.org/ast_of_bacteria/quality_control | EUCAST | official_agency | (c) EUCAST - all rights reserved, no reuse terms stated | `a3-bac-ast-method` |
| `a3-fda-alinity-hiv1` | https://www.fda.gov/media/188665/download | FDA | official_agency | None stated on the page/document read (US federal / UN agency publication) | `hiv-rna-viral-load` |
| `a3-fda-cobas-hiv1` | https://www.fda.gov/media/187859/download | FDA | official_agency | None stated on the page/document read (US federal / UN agency publication) | `hiv-rna-viral-load`, `a3-mol-realtime-pcr-platform` |
| `a3-fda-k181412` | https://www.accessdata.fda.gov/cdrh_docs/reviews/K181412.pdf | FDA | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a3-bac-maldi-tof-platform` |
| `a3-fda-k201675` | https://www.accessdata.fda.gov/cdrh_docs/reviews/K201675.pdf | FDA | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a3-bac-vitek2-platform`, `a3-bac-ast-method` |
| `a3-nist-sop14` | https://www.nist.gov/document/sop-14-gravimetric-calibration-20190508pdf | NIST (US Department of Commerce) | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a3-gen-gravimetric-pipette-calibration` |
| `a3-statpearls-coag-eval` | https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/ | NCBI Bookshelf (NIH/NLM), StatPearls Publishing | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a3-coag-platelet-aggregometry-tem` |
| `a3-statpearls-electrophoresis` | https://www.ncbi.nlm.nih.gov/sites/books/NBK585057/ | NCBI Bookshelf (NIH/NLM), StatPearls Publishing | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a3-bio-electrophoresis` |
| `a3-statpearls-esr` | https://www.ncbi.nlm.nih.gov/sites/books/NBK557485/ | NCBI Bookshelf (NIH/NLM), StatPearls Publishing | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a3-hem-esr-analyzer` |
| `a3-statpearls-flow` | https://www.ncbi.nlm.nih.gov/sites/books/NBK608011/ | NCBI Bookshelf (NIH/NLM), StatPearls Publishing | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a3-imm-flow-cytometer-platform` |
| `a3-statpearls-molgen` | https://www.ncbi.nlm.nih.gov/sites/books/NBK560712/ | NCBI Bookshelf (NIH/NLM), StatPearls Publishing | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a3-gen-fish-molecular-genetics` |
| `a3-statpearls-ms` | https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/ | NCBI Bookshelf (NIH/NLM), StatPearls Publishing | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a3-tox-gc-ms`, `a3-tox-lc-ms` |
| `a3-statpearls-osmometer` | https://www.ncbi.nlm.nih.gov/sites/books/NBK589659/ | NCBI Bookshelf (NIH/NLM), StatPearls Publishing | official_agency | CC BY-NC-ND 4.0 (StatPearls Publishing; stated in the A1 source records, applied to all StatPearls chapters) | `a3-bio-osmometer` |
| `a3-unodc-cocaine-2012` | https://syntheticdrugs.unodc.org/uploads/syntheticdrugs/res/library/forensics_html/Recommended_Methods_for_the_Identification_and_Analysis_of_Cocaine_in_Seized_Materials_ST-NAR-7_and_Rev.1.pdf | UNODC | official_agency | None stated on the page/document read (US federal / UN agency publication) | `a3-tox-tlc` |
| `a3-who-bg-module3` | https://www.who.int/publications/m/item/guidelines-and-principles-for-safe-blood-transfusion-practice---module-3-blood-group-serology | World Health Organization | official_agency | "All rights reserved" (stated on the WHO page) | `a3-trf-gel-card-system` |
| `a3-who-hiv-vl-brief-2023` | https://www.who.int/publications/i/item/9789240055179 | World Health Organization | official_agency | WHO CC BY-NC-SA 3.0 IGO (stated in the source record / WHO publication data) | `hiv-rna-viral-load` |
| `a3-who-poc-cd4-tpp-2020` | https://www.who.int/publications/i/item/point-of-care-test-for-identifying-people-living-with-advanced-HIV-disease | World Health Organization | official_agency | WHO CC BY-NC-SA 3.0 IGO (stated in the source record / WHO publication data) | `a3-hiv-cd4-flow-method` |
| `a3-who-tb-dst-2018` | https://www.who.int/publications/i/item/9789241514842 | World Health Organization | official_agency | WHO CC BY-NC-SA 3.0 IGO (stated in the source record / WHO publication data) | `a3-tb-bactec-mgit960-platform`, `a3-tb-mgit-culture-dst-method` |
| `cdc-hiv-lab-algorithm-2014` | https://stacks.cdc.gov/view/cdc/23447 | CDC / APHL (CDC Stacks) | official_agency | None stated on the page/document read (US federal / UN agency publication) | `hiv-agab-immunoassay-algorithm`, `a1-geenius-hiv-confirm-test` |
| `cdc-hiv-test-types` | https://www.cdc.gov/hivnexus/hcp/diagnosis-testing/index.html | CDC | official_agency | None stated on the page/document read (US federal / UN agency publication) | `hiv-agab-immunoassay-algorithm` |
| `cdc-xpert-mtb-rif` | https://www.cdc.gov/tb/php/laboratory-information/xpert-mtb-rif-assay.html | CDC | official_agency | None stated on the page/document read (US federal / UN agency publication) | `tb-genexpert-platform`, `tb-xpert-mtb-rif-tests` |
| `who-hiv-factsheet` | https://www.who.int/news-room/fact-sheets/detail/hiv-aids | WHO | official_agency | Not recorded in the source record (WHO page; no licence read) | `hiv-agab-immunoassay-algorithm` |
| `who-tbksp-alg1` | https://tbksp.who.int/en/node/3147 | WHO TB Knowledge Sharing Platform | official_agency | Page states none; the handbook it reproduces is CC BY-NC-SA 3.0 IGO per its publication page (A1 record) | `tb-xpert-mtb-rif-tests`, `tb-lamp-test`, `tb-truenat-test` |
