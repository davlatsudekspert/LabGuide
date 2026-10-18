# Gistologiya bo‘limi: manbalar, rasmlar, tekshirilmaganlar

Sana: 2026-10-17. Kod: `lib/features/histology/`. Rasmlar: `assets/histology/img/`
(`tool/histology_images.py`), karta sxemasi: `tool/illustrations/histology/gen_histology.py`.

Qamrov o‘quv dasturidan (`assets/curriculum/curriculum.json`, M2 «Odam ichki a’zolari
tuzilishi va vazifalari»): d005 — to‘qimalar klassifikatsiyasi va epiteliy, d006 —
biriktiruvchi to‘qima, d007 — jigar, d008 — buyrak. Muskul va nerv to‘qimasi
klassifikatsiyani to‘ldirish uchun qo‘shildi. Qon va suyak iligi hujayralari — leykoformula
bo‘limida, bu yerda takrorlanmaydi.

Holat: ekranda «qoralama» belgisi (sitologiya, spermogramma, qon guruhi kabi) —
mutaxassis (domla) tekshiruvidan keyin olib tashlanadi.

## 1. Matn manbalari (hammasi shu sessiyada ochilib o‘qildi)

| Kod | Manba | Qanday tekshirildi |
|---|---|---|
| UM | Hortsch M., et al. *University of Michigan Histology Laboratory Manual*, University of Michigan Medical School (oxirgi tahrir 2025-11-15; PDF 2026-02-12), CC BY-NC-SA 4.0. https://histology.medicine.umich.edu/ | PDF to‘liq matni (306 bet) o‘qildi; lokator = qo‘llanmadagi bet raqami |
| HPA | The Human Protein Atlas, *Dictionary — Normal tissue*: Liver, Kidney, Adipose tissue, Skeletal muscle, Heart muscle, Smooth muscle. https://www.proteinatlas.org/learn/dictionary/normal/… | Sahifa matni olindi |
| Boyd 2020 | Boyd A, Cain O, Chauhan A, Webb GJ. Medical liver biopsy: background, indications, procedure and histopathology. *Frontline Gastroenterol.* 2020;11(1):40–47. doi:10.1136/flgastro-2018-101139 (PMC6914302, CC BY 4.0) | PubMed Central to‘liq matni |
| Commons | Rasm fayl sahifalari (preparat turi, bo‘yoq, kattalashtirish) | Har fayl sahifasi (wikitext + HTML litsenziya shabloni) |

Foydalanilmadi: OpenStax *Anatomy & Physiology 2e* — sahifada litsenziya CC BY-NC-SA va
«LLM/AI mahsulotlariga kiritish taqiqlangan» degan shart borligi sababli manba sifatida
olinmadi. NCBI Bookshelf (StatPearls) — bu muhitdan reCAPTCHA bilan yopiq; Leeds
Histology Guide va SIU — Cloudflare to‘sig‘i. Shuning uchun ular ishlatilmadi.

## 2. Da’vo → manba (asosiy; har bir band kodda `HistoFact.refs` bilan)

| Karta | Da’vo | Manba, joy |
|---|---|---|
| Bir qavatli yassi | yassi hujayralar; kesmada sitoplazma ko‘rinmaydi, yadrolar bo‘yicha taniladi; endoteliy, mezoteliy | UM p. 17–18 |
| Bir qavatli kubsimon | naycha atrofida halqa; buyrak kanalchalari; yadro markazda (yig‘uvchi naychalar); filtratni o‘zgartiradi | UM p. 17, 205; HPA Kidney |
| Bir qavatli prizmatik | baland hujayra, yadrolar asosda bir qator; qadahsimon hujayra — shilliq H&E bilan bo‘yalmaydi; mikrovorsinkali hoshiya; qiya kesimda ko‘p qator ko‘rinishi | UM p. 16–17, 20, 24 |
| Ko‘p qatorli kiprikli | yadrolar turli darajada, hamma hujayra bazal membranada; kipriklar, qadahsimon hujayralar; traxeya | UM p. 18–19 |
| Ko‘p qavatli yassi | qavatlar, bazal qavat yangilaydi; muguzlanmaydigan/muguzlanuvchi; qizilo‘ngach, qin, halqum, teri; ishqalanishdan himoya | UM p. 18, 20, 32 |
| O‘tuvchi | gumbazsimon yuza hujayralar; cho‘zilganda yupqalashadi; faqat siydik yo‘llari; suv/tuz o‘tkazmaydi | UM p. 19, 22, 208, 210 |
| G‘ovak biriktiruvchi | siyrak to‘lqinsimon tolalar; asosiy modda; fibroblast; plazmatik hujayralar | UM p. 26–28, 33 |
| Zich shakllangan (pay) | parallel tolalar, hujayra kam (fibroblastlar); qisqarish yoriqlari; I tip kollagen; silliq muskul/nervdan farqi | UM p. 26, 30, 33, 50 |
| Yog‘ to‘qimasi | bitta lipid tomchisi, chetdagi yadro, kollagen tasmalar; energiya, izolyatsiya, leptin; qo‘ng‘ir yog‘ — ko‘p tomchili | HPA Adipose; UM p. 28–29, 32–33 |
| Gialin tog‘ay | shishasimon matriks (II tip kollagen ko‘rinmaydi), lakunalar, izogen guruhlar, perixondriy; siqilishga chidamli, tomirsiz | UM p. 111, 113–114 |
| Elastik tog‘ay | lakunalar, elastik tolalar (maxsus bo‘yoq), hujayra ko‘proq; quloq suprasi, epiglottis | UM p. 112–114 |
| Tolali tog‘ay | I tip kollagen tolalari, aniq lakunalar, perixondriy yo‘q; umurtqalararo disk; cho‘zilishga mustahkam | UM p. 112–114 |
| Kompakt suyak | osteon, Gavers kanali, lakunalar, kanalikulalar, Volkmann kanallari; shlif — havo qorong‘i | UM p. 116–119, 26 |
| Skelet muskuli | shoxlanmaydigan tolalar, A/I/Z, chetdagi ko‘p yadro; qiya kesim; ixtiyoriy | UM p. 46–47; HPA Skeletal muscle |
| Yurak muskuli | shoxlangan tolalar, interkalyar disklar, markaziy yadro, kapillyarlar; artefakt yoriqlar disk emas | UM p. 46–49; HPA Heart muscle |
| Silliq muskul | duksimon, chiziqsiz, markaziy yadro; ichak qavatlari; qisqarish to‘lqinlari; kollagendan farqi | UM p. 46, 49–50; HPA Smooth muscle |
| Neyron | perikarion, och yadro, yadrocha, Nissl moddasi (bazofil), dendrit/akson; glial hujayradan farqi | UM p. 10, 56–58 |
| Periferik nerv | fassikulalar, miyelin bo‘shlig‘idagi akson, epi/peri/endonevriy, to‘lqinsimon aksonlar; afferent+efferent | UM p. 26, 47, 56, 59 |
| Jigar | plastinkalar va sinusoidlar, markaziy vena, ~6 portal yo‘l, triada, gepatotsit, Kupffer; zonalar 1–3; o‘t; qon aralashishi; markaziy va portal vena farqi | UM p. 197; HPA Liver; Boyd 2020 (Histological assessment, Fig. 1, Table 2) |
| Buyrak | tanacha, Bouman kapsulasi, parietal varaq yassi; proksimal (atsidofil, cho‘tkasimon hoshiya) va distal (och, tor, past kubsimon); filtratsiya; po‘stloq | UM p. 205–207; HPA Kidney |
| Bo‘yash: H&E | gematoksilin asosli, nuklein kislotalar; eozin kislotali; ranglar; shilliq bo‘yalmaydi; jigar biopsiyasida birinchi | UM p. 6, 16; Boyd 2020 (Staining, Table 1) |
| Bo‘yash: Masson, elastik, kumush, PAS, LFB | ranglar va nima ko‘rsatadi | UM p. 7–9, 29, 50; Boyd 2020 Table 1 |

## 3. Rasmlar (hammasi Wikimedia Commons; tekshirildi 2026-10-17)

Har fayl sahifasi ochildi: litsenziya shabloni, muallif, asl izoh. Rasm ko‘z bilan
tekshirildi (nom va ko‘rinish mos). Ishlov: faqat kichraytirish (eni ≤ 900 px), JPEG 80,
kesish va yozuv qo‘shish yo‘q. Jami ≈ 3,3 MB.

| Ilova fayli | Commons fayli | Muallif | Litsenziya | Asl izoh (qisqa) | Bo‘yoq (faylda) |
|---|---|---|---|---|---|
| simple_squamous | Epithelial Tissues Simple Squamous Epithelium (41722161021).jpg | Berkshire Community College Bioscience Image Library | CC0 | whole mount: human epithelium, 200x | yozilmagan |
| simple_cuboidal | Epithelial Tissues Simple Cuboidal Epithelium (41681552432).jpg | Berkshire CC | CC0 | cross section: kidney tubule, 200x | yozilmagan |
| simple_columnar | Epithelial Tissues Simple Columnar Epithelium (27854453538).jpg | Berkshire CC | CC0 | cross section: mammalian gut, 400x | yozilmagan |
| pseudostratified | Epithelial Tissues Pseudostratified Columnar Epithelium (26915091897).jpg | Berkshire CC | CC0 | cross section: mammalian trachea, 200x | yozilmagan |
| stratified_squamous | Epithelial Tissues Stratified Squamous Epithelium (40230837610).jpg | Berkshire CC | CC0 | cross section: stratified squamous epithelium, 100x | yozilmagan |
| transitional | Epithelial Tissues Transitional (27025225607).jpg | Berkshire CC | CC0 | cross section: urinary bladder, 400x | yozilmagan |
| loose_ct | Connective Tissue Loose Aerolar (41743648512).jpg | Berkshire CC | CC0 | tissue spread, 100x | yozilmagan |
| dense_regular | Connective Tissue White Fibrous Connective (27986735128).jpg | Berkshire CC | CC0 | long section: tendon, 100x | yozilmagan |
| adipose | Connective Tissues Adipose (26915768737).jpg | Berkshire CC | CC0 | cross section, 200x | yozilmagan |
| hyaline | Connective Tissue Hyaline Cartilage (26989336187).jpg | Berkshire CC | CC0 | cross section: hyaline cartilage, 200x | yozilmagan |
| elastic_cartilage | Connective Tissue Elastic Cartilage (41855666011).jpg | Berkshire CC | CC0 | cross section: mammalian elastic cartilage, 100x | yozilmagan |
| fibrocartilage | Connective Tissue Fibrocartilage (27988652098).jpg | Berkshire CC | CC0 | cross section: fibrocartilage, 400x | yozilmagan |
| bone | Connective Tissue Compact Bone (41068142774).jpg | Berkshire CC | CC0 | cross section: ground human bone, 200x | (shlif, bo‘yalmagan) |
| skeletal | Muscle Tissue Skeletal Muscle Fibers (40153601630).jpg | Berkshire CC | CC0 | “Cross section: teased skeletal muscle”, 200x | yozilmagan |
| cardiac | Cardiac muscle histology 400x.jpg | Alexander G. Cheroske | CC BY-SA 4.0 | cardiac muscle, light microscope, 400x | yozilmagan |
| smooth | Muscle Tissue Smooth (40087100000).jpg | Berkshire CC | CC0 | cross section: smooth muscle, 400x | yozilmagan |
| neuron | Nervous Tissue Spinal Cord Motor Neuron (41850850452).jpg | Berkshire CC | CC0 | smear: spinal cord, 200x | yozilmagan |
| nerve | Nervous Tissue Nerve Bundle (40106758860).jpg | Berkshire CC | CC0 | cross section: nerve, 100x | yozilmagan |
| liver | Histopathology of liver zones.jpg | Boyd A, Cain O, Chauhan A, Webb GJ (Frontline Gastroenterol 2020, Fig. 1) | CC BY 4.0 | normal liver, portal tract, central vein, zones 1–3 | Reticulin |
| kidney | Benign kidney -- intermed mag.jpg | Nephron (Commons foydalanuvchisi) | CC BY-SA 3.0 (yoki GFDL) | benign kidney on biopsy | H&E |
| stain_pas (bo‘yash sahifasi) | Renal corpuscle.jpg | Ed Uthman | CC BY-SA 2.0 | renal corpuscle, PAS | PAS |

Eslatmalar:
- Berkshire fayllarida bo‘yoq yozilmagan — ilovada «manbada ko‘rsatilmagan». Ko‘rinishidan
  taxmin qilib yozilmadi.
- `skeletal`: fayl izohida «Cross section», lekin rasmda tolalar bo‘ylama ko‘rinadi.
  Shuning uchun ilovada «kesma turi» yozilmadi, faqat «ajratilgan (teased) tolalar».
- `liver`: Commons izohida belgilar «P» va «V», rasmning o‘zida esa «Portal triad»,
  «Central vein», «Zone 1–3» so‘zlari bor. Ilovada rasmdagi yozuvlar tarjima qilib berildi.
- `fibrocartilage`: rasm nomga mos, lekin lakunalar unchalik aniq emas — kartada bor,
  «Bu qaysi to‘qima?» mashqiga kiritilmadi.
- Karta rasmi (`assets/histology/card.png`) — LabGuide sxemasi (bir qavatli prizmatik
  epiteliy, qadahsimon hujayra, mikrovorsinkalar, bazal membrana; UM p. 16–17), mikrofoto emas.

## 4. Atamalar

Ruscha atamalar ruscha Vikipediya maqolalari bilan solishtirildi (Эпителий, Соединительная
ткань, Хрящевая ткань, Костная ткань, Остеон, Мышечная ткань, Сердечная мышечная ткань,
Нерв, Нейрон, Печень, Нефрон, Жировая ткань, Окраска гематоксилином и эозином):
однослойный плоский/кубический/призматический, многорядный, многослойный плоский
(не)ороговевающий, переходный эпителий (уротелий), бокаловидные клетки, щёточная каёмка,
рыхлая волокнистая и плотная оформленная соединительная ткань, гиалиновый/эластический/
волокнистый хрящ, надхрящница, остеон, гаверсов канал, лакуны, канальцы,
поперечнополосатая скелетная/сердечная, гладкая мышечная ткань, вставочные диски,
вещество Ниссля (тигроид), эпиневрий/периневрий/эндоневрий, печёночная долька, балки,
синусоиды, центральная вена, триада, почечное тельце, клубочек, капсула Боумена —
Шумлянского, проксимальный/дистальный каналец.

**Tekshirilmagan (mutaxassisga savol):**
- Vikipediya darslik emas — ruscha atamalarni rus tilidagi gistologiya darsligi
  (masalan, Афанасьев Ю. И. va boshq. «Гистология, эмбриология, цитология») bilan
  solishtirish kerak. Bu muhitda darslik matni yo‘q edi.
- O‘zbekcha atamalar (bir qavatli prizmatik, ko‘p qatorli kiprikli, o‘tuvchi epiteliy,
  g‘ovak tolali va zich shakllangan biriktiruvchi to‘qima, interkalyar disklar, koptokcha,
  Bouman–Shumlyanskiy kapsulasi va h.k.) o‘zbek tilidagi gistologiya darsligi bilan
  solishtirilmagan.
- «Плёночный препарат» (tissue spread) va «тотальный препарат» (whole mount) — ruscha
  tarjima tanlovi, manba bilan tasdiqlanmagan.

## 5. Kiritilmagan (tasdiqlangan rasm yoki manba yetmadi)

- Retikulyar to‘qima (Berkshire rasmida tolalar kichik o‘lchamda aniq emas).
- Qo‘ng‘ir yog‘ — faqat «adashtiriladi» qatorida matn sifatida.
- Teri, oshqozon, ichak, o‘pka, yurak devori qavatlari, taloq, limfa tugun, oshqozon osti va
  qalqonsimon bez — M2 da alohida mavzu yo‘q; bu sessiyada har biri uchun tekshirilgan rasm
  va matn jamlanmadi.
- Jigar gepatotsitlarining katta kattalashtirishdagi H&E rasmi (Commons: «Liver-H&E.jpg»,
  CC BY-SA 4.0) — mos, lekin bitta kartaga bitta rasm qoidasi uchun olinmadi.
- Jigar uchun «Liver (254 13).jpg» — faylda H&E deyilgan, lekin ranglari sariq-yashil,
  shuning uchun olinmadi.
- Fibroz, sirroz va boshqa patologiya — bo‘lim faqat normal gistologiya.

## 2026-10-18 tibbiy ko‘rib chiqish tuzatishlari

- LFB: «miyelin va Nissl moddasini bo‘yaydi» → «asosan miyelinni (Klyuver–Barrera usulida
  hujayralar va Nissl moddasi uchun qo‘shimcha bo‘yoq bilan)». Michigan p. 9 Nissl deydi, lekin u
  keltirgan Klüver & Barrera 1953 — «Combined Staining of Cells and Fibers»; mutaxassis tasdig‘i kerak.
- Jigar: uz «o‘rtacha oltitagacha» → «o‘rtacha oltita» (HPA Liver: «on average by six portal tracts»).
- Batafsil: `docs/AUDIT_2026-10-18_MEDICAL_REVIEW.md`.
