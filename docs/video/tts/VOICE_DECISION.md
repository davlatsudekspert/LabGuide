# LabGuide videolari uchun diktor ovozi: qaror hujjati

*Voice decision for LabGuide narration (uz / ru / en). Tekshirilgan sana: 2026-10-25. Bu huquqiy maslahat emas;
litsenziya matnlari yo‘q manbalardan o‘qildi (havolalar pastda). Eshitib baholash **qilinmagan** — pastga qarang.*

## 1. Qisqa xulosa (Bottom line)

| Til | Tavsiya (bepul + tijoriy ishlatish mumkin) | Holat |
|---|---|---|
| **English** | **Kokoro-82M** (Apache-2.0), ovoz `af_heart` yoki `af_bella`; zaxira: **Piper `en_US-ljspeech-medium`** (ma’lumot public domain) | Ishga tushirildi, ob’ektiv o‘lchandi; **odam eshitib tasdiqlashi kerak** |
| **Русский** | **Hozir tozalangan lokal ovoz YO‘Q.** Piper ruscha ovozlari tijoriy jihatdan tasdiqlanmagan va o‘lchovda tushunarliligi past; Silero ruscha ovozlari (eng yaxshisi) CC BY-NC-SA — reklama uchun mumkin emas. Kandidat: **Azure `ru-RU-SvetlanaNeural`/`DariyaNeural`** (egasining kaliti bilan) | Azure sinalmagan (kalit yo‘q) |
| **O‘zbekcha (Latin)** | **Hozircha hech qaysi ovoz “yaxshi VA tijoriy toza” deb tasdiqlanmagan.** Ikki kandidat bor: **(1) Azure `uz-UZ-MadinaNeural` (ayol)** — egasining Azure kaliti kerak; **(2) Silero `v5_cis_base` / `uzb_saida`** — MIT, lokal, lekin PyTorch kerak (bu mashinada o‘rnatilmadi) | **Ikkalasi ham sinalmagan (NOT RUN)** |

Eng muhim ogohlantirishlar:

1. Men audio eshita olmayman. Tabiiylik, yoqimlilik, urg‘u, aksent **o‘lchanmadi**. “Chiroyli/ravon” degan hukm faqat odam eshitgandan keyin chiqadi.
2. **O‘zbekcha uchun hech qanday ovoz ishga tushirilmadi**, shuning uchun o‘zbekcha sifat haqida hech narsa da’vo qilmayman.
3. Azure **bepul F0** darajasida tijoriy (reklama) ishlatish bo‘yicha rasmiy sahifada aniq gap topilmadi; Microsoft xodimining forumdagi javobi “tijorat uchun pullik (pay-as-you-go) daraja kerak” deydi (2.4-bandga qarang). Egasi reklama joylashdan oldin buni o‘zi tasdiqlashi shart.
4. Hech narsa avtomatik pullikka o‘tkazilmaydi; skript kvota tugaganda to‘xtaydi.

## 2. Nomzodlar jadvali (Candidate table)

Belgilar: ✅ tijoriy ishlatish + chiqqan audioni tarqatish mumkin; ❌ mumkin emas; ⚠️ aniq emas / xavf bor.

| # | Nomzod | Til / jins | Sample rate · hajm | Kod litsenziyasi | Ovoz/model litsenziyasi | Tijorat + audio tarqatish | Attribution | Dalil (URL) | Verdikt |
|---|---|---|---|---|---|---|---|---|---|
| 1 | Piper `en_US-ljspeech-medium/high` | en-US, ayol | 22 050 Hz · 63 / 114 MB | `piper-tts` 1.8.0 = **GPL-3.0-or-later**; eski rhasspy/piper = MIT | Ma’lumot LJ Speech — card: “public domain”, noldan o‘qitilgan; repo yorlig‘i `mit` | ✅ (audio uchun GPL qo‘llanmaydi; dvigatelni o‘zimiz tarqatsak GPL) | Talab yo‘q | `huggingface.co/rhasspy/piper-voices` → `en/en_US/ljspeech/medium/MODEL_CARD` | **Toza** |
| 2 | Piper `en_US-kristin / norman / john`, `en_GB-cori` | en, ayol/erkak | 22 050 Hz · ~63 MB | GPL-3.0 | LibriVox public domain, noldan | ✅ | Talab yo‘q | o‘sha `MODEL_CARD`lar | Toza (sinalmagan) |
| 3 | Piper `en_US-libritts-high`, `libritts_r`, `en_GB-alba/aru/vctk` | en | 22 050 · 63–137 MB | GPL-3.0 | CC BY 4.0 | ✅ | **Ha** (CC BY) | `MODEL_CARD`lar | Attribution bilan mumkin (sinalmagan) |
| 4 | Piper `en_US-lessac-*` va **Lessac’dan fine-tune qilingan hamma ovoz** (amy, joe, mike, kusal, alan, `en_GB-jenny_dioco`, barcha `ru_RU-*`, …) | en/ru | 16–22 kHz | GPL-3.0 | Lessac Blizzard-2013 litsenziyasi: “**Research Purposes only**… excludes… any commercial purpose” | ❌ / ⚠️ (hosila vaznlar) | — | `cstr.ed.ac.uk/projects/blizzard/2013/lessac_blizzard2013/license.html` (1.1 va 3.2-bandlar) | **Ishlatilmasin** |
| 5 | Piper `en_US-ryan-*`, `hfc_*`, `l2arctic`, `en_GB-semaine`, `ru_RU-ruslan`, `tr_TR-dfki`, `kathleen-low` (Ryan’dan) | en/ru/tr | — | GPL-3.0 | CC BY-NC(-SA) | ❌ | — | `MODEL_CARD`lar (`ruslan`: BY-NC-SA 4.0) | **Ishlatilmasin** |
| 6 | Piper `ru_RU-denis/dmitri-medium` | ru, erkak | 22 050 · 63 MB | GPL-3.0 | Ma’lumot **CC0**, lekin “Finetuned from U.S. English **lessac** voice” | ⚠️ boshlang‘ich vaznlar Lessac (research-only) ma’lumotida o‘qitilgan | CC0 | `MODEL_CARD` | **Tasdiqlanmagan** → faqat ichki qoralama |
| 7 | Piper `ru_RU-irina-medium` | ru, ayol | 22 050 | GPL-3.0 | Ma’lumot litsenziyasi **“Unknown”** + Lessac asosi | ❌/⚠️ | — | `MODEL_CARD` | Ishlatilmasin |
| 8 | **Piper — o‘zbek ovozi** | — | — | — | `voices.json` (178 ovoz) ichida **uz yo‘q**; turkiylardan faqat `kk_KZ` (issai CC BY 4.0, iseke/raya), `tr_TR` (NC) | — | — | `huggingface.co/rhasspy/piper-voices/raw/main/voices.json` | **YO‘Q** |
| 9 | **Kokoro-82M** v1.0 | en (US 11F/9M, UK 4F/4M), ja, zh, es, fr, hi, it, pt-BR. **ru va uz YO‘Q** | 24 000 Hz · ONNX int8 92 MB (+0,5 MB/ovoz) | `kokoro-onnx` MIT; `phonemizer`/espeak-ng (fonemalash) GPL-3.0 | **Apache-2.0** vaznlar. Muallif: faqat “permissive/non-copyrighted” audio + yopiq TTS’lardan sintetik audio | ✅ (“We welcome the deployment… in real use cases”) | Talab yo‘q (CC BY ma’lumotlar ja/fr uchun, en uchun emas) | `huggingface.co/hexgrad/Kokoro-82M` (README, VOICES.md) | **Toza** (qoldiq xavf: sintetik o‘quv ma’lumoti manbalari) |
| 10 | **Silero `v5_cis_base` / `uzb_saida`** | **uz (Latin+Cyrillic), ayol deb taxmin** (nomi; tasdiqlanmagan) | 8/24/48 kHz · 91,7 MB (.pt, TorchScript) | MIT (`LICENSE_CIS`) | README: “`base` cis-tts models … under **MIT**” | ✅ (README bo‘yicha) | MIT xabari faqat modelni tarqatsak | `github.com/snakers4/silero-models` (README “V5 CIS Base Models”, “Licence”, `LICENSE_CIS`, `models.yml`) | **Eng yaxshi bepul o‘zbek nomzodi — SINALMAGAN** (torch kerak) |
| 11 | Silero qolgan hamma modellari (`v5_ru`, `v4_uz`/`dilnavoz`, `v3_uz`, `v5_turkic` `uzb_0`, `v5_cis_ext` `uzb_anora`…) | ru, uz | 8–48 kHz | CC BY-NC-SA 4.0 (repo `LICENSE`) | “All of the models are published under the main repo license (i.e. CC-NC-BY) except … `base` cis-tts models” | ❌ (tijorat uchun Silero bilan kelishuv kerak: hello@silero.ai) | — | o‘sha README + `LICENSE` | **Ishlatilmasin** |
| 12 | **Azure Speech** — `uz-UZ-MadinaNeural` (F), `uz-UZ-SardorNeural` (M); `ru-RU-SvetlanaNeural`/`DariyaNeural` (F), `DmitryNeural` (M); en-US ko‘p | uz, ru, en | 24 kHz (API formati tanlanadi) | REST — o‘z kodimiz | Microsoft xizmat shartlari | ⚠️ F0 uchun aniq emas (2.4) | Sun’iy ovoz ekanini oshkor qilish tavsiya | Microsoft Learn: *language-support* (uz-UZ qatorlari), *quotas-and-limits*, Azure *pricing* | **Asosiy o‘zbek yo‘li — kalit kutilmoqda** |
| 13 | Google Cloud TTS | ru bor (Standard/Wavenet/Chirp3-HD) | — | — | Google shartlari | — | — | `docs.cloud.google.com/text-to-speech/docs/list-voices-and-types`: uz-UZ **ro‘yxatda ko‘rinmadi** (til ro‘yxati Urdu → Vietnamese o‘tadi) | **O‘zbek uchun yaroqsiz.** Bepul kvota raqamlari sahifadan o‘qilmadi (NOT VERIFIED) |
| 14 | Chatterbox (Resemble, MIT) + `Abduqayum/uzbek-tts-natural-speech-chatterbox` (repoda `tool/video/uz_tts_chatterbox.py`) | uz (LoRA), jins noma’lum (default `reference_voice.wav`) | torch + transformers==4.46.3 + bir necha yuz MB–GB vaznlar | MIT (Chatterbox, tuning toolkit Apache-2.0) | Model kartasi: “MIT”; o‘quv ma’lumoti “~30 soat **audiobook narration**”, manba va litsenziya **ko‘rsatilmagan** | ⚠️ ma’lumot huquqi noma’lum | — | `huggingface.co/Abduqayum/uzbek-tts-natural-speech-chatterbox` (README, TRAINING.md); `huggingface.co/ResembleAI/chatterbox` | **Tasdiqlanmagan** — muallif ma’lumot litsenziyasini yozmaguncha reklamada ishlatmang |
| 15 | Chatterbox asos modeli | 23 til; **uz yo‘q** (`ar da de el en es fi fr he hi it ja ko ms nl no pl pt ru sv sw tr zh`) | — | MIT | MIT | ✅ | — | HF `ResembleAI/chatterbox` teglari | O‘zbekcha qo‘llamaydi (faqat jamoa fine-tuni) |
| 16 | MeloTTS | en (5 aksent), es, fr, zh, ja, ko. **ru/uz yo‘q** | — | MIT | MIT | ✅ | — | `github.com/myshell-ai/MeloTTS` README | O‘zbek/rus uchun yaroqsiz |
| 17 | Coqui XTTS-v2 | ru bor, **uz yo‘q** | — | — | **CPML (non-commercial)** | ❌ | — | `huggingface.co/coqui/XTTS-v2` | **Chiqarib tashlandi** |
| 18 | Meta MMS-TTS `uzb-script_cyrillic` (va uning fine-tunlari) | uz, **faqat Kirill** | 16 kHz | — | **CC-BY-NC 4.0** | ❌ | — | HF `facebook/mms-tts-uzb-script_cyrillic` (license:cc-by-nc-4.0) | **Chiqarib tashlandi** |
| 19 | `edge-tts` (Edge “read aloud” oxirgi nuqtasi) | uz-UZ, ru-RU, en-US bor | — | LGPL-3.0 (PyPI klassifikatori) | Microsoft’ning **rasmiy bo‘lmagan** (reverse-engineered) xizmati; o‘zi README’da “Microsoft Edge’s online text-to-speech service” deydi, shartnomaviy litsenziya yo‘q | ❌ tijorat uchun | — | `github.com/rany2/edge-tts` README | **Chiqarib tashlandi** (repodagi `make_promo.py` ixtiyoriy `edge-tts` ni eslatadi — reklamada ishlatilmasin) |
| 20 | Boshqa HF o‘zbek modellari: `uzlm/sayro-tts-1.7B` (gated, `license: other`, “Sayro terms”), `mrmuminov/f5-tts-uzbek` (CC-BY-NC), `OvozifyLabs/matcha-tts-uz-v1` (litsenziya ko‘rsatilmagan, erkak), `Anadilorg/Anadil_Uzbek_TTS` (MIT, LoRA VoxCPM2 ustida, Common Voice `uz`), SpeechT5 fine-tunlari | uz | katta/GPU | turli | turli | ⚠️/❌ | — | HF model kartalari | Baholanmadi (litsenziya yoki hajm to‘sqinlik) |

## 3. Ob’ektiv sinov natijalari (nima ishga tushirildi)

Mashina: faqat CPU. Har til uchun 3 ta laboratoriya gapi (`tool/tts/testdata/*_lab.json`). Hisobot: `docs/video/tts/TEST_RESULTS.json`.
ASR aylanma sinov: `faster-whisper` **tiny** (75 MB) va **base** (145 MB), int8; WER/CER matn bilan solishtiriladi (raqamlar so‘zga aylantirilgan).
ASR xatolari qisman ASR’ning o‘z kamchiligi — bu **tushunarlilik** belgisi, **tabiiylik** emas.

| Til | Backend · ovoz | Davomiylik (3 gap) | Sample rate | Peak dBFS | LUFS (gap bo‘yicha) | Clipping | Jim ulush | ASR WER tiny / base | CER tiny / base |
|---|---|---|---|---|---|---|---|---|---|
| en | Piper `en_US-ljspeech-medium` | 26,1 s | 22 050 | **0,0** (piper `normalize_audio`) | −20,1 / −18,7 / −17,5 | 1 ta namuna ≥0,999 (≈5e-6) | 5–12 % | 0,065 / 0,150 | 0,029 / 0,094 |
| en | Kokoro `af_heart` (int8 ONNX) | 24,9 s | 24 000 | −4,3 … −5,2 | −22,5 / −22,8 / −22,8 | 0 | 14–17 % | **0,050 / 0,047** | 0,018 / 0,012 |
| en | Kokoro `af_bella` | 25,8 s | 24 000 | −3,0 … −5,0 | −21,7 / −21,4 / −22,0 | 0 | 13–18 % | 0,098 / **0,031** | 0,039 / 0,012 |
| en | Kokoro `bf_emma` (UK) | 23,4 s | 24 000 | −2,7 … −3,7 | −20,7 / −20,9 / −20,7 | 0 | 12–17 % | 0,118 / 0,065 | 0,067 / 0,028 |
| en | Kokoro `am_michael` | 27,5 s | 24 000 | −3,4 … −4,9 | −24,3 / −24,6 / −24,6 | 0 | 15–17 % | 0,100 / 0,047 | 0,067 / 0,012 |
| ru | Piper `ru_RU-denis-medium` (faqat sinov; litsenziya tasdiqlanmagan) — laboratoriya gaplari | 15,7 s | 22 050 | 0,0 | −17,4 / −18,3 / −17,1 | ≈1e-5 (1–2 namuna) | 1–4 % | **0,685 / 0,685** | 0,247 / 0,228 |
| ru | o‘sha ovoz — oddiy kundalik 3 gap (nazorat) | 11,1 s | 22 050 | 0,0 | −17,6 … −18,8 | ≈1e-5 | 2–7 % | 0,264 / 0,245 | 0,084 / 0,096 |
| uz | **hech narsa ishga tushmadi** | — | — | — | — | — | — | NOT RUN | NOT RUN |

O‘qish:

* **English:** Kokoro `af_heart`/`af_bella` ASR’da deyarli xatosiz (WER ≈3–5 % base bilan), ovozi pastroq (−22 LUFS), clippingsiz. Piper `ljspeech` ham tushunarli, lekin peak 0 dBFS (zaxira yo‘q) — kompozitorda `loudnorm` qiling. Hammasi **YouTube/Instagram maqsadi −14…−16 LUFS** dan past — montajda ko‘tarish kerak.
* **Russian (Piper denis):** oddiy gaplarda WER ≈0,25, lekin lab terminlarida **0,69** (tiny ham, base ham). ASR ruscha jargonda ham zaif, shuning uchun bu sonni “ovoz yomon” deb ham, “yaxshi” deb ham o‘qib bo‘lmaydi; lekin “spektrofotometr, leykotsitar, polimeraza” kabi so‘zlar Piper’da urg‘usiz va xatolik bilan chiqishi ehtimoli yuqori → bu ovoz bilan **jargonli rus videosi chiqarmaslik** tavsiya. Qo‘shimcha ravishda litsenziya masalasi bor (4-qator va 6-qator).
* **Uzbek:** o‘lchov yo‘q. `none` backend bilan faqat **taxminiy** davomiylik (placeholder) hosil qilinadi.
* Tezlik (CPU): Piper ≈3 s ichida 27 s audio (model yuklanishi bilan); Kokoro int8 shunga yaqin. Real-time’dan ancha tez.

Sinalmagan (NOT RUN) va sababi: Silero (torch kerak — diskda joy yo‘q), Azure (egasining kaliti yo‘q), Chatterbox-uz (torch + katta vaznlar), MeloTTS (torch), XTTS/MMS (litsenziya bo‘yicha chiqarilgan), Google (o‘zbek yo‘q).

## 4. Azure Speech — bilishingiz kerak bo‘lgan aniq faktlar

1. **Ovozlar (rasmiy jadval, Microsoft Learn *language-support*, 2026-10-25 o‘qildi):** `uz-UZ` “Uzbek (Latin, Uzbekistan)” — `uz-UZ-MadinaNeural` (Female), `uz-UZ-SardorNeural` (Male), daraja “Standard”. `ru-RU`: `SvetlanaNeural` (F), `DmitryNeural` (M), `DariyaNeural` (F), shuningdek HD `ru-RU-Masha:MAI-Voice-2` (F), `ru-RU-Lev:MAI-Voice-2` (M).
2. **Cheklov (o‘zbek):** jadvaldagi izoh: uz-UZ uchun SSML `<phoneme>`, custom lexicon va visemes **qo‘llab-quvvatlanmaydi**. Ya’ni talaffuzni faqat matnni qayta yozish (respelling) bilan to‘g‘rilash mumkin — `tool/tts/lexicon/uz.json` shu uchun.
3. **Bepul daraja (F0):** Azure narx sahifasi: Text to Speech Neural — **0,5 million belgi/oy bepul**. Kvota sahifasi: F0 real-time TTS **20 so‘rov / 60 s**, bir so‘rovda ≤10 daqiqa audio, **batch synthesis F0’da yo‘q**; F0 limitlari o‘zgartirib bo‘lmaydi. (Skript so‘rovlar orasida 3,2 s kutadi.)
4. **Tijoriy ishlatish — ANIQ EMAS.** Rasmiy narx/kvota sahifalarida F0 audiosini reklamada ishlatish haqida gap topilmadi. Microsoft Q&A’da Microsoft xodimi (Moderator, 2023) yozadi: chiqqan audioni tijoriy ishlatsa bo‘ladi, royalty/ruxsat shart emas, lekin “*for all commercial purposes you will have to change the pricing to standard tier… use a pay as you go type subscription. Free credit subscriptions should not be used for commercial purposes*”; shuningdek sun’iy ovoz ekanini oshkor qilishni tavsiya qiladi. Bu forum javobi, shartnoma emas. **Egasi** Azure Product Terms / Microsoft qo‘llab-quvvatlashidan tasdiqlashi kerak. Agar tasdiqlanmasa — F0 faqat sinov/qoralama uchun, reklama uchun pullik S0 (Microsoft’ning o‘z misolida narx **$15 / 1 million belgi**; 1 daqiqalik video ≈900–1000 belgi ≈ **$0,015**) — qaror egasiniki, skript hech qachon o‘zi o‘tkazmaydi.
5. Azure akkaunt ochishda odatda to‘lov kartasi so‘raladi (men tekshirmadim — ochilish paytida ko‘rasiz). F0 resursi o‘zi pul yechmaydi.

## 5. Egasi uchun aniq qadamlar — o‘zbekcha ovoz (Azure F0)

Men ro‘yxatdan o‘tmadim va kalit yaratmadim. Siz qilasiz:

1. portal.azure.com ga o‘z akkauntingiz bilan kiring (bo‘lmasa o‘zingiz oching).
2. **Create a resource → “Speech”** (Azure AI Speech / Foundry Tools). **Pricing tier: Free F0**. Region: bitta Yevropa/AQSh regioni (masalan `westeurope`) — shu regionda `uz-UZ-MadinaNeural` borligini 7-bandda tekshiring (regional mavjudlikni men tekshirmadim).
3. Resursda **Keys and Endpoint** → `KEY 1` va **Location/Region**.
4. Kalitni **faqat terminal muhitida** bering (repoga yozmang, chatga tashlamang):
   ```bash
   export AZURE_SPEECH_KEY='...'
   export AZURE_SPEECH_REGION='westeurope'
   ```
5. Eshitib ko‘rish uchun sinov (≈ 300 belgi):
   ```bash
   python3 tool/tts/synth.py tool/tts/testdata/uz_lab.json --out /tmp/uz_azure --backend azure --concat --srt
   python3 tool/tts/synth.py tool/tts/testdata/uz_lab.json --out /tmp/uz_sardor --backend azure --voice uz-UZ-SardorNeural
   ```
   `/tmp/uz_azure/narration.wav` ni eshiting: talaffuz (kalibrlash, leykotsitar, neytrofil, limfotsit, monotsit, eozinofil, bazofil, spektrofotometr, xromatografiya, polimeraza zanjirli reaksiya), ravonlik, aksent, ayol ovozi yoqimliligi. O‘zbek tilini biladigan odam “yaxshi” desa — shundan keyingina ishlatiladi. Apostrof variantini ham solishtiring: `--uz-apostrophe "'"` (standart), `--uz-apostrophe "‘"`, `--uz-apostrophe "ʻ"` — qaysi biri `o‘zbek` ni to‘g‘ri o‘qiydi (men sinay olmadim).
6. Noto‘g‘ri o‘qilgan so‘zlarni `tool/tts/lexicon/uz.json` ga yozing (masalan `"leykotsitar": "leykositar"`) — yoki loyihaga xos `--lexicon fayl.json`.
7. Kvota: portal → Speech resursi → **Metrics** (Synthesized Characters). Skript mahalliy hisoblagich yuritadi (`~/.labguide_tts_azure_usage.json`) va **450 000 belgidan** oshsa API’ni chaqirmaydi (F0 = 500 000). Bir xil satr qayta sintez qilinmaydi (kesh: `OUT/.cache`) — kvotani tejaydi.
8. **Kvota tugasa:** Azure 403/429 qaytaradi; skript to‘xtaydi va hech narsani yangilamaydi. Variantlar: (a) keyingi oyni kutish, (b) `--backend none` bilan faqat subtitr/placeholder, (c) Silero `uzb_saida` (3-bo‘lim), (d) egasi qo‘lda S0 (pullik) ga o‘tishni o‘zi hal qilishi. Hech qachon avtomatik emas.

### Muqobil (bepul, lokal): Silero `uzb_saida` — torch bo‘lgan mashinada 10 daqiqalik sinov

```bash
python3 -m venv /tmp/sv && /tmp/sv/bin/pip install silero torch --index-url https://download.pytorch.org/whl/cpu --extra-index-url https://pypi.org/simple
/tmp/sv/bin/python tool/tts/synth.py tool/tts/testdata/uz_lab.json --out /tmp/uz_silero --backend silero --concat
```
(Bu `silero` backendi unit-testda soxta modul bilan tekshirilgan, haqiqiy modelda **ishga tushirilmagan**. Lotin matn skriptda Kirillga o‘giriladi — bu o‘girish taxminiy, o‘zbekcha biladigan odam tekshirsin.) Litsenziya: MIT (README), shuning uchun yoqsa — reklamada ishlatish mumkin va bepul/cheksiz/oflayn. Ovoz egasi/roziligi va jinsi haqida README’da ma’lumot yo‘q: **ayol ekanini eshitib tasdiqlang**.

## 6. Videolar tavsifiga yozish (attribution / oshkor qilish)

Hech bir tavsiya etilgan variant (Kokoro, Piper ljspeech, Silero base-MIT) videoda attribution **talab qilmaydi**. Microsoft sun’iy ovozni oshkor qilishni tavsiya qiladi; Instagram/YouTube ham realistik sun’iy kontentni belgilashni so‘rashi mumkin, shuning uchun halollik uchun quyidagini qo‘shish tavsiya etiladi:

* **uz:** `Diktor ovozi sun’iy intellekt yordamida yaratilgan.`
* **ru:** `Озвучка создана с помощью синтеза речи (ИИ).`
* **en:** `Narration generated with AI text-to-speech.`

Agar CC BY ovoz (masalan Piper `libritts`) tanlansa, qo‘shing: `Voice data: LibriTTS (CC BY 4.0).` Hozirgi tavsiyada bunday ovoz yo‘q.

## 7. Halol cheklovlar

* Tabiiylik/yoqimlilik/aksent — **o‘lchanmadi**. Faqat signal sifati va ASR tushunarliligi o‘lchandi.
* O‘zbekcha: tavsiya etilgan ikki yo‘lning hech biri bu yerda ishga tushmadi → sifatga kafolat yo‘q. Agar ikkalasi ham eshitishda yoqmasa, **bepul + tijoriy toza + yaxshi o‘zbek ovozi yo‘q** deb hisoblang; real variantlar: pullik Azure S0 (juda arzon), yoki haqiqiy diktor yozuvi.
* Ruscha: lokal toza ovoz yo‘q (Silero’ning yaxshi ruscha ovozlari NC; Piper ruscha — Lessac asosli va jargonda zaif). Azure ru kandidat, lekin sinalmagan.
* Litsenziya xulosalari — men o‘qigan matnlar asosida; Lessac asosli hosila vaznlar masalasi yuridik tortishuv bo‘lishi mumkin, shuning uchun “ishlatilmasin” deb belgilandi.
* Kokoro: muallif “sintetik audio yopiq TTS’lardan” o‘quv ma’lumotiga qo‘shilganini yozadi; bu ularning shartlariga bog‘liq qoldiq xavf (Apache-2.0 vaznlar ostida bizga o‘tmaydi, lekin yuridik jihatdan kafolat emas).
* Raqam/birlik normalizatsiyasi (`tool/tts/synth.py`): o‘zbekcha birliklar (“millimol litr”, “milligramm detsilitr”) va ruscha kelishik (“от 45 до 70” → noto‘g‘ri kelishik) — ona tili egasi tekshirishi kerak; murakkab holatlarda sonni so‘z bilan yozing.
* Lug‘atlar (`lexicon/*.json`) — boshlang‘ich taxminlar, eshitib tekshirilmagan.

## 8. Qurilgan vosita

`tool/tts/synth.py` — `python3 tool/tts/synth.py script.json --out DIR --backend none|stub|piper|kokoro|azure|silero [--concat] [--srt] [--mp3]`.
Chiqish: `<id>.wav`, `manifest.json` (har satr uchun `start/end/duration/gap_after/estimated`, `spoken_text`), ixtiyoriy `narration.wav/.srt`.
`none` backend — ovozsiz placeholder + **taxminiy** davomiylik (`estimated: true`), videoni ovozdan oldin yig‘ish uchun. Fayl nomlari satr `id` bilan mos, shuning uchun `make_screen_promo.py` kabi kompozitor `<id>.wav` ni o‘qiy oladi.
`tool/tts/eval_audio.py DIR [--asr tiny]` — shu hujjatdagi o‘lchovlarni takrorlaydi. Testlar: `python3 -m unittest discover -s tool/tts -p 'test_*.py'` (31 ta, tarmoqsiz).

## 9. Dalil havolalari (2026-10-25 da o‘qilgan)

* Piper ovozlari: https://huggingface.co/rhasspy/piper-voices (`voices.json`, har ovozning `MODEL_CARD` fayli)
* Lessac litsenziyasi: https://www.cstr.ed.ac.uk/projects/blizzard/2013/lessac_blizzard2013/license.html
* piper-tts paketi (GPL-3.0-or-later): https://github.com/OHF-voice/piper1-gpl (PyPI metadata)
* Kokoro: https://huggingface.co/hexgrad/Kokoro-82M (README, VOICES.md); ONNX: https://huggingface.co/onnx-community/Kokoro-82M-v1.0-ONNX
* Silero: https://github.com/snakers4/silero-models (README, LICENSE = CC BY-NC-SA 4.0, LICENSE_CIS = MIT, models.yml; `https://models.silero.ai/models/tts/ru/v5_cis_base.pt` 91 680 514 bayt)
* Azure ovozlar: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support?tabs=tts
* Azure kvotalar: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-services-quotas-and-limits
* Azure narx: https://azure.microsoft.com/en-us/pricing/details/cognitive-services/speech-services/ (0,5 mln belgi/oy bepul)
* Microsoft Q&A (tijoriy ishlatish): https://learn.microsoft.com/en-us/answers/questions/1192398/can-i-use-azure-text-to-speech-for-commercial-usag
* Google TTS ovozlar: https://docs.cloud.google.com/text-to-speech/docs/list-voices-and-types
* Chatterbox-uz: https://huggingface.co/Abduqayum/uzbek-tts-natural-speech-chatterbox ; asos: https://huggingface.co/ResembleAI/chatterbox
* MeloTTS: https://github.com/myshell-ai/MeloTTS ; XTTS: https://huggingface.co/coqui/XTTS-v2 ; MMS: https://huggingface.co/facebook/mms-tts-uzb-script_cyrillic ; edge-tts: https://github.com/rany2/edge-tts
