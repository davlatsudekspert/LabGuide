# Kontent bo'laklari

`additions/<yo'nalish>.json` — asosiy paketga (`assets/content/core/pack.json`)
qo'shiladigan kartalar, manbalar, savollar va kasallik qo'llanmalari.
Qo'shgandan keyin: `python3 tool/build_core_pack.py` (upsert + manifest).

Kanonik analit id lari (yo'nalishlar bir-biriga havola qilishi uchun):

| Yo'nalish (fayl) | Guruh id | Analit id lari |
|---|---|---|
| Gormonlar (`endocrine.json`) | `endocrine` | `tsh`, `ft4`, `ft3`, `anti-tpo`, `lh`, `fsh`, `prolactin`, `estradiol`, `progesterone`, `testosterone`, `hcg`, `cortisol`, `insulin`, `c-peptide`, `pth`, `vitamin-d` |
| Gematologiya (`hematology.json`) | `hematology`, `coagulation` | `hemoglobin`, `hematocrit`, `rbc-count`, `wbc-count`, `neutrophils`, `lymphocytes`, `monocytes`, `eosinophils`, `basophils`, `platelets`, `mcv`, `mch`, `mchc`, `rdw`, `reticulocytes`, `esr`, `pt-inr`, `aptt`, `fibrinogen`, `d-dimer`; qo‘shimcha: `mpv`, `blood-smear`, `hemoglobin-electrophoresis`, `g6pd`, `coagulation-factors`, `protein-c-s` |
| Yurak, temir, vitaminlar (`cardio_iron.json`) | `cardiac`, `iron-vitamins` | `troponin`, `natriuretic-peptides`, `ck-mb`, `iron`, `ferritin`, `transferrin-tibc`, `vitamin-b12`, `folate`, `lipoprotein-a`, `lactate` |
| Infeksiya, immunologiya, o'smalar (`infection_immuno.json`) | `infection-serology`, `autoimmune`, `tumor-markers` | `hbsag`, `anti-hcv`, `hiv-test`, `syphilis-tests`, `procalcitonin`, `aso`, `rheumatoid-factor`, `anti-ccp`, `ana`, `psa`, `cea`, `afp`, `ca-125`, `ca-19-9` |
| Umumklinik tekshiruvlar (`general_clinical.json`) | `stool-parasitology`, `body-fluids`, `cytology` (+ mavjud `urine`) | `stool-analysis`, `stool-ova-parasites`, `pinworm-test`, `fecal-occult-blood`, `h-pylori-tests`, `csf-analysis`, `pleural-fluid-analysis`, `synovial-fluid-analysis`, `sputum-afb`, `sputum-culture`, `urine-24h`, `urine-culture`, `pap-test`, `hpv-test`, `vaginal-wet-mount` |
| Kasallik bo'yicha qo'llanma (`conditions.json`) | — | `conditions[]` yuqoridagi id larga havola qiladi |
