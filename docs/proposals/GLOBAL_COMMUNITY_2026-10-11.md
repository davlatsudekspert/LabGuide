# LabGuide — dunyo biokimyogarlari va laborantlari hamjamiyati (taklif)

Sana: 2026-10-11. Holat: **taklif**, egasining qarorini kutadi. Hech narsa hali yoqilmagan.

## 0. Maqsad

LabGuide bugun yaxshi **shaxsiy qo'llanma**: analitlar, kalkulyatorlar, QC, o'quv, toifa, ustoz–talaba sinfi.
Keyingi qadam — uni klinik laboratoriya mutaxassislarini (biokimyogar, laborant, KDL shifokori,
talaba, ustoz) **bir joyga yig'adigan** professional hamjamiyatga aylantirish. Asosiy qadriyat:
*ishonchli bilim + tajriba almashish + malaka oshirish*, ijtimoiy tarmoq shovqinisiz.

Tamoyillar (o'zgarmaydi):
- Tibbiy mazmun faqat manba va mutaxassis tekshiruvidan keyin "tasdiqlangan" bo'ladi.
- Bemor ma'lumoti hech qachon ilovaga kiritilmaydi (anonim holatlar ham faqat tozalangan shablon orqali).
- Har foydalanuvchi faqat o'z yozishmalarini ko'radi; AI egasi nomidan avtomatik javob bermaydi.
- Soxta statistika yo'q: mehmonlar ro'yxatdan o'tganlar soniga qo'shilmaydi.

## 1. Bosqichlar

### 1-bosqich (1–2 oy): Mutaxassis profili va tasdiqlash
- Ixtiyoriy professional profil: rol, mamlakat, laboratoriya turi (ism ixtiyoriy, ommaviy emas).
- "Tasdiqlangan mutaxassis" belgisi: diplom/ish joyi hujjati faqat admin ko'radi, so'ng hujjat o'chiriladi.
- Til: uz / ru / en; keyin kk, ky, tg, tr, ar (Markaziy Osiyo + MDH + Yaqin Sharq).

### 2-bosqich (2–4 oy): Bilim almashish
- **Savol–javob (Q&A)** mavzular bo'yicha (gematologiya, biokimyo, QC, preanalitika…).
  Javoblarni tasdiqlangan mutaxassislar ovozlaydi; eng yaxshi javob — "kurator tasdiqladi".
- **Holatlar kutubxonasi** (case of the week): tozalangan shablon — yosh oralig'i, natijalar,
  savol; bemorni aniqlab bo'ladigan maydon yo'q. Moderatsiyadan keyin chiqadi.
- **Mikroskopiya atlasi hamjamiyat hissasi**: foydalanuvchi o'z mikrofotosini yuklaydi,
  litsenziya (CC BY) tanlaydi, 2 ta mutaxassis tasdiqlamaguncha "diagnostik" deb ko'rsatilmaydi.

### 3-bosqich (4–6 oy): Sifat va malaka
- **Laboratoriyalararo QC taqqoslash** (ixtiyoriy, anonim): bir xil nazorat materiali lotlari bo'yicha
  o'rtacha/SD ni boshqa laboratoriyalar bilan solishtirish (peer group). Faqat agregat ko'rsatiladi,
  kamida 5 laboratoriya bo'lmasa — ko'rsatilmaydi.
- **Uzluksiz ta'lim (CME)**: modul + test → sertifikat (rasmiy kredit faqat hamkor tashkilot bilan
  kelishuvdan keyin; shungacha "LabGuide ichki sertifikati" deb aniq yoziladi).
- Ustoz–talaba sinflari: boshqa kollejlar uchun ochish, umumiy kurs shablonlari.

### 4-bosqich: Hamkorlik
- Milliy jamiyatlar, kollejlar, IFCC/EFLM ochiq resurslari bilan hamkorlik.
- Uskuna ishlab chiqaruvchilari: faqat "Hamkor" belgisi bilan, tibbiy mazmundan alohida.

## 2. Texnik asos (hozirgi arxitekturaga mos)

| Qism | Yechim | Izoh |
|---|---|---|
| Server | Cloudflare Workers + D1 (bor) | Q&A, profillar, ovozlar uchun yangi jadvallar |
| Fayllar (mikrofoto) | Cloudflare R2 (yopiq, imzolangan URL) | Bepul limit 10 GB |
| Moderatsiya | Admin panel (bor) + navbat | Har post avval "kutilmoqda" |
| Bildirishnomalar | Push (FCM/APNs) | Faqat foydalanuvchi yoqsa |
| Qidiruv | D1 FTS5 | Ko'p tilli |

Xarajat: ~1000 faol foydalanuvchigacha Cloudflare bepul tarifida; undan keyin Workers Paid ($5/oy).

## 3. Xavf va qonun

- O'RQ-547 (shaxsiy ma'lumotlar lokalizatsiyasi): O'zbekiston fuqarolari ma'lumoti EI serverida —
  yurist bilan tekshirish kerak; kerak bo'lsa O'zbekistondagi server (MyCloud) ga ko'chirish rejasi.
- Tibbiy maslahat emas: Q&A da "bemorni davolash bo'yicha shaxsiy maslahat berilmaydi" qoidasi.
- Moderatsiya yuki: boshida faqat tasdiqlangan mutaxassislar post yozadi.

## 4. Egasidan kerakli qarorlar

1. Qaysi bosqichdan boshlaymiz? (Tavsiya: 1 + 2-bosqichdagi Q&A.)
2. Mutaxassisni tasdiqlash usuli: hujjat yuklash yoki tashkilot emaili (masalan @...uz klinikalar).
3. Qaysi qo'shimcha tillar birinchi?
4. Moderatorlar kim bo'ladi (siz + 1–2 ustoz)?
