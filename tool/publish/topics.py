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
    # ------------------------------------------------------------------ 0. overview
    dict(
        id="overview", order=0, tier="free", verified=True,
        path=T("Home → your role", "Главный экран → ваша роль", "Bosh sahifa → rolingiz"),
        title=T(
            "LabGuide for the Lab Specialist, the Teacher and the Student",
            "LabGuide для специалиста лаборатории, преподавателя и студента",
            "LabGuide: mutaxassis, ustoz va talaba uchun",
        ),
        hook={
            "en": ("Reference ranges in a PDF. Formulas in a chat. A calculator in another app.",
                   "One app for the lab specialist, the teacher and the student — in Uzbek, Russian and English. A two-minute tour."),
            "ru": ("Референтные интервалы — в PDF. Формулы — в чате. Калькулятор — в другом приложении.",
                   "Одно приложение для специалиста лаборатории, преподавателя и студента — на узбекском, русском и английском. Обзор за две минуты."),
            "uz": ("Me’yor oraliqlari — PDF’da. Formulalar — chatda. Kalkulyator — boshqa ilovada.",
                   "Mutaxassis, ustoz va talaba uchun bitta ilova — o‘zbek, rus va ingliz tillarida. Ikki daqiqalik sayohat."),
        },
        shows={
            "en": ["What LabGuide is: a laboratory reference and learning app in Uzbek, Russian and English. Core "
                   "content works offline and without an account, and the app’s own privacy text says no ads, "
                   "analytics or tracking. The home screen follows the role you choose.",
                   "For the laboratory specialist: test cards with units, guideline thresholds and a cited source for "
                   "each claim; calculators that work only from your own values; Levey–Jennings quality control with "
                   "Westgard rules; a calibration record; a differential counter; the instrument catalog and the "
                   "atlases; in Uzbekistan, practice for the category assessment; records that stay on your phone.",
                   "For the teacher: lecture slides and practical protocols for a big screen, offline too; a class that "
                   "students join with a QR or a short code (sign-in needed); a lecture test where questions can "
                   "differ per student; results by student and the hardest questions.",
                   "For the student: learning from slides by topic, five new questions a day, topic quizzes with every "
                   "answer explained, timed practice exams that work offline with a mistakes review, and a test from "
                   "your teacher on the home screen."],
            "ru": ["Что такое LabGuide: справочное и учебное приложение для лаборатории на узбекском, русском и "
                   "английском. Основное содержимое работает без интернета и без аккаунта, а в собственной политике "
                   "приложения — без рекламы, аналитики и отслеживания. Главный экран подстраивается под выбранную роль.",
                   "Специалисту лаборатории: карточки анализов с единицами, порогами из руководств и источником у "
                   "каждого утверждения; калькуляторы, которые считают только по вашим значениям; контроль качества "
                   "Леви–Дженнингса с правилами Вестгарда; запись калибровки; счётчик лейкоформулы; каталог приборов и "
                   "атласы; в Узбекистане — подготовка к проверке знаний на категорию; записи остаются на вашем телефоне.",
                   "Преподавателю: слайды лекций и практические протоколы для большого экрана, в том числе без "
                   "интернета; группа, в которую студенты входят по QR или короткому коду (нужен вход в аккаунт); "
                   "тест по лекции, где вопросы у студентов могут различаться; результаты по студентам и самые "
                   "трудные вопросы.",
                   "Студенту: учёба по слайдам и темам, пять новых вопросов в день, тесты по темам с объяснением "
                   "каждого ответа, экзамены с таймером без интернета с разбором ошибок и тест от преподавателя на "
                   "главном экране."],
            "uz": ["LabGuide nima: o‘zbek, rus va ingliz tillarida laboratoriya ma’lumotnomasi va o‘quv ilovasi. "
                   "Asosiy qismi internetsiz va hisobsiz ishlaydi, ilovaning o‘z maxfiylik matnida esa reklama, "
                   "analitika va kuzatuv yo‘q. Bosh sahifa tanlagan rolingizga moslashadi.",
                   "Laboratoriya mutaxassisi uchun: birliklar, qo‘llanma chegaralari va har da’vo manbasi bilan tahlil "
                   "kartalari; faqat sizning qiymatlaringizdan hisoblaydigan kalkulyatorlar; Westgard qoidalari bilan "
                   "Levey–Jennings sifat nazorati; kalibrlash yozuvi; leykoformula sanagichi; apparatlar katalogi va "
                   "atlaslar; O‘zbekistonda — bilim va malakani baholashga tayyorlanish; yozuvlar telefoningizda qoladi.",
                   "Ustoz uchun: katta ekran uchun ma’ruza slaydlari va amaliy protokollar, internetsiz ham; talabalar "
                   "QR yoki qisqa kod bilan qo‘shiladigan guruh (akkauntga kirish kerak); savollar talabaga qarab "
                   "farq qilishi mumkin bo‘lgan ma’ruza testi; talabalar bo‘yicha natijalar va eng qiyin savollar.",
                   "Talaba uchun: mavzu bo‘yicha slaydlardan o‘rganish, kuniga beshta yangi savol, har javobi "
                   "izohlangan mavzu testlari, internetsiz ishlaydigan vaqtli mashq imtihonlari va xatolar tahlili "
                   "hamda ustozning testi bosh sahifada."],
        },
        app={
            "en": ["Role changes the home screen and its shortcuts; the knowledge base is the same for every role.",
                   "Classes need an account and a connection; the rest of the core content works without one.",
                   "The category-assessment practice appears for the specialist and teacher roles, for Uzbek-language "
                   "or Uzbekistan-region users, not for the student role."],
            "ru": ["Роль меняет главный экран и быстрые действия; база знаний одна для всех ролей.",
                   "Для групп нужны аккаунт и подключение; остальное основное содержимое работает без них.",
                   "Подготовка к проверке знаний на категорию показывается ролям специалиста и преподавателя, "
                   "пользователям с узбекским языком или регионом Узбекистан, но не роли студента."],
            "uz": ["Rol bosh sahifa va tezkor amallarni o‘zgartiradi; bilim bazasi barcha rollar uchun bitta.",
                   "Guruhlar uchun akkaunt va ulanish kerak; qolgan asosiy qism ularsiz ishlaydi.",
                   "Bilim va malakani baholashga tayyorlanish mutaxassis va ustoz rollarida, o‘zbek tili yoki "
                   "O‘zbekiston mintaqasidagi foydalanuvchilarga ko‘rinadi, talaba roliga emas."],
        },
        limits={
            "en": ["Class screens (class code, QR, test, results, the student’s home) use demo data from the app’s own "
                   "test server; control, calibration and count values are illustrative.",
                   "The video does not interpret any value and shows no reference intervals: the app gives guideline "
                   "thresholds on some cards and says your laboratory’s intervals decide.",
                   "Test-card thresholds and all other app content are under expert review.",
                   "No numbers are claimed for how much content the app holds."],
            "ru": ["Экраны группы (код группы, QR, тест, результаты, главный экран студента) используют демо-данные "
                   "тестового сервера приложения; значения контроля, калибровки и подсчёта — примерные.",
                   "Видео не интерпретирует значения и не показывает референтные интервалы: на части карточек "
                   "приложение даёт пороги из руководств и говорит, что решают интервалы вашей лаборатории.",
                   "Пороги на карточках анализов и весь остальной материал приложения ждут экспертной проверки.",
                   "Никаких цифр об объёме содержимого приложения не заявляется."],
            "uz": ["Guruh ekranlari (guruh kodi, QR, test, natijalar, talabaning bosh sahifasi) ilovaning o‘z test "
                   "serveridagi demo ma’lumotdan foydalanadi; nazorat, kalibrlash va sanash qiymatlari namunaviy.",
                   "Video hech bir qiymatni talqin qilmaydi va me’yor oraliqlarini ko‘rsatmaydi: ilova ayrim "
                   "kartalarda qo‘llanma chegaralarini beradi va laboratoriyangiz oraliqlari hal qilishini aytadi.",
                   "Tahlil kartalaridagi chegaralar va ilovaning barcha boshqa materiali mutaxassis ko‘rigini kutmoqda.",
                   "Ilovadagi material hajmi haqida hech qanday raqam da’vo qilinmaydi."],
        },
        ig={
            "en": ["Reference ranges in a PDF. Formulas in a chat. A calculator in another app.",
                   "One app for the lab specialist, the teacher and the student, in Uzbek, Russian and English: cited "
                   "test cards, calculators, Levey–Jennings QC, a differential counter — then lecture slides, classes "
                   "and tests with per-student questions — then daily questions, quizzes and practice exams.",
                   "A reference and learning aid — it does not diagnose. Which part do you use first?"],
            "ru": ["Референтные интервалы — в PDF. Формулы — в чате. Калькулятор — в другом приложении.",
                   "Одно приложение для специалиста лаборатории, преподавателя и студента на узбекском, русском и "
                   "английском: карточки анализов с источниками, калькуляторы, контроль качества Леви–Дженнингса, "
                   "счётчик лейкоформулы — затем слайды лекций, группы и тесты с разными вопросами — затем вопросы дня, "
                   "тесты и пробные экзамены.",
                   "Справочное и учебное пособие — диагноз не ставит. С какой части начнёте вы?"],
            "uz": ["Me’yor oraliqlari — PDF’da. Formulalar — chatda. Kalkulyator — boshqa ilovada.",
                   "Mutaxassis, ustoz va talaba uchun bitta ilova — o‘zbek, rus va ingliz tillarida: manbali tahlil "
                   "kartalari, kalkulyatorlar, Levey–Jennings sifat nazorati, leykoformula sanagichi — so‘ng ma’ruza "
                   "slaydlari, guruhlar va har talabaga boshqa savolli testlar — so‘ng kunlik savollar, testlar va "
                   "mashq imtihonlari.",
                   "Ma’lumotnoma va o‘quv vositasi — tashxis qo‘ymaydi. Avval qaysi qismidan foydalanasiz?"],
        },
        pinned={
            "en": ("Notes: app screens are real; class screens use demo data; control, calibration and count values are "
                   "illustrative. LabGuide does not diagnose, and your laboratory’s reference intervals decide. "
                   "Narration is English synthetic speech. The content is awaiting expert review — corrections are "
                   "welcome. Which role are you, and what should we show next?"),
            "ru": ("Заметки: экраны приложения — реальные; экраны группы — на демо-данных; значения контроля, "
                   "калибровки и подсчёта — примерные. LabGuide не ставит диагноз, решают референтные интервалы вашей "
                   "лаборатории. Озвучка — синтезированная английская речь. Материал ждёт экспертной проверки, "
                   "поправки приветствуются. Вы в какой роли и что показать дальше?"),
            "uz": ("Eslatma: ilova ekranlari haqiqiy; guruh ekranlari demo ma’lumotda; nazorat, kalibrlash va sanash "
                   "qiymatlari namunaviy. LabGuide tashxis qo‘ymaydi, laboratoriyangizning me’yor oraliqlari hal "
                   "qiladi. Diktor ovozi — sun’iy inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda. Siz qaysi "
                   "roldasiz va keyin nimani ko‘rsatamiz?"),
        },
        keywords={
            "en": ["LabGuide", "lab specialist app", "medical laboratory app", "laboratory reference", "Levey-Jennings",
                   "Westgard rules", "lecture slides", "class mode", "practice quiz", "medical student", "Uzbek",
                   "Russian"],
            "ru": ["LabGuide", "приложение для лаборатории", "лабораторная диагностика", "контроль качества",
                   "правила Вестгарда", "лекции", "тесты для студентов", "преподаватель", "лаборант"],
            "uz": ["LabGuide", "laboratoriya ilovasi", "laborant", "sifat nazorati", "Westgard qoidalari",
                   "ma’ruza slaydlari", "talaba testlari", "ustoz"],
        },
        hashtags_topic={
            "en": ["#LabSpecialist", "#MedicalTeacher", "#StudyApp", "#LevyJennings", "#Westgard",
                   "#PracticeQuiz"],
            "ru": ["#специалистлаборатории", "#преподаватель", "#приложениедляучёбы", "#ЛевиДженнингс",
                   "#Вестгард", "#тесты"],
            "uz": ["#mutaxassis", "#ustoz", "#oquvilovasi", "#LeveyJennings", "#Westgard", "#testlar"],
        },
        thumb_alt={
            "en": "LabGuide logo, the title “One app, three roles” with the three roles Specialist, Teacher and Student, "
                  "three phone screens (the role home screens of the app) and the notice “Real app screens”.",
            "ru": "Логотип LabGuide, заголовок «Одно приложение, три роли» с ролями «Специалист», «Преподаватель» и "
                  "«Студент», три экрана телефона (главные экраны приложения для этих ролей) и пометка «Реальные экраны».",
            "uz": "LabGuide logotipi, «Bitta ilova, uch rol» sarlavhasi va «Mutaxassis», «Ustoz», «Talaba» rollari, "
                  "uchta telefon ekrani (ilovaning shu rollar uchun bosh sahifalari) hamda «Haqiqiy ekranlar» belgisi.",
        },
        chapters=[
            ("hook", T("Scattered lab knowledge", "Разрозненные знания лаборатории", "Tarqoq laboratoriya bilimi")),
            ("what", T("What LabGuide is, and your role", "Что такое LabGuide и ваша роль", "LabGuide nima va rolingiz")),
            ("spec_a", T("For the laboratory specialist", "Специалисту лаборатории", "Laboratoriya mutaxassisi uchun")),
            ("teach_a", T("For the teacher", "Преподавателю", "Ustoz uchun")),
            ("stud_a", T("For the student", "Студенту", "Talaba uchun")),
        ],
        sources=[],
        evidence=["docs/video/overview/CLAIMS_AND_EVIDENCE.md", "docs/video/overview/DESCRIPTION.md",
                  "docs/video/overview/QA.md", "docs/video/overview/lines.en.json"],
        next=["qc", "calculators"],
        paid=None,
        internal=["Free today. Copy checked against the final lines.*.json, CLAIMS_AND_EVIDENCE.md, DESCRIPTION.md and QA.md of "
                  "the rendered video (113.7 s).",
                  "The category-assessment practice is narrated under the SPECIALIST, not the student: the app hides it "
                  "for the student and physician roles (toifa_bank.dart).",
                  "Class screens were filmed with the app's widget-test fake server: demo data, and the real class "
                  "server's deployment state was not verified.",
                  "No numbers about content size are used on purpose."],
    ),
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
        id="photometry", order=3, tier="free", verified=True,
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
                "linearity limit the curve bends and readings fall short (an illustrated curve; the real limit comes "
                "from the reagent IFU).",
                "Three cuvettes: the blank sets zero, then the standard, then the sample; concentration = A sample ÷ "
                "A standard × the standard’s concentration (illustrative numbers).",
                "Above the limit: dilute, measure again, multiply by the dilution factor (illustrative numbers).",
                "Real LabGuide screens: Learn → Lecture mode → Practical protocols, the photometry-basics protocol "
                "(blank, standard and sample step by step, the calculation, and the rule for results above the "
                "linearity limit).",
            ],
            "ru": [
                "Как работает фотометр: свет одной длины волны через кювету, A = log₁₀(I₀/I); при A = 1 проходит "
                "лишь 10 % света, при A = 2 — 1 %.",
                "Закон Бугера–Ламберта–Бера: в пределах диапазона оптическая плотность растёт пропорционально "
                "концентрации; выше границы линейности кривая изгибается и показание занижено (иллюстрация; "
                "реальную границу задаёт IFU реагента).",
                "Три кюветы: бланк задаёт ноль, затем стандарт и проба; концентрация = A пробы ÷ A стандарта × "
                "концентрация стандарта (иллюстративные числа).",
                "Выше границы: разведите, повторите измерение, умножьте на степень разведения (иллюстративные числа).",
                "Реальные экраны LabGuide: Обучение → Режим лекции → Практические протоколы — протокол по основам "
                "фотометрии (бланк, стандарт и проба по шагам, расчёт и правило для результата выше границы "
                "линейности).",
            ],
            "uz": [
                "Fotometr qanday ishlaydi: kyuvetadan bir to‘lqin uzunlikdagi nur, A = log₁₀(I₀/I); A = 1 da nurning "
                "faqat 10 % i o‘tadi, A = 2 da — 1 % i.",
                "Buger–Lambert–Ber qonuni: ma’lum oraliqda optik zichlik konsentratsiyaga mutanosib; chiziqlilik "
                "chegarasidan oshsa egri chiziq bukiladi va natija past chiqadi (rasm; haqiqiy chegara reagent "
                "IFU’sidan olinadi).",
                "Uch kyuveta: blank nolni qo‘yadi, so‘ng standart va namuna; konsentratsiya = A namuna ÷ A standart × "
                "standart konsentratsiyasi (namunaviy sonlar).",
                "Chegaradan oshsa: suyultiring, qayta o‘lchang, suyultirish darajasiga ko‘paytiring (namunaviy sonlar).",
                "LabGuide’ning haqiqiy ekranlari: O‘rganish → Ma’ruza rejimi → Amaliy protokollar — fotometriya "
                "asoslari protokoli (blank, standart va namuna bosqichma-bosqich, hisoblash va chiziqlilik "
                "chegarasidan oshgan natija qoidasi).",
            ],
        },
        app={
            "en": [
                "LabGuide’s Lecture mode (Learn → Lecture mode → Practical protocols) has a protocol on photometry basics: "
                "blank, standard and sample step by step, the calculation, and the rule for results above the "
                "linearity limit.",
                "It is a teaching protocol: the reagent IFU and your lab’s SOP always take precedence.",
            ],
            "ru": [
                "В режиме лекции LabGuide (Обучение → Режим лекции → Практические протоколы) есть протокол по основам "
                "фотометрии: бланк, стандарт и проба по шагам, расчёт и правило для результата выше границы линейности.",
                "Это учебный протокол: IFU реагента и СОП вашей лаборатории всегда главнее.",
            ],
            "uz": [
                "LabGuide ma’ruza rejimida (O‘rganish → Ma’ruza rejimi → Amaliy protokollar) fotometriya asoslari "
                "protokoli bor: blank, standart va namuna bosqichma-bosqich, hisoblash va chiziqlilik chegarasidan "
                "oshgan natija qoidasi.",
                "Bu o‘quv protokoli: reagent IFU’si va laboratoriyangiz SOP’i doim ustun.",
            ],
        },
        limits={
            "en": ["Wavelength, blank and limits always come from your reagent’s IFU; the numbers in the video are "
                   "illustrative (arbitrary units).",
                   "The single-standard calculation is one worked example, not the method for every assay; many "
                   "methods use a factor or a multi-point calibration.",
                   "The bend above the linearity limit is drawn as an illustration; how a real method behaves above "
                   "its limit depends on the method."],
            "ru": ["Длина волны, бланк и границы всегда берутся из IFU вашего реагента; числа в видео "
                   "иллюстративные (условные единицы).",
                   "Расчёт по одному стандарту — один разобранный пример, а не метод для любого анализа; во многих "
                   "методах используют фактор или многоточечную калибровку.",
                   "Изгиб выше границы линейности нарисован как иллюстрация; как ведёт себя реальный метод выше своей "
                   "границы, зависит от метода."],
            "uz": ["To‘lqin uzunligi, blank va chegaralar doim reagent IFU’sidan olinadi; videodagi sonlar namunaviy "
                   "(shartli birliklar).",
                   "Bitta standart bo‘yicha hisoblash — bitta ishlangan misol, har qanday tahlil uchun metod emas; "
                   "ko‘p metodlarda faktor yoki ko‘p nuqtali kalibrlash qo‘llanadi.",
                   "Chiziqlilik chegarasidan keyingi bukilish rasm sifatida chizilgan; haqiqiy metod o‘z chegarasidan "
                   "oshganda qanday bo‘lishi metodga bog‘liq."],
        },
        ig={
            "en": ["Absorbance far above your standard — can you trust that number?",
                   "Photometry basics in about 70 seconds: how a photometer measures absorbance, the Beer–Lambert law "
                   "and the linearity limit, blank → standard → sample, and what to do above the limit (illustrative "
                   "numbers).",
                   "LabGuide’s Lecture mode has a protocol on it: Learn → Lecture mode → Practical protocols. "
                   "A teaching protocol: your reagent IFU and SOP always take precedence."],
            "ru": ["Оптическая плотность намного выше стандарта — можно ли верить этому числу?",
                   "Основы фотометрии примерно за 70 секунд: как фотометр измеряет оптическую плотность, закон "
                   "Бугера–Ламберта–Бера и граница линейности, бланк → стандарт → проба и что делать выше границы "
                   "(иллюстративные числа).",
                   "В режиме лекции LabGuide есть протокол: Обучение → Режим лекции → Практические протоколы. "
                   "Учебный протокол: IFU реагента и СОП всегда главнее."],
            "uz": ["Optik zichlik standartdan ancha yuqori — bu raqamga ishonsa bo‘ladimi?",
                   "Taxminan 70 soniyada fotometriya asoslari: fotometr optik zichlikni qanday o‘lchaydi, "
                   "Buger–Lambert–Ber qonuni va chiziqlilik chegarasi, blank → standart → namuna va chegaradan oshsa "
                   "nima qilish (namunaviy sonlar).",
                   "LabGuide ma’ruza rejimida protokol bor: O‘rganish → Ma’ruza rejimi → Amaliy protokollar. "
                   "O‘quv protokoli: reagent IFU’si va SOP doim ustun."],
        },
        pinned={
            "en": ("Notes: all numbers in this video are illustrative, not patient results. Wavelength, blank and "
                   "limits always come from your reagent’s IFU and your lab’s SOP. Narration is English "
                   "synthetic speech. The content is awaiting expert review — corrections are welcome. "
                   "Do you use a single standard or a calibration curve in your lab?"),
            "ru": ("Заметки: все числа в видео иллюстративные, это не результаты пациентов. Длина волны, бланк и "
                   "границы всегда берутся из IFU вашего реагента и СОП вашей лаборатории. Озвучка — "
                   "синтезированная английская речь. Материал ждёт экспертной проверки, поправки приветствуются. "
                   "Что у вас в лаборатории — один стандарт или калибровочная кривая?"),
            "uz": ("Eslatma: videodagi barcha sonlar namunaviy, bemor natijasi emas. To‘lqin uzunligi, blank va "
                   "chegaralar doim reagent IFU’si va laboratoriyangiz SOP’idan olinadi. Diktor ovozi — "
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
        thumb_alt={
            "en": "LabGuide logo, the title “Photometry” with the subtitle “Blank, standard, sample — and the limit.”, "
                  "a light path from a lamp through a filter and a cuvette to a detector, three cuvettes labelled "
                  "Blank (A 0.000), Standard (A 0.412) and Sample (A 0.309), and the notice “Illustrative data — not a "
                  "patient result”.",
            "ru": "Логотип LabGuide, заголовок «Фотометрия» с подзаголовком «Бланк, стандарт, проба — и граница.», "
                  "ход света от лампы через фильтр и кювету к детектору, три кюветы с подписями «Бланк», «Стандарт» и "
                  "«Проба» и примерными значениями оптической плотности и пометка «Примерные данные — не результат "
                  "пациента».",
            "uz": "LabGuide logotipi, «Fotometriya» sarlavhasi va «Blank, standart, namuna — va chegara.» sarlavha "
                  "osti, lampadan filtr va kyuveta orqali detektorgacha nur yo‘li, «Blank», «Standart» va «Namuna» "
                  "yozuvli uchta kyuveta namunaviy optik zichlik qiymatlari bilan hamda «Namunaviy ma’lumot — bemor "
                  "natijasi emas» belgisi.",
        },
        chapters=[
            ("hook", T("The measurement: light in, light out", "Измерение: свет на входе и на выходе",
                       "O‘lchash: kirgan va chiqqan nur")),
            ("ladder", T("Absorbance scale, Beer–Lambert law, linearity limit",
                         "Шкала A, закон Бугера–Ламберта–Бера, граница линейности",
                         "A shkalasi, Buger–Lambert–Ber qonuni, chiziqlilik chegarasi")),
            ("bss", T("Blank, standard, sample — and dilution", "Бланк, стандарт, проба — и разведение",
                      "Blank, standart, namuna — va suyultirish")),
            ("app_intro", T("In LabGuide: the photometry protocol", "В LabGuide: протокол по фотометрии",
                            "LabGuide’da: fotometriya protokoli")),
        ],
        sources=[],
        evidence=["docs/video/photometry/CLAIMS_AND_EVIDENCE.md", "docs/video/photometry/DESCRIPTION.md",
                  "docs/video/photometry/QA.md",
                  "assets/lectures/decks/fotometriya-asoslari-biokimyo.{uz,ru,en}.json (the protocol, kind: protocol)",
                  "docs/VIDEO_FEATURE_INVENTORY.md §3 (Lecture mode)"],
        next=["calibration", "qc"],
        paid=None,
        internal=["The lead's name for this topic was `spectrophotometry`; the studio id is `photometry` "
                  "(docs/video/photometry/). `spectrophotometry` is kept as an alias.",
                  "Copy checked against lines.*.json, CLAIMS_AND_EVIDENCE.md, DESCRIPTION.md and QA.md of the rendered "
                  "video (69.6 s). Open expert items from the claims table: E5 (the illustrated bend / \"readings "
                  "fall short\" as a general statement) and E6 (single-standard calculation as the only model shown).",
                  "Terminology differs from the calibration video: «оптическая плотность» / «optik zichlik» here, "
                  "«поглощение» / «yutilish» there: the native reviewer picks one (G3).",
                  "The app path is Lecture mode, not Lab → Instruments: the protocol is a lecture deck of kind "
                  "protocol (uz/ru/en); confirm the deck is in the advertised build."],
    ),
    # ------------------------------------------------------------------ 4. qc
    dict(
        id="qc", order=4, tier="free", verified=True,
        path=T("Lab → Quality control", "Лаб. → Контроль качества", "Lab → Sifat nazorati"),
        title=T(
            "Levey–Jennings Charts and Westgard Rules in LabGuide QC",
            "Контроль качества: Леви–Дженнингс и правила Вестгарда в LabGuide",
            "Sifat nazorati: Levey–Jennings va Westgard qoidalari LabGuide’da",
        ),
        hook={
            "en": ("This morning’s control: 2.3 SD above the mean. Stop the run — or report the patients?",
                   "In about 80 seconds: a Levey–Jennings chart, the Westgard rules and how LabGuide records QC runs."),
            "ru": ("Контроль сегодня утром: +2,3 SD от среднего. Остановить серию — или выдать результаты?",
                   "Примерно за 80 секунд: карта Леви–Дженнингса, правила Вестгарда и то, как LabGuide записывает серии QC."),
            "uz": ("Bugun ertalabki nazorat: o‘rtachadan +2,3 SD. To‘xtatasizmi — yoki natija berasizmi?",
                   "Taxminan 80 soniyada: Levey–Jennings grafigi, Westgard qoidalari va LabGuide QC seriyalarini qanday qayd etishi."),
        },
        shows={
            "en": [
                "A Levey–Jennings chart: each control result plotted against its target mean and SD; targets come from "
                "your own control data (about twenty values to start).",
                "z-scores: how many SDs a result sits from the mean; one value beyond 2 SD is the 1-2s rule — a "
                "warning, not a rejection — to inspect with the other rules.",
                "The Westgard rules: 1-3s and R-4s point to random error; 2-2s, 4-1s and 10x to systematic error (a "
                "shift). A worked example: four values in a row beyond 1 SD (4-1s) — reject the run and find the cause.",
                "Real LabGuide screens (illustrative control data): entering each level’s target mean and SD and where "
                "they came from, recording runs, the chart drawn by the app, the broken rule named, a rejected run "
                "kept in the history but left out of later rules and statistics, runs copied as a CSV table, and the "
                "guides on EQA, rejected samples and critical values.",
            ],
            "ru": [
                "Карта Леви–Дженнингса: каждый результат контроля относительно целевого среднего и SD; цели берут из "
                "собственных данных контроля вашей лаборатории (сначала около 20 значений).",
                "z — на сколько SD результат отстоит от среднего; одно значение за 2 SD — правило 1-2s: "
                "предупреждение, а не отклонение; сначала проверьте другими правилами.",
                "Правила Вестгарда: 1-3s и R-4s указывают на случайную ошибку, 2-2s, 4-1s и 10x — на систематическую "
                "(сдвиг). Разобран пример: четыре значения подряд за 1 SD (4-1s) — серию отклонить и найти причину.",
                "Реальные экраны LabGuide (иллюстративные данные контроля): ввод для каждого уровня целевого среднего, "
                "SD и их источника, запись серий, карта, которую строит приложение, название нарушенного правила, "
                "отклонённая серия — в истории, но вне дальнейших правил и статистики, копирование серий таблицей "
                "CSV и памятки по EQA, отклонённым пробам и критическим значениям.",
            ],
            "uz": [
                "Levey–Jennings grafigi: har nazorat natijasi maqsadli o‘rtacha va SD bilan solishtiriladi; maqsadlar "
                "laboratoriyangizning o‘z nazorat ma’lumotidan olinadi (boshida taxminan 20 qiymat).",
                "z-qiymat: natija o‘rtachadan necha SD uzoqda; 2 SD dan tashqari bitta qiymat — 1-2s qoidasi: "
                "ogohlantirish, rad emas; avval boshqa qoidalar bilan tekshiring.",
                "Westgard qoidalari: 1-3s va R-4s tasodifiy xatoga, 2-2s, 4-1s va 10x tizimli xatoga (siljishga) "
                "ishora qiladi. Misol: ketma-ket to‘rt qiymat 1 SD dan tashqarida (4-1s) — seriyani rad eting va "
                "sababini toping.",
                "LabGuide’ning haqiqiy ekranlari (namunaviy nazorat ma’lumotlari): har daraja uchun maqsadli o‘rtacha, "
                "SD va ularning manbasini kiritish, seriyalarni yozish, ilova chizadigan grafik, buzilgan qoidaning "
                "nomi, rad etilgan seriya tarixda qoladi, lekin keyingi qoidalar va statistikaga kirmaydi, seriyalarni "
                "CSV jadval sifatida nusxalash va EQA, rad etilgan namunalar va kritik qiymatlar yo‘riqnomalari.",
            ],
        },
        app={
            "en": [
                "You enter each level’s target mean and SD and where they came from; the app draws the "
                "Levey–Jennings chart from the runs you record.",
                "Westgard rules are checked on every run, and the broken rule is named.",
                "A rejected run stays in the history but is not used in later rules or statistics (this is how the "
                "app works, not the only QC practice).",
                "Runs can be copied as a CSV table; data stays on this device.",
                "The EQA and critical-value guides are explanations only: LabGuide is not connected to any EQA scheme "
                "and does not submit results.",
            ],
            "ru": [
                "Для каждого уровня вы вводите целевое среднее, SD и их источник; карту Леви–Дженнингса по записанным "
                "сериям строит приложение.",
                "Правила Вестгарда проверяются в каждой серии, нарушенное правило названо.",
                "Отклонённая серия остаётся в истории, но не используется в дальнейших правилах и статистике (так "
                "работает приложение; это не единственная практика КК).",
                "Серии можно скопировать таблицей CSV; данные остаются только на этом устройстве.",
                "Памятки по EQA и критическим значениям — только пояснения: LabGuide не подключён ни к одной "
                "программе EQA и не отправляет результаты.",
            ],
            "uz": [
                "Har daraja uchun maqsadli o‘rtacha, SD va ularning manbasini siz kiritasiz; yozilgan seriyalar "
                "bo‘yicha Levey–Jennings grafigini ilova chizadi.",
                "Westgard qoidalari har seriyada tekshiriladi, buzilgan qoida nomlanadi.",
                "Rad etilgan seriya tarixda qoladi, lekin keyingi qoidalar va statistikada ishlatilmaydi (ilova "
                "shunday ishlaydi; bu yagona QC amaliyoti emas).",
                "Seriyalarni CSV jadval sifatida nusxalash mumkin; ma’lumot faqat shu qurilmada qoladi.",
                "EQA va kritik qiymat yo‘riqnomalari faqat tushuntirish: LabGuide hech bir EQA dasturiga ulanmagan "
                "va natija yubormaydi.",
            ],
        },
        limits={
            "en": ["A checking aid — not a substitute for your laboratory’s QC procedure; targets, limits and what to do "
                   "after a rejected run come from that procedure.",
                   "Illustrative control data — not a real lot and not real control results.",
                   "The rules are shown as LabGuide implements them (1-2s as a warning, all rejection rules checked on "
                   "every run); your laboratory’s procedure may differ."],
            "ru": ["Помощник для проверки — не заменяет процедуру QC вашей лаборатории; целевые значения, пределы и "
                   "действия после отклонённой серии определяет эта процедура.",
                   "Иллюстративные данные контроля — не реальный лот и не реальные результаты контролей.",
                   "Правила показаны так, как их реализует LabGuide (1-2s — предупреждение, все правила отклонения "
                   "проверяются в каждой серии); процедура вашей лаборатории может отличаться."],
            "uz": ["Tekshirish yordamchisi — laboratoriyangiz QC tartibining o‘rnini bosmaydi; maqsadli qiymatlar, "
                   "chegaralar va rad etilgan seriyadan keyingi harakatni shu tartib belgilaydi.",
                   "Namunaviy nazorat ma’lumotlari — haqiqiy lot ham, haqiqiy nazorat natijalari ham emas.",
                   "Qoidalar LabGuide amalga oshirganidek ko‘rsatilgan (1-2s — ogohlantirish, barcha rad qoidalari har "
                   "seriyada tekshiriladi); laboratoriyangiz tartibi farq qilishi mumkin."],
        },
        ig={
            "en": ["This morning’s control: 2.3 SD above the mean. Stop the run — or report the patients?",
                   "In about 80 seconds: a Levey–Jennings chart, z-scores, the Westgard rules (1-2s is a warning; 1-3s "
                   "and R-4s point to random error; 2-2s, 4-1s and 10x to systematic error) and how LabGuide records "
                   "QC runs — targets you enter with their source, the broken rule named, rejected runs kept in the "
                   "history but out of later rules, runs copied as a CSV table, data on this device.",
                   "A checking aid — not a substitute for your lab’s QC procedure. Find it in Lab → Quality control. "
                   "Control data in the video are illustrative."],
            "ru": ["Контроль сегодня утром: +2,3 SD от среднего. Остановить серию — или выдать результаты?",
                   "Примерно за 80 секунд: карта Леви–Дженнингса, z, правила Вестгарда (1-2s — предупреждение; 1-3s и "
                   "R-4s — случайная ошибка; 2-2s, 4-1s и 10x — систематическая) и то, как LabGuide записывает серии "
                   "QC — цели, которые вводите вы, с источником, название нарушенного правила, отклонённые серии в "
                   "истории, но вне дальнейших правил, копирование таблицей CSV, данные на устройстве.",
                   "Помощник для проверки — не заменяет процедуру QC вашей лаборатории. Раздел: Лаб. → Контроль "
                   "качества. Данные контроля в видео иллюстративные."],
            "uz": ["Bugun ertalabki nazorat: o‘rtachadan +2,3 SD. To‘xtatasizmi — yoki natija berasizmi?",
                   "Taxminan 80 soniyada: Levey–Jennings grafigi, z-qiymat, Westgard qoidalari (1-2s — ogohlantirish; "
                   "1-3s va R-4s — tasodifiy xato; 2-2s, 4-1s va 10x — tizimli xato) va LabGuide QC seriyalarini "
                   "qanday qayd etishi — siz manbasi bilan kiritadigan maqsadlar, buzilgan qoida nomi, tarixda "
                   "qoladigan, lekin keyingi qoidalarga kirmaydigan rad etilgan seriyalar, CSV jadval nusxasi, "
                   "ma’lumot qurilmada.",
                   "Tekshirish yordamchisi — laboratoriyangiz QC tartibining o‘rnini bosmaydi. Bo‘lim: Lab → Sifat "
                   "nazorati. Videodagi nazorat ma’lumotlari namunaviy."],
        },
        pinned={
            "en": ("Notes: control data in this video are illustrative, not a real lot or real QC results. Targets, "
                   "limits and what to do after a rejected run come from your lab’s QC procedure; LabGuide’s handling "
                   "of rejected runs is the app’s behaviour, not the only QC practice. The EQA guide in the app is an "
                   "explanation only. Narration is English synthetic speech. The content is awaiting expert review — "
                   "corrections are welcome. Which Westgard rules does your lab use?"),
            "ru": ("Заметки: данные контроля в видео иллюстративные, это не реальный лот и не реальные результаты КК. "
                   "Целевые значения, пределы и действия после отклонённой серии определяет процедура КК вашей "
                   "лаборатории; обработка отклонённых серий в LabGuide — поведение приложения, а не единственная "
                   "практика КК. Памятка по EQA в приложении — только пояснение. Озвучка — синтезированная "
                   "английская речь. Материал ждёт экспертной проверки, поправки приветствуются. "
                   "Какие правила Вестгарда применяет ваша лаборатория?"),
            "uz": ("Eslatma: videodagi nazorat ma’lumotlari namunaviy, haqiqiy lot ham, haqiqiy QC natijalari ham emas. "
                   "Maqsadli qiymatlar, chegaralar va rad etilgan seriyadan keyingi harakatni laboratoriyangiz QC "
                   "tartibi belgilaydi; LabGuide’da rad etilgan seriyaning ishlanishi — ilovaning xatti-harakati, "
                   "yagona QC amaliyoti emas. Ilovadagi EQA yo‘riqnomasi faqat tushuntirish. Diktor ovozi — sun’iy "
                   "inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda — tuzatishlar uchun rahmat. "
                   "Laboratoriyangiz qaysi Westgard qoidalarini qo‘llaydi?"),
        },
        keywords={
            "en": ["quality control", "Levey-Jennings chart", "Westgard rules", "internal quality control",
                   "laboratory QC", "QC rules", "z-score", "1-3s", "2-2s", "clinical chemistry", "LabGuide"],
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
        thumb_alt={
            "en": "LabGuide logo, the title “QC rules” with the subtitle “Levey–Jennings + Westgard”, the legend "
                  "“accepted, warning, rejected” (circle, triangle, square), a Levey–Jennings chart with two series of "
                  "control points between the −3s and +3s lines — one warning point beyond +2s and several rejected "
                  "points — and the notice “Illustrative control data — not a real lot”.",
            "ru": "Логотип LabGuide, заголовок «Правила QC» с подзаголовком «Леви–Дженнингс + Вестгард», условные "
                  "обозначения принятых, предупреждающих и отклонённых точек (круг, треугольник, квадрат), карта "
                  "Леви–Дженнингса с двумя рядами точек контроля между линиями −3s и +3s — одна точка-предупреждение "
                  "выше +2s и несколько отклонённых — и пометка «Примерные данные контроля — не реальный лот».",
            "uz": "LabGuide logotipi, «QC qoidalari» sarlavhasi va «Levey–Jennings + Westgard» sarlavha osti, qabul "
                  "qilingan, ogohlantirish va rad etilgan nuqtalar belgilari (doira, uchburchak, kvadrat), −3s va +3s "
                  "chiziqlari orasida ikki qator nazorat nuqtali Levey–Jennings grafigi — +2s dan yuqorida bitta "
                  "ogohlantirish nuqtasi va bir nechta rad etilgan nuqta — hamda «Namunaviy nazorat ma’lumotlari — "
                  "haqiqiy lot emas» belgisi.",
        },
        chapters=[
            ("hook", T("The chart: a control 2.3 SD above the mean", "Карта: контроль на 2,3 SD выше среднего",
                       "Grafik: o‘rtachadan 2,3 SD yuqori nazorat")),
            ("zscore", T("z-scores and the 1-2s warning", "z и предупреждение 1-2s",
                         "z-qiymat va 1-2s ogohlantirishi")),
            ("random", T("Random and systematic error: the Westgard rules",
                         "Случайная и систематическая ошибка: правила Вестгарда",
                         "Tasodifiy va tizimli xato: Westgard qoidalari")),
            ("app_set", T("In LabGuide: targets, runs, rules, rejected runs",
                          "В LabGuide: цели, серии, правила, отклонённые серии",
                          "LabGuide’da: maqsadlar, seriyalar, qoidalar, rad etilgan seriyalar")),
            ("app_more", T("CSV copy and the QC guides", "Таблица CSV и памятки по КК",
                           "CSV jadval va QC yo‘riqnomalari")),
        ],
        sources=[],
        evidence=["docs/video/qc/CLAIMS_AND_EVIDENCE.md", "docs/video/qc/DESCRIPTION.md", "docs/video/qc/QA.md",
                  "docs/VIDEO_FEATURE_INVENTORY.md §1 (QC rows)", "test/widget/qc_flow_test.dart",
                  "test/unit/qc_rules_test.dart"],
        next=["calibration", "calculators"],
        paid=None,
        internal=["Free today: sets, runs, Levey–Jennings, Westgard, CSV copy, JSON backup. A QC summary report as "
                  "CSV/PDF file is a Specialist Pro feature (D-78, flag off): the video does not mention it (nor the "
                  "text backup), so neither does the copy.",
                  "Copy checked against lines.*.json, CLAIMS_AND_EVIDENCE.md, DESCRIPTION.md and QA.md of the rendered "
                  "video (79.7 s). Rules named in the video: 1-2s, 1-3s, R-4s, 2-2s, 4-1s, 10x. Open expert items: E3 "
                  "(the short rule-card paraphrases); the app's stricter-than-1981 handling of 1-2s and its exclusion "
                  "of rejected runs are described as app behaviour, not as the only Westgard practice."],
    ),
    # ------------------------------------------------------------------ 5. gc_ms
    dict(
        id="gcms", order=5, tier="free", verified=True,
        path=T("Lab → Instruments and methods → Toxicology → GC-MS",
               "Лаб. → Приборы и методики → Токсикология → ГХ-МС",
               "Lab → Apparatlar va metodikalar → Toksikologiya → GC-MS"),
        title=T(
            "GC-MS Explained: From Injector to Mass Spectrum (Schematic)",
            "ГХ-МС простыми словами: от инжектора до масс-спектра (схема)",
            "GC-MS tushuntirish: injektordan mass-spektrgacha (sxema)",
        ),
        hook={
            "en": ("Three peaks in one unknown sample. Which compound is which?",
                   "GC-MS separates them first, then reads their fragments — on a schematic, in under 90 seconds."),
            "ru": ("Три пика в неизвестной пробе. Какое вещество где?",
                   "ГХ-МС сначала разделяет их, потом читает их фрагменты — на схеме, меньше чем за 90 секунд."),
            "uz": ("Noma’lum namunada uch cho‘qqi. Qaysi biri qaysi modda?",
                   "GC-MS avval ularni ajratadi, so‘ng bo‘laklarini o‘qiydi — sxemada, 90 soniyadan kamroq vaqtda."),
        },
        shows={
            "en": ["The gas chromatograph on a schematic with numbered parts: carrier gas, autosampler, heated "
                   "injector, an oven with a capillary column, and a heated transfer line.",
                   "Compounds leave the column at different times (retention time); for GC the analyte must be "
                   "volatile, sometimes after derivatization.",
                   "The mass spectrometer: ion source, quadrupole, detector, vacuum pumps and data system. Molecules "
                   "are ionised and break into fragment ions; the quadrupole sorts the ions by m/z and passes them in "
                   "turn.",
                   "The result: a chromatogram over retention time and a mass spectrum for every peak; compounds are "
                   "identified against a spectral library or standards; without quality control, peaks that don’t "
                   "belong to the sample can appear.",
                   "Real LabGuide screens: Lab → Instruments and methods → Toxicology → the GC-MS card — the same "
                   "schematic and parts, then principle and tasks, each with its source; QC notes and biosafety "
                   "(hot parts, glasses, coat and gloves)."],
            "ru": ["Газовый хроматограф на схеме с пронумерованными частями: газ-носитель, автосэмплер, нагреваемый "
                   "инжектор, термостат с капиллярной колонкой и нагреваемая линия переноса.",
                   "Вещества выходят из колонки в разное время (время удерживания); для ГХ аналит должен быть "
                   "летучим, иногда после дериватизации.",
                   "Масс-спектрометр: источник ионов, квадруполь, детектор, вакуумные насосы и система данных. "
                   "Молекулы ионизируются и распадаются на ионы-фрагменты; квадруполь разделяет ионы по m/z и "
                   "пропускает их по очереди.",
                   "Итог: хроматограмма по времени удерживания и масс-спектр каждого пика; вещество находят по "
                   "библиотеке спектров или стандартам; без контроля качества в спектре могут появиться чужие пики.",
                   "Реальные экраны LabGuide: Лаб. → Приборы и методики → Токсикология → карточка ГХ-МС — та же схема "
                   "и детали, затем принцип и задачи, у каждого источник; контроль качества и биобезопасность "
                   "(горячие части, очки, халат, перчатки)."],
            "uz": ["Gaz xromatografi raqamlangan qismli sxemada: tashuvchi gaz, avtonamunaoluvchi, isitiladigan "
                   "injektor, kapillyar kolonkali termostat va isitiladigan uzatish liniyasi.",
                   "Moddalar kolonkadan turli vaqtda chiqadi (ushlanish vaqti); GC uchun modda uchuvchan bo‘lishi "
                   "kerak, ba’zan derivatizatsiya bilan.",
                   "Mass-spektrometr: ion manbai, kvadrupol, detektor, vakuum nasoslari va ma’lumotlar tizimi. "
                   "Molekulalar ionlanadi va ion-bo‘laklarga ajraladi; kvadrupol ionlarni m/z bo‘yicha saralab, "
                   "navbat bilan o‘tkazadi.",
                   "Natija: ushlanish vaqti bo‘yicha xromatogramma va har cho‘qqining mass-spektri; modda spektrlar "
                   "kutubxonasi yoki standartlar bilan aniqlanadi; QC bo‘lmasa, spektrda begona cho‘qqilar chiqishi "
                   "mumkin.",
                   "LabGuide’ning haqiqiy ekranlari: Lab → Apparatlar va metodikalar → Toksikologiya → GC-MS kartasi — "
                   "o‘sha sxema va qismlar, so‘ng tamoyil va vazifalar, har biri manbali; sifat nazorati va biologik "
                   "xavfsizlik (issiq qismlar, ko‘zoynak, xalat, qo‘lqop)."],
        },
        app={
            "en": ["LabGuide has a GC-MS reference card in Lab → Instruments and methods → Toxicology: the schematic "
                   "with numbered parts, then principle and tasks, each with its source.",
                   "The card also has QC notes and biosafety notes: hot parts, glasses, coat and gloves.",
                   "A reference card: methods and limits come from your laboratory and its SOPs."],
            "ru": ["В LabGuide есть справочная карточка ГХ-МС (Лаб. → Приборы и методики → Токсикология): схема с "
                   "пронумерованными частями, затем принцип и задачи, у каждого источник.",
                   "На карточке — также заметки о контроле качества и биобезопасности: горячие части, очки, халат, "
                   "перчатки.",
                   "Справочная карточка: методики и границы определяют лаборатория и её СОП."],
            "uz": ["LabGuide’da GC-MS bo‘yicha ma’lumotnoma kartasi bor (Lab → Apparatlar va metodikalar → "
                   "Toksikologiya): raqamlangan qismli sxema, so‘ng tamoyil va vazifalar, har biri manbali.",
                   "Kartada sifat nazorati va biologik xavfsizlik eslatmalari ham bor: issiq qismlar, ko‘zoynak, "
                   "xalat, qo‘lqop.",
                   "Ma’lumotnoma kartasi: usul va chegaralarni laboratoriya va uning SOP’i belgilaydi."],
        },
        limits={
            "en": ["Schematic — not an exact model.",
                   "The chromatogram and spectra are illustrative schematic panels — no real compound, no numbers on "
                   "the axes.",
                   "The card in the app is itself marked as not yet expert-reviewed, and this video’s content is "
                   "awaiting expert review."],
            "ru": ["Схема — не точная модель.",
                   "Хроматограмма и спектры — схематичные иллюстрации: не реальное вещество, без чисел на осях.",
                   "Сама карточка в приложении помечена как ещё не проверенная экспертом, а материал этого видео ждёт "
                   "экспертной проверки."],
            "uz": ["Sxema — aniq model emas.",
                   "Xromatogramma va spektrlar — sxematik panellar: haqiqiy modda emas, o‘qlarda sonlar yo‘q.",
                   "Ilovadagi kartaning o‘zi hali mutaxassis tomonidan tekshirilmagan deb belgilangan, bu videoning "
                   "mazmuni ham mutaxassis ko‘rigini kutmoqda."],
        },
        ig={
            "en": ["Three peaks in one unknown sample. Which compound is which?",
                   "A schematic walk-through of GC-MS in under 90 seconds: carrier gas, autosampler, injector, oven "
                   "and column, transfer line, ion source, quadrupole, detector, vacuum pumps and data system — "
                   "retention time in the column, sorting by m/z in the quadrupole, and identification against a "
                   "spectral library or standards.",
                   "Reference card in LabGuide: Lab → Instruments and methods → Toxicology → GC-MS. Schematic — not an "
                   "exact model."],
            "ru": ["Три пика в неизвестной пробе. Какое вещество где?",
                   "Схематичный разбор ГХ-МС меньше чем за 90 секунд: газ-носитель, автосэмплер, инжектор, термостат "
                   "с колонкой, линия переноса, источник ионов, квадруполь, детектор, вакуумные насосы и система "
                   "данных — время удерживания в колонке, разделение по m/z в квадруполе и определение по библиотеке "
                   "спектров или стандартам.",
                   "Справочная карточка в LabGuide: Лаб. → Приборы и методики → Токсикология → ГХ-МС. Схема — не "
                   "точная модель."],
            "uz": ["Noma’lum namunada uch cho‘qqi. Qaysi biri qaysi modda?",
                   "GC-MS ning sxemali tahlili 90 soniyadan kamroq vaqtda: tashuvchi gaz, avtonamunaoluvchi, "
                   "injektor, kolonkali termostat, uzatish liniyasi, ion manbai, kvadrupol, detektor, vakuum "
                   "nasoslari va ma’lumotlar tizimi — kolonkadagi ushlanish vaqti, kvadrupolda m/z bo‘yicha saralash "
                   "va spektrlar kutubxonasi yoki standartlar bilan aniqlash.",
                   "LabGuide’dagi ma’lumotnoma kartasi: Lab → Apparatlar va metodikalar → Toksikologiya → GC-MS. "
                   "Sxema — aniq model emas."],
        },
        pinned={
            "en": ("Notes: this is a schematic general-principle video; the chromatogram and spectra are illustrative "
                   "panels, no real compound. Methods and limits come from your laboratory and its SOPs. Narration is "
                   "English synthetic speech. The content is awaiting expert review — corrections are welcome."),
            "ru": ("Заметки: это схематичное видео об общем принципе; хроматограмма и спектры — иллюстративные "
                   "панели, не реальное вещество. Методики и границы определяют ваша лаборатория и её СОП. Озвучка — "
                   "синтезированная английская речь. Материал ждёт экспертной проверки, поправки приветствуются."),
            "uz": ("Eslatma: bu umumiy tamoyil haqidagi sxematik video; xromatogramma va spektrlar — namunaviy "
                   "panellar, haqiqiy modda emas. Usul va chegaralarni laboratoriyangiz va uning SOP’i belgilaydi. "
                   "Diktor ovozi — sun’iy inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda — tuzatishlar uchun "
                   "rahmat."),
        },
        keywords={
            "en": ["GC-MS", "gas chromatography mass spectrometry", "mass spectrometer", "chromatogram", "mass spectrum",
                   "retention time", "quadrupole", "toxicology laboratory", "analytical chemistry", "LabGuide"],
            "ru": ["ГХ-МС", "хромато-масс-спектрометрия", "масс-спектрометр", "хроматограмма", "масс-спектр",
                   "квадруполь", "токсикология", "лаборант"],
            "uz": ["GC-MS", "xromato-mass-spektrometriya", "mass-spektrometr", "xromatogramma", "mass-spektr",
                   "kvadrupol", "toksikologiya", "laborant"],
        },
        hashtags_topic={
            "en": ["#GCMS", "#MassSpectrometry", "#Chromatography", "#Toxicology", "#AnalyticalChemistry",
                   "#LabInstruments", "#MassSpec"],
            "ru": ["#ГХМС", "#массспектрометрия", "#хроматография", "#токсикология", "#аналитическаяхимия",
                   "#приборылаборатории", "#масспектр"],
            "uz": ["#GCMS", "#massspektrometriya", "#xromatografiya", "#toksikologiya", "#analitikkimyo",
                   "#laboratoriyaapparatlari", "#massspektr"],
        },
        thumb_alt={
            "en": "LabGuide logo, the title “GC-MS” with the subtitle “From peak to identity”, a schematic of a gas "
                  "chromatograph–mass spectrometer with ten numbered parts, a chromatogram over retention time with "
                  "three labelled peaks A, B and C, and the notice “Illustrative schematic panels — no real compound”.",
            "ru": "Логотип LabGuide, заголовок «ГХ-МС» с подзаголовком «От пика к веществу», схема газового "
                  "хромато-масс-спектрометра с десятью пронумерованными частями, хроматограмма по времени "
                  "удерживания с тремя помеченными пиками A, B и C и пометка «Схематичные панели — не реальное "
                  "вещество».",
            "uz": "LabGuide logotipi, «GC-MS» sarlavhasi va «Cho‘qqidan moddagacha» sarlavha osti, gaz "
                  "xromato-mass-spektrometrining o‘nta raqamlangan qismli sxemasi, ushlanish vaqti bo‘yicha A, B va C "
                  "belgili uchta cho‘qqili xromatogramma hamda «Sxematik panellar — haqiqiy modda emas» belgisi.",
        },
        chapters=[
            ("hook", T("Three peaks and the gas chromatograph", "Три пика и газовый хроматограф",
                       "Uch cho‘qqi va gaz xromatografi")),
            ("separate", T("Retention time, volatility, the mass spectrometer",
                           "Время удерживания, летучесть, масс-спектрометр",
                           "Ushlanish vaqti, uchuvchanlik, mass-spektrometr")),
            ("quad", T("Ions and the quadrupole (m/z)", "Ионы и квадруполь (m/z)", "Ionlar va kvadrupol (m/z)")),
            ("result", T("The result: chromatogram, spectrum, identity, QC",
                         "Итог: хроматограмма, спектр, вещество, контроль качества",
                         "Natija: xromatogramma, spektr, modda, sifat nazorati")),
            ("app_card", T("In LabGuide: the GC-MS card", "В LabGuide: карточка ГХ-МС", "LabGuide’da: GC-MS kartasi")),
        ],
        sources=["NCBI Bookshelf, “Mass Spectrometer” (Garg, Zubair), the source cited by the app card; last update "
                 "2024-11-22."],
        evidence=["docs/video/gcms/CLAIMS_AND_EVIDENCE.md", "docs/video/gcms/DESCRIPTION.md", "docs/video/gcms/QA.md",
                  "docs/video/lessons/01_gc_ms.md", "assets/instruments/catalog.json lab card a3-tox-gc-ms"],
        next=["qpcr", "photometry"],
        paid=None,
        internal=["Copy checked against lines.*.json, CLAIMS_AND_EVIDENCE.md, DESCRIPTION.md and QA.md of the rendered "
                  "video (82.9 s). Open expert items: every STANDARD_TEXTBOOK row of the claims table; E4 (vacuum "
                  "pumps are only named, never explained).",
                  "The app's lab card is itself flagged NEEDS_REVIEW (expert_reviewed=false, docs/lab_cards_status.json) "
                  "and says so: do not call it \"verified\" or \"reviewed\". The video makes no drug-testing or "
                  "method statement, so neither does the copy."],
    ),
    # ------------------------------------------------------------------ 6. real_time_pcr
    dict(
        id="qpcr", order=6, tier="free", verified=True,
        path=T("Lab → Instruments and methods → Molecular diagnostics → Real-time PCR",
               "Лаб. → Приборы и методики → Молекулярная диагностика → ПЦР в реальном времени",
               "Lab → Apparatlar va metodikalar → Molekulyar diagnostika → Real vaqt PCR"),
        title=T(
            "Real-Time PCR Explained: Thermal Cycler, Fluorescence, Cq",
            "ПЦР в реальном времени: термоциклер, флуоресценция, Cq",
            "Real vaqt PCR: termosiklator, fluoressensiya va Cq",
        ),
        hook={
            "en": ("Sample A crosses the line at cycle 22, sample B at 31. Which one had more target to begin with?",
                   "Real-time PCR on a schematic: the thermal cycler, the amplification curve and Cq — in under 75 seconds."),
            "ru": ("Проба A пересекает линию на 22-м цикле, проба B — на 31-м. В какой было больше мишени?",
                   "ПЦР в реальном времени на схеме: термоциклер, кривая амплификации и Cq — меньше чем за 75 секунд."),
            "uz": ("A namuna chiziqni 22-siklda, B namuna 31-siklda kesib o‘tadi. Qaysi birida boshida nishon ko‘proq edi?",
                   "Real vaqt PCR sxemada: termosiklator, kuchayish egri chizig‘i va Cq — 75 soniyadan kamroq vaqtda."),
        },
        shows={
            "en": ["One PCR cycle: heat separates the strands, on cooling primers bind and a polymerase builds new "
                   "strands — so the target roughly doubles every cycle (general principle).",
                   "The thermal cycler on a schematic with numbered parts: tube strip, heated lid, and a Peltier block "
                   "that switches temperatures.",
                   "The optical path: excitation source, excitation filter, the tube, emission filter and detector.",
                   "The amplification curve: fluorescence grows with the product; Cq is the cycle where it crosses the "
                   "threshold — the lower the Cq, the more starting target.",
                   "Two cautions: trace contamination can give false results, and no amplification does not prove a "
                   "negative.",
                   "Real LabGuide screens: Lab → Instruments and methods → Molecular diagnostics → Real-time PCR — the "
                   "schematic, its numbered parts and the principle, each with its sources, then limitations and "
                   "contamination control."],
            "ru": ["Один цикл ПЦР: нагрев разделяет цепи, при охлаждении садятся праймеры, полимераза строит новые "
                   "цепи — поэтому мишень почти удваивается за цикл (общий принцип).",
                   "Термоциклер на схеме с пронумерованными частями: стрип, нагреваемая крышка и термоблок Пельтье, "
                   "который переключает температуры.",
                   "Оптический путь: источник возбуждения, фильтр возбуждения, пробирка, эмиссионный фильтр и "
                   "детектор.",
                   "Кривая амплификации: флуоресценция растёт с продуктом; Cq — цикл пересечения порога: ниже Cq — "
                   "больше мишени в начале.",
                   "Две оговорки: следовое загрязнение может дать ложный результат, а отсутствие амплификации ещё не "
                   "доказывает отрицательный результат.",
                   "Реальные экраны LabGuide: Лаб. → Приборы и методики → Молекулярная диагностика → ПЦР в реальном "
                   "времени — схема, её пронумерованные части и принцип, у каждого источники, затем ограничения и "
                   "защита от загрязнения."],
            "uz": ["PCR ning bitta sikli: qizdirish zanjirlarni ajratadi, sovutishda praymerlar birikadi, polimeraza "
                   "yangi zanjir quradi — shuning uchun nishon har siklda qariyb ikki barobar ko‘payadi (umumiy "
                   "tamoyil).",
                   "Termosiklator raqamlangan qismli sxemada: probirkalar qatori, isitiladigan qopqoq va "
                   "haroratlarni almashtiradigan Peltye termobloki.",
                   "Optik yo‘l: qo‘zg‘atuvchi nur manbai, qo‘zg‘atish filtri, probirka, nurlanish filtri va detektor.",
                   "Kuchayish egri chizig‘i: signal mahsulot bilan o‘sadi; Cq — chegara kesib o‘tilgan sikl: Cq qancha "
                   "past bo‘lsa, boshida nishon shuncha ko‘p.",
                   "Ikki ogohlantirish: ozgina ifloslanish soxta natija berishi mumkin, kuchayish yo‘qligi esa "
                   "manfiylikni isbotlamaydi.",
                   "LabGuide’ning haqiqiy ekranlari: Lab → Apparatlar va metodikalar → Molekulyar diagnostika → Real "
                   "vaqt PCR — sxema, uning raqamlangan qismlari va tamoyil, har biri manbalari bilan, so‘ng "
                   "cheklovlar va ifloslanishdan himoya."],
        },
        app={
            "en": ["LabGuide has a Real-time PCR reference card in Lab → Instruments and methods → Molecular "
                   "diagnostics: the schematic with numbered parts and the principle, each with its sources.",
                   "The card also covers limitations and contamination control.",
                   "Reference cards: the assay IFU and your laboratory SOP decide."],
            "ru": ["В LabGuide есть справочная карточка «ПЦР в реальном времени» (Лаб. → Приборы и методики → "
                   "Молекулярная диагностика): схема с пронумерованными частями и принцип, у каждого источники.",
                   "На карточке — также ограничения и защита от загрязнения.",
                   "Справочные карточки: решают IFU теста и СОП лаборатории."],
            "uz": ["LabGuide’da Molekulyar diagnostika bo‘limida (Lab → Apparatlar va metodikalar) Real vaqt PCR "
                   "bo‘yicha ma’lumotnoma kartasi bor — ilovada bu atama ba’zi kartalarda «PZR» deb ham yoziladi: "
                   "raqamlangan qismli sxema va tamoyil, har biri manbalari bilan.",
                   "Kartada cheklovlar va ifloslanishdan himoya ham bor.",
                   "Ma’lumotnoma kartalari: test IFU’si va laboratoriya SOP’i hal qiladi."],
        },
        limits={
            "en": ["Schematic — not an exact model; the curves are illustrative, not a real assay or result.",
                   "The assay IFU and your laboratory SOP decide thresholds and interpretation.",
                   "A general-principle video, not an assay protocol; the card in the app is itself marked as not yet "
                   "expert-reviewed."],
            "ru": ["Схема — не точная модель; кривые иллюстративные, это не реальный тест и не результат.",
                   "Пороги и интерпретацию определяют IFU теста и СОП вашей лаборатории.",
                   "Видео об общем принципе, а не протокол анализа; сама карточка в приложении помечена как ещё не "
                   "проверенная экспертом."],
            "uz": ["Sxema — aniq model emas; egri chiziqlar namunaviy, haqiqiy test yoki natija emas.",
                   "Chegaralar va talqinni test IFU’si va laboratoriyangiz SOP’i belgilaydi.",
                   "Umumiy tamoyil haqidagi video, tahlil protokoli emas; ilovadagi kartaning o‘zi hali mutaxassis "
                   "tomonidan tekshirilmagan deb belgilangan."],
        },
        ig={
            "en": ["Sample A crosses the line at cycle 22, sample B at 31. Which one had more target to begin with?",
                   "A schematic walk-through of real-time PCR in under 75 seconds: one cycle, the thermal cycler, the "
                   "optical path from the excitation source to the detector, the amplification curve, the threshold "
                   "and Cq — plus two cautions: trace contamination and no amplification.",
                   "Reference card in LabGuide: Lab → Instruments and methods → Molecular diagnostics → Real-time PCR. "
                   "Schematic — not an exact model."],
            "ru": ["Проба A пересекает линию на 22-м цикле, проба B — на 31-м. В какой было больше мишени?",
                   "Схематичный разбор ПЦР в реальном времени меньше чем за 75 секунд: один цикл, термоциклер, "
                   "оптический путь от источника возбуждения до детектора, кривая амплификации, порог и Cq — и две "
                   "оговорки: следовое загрязнение и отсутствие амплификации.",
                   "Справочная карточка в LabGuide: Лаб. → Приборы и методики → Молекулярная диагностика → ПЦР в "
                   "реальном времени. Схема — не точная модель."],
            "uz": ["A namuna chiziqni 22-siklda, B namuna 31-siklda kesib o‘tadi. Qaysi birida boshida nishon ko‘proq edi?",
                   "Real vaqt PCR ning sxemali tahlili 75 soniyadan kamroq vaqtda: bitta sikl, termosiklator, "
                   "qo‘zg‘atuvchi nur manbaidan detektorgacha optik yo‘l, kuchayish egri chizig‘i, chegara va Cq — "
                   "hamda ikki ogohlantirish: ozgina ifloslanish va kuchayish yo‘qligi.",
                   "LabGuide’dagi ma’lumotnoma kartasi: Lab → Apparatlar va metodikalar → Molekulyar diagnostika → "
                   "Real vaqt PCR. Sxema — aniq model emas."],
        },
        pinned={
            "en": ("Notes: this is a schematic general-principle video, not an assay protocol. Curves are illustrative, "
                   "not results; the assay IFU and your lab’s SOP decide thresholds and interpretation. Narration is "
                   "English synthetic speech. The content is awaiting expert review — corrections are welcome."),
            "ru": ("Заметки: это схематичное видео об общем принципе, а не протокол анализа. Кривые иллюстративные, "
                   "а не результаты; пороги и интерпретацию определяют IFU теста и СОП вашей лаборатории. Озвучка — "
                   "синтезированная английская речь. Материал ждёт экспертной проверки, поправки приветствуются."),
            "uz": ("Eslatma: bu umumiy tamoyil haqidagi sxematik video, tahlil protokoli emas. Egri chiziqlar "
                   "namunaviy, natijalar emas; chegaralar va talqinni test IFU’si va laboratoriyangiz SOP’i "
                   "belgilaydi. Diktor ovozi — sun’iy inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda — "
                   "tuzatishlar uchun rahmat."),
        },
        keywords={
            "en": ["real-time PCR", "qPCR", "thermal cycler", "amplification curve", "Cq", "fluorescence detection",
                   "molecular diagnostics laboratory", "PCR explained", "LabGuide"],
            "ru": ["ПЦР в реальном времени", "qПЦР", "термоциклер", "кривая амплификации", "Cq", "флуоресценция",
                   "молекулярная диагностика", "лаборант"],
            "uz": ["real vaqt PCR", "PZR", "qPCR", "termosiklator", "kuchayish egri chizig‘i", "Cq", "fluoressensiya",
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
        thumb_alt={
            "en": "LabGuide logo, the title “Real-time PCR” with the subtitle “Curves, threshold, Cq”, an amplification "
                  "chart in which curves A and B cross a dashed threshold at Cq 22.0 and Cq 31.2, next to a flat "
                  "no-template control, a small schematic of a real-time PCR instrument with numbered parts, and the "
                  "notice “Illustrative curves — not a real assay or result”.",
            "ru": "Логотип LabGuide, заголовок «ПЦР в реальном времени» с подзаголовком «Кривые, порог, Cq», график "
                  "амплификации: кривые A и B пересекают пунктирный порог на разных циклах (значения Cq подписаны), "
                  "рядом плоская линия контроля без матрицы, небольшая схема прибора для ПЦР в реальном времени с "
                  "пронумерованными частями и пометка «Иллюстративные кривые — не реальный тест или результат».",
            "uz": "LabGuide logotipi, «Real vaqt PCR» sarlavhasi va «Egri chiziq, chegara, Cq» sarlavha osti, "
                  "kuchayish grafigi: A va B egri chiziqlari punktir chegarani turli sikllarda kesib o‘tadi (Cq "
                  "qiymatlari yozilgan), yonida shablonsiz nazoratning tekis chizig‘i, raqamlangan qismli real vaqt "
                  "PCR asbobining kichik sxemasi hamda «Namunaviy egri chiziqlar — haqiqiy test yoki natija emas» "
                  "belgisi.",
        },
        chapters=[
            ("hook", T("Two samples and one PCR cycle", "Две пробы и один цикл ПЦР", "Ikki namuna va bitta PCR sikli")),
            ("cycler", T("The thermal cycler and the optical path", "Термоциклер и оптический путь",
                         "Termosiklator va optik yo‘l")),
            ("curves", T("Amplification curve, Cq and two cautions", "Кривая амплификации, Cq и две оговорки",
                         "Kuchayish egri chizig‘i, Cq va ikki ogohlantirish")),
            ("app_card", T("In LabGuide: the Real-time PCR card", "В LabGuide: карточка «ПЦР в реальном времени»",
                           "LabGuide’da: Real vaqt PCR kartasi")),
        ],
        sources=[],
        evidence=["docs/video/qpcr/CLAIMS_AND_EVIDENCE.md", "docs/video/qpcr/DESCRIPTION.md", "docs/video/qpcr/QA.md",
                  "docs/video/lessons/04_real_time_pcr.md",
                  "assets/instruments/catalog.json lab cards a1-realtime-pcr-method (filmed), "
                  "a3-mol-realtime-pcr-platform (not filmed)"],
        next=["gcms", "osmometry"],
        paid=None,
        internal=["Copy checked against lines.*.json, CLAIMS_AND_EVIDENCE.md, DESCRIPTION.md and QA.md of the rendered "
                  "video (73.4 s). Only the method card (a1-realtime-pcr-method) is filmed; the platform card is not, "
                  "so the copy speaks of one Real-time PCR card. Open expert items: every STANDARD_TEXTBOOK row; R4 "
                  "(excitation filter wording).",
                  "UZ naming: the video says «Real vaqt PCR»; the app's cards say «PZR» in places (the UZ text names "
                  "both once, and «PZR» is also a UZ tag). The owner or a native reviewer aligns them (G3); the video "
                  "is not changed.",
                  "Do not mention any specific assay (e.g. HIV viral load): the video shows none. The app's lab card is "
                  "itself flagged NEEDS_REVIEW (expert_reviewed=false, docs/lab_cards_status.json) and says so: do "
                  "not call it \"verified\" or \"reviewed\"."],
    ),
    # ------------------------------------------------------------------ 7. osmometry
    dict(
        id="osmometry", order=7, tier="free", verified=True,
        path=T("Lab → Instruments and methods → Clinical biochemistry → Osmometer",
               "Лаб. → Приборы и методики → Клиническая биохимия → Осмометр",
               "Lab → Apparatlar va metodikalar → Klinik biokimyo → Osmometr"),
        title=T(
            "Osmometry Explained: Freezing-Point Osmometer and Osmolality",
            "Осмометрия: криоскопический осмометр и осмоляльность",
            "Osmometriya: muzlash nuqtasi osmometri va osmolyallik",
        ),
        hook={
            "en": ("Two samples freeze — and one plateau sits lower. Why?",
                   "Dissolved particles lower the freezing point — that is what an osmometer measures. On a schematic, in under 80 seconds."),
            "ru": ("Две пробы замерзают — одно плато ниже. Почему?",
                   "Растворённые частицы понижают точку замерзания — это и измеряет осмометр. На схеме, меньше чем за 80 секунд."),
            "uz": ("Ikki namuna muzlaydi — bir plato pastroq. Nega?",
                   "Erigan zarrachalar muzlash nuqtasini pasaytiradi — osmometr shuni o‘lchaydi. Sxemada, 80 soniyadan kamroq vaqtda."),
        },
        shows={
            "en": ["A freezing-point osmometer on a schematic with five numbered parts: sample tubes, a thermistor "
                   "probe, a cooling block, a stirring wire and a display.",
                   "The freezing curve: the cooling block supercools the sample below its freezing point, the "
                   "stirring wire vibrates and freezing starts, and released heat lifts the temperature to a plateau "
                   "— the freezing point.",
                   "More particles, a deeper depression — and from it the osmolality. Osmolality is per kilogram of "
                   "water (mOsm/kg); osmolarity is per litre of solution.",
                   "Real LabGuide screens: Lab → Instruments and methods → Clinical biochemistry → Osmometer — the "
                   "same schematic and parts plus specimens, each with its source; what distorts the reading "
                   "(particles, air bubbles, evaporated or viscous samples, high alcohol or acetone) and carry-over "
                   "from an uncleaned container.",
                   "The Calculated osmolality calculator (Lab → Calculators): from sodium, glucose and urea; add the "
                   "measured value and it shows the osmolal gap (illustrative inputs)."],
            "ru": ["Криоскопический осмометр на схеме с пятью пронумерованными частями: пробирки, термисторный зонд, "
                   "охлаждающий блок, мешалка и дисплей.",
                   "Кривая замерзания: охлаждающий блок переохлаждает пробу ниже точки замерзания, мешалка "
                   "вибрирует — начинается кристаллизация, выделившееся тепло поднимает температуру до плато — "
                   "точки замерзания.",
                   "Больше частиц — глубже понижение, а по нему — осмоляльность. Осмоляльность — на килограмм воды "
                   "(мОсм/кг), осмолярность — на литр раствора.",
                   "Реальные экраны LabGuide: Лаб. → Приборы и методики → Клиническая биохимия → Осмометр — та же "
                   "схема и узлы, плюс образцы, у каждого источник; что искажает результат (частицы, пузырьки, "
                   "испарившиеся или вязкие пробы, спирты и ацетон) и перенос пробы из неочищенной ёмкости.",
                   "Калькулятор «Расчётная осмоляльность» (Лаб. → Калькуляторы): из натрия, глюкозы и мочевины; "
                   "добавьте измеренное значение — он покажет осмоляльный зазор (примерные значения)."],
            "uz": ["Muzlash nuqtasi osmometri beshta raqamlangan qismli sxemada: probirkalar, termistor zondi, "
                   "sovutish bloki, sim va displey.",
                   "Muzlash egri chizig‘i: sovutish bloki namunani muzlash nuqtasidan past o‘ta sovitadi, sim "
                   "tebranadi — muzlash boshlanadi, ajralgan issiqlik haroratni platoga ko‘taradi: muzlash nuqtasi.",
                   "Zarracha ko‘p — pasayish chuqurroq, undan esa osmolyallik. Osmolyallik — suv kg iga (mOsm/kg), "
                   "osmolyarlik — eritma litriga.",
                   "LabGuide’ning haqiqiy ekranlari: Lab → Apparatlar va metodikalar → Klinik biokimyo → Osmometr — "
                   "o‘sha sxema va qismlar, namunalar ham, har biri manbali; natijani nima buzadi (zarrachalar, "
                   "pufakchalar, bug‘langan yoki yopishqoq namuna, spirt va aseton) va tozalanmagan idishdan keyingi "
                   "namunaga o‘tish.",
                   "«Hisoblangan osmolyallik» kalkulyatori (Lab → Kalkulyatorlar): natriy, glyukoza va mochevinadan; "
                   "o‘lchangan qiymatni qo‘shsangiz — osmolyal farqni ko‘rsatadi (namunaviy qiymatlar)."],
        },
        app={
            "en": ["LabGuide has an osmometer reference card (Lab → Instruments and methods → Clinical biochemistry): "
                   "the schematic with numbered parts, specimens with their source, limitations, and preanalytic and "
                   "analytic errors.",
                   "Lab → Calculators → Calculated osmolality works from sodium, glucose and urea; with a measured "
                   "value added it shows the osmolal gap.",
                   "Measured or calculated — know which number you read."],
            "ru": ["В LabGuide есть справочная карточка осмометра (Лаб. → Приборы и методики → Клиническая "
                   "биохимия): схема с пронумерованными частями, образцы с источником, ограничения, а также "
                   "преаналитические и аналитические ошибки.",
                   "Лаб. → Калькуляторы → Расчётная осмоляльность считает из натрия, глюкозы и мочевины; с "
                   "добавленным измеренным значением показывает осмоляльный зазор.",
                   "Измерено или рассчитано — знайте, что вы читаете."],
            "uz": ["LabGuide’da osmometr bo‘yicha ma’lumotnoma kartasi bor (Lab → Apparatlar va metodikalar → Klinik "
                   "biokimyo): raqamlangan qismli sxema, manbali namunalar, cheklovlar hamda preanalitik va "
                   "analitik xatolar.",
                   "Lab → Kalkulyatorlar → Hisoblangan osmolyallik natriy, glyukoza va mochevinadan hisoblaydi; "
                   "o‘lchangan qiymat qo‘shilsa, osmolyal farqni ko‘rsatadi.",
                   "O‘lchangan yoki hisoblangan — qaysini o‘qiyotganingizni biling."],
        },
        limits={
            "en": ["Schematic — not an exact model; the curves are illustrative (no numbers on the axes), not a real "
                   "sample or result.",
                   "A reference card and a learning calculator: your laboratory’s SOP and reference intervals decide. "
                   "A calculated osmolality is not a measured osmolality.",
                   "Calculator values on screen are illustrative; the video does not interpret the gap or any value.",
                   "The card in the app is itself marked as not yet expert-reviewed."],
            "ru": ["Схема — не точная модель; кривые иллюстративные (без чисел на осях), это не реальная проба и не "
                   "результат.",
                   "Справочная карточка и учебный калькулятор: решают СОП и референтные интервалы вашей лаборатории. "
                   "Расчётная осмоляльность — не измеренная осмоляльность.",
                   "Значения калькулятора на экране примерные; видео не интерпретирует ни зазор, ни другие значения.",
                   "Сама карточка в приложении помечена как ещё не проверенная экспертом."],
            "uz": ["Sxema — aniq model emas; egri chiziqlar namunaviy (o‘qlarda sonlar yo‘q), haqiqiy namuna yoki "
                   "natija emas.",
                   "Ma’lumotnoma karta va o‘quv kalkulyatori: laboratoriyangiz SOP’i va me’yor oraliqlari hal qiladi. "
                   "Hisoblangan osmolyallik o‘lchangan osmolyallik emas.",
                   "Ekrandagi kalkulyator qiymatlari namunaviy; video farqni ham, boshqa qiymatni ham talqin "
                   "qilmaydi.",
                   "Ilovadagi kartaning o‘zi hali mutaxassis tomonidan tekshirilmagan deb belgilangan."],
        },
        ig={
            "en": ["Two samples freeze — and one plateau sits lower. Why?",
                   "A schematic walk-through in under 80 seconds: the five parts of a freezing-point osmometer, "
                   "supercooling, the stirring wire, the plateau, osmolality per kilogram of water versus osmolarity "
                   "per litre — and what distorts the reading.",
                   "Osmometer reference card and the Calculated osmolality calculator in LabGuide. Measured or "
                   "calculated — know which number you read."],
            "ru": ["Две пробы замерзают — одно плато ниже. Почему?",
                   "Схематичный разбор меньше чем за 80 секунд: пять частей криоскопического осмометра, "
                   "переохлаждение, мешалка, плато, осмоляльность на килограмм воды и осмолярность на литр — и что "
                   "искажает результат.",
                   "Карточка осмометра и калькулятор «Расчётная осмоляльность» в LabGuide. Измерено или рассчитано — "
                   "знайте, что вы читаете."],
            "uz": ["Ikki namuna muzlaydi — bir plato pastroq. Nega?",
                   "Sxemali tahlil 80 soniyadan kamroq vaqtda: muzlash nuqtasi osmometrining beshta qismi, o‘ta "
                   "sovitish, sim, plato, suv kilogrammiga osmolyallik va litrga osmolyarlik — hamda natijani nima "
                   "buzadi.",
                   "LabGuide’da osmometr kartasi va «Hisoblangan osmolyallik» kalkulyatori. O‘lchangan yoki "
                   "hisoblangan — qaysini o‘qiyotganingizni biling."],
        },
        pinned={
            "en": ("Notes: this is a schematic general-principle video, not a method protocol. Curves and calculator "
                   "inputs are illustrative. A calculated osmolality is not a measured one, and the video interprets "
                   "neither; your laboratory’s SOP and reference intervals decide. Narration is English synthetic "
                   "speech. The content is awaiting expert review — corrections are welcome."),
            "ru": ("Заметки: это схематичное видео об общем принципе, а не протокол метода. Кривые и вводимые в "
                   "калькулятор значения иллюстративные. Расчётная осмоляльность — не измеренная, и видео не "
                   "интерпретирует ни ту, ни другую; решают СОП и референтные интервалы вашей лаборатории. Озвучка — "
                   "синтезированная английская речь. Материал ждёт экспертной проверки, поправки приветствуются."),
            "uz": ("Eslatma: bu umumiy tamoyil haqidagi sxematik video, metod protokoli emas. Egri chiziqlar va "
                   "kalkulyatorga kiritilgan qiymatlar namunaviy. Hisoblangan osmolyallik o‘lchangan emas va video "
                   "ikkalasini ham talqin qilmaydi; laboratoriyangiz SOP’i va me’yor oraliqlari hal qiladi. Diktor "
                   "ovozi — sun’iy inglizcha nutq. Material mutaxassis ko‘rigini kutmoqda — tuzatishlar uchun "
                   "rahmat."),
        },
        keywords={
            "en": ["osmometry", "osmometer", "osmolality", "freezing point depression", "supercooling",
                   "osmolal gap", "calculated osmolality", "clinical chemistry", "laboratory instruments", "LabGuide"],
            "ru": ["осмометрия", "осмометр", "осмоляльность", "криоскопия", "понижение точки замерзания",
                   "осмоляльный зазор", "клиническая лаборатория", "лаборант"],
            "uz": ["osmometriya", "osmometr", "osmolyallik", "muzlash nuqtasi pasayishi", "osmolyal farq",
                   "klinik laboratoriya", "laborant"],
        },
        hashtags_topic={
            "en": ["#Osmometry", "#Osmolality", "#Osmometer", "#ClinicalChemistry", "#FreezingPoint",
                   "#LabInstruments", "#BiochemistryLab"],
            "ru": ["#осмометрия", "#осмоляльность", "#осмометр", "#биохимия", "#криоскопия",
                   "#приборылаборатории", "#лабораторныйанализ"],
            "uz": ["#osmometriya", "#osmolyallik", "#osmometr", "#biokimyo", "#muzlashnuqtasi",
                   "#laboratoriyaapparatlari", "#laboratoriyatahlili"],
        },
        thumb_alt={
            "en": "LabGuide logo, the title “Osmometry” with the subtitle “Freezing point → osmolality”, a "
                  "temperature-versus-time chart with two freezing curves A and B whose plateaus sit below a dashed "
                  "“pure water” line, a small schematic of a freezing-point osmometer with five numbered parts, and "
                  "the notice “Illustrative curves — not a real sample or result”.",
            "ru": "Логотип LabGuide, заголовок «Осмометрия» с подзаголовком «Точка замерзания → осмоляльность», "
                  "график температуры от времени с двумя кривыми замерзания A и B, плато которых лежат ниже "
                  "пунктирной линии «чистая вода», небольшая схема криоскопического осмометра с пятью "
                  "пронумерованными частями и пометка «Иллюстративные кривые — не реальная проба».",
            "uz": "LabGuide logotipi, «Osmometriya» sarlavhasi va «Muzlash nuqtasi → osmolyallik» sarlavha osti, "
                  "harorat–vaqt grafigida A va B ikkita muzlash egri chizig‘i — ularning platolari «toza suv» "
                  "punktir chizig‘idan pastda — beshta raqamlangan qismli muzlash nuqtasi osmometrining kichik "
                  "sxemasi hamda «Namunaviy egri chiziqlar — haqiqiy namuna emas» belgisi.",
        },
        chapters=[
            ("hook", T("Why one plateau sits lower, and the osmometer’s parts",
                       "Почему одно плато ниже, и части осмометра",
                       "Nega bir plato pastroq va osmometr qismlari")),
            ("freeze", T("The freezing curve", "Кривая замерзания", "Muzlash egri chizig‘i")),
            ("result", T("From depression to osmolality: per kg, per litre",
                         "От понижения к осмоляльности: на кг и на литр",
                         "Pasayishdan osmolyallikka: kg ga va litrga")),
            ("app_card", T("In LabGuide: the osmometer card", "В LabGuide: карточка осмометра",
                           "LabGuide’da: osmometr kartasi")),
            ("app_limits", T("What distorts the reading", "Что искажает результат", "Natijani nima buzadi")),
            ("app_calc", T("Calculated osmolality and the osmolal gap", "Расчётная осмоляльность и осмоляльный зазор",
                           "Hisoblangan osmolyallik va osmolyal farq")),
        ],
        sources=[],
        evidence=["docs/video/osmometry/CLAIMS_AND_EVIDENCE.md", "docs/video/osmometry/DESCRIPTION.md",
                  "docs/video/osmometry/QA.md",
                  "docs/video/lessons/24_osmometer.md", "assets/instruments/catalog.json lab card a3-bio-osmometer",
                  "docs/VIDEO_FEATURE_INVENTORY.md §1 (calculators: osmolality)"],
        next=["calculators", "photometry"],
        paid=None,
        internal=["Copy checked against lines.*.json, CLAIMS_AND_EVIDENCE.md, DESCRIPTION.md and QA.md of the rendered "
                  "video (78.2 s). The video shows the osmolality calculator, so its bullet stays. Open expert items: "
                  "O6 (principle-level wording supercooling → stirring wire → plateau, NEEDS_EXPERT) and every "
                  "STANDARD_TEXTBOOK row.",
                  "Deliberately not said (kept out of the copy too): the 1.86 °C per osmol/kg constant, reference "
                  "intervals, any meaning of a normal or abnormal gap, sample volume. The app's lab card is itself "
                  "flagged NEEDS_REVIEW (expert_reviewed=false, docs/lab_cards_status.json) and says so: do not call "
                  "it \"verified\" or \"reviewed\"."],
    ),
    # ------------------------------------------------------------------ 8. calculators
    dict(
        id="calculators", order=8, tier="free", verified=True,
        path=T("Lab → Calculators", "Лаб. → Калькуляторы", "Lab → Kalkulyatorlar"),
        title=T(
            "Lab Calculators in LabGuide: eGFR, Input Checks and Dilution",
            "Калькуляторы LabGuide: рСКФ, проверки ввода и разведение",
            "LabGuide kalkulyatorlari: eGFR, kiritish tekshiruvlari, suyultirish",
        ),
        hook={
            "en": ("Creatinine 88, age 45, male: what is the eGFR?",
                   "By hand it is a long formula — and one unit slip changes the answer. A tour of LabGuide’s calculators in about a minute."),
            "ru": ("Креатинин 88, возраст 45, мужчина: какая рСКФ?",
                   "Вручную — длинная формула, и одна ошибка в единицах меняет ответ. Обзор калькуляторов LabGuide — примерно за минуту."),
            "uz": ("Kreatinin 88, yosh 45, erkak: eGFR qancha?",
                   "Qo‘lda — uzun formula, birlikdagi bitta xato javobni o‘zgartiradi. LabGuide kalkulyatorlari — taxminan bir daqiqada."),
        },
        shows={
            "en": ["The question: creatinine 88 µmol/L, age 45, male — what is the eGFR? The app’s own CKD-EPI 2021 "
                   "formula text, and why units matter (creatinine in mg/dL: µmol/L ÷ 88.4).",
                   "Where the calculators are — Lab → Calculators — seventeen of them: clinical formulas, manual "
                   "methods and laboratory tools; “How to use?” shows the steps in the app.",
                   "An eGFR walkthrough on real app screens (illustrative inputs): the fields start empty, a missing "
                   "sex is asked for before calculating, the result shows its KDIGO category and the values you "
                   "entered, and below it the formula, its limitations and the sources.",
                   "Input checks: under 18 eGFR is refused because the equation was built on adults; a glucose of 90 "
                   "in mmol/L gets a unit check.",
                   "SI or conventional units, chosen once in Profile; bench tools such as dilution, C₁V₁ = C₂V₂, from "
                   "your own numbers."],
            "ru": ["Вопрос: креатинин 88 мкмоль/л, возраст 45, мужчина — какая рСКФ? Формула в том виде, как её "
                   "показывает приложение (CKD-EPI 2021), и почему важны единицы (креатинин в мг/дл: мкмоль/л ÷ 88,4).",
                   "Где находятся калькуляторы — Лаб. → Калькуляторы — их семнадцать: клинические формулы, ручные "
                   "методы и лабораторные инструменты; «Как пользоваться?» показывает шаги в приложении.",
                   "Разбор рСКФ на реальных экранах приложения (примерные значения): поля пустые, если не выбран "
                   "пол, приложение спрашивает до расчёта, результат — с категорией KDIGO и введёнными "
                   "значениями, ниже — формула, ограничения и источники.",
                   "Проверки ввода: до 18 лет рСКФ не считается, потому что уравнение создано на взрослых; глюкоза "
                   "90 в ммоль/л вызывает проверку единиц.",
                   "Единицы СИ или обычные — выбираются один раз в профиле; лабораторные инструменты, например "
                   "разведение, C₁V₁ = C₂V₂, по вашим числам."],
            "uz": ["Savol: kreatinin 88 µmol/L, yosh 45, erkak — eGFR qancha? Formula ilova ko‘rsatganidek "
                   "(CKD-EPI 2021) va nega birliklar muhim (kreatinin mg/dL da: µmol/L ÷ 88,4).",
                   "Kalkulyatorlar qayerda — Lab → Kalkulyatorlar — ular o‘n yettita: klinik formulalar, qo‘lda "
                   "usullar va laboratoriya vositalari; «Qanday foydalaniladi?» qadamlarni ilovaning o‘zida "
                   "ko‘rsatadi.",
                   "eGFR ni ilovaning haqiqiy ekranlarida ko‘rib chiqish (namunaviy qiymatlar): maydonlar bo‘sh, "
                   "jins tanlanmasa hisoblashdan oldin so‘raydi, natija KDIGO toifasi va kiritilgan qiymatlar bilan, "
                   "pastda — formula, cheklovlar va manbalar.",
                   "Kiritish tekshiruvlari: 18 yoshdan kichikka eGFR hisoblanmaydi, chunki tenglama kattalarda "
                   "tuzilgan; mmol/L da kiritilgan glyukoza 90 birlik tekshiruvini chiqaradi.",
                   "SI yoki an’anaviy birliklar — profilda bir marta tanlanadi; laboratoriya vositalari, masalan "
                   "suyultirish, C₁V₁ = C₂V₂, o‘z sonlaringizdan."],
        },
        app={
            "en": ["Calculators compute only from the values you enter (the fields start empty); each shows its "
                   "formula, limitations and sources.",
                   "Units: SI or conventional, chosen once in Profile.",
                   "It calculates — you interpret: a learning and checking aid; it does not diagnose, and your "
                   "laboratory’s reference intervals decide."],
            "ru": ["Калькуляторы считают только по введённым вами значениям (поля пустые); у каждого есть формула, "
                   "ограничения и источники.",
                   "Единицы: СИ или обычные — выбираются один раз в профиле.",
                   "Он считает — толкуете вы: вспомогательный расчёт для обучения и проверки; диагноз он не ставит, "
                   "решают референтные интервалы вашей лаборатории."],
            "uz": ["Kalkulyatorlar faqat siz kiritgan qiymatlardan hisoblaydi (maydonlar bo‘sh); har birida formula, "
                   "cheklovlar va manbalar bor.",
                   "Birliklar: SI yoki an’anaviy — profilda bir marta tanlanadi.",
                   "U hisoblaydi — talqin sizniki: o‘rganish va tekshirish vositasi; tashxis qo‘ymaydi, "
                   "laboratoriyangizning me’yor oraliqlari hal qiladi."],
        },
        limits={
            "en": ["All inputs in the video are illustrative, not patient data; every result on screen is computed by "
                   "the app.",
                   "The video does not interpret any result (for example, what a KDIGO category means for a patient).",
                   "The list has 17 rows; one of them explains rather than calculates."],
            "ru": ["Все вводимые в видео значения иллюстративные, это не данные пациентов; каждый результат на экране "
                   "считает приложение.",
                   "Видео не интерпретирует ни один результат (например, что категория KDIGO значит для пациента).",
                   "В списке 17 строк; одна из них объясняет, а не считает."],
            "uz": ["Videodagi barcha kiritishlar namunaviy, bemor ma’lumoti emas; ekrandagi har bir natijani ilova "
                   "hisoblaydi.",
                   "Video hech bir natijani talqin qilmaydi (masalan, KDIGO toifasi bemor uchun nimani anglatishini).",
                   "Ro‘yxatda 17 qator bor; ulardan biri hisoblamaydi, tushuntiradi."],
        },
        ig={
            "en": ["Creatinine 88, age 45, male: what is the eGFR?",
                   "A tour of LabGuide’s calculators in about a minute: eGFR from creatinine, age and sex on real app "
                   "screens — empty fields, input checks, the KDIGO category, the formula, limitations and sources — "
                   "then SI or conventional units and bench tools like dilution (illustrative inputs).",
                   "It calculates — you interpret. A learning and checking aid; it doesn’t diagnose. Find it in "
                   "Lab → Calculators."],
            "ru": ["Креатинин 88, возраст 45, мужчина: какая рСКФ?",
                   "Обзор калькуляторов LabGuide примерно за минуту: рСКФ по креатинину, возрасту и полу на реальных "
                   "экранах — пустые поля, проверки ввода, категория KDIGO, формула, ограничения и источники — затем "
                   "единицы СИ или обычные и лабораторные инструменты вроде разведения (примерные значения).",
                   "Он считает — толкуете вы. Вспомогательный расчёт для обучения и проверки; диагноз не ставит. "
                   "Раздел: Лаб. → Калькуляторы."],
            "uz": ["Kreatinin 88, yosh 45, erkak: eGFR qancha?",
                   "LabGuide kalkulyatorlariga taxminan bir daqiqalik sayohat: kreatinin, yosh va jinsdan eGFR "
                   "ilovaning haqiqiy ekranlarida — bo‘sh maydonlar, kiritish tekshiruvlari, KDIGO toifasi, formula, "
                   "cheklovlar va manbalar — so‘ng SI yoki an’anaviy birliklar va suyultirish kabi laboratoriya "
                   "vositalari (namunaviy qiymatlar).",
                   "U hisoblaydi — talqin sizniki. O‘rganish va tekshirish vositasi; tashxis qo‘ymaydi. Bo‘lim: "
                   "Lab → Kalkulyatorlar."],
        },
        pinned={
            "en": ("Notes: all inputs in this video are illustrative, not patient data, and every result shown is "
                   "computed by the app. Calculators do not interpret results; your laboratory’s reference intervals "
                   "decide. Narration is English synthetic speech. The content is awaiting expert review — "
                   "corrections are welcome. Which calculator is missing for you?"),
            "ru": ("Заметки: все вводимые в видео значения иллюстративные, это не данные пациентов, а каждый "
                   "показанный результат считает приложение. Калькуляторы не интерпретируют результаты; решают "
                   "референтные интервалы вашей лаборатории. Озвучка — синтезированная английская речь. Материал "
                   "ждёт экспертной проверки, поправки приветствуются. Какого калькулятора вам не хватает?"),
            "uz": ("Eslatma: videodagi barcha kiritishlar namunaviy, bemor ma’lumoti emas, ko‘rsatilgan har bir "
                   "natijani ilova hisoblaydi. Kalkulyatorlar natijalarni talqin qilmaydi; laboratoriyangizning "
                   "me’yor oraliqlari hal qiladi. Diktor ovozi — sun’iy inglizcha nutq. Material mutaxassis "
                   "ko‘rigini kutmoqda. Sizga qaysi kalkulyator yetishmaydi?"),
        },
        keywords={
            "en": ["lab calculators", "clinical calculators", "eGFR calculator", "CKD-EPI 2021", "KDIGO",
                   "dilution calculator", "unit check", "SI units", "clinical chemistry", "LabGuide"],
            "ru": ["лабораторные калькуляторы", "клинические калькуляторы", "рСКФ", "СКФ", "CKD-EPI 2021", "KDIGO",
                   "разведение", "лаборант"],
            "uz": ["laboratoriya kalkulyatorlari", "klinik kalkulyatorlar", "eGFR", "CKD-EPI 2021", "KDIGO",
                   "suyultirish", "laborant"],
        },
        hashtags_topic={
            "en": ["#eGFR", "#Creatinine", "#LabCalculator", "#ClinicalChemistry", "#Dilution", "#SIUnits",
                   "#KDIGO"],
            "ru": ["#рСКФ", "#креатинин", "#калькулятор", "#биохимия", "#разведение", "#единицыСИ",
                   "#KDIGO"],
            "uz": ["#eGFR", "#kreatinin", "#kalkulyator", "#biokimyo", "#suyultirish", "#SIbirliklari",
                   "#KDIGO"],
        },
        thumb_alt={
            "en": "LabGuide logo, the title “Lab calculators” with the subtitle “Formula, limits, source”, a card with "
                  "the app’s eGFR formula (CKD-EPI 2021), a phone screen showing an eGFR result with its KDIGO "
                  "category, the entered values, the formula and its limitations, and the notice “Real app screens · "
                  "illustrative values”.",
            "ru": "Логотип LabGuide, заголовок «Калькуляторы» с подзаголовком «Формула, ограничения, источник», "
                  "карточка с формулой рСКФ из приложения (CKD-EPI 2021), экран телефона с результатом рСКФ, "
                  "категорией KDIGO, введёнными значениями, формулой и ограничениями и пометка «Реальные экраны · "
                  "примерные значения».",
            "uz": "LabGuide logotipi, «Kalkulyatorlar» sarlavhasi va «Formula, cheklov, manba» sarlavha osti, "
                  "ilovadagi eGFR formulasi kartasi (CKD-EPI 2021), eGFR natijasi, KDIGO toifasi, kiritilgan "
                  "qiymatlar, formula va cheklovlar ko‘rsatilgan telefon ekrani hamda «Haqiqiy ekranlar · namunaviy "
                  "qiymatlar» belgisi.",
        },
        chapters=[
            ("hook", T("eGFR by hand, and where the calculators are", "рСКФ вручную и где находятся калькуляторы",
                       "eGFR qo‘lda va kalkulyatorlar qayerda")),
            ("app_howto", T("“How to use?” and the eGFR form", "«Как пользоваться?» и форма рСКФ",
                            "«Qanday foydalaniladi?» va eGFR shakli")),
            ("app_refs", T("Formula, limitations, sources and input checks",
                           "Формула, ограничения, источники и проверки ввода",
                           "Formula, cheklovlar, manbalar va kiritish tekshiruvlari")),
            ("app_units", T("Units in Profile and the dilution tool", "Единицы в профиле и разведение",
                            "Profildagi birliklar va suyultirish")),
        ],
        sources=[],
        evidence=["docs/video/calculators/CLAIMS_AND_EVIDENCE.md", "docs/video/calculators/DESCRIPTION.md",
                  "docs/video/calculators/QA.md", "docs/video/04_kalkulyatorlar.md",
                  "docs/VIDEO_FEATURE_INVENTORY.md §1 (calculators)"],
        next=["osmometry", "leukocyte"],
        paid=None,
        internal=["Free today. Copy checked against lines.*.json, CLAIMS_AND_EVIDENCE.md, DESCRIPTION.md and QA.md of "
                  "the rendered video (64.0 s). The video is an eGFR walkthrough plus a unit check, a dilution tool "
                  "and the units setting: anion gap and corrected calcium are NOT in the video, so the copy no longer "
                  "names them.",
                  "\"Seventeen\" is the number of rows in the calculators list (inventory count 2026-10-25; K4): one "
                  "row (colour index) explains why the app recommends MCH/MCHC instead of calculating. Re-check the "
                  "count in the build being advertised.",
                  "RU uses «рСКФ» as in the video; «СКФ» stays as a search keyword and in older tags."],
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
