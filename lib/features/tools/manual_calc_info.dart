/// Qo'lda usullar kalkulyatorlarining formulasi, cheklovlari va manbalari
/// (3 tilda). Manbalar — `CalcSources` (calc_info.dart); har da'vo manba
/// matnidan tekshirilgan, manbada yo'q narsa yozilmaydi.
library;

import '../content/content_model.dart';
import 'calc_info.dart';

enum ManualCalc {
  chamber,
  differential,
  reticulocytes,
  light,
  colourIndex,
  nechiporenko,
  addis,
  zimnitsky,
}

/// MDH klassik usullari (xalqaro qo'llanmada yo'q) — ekranda belgi bilan.
const classicManualCalcs = {
  ManualCalc.nechiporenko,
  ManualCalc.addis,
  ManualCalc.zimnitsky,
};

const Map<ManualCalc, CalcInfo> manualCalcInfo = {
  ManualCalc.chamber: CalcInfo(
    formula: [
      LocalizedText({
        'uz':
            'Hujayra/µL = sanalgan hujayralar × suyultirish ÷ (kvadratlar '
            'soni × bitta kvadrat maydoni, mm² × kamera chuqurligi, mm)',
        'ru':
            'Клеток/мкл = подсчитанные клетки × разведение ÷ (число '
            'квадратов × площадь квадрата, мм² × глубина камеры, мм)',
        'en':
            'Cells/µL = cells counted × dilution ÷ (squares counted × area '
            'of one square, mm² × chamber depth, mm)',
      }),
      LocalizedText({
        'uz':
            '1 µL = 1 mm³; ×10⁹/L = hujayra/µL ÷ 1000. WHO misoli: Neubauer, '
            '4 burchak kvadrat (har biri 1 mm²), chuqurlik 0,1 mm, '
            'suyultirish 1:20, 188 leykotsit → 9,4 × 10⁹/L.',
        'ru':
            '1 мкл = 1 мм³; ×10⁹/л = клеток/мкл ÷ 1000. Пример ВОЗ: камера '
            'Нейбауэра, 4 угловых квадрата (по 1 мм²), глубина 0,1 мм, '
            'разведение 1:20, 188 лейкоцитов → 9,4 × 10⁹/л.',
        'en':
            '1 µL = 1 mm³; ×10⁹/L = cells/µL ÷ 1000. WHO example: improved '
            'Neubauer, 4 corner squares (1 mm² each), depth 0.1 mm, 1 in 20 '
            'dilution, 188 leukocytes → 9.4 × 10⁹/L.',
      }),
    ],
    limitations: [
      LocalizedText({
        'uz':
            'Kvadrat maydoni va chuqurlik kamera setkasiga bog‘liq (Neubauer, '
            'Goryayev, Fuchs–Rosenthal har xil). Qiymatlarni kamerangiz '
            'pasporti yoki setka chizmasidan tekshiring — ilova setka turini '
            'taxmin qilmaydi.',
        'ru':
            'Площадь квадрата и глубина зависят от сетки камеры (Нейбауэр, '
            'Горяев, Фукс–Розенталь различаются). Проверьте значения по '
            'паспорту камеры или схеме сетки — приложение не угадывает тип '
            'сетки.',
        'en':
            'Square area and depth depend on the chamber ruling (Neubauer, '
            'Goryaev and Fuchs–Rosenthal differ). Check them against your '
            'chamber’s certificate or ruling diagram — the app does not guess '
            'the ruling.',
      }),
      LocalizedText({
        'uz':
            'WHO qo‘llanmasiga ko‘ra eritrotsitlarni kamerada sanash aniqligi '
            'past; Ht yoki gemoglobinni o‘lchash tavsiya etiladi.',
        'ru':
            'По руководству ВОЗ, подсчёт эритроцитов в камере малоточен; '
            'рекомендуется измерять гематокрит или гемоглобин.',
        'en':
            'Per the WHO manual, counting erythrocytes in a chamber has low '
            'precision; measuring the PCV or haemoglobin is recommended.',
      }),
      LocalizedText({
        'uz':
            'Yadroli eritrotsitlar leykotsit suyuqligida gemolizlanmaydi va '
            'leykotsit bilan birga sanaladi — ko‘p bo‘lsa, “Leykoformula” '
            'kalkulyatorida tuzating.',
        'ru':
            'Нормобласты не гемолизируются в жидкости для лейкоцитов и '
            'считаются вместе с ними — при большом количестве введите '
            'поправку в калькуляторе «Лейкоформула».',
        'en':
            'Normoblasts are not haemolysed by the diluting fluid and are '
            'counted as leukocytes — if numerous, correct in the '
            '“Differential” calculator.',
      }),
    ],
    refs: [
      CalcRef(
        CalcSources.whoBasicLab2003,
        '9.6.2–9.6.3 (Neubauer, leukocytes); 8.3.3 (Fuchs–Rosenthal); 9.5',
      ),
    ],
  ),
  ManualCalc.differential: CalcInfo(
    formula: [
      LocalizedText({
        'uz': 'Mutlaq son (×10⁹/L) = hujayra turi, % ÷ 100 × WBC (×10⁹/L)',
        'ru': 'Абсолютное число (×10⁹/л) = доля клеток, % ÷ 100 × WBC (×10⁹/л)',
        'en': 'Absolute count (×10⁹/L) = cell type, % ÷ 100 × WBC (×10⁹/L)',
      }),
      LocalizedText({
        'uz':
            'Yadroli eritrotsitlar (n — 100 leykotsitga): NRBC = n × WBC ÷ '
            '(100 + n); tuzatilgan WBC = WBC − NRBC.',
        'ru':
            'Нормобласты (n — на 100 лейкоцитов): NRBC = n × WBC ÷ (100 + n); '
            'исправленный WBC = WBC − NRBC.',
        'en':
            'Nucleated RBCs (n per 100 leukocytes): NRBC = n × WBC ÷ (100 + '
            'n); corrected WBC = WBC − NRBC.',
      }),
    ],
    limitations: [
      LocalizedText({
        'uz':
            'Foizlar yig‘indisi 100 bo‘lishi kerak (yaxlitlash uchun ± 0,5). '
            'Bo‘sh qoldirilgan qator hisobga kirmaydi.',
        'ru':
            'Сумма процентов должна быть 100 (± 0,5 на округление). Пустая '
            'строка не учитывается.',
        'en':
            'Percentages must add up to 100 (± 0.5 for rounding). Empty rows '
            'are not counted.',
      }),
      LocalizedText({
        'uz':
            'Tuzatish faqat hisoblagich yoki kamera yadroli eritrotsitlarni '
            'leykotsit deb sanagan bo‘lsa kerak. Analizatoringiz WBC ni o‘zi '
            'tuzatsa, ikkinchi marta tuzatmang — yo‘riqnomasini tekshiring.',
        'ru':
            'Поправка нужна, только если счётчик или камера посчитали '
            'нормобласты как лейкоциты. Если анализатор уже исправляет WBC, '
            'не корректируйте повторно — проверьте инструкцию.',
        'en':
            'Correct only if the counter or chamber counted nucleated RBCs as '
            'leukocytes. If your analyser already corrects the WBC, do not '
            'correct twice — check its instructions.',
      }),
    ],
    refs: [
      CalcRef(
        CalcSources.whoBasicLab2003,
        '9.13.1, 9.13.3 (number concentration); 9.6.4 (correction for '
        'nucleated erythrocytes)',
      ),
    ],
  ),
  ManualCalc.reticulocytes: CalcInfo(
    formula: [
      LocalizedText({
        'uz':
            'Retikulotsitlar, % = sanalgan retikulotsitlar ÷ ko‘rilgan '
            'eritrotsitlar × 100. Mutlaq son (×10⁹/L) = RBC (×10¹²/L) × % × 10.',
        'ru':
            'Ретикулоциты, % = подсчитанные ретикулоциты ÷ просмотренные '
            'эритроциты × 100. Абсолютное число (×10⁹/л) = RBC (×10¹²/л) × % '
            '× 10.',
        'en':
            'Reticulocytes, % = reticulocytes counted ÷ erythrocytes examined '
            '× 100. Absolute count (×10⁹/L) = RBC (×10¹²/L) × % × 10.',
      }),
      LocalizedText({
        'uz':
            'Tuzatilgan % = % × bemor Ht ÷ 45. RPI = tuzatilgan % ÷ yetilish '
            'koeffitsiyenti.',
        'ru':
            'Исправленный % = % × Ht пациента ÷ 45. RPI = исправленный % ÷ '
            'поправка на созревание.',
        'en':
            'Corrected % = % × patient Hct ÷ 45. RPI = corrected % ÷ '
            'maturation factor.',
      }),
      LocalizedText({
        'uz':
            'Yetilish koeffitsiyenti jadvali [3]: Ht 45 % → 1,0; 35 % → 1,5; '
            '25 % → 2,0; 20 % → 2,5.',
        'ru':
            'Таблица поправки на созревание [3]: Ht 45 % → 1,0; 35 % → 1,5; '
            '25 % → 2,0; 20 % → 2,5.',
        'en':
            'Maturation factor table [3]: Hct 45% → 1.0; 35% → 1.5; '
            '25% → 2.0; 20% → 2.5.',
      }),
    ],
    limitations: [
      LocalizedText({
        'uz':
            'Manba jadvalida faqat nuqtalar bor, oraliq chegaralari yo‘q. '
            'Koeffitsiyent tanlanmasa, ilova eng yaqin nuqtani oladi (teng '
            'masofada — kattasini); bu ilova qoidasi. Laboratoriyangiz boshqa '
            'jadval ishlatsa, koeffitsiyentni qo‘lda tanlang.',
        'ru':
            'В таблице источника даны только точки, без границ интервалов. '
            'Если поправка не выбрана, приложение берёт ближайшую точку (при '
            'равенстве — большую); это правило приложения. Если ваша '
            'лаборатория использует другую таблицу, выберите поправку вручную.',
        'en':
            'The source table gives points only, not interval limits. If no '
            'factor is chosen, the app takes the nearest point (the larger on '
            'a tie); this is an app rule. If your laboratory uses another '
            'table, choose the factor manually.',
      }),
      LocalizedText({
        'uz':
            '“Normal” Ht = 45 manbada kattalar uchun misol sifatida berilgan; '
            'bolalarda RPI eritropoezni yetarli baholamasligi mumkin.',
        'ru':
            '«Нормальный» Ht = 45 приведён в источнике как пример для '
            'взрослых; у детей RPI может оценивать эритропоэз неадекватно.',
        'en':
            'A “normal” Hct of 45 is given in the source as an adult example; '
            'in children the RPI may not assess erythropoiesis adequately.',
      }),
      LocalizedText({
        'uz':
            'Retikulotsitlarning qonda yetilish vaqti anemiya og‘irligi bilan '
            'uzayadi — shuning uchun xom % tuzatiladi [4].',
        'ru':
            'Время созревания ретикулоцитов в крови удлиняется с тяжестью '
            'анемии — поэтому «сырой» % корректируют [4].',
        'en':
            'Circulating reticulocyte maturation time lengthens with the '
            'severity of anaemia — hence the raw % is adjusted [4].',
      }),
    ],
    refs: [
      CalcRef(CalcSources.whoBasicLab2003, '9.12.4 (calculation)'),
      CalcRef(CalcSources.chueh2022, 'Laboratory tests for screening'),
      CalcRef(CalcSources.kroll2015, 'Reticulocyte production index'),
      CalcRef(CalcSources.hillman1969, 'Abstract'),
    ],
  ),
  ManualCalc.light: CalcInfo(
    formula: [
      LocalizedText({
        'uz':
            'Ekssudat, agar kamida bittasi bajarilsa: (1) suyuqlik oqsili ÷ '
            'zardob oqsili > 0,5; (2) suyuqlik LDH ÷ zardob LDH > 0,6; '
            '(3) suyuqlik LDH > zardob LDH yuqori chegarasining 2/3 qismi.',
        'ru':
            'Экссудат, если выполнен хотя бы один: (1) белок жидкости ÷ белок '
            'сыворотки > 0,5; (2) ЛДГ жидкости ÷ ЛДГ сыворотки > 0,6; (3) ЛДГ '
            'жидкости > 2/3 верхней границы нормы ЛДГ сыворотки.',
        'en':
            'Exudate if at least one is met: (1) fluid protein ÷ serum protein '
            '> 0.5; (2) fluid LDH ÷ serum LDH > 0.6; (3) fluid LDH > 2/3 of '
            'the upper limit of normal serum LDH.',
      }),
    ],
    limitations: [
      LocalizedText({
        'uz':
            'Har juftlik (oqsil, LDH) bir xil birlikda va bir usulda '
            'o‘lchanishi kerak. LDH ning yuqori chegarasi — laboratoriyangizning '
            'o‘z referens oralig‘idan.',
        'ru':
            'Каждая пара (белок, ЛДГ) должна быть в одних единицах и одним '
            'методом. Верхняя граница ЛДГ — из референсного интервала вашей '
            'лаборатории.',
        'en':
            'Each pair (protein, LDH) must be in the same unit and by the same '
            'method. The LDH upper limit comes from your laboratory’s own '
            'reference interval.',
      }),
      LocalizedText({
        'uz':
            'Mezonlar ekssudatga juda sezgir, lekin transsudatlarning taxminan '
            '25 % ini ekssudat deb noto‘g‘ri tasniflashi mumkin (ayniqsa yurak '
            'yetishmovchiligi va jigar sirrozida) [2].',
        'ru':
            'Критерии очень чувствительны к экссудату, но могут ошибочно '
            'отнести к экссудатам около 25 % транссудатов (особенно при '
            'сердечной недостаточности и циррозе) [2].',
        'en':
            'The criteria are very sensitive for exudates but may misclassify '
            'about 25% of transudates (notably in heart failure and '
            'cirrhosis) [2].',
      }),
      LocalizedText({
        'uz':
            'Asl 1972 ishda uchinchi mezon LDH ning mutlaq qiymati bilan '
            'berilgan; ilova keyingi adabiyotdagi “yuqori chegaraning 2/3 '
            'qismi” shaklini ishlatadi [2].',
        'ru':
            'В исходной работе 1972 г. третий критерий задан абсолютным '
            'значением ЛДГ; приложение использует более позднюю форму '
            '«2/3 верхней границы нормы» [2].',
        'en':
            'The original 1972 paper stated the third criterion as an '
            'absolute LDH value; the app uses the later “2/3 of the upper '
            'limit of normal” form [2].',
      }),
    ],
    refs: [
      CalcRef(CalcSources.light1972, 'Original criteria'),
      CalcRef(CalcSources.harding2025, 'Table 1; Diagnosis'),
    ],
  ),
  ManualCalc.colourIndex: CalcInfo(
    formula: [
      LocalizedText({
        'uz':
            'MCHC (g/dL) = Hb (g/dL) ÷ Ht (%) × 100 — WHO qo‘llanmasidagi '
            'misol: 15,0 ÷ 43 × 100 ≈ 35.',
        'ru':
            'MCHC (г/дл) = Hb (г/дл) ÷ Ht (%) × 100 — пример из руководства '
            'ВОЗ: 15,0 ÷ 43 × 100 ≈ 35.',
        'en':
            'MCHC (g/dL) = Hb (g/dL) ÷ Hct (%) × 100 — WHO manual example: '
            '15.0 ÷ 43 × 100 ≈ 35.',
      }),
    ],
    limitations: [
      LocalizedText({
        'uz':
            'Rang ko‘rsatkichi formulasi uchun biz tekshira oladigan birlamchi '
            'ochiq manba topilmadi — shuning uchun ilova uni hisoblamaydi.',
        'ru':
            'Для формулы цветового показателя не найден первичный открытый '
            'источник, который мы могли бы проверить, — поэтому приложение '
            'его не рассчитывает.',
        'en':
            'No primary open source we could verify was found for the colour '
            'index formula, so the app does not calculate it.',
      }),
    ],
    refs: [
      CalcRef(CalcSources.whoBasicLab2003, '9.4.1 (MCHC)'),
      CalcRef(CalcSources.medlinePlusRbcIndices, 'What are RBC indices?'),
    ],
  ),
  ManualCalc.nechiporenko: CalcInfo(
    formula: [
      LocalizedText({
        'uz':
            'x (1 µL cho‘kmada) = A ÷ V, bunda A — to‘rda sanalgan hujayralar, '
            'V — sanalgan to‘r hajmi, µL. N (1 ml siydikda) = x × cho‘kma '
            'hajmi (µL) ÷ sentrifugalangan siydik (ml) [1, 44-bet].',
        'ru':
            'x (в 1 мкл осадка) = A ÷ V, где A — клетки, подсчитанные в '
            'сетке, V — объём подсчитанной сетки, мкл. N (в 1 мл мочи) = x × '
            'объём осадка (мкл) ÷ центрифугированная моча (мл) [1, с. 44].',
        'en':
            'x (per 1 µL of sediment) = A ÷ V, where A is the cells counted '
            'and V the volume of the ruling counted, µL. N (per 1 ml of '
            'urine) = x × sediment volume (µL) ÷ urine centrifuged (ml) '
            '[1, p. 44].',
      }),
      LocalizedText({
        'uz':
            'Misol (Aripova [2, 99-bet]): 10 ml siydik, 1 ml cho‘kma, Goryaev '
            'to‘rining 100 katta kvadrati (0,4 µL) → N = A × 250.',
        'ru':
            'Пример (Арипова [2, с. 99]): 10 мл мочи, 1 мл осадка, 100 больших '
            'квадратов сетки Горяева (0,4 мкл) → N = A × 250.',
        'en':
            'Example (Aripova [2, p. 99]): 10 ml urine, 1 ml sediment, 100 '
            'large Goryaev squares (0.4 µL) → N = A × 250.',
      }),
    ],
    limitations: [
      LocalizedText({
        'uz':
            'MDH klassik usuli: xalqaro (JSST) qo‘llanmalarda yo‘q, formula '
            'darsliklardan olingan. Natijani laboratoriyangiz usuli bilan '
            'solishtiring.',
        'ru':
            'Классический метод школы СССР: в международных (ВОЗ) руководствах '
            'его нет, формула взята из учебников. Сверяйте с методикой вашей '
            'лаборатории.',
        'en':
            'A classic Soviet-school method: it is not in international (WHO) '
            'guidance and the formula comes from textbooks. Compare with your '
            'laboratory’s procedure.',
      }),
      LocalizedText({
        'uz':
            'Birlik tuzatildi: Aripova 2007 da A × 250 natijasi “1 litr '
            'siydikda” deb yozilgan. Hisob (0,4 µL, 1 ml cho‘kma, 10 ml siydik) '
            'bo‘yicha bu 1 ml siydikdagi son — ilova shunday ko‘rsatadi.',
        'ru':
            'Исправлена единица: в учебнике Ариповой 2007 результат A × 250 '
            'назван «в 1 литре мочи». По расчёту (0,4 мкл, 1 мл осадка, 10 мл '
            'мочи) это число в 1 мл мочи — так приложение и показывает.',
        'en':
            'Unit corrected: Aripova 2007 labels the A × 250 result “per litre '
            'of urine”. By the arithmetic (0.4 µL, 1 ml sediment, 10 ml urine) '
            'it is the count per 1 ml of urine, and the app shows it that way.',
      }),
      LocalizedText({
        'uz':
            'Darsliklar sanalgan to‘r hajmida farq qiladi: Lyubina butun '
            'Goryaev to‘ri (0,9 µL) bo‘yicha bo‘ladi, Aripova 100 katta '
            'kvadrat (0,4 µL) bo‘yicha. Qaysi hajmni sanaganingizni tanlang.',
        'ru':
            'Учебники различаются объёмом сетки: Любина делит на всю сетку '
            'Горяева (0,9 мкл), Арипова — на 100 больших квадратов (0,4 мкл). '
            'Выберите тот объём, который вы подсчитали.',
        'en':
            'The textbooks differ in the volume counted: Lyubina divides by '
            'the whole Goryaev ruling (0.9 µL), Aripova by 100 large squares '
            '(0.4 µL). Choose the volume you actually counted.',
      }),
      LocalizedText({
        'uz':
            'Ertalabki siydikning o‘rta porsiyasi olinadi va pH darhol '
            'o‘lchanadi: ishqoriy siydikda hujayralar qisman parchalanadi '
            '[1, 43-bet].',
        'ru':
            'Берут среднюю порцию утренней мочи и сразу определяют pH: в '
            'щелочной моче клетки частично разрушаются [1, с. 43].',
        'en':
            'Use the midstream first-morning sample and check the pH at once: '
            'cells partly break down in alkaline urine [1, p. 43].',
      }),
    ],
    refs: [
      CalcRef(CalcSources.lyubina1984, 'Метод Нечипоренко, pp. 43–44'),
      CalcRef(CalcSources.aripova2007, '10.5 Nechiporenko usuli, p. 99'),
    ],
  ),
  ManualCalc.addis: CalcInfo(
    formula: [
      LocalizedText({
        'uz':
            'Sentrifugaga 12 daqiqalik siydik olinadi: Q = v ÷ (t × 5), v — '
            'yig‘ilgan siydik (ml), t — yig‘ish vaqti (soat) [1, 42-bet; '
            '2, 100-bet].',
        'ru':
            'Центрифугируют мочу, выделенную за 12 минут: Q = v ÷ (t × 5), '
            'v — собранная моча (мл), t — время сбора (ч) [1, с. 42; 2, с. 100].',
        'en':
            'Centrifuge the urine passed in 12 minutes: Q = v ÷ (t × 5), v — '
            'urine collected (ml), t — collection time (h) [1, p. 42; '
            '2, p. 100].',
      }),
      LocalizedText({
        'uz':
            'x (1 µL cho‘kmada) = A ÷ V. Sutkada = x × cho‘kma hajmi (µL) × '
            '5 × 24: 0,5 ml cho‘kmada x × 60 000, 1 ml da x × 120 000 '
            '[1, 43-bet; 2, 100-bet].',
        'ru':
            'x (в 1 мкл осадка) = A ÷ V. За сутки = x × объём осадка (мкл) × '
            '5 × 24: при 0,5 мл осадка x × 60 000, при 1 мл — x × 120 000 '
            '[1, с. 43; 2, с. 100].',
        'en':
            'x (per 1 µL of sediment) = A ÷ V. Per day = x × sediment volume '
            '(µL) × 5 × 24: x × 60,000 for 0.5 ml of sediment, x × 120,000 '
            'for 1 ml [1, p. 43; 2, p. 100].',
      }),
    ],
    limitations: [
      LocalizedText({
        'uz':
            'MDH klassik usuli: xalqaro (JSST) qo‘llanmalarda yo‘q, formula '
            'darsliklardan olingan.',
        'ru':
            'Классический метод школы СССР: в международных (ВОЗ) руководствах '
            'его нет, формула взята из учебников.',
        'en':
            'A classic Soviet-school method: not in international (WHO) '
            'guidance; the formula comes from textbooks.',
      }),
      LocalizedText({
        'uz':
            'Siydik 10–12 soat (odatda tunda) yig‘iladi; uzoq yig‘ish va saqlash '
            'paytida hujayralar qisman lizlanishi mumkin — shu sababli '
            'Nechiporenko usuli bitta porsiyada sanaydi [1, 43-bet].',
        'ru':
            'Мочу собирают 10–12 часов (обычно ночью); за долгий сбор и '
            'хранение клетки могут частично лизироваться — поэтому метод '
            'Нечипоренко считает в разовой порции [1, с. 43].',
        'en':
            'Urine is collected for 10–12 hours (usually overnight); during '
            'the long collection and storage cells may partly lyse — which is '
            'why the Nechiporenko method counts a single void [1, p. 43].',
      }),
    ],
    refs: [
      CalcRef(CalcSources.lyubina1984, 'Метод Каковского — Аддиса, pp. 42–43'),
      CalcRef(CalcSources.aripova2007, '10.6 Kakovskiy–Addis usuli, p. 100'),
    ],
  ),
  ManualCalc.zimnitsky: CalcInfo(
    formula: [
      LocalizedText({
        'uz':
            'Odatdagi suv va ovqat rejimida 06:00 da qovuq bo‘shatiladi, so‘ng '
            'har 3 soatda alohida idishga — jami 8 porsiya. 1–4-porsiyalar '
            'kunduzgi, 5–8 — tungi diurez; yig‘indisi — sutkalik diurez '
            '[1, 16-bet; 2, 98-bet].',
        'ru':
            'При обычном водно-пищевом режиме в 6:00 опорожняют мочевой '
            'пузырь, затем каждые 3 часа собирают мочу в отдельную ёмкость — '
            'всего 8 порций. Порции 1–4 — дневной, 5–8 — ночной диурез; сумма '
            '— суточный диурез [1, с. 16; 2, с. 98].',
        'en':
            'On the usual diet and fluids the bladder is emptied at 06:00, '
            'then urine is collected every 3 hours into separate containers — '
            '8 portions. Portions 1–4 are daytime, 5–8 night-time diuresis; '
            'their sum is the 24-hour diuresis [1, p. 16; 2, p. 98].',
      }),
      LocalizedText({
        'uz':
            'Har porsiyada hajm va nisbiy zichlik o‘lchanadi. Zichlik '
            'amplitudasi = eng yuqori − eng past zichlik; sutkalik diurez '
            'ichilgan suyuqlikka foiz sifatida ham hisoblanadi.',
        'ru':
            'В каждой порции измеряют объём и относительную плотность. '
            'Амплитуда плотности = максимальная − минимальная; суточный '
            'диурез считают и в процентах от выпитой жидкости.',
        'en':
            'Volume and specific gravity are measured in each portion. '
            'Specific-gravity amplitude = highest − lowest; the 24-hour '
            'diuresis is also expressed as a percentage of fluid drunk.',
      }),
    ],
    limitations: [
      LocalizedText({
        'uz':
            'MDH klassik usuli. Natija rang bilan baholanmaydi — talqinni '
            'shifokor laboratoriya blankasi va klinik holat bilan qiladi.',
        'ru':
            'Классический метод школы СССР. Результат не окрашивается — '
            'интерпретирует врач по бланку лаборатории и клинике.',
        'en':
            'A classic Soviet-school method. The result is not colour-coded — '
            'the doctor interprets it with the laboratory form and the '
            'clinical picture.',
      }),
      LocalizedText({
        'uz':
            'Zichlikni “1,015” yoki “1015” ko‘rinishida kiriting. Siydik '
            'bo‘lmagan porsiyaga hajm 0 yoziladi, zichlik bo‘sh qoladi.',
        'ru':
            'Плотность вводите как «1,015» или «1015». Для порции без мочи '
            'укажите объём 0, плотность оставьте пустой.',
        'en':
            'Enter specific gravity as “1.015” or “1015”. For a portion with no '
            'urine enter volume 0 and leave the gravity empty.',
      }),
    ],
    refs: [
      CalcRef(CalcSources.lyubina1984, '§ 2. Проба Зимницкого, pp. 16–17'),
      CalcRef(CalcSources.aripova2007, '10.4 Zimnitskiy usuli, pp. 98–99'),
      CalcRef(
        CalcSources.sobirova2006,
        'XVIII bob — Buyrak biokimyosi va siydik',
      ),
    ],
  ),
};

/// Klassik darslik oraliqlari — **referens interval**, diagnostik chegara
/// emas; laboratoriya blankasi asosiy. Natija ular bilan rangda
/// solishtirilmaydi.
class ClassicRange {
  /// [ref] lokatori — sahifa raqami (ekranda “44-bet” / “p. 44”).
  const ClassicRange(this.label, this.value, this.ref);
  final LocalizedText label;
  final LocalizedText value;
  final CalcRef ref;
}

const _lyuN = CalcRef(CalcSources.lyubina1984, '44');
const _ariN = CalcRef(CalcSources.aripova2007, '99');
const _lyuA = CalcRef(CalcSources.lyubina1984, '43');
const _ariA = CalcRef(CalcSources.aripova2007, '100');
const _lyuZ = CalcRef(CalcSources.lyubina1984, '16–17');
const _ariZ = CalcRef(CalcSources.aripova2007, '98–99');

const Map<ManualCalc, List<ClassicRange>> classicRanges = {
  ManualCalc.nechiporenko: [
    ClassicRange(
      LocalizedText({
        'uz': 'Lyubina 1984 (1 ml siydikda)',
        'ru': 'Любина 1984 (в 1 мл мочи)',
        'en': 'Lyubina 1984 (per 1 ml of urine)',
      }),
      LocalizedText({
        'uz': 'leykotsitlar 2000 gacha, eritrotsitlar 1000 gacha, silindrlar yo‘q',
        'ru': 'лейкоциты до 2000, эритроциты до 1000, цилиндры отсутствуют',
        'en': 'leukocytes up to 2,000, erythrocytes up to 1,000, no casts',
      }),
      _lyuN,
    ),
    ClassicRange(
      LocalizedText({
        'uz': 'Aripova 2007 (1 ml siydikda; kitobda “1 litrda”)',
        'ru': 'Арипова 2007 (в 1 мл мочи; в книге «в 1 литре»)',
        'en': 'Aripova 2007 (per 1 ml; the book says “per litre”)',
      }),
      LocalizedText({
        'uz': 'leykotsitlar 4000, eritrotsitlar 1000, silindrlar uchramaydi',
        'ru': 'лейкоциты 4000, эритроциты 1000, цилиндры не встречаются',
        'en': 'leukocytes 4,000, erythrocytes 1,000, casts absent',
      }),
      _ariN,
    ),
  ],
  ManualCalc.addis: [
    ClassicRange(
      LocalizedText({
        'uz': 'Lyubina 1984; Aripova 2007 (sutkada)',
        'ru': 'Любина 1984; Арипова 2007 (за сутки)',
        'en': 'Lyubina 1984; Aripova 2007 (per day)',
      }),
      LocalizedText({
        'uz':
            'leykotsitlar 2 000 000 gacha, eritrotsitlar 1 000 000 gacha, '
            'silindrlar 20 000 gacha',
        'ru':
            'лейкоциты до 2 000 000, эритроциты до 1 000 000, цилиндры до '
            '20 000',
        'en':
            'leukocytes up to 2,000,000, erythrocytes up to 1,000,000, casts '
            'up to 20,000',
      }),
      _lyuA,
    ),
    ClassicRange(
      LocalizedText({
        'uz': 'Aripova 2007',
        'ru': 'Арипова 2007',
        'en': 'Aripova 2007',
      }),
      LocalizedText({
        'uz': 'xuddi shu oraliqlar',
        'ru': 'те же интервалы',
        'en': 'the same intervals',
      }),
      _ariA,
    ),
  ],
  ManualCalc.zimnitsky: [
    ClassicRange(
      LocalizedText({
        'uz': 'Sutkalik diurez',
        'ru': 'Суточный диурез',
        'en': '24-hour diuresis',
      }),
      LocalizedText({
        'uz': 'ichilgan suyuqlikning 60–80 foizi; kunduzgi tungidan ko‘p',
        'ru': '60–80% выпитой жидкости; дневной больше ночного',
        'en': '60–80% of fluid drunk; daytime exceeds night-time',
      }),
      _lyuZ,
    ),
    ClassicRange(
      LocalizedText({
        'uz': 'Alohida porsiyalar',
        'ru': 'Отдельные порции',
        'en': 'Single portions',
      }),
      LocalizedText({
        'uz': 'hajm 40–300 ml, nisbiy zichlik 1,008–1,024',
        'ru': 'объём 40–300 мл, относительная плотность 1,008–1,024',
        'en': 'volume 40–300 ml, specific gravity 1.008–1.024',
      }),
      _ariZ,
    ),
    ClassicRange(
      LocalizedText({
        'uz': 'Izostenuriya (atama)',
        'ru': 'Изостенурия (термин)',
        'en': 'Isosthenuria (term)',
      }),
      LocalizedText({
        'uz': 'zichlik kun bo‘yi 1,010–1,011 atrofida, deyarli o‘zgarmaydi',
        'ru': 'плотность весь день около 1,010–1,011, почти не меняется',
        'en': 'gravity stays around 1.010–1.011 all day, barely changing',
      }),
      _lyuZ,
    ),
  ],
};
