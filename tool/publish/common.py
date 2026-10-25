"""Shared constants for the LabGuide publishing kit (text only, stdlib).

Everything public-facing that is the same for every topic lives here: the mandatory disclosures,
the credits, the "about LabGuide" line, the paid-plan line, the platform limits we check against.

Nothing here publishes anything. All of it is draft text that needs the owner's approval.
Uzbek is Latin script: o‘ g‘ use U+2018, the tutuq belgisi uses U+2019 (docs/L10N_TERMINOLOGY_DECISIONS.md).
"""
from pathlib import Path

LANGS = ("en", "ru", "uz")
LANG_NAMES = {"en": "English", "ru": "Русский", "uz": "O‘zbekcha"}

REPO = Path(__file__).resolve().parents[2]
DOCS_VIDEO = REPO / "docs" / "video"
PUBLISH_DOCS = DOCS_VIDEO / "publishing"
OUT_ROOT = REPO / "video_studio" / "out"
AUDIO_ROOT = REPO / "video_studio" / "public" / "audio"

# Platform limits the kit is checked against (tests/lint). Verify before posting: platforms change them.
YT_TITLE_MAX = 70          # our own stricter limit (YouTube allows 100)
YT_DESC_MAX = 5000
YT_TAGS_MAX = 500
IG_CAPTION_MAX = 2200
HASHTAGS_MIN, HASHTAGS_MAX = 15, 25

# --- Mandatory disclosures (public wording) -------------------------------------------------
DISCLOSURES = {
    "illustrative": {
        "en": "Illustrative data — not patient results.",
        "ru": "Иллюстративные данные — не результаты пациентов.",
        "uz": "Namunaviy ma’lumotlar — bemor natijalari emas.",
    },
    "educational": {
        "en": "Educational use, not medical advice.",
        "ru": "Только для обучения; не является медицинской рекомендацией.",
        "uz": "Faqat o‘quv maqsadida; tibbiy maslahat emas.",
    },
    "voice": {
        "en": "English synthetic narration (Kokoro-82M, Apache-2.0).",
        "ru": "Озвучка на английском языке синтезирована ИИ (Kokoro-82M, Apache-2.0); субтитры на русском.",
        "uz": "Inglizcha diktor ovozi sun’iy intellekt yordamida yaratilgan (Kokoro-82M, Apache-2.0); subtitrlar o‘zbekcha.",
    },
    "review": {
        "en": "Expert review pending: this content has not yet been reviewed by a laboratory specialist.",
        "ru": "Экспертная проверка ожидается: материал пока не проверен специалистом лаборатории.",
        "uz": "Mutaxassis ko‘rigi kutilmoqda: material hali laboratoriya mutaxassisi tomonidan ko‘rib chiqilmagan.",
    },
}
# The English edition has English subtitles; the RU/UZ editions carry their own subtitles.
DISCLOSURES_EN_EDITION_VOICE = "English synthetic narration (Kokoro-82M, Apache-2.0); English subtitles."
DISCLOSURE_ORDER = ("illustrative", "educational", "voice", "review")

ABOUT = {
    "en": ("LabGuide is a clinical-laboratory companion app for lab professionals and students "
           "(English, Russian, Uzbek). It is a learning and reference tool: it does not diagnose "
           "or interpret patient results."),
    "ru": ("LabGuide — приложение-помощник для клинической лаборатории: для лаборантов и студентов "
           "(русский, узбекский, английский). Это учебный и справочный инструмент: он не ставит диагноз "
           "и не интерпретирует результаты пациентов."),
    "uz": ("LabGuide — klinik laboratoriya uchun yordamchi ilova: laborantlar va talabalar uchun "
           "(o‘zbek, rus, ingliz tillarida). Bu o‘quv va ma’lumotnoma vositasi: u tashxis qo‘ymaydi va "
           "bemor natijalarini talqin qilmaydi."),
}

# Heads-up used in public text: the offline/guest statement comes from docs/store/APP_STORE.md.
OFFLINE = {
    "en": "Works offline and without an account.",
    "ru": "Работает без интернета и без аккаунта.",
    "uz": "Internetsiz va hisobsiz ishlaydi.",
}

# Paid plans — public wording. Source: docs/DECISIONS.md D-77/D-78, docs/PAID_BRANCH_STATUS.md,
# docs/TIERS_FEATURE_MAP.md, docs/store/APP_STORE.md §16 (plan names). NEVER a price or a product id.
# Use ONLY for paid topics and ONLY when the owner confirms the paid build is live in the stores.
PAID_LINE = {
    "en": ("Pro features: part of LabGuide’s optional paid plans (Student Pro, Teacher Pro, Specialist Pro, "
           "Premium), with a 7-day free trial where offered. Features that are free today stay free. "
           "Prices are shown in the App Store / Google Play."),
    "ru": ("Функции Pro: входят в необязательные платные планы LabGuide (Студент Pro, Преподаватель Pro, "
           "Специалист Pro, Premium); 7-дневный бесплатный пробный период — там, где он предлагается. "
           "Функции, бесплатные сегодня, остаются бесплатными. Цены показываются в App Store / Google Play."),
    "uz": ("Pro imkoniyatlari: LabGuide’ning ixtiyoriy pullik rejalari (Talaba Pro, Ustoz Pro, Mutaxassis Pro, "
           "Premium) tarkibida; 7 kunlik bepul sinov — taklif qilingan joyda. Bugun bepul imkoniyatlar bepul "
           "qoladi. Narxlar App Store / Google Play’da ko‘rsatiladi."),
}

# Placeholders the owner replaces before posting (we never invent a URL or a store listing).
PLACEHOLDERS = {
    "[[LINK_APP_STORE]]": "App Store link of LabGuide (store approval status: owner to confirm)",
    "[[LINK_PLAY]]": "Google Play link of LabGuide (store approval status: owner to confirm)",
    "[[LINK_SITE]]": "LabGuide web page (owner to confirm it is live)",
    "[[LINK_BIO]]": "the link-in-bio target (Instagram)",
    "[[LINK_PLAYLIST]]": "the YouTube playlist link",
}

CREDITS = {
    "en": [
        "Narration: AI text-to-speech, Kokoro-82M v1.0 (Apache-2.0), voice af_heart, run with kokoro-onnx (MIT).",
        "Fonts: Inter and Instrument Serif, SIL Open Font License 1.1.",
        "Illustrations, schematics, animation and app screens: LabGuide (own work). No third-party "
        "photographs, stock footage, music or logos.",
        "Made with Remotion and FFmpeg.",
    ],
    "ru": [
        "Озвучка: синтез речи ИИ, Kokoro-82M v1.0 (Apache-2.0), голос af_heart, запуск через kokoro-onnx (MIT).",
        "Шрифты: Inter и Instrument Serif, SIL Open Font License 1.1.",
        "Иллюстрации, схемы, анимация и экраны приложения: LabGuide (собственная работа). Без сторонних "
        "фотографий, стоковых видео, музыки и логотипов.",
        "Сделано с помощью Remotion и FFmpeg.",
    ],
    "uz": [
        "Diktor ovozi: sun’iy intellekt nutq sintezi, Kokoro-82M v1.0 (Apache-2.0), ovoz af_heart, kokoro-onnx (MIT) orqali.",
        "Shriftlar: Inter va Instrument Serif, SIL Open Font License 1.1.",
        "Rasmlar, sxemalar, animatsiya va ilova ekranlari: LabGuide (o‘z ishi). Uchinchi tomon fotosuratlari, "
        "stok videolar, musiqa va logotiplar yo‘q.",
        "Remotion va FFmpeg yordamida yaratilgan.",
    ],
}

CREDITS_HEADING = {"en": "Credits", "ru": "Авторы и лицензии", "uz": "Mualliflar va litsenziyalar"}
CHAPTERS_HEADING = {"en": "Chapters", "ru": "Главы", "uz": "Boblar"}
SHOWS_HEADING = {"en": "In this video", "ru": "В этом видео", "uz": "Bu videoda"}
APP_HEADING = {"en": "What LabGuide does today", "ru": "Что LabGuide делает сегодня",
               "uz": "LabGuide bugun nima qiladi"}
LIMITS_HEADING = {"en": "Good to know", "ru": "Важно знать", "uz": "Bilish foydali"}
GET_HEADING = {"en": "Get the app", "ru": "Приложение", "uz": "Ilova"}

# Internal (never public) pre-publication gates, repeated in every kit and in SCHEDULE.md.
GATES = [
    ("G1", "Expert science review of the topic (claims table `docs/video/<id>/CLAIMS_AND_EVIDENCE.md`, rows tagged NEEDS_EXPERT)."),
    ("G2", "Listening review of the English synthetic voice by a person (nobody has listened to it yet)."),
    ("G3", "Native-speaker review of the RU and UZ subtitles, on-screen text and the RU/UZ texts in this kit."),
    ("G4", "Remotion licence check: free for individuals, non-profits and for-profit companies of up to 3 people; "
           "a larger company needs a Company licence (`video_studio/node_modules/remotion/LICENSE.md`)."),
    ("G5", "App availability: the free store build is the only one that exists publicly; the video must match "
           "the build the owner links to. Store approval status is the owner's to confirm."),
    ("G6", "Owner approval of every text in this kit and of the date. Nothing is published by us."),
]
GATE_SHORT = {"G1": "expert science review", "G2": "listening review of the voice",
              "G3": "native RU/UZ review", "G4": "Remotion licence check", "G5": "app availability / store status",
              "G6": "owner approval", "GP": "paid release live (paid topics only)"}
PAID_GATE = ("GP", "Paid release: Pro/Premium are NOT live (flags off, store products unconfirmed, no real sandbox "
                   "purchase ever run: docs/PAID_BRANCH_STATUS.md). Do not publish a paid-topic video before the "
                   "paid build is live in the stores and the owner confirms the plan names and the 7-day trial.")

SAFE_CONTENT_COMMON = [
    "No patient data, names or real results anywhere. All numbers on screen are illustrative and labelled so.",
    "No third-party logo, brand name, stock footage or music. The only logo is the owner's app icon.",
    "Do not call the voice \"natural\", \"professional\" or \"human\": it is synthetic and nobody has listened to it yet.",
    "Do not call the content \"approved\", \"verified\", \"certified\" or \"clinically validated\": expert review is pending.",
    "No diagnosis, treatment, dosing or \"normal range\" statement. Reference ranges come from the user's laboratory.",
    "Do not answer individual medical questions in comments; point to the user's laboratory SOP, the reagent IFU "
    "and the clinician.",
    "No price, discount, product id or availability date in any text (docs/DECISIONS.md D-77/D-78: prices live in the stores).",
    "Check the platform's own disclosure setting for AI-generated / synthetic voice before posting "
    "(NEEDS_OWNER_CHECK: the rules change; the kit already states the voice is synthetic in the text).",
    "Audience: not made for kids. Category: Education. Comments: moderate; hide spam and requests for medical advice.",
]

INTERNAL_LICENCE_NOTES = [
    "Rendered with Remotion: Remotion licence company-size condition is the owner's to confirm (gate G4).",
    "Voice: Kokoro-82M weights Apache-2.0 (hexgrad/Kokoro-82M); residual risk noted in docs/video/tts/VOICE_DECISION.md "
    "(synthetic training-data sources). No attribution is legally required; the kit credits it anyway.",
    "Fonts: Inter, Instrument Serif — OFL (`assets/fonts/*-OFL.txt`).",
    "Imagery: original schematics (`docs/SCHEMATICS_PROVENANCE.md`) and real app screens; no micrographs or photographs.",
    "Music: none. Logo: owner's app icon (`assets/images/logo_mark_large.png`).",
]
