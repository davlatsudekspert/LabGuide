"""LabGuide apparatlar katalogi manbasi → assets/instruments/catalog.json.

    python3 tool/instrument_catalog_src.py

Qoidalar (docs/DECISIONS.md, D-36):
- Har fakt ishlab chiqaruvchining rasmiy sahifasi/hujjati (yoki regulyator
  hujjati)dan **so'zma-so'z** iqtibos va manba id bilan. Manbada yo'q narsa
  yozilmaydi (``null``) — ilova “manbada ko'rsatilmagan” deydi.
- Kundalik parvarish bosqichlari faqat rasmiy hujjatda ochiq bo'lsa.
  Hozircha birorta Phase 1 ishlab chiqaruvchi ularni ochiq e'lon qilmagan.
- Rasm faqat erkin litsenziyali (muallif, litsenziya, manba sahifasi bilan).
- Holat: ``device_info`` (apparat ma'lumoti), ``ifu_available`` (rasmiy
  qo'llanma versiyasi bilan qo'lda), ``expert_reviewed`` (mutaxassis
  tekshirgan). Oxirgi ikkisi dalilsiz qo'yilmaydi (validator tekshiradi).
"""
import json
import pathlib

ACCESSED = "2026-10-09"
OUT = pathlib.Path(__file__).resolve().parent.parent / "assets/instruments/catalog.json"


def t(uz, ru, en):
    return {"uz": uz, "ru": ru, "en": en}


def q(quote, src):
    return {"quote": quote, "source": src}


def fact(label, value, src):
    return {"label": label, "value": value, "source": src}


L_THROUGHPUT = t("Unumdorlik", "Производительность", "Throughput")
L_MENU = t("Testlar menyusi", "Меню тестов", "Assay menu")
L_ISE = t("ISE (elektrolitlar)", "ISE (электролиты)", "ISE (electrolytes)")
L_POSITIONS = t("Joylar", "Позиции", "Positions")
L_PARAMS = t("Parametrlar", "Параметры", "Parameters")
L_SAMPLE = t("Namuna hajmi", "Объём пробы", "Sample volume")
L_REACTION = t("Reaksiya tizimi", "Реакционная система", "Reaction system")
L_CAL = t("Kalibrlash", "Калибровка", "Calibration")
L_LAMP = t("Lampa resursi", "Ресурс лампы", "Lamp life")
L_OPEN = t("Ochiq kanallar", "Открытые каналы", "Open channels")
L_TEMP = t("Ish harorati", "Рабочая температура", "Operating temperature")

CATEGORIES = [
    {
        "id": "chemistry",
        "name": t("Biokimyo", "Биохимия", "Clinical chemistry"),
        "sub": t(
            "Fotometrik va ISE analizatorlar",
            "Фотометрические анализаторы и ISE",
            "Photometric analyzers and ISE",
        ),
        "terms": ["biokimyo", "biokimyoviy", "биохим", "chemistry",
                  "clinical chemistry", "фотометр", "photometer", "fotometr"],
    },
    {
        "id": "hematology",
        "name": t("Gematologiya", "Гематология", "Hematology"),
        "sub": t(
            "Qon hujayralari sanagichlari (3 va 5 qismli)",
            "Счётчики клеток крови (3- и 5-diff)",
            "Blood cell counters (3- and 5-part diff)",
        ),
        "terms": ["gematologiya", "gematolog", "гематолог", "hematology",
                  "haematology", "cbc", "qon", "кров", "blood", "oak", "оак"],
    },
    {
        "id": "immunoassay",
        "name": t("Immunokimyo", "Иммунохимия", "Immunochemistry"),
        "sub": t(
            "Xemilyuminessent immunoanalizatorlar",
            "Хемилюминесцентные иммуноанализаторы",
            "Chemiluminescence immunoassay analyzers",
        ),
        "terms": ["immun", "иммун", "immunoassay", "clia", "ecl",
                  "хемилюмин", "gormon", "гормон", "hormone"],
    },
    {
        "id": "urinalysis",
        "name": t("Siydik tahlili", "Анализ мочи", "Urinalysis"),
        "sub": t(
            "Test-chiziq o'quvchilar va cho'kma mikroskopiyasi",
            "Анализаторы тест-полосок и осадка",
            "Strip readers and sediment analyzers",
        ),
        "terms": ["siydik", "peshob", "моча", "мочи", "urine", "urinalysis",
                  "осадок", "sediment", "cho'kma"],
    },
]

MAKERS = [
    {
        "id": "mindray", "name": "Mindray", "phase": 1,
        "website": "https://www.mindray.com/en/products/laboratory-diagnostics",
        "docs": {
            "name": "Mindray IVD eDocuments",
            "url": "https://www.mindray.com/en/resources-center/ivd-edocs",
            "login": False,
            "note": t(
                "Login so'ramaydi. 2026-10-09 holatida faqat gematologiya reagent/nazorat IFU'lari bor (hujjat nomi, versiya, Part Number). Apparat qo'llanmalari bu yerda yo'q.",
                "Без входа. На 2026-10-09 только IFU гематологических реагентов/контролей (название, версия, Part Number). Руководств к приборам нет.",
                "No login. As of 2026-10-09 it lists only hematology reagent/control IFUs (document name, version, part number). Instrument manuals are not there.",
            ),
        },
    },
    {
        "id": "human", "name": "HUMAN", "phase": 1,
        "website": "https://www.human.de",
        "docs": {
            "name": "HUMAN target value sheets",
            "url": "https://www.human.de/target-value-sheets/",
            "login": None,
            "note": t(
                "Kalibrator/nazorat qiymatlar varaqlari shu sahifada (lot bo'yicha). Sayt avtomatik so'rovlarni bloklagani uchun qolgan bo'limlar tekshirilmadi.",
                "Листы целевых значений калибраторов/контролей (по лоту). Остальные разделы не проверены: сайт блокирует автоматический доступ.",
                "Calibrator/control target value sheets (by lot). Other sections were not verified: the site blocks automated access.",
            ),
        },
    },
    {
        "id": "roche", "name": "Roche Diagnostics", "phase": 1,
        "website": "https://diagnostics.roche.com",
        "docs": {
            "name": "Roche eLabDoc",
            "url": "https://elabdoc-prod.roche.com/eLD/web/",
            "login": False,
            "note": t(
                "Asosiy qidiruv loginsiz: katalog raqami (REF), lot, hujjat ID yoki nomi bo'yicha. Method Sheet / IFU shu yerda. Operator qo'llanmalari va qiymat varaqlari — mijoz logini bilan.",
                "Базовый поиск без входа: по каталожному номеру (REF), лоту, ID или названию документа. Method Sheet / IFU здесь. Руководства оператора и листы значений — с логином клиента.",
                "Basic search without login: by catalog number (REF), lot, document ID or title. Method sheets / IFUs are here. Operator manuals and value sheets need a customer login.",
            ),
        },
    },
    {
        "id": "abbott", "name": "Abbott", "phase": 1,
        "website": "https://www.corelaboratory.abbott",
        "docs": {
            "name": "Abbott Lab Central",
            "url": "https://labcentral.corelaboratory.abbott/int/en/faq.html",
            "login": True,
            "note": t(
                "Faqat Abbott Core Laboratory mijozlari uchun: ro'yxatdan o'tish mijoz raqami va apparat seriya raqami bilan. Technical Library'da IFU va COA bor.",
                "Только для клиентов Abbott Core Laboratory: регистрация по номеру клиента и серийному номеру прибора. В Technical Library — IFU и COA.",
                "Abbott Core Laboratory customers only: registration with customer number and instrument serial number. The Technical Library holds IFUs and COAs.",
            ),
        },
    },
    # Keyingi bosqich: modellar hali kataloglanmagan.
    {"id": "beckman", "name": "Beckman Coulter", "phase": 2,
     "website": "https://www.beckmancoulter.com",
     "docs": {"name": "Beckman Coulter Tech Docs",
              "url": "https://www.beckmancoulter.com/support/tech-docs",
              "login": None, "note": None}},
    {"id": "siemens", "name": "Siemens Healthineers", "phase": 2,
     "website": "https://www.siemens-healthineers.com",
     "docs": {"name": "Siemens Healthineers Document Library",
              "url": "https://www.siemens-healthineers.com/en-uk/services/laboratory-diagnostics/service-and-support/technical-documentation",
              "login": True, "note": None}},
    {"id": "sysmex", "name": "Sysmex", "phase": 2,
     "website": "https://www.sysmex.com", "docs": None},
    {"id": "horiba", "name": "HORIBA Medical", "phase": 2,
     "website": "https://www.horiba.com", "docs": None},
    {"id": "erba", "name": "Erba", "phase": 2,
     "website": "https://www.erbalachema.com/en/",
     "docs": {"name": "Erba Lachema — Diagnostic kits instructions",
              "url": "https://www.erbalachema.com/en/product-support/instructions/instructions-diagnostic-kits/",
              "login": False, "note": None}},
    {"id": "biosystems", "name": "BioSystems", "phase": 2,
     "website": "https://www.biosystems.global", "docs": None},
]

SOURCES = {
    # Mindray
    "mr-bs240": ("Mindray — BS-240 product page", "https://www.mindray.com/en/products/laboratory-diagnostics/chemistry/small-test-volume/bs-240", None),
    "mr-bs480": ("Mindray — BS-480 product page", "https://www.mindray.com/en/products/laboratory-diagnostics/chemistry/medium-test-volume/bs-480", None),
    "mr-bs480-br": ("Mindray — BS-480 brochure", "https://www.mindray.com/content/dam/xpace/en_in/resources/brochures/bs-480-product-brochure-en_in.pdf", "P/N ENG-BS-480-210285x8P-20171017"),
    "mr-bc5390": ("Mindray — BC-5390 product page", "https://www.mindray.com/en/products/laboratory-diagnostics/hematology/5-part-differential-analyzers/bc-5390", None),
    "fda-k160429": ("FDA 510(k) decision summary K160429 (BC-5390)", "https://www.accessdata.fda.gov/cdrh_docs/reviews/K160429.pdf", "K160429"),
    "mr-bc30s": ("Mindray — BC-30s product page", "https://www.mindray.com/en/products/laboratory-diagnostics/hematology/3-part-differential-analyzers/bc-30s", None),
    "mr-bc6200": ("Mindray — BC-6200 product page", "https://www.mindray.com/en/products/laboratory-diagnostics/hematology/5-part-differential-analyzers/bc-6200", None),
    "mr-bc6000-br": ("Mindray — BC-6000 series brochure", "https://www.mindray.com/content/dam/xpace/en/resources/brochure/bc-6000-product-brochure.pdf", "P/N ENG-BC-6000-210285X10P-20190409"),
    "mr-cl900i": ("Mindray — CL-900i product page", "https://www.mindray.com/en/products/laboratory-diagnostics/chemiluminescence-immunoassay/small-test-volume/cl-900i", None),
    "mr-cl900i-br": ("Mindray — CL-900i brochure", "https://www.mindray.com/content/dam/xpace/en/resources/brochure/cl-900i-product-brochure.pdf", "P/N ENG-CL-900i-210285X6P-20220530"),
    "mr-cl1200i": ("Mindray — CL-1200i product page", "https://www.mindray.com/en/products/laboratory-diagnostics/chemiluminescence-immunoassay/medium-test-volume/cl-1200i", None),
    "mr-eu5600": ("Mindray — EU-5600 Pro / EU-5300 Pro product page", "https://www.mindray.com/en/products/laboratory-diagnostics/urinalysis/urinalysis-automation-line/eu-5600-pro-eu-5300-pro", None),
    # HUMAN
    "hu-hs600": ("HUMAN — HumaStar 600 flyer", "https://www.human.de/01_CoreLab_DX/Clinical_Chemistry/HumaStar_Systems/HumaStar_600/Marketing%20Material/981163_Flyer_HumaStar600_EN.PDF", "981163/2023-09"),
    "hu-hl4000": ("HUMAN — HumaLyzer 4000 flyer", "https://www.human.de/01_CoreLab_DX/Clinical_Chemistry/HumaLyzer_Photometers/HumaLyzer_4000/Marketing%20Material/981015_Flyer_HumaLyzer4000_EN.PDF", "981015/2021-11"),
    "hu-hc5d": ("HUMAN — HumaCount 5D flyer", "https://www.human.de/01_CoreLab_DX/Hematology/HumaCount_5-part_Systems/HumaCount_5D/Marketing%20Material/981646_Flyer_HumaCount5D_EN.PDF", "981646/2021-04"),
    "hu-hc30ts": ("HUMAN — HumaCount 80TS / 30TS flyer", "https://www.human.de/01_CoreLab_DX/Hematology/HumaCount_3-part_Systems/HumaCount_80TS_30TS/Marketing%20Material/981642_Flyer_HumaCount80TS_30TS_EN.PDF", "981642/2024-04"),
    "rst-71783": ("Rosstandart type description No. 71783-18 (HumaCount 30TS/80TS), via all-pribors.ru mirror", "https://all-pribors.ru/docs/71783-18.pdf", "71783-18"),
    "hu-clia150": ("HUMAN — HumaCLIA 150 flyer", "https://www.human.de/01_CoreLab_DX/CLIA/HumaCLIA_System/HumaCLIA_150/Marketing%20Material/981022_Flyer_HumaCLIA150_EN.PDF", "981022/2024-03"),
    # Roche
    "ro-c311": ("Roche — cobas c 311 analyzer", "https://diagnostics.roche.com/us/en/products/instruments/cobas-c-311-ins-2043.html", None),
    "ro-docs": ("Roche — technical documents (eLabDoc)", "https://diagnostics.roche.com/us/en/eservice-overview/technical-documents.html", None),
    "ro-c303": ("Roche — cobas c 303 analytical unit", "https://diagnostics.roche.com/global/en/products/instruments/cobas-c-303-ins-6347.html", None),
    "ro-pure": ("Roche — cobas pure integrated solutions", "https://diagnostics.roche.com/global/en/products/systems/cobas-pure-integrated-solutions-sys-351.html", None),
    "ro-e411": ("Roche — cobas e 411 analyzer", "https://diagnostics.roche.com/global/en/products/instruments/cobas-e-411.html", None),
    "ro-e402": ("Roche — cobas e 402 analytical unit", "https://diagnostics.roche.com/nl/en/products/instruments/cobas-e-402-ins-6350.html", None),
    "ro-u411": ("Roche — cobas u 411 urine analyzer", "https://diagnostics.roche.com/se/en/products/instruments/cobas-u-411-ins-2009.html", None),
    "ro-6500": ("Roche — cobas 6500 urine analyzer series", "https://diagnostics.roche.com/au/en/products/systems/cobas-6500-system-sys-250.html", None),
    # Abbott
    "ab-c4000": ("Abbott — ARCHITECT c4000", "https://www.corelaboratory.abbott/us/en/offerings/brands/architect/architect-c4000", None),
    "ab-alinity-ci": ("Abbott — Alinity ci-series", "https://www.corelaboratory.abbott/int/en/offerings/brands/alinity/alinity-ci-series.html", None),
    "ab-emerald": ("Abbott — CELL-DYN Emerald 22 AL", "https://www.corelaboratory.abbott/int/en/offerings/brands/cell-dyn/cell-dyn-emerald-22-al.html", None),
    "ab-hq": ("Abbott — Alinity h-series", "https://www.corelaboratory.abbott/int/en/offerings/brands/alinity/Alinity-h-hematology-system.html", None),
    "ab-i1000": ("Abbott — ARCHITECT i1000SR", "https://www.corelaboratory.abbott/int/en/offerings/brands/architect/architect-i1000SR", None),
    "fda-k041192": ("FDA 510(k) K041192 (ARCHITECT assay)", "https://www.accessdata.fda.gov/cdrh_docs/pdf4/K041192.pdf", "K041192"),
}

MANUAL_NOT_PUBLIC = {
    "access": "not_public",
    "note": t(
        "Operator qo'llanmasi ishlab chiqaruvchi saytida ochiq e'lon qilinmagan. Apparat bilan kelgan nusxadan yoki rasmiy distribyutor/servisdan foydalaning va versiyasini “Mening apparatim”ga yozib qo'ying.",
        "Руководство оператора не опубликовано открыто на сайте производителя. Используйте экземпляр, поставленный с прибором, или запросите у официального дистрибьютора/сервиса и запишите его версию в «Мой прибор».",
        "The operator's manual is not published openly on the manufacturer's site. Use the copy supplied with the instrument or ask the official distributor/service, and record its version under “My instrument”.",
    ),
}


def manual_login(maker_name):
    return {
        "access": "login",
        "note": t(
            f"{maker_name} operator qo'llanmasi mijoz logini bilan beriladi (pastdagi hujjatlar portali).",
            f"Руководство оператора {maker_name} доступно с логином клиента (портал документов ниже).",
            f"The {maker_name} operator's manual is available with a customer login (documents portal below).",
        ),
    }


def model(**kw):
    kw.setdefault("aliases", [])
    kw.setdefault("local_names", {})
    kw.setdefault("facts", [])
    kw.setdefault("maintenance", [])
    kw.setdefault("reagent_system", {"kind": "unknown", "quote": None})
    kw.setdefault("validated_reagents", [])
    kw.setdefault("image", None)
    kw.setdefault("market_note", None)
    kw.setdefault("status", "device_info")
    kw.setdefault("purpose", None)
    kw.setdefault("principle", None)
    return kw


MODELS = [
    # ------------------------------------------------------------ chemistry
    model(
        id="mindray-bs-240", maker="mindray", model="BS-240", category="chemistry",
        aliases=["BS240", "БС-240"],
        local_names={"ru": "BS-240 Биохимический анализатор"},
        kind=t("Avtomatik biokimyoviy analizator", "Автоматический биохимический анализатор", "Automated chemistry analyzer"),
        purpose={
            "text": t(
                "Ko'p funksiyali, stol ustiga qo'yiladigan biokimyo analizatori.",
                "Многофункциональный настольный биохимический анализатор.",
                "Multi-functional benchtop chemistry analyzer.",
            ),
            "quotes": [q("multi-functional benchtop chemistry analyzer with a throughput of 200 tests per hour", "mr-bs240")],
        },
        facts=[
            fact(L_THROUGHPUT, "200 tests per hour", "mr-bs240"),
            fact(t("Reagent joylari", "Позиции реагентов", "Reagent positions"), "40 positions for reagent", "mr-bs240"),
        ],
        maintenance=[q("Step-by-step maintenance guide for easy operation", "mr-bs240")],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="mindray-bs-480", maker="mindray", model="BS-480", category="chemistry",
        aliases=["BS480", "БС-480"],
        local_names={"ru": "BS-480 Биохимический анализатор"},
        kind=t("Avtomatik biokimyoviy analizator (pol ustiga)", "Автоматический биохимический анализатор (напольный)", "Automated chemistry analyzer (floor-standing)"),
        purpose={
            "text": t(
                "Pol ustiga o'rnatiladigan, diskret, random access biokimyo analizatori.",
                "Напольный дискретный биохимический анализатор с произвольным доступом.",
                "Floor-standing, discrete, random-access clinical chemistry analyzer.",
            ),
            "quotes": [q("A floor-standing, discrete and random access clinical chemistry analyzer offering constant throughput of 400 tests per hour.", "mr-bs480")],
        },
        principle={
            "text": t(
                "Yutilish fotometriyasi va turbidimetriya (difraksion panjarali fotometr); elektrolitlar uchun ixtiyoriy ISE (K⁺, Na⁺, Cl⁻).",
                "Абсорбционная фотометрия и турбидиметрия (фотометр с дифракционной решёткой); опционально ISE (K⁺, Na⁺, Cl⁻).",
                "Absorbance photometry and turbidimetry (grating photometer); optional ISE (K⁺, Na⁺, Cl⁻).",
            ),
            "quotes": [
                q("Measuring principles: Absorbance Photometry, Turbidimetry", "mr-bs480-br"),
                q("Reversed optics, grating photometry", "mr-bs480-br"),
            ],
        },
        facts=[
            fact(L_THROUGHPUT, "400 photometric tests/hour, up to 240 tests/hour for ISE", "mr-bs480-br"),
            fact(L_TEMP, "37°C", "mr-bs480-br"),
        ],
        maintenance=[q("Built in Step-by-Step maintenance guide", "mr-bs480-br")],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="human-humastar-600", maker="human", model="HumaStar 600", category="chemistry",
        aliases=["HumaStar600", "Humastar 600", "REF 16660", "16660"],
        kind=t("Avtomatik biokimyoviy analizator", "Автоматический биохимический анализатор", "Automated chemistry analyzer"),
        purpose={
            "text": t(
                "O'rta unumdorlikdagi random access biokimyo tizimi.",
                "Биохимическая система среднего потока с произвольным доступом.",
                "Medium-throughput random-access clinical chemistry system.",
            ),
            "quotes": [q("Medium throughput random access system", "hu-hs600")],
        },
        principle={
            "text": t(
                "Avtomatik random access biokimyo tizimi; elektrolitlar uchun ichki ISE moduli. Fotometr turi flayerda ko'rsatilmagan.",
                "Автоматическая биохимическая система с произвольным доступом; встроенный модуль ISE для электролитов. Тип фотометра во флаере не указан.",
                "Automated random-access chemistry system with a built-in ISE module for electrolytes. The photometer type is not stated in the flyer.",
            ),
            "quotes": [q("Random access clinical chemistry system", "hu-hs600"), q("built-in ISE Module", "hu-hs600")],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 600 tests per hour", "hu-hs600"),
            fact(L_ISE, "Up to 780 tests per hour with ISE", "hu-hs600"),
            fact(L_POSITIONS, "95 positions for samples; 48 cooled positions for reagents", "hu-hs600"),
            fact(L_OPEN, "5 open channels for user defined settings", "hu-hs600"),
        ],
        reagent_system={"kind": "partly_open", "quote": q("5 open channels for user defined settings", "hu-hs600")},
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="human-humalyzer-4000", maker="human", model="HumaLyzer 4000", category="chemistry",
        aliases=["Humalyzer 4000", "HumaLyzer4000", "HL4000", "REF 18250", "18250"],
        kind=t("Yarim avtomatik fotometr", "Полуавтоматический фотометр", "Semi-automatic photometer"),
        purpose={
            "text": t(
                "Yarim avtomatik biokimyo fotometri: namuna va reagentni laborant qo'shadi, o'lchash va hisoblashni apparat bajaradi.",
                "Полуавтоматический биохимический фотометр: пробу и реагент вносит лаборант, измерение и расчёт выполняет прибор.",
                "Semi-automatic chemistry photometer: the operator pipettes sample and reagent; the instrument measures and calculates.",
            ),
            "quotes": [q("Semi-automatic photometer", "hu-hl4000")],
        },
        principle={
            "text": t(
                "Fotometriya (kolorimetriya, UV-testlar, turbidimetriya); 8 ta interferension filtrli referens kanal optikasi. O'lchash oqim kyuvetasi yoki kvadrat kyuvetada.",
                "Фотометрия (колориметрия, УФ-тесты, турбидиметрия); оптика с опорным каналом и 8 интерференционными фильтрами. Измерение в проточной или квадратной кювете.",
                "Photometry (colorimetry, UV tests, turbidimetry) with reference-channel optics and 8 interference filters; measurement in a flow cell or square cuvette.",
            ),
            "quotes": [
                q("Photometry (colorimetry, UV-tests, turbidimetry)", "hu-hl4000"),
                q("Reference channel optics with 8 different interference filters", "hu-hl4000"),
            ],
        },
        facts=[
            fact(L_REACTION, "Flow cell or square cuvette", "hu-hl4000"),
            fact(t("Inkubator", "Инкубатор", "Incubator"), "Built-in: 10 round, 2 square positions", "hu-hl4000"),
            fact(t("Metodlar", "Методы", "Methods"), "144 method positions; more than 50 validated settings for HUMAN reagents", "hu-hl4000"),
            fact(L_LAMP, "Lamp life time of > 5000 h", "hu-hl4000"),
        ],
        maintenance=[
            q("Automatic maintenance reminders (e.g. cleaning)", "hu-hl4000"),
            q("No cleaning of interference filters required (sealed photometer module)", "hu-hl4000"),
            q("Basic wear and tear parts can be replaced without special tools by laboratory staff", "hu-hl4000"),
        ],
        reagent_system={"kind": "open", "quote": q("Reagent system Open", "hu-hl4000")},
        validated_reagents=[
            {"analyte": "glucose-plasma-fasting", "name": "GLUCOSE liquicolor", "refs": ["10121", "10260"], "source": "hu-hl4000"},
            {"analyte": "glucose-plasma-fasting", "name": "GLUCOSE liquiUV mono", "refs": ["10786"], "source": "hu-hl4000"},
            {"analyte": "hba1c", "name": "HbA1c liquidirect", "refs": ["10770"], "source": "hu-hl4000"},
            {"analyte": "creatinine", "name": "auto-CREATININE liquicolor", "refs": ["10052"], "source": "hu-hl4000"},
            {"analyte": "creatinine", "name": "CREATININE (enzym) liquicolor", "refs": ["10053"], "source": "hu-hl4000"},
            {"analyte": "urea", "name": "UREA liquiUV", "refs": ["10521"], "source": "hu-hl4000"},
            {"analyte": "uric-acid", "name": "URIC ACID liquicolor", "refs": ["10690", "10691"], "source": "hu-hl4000"},
            {"analyte": "uric-acid", "name": "URIC ACID liquicolorplus", "refs": ["10694"], "source": "hu-hl4000"},
            {"analyte": "bilirubin-total", "name": "auto-BILIRUBIN-T liquicolor", "refs": ["10742"], "source": "hu-hl4000"},
            {"analyte": "bilirubin-direct", "name": "auto-BILIRUBIN-D liquicolor", "refs": ["10741"], "source": "hu-hl4000"},
            {"analyte": "cholesterol-total", "name": "CHOLESTEROL liquicolor", "refs": ["10017", "10019", "10028"], "source": "hu-hl4000"},
            {"analyte": "hdl-c", "name": "HDL CHOLESTEROL liquicolor", "refs": ["10084", "10284"], "source": "hu-hl4000"},
            {"analyte": "ldl-c", "name": "LDL CHOLESTEROL liquicolor", "refs": ["10094", "10294"], "source": "hu-hl4000"},
            {"analyte": "triglycerides", "name": "TRIGLYCERIDES liquicolor mono", "refs": ["10720P", "10724", "10725"], "source": "hu-hl4000"},
            {"analyte": "albumin", "name": "ALBUMIN liquicolor", "refs": ["10560", "156004"], "source": "hu-hl4000"},
            {"analyte": "total-protein", "name": "TOTAL PROTEIN liquicolor", "refs": ["157004", "10570"], "source": "hu-hl4000"},
            {"analyte": "crp", "name": "CRP", "refs": ["11241"], "source": "hu-hl4000"},
            {"analyte": "sodium", "name": "SODIUM liquicolor", "refs": ["10113"], "source": "hu-hl4000"},
            {"analyte": "chloride", "name": "CHLORIDE liquicolor", "refs": ["10115"], "source": "hu-hl4000"},
            {"analyte": "calcium", "name": "CALCIUM liquicolor", "refs": ["10011"], "source": "hu-hl4000"},
            {"analyte": "magnesium", "name": "MAGNESIUM liquicolor", "refs": ["10010"], "source": "hu-hl4000"},
            {"analyte": "phosphate", "name": "PHOSPHORUS liquirapid", "refs": ["10027"], "source": "hu-hl4000"},
            {"analyte": "lipase", "name": "LIPASE liquicolor", "refs": ["12006", "12026"], "source": "hu-hl4000"},
            {"analyte": "ck", "name": "CK NAC activated liquiUV", "refs": ["12015"], "source": "hu-hl4000"},
            {"analyte": "alt", "name": "GPT (ALAT) IFCC mod. liquiUV", "refs": ["12212", "12012", "12022", "12032"], "source": "hu-hl4000"},
            {"analyte": "ast", "name": "GOT (ASAT) IFCC mod. liquiUV", "refs": ["12211", "12011", "12021", "12031"], "source": "hu-hl4000"},
            {"analyte": "ggt", "name": "gamma-GT liquicolor", "refs": ["12213", "12013", "12023", "12033"], "source": "hu-hl4000"},
        ],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="roche-cobas-c-311", maker="roche", model="cobas c 311", category="chemistry",
        aliases=["c311", "c 311", "cobas c311", "кобас с311"],
        kind=t("Avtomatik biokimyoviy analizator", "Автоматический биохимический анализатор", "Automated chemistry analyzer"),
        purpose={
            "text": t(
                "To'liq avtomatik, diskret biokimyo analizatori.",
                "Полностью автоматический дискретный биохимический анализатор.",
                "Fully automated, discrete clinical chemistry analyzer.",
            ),
            "quotes": [q("The cobas c 311 analyzer is a fully automated, discrete clinical chemistry analyzer", "ro-c311")],
        },
        principle={
            "text": t(
                "Fotometrik testlar va natriy, kaliy, xlor uchun ion-selektiv elektrod (ISE).",
                "Фотометрические тесты и ион-селективный электрод (ISE) для натрия, калия и хлора.",
                "Photometric tests plus ion-selective electrode (ISE) determination of sodium, potassium and chloride.",
            ),
            "quotes": [q("ion-selective electrode (ISE) determination of sodium, potassium, and chloride", "ro-c311")],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 300 tests/hr for photometry tests only", "ro-c311"),
            fact(L_ISE, "450 tests/hr for only ISE tests", "ro-c311"),
            fact(L_MENU, "Over 130 assays and applications available", "ro-c311"),
        ],
        maintenance=[q("Automated maintenance functions", "ro-c311")],
        manual=manual_login("Roche"),
    ),
    model(
        id="roche-cobas-c-303", maker="roche", model="cobas c 303", category="chemistry",
        aliases=["c303", "c 303", "cobas pure", "кобас пьюр"],
        kind=t("Biokimyo moduli (cobas pure)", "Биохимический модуль (cobas pure)", "Chemistry unit (cobas pure)"),
        purpose={
            "text": t(
                "Ko'p turdagi miqdoriy va sifat in vitro testlar uchun to'liq avtomatik analizator (cobas pure tizimi tarkibida).",
                "Полностью автоматический анализатор для широкого спектра количественных и качественных тестов in vitro (в составе системы cobas pure).",
                "Fully automated analyzer for a large array of quantitative and qualitative in vitro tests (part of the cobas pure system).",
            ),
            "quotes": [q("a fully automated analyzer for a large array of quantitative and qualitative in vitro tests", "ro-c303")],
        },
        principle={
            "text": t(
                "Ko'p to'lqinli spektrofotometr; elektrolitlar uchun alohida ISE bloki.",
                "Многоволновой спектрофотометр; отдельный блок ISE для электролитов.",
                "Multiple-wavelength spectrophotometer; separate ISE unit for electrolytes.",
            ),
            "quotes": [q("Photometer: Multiple wavelengths spectrophotometer", "ro-c303")],
        },
        facts=[
            fact(L_THROUGHPUT, "Photometric only: 450 tests/hour", "ro-c303"),
            fact(t("Unumdorlik (fotometriya + ISE)", "Производительность (фотометрия + ISE)", "Throughput (photometric + ISE)"), "750 tests/hour (300 photometric + 450 ISE tests/hour)", "ro-c303"),
            fact(L_MENU, "over 110 clinical chemistry applications", "ro-c303"),
        ],
        maintenance=[q("Automated maintenance requiring only 5 minutes of daily operator intervention", "ro-pure")],
        manual=manual_login("Roche"),
    ),
    model(
        id="abbott-architect-c4000", maker="abbott", model="ARCHITECT c4000", category="chemistry",
        aliases=["c4000", "Architect c4000", "архитект"],
        kind=t("Avtomatik biokimyoviy analizator", "Автоматический биохимический анализатор", "Automated chemistry analyzer"),
        purpose={
            "text": t(
                "Inson namunalarida in vitro diagnostik testlar uchun (rasmiy sahifadagi umumiy ta'rif; modelga xos maqsad alohida yozilmagan).",
                "Для диагностических тестов in vitro на образцах человека (общая формулировка на официальной странице; отдельной для модели нет).",
                "For in vitro diagnostic assays on samples of human origin (general statement on the official page; no model-specific purpose).",
            ),
            "quotes": [q("intended for performing in vitro diagnostic assays on samples of human origin", "ab-c4000")],
        },
        principle={
            "text": t(
                "Fotometrik, potensiometrik va turbidimetrik o'lchash; Na⁺, K⁺, Cl⁻ uchun ISE.",
                "Фотометрия, потенциометрия и турбидиметрия; ISE для Na⁺, K⁺, Cl⁻.",
                "Photometric, potentiometric and turbidimetric measurement; ISE for Na⁺, K⁺, Cl⁻.",
            ),
            "quotes": [q("Photometric, Potentiometric, Turbidimetric", "ab-c4000"), q("patented ISE (Na+, K+ and Cl-)", "ab-c4000")],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 800 tests/hour", "ab-c4000"),
            fact(L_POSITIONS, "Up to 90 refrigerated positions", "ab-c4000"),
        ],
        maintenance=[q("Onboard Maintenance Records: Yes", "ab-c4000")],
        manual=manual_login("Abbott"),
    ),
    model(
        id="abbott-alinity-c", maker="abbott", model="Alinity c", category="chemistry",
        aliases=["Alinity", "алинити"],
        kind=t("Avtomatik biokimyoviy analizator", "Автоматический биохимический анализатор", "Automated chemistry analyzer"),
        principle={
            "text": t("Fotometrik va potensiometrik o'lchash.", "Фотометрическое и потенциометрическое измерение.", "Photometric and potentiometric measurement."),
            "quotes": [q("Photometric, Potentiometric", "ab-alinity-ci")],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 1,350 tests/hour", "ab-alinity-ci"),
            fact(t("Reagent joylari", "Позиции реагентов", "Reagent capacity"), "Up to 70", "ab-alinity-ci"),
        ],
        manual=manual_login("Abbott"),
    ),
    # ----------------------------------------------------------- hematology
    model(
        id="mindray-bc-5390", maker="mindray", model="BC-5390", category="hematology",
        aliases=["BC5390", "БС-5390", "BC-5390 CRP"],
        kind=t("Gematologik analizator, 5 qismli differensial", "Гематологический анализатор, 5-diff", "Hematology analyzer, 5-part differential"),
        purpose={
            "text": t(
                "Klinik laboratoriyalarda in vitro diagnostika uchun miqdoriy avtomatik gematologik analizator.",
                "Количественный автоматический гематологический анализатор для диагностики in vitro в клинических лабораториях.",
                "Quantitative, automated hematology analyzer for in vitro diagnostic use in clinical laboratories.",
            ),
            "quotes": [q("a quantitative, automated hematology analyzer for in vitro diagnostic use in clinical laboratories", "fda-k160429")],
        },
        principle={
            "text": t(
                "Lazer sochilishi, oqim sitometriyasi va kimyoviy bo'yoq (leykotsitlar differensiali); impedans usuli bilan WBC, RBC, BAS va PLT sanaladi; HGB — kolorimetrik usul.",
                "Лазерное светорассеяние, проточная цитометрия и химический краситель (дифференциал лейкоцитов); импедансный метод для подсчёта WBC, RBC, BAS и PLT; HGB — колориметрический метод.",
                "Laser scatter, flow cytometry and chemical dye (WBC differential); impedance counting of WBC, RBC, BAS and PLT; HGB by colorimetry.",
            ),
            "quotes": [
                q("laser scatter, flow cytometry, and chemical dye", "mr-bc5390"),
                q("uses the electrical impedance method to count and measure the size of WBC, RBC, BAS, and PLT", "fda-k160429"),
                q("HGB is determined by the colorimetric method", "fda-k160429"),
            ],
        },
        facts=[fact(L_THROUGHPUT, "throughput of 60 samples per hour", "mr-bc5390")],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="mindray-bc-30s", maker="mindray", model="BC-30s", category="hematology",
        aliases=["BC30s", "BC-30", "BC-20s/30s", "БС-30"],
        local_names={"ru": "BC-20s/30s 3diff анализатор"},
        kind=t("Gematologik analizator, 3 qismli differensial", "Гематологический анализатор, 3-diff", "Hematology analyzer, 3-part differential"),
        purpose={
            "text": t(
                "Ixcham gematologik analizator: umumiy qon tahlili (CBC) va leykotsitlarning 3 qismli differensiali.",
                "Компактный гематологический анализатор: общий анализ крови (CBC) и 3-частный дифференциал лейкоцитов.",
                "Compact hematology analyzer: complete blood count (CBC) with 3-part WBC differential.",
            ),
            "quotes": [q("CBC+3-DIFF, 21 parameters +3 histograms", "mr-bc30s")],
        },
        facts=[
            fact(L_THROUGHPUT, "Throughput:70 samples per hour", "mr-bc30s"),
            fact(L_PARAMS, "CBC+3-DIFF, 21 parameters +3 histograms", "mr-bc30s"),
        ],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="mindray-bc-6200", maker="mindray", model="BC-6200", category="hematology",
        aliases=["BC6200", "BC-6000", "БС-6200"],
        kind=t("Gematologik analizator, 5 qismli differensial", "Гематологический анализатор, 5-diff", "Hematology analyzer, 5-part differential"),
        principle={
            "text": t(
                "BC-6000 seriyasi bukleti: WBC, differensial va NRBC — SF Cube usuli; RBC va PLT — DC impedans; gemoglobin — siyaniddan xoli reagent.",
                "Буклет серии BC-6000: WBC, дифференциал и NRBC — метод SF Cube; RBC и PLT — DC-импеданс; гемоглобин — бесцианидный реагент.",
                "BC-6000 series brochure: WBC, differential and NRBC by SF Cube; RBC and PLT by DC impedance; cyanide-free hemoglobin reagent.",
            ),
            "quotes": [
                q("SF Cube* method to count WBC, 6-Part diff and NRBC", "mr-bc6000-br"),
                q("DC impedance method for RBC and PLT", "mr-bc6000-br"),
                q("Cyanide free reagent for hemoglobin test", "mr-bc6000-br"),
            ],
        },
        facts=[fact(L_THROUGHPUT, "throughput of up to 110 tests per hour", "mr-bc6200")],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="human-humacount-5d", maker="human", model="HumaCount 5D", category="hematology",
        aliases=["Humacount 5D", "HumaCount5D", "HC5D"],
        kind=t("Gematologik analizator, 5 qismli differensial", "Гематологический анализатор, 5-diff", "Hematology analyzer, 5-part differential"),
        purpose={
            "text": t("5 qismli differensialli gematologik tizim.", "Гематологическая система с 5-частным дифференциалом.", "5-part differential hematology system."),
            "quotes": [q("Outstanding 5-part diff hematology system", "hu-hc5d")],
        },
        principle={
            "text": t(
                "Leykotsitlar differensiali 3D lazer sochilishi texnologiyasiga asoslangan. RBC/PLT usuli flayerda ko'rsatilmagan.",
                "Дифференциал лейкоцитов основан на технологии 3D-светорассеяния. Метод для RBC/PLT во флаере не указан.",
                "WBC differential based on 3D scatter technology. The RBC/PLT method is not stated in the flyer.",
            ),
            "quotes": [q("based on 3D scatter technology", "hu-hc5d")],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 60 samples / hour", "hu-hc5d"),
            fact(L_PARAMS, "29 parameters with ALY#% & LIC#%", "hu-hc5d"),
            fact(L_SAMPLE, "Sample volume: 20 μl", "hu-hc5d"),
        ],
        reagent_system={"kind": "closed", "quote": q("require RF card", "hu-hc5d")},
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="human-humacount-30ts", maker="human", model="HumaCount 30TS", category="hematology",
        aliases=["Humacount 30TS", "HumaCount30TS", "HumaCount 80TS", "30TS"],
        local_names={"ru": "Анализатор гематологический автоматический HumaCount 30TS"},
        kind=t("Gematologik analizator, 3 qismli differensial", "Гематологический анализатор, 3-diff", "Hematology analyzer, 3-part differential"),
        purpose={
            "text": t("Avtomatik 3 qismli differensial tahlil.", "Автоматический 3-частный дифференциальный анализ.", "Automated 3-part differential analysis."),
            "quotes": [q("Automated 3-part differentiation analysis", "hu-hc30ts")],
        },
        principle={
            "text": t(
                "Hujayralar Kulter (konduktometrik) usulida sanaladi; gemoglobin — fotometrik usul (Rosstandart tavsifi bo'yicha).",
                "Подсчёт клеток методом Коултера (кондуктометрическим); гемоглобин — фотометрическим методом (по описанию типа Росстандарта).",
                "Cells counted by the Coulter (conductometric) method; hemoglobin photometrically (per the Rosstandart type description).",
            ),
            "quotes": [
                q("методом Культера, или кондуктометрическим методом", "rst-71783"),
                q("фотометрическим методом", "rst-71783"),
            ],
        },
        facts=[
            fact(L_THROUGHPUT, "1 measuring chamber = 30 samples/hour", "hu-hc30ts"),
            fact(L_PARAMS, "22 parameters using just a 25 µl sample volume", "hu-hc30ts"),
        ],
        maintenance=[q("Automated requests for hard/enzymatic cleaning", "hu-hc30ts")],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="abbott-cell-dyn-emerald-22-al", maker="abbott", model="CELL-DYN Emerald 22 AL", category="hematology",
        aliases=["Emerald 22", "Cell-Dyn Emerald 22", "Селл-Дин"],
        kind=t("Gematologik analizator, 5 qismli differensial", "Гематологический анализатор, 5-diff", "Hematology analyzer, 5-part differential"),
        purpose={
            "text": t(
                "Kam va o'rta hajmli laboratoriyalar uchun 5 qismli differensialli avtomatik gematologik analizator.",
                "Автоматический гематологический анализатор с 5-diff для лабораторий малого и среднего потока.",
                "Automated 5-part differential hematology analyzer for low- to mid-volume laboratories.",
            ),
            "quotes": [q("Automated hematology analyzer delivering 5-part differential for low- to mid-volume laboratories.", "ab-emerald")],
        },
        principle={
            "text": t(
                "Optik oqim sitometriyasi, elektr impedansi va yutilish spektrofotometriyasi.",
                "Оптическая проточная цитометрия, электрический импеданс и абсорбционная спектрофотометрия.",
                "Optical flow cytometry, electrical impedance and absorption spectrophotometry.",
            ),
            "quotes": [q("Optical Flow Cytometry technology", "ab-emerald"), q("Electrical impedance", "ab-emerald"), q("Absorption spectrophotometry", "ab-emerald")],
        },
        facts=[fact(L_THROUGHPUT, "40 samples per hour", "ab-emerald")],
        manual=manual_login("Abbott"),
    ),
    model(
        id="abbott-cell-dyn-emerald", maker="abbott", model="CELL-DYN Emerald", category="hematology",
        aliases=["Emerald", "Cell-Dyn Emerald"],
        kind=t("Gematologik analizator, 3 qismli differensial", "Гематологический анализатор, 3-diff", "Hematology analyzer, 3-part differential"),
        purpose={
            "text": t(
                "Kam hajmli laboratoriyalar uchun 3 qismli differensialli ixcham gematologik analizator.",
                "Компактный гематологический анализатор с 3-diff для лабораторий малого потока.",
                "Compact 3-part differential hematology analyzer for low-volume laboratories.",
            ),
            "quotes": [q("Compact hematology analyzer delivering reliable 3-part differentials for low-volume laboratories.", "ab-emerald")],
        },
        principle={
            "text": t("Elektr impedansi va yutilish spektrofotometriyasi.", "Электрический импеданс и абсорбционная спектрофотометрия.", "Electronic impedance and absorption spectrophotometry."),
            "quotes": [q("Electronic impedance", "ab-emerald"), q("Absorption spectrophotometry", "ab-emerald")],
        },
        facts=[fact(L_THROUGHPUT, "Up to 57 samples per hour", "ab-emerald")],
        manual=manual_login("Abbott"),
    ),
    model(
        id="abbott-alinity-hq", maker="abbott", model="Alinity hq", category="hematology",
        aliases=["Alinity h", "Alinity hq"],
        kind=t("Gematologik analizator, 6 qismli differensial", "Гематологический анализатор, 6-diff", "Hematology analyzer, 6-part differential"),
        purpose={
            "text": t(
                "Umumiy qon tahlili (CBC) va leykotsitlarning 6 qismli differensiali.",
                "Общий анализ крови (CBC) и 6-частный дифференциал лейкоцитов.",
                "Complete blood count (CBC) with a 6-part WBC differential.",
            ),
            "quotes": [q("The Alinity hq analyzer delivers a Complete Blood Count (CBC) with a 6-part White Blood Cell (WBC) differential.", "ab-hq")],
        },
        principle={
            "text": t(
                "MAPSS — ko'p burchakli qutblangan yorug'lik sochilishi bo'yicha ajratish texnologiyasi.",
                "MAPSS — разделение по многоугловому поляризованному светорассеянию.",
                "MAPSS (Multi Angle Polarized Scatter Separation) technology.",
            ),
            "quotes": [q("Advanced MAPSS™ (Multi Angle Polarized Scatter Separation) technology", "ab-hq")],
        },
        facts=[
            fact(L_THROUGHPUT, "119/hr for CBC + Differential", "ab-hq"),
            fact(t("Unumdorlik (+ retikulotsitlar)", "Производительность (+ ретикулоциты)", "Throughput (+ reticulocytes)"), "70/hr for CBC + Differential + Reticulocyte", "ab-hq"),
        ],
        manual=manual_login("Abbott"),
    ),
    # ---------------------------------------------------------- immunoassay
    model(
        id="mindray-cl-900i", maker="mindray", model="CL-900i", category="immunoassay",
        aliases=["CL900i", "CL-900", "ЦЛ-900"],
        kind=t("Xemilyuminessent immunoanalizator", "Хемилюминесцентный иммуноанализатор", "Chemiluminescence immunoassay analyzer"),
        purpose={
            "text": t(
                "Ixcham, to'liq avtomatik xemilyuminessent immunoanalizator.",
                "Компактный полностью автоматический хемилюминесцентный иммуноанализатор.",
                "Compact, fully automated chemiluminescence immunoassay analyzer.",
            ),
            "quotes": [q("one of the world's smallest, fully automated chemiluminescence immunoassay analyzers", "mr-cl900i")],
        },
        principle={
            "text": t(
                "Superparamagnit mikrozarrachalar, ishqoriy fosfataza bilan belgilangan reagentlar va AMPPD substrati; signal fotonlarni sanash bilan o'lchanadi.",
                "Суперпарамагнитные микрочастицы, реагенты с меткой щелочной фосфатазы и субстрат AMPPD; сигнал измеряется счётом фотонов.",
                "Superparamagnetic microparticles, ALP-labelled reagents and AMPPD substrate; signal measured by photon counting.",
            ),
            "quotes": [
                q("Micron superparamagnetic particles platform", "mr-cl900i-br"),
                q("alkaline phosphatase (ALP) labeled reagents", "mr-cl900i-br"),
                q("AMPPD substrate", "mr-cl900i-br"),
                q("Photon counting", "mr-cl900i-br"),
            ],
        },
        facts=[
            fact(L_THROUGHPUT, "Throughput of up to 180 tests/hour", "mr-cl900i"),
            fact(L_POSITIONS, "50 sample positions and 15 reagent positions", "mr-cl900i"),
        ],
        maintenance=[q("User maintenance free", "mr-cl900i-br")],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="mindray-cl-1200i", maker="mindray", model="CL-1200i", category="immunoassay",
        aliases=["CL1200i", "ЦЛ-1200"],
        local_names={"ru": "CL-1200i Иммунохемилюминесцентный анализатор"},
        kind=t("Xemilyuminessent immunoanalizator", "Хемилюминесцентный иммуноанализатор", "Chemiluminescence immunoassay analyzer"),
        purpose={
            "text": t("Xemilyuminessent immunoanalizator.", "Хемилюминесцентный иммуноанализатор.", "Chemiluminescence immunoassay analyzer."),
            "quotes": [q("a robust and simple-to-use chemiluminescence analyzer", "mr-cl1200i")],
        },
        principle={
            "text": t("CLIA texnologiyasi; 4 bosqichli magnit ajratish.", "Технология CLIA; 4-фазная магнитная сепарация.", "CLIA technology with 4-phase magnetic separation."),
            "quotes": [q("CLIA technology", "mr-cl1200i"), q("4-phase magnetic separation", "mr-cl1200i")],
        },
        facts=[
            fact(L_THROUGHPUT, "up to 180 tests per hour", "mr-cl1200i"),
            fact(L_POSITIONS, "25 reagents and 60 samples", "mr-cl1200i"),
        ],
        maintenance=[q("Programmable enhanced probe wash with detergent", "mr-cl1200i")],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="human-humaclia-150", maker="human", model="HumaCLIA 150", category="immunoassay",
        aliases=["Humaclia 150", "HumaCLIA150"],
        kind=t("Xemilyuminessent immunoanalizator", "Хемилюминесцентный иммуноанализатор", "Chemiluminescence immunoassay analyzer"),
        purpose={
            "text": t(
                "Kam va o'rta hajmli laboratoriyalar uchun immunoanaliz tizimi (tiroid, fertillik gormonlari, o'sma va kardiomarkerlar va boshqalar).",
                "Иммуноаналитическая система для лабораторий малого и среднего потока (тиреоидные, гормоны фертильности, онко- и кардиомаркеры и др.).",
                "Immunoassay system for low- to mid-volume laboratories (thyroid, fertility hormones, tumour and cardiac markers, and more).",
            ),
            "quotes": [q("ideal fit for every low to mid-volume diagnostic laboratory", "hu-clia150")],
        },
        principle={
            "text": t("Random access xemilyuminessent immunoanaliz; akridiniy efiri texnologiyasi.", "Хемилюминесцентный иммуноанализ с произвольным доступом; технология акридиниевого эфира.", "Random-access chemiluminescence immunoassay using acridinium ester technology."),
            "quotes": [q("Random-access chemiluminescence immunoassay system", "hu-clia150"), q("Acridinium ester technology", "hu-clia150")],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 150 tests per hour", "hu-clia150"),
            fact(L_POSITIONS, "20 cooled cartridge positions", "hu-clia150"),
        ],
        maintenance=[q("Onboard maintenance Yes, scheduling and log", "hu-clia150")],
        manual=MANUAL_NOT_PUBLIC,
    ),
    model(
        id="roche-cobas-e-411", maker="roche", model="cobas e 411", category="immunoassay",
        aliases=["e411", "e 411", "cobas e411", "кобас е411"],
        kind=t("Elektroxemilyuminessent immunoanalizator", "Электрохемилюминесцентный иммуноанализатор", "Electrochemiluminescence immunoassay analyzer"),
        purpose={
            "text": t(
                "Sifat, yarim miqdoriy va miqdoriy immunokimyoviy tahlillar uchun avtomatik analizator.",
                "Автоматический анализатор для качественных, полуколичественных и количественных иммунохимических исследований.",
                "Automated analyzer for qualitative, semi-quantitative and quantitative immunochemistry assays.",
            ),
            "quotes": [q("intended for running qualitative, semi- quantitative and quantitative immunochemistry assays.", "ro-e411")],
        },
        principle={
            "text": t("Elektroxemilyuminessensiya (ECL), geterogen immunoanaliz.", "Электрохемилюминесценция (ECL), гетерогенный иммуноанализ.", "Electrochemiluminescence (ECL) for heterogeneous immunoassays."),
            "quotes": [q("Electrochemiluminescence (ECL) technology for heterogeneous immunoassays", "ro-e411")],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 86 tests/h", "ro-e411"),
            fact(L_POSITIONS, "18 reagent positions", "ro-e411"),
        ],
        manual=manual_login("Roche"),
    ),
    model(
        id="roche-cobas-e-402", maker="roche", model="cobas e 402", category="immunoassay",
        aliases=["e402", "e 402", "cobas pure"],
        kind=t("Immunoanaliz moduli (cobas pure)", "Иммунохимический модуль (cobas pure)", "Immunoassay unit (cobas pure)"),
        purpose={
            "text": t(
                "To'liq avtomatik immunologik analizator (cobas pure tizimi tarkibida).",
                "Полностью автоматический иммунологический анализатор (в составе системы cobas pure).",
                "Fully automated immunology analyzer (part of the cobas pure system).",
            ),
            "quotes": [q("The e 402 analytical unit is a fully automated immunology analyzer", "ro-e402")],
        },
        principle={
            "text": t("Elektroxemilyuminessensiya (ECL).", "Электрохемилюминесценция (ECL).", "Electrochemiluminescence (ECL)."),
            "quotes": [q("using the highly innovative ElectroChemiLuminescence (ECL) technology", "ro-e402")],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 120 tests per hour", "ro-e402"),
            fact(L_POSITIONS, "28 onboard reagent positions", "ro-e402"),
        ],
        maintenance=[q("Automated maintenance requiring only 5 minutes of daily operator intervention", "ro-pure")],
        manual=manual_login("Roche"),
    ),
    model(
        id="abbott-architect-i1000sr", maker="abbott", model="ARCHITECT i1000SR", category="immunoassay",
        aliases=["i1000SR", "i1000", "Architect i1000"],
        kind=t("Xemilyuminessent immunoanalizator", "Хемилюминесцентный иммуноанализатор", "Chemiluminescence immunoassay analyzer"),
        purpose={
            "text": t("Shoshilinch (STAT) natijalar ham beradigan immunoanalizator.", "Иммуноанализатор, в том числе для срочных (STAT) результатов.", "Immunoassay analyzer that also delivers STAT results."),
            "quotes": [q("meets your laboratory's high standards by delivering STAT results", "ab-i1000")],
        },
        principle={
            "text": t(
                "CHEMIFLEX: xemilyuminessent mikrozarrachali immunoanaliz (CMIA), moslashuvchan protokollar bilan.",
                "CHEMIFLEX: хемилюминесцентный иммуноанализ на микрочастицах (CMIA) с гибкими протоколами.",
                "CHEMIFLEX: chemiluminescent microparticle immunoassay (CMIA) with flexible assay protocols.",
            ),
            "quotes": [
                q("CHEMIFLEX", "ab-i1000"),
                q("Chemiluminescent Microparticle Immunoassay (CMIA) technology with flexible assay protocols, referred to as Chemiflex.", "fda-k041192"),
            ],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 100 tests/hour", "ab-i1000"),
            fact(L_POSITIONS, "25 refrigerated positions", "ab-i1000"),
        ],
        manual=manual_login("Abbott"),
    ),
    model(
        id="abbott-alinity-i", maker="abbott", model="Alinity i", category="immunoassay",
        aliases=["Alinity", "алинити"],
        kind=t("Xemilyuminessent immunoanalizator", "Хемилюминесцентный иммуноанализатор", "Chemiluminescence immunoassay analyzer"),
        principle={
            "text": t("CHEMIFLEX xemilyuminessent detektsiya.", "Хемилюминесцентная детекция CHEMIFLEX.", "CHEMIFLEX chemiluminescent detection."),
            "quotes": [q("Utilizes proven CHEMIFLEX chemiluminescent detection technology with an assay design free from biotin interference", "ab-alinity-ci")],
        },
        facts=[
            fact(L_THROUGHPUT, "Up to 200 tests/hour", "ab-alinity-ci"),
            fact(t("Reagent joylari", "Позиции реагентов", "Reagent capacity"), "Up to 47", "ab-alinity-ci"),
        ],
        manual=manual_login("Abbott"),
    ),
    # ----------------------------------------------------------- urinalysis
    model(
        id="roche-cobas-u-411", maker="roche", model="cobas u 411", category="urinalysis",
        aliases=["u411", "u 411", "cobas u411", "кобас у411"],
        kind=t("Yarim avtomatik siydik test-chiziq o'quvchisi", "Полуавтоматический анализатор тест-полосок мочи", "Semi-automated urine strip reader"),
        purpose={
            "text": t(
                "Siydik ko'rsatkichlarini sifat yoki yarim miqdoriy aniqlash uchun yarim avtomatik tizim.",
                "Полуавтоматическая система для качественного или полуколичественного определения показателей мочи.",
                "Semi-automated system for qualitative or semi-quantitative determination of urine analytes.",
            ),
            "quotes": [q("a semiautomated urinalysis system … intended for the in vitro qualitative or semi-quantitative determination of urine analytes", "ro-u411")],
        },
        principle={
            "text": t(
                "Combur10 Test M test-chiziqlarini o'qiydi: 470, 555 va 620 nm LEDlar va fotosensorlar.",
                "Считывает тест-полоски Combur10 Test M: светодиоды 470, 555 и 620 нм и фотосенсоры.",
                "Reads Combur10 Test M strips using 470, 555 and 620 nm LEDs and photo sensors.",
            ),
            "quotes": [q("Combur10 Test M test strips", "ro-u411")],
        },
        facts=[
            fact(L_THROUGHPUT, "600 test strips per hour", "ro-u411"),
            fact(t("Yorug'lik manbai", "Источник света", "Light source"), "LEDs: 470 nm, 555 nm, 620 nm", "ro-u411"),
            fact(L_CAL, "Recommended calibration with calibration strip: once a month", "ro-u411"),
        ],
        image={
            "asset": "assets/instruments/img/cobas_u_411.jpg",
            "license": "CC BY-SA 4.0",
            "license_url": "https://creativecommons.org/licenses/by-sa/4.0/",
            "author": "Roto2esdios",
            "source_page": "https://commons.wikimedia.org/wiki/File:Cobas_u_411.JPG",
            "caption": t(
                "cobas u 411 laboratoriyada (Wikimedia Commons; o'lchami kichraytirilgan).",
                "cobas u 411 в лаборатории (Wikimedia Commons; уменьшено).",
                "cobas u 411 in a laboratory (Wikimedia Commons; resized).",
            ),
        },
        manual=manual_login("Roche"),
    ),
    model(
        id="roche-cobas-6500", maker="roche", model="cobas 6500", category="urinalysis",
        aliases=["u 601", "u 701", "cobas u 601", "cobas u 701", "u601", "u701"],
        kind=t("Avtomatik siydik tahlili liniyasi (u 601 + u 701)", "Автоматическая линия анализа мочи (u 601 + u 701)", "Automated urinalysis line (u 601 + u 701)"),
        purpose={
            "text": t(
                "u 601 — to'liq avtomatik siydik test-chiziq tahlili; u 701 — to'liq avtomatik siydik cho'kmasi mikroskopiyasi.",
                "u 601 — полностью автоматический анализ мочи на тест-полосках; u 701 — полностью автоматическая микроскопия осадка мочи.",
                "u 601: fully automated strip urinalysis; u 701: fully automated urine microscopy.",
            ),
            "quotes": [q("a fully automated urinalysis system", "ro-6500"), q("a fully automated urine microscopy system", "ro-6500")],
        },
        principle={
            "text": t(
                "u 601: reflektometriya va chiziq maydonchalarining yuqori aniqlikdagi tasvirlari; u 701: har bir namunadan 15 ta raqamli tasvir.",
                "u 601: рефлектометрия и снимки высокого разрешения зон полоски; u 701: 15 цифровых изображений каждой пробы.",
                "u 601: reflectance technology with high-resolution images of the strip pads; u 701: 15 digital images per sample.",
            ),
            "quotes": [
                q("uses innovative reflectance technology and takes high-resolution images of the strip pads", "ro-6500"),
                q("15 digital images are taken from each sample", "ro-6500"),
            ],
        },
        facts=[
            fact(t("Unumdorlik (yuqori unumdor konfiguratsiya)", "Производительность (высокопроизводительная конфигурация)", "Throughput (high-throughput configuration)"), "up to 240 samples per hour", "ro-6500"),
            fact(t("Unumdorlik (butun tizim, avtomatik transport)", "Производительность (вся система, автотранспорт)", "Throughput (full system, automated transport)"), "up to 116 samples per hour", "ro-6500"),
        ],
        manual=manual_login("Roche"),
    ),
    model(
        id="mindray-eu-5600-pro", maker="mindray", model="EU-5600 Pro", category="urinalysis",
        aliases=["EU-5300 Pro", "EU5600", "EU-5600", "EU-5300"],
        kind=t("Siydik tahlili tizimi (chiziq + cho'kma)", "Система анализа мочи (полоски + осадок)", "Urinalysis system (strip + sediment)"),
        purpose={
            "text": t(
                "Bitta tizimda quruq kimyo (test-chiziq), shaklli elementlar va eritrotsitlar fazasi tahlili.",
                "В одной системе: сухая химия (тест-полоски), форменные элементы и фаза эритроцитов.",
                "One system for dry chemistry (strips), formed elements and RBC phase analysis.",
            ),
            "quotes": [q("Three features integrated in a single system", "mr-eu5600")],
        },
        principle={
            "text": t(
                "Cho'kma raqamli tasvirlash orqali: namunadan 60 tagacha rangli tasvir olinadi.",
                "Осадок — цифровая визуализация: до 60 цветных изображений пробы.",
                "Sediment by digital imaging: up to 60 full-colour images per sample.",
            ),
            "quotes": [q("2K full-color clear imaging", "mr-eu5600"), q("captures up to 60 clear images from the samples", "mr-eu5600")],
        },
        manual=MANUAL_NOT_PUBLIC,
    ),
]


def build():
    sources = [
        {"id": k, "title": v[0], "url": v[1], "doc_ref": v[2], "accessed": ACCESSED}
        for k, v in SOURCES.items()
    ]
    used = set()
    for m in MODELS:
        for part in ("purpose", "principle"):
            for qq in (m[part] or {}).get("quotes", []):
                used.add(qq["source"])
        for f in m["facts"]:
            used.add(f["source"])
        for qq in m["maintenance"]:
            used.add(qq["source"])
        if m["reagent_system"]["quote"]:
            used.add(m["reagent_system"]["quote"]["source"])
        for r in m["validated_reagents"]:
            used.add(r["source"])
    unknown = used - set(SOURCES)
    assert not unknown, unknown
    return {
        "schema_version": 1,
        "catalog_version": "2026.10.09-1",
        "accessed": ACCESSED,
        "categories": CATEGORIES,
        "makers": MAKERS,
        "sources": sources,
        "models": MODELS,
    }


if __name__ == "__main__":
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(build(), ensure_ascii=False, indent=1) + "\n")
    print(OUT, len(MODELS), "models")
