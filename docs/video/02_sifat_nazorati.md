# 02 — Sifat nazorati: Levey–Jennings va Westgard

RU: Контроль качества: Леви–Дженнингс и Вестгард · EN: Quality control: Levey–Jennings and Westgard

**Format:** ovozsiz, subtitrli ekran yozuvi — diktorsiz. Kadrlar — haqiqiy ekranlar
(`tool/video/howto_walk_test.dart`, `02_sifat_nazorati`). How-to: `HowToSection.qc`.

## Nega kerak
Ichki sifat nazorati har seriyada analitik tizim barqarorligini ko‘rsatadi. Qo‘lda chizilgan
Levey–Jennings grafigi va qoidalarni ko‘z bilan tekshirish xatoga moyil; bo‘lim buni avtomatik qiladi.

## Qanday ishlaydi
Foydalanuvchi test, birlik, maqsad manbai va har daraja uchun maqsadli o‘rtacha va SD ni kiritadi (ilova
qiymat to‘qimaydi). Har seriya natijasi Westgard qoidalari bo‘yicha baholanadi (1-2s ogohlantirish;
1-3s, 2-2s va boshqalar — rad etish), grafikda belgilanadi. Ma’lumot qurilmada; zaxira — matn (JSON)
nusxasi. «Yo‘riqnomalar»: QC rad etilsa nima qilish, EQA, kritik qiymatlar — **tushuntirish**; ilova EQA
dasturiga ulanmaydi va natija yubormaydi. Dalil: `test/widget/qc_flow_test.dart`,
`test/unit/qc_rules_test.dart`, `test/widget/levey_jennings_chart_test.dart`.

## Qanday foydalaniladi
1. «Test qo‘shish»: test nomi, birlik, darajalar.
2. Har daraja: maqsadli o‘rtacha va SD.
3. Har seriyadan keyin natijalar → «Seriyani saqlash».
4. Grafik va Westgard xulosasi.
5. «Yo‘riqnomalar» (QC rad etilsa, EQA, kritik qiymatlar).
6. Zaxira nusxa.

## Natijada nima olasiz
Har daraja bo‘yicha Levey–Jennings grafigi va har seriya uchun Westgard xulosasi — shu qurilmada.

## Qisqa kirish matni
- UZ: Nazorat natijalarini kiriting — ilova grafikni chizadi va Westgard qoidalarini tekshiradi.
- RU: Вводите результаты контроля — приложение строит график и проверяет правила Вестгарда.
- EN: Enter your control results — the app draws the chart and checks the Westgard rules.

## STORYBOARD
<!-- storyboard:begin -->
| # | Kadr (id) | Haqiqiy ekran (marshrut) | Ekrandagi amal | UZ | RU | EN | s |
|---|---|---|---|---|---|---|---|
| — | kartochka | — | Sarlavha | Sifat nazorati: Levey–Jennings va Westgard | Контроль качества: Леви–Дженнингс и Вестгард | Quality control: Levey–Jennings and Westgard | 3 |
| 1 | `lab_tools` | `/lab` | «Sifat nazorati (QC)» ni bosish | Lab → «Sifat nazorati (QC)» | Лаб. → «Контроль качества (QC)» | Lab → “Quality control (QC)” | 3 |
| 2 | `qc_empty` | `/lab/qc` | Bo‘sh holat | Avval nazorat to‘plamini yarating: «Test qo‘shish» | Сначала создайте набор: «Добавить тест» | First create a control set: “Add test” | 3.5 |
| 3 | `qc_form` | `/lab/qc/new` | Forma to‘ldirilgan | Test, birlik, maqsad manbai; har daraja uchun o‘rtacha va SD | Тест, единицы, источник целей; среднее и SD для каждого уровня | Test, unit, target source; mean and SD for each level | 4.5 |
| 4 | `qc_set_empty` | `/lab/qc/set/:id` | To‘plam yaratildi | To‘plam tayyor: har daraja uchun Levey–Jennings grafigi | Набор готов: график Леви–Дженнингса для каждого уровня | Set ready: a Levey–Jennings chart for each level | 3.5 |
| 5 | `qc_run_warning` | `/lab/qc/set/:id` | 2 seriya saqlandi | Seriya natijasini kiriting: 1-2s — ogohlantirish | Введите результат серии: 1-2s — предупреждение | Enter the run result: 1-2s — warning | 4 |
| 6 | `qc_run_reject` | `/lab/qc/set/:id` | 3-seriya saqlandi | 1-3s va 2-2s — seriya rad etildi | 1-3s и 2-2s — серия отклонена | 1-3s and 2-2s — run rejected | 4.5 |
| 7 | `qc_chart` | `/lab/qc/set/:id` | Grafikka surish | Grafikda: ● nazoratda ▲ ogohlantirish ■ rad etilgan | На графике: ● в пределах ▲ предупреждение ■ отклонено | On the chart: ● in control ▲ warning ■ rejected | 4 |
| 8 | `qc_guides` | `/lab/qc` | «Tashqi sifat nazorati (EQA)» ni bosish | «Yo‘riqnomalar»: QC rad etilsa, EQA, kritik qiymatlar | «Памятки»: отклонение QC, EQA, критические значения | “Guides”: rejected QC, EQA, critical values | 4 |
| 9 | `qc_eqa` | `/lab/qc/eqa` | EQA yo‘riqnomasi | EQA — faqat tushuntirish; ilova EQA dasturiga ulanmaydi | EQA — только пояснение; приложение не подключается к программам EQA | EQA is an explainer only; the app does not connect to EQA schemes | 4.5 |
| 10 | `howto` | `/lab/qc` | «Qanday foydalaniladi?» oynasi ochiq | «Qanday foydalaniladi?» — shu qadamlar ilovaning o‘zida | «Как пользоваться?» — эти шаги есть в самом приложении | “How to use?” — the same steps inside the app | 4.5 |
| — | kartochka | — | Yakun: labguide.nfcstore.uz | | | | 3 |

Jami davomiylik (storyboard bo‘yicha): uz — 46.0 s, ru — 46.0 s, en — 46.0 s.
<!-- storyboard:end -->

## Maqsadli davomiylik
45–50 s.

## Kerakli ekran yozuvlari
Lab tabi; QC bo‘sh holati; «Test qo‘shish» shakli (Glucose, mmol/L; 1-daraja 5,0 ± 0,2; 2-daraja 15 ± 0,5 —
**namuna qiymatlar**); to‘plam; 3 seriya (5,1/15,1; 5,5/15,1; 5,7/15,2) — ogohlantirish va rad etish
holatlari; grafik; yo‘riqnomalar ro‘yxati; EQA sahifasi.

## Ma’lum cheklovlar
- Maqsadli qiymatlar foydalanuvchidan; ilova ularni taklif qilmaydi.
- n kichik bo‘lsa ilova buni ekranda yozadi («qiymatlar hali kam»).
- EQA — faqat tushuntirish sahifasi.

## Ilmiy dars rejasi (alohida, uzunroq dars)
**NEEDS_EXPERT.** Manbalar — ilovada keltirilganlar: Westgard JO va boshq., Clin Chem 1981
(doi:10.1093/clinchem/27.3.493); WHO Laboratory quality management system handbook (EQA sahifasi [1]).
1. Ichki QC: nazorat materiali, darajalar, o‘rtacha/SD qayerdan olinadi (laboratoriya ma’lumoti yoki
   ishlab chiqaruvchi varaqasi — ilovadagi ikki tanlov).
2. Levey–Jennings grafigini o‘qish; Westgard qoidalari (1-2s, 1-3s, 2-2s, R-4s, 4-1s, 10x) — ilovadagi
   `qc_rules.dart` ta’riflari bilan.
3. QC rad etilganda harakatlar (ilovadagi «QC rad etilsa nima qilish» yo‘riqnomasi).
4. EQA (PT, qayta tekshirish, joyida baholash) — WHO manbasi bo‘yicha.
