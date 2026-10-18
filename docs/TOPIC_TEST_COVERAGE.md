# Mavzu testlari: savollar qamrovi

Har taqdimot (deck) oxiridagi **Mavzu testi** faqat shu mavzuga bog‘langan, **tekshirilgan** savollardan tuziladi (10 ta; kam bo‘lsa — boricha; 3 tadan kam bo‘lsa — “Bu mavzu uchun savollar tayyorlanmoqda”). Savollar o‘ylab topilmaydi.

Tekshirilgan savol deganda:

- **Toifa** — `curriculum.json` → `test_candidates.ids` dagi rasmiy ro‘yxat savoli: kaliti bor, chiqarilmagan (`held` yo‘q), LabGuide kalit tekshiruvi `verdict: ok` va izohi tasdiqlangan (`unverified` emas). `ambiguous`/`disputed` savollar testga kirmaydi.
- **Paket** — `test_candidates.pack_quiz_ids` dagi mashq savoli, manbasi (`refs`) ko‘rsatilgan.
- **Deck matnidan** — `test_candidates.derived_quiz_ids` dagi paket savoli (`provenance: derived`, manba fayli `content_src/additions/derived_topic_quiz.json`): har biri deck slaydidagi manbali gapdan olingan; `derived_from` da deck, slayd sarlavhasi, asl manba yorlig‘i va o‘sha gap (uz/ru/en) saqlangan, `test/unit/derived_quiz_test.dart` gap slaydda borligini tekshiradi.
- Hammasida: bitta to‘g‘ri javob, uchala tilda variantlar takrorlanmaydi.

Hujjat `test/unit/topic_test_coverage_test.dart` bilan ilovadagi aynan shu qoida (`lib/features/classroom/topic_test.dart`) bo‘yicha yoziladi: `LG_WRITE_COVERAGE=1 flutter test test/unit/topic_test_coverage_test.dart`.

## Xulosa

| | Mavzular |
|---|---:|
| Jami mavzu | 188 |
| 0 ta savol | 47 |
| 1–2 ta (test o‘tkazilmaydi) | 0 |
| 3–4 ta | 0 |
| **< 5 ta (jami, 0 bilan)** | 47 |
| 5–9 ta | 0 |
| **≥ 10 ta** (to‘liq 10 savollik test) | 141 |
| `test_gap: true` belgisi | 32 |

Taqdimotlar (125 ta):

| Holat | Decklar |
|---|---:|
| Test tayyor (≥ 3 savol) | 97 |
| “Savollar tayyorlanmoqda” (< 3) | 1 |
| Tugma yo‘q — amaliy protokol, mavzuga bog‘lanmagan | 27 |

Amaliy protokol decklari (`index_v2.json` da `topics: []`) hech qaysi mavzu yoki analitga bog‘lanmagan — ularda test tugmasi ko‘rsatilmaydi. Bog‘lash uchun eksportga (`tool/slides/export_app_decks.py`) mavzu/analit havolasi qo‘shilishi kerak (mutaxassis tanlovi bilan).

“Chiqarilgan nomzod” — curriculum nomzodlari ichida tekshiruvdan o‘tmaganlari (toifa: kalit `ok` emas yoki izoh tasdiqlanmagan; paket: manbasiz). Ular mutaxassis ko‘rib chiqsa, testga qo‘shilishi mumkin.

## Yangi savollar qanday qo‘shiladi

Deck matnidan olingan savollar faqat deck slaydidagi manbali gapga tayanadi: kalit va xato variantlar o‘sha manbadan; noaniq, eskirgan yoki ilovadagi boshqa gapga zid savollar ikkinchi (taqrizchi) bosqichda o‘chirilgan. Ular ham `review_state: pending` — mutaxassis ko‘rigi kutilmoqda. Slaydlarida manba ko‘rsatilmagan deck (d001) uchun bunday savol yozilmaydi.

Boshqa yo‘l: qoralama uchun `tool/ai` (AI yordamida qoralama) bor, lekin uning natijasi **mutaxassis tekshiruvisiz** testga kirmaydi: savol bankka manbasi bilan qo‘shilib, kaliti tekshirilgach (`verdict: ok` yoki `refs`), mavzuning `test_candidates` ro‘yxatiga yoziladi — shundan keyin test o‘zi paydo bo‘ladi.

## 0 ta savol (47)

| Mavzu | Nomi | Toifa (ok) | Paket (manbali) | Deck matnidan | Jami | Chiqarilgan nomzod | test_gap | Deck |
|---|---|---:|---:|---:|---:|---:|:-:|---|
| d001-P | Laborator xizmatni tashkillashtirish. Tibbiy etika va deontologiya. Ma’naviyat darsi | 0 | 0 | 0 | **0** | 0 | ha | d001 |
| d001-L | Ma’naviyat darsi | 0 | 0 | 0 | **0** | 0 | ha | d001 |
| d091-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d092-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d093-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d094-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d096-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d097-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d098-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d099-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d100-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d102-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d103-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d104-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d105-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d107-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d108-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d109-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d110-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d111-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d113-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d114-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d115-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d117-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d118-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d119-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d120-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d122-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d123-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d124-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d125-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d126-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d128-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d129-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d130-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d131-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d132-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d133-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d134-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d135-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d136-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d137-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d138-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d139-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d140-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d141-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |
| d142-P | Laborator tekshiruv usullarini amaliyotda o‘zlashtirish | 0 | 0 | 0 | **0** | 0 |  | — |

`test_gap` belgisi yo‘q, lekin savoli 0 ta mavzular: 45 ta (asosan 91–142-kunlar amaliyoti: curriculum’da nomzod ro‘yxati bo‘sh).

## 1–2 ta savol — test o‘tkazilmaydi (0)

| Mavzu | Nomi | Toifa (ok) | Paket (manbali) | Deck matnidan | Jami | Chiqarilgan nomzod | test_gap | Deck |
|---|---|---:|---:|---:|---:|---:|:-:|---|

## 3–4 ta savol (0)

| Mavzu | Nomi | Toifa (ok) | Paket (manbali) | Deck matnidan | Jami | Chiqarilgan nomzod | test_gap | Deck |
|---|---|---:|---:|---:|---:|---:|:-:|---|

## 5–9 ta savol (0)

| Mavzu | Nomi | Toifa (ok) | Paket (manbali) | Deck matnidan | Jami | Chiqarilgan nomzod | test_gap | Deck |
|---|---|---:|---:|---:|---:|---:|:-:|---|

## ≥ 10 ta savol (141)

| Mavzu | Nomi | Toifa (ok) | Paket (manbali) | Deck matnidan | Jami | Chiqarilgan nomzod | test_gap | Deck |
|---|---|---:|---:|---:|---:|---:|:-:|---|
| d002-P | O‘zbekistonda klinik biokimyoviy laboratoriyalarni rivojlantirishning tashkiliy masalalari | 0 | 0 | 10 | **10** | 0 | ha | d002 |
| d002-L | O‘zbekistonda klinik biokimyoviy laboratoriyalarni rivojlantirishning tashkiliy masalalari | 0 | 0 | 10 | **10** | 0 | ha | d002 |
| d003-P | Laboratoriya ichida va laboratoriyalar oro o‘tkaziladigan sifat nazorati va uning xususiyatlari | 15 | 0 | 4 | **19** | 4 |  | d003 |
| d003-L | Laboratoriya ichida va laboratoriyalar oro o‘tkaziladigan sifat nazorati va uning xususiyatlari | 15 | 0 | 4 | **19** | 4 |  | d003 |
| d004-A | Attestatsiya 1. Laborator xizmatni tashkillashtirish. Tibbiy etika va deontologiya modulidan | 19 | 0 | 2 | **21** | 4 |  | d004 |
| d005-P | Odam ichki a’zolari tuzilishi va vazifalari. To‘qimalar klassifikatsiyasi. Epiteliy to‘qimasining morfofunksional xarakteristikasi | 0 | 0 | 13 | **13** | 0 | ha | d005 |
| d005-L | Odam ichki a’zolari tuzilishi va vazifalari. To‘qimalar klassifikatsiyasi. Epiteliy to‘qimasining morfofunksional xarakteristikasi | 0 | 0 | 13 | **13** | 0 | ha | d005 |
| d006-P | Biriktiruvchi to‘qimaning morfofunksional xarakteristikasi | 0 | 0 | 10 | **10** | 0 | ha | d006 |
| d006-L | Biriktiruvchi to‘qimaning morfofunksional xarakteristikasi | 0 | 0 | 10 | **10** | 0 | ha | d006 |
| d007-P | Jigar kasalliklarining laborator ko‘rsatkichlari | 20 | 17 | 0 | **37** | 5 |  | d007 |
| d007-L | Jigar kasalliklarining laborator ko‘rsatkichlari | 20 | 17 | 0 | **37** | 5 |  | d007 |
| d008-P | Buyrak va siydik yo‘llari kasalliklarining laborator ko‘rsatkichlari | 16 | 14 | 8 | **38** | 1 |  | d008 |
| d008-L | Buyrak va siydik yo‘llari kasalliklarining laborator ko‘rsatkichlari | 16 | 14 | 8 | **38** | 1 |  | d008 |
| d009-A | Attestatsiya 2. Odam ichki a’zolari tuzilishi va vazifalari modulidan | 17 | 0 | 1 | **18** | 1 |  | d009 |
| d010-P | Qon ishlab chiqarishning zamonaviy nazariyasi. Eritropoez, leykopoez, trombotsitopoez. Limfositopoez | 1 | 3 | 9 | **13** | 0 |  | d010 |
| d010-L | Qon ishlab chiqarishning zamonaviy nazariyasi. Eritropoez, leykopoez, trombotsitopoez. Limfositopoez | 1 | 3 | 9 | **13** | 0 |  | d010 |
| d011-P | Qon shaklli elementlari sonini sanash. Gemoglobinni aniqlash | 7 | 10 | 0 | **17** | 0 |  | d011 |
| d011-L | Qon shaklli elementlari sonini sanash. Gemoglobinni aniqlash | 7 | 10 | 0 | **17** | 0 |  | d011 |
| d012-P | Leykositar formula uchun material olish va ularni sanash. Mieloid, limfomonotsitar va eozinofil tipdagi leykemoid reaksiyalar | 8 | 13 | 5 | **26** | 4 |  | d012 |
| d012-L | Leykositar formula uchun material olish va ularni sanash. Mieloid, limfomonotsitar va eozinofil tipdagi leykemoid reaksiyalar | 8 | 13 | 5 | **26** | 4 |  | d012 |
| d013-P | Anemiyalar. Klassifikatsiyasi, etiologiyasi va patogenezi | 5 | 17 | 0 | **22** | 5 |  | d013 |
| d013-L | Anemiyalar. Klassifikatsiyasi, etiologiyasi va patogenezi | 5 | 17 | 0 | **22** | 5 |  | d013 |
| d014-P | Temir tanqisligi bilan kechadigan anemiyalar. Suyak ko‘migi va periferik qon ko‘rinishi | 8 | 8 | 0 | **16** | 3 |  | d014 |
| d014-L | Temir tanqisligi bilan kechadigan anemiyalar. Suyak ko‘migi va periferik qon ko‘rinishi | 8 | 8 | 0 | **16** | 3 |  | d014 |
| d015-P | Vit. B-12 yetishmasligi bilan bog‘liq kamqonliklar. Suyak ko‘migi va periferik qon ko‘rinishi | 8 | 5 | 2 | **15** | 0 |  | d015 |
| d015-L | Vit. B-12 yetishmasligi bilan bog‘liq kamqonliklar. Suyak ko‘migi va periferik qon ko‘rinishi | 8 | 5 | 2 | **15** | 0 |  | d015 |
| d016-P | Gemolitik kamqonliklar. Klinik-laborator ko‘rsatkichlari. Suyak ko‘migi va periferik qon ko‘rinishi | 4 | 10 | 0 | **14** | 0 |  | d016 |
| d016-L | Gemolitik kamqonliklar. Klinik-laborator ko‘rsatkichlari. Suyak ko‘migi va periferik qon ko‘rinishi | 4 | 10 | 0 | **14** | 0 |  | d016 |
| d017-P | Leykozlar, etiologiyasi, patogenezi va klassifikatsiya | 11 | 3 | 0 | **14** | 2 |  | d017 |
| d017-L | Leykozlar, etiologiyasi, patogenezi va klassifikatsiya | 11 | 3 | 0 | **14** | 2 |  | d017 |
| d018-P | O‘tkir leykozlar. O‘tkir leykozlarda suyak ko‘migi va periferik qon ko‘rinishi | 12 | 1 | 0 | **13** | 2 |  | d018 |
| d018-L | O‘tkir leykozlar. O‘tkir leykozlarda suyak ko‘migi va periferik qon ko‘rinishi | 12 | 1 | 0 | **13** | 2 |  | d018 |
| d019-P | Surunkali leykozlar. Suyak ko‘migi va periferik qon ko‘rinishi | 11 | 0 | 3 | **14** | 2 |  | d019 |
| d019-L | Surunkali leykozlar. Suyak ko‘migi va periferik qon ko‘rinishi | 11 | 0 | 3 | **14** | 2 |  | d019 |
| d020-P | Surunkali mieloleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | 1 | 0 | 9 | **10** | 0 | ha | d020 |
| d020-L | Surunkali mieloleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | 1 | 0 | 9 | **10** | 0 | ha | d020 |
| d021-P | Surunkali limfoleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | 1 | 2 | 9 | **12** | 0 |  | d021 |
| d021-L | Surunkali limfoleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | 1 | 2 | 9 | **12** | 0 |  | d021 |
| d022-L | Mielom kasalligida suyak ko‘migi va periferik qon ko‘rinishi | 3 | 4 | 4 | **11** | 0 |  | d022 |
| d022-P | Mielom kasalligida suyak ko‘migi va periferik qon ko‘rinishi | 3 | 4 | 4 | **11** | 0 |  | d022 |
| d023-A | Attestatsiya 3. Gematologik tekshiruv usullari modulidan | 20 | 2 | 0 | **22** | 5 |  | d023 |
| d024-P | Oshqozon va o‘t suyuqligini mikroskopik tekshirish kasalliklarining klinik laborator ko‘rsatkichlari | 0 | 1 | 9 | **10** | 0 | ha | d024 |
| d024-L | Oshqozon va o‘t suyuqligini mikroskopik tekshirish kasalliklarining klinik laborator ko‘rsatkichlari | 0 | 1 | 9 | **10** | 0 | ha | d024 |
| d025-P | Najasni mikroskopik tekshirish. Klinik diagnostik ahamiyati | 7 | 3 | 10 | **20** | 0 |  | d025 |
| d025-L | Najasni mikroskopik tekshirish. Klinik diagnostik ahamiyati | 7 | 3 | 10 | **20** | 0 |  | d025 |
| d026-P | Najasni mikroskopik tekshirish. Klinik diagnostik ahamiyati (2-kun) | 7 | 2 | 7 | **16** | 0 |  | d026 |
| d027-P | Siydikni tekshirish. Klinik diagnostik ahamiyati | 7 | 8 | 4 | **19** | 1 |  | d027 |
| d027-L | Siydikni tekshirish. Klinik diagnostik ahamiyati | 7 | 8 | 4 | **19** | 1 |  | d027 |
| d028-P | Siydikni tekshirish. Klinik diagnostik ahamiyati (2-kun) | 7 | 8 | 4 | **19** | 1 |  | d028 |
| d029-P | Bronxial astma, pnevmoniya, bronxit va boshqa nafas yo‘llari kasalliklarida balg‘amni tekshirish | 7 | 2 | 6 | **15** | 1 |  | d029 |
| d029-L | Bronxial astma, pnevmoniya, bronxit va boshqa nafas yo‘llari kasalliklarida balg‘amni tekshirish | 7 | 2 | 6 | **15** | 1 |  | d029 |
| d030-P | Sil kasalligida balg‘amni tekshirish va uning klinik diagnostik ahamiyati | 7 | 2 | 6 | **15** | 1 |  | d030 |
| d030-L | Sil kasalligida balg‘amni tekshirish va uning klinik diagnostik ahamiyati | 7 | 2 | 6 | **15** | 1 |  | d030 |
| d031-P | Sil kasalligida balg‘amni tekshirish va uning klinik diagnostik ahamiyati (2-kun) | 7 | 2 | 6 | **15** | 1 |  | d031 |
| d032-P | Transsudat va ekssudatlarni tekshirishning klinik diagnostikasi | 1 | 1 | 10 | **12** | 0 | ha | d032 |
| d032-L | Transsudat va ekssudatlarni tekshirishning klinik diagnostikasi | 1 | 1 | 10 | **12** | 0 | ha | d032 |
| d033-P | Xar xil kasalliklarda orqa miya suyuqligini laborator ko‘rsatkichlari | 1 | 1 | 10 | **12** | 0 | ha | d033 |
| d033-L | Xar xil kasalliklarda orqa miya suyuqligini laborator ko‘rsatkichlari | 1 | 1 | 10 | **12** | 0 | ha | d033 |
| d034-A | Attestatsiya 4. Umumklinik tekshiruv usullari modulidan | 17 | 2 | 4 | **23** | 1 |  | d034 |
| d035-P | Sitologik tekshiruv usullari. Ayollar jinsiy a’zolari ajralmalarini mikroskopik tekshirish. Surtmalarni Gramm, Romanovskiy va metilen ko‘kida bo‘yash | 6 | 4 | 4 | **14** | 1 |  | d035 |
| d036-P | O‘smalar. O‘sma markerlari haqida umumiy ma’lumotlar. Yomon sifatli o‘smalar sitodiagnostikasi | 7 | 4 | 0 | **11** | 1 |  | d036 |
| d036-L | O‘smalar. O‘sma markerlari haqida umumiy ma’lumotlar. Yomon sifatli o‘smalar sitodiagnostikasi | 7 | 4 | 0 | **11** | 1 |  | d036 |
| d037-P | Bachadon bo‘yinchasi va bachadon yomon sifatli o‘smalarining sitodiagnostikasi | 11 | 2 | 1 | **14** | 2 |  | d037 |
| d038-P | Nafas organlari o‘smalari sitodiagnostikasi | 3 | 2 | 6 | **11** | 0 |  | d038 |
| d039-A | Attestatsiya 5. Sitologik tekshiruv usullari modulidan | 19 | 2 | 1 | **22** | 2 |  | d039 |
| d040-P | Klinik biokimyodan umumiy masalalar. Fizik-kimyoviy va kimyoviy usullar (xromatografiya, spektro-, fotometriya) | 0 | 0 | 12 | **12** | 1 | ha | d040 |
| d041-P | Mindray BA-88A bioximik yarim avtomat analizator ishlash prinsiplari. Bioximik analizatorni dasturlash | 0 | 0 | 12 | **12** | 0 | ha | d041 |
| d042-P | Aminokislotalar klassifikatsiyasi. Oddiy va murakkab oqsillar | 16 | 4 | 0 | **20** | 1 |  | d042 |
| d042-L | Aminokislotalar klassifikatsiyasi. Oddiy va murakkab oqsillar | 16 | 4 | 0 | **20** | 1 |  | d042 |
| d043-P | Pigmentlar almashinuvi. Bilirubin hosil bo‘lishi | 10 | 5 | 0 | **15** | 5 |  | d043 |
| d043-L | Pigmentlar almashinuvi. Bilirubin hosil bo‘lishi | 10 | 5 | 0 | **15** | 5 |  | d043 |
| d044-P | Uglevodlar, klassifikatsiyasi, biologik ahamiyati. Uglevodlarni oshqozon-ichak traktida so‘rilishi | 22 | 0 | 0 | **22** | 3 |  | d044 |
| d044-L | Uglevodlar, klassifikatsiyasi, biologik ahamiyati. Uglevodlarni oshqozon-ichak traktida so‘rilishi | 22 | 0 | 0 | **22** | 3 |  | d044 |
| d045-P | Qandli diabet diagnostikasi | 23 | 9 | 4 | **36** | 2 |  | d045 |
| d046-P | Yog‘larning tuzilishi, klassifikatsiyasi va biologik roli | 21 | 11 | 0 | **32** | 4 |  | d046 |
| d046-L | Yog‘larning tuzilishi, klassifikatsiyasi va biologik roli | 21 | 11 | 0 | **32** | 4 |  | d046 |
| d047-P | Suv-tuz almashinuvi va uning buzilishi | 7 | 12 | 4 | **23** | 1 |  | d047 |
| d047-L | Suv-tuz almashinuvi va uning buzilishi | 7 | 12 | 4 | **23** | 1 |  | d047 |
| d048-P | Fermentlar, tuzilishi, klassifikatsiyasi | 20 | 18 | 0 | **38** | 5 |  | d048 |
| d048-L | Fermentlar, tuzilishi, klassifikatsiyasi | 20 | 18 | 0 | **38** | 5 |  | d048 |
| d049-P | Jigar fermentlarini tekshirish | 23 | 10 | 0 | **33** | 2 |  | d049 |
| d050-P | Laktatdegidrogenaza, ishqoriy fosfataza fermentlarini tekshirish | 11 | 5 | 0 | **16** | 2 |  | d050 |
| d051-P | Vitaminlar. Vitamin B12 va D larni tekshirishning klinik diagnostik ahamiyati | 6 | 4 | 0 | **10** | 0 |  | d051 |
| d052-P | Vitaminlar. Vitamin B12 va D larni tekshirishning klinik diagnostik ahamiyati (2-kun) | 6 | 4 | 0 | **10** | 0 |  | d052 |
| d053-A | Attestatsiya 6. Klinik biokimyodan umumiy masalalar modulidan | 22 | 0 | 0 | **22** | 3 |  | d053 |
| d054-P | Klinik biokimyo va biokimyoviy tekshiruv usullari. Umumiy oqsilni va albuminni aniqlash usullari. Klinik diagnostik ahamiyati | 14 | 4 | 0 | **18** | 0 |  | d054 |
| d055-P | Azotemiyalar. Klinik diagnostik ahamiyati | 8 | 8 | 10 | **26** | 0 |  | d055 |
| d055-L | Azotemiyalar. Klinik diagnostik ahamiyati | 8 | 8 | 10 | **26** | 0 |  | d055 |
| d056-P | Mochevinani aniqlash usullari. Klinik diagnostik ahamiyati | 7 | 2 | 4 | **13** | 0 |  | d056 |
| d057-P | Kreatininni aniqlash usullari. Klinik diagnostik ahamiyati | 3 | 4 | 4 | **11** | 0 |  | d057 |
| d058-P | Bilirubinni aniqlash usullari. Klinik diagnostik ahamiyati | 8 | 5 | 0 | **13** | 2 |  | d058 |
| d058-L | Bilirubinni aniqlash usullari. Klinik diagnostik ahamiyati | 8 | 5 | 0 | **13** | 2 |  | d058 |
| d059-P | Glyukozani aniqlash usullari. Glyukoza tolerant testi. Klinik diagnostik ahamiyati | 23 | 2 | 1 | **26** | 2 |  | d059 |
| d060-P | Glikozirlangan gemoglobinni aniqlash. Klinik diagnostik ahamiyati | 2 | 4 | 5 | **11** | 1 |  | d060 |
| d061-P | Transaminazalar, amilazani aniqlash usullari. Klinik diagnostik ahamiyati | 20 | 9 | 0 | **29** | 5 |  | d061 |
| d061-L | Transaminazalar, amilazani aniqlash usullari. Klinik diagnostik ahamiyati | 20 | 9 | 0 | **29** | 5 |  | d061 |
| d062-P | Ishqoriy fosfataza, γ-GT fermentlarini aniqlash usullari. Tekshirishning klinik diagnostik ahamiyati | 19 | 5 | 0 | **24** | 6 |  | d062 |
| d063-P | Kislota-asos muvozanati. Bufer sistemasi | 8 | 0 | 8 | **16** | 1 |  | d063 |
| d063-L | Kislota-asos muvozanati. Bufer sistemasi | 8 | 0 | 8 | **16** | 1 |  | d063 |
| d064-P | Kislota-asos muvozanati. Bufer sistemasi (2-kun) | 8 | 0 | 9 | **17** | 1 |  | d064 |
| d065-P | Umumiy xolesterinni aniqlash. Klinik diagnostik ahamiyati | 16 | 8 | 0 | **24** | 3 |  | d065 |
| d066-P | Triglitseridlarni aniqlash usullari. Klinik diagnostik ahamiyati | 10 | 4 | 0 | **14** | 4 |  | d066 |
| d067-P | Natriy, kaliy, kaltsiyni aniqlash usullari. Klinik diagnostik ahamiyati | 5 | 6 | 2 | **13** | 0 |  | d067 |
| d068-P | Temirni aniqlash usullari. Klinik diagnostik ahamiyati | 8 | 2 | 0 | **10** | 3 |  | d068 |
| d069-P | O‘tkir faza oqsillari | 4 | 5 | 1 | **10** | 0 |  | d069 |
| d069-L | O‘tkir faza oqsillari | 4 | 5 | 1 | **10** | 0 |  | d069 |
| d070-P | SRB, RF, ASLO aniqlash. Klinik diagnostik ahamiyati | 1 | 4 | 9 | **14** | 0 |  | d070 |
| d071-P | Miokard infarkti biokimyoviy markerlari va xavf omillari | 12 | 7 | 0 | **19** | 2 |  | d071 |
| d072-P | Podagra kasalligining laborator diagnostikasi. Siydik kislotasini aniqlash | 0 | 2 | 8 | **10** | 0 | ha | d072 |
| d073-P | Gemostazning zamonaviy tasavvuri | 22 | 12 | 0 | **34** | 3 |  | d073 |
| d073-L | Gemostazning zamonaviy tasavvuri | 22 | 12 | 0 | **34** | 3 |  | d073 |
| d074-A | Attestatsiya 7. Klinik biokimyo va biokimyoviy tekshirish usullari modulidan | 21 | 4 | 0 | **25** | 4 |  | d074 |
| d075-P | Turli kasalliklar laborator diagnostikasi. Qonning tomir ichida ivib qolishi (DVS) sindromi va undagi klinik laborator tekshirishlar | 5 | 10 | 0 | **15** | 3 |  | d075 |
| d075-L | Turli kasalliklar laborator diagnostikasi. Qonning tomir ichida ivib qolishi (DVS) sindromi va undagi klinik laborator tekshirishlar | 5 | 10 | 0 | **15** | 3 |  | d075 |
| d076-P | Allergik kasalliklar laborator diagnostikasi | 0 | 2 | 11 | **13** | 0 | ha | d076 |
| d077-P | Jinsiy yo‘l bilan yuqadigan infeksiyalar laborator diagnostikasi. Vasserman reaksiyasi | 2 | 3 | 7 | **12** | 0 |  | d077 |
| d078-P | Bezgak kasalligining laborator diagnostikasi | 1 | 1 | 9 | **11** | 0 | ha | d078 |
| d078-L | Bezgak kasalligining laborator diagnostikasi | 1 | 1 | 9 | **11** | 0 | ha | d078 |
| d079-P | OIV infeksiyasi. Klinik laborator tekshiruv usullari. Klinik diagnostik ahamiyati | 0 | 1 | 14 | **15** | 0 | ha | d079 |
| d079-L | OIV infeksiyasi. Klinik laborator tekshiruv usullari. Klinik diagnostik ahamiyati | 0 | 1 | 14 | **15** | 0 | ha | d079 |
| d080-P | Parazitar kasalliklar laborator diagnostikasi. Dumaloq gijjalar laborator diagnostikasi | 2 | 2 | 10 | **14** | 0 |  | d080 |
| d080-L | Parazitar kasalliklar laborator diagnostikasi. Dumaloq gijjalar laborator diagnostikasi | 2 | 2 | 10 | **14** | 0 |  | d080 |
| d081-P | Lentasimon gijjalar laborator diagnostikasi. Klinik diagnostik ahamiyati | 1 | 1 | 8 | **10** | 0 | ha | d081 |
| d082-P | So‘ruvchi gijjalar laborator diagnostikasi. Klinik diagnostik ahamiyati | 0 | 1 | 11 | **12** | 0 | ha | d082 |
| d083-P | TORCH infeksiyalar laborator diagnostikasi. Klinik diagnostik ahamiyati | 0 | 0 | 11 | **11** | 0 | ha | d083 |
| d083-L | TORCH infeksiyalar laborator diagnostikasi. Klinik diagnostik ahamiyati | 0 | 0 | 11 | **11** | 0 | ha | d083 |
| d084-P | Klinik laborator diagnostikada gematologik analizatorlar | 1 | 9 | 3 | **13** | 0 |  | d084 |
| d085-P | Klinik laborator diagnostikada ECHT analizatorlar | 0 | 0 | 10 | **10** | 0 | ha | d085 |
| d086-P | Klinik laborator diagnostikada bioximik analizatorlar | 0 | 0 | 12 | **12** | 0 | ha | d086 |
| d087-P | Klinik laborator diagnostikada urino analizatorlar | 0 | 2 | 10 | **12** | 0 | ha | d087 |
| d088-P | Klinik laborator diagnostikada koagulometrik analizatorlar | 0 | 6 | 6 | **12** | 1 |  | d088 |
| d089-A | Attestatsiya 8. Turli kasalliklar laborator diagnostikasi modulidan | 3 | 2 | 16 | **21** | 0 |  | d089 |
| d090-L | Umumiy qon tahlilini amaliyotda o‘zlashtirish | 14 | 13 | 0 | **27** | 1 |  | d090 |
| d095-L | Leykositar formulani amaliyotda o‘zlashtirish | 3 | 10 | 5 | **18** | 0 |  | d095 |
| d101-L | Umumiy siydik tahlilini amaliyotda o‘zlashtirish | 5 | 4 | 4 | **13** | 1 |  | d101 |
| d106-L | Umumiy balg‘am tahlilini amaliyotda o‘zlashtirish | 6 | 2 | 6 | **14** | 1 |  | d106 |
| d112-L | Umumiy axlat (najas) tahlilini amaliyotda o‘zlashtirish | 6 | 2 | 7 | **15** | 0 |  | d112 |
| d116-L | Mindray BA-88A bioximik yarim avtomat analizator ishlash prinsiplari. Bioximik analizatorni dasturlashni amaliyotda o‘zlashtirish | 0 | 0 | 12 | **12** | 0 | ha | d116 |
| d121-L | Laktatdegidrogenaza, ishqoriy fosfataza fermentlar tekshiruvini amaliyotda o‘zlashtirish | 11 | 5 | 0 | **16** | 2 |  | d121 |
| d127-L | SRB, RF, ASLO lar tekshiruvini amaliyotda o‘zlashtirish | 0 | 3 | 8 | **11** | 0 |  | d127 |
| d143-A | Attestatsiya. Laborator tekshiruv usullarini amaliyotda o‘zlashtirish (yakuniy) | 21 | 0 | 2 | **23** | 4 |  | d143 |

## `test_gap` belgisi bor, lekin bir nechta savol topilgan (30)

Belgi curriculum’da “savollar yetarli emas” degani; bu mavzularda tekshirilgan savol bor, lekin test uchun kamida 3 ta kerak.

| Mavzu | Nomi | Toifa (ok) | Paket (manbali) | Deck matnidan | Jami | Chiqarilgan nomzod | test_gap | Deck |
|---|---|---:|---:|---:|---:|---:|:-:|---|
| d002-P | O‘zbekistonda klinik biokimyoviy laboratoriyalarni rivojlantirishning tashkiliy masalalari | 0 | 0 | 10 | **10** | 0 | ha | d002 |
| d002-L | O‘zbekistonda klinik biokimyoviy laboratoriyalarni rivojlantirishning tashkiliy masalalari | 0 | 0 | 10 | **10** | 0 | ha | d002 |
| d005-P | Odam ichki a’zolari tuzilishi va vazifalari. To‘qimalar klassifikatsiyasi. Epiteliy to‘qimasining morfofunksional xarakteristikasi | 0 | 0 | 13 | **13** | 0 | ha | d005 |
| d005-L | Odam ichki a’zolari tuzilishi va vazifalari. To‘qimalar klassifikatsiyasi. Epiteliy to‘qimasining morfofunksional xarakteristikasi | 0 | 0 | 13 | **13** | 0 | ha | d005 |
| d006-P | Biriktiruvchi to‘qimaning morfofunksional xarakteristikasi | 0 | 0 | 10 | **10** | 0 | ha | d006 |
| d006-L | Biriktiruvchi to‘qimaning morfofunksional xarakteristikasi | 0 | 0 | 10 | **10** | 0 | ha | d006 |
| d020-P | Surunkali mieloleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | 1 | 0 | 9 | **10** | 0 | ha | d020 |
| d020-L | Surunkali mieloleykoz. Suyak ko‘migi va periferik qon ko‘rinishi | 1 | 0 | 9 | **10** | 0 | ha | d020 |
| d024-P | Oshqozon va o‘t suyuqligini mikroskopik tekshirish kasalliklarining klinik laborator ko‘rsatkichlari | 0 | 1 | 9 | **10** | 0 | ha | d024 |
| d024-L | Oshqozon va o‘t suyuqligini mikroskopik tekshirish kasalliklarining klinik laborator ko‘rsatkichlari | 0 | 1 | 9 | **10** | 0 | ha | d024 |
| d032-P | Transsudat va ekssudatlarni tekshirishning klinik diagnostikasi | 1 | 1 | 10 | **12** | 0 | ha | d032 |
| d032-L | Transsudat va ekssudatlarni tekshirishning klinik diagnostikasi | 1 | 1 | 10 | **12** | 0 | ha | d032 |
| d033-P | Xar xil kasalliklarda orqa miya suyuqligini laborator ko‘rsatkichlari | 1 | 1 | 10 | **12** | 0 | ha | d033 |
| d033-L | Xar xil kasalliklarda orqa miya suyuqligini laborator ko‘rsatkichlari | 1 | 1 | 10 | **12** | 0 | ha | d033 |
| d040-P | Klinik biokimyodan umumiy masalalar. Fizik-kimyoviy va kimyoviy usullar (xromatografiya, spektro-, fotometriya) | 0 | 0 | 12 | **12** | 1 | ha | d040 |
| d041-P | Mindray BA-88A bioximik yarim avtomat analizator ishlash prinsiplari. Bioximik analizatorni dasturlash | 0 | 0 | 12 | **12** | 0 | ha | d041 |
| d072-P | Podagra kasalligining laborator diagnostikasi. Siydik kislotasini aniqlash | 0 | 2 | 8 | **10** | 0 | ha | d072 |
| d076-P | Allergik kasalliklar laborator diagnostikasi | 0 | 2 | 11 | **13** | 0 | ha | d076 |
| d078-P | Bezgak kasalligining laborator diagnostikasi | 1 | 1 | 9 | **11** | 0 | ha | d078 |
| d078-L | Bezgak kasalligining laborator diagnostikasi | 1 | 1 | 9 | **11** | 0 | ha | d078 |
| d079-P | OIV infeksiyasi. Klinik laborator tekshiruv usullari. Klinik diagnostik ahamiyati | 0 | 1 | 14 | **15** | 0 | ha | d079 |
| d079-L | OIV infeksiyasi. Klinik laborator tekshiruv usullari. Klinik diagnostik ahamiyati | 0 | 1 | 14 | **15** | 0 | ha | d079 |
| d081-P | Lentasimon gijjalar laborator diagnostikasi. Klinik diagnostik ahamiyati | 1 | 1 | 8 | **10** | 0 | ha | d081 |
| d082-P | So‘ruvchi gijjalar laborator diagnostikasi. Klinik diagnostik ahamiyati | 0 | 1 | 11 | **12** | 0 | ha | d082 |
| d083-P | TORCH infeksiyalar laborator diagnostikasi. Klinik diagnostik ahamiyati | 0 | 0 | 11 | **11** | 0 | ha | d083 |
| d083-L | TORCH infeksiyalar laborator diagnostikasi. Klinik diagnostik ahamiyati | 0 | 0 | 11 | **11** | 0 | ha | d083 |
| d085-P | Klinik laborator diagnostikada ECHT analizatorlar | 0 | 0 | 10 | **10** | 0 | ha | d085 |
| d086-P | Klinik laborator diagnostikada bioximik analizatorlar | 0 | 0 | 12 | **12** | 0 | ha | d086 |
| d087-P | Klinik laborator diagnostikada urino analizatorlar | 0 | 2 | 10 | **12** | 0 | ha | d087 |
| d116-L | Mindray BA-88A bioximik yarim avtomat analizator ishlash prinsiplari. Bioximik analizatorni dasturlashni amaliyotda o‘zlashtirish | 0 | 0 | 12 | **12** | 0 | ha | d116 |

## Taqdimotlar bo‘yicha

| Deck | Mavzular | Savollar | Holat |
|---|---|---:|---|
| d001 | d001-P, d001-L | 0 | tayyorlanmoqda |
| d002 | d002-P, d002-L | 10 | tayyor |
| d003 | d003-P, d003-L | 19 | tayyor |
| d004 | d004-A | 21 | tayyor |
| d005 | d005-P, d005-L | 13 | tayyor |
| d006 | d006-P, d006-L | 10 | tayyor |
| d007 | d007-P, d007-L | 37 | tayyor |
| d008 | d008-P, d008-L | 38 | tayyor |
| d009 | d009-A | 18 | tayyor |
| d010 | d010-P, d010-L | 13 | tayyor |
| d011 | d011-P, d011-L | 17 | tayyor |
| d012 | d012-P, d012-L | 26 | tayyor |
| d013 | d013-P, d013-L | 22 | tayyor |
| d014 | d014-P, d014-L | 16 | tayyor |
| d015 | d015-P, d015-L | 15 | tayyor |
| d016 | d016-P, d016-L | 14 | tayyor |
| d017 | d017-P, d017-L | 14 | tayyor |
| d018 | d018-P, d018-L | 13 | tayyor |
| d019 | d019-P, d019-L | 14 | tayyor |
| d020 | d020-P, d020-L | 10 | tayyor |
| d021 | d021-P, d021-L | 12 | tayyor |
| d022 | d022-P, d022-L | 11 | tayyor |
| d023 | d023-A | 22 | tayyor |
| d024 | d024-P, d024-L | 10 | tayyor |
| d025 | d025-P, d025-L | 20 | tayyor |
| d026 | d026-P | 16 | tayyor |
| d027 | d027-P, d027-L | 19 | tayyor |
| d028 | d028-P | 19 | tayyor |
| d029 | d029-P, d029-L | 15 | tayyor |
| d030 | d030-P, d030-L | 15 | tayyor |
| d031 | d031-P | 15 | tayyor |
| d032 | d032-P, d032-L | 12 | tayyor |
| d033 | d033-P, d033-L | 12 | tayyor |
| d034 | d034-A | 23 | tayyor |
| d035 | d035-P | 14 | tayyor |
| d036 | d036-P, d036-L | 11 | tayyor |
| d037 | d037-P | 14 | tayyor |
| d038 | d038-P | 11 | tayyor |
| d039 | d039-A | 22 | tayyor |
| d040 | d040-P | 12 | tayyor |
| d041 | d041-P | 12 | tayyor |
| d042 | d042-P, d042-L | 20 | tayyor |
| d043 | d043-P, d043-L | 15 | tayyor |
| d044 | d044-P, d044-L | 22 | tayyor |
| d045 | d045-P | 36 | tayyor |
| d046 | d046-P, d046-L | 32 | tayyor |
| d047 | d047-P, d047-L | 23 | tayyor |
| d048 | d048-P, d048-L | 38 | tayyor |
| d049 | d049-P | 33 | tayyor |
| d050 | d050-P | 16 | tayyor |
| d051 | d051-P | 10 | tayyor |
| d052 | d052-P | 10 | tayyor |
| d053 | d053-A | 22 | tayyor |
| d054 | d054-P | 18 | tayyor |
| d055 | d055-P, d055-L | 26 | tayyor |
| d056 | d056-P | 13 | tayyor |
| d057 | d057-P | 11 | tayyor |
| d058 | d058-P, d058-L | 13 | tayyor |
| d059 | d059-P | 26 | tayyor |
| d060 | d060-P | 11 | tayyor |
| d061 | d061-P, d061-L | 29 | tayyor |
| d062 | d062-P | 24 | tayyor |
| d063 | d063-P, d063-L | 16 | tayyor |
| d064 | d064-P | 17 | tayyor |
| d065 | d065-P | 24 | tayyor |
| d066 | d066-P | 14 | tayyor |
| d067 | d067-P | 13 | tayyor |
| d068 | d068-P | 10 | tayyor |
| d069 | d069-P, d069-L | 10 | tayyor |
| d070 | d070-P | 14 | tayyor |
| d071 | d071-P | 19 | tayyor |
| d072 | d072-P | 10 | tayyor |
| d073 | d073-P, d073-L | 34 | tayyor |
| d074 | d074-A | 25 | tayyor |
| d075 | d075-P, d075-L | 15 | tayyor |
| d076 | d076-P | 13 | tayyor |
| d077 | d077-P | 12 | tayyor |
| d078 | d078-P, d078-L | 11 | tayyor |
| d079 | d079-P, d079-L | 15 | tayyor |
| d080 | d080-P, d080-L | 14 | tayyor |
| d081 | d081-P | 10 | tayyor |
| d082 | d082-P | 12 | tayyor |
| d083 | d083-P, d083-L | 11 | tayyor |
| d084 | d084-P | 13 | tayyor |
| d085 | d085-P | 10 | tayyor |
| d086 | d086-P | 12 | tayyor |
| d087 | d087-P | 12 | tayyor |
| d088 | d088-P | 12 | tayyor |
| d089 | d089-A | 21 | tayyor |
| d090 | d090-L | 27 | tayyor |
| d095 | d095-L | 18 | tayyor |
| d101 | d101-L | 13 | tayyor |
| d106 | d106-L | 14 | tayyor |
| d112 | d112-L | 15 | tayyor |
| d116 | d116-L | 12 | tayyor |
| d121 | d121-L | 16 | tayyor |
| d127 | d127-L | 11 | tayyor |
| d143 | d143-A | 23 | tayyor |
| kapillyar-qon-olish | — | 0 | tugma yo‘q |
| gemoglobin-gemiglobintsianid | — | 0 | tugma yo‘q |
| eritrotsitlarni-sanash-kamera | — | 0 | tugma yo‘q |
| leykotsitlarni-sanash-kamera | — | 0 | tugma yo‘q |
| echt-aniqlash | — | 0 | tugma yo‘q |
| qon-surtmasi-tayyorlash-boyash | — | 0 | tugma yo‘q |
| leykoformula-sanash-mikroskop | — | 0 | tugma yo‘q |
| siydik-yigish-fizik-xossalar | — | 0 | tugma yo‘q |
| siydik-kimyoviy-tekshiruv | — | 0 | tugma yo‘q |
| siydik-chokmasi-mikroskopiya | — | 0 | tugma yo‘q |
| koprogramma-najas-tahlili | — | 0 | tugma yo‘q |
| najas-parazitologik-tekshiruv | — | 0 | tugma yo‘q |
| perianal-namuna-ostritsa | — | 0 | tugma yo‘q |
| balgam-yigish-baholash | — | 0 | tugma yo‘q |
| balgam-surtmasi-gram-sil-nilsen | — | 0 | tugma yo‘q |
| urogenital-surtma-mikroskopiya | — | 0 | tugma yo‘q |
| zardob-plazma-tayyorlash | — | 0 | tugma yo‘q |
| fotometriya-asoslari-biokimyo | — | 0 | tugma yo‘q |
| yarim-avtomat-biokimyo-analizator | — | 0 | tugma yo‘q |
| glyukoza-gox-pod-fotometrik | — | 0 | tugma yo‘q |
| alt-kinetik-fotometrik | — | 0 | tugma yo‘q |
| mochevina-ureaza-gldg | — | 0 | tugma yo‘q |
| bilirubin-umumiy-bogllangan | — | 0 | tugma yo‘q |
| gemostaz-uchun-venoz-qon-olish | — | 0 | tugma yo‘q |
| trombotsitlarni-sanash-fonio | — | 0 | tugma yo‘q |
| ichki-sifat-nazorati-laboratoriya | — | 0 | tugma yo‘q |
| laboratoriya-biologik-xavfsizlik-sanepid | — | 0 | tugma yo‘q |
