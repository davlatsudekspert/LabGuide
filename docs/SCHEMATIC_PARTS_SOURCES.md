# Sxema qismlari — manbalar (2026-10-25)

Har bir apparat sinfi chizmasidagi raqamli belgi (1..n) → qism nomi va vazifasi,
ishlash prinsipi va natija (ilovada “Qismlari va ishlash prinsipi” paneli,
`SchematicPartsPanel`). Matnlar — `lib/l10n/app_{uz,ru,en}.arb` dagi `schemParts*`
kalitlari; tuzilma — `assets/instruments/schematic_parts.json`; yagona manba —
`tool/illustrations/schematic/parts_src.py` (generator `parts_l10n.py`).

Qoida: faqat darslik darajasidagi umumiy apparat anatomiyasi va kartaning o‘z
manbali matniga (catalog.json `technology`, `principle`, `tasks`, `sources`) zid
bo‘lmagan tamoyil. Aniq model xususiyati, ishlab chiqaruvchi dizayni, o‘ylab
topilgan raqam va klinik tashxis yo‘q. Manba ustuni: catalog.json `sources[].id`
(URL bilan) yoki `STANDARD_TEXTBOOK (NEEDS_EXPERT)` — darslik darajasidagi umumiy
ma’lumot, mutaxassis tasdig‘ini kutadi.

Jami: 32 chizma, 223 qism; 123 tasida (to‘liq yoki qisman) `STANDARD_TEXTBOOK (NEEDS_EXPERT)`.

## `chemistry` — model turi (InstrumentSchematic)

Kartalar: `mindray-bs-240`, `mindray-bs-480`, `human-humastar-600`, `roche-cobas-c-311`, `roche-cobas-c-303`, `abbott-architect-c4000`, `abbott-alinity-c`

| # | qism (en) | manba |
|---|---|---|
| 1 | Sample area | `hu-hs600` <https://www.human.de/01_CoreLab_DX/Clinical_Chemistry/HumaStar_Systems/HumaStar_600/Marketing%20Material/981163_Flyer_HumaStar600_EN.PDF> |
| 2 | Cooled reagent carousel | `hu-hs600` <https://www.human.de/01_CoreLab_DX/Clinical_Chemistry/HumaStar_Systems/HumaStar_600/Marketing%20Material/981163_Flyer_HumaStar600_EN.PDF>; `ab-c4000` <https://www.corelaboratory.abbott/us/en/offerings/brands/architect/architect-c4000> |
| 3 | Sample and reagent probes | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Reaction carousel (cuvettes) | `mr-bs480-br` <https://www.mindray.com/content/dam/xpace/en_in/resources/brochures/bs-480-product-brochure-en_in.pdf> |
| 5 | Photometer | `mr-bs480-br` <https://www.mindray.com/content/dam/xpace/en_in/resources/brochures/bs-480-product-brochure-en_in.pdf>; `ro-c303` <https://diagnostics.roche.com/global/en/products/instruments/cobas-c-303-ins-6347.html> |
| 6 | Purified water container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Liquid waste container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 8 | Computer and software | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `mr-bs480-br` <https://www.mindray.com/content/dam/xpace/en_in/resources/brochures/bs-480-product-brochure-en_in.pdf>; `ro-c311` <https://diagnostics.roche.com/us/en/products/instruments/cobas-c-311-ins-2043.html>; `ab-c4000` <https://www.corelaboratory.abbott/us/en/offerings/brands/architect/architect-c4000> |
| R | Result | `STANDARD_TEXTBOOK (NEEDS_EXPERT)`; `ro-c303` <https://diagnostics.roche.com/global/en/products/instruments/cobas-c-303-ins-6347.html> |

## `photometer` — model turi (InstrumentSchematic)

Kartalar: `human-humalyzer-4000`

| # | qism (en) | manba |
|---|---|---|
| 1 | Display and keypad | `hu-hl4000` <https://www.human.de/01_CoreLab_DX/Clinical_Chemistry/HumaLyzer_Photometers/HumaLyzer_4000/Marketing%20Material/981015_Flyer_HumaLyzer4000_EN.PDF> |
| 2 | Aspiration needle | `hu-hl4000` <https://www.human.de/01_CoreLab_DX/Clinical_Chemistry/HumaLyzer_Photometers/HumaLyzer_4000/Marketing%20Material/981015_Flyer_HumaLyzer4000_EN.PDF> |
| 3 | Measuring cell (flow cell) | `hu-hl4000` <https://www.human.de/01_CoreLab_DX/Clinical_Chemistry/HumaLyzer_Photometers/HumaLyzer_4000/Marketing%20Material/981015_Flyer_HumaLyzer4000_EN.PDF> |
| 4 | Thermal printer | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Waste container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Reagent bottles | `hu-hl4000` <https://www.human.de/01_CoreLab_DX/Clinical_Chemistry/HumaLyzer_Photometers/HumaLyzer_4000/Marketing%20Material/981015_Flyer_HumaLyzer4000_EN.PDF> |
| P | Principle | `hu-hl4000` <https://www.human.de/01_CoreLab_DX/Clinical_Chemistry/HumaLyzer_Photometers/HumaLyzer_4000/Marketing%20Material/981015_Flyer_HumaLyzer4000_EN.PDF>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `hematology5` — model turi (InstrumentSchematic)

Kartalar: `mindray-bc-5390`, `mindray-bc-6200`, `human-humacount-5d`, `abbott-cell-dyn-emerald-22-al`, `abbott-alinity-hq`

| # | qism (en) | manba |
|---|---|---|
| 1 | Autoloader with rack | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Sample probe (open mode) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Impedance chamber | `fda-k160429` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K160429.pdf>; `mr-bc6000-br` <https://www.mindray.com/content/dam/xpace/en/resources/brochure/bc-6000-product-brochure.pdf> |
| 4 | Laser flow cell | `mr-bc5390` <https://www.mindray.com/en/products/laboratory-diagnostics/hematology/5-part-differential-analyzers/bc-5390>; `ab-emerald` <https://www.corelaboratory.abbott/int/en/offerings/brands/cell-dyn/cell-dyn-emerald-22-al.html> |
| 5 | Display (scattergram) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Reagents | `mr-bc5390` <https://www.mindray.com/en/products/laboratory-diagnostics/hematology/5-part-differential-analyzers/bc-5390>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Waste container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `fda-k160429` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K160429.pdf>; `mr-bc5390` <https://www.mindray.com/en/products/laboratory-diagnostics/hematology/5-part-differential-analyzers/bc-5390>; `mr-bc6000-br` <https://www.mindray.com/content/dam/xpace/en/resources/brochure/bc-6000-product-brochure.pdf>; `ab-emerald` <https://www.corelaboratory.abbott/int/en/offerings/brands/cell-dyn/cell-dyn-emerald-22-al.html> |
| R | Result | `hu-hc5d` <https://www.human.de/01_CoreLab_DX/Hematology/HumaCount_5-part_Systems/HumaCount_5D/Marketing%20Material/981646_Flyer_HumaCount5D_EN.PDF>; `ab-hq` <https://www.corelaboratory.abbott/int/en/offerings/brands/alinity/Alinity-h-hematology-system.html> |

## `hematology3` — model turi (InstrumentSchematic)

Kartalar: `mindray-bc-30s`, `human-humacount-30ts`, `abbott-cell-dyn-emerald`

| # | qism (en) | manba |
|---|---|---|
| 1 | Thermal printer | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Display (3 histograms) | `mr-bc30s` <https://www.mindray.com/en/products/laboratory-diagnostics/hematology/3-part-differential-analyzers/bc-30s> |
| 3 | Sample probe | `hu-hc30ts` <https://www.human.de/01_CoreLab_DX/Hematology/HumaCount_3-part_Systems/HumaCount_80TS_30TS/Marketing%20Material/981642_Flyer_HumaCount80TS_30TS_EN.PDF> |
| 4 | Impedance chamber | `rst-71783` <https://all-pribors.ru/docs/71783-18.pdf>; `ab-emerald` <https://www.corelaboratory.abbott/int/en/offerings/brands/cell-dyn/cell-dyn-emerald-22-al.html> |
| 5 | Diluent and lysing solution | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Waste container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `rst-71783` <https://all-pribors.ru/docs/71783-18.pdf>; `ab-emerald` <https://www.corelaboratory.abbott/int/en/offerings/brands/cell-dyn/cell-dyn-emerald-22-al.html>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `mr-bc30s` <https://www.mindray.com/en/products/laboratory-diagnostics/hematology/3-part-differential-analyzers/bc-30s>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `immunoassay` — model turi (InstrumentSchematic)

Kartalar: `mindray-cl-900i`, `mindray-cl-1200i`, `human-humaclia-150`, `roche-cobas-e-411`, `roche-cobas-e-402`, `abbott-architect-i1000sr`, `abbott-alinity-i`

| # | qism (en) | manba |
|---|---|---|
| 1 | Sample rack | `mr-cl900i` <https://www.mindray.com/en/products/laboratory-diagnostics/chemiluminescence-immunoassay/small-test-volume/cl-900i> |
| 2 | Cooled reagent packs | `ab-i1000` <https://www.corelaboratory.abbott/int/en/offerings/brands/architect/architect-i1000SR>; `hu-clia150` <https://www.human.de/01_CoreLab_DX/CLIA/HumaCLIA_System/HumaCLIA_150/Marketing%20Material/981022_Flyer_HumaCLIA150_EN.PDF>; `mr-cl900i-br` <https://www.mindray.com/content/dam/xpace/en/resources/brochure/cl-900i-product-brochure.pdf> |
| 3 | Pipetting probes | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Cuvette feeder | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Incubator ring | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Wash station (magnetic separation) | `mr-cl1200i` <https://www.mindray.com/en/products/laboratory-diagnostics/chemiluminescence-immunoassay/medium-test-volume/cl-1200i>; `mr-cl900i-br` <https://www.mindray.com/content/dam/xpace/en/resources/brochure/cl-900i-product-brochure.pdf> |
| 7 | Luminometer (detector) | `mr-cl900i-br` <https://www.mindray.com/content/dam/xpace/en/resources/brochure/cl-900i-product-brochure.pdf> |
| 8 | Solid waste drawer | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 9 | System solutions | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `mr-cl900i-br` <https://www.mindray.com/content/dam/xpace/en/resources/brochure/cl-900i-product-brochure.pdf>; `mr-cl1200i` <https://www.mindray.com/en/products/laboratory-diagnostics/chemiluminescence-immunoassay/medium-test-volume/cl-1200i>; `hu-clia150` <https://www.human.de/01_CoreLab_DX/CLIA/HumaCLIA_System/HumaCLIA_150/Marketing%20Material/981022_Flyer_HumaCLIA150_EN.PDF>; `ro-e411` <https://diagnostics.roche.com/global/en/products/instruments/cobas-e-411.html>; `fda-k041192` <https://www.accessdata.fda.gov/cdrh_docs/pdf4/K041192.pdf> |
| R | Result | `hu-clia150` <https://www.human.de/01_CoreLab_DX/CLIA/HumaCLIA_System/HumaCLIA_150/Marketing%20Material/981022_Flyer_HumaCLIA150_EN.PDF>; `ro-e411` <https://diagnostics.roche.com/global/en/products/instruments/cobas-e-411.html> |

## `urine_strip` — model turi (InstrumentSchematic)

Kartalar: `roche-cobas-u-411`

| # | qism (en) | manba |
|---|---|---|
| 1 | Urine sample and test strip | `ro-u411` <https://diagnostics.roche.com/se/en/products/instruments/cobas-u-411-ins-2009.html> |
| 2 | Strip tray (transport) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Reading head (LEDs and photosensor) | `ro-u411` <https://diagnostics.roche.com/se/en/products/instruments/cobas-u-411-ins-2009.html> |
| 4 | Display | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Printer | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Used strip bin | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `ro-u411` <https://diagnostics.roche.com/se/en/products/instruments/cobas-u-411-ins-2009.html>; `ro-6500` <https://diagnostics.roche.com/au/en/products/systems/cobas-6500-system-sys-250.html> |
| R | Result | `ro-u411` <https://diagnostics.roche.com/se/en/products/instruments/cobas-u-411-ins-2009.html>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `urine_system` — model turi (InstrumentSchematic)

Kartalar: `roche-cobas-6500`, `mindray-eu-5600-pro`

| # | qism (en) | manba |
|---|---|---|
| 1 | Sample transport line | `ro-6500` <https://diagnostics.roche.com/au/en/products/systems/cobas-6500-system-sys-250.html> |
| 2 | Chemistry module (test strip) | `ro-6500` <https://diagnostics.roche.com/au/en/products/systems/cobas-6500-system-sys-250.html> |
| 3 | Sampling needles | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Sediment module (microscope and camera) | `ro-6500` <https://diagnostics.roche.com/au/en/products/systems/cobas-6500-system-sys-250.html>; `mr-eu5600` <https://www.mindray.com/en/products/laboratory-diagnostics/urinalysis/urinalysis-automation-line/eu-5600-pro-eu-5300-pro> |
| 5 | Display (particle images) | `mr-eu5600` <https://www.mindray.com/en/products/laboratory-diagnostics/urinalysis/urinalysis-automation-line/eu-5600-pro-eu-5300-pro> |
| 6 | Reagent and wash solution | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Waste container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `ro-6500` <https://diagnostics.roche.com/au/en/products/systems/cobas-6500-system-sys-250.html>; `mr-eu5600` <https://www.mindray.com/en/products/laboratory-diagnostics/urinalysis/urinalysis-automation-line/eu-5600-pro-eu-5300-pro> |
| R | Result | `ro-6500` <https://diagnostics.roche.com/au/en/products/systems/cobas-6500-system-sys-250.html>; `mr-eu5600` <https://www.mindray.com/en/products/laboratory-diagnostics/urinalysis/urinalysis-automation-line/eu-5600-pro-eu-5300-pro>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `mass_spec_gc` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-tox-gc-ms`

| # | qism (en) | manba |
|---|---|---|
| 1 | Carrier gas cylinder | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Autosampler | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Injector (inlet) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Oven and capillary column | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Heated transfer line | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Ion source | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Mass analyser (quadrupole) | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/> |
| 8 | Detector (electron multiplier) | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/> |
| 9 | Vacuum pumps | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 10 | Data system | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `mass_spec_lc` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-tox-lc-ms`

| # | qism (en) | manba |
|---|---|---|
| 1 | Mobile phase bottles | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | High-pressure pump | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Autosampler | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Column (in a thermostat) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Electrospray ion source (ESI) | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/> |
| 6 | Mass analyser (quadrupole) | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/> |
| 7 | Detector (electron multiplier) | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/> |
| 8 | Vacuum pumps | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 9 | Data system | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a3-statpearls-ms` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589702/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `maldi_tof` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-bac-maldi-tof-platform`

| # | qism (en) | manba |
|---|---|---|
| 1 | Target plate | `a1-fda-k163536` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K163536.pdf> |
| 2 | Laser | `a1-fda-k163536` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K163536.pdf> |
| 3 | Accelerating electrodes | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Flight tube (TOF) | `a3-fda-k181412` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K181412.pdf> |
| 5 | Detector | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Vacuum pump | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Computer and spectral database | `a1-fda-k163536` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K163536.pdf>; `a3-fda-k181412` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K181412.pdf> |
| P | Principle | `a1-fda-k163536` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K163536.pdf>; `a3-fda-k181412` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K181412.pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a1-fda-k163536` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K163536.pdf>; `a3-fda-k181412` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K181412.pdf> |

## `microbial_id_ast` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-bac-vitek2-platform`

| # | qism (en) | manba |
|---|---|---|
| 1 | Test card (64 wells) | `a3-fda-k201675` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K201675.pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Suspension tube | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Filling chamber | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Incubator | `a3-fda-k201675` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K201675.pdf> |
| 5 | Optical scanner | `a3-fda-k201675` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K201675.pdf> |
| 6 | Computer and software | `a3-fda-k201675` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K201675.pdf> |
| P | Principle | `a3-fda-k201675` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K201675.pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a3-fda-k201675` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K201675.pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `blood_culture` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a1-blood-culture-platform`

| # | qism (en) | manba |
|---|---|---|
| 1 | Blood culture vials | `a1-fda-k173873` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K173873.pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | CO₂ sensor (vial bottom) | `a1-fda-k173873` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K173873.pdf> |
| 3 | Incubator cabinet | `a1-fda-k173873` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K173873.pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Reading system | `a1-fda-k173873` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K173873.pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Positive vial indicator | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Computer and software | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a1-fda-k173873` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K173873.pdf> |
| R | Result | `a1-fda-k173873` <https://www.accessdata.fda.gov/cdrh_docs/reviews/K173873.pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `mycobacterial_culture` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-tb-bactec-mgit960-platform`, `a3-tb-mgit-culture-dst-method`

| # | qism (en) | manba |
|---|---|---|
| 1 | MGIT tube | `a3-who-tb-dst-2018` <https://www.who.int/publications/i/item/9789241514842> |
| 2 | Fluorescent oxygen sensor | `a3-who-tb-dst-2018` <https://www.who.int/publications/i/item/9789241514842> |
| 3 | Tube drawer (incubation and reading) | `a3-who-tb-dst-2018` <https://www.who.int/publications/i/item/9789241514842>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Status lights | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Instrument display | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Computer (GU curves) | `a3-who-tb-dst-2018` <https://www.who.int/publications/i/item/9789241514842> |
| P | Principle | `a3-who-tb-dst-2018` <https://www.who.int/publications/i/item/9789241514842> |
| R | Result | `a3-who-tb-dst-2018` <https://www.who.int/publications/i/item/9789241514842> |

## `flow_cytometer` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-hiv-cd4-flow-method`, `a3-imm-flow-cytometer-platform`

| # | qism (en) | manba |
|---|---|---|
| 1 | Sheath fluid container | `a3-statpearls-flow` <https://www.ncbi.nlm.nih.gov/sites/books/NBK608011/> |
| 2 | Sample tube and probe | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Flow cell (hydrodynamic focusing) | `a3-statpearls-flow` <https://www.ncbi.nlm.nih.gov/sites/books/NBK608011/> |
| 4 | Laser | `a3-statpearls-flow` <https://www.ncbi.nlm.nih.gov/sites/books/NBK608011/> |
| 5 | Forward-scatter (FSC) detector | `a3-statpearls-flow` <https://www.ncbi.nlm.nih.gov/sites/books/NBK608011/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Side-scatter and fluorescence detectors | `a3-statpearls-flow` <https://www.ncbi.nlm.nih.gov/sites/books/NBK608011/> |
| 7 | Waste container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 8 | Computer (dot plots) | `a3-cdc-mmwr-rr2-2003` <https://www.cdc.gov/mmwr/preview/mmwrhtml/rr5202a1.htm> |
| P | Principle | `a3-statpearls-flow` <https://www.ncbi.nlm.nih.gov/sites/books/NBK608011/>; `a3-cdc-mmwr-rr2-2003` <https://www.cdc.gov/mmwr/preview/mmwrhtml/rr5202a1.htm>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a3-cdc-mmwr-rr2-2003` <https://www.cdc.gov/mmwr/preview/mmwrhtml/rr5202a1.htm>; `a3-statpearls-flow` <https://www.ncbi.nlm.nih.gov/sites/books/NBK608011/> |

## `real_time_pcr` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `hiv-rna-viral-load`, `a1-realtime-pcr-method`, `a3-mol-realtime-pcr-platform`

| # | qism (en) | manba |
|---|---|---|
| 1 | PCR tubes (8-tube strip) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Heated lid | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Thermal block (Peltier) | `a1-sp-pcr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589663/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Excitation light source | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Filter wheel | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Detector | `a1-sp-pcr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589663/> |
| 7 | Software (amplification curves) | `a1-sp-pcr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589663/> |
| P | Principle | `a1-sp-pcr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589663/> |
| R | Result | `a1-sp-pcr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589663/>; `a3-fda-cobas-hiv1` <https://www.fda.gov/media/187859/download> |

## `cartridge_molecular` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `tb-genexpert-platform`, `tb-xpert-mtb-rif-tests`

| # | qism (en) | manba |
|---|---|---|
| 1 | Single-use cartridge | `cdc-xpert-mtb-rif` <https://www.cdc.gov/tb/php/laboratory-information/xpert-mtb-rif-assay.html> |
| 2 | Reaction tube | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Specimen container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Instrument module | `cdc-xpert-mtb-rif` <https://www.cdc.gov/tb/php/laboratory-information/xpert-mtb-rif-assay.html>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Computer and software | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `cdc-xpert-mtb-rif` <https://www.cdc.gov/tb/php/laboratory-information/xpert-mtb-rif-assay.html>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `cdc-xpert-mtb-rif` <https://www.cdc.gov/tb/php/laboratory-information/xpert-mtb-rif-assay.html> |

## `coag_analyzer` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a1-coagulation-analyzer-platform`, `a1-pt-inr-test`

| # | qism (en) | manba |
|---|---|---|
| 1 | Citrate tube rack | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Cooled reagent block | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Pipetting arm | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Measuring cuvettes (37 °C) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Light source | `a1-sp-pt` <https://www.ncbi.nlm.nih.gov/sites/books/NBK544269/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Photodetector | `a1-sp-pt` <https://www.ncbi.nlm.nih.gov/sites/books/NBK544269/> |
| 7 | Display (clotting curve) | `a1-sp-pt` <https://www.ncbi.nlm.nih.gov/sites/books/NBK544269/> |
| P | Principle | `a1-sp-pt` <https://www.ncbi.nlm.nih.gov/sites/books/NBK544269/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a1-sp-pt` <https://www.ncbi.nlm.nih.gov/sites/books/NBK544269/> |

## `elisa_reader` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a1-elisa-method`, `a1-elisa-reader-platform`

| # | qism (en) | manba |
|---|---|---|
| 1 | 96-well microplate | `a1-sp-elisa` <https://www.ncbi.nlm.nih.gov/sites/books/NBK555922/> |
| 2 | Light source (lamp) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Well being read | `a1-sp-elisa` <https://www.ncbi.nlm.nih.gov/sites/books/NBK555922/> |
| 4 | Optical filter | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Photodetector | `a1-sp-elisa` <https://www.ncbi.nlm.nih.gov/sites/books/NBK555922/> |
| 6 | Washer needle manifold | `a1-sp-elisa` <https://www.ncbi.nlm.nih.gov/sites/books/NBK555922/> |
| 7 | Wash buffer container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 8 | Waste container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a1-sp-elisa` <https://www.ncbi.nlm.nih.gov/sites/books/NBK555922/> |
| R | Result | `a1-sp-elisa` <https://www.ncbi.nlm.nih.gov/sites/books/NBK555922/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `bsc_class2` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a1-bsc-class2-platform`

| # | qism (en) | manba |
|---|---|---|
| 1 | Front opening (inflow) | `a1-who-lbm4-bsc` <https://apps.who.int/iris/handle/10665/337957> |
| 2 | Front grille | `a1-who-lbm4-bsc` <https://apps.who.int/iris/handle/10665/337957>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Work zone and surface | `a1-who-lbm4-bsc` <https://apps.who.int/iris/handle/10665/337957> |
| 4 | Downflow HEPA filter | `a1-who-lbm4-bsc` <https://apps.who.int/iris/handle/10665/337957> |
| 5 | Fan (blower) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Exhaust HEPA filter | `a1-who-lbm4-bsc` <https://apps.who.int/iris/handle/10665/337957> |
| 7 | Rear plenum | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 8 | Sash (front window) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a1-who-lbm4-bsc` <https://apps.who.int/iris/handle/10665/337957> |
| R | Result | `a1-who-lbm4-bsc` <https://apps.who.int/iris/handle/10665/337957>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `autoclave` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a1-autoclave-platform`

| # | qism (en) | manba |
|---|---|---|
| 1 | Pressure chamber | `a1-cdc-steam` <https://www.cdc.gov/infection-control/hcp/disinfection-sterilization/steam-sterilization.html> |
| 2 | Door with seal and lock | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Loading tray | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Pressure gauge | `a1-cdc-steam` <https://www.cdc.gov/infection-control/hcp/disinfection-sterilization/steam-sterilization.html> |
| 5 | Thermometer | `a1-cdc-steam` <https://www.cdc.gov/infection-control/hcp/disinfection-sterilization/steam-sterilization.html> |
| 6 | Safety valve | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Water reservoir | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a1-cdc-steam` <https://www.cdc.gov/infection-control/hcp/disinfection-sterilization/steam-sterilization.html> |
| R | Result | `a1-cdc-steam` <https://www.cdc.gov/infection-control/hcp/disinfection-sterilization/steam-sterilization.html>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `blood_gas_ise` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a2-platform-blood-gas-ise-analyzer`, `a2-test-arterial-blood-gas-panel`

| # | qism (en) | manba |
|---|---|---|
| 1 | Sample in a heparinised syringe | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Sample inlet probe | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Sensors (electrodes) | `a2-pmc-bga-croatia` <https://pmc.ncbi.nlm.nih.gov/articles/PMC5082214/> |
| 4 | Measuring channel | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Reagent pack | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Display | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Printer | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a2-pmc-bga-croatia` <https://pmc.ncbi.nlm.nih.gov/articles/PMC5082214/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a2-pmc-bga-croatia` <https://pmc.ncbi.nlm.nih.gov/articles/PMC5082214/> |

## `hba1c_analyzer` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a2-test-hba1c`, `a2-platform-hba1c-analyzer`

| # | qism (en) | manba |
|---|---|---|
| 1 | EDTA tube rack | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Sampling arm | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Buffer (eluent) bottles | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Ion-exchange column | `a2-pmc-hba1c-review` <https://pmc.ncbi.nlm.nih.gov/articles/PMC9634344/> |
| 5 | Photometric detector | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Display (chromatogram) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Printer | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 8 | Waste container | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a2-pmc-hba1c-review` <https://pmc.ncbi.nlm.nih.gov/articles/PMC9634344/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a2-pmc-hba1c-review` <https://pmc.ncbi.nlm.nih.gov/articles/PMC9634344/> |

## `lab_fridge` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a2-platform-lab-fridge-freezer-monitoring`

| # | qism (en) | manba |
|---|---|---|
| 1 | Control panel (thermostat) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Refrigerator compartment | `a2-who-qms` <https://iris.who.int/handle/10665/44665> |
| 3 | Probe in a buffered bottle | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Digital data logger (DDL) | `a2-cdc-vaccine-storage` <https://www.cdc.gov/vaccines/hcp/storage-handling/index.html> |
| 5 | Freezer compartment | `a2-who-qms` <https://iris.who.int/handle/10665/44665> |
| P | Principle | `a2-cdc-vaccine-storage` <https://www.cdc.gov/vaccines/hcp/storage-handling/index.html>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a2-cdc-vaccine-storage` <https://www.cdc.gov/vaccines/hcp/storage-handling/index.html>; `a2-who-qms` <https://iris.who.int/handle/10665/44665> |

## `fluorescence_microscope` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a2-platform-led-fluorescence-microscope`, `a2-method-auramine-smear-microscopy-tb`

| # | qism (en) | manba |
|---|---|---|
| 1 | Eyepieces | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | LED illuminator | `a2-who-led` <https://iris.who.int/handle/10665/44602> |
| 3 | Filter cube | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Objective | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Stage with smear | `a2-who-led` <https://iris.who.int/handle/10665/44602> |
| 6 | Focus knobs | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Field of view | `a2-who-led` <https://iris.who.int/handle/10665/44602>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a2-who-led` <https://iris.who.int/handle/10665/44602>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a2-who-led` <https://iris.who.int/handle/10665/44602>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `casa` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a2-platform-casa`

| # | qism (en) | manba |
|---|---|---|
| 1 | Digital camera | `a2-who-semen6` <https://iris.who.int/handle/10665/343208>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Microscope (objective) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Heated stage | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Counting chamber | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Computer and software | `a2-who-semen6` <https://iris.who.int/handle/10665/343208> |
| P | Principle | `a2-who-semen6` <https://iris.who.int/handle/10665/343208>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a2-who-semen6` <https://iris.who.int/handle/10665/343208>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `gel_card_system` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-trf-gel-card-system`

| # | qism (en) | manba |
|---|---|---|
| 1 | Card centrifuge | `a3-who-bg-module3` <https://www.who.int/publications/m/item/guidelines-and-principles-for-safe-blood-transfusion-practice---module-3-blood-group-serology> |
| 2 | Incubator | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Gel card | `a3-who-bg-module3` <https://www.who.int/publications/m/item/guidelines-and-principles-for-safe-blood-transfusion-practice---module-3-blood-group-serology> |
| 4 | Reaction chamber | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Gel column (matrix) | `a3-who-bg-module3` <https://www.who.int/publications/m/item/guidelines-and-principles-for-safe-blood-transfusion-practice---module-3-blood-group-serology> |
| 6 | Positive reaction | `a3-who-bg-module3` <https://www.who.int/publications/m/item/guidelines-and-principles-for-safe-blood-transfusion-practice---module-3-blood-group-serology> |
| 7 | Negative reaction | `a3-who-bg-module3` <https://www.who.int/publications/m/item/guidelines-and-principles-for-safe-blood-transfusion-practice---module-3-blood-group-serology> |
| P | Principle | `a3-who-bg-module3` <https://www.who.int/publications/m/item/guidelines-and-principles-for-safe-blood-transfusion-practice---module-3-blood-group-serology>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a3-who-bg-module3` <https://www.who.int/publications/m/item/guidelines-and-principles-for-safe-blood-transfusion-practice---module-3-blood-group-serology>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `esr_analyzer` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-hem-esr-analyzer`

| # | qism (en) | manba |
|---|---|---|
| 1 | Westergren stand | `a3-statpearls-esr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK557485/> |
| 2 | Westergren tube | `a3-statpearls-esr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK557485/> |
| 3 | Plasma–red cell boundary | `a3-statpearls-esr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK557485/> |
| 4 | Automated reader | `a3-statpearls-esr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK557485/> |
| 5 | Closed tubes | `a3-statpearls-esr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK557485/> |
| 6 | Optical sensors | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Display | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a3-statpearls-esr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK557485/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a3-statpearls-esr` <https://www.ncbi.nlm.nih.gov/sites/books/NBK557485/> |

## `aggregometer` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-coag-platelet-aggregometry-tem`

| # | qism (en) | manba |
|---|---|---|
| 1 | LTA measuring channels | `a3-statpearls-coag-eval` <https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/> |
| 2 | Light source | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | Cuvette (plasma and stir bar) | `a3-statpearls-coag-eval` <https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/> |
| 4 | Photodetector | `a3-statpearls-coag-eval` <https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/> |
| 5 | Aggregation curves | `a3-statpearls-coag-eval` <https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/> |
| 6 | Cup with blood | `a3-statpearls-coag-eval` <https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/> |
| 7 | Pin and torsion sensor | `a3-statpearls-coag-eval` <https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/> |
| 8 | Viscoelastic trace | `a3-statpearls-coag-eval` <https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/> |
| P | Principle | `a3-statpearls-coag-eval` <https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/> |
| R | Result | `a3-statpearls-coag-eval` <https://www.ncbi.nlm.nih.gov/sites/books/NBK606118/> |

## `electrophoresis` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-bio-electrophoresis`

| # | qism (en) | manba |
|---|---|---|
| 1 | Power supply | `a3-statpearls-electrophoresis` <https://www.ncbi.nlm.nih.gov/sites/books/NBK585057/> |
| 2 | Buffer compartments and electrodes | `a3-statpearls-electrophoresis` <https://www.ncbi.nlm.nih.gov/sites/books/NBK585057/> |
| 3 | Wicks | `a3-statpearls-electrophoresis` <https://www.ncbi.nlm.nih.gov/sites/books/NBK585057/> |
| 4 | Support medium and fractions | `a3-statpearls-electrophoresis` <https://www.ncbi.nlm.nih.gov/sites/books/NBK585057/> |
| 5 | Cover | `a3-statpearls-electrophoresis` <https://www.ncbi.nlm.nih.gov/sites/books/NBK585057/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Densitometer | `a3-statpearls-electrophoresis` <https://www.ncbi.nlm.nih.gov/sites/books/NBK585057/> |
| P | Principle | `a3-statpearls-electrophoresis` <https://www.ncbi.nlm.nih.gov/sites/books/NBK585057/> |
| R | Result | `a3-statpearls-electrophoresis` <https://www.ncbi.nlm.nih.gov/sites/books/NBK585057/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |

## `osmometer` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-bio-osmometer`

| # | qism (en) | manba |
|---|---|---|
| 1 | Sample tubes | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 2 | Thermistor probe | `a3-statpearls-osmometer` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589659/> |
| 3 | Cooling block (bath) | `a3-statpearls-osmometer` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589659/> |
| 4 | Stirring wire | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Display (freezing curve) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a3-statpearls-osmometer` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589659/>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a3-statpearls-osmometer` <https://www.ncbi.nlm.nih.gov/sites/books/NBK589659/> |

## `tlc` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-tox-tlc`

| # | qism (en) | manba |
|---|---|---|
| 1 | Developing tank (with lid) | `a3-unodc-cocaine-2012` <https://syntheticdrugs.unodc.org/uploads/syntheticdrugs/res/library/forensics_html/Recommended_Methods_for_the_Identification_and_Analysis_of_Cocaine_in_Seized_Materials_ST-NAR-7_and_Rev.1.pdf> |
| 2 | Mobile phase (solvent) | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 3 | TLC plate (silica gel GF254) | `a3-unodc-cocaine-2012` <https://syntheticdrugs.unodc.org/uploads/syntheticdrugs/res/library/forensics_html/Recommended_Methods_for_the_Identification_and_Analysis_of_Cocaine_in_Seized_Materials_ST-NAR-7_and_Rev.1.pdf> |
| 4 | Origin line | `a3-unodc-cocaine-2012` <https://syntheticdrugs.unodc.org/uploads/syntheticdrugs/res/library/forensics_html/Recommended_Methods_for_the_Identification_and_Analysis_of_Cocaine_in_Seized_Materials_ST-NAR-7_and_Rev.1.pdf> |
| 5 | Solvent front | `a3-unodc-cocaine-2012` <https://syntheticdrugs.unodc.org/uploads/syntheticdrugs/res/library/forensics_html/Recommended_Methods_for_the_Identification_and_Analysis_of_Cocaine_in_Seized_Materials_ST-NAR-7_and_Rev.1.pdf> |
| 6 | Capillaries | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | UV lamp (254 nm) | `a3-unodc-cocaine-2012` <https://syntheticdrugs.unodc.org/uploads/syntheticdrugs/res/library/forensics_html/Recommended_Methods_for_the_Identification_and_Analysis_of_Cocaine_in_Seized_Materials_ST-NAR-7_and_Rev.1.pdf> |
| 8 | Spots under UV | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| P | Principle | `a3-unodc-cocaine-2012` <https://syntheticdrugs.unodc.org/uploads/syntheticdrugs/res/library/forensics_html/Recommended_Methods_for_the_Identification_and_Analysis_of_Cocaine_in_Seized_Materials_ST-NAR-7_and_Rev.1.pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| R | Result | `a3-unodc-cocaine-2012` <https://syntheticdrugs.unodc.org/uploads/syntheticdrugs/res/library/forensics_html/Recommended_Methods_for_the_Identification_and_Analysis_of_Cocaine_in_Seized_Materials_ST-NAR-7_and_Rev.1.pdf> |

## `analytical_balance` — yo‘nalish kartasi sinfi (LabSchematic)

Kartalar: `a3-gen-gravimetric-pipette-calibration`

| # | qism (en) | manba |
|---|---|---|
| 1 | Pipette (air displacement) | `a3-nist-sop14` <https://www.nist.gov/document/sop-14-gravimetric-calibration-20190508pdf> |
| 2 | Weighing vessel | `a3-nist-sop14` <https://www.nist.gov/document/sop-14-gravimetric-calibration-20190508pdf> |
| 3 | Weighing pan | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 4 | Glass enclosure | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 5 | Display and keys | `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 6 | Water container | `a3-nist-sop14` <https://www.nist.gov/document/sop-14-gravimetric-calibration-20190508pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
| 7 | Thermometer | `a3-nist-sop14` <https://www.nist.gov/document/sop-14-gravimetric-calibration-20190508pdf> |
| P | Principle | `a3-nist-sop14` <https://www.nist.gov/document/sop-14-gravimetric-calibration-20190508pdf> |
| R | Result | `a3-nist-sop14` <https://www.nist.gov/document/sop-14-gravimetric-calibration-20190508pdf>; `STANDARD_TEXTBOOK (NEEDS_EXPERT)` |
