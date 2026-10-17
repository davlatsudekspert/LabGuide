# Taqdimotlar qamrovi (mavzu bo‘yicha PPTX)

Avtomatik: `python3 tool/slides/make_topic_decks.py --all --dry-run --report docs/DECKS_COVERAGE.md`. Qo‘lda tahrirlamang.

Tillar: uz, ru, en. Bitta deck = bitta o‘quv kuni (amaliy + ma’ruza bir xil havolalarga ega, `dNNN-P` va `dNNN-L` bitta fayl). Kunlar: 143; deck: 98; kontentsiz (deck yo‘q): 45.

## Rasm va jadvallarni mavzuga bog‘lash qoidasi

- **Analit/holat kartalari** — `links.analytes` / `links.conditions` (pack.json); har analit: maqsad+fiziologiya, me’yor/qaror chegaralari (faqat kartada `decision_limits`/`treatment_goals` bo‘lsa), oshishi/pasayishi, preanalitika.
- **Me’yoriy qiymatlar (toifa bankidan)** — mavzuning og‘zaki savollaridagi `reference`/`cutoffs` qatorlari (manbali).
- **Jadvallar** — `links.reference` (anemiya algoritmi, soxta natijalar, sariqlik, jigar sindromlari, najas parazitlari).
- **Leykoformula hujayralari (sxema)** — 7 asosiy hujayra: `/lab/calculators/differential` vositasi yoki neytrofil/limfotsit/monotsit/eozinofil/bazofil analiti bor mavzularda; reaktiv limfotsit va toksik neytrofil — faqat differential vositali mavzularda; gipersegmentlangan neytrofil — B12/foliy/MMA analitli yoki sarlavhada “B-12”; blast — sarlavhada “leykoz” (surunkali leykozlardan tashqari); smudge hujayra — sarlavhada “limfoleykoz”. Adashtiriladigan juftliklar, talqin, surtma texnikasi va misol oraliqlari — differential vositali mavzularda.
- **Sitologiya sxemalari** — `pap-test` → epiteliy hujayralari + Bethesda jadvali; `vaginal-wet-mount` → flora/yallig‘lanish sxemalari; `pap-test` yoki `hpv-test` → koilotsit, HSIL; surtma olish va bo‘yash — pap-test va vaginal-wet-mount birga bo‘lgan mavzuda. “Qin surtmasi tozalik darajalari” jadvali manbasi yo‘qligi uchun kiritilmagan.
- **Darslik bo‘yicha qisqa mazmun** — `tool/slides/data/books_extra.json`: ustoz kitoblaridan o‘z so‘zim bilan (Aripova va b., 2007: d044, d047, d051, d052 — sahifalar bilan; Najmitdinov, 1998: d010, d017, d018 — elektron matnda sahifa raqami yo‘q, bo‘lim nomi bilan). Yupqa kunlar uchun qo‘shimcha (d001–d006, d009, d010, d019, d020, d032, d033, d038, d040, d041, d053, d063, d064, d078, d081, d083, d085, d086, d116, d143): Aripov va b., 2006; Yusupova va b., 2022 va Kurbonova, 2023 (bosma sahifa raqami bilan); Agzamxodjaev va b., 2016; muallifi/yili ko‘rsatilmagan ma’ruza matnlari (shunday belgilangan). Matn/rasm ko‘chirilmagan; kitobdagi eskirgan yoki o‘zaro zid raqamlar olinmagan. Kitoblar Drive MCP orqali o‘qildi; Najmitdinov matni dastlab leykoz bobining oxirida (sitokimyo) kesilgan edi, to‘liq matn keyin .doc orqali tiklandi (d021/d022 uchun kitob mazmuni hali qo‘shilmagan; surunkali mieloleykozning klinik bo‘limi manbada shikastlangan). Axloq/deontologiya (d001, d004), TORCH (d083, toksoplazmadan tashqari), SOE analizatorlari (d085) va Mindray (d041, d116) bo‘yicha o‘qiladigan manba topilmadi. DjVu atlaslar, Hodjibekov va Sultonov (o‘qib bo‘lmaydi) olinmadi.
- **Mikroskopik atlas fotolari** — `links.microscopy` (urine / blood / parasites); litsenziya va muallif har slaydda va “Adabiyotlar”da.
- **Savol-javob** — curriculum nomzodlari (yo‘q bo‘lsa ilovadagi kabi analit/toifa mavzusi bo‘yicha): paket mashq savollari (manbasizlari tashlanadi), toifa testlari (faqat kaliti aniq: verdict `ok`, bitta javob, `unverified` emas), og‘zaki savollar (javob rejasi). Chegara: {'quiz': 6, 'test': 6, 'oral': 3}.
- `bloodgroup/card.png` va `spermogram/card.png` — hech bir curriculum mavzusiga bog‘lanmagan (havolalarda yo‘q), shuning uchun ishlatilmadi.

## Deck bor mavzular

| Kun | Mavzu (uz) | Slayd (PPTX, uz; ~ — taxminiy) | Kontent | Yetishmaydi |
|---|---|---|---|---|
| d001 | Laborator xizmatni tashkillashtirish. Tibbiy etika va deontologiya. Ma | 22 | kitob 6, Q&A 0+0+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d002 | O‘zbekistonda klinik biokimyoviy laboratoriyalarni rivojlantirishning  | 29 | me’yor qatori 2, kitob 3, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d003 | Laboratoriya ichida va laboratoriyalar oro o‘tkaziladigan sifat nazora | 30 | me’yor qatori 2, kitob 4, Q&A 0+6+3 | — |
| d004 | Attestatsiya 1. Laborator xizmatni tashkillashtirish. Tibbiy etika va  | 28 | me’yor qatori 2, kitob 2, Q&A 0+6+3 | — |
| d005 | Odam ichki a’zolari tuzilishi va vazifalari. To‘qimalar klassifikatsiy | 13 | kitob 5 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d006 | Biriktiruvchi to‘qimaning morfofunksional xarakteristikasi | 6 | kitob 2 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d007 | Jigar kasalliklarining laborator ko‘rsatkichlari | 92 | analit 7, holat 4, jadval 2, me’yor qatori 2, Q&A 6+6+3 | — |
| d008 | Buyrak va siydik yo‘llari kasalliklarining laborator ko‘rsatkichlari | 103 | analit 7, holat 3, me’yor qatori 10, Q&A 6+6+3 | — |
| d009 | Attestatsiya 2. Odam ichki a’zolari tuzilishi va vazifalari modulidan | 29 | me’yor qatori 10, kitob 2, Q&A 0+6+3 | — |
| d010 | Qon ishlab chiqarishning zamonaviy nazariyasi. Eritropoez, leykopoez,  | 37 | analit 1, me’yor qatori 10, kitob 5, Q&A 3+1+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d011 | Qon shaklli elementlari sonini sanash. Gemoglobinni aniqlash | 77 | analit 5, jadval 1, me’yor qatori 16, Q&A 6+6+3 | — |
| d012 | Leykositar formula uchun material olish va ularni sanash. Mieloid, lim | 107 | analit 7, hujayra 12, foto 8, me’yor qatori 9, Q&A 6+6+3 | — |
| d013 | Anemiyalar. Klassifikatsiyasi, etiologiyasi va patogenezi | 90 | analit 7, holat 1, jadval 1, me’yor qatori 12, Q&A 6+5+3 | — |
| d014 | Temir tanqisligi bilan kechadigan anemiyalar. Suyak ko‘migi va perifer | 97 | analit 6, holat 1, jadval 1, foto 8, me’yor qatori 9, Q&A 6+6+3 | — |
| d015 | Vit. B-12 yetishmasligi bilan bog‘liq kamqonliklar. Suyak ko‘migi va p | 77 | analit 5, holat 1, jadval 1, hujayra 1, me’yor qatori 4, Q&A 5+6+3 | — |
| d016 | Gemolitik kamqonliklar. Klinik-laborator ko‘rsatkichlari. Suyak ko‘mig | 75 | analit 5, holat 2, jadval 1, me’yor qatori 2, Q&A 6+4+3 | — |
| d017 | Leykozlar, etiologiyasi, patogenezi va klassifikatsiya | 43 | analit 2, hujayra 1, me’yor qatori 3, kitob 3, Q&A 3+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d018 | O‘tkir leykozlar. O‘tkir leykozlarda suyak ko‘migi va periferik qon ko | 34 | analit 1, hujayra 1, me’yor qatori 3, kitob 2, Q&A 1+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d019 | Surunkali leykozlar. Suyak ko‘migi va periferik qon ko‘rinishi | 28 | me’yor qatori 3, kitob 3, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d020 | Surunkali mieloleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | 10 | kitob 2, Q&A 0+1+1 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d021 | Surunkali limfoleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | 30 | analit 1, hujayra 8, me’yor qatori 1, Q&A 2+1+1 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d022 | Mielom kasalligida suyak ko‘migi va periferik qon ko‘rinishi | 29 | analit 2, me’yor qatori 1, Q&A 4+3+1 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d023 | Attestatsiya 3. Gematologik tekshiruv usullari modulidan | 44 | analit 1, me’yor qatori 27, Q&A 2+6+3 | — |
| d024 | Oshqozon va o‘t suyuqligini mikroskopik tekshirish kasalliklarining kl | 24 | analit 1, Q&A 1+6+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q; curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d025 | Najasni mikroskopik tekshirish. Klinik diagnostik ahamiyati | 64 | analit 4, jadval 1, me’yor qatori 2, Q&A 3+6+3 | — |
| d026 | Najasni mikroskopik tekshirish. Klinik diagnostik ahamiyati (2-kun) | 57 | analit 3, jadval 1, me’yor qatori 2, Q&A 2+6+3 | — |
| d027 | Siydikni tekshirish. Klinik diagnostik ahamiyati | 88 | analit 5, foto 14, me’yor qatori 9, Q&A 6+6+3 | — |
| d028 | Siydikni tekshirish. Klinik diagnostik ahamiyati (2-kun) | 88 | analit 5, foto 14, me’yor qatori 9, Q&A 6+6+3 | — |
| d029 | Bronxial astma, pnevmoniya, bronxit va boshqa nafas yo‘llari kasallikl | 38 | analit 2, me’yor qatori 1, Q&A 2+6+3 | — |
| d030 | Sil kasalligida balg‘amni tekshirish va uning klinik diagnostik ahamiy | 38 | analit 2, me’yor qatori 1, Q&A 2+6+3 | — |
| d031 | Sil kasalligida balg‘amni tekshirish va uning klinik diagnostik ahamiy | 38 | analit 2, me’yor qatori 1, Q&A 2+6+3 | — |
| d032 | Transsudat va ekssudatlarni tekshirishning klinik diagnostikasi | 29 | analit 2, me’yor qatori 1, kitob 4, Q&A 1+1+2 | — |
| d033 | Xar xil kasalliklarda orqa miya suyuqligini laborator ko‘rsatkichlari | 22 | analit 1, kitob 4, Q&A 1+1+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d034 | Attestatsiya 4. Umumklinik tekshiruv usullari modulidan | 48 | analit 2, me’yor qatori 10, Q&A 2+6+3 | — |
| d035 | Sitologik tekshiruv usullari. Ayollar jinsiy a’zolari ajralmalarini mi | 73 | analit 3, sitologiya 13, me’yor qatori 3, Q&A 4+6+3 | — |
| d036 | O‘smalar. O‘sma markerlari haqida umumiy ma’lumotlar. Yomon sifatli o‘ | 59 | analit 5, Q&A 4+6+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d037 | Bachadon bo‘yinchasi va bachadon yomon sifatli o‘smalarining sitodiagn | 51 | analit 2, sitologiya 7, me’yor qatori 1, Q&A 2+6+3 | — |
| d038 | Nafas organlari o‘smalari sitodiagnostikasi | 27 | analit 1, kitob 2, Q&A 2+3+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q; curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d039 | Attestatsiya 5. Sitologik tekshiruv usullari modulidan | 51 | analit 2, sitologiya 7, me’yor qatori 3, Q&A 2+6+3 | — |
| d040 | Klinik biokimyodan umumiy masalalar. Fizik-kimyoviy va kimyoviy usulla | 13 | kitob 4, Q&A 0+0+1 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d041 | Mindray BA-88A bioximik yarim avtomat analizator ishlash prinsiplari.  | 24 | kitob 2, Q&A 0+6+3 | — |
| d042 | Aminokislotalar klassifikatsiyasi. Oddiy va murakkab oqsillar | 41 | analit 2, me’yor qatori 6, Q&A 4+6+3 | — |
| d043 | Pigmentlar almashinuvi. Bilirubin hosil bo‘lishi | 53 | analit 2, holat 1, jadval 1, me’yor qatori 2, Q&A 5+6+3 | — |
| d044 | Uglevodlar, klassifikatsiyasi, biologik ahamiyati. Uglevodlarni oshqoz | 40 | analit 1, me’yor qatori 5, kitob 6, Q&A 0+6+3 | — |
| d045 | Qandli diabet diagnostikasi | 83 | analit 6, holat 3, me’yor qatori 10, Q&A 6+6+3 | — |
| d046 | Yog‘larning tuzilishi, klassifikatsiyasi va biologik roli | 74 | analit 6, holat 1, me’yor qatori 6, Q&A 6+6+3 | — |
| d047 | Suv-tuz almashinuvi va uning buzilishi | 69 | analit 6, me’yor qatori 7, kitob 3, Q&A 6+6+3 | — |
| d048 | Fermentlar, tuzilishi, klassifikatsiyasi | 72 | analit 8, me’yor qatori 1, Q&A 6+6+3 | — |
| d049 | Jigar fermentlarini tekshirish | 65 | analit 4, holat 2, jadval 1, Q&A 6+6+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d050 | Laktatdegidrogenaza, ishqoriy fosfataza fermentlarini tekshirish | 39 | analit 2, Q&A 5+6+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d051 | Vitaminlar. Vitamin B12 va D larni tekshirishning klinik diagnostik ah | 60 | analit 3, holat 2, hujayra 1, me’yor qatori 1, kitob 2, Q&A 4+6+1 | — |
| d052 | Vitaminlar. Vitamin B12 va D larni tekshirishning klinik diagnostik ah | 57 | analit 3, holat 2, hujayra 1, me’yor qatori 1, Q&A 4+6+1 | — |
| d053 | Attestatsiya 6. Klinik biokimyodan umumiy masalalar modulidan | 31 | me’yor qatori 10, kitob 2, Q&A 0+6+3 | — |
| d054 | Klinik biokimyo va biokimyoviy tekshiruv usullari. Umumiy oqsilni va a | 41 | analit 2, me’yor qatori 6, Q&A 4+6+3 | — |
| d055 | Azotemiyalar. Klinik diagnostik ahamiyati | 66 | analit 4, holat 1, me’yor qatori 3, Q&A 6+6+3 | — |
| d056 | Mochevinani aniqlash usullari. Klinik diagnostik ahamiyati | 31 | analit 1, me’yor qatori 2, Q&A 2+6+3 | — |
| d057 | Kreatininni aniqlash usullari. Klinik diagnostik ahamiyati | 39 | analit 2, me’yor qatori 3, Q&A 4+3+2 | — |
| d058 | Bilirubinni aniqlash usullari. Klinik diagnostik ahamiyati | 53 | analit 2, holat 1, jadval 1, me’yor qatori 2, Q&A 5+6+3 | — |
| d059 | Glyukozani aniqlash usullari. Glyukoza tolerant testi. Klinik diagnost | 49 | analit 2, holat 2, me’yor qatori 6, Q&A 2+6+3 | — |
| d060 | Glikozirlangan gemoglobinni aniqlash. Klinik diagnostik ahamiyati | 34 | analit 2, me’yor qatori 3, Q&A 4+2+3 | — |
| d061 | Transaminazalar, amilazani aniqlash usullari. Klinik diagnostik ahamiy | 57 | analit 4, holat 1, me’yor qatori 2, Q&A 6+6+3 | — |
| d062 | Ishqoriy fosfataza, γ-GT fermentlarini aniqlash usullari. Tekshirishni | 43 | analit 2, holat 1, Q&A 5+6+2 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d063 | Kislota-asos muvozanati. Bufer sistemasi | 30 | me’yor qatori 7, kitob 3, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d064 | Kislota-asos muvozanati. Bufer sistemasi (2-kun) | 32 | me’yor qatori 7, kitob 4, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d065 | Umumiy xolesterinni aniqlash. Klinik diagnostik ahamiyati | 62 | analit 4, holat 1, me’yor qatori 5, Q&A 6+6+3 | — |
| d066 | Triglitseridlarni aniqlash usullari. Klinik diagnostik ahamiyati | 42 | analit 2, holat 2, me’yor qatori 2, Q&A 4+6+1 | — |
| d067 | Natriy, kaliy, kaltsiyni aniqlash usullari. Klinik diagnostik ahamiyat | 55 | analit 3, holat 1, me’yor qatori 7, Q&A 6+5+3 | — |
| d068 | Temirni aniqlash usullari. Klinik diagnostik ahamiyati | 60 | analit 3, holat 2, me’yor qatori 9, Q&A 2+6+3 | — |
| d069 | O‘tkir faza oqsillari | 57 | analit 4, me’yor qatori 4, Q&A 5+4+3 | — |
| d070 | SRB, RF, ASLO aniqlash. Klinik diagnostik ahamiyati | 41 | analit 4, holat 1, me’yor qatori 1, Q&A 4+1+1 | — |
| d071 | Miokard infarkti biokimyoviy markerlari va xavf omillari | 69 | analit 5, holat 3, me’yor qatori 1, Q&A 6+6+2 | — |
| d072 | Podagra kasalligining laborator diagnostikasi. Siydik kislotasini aniq | 29 | analit 1, holat 1, Q&A 2+6+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d073 | Gemostazning zamonaviy tasavvuri | 89 | analit 7, holat 2, me’yor qatori 3, Q&A 6+6+3 | — |
| d074 | Attestatsiya 7. Klinik biokimyo va biokimyoviy tekshirish usullari mod | 51 | analit 3, me’yor qatori 9, Q&A 4+6+3 | — |
| d075 | Turli kasalliklar laborator diagnostikasi. Qonning tomir ichida ivib q | 71 | analit 5, holat 1, me’yor qatori 1, Q&A 6+5+2 | — |
| d076 | Allergik kasalliklar laborator diagnostikasi | 33 | analit 1, hujayra 7, me’yor qatori 4, Q&A 2+3+2 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d077 | Jinsiy yo‘l bilan yuqadigan infeksiyalar laborator diagnostikasi. Vass | 58 | analit 3, holat 1, sitologiya 8, Q&A 3+2+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d078 | Bezgak kasalligining laborator diagnostikasi | 24 | analit 1, foto 2, me’yor qatori 1, kitob 3, Q&A 1+1+3 | — |
| d079 | OIV infeksiyasi. Klinik laborator tekshiruv usullari. Klinik diagnosti | 30 | analit 1, holat 1, me’yor qatori 5, Q&A 1+3+3 | — |
| d080 | Parazitar kasalliklar laborator diagnostikasi. Dumaloq gijjalar labora | 40 | analit 2, jadval 1, Q&A 2+2+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d081 | Lentasimon gijjalar laborator diagnostikasi. Klinik diagnostik ahamiya | 38 | analit 1, jadval 1, kitob 4, Q&A 1+1+2 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d082 | So‘ruvchi gijjalar laborator diagnostikasi. Klinik diagnostik ahamiyat | 38 | analit 1, jadval 1, Q&A 1+6+2 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d083 | TORCH infeksiyalar laborator diagnostikasi. Klinik diagnostik ahamiyat | 26 | holat 1, kitob 3, Q&A 0+3+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d084 | Klinik laborator diagnostikada gematologik analizatorlar | 52 | analit 4, me’yor qatori 14, Q&A 6+1+3 | — |
| d085 | Klinik laborator diagnostikada ECHT analizatorlar | 22 | kitob 1, Q&A 0+6+3 | curriculum: gap bayrog‘i (havolalar yetarli emas) |
| d086 | Klinik laborator diagnostikada bioximik analizatorlar | 24 | kitob 2, Q&A 0+6+3 | — |
| d087 | Klinik laborator diagnostikada urino analizatorlar | 37 | analit 1, Q&A 2+6+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d088 | Klinik laborator diagnostikada koagulometrik analizatorlar | 41 | analit 3, Q&A 6+0+3 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d089 | Attestatsiya 8. Turli kasalliklar laborator diagnostikasi modulidan | 37 | analit 2, me’yor qatori 5, Q&A 2+3+3 | — |
| d090 | Umumiy qon tahlilini amaliyotda o‘zlashtirish | 84 | analit 6, jadval 1, me’yor qatori 20, Q&A 6+6+3 | — |
| d095 | Leykositar formulani amaliyotda o‘zlashtirish | 90 | analit 5, hujayra 12, foto 8, me’yor qatori 9, Q&A 6+3+2 | — |
| d101 | Umumiy siydik tahlilini amaliyotda o‘zlashtirish | 64 | analit 2, foto 14, me’yor qatori 9, Q&A 4+5+3 | — |
| d106 | Umumiy balg‘am tahlilini amaliyotda o‘zlashtirish | 38 | analit 2, me’yor qatori 1, Q&A 2+6+3 | — |
| d112 | Umumiy axlat (najas) tahlilini amaliyotda o‘zlashtirish | 57 | analit 3, jadval 1, me’yor qatori 2, Q&A 2+6+3 | — |
| d116 | Mindray BA-88A bioximik yarim avtomat analizator ishlash prinsiplari.  | 24 | kitob 2, Q&A 0+6+3 | — |
| d121 | Laktatdegidrogenaza, ishqoriy fosfataza fermentlar tekshiruvini amaliy | 39 | analit 2, Q&A 5+6+1 | me’yor/qaror chegaralari: kartalarda ham, toifa bankida ham yo‘q |
| d127 | SRB, RF, ASLO lar tekshiruvini amaliyotda o‘zlashtirish | 34 | analit 3, me’yor qatori 1, Q&A 3+3+1 | — |
| d143 | Attestatsiya. Laborator tekshiruv usullarini amaliyotda o‘zlashtirish  | 27 | me’yor qatori 2, kitob 2, Q&A 0+6+3 | — |

## Deck yo‘q mavzular (kontent topilmadi)

Bu kunlarda `links` bo‘sh yoki bog‘langan kontent yo‘q — slayd o‘ylab topilmadi.

| Kun | Mavzu (uz) | Sabab |
|---|---|---|
| d091 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d092 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d093 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d094 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d096 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d097 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d098 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d099 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d100 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d102 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d103 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d104 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d105 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d107 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d108 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d109 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d110 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d111 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d113 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d114 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d115 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d117 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d118 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d119 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d120 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d122 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d123 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d124 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d125 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d126 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d128 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d129 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d130 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d131 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d132 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d133 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d134 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d135 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d136 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d137 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d138 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d139 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d140 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d141 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |
| d142 | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | havolalar bo‘sh |


## Amaliy mashg‘ulot protokollari (kunga bog‘lanmagan to‘plam)

M9 modulining amaliy kunlari (`d091`–`d142`, jumladan yuqoridagi “Deck yo‘q” ro‘yxatidagilar) curriculumda bir xil umumiy nom bilan turadi. Dastur hujjati (`КЛД_ихтисослаштириш_864_кредит`: M9 — 324 soat, shundan ma’ruza 48, laboratoriya ishi 276 (`curriculum.json`da M9 — 330 soat: ma’ruza 48, amaliy 270, attestatsiya 6, qo‘shimcha 6); mavzu yoki texnika ro‘yxati yo‘q, faqat umumiy kompetensiyalar va jihozlar ro‘yxati) hamda dars jadvallari (Karimova, Turg‘unova T1/T2) bu kunlarda **kunma-kun mavzu yoki texnikani ko‘rsatmaydi**: aniq mavzu faqat ma’ruza kunlarida (d090, d095, d101, d106, d112, d116, d121, d127 — ular allaqachon alohida deck), qolganlari “Laborator tekshiruv usullarini amaliyotda o‘zlashtirish”. Shu sababli texnika taqdimotlari **hech bir kunga biriktirilmagan**: nomi texnikaga qarab berilgan raqamsiz to‘plam. Kun ↔ texnika moslik manbalarda yo‘q, shuning uchun o‘ylab topilmadi (ma’ruza kunlari oralig‘idagi kunlar o‘sha ma’ruza mavzusiga tegishli degan taxmin ham hujjatlarda tasdiqlanmagan — ishlatilmadi).

Qoidalar: matn kitoblardan o‘z so‘zim bilan; har slaydda muallif + qisqa nom + bo‘lim/sahifa; oxirgi slayd — “Adabiyotlar”. Son, hajm, vaqt va konsentratsiya faqat manbada ko‘ringan joyda (sahifasi bilan); manbalar bir-biriga zid bo‘lsa — yangi/ishonchlisi yoki umuman olinmagan; eskirgan/xavfli usullar olinmagan. Faqat mavjud rasmlar (`assets/microscopy`) ishlatilgan (atlasda najas va balg‘am fotolari yo‘q — o‘sha protokollarda rasm slaydi yo‘q). “Qin tozalik darajalari” jadvali yuqoridagi sitologiya mavzu decklarida manbasi yo‘qligi uchun yo‘q; u faqat shu to‘plamdagi urogenital protokolda, Kurbonova (2023, 70-b.) manbasi bilan berilgan.

| Texnika (uz) | Guruh | Slayd (uz) | Manbalar |
|---|---|---|---|
| Kapillyar qon olish va gematologik tekshiruv uchun namuna tayyorlash | Gematologiya | 9 | 5 |
| Gemoglobinni gemiglobintsianid (sianmetgemoglobin) usulida aniqlash | Gematologiya | 10 | 2 |
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
| Qon zardobida glyukozani fotometrik aniqlash (GOD-POD) | Klinik biokimyo · fotometrik usullar | 9 | 2 |
| Alaninaminotransferaza (ALT) faolligini kinetik aniqlash | Klinik biokimyo · fotometrik usullar | 10 | 2 |
| Qon zardobida mochevinani fermentativ aniqlash (ureaza–GLDG) | Klinik biokimyo · fotometrik usullar | 9 | 1 |
| Umumiy va bog‘langan bilirubinni diazo usulida aniqlash | Klinik biokimyo · fotometrik usullar | 9 | 1 |
| Gemostaz tizimini tekshirish uchun qon olish va tayyorgarlik | Gematologiya · gemostaz | 8 | 2 |
| Trombotsitlarni Fonio usulida sanash | Gematologiya · gemostaz | 9 | 3 |
| Laboratoriya ichidagi sifat nazorati: bosqichlar va nazorat materiali | Laboratoriya tartibi · sifat va xavfsizlik | 10 | 1 |
| Biologik material bilan xavfsiz ishlash va sanitar-epidemiologik tartib | Laboratoriya tartibi · sifat va xavfsizlik | 10 | 3 |

### Manbalarda bor, lekin olinmagan

- Dastur va dars jadvallari M9 amaliy kunlarida kunma-kun mavzu yoki texnikani ko‘rsatmaydi — texnikalar kunlarga biriktirilmadi.
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
