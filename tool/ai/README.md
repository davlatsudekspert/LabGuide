# AI vazifalari (Claude API) — faqat qo'lda, faqat taklif

Bu papka GitHub Actions orqali **qo'lda** ishga tushiriladigan Claude API vazifalarini o'z ichiga oladi:
ilova mazmuniga ikkinchi fikr (sharh), rus terminologiyasi, test savollari qoralamasi va uz/ru/en moslik tekshiruvi.
Natijalar — **takliflar**; ularni odam ko'rib chiqadi. Hech narsa ilovaga avtomatik tushmaydi (docs/DECISIONS.md, D-55).

## Qanday ishga tushiriladi

1. GitHub'da repo → **Actions** → chap tomondan **AI tasks** → **Run workflow** (tarmoq: `main`).
2. Maydonlar:

| Maydon | Ma'nosi |
|---|---|
| `task` | `content_review` · `ru_terminology` · `quiz_draft` · `translate_check` |
| `target` | nimani tekshirish (pastdagi jadval) |
| `model` | `claude-sonnet-5-5` (standart) yoki `claude-opus-5-5` (faqat `content_review`) |
| `max_items` | eng ko'pi bilan nechta element; standart 20, **qat'iy chegara 60** |
| `dry_run` | **standart `true`**: nima yuborilishi, token va narx taxmini ko'rsatiladi; API chaqirilmaydi, kalit ham berilmaydi |
| `budget_usd` | bitta ishga tushirish uchun USD chegarasi; standart 3, eng ko'pi 10 |

3. **Avval har doim `dry_run = true`** bilan ishga tushiring: ro'yxat va taxminiy narxni ko'ring (run sahifasidagi
   *Summary*). Mos bo'lsa, xuddi shu sozlamalar bilan `dry_run = false` qilib qayta ishga tushiring.

### `target` namunalari

| target | Nima |
|---|---|
| `cytology`, `spermogram`, `bloodgroup` | shu bo'limning Dart kontent fayllaridagi matnlar (`LocalizedText` + `CalcRef`) |
| `analytes`, `conditions`, `pack` | `assets/content/core/pack.json`: analitlar / holatlar / ikkalasi |
| `analyte:alt`, `condition:type-2-diabetes`, `quiz:ogtt-q1` | bitta element |
| `group:liver` | guruhdagi barcha analitlar |
| `all-small` (yoki `all`) | barcha sohalardan navbat bilan namuna; `max_items` bilan cheklanadi |
| `lib/features/spermogram/spermogram_content.dart` | bitta Dart fayl |
| `id:<to'liq id>`, `contains:<qism>` | element identifikatori bo'yicha |
| `analyte:alt,cytology` | vergul bilan bir nechta |

Kutubxona (`library`) yozuvlari **hech qachon yuborilmaydi** (ba'zi kitoblar litsenziyasi AI'ga berishni taqiqlaydi).
Manba hujjatlarining matni ham yuborilmaydi — faqat ilovaning o'z matni va havola ma'lumotlari
(sarlavha, nashriyot, lokator).

## Vazifalar

- **content_review** — ilova matnining mustaqil ikkinchi fikri. Model FAQAT quyidagilarni belgilaydi: shubhali
  raqam/birlik, uz/ru/en nomuvofiqligi, ortiqcha da'vo ("tasdiqlaydi", tashxis ohangi), yetishmayotgan ogohlantirish.
  Tekshira olmasa "Cannot verify" deydi, xotiradan "to'g'ri javob" aytmaydi, mazmunni tahrirlamaydi.
  Har bir topilma: element id, jiddiylik (`info/minor/major/critical`), iqtibos, sabab, nimani tekshirish kerak.
  Iqtibos element matnida bormi — kod tekshiradi (`quote_verified`).
- **ru_terminology** — rus klinik-laboratoriya terminlari (GOST R ISO 15189 uslubi, mashhur kasbiy qo'llanish);
  takliflar ishonch darajasi bilan. Standart bandlari keltirilmaydi (model standart matnini ko'rmaydi).
- **quiz_draft** — kartadagi matndan (analit/bo'lim kartalari) test savollari. Har bir savol shu matndan
  so'zma-so'z olingan gapni keltirishi shart; kod buni tekshiradi va mos kelmaganlarini rad etadi (`rejected`).
  Natija repo test sxemasiga yaqin JSON, lekin `status`/`review_state` = **`ai_draft`** — ilova bu qiymatni
  tanimaydi, ya'ni `pack.json` ga odam qo'lda ko'chirib, holatini o'zi qo'ymaguncha kirmaydi. Spetsifikatsiya bo'yicha
  4 variant; ilovadagi mavjud testlarda hozir 3 variant — kerak bo'lsa skriptda `--options 3`.
- **translate_check** — uz/ru/en ma'nosi mosligi: farq qilgan raqam, shart, da'voning kuchi, tushib qolgan/qo'shilgan fikr.

## Natijani qayerdan o'qish

- Tarmoq **`ai-reports`** (main emas!): `docs/ai_reports/<sana>_<vazifa>_<target>.md` (o'qish uchun) va `.json` (mashina uchun).
  Bir kunda takroran ishga tushirilsa nom `_r2`, `_run<id>` bilan davom etadi — eski hisobot ustiga yozilmaydi.
- Xuddi shu fayllar run sahifasida **Artifacts** ostida (`ai-report-<run id>`, 30 kun).
- Run sahifasining *Summary* qismida qisqa xulosa (holat, token, narx).
- `ai-reports` ni `main` ga **merge qilmang**: kerakli xulosalarni qo'lda ko'chiring (alohida PR).

Hisobot holati: `complete` / `partial` (byudjet tugadi yoki ayrim elementlar xato) / `failed`.

## Taxminiy narx

Sonnet 5.5: kirish $2 / chiqish $10 (1 mln token uchun); Opus 5.5: $4 / $20. Bitta element odatda
~2–10 ming kirish va ~1–3 ming chiqish token (modelning fikrlash tokenlari ham chiqishga kiradi), ya'ni
**Sonnet bilan taxminan $0.02–0.08 bir element**; 20 ta element ~ $0.5–1.5, 60 ta ~ $1.5–5 (chegara bilan to'xtaydi).
Opus ~2 baravar qimmat. Aniq taxmin — `dry_run` natijasida; haqiqiy sarf — hisobotdagi `tokens` va `cost_usd`.
Narxlar `tool/ai/budget.py` da (Anthropic narx jadvali o'zgarsa yangilang).

## Xavfsizlik

- Workflow **faqat `workflow_dispatch`**: pull request, push, schedule bilan ishga tushmaydi.
- `ANTHROPIC_API_KEY` repo secret'i faqat bitta Python qadamining `env` ida; `dry_run=true` bo'lsa umuman berilmaydi.
  Diskka, artifact'ga, logga yozilmaydi (skript chiqishda kalitga o'xshash matn topsa faylni yozmaydi); logda faqat token sonlari.
  Secret yo'q bo'lsa — aniq xato bilan to'xtaydi.
- Ikki alohida ish: `run` (huquq: `contents: read`, kalit bor) va `publish` (`contents: write`, kalit **yo'q**, repo kodi ishlamaydi).
  `publish` faqat `ai-reports` tarmog'iga, aniq refspec bilan, `github-actions[bot]` nomidan yuboradi; `main` ga hech qachon.
- Faqat `main` tarmog'idan ishga tushadi (boshqa tarmoqda birinchi qadam to'xtatadi). Eslatma: bu faqat tasodifiy
  xatoga qarshi; repoga yozish huquqi bor odam workflow faylini o'zgartira oladi. Qo'shimcha himoya uchun
  (ixtiyoriy) secret'ni *Environment* (masalan `ai`) ga o'tkazib, "Required reviewers" qo'ying va ishdagi
  `environment:` qatorini qo'shing.
- Kiritmalar (`target` va b.) hech qachon shell matniga qo'shilmaydi — faqat env orqali; `target` qat'iy belgilar bilan cheklangan.
- Uchinchi tomon action'lar commit SHA bilan mahkamlangan; Python paketlari `requirements.txt` da aniq versiyada.
- Model uchun element — faqat ma'lumot (`<item_json>`); ichidagi "ko'rsatma"larga amal qilmaydi.
- Byudjet qo'riqchisi: har chaqiruvdan oldin (taxminiy kirish + kutilgan chiqish) va keyin (API `usage`) hisob;
  chegara oshadigan bo'lsa to'xtaydi. Ketma-ket 3 xato, kalit/ruxsat xatosi (401/403/404) yoki API hisobida
  kredit tugashi (`400 ... credit balance is too low`) — ishni darhol to'xtatadi (`::error::` izohi, `abort_reason`).
- Qayta urinish (eksponensial backoff + `retry-after`) faqat vaqtinchalik xatolarda: 408/409/429, 5xx (529 overloaded).
  Boshqa 400 xatolar qayta urinilmaydi.
- Xato bo'lgan element log qatorida qisqa sabab bor: `error=<klass> status=<kod> type=<API turi> request_id=... msg='...'`
  (kalit yashiriladi; prompt/javob matni chiqarilmaydi). Mahalliy xato (masalan javobni qayta ishlash) ham ishni
  yiqitmaydi — `mahalliy xato / local error: <klass> ...` sifatida yoziladi.
- `concurrency` guruhi — vazifa+target bo'yicha (`ai-tasks-<task>-<target>`): turli vazifalar parallel ishlaydi,
  hech biri bekor qilinmaydi (GitHub bitta guruhda faqat bitta kutayotgan run'ni saqlaydi). `publish` parallel
  push to'qnashsa `ai-reports`ning yangi uchidan qayta quradi (force'siz, 4 urinish).

## Mahalliy ishlatish va testlar

```
python3 -m unittest discover -s tool/ai/tests            # oflayn, kalit va tarmoq kerak emas
python3 tool/ai/run_task.py --task content_review --target cytology --dry-run
python3 tool/ai/extract.py --list                         # ajratilgan elementlar ro'yxati
```

Haqiqiy chaqiruvni mahalliy qilish shart emas (kalit faqat Actions'da). Kerak bo'lsa:
`pip install -r tool/ai/requirements.txt`, so'ng `ANTHROPIC_API_KEY` ni **o'z terminalingizda** muhit o'zgaruvchisi qilib bering
(hech qayerga yozmang, chatga yubormang).

## Cheklovlar (ochiq aytamiz)

- Model manba hujjatini ko'rmaydi, shuning uchun "manbaga mos" degan xulosa chiqarolmaydi; u faqat ichki
  ziddiyat, uz/ru/en farqi, ortiqcha da'vo va ogohlantirish yo'qligini ko'radi. Manba bilan solishtirish — odam ishi.
- Dart ajratgichi (`extract.py`) evristik: `_T({...})`/`LocalizedText`/`CalcRef` shakllarini tanidi; `_c('16')` kabi
  til bo'yicha birlik yig'uvchi yordamchilar (masalan, spermogramma test variantlari) hisobga olinmaydi. Qisqa
  interfeys yozuvlari (60 belgidan kam) o'tkazib yuboriladi. Yangi kontent shakli qo'shilsa `tests/test_extract.py` ni kengaytiring.
- Hisobot sabablari inglizcha (model shunday yozadi); iqtiboslar asl tilda.
- Modelning "ishonch" darajasi kafolat emas — `confidence: high` ham tekshirishni bekor qilmaydi.
