# Shanba (24 oktyabr) — Android: pastki menyu va tizim tugmalari

Topilgan: Android telefonda (uch tugmali / jest paneli) LabGuide'ning suzuvchi pastki menyusi ustiga
tizim navigatsiya paneli chiqib qoladi — tugmalar bir-birining ustiga tushadi (11:33 skrinshot, build 163).

Qilinadi:
- Pastki menyuga `MediaQuery.viewPadding.bottom` (tizim paneli balandligi) qo'shish; edge-to-edge rejimini tekshirish
  (`SystemChrome.setEnabledSystemUIMode`, `enableEdgeToEdge`), Android 14/15 va 3 tugmali + jest rejimlarida sinash.
- Sahifalarning pastki padding'i menyu + tizim paneli balandligini hisobga olsin (oxirgi kartochka yopilib qolmasin).
- Widget testi: `MediaQuery(viewPadding.bottom: 48)` bilan menyu tizim panelidan yuqorida turishi.

Eslatma: Play 163 build yopiq (alpha) trekka yuborilgan (run 163, success); ichki trekda 161.
