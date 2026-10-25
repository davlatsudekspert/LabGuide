"""Per-topic publishing content (EN / RU / UZ). Text only; nothing here publishes anything.

`verified=True` means every sentence was checked against docs/video/<id>/lines.*.json and
CLAIMS_AND_EVIDENCE.md of an existing, rendered video. `verified=False` topics were drafted from the
feature inventory / lesson plans BEFORE the video existed: re-check every sentence against the final
lines.en.json and CLAIMS_AND_EVIDENCE.md, then flip the flag. The packager refuses to ship a video
without a claims table and warns when the copy is not verified.

Uzbek is Latin script: o‘ g‘ = U+2018, tutuq belgisi = U+2019, quotes « ». No ASCII apostrophe.
All RU / UZ text is NEEDS_NATIVE_REVIEW (gate G3).
"""


def T(en, ru, uz):
    return {"en": en, "ru": ru, "uz": uz}


# Scene id -> chapter start. Titles per language. Only for videos with a storyboard (calibration, leukocyte);
# any other topic gets automatic chapters (merged scenes, first narration line as title) that need editing.
CAL_CHAPTERS = [
    ("hook", T("Why absorbance needs a calibration", "Зачем поглощению нужна калибровка", "Yutilishga nega kalibrlash kerak")),
    ("lightpath", T("Light path and calibrators", "Ход света и калибраторы", "Nur yo‘li va kalibratorlar")),
    ("points", T("Curve, control and residuals", "Кривая, контроль и остатки", "Egri chiziq, nazorat va qoldiqlar")),
    ("app_intro", T("LabGuide: record the calibration", "LabGuide: запись калибровки", "LabGuide: kalibrlashni qayd etish")),
    ("app_rules", T("Acceptance rule, log and history", "Правило приёмки, журнал и история", "Qabul qoidasi, jurnal va tarix")),
]
LEU_CHAPTERS = [
    ("hook", T("Where to count on the film", "Где считать на мазке", "Surtmada qayerda sanash")),
    ("cells_gran", T("The cell types", "Типы клеток", "Hujayra turlari")),
    ("track", T("Move along the film, tap per cell", "Движение по мазку, нажатие на клетку", "Surtma bo‘ylab yurish, har hujayraga bosish")),
    ("app_target", T("Stop at the target, Microscope mode", "Остановка на цели, режим микроскопа", "Maqsadda to‘xtash, mikroskop rejimi")),
    ("formula", T("Percent, absolute counts, ranges", "Проценты, абсолютные числа, интервалы", "Foiz, mutlaq sonlar, me’yorlar")),
    ("app_save", T("Save or copy the result", "Сохранить или скопировать результат", "Natijani saqlash yoki nusxalash")),
]

TOPICS = [
    # ------------------------------------------------------------------ 1. calibration
    dict(
        id="calibration", order=1, tier="free", verified=True,
        path=T("Lab → Calibration", "Лаб. → Калибровка", "Lab → Kalibrlash"),
        title=T(
            "How Photometric Calibration Works — and How LabGuide Logs It",
            "Как работает фотометрическая калибровка и как LabGuide её фиксирует",
            "Fotometrik kalibrlash qanday ishlaydi va LabGuide’da qayd etilishi",
        ),
        hook={
            "en": ("Absorbance 0.486 — which concentration is that? It depends on the calibration behind it.",
                   "In about 90 seconds: the calibration curve, and how LabGuide records the calibration."),
            "ru": ("Поглощение 0,486 — какая это концентрация? Зависит от калибровки, на которой основан результат.",
                   "Примерно за 90 секунд: калибровочная кривая и то, как LabGuide фиксирует калибровку."),
            "uz": ("Yutilish 0,486 — bu qanday konsentratsiya? Bu uning ortidagi kalibrlashga bog‘liq.",
                   "Taxminan 90 soniyada: kalibrlash egri chizig‘i va LabGuide kalibrlashni qanday qayd etishi."),
        },
        shows={
            "en": [
                "How light absorbed in a photometer becomes a signal (schematic, general principle).",
                "Calibrators with assigned values, five illustrative points and a least-squares line: slope, intercept, R².",
                "Reading a control off the curve; why R² alone is not enough and what residuals should look like.",
                "Real LabGuide screens: instrument, analyte, reagent REF and IFU revision, the calibration record, "
                "the acceptance rule, the on-device log and its history.",
            ],
            "ru": [
                "Как поглощённый в фотометре свет становится сигналом (схема, общий принцип).",
                "Калибраторы с назначенными значениями, пять иллюстративных точек и прямая по методу наименьших квадратов: наклон, свободный член, R².",
                "Как считывают контроль по кривой; почему одного R² мало и какими должны быть остатки.",
                "Реальные экраны LabGuide: прибор, аналит, REF реагента и версия IFU, запись калибровки, "
                "правило приёмки, журнал на устройстве и его история.",
            ],
            "uz": [
                "Fotometrda yutilgan nur signalga qanday aylanadi (sxema, umumiy tamoyil).",
                "Belgilangan qiymatli kalibratorlar, beshta namunaviy nuqta va eng kichik kvadratlar chizig‘i: qiyalik, ozod had, R².",
                "Nazoratni egri chiziqdan o‘qish; nega faqat R² yetarli emas va qoldiqlar qanday bo‘lishi kerak.",
                "LabGuide’ning haqiqiy ekranlari: apparat, analit, reagent REF va IFU versiyasi, kalibrlash yozuvi, "
                "qabul qoidasi, qurilmadagi jurnal va uning tarixi.",
            ],
        },
        app={
            "en": [
                "LabGuide documents a calibration; it does not perform it and does not calibrate the analyzer.",
                "A record cannot be saved as “Accepted” until QC after calibration has passed and an approver "
                "(name or role) is entered.",
                "Saved records go to a calibration log stored on your device; creating, editing and deleting a record "
                "each leave a history entry.",
                "Without a verified guide for the instrument, LabGuide does not guess calibration parameters.",
            ],
            "ru": [
                "LabGuide документирует калибровку: он не выполняет её и не калибрует анализатор.",
                "Запись нельзя сохранить как «Принята», пока не пройден КК после калибровки и не указан "
                "утверждающий (имя или должность).",
                "Сохранённые записи попадают в журнал калибровок на вашем устройстве; создание, изменение и "
                "удаление записи оставляют запись в истории.",
                "Если для прибора нет проверенной инструкции, LabGuide не угадывает параметры калибровки.",
            ],
            "uz": [
                "LabGuide kalibrlashni hujjatlashtiradi: uni bajarmaydi va analizatorni kalibrlamaydi.",
                "Yozuvni «Qabul qilindi» deb saqlab bo‘lmaydi, toki kalibrlashdan keyingi QC o‘tmagan va tasdiqlovchi "
                "(ism yoki lavozim) ko‘rsatilmagan bo‘lsa.",
                "Saqlangan yozuvlar qurilmangizdagi kalibrlash jurnaliga tushadi; yozuvni yaratish, tahrirlash va "
                "o‘chirish tarixda iz qoldiradi.",
                "Apparat uchun tekshirilgan yo‘riqnoma bo‘lmasa, LabGuide kalibrlash parametrlarini taxmin qilmaydi.",
            ],
        },
        limits={
            "en": [
                "The five-point straight line is an illustrative example; the number of points, the model and the "
                "acceptance limits come from your reagent IFU and your lab’s SOP.",
                "The app asks for an approver’s name or role; it does not verify identity or authority.",
                "Schematic illustration — not an exact instrument model.",
            ],
            "ru": [
                "Прямая по пяти точкам — иллюстративный пример; число точек, модель и критерии приёмки берут "
                "из IFU реагента и СОП вашей лаборатории.",
                "Приложение запрашивает имя или должность утверждающего; личность и полномочия оно не проверяет.",
                "Схема — не конкретная модель прибора.",
            ],
            "uz": [
                "Beshta nuqtali to‘g‘ri chiziq — namunaviy misol; nuqtalar soni, model va qabul mezonlari reagent "
                "IFU’si va laboratoriyangiz SOP’idan olinadi.",
                "Ilova tasdiqlovchining ismi yoki lavozimini so‘raydi; shaxs va vakolatni tekshirmaydi.",
                "Sxematik tasvir — aniq apparat modeli emas.",
            ],
        },
        ig={
            "en": [
                "Absorbance 0.486 — which concentration is that? It depends on the calibration behind it.",
                "In about 90 seconds: how a photometric calibration curve turns absorbance into concentration "
                "(illustrative data) and how LabGuide records the calibration — calibrator lot, assigned values, "
                "QC after calibration, an approver for “Accepted”, and a log on your device with history.",
                "LabGuide documents calibration; it doesn’t perform it. Find it in Lab → Calibration.",
            ],
            "ru": [
                "Поглощение 0,486 — какая это концентрация? Зависит от калибровки, на которой основан результат.",
                "Примерно за 90 секунд: как калибровочная кривая превращает поглощение в концентрацию (иллюстративные "
                "данные) и как LabGuide фиксирует калибровку — лот калибратора, назначенные значения, КК после "
                "калибровки, утверждающий для «Принята» и журнал на устройстве с историей.",
                "LabGuide документирует калибровку, но не выполняет её. Раздел: Лаб. → Калибровка.",
            ],
            "uz": [
                "Yutilish 0,486 — bu qanday konsentratsiya? Bu uning ortidagi kalibrlashga bog‘liq.",
                "Taxminan 90 soniyada: kalibrlash egri chizig‘i yutilishni konsentratsiyaga qanday aylantiradi (namunaviy "
                "ma’lumot) va LabGuide kalibrlashni qanday qayd etadi — kalibrator loti, belgilangan qiymatlar, "
                "kalibrlashdan keyingi QC, «Qabul qilindi» uchun tasdiqlovchi va qurilmadagi jurnal tarixi bilan.",
                "LabGuide kalibrlashni hujjatlashtiradi — uni bajarmaydi. Bo‘lim: Lab → Kalibrlash.",
            ],
        },
        pinned={
            "en": ("Notes: every number in this video is illustrative, not a patient result. The number of "
                   "calibration points, the model and the acceptance limits always come from your reagent IFU and "
                   "your lab’s SOP. Narration is English synthetic speech; subtitles are in the edition’s language. "
                   "The content is awaiting expert review — corrections are welcome. Which topic should we cover next?"),
            "ru": ("Заметки: все числа в видео иллюстративные, это не результаты пациентов. Число точек калибровки, "
                   "модель и критерии приёмки всегда берутся из IFU реагента и СОП вашей лаборатории. Озвучка — "
                   "синтезированная английская речь; субтитры — на языке выпуска. Материал ждёт экспертной проверки, "
                   "поправки приветствуются. О чём сделать следующее видео?"),
            "uz": ("Eslatma: videodagi barcha raqamlar namunaviy, bemor natijasi emas. Kalibrlash nuqtalari soni, model "
                   "va qabul mezonlari doim reagent IFU’si va laboratoriyangiz SOP’idan olinadi. Diktor ovozi — "
                   "sun’iy inglizcha nutq; subtitrlar nashr tilida. Material mutaxassis ko‘rigini kutmoqda — "
                   "tuzatishlar uchun rahmat. Keyingi video qaysi mavzuda bo‘lsin?"),
        },
        keywords={
            "en": ["photometric calibration", "calibration curve", "absorbance", "calibrators", "clinical chemistry",
                   "laboratory calibration", "least squares", "R squared", "residuals", "QC after calibration",
                   "medical laboratory", "lab technician", "LabGuide"],
            "ru": ["калибровка", "калибровочная кривая", "поглощение", "фотометрия", "клиническая лаборатория",
                   "контроль качества", "лаборант", "биохимия"],
            "uz": ["kalibrlash", "kalibrlash egri chizig‘i", "yutilish", "fotometriya", "klinik laboratoriya",
                   "sifat nazorati", "laborant", "biokimyo"],
        },
        hashtags_topic={
            "en": ["#Calibration", "#ClinicalChemistry", "#Photometry", "#Absorbance", "#QualityControl",
                   "#LabQuality", "#CalibrationCurve", "#BiochemistryLab"],
            "ru": ["#калибровка", "#биохимия", "#фотометрия", "#контрользачества", "#калибровочнаякривая",
                   "#КК", "#лабораторныйанализ"],
            "uz": ["#kalibrlash", "#biokimyo", "#fotometriya", "#sifatnazorati", "#yutilish", "#QC",
                   "#laboratoriyatahlili"],
        },
        thumb_alt={
            "en": "LabGuide logo, the title “Calibration” with the subtitle “From signal to a documented result”, a "
                  "straight calibration line through five points on an absorbance-versus-concentration chart, and "
                  "the notice “Illustrative data — not a patient result”.",
            "ru": "Логотип LabGuide, заголовок «Калибровка» с подзаголовком «От сигнала — к задокументированному "
                  "результату», прямая калибровочная линия через пять точек на графике поглощения от концентрации и "
                  "пометка «Иллюстративные данные — не результат пациента».",
            "uz": "LabGuide logotipi, «Kalibrlash» sarlavhasi va «Signaldan hujjatlashtirilgan natijagacha» "
                  "sarlavha osti, yutilish–konsentratsiya grafigida beshta nuqta orqali o‘tgan kalibrlash chizig‘i "
                  "va «Namunaviy ma’lumot — bemor natijasi emas» belgisi.",
        },
        chapters=CAL_CHAPTERS,
        sources=[],
        evidence=["docs/video/calibration/CLAIMS_AND_EVIDENCE.md", "docs/video/calibration/DESCRIPTION.md",
                  "docs/video/calibration/QA.md"],
        next=["qc", "photometry"],
        paid=None,
        internal=[
            "The calibration log is free today. CSV/PDF export of the log is a Specialist Pro feature (D-78, built "
            "on the paid branch, flag off). The video does not mention it: do not add a paid claim unless the video "
            "is re-cut.",
            "Open expert items from the claims table: E2 hook wording (factor methods), E7 residual criteria, "
            "E9 representativeness of a 5-point linear curve.",
        ],
    ),
    # ------------------------------------------------------------------ 2. leukocyte
    dict(
        id="leukocyte", order=2, tier="free", verified=True,
        path=T("Lab → Differential count", "Лаб. → Лейкоформула", "Lab → Leykoformula"),
        title=T(
            "Leukocyte Differential Count: Cell Types and a Tally in LabGuide",
            "Лейкоформула: типы клеток и счётчик в LabGuide",
            "Leykoformula: hujayra turlari va LabGuide hisoblagichi",
        ),
        hook={
            "en": ("Lost count in the middle of a hundred-cell differential? There is a better way to keep the tally.",
                   "Where to count on the film, five cell types, and a one-tap counter in LabGuide."),
            "ru": ("Сбились со счёта посреди лейкоформулы на сто клеток? Счёт можно вести удобнее.",
                   "Где считать на мазке, пять типов клеток и счётчик LabGuide в одно нажатие."),
            "uz": ("Yuz hujayrali leykoformulaning o‘rtasida sanoqdan adashdingizmi? Hisobni yuritishning qulayroq yo‘li bor.",
                   "Surtmada qayerda sanash, beshta hujayra turi va LabGuide’da bir bosishli hisoblagich."),
        },
        shows={
            "en": [
                "Where to count on a stained blood film under the oil objective: the monolayer, where red cells "
                "touch but do not overlap, and how to move field by field without counting a cell twice.",
                "Segmented and band neutrophils, eosinophil, basophil, lymphocyte and monocyte, as schematic "
                "illustrations drawn by LabGuide on one scale (not micrographs).",
                "The tally in LabGuide on real app screens: one big button per cell class, 100 or 200 cells with a "
                "stop at the target, Microscope mode, percentages and absolute counts, saving the result.",
            ],
            "ru": [
                "Где считать на окрашенном мазке крови под иммерсией: монослой, где эритроциты касаются, но не "
                "налегают друг на друга, и как двигаться поле за полем, не считая клетку дважды.",
                "Сегментоядерный и палочкоядерный нейтрофилы, эозинофил, базофил, лимфоцит и моноцит — схематичные "
                "рисунки LabGuide в одном масштабе (не микрофото).",
                "Счёт в LabGuide на реальных экранах приложения: большая кнопка для каждого типа клеток, 100 или 200 "
                "клеток с остановкой на цели, режим микроскопа, проценты и абсолютные числа, сохранение результата.",
            ],
            "uz": [
                "Bo‘yalgan qon surtmasida immersiya ostida qayerda sanash: eritrotsitlar tegib, ustma-ust tushmagan "
                "monoqatlam va hujayrani ikki marta sanamasdan maydonma-maydon yurish.",
                "Segment va tayoqcha yadroli neytrofillar, eozinofil, bazofil, limfotsit va monotsit — LabGuide "
                "chizgan, bir masshtabdagi sxematik rasmlar (mikrofoto emas).",
                "LabGuide’dagi hisoblagich ilovaning haqiqiy ekranlarida: har hujayra turiga katta tugma, maqsadda "
                "to‘xtaydigan 100 yoki 200 hujayra, mikroskop rejimi, foizlar va mutlaq sonlar, natijani saqlash.",
            ],
        },
        app={
            "en": [
                "One big button per cell class (segmented and band neutrophils, lymphocyte, monocyte, eosinophil, "
                "basophil, other): a tap adds one, a long press takes one away.",
                "You choose 100 or 200 cells; at the target counting stops and an extra tap is not added.",
                "Microscope mode: large screen zones so your eyes can stay on the eyepiece, with sound and vibration "
                "cues where your phone supports and allows them.",
                "Percentages are computed by the app; enter the WBC and absolute counts appear next to them.",
                "Save the result on your device or copy it as text. LabGuide has no PDF export for this counter.",
            ],
            "ru": [
                "Одна большая кнопка на каждый тип клеток (сегментоядерные и палочкоядерные нейтрофилы, лимфоцит, "
                "моноцит, эозинофил, базофил, прочие): нажатие добавляет единицу, долгое нажатие убирает.",
                "Вы выбираете 100 или 200 клеток; на цели подсчёт останавливается, лишнее нажатие не добавляется.",
                "Режим микроскопа: большие зоны экрана, чтобы глаза оставались у окуляра, со звуком и вибрацией — "
                "если телефон их поддерживает и они включены.",
                "Проценты считает приложение; введите WBC — и рядом появятся абсолютные числа.",
                "Результат можно сохранить на устройстве или скопировать текстом. PDF-экспорта у этого счётчика нет.",
            ],
            "uz": [
                "Har hujayra turiga bitta katta tugma (segment va tayoqcha yadroli neytrofillar, limfotsit, monotsit, "
                "eozinofil, bazofil, boshqalar): bosish +1, uzoq bosish −1.",
                "100 yoki 200 hujayrani siz tanlaysiz; maqsadda sanash to‘xtaydi va ortiqcha bosish qo‘shilmaydi.",
                "Mikroskop rejimi: katta ekran zonalari, ko‘z okulyardan uzilmasligi uchun; telefon qo‘llab-quvvatlasa "
                "va yoqilgan bo‘lsa — tovush va tebranish bilan.",
                "Foizlarni ilova hisoblaydi; WBC kiritilsa, yonida mutlaq sonlar chiqadi.",
                "Natijani qurilmada saqlash yoki matn sifatida nusxalash mumkin. Bu hisoblagichda PDF eksport yo‘q.",
            ],
        },
        limits={
            "en": [
                "The tally in the video is an illustrative example, not a typical or normal pattern.",
                "Reference ranges come from your laboratory’s report form; comparing a count with them is not a "
                "diagnosis. The conclusion belongs to the clinician.",
                "Cells and smear are schematic illustrations drawn by LabGuide, not micrographs; app screens are real "
                "(sample values).",
            ],
            "ru": [
                "Подсчёт в видео — иллюстративный пример, а не типичная или нормальная картина.",
                "Референтные интервалы берут с бланка вашей лаборатории; сравнение с ними — не диагноз. "
                "Заключение делает врач.",
                "Клетки и мазок — схематичные рисунки LabGuide, не микрофото; экраны приложения реальные "
                "(примерные значения).",
            ],
            "uz": [
                "Videodagi sanash — namunaviy misol, odatiy yoki me’yoriy manzara emas.",
                "Me’yorlar laboratoriyangiz blankasidan olinadi; sanashni ular bilan solishtirish tashxis emas. "
                "Xulosa shifokorniki.",
                "Hujayralar va surtma — LabGuide chizgan sxematik rasmlar, mikrofoto emas; ilova ekranlari haqiqiy "
                "(namunaviy qiymatlar).",
            ],
        },
        ig={
            "en": [
                "Lost count in the middle of a hundred-cell differential? There is a better way to keep the tally.",
                "In under two minutes: where to count on the film, five cell types (schematic illustrations), and "
                "how LabGuide’s counter works — one big button per cell class, 100 or 200 cells with a stop at the "
                "target, Microscope mode so your eyes stay on the eyepiece, then percentages and absolute counts.",
                "A counting aid: reference ranges come from your laboratory, conclusions from the clinician. "
                "Find it in Lab → Differential count.",
            ],
            "ru": [
                "Сбились со счёта посреди лейкоформулы на сто клеток? Счёт можно вести удобнее.",
                "Меньше чем за две минуты: где считать на мазке, пять типов клеток (схематичные рисунки) и как "
                "работает счётчик LabGuide — большая кнопка на каждый тип, 100 или 200 клеток с остановкой на цели, "
                "режим микроскопа, чтобы глаза оставались у окуляра, затем проценты и абсолютные числа.",
                "Помощник для подсчёта: референтные интервалы — от вашей лаборатории, заключение — от врача. "
                "Раздел: Лаб. → Лейкоформула.",
            ],
            "uz": [
                "Yuz hujayrali leykoformulaning o‘rtasida sanoqdan adashdingizmi? Hisobni yuritishning qulayroq yo‘li bor.",
                "Ikki daqiqadan kamda: surtmada qayerda sanash, beshta hujayra turi (sxematik rasmlar) va LabGuide "
                "hisoblagichi qanday ishlashi — har tur uchun katta tugma, maqsadda to‘xtaydigan 100 yoki 200 hujayra, "
                "ko‘z okulyarda qolishi uchun mikroskop rejimi, so‘ng foizlar va mutlaq sonlar.",
                "Sanash yordamchisi: me’yor — laboratoriyangizdan, xulosa — shifokordan. Bo‘lim: Lab → Leykoformula.",
            ],
        },
        pinned={
            "en": ("Notes: the count in this video is illustrative, not a patient result, and not a typical or normal "
                   "pattern. Cells are schematic drawings, not micrographs. Reference ranges come from your laboratory’s "
                   "report form, and the number of cells to count (100, 200 or other) follows your SOP. Narration is "
                   "English synthetic speech. The content is awaiting expert review — corrections are welcome. "
                   "Do you count 100 or 200 cells in your lab?"),
            "ru": ("Заметки: подсчёт в видео иллюстративный, это не результат пациента и не типичная или нормальная "
                   "картина. Клетки — схематичные рисунки, не микрофото. Референтные интервалы берут с бланка вашей "
                   "лаборатории, а число клеток (100, 200 или иное) определяет ваша СОП. Озвучка — синтезированная "
                   "английская речь. Материал ждёт экспертной проверки, поправки приветствуются. "
                   "Сколько клеток считаете вы — 100 или 200?"),
            "uz": ("Eslatma: videodagi sanash namunaviy, bemor natijasi emas, odatiy yoki me’yoriy manzara ham emas. "
                   "Hujayralar — sxematik rasmlar, mikrofoto emas. Me’yorlar laboratoriyangiz blankasidan olinadi, "
                   "sanaladigan hujayralar soni (100, 200 yoki boshqa) SOP’ingizga bog‘liq. Diktor ovozi — sun’iy "
                   "inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda — tuzatishlar uchun rahmat. "
                   "Siz 100 ta hujayra sanaysizmi yoki 200 ta?"),
        },
        keywords={
            "en": ["differential count", "leukocyte differential", "manual differential", "white blood cell count",
                   "blood smear", "neutrophil", "band neutrophil", "eosinophil", "basophil", "lymphocyte", "monocyte",
                   "hematology", "differential counter app", "LabGuide"],
            "ru": ["лейкоформула", "подсчёт лейкоформулы", "мазок крови", "нейтрофилы", "палочкоядерные",
                   "эозинофилы", "лимфоциты", "гематология", "лаборант"],
            "uz": ["leykoformula", "leykoformulani sanash", "qon surtmasi", "neytrofil", "tayoqcha yadroli",
                   "eozinofil", "limfotsit", "gematologiya", "laborant"],
        },
        hashtags_topic={
            "en": ["#Hematology", "#DifferentialCount", "#BloodSmear", "#Leukocytes", "#WBC", "#Neutrophils",
                   "#Microscopy", "#Cytology"],
            "ru": ["#гематология", "#лейкоформула", "#мазоккрови", "#лейкоциты", "#микроскопия", "#нейтрофилы",
                   "#WBC"],
            "uz": ["#gematologiya", "#leykoformula", "#qonsurtmasi", "#leykotsitlar", "#mikroskopiya",
                   "#neytrofil", "#WBC"],
        },
        thumb_alt={
            "en": "LabGuide logo, the title “Differential count” with the subtitle “100 cells, one tap each.”, a "
                  "round microscope field of schematic red cells with an eosinophil at the reticle, six schematic cell "
                  "icons with illustrative counts, and the notices “Illustrative count — not a patient result” and "
                  "“Schematic illustration — not a micrograph”.",
            "ru": "Логотип LabGuide, заголовок «Лейкоформула» с подзаголовком «100 клеток — по нажатию на каждую.», "
                  "круглое поле микроскопа со схематичными эритроцитами и эозинофилом у сетки, шесть схематичных "
                  "значков клеток с иллюстративными числами и пометки «Иллюстративный подсчёт — не результат "
                  "пациента» и «Схематичный рисунок — не микрофото».",
            "uz": "LabGuide logotipi, «Leykoformula» sarlavhasi va «100 hujayra — har biriga bitta bosish.» sarlavha "
                  "osti, sxematik eritrotsitlar va to‘r yonidagi eozinofilli dumaloq mikroskop maydoni, namunaviy "
                  "sonli oltita sxematik hujayra belgisi hamda «Namunaviy sanash — bemor natijasi emas» va «Sxematik "
                  "rasm — mikrofoto emas» belgilari.",
        },
        chapters=LEU_CHAPTERS,
        sources=[
            "WHO, Manual of basic techniques for a health laboratory, 2nd ed. (2003), §9.10, §9.13.",
            "Gulati G. et al., Ann Lab Med 2013.",
            "Любина А.Я. и др., Клинические лабораторные исследования (1984), §61.",
        ],
        evidence=["docs/video/leukocyte/CLAIMS_AND_EVIDENCE.md", "docs/video/leukocyte/DESCRIPTION.md",
                  "docs/video/leukocyte/QA.md"],
        next=["calibration", "calculators"],
        paid=None,
        internal=[
            "Open expert items from the claims table: E7 (schematic morphology), E10 (the illustrative tally may look "
            "\"normal\" — the app's own default limits mark it within range in one frame), E11 hook wording.",
            "The experimental voice-counting mode of the app is NOT in the video: do not mention it.",
        ],
    ),
    # ------------------------------------------------------------------ 3. photometry (the lead's name: spectrophotometry)
    dict(
        id="photometry", order=3, tier="free", verified=False,
        path=T("Learn → Lecture mode → Practical protocols", "Обучение → Режим лекции → Практические протоколы",
               "O‘rganish → Ma’ruza rejimi → Amaliy protokollar"),
        title=T(
            "Photometry Basics: Blank, Standard, Sample and the Linearity Limit",
            "Основы фотометрии: бланк, стандарт, проба и граница линейности",
            "Fotometriya asoslari: blank, standart, namuna va chiziqlilik chegarasi",
        ),
        hook={
            "en": ("Absorbance far above your standard — can you trust that number?",
                   "Photometry basics: blank, standard, sample and the linearity limit."),
            "ru": ("Оптическая плотность намного выше стандарта — можно ли верить этому числу?",
                   "Основы фотометрии: бланк, стандарт, проба и граница линейности."),
            "uz": ("Optik zichlik standartdan ancha yuqori — bu raqamga ishonsa bo‘ladimi?",
                   "Fotometriya asoslari: blank, standart, namuna va chiziqlilik chegarasi."),
        },
        shows={
            "en": [
                "How a photometer works: one wavelength through the cuvette, A = log₁₀(I₀/I); at A = 1 only ten percent "
                "of the light gets through, at A = 2 one percent.",
                "The Beer–Lambert law: within a range absorbance rises in proportion to concentration; past the "
                "linearity limit the curve bends and readings fall short.",
                "Three cuvettes: the blank sets zero, then the standard, then the sample; concentration = A sample ÷ "
                "A standard × the standard’s concentration (illustrative numbers).",
                "Above the limit: dilute, measure again, multiply by the dilution factor.",
                "Real LabGuide screens: the photometry-basics protocol in Lecture mode.",
            ],
            "ru": [
                "Как работает фотометр: свет одной длины волны через кювету, A = log₁₀(I₀/I); при A = 1 проходит "
                "лишь 10 % света, при A = 2 — 1 %.",
                "Закон Бугера–Ламберта–Бера: в пределах диапазона оптическая плотность растёт пропорционально "
                "концентрации; выше границы линейности кривая изгибается и показание занижено.",
                "Три кюветы: бланк задаёт ноль, затем стандарт и проба; концентрация = A пробы ÷ A стандарта × "
                "концентрация стандарта (иллюстративные числа).",
                "Выше границы: разведите, повторите измерение, умножьте на степень разведения.",
                "Реальные экраны LabGuide: протокол по основам фотометрии в режиме лекции.",
            ],
            "uz": [
                "Fotometr qanday ishlaydi: kyuvetadan bir to‘lqin uzunlikdagi nur, A = log₁₀(I₀/I); A = 1 da nurning "
                "faqat 10 % i o‘tadi, A = 2 da — 1 % i.",
                "Buger–Lambert–Ber qonuni: ma’lum oraliqda optik zichlik konsentratsiyaga mutanosib; chiziqlilik "
                "chegarasidan oshsa egri chiziq bukiladi va natija past chiqadi.",
                "Uch kyuveta: blank nolni qo‘yadi, so‘ng standart va namuna; konsentratsiya = A namuna ÷ A standart × "
                "standart konsentratsiyasi (namunaviy sonlar).",
                "Chegaradan oshsa: suyultiring, qayta o‘lchang, suyultirish koeffitsientiga ko‘paytiring.",
                "LabGuide’ning haqiqiy ekranlari: ma’ruza rejimidagi fotometriya asoslari protokoli.",
            ],
        },
        app={
            "en": [
                "LabGuide’s Lecture mode (Learn → Lecture mode → Practical protocols) has a protocol on photometry basics: "
                "blank, standard and sample step by step, the calculation, and the rule for results above the "
                "linearity limit.",
                "It is a teaching protocol: the reagent IFU and your lab’s SOP always take precedence.",
                "LabGuide does not measure anything and does not interpret results.",
            ],
            "ru": [
                "В режиме лекции LabGuide (Обучение → Режим лекции → Практические протоколы) есть протокол по основам "
                "фотометрии: бланк, стандарт и проба по шагам, расчёт и правило для результата выше границы линейности.",
                "Это учебный протокол: IFU реагента и СОП вашей лаборатории всегда главнее.",
                "LabGuide ничего не измеряет и не интерпретирует результаты.",
            ],
            "uz": [
                "LabGuide ma’ruza rejimida (O‘rganish → Ma’ruza rejimi → Amaliy protokollar) fotometriya asoslari "
                "protokoli bor: blank, standart va namuna bosqichma-bosqich, hisoblash va chiziqlilik chegarasidan "
                "oshgan natija qoidasi.",
                "Bu o‘quv protokoli: reagent IFU’si va laboratoriyangiz SOP’i doim ustun.",
                "LabGuide hech narsani o‘lchamaydi va natijalarni talqin qilmaydi.",
            ],
        },
        limits={
            "en": ["Wavelength, blank and linearity limits always come from your reagent’s IFU; the numbers in the video "
                   "are illustrative.",
                   "The single-standard calculation is one worked example, not the method for every assay."],
            "ru": ["Длина волны, бланк и границы линейности всегда берутся из IFU вашего реагента; числа в видео "
                   "иллюстративные.",
                   "Расчёт по одному стандарту — один разобранный пример, а не метод для любого анализа."],
            "uz": ["To‘lqin uzunligi, blank va chiziqlilik chegaralari doim reagent IFU’sidan olinadi; videodagi "
                   "sonlar namunaviy.",
                   "Bitta standart bo‘yicha hisoblash — bitta ishlangan misol, har qanday tahlil uchun metod emas."],
        },
        ig={
            "en": ["Absorbance far above your standard — can you trust that number?",
                   "Photometry basics in a minute: how a photometer measures absorbance, the Beer–Lambert law and the "
                   "linearity limit, blank → standard → sample, and what to do above the limit (illustrative numbers).",
                   "LabGuide’s Lecture mode has a protocol on it: Learn → Lecture mode → Practical protocols. "
                   "A teaching protocol: your reagent IFU and SOP always take precedence."],
            "ru": ["Оптическая плотность намного выше стандарта — можно ли верить этому числу?",
                   "Основы фотометрии за минуту: как фотометр измеряет оптическую плотность, закон "
                   "Бугера–Ламберта–Бера и граница линейности, бланк → стандарт → проба и что делать выше границы "
                   "(иллюстративные числа).",
                   "В режиме лекции LabGuide есть протокол: Обучение → Режим лекции → Практические протоколы. "
                   "Учебный протокол: IFU реагента и СОП всегда главнее."],
            "uz": ["Optik zichlik standartdan ancha yuqori — bu raqamga ishonsa bo‘ladimi?",
                   "Bir daqiqada fotometriya asoslari: fotometr optik zichlikni qanday o‘lchaydi, Buger–Lambert–Ber "
                   "qonuni va chiziqlilik chegarasi, blank → standart → namuna va chegaradan oshsa nima qilish "
                   "(namunaviy sonlar).",
                   "LabGuide ma’ruza rejimida protokol bor: O‘rganish → Ma’ruza rejimi → Amaliy protokollar. "
                   "O‘quv protokoli: reagent IFU’si va SOP doim ustun."],
        },
        pinned={
            "en": ("Notes: all numbers in this video are illustrative, not patient results. Wavelength, blank and "
                   "linearity limits always come from your reagent’s IFU and your lab’s SOP. Narration is English "
                   "synthetic speech. The content is awaiting expert review — corrections are welcome. "
                   "Do you use a single standard or a calibration curve in your lab?"),
            "ru": ("Заметки: все числа в видео иллюстративные, это не результаты пациентов. Длина волны, бланк и "
                   "границы линейности всегда берутся из IFU вашего реагента и СОП вашей лаборатории. Озвучка — "
                   "синтезированная английская речь. Материал ждёт экспертной проверки, поправки приветствуются. "
                   "Что у вас в лаборатории — один стандарт или калибровочная кривая?"),
            "uz": ("Eslatma: videodagi barcha sonlar namunaviy, bemor natijasi emas. To‘lqin uzunligi, blank va "
                   "chiziqlilik chegaralari doim reagent IFU’si va laboratoriyangiz SOP’idan olinadi. Diktor ovozi — "
                   "sun’iy inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda — tuzatishlar uchun rahmat. "
                   "Laboratoriyangizda bitta standartmi yoki kalibrlash egri chizig‘imi?"),
        },
        keywords={
            "en": ["photometry", "spectrophotometry", "absorbance", "Beer-Lambert law", "linearity limit", "cuvette",
                   "blank standard sample", "clinical chemistry", "dilution factor", "medical laboratory", "LabGuide"],
            "ru": ["фотометрия", "спектрофотометрия", "оптическая плотность", "закон Бугера-Ламберта-Бера",
                   "граница линейности", "кювета", "бланк стандарт проба", "биохимия", "лаборант"],
            "uz": ["fotometriya", "spektrofotometriya", "optik zichlik", "Buger-Lambert-Ber qonuni",
                   "chiziqlilik chegarasi", "kyuveta", "blank standart namuna", "biokimyo", "laborant"],
        },
        hashtags_topic={
            "en": ["#Photometry", "#Spectrophotometry", "#Absorbance", "#BeerLambert", "#ClinicalChemistry",
                   "#LabInstruments", "#BiochemistryLab"],
            "ru": ["#фотометрия", "#спектрофотометрия", "#оптическаяплотность", "#биохимия", "#кювета",
                   "#приборылаборатории", "#лабораторныйанализ"],
            "uz": ["#fotometriya", "#spektrofotometriya", "#optikzichlik", "#biokimyo", "#kyuveta",
                   "#laboratoriyaapparatlari", "#laboratoriyatahlili"],
        },
        thumb_alt=None,
        chapters=[
            ("hook", T("The measurement: light in, light out", "Измерение: свет на входе и на выходе",
                       "O‘lchash: kirgan va chiqqan nur")),
            ("ladder", T("Beer–Lambert law and the linearity limit", "Закон Бугера–Ламберта–Бера и граница линейности",
                         "Buger–Lambert–Ber qonuni va chiziqlilik chegarasi")),
            ("bss", T("Blank, standard, sample — and dilution", "Бланк, стандарт, проба — и разведение",
                      "Blank, standart, namuna — va suyultirish")),
            ("app_intro", T("In LabGuide: the photometry protocol", "В LabGuide: протокол по фотометрии",
                            "LabGuide’da: fotometriya protokoli")),
        ],
        sources=[],
        evidence=["docs/video/photometry/CLAIMS_AND_EVIDENCE.md (when it exists)",
                  "docs/video/photometry/lines.en.json and storyboard.json (the copy follows them as of 2026-10-25)",
                  "assets/lectures/decks/fotometriya-asoslari-biokimyo.{uz,ru,en}.json (the protocol, kind: protocol)",
                  "docs/VIDEO_FEATURE_INVENTORY.md §3 (Lecture mode)"],
        next=["calibration", "qc"],
        paid=None,
        internal=["The lead's name for this topic was `spectrophotometry`; the studio id is `photometry` "
                  "(docs/video/photometry/). `spectrophotometry` is kept as an alias.",
                  "Copy aligned with lines.en.json of the video IN PRODUCTION (no render, no claims table yet): re-check "
                  "every sentence against the final lines and CLAIMS_AND_EVIDENCE.md, then set verified=True.",
                  "Terminology differs from the calibration video: «оптическая плотность» / «optik zichlik» here, "
                  "«поглощение» / «yutilish» there: the native reviewer picks one (G3).",
                  "The app path is Lecture mode, not Lab → Instruments: the protocol is a lecture deck of kind "
                  "protocol (uz/ru/en); confirm the deck is in the advertised build."],
    ),
    # ------------------------------------------------------------------ 4. qc
    dict(
        id="qc", order=4, tier="free", verified=False,
        path=T("Lab → Quality control (QC)", "Лаб. → Контроль качества (QC)", "Lab → Sifat nazorati (QC)"),
        title=T(
            "Levey–Jennings Charts and Westgard Rules in LabGuide QC",
            "Контроль качества: Леви–Дженнингс и правила Вестгарда в LabGuide",
            "Sifat nazorati: Levey–Jennings va Westgard qoidalari LabGuide’da",
        ),
        hook={
            "en": ("Is today’s QC run in control? Enter the control results and see it on a Levey–Jennings chart.",
                   "LabGuide checks each run against the Westgard rules — warning or rejection — on your device."),
            "ru": ("Контроль качества сегодня в норме? Введите результаты — и увидите их на карте Леви–Дженнингса.",
                   "LabGuide проверяет каждую серию по правилам Вестгарда — предупреждение или отклонение — на вашем устройстве."),
            "uz": ("Bugungi sifat nazorati me’yordami? Nazorat natijalarini kiriting — Levey–Jennings grafigida ko‘rasiz.",
                   "LabGuide har seriyani Westgard qoidalari bo‘yicha tekshiradi — ogohlantirish yoki rad etish — qurilmangizda."),
        },
        shows={
            "en": [
                "Creating a control set: test, unit, target source, and a target mean and SD for each level.",
                "Entering run results and reading the Levey–Jennings chart: in control, warning, rejected.",
                "The QC guides: what to do when QC is rejected, external quality assessment (EQA) and critical values.",
            ],
            "ru": [
                "Создание набора контролей: тест, единицы, источник целевых значений, целевое среднее и SD для каждого уровня.",
                "Ввод результатов серии и чтение карты Леви–Дженнингса: в пределах, предупреждение, отклонено.",
                "Памятки по КК: что делать при отклонении КК, внешняя оценка качества (EQA) и критические значения.",
            ],
            "uz": [
                "Nazorat to‘plamini yaratish: test, birlik, maqsad manbai, har daraja uchun maqsadli o‘rtacha va SD.",
                "Seriya natijalarini kiritish va Levey–Jennings grafigini o‘qish: nazoratda, ogohlantirish, rad etilgan.",
                "QC yo‘riqnomalari: QC rad etilsa nima qilish, tashqi sifat baholash (EQA) va kritik qiymatlar.",
            ],
        },
        app={
            "en": [
                "You enter the target mean and SD for each level; the app does not invent target values.",
                "Each saved run is evaluated against the Westgard rules and marked on the chart.",
                "Data stay on your device; you can copy a text backup and copy results as CSV.",
                "The EQA and critical-value guides are explanations only: LabGuide is not connected to any EQA scheme "
                "and does not submit results.",
            ],
            "ru": [
                "Целевое среднее и SD для каждого уровня вводите вы; приложение не придумывает целевые значения.",
                "Каждая сохранённая серия оценивается по правилам Вестгарда и отмечается на графике.",
                "Данные остаются на вашем устройстве; можно скопировать резервную копию текстом и результаты в виде CSV.",
                "Памятки по EQA и критическим значениям — только пояснения: LabGuide не подключён ни к одной "
                "программе EQA и не отправляет результаты.",
            ],
            "uz": [
                "Har daraja uchun maqsadli o‘rtacha va SD ni siz kiritasiz; ilova maqsadli qiymatlarni to‘qimaydi.",
                "Har saqlangan seriya Westgard qoidalari bo‘yicha baholanadi va grafikda belgilanadi.",
                "Ma’lumotlar qurilmangizda qoladi; zaxira nusxani matn sifatida, natijalarni CSV sifatida nusxalash mumkin.",
                "EQA va kritik qiymat yo‘riqnomalari faqat tushuntirish: LabGuide hech bir EQA dasturiga ulanmagan "
                "va natija yubormaydi.",
            ],
        },
        limits={
            "en": ["Targets, limits and the action after a rejected run come from your laboratory’s QC procedure and the "
                   "reagent IFU. The chart is a tool, not a clinical decision.",
                   "Illustrative control values only — not real control results."],
            "ru": ["Целевые значения, пределы и действия после отклонённой серии определяет процедура КК вашей "
                   "лаборатории и IFU реагента. График — инструмент, а не клиническое решение.",
                   "Значения контролей иллюстративные — это не реальные результаты контролей."],
            "uz": ["Maqsadli qiymatlar, chegaralar va rad etilgan seriyadan keyingi harakat laboratoriyangizning QC "
                   "tartibi va reagent IFU’sidan olinadi. Grafik — vosita, klinik qaror emas.",
                   "Nazorat qiymatlari faqat namunaviy — haqiqiy nazorat natijalari emas."],
        },
        ig={
            "en": ["Is today’s QC run in control? Enter the control results and see it on a Levey–Jennings chart.",
                   "LabGuide evaluates every run against the Westgard rules — warning or rejection — marks it on the "
                   "chart and keeps the data on your device. Targets are the ones you enter (illustrative values in "
                   "the video).",
                   "Find it in Lab → Quality control (QC). The EQA guide is an explainer only."],
            "ru": ["Контроль качества сегодня в норме? Введите результаты — и увидите их на карте Леви–Дженнингса.",
                   "LabGuide оценивает каждую серию по правилам Вестгарда — предупреждение или отклонение — отмечает "
                   "её на графике и хранит данные на вашем устройстве. Целевые значения — те, что вводите вы "
                   "(в видео — иллюстративные).",
                   "Раздел: Лаб. → Контроль качества (QC). Памятка по EQA — только пояснение."],
            "uz": ["Bugungi sifat nazorati me’yordami? Nazorat natijalarini kiriting — Levey–Jennings grafigida ko‘rasiz.",
                   "LabGuide har seriyani Westgard qoidalari bo‘yicha baholaydi — ogohlantirish yoki rad etish — "
                   "grafikda belgilaydi va ma’lumotni qurilmangizda saqlaydi. Maqsadli qiymatlar — siz kiritganlar "
                   "(videoda namunaviy).",
                   "Bo‘lim: Lab → Sifat nazorati (QC). EQA yo‘riqnomasi faqat tushuntirish."],
        },
        pinned={
            "en": ("Notes: control values in this video are illustrative, not real QC results. Targets, limits and the "
                   "action after a rejected run come from your lab’s QC procedure and the reagent IFU. The EQA guide in "
                   "the app is an explanation only. Narration is English synthetic speech. The content is awaiting "
                   "expert review — corrections are welcome. Which Westgard rules does your lab use?"),
            "ru": ("Заметки: значения контролей в видео иллюстративные, это не реальные результаты КК. Целевые "
                   "значения, пределы и действия после отклонённой серии определяет процедура КК вашей лаборатории "
                   "и IFU реагента. Памятка по EQA в приложении — только пояснение. Озвучка — синтезированная "
                   "английская речь. Материал ждёт экспертной проверки, поправки приветствуются. "
                   "Какие правила Вестгарда применяет ваша лаборатория?"),
            "uz": ("Eslatma: videodagi nazorat qiymatlari namunaviy, haqiqiy QC natijalari emas. Maqsadli qiymatlar, "
                   "chegaralar va rad etilgan seriyadan keyingi harakat laboratoriyangiz QC tartibi va reagent "
                   "IFU’sidan olinadi. Ilovadagi EQA yo‘riqnomasi faqat tushuntirish. Diktor ovozi — sun’iy "
                   "inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda. Laboratoriyangiz qaysi Westgard "
                   "qoidalarini qo‘llaydi?"),
        },
        keywords={
            "en": ["quality control", "Levey-Jennings chart", "Westgard rules", "internal quality control",
                   "laboratory QC", "QC rules", "1-3s", "2-2s", "clinical chemistry", "LabGuide"],
            "ru": ["контроль качества", "карта Леви-Дженнингса", "правила Вестгарда", "внутрилабораторный контроль",
                   "КК", "лаборант", "клиническая лаборатория"],
            "uz": ["sifat nazorati", "Levey-Jennings grafigi", "Westgard qoidalari", "ichki nazorat", "QC",
                   "laborant", "klinik laboratoriya"],
        },
        hashtags_topic={
            "en": ["#QualityControl", "#Westgard", "#LeveyJennings", "#QC", "#LabQuality", "#ClinicalChemistry",
                   "#LabManagement"],
            "ru": ["#контрользачества", "#Вестгард", "#ЛевиДженнингс", "#КК", "#внутреннийконтроль",
                   "#биохимия", "#менеджментлаборатории"],
            "uz": ["#sifatnazorati", "#Westgard", "#LeveyJennings", "#QC", "#ichkinazorat", "#biokimyo",
                   "#laboratoriyaboshqaruvi"],
        },
        thumb_alt=None,
        chapters=None,
        sources=[],
        evidence=["docs/video/qc/CLAIMS_AND_EVIDENCE.md (when it exists)", "docs/video/02_sifat_nazorati.md",
                  "docs/VIDEO_FEATURE_INVENTORY.md §1 (QC rows)", "test/widget/qc_flow_test.dart",
                  "test/unit/qc_rules_test.dart"],
        next=["calibration", "calculators"],
        paid=None,
        internal=["Free today: sets, runs, Levey–Jennings, Westgard, CSV copy, JSON backup. A QC summary report as "
                  "CSV/PDF file is a Specialist Pro feature (D-78, flag off): do not mention it unless the video does.",
                  "Which Westgard rules the app applies must match the video (app text lists 1-2s, 1-3s, 2-2s, R-4s, "
                  "4-1s, 10x): re-check against the final script."],
    ),
    # ------------------------------------------------------------------ 5. gc_ms
    dict(
        id="gc_ms", order=5, tier="free", verified=False,
        path=T("Lab → Instruments → Toxicology → GC-MS", "Лаб. → Приборы → Токсикология → ГХ-МС",
               "Lab → Apparatlar → Toksikologiya → GC-MS"),
        title=T(
            "GC-MS Explained: From Injector to Mass Spectrum (Schematic)",
            "ГХ-МС простыми словами: от инжектора до масс-спектра (схема)",
            "GC-MS tushuntirish: injektordan mass-spektrgacha (sxema)",
        ),
        hook={
            "en": ("A sample goes in as a vapour and comes out as a chromatogram and a mass spectrum.",
                   "What happens in between, step by step, on a schematic."),
            "ru": ("Образец попадает в прибор паром, а выходит хроматограммой и масс-спектром.",
                   "Что происходит между этим, шаг за шагом, на схеме."),
            "uz": ("Namuna bug‘ sifatida kiradi, xromatogramma va mass-spektr sifatida chiqadi.",
                   "Oradagi jarayon — sxemada, qadamma-qadam."),
        },
        shows={
            "en": ["The two blocks of a GC-MS: the gas chromatograph and the mass spectrometer, with numbered parts "
                   "(schematic).",
                   "How a sample is introduced, why it must be volatile, and how separation in the column differs from "
                   "separation by m/z.",
                   "The two outputs: a chromatogram and a mass spectrum."],
            "ru": ["Два блока ГХ-МС: газовый хроматограф и масс-спектрометр, с пронумерованными частями (схема).",
                   "Как вводят образец, почему он должен быть летучим и чем разделение в колонке отличается от "
                   "разделения по m/z.",
                   "Два результата: хроматограмма и масс-спектр."],
            "uz": ["GC-MS ning ikki bloki: gaz xromatografi va mass-spektrometr, raqamlangan qismlar bilan (sxema).",
                   "Namuna qanday kiritiladi, nega u uchuvchan bo‘lishi kerak va kolonkadagi ajralish m/z bo‘yicha "
                   "ajralishdan nimasi bilan farq qiladi.",
                   "Ikki natija: xromatogramma va mass-spektr."],
        },
        app={
            "en": ["LabGuide has a reference card for GC-MS in the instrument directions (toxicology) with an original "
                   "schematic illustration (not an exact model).",
                   "It is a reference: LabGuide gives no method, no interpretation of results and no drug-testing guidance."],
            "ru": ["В LabGuide есть справочная карточка ГХ-МС в направлениях приборов (токсикология) с оригинальным "
                   "схематичным рисунком (не конкретная модель).",
                   "Это справка: LabGuide не даёт методики, не интерпретирует результаты и не даёт указаний по "
                   "тестированию на наркотические вещества."],
            "uz": ["LabGuide’da apparat yo‘nalishlarida (toksikologiya) GC-MS bo‘yicha ma’lumotnoma kartasi bor, "
                   "original sxematik rasm bilan (aniq model emas).",
                   "Bu ma’lumotnoma: LabGuide metodika bermaydi, natijalarni talqin qilmaydi va giyohvandlik "
                   "moddalarini tekshirish bo‘yicha ko‘rsatma bermaydi."],
        },
        limits={
            "en": ["Schematic illustration — not an exact instrument model; real systems differ by manufacturer.",
                   "The chromatogram and spectrum shown are examples, not real results."],
            "ru": ["Схема — не конкретная модель прибора; реальные системы различаются по производителям.",
                   "Показанные хроматограмма и спектр — примеры, а не реальные результаты."],
            "uz": ["Sxematik tasvir — aniq apparat modeli emas; haqiqiy tizimlar ishlab chiqaruvchiga qarab farq qiladi.",
                   "Ko‘rsatilgan xromatogramma va spektr — misollar, haqiqiy natijalar emas."],
        },
        ig={
            "en": ["A sample goes in as a vapour and comes out as a chromatogram and a mass spectrum.",
                   "A schematic walk-through of GC-MS: injector, column, ion source, analyzer, detector — and the "
                   "difference between separation by retention time and by m/z.",
                   "Reference card in LabGuide’s instrument directions (toxicology). Schematic — not an exact model."],
            "ru": ["Образец попадает в прибор паром, а выходит хроматограммой и масс-спектром.",
                   "Схематичный разбор ГХ-МС: инжектор, колонка, источник ионов, анализатор, детектор — и чем "
                   "разделение по времени удерживания отличается от разделения по m/z.",
                   "Справочная карточка в направлениях приборов LabGuide (токсикология). Схема — не конкретная модель."],
            "uz": ["Namuna bug‘ sifatida kiradi, xromatogramma va mass-spektr sifatida chiqadi.",
                   "GC-MS ning sxemali tahlili: injektor, kolonka, ion manbai, analizator, detektor — va ushlanish "
                   "vaqti bo‘yicha ajralish bilan m/z bo‘yicha ajralish farqi.",
                   "LabGuide apparat yo‘nalishlaridagi ma’lumotnoma kartasi (toksikologiya). Sxema — aniq model emas."],
        },
        pinned={
            "en": ("Notes: this is a schematic general-principle video; real instruments and methods differ. The "
                   "chromatogram and spectrum are examples, not results. Narration is English synthetic speech. The "
                   "content is awaiting expert review — corrections are welcome."),
            "ru": ("Заметки: это схематичное видео об общем принципе; реальные приборы и методики различаются. "
                   "Хроматограмма и спектр — примеры, а не результаты. Озвучка — синтезированная английская речь. "
                   "Материал ждёт экспертной проверки, поправки приветствуются."),
            "uz": ("Eslatma: bu umumiy tamoyil haqidagi sxematik video; haqiqiy apparatlar va metodikalar farq qiladi. "
                   "Xromatogramma va spektr — misollar, natijalar emas. Diktor ovozi — sun’iy inglizcha nutq. "
                   "Material mutaxassis ko‘rigini kutmoqda — tuzatishlar uchun rahmat."),
        },
        keywords={
            "en": ["GC-MS", "gas chromatography mass spectrometry", "mass spectrometer", "chromatogram", "mass spectrum",
                   "retention time", "toxicology laboratory", "analytical chemistry", "LabGuide"],
            "ru": ["ГХ-МС", "хромато-масс-спектрометрия", "масс-спектрометр", "хроматограмма", "масс-спектр",
                   "токсикология", "лаборант"],
            "uz": ["GC-MS", "xromato-mass-spektrometriya", "mass-spektrometr", "xromatogramma", "mass-spektr",
                   "toksikologiya", "laborant"],
        },
        hashtags_topic={
            "en": ["#GCMS", "#MassSpectrometry", "#Chromatography", "#Toxicology", "#AnalyticalChemistry",
                   "#LabInstruments", "#MassSpec"],
            "ru": ["#ГХМС", "#массспектрометрия", "#хроматография", "#токсикология", "#аналитическаяхимия",
                   "#приборылаборатории", "#масспектр"],
            "uz": ["#GCMS", "#massspektrometriya", "#xromatografiya", "#toksikologiya", "#analitikkimyo",
                   "#laboratoriyaapparatlari", "#massspektr"],
        },
        thumb_alt=None,
        chapters=None,
        sources=[],
        evidence=["docs/video/gc_ms/CLAIMS_AND_EVIDENCE.md (when it exists)", "docs/video/lessons/01_gc_ms.md",
                  "assets/instruments/catalog.json lab card a3-tox-gc-ms"],
        next=["real_time_pcr", "photometry"],
        paid=None,
        internal=["Drafted from lesson 01 and the lab-card facts. Re-check against the final lines.en.json; keep every "
                  "statement tagged SOURCED or \"general principle\" as in the claims table. The app's lab card is itself flagged NEEDS_REVIEW (expert_reviewed=false, docs/lab_cards_status.json) and says so: do not call it \"verified\" or \"reviewed\"."],
    ),
    # ------------------------------------------------------------------ 6. real_time_pcr
    dict(
        id="real_time_pcr", order=6, tier="free", verified=False,
        path=T("Lab → Instruments → Real-time PCR", "Лаб. → Приборы → ПЦР в реальном времени",
               "Lab → Apparatlar → Real vaqt PCR"),
        title=T(
            "Real-Time PCR Explained: Thermal Cycler, Fluorescence, Cq",
            "ПЦР в реальном времени: термоциклер, флуоресценция, Cq",
            "Real vaqt PCR: termosiklator, fluoressensiya va Cq",
        ),
        hook={
            "en": ("Each PCR cycle copies the target — and a real-time instrument reads the fluorescence every cycle.",
                   "A schematic walk-through of the thermal cycler, the amplification curve and Cq."),
            "ru": ("Каждый цикл ПЦР копирует мишень, а прибор в реальном времени считывает флуоресценцию в каждом цикле.",
                   "Схематичный разбор термоциклера, кривой амплификации и Cq."),
            "uz": ("PCR ning har sikli nishonni nusxalaydi, real vaqt asbobi esa har siklda fluoressensiyani o‘qiydi.",
                   "Termosiklator, kuchayish egri chizig‘i va Cq ning sxemali tahlili."),
        },
        shows={
            "en": ["The parts of a real-time PCR instrument and the fluorescence signal path (schematic).",
                   "One cycle in three steps: strand separation, primer binding, synthesis — and the target multiplying.",
                   "The amplification curve, the threshold and Cq."],
            "ru": ["Части прибора для ПЦР в реальном времени и путь флуоресцентного сигнала (схема).",
                   "Один цикл в три шага: разделение цепей, посадка праймеров, синтез — и умножение мишени.",
                   "Кривая амплификации, порог и Cq."],
            "uz": ["Real vaqt PCR asbobining qismlari va fluoressent signal yo‘li (sxema).",
                   "Bitta sikl uch bosqichda: zanjirlarning ajralishi, praymer birikishi, sintez — va nishonning ko‘payishi.",
                   "Kuchayish egri chizig‘i, chegara va Cq."],
        },
        app={
            "en": ["LabGuide has reference cards for real-time PCR (the platform and the method) in the instrument "
                   "directions, with an original schematic illustration (not an exact model).",
                   "They are reference material: no lab protocol, no result interpretation and no clinical advice."],
            "ru": ["В LabGuide есть справочные карточки по ПЦР в реальном времени (платформа и метод) в направлениях "
                   "приборов, с оригинальным схематичным рисунком (не конкретная модель).",
                   "Это справочный материал: не протокол лаборатории, не интерпретация результатов и не "
                   "клиническая рекомендация."],
            "uz": ["LabGuide’da apparat yo‘nalishlarida real vaqt PCR bo‘yicha ma’lumotnoma kartalari (platforma va "
                   "metod) bor, original sxematik rasm bilan (aniq model emas).",
                   "Bu ma’lumotnoma: laboratoriya protokoli, natijalarni talqin qilish yoki klinik maslahat emas."],
        },
        limits={
            "en": ["Schematic illustration — not an exact instrument model; real systems differ by manufacturer.",
                   "Curves shown are examples, not real results; thresholds and interpretation follow the assay IFU "
                   "and your SOP."],
            "ru": ["Схема — не конкретная модель прибора; реальные системы различаются по производителям.",
                   "Показанные кривые — примеры, а не реальные результаты; пороги и интерпретацию определяют "
                   "IFU набора и ваша СОП."],
            "uz": ["Sxematik tasvir — aniq apparat modeli emas; haqiqiy tizimlar ishlab chiqaruvchiga qarab farq qiladi.",
                   "Ko‘rsatilgan egri chiziqlar — misollar, haqiqiy natijalar emas; chegaralar va talqin to‘plam "
                   "IFU’si va SOP’ingizga bog‘liq."],
        },
        ig={
            "en": ["Each PCR cycle copies the target — and a real-time instrument reads the fluorescence every cycle.",
                   "A schematic walk-through: the thermal cycler, one cycle in three steps, the amplification curve, "
                   "the threshold and Cq.",
                   "Reference cards in LabGuide’s instrument directions. Schematic — not an exact model."],
            "ru": ["Каждый цикл ПЦР копирует мишень, а прибор в реальном времени считывает флуоресценцию в каждом цикле.",
                   "Схематичный разбор: термоциклер, один цикл в три шага, кривая амплификации, порог и Cq.",
                   "Справочные карточки в направлениях приборов LabGuide. Схема — не конкретная модель."],
            "uz": ["PCR ning har sikli nishonni nusxalaydi, real vaqt asbobi esa har siklda fluoressensiyani o‘qiydi.",
                   "Sxemali tahlil: termosiklator, uch bosqichli bitta sikl, kuchayish egri chizig‘i, chegara va Cq.",
                   "LabGuide apparat yo‘nalishlaridagi ma’lumotnoma kartalari. Sxema — aniq model emas."],
        },
        pinned={
            "en": ("Notes: this is a schematic general-principle video, not an assay protocol. Curves are examples, not "
                   "results; thresholds and interpretation follow the assay IFU and your lab’s SOP. Narration is English "
                   "synthetic speech. The content is awaiting expert review — corrections are welcome."),
            "ru": ("Заметки: это схематичное видео об общем принципе, а не протокол анализа. Кривые — примеры, а не "
                   "результаты; пороги и интерпретацию определяют IFU набора и СОП вашей лаборатории. Озвучка — "
                   "синтезированная английская речь. Материал ждёт экспертной проверки, поправки приветствуются."),
            "uz": ("Eslatma: bu umumiy tamoyil haqidagi sxematik video, tahlil protokoli emas. Egri chiziqlar — "
                   "misollar, natijalar emas; chegaralar va talqin to‘plam IFU’si va laboratoriyangiz SOP’iga "
                   "bog‘liq. Diktor ovozi — sun’iy inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda."),
        },
        keywords={
            "en": ["real-time PCR", "qPCR", "thermal cycler", "amplification curve", "Cq", "fluorescence detection",
                   "molecular diagnostics laboratory", "PCR explained", "LabGuide"],
            "ru": ["ПЦР в реальном времени", "qПЦР", "термоциклер", "кривая амплификации", "Cq", "флуоресценция",
                   "молекулярная диагностика", "лаборант"],
            "uz": ["real vaqt PCR", "qPCR", "termosiklator", "kuchayish egri chizig‘i", "Cq", "fluoressensiya",
                   "molekulyar diagnostika", "laborant"],
        },
        hashtags_topic={
            "en": ["#PCR", "#RealTimePCR", "#qPCR", "#MolecularBiology", "#MolecularDiagnostics", "#ThermalCycler",
                   "#Cq"],
            "ru": ["#ПЦР", "#qПЦР", "#молекулярнаябиология", "#молекулярнаядиагностика", "#термоциклер",
                   "#амплификация", "#Cq"],
            "uz": ["#PCR", "#realvaqtPCR", "#qPCR", "#molekulyarbiologiya", "#molekulyardiagnostika",
                   "#termosiklator", "#Cq"],
        },
        thumb_alt=None,
        chapters=None,
        sources=[],
        evidence=["docs/video/real_time_pcr/CLAIMS_AND_EVIDENCE.md (when it exists)",
                  "docs/video/lessons/04_real_time_pcr.md",
                  "assets/instruments/catalog.json lab cards a3-mol-realtime-pcr-platform, a1-realtime-pcr-method"],
        next=["gc_ms", "osmometry"],
        paid=None,
        internal=["Drafted from lesson 04 and the lab-card facts. Re-check against the final lines.en.json. Do not "
                  "mention any specific assay (e.g. HIV viral load) unless the video shows it. The app's lab card is itself flagged NEEDS_REVIEW (expert_reviewed=false, docs/lab_cards_status.json) and says so: do not call it \"verified\" or \"reviewed\"."],
    ),
    # ------------------------------------------------------------------ 7. osmometry
    dict(
        id="osmometry", order=7, tier="free", verified=False,
        path=T("Lab → Instruments → Osmometer", "Лаб. → Приборы → Осмометр", "Lab → Apparatlar → Osmometr"),
        title=T(
            "Osmometry Explained: Freezing-Point Osmometer and Osmolality",
            "Осмометрия: криоскопический осмометр и осмоляльность",
            "Osmometriya: muzlash nuqtasi osmometri va osmolyallik",
        ),
        hook={
            "en": ("Dissolved particles lower the freezing point — and that is how a freezing-point osmometer measures osmolality.",
                   "Supercooling, freezing and the plateau, on a schematic."),
            "ru": ("Растворённые частицы понижают точку замерзания — так криоскопический осмометр измеряет осмоляльность.",
                   "Переохлаждение, замерзание и плато — на схеме."),
            "uz": ("Erigan zarralar muzlash nuqtasini pasaytiradi — muzlash nuqtasi osmometri osmolyallikni shunday o‘lchaydi.",
                   "O‘ta sovutish, muzlash va plato — sxemada."),
        },
        shows={
            "en": ["The five numbered parts of a freezing-point osmometer (schematic).",
                   "Supercooling, the start of freezing and the plateau, and why osmolality is measured.",
                   "Factors that can distort the result, as listed in the sources."],
            "ru": ["Пять пронумерованных частей криоскопического осмометра (схема).",
                   "Переохлаждение, начало замерзания и плато, и зачем измеряют осмоляльность.",
                   "Факторы, которые могут исказить результат, — по источникам."],
            "uz": ["Muzlash nuqtasi osmometrining beshta raqamlangan qismi (sxema).",
                   "O‘ta sovutish, muzlashning boshlanishi va plato hamda osmolyallik nega o‘lchanadi.",
                   "Natijani buzishi mumkin bo‘lgan omillar — manbalar bo‘yicha."],
        },
        app={
            "en": ["LabGuide has an osmometer reference card in the instrument directions with an original schematic "
                   "illustration (not an exact model).",
                   "Its calculators include osmolality: it computes only from the values you enter and shows the "
                   "formula, the limitations and the source. It does not measure anything."],
            "ru": ["В LabGuide есть справочная карточка осмометра в направлениях приборов с оригинальным "
                   "схематичным рисунком (не конкретная модель).",
                   "Среди калькуляторов есть осмоляльность: он считает только по введённым вами значениям и "
                   "показывает формулу, ограничения и источник. Ничего не измеряет."],
            "uz": ["LabGuide’da apparat yo‘nalishlarida osmometr bo‘yicha ma’lumotnoma kartasi bor, original "
                   "sxematik rasm bilan (aniq model emas).",
                   "Kalkulyatorlari orasida osmolyallik bor: u faqat siz kiritgan qiymatlardan hisoblaydi, formula, "
                   "cheklovlar va manbani ko‘rsatadi. Hech narsani o‘lchamaydi."],
        },
        limits={
            "en": ["Schematic illustration — not an exact instrument model.",
                   "A calculated osmolality is not a measured osmolality. Interpretation belongs to the clinician and "
                   "your laboratory’s reference intervals."],
            "ru": ["Схема — не конкретная модель прибора.",
                   "Расчётная осмоляльность — не измеренная осмоляльность. Интерпретация — за врачом и референтными "
                   "интервалами вашей лаборатории."],
            "uz": ["Sxematik tasvir — aniq apparat modeli emas.",
                   "Hisoblangan osmolyallik o‘lchangan osmolyallik emas. Talqin — shifokor va laboratoriyangizning "
                   "me’yor oraliqlari ishi."],
        },
        ig={
            "en": ["Dissolved particles lower the freezing point — that is how a freezing-point osmometer measures osmolality.",
                   "A schematic walk-through: supercooling, freezing, the plateau, and what can distort the result.",
                   "Osmometer reference card and an osmolality calculator in LabGuide (calculated from your inputs; "
                   "it measures nothing)."],
            "ru": ["Растворённые частицы понижают точку замерзания — так криоскопический осмометр измеряет осмоляльность.",
                   "Схематичный разбор: переохлаждение, замерзание, плато и что может исказить результат.",
                   "Карточка осмометра и калькулятор осмоляльности в LabGuide (считает по вашим данным; ничего "
                   "не измеряет)."],
            "uz": ["Erigan zarralar muzlash nuqtasini pasaytiradi — osmometr osmolyallikni shunday o‘lchaydi.",
                   "Sxemali tahlil: o‘ta sovutish, muzlash, plato va natijani nima buzishi mumkin.",
                   "LabGuide’da osmometr kartasi va osmolyallik kalkulyatori (siz kiritganlardan hisoblaydi; "
                   "hech narsani o‘lchamaydi)."],
        },
        pinned={
            "en": ("Notes: this is a schematic general-principle video, not a method protocol. A calculated osmolality "
                   "is not a measured one, and neither is interpreted here. Narration is English synthetic speech. The "
                   "content is awaiting expert review — corrections are welcome."),
            "ru": ("Заметки: это схематичное видео об общем принципе, а не протокол метода. Расчётная осмоляльность — "
                   "не измеренная, и ни одна из них здесь не интерпретируется. Озвучка — синтезированная английская "
                   "речь. Материал ждёт экспертной проверки, поправки приветствуются."),
            "uz": ("Eslatma: bu umumiy tamoyil haqidagi sxematik video, metod protokoli emas. Hisoblangan osmolyallik "
                   "o‘lchangan emas va bu yerda ikkalasi ham talqin qilinmaydi. Diktor ovozi — sun’iy inglizcha "
                   "nutq. Material mutaxassis ko‘rigini kutmoqda — tuzatishlar uchun rahmat."),
        },
        keywords={
            "en": ["osmometry", "osmometer", "osmolality", "freezing point depression", "supercooling",
                   "clinical chemistry", "laboratory instruments", "LabGuide"],
            "ru": ["осмометрия", "осмометр", "осмоляльность", "криоскопия", "понижение точки замерзания",
                   "клиническая лаборатория", "лаборант"],
            "uz": ["osmometriya", "osmometr", "osmolyallik", "muzlash nuqtasi pasayishi", "klinik laboratoriya",
                   "laborant"],
        },
        hashtags_topic={
            "en": ["#Osmometry", "#Osmolality", "#Osmometer", "#ClinicalChemistry", "#FreezingPoint",
                   "#LabInstruments", "#BiochemistryLab"],
            "ru": ["#осмометрия", "#осмоляльность", "#осмометр", "#биохимия", "#криоскопия",
                   "#приборылаборатории", "#лабораторныйанализ"],
            "uz": ["#osmometriya", "#osmolyallik", "#osmometr", "#biokimyo", "#muzlashnuqtasi",
                   "#laboratoriyaapparatlari", "#laboratoriyatahlili"],
        },
        thumb_alt=None,
        chapters=None,
        sources=[],
        evidence=["docs/video/osmometry/CLAIMS_AND_EVIDENCE.md (when it exists)",
                  "docs/video/lessons/24_osmometer.md", "assets/instruments/catalog.json lab card a3-bio-osmometer",
                  "docs/VIDEO_FEATURE_INVENTORY.md §1 (calculators: osmolality)"],
        next=["calculators", "photometry"],
        paid=None,
        internal=["Drafted from lesson 24, the lab-card facts and the calculator list. If the final video does not show "
                  "the osmolality calculator, delete the second app bullet and the last IG line. The app's lab card is itself flagged NEEDS_REVIEW (expert_reviewed=false, docs/lab_cards_status.json) and says so: do not call it \"verified\" or \"reviewed\"."],
    ),
    # ------------------------------------------------------------------ 8. calculators
    dict(
        id="calculators", order=8, tier="free", verified=False,
        path=T("Lab → Calculators", "Лаб. → Калькуляторы", "Lab → Kalkulyatorlar"),
        title=T(
            "Lab Calculators in LabGuide: eGFR, Anion Gap, Dilution and More",
            "Калькуляторы LabGuide: СКФ, анионный интервал, разведение и другие",
            "LabGuide kalkulyatorlari: eGFR, anion oralig‘i va suyultirish",
        ),
        hook={
            "en": ("Enter the values, get the result — with the formula, the limits and the source shown.",
                   "A quick tour of the calculators in LabGuide."),
            "ru": ("Введите значения — получите результат, с формулой, ограничениями и источником.",
                   "Быстрый обзор калькуляторов LabGuide."),
            "uz": ("Qiymatlarni kiriting — natijani oling, formula, cheklovlar va manba bilan.",
                   "LabGuide kalkulyatorlariga tezkor sayohat."),
        },
        shows={
            "en": ["Where the calculators live in LabGuide and how to open one.",
                   "Entering values, choosing SI or conventional units, and reading the result next to its formula, "
                   "limitations and source.",
                   "Examples such as eGFR, anion gap, corrected calcium, dilution and the bench calculators (illustrative inputs)."],
            "ru": ["Где в LabGuide находятся калькуляторы и как открыть нужный.",
                   "Ввод значений, выбор единиц СИ или традиционных и чтение результата рядом с формулой, "
                   "ограничениями и источником.",
                   "Примеры: СКФ, анионный интервал, скорректированный кальций, разведение и лабораторные "
                   "калькуляторы (иллюстративные данные)."],
            "uz": ["LabGuide’da kalkulyatorlar qayerda va qanday ochiladi.",
                   "Qiymatlarni kiritish, SI yoki an’anaviy birliklarni tanlash va natijani formula, cheklovlar va "
                   "manba yonida o‘qish.",
                   "Misollar: eGFR, anion oralig‘i, tuzatilgan kalsiy, suyultirish va laboratoriya kalkulyatorlari "
                   "(namunaviy kiritishlar)."],
        },
        app={
            "en": ["Calculators compute only from the values you enter; each shows its formula, limitations and source.",
                   "Units: SI (mmol/L, µmol/L) or conventional (mg/dL), chosen in Profile.",
                   "LabGuide does not interpret results, make a diagnosis or suggest drug doses. Works offline and "
                   "without an account."],
            "ru": ["Калькуляторы считают только по введённым вами значениям; у каждого есть формула, ограничения и источник.",
                   "Единицы: СИ (ммоль/л, мкмоль/л) или традиционные (мг/дл) — выбираются в Профиле.",
                   "LabGuide не интерпретирует результаты, не ставит диагноз и не предлагает дозы препаратов. "
                   "Работает без интернета и без аккаунта."],
            "uz": ["Kalkulyatorlar faqat siz kiritgan qiymatlardan hisoblaydi; har birida formula, cheklovlar va manba bor.",
                   "Birliklar: SI (mmol/L, µmol/L) yoki an’anaviy (mg/dL) — Profilda tanlanadi.",
                   "LabGuide natijalarni talqin qilmaydi, tashxis qo‘ymaydi va dori dozasini taklif qilmaydi. "
                   "Internetsiz va hisobsiz ishlaydi."],
        },
        limits={
            "en": ["All inputs in the video are illustrative, not patient data.",
                   "A calculated value is only as good as the inputs and the formula’s limits; reference intervals come "
                   "from your laboratory."],
            "ru": ["Все вводимые в видео значения иллюстративные, это не данные пациентов.",
                   "Расчётное значение настолько хорошо, насколько хороши входные данные и пределы применимости "
                   "формулы; референтные интервалы — из вашей лаборатории."],
            "uz": ["Videodagi barcha kiritishlar namunaviy, bemor ma’lumoti emas.",
                   "Hisoblangan qiymat kiritilgan ma’lumot va formula chegaralari qanchalik yaxshi bo‘lsa, shunchalik "
                   "ishonchli; me’yor oraliqlari laboratoriyangizdan olinadi."],
        },
        ig={
            "en": ["Enter the values, get the result — with the formula, the limits and the source shown.",
                   "A quick tour of the calculators in LabGuide: from eGFR and anion gap to dilution and the bench "
                   "calculators, in SI or conventional units, offline.",
                   "They compute only from what you enter and don’t interpret results. Find them in Lab → Calculators."],
            "ru": ["Введите значения — получите результат, с формулой, ограничениями и источником.",
                   "Быстрый обзор калькуляторов LabGuide: от СКФ и анионного интервала до разведения и лабораторных "
                   "калькуляторов, в единицах СИ или традиционных, без интернета.",
                   "Они считают только по введённым данным и не интерпретируют результаты. Раздел: Лаб. → Калькуляторы."],
            "uz": ["Qiymatlarni kiriting — natijani oling, formula, cheklovlar va manba bilan.",
                   "LabGuide kalkulyatorlariga tezkor sayohat: eGFR va anion oralig‘idan suyultirish va laboratoriya "
                   "kalkulyatorlarigacha, SI yoki an’anaviy birliklarda, internetsiz.",
                   "Ular faqat siz kiritganlardan hisoblaydi va natijalarni talqin qilmaydi. Bo‘lim: Lab → Kalkulyatorlar."],
        },
        pinned={
            "en": ("Notes: all inputs in this video are illustrative, not patient data. Calculators do not interpret "
                   "results; reference intervals come from your laboratory. Narration is English synthetic speech. The "
                   "content is awaiting expert review — corrections are welcome. Which calculator is missing for you?"),
            "ru": ("Заметки: все вводимые в видео значения иллюстративные, это не данные пациентов. Калькуляторы не "
                   "интерпретируют результаты; референтные интервалы берут из вашей лаборатории. Озвучка — "
                   "синтезированная английская речь. Материал ждёт экспертной проверки, поправки приветствуются. "
                   "Какого калькулятора вам не хватает?"),
            "uz": ("Eslatma: videodagi barcha kiritishlar namunaviy, bemor ma’lumoti emas. Kalkulyatorlar natijalarni "
                   "talqin qilmaydi; me’yor oraliqlari laboratoriyangizdan olinadi. Diktor ovozi — sun’iy inglizcha "
                   "nutq. Material mutaxassis ko‘rigini kutmoqda. Sizga qaysi kalkulyator yetishmaydi?"),
        },
        keywords={
            "en": ["lab calculators", "clinical calculators", "eGFR calculator", "anion gap", "corrected calcium",
                   "dilution calculator", "unit converter", "SI units", "clinical chemistry", "LabGuide"],
            "ru": ["лабораторные калькуляторы", "клинические калькуляторы", "СКФ", "анионный интервал",
                   "скорректированный кальций", "разведение", "лаборант"],
            "uz": ["laboratoriya kalkulyatorlari", "klinik kalkulyatorlar", "eGFR", "anion oralig‘i",
                   "tuzatilgan kalsiy", "suyultirish", "laborant"],
        },
        hashtags_topic={
            "en": ["#eGFR", "#AnionGap", "#LabCalculator", "#ClinicalChemistry", "#Dilution", "#SIUnits",
                   "#LabMath"],
            "ru": ["#СКФ", "#анионныйинтервал", "#калькулятор", "#биохимия", "#разведение", "#единицыСИ",
                   "#лабораторныйрасчёт"],
            "uz": ["#eGFR", "#anionoraligi", "#kalkulyator", "#biokimyo", "#suyultirish", "#SIbirliklari",
                   "#laboratoriyahisobi"],
        },
        thumb_alt=None,
        chapters=None,
        sources=[],
        evidence=["docs/video/calculators/CLAIMS_AND_EVIDENCE.md (when it exists)", "docs/video/04_kalkulyatorlar.md",
                  "docs/VIDEO_FEATURE_INVENTORY.md §1 (calculators)", "docs/store/APP_STORE.md §4 (description)"],
        next=["osmometry", "leukocyte"],
        paid=None,
        internal=["Free today. Do not state a number of calculators unless the video does and the count was re-checked "
                  "in the build being advertised (the inventory counted 17 on 2026-10-25)."],
    ),
    # ------------------------------------------------------------------ 9. exam_simulation (paid)
    dict(
        id="exam_simulation", order=9, tier="paid", verified=False,
        path=T("Learn → Exam simulation (Student Pro)", "Обучение → Симуляция экзамена (Студент Pro)",
               "O‘rganish → Imtihon simulyatsiyasi (Talaba Pro)"),
        title=T(
            "Exam-Style Practice in LabGuide: Timed, Balanced, No Going Back",
            "Тренировка экзамена в LabGuide: таймер, баланс тем, без возврата",
            "LabGuide’da imtihondagidek mashq: vaqt, balans, orqaga qaytishsiz",
        ),
        hook={
            "en": ("Practice the way an exam feels: a fixed time, a pass mark and no going back.",
                   "A look at Exam simulation in LabGuide’s Student Pro."),
            "ru": ("Тренируйтесь так, как проходит экзамен: ограничение по времени, проходной балл и без возврата.",
                   "Обзор «Симуляции экзамена» в LabGuide Студент Pro."),
            "uz": ("Imtihondagidek mashq qiling: belgilangan vaqt, o‘tish bali va orqaga qaytmasdan.",
                   "LabGuide Talaba Pro’dagi imtihon simulyatsiyasiga nazar."),
        },
        shows={
            "en": ["Setting up an exam simulation: a required time limit and pass mark, questions drawn in proportion "
                   "from all topics.",
                   "Taking it: one question after another, with no question map, no marking and no going back.",
                   "The report: pass or fail, total time, average time per question, the five longest questions, topics "
                   "and the change against the previous simulation."],
            "ru": ["Настройка симуляции: обязательные лимит времени и проходной балл, вопросы пропорционально из всех тем.",
                   "Прохождение: вопрос за вопросом, без карты вопросов, без пометок и без возврата.",
                   "Отчёт: сдал или не сдал, общее время, среднее время на вопрос, пять самых долгих вопросов, "
                   "темы и динамика относительно прошлой симуляции."],
            "uz": ["Simulyatsiyani sozlash: majburiy vaqt chegarasi va o‘tish bali, savollar barcha mavzulardan "
                   "mutanosib tanlanadi.",
                   "Topshirish: savol ketidan savol, savollar xaritasisiz, belgilashsiz va orqaga qaytmasdan.",
                   "Hisobot: o‘tdi yoki o‘tmadi, umumiy vaqt, bir savolga o‘rtacha vaqt, eng uzoq beshta savol, "
                   "mavzular va oldingi simulyatsiyaga nisbatan o‘zgarish."],
        },
        app={
            "en": ["Exam simulation is a Pro feature of the Student Pro plan (and Premium). The existing free Exam mode and "
                   "the category test stay free and unchanged.",
                   "A practice result is feedback for you, not an official grade or a real exam result."],
            "ru": ["Симуляция экзамена — функция Pro в плане Студент Pro (и Premium). Существующие бесплатный режим "
                   "экзамена и тест категории остаются бесплатными и без изменений.",
                   "Результат тренировки — обратная связь для вас, а не официальная оценка и не результат "
                   "настоящего экзамена."],
            "uz": ["Imtihon simulyatsiyasi — Talaba Pro rejasining (va Premium’ning) Pro imkoniyati. Mavjud bepul "
                   "imtihon rejimi va toifa testi bepul va o‘zgarishsiz qoladi.",
                   "Mashq natijasi — siz uchun fikr-mulohaza, rasmiy baho yoki haqiqiy imtihon natijasi emas."],
        },
        limits={
            "en": ["Questions come from the app’s question banks; the simulation does not copy any real exam."],
            "ru": ["Вопросы берутся из банков вопросов приложения; симуляция не копирует никакой настоящий экзамен."],
            "uz": ["Savollar ilovaning savollar banklaridan olinadi; simulyatsiya hech qanday haqiqiy imtihondan nusxa olmaydi."],
        },
        ig={
            "en": ["Practice the way an exam feels: a fixed time, a pass mark and no going back.",
                   "Exam simulation in LabGuide’s Student Pro: questions drawn in proportion from all topics, one after "
                   "another, then a report with total time, time per question and topics.",
                   "A practice result is feedback for you, not an official grade."],
            "ru": ["Тренируйтесь так, как проходит экзамен: ограничение по времени, проходной балл и без возврата.",
                   "Симуляция экзамена в LabGuide Студент Pro: вопросы пропорционально из всех тем, один за другим, "
                   "затем отчёт с общим временем, временем на вопрос и темами.",
                   "Результат тренировки — обратная связь для вас, а не официальная оценка."],
            "uz": ["Imtihondagidek mashq qiling: belgilangan vaqt, o‘tish bali va orqaga qaytmasdan.",
                   "LabGuide Talaba Pro’da imtihon simulyatsiyasi: savollar barcha mavzulardan mutanosib, birin-ketin, "
                   "so‘ng umumiy vaqt, bir savolga vaqt va mavzular bilan hisobot.",
                   "Mashq natijasi — siz uchun fikr-mulohaza, rasmiy baho emas."],
        },
        pinned={
            "en": ("Notes: exam simulation is practice, not an official exam or grade. Narration is English synthetic "
                   "speech. The content is awaiting expert review — corrections are welcome. What would make a practice "
                   "exam more useful for you?"),
            "ru": ("Заметки: симуляция экзамена — это тренировка, а не официальный экзамен и не оценка. Озвучка — "
                   "синтезированная английская речь. Материал ждёт экспертной проверки, поправки приветствуются. "
                   "Что сделало бы тренировочный экзамен полезнее для вас?"),
            "uz": ("Eslatma: imtihon simulyatsiyasi — mashq, rasmiy imtihon yoki baho emas. Diktor ovozi — sun’iy "
                   "inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda — tuzatishlar uchun rahmat. Mashq "
                   "imtihoni siz uchun nima bilan foydaliroq bo‘lardi?"),
        },
        keywords={
            "en": ["exam simulation", "exam practice", "timed test", "medical laboratory students", "study app",
                   "LabGuide Student Pro", "LabGuide"],
            "ru": ["симуляция экзамена", "тренировочный экзамен", "тест с таймером", "студенты медколледжа",
                   "приложение для учёбы", "LabGuide Студент Pro"],
            "uz": ["imtihon simulyatsiyasi", "mashq imtihoni", "vaqtli test", "tibbiyot talabalari",
                   "o‘quv ilovasi", "LabGuide Talaba Pro"],
        },
        hashtags_topic={
            "en": ["#ExamPrep", "#StudyTips", "#MedicalStudents", "#ExamSimulation", "#LabStudents", "#StudyApp",
                   "#ExamPractice"],
            "ru": ["#подготовкакэкзамену", "#студентымедики", "#симуляцияэкзамена", "#учёба", "#тестыонлайн",
                   "#экзамен", "#медколледж"],
            "uz": ["#imtihonaytayyorgarlik", "#tibbiyottalabalari", "#imtihonsimulyatsiyasi", "#oqish",
                   "#testlar", "#imtihon", "#tibbiyotkolleji"],
        },
        thumb_alt=None,
        chapters=None,
        sources=[],
        evidence=["docs/video/exam_simulation/CLAIMS_AND_EVIDENCE.md (when it exists)",
                  "docs/TIERS_FEATURE_MAP.md §1 (examSimulation: BUILT_AND_TESTED on paid/feat, flag off)",
                  "docs/DECISIONS.md D-77, D-78", "docs/PAID_BRANCH_STATUS.md"],
        next=["premium_overview", "teacher_pro"],
        paid={
            "plans": "Student Pro (and Premium)",
            "status": "Built and tested only with a fake store and fake server on the paid branch; flags off; "
                      "store products unconfirmed; no real sandbox purchase ever run.",
        },
        internal=["Public text says what the feature does; the paid line is appended automatically. Do not publish "
                  "before the paid build is live (gate GP) and before the owner confirms the plan names and the trial.",
                  "Free Exam mode and the category test (toifa) are unchanged and free: never say \"unlock exams\"."],
    ),
    # ------------------------------------------------------------------ 10. teacher_pro (paid)
    dict(
        id="teacher_pro", order=10, tier="paid", verified=False,
        path=T("Learn → Groups (Teacher Pro)", "Обучение → Группы (Преподаватель Pro)",
               "O‘rganish → Guruhlar (Ustoz Pro)"),
        title=T(
            "Teacher Pro in LabGuide: Build a Test, Assign It, Review Results",
            "Преподаватель Pro: свой тест, назначение и результаты в LabGuide",
            "LabGuide Ustoz Pro: test yarating, biriktiring, natijalarni ko‘ring",
        ),
        hook={
            "en": ("Write your own questions, give the test to a group, see who answered what.",
                   "A look at Teacher Pro in LabGuide."),
            "ru": ("Напишите свои вопросы, дайте тест группе и посмотрите, кто как ответил.",
                   "Обзор LabGuide Преподаватель Pro."),
            "uz": ("O‘z savollaringizni yozing, testni guruhga bering va kim nima javob berganini ko‘ring.",
                   "LabGuide Ustoz Pro ga nazar."),
        },
        shows={
            "en": ["Building a test from your own questions (several options, one correct answer, optional explanation) "
                   "or from copies of questions in the app.",
                   "Assigning it to a whole group or to one student, with a deadline and a number of attempts.",
                   "Results by student and by question, the questions most often missed, and a CSV export."],
            "ru": ["Создание теста из собственных вопросов (несколько вариантов, один верный, необязательное пояснение) "
                   "или из копий вопросов приложения.",
                   "Назначение всей группе или одному студенту, со сроком и числом попыток.",
                   "Результаты по студентам и по вопросам, чаще всего ошибочные вопросы и экспорт в CSV."],
            "uz": ["O‘z savollaringizdan (bir nechta variant, bitta to‘g‘ri javob, ixtiyoriy izoh) yoki ilovadagi "
                   "savollar nusxasidan test yaratish.",
                   "Butun guruhga yoki bitta talabaga biriktirish, muddat va urinishlar soni bilan.",
                   "Talabalar va savollar kesimidagi natijalar, eng ko‘p xato qilingan savollar va CSV eksport."],
        },
        app={
            "en": ["Teacher Pro is a Pro feature of the Teacher Pro plan (and Premium). Today’s free groups and "
                   "assignments from the app’s own questions stay free.",
                   "It needs an account and an internet connection: tests, assignments and results are stored on "
                   "LabGuide’s server.",
                   "A teacher sees only the students who joined the group themselves, by a code or an invitation; "
                   "e-mail addresses are not shown."],
            "ru": ["Преподаватель Pro — функция Pro в плане Преподаватель Pro (и Premium). Сегодняшние бесплатные "
                   "группы и задания из вопросов приложения остаются бесплатными.",
                   "Нужны аккаунт и интернет: тесты, задания и результаты хранятся на сервере LabGuide.",
                   "Преподаватель видит только тех студентов, которые сами вступили в группу по коду или "
                   "приглашению; адреса электронной почты не показываются."],
            "uz": ["Ustoz Pro — Ustoz Pro rejasining (va Premium’ning) Pro imkoniyati. Bugungi bepul guruhlar va "
                   "ilovaning o‘z savollaridan topshiriqlar bepul qoladi.",
                   "Hisob va internet kerak: testlar, topshiriqlar va natijalar LabGuide serverida saqlanadi.",
                   "Ustoz faqat guruhga o‘zi kod yoki taklifnoma orqali qo‘shilgan talabalarni ko‘radi; "
                   "elektron pochta manzillari ko‘rsatilmaydi."],
        },
        limits={
            "en": ["Results export is CSV only; there is no PDF export for teacher results."],
            "ru": ["Экспорт результатов — только CSV; PDF-экспорта результатов преподавателя нет."],
            "uz": ["Natijalar eksporti faqat CSV; ustoz natijalari uchun PDF eksport yo‘q."],
        },
        ig={
            "en": ["Write your own questions, give the test to a group, see who answered what.",
                   "Teacher Pro in LabGuide: build a test (or copy questions from the app), assign it to a group or one "
                   "student with a deadline and attempts, then review results by student and by question.",
                   "Needs an account and an internet connection."],
            "ru": ["Напишите свои вопросы, дайте тест группе и посмотрите, кто как ответил.",
                   "Преподаватель Pro в LabGuide: создайте тест (или скопируйте вопросы из приложения), назначьте "
                   "группе или одному студенту со сроком и попытками, затем смотрите результаты по студентам и по "
                   "вопросам.",
                   "Нужны аккаунт и интернет."],
            "uz": ["O‘z savollaringizni yozing, testni guruhga bering va kim nima javob berganini ko‘ring.",
                   "LabGuide Ustoz Pro: test yarating (yoki ilovadan savollarni nusxalang), guruhga yoki bitta "
                   "talabaga muddat va urinishlar bilan biriktiring, so‘ng natijalarni talabalar va savollar "
                   "kesimida ko‘ring.",
                   "Hisob va internet kerak."],
        },
        pinned={
            "en": ("Notes: names and results shown are illustrative, not real students. A teacher sees only students who "
                   "joined the group themselves. Narration is English synthetic speech. The content is awaiting expert "
                   "review — corrections are welcome. What would you like to see in a teacher’s dashboard?"),
            "ru": ("Заметки: имена и результаты на экране иллюстративные, это не реальные студенты. Преподаватель "
                   "видит только тех студентов, которые сами вступили в группу. Озвучка — синтезированная "
                   "английская речь. Материал ждёт экспертной проверки, поправки приветствуются. "
                   "Что вы хотели бы видеть в панели преподавателя?"),
            "uz": ("Eslatma: ekrandagi ismlar va natijalar namunaviy, haqiqiy talabalar emas. Ustoz faqat guruhga o‘zi "
                   "qo‘shilgan talabalarni ko‘radi. Diktor ovozi — sun’iy inglizcha nutq. Material mutaxassis "
                   "ko‘rigini kutmoqda. Ustoz panelida nimani ko‘rishni istardingiz?"),
        },
        keywords={
            "en": ["teacher tools", "create a test", "assign test to students", "student results", "classroom app",
                   "medical education", "LabGuide Teacher Pro", "LabGuide"],
            "ru": ["инструменты преподавателя", "создать тест", "назначить тест", "результаты студентов",
                   "медицинское образование", "LabGuide Преподаватель Pro"],
            "uz": ["ustoz vositalari", "test yaratish", "talabaga test biriktirish", "talabalar natijalari",
                   "tibbiyot ta’limi", "LabGuide Ustoz Pro"],
        },
        hashtags_topic={
            "en": ["#TeacherTools", "#MedicalEducation", "#EdTech", "#TeachingTips", "#QuizMaker",
                   "#ClassroomTools", "#Teachers"],
            "ru": ["#инструментыпреподавателя", "#медицинскоеобразование", "#edtech", "#преподаватель",
                   "#тестыдлястудентов", "#учителям", "#колледж"],
            "uz": ["#ustozvositalari", "#tibbiyottalimi", "#edtech", "#ustoz", "#talabalargatest",
                   "#oqituvchilar", "#kollej"],
        },
        thumb_alt=None,
        chapters=None,
        sources=[],
        evidence=["docs/video/teacher_pro/CLAIMS_AND_EVIDENCE.md (when it exists)",
                  "docs/TEACHER_PRO_MAP.md (paid/teacher, merged into paid/pro-premium)",
                  "docs/DECISIONS.md D-77, D-78", "docs/PAID_BRANCH_STATUS.md",
                  "docs/VIDEO_FEATURE_INVENTORY.md §3 (groups need a server: no video without that wording)"],
        next=["premium_overview", "exam_simulation"],
        paid={
            "plans": "Teacher Pro (and Premium)",
            "status": "Built and tested only with a fake server on the paid branch (migration file only, nothing "
                      "deployed); flags off; store products unconfirmed.",
        },
        internal=["Open owner decision (docs/TEACHER_PRO_MAP.md §6.5): a student needs Student Pro to solve a teacher's "
                  "own-question test. Decide before publishing and add one honest line to the text if it applies.",
                  "Groups need a server and an account; the video must say so (inventory §3). Do not publish before the "
                  "paid build and the server are live (gate GP)."],
    ),
    # ------------------------------------------------------------------ 11. premium_overview (paid)
    dict(
        id="premium_overview", order=11, tier="paid", verified=False,
        path=T("Profile → Subscription", "Профиль → Подписка", "Profil → Obuna"),
        title=T(
            "LabGuide Plans: What Stays Free, What Pro and Premium Add",
            "Планы LabGuide: что остаётся бесплатным, что добавляют Pro и Premium",
            "LabGuide rejalari: nima bepul, Pro va Premium nima qo‘shadi",
        ),
        hook={
            "en": ("Everything that is free in LabGuide today stays free.",
                   "Here is what the optional Pro plans and Premium add on top."),
            "ru": ("Всё, что сегодня бесплатно в LabGuide, остаётся бесплатным.",
                   "А вот что добавляют сверху необязательные планы Pro и Premium."),
            "uz": ("LabGuide’da bugun bepul bo‘lgan hamma narsa bepul qoladi.",
                   "Ixtiyoriy Pro rejalari va Premium ustiga nimalarni qo‘shishi — mana."),
        },
        shows={
            "en": ["What is free: the Lab sections, atlases, calculators, calibration, QC, tests, results history, "
                   "groups and assignments — no daily limits.",
                   "Student Pro: exam simulation, results analytics, PDF and CSV export.",
                   "Teacher Pro: build your own tests, assign them, manage results.",
                   "Specialist Pro: export of the calibration log and a QC summary report.",
                   "Premium: all of the above together."],
            "ru": ["Что бесплатно: разделы Лаб., атласы, калькуляторы, калибровка, КК, тесты, история результатов, "
                   "группы и задания — без дневных лимитов.",
                   "Студент Pro: симуляция экзамена, аналитика результатов, экспорт в PDF и CSV.",
                   "Преподаватель Pro: свои тесты, назначение, управление результатами.",
                   "Специалист Pro: экспорт журнала калибровок и сводный отчёт КК.",
                   "Premium: всё перечисленное вместе."],
            "uz": ["Nima bepul: Lab bo‘limlari, atlaslar, kalkulyatorlar, kalibrlash, QC, testlar, natijalar tarixi, "
                   "guruhlar va topshiriqlar — kunlik limitsiz.",
                   "Talaba Pro: imtihon simulyatsiyasi, natijalar tahlili, PDF va CSV eksport.",
                   "Ustoz Pro: o‘z testlari, biriktirish, natijalarni boshqarish.",
                   "Mutaxassis Pro: kalibrlash jurnalini eksport qilish va QC xulosa hisoboti.",
                   "Premium: yuqoridagilarning hammasi birga."],
        },
        app={
            "en": ["After a 7-day trial or a subscription ends, only the paid features close; the free features and all "
                   "your data stay.",
                   "Plans are managed in Profile → Subscription, where you can also restore a purchase."],
            "ru": ["После окончания 7-дневного пробного периода или подписки закрываются только платные функции; "
                   "бесплатные функции и все ваши данные остаются.",
                   "Планами управляют в Профиль → Подписка, там же можно восстановить покупку."],
            "uz": ["7 kunlik sinov yoki obuna tugagach faqat pullik imkoniyatlar yopiladi; bepul imkoniyatlar va "
                   "barcha ma’lumotlaringiz qoladi.",
                   "Rejalar Profil → Obuna bo‘limida boshqariladi, xaridni tiklash ham shu yerda."],
        },
        limits={
            "en": ["No prices are shown here: they appear in the App Store / Google Play before you buy."],
            "ru": ["Цены здесь не показаны: они отображаются в App Store / Google Play до покупки."],
            "uz": ["Narxlar bu yerda ko‘rsatilmaydi: ular xariddan oldin App Store / Google Play’da ko‘rinadi."],
        },
        ig={
            "en": ["Everything that is free in LabGuide today stays free.",
                   "What the optional plans add: Student Pro (exam simulation, results analytics, export), Teacher Pro "
                   "(your own tests, assignments, results), Specialist Pro (calibration log export, QC summary report) "
                   "— and Premium, which is all of them together.",
                   "After a trial or a subscription ends, only paid features close; your data stays."],
            "ru": ["Всё, что сегодня бесплатно в LabGuide, остаётся бесплатным.",
                   "Что добавляют необязательные планы: Студент Pro (симуляция экзамена, аналитика результатов, "
                   "экспорт), Преподаватель Pro (свои тесты, задания, результаты), Специалист Pro (экспорт журнала "
                   "калибровок, сводный отчёт КК) — и Premium, где всё вместе.",
                   "После окончания пробного периода или подписки закрываются только платные функции; данные остаются."],
            "uz": ["LabGuide’da bugun bepul bo‘lgan hamma narsa bepul qoladi.",
                   "Ixtiyoriy rejalar nimani qo‘shadi: Talaba Pro (imtihon simulyatsiyasi, natijalar tahlili, "
                   "eksport), Ustoz Pro (o‘z testlari, topshiriqlar, natijalar), Mutaxassis Pro (kalibrlash "
                   "jurnalini eksport, QC xulosa hisoboti) — va Premium: hammasi birga.",
                   "Sinov yoki obuna tugagach faqat pullik imkoniyatlar yopiladi; ma’lumotlaringiz qoladi."],
        },
        pinned={
            "en": ("Notes: this video lists what each plan adds; it shows no prices (they appear in the store before "
                   "you buy). Features that are free today stay free. Narration is English synthetic speech. The content "
                   "is awaiting expert review — corrections are welcome. Which Pro feature would help you most?"),
            "ru": ("Заметки: в видео перечислено, что добавляет каждый план; цен нет (они показываются в магазине до "
                   "покупки). Функции, бесплатные сегодня, остаются бесплатными. Озвучка — синтезированная "
                   "английская речь. Материал ждёт экспертной проверки, поправки приветствуются. "
                   "Какая функция Pro помогла бы вам больше всего?"),
            "uz": ("Eslatma: videoda har bir reja nimani qo‘shishi sanab o‘tilgan; narxlar yo‘q (ular xariddan oldin "
                   "do‘konda ko‘rinadi). Bugun bepul imkoniyatlar bepul qoladi. Diktor ovozi — sun’iy inglizcha "
                   "nutq. Material mutaxassis ko‘rigini kutmoqda. Qaysi Pro imkoniyati sizga ko‘proq yordam beradi?"),
        },
        keywords={
            "en": ["LabGuide plans", "LabGuide Pro", "LabGuide Premium", "Student Pro", "Teacher Pro",
                   "Specialist Pro", "subscription", "free trial", "study app", "LabGuide"],
            "ru": ["планы LabGuide", "LabGuide Pro", "LabGuide Premium", "Студент Pro", "Преподаватель Pro",
                   "Специалист Pro", "подписка", "пробный период"],
            "uz": ["LabGuide rejalari", "LabGuide Pro", "LabGuide Premium", "Talaba Pro", "Ustoz Pro",
                   "Mutaxassis Pro", "obuna", "bepul sinov"],
        },
        hashtags_topic={
            "en": ["#ProPlan", "#Premium", "#StudyApp", "#FreeTrial", "#MedicalApp", "#EdTech", "#AppUpdate"],
            "ru": ["#ProПлан", "#Premium", "#приложениедляучёбы", "#пробныйпериод", "#медприложение",
                   "#edtech", "#обновление"],
            "uz": ["#ProReja", "#Premium", "#oquvilovasi", "#bepulsinov", "#tibbiyotilovasi", "#edtech",
                   "#yangilanish"],
        },
        thumb_alt=None,
        chapters=None,
        sources=[],
        evidence=["docs/video/premium_overview/CLAIMS_AND_EVIDENCE.md (when it exists)",
                  "docs/TIERS_FEATURE_MAP.md (built / not built per feature)", "docs/TEACHER_PRO_MAP.md",
                  "docs/DECISIONS.md D-77, D-78", "docs/PAID_BRANCH_STATUS.md",
                  "docs/store/APP_STORE.md §16 (plan names, trial and renewal wording)"],
        next=["exam_simulation", "teacher_pro"],
        paid={
            "plans": "Student Pro, Teacher Pro, Specialist Pro, Premium",
            "status": "Plans exist only on the local paid branch (flags off, nothing deployed, store products "
                      "unconfirmed, no real sandbox purchase ever run).",
        },
        internal=["List only features marked BUILT_AND_TESTED in docs/TIERS_FEATURE_MAP.md / docs/TEACHER_PRO_MAP.md at "
                  "the time of publishing; remove a bullet for anything not built or not shown.",
                  "No prices, no product ids, no store screenshot with a price. Trial wording: \"7-day free trial where "
                  "offered\" (the device-attestation piece is not written yet, so the trial button may not appear).",
                  "Publish last, and only when the paid build is live in the stores (gate GP)."],
    ),
]

# The lead's list called topic 3 "spectrophotometry"; the studio id is "photometry".
ALIASES = {"spectrophotometry": "photometry"}

BY_ID = {t["id"]: t for t in TOPICS}
IDS = [t["id"] for t in TOPICS]
