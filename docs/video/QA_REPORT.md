# Video qo‘llanmalar — kadrma-kadr QA hisoboti (2026-10-25)

30 ta MP4 (10 mavzu × uz/ru/en) — **ovozsiz, subtitrli ekran yozuvi — diktorsiz** — kadrma-kadr
ko‘rib chiqildi, topilgan kamchiliklar pipeline manbalarida tuzatildi, videolar qayta yig‘ildi va
tuzatilgan kadrlar qayta ko‘rildi.

## Usul (nima haqiqatan ko‘rildi)

1. `python3 tool/video/qa_extract.py` — har MP4 dan **har storyboard qadami** uchun bitta kadr
   (ffmpeg, qadam oxiridan 0,45 s oldin — tap belgisi ko‘rinadigan payt, o‘tishdan oldin), jumladan
   boshlang‘ich va yakuniy kartochka: jami 30 video × 10–17 kadr. Kadrlar 4×2 kontakt varaqlariga
   (har katak 360×640 — telefon ekranidagi o‘lchamga yaqin) yig‘ildi va **hammasi Read bilan ko‘zdan
   kechirildi**: 1-o‘tish (eski videolar, `build/video_qa_v1/sheets/`) va tuzatishdan keyingi 2-o‘tish
   (`build/video_qa/sheets/`, 59 varaq — 30 videoning hammasi). 03 va 10-mavzular uchinchi marta
   (oxirgi tuzatishdan keyin) ko‘rildi.
2. Har subtitr uchun shrift o‘lchami va qatorlar soni o‘lchandi (`build/video_qa/captions.tsv`,
   308 subtitr): hozir hammasi ≤ 3 qator, 40 px — 293, 37 px — 12, 34 px — 3 (720 px kenglikda).
   `compose.py` endi 34 px dan kichik shriftga tushmaydi — matn sig‘masa yig‘ish xato bilan to‘xtaydi.
3. Matnlar: uz o‘/g‘ (U+2018) va tutuq (U+2019) — skript bilan tekshirildi (xato yo‘q); ru/en
   atamalar ilova ARB va ekrandagi yozuvlar bilan solishtirildi.
4. Har MP4 — ffprobe: 720×1280, h264, 24 fps, **audio oqimi 0** (30/30); `docs/video/OUTPUTS.md`
   qayta yozildi (davomiylik, hajm, sha256).

Mezonlar: (a) subtitr sig‘adi / o‘qiladi; (b) qadamlar tartibi ilova va storyboard bilan bir xil;
(c) uch til bir xil narsani aytadi; (d) atamalar to‘g‘ri va ARB bilan izchil; (e) har kadr haqiqiy
ekran, tap belgisi to‘g‘ri vidjetda, ekran tili = video tili; (f) halol yorliq bor.

## Umumiy natija (mezonlar bo‘yicha, tuzatishdan keyin)

| Mezon | Natija |
|---|---|
| (a) subtitr sig‘ishi | PASS — 30/30 (kesilish yo‘q; eng kichik shrift 34 px) |
| (b) qadamlar tartibi | PASS — 30/30 (kadr tartibi `compose.py` da storyboard bilan avtomatik solishtiriladi) |
| (c) uch til mosligi | PASS — 1 nomuvofiqlik tuzatildi (pastda #5) |
| (d) atamalar | PASS — 1 tuzatildi (#6); ilova ichidagi 1 kamchilik — ilovada, videoda emas (#10) |
| (e) haqiqiy ekran, tap, til | PASS — har kadr shu tildagi ilova ekrani (uz/ru/en walk alohida render qilinadi); 3 ta tap/kadr muammosi tuzatildi |
| (f) yorliq | PASS — 30/30: boshlang‘ich va yakuniy kartochkada «Ovozsiz, subtitrli ekran yozuvi — diktorsiz» / «Без звука, с субтитрами — запись экрана без диктора» / «Silent screen recording with subtitles — no narration»; MP4 metadata `comment` da ham |

## Topilmalar

Daraja: **O‘rta** — tomoshabin noto‘g‘ri tushunishi yoki kadr subtitrga mos kelmasligi mumkin;
**Past** — o‘qilishi qiyinroq / kosmetik; **Ma’lumot** — kamchilik emas, qayd uchun.

| # | Video | Til | Vaqt / qadam | Nima noto‘g‘ri edi | Daraja | Holat |
|---|---|---|---|---|---|---|
| 1 | 01_kalibrlash | uz, ru, en | 00:26–00:30 / 7 `cal_record` | «Yozuvni saqlash» tugmasi sarlavha paneli ostida qisman yashiringan, tap belgisi yarim ko‘rinadigan tugmada | O‘rta | **FIXED** — `VideoWalk.center()`: element ekran tepasi/pastida bo‘lsa o‘rtaga suriladi; qayta ko‘rildi |
| 2 | 10_boshqa_funksiyalar | uz, ru, en | 00:09–00:14 / 3 `diff_howto` | Tap belgisi how-to oynasining o‘rtasida («Natijada nima olasiz» matni ustida) — bosilmaydigan joyda; aslida «Yopish» bosilgan | O‘rta | **FIXED** — yopish `press()` orqali: en — belgi «Close» tugmasida (kadr ko‘rildi); uz/ru — tugma ko‘rinishi uchun oyna surilgani sababli belgi qo‘yilmaydi (noto‘g‘ri belgi yo‘q) |
| 3 | 03_preanalitika | ru, en | 00:10–00:23 / 3–5 | Surish masofasi qat’iy (900/1100 px) bo‘lgani uchun ru/en kadrlarda bo‘lim sarlavhasi chiqmagan: «Порядок пробирок» kadrida ro‘yxat o‘rtadan, «Which tube…» kadrida bo‘lim boshi yo‘q — subtitr va kadr mos emas | O‘rta | **FIXED** — `VideoWalk.top()`: kadr bo‘lim sarlavhasiga (ARB `prePatientTitle`, `preOrderTitle`, `preTubeForTestTitle`) bog‘landi; uz/ru/en qayta ko‘rildi |
| 4 | 08_bilim_baholash; 04_kalkulyatorlar | ru | 08: 00:03–00:08 (1) va 00:26–00:30 (7); 04: 00:06–00:10 (2) | Uzun subtitr 28–31 px gacha kichraygan (telefonda o‘qish qiyin) | Past | **FIXED** — matnlar qisqartirildi; `compose.py` da 34 px chegarasi va xato |
| 5 | 08_bilim_baholash | uz, ru, en | 7 `as_test_q` | Tillar har xil narsa aytgan: uz — «savollar xaritasi», ru/en — «rasmiy matn — o‘zbekcha» | Past | **FIXED** — uchala tilda: «rasmiy ro‘yxatdan tasodifiy savollar; pastda — savollar xaritasi» (kadrda ko‘rinadi) |
| 6 | 04_kalkulyatorlar | ru | 00:10–00:13 / 3 `calc_egfr` | Subtitrda «eGFR», ekran va ARB da «рСКФ (eGFR)» | Past | **FIXED** — «рСКФ (eGFR, CKD-EPI 2021)…» |
| 7 | 10_boshqa_funksiyalar | uz, ru, en | 00:49–00:53 / 14 `profile` | Subtitr «mavzu (theme)» ni aytadi, kadrda mavzu bo‘limi ko‘rinmaydi | Past | **FIXED** — «Profil: til, birliklar va bo‘lim ko‘rinishi» (kadrda bor narsa) |
| 8 | 06_mikroskopiya; 09_testlar_natijalar | uz/ru/en | 06: 00:31–00:35 (9); 09: 00:12–00:17 (4) | Mashq savoli tasodifiy: bir tilda javob to‘g‘ri, boshqasida noto‘g‘ri (har tilda boshqa savol). Subtitr ikkala holatni ham to‘g‘ri tasvirlaydi («to‘g‘ri yoki to‘g‘ri javob ko‘rsatiladi») | Ma’lumot | **NOT FIXED** — ilovaning haqiqiy xatti-harakati; `MicroQuizScreen.random` marshrut orqali berilmaydi, ilova kodini video uchun o‘zgartirmadik |
| 9 | 05_apparatlar | ru | 00:19–00:23 / 6 | Subtitrda „Мой прибор“ (ichki qo‘shtirnoq), tugmada «Мой прибор» | Ma’lumot | NOT FIXED — tipografik variant (ichma-ich «» o‘rniga „“), ma’no bir xil |
| 10 | 01_kalibrlash | uz, ru, en | 00:33–00:38 / 9 `cal_log` | **Ilova kamchiligi:** jurnalning «Tarix» qatorida xom enum nomlari ko‘rinadi — `pending · training · QC notRun` (uz/ru da ham inglizcha). Manba: `InstrumentsController._summary` (`lib/features/instruments/instruments_controller.dart`) audit yozuviga `outcome.name`, `kind.name`, `qcAfter.name` ni yozadi | Past (ilova) | **NOT FIXED — xabar qilindi.** Audit jurnali append-only va matn yozish paytida saqlanadi; tuzatish (ko‘rsatishda tarjima yoki yangi format) xatti-harakatni o‘zgartiradi — egasi/ishlab chiquvchi qarori kerak. Video kadri ilovani halol ko‘rsatadi |

Jami: 10 topilma — O‘rta 3, Past 5 (shundan 1 — ilova kamchiligi), Ma’lumot 2. Tuzatildi: 7.
Tuzatilmadi: 3 (#8, #9 — kamchilik emas; #10 — ilova, xabar qilindi).

## Halol cheklovlar

- **Ovoz yo‘q** — diktor/TTS vositasi yo‘q; videolar faqat subtitrli. Audio tekshiruvi qilinmadi
  (tekshiradigan narsa yo‘q; ffprobe: 0 audio oqim).
- **Haqiqiy telefonda ko‘rilmadi** — faqat kadrlar (720×1280 dan 360×640 ga kichraytirilgan kontakt
  varaqlari) ko‘rildi; video pleyerda uzluksiz ijro, o‘tish animatsiyalari va tap animatsiyasining har
  bir oraliq kadri alohida ko‘rilmadi (har qadamdan bitta kadr).
- Ekranlar — Flutter widget-test render (haqiqiy ilova kodi va kontenti, serversiz), qurilmadan ekran
  yozuvi emas; shriftlar ilovadagi Inter, lekin tizim UI (status bar) yo‘q.
- Tibbiy/ilmiy mazmun mutaxassis tomonidan tasdiqlanmagan; subtitrlar faqat ilovadagi matnni
  qayta aytadi. Hech kimning nomidan tasdiq yozilmadi.

## Qayta tekshirish

```sh
python3 tool/video/qa_extract.py        # kadrlar + kontakt varaqlari + captions.tsv → build/video_qa/
python3 tool/video/report.py            # storyboard jadvallari + OUTPUTS.md
```
