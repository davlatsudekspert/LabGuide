# Koprologiya va parazitologiya bo‘limi: manbalar, rasmlar, tekshirilmaganlar

Sana: 2026-10-18. Kod: `lib/features/coprology/` (`copro_content.dart` — matn va manbalar,
`copro_scheme.dart` — vektor sxemalar va nisbiy o‘lcham diagrammasi, `copro_screens.dart`).
Yo‘l: `/lab/coprology` (`collect`, `macro`, `micro`, `micro/:id`, `occult`, `parasites`, `parasites/:id`).
Karta: `tool/illustrations/coprology/gen_coprology.py` → `tool/illustrations/render_card.cjs` →
`assets/coprology/card.png` (namuna idishi va lupa ostida askarida tuxumi sxemasi; matnsiz).
Test: `test/widget/coprology_test.dart`. Qaror: D-61.

Bog‘liq: pack kartalari `stool-analysis`, `stool-ova-parasites`, `pinworm-test`, `fecal-occult-blood`;
amaliy protokollar `koprogramma-najas-tahlili`, `najas-parazitologik-tekshiruv`, `perianal-namuna-ostritsa`.

## 1. Manbalar (hammasi shu sessiyada ochib o‘qildi)

| Kod | Manba | Qanday o‘qildi |
|---|---|---|
| JSST | WHO. *Manual of basic techniques for a health laboratory*, 2nd ed., 2003 (`CalcSources.whoBasicLab2003`) | PDF matn qatlami; 4-bob, 105–159-betlar. Matnda «mm» — shrift sababli µm (eritrotsit «7.5–8 mm») |
| Darslik | Kurbonova Z.Ch. *Klinik laboratoriya tashxisi*: darslik. Toshkent: TTA, 2023 (domla bergan; url yo‘q) | Matn; 2-bob, 38–48-betlar (bet raqami bet oxirida) |
| MedlinePlus | Ova and Parasite Test; White Blood Cell (WBC) in Stool; Fecal Occult Blood Test (FOBT) | Sahifa matni |
| Merck | Malik Z. Overview of Malabsorption. *Merck Manual Professional*, 2025 | «Confirming malabsorption» |
| DPDx | CDC DPDx: Ascariasis, Enterobiasis, Hymenolepiasis, Giardiasis, Amebiasis, Trichuriasis, Taeniasis; Stool specimen processing | Sahifalar (WebFetch); ko‘rib chiqilgan sanalar manba yozuvida |

«Darslik» manbasi faqat xalqaro ochiq manbada topilmagan koprogramma talqinlari uchun (mushak tolasi,
biriktiruvchi to‘qima, neytral yog‘, kraxmal, shilliq, leykotsit/eritrotsit me’yori, makroskopik ko‘rsatkichlar);
bunday band matnida «Darslik/Учебник/Textbook» so‘zi bor — test buni tekshiradi.

## 2. Da’vo → manba (asosiy)

| Da’vo | Manba, joy |
|---|---|
| ≈ 100 g, toza quruq qopqoqli idish, siydiksiz, qo‘lqop; 1–4 soat; suyuq/shilliqli avval | JSST 4.2.1, 107-b. |
| Koprogramma 8–12 soat; yaroqsiz namunalar (huqna, surgi, moy, temir/vismut/bariy) | Darslik 38-b. |
| Bir nechta namuna; manfiy natija ma’nosi | MedlinePlus O&P |
| Amyobiaz — 10 kunda 3 ta namuna; lyambliozda takroriy namuna | DPDx Amebiasis, Giardiasis |
| Formalin 1:3, PVA | JSST 4.2.4, 109–110-b. |
| Konsistensiya yozuvi; rang (qora/och sariq/oq); qon va shilliq | JSST 4.2.2–4.2.3, 107-b. |
| Miqdor, shakl, rang, reaksiya, aralashmalar | Darslik 38–42-b. |
| To‘g‘ridan-to‘g‘ri mikroskopiya nimani aniqlaydi | JSST 4.2.3, 107-b. |
| Koprogramma jadvali (me’yor) | Darslik 44–45-b. |
| Mushak tolalari: ko‘rinishi (100–200 µm) | JSST 4.4.1 «Features not to be mistaken for eggs», 144–145-b. |
| Kreatoreya talqini | Darslik 45-b. |
| Biriktiruvchi to‘qima | Darslik 46-b. |
| Yog‘: metilen ko‘ki; neytral yog‘ talqini | Darslik 46-b. |
| Sovun, moy tomchisi ko‘rinishi | JSST 144–145-b. |
| Sudan III — miqdoriy emas; 72 soat, ≥ 100 g/kun, > 7 g/kun; ≥ 40 g/kun | Merck «Confirming malabsorption» |
| Kraxmal ko‘rinishi (50–100 µm, yod — binafsha) | JSST 144–145-b.; talqini — Darslik 46-b. |
| Leykotsit ko‘rinishi va yiring | JSST 4.3.2, 125-b. |
| Leykotsit ma’nosi, manfiy natija cheklovi | MedlinePlus WBC in Stool |
| Leykotsit 0–5, eritrotsit 0–2, talqinlar | Darslik 47-b. |
| Eritrotsit 7,5–8 µm | JSST 4.4.1, 126–127-b. |
| E. histolytica trofozoitida eritrotsitlar | JSST 4.3.1, 113-b. |
| Shilliq va G. intestinalis; shilliq talqini | JSST 115, 125-b.; Darslik 46–47-b. |
| gFOBT va FIT, tayyorgarlik, natija, har yili | MedlinePlus FOBT |
| Benzidin kanserogen; 1 kunlik cheklov | JSST 4.6, 157-b. |
| Boyitishdan oldin to‘g‘ridan-to‘g‘ri tekshiruv | JSST 4.5, 152-b. |
| Willis — qaysi tuxumlar uchun (yaramaydiganlar) | JSST 4.5.1, 152–153-b. |
| Formalin–efir (2000 g 1 daq.) va CDC (500 × g 10 daq.) | JSST 4.5.2, 153–154-b.; DPDx Specimen processing |
| Cho‘ktirish tavsiyasi; flotatsiya kamchiligi | DPDx Specimen processing |
| Askarida: 45–70 / 45–75 µm, 45–90 / ≤ 90 µm; mamillyar qobiq; dekortikatsiya | JSST 127–128, 133-b.; DPDx |
| Ostritsa: 50–60 (× 20–30) µm, asimmetrik; lenta usuli, ertalab | JSST 135–137-b.; DPDx |
| H. nana: JSST 40–60 µm, DPDx 30–50 µm; qutb iplari, 6 ilmoq; H. diminuta | JSST 139-b.; DPDx |
| Giardia: sista 8–12 / 8–19 µm, 2–4 yadro; trofozoit 10–18 / 10–20 µm; antigen | JSST 115, 121-b.; DPDx |
| E. histolytica/dispar: sista 12–15 µm, 4 yadro, to‘mtoq xromatoid; morfologik farqlanmaydi; antigen/PCR; E. coli farqi | JSST 118, 122–123-b.; DPDx |
| Trichuris: 50–65 / 50–55 × 20–25 µm, bochkasimon, tiqinlar | JSST 144-b.; DPDx |
| Taenia: DPDx 30–35 µm, JSST matnida 30–80 µm; 6 ilmoq; tur — bo‘g‘im/skoleks | DPDx; JSST 143–144-b. |

## 3. Rasmlar

Mikrofoto ishlatilmadi. DPDx sahifalaridagi rasmlarning bir qismi uchinchi tomonlarga tegishli (masalan,
askarida sahifasida «Image courtesy of The Leiden University Medical Center», «Orange County Public Health
Laboratory»), har rasm litsenziyasini alohida tasdiqlash imkoni bo‘lmadi. Shuning uchun 7 parazit uchun ilovaning
o‘z vektor sxemasi (`CpSchematic`, `CustomPainter`) — ekranda «Sxema (foto emas)» belgisi va «mikroskopdagi
ko‘rinish boshqacha» izohi bilan. Sxema faqat manbada tasvirlangan belgilarni ko‘rsatadi (mamillyar qobiq,
asimmetriya va lichinka, qutb iplari va 6 ilmoq, 4 yadro va fibril, to‘mtoq xromatoid, ikki tiqin, radial
chiziqli qalin qobiq); o‘lcham va rang shartli. Nisbiy o‘lcham diagrammasi — DPDx uzunliklari (askarida —
urug‘langan tuxum) va JSST eritrotsiti.

## 4. Kiritilmaganlar va sababi

- **Koprogramma talqinlari uchun xalqaro ochiq manba** topilmadi (StatPearls/NCBI Bookshelf reCAPTCHA bilan
  to‘sildi) — darslik bilan berildi va belgilandi.
- **Darslikdagi gvayak (efir bilan), benzidin, Gregersen sinamalari, sulema bilan Shmidt reaksiyasi** — yonuvchan
  efir, kanserogen benzidin (JSST), simob tuzi; kiritilmadi (amaliy protokol bilan bir xil qaror).
- **Darslikdagi «Lyugol bilan kletchatka ko‘karadi… amiloreya»** jumlasi — matnda kraxmal va kletchatka
  aralashgan; kiritilmadi (kraxmalning yod bilan rangi JSST dan).
- **Kristallar, kletchatka, bakteriyalar, sterkobilin** — topshiriq ro‘yxatida yo‘q; keyingi bosqichga.
- **Ankilostomidlar, Strongyloides, shistosomalar, Kato–Katz** — topshiriqdagi 7 parazitdan tashqari.
