# Yo‘nalish kartalari — apparat rasmlari qamrovi (2026-10-25)

Qoida (egasi talabi, 24–25 oktabr):

- Ishlab chiqaruvchi fotosi faqat **yozma ruxsat** bo‘lsa. Hozircha **hech bir
  ishlab chiqaruvchidan ruxsat olinmagan** (`docs/instrument_permission_emails/`
  dagi xatlar faqat qoralama, yuborilmagan) — shuning uchun foto ham, “o‘xshatma”
  ham ishlatilmaydi.
- Aks holda — LabGuide’ning **o‘z original sxematik chizmasi**, apparat **SINFI**
  bo‘yicha: brend, logotip, yozuv, ishlab chiqaruvchi dizayni yo‘q; rasmda matn
  yo‘q; faqat tamoyil darajasidagi umumiy qismlar. Kartada doim izoh:
  “Sxematik tasvir — aniq model emas” (`instSchematicCaption`), bosilsa
  kattalashtiriladi; alt-matn — sinf tavsifi (`labSchem*`, uz/ru/en).
- Platforma kartasi — o‘z sinf chizmasi; test/usul kartasi — u bajariladigan
  (bog‘langan) platformaning chizmasi; mazmunli apparat bo‘lmasa — **istisno**
  (chizma majburan qo‘yilmaydi, sabab quyida).
- NEEDS_SOURCE stub kartalar (19 ta) ko‘rsatilmaydi va ularga rasm berilmaydi
  (katalog validatori stubda `schematic` maydonini rad etadi).

Manba: `assets/instruments/catalog.json` → `lab_cards[].schematic`; kalitlar
ro‘yxati — `lib/features/instruments/lab_direction_card.dart` (`LabSchematic`);
chizmalar — `tool/illustrations/schematic/gen.py` (L1–L25), fayllar
`assets/instruments/schematic/<kalit>_480.png` va `_1200.png`; kelib chiqishi —
`docs/SCHEMATICS_PROVENANCE.md`. Qorovul: `test/guards/lab_card_schematic_guard_test.dart`
(yangi ommaviy karta shu jadvalda bo‘lmasa yoki rasmi/istisno sababi bo‘lmasa — xato).

Qism belgilari (2026-10-25): har bir chizmada asosiy qismlar raqamlangan
(1..n); chizma ostida yig‘ilgan “Qismlari va ishlash prinsipi” paneli
(`SchematicPartsPanel`) — qism nomi va vazifasi, ishlash prinsipi, natija.
Ma’lumot: `assets/instruments/schematic_parts.json` + ARB `schemParts*`;
manbalar — `docs/SCHEMATIC_PARTS_SOURCES.md`; qorovul —
`test/guards/schematic_parts_guard_test.dart`.

Jami: 45 ta ommaviy karta — 35 tasida sxematik chizma, 10 tasi istisno;
25 ta yangi sinf chizmasi.

| card id | kind | schematic key | reason |
|---|---|---|---|
| `tb-genexpert-platform` | platform | `cartridge_molecular` | Kartrijli yopiq NAAT platformasi: sinf chizmasi (modullar, bir martalik kartrij, namuna idishi). Kartada `models: []` — izoh “aniq model emas”. |
| `tb-xpert-mtb-rif-tests` | test | `cartridge_molecular` | Test bog‘langan platformada (`tb-genexpert-platform`) bajariladi — o‘sha sinf chizmasi. |
| `tb-lamp-test` | test | — | Istisno: apparat kartasi manbasiz (`a3-tb-lamp-platform-stub`, NEEDS_SOURCE); kartada apparat tavsifi yo‘q — chizma majburan qo‘yilmaydi. |
| `tb-truenat-test` | test | — | Istisno: chipli mikro-PCR o‘quvchisi kartasi manbasiz (`a3-truenat-platform-stub`); kartada apparat tavsifi yo‘q. Umumiy PCR chizmasi bu qurilmaga mos kelmaydi. |
| `hiv-agab-immunoassay-algorithm` | test | — | Istisno: laboratoriya algoritmi; kombinatsiyalangan immunoanaliz turli formatlarda (avtomatik analizator yoki planshet) bajariladi — bitta mazmunli apparat yo‘q. |
| `hiv-rna-viral-load` | test | `real_time_pcr` | Miqdoriy real vaqt RT-PCR; bog‘langan platforma `a3-mol-realtime-pcr-platform` — o‘sha sinf chizmasi (avtomatik ekstraksiya moduli alohida chizilmagan). |
| `a1-geenius-hiv-confirm-test` | test | — | Istisno: immunoxromatografik kasseta va faqat shu testga mo‘ljallangan o‘quvchi (bitta ishlab chiqaruvchining qurilmasi) — “sinf” chizmasi aniq modelga o‘xshab qolishi mumkin. |
| `a1-realtime-pcr-method` | method | `real_time_pcr` | Usul real vaqt PCR amplifikatorida bajariladi (bog‘langan platforma `a3-mol-realtime-pcr-platform`). |
| `a1-autoclave-platform` | platform | `autoclave` | Bug‘li sterilizator sinfi: kamera, eshik, bosim va harorat ko‘rsatkichlari. |
| `a1-blood-culture-platform` | platform | `blood_culture` | Avtomatik gemokultura tizimi sinfi: inkubator-o‘quvchi, flakon tubidagi sensor. Kartada `models: []` — aniq model emas. |
| `a1-coagulation-analyzer-platform` | platform | `coag_analyzer` | Koagulometr sinfi: reagentlar, kyuvetalar, optik laxta aniqlash. |
| `a1-pt-inr-test` | test | `coag_analyzer` | PT/INR koagulometrda o‘lchanadi (bog‘langan platforma `a1-coagulation-analyzer-platform`). |
| `a1-elisa-method` | method | `elisa_reader` | Planshet usuli: o‘quvchi va yuvish qurilmasida (bog‘langan platforma `a1-elisa-reader-platform`). |
| `a1-elisa-reader-platform` | platform | `elisa_reader` | Mikroplanshet o‘quvchisi va yuvish qurilmasi sinfi. |
| `a1-bsc-class2-platform` | platform | `bsc_class2` | II sinf biologik xavfsizlik shkafi: oyna, HEPA filtrlar, havo oqimi strelkalari, ish yuzasi (yon kesim). |
| `a2-platform-blood-gas-ise-analyzer` | platform | `blood_gas_ise` | Qon gazlari va ISE analizatori sinfi: namuna zondi, elektrodli sensor kassetasi, reagent paketi. |
| `a2-test-arterial-blood-gas-panel` | test | `blood_gas_ise` | Panel shu analizatorda o‘lchanadi (bog‘langan platforma `a2-platform-blood-gas-ise-analyzer`). |
| `a2-method-calibrators-control-materials` | method | — | Istisno: material (kalibrator va nazorat materiali), apparat emas; har qanday analizatorga tegishli. |
| `a2-platform-lab-fridge-freezer-monitoring` | platform | `lab_fridge` | Sovutgich-muzlatgich, buferli datchik va raqamli harorat yozgichi (DDL) sinfi. |
| `a2-test-hba1c` | test | `hba1c_analyzer` | Test bog‘langan platformada (`a2-platform-hba1c-analyzer`); chizma usulni (ion almashinish, affinlik va h.k.) ko‘rsatmaydi. |
| `a2-platform-hba1c-analyzer` | platform | `hba1c_analyzer` | Ixcham HbA1c analizatori sinfi; ichki usul ataylab ko‘rsatilmagan (kartada bir nechta tamoyil bor). |
| `a2-platform-led-fluorescence-microscope` | platform | `fluorescence_microscope` | LED fluoressent mikroskop sinfi; ichki rasm — auramin bilan bo‘yalgan batsillalarning umumiy ko‘rinishi. |
| `a2-method-auramine-smear-microscopy-tb` | method | `fluorescence_microscope` | Surtma LED fluoressent mikroskopda ko‘riladi (bog‘langan platforma). |
| `a2-method-newborn-screening-dbs-qa` | method | — | Istisno: filtr qog‘ozdagi quruq qon dog‘lari va tashqi sifat nazorati dasturi; bitta apparat yo‘q (tahlil turli platformalarda). |
| `a2-test-semen-analysis-who6` | test | — | Istisno: asosiy usul — qo‘lda mikroskopiya; CASA faqat qo‘shimcha. CASA chizmasi noto‘g‘ri taassurot beradi; yorug‘lik mikroskopi kartasi manbasiz (`a3-light-microscope-stub`). |
| `a2-platform-casa` | platform | `casa` | CASA sinfi: kamerali mikroskop, isitiladigan stolik, kompyuter ekranida harakat izlari. |
| `a2-test-urine-drug-immunoassay-screen` | test | — | Istisno: format har xil (avtomatik analizator yoki tezkor test); kartada platforma ko‘rsatilmagan — chizma majburan qo‘yilmaydi. |
| `a3-trf-gel-card-system` | platform | `gel_card_system` | Gel karta tizimi: karta sentrifugasi, inkubator, musbat/manfiy reaksiyali gel karta. |
| `a3-hem-esr-analyzer` | platform | `esr_analyzer` | Westergren shtativi va avtomatik EChT o‘quvchisi sinfi. |
| `a3-tox-gc-ms` | platform | `mass_spec_gc` | GC (gaz ballon, avtonamunaoluvchi, termostatdagi kolonka) + ion manbai + kvadrupol + detektor + vakuum + ma’lumot tizimi. |
| `a3-tox-lc-ms` | platform | `mass_spec_lc` | LC (erituvchilar, nasos, avtonamunaoluvchi, kolonka) + ESI manbai + analizator + detektor + vakuum. |
| `a3-gen-gravimetric-pipette-calibration` | method | `analytical_balance` | Usul jihozi: analitik tarozi, toza suv, termometr (manbadagi tavsif: elektron tarozi va suv). |
| `a3-coag-platelet-aggregometry-tem` | platform | `aggregometer` | LTA agregometri va viskoelastik (TEG/ROTEM turi) analizator sinfi; aniq model emas. |
| `a3-tox-tlc` | method | `tlc` | Usulning o‘zi jihoz: rivojlantirish kamerasi, plastina, UB lampa (254 nm). |
| `a3-gen-fish-molecular-genetics` | method | — | Istisno: bir nechta usul sinfi (FISH, mikromassiv, kariotip, MLPA, NGS); bitta apparat yo‘q. FISH uchun fluoressent mikroskop chizmasi — egasi qarori (pastda). |
| `a3-bio-electrophoresis` | platform | `electrophoresis` | Tok manbai, kamera (bufer, pilikcha, tashuvchi muhit, qopqoq), densitometr. |
| `a3-bio-osmometer` | platform | `osmometer` | Muzlash nuqtasi osmometri (kartadagi asosiy tur). |
| `a3-tb-bactec-mgit960-platform` | platform | `mycobacterial_culture` | Mikobakteriyalar uchun suyuq muhit tizimi sinfi (tortmalar, probirka tubidagi kislorod sensori); aniq model emas. |
| `a3-tb-mgit-culture-dst-method` | method | `mycobacterial_culture` | Usul bog‘langan platformada (`a3-tb-bactec-mgit960-platform`) bajariladi. |
| `a3-hiv-cd4-flow-method` | method | `flow_cytometer` | Usul oqim sitometrida (bog‘langan platforma `a3-imm-flow-cytometer-platform`). |
| `a3-imm-flow-cytometer-platform` | platform | `flow_cytometer` | Suyuqlik tizimi, optika (lazer, kyuveta, detektorlar), kompyuter. |
| `a3-mol-realtime-pcr-platform` | platform | `real_time_pcr` | Termoblok, isitiladigan qopqoq, optik modul, probirka qatori. |
| `a3-bac-vitek2-platform` | platform | `microbial_id_ast` | Avtomatik ID/AST tizimi sinfi (kasseta, kartalar, inkubator-o‘quvchi); aniq model emas. |
| `a3-bac-ast-method` | method | — | Istisno: asosiy EUCAST usullari qo‘lda (disk-diffuziya, mikrosuyultirish); avtomatik tizim — faqat hosila usul, uning chizmasi noto‘g‘ri taassurot beradi. |
| `a3-bac-maldi-tof-platform` | platform | `maldi_tof` | Nishon plastina, lazer, uchish trubasi, detektor, vakuum. |

## Egasi qarori kerak

- `a3-gen-fish-molecular-genetics`: FISH uchun `fluorescence_microscope`
  chizmasini qo‘yish mumkin, lekin karta bir nechta usul sinfi (mikromassiv,
  kariotip, MLPA, NGS) — hozircha istisno.
- `a2-test-semen-analysis-who6`: yorug‘lik mikroskopi kartasi (`a3-light-microscope-stub`)
  manbali bo‘lsa, unga va shu testga umumiy mikroskop chizmasi qo‘shiladi.
- `tb-lamp-test`, `tb-truenat-test`: platforma stublari manbali bo‘lganda sinf
  chizmalari (isitish bloki + fluoressent o‘quvchi; chipli mikro-PCR o‘quvchisi)
  alohida chiziladi.
