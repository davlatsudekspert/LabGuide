/// QC yo'riqnomalari matni (3 tilda): QC rad etilganda, tashqi sifat
/// nazorati (EQA) va kritik qiymatlar.
///
/// Har band manba matnidan olingan (WHO LQMS 2011, Westgard 1981,
/// Campbell 2012, Imoh 2023). Umumiy “kritik chegaralar” raqamlari
/// ataylab berilmaydi: ro'yxatni har laboratoriya o'zi tuzadi.
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';

enum QcGuide { rejected, eqa, critical }

String qcGuideRoute(QcGuide g) => switch (g) {
  QcGuide.rejected => 'rejected',
  QcGuide.eqa => 'eqa',
  QcGuide.critical => 'critical',
};

class GuideSection {
  const GuideSection(this.title, this.items, {this.numbered = false});

  final LocalizedText title;
  final List<LocalizedText> items;

  /// `true` — bosqichlar (raqamli), aks holda ro'yxat.
  final bool numbered;
}

class GuideContent {
  const GuideContent({
    required this.intro,
    required this.sections,
    required this.notice,
    required this.refs,
  });

  final LocalizedText intro;
  final List<GuideSection> sections;
  final LocalizedText notice;
  final List<CalcRef> refs;
}

const Map<QcGuide, GuideContent> qcGuides = {
  QcGuide.rejected: GuideContent(
    intro: LocalizedText({
      'uz':
          'Nazorat namunasi ruxsat etilgan oraliqdan chiqsa, seriya “nazoratdan '
          'chiqqan” hisoblanadi. Quyidagi tartib WHO LQMS qo‘llanmasidan; '
          'qoida va xato turi — Westgard multiqoidasidan.',
      'ru':
          'Если контрольный образец вне допустимого диапазона, серия считается '
          '«вышедшей из-под контроля». Порядок ниже — по руководству ВОЗ LQMS; '
          'правила и тип ошибки — по мультиправилу Вестгарда.',
      'en':
          'When a control falls outside its acceptable range, the run is '
          '“out of control”. The steps below follow the WHO LQMS handbook; the '
          'rules and error types follow the Westgard multirule.',
    }),
    sections: [
      GuideSection(
        LocalizedText({
          'uz': 'Bosqichlar',
          'ru': 'Порядок действий',
          'en': 'Steps',
        }),
        numbered: true,
        [
          LocalizedText({
            'uz':
                'Tekshiruvni to‘xtating. Bu seriyaning bemor natijalarini '
                'bermang [1].',
            'ru':
                'Остановите исследования. Не выдавайте результаты пациентов из '
                'этой серии [1].',
            'en': 'Stop testing. Do not report patient results from this run [1].',
          }),
          LocalizedText({
            'uz':
                'Qaysi qoida buzilganini aniqlang: 1-3s yoki R-4s — ko‘proq '
                'tasodifiy xato; 2-2s, 4-1s, 10x — tizimli xato; faqat 1-2s — '
                'ogohlantirish [2].',
            'ru':
                'Определите, какое правило нарушено: 1-3s или R-4s — чаще '
                'случайная ошибка; 2-2s, 4-1s, 10x — систематическая; только '
                '1-2s — предупреждение [2].',
            'en':
                'Identify the rule that failed: 1-3s or R-4s — mostly random '
                'error; 2-2s, 4-1s, 10x — systematic error; 1-2s alone is a '
                'warning [2].',
          }),
          LocalizedText({
            'uz':
                'Sababni izlang. Nazoratni sabab izlamay shunchaki qayta '
                'o‘tkazmang [1].',
            'ru':
                'Ищите причину. Не повторяйте контроль просто так, не '
                'поискав источник ошибки [1].',
            'en':
                'Look for the cause. Do not simply repeat the test without '
                'looking for the source of error [1].',
          }),
          LocalizedText({
            'uz':
                'Sababni tuzatgach, nazorat materialini qayta tekshiring [1].',
            'ru':
                'После устранения причины повторно исследуйте контрольный '
                'материал [1].',
            'en': 'Once the cause is corrected, recheck the control material [1].',
          }),
          LocalizedText({
            'uz':
                'Nazorat to‘g‘ri chiqsa, bemor namunalarini yana bir QC namunasi '
                'bilan birga qayta tekshiring [1].',
            'ru':
                'Если контроль в норме, повторите образцы пациентов вместе с '
                'ещё одним контролем [1].',
            'en':
                'If the controls read correctly, repeat the patient samples '
                'together with another QC specimen [1].',
          }),
          LocalizedText({
            'uz':
                'Bemor natijalarini muammo hal bo‘lib, nazorat to‘g‘ri ishlashni '
                'ko‘rsatgandan keyingina bering [1].',
            'ru':
                'Выдавайте результаты пациентов только когда проблема решена и '
                'контроль показывает правильную работу [1].',
            'en':
                'Report patient results only after the problem is resolved and '
                'the controls show proper performance [1].',
          }),
          LocalizedText({
            'uz':
                'Nima bo‘lgani, topilgan sabab va ko‘rilgan choralarni qayd '
                'eting — QC yozuvlari to‘liq bo‘lishi kerak [1].',
            'ru':
                'Запишите, что произошло, найденную причину и принятые меры — '
                'записи QC должны быть полными [1].',
            'en':
                'Record what happened, the cause found and the action taken — '
                'QC records must be complete [1].',
          }),
        ],
      ),
      GuideSection(
        LocalizedText({
          'uz': 'Tekshiriladigan sabablar',
          'ru': 'Возможные причины',
          'en': 'Possible causes to check',
        }),
        [
          LocalizedText({
            'uz': 'Reagent yoki to‘plam buzilgan',
            'ru': 'Деградация реагентов или наборов',
            'en': 'Degraded reagents or kits',
          }),
          LocalizedText({
            'uz': 'Nazorat materiali buzilgan',
            'ru': 'Деградация контрольного материала',
            'en': 'Degraded control material',
          }),
          LocalizedText({
            'uz': 'Bajaruvchi xatosi',
            'ru': 'Ошибка оператора',
            'en': 'Operator error',
          }),
          LocalizedText({
            'uz': 'Ishlab chiqaruvchi yo‘riqnomasiga amal qilinmagan',
            'ru': 'Не соблюдена инструкция производителя',
            'en': 'Manufacturer’s instructions not followed',
          }),
          LocalizedText({
            'uz': 'Eskirgan SOP / usul qo‘llanmasi',
            'ru': 'Устаревшая СОП / методическое руководство',
            'en': 'Outdated procedure manual',
          }),
          LocalizedText({
            'uz': 'Asbob nosozligi',
            'ru': 'Неисправность оборудования',
            'en': 'Equipment failure',
          }),
          LocalizedText({
            'uz': 'Kalibrovka xatosi',
            'ru': 'Ошибка калибровки',
            'en': 'Calibration error',
          }),
        ],
      ),
    ],
    notice: LocalizedText({
      'uz':
          'Laboratoriyangizning yozma tuzatish tartibi (SOP) va ishlab '
          'chiqaruvchining nosozlik qo‘llanmasi ustuvor [1].',
      'ru':
          'Приоритет — письменный порядок корректирующих действий вашей '
          'лаборатории (СОП) и руководство производителя по устранению '
          'неполадок [1].',
      'en':
          'Your laboratory’s written remedial-action procedure (SOP) and the '
          'manufacturer’s troubleshooting guide take precedence [1].',
    }),
    refs: [
      CalcRef(
        CalcSources.whoLqms2011,
        '7-6: Using quality control information',
      ),
      CalcRef(CalcSources.westgard1981, 'Multirule procedure'),
    ],
  ),
  QcGuide.eqa: GuideContent(
    intro: LocalizedText({
      'uz':
          'Tashqi sifat nazorati (EQA) — laboratoriya ishini tashqi tashkilot '
          'yordamida xolis tekshirish tizimi. Ichki QC kundalik barqarorlikni '
          'ko‘rsatadi; EQA esa natijalaringiz boshqa laboratoriyalarniki bilan '
          'mos kelishini ko‘rsatadigan yagona vosita [1].',
      'ru':
          'Внешняя оценка качества (EQA) — система объективной проверки работы '
          'лаборатории с помощью внешней организации. Внутренний QC показывает '
          'повседневную стабильность; EQA — единственный способ убедиться, что '
          'ваши результаты сопоставимы с другими лабораториями [1].',
      'en':
          'External quality assessment (EQA) is a system for objectively '
          'checking a laboratory’s performance using an external agency. '
          'Internal QC shows day-to-day stability; EQA is the only means to '
          'ensure your performance is comparable to other laboratories [1].',
    }),
    sections: [
      GuideSection(
        LocalizedText({'uz': 'Turlari', 'ru': 'Виды', 'en': 'Types'}),
        [
          LocalizedText({
            'uz':
                'Malaka sinovi (PT): provayder noma’lum namunalar yuboradi, '
                'barcha laboratoriyalar natijasi taqqoslanadi va hisobot '
                'qaytariladi.',
            'ru':
                'Проверка квалификации (PT): провайдер рассылает неизвестные '
                'образцы, результаты всех лабораторий сравниваются, отчёт '
                'возвращается.',
            'en':
                'Proficiency testing (PT): a provider sends unknown samples, '
                'all laboratories’ results are compared and reported back.',
          }),
          LocalizedText({
            'uz':
                'Qayta tekshirish: o‘qilgan preparatlar yoki tekshirilgan '
                'namunalar ma’lumotnoma laboratoriyasida qayta ko‘riladi.',
            'ru':
                'Перепроверка: просмотренные препараты или исследованные '
                'образцы перепроверяются в референс-лаборатории.',
            'en':
                'Rechecking/retesting: slides or samples already read are '
                'rechecked by a reference laboratory.',
          }),
          LocalizedText({
            'uz': 'Joyida baholash — PT yoki qayta tekshirish qiyin bo‘lganda.',
            'ru': 'Оценка на месте — когда PT или перепроверка затруднены.',
            'en': 'On-site evaluation — when PT or rechecking is difficult.',
          }),
        ],
      ),
      GuideSection(
        LocalizedText({
          'uz': 'PT qanday o‘tadi',
          'ru': 'Как проходит PT',
          'en': 'How PT works',
        }),
        numbered: true,
        [
          LocalizedText({
            'uz':
                'Provayder namunalarni muntazam yuboradi; maqbul chastota — '
                'yiliga 3–4 marta.',
            'ru':
                'Провайдер рассылает образцы регулярно; оптимально — 3–4 раза '
                'в год.',
            'en':
                'The provider sends samples at regular intervals; 3–4 times a '
                'year is optimal.',
          }),
          LocalizedText({
            'uz':
                'Namunani oddiy bemor namunasi kabi tekshiring: odatiy usul, '
                'odatda shu ishni qiladigan xodim.',
            'ru':
                'Исследуйте образец как обычный образец пациента: обычным '
                'методом, сотрудником, который обычно выполняет это '
                'исследование.',
            'en':
                'Test the sample like a patient sample: the usual method and '
                'the staff who routinely do the test.',
          }),
          LocalizedText({
            'uz':
                'Natijani muddatida yuboring; boshqa laboratoriyalar bilan '
                'muhokama qilmang.',
            'ru':
                'Отправьте результат в срок; не обсуждайте его с другими '
                'лабораториями.',
            'en':
                'Submit results on time; do not discuss them with other '
                'laboratories.',
          }),
          LocalizedText({
            'uz':
                'Hisobotni o‘rganing, kamchilik bo‘lsa sababini tekshirib, '
                'tuzating; natija va choralarni saqlang, jamoaga yetkazing.',
            'ru':
                'Изучите отчёт, при неудаче найдите причину и устраните; '
                'храните результаты и меры, сообщите коллективу.',
            'en':
                'Review the report; investigate and correct any deficiency; '
                'keep results and actions on record and share them with staff.',
          }),
        ],
      ),
      GuideSection(
        LocalizedText({
          'uz': 'Natija qoniqarsiz bo‘lsa — butun yo‘lni tekshiring',
          'ru': 'Если результат неудовлетворительный — проверьте весь путь',
          'en': 'Poor result — check the whole path',
        }),
        [
          LocalizedText({
            'uz':
                'Tahlilgacha: namuna yuborish yoki saqlashda buzilgan, '
                'noto‘g‘ri ishlov berilgan yoki belgilangan.',
            'ru':
                'Преаналитика: образец повреждён при доставке или хранении, '
                'неправильно обработан или промаркирован.',
            'en':
                'Pre-examination: sample compromised in shipping or storage, '
                'processed or labelled wrongly.',
          }),
          LocalizedText({
            'uz':
                'Tahlil: matritsa effekti, reagent, asbob, usul, kalibrovka, '
                'hisob; xato tasodifiymi yoki tizimlimi; xodim malakasi.',
            'ru':
                'Аналитика: матричный эффект, реагенты, прибор, метод, '
                'калибровка, расчёты; случайная или систематическая ошибка; '
                'компетентность персонала.',
            'en':
                'Examination: matrix effect, reagents, instrument, method, '
                'calibration, calculations; random or systematic error; staff '
                'competency.',
          }),
          LocalizedText({
            'uz':
                'Tahlildan keyin: hisobot shakli chalkash, talqin noto‘g‘ri, '
                'ko‘chirishda xato. Provayder ma’lumotni noto‘g‘ri kiritgan '
                'bo‘lishi ham mumkin.',
            'ru':
                'Постаналитика: запутанная форма отчёта, неверная '
                'интерпретация, ошибки переписывания. Возможна и ошибка ввода '
                'у провайдера.',
            'en':
                'Post-examination: confusing report format, wrong '
                'interpretation, transcription errors. The provider may also '
                'have captured data incorrectly.',
          }),
        ],
      ),
      GuideSection(
        LocalizedText({
          'uz': 'Yodda tuting',
          'ru': 'Помните',
          'en': 'Keep in mind',
        }),
        [
          LocalizedText({
            'uz': 'Bitta qoniqarsiz natija hali muammo borligini anglatmaydi.',
            'ru':
                'Один неудовлетворительный результат ещё не означает проблему.',
            'en':
                'A single unacceptable result does not necessarily mean a '
                'problem.',
          }),
          LocalizedText({
            'uz':
                'PT tahlilgacha va tahlildan keyingi bosqich xatolarining '
                'hammasini aniqlamaydi — yagona baholash usuli bo‘lmasin.',
            'ru':
                'PT выявляет не все ошибки пре- и постаналитики — это не '
                'единственный способ оценки.',
            'en':
                'PT does not detect all pre- and post-examination problems — '
                'it should not be the only measure of quality.',
          }),
          LocalizedText({
            'uz':
                'ISO 15189 laboratoriyalararo taqqoslashni talab qiladi; sxema '
                'bo‘lmasa — boshqa yo‘l, masalan, namuna almashish.',
            'ru':
                'ISO 15189 требует межлабораторных сличений; если схемы нет — '
                'другой способ, например обмен образцами.',
            'en':
                'ISO 15189 requires interlaboratory comparison; where no scheme '
                'exists, use another mechanism such as sample exchange.',
          }),
          LocalizedText({
            'uz': 'EQA jazo emas — u o‘rganish va yaxshilash vositasi.',
            'ru': 'EQA — не наказание, а инструмент обучения и улучшения.',
            'en':
                'EQA should not be punitive — it is a tool for learning and '
                'improvement.',
          }),
        ],
      ),
    ],
    notice: LocalizedText({
      'uz':
          'Ilova EQA dasturiga ulanmagan va natija yubormaydi — bu sahifa '
          'faqat tushuntirish.',
      'ru':
          'Приложение не подключено к программам EQA и не отправляет '
          'результаты — эта страница только поясняет.',
      'en':
          'The app is not connected to any EQA programme and does not submit '
          'results — this page only explains.',
    }),
    refs: [
      CalcRef(
        CalcSources.whoLqms2011,
        'Chapter 10: 10-1, 10-2, 10-3, 10-5, 10-6',
      ),
    ],
  ),
  QcGuide.critical: GuideContent(
    intro: LocalizedText({
      'uz':
          'Kritik (“panik”) qiymat — hayot uchun xavfli holatni ko‘rsatadigan, '
          'zudlik bilan tibbiy choralar talab qiladigan darajada g‘ayrioddiy '
          'natija [3].',
      'ru':
          'Критическое («паническое») значение — результат, настолько '
          'отклонённый, что указывает на угрожающее жизни состояние и требует '
          'немедленного вмешательства [3].',
      'en':
          'A critical (“panic”) value is a result so abnormal that it suggests '
          'a potentially life-threatening condition needing immediate '
          'intervention [3].',
    }),
    sections: [
      GuideSection(
        LocalizedText({
          'uz': 'Ro‘yxatni kim tuzadi',
          'ru': 'Кто составляет список',
          'en': 'Who sets the list',
        }),
        [
          LocalizedText({
            'uz':
                'Hamma uchun yagona ro‘yxat yo‘q. Kritik testlar va chegaralarni '
                'laboratoriya klinitsistlar bilan birga belgilaydi [2].',
            'ru':
                'Единого для всех списка нет. Критические тесты и пределы '
                'лаборатория определяет вместе с клиницистами [2].',
            'en':
                'There is no universal list. The laboratory defines critical '
                'tests and limits together with clinicians [2].',
          }),
          LocalizedText({
            'uz':
                'Har tahlil SOP sida hayot uchun xavfli oraliqlar va shoshilinch '
                'xabar berish tartibi yozilishi kerak [1].',
            'ru':
                'В СОП каждого исследования должны быть указаны угрожающие '
                'жизни диапазоны и порядок срочного сообщения [1].',
            'en':
                'Each test’s SOP should state the life-threatening ranges and '
                'how to handle an urgent report [1].',
          }),
          LocalizedText({
            'uz':
                'Shuning uchun ilova umumiy raqamlar bermaydi — '
                'laboratoriyangiz tasdiqlagan ro‘yxatdan foydalaning.',
            'ru':
                'Поэтому приложение не даёт общих чисел — пользуйтесь списком, '
                'утверждённым вашей лабораторией.',
            'en':
                'That is why the app gives no general numbers — use the list '
                'approved by your laboratory.',
          }),
        ],
      ),
      GuideSection(
        LocalizedText({
          'uz': 'Tartibda nima bo‘lishi kerak',
          'ru': 'Что должно быть в порядке',
          'en': 'What the procedure must cover',
        }),
        numbered: true,
        [
          LocalizedText({
            'uz': 'Kritik natija qanday aniqlanadi.',
            'ru': 'Как выявляется критический результат.',
            'en': 'How critical results are identified.',
          }),
          LocalizedText({
            'uz': 'Kim xabar beradi va kim qabul qila oladi.',
            'ru': 'Кто сообщает и кто может принять сообщение.',
            'en': 'Who may report and who may receive the result.',
          }),
          LocalizedText({
            'uz': 'Qancha vaqt ichida yetkazilishi kerak.',
            'ru': 'В какой срок результат должен быть доставлен.',
            'en': 'The acceptable timeframe for delivery.',
          }),
          LocalizedText({
            'uz':
                'Javobgar shifokorga yetib bo‘lmasa — yuqoriga uzatish '
                '(eskalatsiya) tartibi.',
            'ru': 'Если связаться не удаётся — порядок эскалации.',
            'en': 'Escalation if reporting fails.',
          }),
          LocalizedText({
            'uz': 'Qaysi aloqa kanali ishlatiladi (telefon, tizim va h.k.).',
            'ru': 'Какие каналы связи используются (телефон, система и т. д.).',
            'en':
                'Which communication channels are used (phone, system, etc.).',
          }),
          LocalizedText({
            'uz':
                'Nima va qanday qayd etiladi (vaqt, kim xabar berdi, kim qabul '
                'qildi, natija).',
            'ru':
                'Что и как записывается (время, кто сообщил, кто принял, '
                'результат).',
            'en':
                'What is recorded and how (time, who reported, who received, '
                'the result).',
          }),
          LocalizedText({
            'uz': 'Tartib qanday baholanadi va yangilanadi.',
            'ru': 'Как порядок оценивается и обновляется.',
            'en': 'How the procedure is maintained and evaluated.',
          }),
        ],
      ),
      GuideSection(
        LocalizedText({
          'uz': 'Amaliyotdan',
          'ru': 'Из практики',
          'en': 'From practice',
        }),
        [
          LocalizedText({
            'uz':
                'Telefon orqali xabarda ba’zi laboratoriyalar qabul qiluvchidan '
                'natijani qayta o‘qib berishni (read-back) talab qiladi; buni '
                'o‘z tartibingizda belgilang [3].',
            'ru':
                'При сообщении по телефону часть лабораторий требует, чтобы '
                'получатель повторил результат (read-back); определите это в '
                'своём порядке [3].',
            'en':
                'For phone notification some laboratories require the '
                'receiver to read the result back; decide this in your own '
                'procedure [3].',
          }),
          LocalizedText({
            'uz':
                'So‘rovnomalarda ko‘p laboratoriyada shifokorga yetib '
                'bo‘lmaganda nima qilish va xabar muddati belgilanmagani '
                'aniqlangan — aynan shu bandlarni oldindan yozing [3].',
            'ru':
                'Опросы показали, что во многих лабораториях не определены '
                'действия при недоступности врача и срок сообщения — пропишите '
                'эти пункты заранее [3].',
            'en':
                'Surveys found that many laboratories had no plan for an '
                'unreachable caregiver and no notification time limit — write '
                'these down in advance [3].',
          }),
        ],
      ),
    ],
    notice: LocalizedText({
      'uz':
          'Ilova xabar yubormaydi va kritik natijalarni kuzatmaydi — bu sahifa '
          'tartibni tuzishga yordam beradi.',
      'ru':
          'Приложение не отправляет сообщения и не отслеживает критические '
          'результаты — эта страница помогает составить порядок.',
      'en':
          'The app does not send notifications or track critical results — '
          'this page helps you write the procedure.',
    }),
    refs: [
      CalcRef(CalcSources.whoLqms2011, '16-4: Standard operating procedures'),
      CalcRef(CalcSources.campbell2012, 'Abstract'),
      CalcRef(CalcSources.imoh2023, 'Introduction; Results; Discussion'),
    ],
  ),
};
