"""LabGuide mikroskopiya atlasi manbasi → assets/microscopy/atlas.json.

    python3 tool/microscopy_images.py      # (bir marta) rasmlarni yuklab, kichraytirish
    python3 tool/microscopy_atlas_src.py   # JSON'ni qayta yig'ish va tekshirish

Qoidalar:
- Rasm faqat erkin litsenziyali: CC0 / CC BY / CC BY-SA / public domain yoki
  CDC PHIL (CDC va fotograf krediti bilan, mazmuni o'zgartirilmaydi). NC/ND,
  noaniq litsenziya, chizma/illyustratsiya va generativ (AI) rasm olinmaydi.
- Litsenziya, muallif va asl izoh manba sahifasidan **qayta tekshirilgan**
  (Wikimedia Commons API extmetadata + sahifa matni; CDC PHIL Details
  sahifasi), sana: ACCESSED.
- Asl izoh so'zma-so'z, manba tilida (``caption.text``). Tarjima — LabGuide
  tarjimasi (``caption.tr``).
- Kattalashtirish/bo'yoq faqat manbada yozilgan bo'lsa (so'zma-so'z), aks holda
  ``null`` — ilova “manbada ko'rsatilmagan” deydi.
- Rasm faqat kichraytirilgan (uzun tomoni ≤ MAX_SIDE) va JPEG'ga o'tkazilgan;
  kesilmagan, yozuv qo'shilmagan, EXIF tozalangan.
- ``note`` — LabGuide'ning qisqa tushuntirishi: **draft**, mutaxassis
  tekshiruvi kutilmoqda; manbasiz raqam yo'q.
- Litsenziyali rasm topilmagan tur (``gap``) halol ko'rsatiladi.
"""
import hashlib
import json
import pathlib
import sys

ACCESSED = "2026-10-09"
ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "assets/microscopy/atlas.json"
IMG_DIR = "assets/microscopy/img"
MAX_SIDE = 1600

# Ruxsat etilgan litsenziyalar va ularning kanonik havolasi.
LICENSES = {
    "CC0 1.0": "https://creativecommons.org/publicdomain/zero/1.0/",
    "CC BY 2.0": "https://creativecommons.org/licenses/by/2.0/",
    "CC BY 3.0": "https://creativecommons.org/licenses/by/3.0/",
    "CC BY 4.0": "https://creativecommons.org/licenses/by/4.0/",
    "CC BY-SA 2.0": "https://creativecommons.org/licenses/by-sa/2.0/",
    "CC BY-SA 3.0": "https://creativecommons.org/licenses/by-sa/3.0/",
    "CC BY-SA 4.0": "https://creativecommons.org/licenses/by-sa/4.0/",
    "Public domain": "https://creativecommons.org/publicdomain/mark/1.0/",
    "CDC PHIL": "https://www.cdc.gov/other/agencymaterials.html",
}

# CDC PHIL yozuvlaridagi “Copyright Restrictions” matni (har yozuvda bir xil,
# 2026-10-09 da tekshirildi).
CDC_TERMS = (
    "Permission is not required for public domain images, however, these "
    "images are provided by CDC and are available for personal, professional, "
    "and educational use with appropriate attribution. Redistribution must "
    "credit CDC and, where known, the individual photographer, and identify "
    "the CDC website as the free source."
)


def t(uz, ru, en):
    return {"uz": uz, "ru": ru, "en": en}


SECTIONS = [
    {
        "id": "urine",
        "name": t("Siydik cho‘kmasi", "Осадок мочи", "Urine sediment"),
        "sub": t(
            "Eritrotsitlar, leykotsitlar, epiteliy, silindrlar, kristallar",
            "Эритроциты, лейкоциты, эпителий, цилиндры, кристаллы",
            "Red cells, white cells, epithelium, casts, crystals",
        ),
    },
    {
        "id": "blood",
        "name": t("Periferik qon surtmasi", "Мазок периферической крови",
                  "Peripheral blood smear"),
        "sub": t(
            "Leykotsitlar va eritrotsitlar shakli",
            "Лейкоциты и форма эритроцитов",
            "White cells and red cell shape",
        ),
    },
    {
        "id": "parasites",
        "name": t("Parazitlar", "Паразиты", "Parasites"),
        "sub": t(
            "Bezgak: yupqa va qalin surtma",
            "Малярия: тонкий и толстый мазок",
            "Malaria: thin and thick films",
        ),
    },
]

GROUPS = [
    {"id": "urine-rbc", "section": "urine",
     "name": t("Eritrotsitlar", "Эритроциты", "Red blood cells")},
    {"id": "urine-wbc", "section": "urine",
     "name": t("Leykotsitlar", "Лейкоциты", "White blood cells")},
    {"id": "urine-epi", "section": "urine",
     "name": t("Epiteliy", "Эпителий", "Epithelial cells")},
    {"id": "urine-casts", "section": "urine",
     "name": t("Silindrlar", "Цилиндры", "Casts")},
    {"id": "urine-crystals", "section": "urine",
     "name": t("Kristallar", "Кристаллы", "Crystals")},
    {"id": "blood-wbc", "section": "blood",
     "name": t("Leykotsitlar", "Лейкоциты", "White blood cells")},
    {"id": "blood-rbc", "section": "blood",
     "name": t("Eritrotsitlar shakli", "Форма эритроцитов", "Red cell shape")},
    {"id": "malaria", "section": "parasites",
     "name": t("Bezgak", "Малярия", "Malaria")},
]

NO_IMAGE_COMMONS = t(
    "Erkin litsenziyali, aniq belgilangan mikrofoto hali topilmadi "
    f"({ACCESSED} holatiga). Topilgach, muallif va litsenziyasi bilan qo‘shiladi.",
    "Микрофотография со свободной лицензией и чёткой подписью пока не найдена "
    f"(на {ACCESSED}). Будет добавлена с автором и лицензией, когда найдётся.",
    "No clearly labelled micrograph with a free licence found yet "
    f"(as of {ACCESSED}). It will be added with author and licence once found.",
)

# Tur (rasmdagi obyekt). ``quiz`` — “Bu nima?” mashqida javob/variant bo'la
# oladimi (aralash maydon va jurnal paneli — yo'q). ``note`` — draft.
ENTITIES = [
    {
        "id": "urine-rbc", "group": "urine-rbc", "quiz": True,
        "name": t("Siydikdagi eritrotsitlar", "Эритроциты в моче",
                  "Red blood cells in urine"),
        "terms": ["eritrotsit", "eritrosit", "эритроцит", "rbc", "red cell",
                  "red blood", "gematuriya", "гематури", "hematuria",
                  "haematuria", "qizil qon"],
        "note": t(
            "Kichik, yadrosiz, odatda ikki tomoni botiq disk shaklidagi "
            "hujayralar; bo‘yalmagan preparatda och sarg‘ish ko‘rinishi "
            "mumkin. Shakli siydik zichligi va pH ga qarab o‘zgaradi "
            "(shishgan yoki burishgan).",
            "Мелкие безъядерные клетки, обычно в форме двояковогнутого "
            "диска; в неокрашенном препарате могут выглядеть бледно-"
            "желтоватыми. Форма меняется в зависимости от плотности и pH "
            "мочи (набухшие или сморщенные).",
            "Small anucleate cells, usually biconcave discs; may look pale "
            "yellowish in an unstained preparation. Shape changes with urine "
            "concentration and pH (swollen or crenated).",
        ),
    },
    {
        "id": "urine-rbc-dysmorphic", "group": "urine-rbc", "quiz": False,
        "name": t("Dismorf eritrotsitlar", "Дисморфные эритроциты",
                  "Dysmorphic red blood cells"),
        "terms": ["dismorf", "дисморф", "dysmorphic", "akantotsituriya",
                  "glomerulyar", "гломеруляр", "glomerular"],
        "gap": t(
            "Erkin litsenziyali rasm hali yo‘q: Wikimedia Commons’dagi "
            "nomzodlar umumiy «Attribution» shablonida — biz qabul qiladigan "
            "CC0 / CC BY / CC BY-SA / public domain ro‘yxatida emas "
            f"({ACCESSED}).",
            "Изображения со свободной лицензией пока нет: кандидаты на "
            "Wikimedia Commons размечены общим шаблоном «Attribution», "
            "которого нет в нашем списке CC0 / CC BY / CC BY-SA / public "
            f"domain ({ACCESSED}).",
            "No freely licensed image yet: the Wikimedia Commons candidates "
            "carry a generic “Attribution” template, which is not in our "
            f"CC0 / CC BY / CC BY-SA / public domain list ({ACCESSED}).",
        ),
    },
    {
        "id": "urine-wbc", "group": "urine-wbc", "quiz": True,
        "name": t("Siydikdagi leykotsitlar", "Лейкоциты в моче",
                  "White blood cells in urine"),
        "terms": ["leykotsit", "leykosit", "лейкоцит", "wbc", "white cell",
                  "white blood", "yiring", "гной", "pus", "piuriya", "пиури",
                  "pyuria"],
        "note": t(
            "Eritrotsitlardan kattaroq, donador sitoplazmali, yadrosi "
            "ko‘pincha bo‘lakli hujayralar. Ko‘p bo‘lsa to‘da hosil qilishi "
            "mumkin.",
            "Крупнее эритроцитов, с зернистой цитоплазмой и часто "
            "сегментированным ядром. При большом количестве могут "
            "образовывать скопления.",
            "Larger than red cells, with granular cytoplasm and an often "
            "lobed nucleus. May form clumps when numerous.",
        ),
    },
    {
        "id": "urine-epi-mixed", "group": "urine-epi", "quiz": False,
        "name": t("Epiteliy hujayralari (aralash maydon)",
                  "Эпителиальные клетки (смешанное поле)",
                  "Epithelial cells (mixed field)"),
        "terms": ["epiteliy", "epitel", "эпители", "epithelial",
                  "aralash", "смешан", "mixed", "bakteriya", "бактери",
                  "bacteria", "infeksiya", "инфекц", "infection"],
        "note": t(
            "Bir maydonda bir nechta element bor. Epiteliy hujayralarini "
            "kattaligi va yirik, aniq yadrosi bo‘yicha leykotsit va "
            "eritrotsitlardan ajrating. Epiteliy turi manbada "
            "ko‘rsatilmagan.",
            "В одном поле несколько элементов. Эпителиальные клетки "
            "отличайте от лейкоцитов и эритроцитов по размеру и крупному "
            "чёткому ядру. Тип эпителия в источнике не указан.",
            "Several elements share one field. Tell epithelial cells from "
            "white and red cells by their size and large, distinct nucleus. "
            "The source does not state the epithelial type.",
        ),
    },
    {
        "id": "urine-rte", "group": "urine-epi", "quiz": True,
        "name": t("Buyrak kanalchalari epiteliysi",
                  "Почечный канальцевый эпителий",
                  "Renal tubular epithelial cells"),
        "terms": ["kanalcha", "канальц", "tubular", "renal", "buyrak",
                  "почеч", "rte", "epiteliy", "эпители", "epithelial"],
        "note": t(
            "Leykotsitlardan kattaroq, yirik dumaloq yoki oval yadroli "
            "epiteliy hujayralari. Leykotsit bilan adashtirish oson — "
            "yadro shakliga e’tibor bering.",
            "Эпителиальные клетки крупнее лейкоцитов, с крупным круглым "
            "или овальным ядром. Их легко спутать с лейкоцитами — "
            "обращайте внимание на форму ядра.",
            "Epithelial cells larger than white cells, with a large round or "
            "oval nucleus. Easily confused with white cells — look at the "
            "nucleus shape.",
        ),
    },
    {
        "id": "urine-squamous", "group": "urine-epi", "quiz": False,
        "name": t("Yassi epiteliy", "Плоский эпителий",
                  "Squamous epithelial cells"),
        "terms": ["yassi", "плоск", "squamous", "epiteliy", "эпители",
                  "epithelial"],
        "gap": NO_IMAGE_COMMONS,
    },
    {
        "id": "cast-hyaline", "group": "urine-casts", "quiz": True,
        "name": t("Gialin silindr", "Гиалиновый цилиндр", "Hyaline cast"),
        "terms": ["gialin", "гиалин", "hyaline", "silindr", "цилиндр",
                  "cast"],
        "note": t(
            "Shaffof, bir jinsli silindrsimon tuzilma. Yorug‘lik "
            "kamaytirilganda (kondensor tushirilganda) yaxshiroq ko‘rinadi.",
            "Прозрачная однородная цилиндрическая структура. Лучше видна "
            "при уменьшенном освещении (опущенном конденсоре).",
            "Transparent, homogeneous cylindrical structure. Easier to see "
            "with reduced light (lowered condenser).",
        ),
    },
    {
        "id": "cast-granular", "group": "urine-casts", "quiz": True,
        "name": t("Donador silindr", "Зернистый цилиндр", "Granular cast"),
        "terms": ["donador", "зернист", "granular", "silindr", "цилиндр",
                  "cast"],
        "note": t(
            "Silindr matritsasi ichida mayda yoki yirik donachalar bor.",
            "В матриксе цилиндра видны мелкие или крупные гранулы.",
            "The cast matrix contains fine or coarse granules.",
        ),
    },
    {
        "id": "cast-panel", "group": "urine-casts", "quiz": False,
        "name": t(
            "Silindrlar: epiteliyli, «loyqa» donador, leykotsitar, "
            "eritrotsitar",
            "Цилиндры: эпителиальный, «грязный» зернистый, лейкоцитарный, "
            "эритроцитарный",
            "Casts: renal tubular epithelial, muddy brown granular, WBC, RBC",
        ),
        "terms": ["silindr", "цилиндр", "cast", "eritrotsitar",
                  "эритроцитар", "rbc cast", "red cell cast", "leykotsitar",
                  "лейкоцитар", "wbc cast", "muddy", "грязн", "loyqa",
                  "epitelial", "эпителиаль", "nekroz", "некроз", "necrosis",
                  "aki", "glomerulonefrit", "гломерулонефрит",
                  "glomerulonephritis"],
        "note": t(
            "Jurnal rasmi: to‘rt panel (a–d), har biri asl izohda nomlangan. "
            "Rasm kichik — to‘liq ekranda kattalashtirib ko‘ring.",
            "Рисунок из журнала: четыре панели (a–d), каждая названа в "
            "исходной подписи. Изображение небольшое — увеличьте его на "
            "весь экран.",
            "Journal figure: four panels (a–d), each named in the original "
            "caption. The image is small — open it full screen to zoom.",
        ),
    },
    {
        "id": "crystal-caox", "group": "urine-crystals", "quiz": True,
        "name": t("Kalsiy oksalat kristallari", "Кристаллы оксалата кальция",
                  "Calcium oxalate crystals"),
        "terms": ["oksalat", "оксалат", "oxalate", "kalsiy", "кальци",
                  "calcium", "kristall", "кристалл", "crystal"],
        "note": t(
            "Kalsiy oksalat ikki ko‘rinishda uchraydi: monogidrat (oval, "
            "«gantel» yoki tayoqchasimon) va digidrat (konvert shaklli). "
            "Manba izohiga ko‘ra bu rasmda — monogidrat.",
            "Оксалат кальция встречается в двух формах: моногидрат "
            "(овальные, в виде «гантелей» или палочек) и дигидрат (в форме "
            "конвертов). По подписи источника здесь — моногидрат.",
            "Calcium oxalate occurs as the monohydrate (oval, dumbbell or "
            "rod-like) and the dihydrate (envelope-shaped). Per the source "
            "caption, this image shows the monohydrate.",
        ),
    },
    {
        "id": "crystal-uric", "group": "urine-crystals", "quiz": True,
        "name": t("Siydik kislotasi kristallari", "Кристаллы мочевой кислоты",
                  "Uric acid crystals"),
        "terms": ["siydik kislota", "мочев", "uric", "urat", "урат",
                  "kristall", "кристалл", "crystal"],
        "note": t(
            "Sariqdan qizg‘ish-jigarranggacha bo‘lgan romb, plastinka yoki "
            "rozetka shaklidagi kristallar; odatda kislotali siydikda.",
            "Кристаллы от жёлтого до красновато-коричневого цвета в форме "
            "ромбов, пластин или розеток; обычно в кислой моче.",
            "Yellow to reddish-brown crystals shaped as rhombs, plates or "
            "rosettes; typically in acidic urine.",
        ),
    },
    {
        "id": "crystal-triple", "group": "urine-crystals", "quiz": True,
        "name": t("Tripelfosfat (struvit) kristallari",
                  "Кристаллы трипельфосфата (струвит)",
                  "Triple phosphate (struvite) crystals"),
        "terms": ["tripelfosfat", "трипельфосфат", "triple phosphate",
                  "struvit", "струвит", "struvite", "fosfat", "фосфат",
                  "phosphate", "kristall", "кристалл", "crystal"],
        "note": t(
            "Rangsiz prizmalar, ko‘pincha «tobut qopqog‘i» shaklida; odatda "
            "ishqoriy siydikda.",
            "Бесцветные призмы, часто в форме «крышки гроба»; обычно в "
            "щелочной моче.",
            "Colourless prisms, often “coffin-lid” shaped; typically in "
            "alkaline urine.",
        ),
    },
    {
        "id": "crystal-cystine", "group": "urine-crystals", "quiz": True,
        "name": t("Sistin kristallari", "Кристаллы цистина",
                  "Cystine crystals"),
        "terms": ["sistin", "цистин", "cystine", "cistina", "kristall",
                  "кристалл", "crystal"],
        "note": t(
            "Rangsiz, yupqa olti burchakli plastinkalar, ko‘pincha qatlam-"
            "qatlam. Klinik ahamiyatli topilma — natijani mutaxassis "
            "tasdiqlaydi.",
            "Бесцветные тонкие шестиугольные пластинки, часто слоями. "
            "Клинически значимая находка — результат подтверждает "
            "специалист.",
            "Colourless, thin hexagonal plates, often layered. A clinically "
            "significant finding — a specialist confirms the result.",
        ),
    },
    {
        "id": "neutrophil", "group": "blood-wbc", "quiz": True,
        "name": t("Neytrofil", "Нейтрофил", "Neutrophil"),
        "terms": ["neytrofil", "нейтрофил", "neutrophil", "pmn",
                  "segment", "сегмент", "granulotsit", "гранулоцит",
                  "granulocyte", "leykotsit", "лейкоцит", "wbc"],
        "note": t(
            "Yadrosi bir nechta bo‘lakka bo‘lingan (segmentlangan); "
            "sitoplazmasi och, mayda donachali.",
            "Ядро разделено на несколько сегментов; цитоплазма светлая, "
            "с мелкой зернистостью.",
            "Nucleus divided into several lobes (segmented); pale cytoplasm "
            "with fine granules.",
        ),
    },
    {
        "id": "lymphocyte", "group": "blood-wbc", "quiz": True,
        "name": t("Limfotsit", "Лимфоцит", "Lymphocyte"),
        "terms": ["limfotsit", "limfosit", "лимфоцит", "lymphocyte",
                  "leykotsit", "лейкоцит", "wbc"],
        "note": t(
            "Kichik hujayra: yumaloq, to‘q bo‘yalgan yadro hujayraning "
            "katta qismini egallaydi; sitoplazmasi ingichka havorang hoshiya.",
            "Небольшая клетка: круглое тёмное ядро занимает большую часть "
            "клетки; цитоплазма — узкий голубой ободок.",
            "Small cell: a round, dark nucleus fills most of the cell; the "
            "cytoplasm is a thin pale-blue rim.",
        ),
    },
    {
        "id": "monocyte", "group": "blood-wbc", "quiz": True,
        "name": t("Monotsit", "Моноцит", "Monocyte"),
        "terms": ["monotsit", "monosit", "моноцит", "monocyte",
                  "leykotsit", "лейкоцит", "wbc"],
        "note": t(
            "Yirik hujayra: yadrosi buyraksimon yoki bukilgan, xromatini "
            "nozik to‘rsimon; sitoplazmasi kulrang-havorang, ba’zan vakuolali.",
            "Крупная клетка: ядро бобовидное или изогнутое, с нежным "
            "сетчатым хроматином; цитоплазма серо-голубая, иногда с "
            "вакуолями.",
            "Large cell: kidney-shaped or folded nucleus with fine, lacy "
            "chromatin; grey-blue cytoplasm, sometimes vacuolated.",
        ),
    },
    {
        "id": "eosinophil", "group": "blood-wbc", "quiz": True,
        "name": t("Eozinofil", "Эозинофил", "Eosinophil"),
        "terms": ["eozinofil", "эозинофил", "eosinophil", "granulotsit",
                  "гранулоцит", "granulocyte", "leykotsit", "лейкоцит", "wbc"],
        "note": t(
            "Sitoplazmasi yirik to‘q sariq-qizg‘ish donachalar bilan to‘la; "
            "yadrosi ko‘pincha ikki bo‘lakli.",
            "Цитоплазма заполнена крупными оранжево-красными гранулами; "
            "ядро чаще двудольчатое.",
            "Cytoplasm packed with large orange-red granules; the nucleus is "
            "often bilobed.",
        ),
    },
    {
        "id": "basophil", "group": "blood-wbc", "quiz": True,
        "name": t("Bazofil", "Базофил", "Basophil"),
        "terms": ["bazofil", "базофил", "basophil", "granulotsit",
                  "гранулоцит", "granulocyte", "leykotsit", "лейкоцит", "wbc"],
        "note": t(
            "Yirik, to‘q binafsha donachalar yadroni qisman yopib turadi.",
            "Крупные тёмно-фиолетовые гранулы частично закрывают ядро.",
            "Large dark purple granules partly obscure the nucleus.",
        ),
    },
    {
        "id": "acanthocyte", "group": "blood-rbc", "quiz": True,
        "name": t("Akantotsitlar", "Акантоциты", "Acanthocytes"),
        "terms": ["akantotsit", "akantosit", "акантоцит", "acanthocyte",
                  "acantócito", "eritrotsit", "эритроцит", "rbc",
                  "abetalipoproteinemiya", "абеталипопротеинеми",
                  "abetalipoproteinemia"],
        "note": t(
            "Eritrotsit yuzasida notekis joylashgan, uzunligi har xil "
            "tikansimon o‘simtalar. Ekinotsitlardan farqi — o‘simtalari "
            "bir tekis taqsimlanmagan.",
            "Эритроциты с неравномерно расположенными шипами разной длины. "
            "В отличие от эхиноцитов, выросты распределены неравномерно.",
            "Red cells with irregularly spaced spicules of uneven length. "
            "Unlike echinocytes, the projections are not evenly spread.",
        ),
    },
    {
        "id": "malaria-thin", "group": "malaria", "quiz": True,
        "name": t("Bezgak (P. falciparum): yupqa surtma",
                  "Малярия (P. falciparum): тонкий мазок",
                  "Malaria (P. falciparum): thin film"),
        "terms": ["bezgak", "малярия", "malaria", "plasmodium", "плазмоди",
                  "falciparum", "yupqa", "тонк", "thin", "trofozoit",
                  "трофозоит", "trophozoite", "parazit", "паразит",
                  "parasite"],
        "note": t(
            "Yupqa surtmada eritrotsitlar bir qavat yotadi va parazit "
            "hujayra ichida ko‘rinadi — turini aniqlash uchun qulay.",
            "В тонком мазке эритроциты лежат в один слой, паразит виден "
            "внутри клетки — удобно для определения вида.",
            "In a thin film red cells lie in one layer and the parasite is "
            "seen inside the cell — useful for species identification.",
        ),
    },
    {
        "id": "malaria-thick", "group": "malaria", "quiz": True,
        "name": t("Bezgak (P. falciparum): qalin surtma",
                  "Малярия (P. falciparum): толстый мазок",
                  "Malaria (P. falciparum): thick film"),
        "terms": ["bezgak", "малярия", "malaria", "plasmodium", "плазмоди",
                  "falciparum", "qalin", "толст", "thick", "gametotsit",
                  "гаметоцит", "gametocyte", "parazit", "паразит",
                  "parasite"],
        "note": t(
            "Qalin surtmada eritrotsitlar gemolizlangan, parazitlar fonda "
            "erkin ko‘rinadi — parazitni topish uchun sezgirroq.",
            "В толстом мазке эритроциты гемолизированы, паразиты видны "
            "свободно на фоне — чувствительнее для обнаружения паразита.",
            "In a thick film red cells are lysed and parasites lie free on "
            "the background — more sensitive for finding parasites.",
        ),
    },
]


def commons(title, author, license_, original, date, credit="Own work"):
    """Wikimedia Commons fayli (metama'lumot Commons API'dan)."""
    name = title.removeprefix("File:").replace(" ", "_")
    return {
        "provider": "commons",
        "source_title": title,
        "source_page": "https://commons.wikimedia.org/wiki/File:" + name,
        "author": author,
        "credit": credit,
        "license": license_,
        "license_url": LICENSES[license_],
        "date": date,
        "original_size": list(original),
    }


def phil(pid, provider, date, original, lores):
    """CDC Public Health Image Library yozuvi."""
    return {
        "provider": "cdc_phil",
        "source_title": f"CDC PHIL ID#{pid}",
        "source_page": f"https://wwwn.cdc.gov/phil/Details.aspx?pid={pid}",
        "author": provider,
        "credit": "CDC Public Health Image Library (PHIL)",
        "license": "CDC PHIL",
        "license_url": LICENSES["CDC PHIL"],
        "terms_quote": CDC_TERMS,
        "date": date,
        "original_size": list(original),
        "lores_url": lores,
    }


def cap(lang, text, uz, ru, en):
    return {"lang": lang, "text": text, "tr": t(uz, ru, en)}


def stain(text, uz, ru, en):
    return {"text": text, "tr": t(uz, ru, en)}


# file_url — asl fayl (Commons: upload.wikimedia.org; PHIL: hi-res fayl).
IMAGES = [
    # ---------------------------------------------------------- siydik: RBC
    {
        "id": "u-rbc-1", "entity": "urine-rbc", "quiz": "field",
        **commons("File:MicroHematuria.JPG", "Bobjgalindo", "CC BY-SA 4.0",
                  (1743, 1501), "2005-02-19"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/2/28/MicroHematuria.JPG",
        # Asl fayl (Commons API sha1 bilan bir xil nusxa) → 1600 px.
        "fetch": "original",
        "caption": cap(
            "en",
            "Microscopic hematuria: Red blood cells in a urine sample seen "
            "under the microscope.",
            "Mikroskopik gematuriya: mikroskop ostida ko‘rilgan siydik "
            "namunasidagi eritrotsitlar.",
            "Микроскопическая гематурия: эритроциты в пробе мочи под "
            "микроскопом.",
            "Microscopic hematuria: red blood cells in a urine sample seen "
            "under the microscope.",
        ),
    },
    {
        "id": "u-rbc-2", "entity": "urine-rbc", "quiz": "field",
        **commons("File:Haematuria.jpg", "J3D3", "CC BY-SA 3.0",
                  (1532, 1336), "2010-07-08"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/0/0c/Haematuria.jpg",
        "caption": cap(
            "en",
            "Microphotography - sample of urine with hematuria",
            "Mikrofotografiya — gematuriyali siydik namunasi",
            "Микрофотография — образец мочи с гематурией",
            "Microphotograph — urine sample with hematuria",
        ),
    },
    # ---------------------------------------------------------- siydik: WBC
    {
        "id": "u-wbc-1", "entity": "urine-wbc", "quiz": "field",
        **commons("File:Plenty of pus cells in Urine Microscopy.jpg",
                  "Ajay Kumar Chaurasiya", "CC BY-SA 4.0", (4000, 2250),
                  "2021-12-08"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/2/20/Plenty_of_pus_cells_in_Urine_Microscopy.jpg",
        "magnification": "400X",
        "caption": cap(
            "en",
            "Plenty of pus cells in Urine Microscopy at magnification of 400X",
            "Siydik mikroskopiyasida ko‘p miqdorda yiring hujayralari "
            "(400X kattalashtirish)",
            "Множество гнойных клеток при микроскопии мочи (увеличение 400X)",
            "Plenty of pus cells on urine microscopy (400X magnification)",
        ),
    },
    {
        "id": "u-wbc-2", "entity": "urine-wbc", "quiz": "field",
        **commons("File:Pus cells (dead leukocytes) in urine microscopy.jpg",
                  "Ajay Kumar Chaurasiya", "CC BY-SA 4.0", (3264, 2448),
                  "2017-09-30"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/d/da/Pus_cells_%28dead_leukocytes%29_in_urine_microscopy.jpg",
        "caption": cap(
            "en",
            "Under a microscope, pus cells appear as small, spherical cells "
            "with a multi-lobed nucleus. They are a key component of the "
            "body's immune response to infection or inflammation. The "
            "presence of pus cells in urine is indicative of an ongoing "
            "immune response within the urinary tract.",
            "Mikroskop ostida yiring hujayralari ko‘p bo‘lakli yadroli "
            "kichik, sharsimon hujayralar ko‘rinishida bo‘ladi. Ular "
            "organizmning infeksiya yoki yallig‘lanishga immun javobining "
            "asosiy qismi. Siydikda yiring hujayralari bo‘lishi siydik "
            "yo‘llarida davom etayotgan immun javobdan dalolat beradi.",
            "Под микроскопом гнойные клетки выглядят как мелкие сферические "
            "клетки с многодольчатым ядром. Они — ключевой компонент "
            "иммунного ответа организма на инфекцию или воспаление. "
            "Наличие гнойных клеток в моче указывает на продолжающийся "
            "иммунный ответ в мочевыводящих путях.",
            "Under a microscope, pus cells appear as small, spherical cells "
            "with a multi-lobed nucleus. They are a key part of the body's "
            "immune response to infection or inflammation. Pus cells in "
            "urine indicate an ongoing immune response in the urinary tract.",
        ),
    },
    # ----------------------------------------------------- siydik: epiteliy
    {
        "id": "u-epi-1", "entity": "urine-epi-mixed", "quiz": None,
        **commons(
            "File:Pus cells, Epithelial cells, RBCs and Bacteria in Urine "
            "Microscopy.jpg",
            "Ajay Kumar Chaurasiya", "CC BY-SA 4.0", (4000, 2250),
            "2021-12-08"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/7/74/Pus_cells%2C_Epithelial_cells%2C_RBCs_and_Bacteria_in_Urine_Microscopy.jpg",
        "magnification": "800X",
        "caption": cap(
            "en",
            "Pus cells, Epithelial cells, RBCs and Bacteria in Urine "
            "Microscopy at magnification of 800X",
            "Siydik mikroskopiyasida yiring hujayralari, epiteliy "
            "hujayralari, eritrotsitlar va bakteriyalar (800X "
            "kattalashtirish)",
            "Гнойные клетки, эпителиальные клетки, эритроциты и бактерии "
            "при микроскопии мочи (увеличение 800X)",
            "Pus cells, epithelial cells, red cells and bacteria on urine "
            "microscopy (800X magnification)",
        ),
    },
    {
        "id": "u-epi-2", "entity": "urine-epi-mixed", "quiz": None,
        **commons("File:UrinaryInfection.jpg", "J3D3", "CC BY-SA 3.0",
                  (1561, 1371), "2010-10-12"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/c/c6/UrinaryInfection.jpg",
        "caption": cap(
            "en",
            "Sample of urine from a patient with urinary infection. It's "
            "possible recognize epitelial cells, red blood cells and "
            "leukocytes",
            "Siydik yo‘llari infeksiyasi bo‘lgan bemorning siydik namunasi. "
            "Epiteliy hujayralari, eritrotsitlar va leykotsitlarni ajratish "
            "mumkin.",
            "Образец мочи пациента с инфекцией мочевыводящих путей. Можно "
            "различить эпителиальные клетки, эритроциты и лейкоциты.",
            "Urine sample from a patient with a urinary infection. "
            "Epithelial cells, red blood cells and leukocytes can be "
            "recognised.",
        ),
    },
    {
        "id": "u-rte-1", "entity": "urine-rte", "quiz": "field",
        **commons("File:RTcells.JPG", "Bobjgalindo", "CC BY-SA 4.0",
                  (1443, 1230), "2005-02-17"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/8/85/RTcells.JPG",
        "caption": cap(
            "en",
            "Renal tubular epithelial cells in a poorly collected urine "
            "sample.",
            "Noto‘g‘ri yig‘ilgan siydik namunasidagi buyrak kanalchalari "
            "epiteliy hujayralari.",
            "Клетки почечного канальцевого эпителия в неправильно собранной "
            "пробе мочи.",
            "Renal tubular epithelial cells in a poorly collected urine "
            "sample.",
        ),
    },
    # ---------------------------------------------------- siydik: silindrlar
    {
        "id": "u-cast-hyaline-1", "entity": "cast-hyaline", "quiz": "field",
        **commons("File:Hyaline Cast in Urine Microscopy.jpg",
                  "Ajay Kumar Chaurasiya", "CC BY-SA 4.0", (3264, 2448),
                  "2017-08-16"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/b/b6/Hyaline_Cast_in_Urine_Microscopy.jpg",
        "caption": cap(
            "en",
            "Hyaline casts are a type of urinary cast that can be observed "
            "during urine microscopy. Urinary casts are cylindrical "
            "structures that can form in the renal tubules of the kidneys "
            "and are composed of various materials",
            "Gialin silindrlar — siydik mikroskopiyasida ko‘rinishi mumkin "
            "bo‘lgan siydik silindrlarining bir turi. Siydik silindrlari — "
            "buyrak kanalchalarida hosil bo‘lishi mumkin bo‘lgan, turli "
            "moddalardan tashkil topgan silindrsimon tuzilmalar.",
            "Гиалиновые цилиндры — разновидность мочевых цилиндров, которую "
            "можно увидеть при микроскопии мочи. Мочевые цилиндры — "
            "цилиндрические структуры, которые могут образовываться в "
            "почечных канальцах и состоят из различных материалов.",
            "Hyaline casts are a type of urinary cast that can be seen on "
            "urine microscopy. Urinary casts are cylindrical structures that "
            "can form in the renal tubules and are made of various materials.",
        ),
    },
    {
        "id": "u-cast-granular-1", "entity": "cast-granular", "quiz": "field",
        **commons("File:Granular Casts in Urine Microscopy.jpg",
                  "Ajay Kumar Chaurasiya", "CC BY 4.0", (4000, 2250),
                  "2023-12-20"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/b/b5/Granular_Casts_in_Urine_Microscopy.jpg",
        "caption": cap(
            "en",
            "Granular casts are cylindrical structures composed of protein "
            "material with embedded granules. They are typically larger than "
            "red or white blood cells but vary in size. Their appearance can "
            "range from finely granular to coarsely granular.",
            "Donador silindrlar — oqsil moddasidan iborat, ichida "
            "donachalar bo‘lgan silindrsimon tuzilmalar. Ular odatda "
            "eritrotsit yoki leykotsitdan kattaroq, ammo o‘lchami har xil. "
            "Ko‘rinishi mayda donadordan yirik donadorgacha bo‘lishi mumkin.",
            "Зернистые цилиндры — цилиндрические структуры из белкового "
            "материала с включёнными гранулами. Обычно они крупнее "
            "эритроцитов и лейкоцитов, но различаются по размеру. Их вид "
            "может быть от мелкозернистого до грубозернистого.",
            "Granular casts are cylindrical structures of protein material "
            "with embedded granules. They are usually larger than red or "
            "white cells but vary in size, from finely to coarsely granular.",
        ),
    },
    {
        "id": "u-cast-panel-1", "entity": "cast-panel", "quiz": None,
        **commons(
            "File:RTE cast, muddy granular cast, WBC cast and RBC cast in "
            "urine.jpg",
            "Mohsenin V.", "CC BY 4.0", (567, 337), "2017-01-01",
            credit="Mohsenin V. Practical approach to detection and "
            "management of acute kidney injury in critically ill patient. "
            "J Intensive Care. 2017;5:57. doi:10.1186/s40560-017-0251-y "
            "(PMC5603084)"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/8/87/RTE_cast%2C_muddy_granular_cast%2C_WBC_cast_and_RBC_cast_in_urine.jpg",
        "caption": cap(
            "en",
            "From source: \"Urine microscopy for analysis of urine sediments. "
            "Renal tubular epithelial cell casts (a) and “Muddy” brown "
            "granular casts (b) suggest acute tubular injury/necrosis (ATN) "
            "as the etiology of AKI. White blood cell casts are generally "
            "seen in acute interstitial nephritis or acute pyelonephritis "
            "(c). Red cell cast denotes glomerular disease as in "
            "glomerulonephritis or small vessel vasculitis (d)\"",
            "Manbadan: «Siydik cho‘kmasini tahlil qilish uchun siydik "
            "mikroskopiyasi. Buyrak kanalchalari epiteliy hujayrali "
            "silindrlar (a) va «loyqa» jigarrang donador silindrlar (b) "
            "o‘tkir buyrak shikastlanishi (AKI) sababi sifatida o‘tkir "
            "kanalcha shikastlanishi/nekrozi (ATN)ga ishora qiladi. "
            "Leykotsitar silindrlar odatda o‘tkir interstitsial nefrit yoki "
            "o‘tkir pielonefritda uchraydi (c). Eritrotsitar silindr "
            "glomerulonefrit yoki mayda tomirlar vaskuliti kabi koptokcha "
            "kasalligini bildiradi (d)»",
            "Из источника: «Микроскопия мочи для анализа мочевого осадка. "
            "Цилиндры из клеток почечного канальцевого эпителия (a) и "
            "«грязно-бурые» зернистые цилиндры (b) указывают на острое "
            "канальцевое повреждение/некроз (ATN) как причину ОПП (AKI). "
            "Лейкоцитарные цилиндры обычно наблюдаются при остром "
            "интерстициальном нефрите или остром пиелонефрите (c). "
            "Эритроцитарный цилиндр указывает на гломерулярное заболевание, "
            "например гломерулонефрит или васкулит мелких сосудов (d)»",
            "From the source: “Urine microscopy for analysis of urine "
            "sediments. Renal tubular epithelial cell casts (a) and muddy "
            "brown granular casts (b) suggest acute tubular injury/necrosis "
            "(ATN) as the cause of AKI. White cell casts are generally seen "
            "in acute interstitial nephritis or acute pyelonephritis (c). A "
            "red cell cast denotes glomerular disease such as "
            "glomerulonephritis or small vessel vasculitis (d).”",
        ),
    },
    # ---------------------------------------------------- siydik: kristallar
    {
        "id": "u-cryst-caox-1", "entity": "crystal-caox", "quiz": "field",
        **commons(
            "File:Calcium Oxalate Monohydrate Crystals in Urine "
            "Microscopy.jpg",
            "Ajay Kumar Chaurasiya", "CC BY-SA 4.0", (4000, 3000),
            "2021-12-13"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/8/86/Calcium_Oxalate_Monohydrate_Crystals_in_Urine_Microscopy.jpg",
        "magnification": "1600X",
        "caption": cap(
            "en",
            "Calcium Oxalate Monohydrate Crystals in Urine Sediment "
            "Microscopy at Magnification of 1600X",
            "Siydik cho‘kmasi mikroskopiyasida kalsiy oksalat monogidrat "
            "kristallari (1600X kattalashtirish)",
            "Кристаллы моногидрата оксалата кальция при микроскопии "
            "мочевого осадка (увеличение 1600X)",
            "Calcium oxalate monohydrate crystals on urine sediment "
            "microscopy (1600X magnification)",
        ),
    },
    {
        "id": "u-cryst-uric-1", "entity": "crystal-uric", "quiz": "field",
        **commons("File:UricAcid.jpg", "J3D3", "CC BY-SA 3.0", (1597, 1536),
                  "2010-10-11"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/f/f8/UricAcid.jpg",
        "caption": cap(
            "en",
            "Uric acid cristals in a sample of urine from a patient with "
            "leukemia.",
            "Leykemiyali bemor siydik namunasidagi siydik kislotasi "
            "kristallari.",
            "Кристаллы мочевой кислоты в пробе мочи пациента с лейкемией.",
            "Uric acid crystals in a urine sample from a patient with "
            "leukaemia.",
        ),
    },
    {
        "id": "u-cryst-triple-1", "entity": "crystal-triple", "quiz": "field",
        **commons(
            "File:Кристаллы трипельфосфата в форме гробовых крышек и призм "
            "на фоне аморфных фосфатов. Осадок мочи. Нативный препарат. "
            "x400.jpg",
            "Vladimir064", "CC BY 4.0", (1810, 1741), "2017-10-30"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/3/32/%D0%9A%D1%80%D0%B8%D1%81%D1%82%D0%B0%D0%BB%D0%BB%D1%8B_%D1%82%D1%80%D0%B8%D0%BF%D0%B5%D0%BB%D1%8C%D1%84%D0%BE%D1%81%D1%84%D0%B0%D1%82%D0%B0_%D0%B2_%D1%84%D0%BE%D1%80%D0%BC%D0%B5_%D0%B3%D1%80%D0%BE%D0%B1%D0%BE%D0%B2%D1%8B%D1%85_%D0%BA%D1%80%D1%8B%D1%88%D0%B5%D0%BA_%D0%B8_%D0%BF%D1%80%D0%B8%D0%B7%D0%BC_%D0%BD%D0%B0_%D1%84%D0%BE%D0%BD%D0%B5_%D0%B0%D0%BC%D0%BE%D1%80%D1%84%D0%BD%D1%8B%D1%85_%D1%84%D0%BE%D1%81%D1%84%D0%B0%D1%82%D0%BE%D0%B2._%D0%9E%D1%81%D0%B0%D0%B4%D0%BE%D0%BA_%D0%BC%D0%BE%D1%87%D0%B8._%D0%9D%D0%B0%D1%82%D0%B8%D0%B2%D0%BD%D1%8B%D0%B9_%D0%BF%D1%80%D0%B5%D0%BF%D0%B0%D1%80%D0%B0%D1%82._x400.jpg",
        "magnification": "x400",
        "stain": stain("Native preparation",
                       "Nativ preparat (bo‘yalmagan)",
                       "Нативный препарат (неокрашенный)",
                       "Native preparation (unstained)"),
        "caption": cap(
            "en",
            "Triple phosphate crystals in the form of coffin caps and prisms "
            "against the background of amorphous crystals in human urine. "
            "Native preparation.x400",
            "Odam siydigida amorf kristallar fonida «tobut qopqog‘i» va "
            "prizma shaklidagi tripelfosfat kristallari. Nativ preparat. "
            "x400",
            "Кристаллы трипельфосфата в форме «гробовых крышек» и призм на "
            "фоне аморфных кристаллов в моче человека. Нативный препарат. "
            "x400",
            "Triple phosphate crystals shaped like coffin lids and prisms on "
            "a background of amorphous crystals in human urine. Native "
            "preparation, x400.",
        ),
    },
    {
        "id": "u-cryst-cystine-1", "entity": "crystal-cystine",
        "quiz": "field",
        **commons("File:Cystine in Urine.jpg", "J3D3", "CC BY-SA 4.0",
                  (2592, 1944), "2019-04-17"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/a/aa/Cystine_in_Urine.jpg",
        "caption": cap(
            "es",
            "Cristal de Cistina en orina.",
            "Siydikdagi sistin kristali.",
            "Кристалл цистина в моче.",
            "Cystine crystal in urine.",
        ),
    },
    # ------------------------------------------------------- qon: leykotsit
    {
        "id": "b-neut-1", "entity": "neutrophil", "quiz": "centre",
        **commons(
            "File:WBC (neutrophil) at centre, numerous erythrocytes and "
            "platelets (dot like bodies) in Wright's stained peripheral blood "
            "smear (PBS) microscopy.jpg",
            "Ajay Kumar Chaurasiya", "CC BY-SA 4.0", (3264, 2448),
            "2017-08-02"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/0/0b/WBC_%28neutrophil%29_at_centre%2C_numerous_erythrocytes_and_platelets_%28dot_like_bodies%29_in_Wright%27s_stained_peripheral_blood_smear_%28PBS%29_microscopy.jpg",
        # Bo'yoq fayl nomida: “…in Wright's stained peripheral blood smear”.
        "stain": stain("Wright's stain", "Rayt bo‘yog‘i", "Окраска по Райту",
                       "Wright's stain"),
        "caption": cap(
            "en",
            "WBC (White Blood Cell) at Center (Neutrophil): In a peripheral "
            "blood smear, white blood cells are typically observed. "
            "Neutrophils are a type of white blood cell and are one of the "
            "body's primary defenses against infection. Finding neutrophils "
            "in the blood smear is normal, and the presence of these cells "
            "suggests that the immune system is actively monitoring for "
            "potential infections. Numerous Erythrocytes (Red Blood Cells): "
            "Erythrocytes, or red blood cells (RBCs), are responsible for "
            "carrying oxygen from the lungs to the body's tissues and "
            "returning carbon dioxide to the lungs for exhalation. It's "
            "normal to observe numerous RBCs in a peripheral blood smear. A "
            "high number of RBCs could be associated with conditions like "
            "polycythemia or dehydration. Platelets (Dot-like Bodies): "
            "Platelets are small cell fragments involved in blood clotting "
            "and wound healing. They appear as small, dot-like structures in "
            "a peripheral blood smear. The presence of a normal number of "
            "platelets is essential for proper clotting. Low platelet counts "
            "(thrombocytopenia) or abnormal platelet function can lead to "
            "bleeding disorders.",
            "Markazdagi leykotsit (neytrofil): periferik qon surtmasida "
            "odatda leykotsitlar ko‘rinadi. Neytrofillar leykotsitlarning bir "
            "turi va organizmning infeksiyaga qarshi asosiy himoyalaridan "
            "biri. Qon surtmasida neytrofil topilishi normal; bu hujayralar "
            "immun tizimi ehtimoliy infeksiyalarni faol kuzatib turganini "
            "ko‘rsatadi. Ko‘p sonli eritrotsitlar (qizil qon hujayralari): "
            "eritrotsitlar o‘pkadan to‘qimalarga kislorod tashiydi va "
            "karbonat angidridni nafas bilan chiqarish uchun o‘pkaga "
            "qaytaradi. Periferik qon surtmasida ko‘p eritrotsit ko‘rinishi "
            "normal. Eritrotsitlar ko‘pligi politsitemiya yoki suvsizlanish "
            "kabi holatlar bilan bog‘liq bo‘lishi mumkin. Trombotsitlar "
            "(nuqtasimon tanachalar): trombotsitlar qon ivishi va yara "
            "bitishida qatnashadigan kichik hujayra bo‘laklari. Periferik qon "
            "surtmasida ular kichik nuqtasimon tuzilmalar ko‘rinishida. "
            "To‘g‘ri qon ivishi uchun trombotsitlar soni normal bo‘lishi "
            "zarur. Trombotsitlar kamligi (trombotsitopeniya) yoki ular "
            "funksiyasining buzilishi qon ketishi bilan kechadigan "
            "kasalliklarga olib kelishi mumkin.",
            "Лейкоцит в центре (нейтрофил): в мазке периферической крови "
            "обычно видны лейкоциты. Нейтрофилы — разновидность лейкоцитов "
            "и одна из основных защит организма от инфекции. Обнаружение "
            "нейтрофилов в мазке — норма; их присутствие говорит о том, что "
            "иммунная система активно отслеживает возможные инфекции. "
            "Многочисленные эритроциты (красные клетки крови): эритроциты "
            "переносят кислород из лёгких к тканям и возвращают углекислый "
            "газ в лёгкие для выдоха. Многочисленные эритроциты в мазке "
            "периферической крови — норма. Большое их количество может быть "
            "связано с такими состояниями, как полицитемия или "
            "обезвоживание. Тромбоциты (точечные тельца): тромбоциты — "
            "мелкие фрагменты клеток, участвующие в свёртывании крови и "
            "заживлении ран. В мазке они выглядят как мелкие точечные "
            "структуры. Нормальное количество тромбоцитов необходимо для "
            "правильного свёртывания. Низкое число тромбоцитов "
            "(тромбоцитопения) или нарушение их функции могут приводить к "
            "нарушениям с кровотечениями.",
            "White blood cell at the centre (neutrophil): white cells are "
            "typically seen in a peripheral blood smear. Neutrophils are a "
            "type of white cell and one of the body's main defences against "
            "infection; finding them in a smear is normal. Numerous red "
            "blood cells: they carry oxygen from the lungs to the tissues and "
            "return carbon dioxide to the lungs. Many red cells in a smear "
            "are normal; a high number may be linked to polycythaemia or "
            "dehydration. Platelets (dot-like bodies): small cell fragments "
            "involved in clotting and wound healing, seen as small dots. A "
            "normal platelet number is essential for clotting; low counts "
            "(thrombocytopenia) or abnormal function can cause bleeding "
            "disorders.",
        ),
    },
    {
        "id": "b-neut-2", "entity": "neutrophil", "quiz": "arrowhead",
        **phil("18910", "CDC/ Dr. F. Gilbert", "1972", (3045, 2005),
               "https://wwwn.cdc.gov/phil///PHIL_Images/18910/18910_lores.jpg"),
        "file_url": "https://wwwn.cdc.gov/phil///PHIL_Images/18910/18910.tif",
        "magnification": "1000X",
        "caption": cap(
            "en",
            "Under a magnification of 1000X, this photomicrograph of a blood "
            "smear, revealed the presence of a white blood cell (WBC), known "
            "as a polymorphonuclear leukocyte (PMN), or more specifically, as "
            "a neutrophil (arrowhead). This WBC was surrounded by numbers of "
            "normal red blood cells (RBCs), also referred to as erythrocytes.",
            "1000X kattalashtirishda olingan qon surtmasining ushbu "
            "mikrofotosida polimorfonuklear leykotsit (PMN), aniqrog‘i "
            "neytrofil (strelka) ko‘rinadi. Uning atrofida ko‘plab normal "
            "eritrotsitlar bor.",
            "На этой микрофотографии мазка крови при увеличении 1000X виден "
            "полиморфноядерный лейкоцит (PMN), а точнее нейтрофил "
            "(стрелка). Он окружён множеством нормальных эритроцитов.",
            "At 1000X magnification, this blood smear photomicrograph shows "
            "a polymorphonuclear leukocyte (PMN), specifically a neutrophil "
            "(arrowhead), surrounded by many normal red blood cells.",
        ),
    },
    {
        "id": "b-lymph-1", "entity": "lymphocyte", "quiz": "arrowhead",
        **phil("18909", "CDC/ Dr. F. Gilbert", "1972", (3045, 2005),
               "https://wwwn.cdc.gov/phil///PHIL_Images/18909/18909_lores.jpg"),
        "file_url": "https://wwwn.cdc.gov/phil///PHIL_Images/18909/18909.tif",
        "magnification": "1000X",
        "caption": cap(
            "en",
            "Under a magnification of 1000X, this photomicrograph of a blood "
            "smear, revealed the presence of a leukocyte, or white blood cell "
            "(WBC), specifically known as a lymphocyte (arrowhead). This WBC "
            "was surrounded by numbers of normal red blood cells (RBCs), also "
            "referred to as erythrocytes.",
            "1000X kattalashtirishda olingan qon surtmasining ushbu "
            "mikrofotosida leykotsit, aniqrog‘i limfotsit (strelka) "
            "ko‘rinadi. Uning atrofida ko‘plab normal eritrotsitlar bor.",
            "На этой микрофотографии мазка крови при увеличении 1000X виден "
            "лейкоцит, а именно лимфоцит (стрелка). Он окружён множеством "
            "нормальных эритроцитов.",
            "At 1000X magnification, this blood smear photomicrograph shows a "
            "white blood cell, specifically a lymphocyte (arrowhead), "
            "surrounded by many normal red blood cells.",
        ),
    },
    {
        "id": "b-mono-1", "entity": "monocyte", "quiz": "centre",
        **phil("30136", "CDC/ Dr. Candler Ballard", "1974", (3229, 2093),
               "https://wwwn.cdc.gov/phil///PHIL_Images/30136/30136_lores.jpg"),
        "file_url": "https://wwwn.cdc.gov/phil///PHIL_Images/30136/30136.tif",
        "caption": cap(
            "en",
            "This photomicrograph of a blood specimen shows the morphology of "
            "a normal monocyte.",
            "Qon namunasining ushbu mikrofotosi normal monotsit "
            "morfologiyasini ko‘rsatadi.",
            "Эта микрофотография образца крови показывает морфологию "
            "нормального моноцита.",
            "This photomicrograph of a blood specimen shows the morphology of "
            "a normal monocyte.",
        ),
    },
    {
        "id": "b-eos-1", "entity": "eosinophil", "quiz": "arrowhead",
        **phil("18907", "CDC/ Dr. F. Gilbert", "1972", (3045, 2005),
               "https://wwwn.cdc.gov/phil///PHIL_Images/18907/18907_lores.jpg"),
        "file_url": "https://wwwn.cdc.gov/phil///PHIL_Images/18907/18907.tif",
        "magnification": "1000X",
        "caption": cap(
            "en",
            "Under a magnification of 1000X, this photomicrograph of a blood "
            "smear, revealed the presence of an eosinophilic leukocyte "
            "(arrowhead), also known as an eosinophil, a type of white blood "
            "cell (WBC). A polymorphonuclear WBC, due to its multilobular "
            "nucleus, the eosinophil is categorized as a granulocyte due to "
            "the presence of granules in the cell’s cytoplasm. Surrounding "
            "this eosinophil, were numerous red blood cells (RBCs), also "
            "referred to as erythrocytes.",
            "1000X kattalashtirishda olingan qon surtmasining ushbu "
            "mikrofotosida eozinofil leykotsit (strelka), ya’ni eozinofil — "
            "leykotsitlarning bir turi ko‘rinadi. Ko‘p bo‘lakli yadrosi "
            "tufayli polimorfonuklear leykotsit bo‘lgan eozinofil "
            "sitoplazmasida donachalar borligi uchun granulotsitlarga "
            "kiritiladi. Eozinofil atrofida ko‘plab eritrotsitlar bor.",
            "На этой микрофотографии мазка крови при увеличении 1000X виден "
            "эозинофильный лейкоцит (стрелка), или эозинофил, — "
            "разновидность лейкоцитов. Полиморфноядерный из-за "
            "многодольчатого ядра, эозинофил относится к гранулоцитам "
            "благодаря гранулам в цитоплазме. Вокруг эозинофила — "
            "многочисленные эритроциты.",
            "At 1000X magnification, this blood smear photomicrograph shows "
            "an eosinophilic leukocyte (arrowhead), or eosinophil, a type of "
            "white cell. Polymorphonuclear because of its multilobed nucleus, "
            "it is classed as a granulocyte because of the granules in its "
            "cytoplasm. It is surrounded by numerous red blood cells.",
        ),
    },
    {
        "id": "b-baso-1", "entity": "basophil", "quiz": "arrowhead",
        **phil("18908", "CDC/ Dr. F. Gilbert", "1972", (3045, 2005),
               "https://wwwn.cdc.gov/phil///PHIL_Images/18908/18908_lores.jpg"),
        "file_url": "https://wwwn.cdc.gov/phil///PHIL_Images/18908/18908.tif",
        "magnification": "1000X",
        "caption": cap(
            "en",
            "Under a magnification of 1000X, this photomicrograph of a blood "
            "smear, revealed the presence of a basophilic leukocyte "
            "(arrowhead), also known as an basophil, a type of white blood "
            "cell (WBC). A polymorphonuclear (PMN) WBC, due to its "
            "multilobular nucleus, which here, is difficult to see, this "
            "basophil is categorized as a granulocyte, due to the presence of "
            "abundant large granules in the cell cytoplasm. Surrounding the "
            "basophil were numerous red blood cells (RBCs), also referred to "
            "as erythrocytes.",
            "1000X kattalashtirishda olingan qon surtmasining ushbu "
            "mikrofotosida bazofil leykotsit (strelka), ya’ni bazofil — "
            "leykotsitlarning bir turi ko‘rinadi. Ko‘p bo‘lakli yadrosi (bu "
            "yerda u qiyin ko‘rinadi) tufayli polimorfonuklear (PMN) "
            "leykotsit bo‘lgan bazofil sitoplazmasida ko‘p sonli yirik "
            "donachalar borligi uchun granulotsitlarga kiritiladi. Bazofil "
            "atrofida ko‘plab eritrotsitlar bor.",
            "На этой микрофотографии мазка крови при увеличении 1000X виден "
            "базофильный лейкоцит (стрелка), или базофил, — разновидность "
            "лейкоцитов. Полиморфноядерный (PMN) из-за многодольчатого ядра, "
            "которое здесь плохо видно, базофил относится к гранулоцитам "
            "благодаря обилию крупных гранул в цитоплазме. Вокруг базофила — "
            "многочисленные эритроциты.",
            "At 1000X magnification, this blood smear photomicrograph shows "
            "a basophilic leukocyte (arrowhead), or basophil, a type of white "
            "cell. Polymorphonuclear (PMN) because of its multilobed nucleus, "
            "which is hard to see here, it is classed as a granulocyte "
            "because of the abundant large granules in its cytoplasm. It is "
            "surrounded by numerous red blood cells.",
        ),
    },
    # ----------------------------------------------------- qon: eritrotsit
    {
        "id": "b-acanth-1", "entity": "acanthocyte", "quiz": "field",
        **commons(
            "File:Acanthocytosis.jpg",
            "Rola Zamel, Razi Khan, Rebecca L Pollex and Robert A Hegele",
            "CC BY 2.0", (902, 671), "2008-07-08",
            credit="Abetalipoproteinemia: two case reports and literature "
            "review. Orphanet Journal of Rare Diseases 2008, 3:19. "
            "doi:10.1186/1750-1172-3-19"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/e/e5/Acanthocytosis.jpg",
        "caption": cap(
            "en",
            "Acanthocytes on the peripheral blood smear of a patient with "
            "abetalipoproteinemia.",
            "Abetalipoproteinemiyali bemorning periferik qon surtmasidagi "
            "akantotsitlar.",
            "Акантоциты в мазке периферической крови пациента с "
            "абеталипопротеинемией.",
            "Acanthocytes on the peripheral blood smear of a patient with "
            "abetalipoproteinaemia.",
        ),
    },
    {
        "id": "b-acanth-2", "entity": "acanthocyte", "quiz": "centre",
        **commons("File:Acanthocyte smear 2009-10-08.JPG",
                  "Paulo Henrique Orlandi Mourao", "CC BY-SA 3.0",
                  (3072, 2304), "2009-10-08"),
        "file_url": "https://upload.wikimedia.org/wikipedia/commons/c/cc/Acanthocyte_smear_2009-10-08.JPG",
        # Sahifa matni: “Peripheral Blood / May-Grunwald Giemsa (MGG) stain”.
        "stain": stain("May-Grunwald Giemsa (MGG) stain",
                       "May-Grünwald–Giemsa (MGG) bo‘yog‘i",
                       "Окраска по Май-Грюнвальду — Гимзе (MGG)",
                       "May-Grünwald–Giemsa (MGG) stain"),
        "caption": cap(
            "en",
            "Acanthocyte",
            "Akantotsit",
            "Акантоцит",
            "Acanthocyte",
        ),
    },
    # ----------------------------------------------------------- parazitlar
    {
        "id": "p-mal-thin-1", "entity": "malaria-thin", "quiz": "field",
        **phil("5861", "CDC/ Steven Glenn, Laboratory & Consultation Division",
               "1979", (1757, 1192),
               "https://wwwn.cdc.gov/phil///PHIL_Images/20040624/34d6cf48e6eb417eb890cd6f85a70f22/5861_lores.jpg"),
        "file_url": "https://wwwn.cdc.gov/phil///PHIL_Images/20040624/34d6cf48e6eb417eb890cd6f85a70f22/5861.tif",
        "stain": stain("Giemsa", "Giemsa bo‘yog‘i",
                       "Окраска по Гимзе", "Giemsa"),
        "caption": cap(
            "en",
            "This Giemsa-stained, thin film blood smear photomicrograph "
            "reveals the presence of numerous of ring-form, Plasmodium "
            "falciparum trophozoites, with some infected red blood cells "
            "(RBCs) harboring multiple organisms.",
            "Giemsa bilan bo‘yalgan yupqa qon surtmasining ushbu "
            "mikrofotosida ko‘plab halqasimon Plasmodium falciparum "
            "trofozoitlari ko‘rinadi; ba’zi zararlangan eritrotsitlarda bir "
            "nechta parazit bor.",
            "На этой микрофотографии тонкого мазка крови, окрашенного по "
            "Гимзе, видны многочисленные кольцевидные трофозоиты Plasmodium "
            "falciparum; в некоторых инфицированных эритроцитах — по "
            "несколько паразитов.",
            "This Giemsa-stained thin blood film photomicrograph shows "
            "numerous ring-form Plasmodium falciparum trophozoites; some "
            "infected red cells contain more than one parasite.",
        ),
    },
    {
        "id": "p-mal-thick-1", "entity": "malaria-thick", "quiz": "field",
        **phil("22817", "CDC/ Dr. Mae Mellvin", "1971", (3045, 2005),
               "https://wwwn.cdc.gov/phil///PHIL_Images/22817/22817_lores.jpg"),
        "file_url": "https://wwwn.cdc.gov/phil///PHIL_Images/22817/22817.tif",
        "magnification": "1125X",
        "stain": stain("Giemsa", "Giemsa bo‘yog‘i",
                       "Окраска по Гимзе", "Giemsa"),
        "caption": cap(
            "en",
            "Under a magnification of 1125X, this photomicrograph of a Giemsa "
            "stained thick film blood smear, revealed a number of Plasmodium "
            "falciparum parasites, in the form of gametocytes, and ring-form "
            "trophozoites.",
            "1125X kattalashtirishda olingan, Giemsa bilan bo‘yalgan qalin "
            "qon surtmasining ushbu mikrofotosida gametotsit va halqasimon "
            "trofozoit shaklidagi bir qancha Plasmodium falciparum "
            "parazitlari ko‘rinadi.",
            "На этой микрофотографии толстого мазка крови, окрашенного по "
            "Гимзе, при увеличении 1125X видны паразиты Plasmodium "
            "falciparum в форме гаметоцитов и кольцевидных трофозоитов.",
            "At 1125X magnification, this Giemsa-stained thick blood film "
            "photomicrograph shows several Plasmodium falciparum parasites as "
            "gametocytes and ring-form trophozoites.",
        ),
    },
]

# Ko'rib chiqilgan, lekin olinmagan nomzodlar (hisobot va keyingi ish uchun).
REJECTED = [
    ("CDC PHIL ID#18906", "Limfotsit + neytrofil bitta maydonda; limfotsit "
     "uchun aniqroq #18909 olindi (mashqda chalkashlik bo'lmasin)."),
    ("File:Struvite crystals (urine) - Strüvit kristalleri (idrar) - 01.png",
     "Avtomatik analizator tasviri; tripelfosfat uchun oddiy mikroskop "
     "fotosi (x400, nativ) olindi."),
    ("File:Dismorpha red cells.jpg, File:G1 red cells.jpg",
     "Commons'da umumiy «Attribution» shabloni — ruxsat ro'yxatida emas."),
    ("File:Red blood cell cast in urine sediment.jpg, File:Uric acid crystals "
     "in urine sediment.jpg, File:Human blood film with acanthocytes 01/02.jpg",
     "Commons'da CC BY deyilgan, lekin manbasi StatPearls/NCBI — asl "
     "litsenziyani tekshirib bo'lmadi (reCAPTCHA)."),
    ("Mkaercher (Epithelzelle…, Leukozyten…, Zylinder…)",
     "Akridin-oranj fluoressensiya, 531×384 px — yorug' maydon atlasi uchun "
     "mos emas."),
]


def sha256(path):
    h = hashlib.sha256()
    h.update(path.read_bytes())
    return h.hexdigest()


def jpeg_size(path):
    """JPEG o'lchami (SOF markeridan) — PIL'siz."""
    data = path.read_bytes()
    i = 2
    while i < len(data):
        if data[i] != 0xFF:
            raise ValueError(f"bad JPEG marker in {path}")
        marker = data[i + 1]
        length = int.from_bytes(data[i + 2:i + 4], "big")
        if marker in (0xC0, 0xC1, 0xC2):
            h = int.from_bytes(data[i + 5:i + 7], "big")
            w = int.from_bytes(data[i + 7:i + 9], "big")
            return w, h
        i += 2 + length
    raise ValueError(f"no SOF in {path}")


def check():
    errors = []
    entity_ids = {e["id"] for e in ENTITIES}
    group_ids = {g["id"] for g in GROUPS}
    for e in ENTITIES:
        if e["group"] not in group_ids:
            errors.append(f"{e['id']}: unknown group")
        imgs = [i for i in IMAGES if i["entity"] == e["id"]]
        if "gap" in e and imgs:
            errors.append(f"{e['id']}: gap with images")
        if "gap" not in e and not imgs:
            errors.append(f"{e['id']}: no images and no gap")
    seen = set()
    for i in IMAGES:
        if i["id"] in seen:
            errors.append(f"duplicate {i['id']}")
        seen.add(i["id"])
        if i["entity"] not in entity_ids:
            errors.append(f"{i['id']}: unknown entity")
        lic = i["license"]
        if lic not in LICENSES or "NC" in lic or "ND" in lic:
            errors.append(f"{i['id']}: licence {lic}")
        if i["license_url"] != LICENSES.get(lic):
            errors.append(f"{i['id']}: licence url")
        if not i["author"].strip() or not i["source_page"].startswith("https://"):
            errors.append(f"{i['id']}: author/source")
        if i["provider"] == "cdc_phil" and not i["author"].startswith("CDC"):
            errors.append(f"{i['id']}: CDC credit")
        if not i["caption"]["text"].strip():
            errors.append(f"{i['id']}: caption")
    if errors:
        sys.exit("\n".join(errors))


def build():
    check()
    images = []
    total = 0
    for i in IMAGES:
        path = ROOT / IMG_DIR / f"{i['id']}.jpg"
        if not path.exists():
            sys.exit(f"missing image file: {path} (python3 tool/microscopy_images.py)")
        w, h = jpeg_size(path)
        if max(w, h) > MAX_SIDE:
            sys.exit(f"{path}: {w}x{h} > {MAX_SIDE}")
        ow, oh = i["original_size"]
        if (w, h) != (ow, oh) and abs(w / h - ow / oh) > 0.01:
            sys.exit(f"{path}: aspect changed (crop?) {w}x{h} vs {ow}x{oh}")
        size = path.stat().st_size
        total += size
        rec = {k: v for k, v in i.items() if k not in ("lores_url", "fetch")}
        rec["asset"] = f"{IMG_DIR}/{i['id']}.jpg"
        rec["size"] = [w, h]
        rec["bytes"] = size
        rec["sha256"] = sha256(path)
        rec.setdefault("magnification", None)
        rec.setdefault("stain", None)
        images.append(rec)
    if total > 6_300_000:
        sys.exit(f"images too large: {total} bytes")
    out = {
        "schema_version": 1,
        "atlas_version": ACCESSED,
        "accessed": ACCESSED,
        "max_side": MAX_SIDE,
        "sections": SECTIONS,
        "groups": GROUPS,
        "entities": ENTITIES,
        "images": images,
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=1) + "\n",
                   encoding="utf-8")
    print(f"{OUT.relative_to(ROOT)}: {len(images)} images, "
          f"{total / 1e6:.2f} MB, {len(ENTITIES)} entities")


if __name__ == "__main__":
    build()
