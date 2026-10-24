# Lab cards: statements removed from the public cards (2026-10-24)

Source: EXPERT_REVIEW_PACKET_TB_HIV.csv (gap audit). Nothing below is shown in the app.
Each item needs an official/journal source (or an expert) before it may return.

| card_id | field | statement (removed) | why unverified |
|---|---|---|---|
| tb-genexpert-platform | instrument_vs_test_note | "Xpert MTB/RIF and Ultra are separate tests that run on the platform" (Ultra part) | CDC page never mentions Ultra; only a Cepheid marketing page lists it. Note now names MTB/RIF only. |
| tb-genexpert-platform | models | GeneXpert II/IV/XVI = 2/4/16 modules | Only the Cepheid 2022 marketing brochure (manufacturer_marketing); no official/IFU source. Field stays empty. |
| tb-xpert-mtb-rif-tests | tasks[1] | "MTBC detected trace" applies to Ultra only, not the standard test | WHO page discusses trace under Ultra; it does not state the standard test lacks it. |
| tb-xpert-mtb-rif-tests | limitations[2] (rewritten, not removed) | non-viable-bacilli remark | Qualifier added per WHO TB KSP node 3147: HIV-negative symptomatic adults, treatment completed <5 years ago; trace = confirmation in people with HIV, children (pulmonary), extrapulmonary samples. The Ultra-only scope is kept in the text. |
| tb-xpert-mtb-rif-tests | tasks[0] (rewritten) | "under 2 hours" | CDC states it for Xpert MTB/RIF only; the text now says so (not claimed for Ultra). |
| tb-lamp-test | specimens[0] | "A fresh specimen is needed" | WHO footnote ties the fresh specimen to the follow-up DST step, not clearly to TB-LAMP itself; accepted specimen type unknown. |
| tb-lamp-test | instrument_vs_test_note | generic Xpert text (reagent cartridge, "instrument has its own card") | False for TB-LAMP: no instrument card exists, not described as cartridge-based. Replaced by "This card covers the test only." |
| tb-truenat-test | instrument_vs_test_note | same generic Xpert text | No Truenat platform card; chip-based claim only from a search snippet. Replaced as above. |
| hiv-agab-immunoassay-algorithm | technology[1] | "The term 4th generation is not used on the pages read - not verified" | A verification note, not a fact; the CDC/APHL PDF does define 4th-generation assays but no precise citation was made, so the sentence is removed. |
| hiv-agab-immunoassay-algorithm | limitations[0] first sentence | "The app does not diagnose ... diagnosis rests with an authorised laboratory and clinician" | App's own disclaimer wrongly tagged with a CDC source. It is shown on every card by the app (labDirDisclaimer) without a source tag. |
| hiv-agab-immunoassay-algorithm | tasks[0] (rewritten) | NAT step | Source: only specimens reactive on the initial assay but nonreactive/indeterminate on differentiation go to NAT. |
| hiv-agab-immunoassay-algorithm | linked | link to hiv-rna-viral-load | Target is now a hidden NEEDS_SOURCE stub. |
| hiv-rna-viral-load | whole card (now NEEDS_SOURCE stub, P1) | name "HIV-1 RNA (NAT, viral load)"; tasks: NATs detect HIV RNA earliest of three test types (CDC HIV Nexus); NAT follows nonreactive/indeterminate differentiation result (CDC/APHL 2014) | Sourced sentences concern the qualitative diagnostic NAT, not quantitative viral load. No fetched source covers viral-load technology, specimens or QC (clinicalinfo.hiv.gov 403, NCBI NBK602012 bot-check, WHO 9789240089495 404). WHO 2023 brief (9789240055179) gives thresholds only and was not re-fetched. |

Open questions for experts remain in EXPERT_REVIEW_PACKET_TB_HIV.* (kept outside the repo).
