# Toifa banki tarjimasi (ru / en) — 2026-10-10

Qaror: ilovadagi hamma narsa uch tilli (uz/ru/en). Rasmiy attestatsiya banki
(`assets/toifa/kdl_tests.json`, `kdl_oral.json`) o‘zbekcha qoladi va **asosiy**
matn hisoblanadi; ru/en — faqat yordamchi tarjima.

## Hajmi

| | Savol | Tillar | Yozuv |
|---|---|---|---|
| Test (savol + variantlar + LabGuide izohi) | 488 | ru, en | 976 |
| Og‘zaki (savol + javob rejasi, xatolar, referens, chegaralar, izoh) | 289 | ru, en | 578 |
| Tuzilmali qatorlar (referens/chegara maydonlari, umumiy lug‘at orqali) | 326 noyob | ru, en | — |

Asset hajmi: `kdl_tests.json` 450 608 B, `kdl_oral.json` 1 739 762 B
(tarjimalar bilan taxminan +2,2 MB).

## Joylashuvi

- Manba: `tool/toifa/translations/{tests,oral}_{ru,en}.json` (id → matnlar).
- `tool/toifa/build_toifa.py` ularni har savolga `tr: {ru:{…}, en:{…}}` qilib
  qo‘shadi (`--merge-only` — manba papkasiz, mavjud assetlarga qayta qo‘shadi).
  Variantlar soni, reja bandlari soni, xatolar/referens/chegaralar soni va
  izoh mavjudligi asl bilan mos kelmasa — build xato beradi.
- `ToifaBank` yuklashda ham tekshiradi (`translation options` /
  `translation plan` — mos kelmasa yuklanmaydi).

## Ilovadagi xatti-harakat

- Interfeys ru/en bo‘lsa: tarjima ko‘rinadi, yonida “Rasmiy matn — o‘zbekcha”
  belgisi (`OfficialTextTag`; ilgari `UzbekOnlyTag`) va “Asl matnni ko‘rish”
  tugmasi (`OfficialTextToggle`) — bosilganda o‘zbekcha savol va variantlar
  (og‘zaki savolda reja ham) ko‘rinadi. Interfeys uz bo‘lsa belgi ham, tugma ham yo‘q.
- Baholash o‘zgarmagan: faqat rasmiy `key` bo‘yicha; variantlar tartibi va
  kalit indekslari tarjimadan mustaqil.
- Ko‘rinish qoidasi o‘zgarmagan: Toifa faqat UZ foydalanuvchilarga (shifokorga
  emas); tarjima ru interfeysli UZ foydalanuvchilar va sinf (classroom) testlari
  uchun ishlaydi (`topic_questions.dart`, `classroom_screens.dart`,
  `lecture_screens.dart`, `daily_screens.dart`, imtihon ko‘rib chiqish kartasi).
- Yangi l10n kalitlari: `toifaShowOriginal`, `toifaHideOriginal`,
  `toifaOriginalTitle`, `toifaTranslationAux`; `toifaUzbekOnly`/`toifaUzbekNotice`
  matni yangilandi.

## Tekshiruvlar

- `test/fixtures/toifa_official_snapshot.json` — **asl** assetlardan olingan
  kalit, variantlar soni va rasmiy matn sha256 izi (488 test + 289 og‘zaki).
- `test/widget/toifa_translation_test.dart`: har savolda ru/en bor, variantlar
  va reja soni mos; kalit va rasmiy matn izi asl bilan bir xil; ru va en
  widget testlari (tarjima + belgi + “Asl matnni ko‘rish” + xato javob
  baholanishi).
- Raqamli tekshiruv: tarjimadagi sonlar/birliklar asl bilan solishtirildi
  (23 ogohlantirish ko‘rib chiqildi, hammasi zararsiz: masalan “12 barmoqli ichak”
  → duodenum, “24 soat” aniqlashtirishlari). En tarjimada o‘nlik vergul nuqtaga
  almashtirilgan (“10 000” kabi ming ajratgichlar saqlangan).

## Mutaxassis ko‘rigi uchun noaniq atamalar (14)

Quyidagilar tarjimon (LLM) uchun noaniq; tibbiy laborant/mutaxassis tasdiqlashi kerak.

1. **“12 barmoqli ichak”** — ru: «двенадцатиперстная кишка», en: *duodenum*.
2. **Berezovskiy–Shternberg hujayralari** (kdl-t-007) — ru: «Березовского–Штернберга», en: *Berezovsky–Sternberg* (xalqaro: Reed–Sternberg).
3. **Kakovskiy–Addis usuli** (kdl-t-427) — ru: «Каковского–Аддиса», en: *Kakovsky–Addis* (xalqaro: Addis count).
4. **Rivalt sinamasi** (kdl-t-046) — *Rivalta test* (ekssudat/transsudat).
5. **Romanovskiy bo‘yog‘i** — en: *Romanowsky stain*; ru: по Романовскому.
6. **Bens-Jons oqsili** — en: *Bence Jones protein*.
7. **Limfogranulematoz** — en: *lymphogranulomatosis (Hodgkin lymphoma)*.
8. **Gistiotsitoz / sarkoidoz** va boshqa gematologik atamalar — Hodgkin/histiocytosis ro‘yxati.
9. **Koagulologik testlar nomlari** (APTV, protrombin indeksi, “Kvik bo‘yicha”, trombin vaqti) — ru: АЧТВ/ПТИ/по Квику; en: aPTT, prothrombin index, Quick.
10. **Mikroskopiya atamalari**: “tsilindrsimon” / “kiprikli” epiteliy turlari — *columnar* / *pseudostratified ciliated*.
11. **Urologik nomlar** (Nechiporenko, Zimnitskiy, Reberg sinamalari) — ru: translit. bo‘yicha, en: *Nechiporenko*, *Zimnitsky*, *Rehberg* (Reberg) test.
12. **“Nuqtali (punktat)”** — en: *aspirate* (ba’zi joylarda *puncture fluid*).
13. **Guruh/immun atamalari**: “Kumbs sinamasi” — *Coombs test*; “Rezus-konflikt” — *Rh incompatibility*.
14. **LabGuide izohlaridagi** “kalit”, “bahsli kalit”, “manbasiz tuzatish” kabi ichki atamalar — ru/en: *key*/*disputed key*/*unsourced correction* (ilova interfeysidagi so‘zlarga moslab).

Eslatma: bu ro‘yxat asosan translit. qilingan nom-nazariyalar va rus laborant
an’anasidagi atamalar bo‘yicha. Raqamlar, birliklar, belgilar (<, ≥) va
manbalar (ADA, KDIGO va h.k.) o‘zgartirilmagan.
