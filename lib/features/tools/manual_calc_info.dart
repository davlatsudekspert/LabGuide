/// Qo'lda usullar kalkulyatorlarining formulasi, cheklovlari va manbalari
/// (3 tilda). Manbalar — `CalcSources` (calc_info.dart); har da'vo manba
/// matnidan tekshirilgan, manbada yo'q narsa yozilmaydi.
library;

import '../content/content_model.dart';
import 'calc_info.dart';

enum ManualCalc { chamber, differential, reticulocytes, light, colourIndex }

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
};
