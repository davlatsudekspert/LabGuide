# LabGuide — qarorlar jurnali

Har bir qaror: nima, nega, qachon qayta ko‘rib chiqiladi. Yangi qaror pastga qo‘shiladi.

## D-01. Loyiha `nfcx` repozitoriysidagi `labguide/` papkasida (2026-10-08)
Sessiya faqat `davlatsudekspert/nfcx` (NFCSTORE) repozitoriysiga ulangan edi; alohida LabGuide
repozitoriysi yo‘q. START_HERE “NFCSTORE/Forensic loyihalariga tegmang” deydi — shuning uchun
ilova o‘z-o‘zidan yetarli `labguide/` papkasida, NFCSTORE’ning birorta fayli (ildiz
`.gitignore`, CI workflow’lar ham) o‘zgartirilmagan. Branch: `claude/new-session-xqozot`;
NFCSTORE CI faqat `main` push’da ishlaydi, bu branch uni ishga tushirmaydi.
**Qayta ko‘rish:** alohida repo ochilsa — `git subtree split -P labguide` bilan tarix saqlangan
holda ko‘chirish.

## D-02. Flutter 3.47.6 + `material_ui` paketi (2026-10-08)
Yangi loyiha → START_HERE tavsiyasi bo‘yicha Flutter. Versiya taxmin qilinmadi: rasmiy
`releases_linux.json` dagi joriy stable (3.47.6, Dart 3.13.5). Flutter 3.47 da Material
kutubxonasi `package:material_ui` ga ko‘chirilmoqda (`flutter/material.dart` uchun rasmiy
data-driven fix bor), `go_router 18` ham shu paketni ishlatadi — shuning uchun ilova bitta
MaterialApp/Theme turi bilan `material_ui` dan foydalanadi.

## D-03. Navigatsiya: go_router `StatefulShellRoute.indexedStack`
Har tab o‘z navigation stacki va scroll holatini saqlaydi (IndexedStack). Analit kartasi
har tab ichida ochiladi (`/home/analyte/:id`, `/tests/analyte/:id`, `/library/saved/analyte/:id`),
shunda “orqaga” foydalanuvchini kelgan joyiga qaytaradi. Faol tab qayta bosilsa — ildiziga.
Android “orqaga” tab ildizida bo‘lsa avval Bosh tabga qaytaradi.

## D-04. Holat boshqaruvi: ChangeNotifier + InheritedWidget (`AppScope`)
Qo‘shimcha state kutubxonasi kiritilmadi: controllerlar kichik, testda oson almashtiriladi
(`MemoryKeyValueStore`, demo/unconfigured adapterlar). Murakkablik oshsa (server sinxronlash,
guruhlar) Riverpod ko‘rib chiqiladi.

## D-05. Router faqat onboarding holati o‘zgarganda yangilanadi
Dastlab `refreshListenable: settings` edi — rol saqlanganda kechikkan router yangilanishi
endigina yopilgan rol sahifasini qaytarib qo‘ydi (widget test topdi). Endi `OnboardingChanges`
faqat `onboarded` o‘zgarishini uzatadi.

## D-06. i18n: gen-l10n ARB (`lib/l10n/app_{uz,ru,en}.arb`)
UI satrlari ARB da, klinik kontent esa kontent paketida (UI satrlariga qotirilmaydi).
Boshlang‘ich til: tizim tili uz/ru/en bo‘lsa shu, aks holda o‘zbekcha. O‘zbek matnida
prototipdagi ‘ (U+2018) va ’ (U+2019) belgilari; qidiruv barcha apostrof variantlarini bir xil
deb hisoblaydi.

## D-07. Shrift: Inter (OFL), ilovaga qo‘shilgan
Prototip Inter’dan foydalanadi. Oflayn ishlashi uchun 400/500/600/700 statik TTF lar
`assets/fonts/` da (Google Fonts, Inter 4.001; litsenziya `Inter-OFL.txt`). Kirill, o‘zbek
apostroflari, ₁₂, ≥, → glyphlari tekshirilgan.

## D-08. Scroll-collapse sarlavha ro‘yxatdan tashqarida
Katta sarlavha (eyebrow + sarlavha + izoh) yuqori panel ostida turadi; kontent pastga
surilganda 14 px hysteresis bilan ixchamlashadi, yuqoriga 14 px qaytganda kengayadi, ro‘yxat
tepasida doim kengaygan. Faqat foydalanuvchi scroll’i hisobga olinadi (layout o‘zgarishi
tebranish keltirmaydi); kontent qisqa bo‘lsa ixchamlashmaydi. 200 ms, reduced motion’da 0.
Welcome sahifasida (rasm bilan) sarlavha kontent bilan birga suriladi. Uzun so‘zli sarlavha
(“Аланинаминотрансфераза”) so‘z o‘rtasidan bo‘linmasligi uchun 24 px gacha kichrayadi.

## D-09. Sahifa o‘tishlari: Android 200 ms, iOS — tizim (Cupertino)
DESIGN_REQUIREMENTS 200 ms o‘tishni so‘raydi; iOS’da esa chetdan surib qaytish imo-ishorasi
muhimroq, shuning uchun iOS’da `CupertinoPageTransitionsBuilder` qoldirildi.

## D-10. Kontent: tekshiriladigan JSON paket (hozircha), lokal DB keyinroq
START_HERE “core matnlar lokal DB” deydi. Hozirgi hajm (35 ta manbali karta, 52 manba,
71 savol, 25 kutubxona yozuvi; ~0,7 MB) uchun xotirada yuklanadigan, sha256 bilan
tekshiriladigan paket yetarli va ishonchli; tekshiruv fon isolate’da (`compute`) bajariladi.
Sxema DB jadvallariga to‘g‘ridan-to‘g‘ri mos (analytes/claims/sources/library/lessons/…).
**Qayta ko‘rish:** yuzlab karta yoki to‘liq matnli qidiruv kerak bo‘lganda drift/SQLite + FTS.
Atomar o‘rnatish (`PackInstaller`) va manifest formati yuklanadigan paketlar uchun tayyor.

## D-11. Klinik kontent qoidalari
- Har da’vo manbaga (`refs`, sahifa bilan) bog‘langan; manbasiz da’vo, review’siz
  `published`/`reviewed`, struktura-kartada da’vo — paket rad etiladi.
- Referens interval va diagnostik chegara alohida; glyukozada referens interval berilmagan
  (laboratoriya blankidan), NIDDK chegaralari mg/dL da, manbadagidek. Molyar massasi bor
  analitda mmol/L ekvivalenti ham ko‘rsatiladi, lekin “hisoblangan” deb belgilanadi va izohda
  manbada yo‘qligi aytiladi (D-29).
- Glyukoza matni 2026-10-08 da MedlinePlus va NIDDK sahifalari bilan qayta solishtirildi;
  MedlinePlus’dagi sabablar ro‘yxati to‘liqroq bo‘lgani uchun matn kengaytirildi.
  Mustaqil mutaxassis review’i **yo‘q** — karta “manbali o‘quv namuna, review kutilmoqda”.
- Boshqa 34 analit ham keyinchalik manbali o‘quv namunasiga aylantirildi (D-19); hech biri
  mustaqil review’dan o‘tmagan. “Faqat tuzilma” holati yangi analit uchun saqlanadi.
- Birlik konvertori faqat tasdiqlangan molyar massasi bor analit uchun (glyukoza 180,156
  g/mol, IUPAC atom massalaridan; hozir 13 analit — D-22); umumiy koeffitsiyent yo‘q.
- Natijani avtomatik talqin qilish, tashxis yoki doza chiqarish yo‘q.

## D-12. Domla materiallari uchun kengaytiriladigan sxema (2026-10-08)
`LibraryItem` (nomi, mualliflar, yil, nashr, til, kategoriyalar, mavzular, kim bergan,
import holati, tarqatish huquqi, eski nashr, alohida paket), `SourceRef` (manba + sahifa),
`Discrepancy` (≥2 pozitsiya, hal qilish faqat tekshiruvchi va izoh bilan), `Lesson`, draft
testlar. Validator: kelmagan/kataloglanmagan materialdan iqtibos keltirib bo‘lmaydi; tarqatish
ruxsati (sana + dalil) qayd etilmaguncha to‘liq kitob paketi rad etiladi. Tartib:
[CONTENT_INTAKE.md](CONTENT_INTAKE.md).

## D-13. OTP adapterlari
`createOtpAdapter`: debug → `DemoOtpAdapter` (kod 123456, 5 daq, 5 urinish, 60 s); release
va profile → `UnconfiguredOtpAdapter` (hech narsa qabul qilmaydi). `DemoOtpAdapter` release
bayrog‘i bilan yaratilsa xato beradi. Demo email sessiyasi qayta ochilganda tiklanmaydi.
Production adapter E bosqichda: kod va limitlar serverda, token secure storage’da.
Hozirgi `auth.session = email:<manzil>` belgisi vaqtinchalik: E bosqichda sessiya faqat
secure storage’dagi server tokeni server tomonidan tasdiqlangandan keyin tiklanadi.

## D-14. Tab nomlari va kenglik siyosati
Tab nomi 11 px, katta shrift sozlamasida 1.15 gacha kattalashadi. Teng ulushga sig‘masa
(320 px da “Библиотека”), kengliklar nom uzunligiga mutanosib taqsimlanadi (har tab ≥ 48 px);
shunda ham sig‘masa masshtab 1.0. Matn hech qachon 11 px dan kichraymaydi va qirqilmaydi.

## D-15. Biznes sozlamalari konfiguratsiyada
Narxlar qotirilmagan (store’dan olinadi), qurilma soni taklifi `AppConfig.maxActiveDevicesProposal = 2`.
Xarid/tiklash tugmalari store ulanmaguncha o‘chirilgan va “hali mavjud emas” deb yozilgan.

## D-16. Bundle ID / applicationId: `uz.labguide.app` (2026-10-08)
`flutter create` bergan `uz.labguide.labguide` hech qayerda ro‘yxatdan o‘tmasdan oldin toza
`uz.labguide.app` ga almashtirildi (Android namespace/applicationId, Kotlin paketi, iOS
PRODUCT_BUNDLE_IDENTIFIER). App Store / Play’da ro‘yxatdan o‘tgach o‘zgartirib bo‘lmaydi.

## D-17. Muhitga oid (repoga kirmaydi)
Bulut konteynerida Maven Central 429 qaytardi; `~/.gradle/init.d/maven-mirror.gradle`
mavenCentral manzilini Google’ning rasmiy ko‘zgusiga yo‘naltiradi. Loyiha fayllari o‘zgarmagan.

## D-18. Klinik kalkulyatorlar — faqat birlamchi manbadan tekshirilgan formulalar (2026-10-08)
eGFR CKD-EPI 2021 (Inker 2021, 2-jadval; NKF sahifasi), ACR va KDIGO 2012 A toifasi
(6-jadval), anion farq (Kraut va Madias; albumin tuzatishi Figge 1998), tuzatilgan kalsiy,
LDL (Friedewald 1972; Sampson 2020), non-HDL, hisoblangan osmolyallik (Rasouli 2016; SI
shakli Lynd 2008), HbA1c NGSP↔IFCC (NGSP master tenglamasi) va eAG (ADAG, Nathan 2008).
- Har koeffitsiyent birlamchi matndan o‘qib tekshirildi; test qiymatlari mustaqil Python
  hisobidan (eAG — ADAG 2-jadvali bilan bir xil).
- Kalsiy: Payne 1973 maqolasidagi asl formula `Ca − albumin + 4.0` (mg/dL, g/dL). Keng
  tarqalgan 0.8 koeffitsiyentli variant manbada yo‘q — ishlatilmadi, ekranda izohlangan.
- Figge “normal albumin” qiymatini bermaydi → foydalanuvchi o‘z laboratoriyasi qiymatini
  kiritadi; ilova son to‘qimaydi.
- Formula doirasidan tashqarida natija berilmaydi: yosh < 18 (eGFR), TG > 400 mg/dL
  (Friedewald), TG > 800 mg/dL (Sampson), A1C 4–12 % dan tashqari (eAG).
- Kirish oralig‘i (masalan kreatinin 0.1–30 mg/dL) klinik chegara emas — birlik adashishini
  ushlash uchun; xabar oraliqni kiritilgan birlikda ko‘rsatadi.
- KDIGO toifalari rangsiz, “tasnif, tashxis emas” izohi bilan; toifa ekrandagi (yaxlitlangan)
  qiymat bo‘yicha — son va toifa doim mos.
- SI birliklar birinchi tanlangan (O‘zbekiston/MDH laboratoriyalari shuni beradi).
- Formula, cheklov va manba matnlari kod bilan birga `lib/features/tools/calc_info.dart` da:
  formula o‘zgarsa, izoh ham shu commit’da o‘zgaradi. Bibliografiyada faqat tekshirilgan
  maydonlar (muallif, sarlavha, jurnal, yil, DOI) — jild/sahifa yozilmagan.

## D-19. 35 ta analit kartasi — AQSh davlat sahifalaridan, draft holatida (2026-10-08)
- Manbalar: MedlinePlus lab-test sahifalari (asosiy), NIDDK, NHLBI — jami 52 ta; har birida
  URL, kirish sanasi va sahifaning yangilangan/ko‘rib chiqilgan sanasi (`source_date`).
- Matn uch tilda, manbadan o‘z so‘zlarimiz bilan; har bir da’vo manba va bo‘lim nomi
  (`locator`) bilan. Har da’vo uchun so‘zma-so‘z inglizcha iqtibos yig‘ilib tekshirildi
  (ilovaga kirmaydi): sahifalar qayta yuklanib, 708 iqtibosdan 704 tasi avtomatik, 2 tasi
  qo‘lda (havola/bo‘shliq farqi) tasdiqlandi; rasmdan o‘qilgan 2 tasi olib tashlanib,
  eGFR chegarasi matnli manbalarga (NIDDK CKD tests + eGFR tenglamalari sahifasi) bog‘landi.
- Referens interval yo‘q. Diagnostik chegara faqat manba aniq bergan joyda: HbA1c, OGTT
  (NIDDK jadvali), eGFR < 60 va ≤ 15, ACR > 30 mg/g; mikro/makroalbuminuriya — “manba
  atamasi” sifatida. Qat’iy chegaralar uchun `low_exclusive` / `high_exclusive` qo‘shildi
  (“< 60”, “> 30” manbadagidek, “≤/≥” emas).
- Populyatsiya manbadagidek: NIDDK “if you are not pregnant” deydi — yosh aytilmagan, shuning
  uchun “kattalar” so‘zi olib tashlandi (glyukoza kartasidagi oldingi xatoim ham tuzatildi).
- Lipid “sog‘lom daraja” jadvallari, xavfga bog‘liq maqsadlar va CRP “sog‘lom miqdor” ataylab
  kiritilmadi — ular populyatsiya/xavfga bog‘liq va referens intervalga o‘xshaydi.
- Birlik faqat manba ko‘rsatgan bo‘lsa (fermentlar sahifalarida yo‘q → karta birliksiz).
- Hammasi `status: draft`, `content_state: sourced_sample`, review `pending` — mustaqil
  ekspert ko‘rmagan. Manba qayta foydalanish huquqi konservativ (`verify_before_distribution`).
- Tahririy izohlar `review_note` da (ilovada ko‘rsatilmaydi); ekspert uchun ochiq savollar:
  [CONTENT_REVIEW_NOTES.md](CONTENT_REVIEW_NOTES.md).
- Testlar: 68 ta yangi savol (har analitga 2 ta), hammasi draft, manba va mavzu (`topic_ids`)
  bilan. Mashq endi mavzu bo‘yicha: guruh, bitta analit (kartadan) yoki aralash 10 ta.

## D-20. Ichki sifat nazorati: Levey–Jennings + Westgard qoidalari (2026-10-08)
- Manba: Westgard JO, Barry PL, Hunt MR, Groth T. *A multi-rule Shewhart chart for quality
  control in clinical chemistry.* Clin Chem 1981;27(3):493–501 (doi:10.1093/clinchem/27.3.493) —
  to‘liq matn (arxivlangan PDF) o‘qib tekshirildi; Westgard sayti darslari qo‘shimcha.
- Qoidalar maqoladagidek: 1-2s ogohlantirish; 1-3s; 2-2s (seriya ichida ikki material bo‘ylab
  va bir material ketma-ket ikki seriyada); R-4s faqat seriya ichida; 4-1s va 10x bir material
  ichida (4/10 seriya) yoki materiallar bo‘ylab (joriy + oldingi seriya / 5 seriya).
  Chegara qat’iy: aynan ±2 SD buzilish emas (“exceeds”).
- 1981 tartibida 1-2s “eshik” edi; Westgard sayti kompyuter tizimlari uchun bu shart emasligini
  aytadi. Ilova har seriyada hamma rad qoidalarini tekshiradi, 1-2s ni ogohlantirish deb
  ko‘rsatadi — shuning uchun 2s siz 4-1s ham rad deb belgilanadi (klassik qo‘lda tartibdan
  qattiqroq; ekranda izohlangan).
- Maqsadli o‘rtacha va SD ni ilova bermaydi: foydalanuvchi kiritadi va manbasini belgilaydi.
  Maqola: laboratoriyaning o‘z ma’lumotidan (~20 o‘lchov, keyin qayta hisoblash); ishlab
  chiqaruvchi qiymati tanlansa ogohlantirish ko‘rsatiladi (varaqadagi oraliqlar ko‘pincha keng).
- Grafik: ±1s/±2s/±3s chiziqlari (W81 2-rasm), nuqta holati shakl bilan ham (doira/uchburchak/
  kvadrat) — faqat rangga tayanmaydi; ±4 SD dan tashqarisi strelka bilan.
- Ma’lumot faqat qurilmada (`qc.data`), buzilgan yozuv ustidan yozilmaydi; “lokal ma’lumotlarni
  o‘chirish” QC ni ham o‘chiradi. Kuzatilgan n, x̄, SD (n−1), CV % ko‘rsatiladi.

## D-21. LabGuide alohida public repoga ko‘chadi (2026-10-08)
nfcx hisobida GitHub Actions to‘lovi o‘tmagani sabab barcha ishlar `startup_failure` bilan
to‘xtadi. Egasi “public qilib ishlataver” dedi: public repoda standart runnerlar (macOS ham)
bepul. Reja: `git subtree split -P labguide` bilan tarix saqlangan holda yangi
`labguide` repoga; CI `labguide/.github/workflows/build.yml` da (split’dan keyin repo ildizida
`.github/` bo‘ladi; nfcx ichida esa ishlamaydi — NFCSTORE CI’ga tegmaydi). nfcx ildizidagi
oldingi `labguide-ios.yml` olib tashlandi. Litsenziya fayli qo‘shilmaydi (kod ko‘rinadi,
huquqlar egada). Secretlar repo sozlamalarida — kodda yo‘q ([IOS_TESTFLIGHT.md](IOS_TESTFLIGHT.md)).
Repo yaratish Claude integratsiyasiga ruxsat etilmagan (403) — egasi yaratadi.

## D-22. Birlik konvertori 13 analitga kengaytirildi (2026-10-08)
Molyar massa faqat formula + IUPAC qisqartirilgan standart atom massalaridan (C 12.011,
H 1.008, N 14.007, O 15.999; Ca 40.078, Mg 24.305, P 30.974): kreatinin 113.120, siydik
kislotasi 168.112, bilirubin 584.673 (µmol/L), xolesterin 386.664 (umumiy, HDL, LDL, non-HDL),
triglitseridlar — triolein 885.453 (an’anaviy model), kalsiy, magniy, fosfor (mmol/L).
SI birlik paketda (`si_unit`: mmol/L yoki µmol/L). Mochevina/BUN ataylab qo‘shilmadi: bir
analitda ikki asos (butun molekula vs azot) — chalkashlik xavfi; osmolyallik kalkulyatori
BUN’ni alohida qabul qiladi.

## D-23. Preanalitika — WHO 2010 qon olish qo‘llanmasidan (2026-10-08)
Manba: *WHO guidelines on drawing blood: best practices in phlebotomy*, WHO 2010 (ISBN 978 92
4 159922 1; IRIS 10665/44294) — to‘liq PDF o‘qib tekshirildi. Kiritilganlar: probirkalar tartibi
(2.2.3, 2.3-jadval; NCCLS 2003 konsensusi asosida), jadval izohlari (rang kodlari farq qiladi —
laboratoriya bilan tekshirish; aralashtirish; faqat koagulogramma), kapillyar tartib (7.1.3),
gemoliz sabablari (1.1.1), jgut (2 daqiqa — “ba’zi qo‘llanmalar” iborasi bilan, manbadagidek),
bemorni aniqlash va yorliq. Manbada yo‘q narsalar yozilmadi: aylantirishlar soni (laboratoriya
belgilaydi), och qoringa talab, “to‘shak yonida yorliqlash”. Nashr “© WHO 2010, all rights
reserved” — jadval ko‘chirilmadi, faktlar o‘z so‘zlarimiz bilan, joyi ko‘rsatilgan. Qopqoq
rangi doira bilan ham, matn bilan ham (faqat rangga tayanmaydi). Rus tilidagi nashri IRIS’da
topilmadi.

## D-24. Kutubxona katalogi: 25 ta tekshirilgan yozuv, faqat havola (2026-10-08)
Har yozuvning rasmiy sahifasi yuklab ko‘rildi, litsenziya iborasi so‘zma-so‘z saqlandi
(`licence_quote`, ilovada ko‘rsatilmaydi). Kirish turi: ochiq litsenziya (OpenStax,
LibreTexts — CC BY-NC-SA 4.0; WHO biologik xavfsizlik 4-nashr en/ru — CC BY-NC-SA 3.0 IGO;
MedlinePlus — AQSh davlat ishi), bepul o‘qish (WHO sifat menejmenti en/ru, flebotomiya,
WHO/IDF diabet hisoboti en/ru, ZiyoNET darsliklari, lex.uz hujjatlari) va faqat katalog
(SamMU e-kutubxonasi — HEMIS login; Tietz, Henry — pullik).
- Hech bir fayl yuklanmadi/tarqatilmadi — faqat bibliografik yozuv va rasmiy havola.
- **NC litsenziyalar** notijorat tarqatishga ruxsat beradi; ilovada pullik obuna rejasi bor,
  shuning uchun ularning matni paketga kiritilmaydi (faqat havola).
- **OpenStax** sahifasi kitobni LLM o‘qitish yoki generativ AI mahsulotlariga kiritishni
  yozma ruxsatsiz taqiqlaydi — matni ilovaning hech bir AI funksiyasiga berilmaydi
  (`review_note`).
- WHO “Manual of basic techniques” (2003): who.int’da CC BY-NC-SA 3.0 IGO, IRIS’da huquq
  maydoni yo‘q — tasdiqlanguncha “bepul o‘qish” deb belgilandi.
- ZiyoNET: foydalanuvchilar yuklagan fayllar, sayt “Barcha huquqlar himoyalangan” — faqat havola.
- Izohlar (nega foydali) uch tilda qayta yozildi; agent izohidagi tekshirilmagan iboralar
  (masalan, “ISO 15189 asosida”) olib tashlandi. Interfeys tilidagi materiallar birinchi.
- Topilmadi/kiritilmadi: NCBI “Clinical Methods” (sahifa reCAPTCHA bilan yopiq), TMA
  kutubxonasi (sahifalar ishlamaydi), GEOTAR-Media katalogi.

## D-25. CI yana nfcx’da; public repo va Codemagic bekor (2026-10-08)
Egasi GitHub to‘lovini tiklashini aytdi; Codemagic varianti ham bekor qilindi
(`codemagic.yaml` yozilib, commit qilinmasdan o‘chirildi). Shuning uchun D-21 (alohida public
repo) amalga oshirilmaydi: workflow nfcx ildizidagi `.github/workflows/labguide-ios.yml` ga
qaytarildi (Android sinov APK job’i qo‘shildi, secretlar `LABGUIDE_* || NOVA_*`),
`labguide/.github` olib tashlandi. To‘lov tiklanguncha CI ishga tushmaydi; kod va testlar
konteynerda tekshiriladi.

## D-26. QC maqsad tarixi, CSV eksport, ishga tushish ekrani (2026-10-08)
- **Maqsad tarixi:** yangi nazorat loti yoki qayta hisoblangan x̄/SD uchun “Maqsad yoki lotni
  almashtirish”. Eski maqsad `previous` ga o‘tadi; har seriya o‘z vaqtida amal qilgan maqsad
  bilan baholanadi (o‘tmish qayta yozilmaydi). Grafik va kuzatilgan statistika — joriy davr.
  Eski saqlangan ma’lumot (tarixsiz) o‘zgarishsiz o‘qiladi.
- **CSV:** barcha seriyalar (sana, daraja, o‘sha paytdagi lot/x̄/SD, qiymat, z, xulosa, qoidalar,
  izoh) clipboard’ga — Excel/Sheets uchun; qiymatlar nuqta bilan, CSV qo‘shtirnoq qoidasi bilan.
- **Manbalar ekrani** endi kalkulyator, QC (Westgard 1981) va preanalitika (WHO 2010) manbalarini
  ham ko‘rsatadi.
- **Ishga tushish:** Android/iOS da oq fon o‘rniga mavzuga mos fon (yorug‘ #F3F3EC, qorong‘i
  #0D1919) — qorong‘i rejimda oq “chaqnash” yo‘q; Android 12+ splash foni ham shu rang. Android
  belgisi alohida PNG (adaptive ikonka XML `<bitmap>` ichida ishlamaydi).

## D-27. QC: chegaradagi qiymat, rad etilgan seriya, zaxira nusxa (2026-10-08)
Mustaqil sharh (review A) topgan xatolar asosida:
- **Chegaradagi qiymat:** z suzuvchi nuqta xatosi bilan hisoblanadi (x̄ 5.0, SD 0.2, qiymat 5.4 →
  z = 2.0000000000000018). D-20 ga ko‘ra aynan ±k SD dagi qiymat buzilish emas, shuning uchun
  barcha taqqoslashlar `z > k + 1e-9`. Avval bu holatda 2-2s/4-1s bo‘yicha noto‘g‘ri “rad”
  chiqardi.
- **Rad etilgan seriya:** rad etilgan seriya qiymatlari keyingi seriyalarning seriyalararo
  qoidalarida (2-2s, 4-1s, 10x) va kuzatilgan x̄/SD/CV da ishlatilmaydi — xato tuzatilib, seriya
  qaytarilgan deb hisoblanadi (bitta 1-3s chiqishi SD ni ~1.6 dan 14.4 ga oshirardi). Seriya
  tarixda qoladi va “keyingi qoidalar va statistikada ishlatilmaydi” deb belgilanadi.
- **Saqlash:** avval diskka, so‘ng xotiraga yoziladi; xato bo‘lsa ekranda saqlanmagan ma’lumot
  ko‘rinmaydi va xabar chiqadi (tugma “osilib” qolmaydi). Cheksiz qiymatlar (1e400) rad etiladi.
- **Maqsad:** manba (laboratoriya/ishlab chiqaruvchi) endi har maqsadda saqlanadi; amal qilish
  sanasini tanlash mumkin (oldingi davrdan oldin emas); “kuzatilgan x̄/SD” tugmasi (rad
  etilmagan, joriy davr). n < 20 bo‘lsa Westgard 1981 dagi ~20 qiymat eslatiladi.
- **Seriya vaqti:** kechikib kiritilgan seriya uchun haqiqiy vaqt tanlanadi (kelajak emas).
- **Zaxira nusxa:** QC JSON nusxasi clipboard’ga va tekshirilgan holda tiklash (tasdiq bilan).
  Saqlangan ma’lumot o‘qilmasa — matnni nusxalash, zaxiradan tiklash yoki tasdiq bilan
  o‘chirish; avval foydalanuvchi butunlay qulflanib qolardi.
- **CSV:** `run_verdict` + `level_verdict` + `level_rules`; `= + - @` bilan boshlanadigan matn
  `'` bilan himoyalanadi (CSV formula injection).
- **Kirish:** “1,500” — ming ajratgichmi yoki o‘nlik vergulmi aniq emas, taxmin qilinmaydi
  (qayta kiritish so‘raladi). `roundHalfUp` juda katta sonlarda int64 ga o‘tmaydi.

## D-28. Qobiq, accessibility va platforma (2026-10-08)
Mustaqil sharh (review D) natijasida:
- **TalkBack:** tablar, “Orqaga” va profil tugmasida `excludeSemantics` ichki InkWell’ning tap
  amalini ham olib tashlagan edi — Android’da ikki marta bosish hech narsa qilmasdi. `onTap`
  Semantics’ga qaytarildi; test tuzatishsiz yiqiladi.
- **Profildan kirish:** OTP `context.go('/profile')` tablar va ularning steklarini tashlab
  yuborardi (orqaga tugmasi yo‘q, Android back ilovadan chiqardi). Endi OTP natija bilan
  yopiladi, email ekrani profilga qaytaradi. Muvaffaqiyatdan keyin “faol kod yo‘q” chaqnamaydi;
  6 raqamda avtomatik tekshiradi (iOS raqam klaviaturasida Done yo‘q); qayta yuborish taymeri
  kod yuborilgan vaqtdan; xato matnlari til almashganda yangilanadi.
- **Past ekran:** landshaft telefon yoki kichik telefon + katta shriftda katta sarlavha ro‘yxatni
  0 px gacha siqardi. Endi sarlavha ekran balandligining 40 % dan oshsa yoki joy 420 px dan kam
  bo‘lsa, ro‘yxat ichiga o‘tadi. Telefon portretga **qulflanmadi** (WCAG 1.3.4 — yo‘nalishni
  cheklamaslik). Ixcham sarlavha kontent qisqarganda (natijasiz qidiruv) kengayadi.
- **Tab xotirasi:** boshqa tabdagi bo‘limga havola o‘sha tab allaqachon shu bo‘lim ichida bo‘lsa
  (ochiq QC to‘plami, imtihon) stekni tashlab yubormaydi. Faol tab ildizida qayta bosilsa,
  ro‘yxat tepaga suriladi.
- **Kontrast:** boshqaruv chegaralari uchun `outline` tokeni (yorug' 3.2:1, qorong‘i 4.5:1;
  WCAG 1.4.11 ≥ 3:1) — maydon, ikkinchi darajali tugma, tanlanmagan chip, rol radiosi.
- **Brend:** “LabGuide” 200 % shriftda kesilmaydi (1.3 gacha, sig‘masa kichrayadi) va sarlavha
  emas — sahifada bitta sarlavha.
- **Ma’lumotlar:** “Lokal ma’lumotlarni o‘chirish” matni QC qaydlari va mashq natijalarini ham
  aytadi, avval QC zaxirasini olishni eslatadi. “Faqat shu qurilmada” o‘rniga: qurilmaning o‘z
  zaxira nusxasiga (iCloud/Google) kirishi mumkin — zaxira o‘chirilmadi, chunki QC tarixi
  telefon almashganda yo‘qolmasligi muhimroq. Mehmon uchun “Chiqish” → “Sozlashni boshidan
  boshlash”; hisobli foydalanuvchi chiqishda qurilmadagi ma’lumotni ham o‘chirishni tanlaydi.
- **Qoralamalar:** tadqiqot va dars eslatmalari yozish davomida (600 ms) va sahifadan chiqishda
  avtomatik saqlanadi.
- **Android:** ishga tushgandan keyingi oyna foni ilova foniga mos; release imzo
  `android/key.properties` orqali (bo‘lmasa — debug kalit, faqat sinov APK); CI’da ixtiyoriy
  `ANDROID_KEYSTORE_*` / `ANDROID_KEY_*` secretlari bilan release APK + AAB (D-34 gacha
  `LABGUIDE_ANDROID_*`).
- **Ruscha ko‘plik:** `quizTopicMixed` ICU plural.

## D-29. Kontent yaxlitligi, qidiruv va mashq (2026-10-08)
Mustaqil sharh (review B) asosida:
- **Validator** endi rad etadi: kartadagi iqtibos `source_ids` da yo‘q bo‘lsa (avval “[0]”
  chiqardi); `source_ids` dagi manba hech qayerda keltirilmasa (fruktozamin/ALT dagi ortiqcha
  manbalar olib tashlandi); chegarasiz yoki low > high chegara/interval; mavjud bo‘lmagan
  bo‘limdagi da’vo; o‘ziga yoki takroriy `related`; manfiy molyar massa; `reviewed_at` siz
  tasdiqlangan review; 2 tadan kam variantli savol; analit/guruh bo‘lmagan `topic_ids`;
  takroriy savol/manba/guruh/dars id; uz, ru yoki en bo‘sh yoki yo‘q matn (paketdagi 1084 ta
  matn tekshirildi — hammasi to‘liq).
- **Qaror chegaralari** har biri alohida blokda — o‘z aholisi, izohi va manbasi bilan (avval
  aholilar umumiy ro‘yxatda edi). mg/dL chegaraning mmol/L ekvivalenti molyar massadan
  hisoblanadi va “hisoblangan” deb belgilanadi; OGTT ga glyukoza molyar massasi qo‘shildi.
  Bir chegarali referens interval “≥ a” / “≤ b” (avval “–5”).
- **Qidiruv:** o‘zbek kirill yozuvidagi so‘rov lotinga o‘giriladi (“сийдик кислотаси”).
- **Mashq:** sarlavha til almashganda yangilanadi; ikki marta bosish natijani bir marta yozadi;
  Learn ekranidagi savollar soni paket yuklangach yangilanadi; javobdan keyin savol manbasi
  (havola bilan) ko‘rsatiladi.
- **Kutubxona:** `tests` turkumi “Laboratoriya tahlillari” (test savollari emas); kitoblar
  ro‘yxati ostida katalog izohi, bo‘sh filtr natijasida “Filtrlarni tozalash”.
- **Kalibrovka:** Asboblar ro‘yxatidan ishlab chiqaruvchi uzatiladi; maydon o‘zgarsa eski IFU
  natijasi o‘chadi.

## D-30. QC audit izi va maqsadni bekor qilish (2026-10-08)
- Har seriya kiritilganda o‘sha paytdagi Westgard xulosasi va qoidalari (`entered`) saqlanadi.
  Keyin oldingi seriya o‘chirilsa yoki maqsad o‘zgarsa joriy baho boshqacha bo‘lishi mumkin —
  tarixda “Kiritilganda: Rad etildi · 1-2s, 2-2s” ko‘rinadi, CSV’da `entered_verdict` ustuni.
  Eski yozuvlarda bu maydon yo‘q — ko‘rsatilmaydi (taxmin qilinmaydi).
- Xato kiritilgan maqsadni “Oxirgi o‘zgarishni bekor qilish” bilan qaytarish mumkin (tasdiq
  bilan); seriyalar qayta baholanadi.

## D-31. Mashq variantlari: to‘g‘ri javob uzunligi bo‘yicha bilinmasin (2026-10-08)
71 savolning 61 tasida to‘g‘ri javob eng uzun variant edi — talaba o‘qimasdan topardi.
40 savoldagi 76 ta noto‘g‘ri variant uch tilda qayta yozildi (keng tarqalgan xato tushunchalar;
yangi son, chegara yoki klinik fakt qo‘shilmagan; 72 tasida izoh o‘zgarmagan, 4 tasida faqat
basis dagi faktlar bilan moslashtirilgan). Endi 21/71 (en), uz va ru da ham ≤ 50 % — test
buni nazorat qiladi. To‘g‘ri variantlar, savol matni, manbalar va `correct_index` o‘zgarmagan.
Savollar baribir draft — mustaqil review kerak.

## D-32. Holatni tiklash (state restoration) (2026-10-08)
Android/iOS ilovani fonda xotira uchun yopsa (process death), qaytganda foydalanuvchi turgan
tab va sahifa steki tiklanadi: `MaterialApp.router`, `GoRouter`, `StatefulShellRoute` va har
bir tab uchun `restorationScopeId`. Maydonlardagi kiritilgan matn tiklanmaydi (QC seriyasi va
qoralamalar baribir saqlanadi). Ishga tushish ekrani tizim mavzusiga ergashadi — ilova ichida
qorong‘i, tizimda yorug‘ bo‘lsa, birinchi kadr yorug‘ fonda chiqadi (platforma cheklovi).

## D-33. Yakuniy mustaqil review tuzatishlari (2026-10-09)
- **Klaviatura:** past ekranda klaviatura ochilsa, katta sarlavha ro‘yxatga ko‘chib, ro‘yxat
  indekslari siljirdi — QC da 2-daraja qiymati 1-darajaga yozilib, soxta 1-3s rad chiqishi
  mumkin edi. Endi ro‘yxatning birinchi o‘rni doim band (`SizedBox.shrink`), joylashuv qarori
  esa klaviatura ochiq paytda o‘zgarmaydi. Shell ichida `MediaQuery.viewInsets` olib
  tashlangani uchun klaviatura `View.of(context).viewInsets` dan aniqlanadi.
- **O‘nlik vergul:** maydonlar ilova tilining o‘nlik belgisi bilan o‘qiladi
  (`parseFieldNumber`). UZ/RU da “1,500” = 1,5 (QC “Kuzatilgan x̄/SD” 5,125 yozadi va endi
  saqlanadi); EN da “1,500” avvalgidek ikki ma’noli — rad etiladi, taxmin qilinmaydi.
- **Boshqa tabga havola:** tab allaqachon bo‘lim ichida bo‘lsa `goBranch` — push qilingan
  sahifalar va saqlanmagan kiritish yo‘qolmaydi (`go` stekni URL’dan qayta qurardi).
- **Zaxira va paket:** QC zaxirasidagi `entered` (xulosa va qoidalar) hamda paketdagi barcha satr
  ro‘yxatlari qabul paytida tekshiriladi — buzuq qiymat keyin ekranda yiqitmaydi, noma’lum
  xulosa “qabul” bo‘lib ko‘rinmaydi.
- **Guruh savollari:** mavzusi guruh id si bo‘lgan savol shu guruh bo‘limida chiqadi; har savol
  mavzu tanlovidan topilishi testlanadi.

## D-34. LabGuide alohida repozitoriyda: `davlatsudekspert/labguide` (2026-10-09)
Egasining talabi: NFCSTORE bilan aralashib ketmasin. Ilova nfcx’da `labguide/` papkasida edi
(D-01) va [nfcx#86](https://github.com/davlatsudekspert/nfcx/pull/86) orqali nfcx `main` ga
ham qo‘shilib ketgan edi. Endi:
- `git subtree split --prefix=labguide` — LabGuide commitlari tarixi bilan, ilova repo
  ildizida; NFCSTORE fayllari, tag’lari va obyektlari ko‘chirilmadi (tarixda maxfiy kalit yo‘q —
  tekshirildi).
- Repo **public** (egasi tanladi): standart runnerlar, jumladan macOS, bepul. Repoda
  secret yo‘q; secretlar repo sozlamalarida.
- CI: `.github/workflows/ci.yml` — `main` ga push va PR’da imzosiz tekshiruv, qo‘lda
  `mode: testflight`. Secret nomlari soddalashtirildi: `ASC_*`, `IOS_CERTIFICATE_*`,
  `IOS_TEAM_ID`, `ANDROID_*` (NFCSTORE’ning `NOVA_*` zaxirasi olib tashlandi). Egasi yangi
  repo uchun yangi secretlar qo‘yadi (nfcx’nikidan foydalanilmaydi).
- Imzo: `.p12` secret bo‘lmasa — **bulut imzo**: arxiv imzosiz (`CODE_SIGNING_ALLOWED=NO`),
  `xcodebuild -exportArchive -allowProvisioningUpdates` API kalit bilan Apple’ning
  cloud-managed Distribution sertifikati va avtomatik App Store profilidan foydalanadi.
  Maxfiy kalit Apple’da qoladi, egasiga Mac va openssl kerak emas; API kalit Admin bo‘lishi
  shart. `.p12` berilsa — avvalgi qo‘lda imzo yo‘li. **Tekshirildi:** run #5 (2026-10-09)
  — IPA `uz.labguide.app 0.1.0 (1)`, SDK iphoneos26.2, min iOS 15.0; altool validate +
  upload o‘tdi, TestFlight processingState VALID. Loyiha CocoaPods emas, SwiftPM
  ishlatadi (`pod install` kerak emas — run #4 shu sababdan yiqilgan). Build raqami
  App Store Connect’dagi oxirgisidan hisoblanadi — run raqami qaytadan boshlansa ham
  to‘qnashmaydi.
- nfcx’dan `labguide/` va `labguide-ios.yml` alohida PR bilan olib tashlanadi (egasi
  merge qiladi). D-21’dagi reja shu bilan amalga oshdi.


## D-35. Hisob, “Taklif va yordam” va admin panel — Supabase (2026-10-09)
- **Server:** Supabase (Auth email OTP, Postgres + RLS, yopiq Storage, Edge Function).
  Ilova faqat URL va publishable kalitni biladi (`--dart-define`, CI secrets); service role
  faqat `delete-account` funksiyasida. Sozlanmagan build “server hali ulanmagan” deydi,
  mehmon rejimi o‘zgarmaydi.
- **Admin:** vakolatni server beradi — `admin_allowlist` dagi email **kod bilan
  tasdiqlangandagina** `app_admins` ga yoziladi (trigger). Admin RPC’lari qo‘shimcha
  `aal2` (TOTP) talab qiladi. Ilovadagi email/rol solishtiruvi hech narsa bermaydi; jadvallarga
  to‘g‘ridan-to‘g‘ri yozish yopiq. Muhim amallar `admin_audit` ga (faqat qo‘shiladi).
- **Statistika:** faqat tasdiqlangan, o‘chirilmagan hisoblar; “faol” — kun bo‘yicha
  `last_seen_on` (Asia/Tashkent), ilova ochilganda bir marta yangilanadi. Free/Pro billing
  ulanmaguncha “ma’lumot yo‘q” — soxta raqam ko‘rsatilmaydi.
- **Murojaatlar:** foydalanuvchi faqat o‘z yozishmasini ko‘radi (RLS); javobni admin o‘zi
  yozadi, avtomatik/AI javob yo‘q. Skrinshot — PNG/JPEG ≤ 5 MB, o‘z papkasi, kuniga 10 ta;
  biriktirishda PHI eslatmasi doim ko‘rinadi. Push/email shart emas: o‘qilmagan javob
  profil belgisida.
- **Sinov:** `tool/backend_test.sh` (haqiqiy Postgres, qabul ssenariysi) + widget testlar
  (`FakeLabBackend` — xuddi shu qoidalar) + OTP adapteri (MockClient: muddat, urinish,
  qayta yuborish, chiqish).

## D-36. Apparatlar katalogi va kalibrlash oqimi (2026-10-09)
- **Oqim:** yo‘nalish (biokimyo, gematologiya, immunokimyo, siydik) → ishlab chiqaruvchi →
  aniq model → karta → amal (saqlash, kalibrlash, QC). Qidiruv uz/ru/en: model, sinonim,
  ishlab chiqaruvchi, yo‘nalish nomlari.
- **Manba qoidasi:** har fakt — rasmiy sahifa/buklet/FDA/Rosstandart hujjatidan so‘zma-so‘z
  iqtibos va manba id (`tool/instrument_catalog_src.py` → `assets/instruments/catalog.json`).
  Tadqiqot hisobotidagi iqtiboslar rasmiy sahifalarda qayta tekshirildi; mos kelmaganlari
  tuzatildi yoki olib tashlandi (masalan, cobas e 411 “Not Available” aksessuarlarga
  tegishli bo‘lib chiqdi; BS-240 to‘lqin uzunliklari katalog sahifasida ikki modelga
  tegishli bo‘lgani uchun qo‘yilmadi).
- **Uch holat:** “Apparat ma’lumoti mavjud” / “Yo‘riqnoma mavjud” / “Mutaxassis tekshirgan”.
  Validator dalilsiz yuqori holatni rad etadi; hozir hamma model birinchi holatda — Phase 1
  ishlab chiqaruvchilar operator qo‘llanmasini ochiq e’lon qilmaydi.
- **Parvarish:** kundalik bosqichlar faqat rasmiy qo‘llanmadan; hozircha faqat
  ishlab chiqaruvchining ochiq iqtiboslari + “qo‘llanmangizga amal qiling”.
- **Kalibrlash:** apparat + analit → reagent ishlab chiqaruvchisi (boshqa bo‘lsa — moslik
  ogohlantirishi) → REF + IFU versiyasi → yo‘riqnoma. **Lot bu bosqichda so‘ralmaydi**;
  lot va belgilangan qiymatlar faqat kalibrlash yozuvi yaratilganda (foydalanuvchi qiymatlar
  varag‘idan kiritadi, ilova taxmin qilmaydi). Rasmiy manbada “validated setting” bor
  reagentlar (HumaLyzer 4000 flayeri 981015/2021-11) REF bo‘yicha ko‘rsatiladi —
  parametrlar emas.
- **Qayta kiritmaslik:** “Mening apparatim” (nom, seriya, qo‘llanma versiyasi) va analit
  bo‘yicha oxirgi reagent tanlovi qurilmada saqlanadi; yozuv yaratilganda katalog modeli
  avtomatik saqlanadi.
- **Rasm (D-36a, 2026-10-09 yangilandi):** model kartasida faqat **aynan shu modelning**
  fotosi — ishlab chiqaruvchidan yozma ruxsat bilan yoki modeli aniq yozilgan erkin
  litsenziyali manbadan; saytda ochiq turishi ruxsat emas (Mindray, Roche, Abbott
  Terms of Use tijoriy/qayta foydalanishni yozma ruxsatsiz taqiqlaydi). Metadata majburiy:
  manufacturer, model, source_url, license/rights, checked_at, author; validator boshqa
  modelning rasmini rad etadi. Ikki o‘lcham (≈480 / ≤1600 px), maydonda `BoxFit.contain`,
  bosilganda to‘liq ekran (InteractiveViewer). Rasm yo‘q bo‘lsa — neytral belgi va
  “Model rasmi hozircha mavjud emas” + “Ishlab chiqaruvchi manbasi” havolasi. Yo‘nalish
  sxematik chizmalari (`tool/illustrations/*.svg`) endi faqat yo‘nalish sahifasida, “sxematik”
  izohi bilan. Hozir 26 modeldan hech birida ruxsatli rasm yo‘q; ruxsat so‘rash ro‘yxati —
  `docs/INSTRUMENT_IMAGES.md`. Wikimedia’dagi cobas u 411 fotosi xira va kesilgan — qo‘yilmaydi.
- **Foydalanuvchi sifatida tekshiruv:** `tool/screenshots/walkthrough_test.dart` — mutaxassis
  yo‘li 23 qadam (uz), ru/qorong‘i/katta shrift, en; har qadam rasmi ko‘rib chiqildi. Topilgan
  va tuzatilgan: qirqilgan qidiruv matnlari, keyingi sahifaga o‘tib qolgan “Saqlandi”
  xabari, tor birlik maydoni, tafsilotdagi forma yorliqlari, katta shriftda siqilgan
  apparat nomi (matnli tugma → qalam belgisi), kartada tugmalar ekrandan pastda
  (rasm 16:9 banner, amallar holatdan oldin).
- **UX:** yozuv saqlangach forma yopiladi va foydalanuvchi sahifa pastida qoladi — “Saqlandi”
  xabarida “Kalibrlash jurnali” tugmasi bor (test shu bo‘shliqni topdi).

## D-37. Ilova ikonkasi — egasining logosi (2026-10-09)
Egasi bergan logo (`tool/icons/logo_source.jpg`) hamma joyda: iOS AppIcon, Android
legacy va adaptive ikonka, ishga tushish ekrani, ilova sarlavhasidagi brend belgisi,
do‘kon fayllari (`docs/store/app_store_icon_1024.png`, `google_play_icon_512.png`,
`google_play_feature_graphic.png`). `tool/icons/make_icons.py` belgini plitkaning 3D
qirrasi ichidan kesadi va burchaklarni to‘ldiradi — platforma niqobi (iOS ~22 %, Google
Play ~20 %, Android doira) toza qismni ko‘rsatadi. Adaptive ikonkada rasm ko‘rinadigan
72 dp maydonni to‘liq qoplaydi; monoxrom (themed) qatlam olib tashlandi — rangli rasm
bitta rang siluetida kvadrat bo‘lib qolardi. Manba 476 px belgidan 1024 ga kattalashtirildi;
yuqoriroq o‘lchamli asl fayl (≥ 1024 px) kelsa skript qayta ishga tushiriladi. Ilova
ranglari (yashil palitra) o‘zgarmadi — logo faqat belgi sifatida.

## D-38. Gormon tahlillari — 16 karta, “Gormonlar” guruhi (2026-10-09)
- Bo‘lak fayl: `content_src/additions/endocrine.json` → `python3 tool/build_core_pack.py`.
  Guruh `endocrine` (“Gormonlar”); kichik bo‘limlar o‘rniga sinonim-teglar (“qalqonsimon
  bez”, “reproduktiv gormonlar”, “jinsiy gormonlar”). Kanonik id lar — `content_src/README.md`.
- Manbalar faqat ochiq davlat sahifalari: MedlinePlus lab-test sahifalari (NLM o‘zi
  ularni public domain deb belgilaydi — `usingcontent` sahifasi, 2026-10-09 tekshirildi),
  NIDDK, NICHD va FDA biotin qo‘llanmasi (2020, PDF). Lab Tests Online kabi mualliflik
  huquqi bor saytlar va MedlinePlus’ning A.D.A.M. ensiklopediyasi ishlatilmadi.
  `reuse_rights` baribir konservativ (`verify_before_distribution`), izoh `review_note` da.
- 165 da’vo; har biri uchun manbadan so‘zma-so‘z inglizcha iqtiboslar (814 ta) yig‘ilib,
  yuklab olingan sahifada **aynan `locator` bo‘limi ichida** avtomatik tekshirildi (ilovaga
  kirmaydi). Biotin interferensiyasi FDA’ning umumiy bayonoti (“biotin is used in hormone
  tests”) sifatida berildi — muayyan reagent nomlanmaydi; insulin kartasida esa MedlinePlus’ning
  aniq talabi (kamida bir kun oldin to‘xtatish).
- Referens interval va qaror chegarasi yo‘q: MedlinePlus “How to Understand Your Lab Results”
  sahifasi laboratoriyalar turli metod va oraliq ishlatishini aytadi — bu har kartada
  manbali “Cheklovlar” da’vosi. D vitamini toifalari (tanqis/yetarli emas/…) raqamsiz.
- 16 mashq savoli (qalqonsimon 4, reproduktiv 4, kortizol 2, insulin/C-peptid 3,
  PTG/D vitamini 3), hammasi draft, manba va bo‘lim bilan.
- UX tuzatish: mashqda ro‘yxat pastidagi mavzu (“Gormonlar”) tanlanganda eski scroll
  tufayli savol boshi yashirinib qolardi — `QuizScreen` sahifasi bosqich/savol bo‘yicha
  kalitlanadi va tepadan ochiladi (regressiya testi `hormones_flow_test.dart`).

## D-39. Yangi yashil logo (2026-10-09)
- Egasi tasdiqlagan yashil logo (`tool/icons/logo_source_green.webp`, asl fayl o'zgartirilmaydi)
  eski ko'k-firuza belgining o'rnini oldi. Belgi qayta chizilmagan: kvadrat plitka manbadan
  kesiladi (yozuv va tashqi sutrang maydon olinmaydi), 3D yorug' hoshiya (~20 px) olib
  tashlanadi, burchaklar ichki ranglar bilan to'ldiriladi (iOS/Play ikonkasi shaffofsiz,
  chekkagacha; niqobni platforma qo'yadi).
- Manbadagi plitka ~611 px: 1024 px ikonka **kattalashtirilgan** (LANCZOS + yengil keskinlik),
  yuqori aniqlikdagi asl yoki vektor emas. Dizayner ≥1024 px / SVG bersa `make_icons.py`
  qayta ishga tushiriladi.
- 32 px da DNK va kompas detallari yo'qoladi (probirka + tishli halqa silueti qoladi); dizayn
  o'zgartirilmadi.
- Ilova: sarlavhada kichik belgi + "LabGuide" + tarjima qilinadigan "Biokimyo · Laboratoriya"
  (rasmdagi yozuv takrorlanmaydi). Welcome — 120 pt belgi (molekula rasmi o'rniga); kirish
  ekrani — 88 pt (ekran balandligi ≥ 700 pt bo'lsa; past ekranda joy forma/klaviaturaga).
  Sun'iy kutish yo'q. Palitra o'zgarmadi; splash foni kunduzgi #F3F3EC, tungi #0D1919.

## D-40. Toifa — shifokorga emas; eslatma 20:00; Android ovozi faqat oflayn (2026-10-09)
- Egasi: "Toifa shifokorlarga kk emas". KDL malaka toifasi bo'limi (bosh sahifa, O'rganish,
  `/learn/toifa` manzili) va kunlik savolning toifa manbasi shifokor roliga ko'rsatilmaydi;
  shifokor kunlik savolni kontent paketi mashq savollaridan oladi. Laborant, talaba, ustoz —
  avvalgidek (til uz yoki mintaqa UZ).
- Kunlik eslatmaning standart vaqti 20:00 (egasi tasdiqladi).
- Leykoformula ovozli buyruqlari Android'da faqat qurilmada oflayn tanish bo'lsa yoqiladi
  (Android 12+, `isOnDeviceRecognitionAvailable`); aks holda "oflayn tanish yo'q" xabari.
  Ovoz hech qachon tizim xizmati serveriga ketmaydi — Play Data safety'da audio yo'q.

## D-41. Server — Cloudflare Workers + D1, email kodi — Resend (2026-10-10)
- Egasi qarori: Supabase o'rniga Cloudflare Workers + D1 (bepul tarif), email OTP — Resend
  (`alideveloper.uz` domeni, `LabGuide <labguide@alideveloper.uz>`; Brevo zaxira: `EMAIL_PROVIDER=brevo`).
  NFCSTORE sozlamalariga tegilmaydi. Kod `cloudflare/`, ilova adapteri `CloudflareLabBackend`; build'da
  `LG_API_URL` berilsa u ishlatiladi, bo'sh bo'lsa avvalgi tanlov (Supabase / “ulanmagan”).
  Batafsil: `docs/BACKEND_CLOUDFLARE.md`.
- Email serverda ochiq saqlanmaydi (HMAC + niqoblangan ko'rinish); shuning uchun admin
  “to'liq emailni ochish” bu serverda yo'q. OTP va sessiya tokenlari faqat hash holida.
- Admin — faqat maxfiy `LG_ADMIN_EMAILS` + OTP tasdig'i yoki qo'lda; admin yo'llari TOTP (aal2).
  `teacher` roli faqat guruh yaratishga ruxsat; ustoz huquqi — faqat o'z guruhlari.
- A'zo ismi so'ralmaydi: taxallus yoki “Talaba NN”. Talaba a'zolar ro'yxatida faqat ustozni
  va o'zini ko'radi (Supabase'dagidan qattiqroq).
- Murojaatlar, admin panel, tekshiruv, hamkorlar va Pro — hozircha faqat sxema, endpointlar
  `501`, ilova “ulanmagan” deydi. `LabBackend` interfeysi o'zgarmadi.
## D-42. Ustoz va o‘quv dasturi bo‘yicha guruh darslari (2026-10-10)
Egasi qarori (2026-10-10):
- **Ustoz** — email (OTP) bilan kirgan hisob o‘zini “ustoz” sifatida ro‘yxatdan o‘tkazadi
  (`registerTeacher`). Bu faqat guruh ochish huquqi: ustoz faqat o‘zi yaratgan guruhni
  boshqaradi va faqat o‘z talabalari natijasini ko‘radi. Ustoz admin EMAS; admin vakolati
  avvalgidek faqat serverdagi ro‘yxat + tasdiqlangan email (D-35), hech kim o‘zini admin qila
  olmaydi. Ilovadagi “Ustoz” roli (sozlama) hech qanday huquq bermaydi.
- **Ism-familiya serverda saqlanmaydi.** Talaba guruhda ixtiyoriy taxallus (2–24 belgi) yoki
  tartib raqami (“Talaba 07”, qayta ishlatilmaydi) bilan ko‘rinadi; boshqa talabalar uni
  ko‘rmaydi (a’zolar ro‘yxati — faqat ustozga). Ilova taxallus o‘rniga email qismini endi
  yubormaydi. Ustoz real ismni faqat o‘z qurilmasida lokal belgi sifatida yozishi mumkin
  (`ClassroomLocal`, `classroom.local` kaliti) — serverga yuborilmaydi, “Lokal ma’lumotlarni
  o‘chirish” bilan o‘chadi.
- **Oqim:** guruh → 8 belgili kod + QR (QR’da faqat kod; `/learn/classes/join?code=` kodni
  to‘ldiradi) → talaba qo‘shiladi → ustoz mavzuni guruhga ochadi → 3 bosqich: (1) ma’ruza
  (taqdimot rejimi), (2) og‘zaki savol-javob (toifa og‘zaki bankidan nomzodlar + qisqa javob
  rejasi; “so‘raldi” va bildi/qisman/bilmadi baholari FAQAT ustoz qurilmasida), (3) guruh testi
  — ustoz “Testni boshlash” bosganda talabalarda ochiladi, vaqt chegarasi sozlanadi, ball va
  har savol natijasi serverda; ustoz paneli — talaba bo‘yicha ball, savol bo‘yicha xato
  ulushi (mavjud topshiriq ekrani). “Testni yakunlash” — yangi urinish yo‘q (boshlaganlarga
  2 daqiqa).
- **Nomzod savollar** (`oral_candidates`, `test_candidates`) avtomatik tanlangan, kalitlari
  tekshirilmagan: ilova ularni oldindan tanlamaydi va “to‘g‘ri” deb belgilamaydi — ustoz har
  birini kaliti bilan ko‘rib tanlaydi (bahsli kalit belgilanadi). Test paket va toifa
  savollaridan aralash bo‘lishi mumkin (`ClassQuestionSource`, sessiya manbasi `class`).
- **O‘quv dasturi** (`curriculum.json`: modul → mavzu → links {analytes, conditions,
  reference, tools, microscopy, toifa_topic}, kun `n`, hafta, soat, turi) uchun model va
  o‘quvchi bor (`lib/features/classroom/curriculum.dart`), test fixture bilan. Asset hali
  QO‘SHILMAGAN — ilova “O‘quv dasturi hali qo‘shilmagan” deb halol ko‘rsatadi. Qo‘shilganda
  kurator ismi, klinika/baza nomi va guruhga xos sanalar asset’ga kiritilmaydi; sana ustoz
  belgilagan boshlanish sanasidan hisoblanadi (yakshanba o‘tkaziladi, “taxminiy”, faqat ustoz
  qurilmasida).
- **Ma’ruza rejimi** (`/learn/lecture/<topicId>`) serversiz: slaydlar mavzu, bog‘langan
  kartalar/jadvallar/atlas/kalkulyatorlar va nomzod savollardan; katta shrift, oldinga/orqaga
  (tugma, surish, klaviatura), ekran o‘chmaydi (mavjud wakelock).
- **Server:** ilova faqat `LabBackend` interfeysiga tayanadi. Egasi keyinroq serverni
  Cloudflare Workers + D1 (OTP — Resend) qilib yozishni tanladi; `supabase/migrations/
  20261010000100_teacher_topics.sql` va `supabase/tests/30_teacher_topics.sql` qoidalar
  (RLS) uchun ma’lumotnoma va qabul testi sifatida qoladi — Worker API shu kontraktga mos
  bo‘lishi kerak. Server ulanmagan buildda barcha guruh ekranlari “Server hali ulanmagan”.
- **Maxfiylik siyosati va do‘kon deklaratsiyasi hozir o‘zgartirilmadi.** Server ulanganda
  alohida yangilanadi: email (hisob), ixtiyoriy taxallus, guruh a’zoligi, test javoblari va
  natijalari, ustoz ro‘yxati; real ism va og‘zaki baholar faqat qurilmada.
**Qayta ko‘rish:** curriculum asset’i tayyor bo‘lganda (shaxsiy ma’lumotsiz) va server
ulanganda (siyosat + Data safety / App Privacy).

## D-43. Hamjamiyat: avtomatik mutaxassis tasdig‘i, savol-javob, tarjima (2026-10-11)
Egasi qarorlari (taklif: `docs/proposals/GLOBAL_COMMUNITY_2026-10-11.md`):
- **Tasdiqlash avtomatik** (egasi qo‘lda ko‘rmaydi): foydalanuvchi kasb, mamlakat va hujjat
  suratini (JPEG/PNG ≤ 5 MB; PDF — birinchi sahifa surati) yuklaydi → Workers AI
  (`LG_VERIFY_MODEL`) qat’iy JSON → darhol belgi. **Fayl hech qayerda saqlanmaydi** (D1, R2,
  log — testda tekshirilgan); saqlanadi: `user_hash`, kasb, mamlakat, holat, sabab kodlari, sana.
  Kuniga 3 urinish. Belgi halol: “✓ Mutaxassis (hujjat avtomatik tekshirilgan)” + izoh.
- **Egasi** hisobi — qo‘lda tekshirilgan (supervisor hujjatni ko‘rgan, hujjat saqlanmaydi):
  `manual_document_review`, belgi “✓ Tasdiqlangan mutaxassis”, nom `LG_OWNER_DISPLAY_NAME`
  (“LabGuide”). Faqat admin va faqat `LG_ADMIN_EMAILS` dagi email uchun server endpointi;
  metadata kodda, ism va hujjat raqami yo‘q.
- **Shikoyat:** hisobli har kim; 3 ta turli shikoyatchi → `suspended` (QA: avtomatik to‘xtatishga faqat
  tasdiqlangan mutaxassis, admin yoki ≥ 3 kunlik hisob shikoyati sanaladi — yangi hisoblar to‘dasiga qarshi;
  qolganlari ham saqlanadi va admin panelida ko‘rinadi) (postlar yashiriladi,
  yozolmaydi), admin panelida; admin tiklaydi / tasdiqni bekor qiladi (bekor qilingan a’zo AI orqali qayta
  tasdiqlanmaydi). Admin — faqat server
  bergan vakolat + TOTP; email mosligi yetarli emas. Mijoz o‘zini tasdiqlay yoki admin qila olmaydi.
- **Savol-javob:** savol — hisobli har kim (mehmon emas), javob va ovoz — faqat tasdiqlangan
  mutaxassis, eng yaxshi javob — savol muallifi, qadash/o‘chirish — admin. O‘qish ommaviy
  (mehmon ham). Joylar: Bosh sahifa kartasi (oxirgi 3 + “Savol berish”), analit va holat kartasi
  oxirida “Bu tahlil/holat bo‘yicha savollar (N)”, Profil → “Mening savollarim”, “Mutaxassis
  tasdiqlash”, admin uchun “Hamjamiyat moderatsiyasi”. 6-tab qo‘shilmadi. Limitlar: savol
  kuniga 5, javob 20, shikoyat 20; uzunlik; email/telefon taqiqlangan.
- **Tarjima:** post tili ≠ interfeys tili bo‘lsa “Tarjima qilish / Перевести / Translate” →
  Workers AI m2m100 (`LG_TRANSLATE_MODEL`), D1 keshi `(post, til)`; “Mashina tarjimasi” belgisi
  va “Asl matn” almashtirgichi (toifa naqshi).
- **Feature flag:** hamjamiyat UI faqat Cloudflare serveri (`LG_API_URL`) ulanganda; Supabase
  yoki ulanmagan buildda umuman ko‘rinmaydi.
- **Seed:** egasi tasdiqlagan 2 ta savol-javob (kaliy, HbA1c; uz) `cloudflare/seed/
  community_seed.json`; admin endpointi idempotent. Productionga supervisor deploydan keyin qo‘llaydi.
- **Cheklovlar (ochiq):** AI tasdig‘i aldanishi mumkin (soxta hujjat, rasm ichidagi buyruq) —
  shikoyat mexanizmi va admin bekor qilishi shu uchun; PDF serverda o‘qilmaydi; model javob
  formati deploydan keyin bir marta haqiqiy so‘rov bilan tekshirilishi kerak. Maxfiylik
  siyosati va do‘kon deklaratsiyalari yangilandi (hujjat — ephemeral, Q&A — ilova ichida ommaviy).

## D-44. Adminlar boshqaruvi: egasi ilovadan admin qo‘shadi/oladi (2026-10-11) — **egasi tasdig‘i kutilmoqda**
Egasi so‘rovi: boshqa odamlarni Gmail/email bo‘yicha admin qilish va olib tashlash.
- **Super admin** = maxfiy `LG_ADMIN_EMAILS` dagi email(lar). **Faqat super admin** admin
  qo‘shadi/oladi; super adminni API orqali olib tashlab bo‘lmaydi (faqat secretni o‘zgartirib).
  *(Taklif — egasi tasdiqlashi kerak: qo‘shilgan admin boshqa adminni qo‘sha olmaydi.)*
- Qo‘shilgan admin boshqa barcha admin bo‘limlariga to‘liq kiradi (moderatsiya, hamjamiyat,
  murojaatlar, kontent tekshiruvi); istisno — adminlarni boshqarish va “Hamjamiyatni ishga
  tushirish” (egasi tasdig‘i, faqat `LG_ADMIN_EMAILS`).
- Vakolatni **faqat server** beradi (D-35/D-41 qoidasi o‘zgarmadi): ilovadagi email mosligi hech
  narsa bermaydi, hech kim o‘zini admin qila olmaydi; email kod bilan tasdiqlanganda (hisob bo‘lsa
  — darhol) kuchga kiradi va **har admin amali TOTP (aal2)** talab qiladi.
- D1 `admin_grants` (migratsiya `0006`): email faqat HMAC + niqob, kim qo‘shgan/olgan — HMAC(user_id),
  sanalar; audit `admin_grant_added/removed`. Olib tashlash mavjud sessiyalarda darhol amal qiladi
  (sessiyalar aal1 ga tushadi). Limitlar: qo‘shish soatiga 10, olish 20, faol qo‘shilgan admin ≤ 20.
- Endpointlar: `GET/POST /v1/admin/admins`, `DELETE /v1/admin/admins/:id` (docs/BACKEND_CLOUDFLARE.md).
- **Admin panel** endi yagona boshqaruv sahifasi (Profil → Admin panel): holat (egasi/admin, 2FA),
  Hamjamiyat moderatsiyasi (kutilayotganlar soni; ishga tushirish — faqat egasiga), Taklif va yordam,
  Kontent tekshiruvi (paketdagi haqiqiy tekshirilmagan sonlar), Adminlar boshqaruvi. Serverda hali
  yo‘q bo‘limlar (murojaatlar, statistika, foydalanuvchilar, jurnal, hamkorlar) “ulanmagan” deb
  ochiq aytiladi — soxta son yo‘q. Profildagi alohida “Hamjamiyat moderatsiyasi” qatori panelga ko‘chdi.
  Moderatsiyadagi tiklash/bekor qilish va adminni qo‘shish/olib tashlash — tasdiq oynasi bilan.
- Maxfiylik siyosati (uz/ru/en) yangilandi: qo‘shilgan admin emaili ham faqat hash + niqob.
- **Ochiq (egasi hal qiladi):** hisobini o‘chirgan qo‘shilgan admin shu email bilan qayta
  ro‘yxatdan o‘tsa, grant qolgani uchun yana admin bo‘ladi (egasi ilovada olib tashlaydi).
  Olib tashlangan adminning TOTP kaliti saqlanib qoladi (qayta qo‘shilsa — o‘sha autentifikator).

## D-45. Tayyor taqdimotlar Ma'ruza rejimida (2026-10-11)
- `assets/lectures/index.json` + `dNNN.json`: mavzu (topic id) → tayyor slaydlar
  (sarlavha, bandlar ≤6, manba, ustoz izohi). Bo'lsa — Ma'ruza rejimi shuni
  ko'rsatadi, bo'lmasa — avtomatik slaydlar (o'zgarmagan).
- Birinchi deck: 1-mavzu (d001-P, d001-L), 30 slayd (PPTX dizayni, rasm sifatida
  `assets/lectures/d001/NN.jpg`, belgilar — Material Icons, Apache 2.0), faqat o'zbekcha.
  Manba: `tool/slides/make_m1.py` (PPTX va JSON bir joydan). Holati `draft` —
  ilovada "Ustoz tekshiruvi uchun qoralama" deb ko'rsatiladi; ru/en tilida
  "faqat o'zbek tilida" ogohlantirishi.
- Ustoz izohi auditoriyaga ko'rinmaydi — tepadagi tugma bilan ochiladi.
- Yotiq ekranda (TV/proyektor) rasmli slayd butun ekranda; chetini bosib o'tiladi.
  Ekran ulashilganda ustoz izohi ham televizorda ko'rinadi — darsda yopiq tursin.
- Qolgan mavzular va PPTX yuklash (Ustoz Pro) — 17-oktabr rejasi.

## D-46. Pro yo'nalishi: Ustoz Pro + Talaba Pro, butun dunyo (2026-10-12, egasi tasdiqladi)
> **SUPERSEDED (D-73/D-74, 2026-10-24):** narxlar, tariflar, sinov va Pro tafsilotlari D-73/D-74 (va D-75) bilan almashtirilgan. Quyidagi matn — tarix sifatida saqlangan.

- Maqsad: ilova butun dunyoda foydalanilsin va sotib olinsin (uz/ru/en, keyin boshqa tillar).
- **Bepul:** barcha kartalar, kalkulyatorlar, preanalitika, sanagich, ochiq manbalar, kuniga
  10–20 savol, toifa namunalari, hamjamiyatni o'qish/savol berish.
- **Talaba Pro (arzon, Ustoz Pro'dan 3–5 baravar arzon):** cheksiz savollar, imtihon simulyatsiyasi,
  zaif mavzular tahlili, to'liq toifa banki, kartadan mini-test, atlas mashqlari, ichki sertifikat
  ("LabGuide ichki sertifikati" — rasmiy kredit emas).
- **Ustoz Pro:** guruhlar, testlar, hisobotlar, ma'ruza rejimi, tayyor taqdimotlar, ikki ekranli rejim,
  guruh topshiriqlari; guruh talabalariga chegirma.
- **ru/en uchun alohida qiymat:** akkreditatsiya testlariga tayyorgarlik (litsenziyasi tekshirilgach),
  xalqaro standartlar (CLSI, IFCC, WHO, ISO 15189, Westgard), SI/an'anaviy birliklar, klinik holatlar,
  ona tilida mutaxassis tekshirgan mazmun. Begona imtihon banklari ko'chirilmaydi.
- To'lov: ilova ichida Apple/Google; muassasa litsenziyasi — shartnoma (YATT kerak bo'ladi).
- Narx, sinov muddati va limitlar — egasi bilan alohida (17-oktabr).

## D-47. Avtomatik taqdimot va AI Ustoz — reja (2026-10-12, egasi tasdiqladi)
**Avtomatik taqdimot (Ustoz Pro, uz/ru/en, barcha davlatlar):**
- Ustoz mavzu yoki tahlillarni tanlaydi → tizim ilovadagi tekshirilgan mazmundan (kartalar,
  preanalitika, kalkulyatorlar, atlas, toifa savollari) slaydlar yig'adi. Ma'lumot to'qilmaydi.
- Slaydlar ilovada chiziladi (1-mavzu dizayni: belgilar, kartochkalar, sxemalar) — 3 tilda,
  TV'da tiniq. Materiali kam mavzular uchun tayyor (qo'lda yasalgan, tekshirilgan) decklar.
- Ikki ekranli rejim: TV — faqat slayd; telefon — boshqaruv, ustoz izohi, keyingi slayd.
- AI yozgan taqdimot — keyinroq, faqat "AI qoralama — ustoz tekshiradi" belgisi bilan, tahrirlanadi.

**AI Ustoz (Pro, kunlik limit):**
1. Offline asos (AI'siz, har doim ishlaydi): har savolga tekshirilgan tushuntirish, og'zaki
   imtihon mashqi (javob rejasi bilan o'zini tekshirish), aqlli takrorlash, 3 tilda qidiruv.
2. Online AI Ustoz: shu bazaga tayanadi, manba ko'rsatadi, to'qimaydi ("bilmayman"),
   "AI" belgisi, bemorga shaxsiy maslahat bermaydi, bemor ma'lumoti yuborilmaydi,
   yozishma faqat egasiga ko'rinadi, egasi nomidan yozmaydi. Internet yo'q — offline rejim.
3. Telefon ichidagi kichik model — keyin, ixtiyoriy paket, "tajriba" belgisi bilan.

**Tartib:** 17-oktabr (shanba) — avtomatik taqdimot + slayd shablonlari, keyin ikki ekranli
rejim → offline tushuntirishlar/og'zaki mashq → online AI Ustoz → telefon ichidagi model.

## D-48. Narxlar (2026-10-12, egasi tasdiqladi: "narxlar maqul")
> **SUPERSEDED (D-73/D-74, 2026-10-24):** narxlar, tariflar, sinov va Pro tafsilotlari D-73/D-74 (va D-75) bilan almashtirilgan. Quyidagi matn — tarix sifatida saqlangan.

D-46 dagi paketlar aniqlashtirildi: shaxsiy **Pro** (laborant, shifokor, toifaga tayyorlanuvchi)
+ talabaga chegirma; **Ustoz Pro**; **Muassasa** (shartnoma).

| Paket | O'zbekiston | Xalqaro |
|---|---|---|
| Pro (shaxsiy) | 29 000 so'm/oy · 199 000 so'm/yil | $4.99/oy · $34.99/yil |
| Pro — talaba chegirmasi | ~~15 000 so'm/oy · 99 000 so'm/yil · $2.49/oy · $17.99/yil~~ — D-50 almashtirgan | |
| Ustoz Pro | ~~69 000 so'm/oy · 490 000 so'm/yil · $9.99/oy · $69.99/yil~~ — D-57 almashtirgan | |
| Muassasa | ~15 000 so'm/kishi/oy, kamida 20 kishi | kelishuv |

- Rossiya/Qozog'iston — o'rtadagi narx (do'kon mamlakat narxi). 7 kunlik bepul sinov (tasdiqlash kerak).
- Ochiq: ilk foydalanuvchilarga chegirma; talaba holatini qanday tasdiqlash; bepul kunlik savollar soni.
- Ommaviy chiqishdan oldin: yo Pro to'lov bilan to'liq ulanadi, yo hammasi bepul chiqadi
  ("To'lov hali yoqilmagan" yozuvi yashiriladi) — Apple 3.1.1/2.1.

## D-49. Pro tafsilotlari (2026-10-12, egasi javoblari)
> **SUPERSEDED (D-73/D-74, 2026-10-24):** narxlar, tariflar, sinov va Pro tafsilotlari D-73/D-74 (va D-75) bilan almashtirilgan. Quyidagi matn — tarix sifatida saqlangan.

- Bepul sinov: Pro — 7 kun, Ustoz Pro — 14 kun (egasi rozi, 2026-10-12). 1 oy emas.
- Bepul foydalanuvchi: kuniga 2 ta savol (egasi qarori). Tavsiya: xatolarni qayta ishlash cheklanmasin.
- Ilk foydalanuvchilarga chegirma: yo'q.
- Talaba chegirmasi: talaba bileti bilan tasdiqlash — hamjamiyatdagi mutaxassis tasdig'i usulida
  (AI tekshiradi, hujjat saqlanmaydi, faqat natija + amal muddati; yiliga qayta tasdiq).
  Do'konda alohida "talaba" obuna mahsuloti; faqat tasdiqlangan hisobga ko'rsatiladi.
- Ustoz PPTX yuklamaydi. Faqat monitorga chiqarish: iPhone — AirPlay (ekranni takrorlash),
  Android — ekran translyatsiyasi (Miracast/Smart View, Cast); ilova tashqi ekranni ko'rib
  faqat slaydni chiqaradi (ikki ekranli rejim). Chromecast uchun alohida Cast qabul qiluvchi — keyin.

## D-50. Talaba narxi (A varianti), reklama roliklari, ustoz-elchi (2026-10-12)
> **SUPERSEDED (D-73/D-74, 2026-10-24):** narxlar, tariflar, sinov va Pro tafsilotlari D-73/D-74 (va D-75) bilan almashtirilgan. Quyidagi matn — tarix sifatida saqlangan.

- Talaba chegirmasi (D-48 ni almashtiradi): **9 000 so'm/oy · 49 000 so'm/yil**; xalqaro **$1.49/oy · $9.99/yil**.
  3–4 oydan keyin natijaga qarab ko'riladi (Play narx tajribasi).
- Reklama roliklari **uz/ru/en**: maqsad — talaba (kelajakdagi shifokor, laborant, biokimyogar) ilova
  unga nega kerakligini tushunsin: toifa/imtihon, kundalik ish (kalkulyator, QC, preanalitika),
  ustoz uchun taqdimot. Pro va avtomatik taqdimot tayyor bo'lgach, haqiqiy ilova ekranlaridan
  (soxta raqam/sharh yo'q). Chet ellik (ingliz tilidagi) tibbiyot talabalari ham auditoriya.
- **Ustoz-elchi:** bitta biokimyo o'qituvchisiga bepul Ustoz Pro (admin beradi, muddatli),
  u ilovani talabalariga tanishtiradi. Reklamada hamkorlik ochiq aytiladi. Kerak:
  admin panelda "Pro berish (muddat bilan)" — server tomonidan, audit bilan.

## D-51. Reklama roliklari: ovoz va format (2026-10-12)
- Ovoz: sof o'zbek tilida, **ayol ovozi, aksentsiz** (ru/en versiyalarda — shu tilda ona tili darajasida).
  Manba (egasi tasdiqladi — hasharchilar promo usuli): `edge-tts` (Microsoft neyron ovozlari):
  uz — `uz-UZ-MadinaNeural` (rate ≈ +10…+20%), ru — `ru-RU-SvetlanaNeural`, en — `en-US-JennyNeural`;
  ffmpeg bilan sukunat kesiladi; fon musiqasi o'zimiz sintez qilamiz (mualliflik muammosi yo'q),
  ovoz vaqtida musiqa pasayadi, sahna o'tishida yengil "whoosh". Robot ovoz ishlatilmaydi.
- Format (namuna — hasharchilar promo): 9:16, logo → qiyshaytirilgan telefon mockuplari (haqiqiy ekranlar)
  → har sahnada yorliq + sarlavha → oxirida "Hoziroq yuklab oling".
- Roliklar: Talaba (2 ta, yoki bitta 50–60 s), Shifokor, Mutaxassis (vrach-laborant/laborant); uz/ru/en.
- Shanba (17-oktabr) rejasi bilan, Pro va avtomatik taqdimot tayyor bo'lgach.

## D-52. Roliklar: egasining o'z ovozi; shanba rejasi (2026-10-12)
- `edge-tts` (Madina) bulut serveridan 403 bilan rad etiladi, shuning uchun D-51 dagi ovoz manbasi
  o'zgaradi: roliklar ovozsiz (faqat musiqa) tayyorlanadi, egasi diktor PDF bo'yicha o'zi o'qiydi,
  fayllar gap-gap videoga joylanadi. Roliklar: talaba, shifokor, laborant, ustoz (har biri ≥ 1 daqiqa).
- Talaba rolida O'rganishda toifa kartasi ko'rsatilmaydi (toifa ishlayotgan mutaxassis uchun).
- Shanba ish rejasi: `PLAN_2026-10-17_SHANBA.md`.

## D-53. Bepul kunlik savollar: 5 ta (2026-10-12, egasi: "qaysi ma'qul bo'lsa")
- D-49 dagi "kuniga 2 ta savol" o'rniga **kuniga 5 ta** (mavjud "Bugungi 5 ta savol" bilan bir xil).
  Sabab: 2 ta savol odat hosil qilmaydi; imtihon simulyatsiyasi, to'liq bank va zaif mavzular Pro'da qoladi.
  Xatolarni qayta ishlash cheklanmaydi. Foydalanuvchilar ko'paygach qayta ko'riladi.
- Shanba (17-oktabr) kuni boshida to'liq audit (mazmun, rollar, Pro chegarasi, xavfsizlik, texnik).

## D-54. Tahlil varaqasini o'qish: avval bepul, qurilmada (2026-10-12)
- Egasi: hozircha bepul usulda sinash — varaqalar asosan kompyuterda bosilgan.
- Qurilmadagi OCR (iOS Vision / Android ML Kit) + ilovaning oflayn bazasi (kartalar, natija naqshlari).
  Rasm qurilmadan chiqmaydi, xarajat yo'q. Tashxis qo'yilmaydi.
- Claude API (ishlatganicha to'lov, oylik to'lov yo'q) — keyin, Pro uchun, murakkab varaqalarga;
  aniqlik bepul usulda o'lchangandan keyin hal qilinadi. Android ML Kit kirillni tanimasligi — tekshiriladi.

## D-47a. Avtomatik taqdimot: amalga oshirish (2026-10-17)
- **Yig'ish qoidasi** (`lib/features/classroom/auto_deck.dart`, LLM va tashqi chaqiruvsiz): faqat paketdagi
  manbaga bog'langan mazmun — karta da'volari (maqsad, fiziologiya, oshishi/pasayishi, preanalitika, xalaqit),
  qaror chegaralari va referens intervallar (jadval; "me'yor emas" izohi bilan), davolash maqsadlari
  (eskirgan yo'riqnomalar kirmaydi), kitob/JSST jadvallari, klinik holat tavsifi, atlas rasmlari (litsenziya
  manbada), mashq savollari (manbasi bor, kaliti va tushuntirishi bilan). Mazmun yetmasa slayd chiqmaydi;
  manbasi paketda yo'q da'vo va savol olinmaydi; "faqat tuzilma" yoki matnsiz karta o'tkaziladi va aytiladi.
- **Til:** ilova tili. Tanlangan tilda matni yo'q element tashlanadi, soni sarlavha slaydida va ko'rishda
  aytiladi; tillar aralashtirilmaydi.
- **Manba:** har slaydda "Manba: ..." qatori; oxirida qolgan slaydlardan avtomatik yig'iladigan "Manbalar"
  slaydi (ustoz slaydni olib tashlasa, uning manbasi ro'yxatdan ham tushadi).
- **Halollik:** kartalar hali mustaqil mutaxassis tekshiruvidan o'tmagan — sarlavha slaydida "o'quv namunasi,
  ekspertiza kutilmoqda" izohi chiqadi. Kuratorning `goals`/`key_points` matnlari manbasiz, shuning uchun
  avtomatik taqdimotga kiritilmaydi. Karta "Cheklovlar" bandi (har kartada bir xil umumiy gap) slayd bo'lmaydi.
- **Shablonlar** (`LectureSlide.template`, hammasi ilova ichida chiziladi): sarlavha, bandlar, jadval (rang
  belgilari bilan), rasm, savol-javob (javob tugma yoki Enter bilan). Mavjud Ma'ruza pleyeri shuni chizadi.
- **Kirish:** `/learn/lecture` → "Avtomatik taqdimot" → `/learn/lecture/auto` (tanlash) → `.../preview`
  (tartib, olib tashlash) → `.../play`. Ustoz Pro (`Feature.autoPresentation`): kirishda va "Boshlash"da
  tekshiriladi; TestFlight/`LG_ALL_FEATURES_OPEN` da ochiq. (D-58: tekshiruv va bayroq olib tashlandi — hamma uchun ochiq.)

## D-55. AI yordamidagi sharh ishlari: faqat qo'lda, faqat taklif (2026-10-17)
- Egasi repo secret'i `ANTHROPIC_API_KEY` ni fon AI ishlari uchun ishlatishga ruxsat berdi. Kalitni hech kim (chatda ham)
  o'qiy olmaydi — u faqat GitHub Actions ichida mavjud.
- **Ishga tushirish:** faqat `workflow_dispatch` (Actions → "AI tasks" → Run workflow); `pull_request`, `push`,
  `schedule` bilan hech qachon. Standart `dry_run=true` (hech narsa chaqirilmaydi, token/narx taxmini ko'rsatiladi).
  Bir vaqtda bitta ishga tushirish; elementlar soni qat'iy 60 dan oshmaydi; byudjet chegarasi (standart 3 USD, eng ko'pi 10).
- **Natija:** `ai-reports` tarmog'iga (`docs/ai_reports/<sana>_<vazifa>_<target>.md/.json`) `github-actions[bot]` nomidan,
  `main` ga hech qachon; avtomatik merge yo'q. Hisobotlar — TAKLIF: ilova mazmuni (`assets/`, `lib/`, l10n) avtomatik
  o'zgarmaydi, test qoralamalari `ai_draft` holatida (ilova tanimaydi), odam ko'rib chiqmaguncha pack'ga kirmaydi.
- **Qamrov:** `content_review` (ikkinchi fikr: raqam/birlik, uz/ru/en nomuvofiqligi, ortiqcha da'vo, ogohlantirish yo'qligi;
  "tekshira olmayman" deydi, xotiradan tuzatmaydi), `ru_terminology`, `quiz_draft`, `translate_check`.
  Model manba hujjatini ko'rmaydi (faqat ilova matni va havola ma'lumotlari), shuning uchun u mutaxassis
  tekshiruvining o'rnini bosmaydi (D-47a dagi "ekspertiza kutilmoqda" holati o'zgarmaydi).
- **Xavfsizlik:** kalit faqat bitta Python qadamining env'ida (huquq `contents: read`); push qiluvchi alohida ish
  (`contents: write`) kalitsiz; action'lar commit SHA bilan mahkamlangan; kiritmalar shell'ga qo'shilmaydi.
  Litsenziyasi AI'ga berishni taqiqlovchi kutubxona yozuvlari yuborilmaydi. Tafsilot: `tool/ai/README.md`.
- **Qayta ko'rish:** birinchi haqiqiy ishga tushirishlardan keyin (aniq narx va foydali topilmalar ulushi);
  Claude'ni ilova ichida (Pro, D-54) ishlatish alohida qaror bo'lib qoladi.

## D-57. Ustoz Pro narxi: Pro'dan qimmat, lekin D-48 dagidan arzon (2026-10-17, egasi qarori)
> **SUPERSEDED (D-73/D-74, 2026-10-24):** narxlar, tariflar, sinov va Pro tafsilotlari D-73/D-74 (va D-75) bilan almashtirilgan. Quyidagi matn — tarix sifatida saqlangan.

D-48 dagi **Ustoz Pro** qatorini (69 000 so'm/oy · 490 000 so'm/yil · $9.99/oy · $69.99/yil) almashtiradi.
(D-56 raqami boshqa ish uchun band qilingan, shuning uchun D-57.)

| Paket | O'zbekiston | Xalqaro |
|---|---|---|
| Pro (shaxsiy) — o'zgarmaydi | 29 000 so'm/oy · 199 000 so'm/yil | $4.99/oy · $34.99/yil |
| Pro — talaba (D-50) — o'zgarmaydi | 9 000 so'm/oy · 49 000 so'm/yil | $1.49/oy · $9.99/yil |
| **Ustoz Pro (yangi)** | **39 000 so'm/oy · 269 000 so'm/yil** | **$6.99/oy · $46.99/yil** |

- **Mantiq:** Ustoz Pro doim Pro'dan qimmat bo'lishi kerak (ustoz = Pro'dagi hammasi + guruhlar, topshiriqlar,
  avtomatik taqdimot). Yillik narx Pro bilan bir xil nisbatda: Pro 199 000 / 29 000 ≈ 6,9 baravar →
  39 000 × 6,9 ≈ 269 000 so'm. Xalqaro: $4.99 → $6.99 (×1,4, so'mdagi 29 000 → 39 000 ≈ ×1,34 ga yaqin);
  yillik $46.99 (oylikning ≈ 6,7 baravari; Pro'da $34.99 / $4.99 ≈ 7,0 — yillik chegirma biroz kuchliroq,
  egasi taklifi).
- **Egasi argumenti:** ChatGPT foydalanuvchilari PPTX tayyorlash uchun oyiga ~228 000 so'm to'laydi; LabGuide
  shu ishni (manbali, o'quv rejaga mos taqdimot) bajaradi, 39 000 so'm esa uning ~1/6 qismi. Eslatma: ilova
  tashqi LLM'ni chaqirmaydi — taqdimot paketdagi manbaga bog'langan mazmundan qoida bo'yicha yig'iladi
  (D-47a), shuning uchun reklamada "AI" va "ChatGPT o'rnini bosadi" kabi taqqoslash yozilmaydi
  (Apple 2.3.1/2.3.14: tekshirib bo'lmaydigan da'vo va narx haqida aniq ma'lumot yo'q).
- **Sinov muddati o'zgarmaydi:** Ustoz Pro — 14 kun, Pro va talaba — 7 kun (D-49).
- **Do'kon narx pog'onalari (price points):** Apple va Google narxni faqat o'z ro'yxatidagi pog'onalardan
  tanlatadi, shuning uchun yakuniy raqam yaxlitlanishi mumkin. Apple'ning UZS pog'onalari ro'yxatini ochiq
  rasmiy manbada topib bo'lmadi (App Store Connect → obuna → Subscription Prices → O'zbekiston, "Show all
  prices"): shu ro'yxatdan **39 000 va 269 000 ga eng yaqin** pog'onani tanlang; USD uchun $6.99 va $46.99
  odatda mavjud (App Store Connect'da tekshiring). Google Play'da narx istalgan raqam (mahalliy valyutada
  yaxlitlash qoidalari bilan). Tanlangan haqiqiy narxni shu yerga yozib qo'ying. Ilova narxni kodda
  saqlamaydi — do'kondan oladi, shuning uchun kod o'zgarmaydi.
- **Hali sotuvda emas:** obuna ulanmagan (to'lov yoqilmagan), shuning uchun avvalgi 69 000 narxdagi obunachi
  yo'q, narx o'zgarishi uchun foydalanuvchi roziligi (Apple price-increase consent) kerak emas.
  Narxni *oshirish* keyinroq mavjud obunachilar roziligini talab qiladi — shuning uchun boshlang'ich narxni
  shu paytda ehtiyotkorlik bilan tanlang.
- **Joylar:** `docs/PRO_BILLING_PLAN.md` 2-bo'lim jadvali; kodda qotirilgan narx yo'q (test mahsulotlari
  `test/helpers/billing_fakes.dart` dagi `displayPrice` — faqat sinov qiymati, yangi $6.99 ga moslangan).


## D-56. Google va Apple bilan kirish (2026-10-17)
- **Qaror (egasi):** email-kod kirishi yoniga "Google bilan kirish" va "Apple bilan kirish" qo‘shiladi. Sabab: Apple 4.8 —
  boshqa uchinchi tomon kirishi bo‘lsa, Sign in with Apple ham bo‘lishi shart. Mehmon rejimi o‘zgarmaydi (5.1.1: majburiy
  kirish yo‘q); hisobni o‘chirish (5.1.1(v)) ishlashda qoladi.
- **Bitta email = bitta hisob:** provayderning *tasdiqlangan* emaili mavjud hisob emailiga teng bo‘lsa — o‘sha hisobga
  kiriladi (bog‘lanadi), dublikat yaratilmaydi; rol eski dizayn bo‘yicha almashtiriladi. Apple private relay emaili alohida
  email-identitet; birinchi kirishdan keyin hisob provayder `sub` i bo‘yicha topiladi (`auth_identities`).
- **Xavfsizlik dizayni:** ID token faqat **serverda** tekshiriladi (`cloudflare/src/social.ts`): imzo (provayder JWKS, RS256,
  keshlanadi, kalit almashtirish qo‘llanadi), `iss`, `aud` (Google — `GOOGLE_CLIENT_IDS`; Apple — `uz.labguide.app`), `exp`,
  `email_verified`, nonce (xom nonce serverga, `sha256` provayderga) va bir martalik belgi (`auth_replay`, faqat hash). Hech
  qanday provayder tokeni saqlanmaydi. Sessiya email-kod bilan bir xil (`aal1`, hash, 60 kun) va shu limitlar turi.
  **Admin vakolati bu yo‘l bilan berilmaydi** (faqat email kodi; vakolat olinishi esa ishlaydi) — admin amallari baribir TOTP.
- **Ma’lumotni minimallashtirish:** Apple’dan faqat email so‘raladi (ism so‘ralmaydi); Google profil nomi/rasmi ilovada ham,
  serverda ham saqlanmaydi. Bazada: identitet (provayder, `sub`), mavjud `users` jadvali (email HMAC + niqoblangan).
- **Apple revoke (5.1.1(v)):** hisobni o‘chirishda ilova Apple’dan yangi `authorizationCode` oladi, server uni almashtirib
  refresh tokenni darhol bekor qiladi (`/auth/revoke`) — saqlanmaydi, shuning uchun bazada token yo‘q. Apple oynasi bekor
  qilinsa o‘chirish to‘xtatiladi (hech narsa o‘chmaydi); Apple oynasi xato bersa yoki server sozlanmagan bo‘lsa hisob
  baribir o‘chadi va natija `audit_log` da (`apple_revoke`).
- **Tugma faqat ishlasa ko‘rinadi:** ilova tugmani (1) platforma qo‘llasa, (2) build sozlangan bo‘lsa
  (`LG_GOOGLE_CLIENT_ID` [+ iOS: `LG_GOOGLE_IOS_CLIENT_ID`], `LG_APPLE_SIGNIN`), (3) `GET /v1/auth/providers` yoqqan bo‘lsa
  ko‘rsatadi. Server sozlamasiz — `503 not_configured`. Apple tugmasi Google’dan kam ko‘zga tashlanmaydi (birinchi, bir xil
  eni/balandligi, plaginning rasmiy tugmasi).
- **TestFlight buzilmasin:** `com.apple.developer.applesignin` entitlement fayli (`ios/Runner/Runner.entitlements`) repoda
  bor, lekin Xcode loyihasiga CI faqat repo variable `LG_APPLE_SIGNIN=true` bo‘lganda ulaydi (egasi App ID’da imkoniyatni
  yoqqach). Qo‘lda imzoda profilda imkoniyat bo‘lmasa — ogohlantirish bilan o‘chiriladi; IPA tekshiruvi entitlement
  haqiqatan bor-yo‘qligini isbotlaydi. Standart holatda iOS build avvalgidek.
- **Qaytarish sharti:** Google/Apple tekshiruvida jiddiy xavfsizlik muammosi chiqsa, secretlarni (`GOOGLE_CLIENT_IDS`,
  `APPLE_SIGNIN_*`) o‘chirish kifoya — endpointlar `503`, tugmalar yo‘qoladi; email-kod kirishi ta’sirlanmaydi.
- **Egasi qadamlari:** `docs/AUTH_SOCIAL_LOGIN.md`. Maxfiylik siyosati va do‘kon deklaratsiyalari yangilangan.

## D-58. Pro/to'lov ilovadan olib tashlandi (2026-10-17, egasi qarori)
- Pro/payments removed from the shipping app (Apple 2.5.19/2.1); everything free; return as a complete update
  later; work kept on branch `pro-later`. Reklama UI do'kon buildidan ham chiqarildi (`LG_PARTNER_ADS=false`,
  faqat TestFlight/Play ichki test buildlarida `true` — docs/PARTNERS.md). Serverda faqat ko'rinmas `users.plan`
  ustuni (`0009_admin_console.sql`), hech bir endpoint uni bermaydi.

## D-59. Ma'ruza — haqiqiy 16:9 taqdimot, to'liq ekran va ekranga uzatish (2026-10-17, egasi talabi)
- **Muammo (egasi):** ma'ruza slaydlari tik matn sahifasi kabi edi; manba qatori kesilib qolardi.
- **Kanvas:** har slayd 1280×720 dizayn o'lchamida chiziladi (`lib/features/classroom/lecture_canvas.dart`)
  va ekranga teng masshtablanadi (FittedBox) — PPTX (`make_topic_decks.render_deck`) ko'rinishi: eyebrow chipi,
  katta sarlavha, belgili/raqamli bandlar, "Yorliq:" qalin aksentda, jadval (aksent sarlavha, zebra qatorlar),
  rasm + izoh + muallif qatori, savol kartalari (javob ochilsa to'g'risi ajratiladi), sarlavha slaydi chuqur
  yashil fonda lime aksent va logo bilan, footer "LabGuide · <deck>" va slayd raqami; kunduzgi/tungi ranglar
  `tokens.dart` dan. Kanvas ichida tizim shrift masshtabi qo'llanmaydi (slayd — "rasm"; kattalashtirish —
  to'liq ekran); panel matni masshtabga bo'ysunadi. Sig'masa — kesilmaydi, butunligicha kichrayadi.
- **Bo'lish (eksport):** `tool/slides/export_app_decks.py` 16:9 byudjeti (shu o'lchamlar, asosiy matn 28 px da
  hisoblanadi, ilovada ≥ 26 px): uzun slayd davom slaydlariga ("· 2/3"), band chegarasida; bitta uzun band —
  faqat jumla oxirida (qisqartmalar e.g., т.е., "A." chegara emas). Har qismda manba bir xil. Jadval qatorlar
  bo'yicha, rasm izohi qatorlar bo'yicha (rasm takrorlanadi), savol izohi davom slaydida. Natija: 11 708 → 14 738
  slayd (369 fayl); 38 holatda bitta jadval qatori 24 px da sig'maydi — ilova shriftni kichraytiradi.
- **To'liq manbalar:** slaydda `ref` → deck `refs` (Adabiyotlar raqami + shu slayd bo'lim/sahifalari);
  ilovada manba qatorini bosish — to'liq yozuvlar oynasi (hech narsa kesilmaydi).
- **To'liq ekran:** faqat slayd; chap/o'ng yarmi yoki surish; tik ekranda "Gorizontal holatga aylantiraymizmi?"
  (Ha — majburiy landscape + immersive; Yo'q — aylantirmaydi), "Qayta so'ramaslik" qurilmada
  (`lecture.orientation`), menyuda ham. Chiqishda (tugma, orqaga, Esc, ekran yopilishi) ekran holati
  cheklovsiz va tizim panellari qaytariladi. ≥ 900 px — slayd yonida panel (aylantirish shart emas).
- **Ekranga uzatish:** haqiqiy ikkinchi ekran EMAS — tizimning ekranni takrorlashi (Android Cast/Miracast,
  iOS AirPlay Screen Mirroring). Android'da `android_intent_plus` (6.1.0, BSD-3, sof Java) bilan
  `android.settings.CAST_SETTINGS` ochiladi, bo'lmasa yo'riqnoma; iOS — Boshqaruv markazi yo'riqnomasi.
  Taqdimot rejimi ko'zgu uchun: tugmalarsiz (3 s dan keyin yashiriladi), ekran o'chmaydi (wakelock_plus).
  "Taqdimotchi rejimi" (joriy + keyingi slayd, vaqt, izoh, katta tugmalar) — faqat shu qurilmada; ko'zguda
  televizor ham shuni ko'rsatadi. Tashqi displeyga alohida chiqish (Android Presentation / iOS UIScreen) native
  kod talab qiladi — keyinga (QOLGAN_ISHLAR).

## D-60. Toifa: 50 savollik test (imtihon/mashq rejimi), kunlik mashg'ulot, "ertaga davom etamiz" eslatmasi, og'zaki bilet yozmasdan (2026-10-17, egasi talabi)
- **Muammo (egasi, mutaxassislar):** toifa va testlar mutaxassisni ilovada ushlab turadi — 50 savollik test, xato
  DARHOL ko'rinsin; har kungi natija saqlansin va ertaga qaytishga taklif qilinsin; bilet 5 savol, lekin ilovaga
  javob yozib bo'lmaydi.
- **Test rejimi aniq tanlanadi** (`ToifaTestScreen`): "Imtihon rejimi" — avvalgidek (`ExamSession`, ixtiyoriy vaqt,
  natija oxirida, qoralama `exam.active`); "Mashq rejimi — xato darhol ko'rinadi" — `ToifaDrill`
  (`lib/features/toifa/toifa_daily.dart`), vaqtsiz, har javobdan keyin rasmiy kalit, (bo'lsa) LabGuide izohi va
  manba, so'ng "Keyingi"; qoralama `toifa.drill` da (ilova yopilsa — shu savoldan davom). Ikkalasi ham faqat
  rasmiy kalitli (`scorable`) savollardan, 50 ta (bankda kamroq bo'lsa — hammasi). Mashq natijasi: ball, o'tish
  chegarasi, xatolar (to'g'ri javob bilan), "Xatolarni qayta ishlash" (faqat xato savollar, mashq rejimida).
  Har javob umumiy xatolar tarixiga (`QuizProgressController`) ham yoziladi — "Xatolar" sahifasi o'zgarmadi.
  Mashqda kalit boshlanganda saqlanadi (bank yangilansa ham ball o'zgarmaydi); bankda yo'q savolli qoralama tashlanadi.
- **Kunlik hisob** (`toifa.daily`, kalit — qurilmaning mahalliy sanasi `yyyy-MM-dd`; oxirgi 60 kun): javob berilgan
  test savollari, to'g'rilari, yakunlangan biletlar. Mashq rejimi va mavzu mashqi — har javobda; imtihon — yakunda
  (`recordExamProgress`, javob berilganlari). Kunlik maqsad: N savol (20/50/100, sukut 50) YOKI 1 bilet.
  Seriya — maqsad bajarilgan ketma-ket kunlar (bugun hali bajarilmagan bo'lsa kechagacha sanaladi; muzlatish yo'q —
  kunlik savoldan farqli, sodda). "Bugun" kartasi (`ToifaTodayCard`): hub'da (maqsad tanlovi va eslatma bilan) va
  bosh sahifada — toifa bo'limini ochgan har qanday rolga (laborant ochmaguncha — avvalgi kirish kartasi).
  Shifokor va talabaga bo'lim yopiq (egasi qarori, 2026-10-09 va 10-12 — o'zgarmadi), ularga karta ham yo'q.
- **Eslatma** — yangi plagin yo'q: kunlik savolning `ReminderScheduler`/`flutter_local_notifications` qayta
  ishlatildi, `ReminderSlot` (daily 7100+, toifa 7200+ id, alohida Android kanali, `payload`) bilan — biri
  ikkinchisini bekor qilmaydi; bosilsa toifa bo'limi ochiladi. Standart o'chiq; ruxsat faqat yoqilganda
  so'raladi (iOS/Android oynasi, rad etilsa o'chiq qoladi). Maqsad bajarilgach natija sahifalarida (mashq, imtihon,
  mavzu mashqi, bilet yakuni) "Ertaga davom etamizmi? Eslatma vaqtini tanlang" paneli (kalit, vaqt — sukut 20:00,
  "Kerak emas"). Matn: "Bugungi toifa mashg'uloti sizni kutmoqda — N ta savol yoki 1 bilet". Maqsad bajarilgan
  kuni eslatma kelmaydi; 7 kun oldinga rejalashtiriladi. Rol shifokor/talabaga o'zgarsa — bekor qilinadi.
  Maxfiylik siyosati §1 va §14 bir jumlaga yangilandi (lokal, server yo'q).
- **Og'zaki bilet yozmasdan:** tayyorlanish matni — "ilovaga yozish shart emas"; har savolda "Javobni o'ylab
  ko'ring: ovoz chiqarib ayting yoki qog'ozga yozing", ixtiyoriy 3 daqiqalik o'ylash taymeri (to'xtatsa bo'ladi,
  saqlanmaydi), "Javob rejasini ko'rish", ixtiyoriy "asosiy so'zlar" ro'yxati — FAQAT mavjud reja bandlari va
  referens/chegara qiymatlaridan belgilanadigan checklist (belgilar saqlanmaydi), so'ng Bildim/Qisman/Bilmadim.
  Yakunda: baholar, "Takrorlash kerak" ro'yxati. Ovoz yozish yo'q.
- **Leitner** (`toifa.leitner`): bilmadim → 1-quti, qisman → 2-quti, bildim → bir quti yuqori (yangi → 3), 5 quti;
  oraliq biletlar soni bilan (1, 2, 4, 8, 16). Bilet tartibi: muddati kelgan zaif (1–2-quti, ko'pi bilan 3 ta) →
  yangi → muddati kelgan mustahkam → qolgan. Bilet ichida baho o'zgartirilsa quti biletdan oldingi holatdan
  hisoblanadi. Eski baholar (`toifa.oral`) birinchi o'qishda qutiga o'tkaziladi.
- Savollar, kalitlar, javob rejalari o'zgarmadi (assets/toifa faqat o'qiladi).

## D-62. Hamjamiyat moderatsiyasi: `author.ref`, server bloklari, so'z filtri (App Store 1.2) (2026-10-18)
- **Muammo:** ilovadagi "Bloklash" tugmasi serverdan muallif belgisini (`author.ref`) kutardi — server bermagani
  uchun tugma chiqmasdi; haqorat/so'kinish filtri yo'q edi → 1.2 to'liq bajarilmagan.
- **`author.ref`** (`cloudflare/src/community.ts`): `HMAC(community kaliti, 'author-ref:' + user_hash)` ning 24 hex
  belgisi. Barqaror (bir muallif — bir xil, mehmonga ham), lekin qaytarib bo'lmaydi: foydalanuvchi id si, email va
  `user_hash` (admin yo'llaridagi kalit) chiqmaydi (test tekshiradi). Ko'ruvchiga xos emas — mehmon ham qurilmada
  bloklay oladi; ilovadagi lokal blok ro'yxati shu belgilar bilan.
- **Server bloklari** (migratsiya `0011_community_blocks.sql`, `(viewer_hash, author_hash)`): `POST /v1/community/blocks
  {kind, id}` — post orqali (server `ref` ni muallifga qaytara olmaydi), `GET` — bloklangan belgilar (qurilmalar
  sinxroni), `DELETE` — hammasi. Savollar ro'yxati va savol ichidagi javoblarda shu ko'ruvchiga bloklangan
  muallif ko'rsatilmaydi (savolning o'zi ochilsa — ilova "yashirilgan" panelini ko'rsatadi). O'zini va egasini
  (LabGuide) bloklab bo'lmaydi — unga shikoyat. Hisob o'chirilganda ikki tomondagi bloklar ham o'chadi. Ilova:
  blok darhol lokal (oflayn ham) + kirgan bo'lsa serverga; ro'yxat ochilganda hisobdagi bloklar qo'shiladi;
  "Hammasini qaytarish" serverda ham.
- **So'z filtri** (`cloudflare/src/moderation.ts`, ro'yxat — ma'lumot fayli `cloudflare/data/abuse_words.json`):
  savol (sarlavha + matn) va javob yaratishda `400 abusive_language`; ilova uz/ru/en da tushunarli xabar
  (`cmErrAbusive`), topilgan so'z oshkor qilinmaydi. Normallashtirish: NFKC, kichik harf, ё→е, apostroflar
  (o‘/g‘/ʼ) olib tashlanadi, lotin↔kirill o'xshash harflar (ikkala skelet), o'zbek kirill ў қ ғ ҳ → у к г х,
  ъ/ь olib tashlanadi, takror harflar bittaga, "с.у.к.а" kabi bo'lingan harflar birlashtiriladi. Moslik FAQAT
  butun so'z (`words`) yoki aniq o'zak — so'z boshi (`stems`; rus old qo'shimchalari bilan `ru_prefixed_stems`);
  so'z ichidan qidirilmaydi. Shuning uchun "анализ", "сукцинат", "kalsiy", "siydik", "spermogramma", "pH",
  "бляшка", "педикулёз", "себум", "sikl", "cocktail", "застрахуйте" o'tadi (`cloudflare/test/moderation.test.ts`;
  qisqa xavfli o'zaklar ro'yxatda bo'lmasligi ham test qilinadi). Qoida: yangi so'z qo'shganda tibbiy so'zlar
  testi yashil qolsin.
- Natija: 1.2 — filtr, shikoyat, bloklash, aloqa ma'lumoti — hammasi bor (`docs/APPLE_2026_REQUIREMENTS.md` §4).

## D-63. Egasi admin panelida hisobni email bo'yicha o'chirish (2026-10-18)
- **Muammo:** maxfiylik siyosati email orqali o'chirish so'rovini taklif qilardi, lekin vosita yo'q edi
  (faqat `wrangler d1 execute`).
- **Yechim:** `POST /v1/admin/accounts/delete {email, confirm_user_id}` (panel admini, yozish limiti). Email serverda
  HMAC qilinadi (aniq moslik; saqlanmaydi, javobga chiqmaydi), `confirm_user_id` — panel ko'rsatgan hisob: boshqa
  hisob o'chmaydi (`confirmation_mismatch`). O'zini (`self`) va adminni (`admin`) o'chirib bo'lmaydi.
- **Bir xil yo'l:** `auth.ts deleteUserData()` — o'zi o'chirish (`DELETE /v1/me`) ham, admin ham shuni chaqiradi
  (guruhlar, natijalar, hamjamiyat, bloklar, murojaatlar, sessiyalar, identitetlar, Apple tokenini bekor qilish
  urinishi). Admin holatida foydalanuvchining yangi Apple `authorizationCode` i yo'q (refresh token serverda
  saqlanmaydi) → natija `no_code` jurnalda (`apple_revoke`, actor = admin, `via: admin`); siyosatda va qo'llanmada
  foydalanuvchiga iPhone sozlamalaridan ham olib tashlash aytiladi. Jurnal: `account_deleted_by_admin`
  (actor — admin, target — o'chirilgan id).
- **Ilova:** Admin panel → Foydalanuvchilar → (email bo'yicha topib) hisob → "Hisobni o'chirish": to'liq email
  qayta yoziladi → tasdiq oynasi → sahifa "o'chirildi" holatiga o'tadi, ro'yxatga qaytish.
- **Siyosat:** email so'rovi admin vositasi bilan **30 kun ichida** bajariladi (uz/ru/en, `site/privacy`,
  `site/delete-account`; `docs/ADMIN_PANEL_GUIDE.md` §5).

## D-64. Tanlanadigan ilova mavzusi: Klassik va Ivory (2026-10-18, egasi talabi)
- **Reestr:** `lib/design/themes.dart` — `LgThemeId { classic, ivory }`; har mavzuda kunduzgi va tungi
  `LgPalette` (`tokens.dart`: `light/dark` — asl yashil, `ivoryLight/ivoryDark`) va `LgStyle` ThemeExtension
  (serif sarlavha, konturli teglar, qora tanlangan tab, oltin halqa, pill tugma/chiplar, mavzu ekrani gradienti).
  Standart — Klassik (o'zgarishsiz). Palitraga ikki token qo'shildi: `accent` (dekorativ: halqa, nuqta — matn
  uchun emas) va `accentInk` (eyebrow matni, ≥ 4,5:1); Klassikda ikkalasi ham brend rangi — ko'rinish o'zgarmaydi.
- **Ivory:** fon #F3F1EC, kartalar #FCFBF8, asosiy (tugma, tanlangan tab, Lab tugmasi) #141414, oltin #C9A86A
  kam joyda (dumaloq belgilar halqasi, eyebrow #7A5A22), kulrang ikkinchi matn #5F5B54. Tungi Ivory — ko'mir fon
  #0F1116, ivory matn/asosiy #F2EEE5/#EDE6D6, oltin #D2B57E; mavzu ekranining sarlavha kartasi chuqur
  dengiz-qora gradientda. Barcha juftliklar WCAG AA — `app_flow_test` (matn ≥ 4,5:1, kontur ≥ 3:1) va
  `bottom_nav_test` (shisha menyu) to'rt palitrani tekshiradi.
- **Shrift:** katta sarlavhalar (displaySmall, headlineMedium, headlineSmall) faqat Ivory'da serif; asosiy matn
  Inter. Tanlov — **Instrument Serif** (tor, yuqori kontrastli "fashion" serif; lotin, o‘ g‘ uchun U+2018 bor).
  Kirill glyphi yo'q, shuning uchun ruscha interfeysda **Playfair Display** (variable, wght 500) asosiy, boshqa
  tillarda kirill harflari fallback orqali Playfair'dan. Ikkalasi ham SIL Open Font License 1.1 (Google Fonts
  repozitoriysidan): `assets/fonts/InstrumentSerif-Regular.ttf` + `InstrumentSerif-OFL.txt`,
  `assets/fonts/PlayfairDisplay-Variable.ttf` + `PlayfairDisplay-OFL.txt` ("Playfair Display" — Reserved Font
  Name; shrift o'zgartirilmagan). Hajm ~370 KB.
- **Sozlama:** Profil → Tashqi ko‘rinish → **Mavzu** (`/profile/theme`): mavzu kartalari (nomi mavzuning o'z
  sarlavha shriftida, 5 rang nuqtasi, logotipli dumaloq belgi — Ivory'da oltin halqa), kunduzgi/tungi/tizim
  tanlovi (Profil'dagi chiplar ham qoldi). Kalit `settings.appTheme` (kv store), darhol butun ilovaga qo'llanadi,
  `MaterialApp` 360 ms silliq o'tish (reduced motion — darhol). Lokal ma'lumot o'chirilsa — Klassik.
- Boshqa ilovaning kodi, rasm yoki logotiplari ishlatilmadi — faqat uslub. Ma'ruza slaydlari o'z palitrasida qoladi.
- Ko'rik: `tool/screenshots/walk_all_screens_test.dart` ga Ivory variantlari (uz · kunduzgi · 390, ru · tungi ·
  320); layout matritsasiga har til uchun Ivory 320 px ×1,3.

## D-61. Koagulogramma va koprologiya + parazitologiya bo'limlari (2026-10-18, 2-to'lqin)
- **Tuzilishi** — siydik tahlili/spermogramma namunasida: `lib/features/coagulogram/` (`coag_content.dart` — matn
  va manbalar, `coag_logic.dart` — ISTH DIC bali, PT/APTT birikmasi, sitrat formulasi, `coag_screens.dart`) va
  `lib/features/coprology/` (`copro_content.dart`, `copro_scheme.dart` — vektor sxemalar va o'lcham diagrammasi,
  `copro_screens.dart`). Yo'llar `/lab/coagulogram/{tests,sample,reader,dic,monitoring}` va
  `/lab/coprology/{collect,macro,micro/:id,occult,parasites/:id}`. Lab tabida ikki rasmli karta (qon morfologiyasidan
  keyin), umumiy qidiruvda ikki bo'lim, ARB: `coagTitle`, `coagLabCardBody`, `coproTitle`, `coproLabCardBody`;
  qolgan matn — kontent faylidagi `LocalizedText` (3 til).
- **Nol xato qoidasi:** har da'vo `CgFact`/`CpFact` + `CalcRef` (manba + bo'lim/bet). Manbalar shu sessiyada
  ochilgan: WFH laboratoriya qo'llanmasi 3-nashr (3- va 5-qism), Magnette 2016, Toh 2016, Iba 2019, Wada 2014,
  CHEST 2012 (Ageno; Garcia), MedlinePlus, JSST 2003 (4-bob), CDC DPDx, Merck Manual; koprogramma talqinlari
  (mushak tolasi, biriktiruvchi to'qima, kraxmal, shilliq, me'yor raqamlari) xalqaro ochiq manbada topilmadi —
  faqat domla darsligidan (Kurbonova 2023, url yo'q) va matnda "Darslik/Учебник/Textbook" deb belgilanadi (test
  tekshiradi). Manbalar farq qilsa (to'ldirish ≥ 80 % / > 90 %, sentrifuga rejimi, parazit o'lchamlari) — ikkalasi.
- **Me'yorlar:** PT/APTT/TT oralig'i laboratoriyaga bog'liq — "me'yor" raqami berilmaydi, faqat manba misoli izoh
  bilan. INR maqsadi (≈ 2,0–3,0) va geparin APTT oralig'i (1,5–2,5 × nazorat, tasdiqlanmagan) manbadagi kabi.
- **ISTH DIC bali:** Taylor 2001 asl maqolasi (Thieme) ochilmadi — chegaralar Toh 2016 (ISTH SSC a'zosi) va Iba
  2019 jadvallaridan (bir xil): trombotsit ≥ 100/≥ 50/< 50 → 0/1/2, marker 0/2/3, PT uzayishi < 3 / ≥ 3 / ≥ 6 s →
  0/1/2, fibrinogen < 1 g/l → 1; ≥ 5 — ochiq DIC bilan mos (har kuni takrorlash). Bal faqat "asosiy kasallik bor"
  deb belgilanganda hisoblanadi. PT uzayishi nimaga nisbatan ekani ochilgan jadvallarda yo'q — ekranda aytiladi.
- **Rasmlar:** DPDx sahifalaridagi ayrim rasmlar uchinchi tomonlarga tegishli (masalan, Leiden universiteti) —
  shuning uchun mikrofoto olinmadi; 7 parazit uchun ilovaning o'z `CustomPainter` sxemasi, "Sxema (foto emas)"
  belgisi bilan. Karta rasmlari — `tool/illustrations/{coagulogram,coprology}/gen_*.py` → `render_card.cjs`.
- **Tashxis emas:** o'qish yordamchisi va DIC natijasi ostida yo'llanma eslatmasi; "qoralama" belgisi domla
  tekshiruvigacha. Tafsilot: docs/COAGULOGRAM_SOURCES.md, docs/COPROLOGY_SOURCES.md.

## D-65. "Qoralama / tekshirilmagan" belgilari o'rniga adabiyot: "Manba: Muallif, yil, «nom», bob/bet" (2026-10-18, egasi qarori)

- **Qaror:** ilovadagi kontent ilmiy adabiyot bilan solishtirilgan; ekranda "Draft", "Qoralama",
  "mutaxassis tekshiruvidan o'tmagan", "Mustaqil mutaxassis tekshiruvi kutilmoqda", "tekshirilmagan" kabi
  yozuvlar ko'rsatilmaydi. O'rniga — yumshoq (amber emas) **"Manbalar" paneli**
  (`lib/features/tools/sources_panel.dart`: `SourcesPanel`, `SourcesNote`, `shortCitation`): har qator
  "Manba: <Muallif>, <yil>, «<nom>», <bob/bet>" (ru "Источник:", en "Source:"). Qatorlar bo'limning o'z
  `CalcSource`/`CalcRef` ro'yxatidan olinadi (yangi manba qo'shilmadi); bob/bet faqat ma'lum bo'lsa
  (masalan, JSST 2003, 7-bob, 233–252-bet — siydik tahlili). Sahifada manbalar ko'p bo'lsa — 4 tasi va
  "+ yana N ta — pastdagi ro'yxatda".
- **Tibbiy xavfsizlik eslatmasi saqlanadi** (Apple/tibbiy talab), bitta neytral qator (`sourcesDisclaimer`):
  "O'quv ma'lumotnomasi, tashxis emas: natijani shifokor klinik ma'lumotlar bilan baholaydi; referens
  oraliqlar laboratoriya va usulga bog'liq."
- **Qayerda:** siydik tahlili, spermogramma, qon guruhi, gistologiya, qon morfologiyasi, koagulogramma
  (`cgLeadRefs`), koprologiya (`cpLeadRefs`; "Darslik" — manba turi izohi, `CpL.textbookNote`), sitologiya
  (+ qo'shimcha sahifalar), leykoformula, jadvallar va algoritmlar, mikroskopiya atlasi, analit kartalari ("Manbalarga
  asoslangan: <karta manbalari>"), holatlar (shartlar) kartalari, paketlar, imtihon/mashq, toifa javob rejalari,
  sinf (ustoz) ekranlari. Analit/holat kartasidagi "Tekshiruv holati" paneli "Tayyorlanishi va manbalar" bo'ldi:
  tayyorlagan, manbalar ko'rilgan va solishtirilgan sanalar; "tasdiq kutilmoqda / tekshiruvchi tayinlanmagan /
  tarjima tekshiruvi kutilmoqda" qatorlari olib tashlandi (tasdiqlangan bo'lsa — ijobiy qator qoladi).
  Holat yorlig'i "Manbali namuna" → "Manbalarga asoslangan" (amber emas).
- **Paketlar va imtihon:** "draft" holat chipi ko'rsatilmaydi (sinov paketi belgisi qoladi). Imtihonda
  "Natija — ichki mashq uchun, rasmiy baho emas" (`examPracticeNotice`) qoladi; "tekshirilmagan" da'vosi yo'q.
  Savollardagi "Qoralama · tekshirilmagan" tegi olib tashlandi.
- **Kalitlar:** almashtirildi — `diffDraftTag`→`sourcesPanelTitle`, `diffDraftNote`→`sourcesDisclaimer`,
  `micDraftTag`→`sourceLine`, `cytoDraftNote`→`sourcesPanelMore`, `analyteSampleNotice`→`analyteSourcesBased`,
  `refDraftNote`→`refBooksNote`, `examDraftNotice`→`examPracticeNotice`, `packsCoreState`→`packsCoreSources`;
  o'chirildi — `packsStatusDraft`, `quizDraftTag`, `statusDraft`, `analyteExpertApprovalPending`,
  `analyteReviewerNotAssigned`, `analyteTranslationPending`, `analyteAgentCheckValue`; matni neytrallashtirildi —
  `condNotDiagnosticBody`, `condReferralFooter`, `analyteStructureOnlyBody`, `analyteNotWritten`,
  `analyteReview`, `analyteAgentCheck`, `statusSourcedSample`, `micEduNotice`, `quizReviewNote`, `examNoSource`,
  `toifaAboutOral`, `toifaPlanDisclaimer`, `toifaPlanPending`, `toifaPlanNotChecked`, `toifaAgentChecked`,
  `toifaNoteNoSource`, `classroomOralNotice`, `classroomCandidatesNotice`, `lectureDraftNotice`,
  `cytoDegreeSourceNote`, `intakeStep5`. Bo'lim matnlaridagi `draftNote` (UrL, SpermL, BgL, HisL, BmL) o'rniga
  `urLeadRefs`, `spermLeadRefs`, `bgLeadRefs`, `histoLeadRefs`, `bmLeadRefs`.
- **Qaytib kelmasligi uchun:** `test/unit/no_draft_wording_test.dart` — uch tildagi barcha ARB qiymatlari va
  `lib/` dagi ekran matnlari taqiqlangan so'zlar ro'yxati bilan tekshiriladi. Istisnolar (kontent holati haqida
  emas): foydalanuvchining o'z qoralamasi (ilmiy ish), maxfiylik, paket butunligi (SHA-256), faqat tekshiruvchi/
  admin ko'radigan ish oqimi (tekshiruv navbati, hamkor qoralamasi).
- **O'zgarmadi:** tibbiy matn, raqamlar, manbalar ro'yxati; ichki ma'lumot modeli (`status: draft`,
  `isDraft`, tekshiruvchi navbati) — faqat foydalanuvchiga ko'rinadigan yozuvlar. Rasmli ma'ruza slaydlaridagi
  (JPG) matn qayta chizilmadi.

## D-66. Variantli mavzu testi: "Har bir talabaga boshqa savollar" (2026-10-18, egasi savoli)

- **Muammo:** taqdimotdan "Guruhga topshirish" hammaga bir xil savollar to'plamini berardi (faqat tartib va
  variantlar aralashardi) — yonma-yon o'tirgan talabalar javob almashishi oson edi.
- **Qaror:** ixtiyoriy rejim (`AssignDeckTestScreen` dagi kalit). Mavzu hovuzi (≤ 60, ko'p bo'lsa — tasodifiy
  60 tasi) kamida 2 × N bo'lsa **standart yoqiq**, aks holda o'chiq va bosib bo'lmaydi (tushuntirish bilan);
  Supabase serverida yo'q (`LabBackend.supportsVariantTests`). Topshiriq hovuzni (`question_ids`), butun
  hovuz kalitini, `per_student = N` va `pool_topics` ni saqlaydi (migratsiya `0012_assignment_variants`).
- **Tanlov:** talaba to'plami saqlanmaydi, server va ilovada bir xil hisoblanadi — SHA-256(`aid:uid:savolId`)
  bo'yicha saralash, mavzu (birinchi `topicIds`) qatlamlari bo'yicha navbatma-navbat (qatlamlar tartibi ham
  talabaga qarab SHA-256 bilan). Shu sababli **adolat**: har talaba har kichik mavzudan deyarli teng (±1)
  savol oladi, "ortiqcha" savol beradigan mavzu talabadan talabaga almashadi — qiyinlik aralashmasi
  taqqoslanadi (har savol qiyinligini o'lchab bo'lmaydi; mavzu — eng yaqin ishonchli o'lchov). Umumiy test
  vektorlari: `cloudflare/test/variant_vectors.json` (TS va Dart ikkalasi tekshiradi).
- **Server:** `start` talaba to'plamini qaytaradi; `submit` da `question_ids` aynan shu to'plam bo'lishi shart
  (aks holda `400 invalid_questions`); ball — faqat o'z savollari bo'yicha, `total = N`; `submissions.question_ids`
  saqlanadi. `reveal` (muddat tugagach) o'zgarmadi. Jadvaldagi mavzu testi variantli emas.
- **Ustoz natijalari:** "Variantli test" yorlig'i va "har talabaga N ta, hovuzda M ta"; savol bo'yicha va eng
  qiyin savollar (topshiriq sahifasi va "Katta ekran") — har savol faqat u tushgan talabalar orasida, "n ta
  talabaga tushdi" bilan; eng qiyinlar xato ulushi bo'yicha. Talaba ekranida alohida belgi yo'q.

## D-67. M9 amaliy kunlari: "LabGuide tavsiya etgan amaliy reja" (2026-10-18, egasi qarori)

- **Muammo:** 9-modulning 45 ta amaliy kuni (d091–d142, ma'ruza kunlari d090/095/101/106/112/116/121/127 dan
  tashqari) barcha dars jadvallarida (Karimova 2026; Turg'unova 2026-04-25 va 2026-05-10 nusxalari) faqat
  "Laborator tekshiruv usullarini amaliyotda o'zlashtirish" deb yozilgan; dasturda (`КЛД_ихтисослаштириш_864`)
  M9 — 324 soat (ma'ruza 48, laboratoriya ishi 276), mavzu/kun ro'yxati yo'q. Egasi: "amaliy jadval hujjati yo'q —
  o'zing eng yaxshisini hal qil; kitoblardan foydalan".
- **Qaror:** kunma-kun reja LabGuide tomonidan tuziladi va **tavsiya** sifatida ochiq belgilanadi:
  `curriculum.json` da `plan_source: "labguide_recommended"`, `plan_block`, `plan_refs` (reja asoslangan darslik
  bob/bo'lim/sahifa), `links.protocols` (amaliy protokollar; `id#1-4` — tanlangan slaydlar). Ilovada kun meta
  qatorida "LabGuide tavsiya etgan amaliy reja" (ru/en), deckda sarlavha slaydida va birinchi "Kun rejasi"
  slaydida (jadvaldagi umumiy nom, tavsiya, "ustoz o'zgartirishi mumkin", Manba — `plan_refs`).
- **Tuzilish:** ma'ruzadan keyingi amaliy kunlar o'sha mavzuni mashq qiladi (A: UQT, B: surtma/leykoformula,
  C: siydik, D: balg'am va surtmalar, E: najas/parazitologiya, F: yarim avtomat analizator, G: fermentlar va
  fotometrik usullar, H: SRB/RF/ASLO → gemostaz → preanalitika → biologik xavfsizlik → ichki sifat nazorati →
  takrorlash → attestatsiyaga tayyorgarlik); blok ichida namuna olish → tayyorlash/bo'yash → sanash/o'lchash →
  talqin/QC. Tartib darsliklar bob tartibiga tayangan (Aripova 2007 X–XIII boblar; Kurbonova 2023 1–2, 5–6, 9–10,
  12-boblar; Aripov va b. 2006 I va III boblar; WHO 2010; Selivanov 2005; Saidov 2017).
- **Faqat mavjud manbali kontent:** 27 ta protokol, analit kartalari, lab bo'limlari, atlas, jadvallar. Yangi
  tibbiy matn yo'q. Kun decklari: reja slaydi + protokol slaydlari + analit/atlas; savol-javob bloki va og'zaki
  me'yor jadvali qo'yilmaydi (nomzodlar ma'ruza kunidan meros — mavzu testida ishlatiladi). Deck hajm byudjeti
  13 → 16 MiB (+~2.8 MB).
- **Manba:** `tool/curriculum/m9_plan.json` → `python3 tool/curriculum/apply_m9_plan.py` (curriculum.json va
  `docs/M9_PRACTICAL_TOPICS.md`; `--check` testda). Kun soni (143) o'zgarmadi (D-42; jadval variantlari 142/144
  kun faqat oxirida farq qiladi). Manbada kunma-kun mavzu paydo bo'lsa — reja o'sha manbaga moslanadi va
  `plan_source` olib tashlanadi.

## D-68. Ilova ichidagi QR skaner: guruhga qo'shilish va testni ochish (2026-10-18)

- **Muammo:** QR faqat telefonning o'z kamerasi orqali ishlardi (QR → sayt `site/j/` → "Ilovada ochish"),
  ilovada skaner yo'q edi (E2E_CLASSROOM_2026-10-18, 6-bo'lim: CI build bilan keyin qo'shish).
- **Qaror:** `mobile_scanner` **7.4.2** (BSD-3, 2026-09-14). Android: CameraX + bundled ML Kit (oflayn, Play
  Services shart emas), plagin minSdk 23 — bizda 24; iOS: AVFoundation/Vision, iOS 12+ — bizda 15.0, SwiftPM
  paketi bor (CocoaPods kerak emas). **Deployment target / minSdk / ci.yml o'zgarmadi.**
- **UI:** "QR kodni skanerlash" — qo'shilish ekranida (asosiy tugma) va "Guruh va topshiriqlar" da (qo'shilish
  plitkasi ostida). To'liq ekranli skaner: ramka, chiroq, "Kodni yozish yoki qo'yish" zaxira yo'li; ruxsat yo'q —
  "Sozlamalarni ochish" (Android `APPLICATION_DETAILS_SETTINGS`, iOS `app-settings:`), qaytganda qayta urinish.
  O'qilgan matn mavjud `parseInvite` bilan (sayt havolasi, `labguide://app/j`, xom kod); begona QR — xabar, skaner
  ochiq qoladi. Topilsa — tebranish (`HapticFeedback.mediumImpact`), skaner yopiladi, darhol qo'shiladi (taxallus
  ixtiyoriy, oldingi guruhdan to'ldiriladi), `a=` bo'lsa — test ochiladi. Avtomatik qo'shilish faqat ilova
  ichidan (`GoRouter extra`), deep link bilan emas.
- **Platforma:** faqat Android/iOS; veb/desktop — tugma ko'rinmaydi. Plagin faqat
  `lib/features/classroom/qr_scanner.dart` da, `QrScanner` interfeysi ortida (`AppServices.qrScanner`); testlar
  soxta skaner bilan (`test/helpers/fake_qr_scanner.dart`).
- **Ruxsatlar:** Android `CAMERA` + `android.hardware.camera` `required="false"` (kamerasiz qurilmalar ham
  o'rnatadi). image_picker (hujjat surati) Android'da manifestda `CAMERA` bo'lsa ruxsatni o'zi so'raydi. iOS
  `NSCameraUsageDescription` (Info.plist va uz/ru/en `InfoPlist.strings`) QR skanerni ham tilga oladi.
- **Maxfiylik:** kadr qurilmada o'qiladi, saqlanmaydi, yuborilmaydi (siyosat 14-bo'lim, "Qisqacha"). Android'da
  ML Kit Google'ga SDK diagnostikasini yuboradi (Google data disclosure) — siyosatda ochiq yozildi; Play Data
  safety belgilari egasi qarori (`docs/store/APP_STORE.md` 12-bo'lim, `PRIVACY_OPEN_QUESTIONS.md` 5a).
- **Tekshiruv:** native qism faqat CI build'da (Android + iOS) tekshiriladi — bu muhitda build yo'q. Qorovul:
  `test/guards/classroom_guard_test.dart :: Ilova ichidagi QR skaner (D-68)`.

## D-69. Ilova xaritasi savollari Q1–Q8 bo'yicha qarorlar (2026-10-18, egasi topshirig'i: "eng yaxshisini hal qil")

Manba: `docs/APP_MAP_2026-10-18.md` §4. Har qaror minimal o'zgarish bilan; eski manzillar ishlayveradi.

- **Q1 — bitta mavzu, bitta ma'ruza:** o'quv dasturining 188 mavzusining hammasi uchun katalogda tayyor 16:9
  taqdimot bor. Ma'ruza ro'yxatining pastki "Dastur mavzulari — avtomatik slaydlar" bo'limi olib tashlandi.
  `/learn/lecture/<topicId>` tayyor deckka yo'naltiriladi (`/learn/lecture/deck/<id>`, router `redirect`);
  deck yo'q bo'lsa — avtomatik slaydlar (zaxira). Guruh darsida "Avtomatik slaydlar" ikkinchi tugmasi faqat deck
  yo'q bo'lsa (o'shanda u asosiy tugma). "Avtomatik taqdimot" (mavzu/tahlillardan yig'ish) qoladi.
- **Q2 — Lab tabi tartibi:** avval "Ish vositalari" (Leykoformula birinchi, so'ng kalibrlash, QC, preanalitika,
  kalkulyatorlar, apparatlar), keyin "Bo'limlar va atlaslar" (rasmli bo'limlar, mikroskopiya atlasi).
- **Q3 — bosh sahifa hero:** hero tugmasi 1-plitkani takrorlamaydi. Shu qurilmada oxirgi ochilgan taqdimot,
  mavzu testi yoki bo'lim bo'lsa — "Davom ettirish" (izohda nomi; `StoreKeys.homeResume`, router manzilidan
  yoziladi). Tarix bo'lmasa — rolning boshlang'ich amali: talaba — kunlik savollar, ustoz — guruhlar, laborant —
  bugungi toifa mashg'uloti (toifa ko'rinsa) yoki QC, shifokor — tahlil qidiruvi (`/tests?search=1`, maydon
  fokusda). Talabadagi "Kunlik savol" plitkasi olib tashlandi (shu sahifada Kunlik karta bor). Eslatma: ustoz va
  (toifasiz) laborantda tarix bo'lmagan birinchi ochilishda zaxira amal 1-plitka bilan bir manzil — topshiriqdagi
  qaror shunday; tarix paydo bo'lgach hero "Davom ettirish" bo'ladi.
- **Q4 — Ma'ruza qidiruvda hamma rolga** (O'rganish tabidagi qator bilan bir xil; `teacherOnly` olib tashlandi).
- **Q5 — "Dars rejasi"** O'rganish tabida faqat ustozga va server tasdiqlagan adminga ko'rinadi. "Ilmiy ish
  maydoni" (Kutubxona) alohida qoladi, birlashtirilmadi.
- **Q6 — "Yordam va aloqa":** Profilda bitta kirish (`/profile/help`), ichida ikki aniq yo'l: ilova ichidagi
  yozishma ("Taklif va yordam", `/profile/support`, o'qilmagan javob belgisi bilan) va email/shikoyat ("Aloqa va
  shikoyat", `/profile/contact`). Ikkala manzil va boshqa joylardagi havolalar (hamjamiyatdagi shikoyat,
  kontent so'rovi) o'zgarmadi.
- **Q7 — atlas bo'limi nomi:** "Parazitlar" → "Qon parazitlari (bezgak)" / "Кровяные паразиты (малярия)" /
  "Blood parasites (malaria)" (`assets/microscopy/atlas.json`, manba `tool/microscopy_atlas_src.py`). Koprologiyadagi
  "Parazitlar" (ichak parazitlari) o'zgarmadi.
- **Q8 — "Bo'lim mashqlari":** O'rganish tabida mashqi bor har Lab bo'limining mashqi bitta guruhda, bir xil
  ko'rinishda ("<bo'lim> — mashq"): leykoformula, mikroskopiya, sitologiya, spermogramma, qon guruhi, gistologiya,
  siydik tahlili, qon morfologiyasi. Koagulogramma va koprologiyada hozircha mashq yo'q — mashq qo'shilsa,
  `kLabSectionQuizzes` ga qo'shiladi.
- **Testlar:** `test/widget/app_map_test.dart` (Q2, Q3, Q5, Q6, Q7, Q8), `lecture_deck_test.dart` (Q1
  yo'naltirish va zaxira), `global_search_test.dart` (Q4), `tab_memory_test.dart` (Q3 hero).

## D-70. Audit 2026-10-24 bo'yicha P0 tuzatishlar va Pro narxlari (TAKLIF — egasi tasdig'ini kutadi)
> **QISMAN SUPERSEDED (D-73/D-76/D-77, 2026-10-25):** quyidagi “Pro narxlari — TAKLIF” bandi (Oddiy $3.99, Ustoz $5.99,
> “30 kunlik bepul foydalanish”) — tarix. Amaldagi: narxlar D-73/D-76 (`ProPricing`), sinov **7 kun** (D-76, D-77).
> P0 tuzatishlar va qolgan bandlar o'zgarmagan.
- **ANC / eozinofil yo'llash chegarasi** endi YAXLITLANMAGAN qiymat bo'yicha (0,497 ekranda "0,50" bo'lsa ham
  `< 0,5` — yo'llanadi). D-audit #13 dagi "ekrandagi qiymat" qarori bekor qilindi (xavfsizlik tomoniga).
  Test: `test/unit/diff_assessment_test.dart`. Shifokor/mutaxassis siyosatini tasdiqlashi kerak.
- **Kalibrovka yozuvi** standart holati `pending` (avval `accepted`). Tasdiqlovchi, kalibrovkadan keyingi QC,
  SOP havola va o'zgarmas audit izi — keyingi bosqich (hali yo'q).
- **IFU moslash** analitni ham tekshiradi (`IfuQuery.analyteId`). Reagent ishlab chiqaruvchisi tekshiruvi hali yo'q.
- **CI:** `ios` (macOS, pullik) job faqat `build`/`testflight` rejimlarida yoki `v*` tegida ishga tushadi.
- **Pro narxlari — TAKLIF, YOQILMAGAN:** Talaba $1.49/oy (rejalashtirilgan bazaviy), Oddiy $3.99/oy, Ustoz $5.99/oy
  (taklif). Yillik narxlar va 30 kunlik bepul foydalanish mexanizmi TASDIQLANMAGAN. D-49 (7/14 kunlik sinov),
  D-57 (Ustoz $6.99) va 29 000 so'm/$4.99 eskirgan hisoblanadi, lekin egasi tasdiqlamaguncha kodda o'zgarmaydi.
  Pro faqat main'dan yangi alohida tarmoqda tayyorlanadi (`pro-later` — eski surat); bepul reliz o'zgarmaydi.
- **Ochiq (egasi qarori):** Toifa bo'limi hozir til UZ yoki qurilma mintaqasi UZ bo'lsa ko'rinadi (D-40). Master
  rejadagi "til mamlakatga bog'lanmasin" bilan ziddiyat: ruscha tilli va rus mintaqali foydalanuvchi ko'rmaydi.
  Variant: sozlamalarda ochiq tanlov.


## D-71. Pro tarmog'i (`pro-next`): haqiqiy holat, bayroqlar, TAKLIF narxlar (2026-10-24, TASDIQLANMAGAN)
> **QISMAN SUPERSEDED (D-73/D-76/D-77, 2026-10-25):** TAKLIF narxlar (3.99/5.99) va “30 kunlik bepul foydalanish —
> mexanizm OCHIQ qaror” yopildi: narxlar D-73/D-76, sinov — server beradigan **7 kun** (D-76, D-77). Bayroqlar
> (`proEnabled` standart `false`, `gated` bo'sh) qoidasi amalda. Quyidagi matn — tarix.
Bu yozuv faqat `pro-next` tarmog'ida. Bepul reliz (`main`) o'zgarmaydi: D-58 u yerda kuchda.

**Tarmoq haqiqati.** `pro-later` — jonli tarmoq emas, `7141aff` (D-58 olib tashlash) dan bir commit oldingi
`main` surati; `main` ning ajdodi, hech narsa birlashtirmaydi. Shuning uchun Pro kodi `7141aff^` dan
(`git show 7141aff^:<yo'l>`) qo'lda qayta tiklandi va joriy `main` (router, learn/exam/toifa/classes, profil, ARB)
bilan solishtirib moslandi. `pro-next` = `origin/main c8c9430` + shu ish. `pro-later` arxiv bo'lib qoladi.

**Bayroqlar (hammasi standart O'CHIQ).**
- Ilova: `BuildFlags.proEnabled` (`--dart-define=LG_PRO_ENABLED=true`, standart `false`, release'da doimiy).
  O'chiq bo'lsa: `EntitlementService.disabled()` (do'kon yo'q, server yo'q, `can()` doim `true`), `start()`
  chaqirilmaydi, `in_app_purchase` ishga tushmaydi, `/profile/purchase` yo'li ro'yxatda yo'q, Profil'da obuna
  qatori yo'q, billing so'rovi ketmaydi. Testlar: `test/widget/pro_flag_off_test.dart`,
  `test/guards/pro_flag_default_guard_test.dart`, `product_policy_guard_test.dart`.
- Server: `LG_BILLING_ENABLED=true` (Worker env). Bo'lmasa `/v1/billing/*`, `/v1/entitlements` — 404
  (`cloudflare/test/guards.test.ts`). Do'kon kalitlari (`APPLE_IAP_*`, `GOOGLE_PLAY_SERVICE_ACCOUNT`) ham kerak.
  Migratsiya 0007 → `0014_billing.sql` (dastlab `0013_billing.sql`; audit birlashmasida 0014 ga ko'chirildi, 0013 — `0013_admin_step_up`) (0007 raqami D-58 da band deb belgilangan; eski 0003 `entitlements` jadvalini
  almashtiradi — hech qachon yozilmagan). CI (`ci.yml`) tegilmagan: `deploy_api` billing secretlarini o'rnatmaydi.
- Yopiladigan imkoniyatlar: `ProGatePolicy.gated` — BO'SH. Boshlash nuqtalari ulangan (`requireFeature`), lekin
  hech narsa yopilmaydi.
- Bepul davr: `ProTrialConfig.freeTrialDays` = `null` (o'chiq).

**TAKLIF narxlar (egasi tasdiqlamagan; `lib/core/entitlements/pro_catalog.dart`, MA'LUMOT — UI'da qotirilmagan).**
| Reja | Oylik (USD) | Yillik |
|---|---|---|
| Talaba (`...pro.student.monthly`) | 1.49 | belgilanmagan (null) |
| Oddiy / Pro (`...pro.monthly`) | 3.99 | belgilanmagan (null) |
| Ustoz Pro (`...teacherpro.monthly`) | 5.99 | belgilanmagan (null) |
Foydalanuvchi ko'radigan narx doim do'kondan (mahalliy valyuta). Yillik narx `null` bo'lsa yillik mahsulot to'lov
oynasida ko'rsatilmaydi. TODO(owner): yillik narxlar. ESKIRGAN va hech qayerda faol emas: 29 000 so'm/$4.99,
Ustoz $6.99, talaba 9 000 so'm, yillik 199 000/269 000 so'm, 7/14 kunlik sinov (D-48, D-49, D-50, D-57). Tekshiruv:
`pro_flag_default_guard_test.dart :: eski narxlar …`.

**30 kunlik bepul foydalanish — mexanizm OCHIQ qaror.** Faqat `freeTrialDays` (nullable; `null` = o'chiq; `> 0` =
kunlar) va `ProTrialMechanism` ilgagi bor. Variantlar: (a) do'kon-native kirish taklifi (Apple Introductory Offer /
Google Play free-trial offer): kunlar do'konda sozlanadi, ilova `StoreProduct.freeTrial` ni do'kondan o'qiydi,
karta/Apple ID olinadi, 3.1.2 matni do'konnikidan — shu ilova kodida allaqachon ishlaydi; (b) server beradigan
sinov huquqi (kartasiz): serverda `trial_until` kerak — HALI YO'Q, 3.1.2 matni va suiiste'mol cheklovi alohida
loyihalanadi; (c) yo'q. Tanlov bo'lmaguncha `freeTrialDays` ni yoqmang.

**Rejadagi yopish ro'yxati bilan ZIDDIYAT (hech narsa yopilmadi).** `docs/PRO_BILLING_PLAN.md` §1 (D-46/D-53) bugun
`main` da BEPUL bo'lgan imkoniyatlarni yopardi: cheksiz savollar (mavzu mashqi, kartadan mini-test), imtihon
simulyatsiyasi, to'liq toifa banki, zaif mavzular tahlili, atlas mashqi, to'liq tarix (`unlimitedHistory`),
guruh ochish, topshiriqlar, ma'ruza/avto-taqdimot. D-53 "bepul — kunlik 5 savol" `main` da yo'q. Yopish =
bor imkoniyatni olib qo'yish (foydalanuvchi e'tirozi, mavjud ustozlar). Qaror: standart — hech narsa yopilmaydi;
egasi ro'yxatni (va mavjud foydalanuvchilarni saqlab qolishni) belgilaguncha `ProGatePolicy.gated` bo'sh.
Ulangan boshlash nuqtalari: imtihon boshlash, toifa test/mashq boshlash, mavzu mashqi raundi, atlas mashqi raundi,
guruh ochish, avto-taqdimot boshlash, tarix ko'rinishi (`historyView`), zaif mavzular. UlanMAGAN (eski reja
ularga ega edi, qayta ulash kerak bo'lsa): topshiriq yaratish (endi `topic_test_screens`/`general_test_screen`),
ma'ruza ro'yxati qatorlari (`lecture_screens`, `classroom_screens`), toifa mashq qatorlari, kartadan mini-test
"yopiq" holati, `toifaAllows`.

**Saqlangan ilgaklar (hammasi o'chiq).** StoreKit 2/Play Billing (`in_app_purchase` 3.3), xaridni tiklash,
yangilash/bekor/grace/billing retry/refund holatlari, mehmon xaridi: eski kod hisobsiz xaridga RUXSAT bergan (qurilmada
ishlaydi, hisobga kirilganda bog'lanadi; App Store 5.1.1) — "mehmon xarid qila olmaydi" qoidasi kodda YO'Q (egasi
xohlasa — ochiq qaror #10), HMAC imzolangan 7 kunlik oflayn kesh, "bitta xarid —
bitta hisob" (`owned_by_other`), ASSN v2/RTDN.

**HALI YO'Q:** talaba tasdig'i (`studentVerified=false`, talaba mahsulotlari ko'rinmaydi), referral/ustoz-elchi
(D-50 g'oya), mintaqaviy narx (faqat do'kon narxlari; Apple UZ — USD, Play UZS tasdiqlanmagan), maxfiylik
siyosati/foydalanish shartlarida obuna bo'limi (`PRIVACY_POLICY.md`, `site/privacy`), Data safety/App Privacy
(xarid tarixi) yangilanishi, x5c zanjirini Apple Root CA bilan tekshirish (eski cheklov), do'kon mahsulotlari va
kalitlari, sandbox matritsasi (xarid/tiklash/bekor/grace/refund/boshqa hisob).

**Ogohlantirish.** `pubspec.yaml` da `in_app_purchase` bor: bu tarmoqdan yig'ilgan Android build manifestga
`com.android.vending.BILLING` ruxsatini qo'shadi (plagin birlashtiradi) — bepul reliz FAQAT `main` dan yig'iladi.
`pro-next` ni `main` ga qo'shish: do'konlarda bepul reliz tasdiqlangandan keyin, egasi roziligi bilan, 
`product_policy_guard_test` (D-58 qatiy variantiga qaytarilgan nusxa bilan) qayta ko'rib chiqilgach.

**Egasi qarorlari (ochiq):** (1) narxlar USD 1.49/3.99/5.99 — ha/yo'q/tahrir; (2) yillik narxlar yoki yillik yo'q;
(3) Play UZS narx pog'onalari, Apple UZ = USD qabul; (4) 30 kun: (a)/(b)/(c); (5) talaba — tasdiqdan keyin yoki
ochiq; (6) qaysi imkoniyatlar yopiladi, mavjud foydalanuvchilar (grandfathering); (7) `pro-next` → `main` qoidasi,
`pro-later` ni arxiv tegi qilish; (8) do'kon kalitlari kimda va `deploy_api` qachon; (9) maxfiylik/shartlar matni; (10) mehmon xarid qila olsinmi yoki avval hisob shartmi.

## D-72. Pro taklifi: yillik tarif, 30 kunlik davr, pullik funksiyalar, bepul huquqlar (2026-10-24, TAKLIF)
> **SUPERSEDED (D-73/D-76/D-77, 2026-10-25):** 30 kunlik davr → 7 kunlik server sinovi (D-76); narxlar → D-73/D-76.
> Quyidagi matn — tarix.
Egasi 2026-10-24 topshirig'i: Pro `pro-next` da tayyorlanadi, `proEnabled=false` saqlanadi; taklif narxlar Talaba $1.49, Oddiy $3.99,
Ustoz $5.99 (oylik); yillik, 30 kunlik bepul davr va pullik funksiyalar — ALOHIDA TAKLIF sifatida; mavjud bepul foydalanuvchilar
huquqi egasi qarorisiz cheklanmaydi; billing/paywall/server faollashtirilmaydi. To'liq matn: `docs/PRO_PROPOSAL_D72.md`.
Kodga o'zgarish kiritilmadi (D-71 holati o'zgarmaydi).


## D-73. Pro: egasi narxlari (3 daraja), admin tomonidan Pro berish (2026-10-24; narxlar EGASI QARORI, Pro YOQILMAGAN)
`pro-next` tarmog'ida. `main` va bepul reliz o'zgarmaydi. **Hech narsa deploy qilinmadi, yoqilmadi, do'konga yuborilmadi;
production D1 ga migratsiya qo'llanmadi** (0015 — faqat fayl). `BuildFlags.proEnabled` standart `false`,
server `LG_BILLING_ENABLED` o'chiq (billing va admin grant yo'llari 404), `ProGatePolicy.gated` BO'SH,
`ProTrialConfig.freeTrialDays = null` — mavjud bepul foydalanuvchilar huquqi o'zgarmaydi.

**1. Narxlar — OWNER-DECIDED 2026-10-24 (lekin ENABLED EMAS).** D-71/D-72 dagi taklif narxlar va tariflar ularni
almashtirib bekor qiladi (Standart 3.99, eski Ustoz 5.99, yillik `null`). Narx kodda MA'LUMOT
(`lib/core/entitlements/pro_catalog.dart`, `ProPricing`); ekran narxni do'kondan oladi.
| Daraja | Oylik (USD) | Yillik (USD) |
|---|---|---|
| Talaba (Student) | 1.49 | 9.99 |
| Ustoz (Teacher) | 2.49 | 24.99 |
| Mutaxassis (Specialist) | 3.49 | 34.99 |
Yillik narx belgilangani uchun yillik mahsulot ro'yxatda (`annualOffered`), lekin hammasi baribir bayroq ortida.
Eski-narx qorovuli o'z kuchida: 29 000 so'm, $4.99, $6.99, 7/14 kunlik sinov — endi 3.99 va 5.99 ham taqiqlangan
(`pro_flag_default_guard_test`). Hozirgi 9.99 va 34.99 yangi yillik narxlar bo'lgani uchun taqiqdan olindi.

**Daraja → ilova darajasi (`ProTier`) moslashi** (tayyorgarlik; hech narsa yopilmagani uchun amalda ta'sirsiz):
Talaba → Pro; Ustoz → Ustoz Pro; Mutaxassis → Ustoz Pro darajasi (eng qimmat reja kamroq bermasin). Server
huquqni hal qilishda tartib: Talaba < Ustoz < Mutaxassis (narx tartibi). Bu moslash — ochiq qaror.

**Mahsulot id'lari** (do'konlarda HECH QANDAY mahsulot hali yaratilmagan, shuning uchun nomlarni almashtirish bepul):
| Yangi id | Daraja | Eski id (alias sifatida qoldi) |
|---|---|---|
| `uz.labguide.student.monthly` / `.yearly` | Talaba | `uz.labguide.pro.student.monthly` / `.yearly` |
| `uz.labguide.teacher.monthly` / `.yearly` | Ustoz | `uz.labguide.teacherpro.monthly` / `.yearly` |
| `uz.labguide.specialist.monthly` / `.yearly` | Mutaxassis | `uz.labguide.pro.monthly` / `.yearly` (eski «Oddiy/Pro» → Mutaxassis) |
Eski id'lar `BillingCatalog.legacyAliases` va serverdagi `BILLING_PRODUCTS` da faqat o'qish uchun alias (eski server
qatori / kesh buzilmasin); yangi do'kon mahsuloti ularda YARATILMAYDI. Unit test ilova va server ro'yxatini solishtiradi.

**2. Bepul sinov.** `freeTrialDays` = `null`, mexanizm (`undecided`) o'zgarmadi: 30 kunlik davr hali qaror qilinmagan,
hech narsa yozilmadi.

**3. Admin tomonidan Pro berish** (faqat `LG_BILLING_ENABLED=true` bo'lganda mavjud; bo'lmasa 404, hatto admin
tokeni bilan ham).
- Yo'llar: `POST /v1/admin/pro-grants {email, tier: student|teacher|specialist, durationDays?: 30|90|365|null,
  note?, mode?: replace|extend}`, `DELETE /v1/admin/pro-grants/:id`, `GET /v1/admin/pro-grants` (faol va kutilayotgan).
- Vakolat: serverda berilgan admin roli (`admins`) VA TOTP (aal2) — mavjud `requireAdmin` modeli. Oddiy foydalanuvchi
  403, TOTP siz admin 403, tokensiz 401. Egasi paneli (TOTP siz, `ADMIN_EMAILS`) bu amalga YETMAYDI: Pro berish —
  “Adminlar boshqaruvi” kabi 2FA talab qiladi.
- Email: trim + kichik harf (`normalizeEmail`), yaroqsiz email 400; saqlashda faqat HMAC + niqob (`ab***@…`), javob va
  jurnalda to'liq email yo'q. Daraja/muddat/izoh tekshiriladi (izoh ≤ 200 belgi, boshqaruv belgilarisiz).
- Hisob yo'q bo'lsa grant KUTILMOQDA (`starts_at IS NULL`); hisob ochilganda yoki birinchi kirishda
  (`findOrCreateUser`, email kodi ham Google/Apple ham) qo'llanadi — muddat shu paytdan; jurnal `pro_grant_applied`.
  Hisob bor bo'lsa — darhol. Kirish hech qachon grant xatosi tufayli to'xtamaydi.
- Qayta berish aniq: `replace` (standart; daraja/muddat/izoh yangilanadi, muddat hozirdan, bitta faol qator) yoki
  `extend` (mavjud tugashidan uzaytiradi, yuqori daraja qoladi; kutilayotganga 409 `pending_cannot_extend`,
  muddatsiz so'rovga `duration_required`). Bir emailga bitta faol grant (unique indeks).
- Huquqni hal qilish (`resolveAccess`, `GET /v1/billing/entitlements` da `resolved`): faqat hozir amaldagilar;
  YUQORI daraja yutadi, teng darajada UZOQROQ muddat (muddatsiz — eng uzoq), to'liq tenglikda DO'KON. Admin grant
  do'kon obunasini hech qachon bosib o'tmaydi va uni o'chirmaydi; grant qatori `source: admin_grant`,
  `platform: admin_grant`, `ownership: granted`. Muddat tugasa `expired` (huquq yo'q); bekor qilinsa qator darhol yo'qoladi.
- Audit (`audit_log`): `pro_grant_created|replaced|extended|revoked|applied` — kim (actor), nishon grant id, ichida
  niqoblangan email, daraja, `until`, hisob id si. Izoh jurnalga yozilmaydi.
- Limit: berish soatiga 30, bekor soatiga 60, ro'yxat 10 daqiqada 60 (har admin uchun); faol grantlar ≤ 2000.
- Hisob o'chirilsa shu emailning grantlari ham o'chadi (`deleteUserData`).
- Ilova: Admin panelda “Pro berish” qatori → ekran (email, daraja, muddat, izoh, uzaytirish tanlovi, tasdiq oynasi;
  faol/kutilayotgan ro'yxat; qaytarib olish — tasdiq bilan). FAQAT `BuildFlags.proEnabled` VA admin (AdminGate: admin
  roli + TOTP) bo'lganda; bayroq o'chiq bo'lsa `services.proGrants == null`, qator ham yo'l ham yo'q — panel avvalgidek.
  Klient `admin_grant` qatorini taniydi (`ServerEntitlement.isAdminGrant`, `ProSource.adminGrant`), eng yaxshisini
  serverdagi qoida bilan tanlaydi.
- Migratsiya `cloudflare/migrations/0015_pro_grants.sql` — FAYL. Qo'llash egasi `deploy_api` ni ishga tushirganda
  (CI bu ishda ishga tushirilmadi). 0007 raqami band bo'lib qoladi.

**4. Regressiya qorovullari.** `proEnabled` standart false; `ProGatePolicy.gated` bo'sh va hech bir bepul imkoniyat
unda yo'q; bayroq o'chiq — paywall/obuna qatori/admin “Pro berish” yo'q (`admin_pro_grant_test`,
`pro_flag_default_guard_test`, `product_policy_guard_test`); admin grant yo'llari bayroqsiz 404
(`cloudflare/test/progrants.test.ts`, `guards.test.ts`); billing va grant kodi `app.ts` da faqat `billingRoutes` ichida.

**5. HALI OCHIQ (egasi qarori kerak).**
1. 30 kunlik bepul davr mexanizmi: do'kon kirish taklifi (a) yoki server `trial_until` (b) yoki yo'q (c).
2. Nima pullik bo'ladi (`ProGatePolicy.gated`), va har daraja nimani ochadi (Talaba/Ustoz/Mutaxassis farqi, yuqoridagi
   moslash to'g'rimi).
3. Mavjud bepul foydalanuvchilar (grandfathering): hozirgi huquq saqlanishi — tavsiya HA, qaror emas.
4. Mehmon xaridi qoidasi: hisobsiz sotib olish mumkinmi (eski kod ruxsat bergan).
5. UZS narx pog'onalari (Play UZS; Apple UZ — USD qabul) va yillik narxning mahalliy yaxlitlanishi.
6. Do'kon mahsulotlari va kalitlari (yuqoridagi yangi id'lar bilan App Store Connect / Play Console), `deploy_api`
   qachon va kim; `APPLE_IAP_*`, `GOOGLE_PLAY_SERVICE_ACCOUNT`.
7. Maxfiylik siyosati / Foydalanish shartlari matni (obuna va admin bergan Pro), Play Data safety / App Privacy yangilanishi.
8. Talaba tasdig'i (usuli; hozir `studentVerified=false`, talaba mahsulotlari ko'rinmaydi).
9. Admin grant siyosati: kim bera oladi (hozir har aal2 admin), maksimal muddat/ro'yxat hajmi, kutilayotgan grantning
   amal qilish muddati (hozir cheksiz), grant haqida foydalanuvchiga xabar (hozir yo'q).
10. `pro-next` → `main` qoidasi va `pro-later` arxiv tegi (D-71 #7).

## D-74. Pro: reja ↔ panel ajratish (server), 30 kunlik sinov — bir telefonga bir marta, “Obuna” ekrani (2026-10-24; Pro YOQILMAGAN)
> **QISMAN SUPERSEDED (D-76, 2026-10-24, egasi qarori):** matritsa (§1: Mutaxassis → ustoz paneli, `specialist`
> imkoniyati) va sinov muddati (30 kun) D-76 bilan almashtirilgan; qolgan qoidalar amalda. Quyidagi matn — tarix.
`pro-next` tarmog'ida. **Hech narsa deploy qilinmadi, yoqilmadi, do'konga yuborilmadi; production D1 ga migratsiya
qo'llanmadi** (`0016_pro_trials.sql` — faqat fayl). `BuildFlags.proEnabled` standart `false`; server yo'llari
(`/v1/billing/trial/*`, `/v1/pro/*`) `LG_BILLING_ENABLED=true` bo'lmasa 404; qurilma attestatsiyasi tekshiruvchisi
production'da ULANMAGAN — sinov `503 device_attestation_not_configured`. `ProGatePolicy.gated` BO'SH (bugun bepul
hech narsa pullik bo'lmadi), mavjud bepul foydalanuvchilar va bepul ustoz paneli (guruhlar, topshiriqlar) o'zgarmadi.
Egasi qoidalari (topshiriq 2026-10-24): (1) Talaba rejasi ustoz panelini ochmasin, qaror serverda; (2) 30 kunlik
bepul sinov bir telefonga bir marta; (3) ilovada aniq “Obuna” ekrani.

**1. Daraja × imkoniyat matritsasi (MA'LUMOT, `cloudflare/src/tiers.ts` `TIER_CAPABILITIES`; ilova nusxasi
`lib/core/entitlements/plan_matrix.dart`, test solishtiradi).** Imkoniyat — funksiya emas, TOIFA; yangi funksiya
o'ylab topilmadi. Kelajakda `gated` ga qo'shiladigan har funksiya toifaga tegishli (`Feature.tier`: pro → `learner`,
teacher → `teacher_panel`) va daraja faqat o'z to'plamidagini ochadi.
| Daraja | `learner` (talaba tomoni Pro) | `teacher_panel` (ustoz paneli Pro) | `specialist` (mutaxassis Pro) |
|---|---|---|---|
| Talaba | ha | **yo'q** | yo'q |
| Ustoz | ha | ha | yo'q |
| Mutaxassis | ha | ha (D-73: “eng qimmat reja kamroq bermasin”) | ha |
Mutaxassis → Ustoz paneli huquqi D-73 moslashidan; qat'iy variant (`learner + specialist`) — ochiq qaror #2.

**2. Serverda tekshiruv — `requireTier(ctx, capability)`.** Qaror faqat serverda saqlangan huquqdan (`loadAccess`:
do'kon obunasi, admin grant, sinov → `resolveAccess`); `users.role` (ilovada tanlanadigan rol, `PUT /v1/me/profile`)
va lokal sozlamalar hech narsa ochmaydi. Bayroq o'chiq → 404; sessiyasiz → 401; huquq yo'q → 403 `plan_required`;
daraja ochmaydi → 403 `tier_insufficient`. Inert yo'llar: `GET /v1/pro/access` (daraja + imkoniyatlar),
`GET /v1/pro/check/:capability` (Pro-only yo'llar namunasi; `teacher_panel` uchun qo'shimcha `teacher_accounts` —
bepul ustoz paneli qoidasi bilan bir xil, aks holda 403 `teacher_role_required`). Bepul ustoz paneli `requireTier`
ga ulanMAGAN. Admin grant ham darajaga bo'ysunadi (Talaba grant → ustoz paneli yo'q). Testlar:
`cloudflare/test/tiers.test.ts`.

**3. Bepul sinov — bir telefonga bir marta (server mexanizmi, o'chiq).** `POST /v1/billing/trial/challenge` (5 daqiqalik
bir martalik nonce, faqat SHA-256 saqlanadi) → ilova `DeviceAttestor` bilan attestatsiya → `POST /v1/billing/trial/start
{tier, email, attestation:{platform, token, nonce, key_id?}}` → 201 + huquqlar surati (`source: trial`). Qoidalar:
- Hisob: sessiya shart (mehmonning server hisobi yo'q → 401). Email: so'rovdagi email `users.email_hash` bilan mos
  bo'lishi kerak (hisob faqat OTP yoki provayder `email_verified` bilan yaratiladi) — aks holda 403 `email_not_verified`.
- (a) Kanonik email (`canonicalEmail`): trim + kichik harf; Gmail/Googlemail — nuqtalar va `+teg` olib tashlanadi;
  Microsoft (`outlook/hotmail/live/msn`) va Yandex (`yandex.*`, `ya.ru` → `yandex.ru`) — `+teg`. Faqat sinov kaliti;
  kirish identifikatori o'zgarmaydi. Boshqa provayder aliaslari (bir martalik domenlar va h.k.) — qo'shilmadi.
- (b) Qurilma: server `DeviceAttestationVerifier` interfeysi (`verify` → barqaror `subject` + platforma bayrog'i
  `alreadyUsed`, ixtiyoriy `markUsed`); standart `UnconfiguredVerifier` → 503. Haqiqiy Apple/Google tekshiruvchi YO'Q;
  testlarda `cloudflare/test/fake_attestation.ts`. Ilova: `DeviceAttestor` + `UnconfiguredDeviceAttestor` (standart).
- Saqlash: faqat HMAC (server kaliti `keys.trial`, `LG_SERVER_SECRET` dan) — `email_key`, `device_key`
  (platforma + subyekt). Xom email, qurilma id si, attestatsiya tokeni yozilmaydi; jurnalda faqat hisob id, daraja,
  muddat, platforma. **Saqlash muddati: sinov boshlanganidan 730 kun (24 oy)**, keyin kunlik tozalash o'chiradi
  (`TRIAL_RETENTION_DAYS`). `LG_SERVER_SECRET` almashtirilsa eski yozuvlar mos kelmaydi (sinov qayta ochiladi).
- (c) Bitta sinov: hisobga (`user_id`), kanonik emailga, qurilmaga (unikal indekslar, parallel so'rov ham) → 409
  `trial_already_used` (sababi ataylab aytilmaydi).
- (d) Hisob o'chirilganda yozuv O'CHMAYDI: `user_id = NULL`, `account_deleted_at` — qayta ro'yxatdan o'tish sinovni
  qaytarmaydi. Maxfiylik asosi: suiiste'molning oldini olishdagi qonuniy manfaat, minimal ma'lumot (kalitli xesh),
  cheklangan muddat; matn loyihasi `site/privacy` §10a (uz/ru/en) va ARB `proPrivacyTrialNote` (ilovada faqat
  bayroq bilan) — FAQAT `pro-next` da, Pro yoqilmaguncha nashr qilinmaydi. Yurist/egasi tasdig'i kerak.
- (e) Limitlar: start — hisobga 5/soat, IP ga 30/soat; challenge — hisobga 20/soat.
- (f) Daraja ruxsati (serverdagi yozuvlardan): Talaba — har hisob; Ustoz — `teacher_accounts` (serverda ustoz
  sifatida ro'yxatdan o'tgan; profil roli “teacher” yetmaydi); Mutaxassis — hamjamiyatda hujjat bilan tasdiqlangan
  (`community_members.status='verified'`). Aks holda 403 `plan_not_allowed`. Eslatma: `teacher_accounts` o'zi
  o'z-o'zini ro'yxatdan o'tkazish (D-42) — tasdiq emas (ochiq qaror #4).
- (g) Muddat (30 kun) `resolveAccess` da hisobga olinadi; muddat o'tgach huquq yo'q (`expired`). Sinov pullik do'kon
  obunasini hech qachon bosib o'tmaydi (amaldagi obuna bo'lsa sinov qatori e'tiborsiz; tenglikda do'kon > admin >
  sinov); amaldagi obunada sinov boshlanmaydi (409 `already_subscribed`).
- Testlar: `cloudflare/test/trial.test.ts` (bir telefonda ikkinchi hisob, gmail nuqta/+teg, mehmon, tasdiqlanmagan
  email, o'chirib qayta ro'yxat, boshqa qurilma, soxta tekshiruvchi rad, nonce, platforma bayrog'i, sozlanmagan → 503,
  bayroq o'chiq → 404, muddat, saqlash muddati, limit), `guards.test.ts`.

**4. Halol cheklovlar.** Hech bir usul qat'iyatli buzg'unchini to'liq to'xtatmaydi: yangi telefon, emulyator/root
(attestatsiya qisman ushlaydi), App Attest kalitini qayta o'rnatishda yangilash, zavod sozlamasiga qaytarish
(platforma bayrog'i saqlanishi kerak — rasmiy hujjat bilan tekshirilmagan), ko'p email, `LG_SERVER_SECRET` almashishi.
Batafsil va do'kon-native taklif farqi: `docs/PRO_TRIAL_ABUSE_NOTES.md`. Do'kon kirish taklifi (Apple Introductory
Offer / Play free trial) — Apple ID / Google hisobiga bir marta (qurilmaga emas), karta kerak, avtomatik pullikka
o'tadi; iOS'da server bergan kartasiz sinov App Review 3.1.1 bilan ziddiyatga uchrashi mumkin (ochiq qaror #1).

**5. Ilova (“Obuna” ekrani, `lib/features/profile/subscription_screen.dart`).** Profil → “Obuna” (yagona qator, faqat
`BuildFlags.proEnabled`; eski “Obuna va tiklash” qatori olib tashlandi, to'lov oynasi `/profile/purchase` shu ekrandan
— to'lov yoqilganda). Uch reja, oylik/yillik USD narx (`ProPricing` katalogidan; do'konda mahalliy valyuta), har reja
nima uchun (matritsadan), “Hozircha hamma imkoniyat bepul. Rejalar hali faol emas”, holat (bepul / sinov — qolgan
kunlar / reja / admin bergan), sinov qoidasi (“bir telefonga bir marta”), “Xaridni tiklash”. Sinov tugmasi yo'q
(attestatsiya yo'q) — “hali yoqilmagan”. ARB `proSub*` (uz/ru/en). Bayroq o'chiq — Profil va yo'llar avvalgidek.
Testlar: `test/widget/subscription_screen_test.dart` (bayroq on/off, 320px/1.3 uch tilda, holatlar, maxfiylik izohi),
`test/unit/plan_matrix_test.dart`, `test/unit/trial_entitlement_test.dart`.

**6. Egasi nima sozlashi kerak (sinovni yoqish uchun; hech biri qilinmagan).**
1. Apple: App ID'da App Attest (va/yoki DeviceCheck) imkoniyati; Developer → Keys → DeviceCheck kaliti (.p8, Key ID,
   Team ID) — Worker secretlari; App Attest attestatsiyasini Apple App Attest Root CA bilan tekshiruvchi server kodi;
   iOS native plagin (DCAppAttestService / DCDevice).
2. Google: Play Console → App integrity → Play Integrity API (Google Cloud loyihasini bog'lash), tokenni
   `decodeIntegrityToken` bilan ochish uchun service account (secret), kerak bo'lsa “device recall” (beta); Android
   native plagin (Integrity API, nonce = server challenge).
3. Server: haqiqiy `DeviceAttestationVerifier` ni yozish va `index.ts` da ulash; `0014`/`0015`/`0016` migratsiyalarini
   qo'llash; `LG_BILLING_ENABLED=true`; `deploy_api`.
4. Do'kon mahsulotlari (D-73 id'lari) va kalitlar (`APPLE_IAP_*`, `GOOGLE_PLAY_SERVICE_ACCOUNT`).
5. Maxfiylik siyosati (§10a ni nashr qilish), App Privacy (Device ID — firibgarlikka qarshi), Play Data safety
   (“Device or other IDs”, xeshlangan), Foydalanish shartlari (sinov qoidasi).
6. `ProTrialConfig.freeTrialDays`/`mechanism` hali `null`/`undecided` — server sinovi tanlansa yangilanadi.

**7. Ochiq qarorlar.** (1) Sinov mexanizmi: server (bu D-74) yoki do'kon kirish taklifi yoki ikkalasi (iOS 3.1.1
xavfi); (2) Mutaxassis ustoz panelini olsinmi (hozir ha); (3) saqlash muddati 24 oy to'g'rimi; (4) Ustoz/Mutaxassis
sinovi uchun qanday tasdiq (hozir `teacher_accounts` / hamjamiyat tasdig'i); (5) qo'shimcha email aliaslari va bir
martalik domenlar ro'yxati; (6) attestatsiya yo'q qurilmalar (Huawei/AOSP, web) — sinov yo'q (hozir) yoki boshqa yo'l;
(7) D-73 §5 dagi qolgan qarorlar.

## D-75. Pro tayyorligi: do'kon tekshiruvi, bildirishnomalar, sandbox, oflayn, sinov platformasi (2026-10-24; Pro YOQILMAGAN)
> **QISMAN SUPERSEDED (D-76, 2026-10-24, egasi qarori):** 30 kunlik sinov → 7 kun (hamma reja); 3 reja → 4 reja
> (Premium); “Mutaxassis → ustoz paneli” bekor. Do'kon tekshiruvi, bildirishnomalar, sandbox, oflayn, platforma
> qoidalari o'zgarmagan.
`pro-next` tarmog'ida. **Hech narsa deploy qilinmadi, yoqilmadi, do'konga yuborilmadi, push qilinmadi; production D1 ga
migratsiya qo'llanmadi** (`0017_billing_notifications.sql` — faqat fayl). `BuildFlags.proEnabled` standart `false`,
`LG_BILLING_ENABLED` o'chiq (yo'llar 404), `ProGatePolicy.gated` BO'SH, `LG_BILLING_SANDBOX` o'chiq,
`TRIAL_PLATFORMS` standart `android`. Mavjud bepul foydalanuvchilar huquqi o'zgarmadi. Narxlar — D-73 (yagona manba
`pro_catalog.dart`). To'liq audit: `docs/PRO_READINESS_2026-10-24.md`; test muhiti: `docs/PRO_TEST_ENVIRONMENT.md`;
Apple'ga savol loyihasi: `docs/APPLE_REVIEW_QUESTION_DRAFT.md` (yuborilmagan).

**Server.** Injeksiya qilinadigan `StoreVerifier` (`deps.storeVerifiers`; haqiqiy App Store Server API / Play
Developer API, kalitsiz `503 store_verifier_not_configured`). Apple JWS — x5c zanjiri Apple Root CA - G3 ga pin
(SHA-256 `63343abf…3e9179`, `src/x509.ts`), Apple OID, muddat, ES256; tranzaksiya muhiti host bilan mos. ASSN V2 va
RTDN: imzo / Pub/Sub OIDC (yoki URL token; hech biri bo'lmasa 503), `notificationUUID`/`messageId` bo'yicha takror
tashlanadi, `audit_log` ga `billing_notification`; REFUND/REVOKE/REVOKED/voided — darhol `revoked`; grace — Pro bor;
billing retry/hold/pause/expired — yo'q; holat har doim do'kon API'sidan qayta o'qiladi. `LG_BILLING_SANDBOX=true`
bo'lmasa sandbox/test xaridi `403 sandbox_not_allowed`, sandbox bildirishnomasi e'tiborsiz. Play: obuna
(`uz.labguide.<daraja>`) + base plan (`monthly`/`yearly`) → kanonik id `uz.labguide.<daraja>.<davr>` (App Store id
bilan bir xil); eski D-46 id'lari alias. `restore: true` — hisobning qatorlari do'kondan qayta o'qiladi. Javobda
`offline_until` = min(hozir + 7 kun, huquq tugashi). Sinov: `TRIAL_PLATFORMS` (standart `android`) — iOS
`403 trial_not_available_on_platform`; `GET /v1/billing/status` → `trial: {android, ios, platforms}` (platforma ×
attestatsiya) va `sandbox`.

**Ilova.** Play'da faqat asosiy reja (sinov/chegirma takliflari tanlanmaydi), do'kon kirish taklifi ko'rsatilmaydi
(`ProTrialConfig.storeIntroOffersAllowed = false`, mexanizm `serverGranted`, 30 kun). Oflayn: kesh chegarasi min(7 kun,
`offline_until`), qurilma kaliti bilan HMAC; uzaytirilmaydi; bepul imkoniyatlar hech qachon yopilmaydi. Ilova qayta
ochilganda yangilash (5 daqiqalik throttle) + kirish/ishga tushishda. Sinov tugmasi faqat server imkoniyat so'rovi
VA attestatsiya bo'lsa; aks holda oddiy izoh; sinov kodi xarid boshlamaydi. “Obuna” ekrani POLICY_REVIEW bo'yicha
(do'kon narxi eng ko'zga tashlanadi, yillik — yillik, boshqarish/bekor, tiklash, shartlar, maxfiylik, sinov matni
“to'lov usuli yo'q, pul yechilmaydi, bepul imkoniyatlar davom etadi”, “Pro tugadi”). Debug soxta xarid
(`LG_FAKE_PURCHASES`, release'da imkonsiz). Admin grantlar hisobga bog'langan (platformaga emas) — shuning uchun
`ADMIN_GRANTS_PLATFORMS` qo'shilmadi; iOS'dagi xavf Apple savolida (2-savol).

**Testlar.** `cloudflare/test/billing.test.ts`, `billing_lifecycle.test.ts`, `x509.test.ts`, `trial.test.ts`,
`guards.test.ts`; ilova `test/unit/pro_readiness_d75_test.dart`, `test/widget/subscription_screen_test.dart`,
`test/guards/pro_flag_default_guard_test.dart` (D-75 guruhi), `entitlements_flow_test.dart`.

**Egasi qarorlari (OCHIQ).**
1. iOS sinovi: Apple'ga savol yuborish; javobga qarab variant A (iOS'da vaqtli sinov yo'q) yoki B (1 oylik App Store
   kirish taklifi — avtomatik pullik, egasi qoidasiga zid); ijobiy bo'lsa `TRIAL_PLATFORMS=android,ios` + DeviceCheck.
2. Family Sharing — ishga tushirishda O'CHIQ (yoqilsa qaytarib bo'lmaydi).
3. Sinov xeshlarini hisob o'chirilgandan keyin 24 oy saqlash — yurist tekshiruvi (Apple 5.1.1(v) bo'yicha NOANIQ).
4. Play Integrity “device recall” beta'ga yozilish; haqiqiy Play Integrity / DeviceCheck tekshiruvchilari (kalitlar,
   native plaginlar) — hozir YO'Q.
5. Do'kon mahsulotlari: App Store — bitta guruh, 6 mahsulot; Play — 3 obuna × 2 base plan, sinov offer'isiz.
6. Kalitlar (Worker secretlari): `APPLE_IAP_*`, `GOOGLE_PLAY_SERVICE_ACCOUNT`, `PLAY_RTDN_AUDIENCE`/
   `PLAY_RTDN_SERVICE_ACCOUNT` (yoki `PLAY_RTDN_TOKEN`), ixtiyoriy `APPLE_SUBSCRIPTION_GROUP_ID`.
7. Migratsiyalar 0014–0017 ni qo'llash (avval test D1, keyin production — egasi `deploy_api` bilan).
8. `LG_BILLING_ENABLED` ni qachon yoqish; App Review sandbox xaridlari uchun `LG_BILLING_SANDBOX` siyosati
   (production'da o'chiq bo'lsa review xaridi rad etiladi).
9. Play Data safety (“Device or other IDs”, “Purchase history”, firibgarlikka qarshi) va App Privacy (“Device ID”,
   “Purchase History”) deklaratsiyalari, maxfiylik siyosati §10a nashri.
10. D-73/D-74 dagi boshqa ochiq qarorlar (nima pullik bo'ladi — hozir hech narsa; Mutaxassis → ustoz paneli va h.k.).

## D-76. Pro: to'rt reja (Premium), `lab` imkoniyati, Lab — Pro (REJA, faol emas), 7 kunlik sinov, mehmon xarid qilmaydi (2026-10-24, egasi qarori; Pro YOQILMAGAN)
`pro-next` qatoridagi `pro/tiers-premium` tarmog'ida (lokal). **Hech narsa deploy qilinmadi, push qilinmadi, yoqilmadi,
do'konga yuborilmadi; production D1 ga migratsiya qo'llanmadi** (`0018_premium_tier.sql` — faqat fayl).
`BuildFlags.proEnabled` standart `false`; `ProGatePolicy.gated` BO'SH (bugun bepul hech narsa yopilmadi); server
`LG_BILLING_ENABLED` o'chiq. D-74 matritsasi va D-74/D-75 dagi 30 kunlik sinov shu qaror bilan almashtirildi.

**1. To'rt pullik reja, narxlar — EGASI bergan (USD; yagona manba `lib/core/entitlements/pro_catalog.dart` `ProPricing`).**
| Reja | Oylik | Yillik | Mahsulot id (App Store = kanonik) | Play obuna (+ base plan `monthly`/`yearly`) |
|---|---|---|---|---|
| Talaba | 1.49 | 9.99 | `uz.labguide.student.monthly/.yearly` | `uz.labguide.student` |
| Ustoz | 2.49 | 24.99 | `uz.labguide.teacher.monthly/.yearly` | `uz.labguide.teacher` |
| Mutaxassis | 3.49 | 34.99 | `uz.labguide.specialist.monthly/.yearly` | `uz.labguide.specialist` |
| **Premium** (yangi) | 4.99 | 49.99 | `uz.labguide.premium.monthly/.yearly` | `uz.labguide.premium` |
Kodda: `ProPlan.premium`, `BillingCatalog.premium*`, server `Plan`/`PLAN_RANK`/`BILLING_PRODUCTS`/`PLAY_SUBSCRIPTIONS`
(`cloudflare/src/billing.ts`). Katalogda yo'q (eski/sinov) mahsulot qatori endi eng past daraja (`student`) — Lab yoki
ustoz panelini hech qachon ochmaydi (ilova `BillingCatalog.tierOf` bilan bir xil).

**2. Imkoniyat matritsasi (MA'LUMOT; server `cloudflare/src/tiers.ts` `TIER_CAPABILITIES` ↔ ilova
`lib/core/entitlements/plan_matrix.dart`, test `test/unit/plan_matrix_test.dart` solishtiradi).** Imkoniyatlar:
`learner`, `teacher_panel`, `lab` (D-74 dagi `specialist` imkoniyati o'rniga `lab`).
| Reja | `learner` | `teacher_panel` | `lab` |
|---|---|---|---|
| Talaba | ha | yo'q | yo'q |
| Ustoz | ha | ha | **yo'q** |
| Mutaxassis | ha | **yo'q** | ha |
| Premium | ha | ha | ha |
“Mutaxassis Ustozni ham qamraydi” (D-73/D-74) qoidasi BEKOR. Ilovadagi `ProTier` endi chiziqli zinapoya emas —
imkoniyatlar TO'PLAMI (`ProTier.covers(feature)`); bir nechta amaldagi huquq birlashtiriladi (masalan, Ustoz obunasi +
Mutaxassis admin granti = ustoz paneli + Lab) — server `accessCapabilities` (`requireTier`) va ilova
`EntitlementService.tier` bir xil. Qaror faqat serverda saqlangan rejadan (do'kon / admin grant / sinov), lokal roldan
emas; Talaba yoki Mutaxassis rejasi ustoz panelini hech qachon ochmaydi (`403 tier_insufficient`); `teacher_panel`
uchun qo'shimcha `teacher_accounts` (aks holda `403 teacher_role_required`). Admin grantni `extend` rejimida
solishtirib bo'lmaydigan daraja (Ustoz ↔ Mutaxassis) bilan uzaytirish — `409 tier_not_comparable` (jim tanlov yo'q;
admin `replace` bilan aniq tanlaydi).

**3. Lab — Pro (`lab` imkoniyati) — REJA, FAOL EMAS.** `Feature` ga Lab funksiyalari qo'shildi: `leukocyteCounter`
(sanashni boshlash va natijani saqlash), `absoluteCounts`, `leukocyteEvaluation`, `labSections` (sitologiya,
spermogramma, qon guruhi, gistologiya, siydik tahlili, qon morfologiyasi, koprologiya), `coagulogram`,
`labInstruments`, `labDirections`, `calibration`, `qualityControl`, `labCalculators`. Ular
`ProGatePolicy.plannedLabGate` da (const, FAOL EMAS); `gated` bo'sh qoladi. Qoida: **kirish sahifasi ochiladi va
ko'rinadi, vosita/amal boshlanishida tekshiriladi** — leykoformula hisoblagichi ekrani ochiladi, YANGI sanashni
boshlash (birinchi bosish, “ko'rmasdan” rejim) `allowOrOffer` orqali to'lov oynasini ochadi; **boshlangan sanash
hech qachon to'xtatilmaydi**; Lab bo'limlari ichidagi sahifalar va vositalar yo'l darajasida (`router.dart`
`labGate`) — Lab tabi, Bosh sahifa, qidiruv yoki analit kartasidan kelinsa ham. Rasm mualliflari (litsenziya) sahifalari
va preanalitika (bitta ma'lumot sahifasi) ochiq; mikroskopiya atlasi — avvalgidek `atlasPractice` (`learner`).
Standart buildda hech narsa yopilmaydi, “tez orada” yoki yopiq tugma yo'q (App Store 2.1 / 3.1.1). Sinov:
`test/widget/lab_gate_test.dart` (`EntitlementService(gated: plannedLabGate)` override bilan).

**4. Bepul sinov — 7 kun, HAMMA reja uchun** (Talaba, Ustoz, Mutaxassis, Premium): `cloudflare/src/trial.ts`
`TRIAL_DAYS = 7`, `ProTrialConfig.serverTrialDays = 7`, ARB uz/ru/en (`proSubTrialTitle({days})`,
`proPrivacyTrialNote`), `site/privacy`. Bir telefonga bir marta, karta yo'q, avtomatik pullik yo'q; suiiste'molga
qarshi qoidalar o'zgarmadi (hisob/email/telefonga bitta, Gmail kanonik, kalitli xesh, standart faqat Android, iOS
`403` Apple javobigacha, do'kon kirish takliflari o'chiq). Sinov foydalanuvchi tanlagan rejani beradi; reja ruxsati
reja imkoniyatlaridan: ustoz paneli bor reja — `teacher_accounts`, Lab bor reja — tasdiqlangan mutaxassis; shuning
uchun **Premium sinovi ikkala shartni ham** talab qiladi (ochiq qaror #2).

**5. Mehmon rejimi qoladi (Apple 5.1.1); mehmon sinov ham, xarid ham olmaydi.** D-73 ochiq qarori (10) shu bilan
yopildi: `EntitlementService.purchase/restore` mehmonga `BillingOutcome.signInRequired` (do'kon oynasi ochilmaydi),
to'lov oynasida obuna tugmasi o'rniga izoh va “Hisobga kirish”; qurilmadagi do'kon tranzaksiyasi mehmonga huquq
BERMAYDI (eslab qolinadi, hisobga kirilganda serverga bog'lanadi); sinov — avvalgidek `TrialBlock.guest`, server 401.

**6. Admin Pro berish** — to'rt reja (`/profile/admin/pro-grants`, `ProPlan.values`), server `0018` dan keyin
`premium` ni yozadi.

**7. Migratsiya `0018_premium_tier.sql`.** `pro_grants.tier` va `pro_trials.tier` CHECK cheklovi `premium` bilan
kengaytirildi (SQLite: jadval qayta quriladi — yangi jadval, ma'lumot nusxasi, eskisini o'chirish, nom, indekslar;
0004 dagidek). 0014–0017 tahrirlanmadi. Test: `cloudflare/test/migration_0018.test.ts` (eski 0015/0016 jadvali
ustiga: qatorlar saqlanadi, premium ochiladi, unikal indekslar qayta quriladi).

**Testlar.** Server: `tiers.test.ts` (matritsa jadvali, har reja × imkoniyat, `403 tier_insufficient`, birlashma),
`trial.test.ts` (7 kun, Mutaxassis/Premium sinovi), `progrants.test.ts` (to'rt reja, premium mahsulot/grant,
`tier_not_comparable`), `migration_0018.test.ts`. Ilova: `plan_matrix_test.dart` (server paritet),
`entitlements_test.dart`, `trial_entitlement_test.dart`, `pro_flag_default_guard_test.dart`, `lab_gate_test.dart`,
`entitlements_flow_test.dart`, `subscription_screen_test.dart`, `admin_pro_grant_test.dart`.

**Ochiq qarorlar (egasi).**
1. Lab yopilishini qachon faollashtirish (`plannedLabGate` → `gated`) — Pro yoqilganda alohida qaror.
2. Premium sinovi uchun shart: hozir ustoz (`teacher_accounts`) VA tasdiqlangan mutaxassis — yumshatilsinmi.
3. Lab ichidagi mashq/test sahifalari (masalan, bo'lim testlari) ham `labSections` ostida — Talaba rejasiga
   qoldirilsinmi; leykoformula bo'limidagi hujayralar, tarix, mashq — hozir ochiq (ko'rish).
4. Mehmon xarid qila olmasligi (D-76 §5) — App Store 5.1.1 bo'yicha review xavfi (Apple obunani hisobsiz sotishni
   kutishi mumkin); kerak bo'lsa Apple'ga savolga qo'shish.
5. Do'kon mahsulotlari: App Store — 8 mahsulot (bitta guruh), Play — 4 obuna × 2 base plan; narx pog'onalari va UZS.



## D-77. Pullik tizim: Free + Pro + Premium, faqat 7 kunlik sinov, keyingi yangilanishda (2026-10-25, egasi qarori)
**Egasi qarori (2026-10-25):** keyingi yangilanishda **Free + Pro + Premium** chiqadi, bepul sinov **faqat 7 kun**
(30 kunlik variant YO'Q). Do'konlarda (App Store / Google Play) tekshiruvda turgan bepul versiya (`main` `4b0f057`)
**o'zgarmaydi**; pullik tizim alohida tarmoqda — `paid/pro-premium` (`fix/images-apparatus` + `pro/tiers-premium`
birlashmasi) — tugatiladi. **Egasining aniq ruxsatisiz hech narsa nashr qilinmaydi** (push, merge `main` ga, PR,
build, deploy, do'konga yuborish, do'kon/billing API chaqiruvi — yo'q).

**Doirasi.** Bu qaror **faqat `paid/pro-premium` tarmog'i** uchun D-58 ni almashtiradi (D-58 “ilovada Pro/to'lov
yo'q” `main` va bepul reliz tarmog'ida kuchda qoladi). D-70/D-71/D-72/D-74/D-75 dagi “30 kun” matni SUPERSEDED
bo'lib qoladi (tarix); D-73/D-76 narxlari va mahsulot id'lari — UNCONFIRMED-until-created-in-store (do'konlarda
hali yaratilmagan).

**Bu bosqichda hamma o'chirgich O'CHIQ** (yoqish — keyingi bosqichda, rahbar tomonidan): `BuildFlags.proEnabled`
standart `false` (`LG_PRO_ENABLED` berilmaydi), `ProGatePolicy.gated` bo'sh, `LG_FAKE_PURCHASES` / `LG_PARTNER_ADS`
standart `false`, server `LG_BILLING_ENABLED` o'rnatilmagan (billing/sinov/admin-grant yo'llari 404), do'kon
kirish taklifi yo'q (`storeIntroOffersAllowed = false`).

**Yangi qorovullar (D-58 qorovuli o'rniga, shu tarmoqda):** `test/guards/paid_policy_d77_guard_test.dart`
- (a) build bayroqlarining standart holati aniq yozilgan va tekshiriladi (ilova + server);
- (b) ARB va `lib/` da narx literali yo'q — narx do'kondan keladi; yagona narx ma'lumoti `ProPricing`
  (`lib/core/entitlements/pro_catalog.dart`, D-76);
- (c) sinov uzunligi hamma joyda 7: Dart `ProTrialConfig.serverTrialDays`, TypeScript `TRIAL_DAYS`, ARB
  `proPrivacyTrialNote`, shu qaror; “30 kun / 30 days / 30 дней” sinov matni faqat SUPERSEDED tarixda;
- (d) do'kon talablari asoslari: “Xaridlarni tiklash” to'lov oynasi va “Obuna” ekranida bor, narx va davr xarid
  tugmasidan oldin (bir kartada) ko'rsatiladi, tashqi to'lov havolasi yo'q (faqat do'kon obuna sahifasi, EULA,
  maxfiylik siyosati sayti).
`tool/site/check_site.py`: umumiy “Pro/obuna/subscription” taqig'i o'rniga — narx literali va 7 dan boshqa sinov
muddati (shu jumladan SUPERSEDED 30 kunlik) taqiqlanadi; obuna so'zlari faqat `privacy/` sahifasida (manba `docs/store/PRIVACY_POLICY.md`,
qo'lda tahrir “eskirgan” xatosi bilan ushlanadi). Maxfiylik/shartlar matni (Pro §10a) — alohida ish (matnlar agenti).

**Tekshirilmagan (NOT VERIFIED):** haqiqiy App Store / Google Play sandbox xaridi bir marta ham qilinmagan; barcha
Pro testlari soxta do'kon / soxta server / soxta attestatsiya bilan. Holat: `docs/PAID_BRANCH_STATUS.md`.

### D-77 addendum (2026-10-25, `paid/srv`): sinov attestatsiyasi, mehmon xaridi, billing to‘liqligi
Faqat lokal tarmoq `paid/srv` (`paid/pro-premium@21b5a24` dan). **Push, merge, PR, build, deploy, migratsiya
(remote), do‘kon/Apple/Google/Cloudflare API chaqiruvi — QILINMAGAN.** Haqiqiy do‘kon xaridi va qurilmada attestatsiya
— NOT VERIFIED (faqat soxta fetch, sintetik token/zanjir, soxta platforma kanali). Hamma o‘chirgich avvalgidek O‘CHIQ
(`LG_PRO_ENABLED`, `LG_BILLING_ENABLED`, `gated` bo‘sh, `storeIntroOffersAllowed = false`); narx/id — UNCONFIRMED.
1. **Sinov — faqat server, 7 kun, bir marta.** Haqiqiy tekshiruvchilar `cloudflare/src/attestation.ts`: Android —
   Play Integrity classic (service account JWT WebCrypto’da, `decodeIntegrityToken`, paket / nonce = H(server nonce,
   ANDROID_ID) / imzo sertifikati / `MEETS_DEVICE_INTEGRITY` / `LICENSED` / vaqt); iOS — DeviceCheck ikki bit
   (ES256 JWT, query/update, bit0 = sinov ishlatilgan). App Attest — **NOT DONE** (doimiy belgi bermaydi; to‘liq
   tekshiruvi yozilmadi). `index.ts` da `platformVerifier()` ulandi; secretlarsiz — **503 `trial_unavailable`**
   (`reason: device_attestation_not_configured`; avvalgi kod `device_attestation_not_configured` o‘rniga —
   ataylab, ilova ikkalasini ham “mavjud emas” deb tushunadi). Holat mashinasi `GET /v1/billing/trial`
   (`not_started` → `active` → `expired`, server soati; mijoz vaqti o‘qilmaydi). Bitta sinov = foydalanuvchi
   tanlagan bitta reja. Attestatsiya tokeni bir martalik (SHA-256, `0019`). IP tarmog‘i (/24, /48) limitlari: yangi
   (< 24 soat) hisoblar sutkasiga 3, jami 20 muvaffaqiyatli sinov; ASN cheklovi ataylab yo‘q (CGNAT). Bir martalik
   domenlar — faqat ixtiyoriy `TRIAL_BLOCKED_EMAIL_DOMAINS` (repoda tekshirilgan ro‘yxat yo‘q). Qolgan xavflar:
   `docs/PRO_TRIAL_ABUSE_NOTES.md` §6 (factory reset Android’da yangi sinov beradi).
2. **Mehmon xaridi — D-76 §5 ni almashtiradi (Apple 5.1.1(v)).** Hisobga bog‘liq bo‘lmagan imkoniyatlar (`learner`,
   `lab`) uchun hisob majburiy emas: server `GET /v1/billing/status` → `guest.purchase_plans` (TIER_CAPABILITIES dan
   — `teacher_panel` siz rejalar: Talaba, Mutaxassis) beradi; mehmon sotib oladi va TIKLAYDI (`/v1/billing/guest/
   verify|entitlements`), server do‘kon tranzaksiyasi + qurilmaga (HMAC) bog‘langan imzolangan token beradi (≤ 5
   qurilma). Hisobga kirilganda `/v1/billing/guest/link` xaridni hisobga o‘tkazadi va mehmon qatori
   `linked_user_id` oladi — mehmon tokeni boshqa huquq bermaydi (ikki marta berilmaydi). Hisobda sotib olingan
   xarid mehmonga berilmaydi. `teacher_panel` — faqat hisob (mehmon Premium tiklasa ham faqat learner + lab).
   Ustoz / Premium kartasida mehmonga xarid tugmasi yo‘q, izoh. Server siyosat bermasa — eski D-76 xulqi.
   Sinov — avvalgidek faqat hisob bilan.
3. **Billing to‘liqligi.** Server: do‘kon davri `period_type` (`trial`/`intro`/`normal`: Apple `offerType`/
   `offerDiscountType`, Play `offerPhase` / v1 `paymentState` — Play maydon nomlari NOT VERIFIED), `auto_renew`
   (Apple `signedRenewalInfo.autoRenewStatus` — imzosi tekshiriladi; Play `autoRenewingPlan` / CANCELED),
   `pending_product_id` (pastga o‘tish), Apple grace — huquq `gracePeriodExpiresDate` gacha (oldin tranzaksiya
   `expiresDate` o‘tgani uchun grace huquq bermasdi — tuzatildi). Webhooklar mehmon qatorini ham yangilaydi. Ilova:
   bekor qilingan (“avtomatik yangilash o‘chirilgan: sana gacha”), do‘kon sinov davri, keyingi reja satrlari;
   oflayn kesh — monoton yuqori belgi (`last_seen`): oyna ichida soatni orqaga surib oflayn Pro cho‘zilmaydi.
4. **Ikki sinov siyosati** (`lib/core/entitlements/trial_policy.dart`): do‘kon taklifi shartlari faqat do‘kon
   ma’lumotidan va faqat do‘kon haqli desa; App Store’da Apple o‘zi qo‘llaydigan taklif yashirilmaydi (oldin
   `storeIntroOffersAllowed=false` uni yashirardi — to‘lov oynasi do‘kon oynasiga zid bo‘lmasin); Play’da taklif
   faqat egasi yoqsa. Server sinovi ishlatilgan bo‘lsa — “bu do‘kon taklifi, LabGuide sinovidan alohida” izohi.
5. **Ilova attestatsiyasi**: `PlatformDeviceAttestor` (kanal `uz.labguide.app/attestation`), Android
   `MainActivity.kt` + `com.google.android.play:integrity:1.4.0`, iOS `AppDelegate.swift` (DeviceCheck + Keychain
   UUID). Gradle/Xcode kompilyatsiyasi — **NOT RUN**; qurilmada — NOT VERIFIED.
6. **D-77 qorovullari** o‘zgartirilmadi va yashil (`paid_policy_d77_guard_test.dart`); server qorovuliga D-77
   addendum testi qo‘shildi. Hujjatlar: `docs/PAID_SANDBOX_RUNBOOK.md`, `docs/PAID_BACKEND_DEPLOY_CHECKLIST.md`,
   `docs/PRO_TRIAL_ABUSE_NOTES.md` (yangilandi). Migratsiya `0019_trial_attest_guest.sql` — faqat fayl.
7. **Tekshiruv (2026-10-25, lokal):** server `tsc --noEmit` — xato yo‘q, `vitest run` — 28 fayl / 399 test PASS
   (oldin 24 / 332); `flutter analyze` — xato yo‘q; Pro/billing/sinov/l10n to‘plami + `test/guards/` (17 yo‘l) —
   360 test PASS. To‘liq `flutter test`, Gradle/Xcode build, `wrangler dev` — NOT RUN.

## D-78. Pullik katalog: faqat YANGI Pro funksiyalar; bugun bepul hamma narsa bepul qoladi (2026-10-25, egasi qarori)
**Egasining yakuniy tarif qarori (2026-10-25)** — `paid/feat` tarmog'ida amalga oshirildi (faqat lokal; push, merge,
PR, build, deploy yo'q; `LG_PRO_ENABLED` standart `false`).
1. **Free:** bugun `main` (`4b0f057`, do'kon tekshiruvida) da bor HAMMA funksiya bepul va to'liq ishlaydi — Lab bo'limi
   (leykoformula, bo'limlar, koagulogramma, apparatlar, yo'nalishlar, kalibrlash, QC, kalkulyatorlar), atlas va atlas
   mashqi, toifa / Bilim va ko'nikmalarni baholash, testlar va mashq, natijalar tarixi, guruhlar, topshiriqlar, ma'ruza
   rejimi. **Kunlik limit yo'q.** D-53/D-71/D-76 dagi “kunlik 5 savol”, “oxirgi 3 natija”, `fullToifaBank`,
   `atlasPractice`, `weakTopics`, `plannedLabGate` / `labGate` (D-76 §3 “Lab — Pro”) — **BEKOR** (kod va testlardan
   olib tashlandi).
2. **Talaba Pro** (`learner`): ustoz bilan ishlanadigan maxsus testlar (talaba tomoni), natijalar tarixi (kengaytirilgan
   tahlil), imtihon simulyatsiyasi, PDF/CSV eksport, qo'shimcha materiallar.
3. **Ustoz Pro** (`teacher_panel`): test yaratish, talabalarni biriktirish, guruhlar, natijalarni boshqarish.
4. **Mutaxassis Pro** (`lab`): professional laboratoriya funksiyalari.
5. **Premium** = hammasi birga. Matritsa D-76 dagidek: Talaba = learner; Ustoz = learner + teacher_panel; Mutaxassis =
   learner + lab; Premium = uchalasi.
6. Har foydalanuvchi tegishli pullik funksiyalarni **7 kun** bepul sinaydi (D-76/D-77, o'zgarmadi).
7. 7 kundan keyin obunasiz — faqat PULLIK funksiyalar yopiladi; bepul funksiyalar va foydalanuvchining BARCHA
   ma'lumotlari qoladi (o'chirilmaydi, yashirilmaydi; avval yaratilgan Pro natijalari ko'rinadi — faqat yangi pullik
   amalni boshlash yopiladi).

**Katalog (`lib/core/entitlements/feature.dart` `Feature`; server nusxasi `cloudflare/src/tiers.ts`
`FEATURE_CAPABILITIES`; test `test/unit/plan_matrix_test.dart`).** Egasi ro'yxati — mahsulot NOMLARI; kodda faqat bugun
yo'q (yangi yoki kengaytirilgan) qism pullik:
| Feature (`wire`) | Toifa | Nima |
|---|---|---|
| `resultsAnalytics` (`results_analytics`) | learner | barcha banklar bo'yicha to'liq tarix, mavzular trendi, zaif mavzular (bepul tarix ro'yxati o'zgarmaydi) |
| `examSimulation` (`exam_simulation`) | learner | imtihon sharoiti: majburiy vaqt va o'tish chegarasi, mavzular bo'yicha muvozanatli tanlov, ketma-ket (orqaga qaytish/belgilash yo'q), savol bo'yicha vaqt hisoboti (bepul imtihon va toifa testi o'zgarmaydi) |
| `resultsExport` (`results_export`) | learner | natijalarni PDF va CSV faylga eksport |
| `teacherTests` (`teacher_tests`) | learner | Ustoz Pro'da yaratilgan maxsus testlarni yechish (bugungi bepul topshiriqlar KIRMAYDI) |
| `teacherTestBuilder` (`teacher_test_builder`) | teacher_panel | o'z testini yaratish/tahrirlash |
| `teacherTestAssign` (`teacher_test_assign`) | teacher_panel | o'z testiga talaba/guruh biriktirish |
| `teacherResults` (`teacher_results`) | teacher_panel | o'z testlari natijalarini boshqarish, jamlanma, eksport |
| `calibrationExport` (`calibration_export`) | lab | kalibrlash jurnalini CSV/PDF ga eksport |
| `qcReport` (`qc_report`) | lab | QC xulosa hisoboti va QC ma'lumotini CSV/PDF faylga eksport (bepul CSV nusxasi o'zgarmaydi) |

`ProGatePolicy.gated` = faqat QURILGAN (ekran + test) funksiyalar — qurilmagan qator to'lov oynasida va'da qilinmaydi;
`ProGatePolicy.catalog` = hammasi. “Qo'shimcha materiallar” — dasturiy ta'rifi va mazmuni yo'q → katalogga
QO'SHILMADI (bo'sh pullik bo'lim yo'q). Holat jadvali: `docs/TIERS_FEATURE_MAP.md`.

**Qorovullar / testlar.** `test/widget/free_features_open_test.dart` (`lab_gate_test.dart` o'rniga): main router'idagi
har bir yo'l (`test/fixtures/main_routes_4b0f057.txt`, 210 ta + sikl yo'llari) butun katalog yopilgan, obunasiz,
mehmon va muddati o'tgan holatda to'lov oynasiga olib bormaydi (yo'l darajasidagi gate qo'shib ko'rilganda test
haqiqatan yiqildi). `pro_flag_default_guard_test`: eski yopish kodlari (`plannedLabGate`, `labGate(`, `historyView(`)
yo'q, gate chaqiruvlari faqat ro'yxatdagi Pro kirish nuqtalarida, har `gated` funksiyaning kirish nuqtasi bor.
D-77 qorovuli: `gated` bo'sh bo'lishi shart emas (D-78) — faqat katalogdan; bayroq o'chiq buildda hamma ochiq.

**D-78 qo'shimcha (2026-10-26) — `pro_preview` (tester ko'rishi uchun).** Egasi test buildda pullik bo'limlarni ko'rmadi:
bayroqlar standart O'CHIQ (D-77). ci.yml ga qo'lda ishga tushiriladigan `pro_preview` (standart false) kiritildi: faqat
`testflight` / `play_internal` rejimida `LG_PRO_ENABLED` va `LG_ALL_FEATURES_OPEN` = true (tester Talaba/Ustoz/Mutaxassis/
Premium interfeysini ko'radi, hamma imkoniyat OCHIQ). push/PR/`build`/`deploy_*` va do'kon buildlarida doim false
(`repo_registry_guard_test`). Cheklov: do'kon xaridi va billing serveri yo'q (mahsulotlar/narxlar tasdiqlanmagan, Cloudflare
deploy ruxsat kutadi) — xarid tugmalari "mavjud emas" holatida; Ustoz Pro serveri (0020 migratsiya) deploy qilinmaguncha
o'qituvchi testlari server qismi ishlamaydi. Do'konga yuboriladigan (bepul) build o'zgarmaydi.
