# LabGuide — maxfiylik siyosati / Политика конфиденциальности / Privacy Policy

Kuchga kirgan sana / Дата вступления в силу / Effective date: **2026-10-10**
Aloqa / Контакт / Contact: **labguide@nfcstore.uz**

> Eslatma (e’lon qilishdan oldin o‘chiriladi):
> - **Egasi tasdiqlashi kerak:** sana (2026-10-10) va aloqa (labguide@nfcstore.uz) (aloqa manzili Cloudflare Email Routing orqali egasining Gmail’iga yo‘naltiriladi) hozircha
>   taklif qilingan qiymatlar; aloqa manzili haqiqatan ishlashini va xatlarni qabul qilishini
>   tekshiring.
> - Matn **Cloudflare serveri** (Workers + D1, Sharqiy Yevropa; D-41, D-42,
>   `docs/BACKEND_CLOUDFLARE.md`, `cloudflare/src`, `cloudflare/migrations`) kodiga mos va
>   `LG_API_URL` berilgan build uchun. `LG_API_URL` bo‘sh build serverga hech narsa yubormaydi
>   (“Hisobsiz” qismi shunga ham to‘g‘ri). Supabase **ishlatilmaydi** — undan eski
>   ma’lumotlar olib tashlangan.
> - **Hamjamiyat (D-43)** — `cloudflare/src/community.ts`, `0005_community.sql`: hujjat surati
>   saqlanmaydi (testda tekshirilgan), Q&A ilova ichida ommaviy, tarjima — Workers AI.
> - Murojaatlar (“Taklif va yordam”), tekshiruvchi, hamkorlar (reklama), admin panel va Pro
>   server tomonida hali yo‘q (endpointlar `501`) — shuning uchun matnda “to‘planmaydi” deyilgan.
>   Ular ishga tushirilsa, matn va do‘kon deklaratsiyalarini yangilang.
> - **O‘zbekiston qonunchiligi (muhim):** “Shaxsga doir ma’lumotlar to‘g‘risida”gi qonun
>   (O‘RQ-547) O‘zbekiston fuqarolarining shaxsiy ma’lumotlarini internet orqali qayta
>   ishlashda ularni O‘zbekiston hududidagi texnik vositalarda saqlashni va ma’lumotlar bazasini
>   davlat reyestrida ro‘yxatdan o‘tkazishni talab qiladi. Server hozir Evropa Ittifoqi
>   (Sharqiy Yevropa) hududida — matnda bu ochiq aytilgan. Muvofiqlik va reyestr bo‘yicha
>   e’lon qilishdan oldin yurist bilan tekshiring (bu huquqiy maslahat emas).

## O‘zbekcha

**Hisobsiz foydalanish.** Mehmon sifatida (yoki server ulanmagan buildda) LabGuide hech qanday
shaxsiy ma’lumotni serverga yubormaydi. Sozlamalar, xatcho‘plar, QC qaydlari, apparatlaringiz,
kalibrlash jurnali, o‘qish holati va mashq natijalari faqat qurilmangizda saqlanadi (qurilmaning
o‘z zaxira nusxasiga — iCloud yoki Google — tizim sozlamalariga ko‘ra kirishi mumkin). Ustozning
guruh a’zosiga qo‘ygan real ism belgisi ham faqat ustoz qurilmasida qoladi.

**Xizmat ko‘rsatuvchilar.** Email bilan kirsangiz, ma’lumot quyidagi xizmatlar orqali
qayta ishlanadi:
- **Cloudflare, Inc.** — server (Workers) va ma’lumotlar bazasi (D1, Sharqiy Yevropa);
- **Resend** — faqat kirish kodi xatini yuborish (email manzilingiz va 6 raqamli kod xat
  yuborish uchun unga uzatiladi; xizmat o‘z siyosatiga ko‘ra yetkazish jurnalini saqlashi mumkin).

Ular ma’lumotni faqat LabGuide nomidan, xizmat ko‘rsatish uchun qayta ishlaydi; reklama uchun
ishlatmaydi va sotmaydi.

**Hisob bilan serverda nima saqlanadi va qancha vaqt.**
- **Email:** ochiq holda saqlanmaydi — faqat HMAC-hash (hisobni topish uchun) va niqoblangan
  ko‘rinish (masalan `da***@gmail.com`). Hisob o‘chirilguncha.
- **Kirish kodi:** faqat hash ko‘rinishida; 10 daqiqa amal qiladi, 5 urinish; ishlatilgach yoki
  muddati o‘tgach o‘chadi (muddati o‘tganlarini kunlik tozalash ham o‘chiradi).
- **Sessiya:** token faqat hash ko‘rinishida (tokenning o‘zi qurilmangizda, Keychain / Android
  Keystore); 60 kun, so‘ng o‘chadi; “Chiqish” ham o‘chiradi.
- **Profil:** ichki tasodifiy identifikator, tanlangan rol va til, ro‘yxatdan o‘tgan vaqt,
  ilovadan oxirgi foydalangan **kun** (vaqt va joylashuv emas). Hisob o‘chirilguncha.
- **Ustoz:** “ustoz” sifatida ro‘yxatdan o‘tgan vaqt. Hisob o‘chirilguncha.
- **Guruhlar:** guruh nomi, 8 belgili qo‘shilish kodi, a’zolik (rol, qo‘shilgan vaqt),
  guruhdagi taxallusingiz (ixtiyoriy) yoki avtomatik tartib raqamingiz (“Talaba 07”).
  **Ism-familiya so‘ralmaydi va serverga yuborilmaydi.** Guruh yoki hisob o‘chirilguncha.
- **O‘quv jarayoni:** ustoz ochgan mavzular (id va vaqtlar), test topshiriqlari (nom, savollar
  id si, vaqt chegarasi, to‘g‘ri javob kaliti — faqat ustozga), testni boshlash vaqti hamda
  **javoblaringiz, har savol natijasi va ballingiz**. Server og‘zaki savol-javob belgisini
  (natija, 1–5 baho) ham saqlay oladi, lekin ilova hozir uni yubormaydi. Guruh yoki hisob
  o‘chirilguncha.
- **Suiiste’molga qarshi hisoblagichlar:** kod so‘rash/tekshirish urinishlari soni; kalitida
  email/IP faqat hash ko‘rinishida. Kunlik tozalash bilan taxminan bir sutka ichida o‘chadi.
- **Xavfsizlik jurnali:** faqat ichki identifikator, vaqt va amal turi (masalan, “hisob
  o‘chirildi”); email yo‘q. Hisob o‘chirilgandan keyin ham qoladi.

IP manzilingiz LabGuide bazasida saqlanmaydi (faqat suiiste’molga qarshi hash-teg); Cloudflare
esa tarmoq xizmati sifatida so‘rovlarni o‘z siyosatiga ko‘ra qayta ishlaydi. Murojaatlar
(“Taklif va yordam”), skrinshotlar, tekshiruvchi qarorlari, hamkorlar va to‘lovlar serverda
hozircha **to‘planmaydi** (ishlamaydi).

**Nima to‘planmaydi.** Analitika SDK, reklama identifikatori, joylashuv, kontaktlar, kuzatuv
(tracking) yo‘q. Ma’lumotlaringiz sotilmaydi va reklama uchun boshqalarga berilmaydi.

**Mikrofon va ovozli buyruqlar (ixtiyoriy, eksperimental).** Leykoformula sanashda ovozli
buyruqlarni o‘zingiz yoqsangizgina mikrofonga ruxsat so‘raladi. Nutq tizimning nutqni tanish
xizmati orqali faqat qurilmaning o‘zida (oflayn) matnga aylantiriladi — iPhone’da ham,
Android’da ham (Android 12+); qurilmada oflayn tanish bo‘lmasa rejim yoqilmaydi. LabGuide
ovozni yozib olmaydi, saqlamaydi va o‘z serveriga yubormaydi; faqat tanilgan hujayra nomi
sanaladi. Ovoz bilan bemor ismini aytmang.

**Eslatmalar va ulashish.** Kunlik savol eslatmasi standart o‘chiq; yoqsangiz, u qurilmada
rejalashtiriladigan lokal bildirishnoma (push server yo‘q). Natija kartochkasini ulashish
tizimning ulashish oynasi orqali faqat siz tanlagan joyga yuboriladi; rasmda shaxsiy
ma’lumot yo‘q. “Rasmni saqlash” tanlansa, foto kutubxonasiga faqat shu rasm qo‘shiladi.

**Kim ko‘radi.** Ustoz faqat o‘zi yaratgan guruhni, uning a’zolari ro‘yxatini (taxallus yoki
tartib raqami) va o‘z talabalarining test javoblari va ballarini ko‘radi. Talaba faqat o‘zining
natijasini va o‘z a’zoligini ko‘radi; boshqa talabalarni va ularning natijalarini ko‘rmaydi.
Test javob kaliti faqat ustozga ko‘rinadi. Administrator vakolati faqat serverdagi maxfiy
ro‘yxat + tasdiqlangan email orqali beriladi va ikki bosqichli himoyani (TOTP) talab qiladi;
LabGuide egasi/administratori baza va uning zaxirasiga texnik kirish huquqiga ega, lekin to‘liq
emailni tiklay olmaydi (u saqlanmaydi). Cloudflare va Resend xodimlari faqat o‘z xizmat
shartlari doirasida kirishi mumkin.

**Ma’lumot O‘zbekistondan tashqarida saqlanadi.** Cloudflare D1 bazasi Sharqiy Yevropa
(EI) hududida joylashgan, ya’ni ma’lumotlaringiz **O‘zbekiston hududidan tashqarida**
saqlanadi va qayta ishlanadi; Cloudflare va Resend global infratuzilmada ishlaydi
(ma’lumot AQShga ham uzatilishi mumkin). Email bilan kirib, shu shartlarga rozilik bildirasiz;
rozi bo‘lmasangiz, hisobsiz (mehmon) foydalaning — asosiy imkoniyatlar qurilmada ishlaydi.
Ma’lumot uzatishda shifrlanadi (HTTPS).

**Hamjamiyat (savol-javob, ixtiyoriy).** Server ulangan buildda hisobli foydalanuvchi savol
beradi, tasdiqlangan mutaxassislar javob yozadi. **Savol va javoblar matni ilova ichida hamma
uchun ochiq** (mehmonlar ham o‘qiydi); muallif ismsiz ko‘rsatiladi — faqat “Foydalanuvchi” yoki
mutaxassis belgisi, kasb va mamlakat kodi. Serverda saqlanadi: post matni, tili, mavzusi
(tahlil/holat id si), vaqti, ovozlar va eng yaxshi javob belgisi; muallif ichki identifikator
emas, uning maxfiy kalitli hash’i bilan bog‘lanadi. Matnga email/telefon yozib bo‘lmaydi; bemor
ma’lumotini yozmang. **Mutaxassis tasdig‘i:** yuklagan hujjat surati (diplom, sertifikat, ish
joyi hujjati) faqat tekshiruv vaqtida Cloudflare Workers AI modeliga uzatiladi va
**saqlanmaydi** — na bazada, na fayl omborida, na jurnalda; uni inson ko‘rmaydi. Faqat natija
qoladi: kasb, mamlakat kodi, holat, qisqa texnik sabab kodlari (ism yo‘q) va sana. **Tarjima:**
“Tarjima qilish” bosilganda post matni Cloudflare Workers AI tarjima modeliga yuboriladi va
tarjima serverda keshlanadi (post o‘chirilguncha). **Shikoyatlar** (kim, qaysi post, sabab) faqat
administratorga ko‘rinadi; 3 ta turli foydalanuvchi shikoyati hamjamiyatdagi hisobni admin
ko‘rib chiqquncha to‘xtatadi. Tasdiq va shikoyat ma’lumotlarini faqat o‘zingiz va administrator
ko‘radi. Hamjamiyat ma’lumotlari hisob o‘chirilguncha saqlanadi.

**Bemor ma’lumotlari.** Ilovaga (taxallus va guruh nomiga ham) bemorni aniqlaydigan ma’lumot
(ism, tug‘ilgan sana, karta raqami) kiritmang. Guruhda taxallus sifatida o‘z ismingizni
ko‘rsatish shart emas.

**O‘chirish.** Profil → Maxfiylik → “Hisobni o‘chirish” serverdagi quyidagilarni butunlay
o‘chiradi: profil, hamma sessiyalar, ustoz va admin yozuvi, guruhlardagi a’zoligingiz va
taxallusingiz, sizning test javoblaringiz, urinishlaringiz va ballaringiz, ustoz belgilari,
hamjamiyatdagi savol va javoblaringiz (va ularga yozilgan javoblar), ovozlaringiz, shikoyatlar va
mutaxassis tasdig‘i holati.
Agar siz ustoz bo‘lsangiz — **siz yaratgan guruhlar ham o‘chadi**: ularning a’zolari, mavzulari,
topshiriqlari, javob kalitlari va barcha talabalar natijalari. Faqat xavfsizlik jurnalidagi
ichki identifikator va “hisob o‘chirildi” yozuvi qoladi (email emas). “Lokal ma’lumotlarni
o‘chirish” — qurilmadagi hamma narsa. Guruhdan chiqish faqat a’zolikni o‘chiradi, natijalaringiz
esa hisobingiz yoki guruh o‘chirilguncha ustozda qoladi. Ilovasiz so‘rov uchun:
labguide@nfcstore.uz.

**Saqlash muddati.** Yuqorida ko‘rsatilganidek: kod 10 daqiqa, sessiya 60 kun, hisoblagichlar
~1 sutka; qolgan ma’lumotlar hisob (yoki guruh) o‘chirilguncha. Faol bo‘lmagan hisoblar
avtomatik o‘chirilmaydi.

**Bolalar.** Ilova bolalarga mo‘ljallanmagan va ulardan ataylab ma’lumot to‘plamaydi.

**O‘zgarishlar.** Siyosat o‘zgarsa, yangi versiya shu sahifada sana bilan e’lon qilinadi.

## Русский

**Без аккаунта.** В гостевом режиме (и в сборке без подключённого сервера) LabGuide не
отправляет персональные данные на сервер. Настройки, закладки, записи QC, ваши приборы, журнал
калибровок, положение чтения и результаты тренировок хранятся только на устройстве (могут
попадать в системную резервную копию iCloud или Google). Реальное имя, которое преподаватель
ставит участнику группы как метку, тоже остаётся только на устройстве преподавателя.

**Поставщики услуг.** При входе по email данные обрабатываются через:
- **Cloudflare, Inc.** — сервер (Workers) и база данных (D1, Восточная Европа);
- **Resend** — только отправка письма с кодом входа (ему передаются ваш email и 6-значный код;
  сервис может хранить журнал доставки по своей политике).

Они обрабатывают данные только от имени LabGuide для оказания услуги; не используют их для
рекламы и не продают.

**Что хранится на сервере и сколько.**
- **Email:** в открытом виде не хранится — только HMAC-хеш (для поиска аккаунта) и маскированный
  вид (например `da***@gmail.com`). До удаления аккаунта.
- **Код входа:** только хеш; действует 10 минут, 5 попыток; удаляется после использования или
  по истечении (просроченные также удаляет ежедневная очистка).
- **Сессия:** токен только в виде хеша (сам токен — на вашем устройстве, Keychain / Android
  Keystore); 60 дней, затем удаляется; «Выйти» тоже удаляет.
- **Профиль:** внутренний случайный идентификатор, выбранные роль и язык, время регистрации,
  **день** последнего использования (не время и не местоположение). До удаления аккаунта.
- **Преподаватель:** время регистрации в роли преподавателя. До удаления аккаунта.
- **Группы:** название, 8-значный код присоединения, участие (роль, время), ваш псевдоним
  (необязательно) или автоматический порядковый номер («Студент 07»). **Имя и фамилия не
  запрашиваются и не отправляются на сервер.** До удаления группы или аккаунта.
- **Учебный процесс:** открытые преподавателем темы (id и время), тестовые задания (название, id
  вопросов, лимит времени, ключ ответов — только для преподавателя), время начала теста и
  **ваши ответы, результат по каждому вопросу и балл**. Сервер умеет хранить и отметки
  устного опроса (результат, оценка 1–5), но приложение сейчас их не отправляет. До удаления
  группы или аккаунта.
- **Счётчики защиты от злоупотреблений:** число попыток запроса/проверки кода; в ключе email/IP
  только в виде хеша. Удаляются ежедневной очисткой, примерно в течение суток.
- **Журнал безопасности:** только внутренний идентификатор, время и тип действия (например,
  «аккаунт удалён»); email нет. Сохраняется и после удаления аккаунта.

Ваш IP-адрес не сохраняется в базе LabGuide (только хеш-метка для защиты от злоупотреблений);
Cloudflare как сетевой сервис обрабатывает запросы по своей политике. Обращения («Предложения и
помощь»), скриншоты, решения рецензентов, партнёры и платежи на сервере пока **не собираются**
(не работают).

**Что не собирается.** Нет SDK аналитики, рекламного идентификатора, геолокации, контактов и
отслеживания. Данные не продаются и не передаются для рекламы.

**Микрофон и голосовые команды (по желанию, экспериментально).** Доступ к микрофону
запрашивается, только если вы сами включите голосовые команды при подсчёте лейкоформулы. Речь
распознаётся системной службой только на самом устройстве (офлайн) — и на iPhone, и на Android
(Android 12+); если офлайн-распознавания нет, режим не включается. LabGuide не
записывает, не хранит и не отправляет звук на свой сервер; учитывается только распознанное
название клетки. Не называйте вслух имя пациента.

**Напоминания и «Поделиться».** Напоминание о вопросах дня по умолчанию выключено; если его
включить, это локальное уведомление, запланированное на устройстве (push-сервера нет).
Карточка результата отправляется через системное окно «Поделиться» только туда, куда выберете
вы; персональных данных в ней нет. При выборе «Сохранить изображение» в фотоальбом добавляется
только эта картинка.

**Кто видит.** Преподаватель видит только созданную им группу, список её участников
(псевдоним или номер) и ответы и баллы своих студентов. Студент видит только свой результат и
своё участие; других студентов и их результаты не видит. Ключ ответов теста виден только
преподавателю. Права администратора выдаются только по секретному списку на сервере и
подтверждённому email и требуют двухфакторной защиты (TOTP); владелец/администратор LabGuide
имеет технический доступ к базе и её копиям, но не может восстановить полный email (он не
хранится). Сотрудники Cloudflare и Resend могут получать доступ лишь в рамках условий своих
услуг.

**Данные хранятся за пределами Узбекистана.** База Cloudflare D1 находится в Восточной Европе
(ЕС), то есть ваши данные хранятся и обрабатываются **за пределами территории Узбекистана**;
Cloudflare и Resend работают на глобальной инфраструктуре (данные могут передаваться и в США).
Входя по email, вы соглашаетесь с этим; если не согласны, пользуйтесь без аккаунта (гостевой
режим) — основные функции работают на устройстве. При передаче данные шифруются (HTTPS).

**Сообщество (вопросы и ответы, по желанию).** В сборке с сервером вошедший пользователь может
задать вопрос, отвечают подтверждённые специалисты. **Тексты вопросов и ответов открыты всем
внутри приложения** (читают и гости); автор показывается без имени — «Участник» или значок
специалиста, профессия и код страны. На сервере хранятся: текст, язык, тема (id анализа или
состояния), время, голоса и отметка лучшего ответа; автор связан не внутренним идентификатором,
а его хешем с секретным ключом. В тексте нельзя указывать email/телефон; не пишите данные
пациентов. **Подтверждение специалиста:** фото документа (диплом, сертификат, документ с места
работы) передаётся модели Cloudflare Workers AI только на время проверки и **не сохраняется** —
ни в базе, ни в файловом хранилище, ни в журналах; человек его не видит. Остаётся только
результат: профессия, код страны, статус, короткие технические коды причины (без имени) и дата.
**Перевод:** по нажатию «Перевести» текст записи отправляется модели перевода Cloudflare Workers AI,
перевод кешируется на сервере (до удаления записи). **Жалобы** (кто, на какую запись, причина)
видит только администратор; жалобы 3 разных пользователей приостанавливают аккаунт в сообществе до
проверки администратором. Данные подтверждения и жалоб видите только вы и администратор. Данные
сообщества хранятся до удаления аккаунта.

**Данные пациентов.** Не вводите в приложение (в том числе в псевдоним и название группы) данные,
позволяющие идентифицировать пациента (ФИО, дату рождения, номер карты). В группе указывать своё
имя в качестве псевдонима не обязательно.

**Удаление.** Профиль → Конфиденциальность → «Удалить аккаунт» полностью удаляет на сервере:
профиль, все сессии, записи преподавателя и администратора, ваше участие и псевдоним в группах,
ваши ответы на тесты, попытки и баллы, отметки преподавателя, ваши вопросы и ответы в сообществе
(и ответы на ваши вопросы), голоса, жалобы и статус подтверждения специалиста. Если вы преподаватель —
**созданные вами группы тоже удаляются**: их участники, темы, задания, ключи ответов и
результаты всех студентов. Остаётся только внутренний идентификатор в журнале безопасности и
запись «аккаунт удалён» (без email). «Удалить локальные данные» — всё на устройстве. Выход из
группы удаляет только участие, а ваши результаты остаются у преподавателя до удаления аккаунта
или группы. Запрос без приложения: labguide@nfcstore.uz.

**Срок хранения.** Как указано выше: код 10 минут, сессия 60 дней, счётчики около суток;
остальное — до удаления аккаунта (или группы). Неактивные аккаунты автоматически не удаляются.

**Дети.** Приложение не предназначено для детей и намеренно не собирает их данные.

**Изменения.** При изменении политики новая версия публикуется на этой странице с датой.

## English

**Without an account.** In guest mode (and in a build with no server connected) LabGuide sends
no personal data to a server. Settings, bookmarks, QC records, your instruments, calibration
log, reading position and practice results stay on your device (they may be included in the
system’s iCloud or Google backup). A real-name label a teacher puts on a group member also
stays only on the teacher’s device.

**Service providers.** If you sign in with email, data is processed through:
- **Cloudflare, Inc.** — the server (Workers) and database (D1, Eastern Europe);
- **Resend** — only to send the sign-in code email (your email address and the 6-digit code are
  passed to it; it may keep a delivery log under its own policy).

They process data only on LabGuide’s behalf to provide the service; they do not use it for
advertising or sell it.

**What the server stores, and for how long.**
- **Email:** never stored in the clear — only an HMAC hash (to find your account) and a masked
  form (e.g. `da***@gmail.com`). Until you delete your account.
- **Sign-in code:** hash only; valid for 10 minutes, 5 attempts; removed once used or expired
  (the daily cleanup also removes expired ones).
- **Session:** the token is stored only as a hash (the token itself lives on your device,
  Keychain / Android Keystore); 60 days, then removed; “Sign out” also removes it.
- **Profile:** an internal random identifier, your chosen role and language, sign-up time, and
  the **day** you last used the app (not time or location). Until account deletion.
- **Teacher:** the time you registered as a teacher. Until account deletion.
- **Groups:** group name, 8-character join code, membership (role, join time), your nickname
  (optional) or an automatic sequence number (“Student 07”). **No first or last name is asked
  for or sent to the server.** Until the group or account is deleted.
- **Teaching activity:** topics a teacher opened (ids and times), test assignments (title,
  question ids, time limit, answer key — teacher only), the time you started a test, and
  **your answers, per-question result and score**. The server can also store oral Q&A marks
  (result, 1–5 grade), but the app does not send them at present. Until the group or account is
  deleted.
- **Abuse-protection counters:** the number of code request/verify attempts; the key holds an
  email/IP only as a hash. Removed by the daily cleanup, within roughly a day.
- **Security log:** only an internal identifier, time and action type (e.g. “account
  deleted”); no email. It remains after account deletion.

Your IP address is not stored in LabGuide’s database (only a hashed tag for abuse protection);
Cloudflare, as a network service, handles requests under its own policy. Support requests
(“Feedback and help”), screenshots, reviewer decisions, partners and payments are **not
collected** on the server at present (not active).

**What is not collected.** No analytics SDK, advertising identifier, location, contacts or
tracking. Your data is not sold or shared for advertising.

**Microphone and voice commands (optional, experimental).** Microphone access is requested only
if you turn on voice commands in the differential counter. Speech is recognised by the system
speech service on the device itself only (offline) — on iPhone and on Android 12+; if on-device
recognition is unavailable, the mode stays off. LabGuide does not record,
store or send audio to its own server; only the recognised cell name is counted. Do not say a
patient’s name aloud.

**Reminders and sharing.** The daily question reminder is off by default; if you turn it on, it
is a local notification scheduled on the device (no push server). A result card is shared
through the system share sheet only to the destination you choose; it contains no personal
data. If you choose “Save Image”, only that image is added to your photo library.

**Who can see it.** A teacher sees only the group they created, its member list (nickname or
number) and the answers and scores of their own students. A student sees only their own result
and membership — not other students or their results. The test answer key is visible only to
the teacher. Administrator rights are granted only via a secret server-side list plus a
verified email and require two-factor authentication (TOTP); the LabGuide owner/administrator
has technical access to the database and its backups but cannot recover a full email address
(it is not stored). Cloudflare and Resend personnel may access data only as allowed by their
own service terms.

**Data is stored outside Uzbekistan.** The Cloudflare D1 database is located in Eastern Europe
(EU), so your data is stored and processed **outside the territory of Uzbekistan**; Cloudflare
and Resend run on global infrastructure (data may also be transferred to the US). By signing in
with email you accept this; if you do not, use the app without an account (guest mode) — the
core features work on the device. Data is encrypted in transit (HTTPS).

**Community (Q&A, optional).** In a build connected to the server, a signed-in user can ask a
question and verified specialists answer. **Question and answer texts are public inside the app**
(guests can read them too); the author is shown without a name — “Member” or a specialist badge,
profession and country code. The server stores: the text, its language, topic (test or condition
id), time, votes and the best-answer mark; the author is linked not by the internal identifier but
by a keyed hash of it. Email addresses/phone numbers are rejected in posts; do not write patient
data. **Specialist verification:** the photo of your document (diploma, certificate, employment
document) is passed to a Cloudflare Workers AI model only for the duration of the check and is
**not stored** — not in the database, not in file storage, not in logs; no person looks at it.
Only the result is kept: profession, country code, status, short technical reason codes (no name)
and date. **Translation:** when you tap “Translate”, the post text is sent to a Cloudflare Workers
AI translation model and the translation is cached on the server (until the post is deleted).
**Reports** (who, which post, reason) are visible only to the administrator; reports from 3
different users suspend the community account until an administrator reviews it. Verification and
report data are visible only to you and the administrator. Community data is kept until the
account is deleted.

**Patient data.** Do not enter information that identifies a patient (name, date of birth,
record number) anywhere in the app, including nicknames and group names. In a group you do not
have to use your own name as a nickname.

**Deletion.** Profile → Privacy → “Delete account” permanently removes from the server: your
profile, all sessions, teacher and admin records, your group memberships and nicknames, your
test answers, attempts and scores, teacher marks about you, your community questions and answers
(and answers to your questions), votes, reports and specialist verification status. If you are a teacher, **the
groups you created are deleted too**: their members, topics, assignments, answer keys and all
students’ results. Only an internal identifier in the security log and an “account deleted”
entry remain (no email). “Delete local data” removes everything on the device. Leaving a group
removes only your membership; your results stay with the teacher until your account or the
group is deleted. Request without the app: labguide@nfcstore.uz.

**Retention.** As listed above: code 10 minutes, session 60 days, counters about a day; all
other data until the account (or group) is deleted. Inactive accounts are not deleted
automatically.

**Children.** The app is not directed to children and does not knowingly collect their data.

**Changes.** If this policy changes, the new version is published on this page with its date.
