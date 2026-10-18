# Taqdimotlar qamrovi (mavzu bo‘yicha PPTX)

Avtomatik: `python3 tool/slides/make_topic_decks.py --all --dry-run --report docs/DECKS_COVERAGE.md`. Qo‘lda tahrirlamang.

**Ilova ichida:** shu mazmunning hammasi (143 kun mavzusi + amaliy protokollar, uz/ru/en) ilovaning Ma’ruza bo‘limida qidiruv bilan mavjud: `python3 tool/slides/export_app_decks.py` `assets/lectures/decks/` va `assets/lectures/index_v2.json` ni qayta yozadi (kontent o‘zgarganda ishga tushiring; `--check` dolzarbligini tekshiradi). PPTX fayllar repoga qo‘shilmaydi.

Tillar: uz. Bitta deck = bitta o‘quv kuni (amaliy + ma’ruza bir xil havolalarga ega, `dNNN-P` va `dNNN-L` bitta fayl). Kunlar: 143; deck: 143; kontentsiz (deck yo‘q): 0.

## Rasm va jadvallarni mavzuga bog‘lash qoidasi

- **Analit/holat kartalari** — `links.analytes` / `links.conditions` (pack.json); har analit: maqsad+fiziologiya, me’yor/qaror chegaralari (faqat kartada `decision_limits`/`treatment_goals` bo‘lsa), oshishi/pasayishi, preanalitika.
- **Me’yoriy qiymatlar (toifa bankidan)** — mavzuning og‘zaki savollaridagi `reference`/`cutoffs` qatorlari (manbali).
- **Jadvallar** — `links.reference` (anemiya algoritmi, soxta natijalar, sariqlik, jigar sindromlari, najas parazitlari).
- **Leykoformula hujayralari (sxema)** — 7 asosiy hujayra: `/lab/calculators/differential` vositasi yoki neytrofil/limfotsit/monotsit/eozinofil/bazofil analiti bor mavzularda; reaktiv limfotsit va toksik neytrofil — faqat differential vositali mavzularda; gipersegmentlangan neytrofil — B12/foliy/MMA analitli yoki sarlavhada “B-12”; blast — sarlavhada “leykoz” (surunkali leykozlardan tashqari); smudge hujayra — sarlavhada “limfoleykoz”. Adashtiriladigan juftliklar, talqin, surtma texnikasi va misol oraliqlari — differential vositali mavzularda.
- **Sitologiya sxemalari** — `pap-test` → epiteliy hujayralari + Bethesda jadvali; `vaginal-wet-mount` → flora/yallig‘lanish sxemalari; `pap-test` yoki `hpv-test` → koilotsit, HSIL; surtma olish va bo‘yash — pap-test va vaginal-wet-mount birga bo‘lgan mavzuda. “Qin surtmasi tozalik darajalari” jadvali manbasi yo‘qligi uchun kiritilmagan.
- **Darslik bo‘yicha qisqa mazmun** — `tool/slides/data/books_extra.json`: ustoz kitoblaridan o‘z so‘zim bilan (Aripova va b., 2007: d044, d047, d051, d052 — sahifalar bilan; Najmitdinov, 1998: d010, d017, d018 — elektron matnda sahifa raqami yo‘q, bo‘lim nomi bilan). Yupqa kunlar uchun qo‘shimcha (d001–d006, d009, d010, d019, d020, d032, d033, d038, d040, d041, d053, d063, d064, d078, d081, d083, d085, d086, d116, d143): Aripov va b., 2006; Yusupova va b., 2022 va Kurbonova, 2023 (bosma sahifa raqami bilan); Agzamxodjaev va b., 2016; muallifi/yili ko‘rsatilmagan ma’ruza matnlari (shunday belgilangan). Matn/rasm ko‘chirilmagan; kitobdagi eskirgan yoki o‘zaro zid raqamlar olinmagan. Kitoblar Drive MCP orqali o‘qildi; Najmitdinov matni dastlab leykoz bobining oxirida (sitokimyo) kesilgan edi, to‘liq matn keyin .doc orqali tiklandi (d021/d022 uchun kitob mazmuni hali qo‘shilmagan; surunkali mieloleykozning klinik bo‘limi manbada shikastlangan). Axloq/deontologiya (d001, d004), TORCH (d083, toksoplazmadan tashqari), SOE analizatorlari (d085) va Mindray (d041, d116) bo‘yicha o‘qiladigan manba topilmadi. DjVu atlaslar, Hodjibekov va Sultonov (o‘qib bo‘lmaydi) olinmadi.
- **M9 amaliy kunlari (d091–d142): LabGuide tavsiya etgan amaliy reja** (D-67, `docs/M9_PRACTICAL_TOPICS.md`) — manbalarda kunma-kun mavzu yo‘q; `plan_source: "labguide_recommended"` kunlarda birinchi mazmun slaydi «Kun rejasi» (jadvaldagi umumiy nom, tavsiya, reja asoslangan darslik bobi — `plan_refs`), so‘ng `links.protocols` dagi amaliy protokol slaydlari (protokol decklari bilan bir xil matn; `id#1-4` — tanlangan slaydlar).
- **Mikroskopik atlas fotolari** — `links.microscopy` (urine / blood / parasites); litsenziya va muallif har slaydda va “Adabiyotlar”da.
- **Savol-javob** — curriculum nomzodlari (yo‘q bo‘lsa ilovadagi kabi analit/toifa mavzusi bo‘yicha): paket mashq savollari (manbasizlari tashlanadi), toifa testlari (faqat kaliti aniq: verdict `ok`, bitta javob, `unverified` emas), og‘zaki savollar (javob rejasi). Chegara: {'quiz': 6, 'test': 6, 'oral': 3}.
- `bloodgroup/card.png` va `spermogram/card.png` — hech bir curriculum mavzusiga bog‘lanmagan (havolalarda yo‘q), shuning uchun ishlatilmadi.

## Deck bor mavzular

| Kun | Mavzu (uz) | Slayd (PPTX, uz; ~ — taxminiy) | Kontent | Yetishmaydi |
|---|---|---|---|---|
| d001 | Laborator xizmatni tashkillashtirish. Tibbiy etika va deontologiya. Ma | ~12 | kitob 6, Q&A 0+0+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d002 | O‘zbekistonda klinik biokimyoviy laboratoriyalarni rivojlantirishning  | ~22 | me’yor qatori 2, kitob 3, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d003 | Laboratoriya ichida va laboratoriyalar oro o‘tkaziladigan sifat nazora | ~23 | me’yor qatori 2, kitob 4, Q&A 0+6+3 | — |
| d004 | Attestatsiya 1. Laborator xizmatni tashkillashtirish. Tibbiy etika va  | ~21 | me’yor qatori 2, kitob 2, Q&A 0+6+3 | — |
| d005 | Odam ichki a’zolari tuzilishi va vazifalari. To‘qimalar klassifikatsiy | ~11 | kitob 5 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d006 | Biriktiruvchi to‘qimaning morfofunksional xarakteristikasi | ~9 | kitob 2 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d007 | Jigar kasalliklarining laborator ko‘rsatkichlari | ~75 | analit 7, holat 4, jadval 2, me’yor qatori 2, Q&A 6+6+3 | — |
| d008 | Buyrak va siydik yo‘llari kasalliklarining laborator ko‘rsatkichlari | ~65 | analit 7, holat 3, me’yor qatori 10, Q&A 6+6+3 | — |
| d009 | Attestatsiya 2. Odam ichki a’zolari tuzilishi va vazifalari modulidan | ~21 | me’yor qatori 10, kitob 2, Q&A 0+6+3 | — |
| d010 | Qon ishlab chiqarishning zamonaviy nazariyasi. Eritropoez, leykopoez,  | ~25 | analit 1, me’yor qatori 10, kitob 5, Q&A 3+1+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d011 | Qon shaklli elementlari sonini sanash. Gemoglobinni aniqlash | ~54 | analit 5, jadval 1, me’yor qatori 16, Q&A 6+6+3 | — |
| d012 | Leykositar formula uchun material olish va ularni sanash. Mieloid, lim | ~92 | analit 7, hujayra 12, foto 8, me’yor qatori 9, Q&A 6+6+3 | — |
| d013 | Anemiyalar. Klassifikatsiyasi, etiologiyasi va patogenezi | ~64 | analit 7, holat 1, jadval 1, me’yor qatori 12, Q&A 6+5+3 | — |
| d014 | Temir tanqisligi bilan kechadigan anemiyalar. Suyak ko‘migi va perifer | ~68 | analit 6, holat 1, jadval 1, foto 8, me’yor qatori 9, Q&A 6+6+3 | — |
| d015 | Vit. B-12 yetishmasligi bilan bog‘liq kamqonliklar. Suyak ko‘migi va p | ~60 | analit 5, holat 1, jadval 1, hujayra 1, me’yor qatori 4, Q&A 5+6+3 | — |
| d016 | Gemolitik kamqonliklar. Klinik-laborator ko‘rsatkichlari. Suyak ko‘mig | ~57 | analit 5, holat 2, jadval 1, me’yor qatori 2, Q&A 6+4+3 | — |
| d017 | Leykozlar, etiologiyasi, patogenezi va klassifikatsiya | ~36 | analit 2, hujayra 1, me’yor qatori 3, kitob 3, Q&A 3+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d018 | O‘tkir leykozlar. O‘tkir leykozlarda suyak ko‘migi va periferik qon ko | ~28 | analit 1, hujayra 1, me’yor qatori 3, kitob 2, Q&A 1+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d019 | Surunkali leykozlar. Suyak ko‘migi va periferik qon ko‘rinishi | ~22 | me’yor qatori 3, kitob 3, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d020 | Surunkali mieloleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | ~8 | kitob 2, Q&A 0+1+1 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d021 | Surunkali limfoleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | ~26 | analit 1, hujayra 8, me’yor qatori 1, Q&A 2+1+1 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d022 | Mielom kasalligida suyak ko‘migi va periferik qon ko‘rinishi | ~26 | analit 2, me’yor qatori 1, Q&A 4+3+1 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d023 | Attestatsiya 3. Gematologik tekshiruv usullari modulidan | ~27 | analit 1, me’yor qatori 27, Q&A 2+6+3 | — |
| d024 | Oshqozon va o‘t suyuqligini mikroskopik tekshirish kasalliklarining kl | ~21 | analit 1, Q&A 1+6+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q; curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d025 | Najasni mikroskopik tekshirish. Klinik diagnostik ahamiyati | ~44 | analit 4, jadval 1, me’yor qatori 2, Q&A 3+6+3 | — |
| d026 | Najasni mikroskopik tekshirish. Klinik diagnostik ahamiyati (2-kun) | ~39 | analit 3, jadval 1, me’yor qatori 2, Q&A 2+6+3 | — |
| d027 | Siydikni tekshirish. Klinik diagnostik ahamiyati | ~55 | analit 5, foto 14, me’yor qatori 9, Q&A 6+6+3 | — |
| d028 | Siydikni tekshirish. Klinik diagnostik ahamiyati (2-kun) | ~55 | analit 5, foto 14, me’yor qatori 9, Q&A 6+6+3 | — |
| d029 | Bronxial astma, pnevmoniya, bronxit va boshqa nafas yo‘llari kasallikl | ~29 | analit 2, me’yor qatori 1, Q&A 2+6+3 | — |
| d030 | Sil kasalligida balg‘amni tekshirish va uning klinik diagnostik ahamiy | ~29 | analit 2, me’yor qatori 1, Q&A 2+6+3 | — |
| d031 | Sil kasalligida balg‘amni tekshirish va uning klinik diagnostik ahamiy | ~29 | analit 2, me’yor qatori 1, Q&A 2+6+3 | — |
| d032 | Transsudat va ekssudatlarni tekshirishning klinik diagnostikasi | ~20 | analit 2, me’yor qatori 1, kitob 4, Q&A 1+1+2 | — |
| d033 | Xar xil kasalliklarda orqa miya suyuqligini laborator ko‘rsatkichlari | ~15 | analit 1, kitob 4, Q&A 1+1+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d034 | Attestatsiya 4. Umumklinik tekshiruv usullari modulidan | ~29 | analit 2, me’yor qatori 10, Q&A 2+6+3 | — |
| d035 | Sitologik tekshiruv usullari. Ayollar jinsiy a’zolari ajralmalarini mi | ~51 | analit 3, sitologiya 13, me’yor qatori 3, Q&A 4+6+3 | — |
| d036 | O‘smalar. O‘sma markerlari haqida umumiy ma’lumotlar. Yomon sifatli o‘ | ~41 | analit 5, Q&A 4+6+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d037 | Bachadon bo‘yinchasi va bachadon yomon sifatli o‘smalarining sitodiagn | ~37 | analit 2, sitologiya 7, me’yor qatori 1, Q&A 2+6+3 | — |
| d038 | Nafas organlari o‘smalari sitodiagnostikasi | ~19 | analit 1, kitob 2, Q&A 2+3+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q; curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d039 | Attestatsiya 5. Sitologik tekshiruv usullari modulidan | ~37 | analit 2, sitologiya 7, me’yor qatori 3, Q&A 2+6+3 | — |
| d040 | Klinik biokimyodan umumiy masalalar. Fizik-kimyoviy va kimyoviy usulla | ~8 | kitob 4, Q&A 0+0+1 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d041 | Mindray BA-88A bioximik yarim avtomat analizator ishlash prinsiplari.  | ~20 | kitob 2, Q&A 0+6+3 | — |
| d042 | Aminokislotalar klassifikatsiyasi. Oddiy va murakkab oqsillar | ~34 | analit 2, me’yor qatori 6, Q&A 4+6+3 | — |
| d043 | Pigmentlar almashinuvi. Bilirubin hosil bo‘lishi | ~43 | analit 2, holat 1, jadval 1, me’yor qatori 2, Q&A 5+6+3 | — |
| d044 | Uglevodlar, klassifikatsiyasi, biologik ahamiyati. Uglevodlarni oshqoz | ~29 | analit 1, me’yor qatori 5, kitob 6, Q&A 0+6+3 | — |
| d045 | Qandli diabet diagnostikasi | ~63 | analit 6, holat 3, me’yor qatori 10, Q&A 6+6+3 | — |
| d046 | Yog‘larning tuzilishi, klassifikatsiyasi va biologik roli | ~54 | analit 6, holat 1, me’yor qatori 6, Q&A 6+6+3 | — |
| d047 | Suv-tuz almashinuvi va uning buzilishi | ~52 | analit 6, me’yor qatori 7, kitob 3, Q&A 6+6+3 | — |
| d048 | Fermentlar, tuzilishi, klassifikatsiyasi | ~55 | analit 8, me’yor qatori 1, Q&A 6+6+3 | — |
| d049 | Jigar fermentlarini tekshirish | ~53 | analit 4, holat 2, jadval 1, Q&A 6+6+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d050 | Laktatdegidrogenaza, ishqoriy fosfataza fermentlarini tekshirish | ~32 | analit 2, Q&A 5+6+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d051 | Vitaminlar. Vitamin B12 va D larni tekshirishning klinik diagnostik ah | ~47 | analit 3, holat 2, hujayra 1, me’yor qatori 1, kitob 2, Q&A 4+6+1 | — |
| d052 | Vitaminlar. Vitamin B12 va D larni tekshirishning klinik diagnostik ah | ~45 | analit 3, holat 2, hujayra 1, me’yor qatori 1, Q&A 4+6+1 | — |
| d053 | Attestatsiya 6. Klinik biokimyodan umumiy masalalar modulidan | ~21 | me’yor qatori 10, kitob 2, Q&A 0+6+3 | — |
| d054 | Klinik biokimyo va biokimyoviy tekshiruv usullari. Umumiy oqsilni va a | ~34 | analit 2, me’yor qatori 6, Q&A 4+6+3 | — |
| d055 | Azotemiyalar. Klinik diagnostik ahamiyati | ~48 | analit 4, holat 1, me’yor qatori 3, Q&A 6+6+3 | — |
| d056 | Mochevinani aniqlash usullari. Klinik diagnostik ahamiyati | ~26 | analit 1, me’yor qatori 2, Q&A 2+6+3 | — |
| d057 | Kreatininni aniqlash usullari. Klinik diagnostik ahamiyati | ~27 | analit 2, me’yor qatori 3, Q&A 4+3+2 | — |
| d058 | Bilirubinni aniqlash usullari. Klinik diagnostik ahamiyati | ~43 | analit 2, holat 1, jadval 1, me’yor qatori 2, Q&A 5+6+3 | — |
| d059 | Glyukozani aniqlash usullari. Glyukoza tolerant testi. Klinik diagnost | ~39 | analit 2, holat 2, me’yor qatori 6, Q&A 2+6+3 | — |
| d060 | Glikozirlangan gemoglobinni aniqlash. Klinik diagnostik ahamiyati | ~25 | analit 2, me’yor qatori 3, Q&A 4+2+3 | — |
| d061 | Transaminazalar, amilazani aniqlash usullari. Klinik diagnostik ahamiy | ~47 | analit 4, holat 1, me’yor qatori 2, Q&A 6+6+3 | — |
| d062 | Ishqoriy fosfataza, γ-GT fermentlarini aniqlash usullari. Tekshirishni | ~37 | analit 2, holat 1, Q&A 5+6+2 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d063 | Kislota-asos muvozanati. Bufer sistemasi | ~22 | me’yor qatori 7, kitob 3, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d064 | Kislota-asos muvozanati. Bufer sistemasi (2-kun) | ~23 | me’yor qatori 7, kitob 4, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d065 | Umumiy xolesterinni aniqlash. Klinik diagnostik ahamiyati | ~48 | analit 4, holat 1, me’yor qatori 5, Q&A 6+6+3 | — |
| d066 | Triglitseridlarni aniqlash usullari. Klinik diagnostik ahamiyati | ~39 | analit 2, holat 2, me’yor qatori 2, Q&A 4+6+1 | — |
| d067 | Natriy, kaliy, kaltsiyni aniqlash usullari. Klinik diagnostik ahamiyat | ~42 | analit 3, holat 1, me’yor qatori 7, Q&A 6+5+3 | — |
| d068 | Temirni aniqlash usullari. Klinik diagnostik ahamiyati | ~43 | analit 3, holat 2, me’yor qatori 9, Q&A 2+6+3 | — |
| d069 | O‘tkir faza oqsillari | ~40 | analit 4, me’yor qatori 4, Q&A 5+4+3 | — |
| d070 | SRB, RF, ASLO aniqlash. Klinik diagnostik ahamiyati | ~31 | analit 4, holat 1, me’yor qatori 1, Q&A 4+1+1 | — |
| d071 | Miokard infarkti biokimyoviy markerlari va xavf omillari | ~55 | analit 5, holat 3, me’yor qatori 1, Q&A 6+6+2 | — |
| d072 | Podagra kasalligining laborator diagnostikasi. Siydik kislotasini aniq | ~26 | analit 1, holat 1, Q&A 2+6+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d073 | Gemostazning zamonaviy tasavvuri | ~63 | analit 7, holat 2, me’yor qatori 3, Q&A 6+6+3 | — |
| d074 | Attestatsiya 7. Klinik biokimyo va biokimyoviy tekshirish usullari mod | ~37 | analit 3, me’yor qatori 9, Q&A 4+6+3 | — |
| d075 | Turli kasalliklar laborator diagnostikasi. Qonning tomir ichida ivib q | ~50 | analit 5, holat 1, me’yor qatori 1, Q&A 6+5+2 | — |
| d076 | Allergik kasalliklar laborator diagnostikasi | ~28 | analit 1, hujayra 7, me’yor qatori 4, Q&A 2+3+2 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d077 | Jinsiy yo‘l bilan yuqadigan infeksiyalar laborator diagnostikasi. Vass | ~37 | analit 3, holat 1, sitologiya 8, Q&A 3+2+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d078 | Bezgak kasalligining laborator diagnostikasi | ~19 | analit 1, foto 2, me’yor qatori 1, kitob 3, Q&A 1+1+3 | — |
| d079 | OIV infeksiyasi. Klinik laborator tekshiruv usullari. Klinik diagnosti | ~22 | analit 1, holat 1, me’yor qatori 5, Q&A 1+3+3 | — |
| d080 | Parazitar kasalliklar laborator diagnostikasi. Dumaloq gijjalar labora | ~27 | analit 2, jadval 1, Q&A 2+2+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d081 | Lentasimon gijjalar laborator diagnostikasi. Klinik diagnostik ahamiya | ~23 | analit 1, jadval 1, kitob 4, Q&A 1+1+2 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d082 | So‘ruvchi gijjalar laborator diagnostikasi. Klinik diagnostik ahamiyat | ~29 | analit 1, jadval 1, Q&A 1+6+2 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d083 | TORCH infeksiyalar laborator diagnostikasi. Klinik diagnostik ahamiyat | ~18 | holat 1, kitob 3, Q&A 0+3+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d084 | Klinik laborator diagnostikada gematologik analizatorlar | ~36 | analit 4, me’yor qatori 14, Q&A 6+1+3 | — |
| d085 | Klinik laborator diagnostikada ECHT analizatorlar | ~19 | kitob 1, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d086 | Klinik laborator diagnostikada bioximik analizatorlar | ~20 | kitob 2, Q&A 0+6+3 | — |
| d087 | Klinik laborator diagnostikada urino analizatorlar | ~25 | analit 1, Q&A 2+6+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d088 | Klinik laborator diagnostikada koagulometrik analizatorlar | ~28 | analit 3, Q&A 6+0+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d089 | Attestatsiya 8. Turli kasalliklar laborator diagnostikasi modulidan | ~23 | analit 2, me’yor qatori 5, Q&A 2+3+3 | — |
| d090 | Umumiy qon tahlilini amaliyotda o‘zlashtirish | ~57 | analit 6, jadval 1, me’yor qatori 20, Q&A 6+6+3 | — |
| d091 | Kapillyar qon olish va gematologik tekshiruv uchun namuna tayyorlash | ~10 | protokol 1 | — |
| d092 | Gemoglobinni gemiglobintsianid usulida aniqlash | ~17 | protokol 1, analit 1 | — |
| d093 | Eritrotsitlarni sanoq kamerasida (Goryaev) sanash | ~16 | protokol 1, analit 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d094 | Leykotsitlarni sanoq kamerasida sanash va EChTni aniqlash | ~24 | protokol 2, analit 2 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d095 | Leykositar formulani amaliyotda o‘zlashtirish | ~78 | analit 5, hujayra 12, foto 8, me’yor qatori 9, Q&A 6+3+2 | — |
| d096 | Yupqa qon surtmasini tayyorlash va yaroqliligini baholash | ~12 | protokol 1, analit 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d097 | Surtmani qotirish va Romanovskiy–Gimza usulida bo‘yash | ~8 | protokol 1 | — |
| d098 | Leykotsitar formulani immersion mikroskopda sanash texnikasi | ~9 | protokol 1 | — |
| d099 | Me’yoriy leykotsitlarni aniqlash mezonlari (mikroskopik atlas bilan) | ~33 | protokol 1, analit 5, hujayra 7, foto 8 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d100 | Trombotsitlarni Fonio usulida sanash | ~16 | protokol 1, analit 1 | — |
| d101 | Umumiy siydik tahlilini amaliyotda o‘zlashtirish | ~38 | analit 2, foto 14, me’yor qatori 9, Q&A 4+5+3 | — |
| d102 | Siydikni yig‘ish, saqlash va fizik xossalarini aniqlash | ~9 | protokol 1 | — |
| d103 | Siydikni kimyoviy tekshirish: test-tilimchalar va sulfosalitsil sinama | ~14 | protokol 1, analit 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d104 | Siydik cho‘kmasi: preparat tayyorlash, hujayralar va silindrlar | ~11 | protokol 1, analit 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d105 | Siydik cho‘kmasi: kristallar, atlas va natijani izohlash | ~18 | protokol 1, foto 14 | — |
| d106 | Umumiy balg‘am tahlilini amaliyotda o‘zlashtirish | ~29 | analit 2, me’yor qatori 1, Q&A 2+6+3 | — |
| d107 | Balg‘amni yig‘ish va makroskopik ko‘rish | ~8 | protokol 1 | — |
| d108 | Balg‘amning nativ mikroskopiyasi va namuna sifati | ~7 | protokol 1 | — |
| d109 | Balg‘am surtmasini Gram usulida bo‘yash va ko‘rish | ~9 | protokol 1 | — |
| d110 | Sil–Nilsen usulida bo‘yash: kislotaga chidamli bakteriyalarni qidirish | ~10 | protokol 1, analit 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d111 | Urogenital surtmalar mikroskopiyasi: gonoreya va trixomoniaz | ~22 | protokol 1, analit 1, sitologiya 6 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d112 | Umumiy axlat (najas) tahlilini amaliyotda o‘zlashtirish | ~39 | analit 3, jadval 1, me’yor qatori 2, Q&A 2+6+3 | — |
| d113 | Najasning umumiy tahlili (koprogramma) | ~20 | protokol 1, analit 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d114 | Najasda sodda jonivorlar va gijja tuxumlarini aniqlash | ~29 | protokol 1, analit 1, jadval 1, foto 2 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d115 | Perianal namuna: ostritsa (Enterobius vermicularis) tuxumlarini aniqla | ~13 | protokol 1, analit 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d116 | Mindray BA-88A bioximik yarim avtomat analizator ishlash prinsiplari.  | ~20 | kitob 2, Q&A 0+6+3 | — |
| d117 | Zardob va plazma tayyorlash (biokimyoviy tekshiruv uchun) | ~11 | protokol 1 | — |
| d118 | Biokimyoviy fotometriya asoslari va reaktivlar to‘plami bilan ishlash | ~10 | protokol 1 | — |
| d119 | Yarim avtomat biokimyoviy analizator: test dasturi, kalibrovka va nazo | ~10 | protokol 1 | — |
| d120 | Qon zardobida glyukozani GOD–POD usulida aniqlash (qo‘lda va analizato | ~16 | protokol 1, analit 1 | — |
| d121 | Laktatdegidrogenaza, ishqoriy fosfataza fermentlar tekshiruvini amaliy | ~32 | analit 2, Q&A 5+6+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d122 | LDG va ishqoriy fosfataza: namuna, faollikni o‘lchash va natija talqin | ~11 | protokol 1, analit 2 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d123 | Alaninaminotransferaza (ALT) faolligini kinetik usulda aniqlash | ~16 | protokol 1, analit 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d124 | Qon zardobida mochevinani ureaza–GLDG usulida aniqlash | ~15 | protokol 1, analit 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d125 | Umumiy va bog‘langan bilirubinni diazo usulida aniqlash | ~22 | protokol 1, analit 2, jadval 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d126 | Biokimyoviy analitik seriyada nazorat materiali bilan ishlash | ~8 | protokol 2 | — |
| d127 | SRB, RF, ASLO lar tekshiruvini amaliyotda o‘zlashtirish | ~26 | analit 3, me’yor qatori 1, Q&A 3+3+1 | — |
| d128 | SRB, RF va ASLO: namuna, usul cheklovlari va natija talqini | ~14 | protokol 1, analit 3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d129 | Yallig‘lanish ko‘rsatkichlari: SRB va EChTni birga baholash | ~17 | protokol 1, analit 2, holat 1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d130 | Gemostaz tizimini tekshirish uchun qon olish va tayyorgarlik | ~9 | protokol 1 | — |
| d131 | Koagulogramma: PV/MNO, AChTV va fibrinogen natijalarini o‘qish | ~14 | analit 3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d132 | Venoz qon olish: probirkalar va yo‘llanma | ~6 | protokol 1 | — |
| d133 | Laboratoriyadan oldingi (preanalitik) omillar va namuna xatolari | ~7 | protokol 2 | — |
| d134 | Biologik material bilan xavfsiz ishlash va sanitar-epidemiologik tarti | ~11 | protokol 1 | — |
| d135 | Laboratoriya ichidagi sifat nazorati: bosqichlar va nazorat materiali | ~7 | protokol 1 | — |
| d136 | Nazorat kartasi (Levey–Jennings) va Westgard qoidalari bilan ishlash | ~5 | protokol 1 | — |
| d137 | Analitik va yakuniy bosqich xatolari; asbob parvarishi | ~6 | protokol 2 | — |
| d138 | Takrorlash: umumiy qon tahlili — sanash usullari va xatolar | ~12 | protokol 4 | — |
| d139 | Takrorlash: qon surtmasi, leykoformula va trombotsitlar | ~14 | protokol 3, foto 8 | — |
| d140 | Takrorlash: siydik va najas tahlili | ~9 | protokol 5 | — |
| d141 | Takrorlash: balg‘am, surtmalar va fotometrik biokimyoviy usullar | ~10 | protokol 6 | — |
| d142 | Yakuniy attestatsiyaga tayyorgarlik: amaliy ko‘nikmalar va xavfsizlik | ~6 | protokol 2 | — |
| d143 | Attestatsiya. Laborator tekshiruv usullarini amaliyotda o‘zlashtirish  | ~21 | me’yor qatori 2, kitob 2, Q&A 0+6+3 | — |

## Deck yo‘q mavzular (kontent topilmadi)

Bu kunlarda `links` bo‘sh yoki bog‘langan kontent yo‘q — slayd o‘ylab topilmadi.

| Kun | Mavzu (uz) | Sabab |
|---|---|---|


## Amaliy mashg‘ulot protokollari (alohida to‘plam)

M9 modulining amaliy kunlari (`d091`–`d142`) manbalarda bir xil umumiy nomda: dastur hujjati (`КЛД_ихтисослаштириш_864_кредит`: M9 — 324 soat, shundan ma’ruza 48, laboratoriya ishi 276; mavzu yoki texnika ro‘yxati yo‘q) va dars jadvallari bu kunlarda **kunma-kun mavzu ko‘rsatmaydi** — aniq mavzu faqat ma’ruza kunlarida (d090, d095, d101, d106, d112, d116, d121, d127). Protokollar texnika nomi bilan alohida to‘plamda qoladi; D-67 dan boshlab ular **LabGuide tavsiya etgan amaliy reja** (manbadagi moslik emas, tavsiya; `docs/M9_PRACTICAL_TOPICS.md`) orqali M9 kunlariga `links.protocols` bilan bog‘langan va o‘sha kunlarning decklarida «Kun rejasi» slaydidan keyin chiqadi.

Qoidalar: matn kitoblardan o‘z so‘zim bilan; har slaydda muallif + qisqa nom + bo‘lim/sahifa; oxirgi slayd — “Adabiyotlar”. Son, hajm, vaqt va konsentratsiya faqat manbada ko‘ringan joyda (sahifasi bilan); manbalar bir-biriga zid bo‘lsa — yangi/ishonchlisi yoki umuman olinmagan; eskirgan/xavfli usullar olinmagan. Faqat mavjud rasmlar (`assets/microscopy`) ishlatilgan (atlasda najas va balg‘am fotolari yo‘q — o‘sha protokollarda rasm slaydi yo‘q). “Qin tozalik darajalari” jadvali yuqoridagi sitologiya mavzu decklarida manbasi yo‘qligi uchun yo‘q; u faqat shu to‘plamdagi urogenital protokolda, Kurbonova (2023, 70-b.) manbasi bilan berilgan.

Kurs kitoblarida usuli yo‘q 19 ta test (kreatinin … D vitamini; `docs/PROTOCOLS_COVERAGE.md`) protokollari ishlab chiqaruvchi o‘z saytida ochiq e’lon qilgan **to‘plam yo‘riqnomasi (IFU)** asosida yozilgan: 18 tasi SPINREACT, D vitamini — Immusmol ELISA IFU si. Har protokol bitta to‘plamga tayanadi va birinchi slaydda «misol sifatida shu IFU; laboratoriya to‘plami IFU si ustun» deb aytadi; har sondagi qiymat IFU sahifasidan (so‘zma-so‘z parchalar — `tool/slides/data/ifu_source_excerpts.json`, tekshiruv — `tool/slides/test_ifu_protocols.py`).

| Texnika (uz) | Guruh | Slayd (uz) | Manbalar |
|---|---|---|---|
| Kapillyar qon olish va gematologik tekshiruv uchun namuna tayyorlash | Gematologiya | 9 | 5 |
| Gemoglobinni gemiglobintsianid (sianmetgemoglobin) usulida aniqlash | Gematologiya | 12 | 2 |
| Eritrotsitlarni sanoq kamerasida (Goryaev) sanash | Gematologiya | 10 | 2 |
| Leykotsitlarni sanoq kamerasida sanash | Gematologiya | 10 | 2 |
| Eritrotsitlarning cho‘kish tezligini (EChT) aniqlash | Gematologiya | 8 | 2 |
| Yupqa qon surtmasini tayyorlash, qotirish va Romanovskiy–Gimza usulida bo‘yash | Gematologiya | 11 | 2 |
| Leykotsitar formulani mikroskopda sanash (immersiya) | Gematologiya | 14 | 7 |
| Siydikni yig‘ish, saqlash va fizik xossalarini aniqlash | Umumklinik tekshiruvlar · siydik | 8 | 4 |
| Siydikni kimyoviy tekshirish: test-tilimchalar va sulfosalitsil sinamasi | Umumklinik tekshiruvlar · siydik | 10 | 3 |
| Siydik cho‘kmasini mikroskopda tekshirish | Umumklinik tekshiruvlar · siydik | 13 | 9 |
| Najasning umumiy tahlili (koprogramma) | Umumklinik tekshiruvlar · najas va parazitologiya | 16 | 3 |
| Najasda sodda jonivorlar va gijja tuxumlarini aniqlash | Umumklinik tekshiruvlar · najas va parazitologiya | 17 | 2 |
| Perianal burmalardan namuna: ostritsa (Enterobius vermicularis) tuxumlari | Umumklinik tekshiruvlar · najas va parazitologiya | 9 | 2 |
| Balg‘amni yig‘ish, ko‘rish va nativ mikroskopiya | Umumklinik va mikrobiologik tekshiruvlar · balg‘am, surtmalar | 10 | 4 |
| Balg‘am surtmasini Gram va Sil–Nilsen usullarida bo‘yash | Umumklinik va mikrobiologik tekshiruvlar · balg‘am, surtmalar | 11 | 3 |
| Urogenital surtmalar mikroskopiyasi: gonoreya va trixomoniaz | Umumklinik va mikrobiologik tekshiruvlar · balg‘am, surtmalar | 12 | 3 |
| Zardob va plazma tayyorlash (biokimyoviy tekshiruv uchun) | Klinik biokimyo · fotometrik usullar | 10 | 1 |
| Biokimyoviy fotometriya asoslari va to‘plam bilan ishlash tartibi | Klinik biokimyo · fotometrik usullar | 9 | 1 |
| Yarim avtomat biokimyoviy analizatorda ishlash: test dasturi, kalibrovka, nazorat | Klinik biokimyo · fotometrik usullar | 9 | 1 |
| Qon zardobida glyukozani fotometrik aniqlash (GOD-POD) | Klinik biokimyo · fotometrik usullar | 11 | 2 |
| Alaninaminotransferaza (ALT) faolligini kinetik aniqlash | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Qon zardobida mochevinani fermentativ aniqlash (ureaza–GLDG) | Klinik biokimyo · fotometrik usullar | 11 | 1 |
| Umumiy va bog‘langan bilirubinni diazo usulida aniqlash | Klinik biokimyo · fotometrik usullar | 11 | 1 |
| Gemostaz tizimini tekshirish uchun qon olish va tayyorgarlik | Gematologiya · gemostaz | 8 | 2 |
| Trombotsitlarni Fonio usulida sanash | Gematologiya · gemostaz | 9 | 3 |
| Laboratoriya ichidagi sifat nazorati: bosqichlar va nazorat materiali | Laboratoriya tartibi · sifat va xavfsizlik | 10 | 1 |
| Biologik material bilan xavfsiz ishlash va sanitar-epidemiologik tartib | Laboratoriya tartibi · sifat va xavfsizlik | 10 | 3 |
| Kreatinin: Yaffe kinetik usuli (ishqoriy pikrat) | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Umumiy oqsil: biuret usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Albumin: bromkrezol yashili (BCG) usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Umumiy xolesterin: CHOD-PAP (CHOD-POD) fermentativ usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Triglitseridlar: GPO-PAP (GPO-POD) fermentativ usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| YZLP xolesterini (HDL-C): to‘g‘ridan-to‘g‘ri fermentativ usul | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Aspartataminotransferaza (AST): kinetik UV usuli (IFCC tavsiyasi) | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Ishqoriy fosfataza (IF): p-nitrofenilfosfat kinetik usuli (DGKC) | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Gamma-glutamiltransferaza (GGT): kinetik usul (karboksi substrat) | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| α-amilaza: CNPG3 kinetik usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Siydik kislotasi: urikaza-PAP (urikaza-POD) usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Kalsiy: arsenazo III usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Zardob temiri: ferrozin usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Noorganik fosfor (fosfat): fosfomolibdat UV usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| Magniy: ksilidil ko‘ki usuli | Klinik biokimyo · fotometrik usullar | 12 | 2 |
| C-reaktiv oqsil (CRB): lateks-agglyutinatsiya sinamasi | Klinik immunologiya · lateks-agglyutinatsiya | 11 | 2 |
| Revmatoid omil (RF): lateks-agglyutinatsiya sinamasi | Klinik immunologiya · lateks-agglyutinatsiya | 11 | 2 |
| Antistreptolizin O (ASLO): lateks-agglyutinatsiya sinamasi | Klinik immunologiya · lateks-agglyutinatsiya | 11 | 2 |
| D vitamini (25-OH D umumiy): raqobatli ELISA | Klinik immunologiya · immunoferment tahlil (ELISA) | 13 | 1 |

### Manbalarda bor, lekin olinmagan

- Dastur va dars jadvallari M9 amaliy kunlarida kunma-kun mavzu yoki texnikani ko‘rsatmaydi — texnikalar kunlarga manba asosida biriktirilmadi; bog‘lanish faqat LabGuide tavsiya etgan amaliy reja sifatida (D-67).
- Najas: yashirin qon uchun gvayak (efir bilan), benzidin, Gregersen va amidopirin (piramidon) sinamalari hamda sterkobilin uchun sulema (simob xloridi) bilan Shmidt reaksiyasi olinmagan — yonuvchan efir, zaharli simob tuzi va eskirgan reaktivlar (Kurbonova, 42–43-b.; Aripova, 137-b.). Faqat tayyorgarlik qoidalari berilgan.
- Siydik: qaynatish sinamasi (Aripova xavfli deb tavsiya etmaydi), issiq konsentrlangan reaktivlar, ammiak, nitroprussid yoki temir xlorid bilan klassik sinamalar (Geller, Gaynes, Lange, Garrison) va pH uchun metilen ko‘ki kabi eski usullar olinmagan.
- Gemoglobin: Sali usuli standartlashmagani va hozir klinikada tavsiya etilmagani uchun olinmagan (Aripov va b., 2006).
- Zardob ajratish: zardob ajralishini tezlatish uchun probirka devori bo‘ylab tayoqcha yurgizish (qo‘llanmada bor) gemolizni oshirishi mumkin bo‘lgani uchun olinmagan.
- ALT: Aripova kitobidagi 2,4-dinitrofenilgidrazinli kolorimetrik usul (eskirgan) olinmagan; kinetik usul berilgan.
- Birinchi yordam: 2006 yilgi qo‘llanmadagi “jarohatni 70% spirt yoki yod bilan dezinfeksiya qilish” tavsiyasi olinmagan — Kurbonova (2023) kuchli moddalarni qo‘llashni taqiqlaydi; yangiroq manba tanlandi.
- Zaxm uchun Vasserman reaksiyasi (eskirgan serologik sinama) va oq treponemani qora maydonda ko‘rish usuli; xlamidioz (surtma emas, qirma olinadi) olinmagan.
- Sil–Nilsen bilan bo‘yalgan surtmani o‘qish (rang, baholash, hisoblash) manbada yo‘q; Gram safranin vaqti Aripova matnida «30–60 daqiqa» deb bosilgan (aniq xato) — ikkalasi ham to‘qib chiqarilmadi, laboratoriya yo‘riqnomasiga havola berildi.
- Najas tahlili: namuna topshirish muddati manbalarda har xil (Kurbonova 8–12 soat; Aripov va b. 10–12 soat, muzlatgichda) — ikkala qiymat ochiq ko‘rsatilgan; qin tozalik darajalari jadvalidagi III daraja matni Kurbonovada noaniq berilgani uchun izohlab qisqartirilgan.
- O‘qib bo‘lmagan manbalar: Sultonov .doc va likvor (CSF) hujjati skaner qilingan (matn qatlami yo‘q), “Sil kasalligida laborator tekshiruv usullari” materiali KDL / KDL WORD papkalarida topilmadi — ular asosida hech narsa yozilmadi.
- Xalqaro manba bilan tasdiqlanmagan eski kitob raqamlari olib tashlandi (tibbiy audit, 2026-10-17): gemostaz uchun qonni 45 daqiqada yetkazish, trombotsitlar me’yori 180–320 × 10⁹/l, “birlamchi trombotsitoz — 400 dan ortiq”, “klinik belgilar 70 dan past / 700–900 da” (Kurbonova, 98–102-b.); igna qalpoqchasini kiydirish, qo‘l yuvish 10–15 soniya, postkontakt profilaktika “2 dan 72 soatgacha” va “ko‘zga sachraganda kontakt linzani olmang” JSST 2010 bo‘yicha almashtirildi.
