# LabGuide sayti (statik)

Google OAuth (“In production” uchun bosh sahifa va maxfiylik siyosati havolasi), App Store va
Google Play uchun ochiq sahifalar. Oddiy HTML + CSS: JavaScript yo‘q (yagona istisno — `j/`, quyida), tashqi so‘rov yo‘q
(shrift — tizimniki), internetsiz ham ochiladi, telefonda moslashadi, yorug‘/qorong‘i mavzu
qurilma sozlamasiga ko‘ra (`prefers-color-scheme`).

| Fayl | Nima |
|---|---|
| `index.html` | Bosh sahifa (uz/ru/en): LabGuide nima, “tibbiy qurilma emas” ogohlantirishi, aloqa, havolalar |
| `privacy/index.html` | Maxfiylik siyosati — **avtomatik yasaladi**, qo‘lda tahrirlamang |
| `terms/index.html` | Foydalanish shartlari (obuna, bepul sinov, bekor qilish) — **avtomatik yasaladi** (`docs/store/TERMS_OF_USE.md`), qo‘lda tahrirlamang |
| `delete-account/index.html` | Hisobni o‘chirish yo‘riqnomasi (ilovada va email orqali) |
| `j/index.html` | Guruh taklifi QR havolasi (`j/?c=KOD&a=TEST`): kod katta harfda va “Ilovada ochish” (`labguide://app/j?...`). Kichik ichki skript faqat `?c=` ni o‘qiydi — tashqi so‘rov yo‘q, hech narsa saqlanmaydi (`check_site.py` skriptni faqat shu sahifaga ruxsat etadi) |
| `style.css` | Umumiy uslub (ranglar ilova palitrasidan, `lib/design/tokens.dart`) |
| `logo.png` | Ilova belgisi, 192 px (`tool/icons/icon_1024.png` dan) |
| `robots.txt` | Qidiruv tizimlariga ruxsat |

## Yangilash

Siyosat matni bitta joyda — `docs/store/PRIVACY_POLICY.md`, foydalanish shartlari — `docs/store/TERMS_OF_USE.md`. Ularni o‘zgartirgandan keyin:

```sh
python3 tool/site/build_site.py      # site/privacy/index.html va site/terms/index.html ni qayta yasaydi
python3 tool/site/check_site.py      # tekshiruv: ichki izoh, taqiqlangan so‘zlar, havolalar
```

`build_site.py` faqat Python standart kutubxonasini ishlatadi; `--logo` bilan `logo.png` ni ham
qayta yasaydi (Pillow kerak). Ichki izohlar (`> Eslatma …` iqtibosi va `<!-- … -->`) sahifaga
chiqmaydi. `check_site.py` xato topsa, nol bo‘lmagan kod bilan tugaydi — sahifa eskirgan
(Markdown o‘zgargan, lekin sahifa qayta yasalmagan) bo‘lsa ham. `--self-test` tekshiruvchining
o‘zini sinaydi.

Bosh sahifa va o‘chirish sahifasi qo‘lda yoziladi. Ulardagi da’volar siyosat bilan bir xil
bo‘lsin (ilovada yo‘q narsani yozmang). D-77: to‘lov/obuna so‘zlari, Pro va Premium nomlari faqat
`privacy/` va `terms/` da bo‘lishi mumkin; narx (so‘m, USD, $) hech bir sahifada yozilmaydi — narx
do‘kondan; sinov muddati faqat 30 kun (D-80; `check_site.py` shuni tekshiradi).

## Joylash

Taklif qilingan manzil — egasining domeni ostida: **`https://labguide.nfcstore.uz/`**.

| Sahifa | Manzil | Qayerga beriladi |
|---|---|---|
| Bosh sahifa | `https://labguide.nfcstore.uz/` | Google OAuth → Branding → *Application home page*; App Store → *Support URL* |
| Maxfiylik siyosati | `https://labguide.nfcstore.uz/privacy/` | Google OAuth → *Privacy policy link*; App Store Connect → *Privacy Policy URL*; Play Console → *Privacy policy* |
| Foydalanish shartlari | `https://labguide.nfcstore.uz/terms/` | App Store Connect → *License Agreement* / ilova tavsifi; Play Console → ilova tavsifi; ilovada to‘lov oynasidagi havola (`Contact.termsOfUseUrl`) |
| Hisobni o‘chirish | `https://labguide.nfcstore.uz/delete-account/` | Play Console → Data safety → *Delete account URL* |

Sahifalar bir-biriga nisbiy havola bilan ulangan (`../style.css`, `privacy/index.html`), shuning
uchun sayt istalgan papkada ishlaydi (`/labguide/`, domen ildizi yoki kompyuterda oddiy fayl).
Manzil oxiridagi `/` muhim: `…/privacy` (sleshsiz) ochilsa, ko‘pchilik hosting uni o‘zi
`…/privacy/` ga yo‘naltiradi; do‘kon va Google maydonlariga doim sleshli manzilni yozing.

### 1-variant: Cloudflare Pages (tavsiya)

`nfcstore.uz` domeni Cloudflare’da bo‘lsa (email ham Cloudflare Email Routing orqali):

1. Cloudflare → **Workers & Pages → Create → Pages → Upload assets** (yoki Git’ga ulash).
   Loyiha nomi, masalan, `labguide-site`. Yuklanadigan papka — `site/` ning **ichidagi** fayllar.
   Git bilan: *Build command* bo‘sh, *Build output directory* — `site`.
2. Natija: `https://labguide-site.pages.dev/` — sinab ko‘ring (uchala sahifa, telefonda, qorong‘i
   mavzuda).
3. **Subdomen `labguide.nfcstore.uz`** → Pages → *Custom domains*. Ilova (maxfiylik havolasi
   `lib/core/contact.dart`, QR/taklif havolasi `…/j/?c=KOD`) aynan shu manzilni ishlatadi, shuning
   uchun boshqa yo‘l (masalan, `nfcstore.uz/labguide/`) tanlanmasin — aks holda ilovadagi havolalar
   ishlamaydi (`tool/site/test_guards.py` tekshiradi). Manzillar: `https://labguide.nfcstore.uz/`,
   `…/privacy/`, `…/terms/`, `…/delete-account/`, `…/j/`.
4. HTTPS Cloudflare tomonidan avtomatik.

### 2-variant: istalgan statik hosting

`site/` ichidagi fayllarni server papkasiga (masalan, `public_html/labguide/`) nusxalang —
boshqa sozlama kerak emas. Server `…/privacy/` so‘raganda `privacy/index.html` ni berishi kerak
(Apache, Nginx, GitHub Pages, Netlify — standart holatda shunday).

### Joylagandan keyin

- Uchala manzilni brauzerda oching; `UZ / RU / EN` tugmalari tegishli bo‘limga o‘tkazishini
  tekshiring.
- **Google OAuth:** Google Auth platform → *Branding* → bosh sahifa va maxfiylik siyosati
  havolalari; *Authorized domains* ga `nfcstore.uz`. Domen Google Search Console’da egasi nomidan
  tasdiqlangan bo‘lishi kerak (DNS TXT yozuvi — Cloudflare DNS’da qo‘shiladi). Keyin *Audience* →
  *Publish app* (“In production”).
- **App Store Connect / Play Console:** yuqoridagi jadvaldagi maydonlar
  (`docs/store/APP_STORE.md` 6, 12, 14-bo‘limlar; `docs/store/PLAY_CONSOLE_UPLOAD.md` 2-bo‘lim).
- Ilovadagi havola (`lib/core/contact.dart`, `privacyPolicyUrl`) hozircha GitHub’dagi
  Markdown’ga ishora qiladi — sayt ishlagach yangi manzilga almashtiring.
- `robots.txt` faqat domen ildizida (`nfcstore.uz/robots.txt`) hisobga olinadi; sayt
  `/labguide/` ostida bo‘lsa, bu fayl ta’sirsiz, lekin zarari yo‘q.

E’lon qilishdan oldin: `docs/store/PRIVACY_OPEN_QUESTIONS.md` (sana, aloqa, huquqiy savollar).
