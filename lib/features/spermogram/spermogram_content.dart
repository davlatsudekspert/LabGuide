/// Spermogramma bo'limi matnlari (3 tilda) va manbalari.
///
/// Har bir raqam va da'vo shu sessiyada birlamchi manbadan tekshirilgan:
/// JSST 2021 qo'llanmasi (6-nashr) PDF'i, JSST 2010 (5-nashr) — atamalar
/// jadvali, EAU qo'llanmasi. Manbada yo'q raqam yozilmaydi; lokatorda
/// bo'lim va sahifa. Kontent mutaxassis tekshiruvidan o'tmagan — "draft".
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';
import 'spermogram_logic.dart';

typedef _T = LocalizedText;

abstract final class SpermSources {
  static const who2021 = CalcSource(
    id: 'sperm-who-2021',
    citation:
        'World Health Organization. WHO laboratory manual for the '
        'examination and processing of human semen, 6th ed. Geneva: WHO; '
        '2021. ISBN 978-92-4-003078-7',
    url: 'https://www.who.int/publications/i/item/9789240030787',
  );
  static const who2010 = CalcSource(
    id: 'sperm-who-2010',
    citation:
        'World Health Organization. WHO laboratory manual for the '
        'examination and processing of human semen, 5th ed. Geneva: WHO; 2010',
    url: 'https://iris.who.int/handle/10665/44261',
  );
  static const eau = CalcSource(
    id: 'sperm-eau-male-infertility',
    citation:
        'European Association of Urology. EAU Guidelines on Sexual and '
        'Reproductive Health — Male Infertility',
    url: 'https://uroweb.org/guidelines/sexual-and-reproductive-health/chapter/male-infertility',
  );

  static const all = [who2021, who2010, eau];
}

// Tez-tez ishlatiladigan lokatorlar.
const refTable83 = CalcRef(SpermSources.who2021, 'Table 8.3, p. 213');
const refNotThreshold = CalcRef(SpermSources.who2021, '§8.1.3, p. 214');
const refPopulation = CalcRef(SpermSources.who2021, '§8.1.1, p. 211–212');
const refMultiparam = CalcRef(SpermSources.who2021, '§8.1.2.1, p. 213');
const refPh = CalcRef(SpermSources.who2021, '§2.4.2.5, p. 17–18');
const refPhCbavd = CalcRef(SpermSources.who2021, '§2.5.4, p. 65');
const refMotility = CalcRef(SpermSources.who2021, '§2.4.6, p. 23–24');
const refMotilityGrades = CalcRef(SpermSources.who2021, '§2.4.6.1, p. 24');
const refMotilityCalc = CalcRef(SpermSources.who2021, '§2.4.6.2, p. 25');
const refVitality = CalcRef(SpermSources.who2021, '§2.4.7, p. 26');
const refTotalNumber = CalcRef(SpermSources.who2021, '§2.4.8.7, p. 35');
const refAzoo = CalcRef(SpermSources.who2021, '§2.4.8.8, p. 35');
const refMorph = CalcRef(SpermSources.who2021, '§2.4.9.6, p. 51–54');
const refTzi = CalcRef(SpermSources.who2021, '§2.5.17.2, p. 80–81');
const refPatient = CalcRef(SpermSources.who2021, '§2.3.1, p. 13–14');
const refCollection = CalcRef(SpermSources.who2021, '§2.3.2, p. 14–15');
const refTerms2010 = CalcRef(
  SpermSources.who2010,
  'Appendix 1, §A1.2 and Table A1.3, p. 225–226',
);
const refEau = CalcRef(SpermSources.eau, '§11.3.2, Table 11.2');

/// Interfeys matnlari.
abstract final class SpermL {
  static const subtitle = _T({
    'uz': 'JSST 2021 qo‘llanmasi asosida',
    'ru': 'По руководству ВОЗ 2021',
    'en': 'Based on the WHO 2021 manual',
  });
  static const draftNote = _T({
    'uz':
        'Qoralama: matn JSST qo‘llanmasi (6-nashr, 2021) bilan solishtirilgan, '
        'lekin mutaxassis tekshiruvidan hali o‘tmagan. Natijani shifokor '
        'baholaydi.',
    'ru':
        'Черновик: текст сверен с руководством ВОЗ (6-е изд., 2021), но ещё '
        'не прошёл экспертную проверку. Результат оценивает врач.',
    'en':
        'Draft: checked against the WHO manual (6th ed., 2021) but not yet '
        'reviewed by an expert. Results are interpreted by a clinician.',
  });

  // Hub qatorlari.
  static const limitsTitle = _T({
    'uz': 'Asosiy ko‘rsatkichlar',
    'ru': 'Основные показатели',
    'en': 'Key parameters',
  });
  static const limitsSub = _T({
    'uz': 'JSST 2021 pastki referens chegaralari, 95% IO',
    'ru': 'Нижние референтные пределы ВОЗ 2021, 95% ДИ',
    'en': 'WHO 2021 lower reference limits, 95% CI',
  });
  static const counterTitle = _T({
    'uz': 'Sanash hisoblagichi',
    'ru': 'Счётчик',
    'en': 'Counter',
  });
  static const counterSub = _T({
    'uz': 'Harakatchanlik (a, b, c, d) va morfologiya',
    'ru': 'Подвижность (a, b, c, d) и морфология',
    'en': 'Motility (a, b, c, d) and morphology',
  });
  static const assessTitle = _T({
    'uz': 'Natijani baholash',
    'ru': 'Оценка результата',
    'en': 'Assess a result',
  });
  static const assessSub = _T({
    'uz': 'Qiymatlarni kiriting — JSST chegaralari bilan solishtiriladi',
    'ru': 'Введите значения — сравнение с пределами ВОЗ',
    'en': 'Enter values — compared with WHO limits',
  });
  static const termsTitle = _T({
    'uz': 'Atamalar',
    'ru': 'Термины',
    'en': 'Terms',
  });
  static const termsSub = _T({
    'uz': 'Oligo-, asteno-, terato-, azoospermiya va boshqalar',
    'ru': 'Олиго-, астено-, терато-, азооспермия и др.',
    'en': 'Oligo-, astheno-, terato-, azoospermia and more',
  });
  static const preTitle = _T({
    'uz': 'Preanalitika',
    'ru': 'Преаналитика',
    'en': 'Pre-analytics',
  });
  static const preSub = _T({
    'uz': 'Tiyilish, namuna olish, yetkazish vaqti va harorati',
    'ru': 'Воздержание, сбор, время и температура доставки',
    'en': 'Abstinence, collection, delivery time and temperature',
  });
  static const quizTitle = _T({
    'uz': 'Mashq',
    'ru': 'Тренировка',
    'en': 'Practice',
  });
  static const quizSub = _T({
    'uz': 'Tekshirilgan ma’lumotlar bo‘yicha savollar',
    'ru': 'Вопросы по проверенному материалу',
    'en': 'Questions on the verified material',
  });
  static const quizIntro = _T({
    'uz':
        'Chegaralar, harakatchanlik toifalari, atamalar va preanalitika '
        'bo‘yicha savollar. Har javobdan keyin izoh ochiladi.',
    'ru':
        'Вопросы о референтных пределах, категориях подвижности, терминах и '
        'преаналитике. После каждого ответа открывается пояснение.',
    'en':
        'Questions on reference limits, motility grades, terms and '
        'pre-analytics. An explanation opens after each answer.',
  });
  static const quizStart = _T({
    'uz': 'Boshlash',
    'ru': 'Начать',
    'en': 'Start',
  });

  // Ko'rsatkichlar sahifasi.
  static const limitsIntro = _T({
    'uz':
        'JSST 2021: tabiiy yo‘l bilan 12 oy ichida homiladorlik boshlangan '
        'juftliklardagi erkaklar natijalarining taqsimoti (12 mamlakat, '
        'taxminan 3500 erkak). Pastki chegara — 5-persentil: bu populyatsiyadagi '
        'erkaklarning faqat 5% ida natija undan past bo‘lgan.',
    'ru':
        'ВОЗ 2021: распределение результатов мужчин из пар с наступлением '
        'естественной беременности в течение 12 месяцев (12 стран, около 3500 '
        'мужчин). Нижний предел — 5-й процентиль: ниже него оказались '
        'результаты лишь 5% мужчин этой популяции.',
    'en':
        'WHO 2021: distribution of results from men in couples with a natural '
        'conception within 12 months (12 countries, about 3500 men). The lower '
        'limit is the 5th percentile: only 5% of men in this population had '
        'results below it.',
  });
  static const colParam = _T({
    'uz': 'Ko‘rsatkich',
    'ru': 'Показатель',
    'en': 'Parameter',
  });
  static const colLower = _T({
    'uz': 'Pastki chegara (95% IO)',
    'ru': 'Нижний предел (95% ДИ)',
    'en': 'Lower limit (95% CI)',
  });
  static const colMedian = _T({
    'uz': 'Mediana',
    'ru': 'Медиана',
    'en': 'Median',
  });
  static const notThreshold = _T({
    'uz':
        'Muhim: pastki 5-persentil fertil va infertil erkaklarni ajratuvchi '
        'chegara emas. Fertil va infertil erkaklar natijalari sezilarli '
        'darajada ustma-ust tushadi.',
    'ru':
        'Важно: нижний 5-й процентиль не является границей между фертильными '
        'и бесплодными мужчинами. Результаты фертильных и бесплодных мужчин '
        'существенно перекрываются.',
    'en':
        'Important: the lower 5th percentile is not a limit between fertile '
        'and infertile men. Results of fertile and infertile men overlap '
        'substantially.',
  });
  static const multiparam = _T({
    'uz':
        'JSST bir nechta ko‘rsatkichni birga talqin qilishni taklif qiladi, '
        'ammo bunday birlashgan chegaralar hali ishlab chiqilmagan.',
    'ru':
        'ВОЗ предлагает многопараметрическую интерпретацию, но объединённые '
        'референтные пределы для неё ещё не разработаны.',
    'en':
        'WHO suggests a multiparametric interpretation, but combined '
        'reference limits for it have yet to be developed.',
  });
  static const phTitle = _T({
    'uz': 'pH haqida',
    'ru': 'О pH',
    'en': 'About pH',
  });
  static const phNote = _T({
    'uz':
        'pH Table 8.3 da persentil sifatida berilmagan. JSST 2021: pH 7,2 '
        'dan past bo‘lsa, urug‘ pufakchalarining ishqoriy suyuqligi '
        'yetishmasligini ko‘rsatishi mumkin; siydik aralashgani ham sabab '
        'bo‘lishi mumkin. pH bir xil vaqtda, afzali 30 daqiqada, har holda '
        '1 soat ichida o‘lchanadi. Spermatozoidsiz eyakulyatda pH 7,0 dan '
        'past bo‘lsa — urug‘ yo‘llarining tug‘ma ikki tomonlama yo‘qligi '
        'ehtimoli. EAU jadvalida pH > 7,2 — "konsensus chegara".',
    'ru':
        'pH не приводится в Table 8.3 как процентиль. ВОЗ 2021: pH ниже 7,2 '
        'может указывать на недостаток щелочного секрета семенных пузырьков; '
        'причиной может быть и примесь мочи. pH измеряют в одно и то же '
        'время, желательно через 30 минут, но в любом случае в течение 1 часа. '
        'pH ниже 7,0 в эякуляте без сперматозоидов — возможно врождённое '
        'двустороннее отсутствие семявыносящих протоков. В таблице EAU '
        'pH > 7,2 — «консенсусное пороговое значение».',
    'en':
        'pH is not given as a percentile in Table 8.3. WHO 2021: a pH below '
        '7.2 may indicate a lack of alkaline seminal vesicular fluid; it can '
        'also be due to urine contamination. Measure at a uniform time, '
        'preferably at 30 minutes, in any case within 1 hour. A pH below 7.0 '
        'in an ejaculate without spermatozoa may point to congenital bilateral '
        'absence of the vas deferens. The EAU table lists pH > 7.2 as a '
        '"consensus threshold value".',
  });
  static const totalNote = _T({
    'uz':
        'Umumiy son = konsentratsiya × eyakulyat hajmi. JSST bo‘yicha u '
        'moyak faoliyatini konsentratsiyadan yaxshiroq aks ettiradi, shuning '
        'uchun hajm aniq o‘lchanishi kerak.',
    'ru':
        'Общее число = концентрация × объём эякулята. По ВОЗ оно лучше '
        'отражает продукцию сперматозоидов яичками, чем концентрация, поэтому '
        'объём нужно измерять точно.',
    'en':
        'Total number = concentration × ejaculate volume. WHO considers it a '
        'better measure of testicular sperm production than concentration, '
        'so volume must be measured accurately.',
  });

  // Hisoblagich.
  static const tabMotility = _T({
    'uz': 'Harakatchanlik',
    'ru': 'Подвижность',
    'en': 'Motility',
  });
  static const tabMorph = _T({
    'uz': 'Morfologiya',
    'ru': 'Морфология',
    'en': 'Morphology',
  });
  static const targetLabel = _T({'uz': 'Maqsad', 'ru': 'Цель', 'en': 'Target'});
  static const motilityHow = _T({
    'uz':
        'JSST: har bir takrorda taxminan 200 ta spermatozoid sanaladi; har '
        'takror — alohida yangi nam preparat. Avval tez va sekin progressiv, '
        'so‘ng shu maydondagi noprogressiv va harakatsizlar sanaladi. 200 ga '
        'yetganda maydondagi barcha toifalar sanalmagan bo‘lsa, sanash davom '
        'ettiriladi. 100 — faqat mashq uchun.',
    'ru':
        'ВОЗ: в каждом повторе оценивают около 200 сперматозоидов; каждый '
        'повтор — отдельный свежий нативный препарат. Сначала считают быстро '
        'и медленно прогрессивные, затем в том же участке — непрогрессивные и '
        'неподвижные. Если 200 набрано раньше, чем подсчитаны все категории '
        'участка, подсчёт продолжают. 100 — только для тренировки.',
    'en':
        'WHO: assess about 200 spermatozoa per replicate; each replicate is a '
        'separate, fresh wet preparation. Count rapid and slow progressive '
        'first, then non-progressive and immotile in the same area. If 200 is '
        'reached before all categories of the area are scored, keep counting. '
        '100 is for practice only.',
  });
  static const targetReached = _T({
    'uz':
        'Maqsadga yetildi. Joriy maydonning barcha toifalarini sanab '
        'tugating; keyin ikkinchi takror bilan solishtiring (JSST Table 2.2).',
    'ru':
        'Цель достигнута. Досчитайте все категории текущего участка; затем '
        'сравните со вторым повтором (ВОЗ, Table 2.2).',
    'en':
        'Target reached. Finish scoring all categories in the current area, '
        'then compare with the second replicate (WHO Table 2.2).',
  });
  static const undo = _T({
    'uz': 'Bekor qilish',
    'ru': 'Отменить',
    'en': 'Undo',
  });
  static const reset = _T({'uz': 'Qaytadan', 'ru': 'Сбросить', 'en': 'Reset'});
  static const counted = _T({
    'uz': 'Sanaldi',
    'ru': 'Подсчитано',
    'en': 'Counted',
  });
  static const progressive = _T({
    'uz': 'Progressiv harakat (PR = a + b)',
    'ru': 'Прогрессивная подвижность (PR = a + b)',
    'en': 'Progressive motility (PR = a + b)',
  });
  static const totalMotility = _T({
    'uz': 'Umumiy harakatchanlik (PR + NP)',
    'ru': 'Общая подвижность (PR + NP)',
    'en': 'Total motility (PR + NP)',
  });
  static const whoLower = _T({
    'uz': 'JSST pastki chegarasi',
    'ru': 'Нижний предел ВОЗ',
    'en': 'WHO lower limit',
  });
  static const roundingNote = _T({
    'uz':
        'Foizlar butun songa yaxlitlanadi; faqat yig‘indi 99 yoki 101 bo‘lsa, '
        'ustun guruh tuzatiladi (JSST qoidasi). Bir nechta x,5 qiymat '
        'yaxlitlanib yig‘indi boshqacha chiqsa, tuzatilmaydi — o‘nli qiymatlar '
        'ko‘rsatiladi.',
    'ru':
        'Проценты округляются до целых; только если сумма 99 или 101, '
        'корректируется доминирующая группа (правило ВОЗ). Если из-за '
        'округления нескольких значений x,5 сумма иная, коррекции нет — '
        'показаны значения с десятыми.',
    'en':
        'Percentages are rounded to whole numbers; only if the sum is 99 or '
        '101 is the dominant group adjusted (WHO rule). If rounding several '
        'x.5 values gives another sum, nothing is adjusted — values with one '
        'decimal are shown.',
  });
  static const morphHow = _T({
    'uz':
        'Har spermatozoid bir marta sanaladi. Normal bo‘lsa — "Normal". '
        'Anormal bo‘lsa — avval barcha nuqsonlarini belgilang, so‘ng '
        '"Anormal" ni bosing. JSST: kamida 200 ta spermatozoid baholanadi.',
    'ru':
        'Каждый сперматозоид считается один раз. Нормальный — «Норма». '
        'Аномальный — сначала отметьте все его дефекты, затем нажмите '
        '«Аномальный». ВОЗ: оценивают не менее 200 сперматозоидов.',
    'en':
        'Each spermatozoon is counted once. Normal — tap "Normal". Abnormal — '
        'first mark all its defects, then tap "Abnormal". WHO: evaluate at '
        'least 200 spermatozoa.',
  });
  static const normal = _T({'uz': 'Normal', 'ru': 'Норма', 'en': 'Normal'});
  static const abnormal = _T({
    'uz': 'Anormal',
    'ru': 'Аномальный',
    'en': 'Abnormal',
  });
  static const pickDefect = _T({
    'uz': 'Avval kamida bitta nuqsonni belgilang.',
    'ru': 'Сначала отметьте хотя бы один дефект.',
    'en': 'Mark at least one defect first.',
  });
  static const normalForms = _T({
    'uz': 'Normal shakllar',
    'ru': 'Нормальные формы',
    'en': 'Normal forms',
  });
  static const defectsTitle = _T({
    'uz': 'Nuqsonli spermatozoidlar (barcha sanalganlardan)',
    'ru': 'Сперматозоиды с дефектом (от всех подсчитанных)',
    'en': 'Spermatozoa with a defect (of all counted)',
  });
  static const defectsNote = _T({
    'uz':
        'Bir hujayrada bir necha nuqson bo‘lishi mumkin, shuning uchun '
        'nuqsonlar foizlari yig‘indisi 100 dan oshishi mumkin.',
    'ru':
        'У одной клетки может быть несколько дефектов, поэтому сумма '
        'процентов дефектов может превышать 100.',
    'en':
        'One cell can have several defects, so the defect percentages can '
        'add up to more than 100.',
  });
  static const tzi = _T({
    'uz': 'Teratozoospermiya indeksi (TZI)',
    'ru': 'Индекс тератозооспермии (TZI)',
    'en': 'Teratozoospermia index (TZI)',
  });
  static const tziNote = _T({
    'uz': 'TZI = nuqsonlar soni ÷ anormal spermatozoidlar soni.',
    'ru': 'TZI = число дефектов ÷ число аномальных сперматозоидов.',
    'en': 'TZI = number of defects ÷ number of abnormal spermatozoa.',
  });

  // Baholash.
  static const assessIntro = _T({
    'uz':
        'Laboratoriya natijalarini kiriting (bo‘sh maydon hisobga '
        'olinmaydi). Umumiy son hajm × konsentratsiyadan hisoblanadi.',
    'ru':
        'Введите результаты анализа (пустые поля не учитываются). Общее '
        'число рассчитывается как объём × концентрация.',
    'en':
        'Enter the lab results (empty fields are ignored). The total number '
        'is calculated as volume × concentration.',
  });
  static const invalid = _T({
    'uz': 'Son kiriting (0 yoki undan katta).',
    'ru': 'Введите число (0 или больше).',
    'en': 'Enter a number (0 or more).',
  });
  static const invalidPercent = _T({
    'uz': '0 dan 100 gacha son kiriting.',
    'ru': 'Введите число от 0 до 100.',
    'en': 'Enter a number from 0 to 100.',
  });
  static const invalidPh = _T({
    'uz': '0 dan 14 gacha son kiriting.',
    'ru': 'Введите число от 0 до 14.',
    'en': 'Enter a number from 0 to 14.',
  });
  static const errProgressive = _T({
    'uz':
        'Progressiv harakat umumiy harakatchanlikdan katta bo‘lishi mumkin '
        'emas (PR umumiy harakatchanlikning bir qismi).',
    'ru':
        'Прогрессивная подвижность не может быть больше общей (PR — часть '
        'общей подвижности).',
    'en':
        'Progressive motility cannot exceed total motility (PR is part of '
        'total motility).',
  });
  static const phOptional = _T({
    'uz': 'pH (ixtiyoriy)',
    'ru': 'pH (необязательно)',
    'en': 'pH (optional)',
  });
  static const resultTitle = _T({
    'uz': 'Natija',
    'ru': 'Результат',
    'en': 'Result',
  });
  static const emptyHint = _T({
    'uz': 'Natija uchun kamida bitta qiymat kiriting.',
    'ru': 'Введите хотя бы одно значение.',
    'en': 'Enter at least one value.',
  });
  static const calculatedTotal = _T({
    'uz': 'Umumiy son (hisoblangan)',
    'ru': 'Общее число (рассчитано)',
    'en': 'Total number (calculated)',
  });
  static const belowTitle = _T({
    'uz': 'JSST 2021 pastki chegarasidan past',
    'ru': 'Ниже нижнего предела ВОЗ 2021',
    'en': 'Below the WHO 2021 lower limit',
  });
  static const allAbove = _T({
    'uz':
        'Kiritilgan barcha qiymatlar JSST 2021 pastki chegaralaridan past '
        'emas.',
    'ru': 'Все введённые значения не ниже нижних пределов ВОЗ 2021.',
    'en': 'All entered values are at or above the WHO 2021 lower limits.',
  });
  static const mayPoint = _T({
    'uz': 'Ko‘rsatishi mumkin (tashxis emas)',
    'ru': 'Может указывать на (не диагноз)',
    'en': 'May point to (not a diagnosis)',
  });
  static const basisTotal = _T({
    'uz': 'Oligozoospermiya umumiy son bo‘yicha baholandi (afzal ko‘rsatkich).',
    'ru': 'Олигозооспермия оценена по общему числу (предпочтительный показатель).',
    'en': 'Oligozoospermia was assessed by total number (preferred).',
  });
  static const basisConc = _T({
    'uz':
        'Hajm kiritilmagan — oligozoospermiya konsentratsiya bo‘yicha '
        'baholandi. Umumiy son afzalroq.',
    'ru':
        'Объём не введён — олигозооспермия оценена по концентрации. Общее '
        'число предпочтительнее.',
    'en':
        'Volume not entered — oligozoospermia was assessed by concentration. '
        'Total number is preferred.',
  });
  static const necroNote = _T({
    'uz':
        'Nekrozoospermiya ta’rifi: tirik spermatozoidlar ulushi past VA '
        'harakatsizlar ulushi yuqori. Bu yerda “yuqori” — umumiy '
        'harakatchanlik pastki chegaradan (42 %) past, ya’ni harakatsizlar '
        '58 % dan ko‘p; faqat tiriklik past bo‘lsa, atama qo‘llanmaydi.',
    'ru':
        'Определение некрозооспермии: низкая доля живых И высокая доля '
        'неподвижных сперматозоидов. Здесь «высокая» — общая подвижность ниже '
        'нижнего предела (42 %), то есть неподвижных больше 58 %; при одной '
        'лишь низкой жизнеспособности термин не применяется.',
    'en':
        'Necrozoospermia means a low percentage of live AND a high percentage '
        'of immotile spermatozoa. Here “high” means total motility below its '
        'lower limit (42 %), i.e. more than 58 % immotile; low vitality alone '
        'does not give the term.',
  });
  static const azooSuspected = _T({
    'uz': 'Azoospermiyaga shubha (sentrifugalangan cho‘kmada tasdiqlang)',
    'ru':
        'Подозрение на азооспермию (подтвердите в осадке после '
        'центрифугирования)',
    'en': 'Azoospermia suspected (confirm in a centrifuged sediment)',
  });
  static const azooSuspectedWhat = _T({
    'uz': 'Nam preparatlarda spermatozoid topilmadi.',
    'ru': 'В нативных препаратах сперматозоиды не найдены.',
    'en': 'No spermatozoa were seen in the wet preparations.',
  });
  static const azooNote = _T({
    'uz':
        'Nam preparatda spermatozoid ko‘rinmasa, azoospermiyaga faqat '
        'shubha qilinadi. JSST: "azoospermiya" atamasi faqat sentrifugalangan '
        'namuna cho‘kmasida ham spermatozoid topilmasa ishlatiladi; bu '
        'eyakulyat tavsifi, tashxis emas.',
    'ru':
        'Если в нативных препаратах сперматозоидов нет, азооспермию можно '
        'лишь подозревать. ВОЗ: термин «азооспермия» применяют, только если '
        'сперматозоиды не найдены и в осадке центрифугированного образца; это '
        'описание эякулята, а не диагноз.',
    'en':
        'If no spermatozoa are seen in wet preparations, azoospermia can only '
        'be suspected. WHO: the term azoospermia is used only if no '
        'spermatozoa are found in the sediment of a centrifuged sample; it '
        'describes the ejaculate and is not a diagnosis.',
  });
  static const lowPh = _T({
    'uz':
        'pH 7,2 dan past: urug‘ pufakchalari suyuqligi yetishmasligini yoki '
        'siydik aralashganini ko‘rsatishi mumkin (JSST 2021).',
    'ru':
        'pH ниже 7,2: может указывать на недостаток секрета семенных '
        'пузырьков или примесь мочи (ВОЗ 2021).',
    'en':
        'pH below 7.2: may indicate a lack of seminal vesicular fluid or '
        'urine contamination (WHO 2021).',
  });
  static const termsBasis = _T({
    'uz':
        'Atamalar JSST 2010 ta’riflari bo‘yicha, JSST 2021 chegaralariga '
        'nisbatan qo‘llandi: 6-nashr atamalar uchun alohida chegara bermaydi.',
    'ru':
        'Термины — по определениям ВОЗ 2010 относительно пределов ВОЗ 2021: '
        '6-е издание не задаёт отдельных порогов для терминов.',
    'en':
        'Terms follow the WHO 2010 definitions, applied to the WHO 2021 '
        'limits: the 6th edition gives no separate thresholds for terms.',
  });
  static const referNote = _T({
    'uz':
        'Natijani shifokor (androlog, urolog) baholaydi. EAU: JSST mezonlari '
        'bo‘yicha natija normal bo‘lsa, bitta tahlil yetarli; kamida ikki '
        'tahlilda o‘zgarish bo‘lsa — keyingi andrologik tekshiruv kerak.',
    'ru':
        'Результат оценивает врач (андролог, уролог). EAU: если анализ в '
        'норме по критериям ВОЗ, достаточно одного исследования; если '
        'отклонения выявлены как минимум в двух анализах, показано '
        'дальнейшее андрологическое обследование.',
    'en':
        'A clinician (andrologist, urologist) interprets the result. EAU: if '
        'the analysis is normal by WHO criteria, a single test is sufficient; '
        'if results are abnormal on at least two tests, further andrological '
        'investigation is indicated.',
  });

  // Atamalar sahifasi.
  static const termsIntro = _T({
    'uz':
        'Atamalar sifatni tavsiflaydi va biologik sababni bildirmaydi. '
        'Ta’riflar — JSST 2010 (5-nashr) jadvalidan. JSST 2021 bunday '
        'bo‘linish uchun chegara bermaydi; EAU uni amaliyotda foydali deb '
        'hisoblaydi.',
    'ru':
        'Термины описывают качество эякулята и не указывают на биологическую '
        'причину. Определения — из таблицы ВОЗ 2010 (5-е изд.). ВОЗ 2021 не '
        'приводит пороги для такого деления; EAU считает его клинически '
        'полезным.',
    'en':
        'The terms classify semen quality and do not imply a biological '
        'cause. Definitions are from the WHO 2010 (5th ed.) table. WHO 2021 '
        'gives no thresholds for this subdivision; EAU still considers it '
        'clinically useful.',
  });
  static const suffixNote = _T({
    'uz':
        '"-spermiya" qo‘shimchasi eyakulyatga, "-zoospermiya" — '
        'spermatozoidlarga tegishli. Shuning uchun "oligospermiya", '
        '"astenospermiya", "teratospermiya" kabi atamalar ishlatilmasligi '
        'kerak (JSST 2010).',
    'ru':
        'Суффикс «-спермия» относится к эякуляту, «-зооспермия» — к '
        'сперматозоидам. Поэтому термины «олигоспермия», «астеноспермия», '
        '«тератоспермия» использовать не следует (ВОЗ 2010).',
    'en':
        'The suffix "-spermia" refers to the ejaculate and "-zoospermia" to '
        'the spermatozoa, so terms such as oligospermia, asthenospermia and '
        'teratospermia should not be used (WHO 2010).',
  });
  static const gradesTitle = _T({
    'uz': 'Harakatchanlik toifalari (JSST 2021)',
    'ru': 'Категории подвижности (ВОЗ 2021)',
    'en': 'Motility grades (WHO 2021)',
  });
  static const gradesNote = _T({
    'uz':
        '6-nashrda to‘rt toifa (a, b, c, d) qaytarildi, chunki tez progressiv '
        'spermatozoidlar borligi yoki yo‘qligi klinik ahamiyatga ega.',
    'ru':
        'В 6-м издании возвращены четыре категории (a, b, c, d), так как '
        'наличие или отсутствие быстро прогрессивных сперматозоидов '
        'клинически важно.',
    'en':
        'The 6th edition reverted to four grades (a, b, c, d) because the '
        'presence or absence of rapid progressive spermatozoa is clinically '
        'important.',
  });
  static const morphTitle = _T({
    'uz': 'Morfologiya nuqsonlari sohalari',
    'ru': 'Области дефектов морфологии',
    'en': 'Morphology defect regions',
  });
}

/// Ko'rsatkich nomlari va birliklari.
const spermParamNames = <SpermParam, LocalizedText>{
  SpermParam.volume: _T({
    'uz': 'Eyakulyat hajmi',
    'ru': 'Объём эякулята',
    'en': 'Semen volume',
  }),
  SpermParam.concentration: _T({
    'uz': 'Spermatozoidlar konsentratsiyasi',
    'ru': 'Концентрация сперматозоидов',
    'en': 'Sperm concentration',
  }),
  SpermParam.totalNumber: _T({
    'uz': 'Spermatozoidlarning umumiy soni',
    'ru': 'Общее число сперматозоидов',
    'en': 'Total sperm number',
  }),
  SpermParam.totalMotility: _T({
    'uz': 'Umumiy harakatchanlik (PR + NP)',
    'ru': 'Общая подвижность (PR + NP)',
    'en': 'Total motility (PR + NP)',
  }),
  SpermParam.progressive: _T({
    'uz': 'Progressiv harakat (PR)',
    'ru': 'Прогрессивная подвижность (PR)',
    'en': 'Progressive motility (PR)',
  }),
  SpermParam.vitality: _T({
    'uz': 'Tiriklik (tirik spermatozoidlar)',
    'ru': 'Жизнеспособность (живые сперматозоиды)',
    'en': 'Vitality (live spermatozoa)',
  }),
  SpermParam.normalForms: _T({
    'uz': 'Normal shakllar',
    'ru': 'Нормальные формы',
    'en': 'Normal forms',
  }),
};

const spermParamUnits = <SpermParam, LocalizedText>{
  SpermParam.volume: _T({'uz': 'mL', 'ru': 'мл', 'en': 'mL'}),
  SpermParam.concentration: _T({
    'uz': '×10⁶/mL',
    'ru': '×10⁶/мл',
    'en': '×10⁶/mL',
  }),
  SpermParam.totalNumber: _T({
    'uz': '×10⁶ eyakulyatda',
    'ru': '×10⁶ в эякуляте',
    'en': '×10⁶ per ejaculate',
  }),
  SpermParam.totalMotility: _T({'uz': '%', 'ru': '%', 'en': '%'}),
  SpermParam.progressive: _T({'uz': '%', 'ru': '%', 'en': '%'}),
  SpermParam.vitality: _T({'uz': '%', 'ru': '%', 'en': '%'}),
  SpermParam.normalForms: _T({'uz': '%', 'ru': '%', 'en': '%'}),
};

/// Harakatchanlik toifalari: nom, tugma yozuvi, ta'rif (JSST 2021 §2.4.6.1).
class GradeInfo {
  const GradeInfo(this.letter, this.name, this.definition);
  final String letter;
  final LocalizedText name;
  final LocalizedText definition;
}

const motilityGrades = <MotilityGrade, GradeInfo>{
  MotilityGrade.rapid: GradeInfo(
    'a',
    _T({
      'uz': 'Tez progressiv',
      'ru': 'Быстрые прогрессивные',
      'en': 'Rapid progressive',
    }),
    _T({
      'uz':
          '≥ 25 µm/s: faol harakat, to‘g‘ri chiziq yoki katta aylana bo‘ylab; '
          '1 soniyada kamida 25 µm (yoki dum uzunligining ½) masofa.',
      'ru':
          '≥ 25 мкм/с: активное движение по прямой или по большому кругу; '
          'за 1 секунду не менее 25 мкм (или ½ длины хвоста).',
      'en':
          '≥ 25 µm/s: moving actively, linearly or in a large circle; at least '
          '25 µm (or ½ tail length) in one second.',
    }),
  ),
  MotilityGrade.slow: GradeInfo(
    'b',
    _T({
      'uz': 'Sekin progressiv',
      'ru': 'Медленные прогрессивные',
      'en': 'Slow progressive',
    }),
    _T({
      'uz':
          '5 dan < 25 µm/s gacha: faol harakat, 1 soniyada 5 dan < 25 µm '
          'gacha (kamida bitta bosh uzunligidan dumning ½ idan kamgacha).',
      'ru':
          'От 5 до < 25 мкм/с: активное движение, за 1 секунду от 5 до '
          '< 25 мкм (от одной длины головки до менее ½ длины хвоста).',
      'en':
          '5 to < 25 µm/s: moving actively, 5 to < 25 µm in one second (at '
          'least one head length to less than ½ tail length).',
    }),
  ),
  MotilityGrade.nonProgressive: GradeInfo(
    'c',
    _T({
      'uz': 'Noprogressiv',
      'ru': 'Непрогрессивные',
      'en': 'Non-progressive',
    }),
    _T({
      'uz':
          '< 5 µm/s: dum faol harakatlanadi, lekin oldinga siljish yo‘q — '
          'masalan, kichik aylanada suzish; bosh 5 µm (bitta bosh uzunligi) '
          'dan kam siljiydi.',
      'ru':
          '< 5 мкм/с: активные движения хвоста без продвижения — например, '
          'плавание по малому кругу; головка смещается менее чем на 5 мкм '
          '(одна длина головки).',
      'en':
          '< 5 µm/s: active tail movement without progression — e.g. '
          'swimming in small circles; the head moves less than 5 µm (one head '
          'length).',
    }),
  ),
  MotilityGrade.immotile: GradeInfo(
    'd',
    _T({'uz': 'Harakatsiz', 'ru': 'Неподвижные', 'en': 'Immotile'}),
    _T({
      'uz': 'Dumning faol harakati yo‘q.',
      'ru': 'Нет активных движений хвоста.',
      'en': 'No active tail movements.',
    }),
  ),
};

const morphDefectNames = <MorphDefect, LocalizedText>{
  MorphDefect.head: _T({
    'uz': 'Bosh (H)',
    'ru': 'Головка (H)',
    'en': 'Head (H)',
  }),
  MorphDefect.neckMidpiece: _T({
    'uz': 'Bo‘yin va o‘rta qism (NM)',
    'ru': 'Шейка и средняя часть (NM)',
    'en': 'Neck and midpiece (NM)',
  }),
  MorphDefect.tail: _T({'uz': 'Dum (T)', 'ru': 'Хвост (T)', 'en': 'Tail (T)'}),
  MorphDefect.cytoplasm: _T({
    'uz': 'Ortiqcha qoldiq sitoplazma (C)',
    'ru': 'Избыток остаточной цитоплазмы (C)',
    'en': 'Excess residual cytoplasm (C)',
  }),
};

/// Sitoplazma qoldig'i qachon nuqson (JSST 2021 §2.4.9.6).
const cytoplasmNote = _T({
  'uz':
      'Sitoplazma qoldig‘i normal bosh o‘lchamining uchdan biridan katta '
      'bo‘lsagina nuqson hisoblanadi.',
  'ru':
      'Остаточная цитоплазма считается дефектом, только если она больше '
      'трети размера нормальной головки.',
  'en':
      'Residual cytoplasm is an anomaly only when it exceeds one third of '
      'normal sperm head size.',
});

/// Atama: nom va ta'rif (JSST 2010 Table A1.3).
class SpermTermInfo {
  const SpermTermInfo(this.name, this.definition, {this.extra});
  final LocalizedText name;
  final LocalizedText definition;

  /// Qo'shimcha izoh (masalan, JSST 2021 dan).
  final LocalizedText? extra;
}

const spermTerms = <SpermTerm, SpermTermInfo>{
  SpermTerm.normozoospermia: SpermTermInfo(
    _T({
      'uz': 'Normozoospermiya',
      'ru': 'Нормозооспермия',
      'en': 'Normozoospermia',
    }),
    _T({
      'uz':
          'Spermatozoidlar umumiy soni (yoki konsentratsiyasi), progressiv '
          'harakatlanuvchi va morfologik normal spermatozoidlar ulushi pastki '
          'referens chegaraga teng yoki undan yuqori.',
      'ru':
          'Общее число (или концентрация) сперматозоидов, доля прогрессивно '
          'подвижных и морфологически нормальных сперматозоидов равны нижним '
          'референтным пределам или выше их.',
      'en':
          'Total number (or concentration) of spermatozoa, and percentages of '
          'progressively motile and morphologically normal spermatozoa, equal '
          'to or above the lower reference limits.',
    }),
  ),
  SpermTerm.oligozoospermia: SpermTermInfo(
    _T({
      'uz': 'Oligozoospermiya',
      'ru': 'Олигозооспермия',
      'en': 'Oligozoospermia',
    }),
    _T({
      'uz':
          'Spermatozoidlar umumiy soni (yoki konsentratsiyasi) pastki referens '
          'chegaradan past. Umumiy songa doim ustunlik beriladi.',
      'ru':
          'Общее число (или концентрация) сперматозоидов ниже нижнего '
          'референтного предела. Предпочтение всегда отдаётся общему числу.',
      'en':
          'Total number (or concentration) of spermatozoa below the lower '
          'reference limit. Total number always takes precedence.',
    }),
  ),
  SpermTerm.asthenozoospermia: SpermTermInfo(
    _T({
      'uz': 'Astenozoospermiya',
      'ru': 'Астенозооспермия',
      'en': 'Asthenozoospermia',
    }),
    _T({
      'uz':
          'Progressiv harakatlanuvchi (PR) spermatozoidlar ulushi pastki '
          'referens chegaradan past.',
      'ru':
          'Доля прогрессивно подвижных (PR) сперматозоидов ниже нижнего '
          'референтного предела.',
      'en':
          'Percentage of progressively motile (PR) spermatozoa below the lower '
          'reference limit.',
    }),
  ),
  SpermTerm.teratozoospermia: SpermTermInfo(
    _T({
      'uz': 'Teratozoospermiya',
      'ru': 'Тератозооспермия',
      'en': 'Teratozoospermia',
    }),
    _T({
      'uz':
          'Morfologik normal spermatozoidlar ulushi pastki referens chegaradan '
          'past.',
      'ru':
          'Доля морфологически нормальных сперматозоидов ниже нижнего '
          'референтного предела.',
      'en':
          'Percentage of morphologically normal spermatozoa below the lower '
          'reference limit.',
    }),
  ),
  SpermTerm.oligoasthenozoospermia: SpermTermInfo(
    _T({
      'uz': 'Oligoastenozoospermiya',
      'ru': 'Олигоастенозооспермия',
      'en': 'Oligoasthenozoospermia',
    }),
    _T({
      'uz':
          'Umumiy son (yoki konsentratsiya) va PR ulushi pastki chegaralardan '
          'past.',
      'ru': 'Общее число (или концентрация) и доля PR ниже нижних пределов.',
      'en':
          'Total number (or concentration) and percentage of PR spermatozoa '
          'below the lower reference limits.',
    }),
  ),
  SpermTerm.oligoteratozoospermia: SpermTermInfo(
    _T({
      'uz': 'Oligoteratozoospermiya',
      'ru': 'Олиготератозооспермия',
      'en': 'Oligoteratozoospermia',
    }),
    _T({
      'uz':
          'Umumiy son (yoki konsentratsiya) va normal shakllar ulushi pastki '
          'chegaralardan past.',
      'ru':
          'Общее число (или концентрация) и доля нормальных форм ниже нижних '
          'пределов.',
      'en':
          'Total number (or concentration) and percentage of normal forms '
          'below the lower reference limits.',
    }),
  ),
  SpermTerm.asthenoteratozoospermia: SpermTermInfo(
    _T({
      'uz': 'Astenoteratozoospermiya',
      'ru': 'Астенотератозооспермия',
      'en': 'Asthenoteratozoospermia',
    }),
    _T({
      'uz': 'PR va normal shakllar ulushi pastki chegaralardan past.',
      'ru': 'Доли PR и нормальных форм ниже нижних пределов.',
      'en':
          'Percentages of both PR and morphologically normal spermatozoa '
          'below the lower reference limits.',
    }),
  ),
  SpermTerm.oligoasthenoteratozoospermia: SpermTermInfo(
    _T({
      'uz': 'Oligoastenoteratozoospermiya',
      'ru': 'Олигоастенотератозооспермия',
      'en': 'Oligoasthenoteratozoospermia',
    }),
    _T({
      'uz':
          'Umumiy son (yoki konsentratsiya), PR va normal shakllar ulushi — '
          'uchalasi pastki chegaralardan past.',
      'ru':
          'Общее число (или концентрация), доли PR и нормальных форм — все '
          'три ниже нижних пределов.',
      'en':
          'Total number (or concentration), and percentages of both PR and '
          'normal forms, below the lower reference limits.',
    }),
  ),
  SpermTerm.azoospermia: SpermTermInfo(
    _T({'uz': 'Azoospermiya', 'ru': 'Азооспермия', 'en': 'Azoospermia'}),
    _T({
      'uz':
          'Eyakulyatda spermatozoid yo‘q (qo‘llangan usulning aniqlash '
          'chegarasi bo‘yicha).',
      'ru':
          'В эякуляте нет сперматозоидов (в пределах чувствительности '
          'применённого метода).',
      'en':
          'No spermatozoa in the ejaculate (given as the limit of '
          'quantification for the method used).',
    }),
    extra: SpermL.azooNote,
  ),
  SpermTerm.necrozoospermia: SpermTermInfo(
    _T({
      'uz': 'Nekrozoospermiya',
      'ru': 'Некрозооспермия',
      'en': 'Necrozoospermia',
    }),
    _T({
      'uz':
          'Eyakulyatda tirik spermatozoidlar ulushi past va harakatsizlar '
          'ulushi yuqori.',
      'ru':
          'Низкая доля живых и высокая доля неподвижных сперматозоидов в '
          'эякуляте.',
      'en':
          'Low percentage of live, and high percentage of immotile, '
          'spermatozoa in the ejaculate.',
    }),
  ),
};

/// Atamalar sahifasidagi qo'shimcha atamalar (baholashda ishlatilmaydi).
const spermExtraTerms = <SpermTermInfo>[
  SpermTermInfo(
    _T({'uz': 'Aspermiya', 'ru': 'Аспермия', 'en': 'Aspermia'}),
    _T({
      'uz': 'Eyakulyat yo‘q (eyakulyatsiya yo‘q yoki retrograd).',
      'ru': 'Нет эякулята (отсутствие эякуляции или ретроградная эякуляция).',
      'en': 'No semen (no or retrograde ejaculation).',
    }),
  ),
  SpermTermInfo(
    _T({
      'uz': 'Kriptozoospermiya',
      'ru': 'Криптозооспермия',
      'en': 'Cryptozoospermia',
    }),
    _T({
      'uz':
          'Yangi preparatlarda spermatozoid yo‘q, lekin sentrifugalangan '
          'cho‘kmada topiladi.',
      'ru':
          'В свежих препаратах сперматозоидов нет, но они обнаруживаются в '
          'осадке после центрифугирования.',
      'en':
          'Spermatozoa absent from fresh preparations but observed in a '
          'centrifuged pellet.',
    }),
  ),
  SpermTermInfo(
    _T({
      'uz': 'Gemospermiya (gematospermiya)',
      'ru': 'Гемоспермия (гематоспермия)',
      'en': 'Haemospermia (haematospermia)',
    }),
    _T({
      'uz': 'Eyakulyatda eritrotsitlar bor.',
      'ru': 'Наличие эритроцитов в эякуляте.',
      'en': 'Presence of erythrocytes in the ejaculate.',
    }),
  ),
  SpermTermInfo(
    _T({
      'uz': 'Leykospermiya (leykotsitospermiya, piospermiya)',
      'ru': 'Лейкоспермия (лейкоцитоспермия, пиоспермия)',
      'en': 'Leukospermia (leukocytospermia, pyospermia)',
    }),
    _T({
      'uz': 'Eyakulyatda leykotsitlar chegara qiymatdan ko‘p.',
      'ru': 'Лейкоциты в эякуляте выше порогового значения.',
      'en':
          'Presence of leukocytes in the ejaculate above the threshold value.',
    }),
  ),
];

/// Preanalitika qadamlari (JSST 2021 §2.3, §2.4).
class SpermStep {
  const SpermStep(this.title, this.body, this.ref);
  final LocalizedText title;
  final LocalizedText body;
  final CalcRef ref;
}

const spermPreSteps = <SpermStep>[
  SpermStep(
    _T({'uz': 'Ko‘rsatma', 'ru': 'Инструктаж', 'en': 'Instructions'}),
    _T({
      'uz':
          'Erkakka namuna olish bo‘yicha aniq yozma va og‘zaki ko‘rsatma '
          'beriladi; shifokor ham xuddi shu ma’lumotni beradi.',
      'ru':
          'Мужчине дают чёткие письменные и устные инструкции по сбору '
          'эякулята; врач даёт ту же информацию.',
      'en':
          'The man is given clear written and spoken instructions on '
          'collection; the clinician gives the same information.',
    }),
    refPatient,
  ),
  SpermStep(
    _T({
      'uz': 'Tiyilish: 2–7 kun',
      'ru': 'Воздержание: 2–7 дней',
      'en': 'Abstinence: 2–7 days',
    }),
    _T({
      'uz':
          'Eyakulyat kamida 2 kun va ko‘pi bilan 7 kunlik eyakulyatsiyadan '
          'tiyilishdan keyin olinadi. Tiyilish muddati qayd etiladi va '
          'xulosada ko‘rsatiladi.',
      'ru':
          'Эякулят собирают после не менее 2 и не более 7 дней '
          'эякуляторного воздержания. Срок воздержания записывают и '
          'указывают в заключении.',
      'en':
          'Collect after a minimum of 2 and a maximum of 7 days of '
          'ejaculatory abstinence. The abstinence period is recorded and '
          'given in the report.',
    }),
    refPatient,
  ),
  SpermStep(
    _T({
      'uz': 'Namuna olish usuli',
      'ru': 'Способ сбора',
      'en': 'How to collect',
    }),
    _T({
      'uz':
          'Asosiy usul — masturbatsiya. Uzilgan jinsiy aloqa tavsiya '
          'etilmaydi (to‘liq yig‘ilmaslik, qin suyuqligi aralashishi). Oddiy '
          'lateks prezervativlar ishlatilmaydi — ular spermatozoid '
          'harakatiga ta’sir qiladi; kontratseptiv prezervativlarda '
          'spermitsidlar bor. Lubrikantlardan qochiladi; zarur bo‘lsa — faqat '
          'tasdiqlangan, spermatozoidga zararsizi.',
      'ru':
          'Основной способ — мастурбация. Прерванный половой акт не '
          'рекомендуется (неполный сбор, примесь влагалищного секрета). '
          'Обычные латексные презервативы использовать нельзя — они нарушают '
          'подвижность; в контрацептивных презервативах есть спермициды. '
          'Лубрикантов избегают; при крайней необходимости — только '
          'валидированные, нетоксичные для сперматозоидов.',
      'en':
          'Masturbation is the primary method. Coitus interruptus is not '
          'recommended (incomplete collection, vaginal contamination). '
          'Ordinary latex condoms must not be used — they interfere with '
          'motility; contraceptive condoms contain spermicides. Avoid '
          'lubricants; if absolutely necessary, only validated '
          'non-spermatotoxic ones.',
    }),
    refPatient,
  ),
  SpermStep(
    _T({
      'uz': 'To‘liq namuna',
      'ru': 'Полный эякулят',
      'en': 'Complete sample',
    }),
    _T({
      'uz':
          'Eyakulyat to‘liq yig‘iladi; biror qismi yo‘qolgan bo‘lsa, erkak '
          'buni aytishi kerak. To‘liqligi va olishdagi qiyinchiliklar qayd '
          'etiladi.',
      'ru':
          'Эякулят собирают полностью; о потере любой фракции мужчина должен '
          'сообщить. Полноту и трудности при сборе записывают.',
      'en':
          'The whole ejaculate is collected; the man should report any lost '
          'fraction. Completeness and any difficulties are recorded.',
    }),
    refPatient,
  ),
  SpermStep(
    _T({'uz': 'Idish', 'ru': 'Контейнер', 'en': 'Container'}),
    _T({
      'uz':
          'Toza, keng og‘izli plastik idish — spermatozoidlar uchun zararsizligi '
          'tasdiqlangan partiyadan. Olishdan oldin idish 20 °C dan 37 °C '
          'gacha haroratda saqlanadi. Idish va ish varaqasi aralashib '
          'ketmaydigan qilib belgilanadi.',
      'ru':
          'Чистый широкогорлый пластиковый контейнер из партии, проверенной на '
          'нетоксичность для сперматозоидов. До сбора контейнер хранят при '
          '20–37 °C. Контейнер и рабочий бланк маркируют так, чтобы исключить '
          'путаницу.',
      'en':
          'A clean, wide-mouthed plastic container from a batch confirmed '
          'non-toxic for spermatozoa, kept at 20–37 °C before collection. '
          'Label container and work sheet so that mix-ups are impossible.',
    }),
    refCollection,
  ),
  SpermStep(
    _T({
      'uz': 'Tahlilgacha vaqt',
      'ru': 'Время до анализа',
      'en': 'Time to analysis',
    }),
    _T({
      'uz':
          'Namunani laboratoriya yonidagi alohida xonada olish tavsiya '
          'etiladi. Tekshiruv ideal holda olishdan keyin 30 daqiqa ichida, '
          'ko‘pi bilan 60 daqiqadan kechiktirmay boshlanadi.',
      'ru':
          'Сбор рекомендуется в отдельной комнате рядом с лабораторией. '
          'Исследование в идеале начинают в течение 30 минут после сбора, '
          'но не позднее 60 минут.',
      'en':
          'Collection in a private room close to the laboratory is '
          'recommended. Ideally start the examination within 30 minutes of '
          'collection, and no later than 60 minutes.',
    }),
    refPatient,
  ),
  SpermStep(
    _T({
      'uz': 'Uyda olinsa: yetkazish',
      'ru': 'Сбор вне лаборатории: доставка',
      'en': 'Collected elsewhere: delivery',
    }),
    _T({
      'uz':
          'Tashishda namuna harorati 20 °C dan pasaymasligi va 37 °C dan '
          'oshmasligi kerak. Idish kiyim ostida tanaga yaqin (masalan, qo‘ltiq '
          'ostida) tutiladi va afzali 30 daqiqa ichida, 50 daqiqadan kechikmay '
          'yetkaziladi.',
      'ru':
          'При транспортировке температура образца не должна опускаться ниже '
          '20 °C и подниматься выше 37 °C. Контейнер держат у тела под одеждой '
          '(например, в подмышке) и доставляют желательно в течение 30 минут, '
          'не позднее 50 минут после сбора.',
      'en':
          'During transport the sample must stay between 20 °C and 37 °C. '
          'Keep the container close to the body under clothes (e.g. in the '
          'armpit) and deliver preferably within 30 minutes, no later than '
          '50 minutes after collection.',
    }),
    refPatient,
  ),
  SpermStep(
    _T({
      'uz': 'Qabulda qayd etiladi',
      'ru': 'Что записать при приёме',
      'en': 'Record at reception',
    }),
    _T({
      'uz':
          'Erkakning shaxsi (namuna o‘ziniki ekanini tasdiqlashi ma’qul), '
          'tiyilish muddati, olish sanasi va vaqti, namunaning to‘liqligi va '
          'olishdagi qiyinchiliklar, eyakulyat hajmi.',
      'ru':
          'Идентификация мужчины (желательно его подтверждение, что образец '
          'его), срок воздержания, дата и время сбора, полнота образца и '
          'трудности при сборе, объём эякулята.',
      'en':
          'Identity of the man (ideally his confirmation that the sample is '
          'his), abstinence period, date and time of collection, completeness '
          'and any difficulties, ejaculate volume.',
    }),
    refCollection,
  ),
  SpermStep(
    _T({
      'uz': 'Suyulish va baholash vaqti',
      'ru': 'Разжижение и время оценки',
      'en': 'Liquefaction and timing',
    }),
    _T({
      'uz':
          '30 daqiqada suyulsa, tekshiruv shunda boshlanadi; suyulmasa — yana '
          '30 daqiqa 37 °C da qoldiriladi, kechikish xulosada yoziladi. '
          'Harakatchanlik harorati standartlashtiriladi. Tiriklik afzali '
          '30 daqiqada, har holda 1 soat ichida baholanadi.',
      'ru':
          'Если разжижение завершилось за 30 минут, исследование начинают '
          'сразу; если нет — оставляют ещё на 30 минут при 37 °C и отмечают '
          'задержку в заключении. Температуру при оценке подвижности '
          'стандартизируют. Жизнеспособность оценивают желательно через '
          '30 минут, но в любом случае в течение 1 часа.',
      'en':
          'If liquefaction is complete within 30 minutes, start then; if not, '
          'leave another 30 minutes at 37 °C and note the delay in the report. '
          'Standardise the temperature for motility. Assess vitality '
          'preferably at 30 minutes, in any case within 1 hour.',
    }),
    refMotility,
  ),
];

/// Mashq savoli: to'g'ri javob birinchi ([options][0]); ekranda aralashtiriladi.
class SpermQuizItem {
  const SpermQuizItem(this.id, this.prompt, this.options, this.basis);
  final String id;
  final LocalizedText prompt;
  final List<LocalizedText> options;
  final LocalizedText basis;
}

LocalizedText _n(String s) => _T({'uz': s, 'ru': s, 'en': s});

/// Konsentratsiya varianti (birlik tilga qarab).
LocalizedText _c(String v) =>
    _T({'uz': '$v ×10⁶/mL', 'ru': '$v ×10⁶/мл', 'en': '$v ×10⁶/mL'});

final spermQuiz = <SpermQuizItem>[
  SpermQuizItem(
    'sperm-q-conc',
    const _T({
      'uz': 'JSST 2021: spermatozoidlar konsentratsiyasining pastki chegarasi?',
      'ru': 'ВОЗ 2021: нижний предел концентрации сперматозоидов?',
      'en': 'WHO 2021: lower reference limit for sperm concentration?',
    }),
    [_c('16'), _c('15'), _c('20'), _c('39')],
    const _T({
      'uz': 'Table 8.3: 16 (95% IO 15–18) ×10⁶/mL. 39 — umumiy son.',
      'ru': 'Table 8.3: 16 (95% ДИ 15–18) ×10⁶/мл. 39 — общее число.',
      'en': 'Table 8.3: 16 (95% CI 15–18) ×10⁶/mL. 39 is the total number.',
    }),
  ),
  SpermQuizItem(
    'sperm-q-total',
    const _T({
      'uz': 'JSST 2021: eyakulyatdagi umumiy sonning pastki chegarasi?',
      'ru': 'ВОЗ 2021: нижний предел общего числа сперматозоидов?',
      'en': 'WHO 2021: lower limit for total sperm number per ejaculate?',
    }),
    [_n('39 ×10⁶'), _n('16 ×10⁶'), _n('58 ×10⁶'), _n('210 ×10⁶')],
    const _T({
      'uz': 'Table 8.3: 39 (35–40) ×10⁶. 210 — mediana.',
      'ru': 'Table 8.3: 39 (35–40) ×10⁶. 210 — медиана.',
      'en': 'Table 8.3: 39 (35–40) ×10⁶. 210 is the median.',
    }),
  ),
  SpermQuizItem(
    'sperm-q-volume',
    const _T({
      'uz': 'JSST 2021: eyakulyat hajmining pastki chegarasi?',
      'ru': 'ВОЗ 2021: нижний предел объёма эякулята?',
      'en': 'WHO 2021: lower limit for semen volume?',
    }),
    const [
      _T({'uz': '1,4 mL', 'ru': '1,4 мл', 'en': '1.4 mL'}),
      _T({'uz': '1,0 mL', 'ru': '1,0 мл', 'en': '1.0 mL'}),
      _T({'uz': '2,0 mL', 'ru': '2,0 мл', 'en': '2.0 mL'}),
      _T({'uz': '3,0 mL', 'ru': '3,0 мл', 'en': '3.0 mL'}),
    ],
    const _T({
      'uz': 'Table 8.3: 1,4 (1,3–1,5) mL; mediana 3,0 mL.',
      'ru': 'Table 8.3: 1,4 (1,3–1,5) мл; медиана 3,0 мл.',
      'en': 'Table 8.3: 1.4 (1.3–1.5) mL; median 3.0 mL.',
    }),
  ),
  SpermQuizItem(
    'sperm-q-pr',
    const _T({
      'uz': 'JSST 2021: progressiv harakat (PR) pastki chegarasi?',
      'ru': 'ВОЗ 2021: нижний предел прогрессивной подвижности (PR)?',
      'en': 'WHO 2021: lower limit for progressive motility (PR)?',
    }),
    [_n('30%'), _n('32%'), _n('42%'), _n('40%')],
    const _T({
      'uz': 'Table 8.3: PR 30% (29–31); umumiy harakatchanlik 42% (40–43).',
      'ru': 'Table 8.3: PR 30% (29–31); общая подвижность 42% (40–43).',
      'en': 'Table 8.3: PR 30% (29–31); total motility 42% (40–43).',
    }),
  ),
  SpermQuizItem(
    'sperm-q-morph',
    const _T({
      'uz': 'JSST 2021: normal shakllarning pastki chegarasi?',
      'ru': 'ВОЗ 2021: нижний предел нормальных форм?',
      'en': 'WHO 2021: lower limit for normal forms?',
    }),
    [_n('4%'), _n('14%'), _n('30%'), _n('54%')],
    const _T({
      'uz': 'Table 8.3: 4% (3,9–4,0). 54% — tiriklik chegarasi.',
      'ru': 'Table 8.3: 4% (3,9–4,0). 54% — предел жизнеспособности.',
      'en': 'Table 8.3: 4% (3.9–4.0). 54% is the vitality limit.',
    }),
  ),
  SpermQuizItem(
    'sperm-q-meaning',
    const _T({
      'uz': 'Pastki 5-persentil nimani anglatadi?',
      'ru': 'Что означает нижний 5-й процентиль?',
      'en': 'What does the lower 5th percentile mean?',
    }),
    const [
      _T({
        'uz':
            'Referens populyatsiyaning 5% ida natija undan past; fertillik '
            'chegarasi emas',
        'ru':
            'У 5% референтной популяции результат ниже; это не граница '
            'фертильности',
        'en':
            'Only 5% of the reference population were below it; not a '
            'fertility limit',
      }),
      _T({
        'uz': 'Undan past bo‘lsa — bepushtlik',
        'ru': 'Ниже — значит бесплодие',
        'en': 'Below it means infertility',
      }),
      _T({
        'uz': 'Bepusht erkaklarning o‘rtacha qiymati',
        'ru': 'Среднее значение у бесплодных мужчин',
        'en': 'The mean value in infertile men',
      }),
      _T({
        'uz': 'Davolash boshlanadigan chegara',
        'ru': 'Порог для начала лечения',
        'en': 'The threshold to start treatment',
      }),
    ],
    const _T({
      'uz': 'JSST 2021 §8.1.3: fertil va infertil erkaklar orasidagi chegara emas.',
      'ru': 'ВОЗ 2021 §8.1.3: это не граница между фертильными и бесплодными.',
      'en': 'WHO 2021 §8.1.3: not a limit between fertile and infertile men.',
    }),
  ),
  SpermQuizItem(
    'sperm-q-grades',
    const _T({
      'uz': 'JSST 2021 harakatchanlikni nechta toifaga ajratadi?',
      'ru': 'Сколько категорий подвижности в ВОЗ 2021?',
      'en': 'How many motility grades does WHO 2021 use?',
    }),
    const [
      _T({
        'uz': 'To‘rtta: a, b, c, d',
        'ru': 'Четыре: a, b, c, d',
        'en': 'Four: a, b, c, d',
      }),
      _T({
        'uz': 'Uchta: PR, NP, IM',
        'ru': 'Три: PR, NP, IM',
        'en': 'Three: PR, NP, IM',
      }),
      _T({
        'uz': 'Ikkita: harakatli va harakatsiz',
        'ru': 'Две: подвижные и неподвижные',
        'en': 'Two: motile and immotile',
      }),
      _T({'uz': 'Beshta', 'ru': 'Пять', 'en': 'Five'}),
    ],
    const _T({
      'uz': '§2.4.6.1: tez progressiv, sekin progressiv, noprogressiv, harakatsiz.',
      'ru':
          '§2.4.6.1: быстрые и медленные прогрессивные, непрогрессивные, '
          'неподвижные.',
      'en':
          '§2.4.6.1: rapid progressive, slow progressive, non-progressive, '
          'immotile.',
    }),
  ),
  SpermQuizItem(
    'sperm-q-abstinence',
    const _T({
      'uz': 'JSST 2021 bo‘yicha tiyilish muddati?',
      'ru': 'Срок воздержания по ВОЗ 2021?',
      'en': 'Abstinence period per WHO 2021?',
    }),
    const [
      _T({'uz': '2–7 kun', 'ru': '2–7 дней', 'en': '2–7 days'}),
      _T({'uz': '1–3 kun', 'ru': '1–3 дня', 'en': '1–3 days'}),
      _T({'uz': '5–10 kun', 'ru': '5–10 дней', 'en': '5–10 days'}),
      _T({
        'uz': 'Kamida 10 kun',
        'ru': 'Не менее 10 дней',
        'en': 'At least 10 days',
      }),
    ],
    const _T({
      'uz': '§2.3.1: kamida 2, ko‘pi bilan 7 kun.',
      'ru': '§2.3.1: не менее 2 и не более 7 дней.',
      'en': '§2.3.1: a minimum of 2 and a maximum of 7 days.',
    }),
  ),
  SpermQuizItem(
    'sperm-q-transport',
    const _T({
      'uz': 'Uyda olingan namuna qanday yetkaziladi?',
      'ru': 'Как доставить образец, собранный вне лаборатории?',
      'en': 'How is a sample collected elsewhere delivered?',
    }),
    const [
      _T({
        'uz': '20–37 °C da, tanaga yaqin; 50 daqiqadan kechikmay',
        'ru': 'При 20–37 °C, у тела; не позднее 50 минут',
        'en': 'At 20–37 °C, close to the body; within 50 minutes',
      }),
      _T({
        'uz': 'Muzlatgichda, 24 soat ichida',
        'ru': 'В холодильнике, в течение 24 часов',
        'en': 'In a fridge, within 24 hours',
      }),
      _T({
        'uz': 'Xona haroratida, 3 soat ichida',
        'ru': 'При комнатной температуре, в течение 3 часов',
        'en': 'At room temperature, within 3 hours',
      }),
      _T({
        'uz': 'Muz ustida, 2 soat ichida',
        'ru': 'На льду, в течение 2 часов',
        'en': 'On ice, within 2 hours',
      }),
    ],
    const _T({
      'uz':
          '§2.3.1: 20 °C dan past emas, 37 °C dan yuqori emas; afzali 30, '
          'ko‘pi bilan 50 daqiqa.',
      'ru':
          '§2.3.1: не ниже 20 °C и не выше 37 °C; желательно 30, не позднее '
          '50 минут.',
      'en':
          '§2.3.1: not below 20 °C or above 37 °C; preferably 30, at most '
          '50 minutes.',
    }),
  ),
  SpermQuizItem(
    'sperm-q-azoo',
    const _T({
      'uz': '"Azoospermiya" atamasi qachon ishlatiladi?',
      'ru': 'Когда применяют термин «азооспермия»?',
      'en': 'When is the term azoospermia used?',
    }),
    const [
      _T({
        'uz': 'Sentrifugalangan cho‘kmada ham spermatozoid topilmasa',
        'ru':
            'Если сперматозоиды не найдены и в осадке после центрифугирования',
        'en': 'If no spermatozoa are found even in a centrifuged sediment',
      }),
      _T({
        'uz': 'Bitta nam preparatda spermatozoid ko‘rinmasa',
        'ru': 'Если в одном нативном препарате нет сперматозоидов',
        'en': 'If one wet preparation shows no spermatozoa',
      }),
      _T({
        'uz': 'Konsentratsiya 16 ×10⁶/mL dan past bo‘lsa',
        'ru': 'Если концентрация ниже 16 ×10⁶/мл',
        'en': 'If concentration is below 16 ×10⁶/mL',
      }),
      _T({
        'uz': 'Barcha spermatozoidlar harakatsiz bo‘lsa',
        'ru': 'Если все сперматозоиды неподвижны',
        'en': 'If all spermatozoa are immotile',
      }),
    ],
    const _T({
      'uz': '§2.4.8.8: atama faqat cho‘kma tekshirilgandan keyin; bu tashxis emas.',
      'ru': '§2.4.8.8: термин — только после исследования осадка; это не диагноз.',
      'en':
          '§2.4.8.8: only after examining the sediment; it is not a diagnosis.',
    }),
  ),
];
