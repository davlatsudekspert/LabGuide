// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTagline => 'БИОХИМИЯ · ЛАБОРАТОРИЯ';

  @override
  String get navHome => 'Главная';

  @override
  String get navTests => 'Анализы';

  @override
  String get navLab => 'Лаб.';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navLearn => 'Обучение';

  @override
  String get actionBack => 'Назад';

  @override
  String get actionProfile => 'Профиль и настройки';

  @override
  String get actionLanguage => 'Язык';

  @override
  String get actionOpen => 'Открыть';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionCopyLink => 'Копировать ссылку';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String plannedStage(String stage) {
    return 'Запланировано на этапе $stage';
  }

  @override
  String get notAvailableYet => 'Пока недоступно';

  @override
  String get debugBuildBadge => 'DEBUG · ДЕМО-АДАПТЕРЫ';

  @override
  String get welcomeEyebrow => 'Ваш лабораторный помощник';

  @override
  String get welcomeTitle => 'Биохимия.\nПонятно и практично.';

  @override
  String get welcomeSubtitle =>
      'Анализы, лабораторная практика и обучение в одном месте.';

  @override
  String get welcomeDevices => 'Телефон и планшет';

  @override
  String get welcomeRoles =>
      'Врач · специалист лаборатории · студент · преподаватель';

  @override
  String get welcomeGetStarted => 'Начать / зарегистрироваться';

  @override
  String get welcomeGuest => 'Посмотреть как гость';

  @override
  String get welcomeSignIn => 'Войти';

  @override
  String get welcomeGuestNote =>
      'Для чтения контента аккаунт не нужен. Вход нужен для синхронизации, групп и покупок.';

  @override
  String get authTitle => 'Добро пожаловать';

  @override
  String get authSubtitle => 'Вход или регистрация по email.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authEmailInvalid => 'Введите корректный адрес email.';

  @override
  String get authConsent =>
      'Я принимаю условия использования и политику конфиденциальности.';

  @override
  String get authConsentRequired => 'Примите условия, чтобы продолжить.';

  @override
  String get authGetCode => 'Получить код';

  @override
  String get authViewTerms => 'Посмотреть условия';

  @override
  String get authDemoNotice =>
      'Debug-сборка: демо-вход. Письмо не отправляется; код будет показан на следующем экране.';

  @override
  String get authUnavailableTitle => 'Вход по email пока не подключён';

  @override
  String get authUnavailableBody =>
      'Весь контент для чтения доступен гостю. Вход включится после настройки почтового сервиса.';

  @override
  String get authContinueGuest => 'Продолжить как гость';

  @override
  String authRateLimited(int seconds) {
    return 'Слишком много запросов. Повторите через $seconds с.';
  }

  @override
  String get authGenericError =>
      'Что-то пошло не так. Проверьте соединение и повторите попытку.';

  @override
  String get otpTitle => 'Подтвердите email';

  @override
  String get otpCodeLabel => '6-значный код';

  @override
  String get otpVerify => 'Подтвердить';

  @override
  String otpDemoCode(String code) {
    return 'Демо-код: $code. Письмо не отправлено (только debug-сборка).';
  }

  @override
  String otpInvalid(int attempts) {
    return 'Неверный код. Осталось попыток: $attempts.';
  }

  @override
  String get otpExpired => 'Срок действия кода истёк. Запросите новый.';

  @override
  String get otpTooManyAttempts =>
      'Слишком много попыток. Запросите новый код.';

  @override
  String get otpNoActiveCode => 'Нет активного кода. Запросите новый.';

  @override
  String get otpFormat => 'Введите 6-значный код.';

  @override
  String get otpResend => 'Получить код повторно';

  @override
  String otpResendIn(int seconds) {
    return 'Повторно через $seconds с';
  }

  @override
  String otpValidFor(int minutes) {
    return 'Код действует $minutes мин.';
  }

  @override
  String get otpResent => 'Выдан новый код.';

  @override
  String get rolesTitle => 'Ваше рабочее пространство';

  @override
  String get rolesSubtitle =>
      'Выберите основное направление. Его можно изменить позже.';

  @override
  String get rolesNote =>
      'Роль меняет только главную страницу. Она не даёт доступа к чужим группам и данным.';

  @override
  String get roleDoctor => 'Врач';

  @override
  String get roleDoctorDesc => 'Результаты и клинический контекст';

  @override
  String get roleLab => 'Специалист лаборатории';

  @override
  String get roleLabDesc => 'Методики, приборы и контроль качества';

  @override
  String get roleStudent => 'Студент';

  @override
  String get roleStudentDesc => 'Обучение, практика и экзамены';

  @override
  String get roleTeacher => 'Преподаватель / исследователь';

  @override
  String get roleTeacherDesc => 'Группы, задания и исследования';

  @override
  String get homeTitle => 'Знания. Точность. Практика.';

  @override
  String get homeFocusTag => 'Ваше направление';

  @override
  String get homeHeroDoctorTitle => 'Результат в клиническом контексте';

  @override
  String get homeHeroDoctorBody =>
      'Анализ, влияющие факторы и связанные исследования.';

  @override
  String get homeHeroDoctorCta => 'Открыть анализы';

  @override
  String get condGuideTitle => 'Анализы по заболеваниям';

  @override
  String get condGuideEyebrow => 'Справочник врача';

  @override
  String get condGuideBody =>
      'Для каждого состояния: какие анализы в первую очередь, какие затем — и на что может указывать результат.';

  @override
  String get condGuideSearch => 'Найти болезнь или анализ…';

  @override
  String get condGuideAll => 'Все состояния';

  @override
  String condCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count состояния',
      many: '$count состояний',
      few: '$count состояния',
      one: '$count состояние',
    );
    return '$_temp0';
  }

  @override
  String condSystemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count системы',
      many: '$count систем',
      few: '$count системы',
      one: '$count система',
    );
    return '$_temp0';
  }

  @override
  String get condListSubtitle =>
      'Какие анализы при каком состоянии — и о чём может говорить результат';

  @override
  String get condSearchLabel => 'Поиск состояний';

  @override
  String get condSearchHint => 'Диабет, анемия, щитовидная железа, ТТГ…';

  @override
  String get condEmptyTitle => 'Ничего не найдено';

  @override
  String get condEmptyBody =>
      'Попробуйте другое название, разговорное название или название анализа (например, «сахарный диабет»).';

  @override
  String get condTierFirstLine => 'В первую очередь';

  @override
  String get condTierAdditional => 'Дополнительно';

  @override
  String get condTierMonitoring => 'Наблюдение';

  @override
  String get condTierFirstLineHint =>
      'Назначают в первую очередь при подозрении';

  @override
  String get condTierAdditionalHint =>
      'Для уточнения, поиска причины или дифференциации';

  @override
  String get condTierMonitoringHint => 'После диагноза или во время лечения';

  @override
  String get condPatternsTitle => 'Типичные сочетания результатов';

  @override
  String get condPatternsHint =>
      '«Если получилось так — вероятно вот это». Трактовка вероятностная: окончательный вывод делает врач с учётом клинической картины.';

  @override
  String get condNotDiagnosticTitle => 'Не инструмент для постановки диагноза';

  @override
  String get condNotDiagnosticBody =>
      'Справочник помогает планировать обследование. Клиническая оценка и окончательное решение — за врачом. Текст — черновик на основе источников, ожидает независимой экспертной проверки.';

  @override
  String get condCautionsTitle => 'Важно учитывать';

  @override
  String get condNoCard => 'Карточки пока нет';

  @override
  String get condCopyList => 'Скопировать список анализов';

  @override
  String get condCopyListSub => 'Готовый текст для направления или сообщения';

  @override
  String get condCopied => 'Список скопирован';

  @override
  String condReferralTitle(String name) {
    return '$name — анализы';
  }

  @override
  String get condReferralFooter =>
      'Справочник LabGuide (черновик). Не инструмент диагностики — окончательное решение за врачом.';

  @override
  String get condAnalyteSection => 'При каких состояниях назначают';

  @override
  String get condTestsEntrySub =>
      'Выберите состояние — нужные анализы и сочетания результатов';

  @override
  String get condSearchSection => 'Состояния';

  @override
  String condRowFirstLine(String tests) {
    return 'Сначала: $tests';
  }

  @override
  String get condSysEndocrine => 'Эндокринная система';

  @override
  String get condSysKidney => 'Почки и мочевые пути';

  @override
  String get condSysLiver => 'Печень и желчные пути';

  @override
  String get condSysDigestive => 'Поджелудочная железа и кишечник';

  @override
  String get condSysCardio => 'Сердце и сосуды';

  @override
  String get condSysBlood => 'Кровь и свёртывание';

  @override
  String get condSysInfection => 'Инфекции';

  @override
  String get condSysRheumatology => 'Ревматология';

  @override
  String get condSysBone => 'Кости и обмен кальция';

  @override
  String get condSysPregnancy => 'Беременность и репродуктивное здоровье';

  @override
  String get condSysProstate => 'Простата';

  @override
  String get homeHeroLabTitle => 'Уверенная работа в лаборатории';

  @override
  String get homeHeroLabBody =>
      'Образцы, методики и контроль качества в одном месте.';

  @override
  String get homeHeroLabCta => 'Открыть контроль качества';

  @override
  String get homeHeroStudentTitle => 'Понимайте биохимию';

  @override
  String get homeHeroStudentBody =>
      'Тема → объяснение → практика → повторение.';

  @override
  String get homeHeroStudentCta => 'Начать обучение';

  @override
  String get homeHeroTeacherTitle => 'От знаний к занятию';

  @override
  String get homeHeroTeacherBody =>
      'Группы, вопросы с объяснениями и задания со сроками.';

  @override
  String get homeHeroTeacherCta => 'Открыть группы';

  @override
  String get homeQuickAccess => 'Быстрый доступ';

  @override
  String get homeUsefulTests => 'Полезные анализы';

  @override
  String get featureTests => 'Анализы';

  @override
  String get featureCalculators => 'Калькуляторы';

  @override
  String get featureSampleFactors => 'Факторы образца';

  @override
  String get featureSaved => 'Сохранённое';

  @override
  String get featureCalibration => 'Калибровка';

  @override
  String get featureQc => 'QC';

  @override
  String get featureSampling => 'Взятие образца';

  @override
  String get featureTopics => 'Темы';

  @override
  String get featureQuiz => 'Тест';

  @override
  String get featureMicroscopy => 'Микроскопия';

  @override
  String get featureExam => 'Экзамен';

  @override
  String get featureClasses => 'Группы';

  @override
  String get featureQuestionBank => 'Вопросы';

  @override
  String get featureSources => 'Источники';

  @override
  String get featureResearch => 'Исследования';

  @override
  String get testsTitle => 'Атлас анализов';

  @override
  String get testsSubtitle => 'От показателя к практической информации.';

  @override
  String get testsSearchLabel => 'Поиск анализа';

  @override
  String get testsSearchHint => 'АЛТ, креатинин, HbA1c…';

  @override
  String get testsFilterAll => 'Все';

  @override
  String get testsEmptyTitle => 'Ничего не найдено';

  @override
  String get testsEmptyBody =>
      'Попробуйте другое название, сокращение или синоним.';

  @override
  String get testsClearSearch => 'Очистить поиск';

  @override
  String testsResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count анализа',
      many: '$count анализов',
      few: '$count анализа',
      one: '$count анализ',
    );
    return '$_temp0';
  }

  @override
  String get statusDraft => 'Черновик';

  @override
  String get statusVerified => 'Проверено';

  @override
  String get statusPublished => 'Опубликовано';

  @override
  String get statusSourcedSample => 'Пример с источниками';

  @override
  String get statusStructureOnly => 'Только структура';

  @override
  String get contentLoading => 'Загрузка контента…';

  @override
  String get contentErrorTitle => 'Не удалось загрузить контент';

  @override
  String get contentErrorBody =>
      'Пакет контента не прошёл проверку. Непроверенные данные никогда не показываются.';

  @override
  String get analyteSave => 'Сохранить';

  @override
  String get analyteSaved => 'Сохранено';

  @override
  String get analyteSavedToast => 'Добавлено в сохранённое';

  @override
  String get analyteRemovedToast => 'Удалено из сохранённого';

  @override
  String get analyteNotFound => 'Карточка анализа не найдена.';

  @override
  String get analyteStructureOnlyTitle => 'Контент готовится';

  @override
  String get analyteStructureOnlyBody =>
      'В карточке пока только структура. Клинический текст добавляется после подбора источников и независимой экспертизы — общий текст не выдаётся за готовый.';

  @override
  String get analyteSampleNotice =>
      'Учебный пример на основе указанных источников. Ожидает независимой экспертизы — не для клинических решений.';

  @override
  String get analyteNotWritten =>
      'Ещё не написано: требуются источники и проверка.';

  @override
  String get analyteAtAGlance => 'Кратко';

  @override
  String get analyteSpecimen => 'Образец';

  @override
  String get analytePopulation => 'Популяция';

  @override
  String get analyteMethod => 'Метод';

  @override
  String get analyteMethodNotSet => 'Не указан — зависит от IFU реагента';

  @override
  String get analyteUnits => 'Единицы';

  @override
  String get analyteRefIntervals => 'Референсные интервалы';

  @override
  String get analyteRefIntervalNone =>
      'Референсный интервал здесь не приводится. Используйте интервал из бланка вашей лаборатории: он зависит от метода, образца и популяции.';

  @override
  String get analyteDecisionLimits => 'Диагностические пороги';

  @override
  String get analyteDecisionNotRef =>
      'Диагностические пороги — это не лабораторный референсный интервал.';

  @override
  String analyteSiNote(String unit, String mass) {
    return 'Значения в $unit в источнике не приводятся — они пересчитаны из пороговых значений источника в мг/дл по молярной массе ($mass г/моль) и округлены. Основной порог — значение источника в мг/дл.';
  }

  @override
  String analyteSiApprox(String value) {
    return '$value (расчётно)';
  }

  @override
  String get analyteNoInterpretation =>
      'LabGuide не интерпретирует отдельные результаты и не предлагает диагнозы или дозы.';

  @override
  String get analyteSources => 'Источники';

  @override
  String analyteSourceAccessed(String date) {
    return 'Дата обращения: $date';
  }

  @override
  String get analyteReuseRightsVerify =>
      'Права на использование: необходимо проверить перед распространением';

  @override
  String get analyteReview => 'Статус проверки';

  @override
  String get analyteReviewPending => 'Ожидает экспертизы';

  @override
  String get analyteReviewApproved => 'Проверено';

  @override
  String get analyteReviewerNotAssigned => 'Рецензент не назначен';

  @override
  String get analyteTranslationPending => 'Проверка перевода ожидается';

  @override
  String analyteContentVersion(String version) {
    return 'Версия контента $version';
  }

  @override
  String get analyteConvertUnits => 'Пересчёт единиц';

  @override
  String get analyteConvertUnitsSub => 'Коэффициент для данного вещества';

  @override
  String get analyteMethodCalibration => 'Методика и калибровка';

  @override
  String get analyteMethodCalibrationSub => 'IFU · QC';

  @override
  String get analyteCalculatorSub => 'Калькулятор · опубликованная формула';

  @override
  String get analytePractice => 'Закрепить тему';

  @override
  String get analytePracticeSub => 'Вопросы с объяснениями';

  @override
  String get analyteRelated => 'Связанные анализы';

  @override
  String get sectionPurpose => 'Для чего?';

  @override
  String get sectionPhysiology => 'Физиология';

  @override
  String get sectionHighResult => 'Повышенный результат';

  @override
  String get sectionLowResult => 'Пониженный результат';

  @override
  String get sectionPositiveResult => 'Положительный результат';

  @override
  String get sectionNegativeResult => 'Отрицательный результат';

  @override
  String get sectionResults => 'Что означает результат';

  @override
  String get sectionPreanalytics => 'Образец и преаналитика';

  @override
  String get sectionInterference => 'Интерференции';

  @override
  String get sectionLimitations => 'Ограничения';

  @override
  String get labTitle => 'Лаборатория';

  @override
  String get labSubtitle => 'Понятный путь на каждом этапе.';

  @override
  String get labHeroEyebrow => 'Практика';

  @override
  String get labHeroTitle => 'Прибор → реагент → метод';

  @override
  String get labHeroBody => 'Инструкции и контроль для конкретной модели.';

  @override
  String get labHeroCta => 'Открыть калибровку';

  @override
  String get labQcSub => 'Контрольные карты и правила';

  @override
  String get labPreanalytics => 'Преаналитика';

  @override
  String get labPreanalyticsSub => 'Подготовка, взятие, хранение, доставка';

  @override
  String get labCalculatorsSub => 'Разведения и единицы';

  @override
  String get labInstruments => 'Приборы и методики';

  @override
  String get labInstrumentsSub => 'Биохимия · гематология · иммунохимия · моча';

  @override
  String get labMicroscopySub => 'Сравнение изображений и структур';

  @override
  String get calTitle => 'Путь калибровки';

  @override
  String get calSubtitle =>
      'Для выбора инструкции необходимо точное соответствие.';

  @override
  String get calManufacturer => 'Производитель';

  @override
  String get calManufacturerOther => 'Другой';

  @override
  String get calModel => 'Модель прибора';

  @override
  String get calModelHint => 'Точное название модели';

  @override
  String get calReagentRef => 'REF реагента';

  @override
  String get calIfuRevision => 'Версия IFU';

  @override
  String get calCalibratorLot => 'Лот калибратора';

  @override
  String get calCheck => 'Проверить соответствие';

  @override
  String get calFieldsRequired => 'Укажите модель, REF реагента и версию IFU.';

  @override
  String get calNoMatchTitle =>
      'Для этой комбинации нет проверенной инструкции';

  @override
  String get calNoMatchBody =>
      'Параметры калибровки показываются только из проверенной IFU, совпадающей по производителю, модели, REF реагента, версии IFU и лоту калибратора. Используйте действующую IFU производителя.';

  @override
  String calCatalogCount(int count) {
    return 'Проверенных записей IFU в этой сборке: $count';
  }

  @override
  String get calBrandWarning =>
      'Название бренда (например, Mindray или HUMAN) не означает, что у всех моделей одинаковые настройки. IFU реагента и руководство к прибору — разные документы.';

  @override
  String get calWorkflow => 'Рабочая последовательность';

  @override
  String get calStep1 => 'Модель, реагент и версия инструкции';

  @override
  String get calStep2 => 'Лот калибратора и назначенные значения';

  @override
  String get calStep3 => 'Подготовка согласно методике';

  @override
  String get calStep4 => 'Калибровка по инструкции';

  @override
  String get calStep5 => 'QC после калибровки';

  @override
  String get calStep6 => 'Записи и поиск неисправностей';

  @override
  String get calNoServiceCodes =>
      'Сервисные коды и способы обхода защиты не включаются.';

  @override
  String get qcTitle => 'Контроль качества';

  @override
  String get qcChartTitle => 'Леви–Дженнингс';

  @override
  String get qcChartBody =>
      'Для графика нужны тест, лот контроля, уровень, целевое среднее и SD. Вымышленные результаты не отображаются.';

  @override
  String get qcEmptyTitle => 'Записей контроля пока нет';

  @override
  String get qcEmptyBody =>
      'Добавьте тест с уровнями контроля, чтобы начать график Леви–Дженнингса. Данные хранятся только на этом устройстве.';

  @override
  String get qcIntro =>
      'Введите целевое среднее и SD для каждого уровня контроля, затем записывайте каждую серию. Приложение проверяет правила Вестгарда и никогда не придумывает целевые значения или результаты.';

  @override
  String get qcLoadError =>
      'Не удалось прочитать сохранённые данные контроля качества. Ничего не перезаписано.';

  @override
  String get qcAddSet => 'Добавить тест';

  @override
  String get qcSetName => 'Название теста';

  @override
  String get qcUnit => 'Единица';

  @override
  String get qcTargetSource => 'Источник целевого среднего и SD';

  @override
  String get qcSourceLab => 'Данные нашей лаборатории';

  @override
  String get qcSourceManufacturer => 'Паспорт производителя';

  @override
  String qcLevel(String label) {
    return 'Уровень $label';
  }

  @override
  String qcLevelNamed(String label) {
    return 'Уровень «$label»';
  }

  @override
  String qcLevelsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count уровня',
      many: '$count уровней',
      few: '$count уровня',
      one: '$count уровень',
    );
    return '$_temp0';
  }

  @override
  String qcRunsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count серии',
      many: '$count серий',
      few: '$count серии',
      one: '$count серия',
      zero: 'нет серий',
    );
    return '$_temp0';
  }

  @override
  String get qcLot => 'Лот';

  @override
  String get qcMean => 'Целевое среднее';

  @override
  String get qcSd => 'Целевое SD';

  @override
  String get qcAddLevel => 'Добавить уровень';

  @override
  String get qcRemoveLevel => 'Удалить уровень';

  @override
  String get qcSave => 'Сохранить';

  @override
  String get qcTargetNote =>
      'Westgard и соавт. (1981) рассчитывают среднее и SD по собственным контрольным измерениям лаборатории — сначала примерно по 20 (одна серия в день), затем пересматривают по мере накопления данных. Приложение эти значения не предоставляет.';

  @override
  String get qcManufacturerWarning =>
      'Значения производителя — лишь ориентир; уроки Вестгарда рекомендуют пределы, рассчитанные по собственным контрольным данным, — диапазоны из паспорта часто слишком широки.';

  @override
  String get qcErrName => 'Введите название теста.';

  @override
  String qcErrLevel(String label) {
    return '$label: введите среднее и SD больше нуля.';
  }

  @override
  String get qcAccept => 'Принята';

  @override
  String get qcWarning => 'Предупреждение';

  @override
  String get qcReject => 'Отклонена';

  @override
  String get qcAcceptBody => 'Ни одно правило не нарушено.';

  @override
  String get qcLatestRun => 'Последняя серия';

  @override
  String get qcNoRunsYet => 'Серий пока нет — добавьте первую ниже.';

  @override
  String get qcAddRun => 'Добавить серию';

  @override
  String get qcNote => 'Примечание (необязательно)';

  @override
  String get qcSaveRun => 'Сохранить серию';

  @override
  String get qcErrRunEmpty => 'Введите хотя бы одно контрольное значение.';

  @override
  String qcErrRunInvalid(String label) {
    return '$label: не число.';
  }

  @override
  String get qcRunHistory => 'Серии';

  @override
  String get qcStats => 'Наблюдаемые';

  @override
  String get qcChartLegend => '● в пределах   ▲ предупреждение   ■ отклонено';

  @override
  String qcChartSemantics(String label, int count) {
    return 'График Леви–Дженнингса, $label: значений $count';
  }

  @override
  String get qcDeleteRun => 'Удалить серию';

  @override
  String get qcDeleteSet => 'Удалить тест и все серии';

  @override
  String get qcConfirmDelete => 'Это нельзя отменить.';

  @override
  String get qcSetMissing => 'Этого теста больше нет.';

  @override
  String get qcCopyCsv => 'Скопировать серии таблицей (CSV)';

  @override
  String qcCopied(int count) {
    return 'Скопировано строк: $count — вставьте в Excel или Google Таблицы';
  }

  @override
  String get qcChangeTarget => 'Сменить цель или лот';

  @override
  String get qcChangeTargetBody =>
      'Используйте при переходе на новый лот контроля или после пересчёта среднего и SD лабораторией. Новые значения действуют с выбранного времени (обычно с этого момента); прежние серии по-прежнему оцениваются по действовавшим тогда целям.';

  @override
  String get qcErrTarget => 'Введите среднее и SD больше нуля.';

  @override
  String qcSince(String date) {
    return 'с $date';
  }

  @override
  String qcPreviousTarget(String target, String date) {
    return 'Ранее: $target (с $date)';
  }

  @override
  String get qcRulesSource =>
      'Правила: мультиправило Вестгарда (Westgard JO и соавт., Clin Chem 1981; doi:10.1093/clinchem/27.3.493). Средство обучения и проверки — не заменяет процедуру контроля качества вашей лаборатории.';

  @override
  String get qcGuidesTitle => 'Памятки';

  @override
  String get qgRejected => 'Что делать, если QC отклонён';

  @override
  String get qgRejectedSub => 'Остановить, найти причину, перепроверить';

  @override
  String get qgEqa => 'Внешний контроль качества (EQA)';

  @override
  String get qgEqaSub => 'Что это, как работает, если результат плохой';

  @override
  String get qgCritical => 'Критические значения';

  @override
  String get qgCriticalSub => 'Кто составляет список и как сообщать';

  @override
  String get qgWhatToDo => 'Что делать?';

  @override
  String get qcErrSave => 'Не удалось сохранить. Попробуйте ещё раз.';

  @override
  String qcErrNotFinite(String label) {
    return '$label: значение слишком велико или слишком мало.';
  }

  @override
  String get qcLevelName => 'Название уровня (необязательно, напр. «Низкий»)';

  @override
  String get qcStatsExcluded => 'Отклонённые серии не учитываются.';

  @override
  String qcStatsFew(int count) {
    return 'n = $count: значений пока мало — Westgard и соавт. (1981) рассчитывают цель сначала примерно по 20 значениям.';
  }

  @override
  String qcUseObserved(int count) {
    return 'Подставить наблюдаемые x̄ и SD (n = $count)';
  }

  @override
  String get qcEffectiveFrom => 'Действует с';

  @override
  String get qcFromNow => 'С этого момента';

  @override
  String qcFromDate(String date) {
    return 'С $date';
  }

  @override
  String get qcPickDate => 'Выбрать дату';

  @override
  String qcRunTime(String time) {
    return 'Время серии: $time';
  }

  @override
  String get qcRunTimeNow => 'сейчас';

  @override
  String get qcRunTimeHint =>
      'Для серии, внесённой с опозданием, выберите фактическое время измерения — правила проверяют серии по порядку времени.';

  @override
  String qcShowAllRuns(int count) {
    return 'Показать все ($count)';
  }

  @override
  String get qcRejectedExcluded =>
      'Не используется в следующих правилах и статистике';

  @override
  String qcAtEntry(String verdict) {
    return 'При вводе: $verdict';
  }

  @override
  String get qcUndoTarget => 'Отменить последнее изменение';

  @override
  String qcUndoTargetBody(String target) {
    return 'Текущая цель будет удалена, вернётся предыдущая: $target. Серии будут переоценены.';
  }

  @override
  String get qcBackupTitle => 'Резервная копия';

  @override
  String get qcBackupBody =>
      'Данные контроля качества хранятся только на этом устройстве. Скопируйте резервную копию (JSON) и сохраните в надёжном месте; на другом устройстве её можно восстановить из буфера.';

  @override
  String get qcBackupCopy => 'Скопировать резервную копию';

  @override
  String get qcBackupCopied => 'Резервная копия скопирована в буфер';

  @override
  String get qcBackupRestore => 'Восстановить из буфера';

  @override
  String qcRestoreConfirm(int sets, int runs) {
    return 'Текущие данные контроля качества будут заменены резервной копией из буфера: тестов — $sets, серий — $runs.';
  }

  @override
  String get qcRestoreAction => 'Заменить';

  @override
  String get qcRestoreInvalid =>
      'В буфере нет корректной резервной копии контроля качества.';

  @override
  String get qcRestored => 'Данные контроля качества восстановлены';

  @override
  String get qcCopyRaw => 'Скопировать сохранённый текст';

  @override
  String get qcDiscard => 'Удалить нечитаемые данные';

  @override
  String get qcDiscardConfirm =>
      'Сначала скопируйте сохранённый текст. После удаления его нельзя вернуть.';

  @override
  String get preTitle => 'Путь образца';

  @override
  String get preStep1 => 'Подготовка к анализу';

  @override
  String get preStep2 => 'Выбор образца и добавки';

  @override
  String get preStep3 => 'Взятие и идентификация';

  @override
  String get preStep4 => 'Разделение и хранение';

  @override
  String get preStep5 => 'Доставка и приём';

  @override
  String get preNotice =>
      'Цвет пробирки, время и температура привязаны к конкретной пробирке, методу и инструкции. Универсальные параметры не приводятся.';

  @override
  String get diffTitle => 'Лейкоформула';

  @override
  String get diffSubtitle => 'Узнать клетки, посчитать, интерпретировать';

  @override
  String get diffLabCardBody =>
      'Счётчик для ручного подсчёта, атлас клеток и интерпретация';

  @override
  String get diffHeroTitle => 'Читайте лейкоформулу уверенно';

  @override
  String get diffHeroBody =>
      'Схемы клеток, счётчик с крупными кнопками, интерпретация и техника мазка — в одном месте.';

  @override
  String get diffStartCount => 'Начать подсчёт';

  @override
  String diffResumeCount(int count, int target) {
    return 'Продолжить подсчёт ($count/$target)';
  }

  @override
  String get diffCellsTitle => 'Как узнать клетку';

  @override
  String diffCellsSub(int count) {
    return '$count клеток: размер, ядро, цитоплазма, гранулы';
  }

  @override
  String get diffConfusionsTitle => 'Частые ошибки';

  @override
  String get diffConfusionsSub =>
      'Реактивный лимфоцит или моноцит? Палочка или сегмент?';

  @override
  String get diffCounterTitle => 'Счётчик';

  @override
  String get diffCounterSub =>
      'Нажатие +1, долгое нажатие −1; 100 или 200 клеток';

  @override
  String get diffHistoryTitle => 'Сохранённые результаты';

  @override
  String diffHistorySub(int count) {
    return 'Результатов: $count — только на этом устройстве';
  }

  @override
  String get diffInterpretTitle => 'Интерпретация';

  @override
  String get diffInterpretSub =>
      'Сдвиг влево, нейтрофилия, лимфоцитоз и другое';

  @override
  String get diffTechniqueTitle => 'Техника мазка и ошибки';

  @override
  String get diffTechniqueSub => 'Приготовление, окраска, где считать';

  @override
  String get diffQuizTitle => 'Тренажёр «Что это за клетка?»';

  @override
  String diffQuizSub(int count) {
    return 'Вопросов: $count, со схемами';
  }

  @override
  String get diffLearnSub =>
      'Атлас клеток, счётчик и тренажёр «Что это за клетка?»';

  @override
  String get diffSourcesTitle => 'Источники';

  @override
  String get diffDraftTag => 'Черновик · на проверке у специалиста';

  @override
  String get diffDraftNote =>
      'Раздел не прошёл проверку специалиста. Результат — не диагноз; референсы — на бланке вашей лаборатории.';

  @override
  String get diffSchematicCaption =>
      'Схематичный рисунок (нарисован LabGuide) — не микрофото';

  @override
  String get diffScaleNote =>
      'Все схемы в одном масштабе; эритроциты вокруг (~7,5 мкм) — для сравнения размеров.';

  @override
  String get diffRelatedCards => 'Карточки анализов';

  @override
  String get diffSize => 'Размер';

  @override
  String get diffNucleus => 'Ядро';

  @override
  String get diffCytoplasm => 'Цитоплазма';

  @override
  String get diffGranules => 'Гранулы';

  @override
  String get diffKeySign => 'Главный признак';

  @override
  String get diffSeenIn => 'Когда встречается';

  @override
  String get diffReferTitle => 'Направьте врачу или гематологу';

  @override
  String get diffReferBody =>
      'Если видите бласт или неопознанную клетку — не интерпретируйте сами. Мазок должен посмотреть гематолог или врач по порядку вашей лаборатории.';

  @override
  String get diffCompareA => 'Слева';

  @override
  String get diffCompareB => 'Справа';

  @override
  String get diffFeature => 'Признак';

  @override
  String get diffTip => 'Совет';

  @override
  String get diffOpenCell => 'Подробнее';

  @override
  String get diffTargetLabel => 'Сколько клеток считать';

  @override
  String get diffWbcLabel => 'Лейкоциты (WBC), ×10⁹/л — необязательно';

  @override
  String get diffWbcHint => 'например, 7,5';

  @override
  String get diffWbcInvalid => 'Введите положительное число (например, 7,5)';

  @override
  String get diffTapHint => 'Нажатие: +1 · Долгое нажатие: −1';

  @override
  String get diffUndo => 'Отменить последнее';

  @override
  String get diffReset => 'Сначала';

  @override
  String get diffResetTitle => 'Очистить подсчёт?';

  @override
  String diffResetBody(int count) {
    return 'Будет удалено подсчитанных клеток: $count.';
  }

  @override
  String get diffResetConfirm => 'Очистить';

  @override
  String diffDoneTitle(int target) {
    return 'Подсчитано $target клеток';
  }

  @override
  String get diffDoneBody =>
      'Подсчёт остановлен. Проверьте результат, сохраните или скопируйте.';

  @override
  String get diffBlocked => 'Цель достигнута — нажатие не добавлено';

  @override
  String get diffResultTitle => 'Результат';

  @override
  String get diffColCell => 'Клетка';

  @override
  String get diffColCount => 'Число';

  @override
  String get diffColAbs => '×10⁹/л';

  @override
  String get diffAbsNeedWbc => 'Для абсолютных чисел введите WBC.';

  @override
  String get diffOtherWarning =>
      'Подсчитаны «другие» клетки. Если это бласты или неопознанные клетки — мазок должен посмотреть гематолог или врач.';

  @override
  String get diffSave => 'Сохранить в историю';

  @override
  String get diffSaved => 'Результат сохранён (только на этом устройстве)';

  @override
  String get diffLabelField => 'Метка образца (необязательно, без ФИО)';

  @override
  String get diffLabelHint => 'например, образец 12';

  @override
  String get diffCopy => 'Копировать';

  @override
  String get diffCopied => 'Результат скопирован';

  @override
  String diffCopyHeader(int total) {
    return 'Лейкоформула ($total клеток)';
  }

  @override
  String get diffCopyFooter =>
      'LabGuide · ручной подсчёт. Референс — на бланке лаборатории.';

  @override
  String diffWbcLine(String value) {
    return 'WBC: $value ×10⁹/л';
  }

  @override
  String diffButtonSemantics(String cell, int count) {
    return '$cell: $count. Нажмите — добавить, удерживайте — убавить.';
  }

  @override
  String get diffDecrementAction => 'Убавить на один';

  @override
  String get diffHistoryEmptyTitle => 'Сохранённых результатов пока нет';

  @override
  String get diffHistoryEmptyBody =>
      'Закончите подсчёт и нажмите «Сохранить в историю».';

  @override
  String get diffHistoryClear => 'Удалить все';

  @override
  String get diffHistoryClearTitle => 'Удалить историю?';

  @override
  String diffHistoryClearBody(int count) {
    return 'С этого устройства будет удалено результатов: $count.';
  }

  @override
  String get diffDeleted => 'Результат удалён';

  @override
  String get diffHistoryLocalNote =>
      'Результаты хранятся только на этом устройстве и не отправляются на сервер. «Удалить локальные данные» в профиле удалит и их.';

  @override
  String get diffInterpretIntro =>
      'Интерпретация всегда — вместе с референсом и клиникой. Референс — на бланке вашей лаборатории; причины ниже лишь возможные, это не диагноз.';

  @override
  String get diffPossibleCauses => 'Возможные причины';

  @override
  String get diffAbsNote =>
      'Если резко растёт один тип, проценты остальных падают. Поэтому смотрите абсолютные числа (доля × WBC).';

  @override
  String get diffRangesTitle => 'Почему приложение не даёт «норму»?';

  @override
  String get diffRangesBody =>
      'Даже в двух открытых источниках примерные интервалы для взрослых (%) различаются. В отчёте используется только референс с бланка вашей лаборатории; у детей интервалы зависят от возраста.';

  @override
  String get diffRangesWho => 'ВОЗ 2003';

  @override
  String get diffRangesMedline => 'MedlinePlus';

  @override
  String get diffQuizPrompt => 'Что это за клетка?';

  @override
  String get diffQuizIntro =>
      'Выберите клетку по схеме. Вопросы каждый раз перемешиваются; после ответа показан отличительный признак.';

  @override
  String get diffQuizStart => 'Начать тренировку';

  @override
  String get diffRealSmear => 'Настоящий мазок';

  @override
  String get diffRealSmearNote =>
      'Лицензированное микрофото из атласа микроскопии. Автор и лицензия — при открытии снимка.';

  @override
  String get diffAtlasRow => 'Настоящие мазки крови';

  @override
  String get diffAtlasRowSub =>
      'Лицензированные микрофото из атласа микроскопии';

  @override
  String diffQuizExtended(int count) {
    return 'Расширенная тренировка ($count вопросов)';
  }

  @override
  String get diffQuizExtendedIntro =>
      'В дополнение к вопросам по схемам: узнайте клетку по описанию ядра, цитоплазмы и гранул.';

  @override
  String get diffQuizDescribed => 'Какая клетка соответствует описанию?';

  @override
  String diffHistoryMore(int count) {
    return 'Ещё результатов на устройстве: $count';
  }

  @override
  String get preOrderTitle => 'Порядок взятия пробирок (венепункция)';

  @override
  String get preOrderSub =>
      'ВОЗ 2010, табл. 2.3 (на основе консенсуса NCCLS 2003). Сверяйте с действующим порядком вашей лаборатории.';

  @override
  String preCap(String cap) {
    return 'Крышка: $cap';
  }

  @override
  String get preHaemolysisTitle => 'Причины гемолиза';

  @override
  String get preTourniquetTitle => 'Жгут';

  @override
  String get preIdTitle => 'Идентификация пациента и маркировка';

  @override
  String get calcTitle => 'Калькуляторы';

  @override
  String get calcLearningTag => 'Учебный калькулятор';

  @override
  String get calcDilution => 'Разведение';

  @override
  String get calcDilutionSub => 'C₁V₁ = C₂V₂';

  @override
  String get calcUnits => 'Пересчёт единиц';

  @override
  String get calcUnitsSub => 'Для конкретного вещества';

  @override
  String get calcSectionManual => 'Ручные методы';

  @override
  String get mcChamber => 'Счётная камера';

  @override
  String get mcChamberSub => 'Горяев, Нейбауэр: клеток/мкл и ×10⁹/л';

  @override
  String get mcDiff => 'Лейкоформула: абсолютные числа';

  @override
  String get mcDiffSub => 'WBC × %, поправка на нормобласты';

  @override
  String get mcRetic => 'Ретикулоциты';

  @override
  String get mcReticSub => '%, исправленный % и RPI';

  @override
  String get mcLight => 'Критерии Лайта';

  @override
  String get mcLightSub => 'Плевральная жидкость: экссудат или транссудат';

  @override
  String get mcColour => 'Цветовой показатель';

  @override
  String get mcColourSub => 'Почему приложение рекомендует MCH и MCHC';

  @override
  String get mfCells => 'Подсчитано клеток';

  @override
  String get mfSquares => 'Число подсчитанных квадратов';

  @override
  String get mfSquareArea => 'Площадь одного квадрата';

  @override
  String get mfDepth => 'Глубина камеры';

  @override
  String get mfDilution => 'Степень разведения (для 1:20 — 20)';

  @override
  String get mfWbc => 'Лейкоциты (WBC)';

  @override
  String get mfSeg => 'Сегментоядерные нейтрофилы';

  @override
  String get mfBand => 'Палочкоядерные нейтрофилы';

  @override
  String get mfEos => 'Эозинофилы';

  @override
  String get mfBaso => 'Базофилы';

  @override
  String get mfLymph => 'Лимфоциты';

  @override
  String get mfMono => 'Моноциты';

  @override
  String get mfOther => 'Другие клетки';

  @override
  String get mfNrbc => 'Нормобласты на 100 лейкоцитов';

  @override
  String get mfReticCounted => 'Подсчитано ретикулоцитов';

  @override
  String get mfRbcExamined => 'Просмотрено эритроцитов';

  @override
  String get mfHct => 'Гематокрит (Ht)';

  @override
  String get mfRbc => 'Эритроциты (RBC)';

  @override
  String get mfMaturation => 'Поправка на созревание';

  @override
  String get mfMaturationAuto => 'Авто';

  @override
  String get mfPfProtein => 'Жидкость: общий белок';

  @override
  String get mfSerumProtein => 'Сыворотка: общий белок';

  @override
  String get mfPfLdh => 'Жидкость: ЛДГ';

  @override
  String get mfSerumLdh => 'Сыворотка: ЛДГ';

  @override
  String get mfLdhUln => 'Верхняя граница нормы ЛДГ сыворотки';

  @override
  String get mfSameUnit =>
      'Оба значения в паре — в одних единицах (например, оба г/л, оба Ед/л).';

  @override
  String get mrCellsPerUl => 'клеток/мкл';

  @override
  String get mrVolume => 'Подсчитанный объём';

  @override
  String get mrWbcUsed => 'Исправленный WBC';

  @override
  String get mrNrbc => 'Нормобласты';

  @override
  String get mrPercentSum => 'Сумма процентов';

  @override
  String get mrAbsolute => 'Абсолютные числа';

  @override
  String get mrNoCorrection => 'Нормобласты не введены — WBC не исправлен.';

  @override
  String get mrReticAbs => 'Абсолютное число';

  @override
  String get mrReticCorrected => 'Исправленный %';

  @override
  String get mrRpi => 'Индекс продукции ретикулоцитов (RPI)';

  @override
  String mrMaturationAuto(String factor, String hct) {
    return 'Поправка $factor: ближайшая к Ht $hct % точка таблицы (правило приложения).';
  }

  @override
  String mrMaturationChosen(String factor) {
    return 'Поправка $factor: выбрана вами.';
  }

  @override
  String get mrNoRbc => 'Для абсолютного числа введите RBC.';

  @override
  String get mrExudate => 'Соответствует критериям экссудата';

  @override
  String get mrTransudate =>
      'Ни один критерий не выполнен — соответствует транссудату';

  @override
  String get mrIncomplete =>
      'Два критерия не выполнены; для третьего введите верхнюю границу ЛДГ';

  @override
  String get mrProteinRatio => 'Белок: жидкость ÷ сыворотка (> 0,5)';

  @override
  String get mrLdhRatio => 'ЛДГ: жидкость ÷ сыворотка (> 0,6)';

  @override
  String get mrLdhUln => 'ЛДГ жидкости ÷ верхняя граница (> 2/3)';

  @override
  String get mrMet => 'выполнен';

  @override
  String get mrNotMet => 'не выполнен';

  @override
  String get mrNotAssessed => 'не оценён';

  @override
  String mErrSum(String sum) {
    return 'Сумма процентов $sum — должна быть 100. Проверьте строки.';
  }

  @override
  String get mErrReticGtExamined =>
      'Ретикулоцитов не может быть больше, чем просмотренных эритроцитов.';

  @override
  String mErrWhole(String field, String min, String max) {
    return '$field: введите целое число ($min–$max).';
  }

  @override
  String get ciWhatTitle => 'Что это?';

  @override
  String get ciWhat =>
      'Цветовой показатель — относительный показатель, традиционно применяемый в лабораториях СНГ: оценивает содержание гемоглобина в одном эритроците относительно «нормы». Используется для обозначения гипо-, нормо- или гиперхромии эритроцитов.';

  @override
  String get ciWhyTitle => 'Почему приложение его не рассчитывает';

  @override
  String get ciWhy =>
      'Для формулы не найден первичный открытый источник, который мы могли бы проверить. Приложение не даёт чисел и формул без источника.';

  @override
  String get ciUseTitle => 'Что использовать вместо него';

  @override
  String get ciUse =>
      'Гемоглобин в одном эритроците прямо выражает MCH (среднее содержание гемоглобина, пг), а концентрацию гемоглобина в эритроците — MCHC. Гематологический анализатор выдаёт оба. Гипо-/гиперхромию оценивайте по ним и референсным интервалам вашей лаборатории.';

  @override
  String get dilC1 => 'C₁ · Исходная концентрация';

  @override
  String get dilC2 => 'C₂ · Конечная концентрация';

  @override
  String get dilV2 => 'V₂ · Конечный объём (мл)';

  @override
  String get dilNote =>
      'Единицы C₁ и C₂ должны совпадать. Простая модель разведения: реакции, безопасность и изменение объёма не учитываются.';

  @override
  String get dilCalculate => 'Рассчитать';

  @override
  String dilResult(String volume) {
    return 'V₁ = $volume мл';
  }

  @override
  String get dilResultBody =>
      'Объём исходного раствора. Доведите общий конечный объём до V₂.';

  @override
  String dilDiluent(String volume) {
    return 'Разбавитель ≈ $volume мл (если объёмы складываются)';
  }

  @override
  String get dilNoDilution => 'C₂ = C₁: разведение не требуется.';

  @override
  String get dilErrorInvalid => 'Введите число больше нуля в каждое поле.';

  @override
  String get dilErrorC2GtC1 =>
      'C₂ не может превышать C₁: разведение не повышает концентрацию.';

  @override
  String get dilErrorRange => 'Значения вне допустимого диапазона расчёта.';

  @override
  String get ucTitle => 'Пересчёт единиц';

  @override
  String get ucSubtitle =>
      'У каждого вещества свой коэффициент — один общий коэффициент мг/дл → ммоль/л был бы ошибкой.';

  @override
  String get ucAnalyte => 'Вещество';

  @override
  String get ucValue => 'Значение';

  @override
  String get ucSwap => 'Поменять единицы';

  @override
  String get ucConvert => 'Пересчитать';

  @override
  String ucNote(String mass) {
    return 'Рассчитано по молярной массе $mass г/моль. Лаборатории могут округлять иначе; используйте единицы вашей лаборатории.';
  }

  @override
  String get ucNotAvailable =>
      'Для этого вещества нет проверенной молярной массы, поэтому пересчёт не предлагается.';

  @override
  String get ucErrorInvalid => 'Введите число 0 или больше.';

  @override
  String get ucErrorRange => 'Значение вне допустимого диапазона расчёта.';

  @override
  String get calcSectionClinical => 'Клинические формулы';

  @override
  String get calcSectionLab => 'Лабораторные';

  @override
  String get calcEgfr => 'рСКФ (eGFR) · CKD‑EPI 2021';

  @override
  String get calcEgfrSub => 'Креатинин, возраст, пол';

  @override
  String get calcAcr => 'Альбумин/креатинин';

  @override
  String get calcAcrSub => 'ACR мочи · категория A по KDIGO';

  @override
  String get calcAnionGap => 'Анионный интервал';

  @override
  String get calcAnionGapSub => 'Na, Cl, HCO₃ · K и альбумин по желанию';

  @override
  String get calcCalcium => 'Скорректированный кальций';

  @override
  String get calcCalciumSub => 'По альбумину · Payne 1973';

  @override
  String get calcLdl => 'ХС ЛПНП и ХС не-ЛПВП';

  @override
  String get calcLdlSub => 'Фридевальд · Сэмпсон';

  @override
  String get calcOsmo => 'Расчётная осмоляльность';

  @override
  String get calcOsmoSub => 'И осмоляльный зазор';

  @override
  String get calcHba1c => 'HbA1c: единицы и eAG';

  @override
  String get calcHba1cSub => 'NGSP ↔ IFCC · ADAG';

  @override
  String get calcFormulaTag => 'Опубликованная формула';

  @override
  String get calcOptional => 'необязательно';

  @override
  String get calcNotDiagnosis =>
      'Вспомогательный расчёт для обучения и проверки. Не ставит диагноз: интерпретируйте результат с учётом клинической картины и референсных интервалов вашей лаборатории.';

  @override
  String calcUnitCheck(String field, String value, String unit) {
    return '$field: $value $unit — необычное значение для этой единицы; проверьте, правильно ли выбрана единица.';
  }

  @override
  String calcInputs(String list) {
    return 'Введено: $list';
  }

  @override
  String calcNegativeCheck(String name) {
    return '$name: отрицательное значение — проверьте введённые значения и единицы.';
  }

  @override
  String calcUnitGroup(String field) {
    return 'Единица: $field';
  }

  @override
  String get calcFormula => 'Формула';

  @override
  String get calcLimitations => 'Ограничения';

  @override
  String get calcSources => 'Источники';

  @override
  String get fieldCreatinine => 'Креатинин сыворотки';

  @override
  String get fieldAge => 'Возраст, лет';

  @override
  String get fieldSex => 'Пол';

  @override
  String get fieldSodium => 'Натрий (Na⁺)';

  @override
  String get fieldChloride => 'Хлорид (Cl⁻)';

  @override
  String get fieldBicarbonate => 'Бикарбонат (HCO₃⁻)';

  @override
  String get fieldPotassium => 'Калий (K⁺)';

  @override
  String get fieldAlbumin => 'Альбумин сыворотки';

  @override
  String get fieldNormalAlbumin =>
      'Нормальный альбумин, принятый в вашей лаборатории';

  @override
  String get fieldCalcium => 'Общий кальций сыворотки';

  @override
  String get fieldTotalCholesterol => 'Общий холестерин';

  @override
  String get fieldHdl => 'ХС ЛПВП';

  @override
  String get fieldTriglycerides => 'Триглицериды';

  @override
  String get fieldGlucose => 'Глюкоза';

  @override
  String get fieldUrea => 'Мочевина (или BUN)';

  @override
  String get fieldMeasuredOsmolality => 'Измеренная осмоляльность';

  @override
  String get fieldHba1c => 'HbA1c';

  @override
  String get fieldUrineAlbumin => 'Альбумин мочи';

  @override
  String get fieldUrineCreatinine => 'Креатинин мочи';

  @override
  String get sexFemale => 'Женский';

  @override
  String get sexMale => 'Мужской';

  @override
  String resGfrCategory(String code) {
    return 'Категория СКФ по KDIGO: $code';
  }

  @override
  String resAlbCategory(String code) {
    return 'Категория альбуминурии по KDIGO: $code';
  }

  @override
  String get resCategoryBasisSi => 'Определена по порогам в мг/ммоль.';

  @override
  String get resCategoryBasisConv => 'Определена по порогам в мг/г.';

  @override
  String get resAnionGap => 'Анионный интервал';

  @override
  String get resAnionGapK => 'С калием';

  @override
  String get resAnionGapAlb => 'С поправкой на альбумин (Figge)';

  @override
  String get resCorrectedCa => 'Скорректированный кальций (Payne)';

  @override
  String get resNonHdl => 'ХС не-ЛПВП';

  @override
  String get resLdlFriedewald => 'ХС ЛПНП · Фридевальд';

  @override
  String get resLdlSampson => 'ХС ЛПНП · Сэмпсон';

  @override
  String get resOsmCalc => 'Расчётная осмоляльность';

  @override
  String get resOsmGap => 'Осмоляльный зазор';

  @override
  String get resEag => 'Расчётная средняя глюкоза (eAG)';

  @override
  String errCalcMissing(String field) {
    return 'Введите число: $field.';
  }

  @override
  String errCalcImplausible(String field, String min, String max, String unit) {
    return '$field: вне диапазона, который принимает калькулятор ($min–$max$unit). Проверьте значение и единицы.';
  }

  @override
  String get errEgfrAge =>
      'Уравнение CKD-EPI 2021 разработано на участниках 18 лет и старше; у детей не рассчитывается.';

  @override
  String errFriedewaldTg(String limit) {
    return 'Не рассчитано: при триглицеридах выше $limit формула Фридевальда ненадёжна.';
  }

  @override
  String errSampsonTg(String limit) {
    return 'Не рассчитано: уравнение Сэмпсона проверено при триглицеридах до $limit.';
  }

  @override
  String errEagRange(String range) {
    return 'eAG не показан: данные ADAG охватывают HbA1c $range.';
  }

  @override
  String get errHdlGeTc =>
      'ХС ЛПВП не может быть больше общего холестерина или равен ему.';

  @override
  String get errNotPositive =>
      'Не рассчитано: результат не положительный — проверьте значения.';

  @override
  String get errSexMissing => 'Выберите пол.';

  @override
  String get micTitle => 'Атлас микроскопии';

  @override
  String get micSubtitle =>
      'Моча, кровь и паразиты — лицензированные микрофотографии';

  @override
  String get micAtlasError => 'Не удалось открыть атлас';

  @override
  String get micNotFound => 'Такое изображение или раздел не найдены';

  @override
  String micImagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count снимка',
      many: '$count снимков',
      few: '$count снимка',
      one: '$count снимок',
    );
    return '$_temp0';
  }

  @override
  String micGapsCount(int count) {
    return 'Без снимка пока: $count';
  }

  @override
  String micResultsCount(int count) {
    return 'Найдено: $count';
  }

  @override
  String get micSearchLabel => 'Поиск по атласу';

  @override
  String get micSearchHint => 'Например: нейтрофил, oxalate, bezgak';

  @override
  String get micNoResultsTitle => 'Ничего не найдено';

  @override
  String get micNoResultsBody =>
      'Попробуйте другое название или другой язык (uz, ru, en).';

  @override
  String get micSections => 'Разделы';

  @override
  String get micEduNotice =>
      'Учебные изображения — не для диагностики. У каждого снимка указаны автор, лицензия и исходная подпись. Пояснения LabGuide — черновик, ожидают проверки специалиста.';

  @override
  String get micEduTag => 'Учебный снимок — не для диагностики';

  @override
  String get micNoImageYet => 'Лицензированного снимка пока нет';

  @override
  String get micGapWhy => 'Почему нет?';

  @override
  String get micAllGroups => 'Все';

  @override
  String get micSectionQuiz => 'Тренировка по этому разделу';

  @override
  String get micZoom => 'Увеличить';

  @override
  String micOpenFull(String name) {
    return '$name — открыть на весь экран';
  }

  @override
  String micImageSemantics(String name) {
    return 'Микрофотография: $name';
  }

  @override
  String get micNames => 'Название на трёх языках';

  @override
  String get micOriginalCaption => 'Исходная подпись';

  @override
  String micCaptionLang(String lang) {
    return 'На языке источника, дословно · $lang';
  }

  @override
  String get micTranslation => 'Перевод (LabGuide)';

  @override
  String get micLangEn => 'английский';

  @override
  String get micLangEs => 'испанский';

  @override
  String get micLangRu => 'русский';

  @override
  String get micPreparation => 'Препарат';

  @override
  String get micMagnification => 'Увеличение';

  @override
  String get micStain => 'Окраска';

  @override
  String get micNotStated => 'в источнике не указано';

  @override
  String get micOnlySource => 'Показано только то, что указано в источнике.';

  @override
  String get micDraftTitle => 'На что обратить внимание';

  @override
  String get micDraftTag => 'Черновик · ожидает проверки специалиста';

  @override
  String get micCreditTitle => 'Автор и лицензия';

  @override
  String get micAuthor => 'Автор';

  @override
  String get micAuthorPage => 'Страница автора';

  @override
  String get micLabelBySource => 'Название — по подписи источника';

  @override
  String get micLabelNoQuiz => 'Не входит в упражнение';

  @override
  String get micCredit => 'Источник';

  @override
  String get micOwnWork => 'Собственная работа автора (Own work)';

  @override
  String get micLicense => 'Лицензия';

  @override
  String get micSourceDate => 'Дата в источнике';

  @override
  String micLicenseText(String license) {
    return 'Текст лицензии: $license';
  }

  @override
  String get micSourcePage => 'Страница источника';

  @override
  String get micOriginalFile => 'Исходный файл';

  @override
  String micResized(int width, int height, int origWidth, int origHeight) {
    return 'Копия в приложении: $width×$height px (оригинал $origWidth×$origHeight px, только уменьшено). Без обрезки и надписей.';
  }

  @override
  String micNotResized(int width, int height) {
    return 'Копия в приложении: $width×$height px, в исходном размере. Без обрезки и надписей.';
  }

  @override
  String get micShareAlike =>
      'CC BY-SA: производные версии этого снимка распространяются под той же лицензией.';

  @override
  String get micCdcTerms =>
      'Условия использования (со страницы CDC PHIL, дословно)';

  @override
  String get micCdcFree =>
      'Бесплатный источник: CDC Public Health Image Library (PHIL), wwwn.cdc.gov/phil';

  @override
  String get micSameEntity => 'Другие снимки этого типа';

  @override
  String get micCreditsTitle => 'Авторы снимков';

  @override
  String get micCreditsSub => 'Лицензии и источники';

  @override
  String micCreditsIntro(String date) {
    return 'Лицензия, автор и исходная подпись каждого снимка перепроверены на странице источника ($date). Снимки только уменьшены: без обрезки и надписей, EXIF удалён. Берутся только снимки CC0, CC BY, CC BY-SA, public domain и CDC PHIL.';
  }

  @override
  String get micLicenseTexts => 'Тексты лицензий';

  @override
  String get micCreditsRow => 'Авторы и лицензии';

  @override
  String get micCreditsRowSub =>
      'Источник и условия использования каждого снимка';

  @override
  String get micClose => 'Закрыть';

  @override
  String get micZoomIn => 'Увеличить';

  @override
  String get micZoomOut => 'Уменьшить';

  @override
  String get micZoomReset => 'Исходный вид';

  @override
  String get micViewerHint =>
      'Увеличивайте двумя пальцами или двойным касанием';

  @override
  String get micHeroEyebrow => 'Тренировка';

  @override
  String get micQuizTitle => 'Что это?';

  @override
  String get micQuizSubtitle => 'Тренировка по микроскопии';

  @override
  String get micQuizHeroBody =>
      'Посмотрите на снимок и выберите верное название: 4 варианта, все из атласа. Ответ — сразу.';

  @override
  String get micQuizCta => 'Начать тренировку';

  @override
  String get micQuizScope => 'Из какого раздела?';

  @override
  String micQuizScopeChip(String name, int count) {
    return '$name · $count';
  }

  @override
  String micQuizStart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Начать · $count вопроса',
      many: 'Начать · $count вопросов',
      few: 'Начать · $count вопроса',
      one: 'Начать · $count вопрос',
    );
    return '$_temp0';
  }

  @override
  String micQuizBest(int correct, int total) {
    return 'Лучший результат: $correct/$total';
  }

  @override
  String get micQuizNoBest => 'Результата пока нет — начните первый раунд';

  @override
  String get micQuizRules =>
      'Варианты берутся только из названий атласа. Смешанные поля и панели из журналов в тренировку не входят. Результат хранится только на этом устройстве.';

  @override
  String micQuizProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String micQuizStreak(int count) {
    return '$count подряд';
  }

  @override
  String get micQuizPromptArrow => 'Какая клетка отмечена стрелкой?';

  @override
  String get micQuizPromptCentre => 'Какая клетка в центре?';

  @override
  String get micQuizPromptField => 'Что в основном видно в этом поле?';

  @override
  String get micQuizCorrect => 'Верно!';

  @override
  String micQuizWrong(String answer) {
    return 'Неверно. Правильный ответ: $answer';
  }

  @override
  String get micQuizOpenCard => 'Открыть карточку снимка';

  @override
  String get micQuizTapToZoom => 'Нажмите на снимок, чтобы увеличить';

  @override
  String get micQuizResultGreat => 'Отличный результат!';

  @override
  String get micQuizResultGood => 'Хороший результат';

  @override
  String get micQuizResultKeep => 'Продолжайте тренироваться';

  @override
  String micQuizScore(int correct, int total) {
    return 'Верно $correct из $total';
  }

  @override
  String micQuizBestStreak(int count) {
    return 'Лучшая серия: $count';
  }

  @override
  String get micQuizNewRecord => 'Новый рекорд';

  @override
  String micQuizRetryMistakes(int count) {
    return 'Повторить ошибки ($count)';
  }

  @override
  String get micQuizNewRound => 'Новый раунд';

  @override
  String get micQuizChangeScope => 'Другой раздел';

  @override
  String get micQuizBackToAtlas => 'Вернуться в атлас';

  @override
  String get insTitle => 'Приборы';

  @override
  String get insMindraySub => 'Необходима точная модель';

  @override
  String get insHumanSub => 'Документы прибора и реагента раздельны';

  @override
  String get insOther => 'Другой производитель';

  @override
  String get insOtherSub => 'Подбор по точной модели и IFU';

  @override
  String get instSearchLabel => 'Поиск прибора';

  @override
  String get instSearchHint => 'Модель или компания';

  @override
  String get instNoResultsTitle => 'Модель не найдена';

  @override
  String get instNoResultsBody =>
      'Прибор, которого нет в каталоге, можно добавить вручную кнопкой ниже.';

  @override
  String get instMine => 'Мои приборы';

  @override
  String get instDirections => 'Направления';

  @override
  String instModelsCount(int count) {
    return 'Моделей: $count';
  }

  @override
  String instPlanned(String names) {
    return 'Следующий этап: $names';
  }

  @override
  String get instPlannedBody =>
      'Модели этих производителей будут добавлены после проверки по официальным источникам.';

  @override
  String get instAddCustom => 'Добавить прибор не из списка';

  @override
  String get instAddCustomSub => 'Производителя и модель вводите сами';

  @override
  String get instCustomTag => 'Введено вами';

  @override
  String instCatalogNote(String date) {
    return 'Каталог составлен по официальным страницам и документам производителей (на $date). У каждого факта указан источник.';
  }

  @override
  String get instChooseMaker => 'Выберите производителя';

  @override
  String get instChooseModel => 'Выберите модель';

  @override
  String get instStatusTitle => 'Статус сведений';

  @override
  String get instStatusDevice => 'Сведения о приборе есть';

  @override
  String get instStatusDeviceSub =>
      'С официальной страницы, буклета или документа регулятора';

  @override
  String get instStatusIfu => 'Руководство есть';

  @override
  String get instStatusIfuSub =>
      'Сверено с официальным руководством оператора (с версией)';

  @override
  String get instStatusExpert => 'Проверено специалистом';

  @override
  String get instStatusExpertSub =>
      'Рассмотрено независимым специалистом лаборатории';

  @override
  String get instStatusDone => 'есть';

  @override
  String get instStatusNotYet => 'пока нет';

  @override
  String get instPurpose => 'Назначение';

  @override
  String get instPrinciple => 'Принцип работы';

  @override
  String get instNotStated => 'В официальном источнике не указано.';

  @override
  String get instOfficialText => 'Официальный текст';

  @override
  String get instKeyFacts => 'Основные сведения';

  @override
  String get instManual => 'Руководство оператора';

  @override
  String get instManualPublic => 'Опубликовано открыто';

  @override
  String get instManualLogin => 'По логину';

  @override
  String get instManualNotPublic => 'Открыто не опубликовано';

  @override
  String get instDocsPortal => 'Портал документов';

  @override
  String get instLoginYes => 'нужен логин';

  @override
  String get instLoginNo => 'без логина';

  @override
  String get instLoginUnknown => 'наличие логина не проверено';

  @override
  String get instMaintenance => 'Ежедневное обслуживание';

  @override
  String get instMaintenanceNone =>
      'Производитель не публикует открыто шаги ежедневного обслуживания. Следуйте разделу «Maintenance» руководства оператора вашего прибора — LabGuide не придумывает шаги.';

  @override
  String get instMaintenanceQuotes => 'Что производитель сообщает открыто:';

  @override
  String get instReagentSystem => 'Реагентная система';

  @override
  String get instReagentOpen =>
      'Открытая — можно настроить и реагенты других производителей';

  @override
  String get instReagentPartly =>
      'Частично открытая — есть пользовательские каналы';

  @override
  String get instReagentClosed => 'Закрытая — только системные реагенты';

  @override
  String get instReagentUnknown =>
      'Открытость в официальном источнике не указана';

  @override
  String instValidatedReagents(int count) {
    return 'Реагенты с готовыми настройками на приборе (по официальному источнику): $count';
  }

  @override
  String get instImageNone =>
      'Изображение с ясной лицензией не найдено — фото производителя без разрешения не размещаем.';

  @override
  String instImageCredit(String author, String license) {
    return 'Фото: $author · $license';
  }

  @override
  String get instIllustration =>
      'Схематичное изображение (нарисовано LabGuide) — не внешний вид конкретной модели.';

  @override
  String get instSources => 'Источники';

  @override
  String instAccessed(String date) {
    return 'просмотрено $date';
  }

  @override
  String get instSaveMine => 'Сохранить как «Мой прибор»';

  @override
  String instSavedCount(int count) {
    return 'В «Моих приборах»: $count';
  }

  @override
  String get instCalibrate => 'Калибровка';

  @override
  String get instQc => 'Контроль качества (QC)';

  @override
  String get instSaveTitle => 'Сохранить прибор';

  @override
  String get instLabel => 'Название (необязательно)';

  @override
  String get instLabelHint => 'например, кабинет 1 или резервный';

  @override
  String get instSerial => 'Серийный номер (необязательно)';

  @override
  String get instManualVersion => 'Версия руководства (необязательно)';

  @override
  String get instManualVersionHint => 'версия или дата на обложке руководства';

  @override
  String get instSave => 'Сохранить';

  @override
  String get instSaved => 'Сохранено';

  @override
  String get instRemove => 'Удалить из списка';

  @override
  String get instRemoveConfirm =>
      'Удалить прибор из списка? Записи журнала калибровки сохранятся.';

  @override
  String get instMaker => 'Производитель';

  @override
  String get instModel => 'Модель';

  @override
  String get instCategory => 'Направление';

  @override
  String get instCustomRequired => 'Укажите производителя и модель.';

  @override
  String get instCatalogError => 'Не удалось прочитать каталог приборов';

  @override
  String get instOpenCard => 'Карточка прибора';

  @override
  String get partnerAdLabel => 'Реклама';

  @override
  String get partnerLabel => 'Партнёр';

  @override
  String get partnerOfficialTitle => 'Официальные партнёры';

  @override
  String get partnerSectionNote =>
      'Сведения предоставлены компаниями-партнёрами. Данные каталога выше, их порядок и статус проверки от партнёрства не зависят.';

  @override
  String get partnerKindManufacturer => 'Производитель';

  @override
  String get partnerKindDistributor => 'Официальный дистрибьютор';

  @override
  String get partnerKindService => 'Сервисный центр';

  @override
  String get partnerCall => 'Позвонить';

  @override
  String get partnerTelegram => 'Telegram';

  @override
  String get partnerWebsite => 'Сайт';

  @override
  String get partnerEmail => 'Email';

  @override
  String get partnerBrochure => 'Буклет';

  @override
  String get partnerMore => 'Подробнее';

  @override
  String partnerRegions(String regions) {
    return 'Регионы: $regions';
  }

  @override
  String partnerRegistration(String number) {
    return 'Регистрационное удостоверение в Узбекистане: $number';
  }

  @override
  String get partnerRegistrationNote => 'Номер предоставлен партнёром.';

  @override
  String get partnerBecome => 'Стать партнёром';

  @override
  String get partnerBecomeSub => 'Для компаний: ваши анализаторы в LabGuide';

  @override
  String get partnerNotFoundTitle => 'Партнёр не найден';

  @override
  String get partnerNotFoundBody =>
      'Возможно, срок размещения истёк или оно приостановлено.';

  @override
  String get partnerContacts => 'Контакты';

  @override
  String get partnerAbout => 'О компании';

  @override
  String get partnerInstruments => 'Связанные анализаторы';

  @override
  String partnerAllModels(String maker) {
    return '$maker: все модели';
  }

  @override
  String get partnerPageNote =>
      'Эта страница — реклама. LabGuide не рекомендует продукцию партнёров; данные каталога и статус проверки от партнёрства не зависят.';

  @override
  String get partnerOfferTitle => 'Ваши контакты — в карточке анализатора';

  @override
  String get partnerOfferBody =>
      'Специалист лаборатории читает об анализаторе — и в одно касание звонит официальному дистрибьютору или в сервисный центр. Для производителей, официальных дистрибьюторов и сервисных центров.';

  @override
  String get partnerWhatTitle => 'Что вы получаете';

  @override
  String get partnerWhatCard =>
      'Раздел «Официальные партнёры» в карточке анализатора: логотип, краткое описание, регионы, кнопки звонка и Telegram.';

  @override
  String get partnerWhatCategory =>
      'Компактная карточка «Партнёр» внутри направления (например, «Биохимия»).';

  @override
  String get partnerWhatLabHome =>
      'Одна рекламная карточка на главной странице раздела «Лаб» (по очереди).';

  @override
  String get partnerWhatPage =>
      'Страница партнёра: связанные модели, номера удостоверений, буклет.';

  @override
  String get partnerWhatReport =>
      'Отчёт: показы и нажатия «связаться» по дням и местам размещения (без персональных данных).';

  @override
  String get partnerAudienceTitle => 'Аудитория';

  @override
  String get partnerAudienceBody =>
      'LabGuide — для специалистов лабораторий, врачей, студентов и преподавателей, на узбекском, русском и английском. Число пользователей и распределение по ролям покажем при переговорах по серверной статистике; оценочных цифр не называем.';

  @override
  String get partnerRulesTitle => 'Правила';

  @override
  String get partnerRule1 =>
      'Везде стоит чёткая пометка «Реклама» или «Партнёр».';

  @override
  String get partnerRule2 =>
      'Факты каталога, их порядок и статус проверки от партнёрства не зависят и за деньги не меняются.';

  @override
  String get partnerRule3 =>
      'Реклама медицинских изделий: анализатор должен быть зарегистрирован в Узбекистане; номер удостоверения показывается в карточке.';

  @override
  String get partnerRule4 =>
      'Только проверяемые сведения: недоказанные утверждения вроде «лучший» или «точность 100%» не принимаются.';

  @override
  String get partnerRule5 =>
      'Персональные данные пользователей партнёрам не передаются.';

  @override
  String get partnerPriceTitle => 'Стоимость';

  @override
  String get partnerPriceBody =>
      'Стоимость обсуждается — в зависимости от мест размещения, срока и регионов.';

  @override
  String get partnerHowTitle => 'Как подключиться';

  @override
  String get partnerHow1 => 'Отправьте заявку через форму ниже.';

  @override
  String get partnerHow2 => 'Мы свяжемся с вами и согласуем условия.';

  @override
  String get partnerHow3 =>
      'Вы присылаете логотип, описание (uz/ru/en), контакты и номера удостоверений.';

  @override
  String get partnerHow4 =>
      'После проверки размещение публикуется; отчёт присылаем регулярно.';

  @override
  String get partnerFormTitle => 'Заявка';

  @override
  String get partnerFormCompany => 'Компания';

  @override
  String get partnerFormContact => 'Контактное лицо';

  @override
  String get partnerFormPhone => 'Телефон';

  @override
  String get partnerFormEmail => 'Email';

  @override
  String get partnerFormProducts => 'Продукция (анализаторы, модели)';

  @override
  String get partnerFormMessage => 'Сообщение';

  @override
  String get partnerFormHint => 'Нужен телефон или email (хотя бы одно).';

  @override
  String get partnerFormSend => 'Отправить заявку';

  @override
  String get partnerFormInvalid =>
      'Укажите компанию и контактное лицо, правильно введите телефон или email.';

  @override
  String get partnerSentTitle => 'Заявка отправлена';

  @override
  String get partnerSentBody =>
      'Ответ появится на этой странице в разделе «Ваши заявки». При необходимости свяжемся по указанному телефону или email.';

  @override
  String get partnerSendAnother => 'Отправить ещё заявку';

  @override
  String get partnerFormSignIn =>
      'Чтобы отправить заявку, войдите по email — ответ придёт в этот аккаунт.';

  @override
  String get partnerFormUnavailable =>
      'Отправка заявок пока не подключена: в этой сборке сервер не настроен.';

  @override
  String get partnerMyRequests => 'Ваши заявки';

  @override
  String get partnerReqStatusNew => 'Новая';

  @override
  String get partnerReqStatusInReview => 'На рассмотрении';

  @override
  String get partnerReqStatusAccepted => 'Принята';

  @override
  String get partnerReqStatusDeclined => 'Отклонена';

  @override
  String partnerReqReply(String text) {
    return 'Ответ LabGuide: $text';
  }

  @override
  String get partnerPlacementCard => 'Карточка анализатора';

  @override
  String get partnerPlacementCategory => 'Направление';

  @override
  String get partnerPlacementLabHome => 'Главная «Лаб»';

  @override
  String get partnerPlacementPage => 'Страница партнёра';

  @override
  String get adminPartners => 'Партнёры';

  @override
  String get adminPartnersSub => 'Реклама: создание, публикация, статистика';

  @override
  String get adminPartnerRequests => 'Заявки на партнёрство';

  @override
  String adminPartnerRequestsNew(int count) {
    return 'Новых заявок: $count';
  }

  @override
  String get adminPartnerNew => 'Новый партнёр';

  @override
  String get adminPartnersEmpty => 'Партнёров пока нет';

  @override
  String get adminPartnerStatusDraft => 'Черновик';

  @override
  String get adminPartnerStatusLive => 'Опубликован';

  @override
  String get adminPartnerStatusPaused => 'Приостановлен';

  @override
  String get adminPartnerExpired => 'Срок истёк';

  @override
  String get adminPartnerUpcoming => 'Ещё не начался';

  @override
  String get adminPartnerName => 'Название компании';

  @override
  String get adminPartnerKind => 'Тип';

  @override
  String get adminPartnerLogo => 'Ссылка на логотип (https://…)';

  @override
  String get adminPartnerLogoUpload => 'Загрузить логотип (PNG/JPEG, ≤ 1 МБ)';

  @override
  String get adminPartnerLogoTooLarge => 'Логотип больше 1 МБ или не PNG/JPEG.';

  @override
  String adminPartnerSummary(String lang) {
    return 'Краткое описание ($lang)';
  }

  @override
  String get adminPartnerRegions => 'Регионы';

  @override
  String get adminPartnerTelegram => 'Telegram (username)';

  @override
  String get adminPartnerWebsite => 'Сайт (https://…)';

  @override
  String get adminPartnerBrochure => 'Ссылка на буклет (https://…)';

  @override
  String get adminPartnerLinks => 'Привязка к каталогу';

  @override
  String get adminPartnerMakers => 'Производители (все модели)';

  @override
  String get adminPartnerModels => 'Модели';

  @override
  String get adminPartnerAddModel => 'Добавить модель';

  @override
  String get adminPartnerRegNo => 'Номер удостоверения (необязательно)';

  @override
  String get adminPartnerUnlink => 'Убрать';

  @override
  String get adminPartnerPeriodTitle => 'Период размещения';

  @override
  String get adminPartnerStarts => 'Начало';

  @override
  String get adminPartnerEnds => 'Окончание';

  @override
  String get adminPartnerSave => 'Сохранить';

  @override
  String get adminPartnerSaved => 'Сохранено';

  @override
  String get adminPartnerPublish => 'Опубликовать';

  @override
  String get adminPartnerPause => 'Приостановить';

  @override
  String get adminPartnerPublished => 'Опубликовано';

  @override
  String get adminPartnerPausedMsg => 'Приостановлено';

  @override
  String get adminPartnerPublishRules =>
      'Для публикации нужны описание, хотя бы один контакт и хотя бы одна привязка. Реклама везде идёт с пометкой «Реклама» и не влияет на данные каталога.';

  @override
  String get adminPartnerInvalid =>
      'Проверьте данные: название (2–120 символов), телефон, Telegram (5–32 символа), ссылки https, email, даты; для публикации — описание, контакт и привязка.';

  @override
  String get adminPartnerStats => 'Статистика';

  @override
  String get adminStatsImpressions => 'Показы';

  @override
  String get adminStatsContacts => 'Нажатия «связаться»';

  @override
  String get adminStatsCtr => 'Доля нажатий (CTR)';

  @override
  String get adminStats7 => 'Последние 7 дней';

  @override
  String get adminStats30 => 'Последние 30 дней';

  @override
  String get adminStatsAll => 'За всё время';

  @override
  String get adminStatsPeriods => 'По периодам';

  @override
  String get adminStatsByPlacement => 'По местам размещения (30 дней)';

  @override
  String get adminStatsDaily => 'По дням';

  @override
  String get adminStatsEmpty => 'Событий пока нет';

  @override
  String get adminStatsNote =>
      'Как считается: показ — блок партнёра отрисован на экране; с одного устройства — не чаще раза в день на каждое место. Учитываются только вошедшие пользователи (гости и админ — нет). Персональные данные не хранятся, только дневные счётчики (время Ташкента).';

  @override
  String get adminStatsCopy => 'Скопировать отчёт';

  @override
  String get adminRequestsEmpty => 'Заявок нет';

  @override
  String get adminRequestReply => 'Ответ (увидит заявитель)';

  @override
  String get adminRequestSave => 'Сохранить статус и ответ';

  @override
  String get adminActionPartnerCreated => 'Партнёр создан';

  @override
  String get adminActionPartnerUpdated => 'Партнёр изменён';

  @override
  String get adminActionPartnerPublished => 'Партнёр опубликован';

  @override
  String get adminActionPartnerPaused => 'Партнёр приостановлен';

  @override
  String get adminActionPartnerDraft => 'Партнёр возвращён в черновик';

  @override
  String get adminActionPartnerRequest => 'Заявка на партнёрство обработана';

  @override
  String get calStepInstrument => '1. Прибор';

  @override
  String get calStepAnalyte => '2. Аналит';

  @override
  String get calStepReagent => '3. Реагент';

  @override
  String get calChooseInstrument =>
      'Сначала выберите прибор: из сохранённых или из каталога.';

  @override
  String get calChange => 'Изменить';

  @override
  String get calFromCatalog => 'Выбрать из каталога';

  @override
  String get calAnalyteHint => 'Например, глюкоза';

  @override
  String get calReagentMaker => 'Производитель реагента';

  @override
  String get calReagentMakerName => 'Название производителя';

  @override
  String get calDifferentMaker =>
      'Производитель реагента отличается от производителя прибора. Совместимость проверьте отдельно по списку приборов (application) в IFU реагента и по реагентной системе прибора.';

  @override
  String calValidated(String doc) {
    return 'По официальному источнику ($doc) на этом приборе есть готовые настройки для реагентов:';
  }

  @override
  String get calRefListed => 'Введённый REF есть в этом списке.';

  @override
  String get calRefNotListed =>
      'Введённого REF нет в этом списке — перепроверьте упаковку реагента и IFU.';

  @override
  String get calShowGuide => 'Показать руководство';

  @override
  String get calGuideNeeds =>
      'Укажите прибор, аналит, REF реагента и версию IFU. Лот на этом шаге не нужен.';

  @override
  String get calGuideFound => 'Найдено проверенное руководство';

  @override
  String get calGuideNoneTitle => 'Проверенного руководства пока нет';

  @override
  String get calGuideNoneBody =>
      'Для этой комбинации прибор + REF реагента + версия IFU в LabGuide нет сверенной записи. Параметры не угадываем — возьмите их из документов:';

  @override
  String get calGuide1 =>
      'Название и REF калибратора — в разделе «Calibration» IFU реагента.';

  @override
  String get calGuide2 => 'Число точек и способ калибровки — в том же разделе.';

  @override
  String get calGuide3 =>
      'Значения для каждого лота — в листе значений калибратора (номер лота должен совпадать).';

  @override
  String get calGuide4 =>
      'Когда нужна повторная калибровка (смена лота, отказ QC, срок) — в IFU.';

  @override
  String get calGuide5 =>
      'После калибровки проведите QC и внесите результат в запись.';

  @override
  String get calDocsWhere => 'Где найти документы';

  @override
  String get calRecordCreate => 'Создать запись калибровки';

  @override
  String get calRecordTitle => 'Запись калибровки';

  @override
  String get calCalibratorName =>
      'Название или REF калибратора (необязательно)';

  @override
  String get calLotExpiry => 'Срок годности лота (необязательно)';

  @override
  String get calLevels => 'Уровни калибратора';

  @override
  String get calLevelName => 'Уровень';

  @override
  String get calLevelValue => 'Назначенное значение';

  @override
  String get calLevelUnit => 'Единица';

  @override
  String get calAddLevel => 'Добавить уровень';

  @override
  String get calRemoveLevel => 'Удалить уровень';

  @override
  String get calValuesFromSheet =>
      'Переносите значения из листа значений именно этого лота. LabGuide их не угадывает и не проверяет.';

  @override
  String get calPerformedOn => 'Дата выполнения';

  @override
  String get calOutcome => 'Результат';

  @override
  String get calOutcomeAccepted => 'Принята';

  @override
  String get calOutcomeRejected => 'Отклонена';

  @override
  String get calOutcomePending => 'Ожидается';

  @override
  String get calNote => 'Комментарий (необязательно)';

  @override
  String get calRecordSave => 'Сохранить запись';

  @override
  String get calRecordSaved => 'Запись калибровки сохранена';

  @override
  String get calLotRequired => 'Укажите лот калибратора.';

  @override
  String get calLevelInvalid =>
      'Для каждого уровня укажите название, значение (число) и единицу.';

  @override
  String get calLog => 'Журнал калибровок';

  @override
  String get calLogSub => 'Лот, значения и результат — на этом устройстве';

  @override
  String get calLogEmpty => 'Записей пока нет';

  @override
  String get calLogEmptyBody =>
      'После калибровки создайте запись — лот, значения и результат сохранятся здесь.';

  @override
  String get calDeleteRecord => 'Удалить запись';

  @override
  String get calDeleteRecordConfirm => 'Удалить запись калибровки?';

  @override
  String get calUserEntered => 'Значения введены пользователем.';

  @override
  String get calDetailInstrument => 'Прибор';

  @override
  String get calDetailManual => 'Версия руководства';

  @override
  String get calDetailCalibrator => 'Калибратор';

  @override
  String get calDetailLotExpiry => 'Срок годности лота';

  @override
  String get calLot => 'Лот';

  @override
  String calAnalyteSelected(String name) {
    return 'Аналит: $name';
  }

  @override
  String get libTitle => 'Библиотека';

  @override
  String get libSubtitle => 'Ваши знания в одном месте.';

  @override
  String get libBooks => 'Книги и руководства';

  @override
  String get libBooksSub => 'Каталог книг, пособий и сайтов';

  @override
  String get libPacks => 'Офлайн-пакеты';

  @override
  String get libPacksSub => 'Установленные и ожидаемые пакеты';

  @override
  String get libSavedSub => 'Сохранённые анализы';

  @override
  String get libResearchSub => 'Вопрос, план, реальные данные и источники';

  @override
  String get libSources => 'Источники и лицензии';

  @override
  String get libSourcesSub => 'Проверка и условия использования';

  @override
  String get booksEmptyTitle => 'Книг пока нет';

  @override
  String get booksEmptyBody =>
      'Книги добавляются только при подтверждённом праве распространения. PDF, добавленный вами, остаётся для личного изучения и не распространяется.';

  @override
  String get booksCatalogNote =>
      'Материалы каталога даны ссылками на официальные страницы. Полный текст добавляется в приложение только при открытой лицензии или подтверждённом праве на распространение.';

  @override
  String get booksResetFilters => 'Сбросить фильтры';

  @override
  String get packsInstalled => 'Установлено';

  @override
  String get packsCoreTitle => 'Основной контент';

  @override
  String packsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String packsSize(String size) {
    return 'Размер: $size';
  }

  @override
  String packsLanguages(String languages) {
    return 'Языки: $languages';
  }

  @override
  String packsLicence(String licence) {
    return 'Лицензия: $licence';
  }

  @override
  String get packsVerified => 'Целостность проверена (SHA-256)';

  @override
  String get packsUpcoming => 'Ожидаемые пакеты';

  @override
  String get packsUpcomingBody =>
      'Перед загрузкой показывается реальный размер. Пакеты публикуются только после проверки контента.';

  @override
  String get packsBiochem => 'Основы биохимии';

  @override
  String get packsSpecimensQc => 'Образцы и QC';

  @override
  String get packsMicroscopy => 'Атлас микроскопии';

  @override
  String get packsNotPublished => 'Ещё не опубликован';

  @override
  String get packsBuiltIn => 'Встроено в приложение';

  @override
  String get packsOffline => 'Работает без интернета';

  @override
  String get packsCoreState =>
      'Статус: черновик — учебный материал с источниками, ещё не прошёл независимую экспертную проверку';

  @override
  String packsContents(int cards, int questions, int sources) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards карточек',
      few: '$cards карточки',
      one: '$cards карточка',
    );
    String _temp1 = intl.Intl.pluralLogic(
      questions,
      locale: localeName,
      other: '$questions вопросов',
      few: '$questions вопроса',
      one: '$questions вопрос',
    );
    String _temp2 = intl.Intl.pluralLogic(
      sources,
      locale: localeName,
      other: '$sources источников',
      few: '$sources источника',
      one: '$sources источник',
    );
    return 'Состав: $_temp0, $_temp1, $_temp2';
  }

  @override
  String get packsDownloadable => 'Пакеты для загрузки';

  @override
  String get packsCatalogLoading => 'Загрузка каталога…';

  @override
  String get packsCatalogCached => 'Показан последний сохранённый каталог';

  @override
  String get packsCatalogEmpty => 'Пока нет пакетов для загрузки';

  @override
  String get packsStatusTest => 'Тестовый пакет · не клинический';

  @override
  String get packsStatusDraft => 'Черновик · не проверен экспертом';

  @override
  String get packsStatusReviewed => 'Проверен экспертом';

  @override
  String packsMeta(String version, String size, String languages) {
    return 'Версия $version · $size · $languages';
  }

  @override
  String packsDownload(String size) {
    return 'Загрузить · $size';
  }

  @override
  String packsDownloading(int percent) {
    return 'Загрузка… $percent %';
  }

  @override
  String packsInstalledVersion(String version, String size) {
    return 'Установлено: $version · $size';
  }

  @override
  String packsUpdate(String version) {
    return 'Обновить до $version';
  }

  @override
  String get packsRemove => 'Удалить';

  @override
  String get packsRemoveTitle => 'Удалить пакет?';

  @override
  String get packsRemoveBody =>
      'Пакет будет удалён с устройства. Его можно загрузить снова.';

  @override
  String get packsFailNetwork =>
      'Нет соединения с интернетом. Проверьте связь и попробуйте снова.';

  @override
  String get packsFailServer => 'Сервер не ответил. Попробуйте позже.';

  @override
  String get packsFailIntegrity =>
      'Пакет не прошёл проверку (размер или SHA-256 не совпали) и не установлен. Прежнее состояние не изменилось.';

  @override
  String get packsFailIncompatible =>
      'Для этого пакета нужна более новая версия приложения.';

  @override
  String get packsFailStorage =>
      'Не удалось записать на устройство. Проверьте свободное место.';

  @override
  String get packsPlanned => 'Запланировано';

  @override
  String get packsPlannedBody =>
      'Будут опубликованы после независимой проверки; размер показывается до загрузки.';

  @override
  String get savedEmptyTitle => 'Закладок пока нет';

  @override
  String get savedEmptyBody =>
      'Нажмите «Сохранить» в карточке анализа, и она появится здесь.';

  @override
  String get sourcesTitle => 'Источники и лицензии';

  @override
  String get sourcesContent => 'Карточки анализов';

  @override
  String get sourcesMethods => 'Калькуляторы, контроль качества и преаналитика';

  @override
  String get sourcesBody =>
      'Каждое публикуемое утверждение связано с первоисточником, датой обращения, областью применения и статусом проверки.';

  @override
  String get researchTitle => 'Исследовательское пространство';

  @override
  String get researchQuestion => 'Тема или исследовательский вопрос';

  @override
  String get researchQuestionHint => 'Введите тему';

  @override
  String get researchNotes => 'Цель и заметки';

  @override
  String get researchNotesHint => 'Ваши данные и источники';

  @override
  String get researchSave => 'Сохранить черновик';

  @override
  String get researchSaved => 'Черновик сохранён на этом устройстве';

  @override
  String get researchAutosave =>
      'Черновик автоматически сохраняется на этом устройстве по мере ввода.';

  @override
  String get researchOutline => 'Структура плана';

  @override
  String get researchStep1 => 'Вопрос и цель';

  @override
  String get researchStep2 => 'Обзор источников';

  @override
  String get researchStep3 => 'Метод и реальные данные';

  @override
  String get researchStep4 => 'Результаты, ограничения и выводы';

  @override
  String get researchNoFabrication =>
      'LabGuide не генерирует результаты, данные пациентов или цитаты. Используйте только свои данные и источники.';

  @override
  String get learnTitle => 'Учитесь с пониманием';

  @override
  String get learnHeroTag => 'Биохимия в иллюстрациях';

  @override
  String get learnHeroTitle => 'От молекулы к практике';

  @override
  String get learnHeroBody => 'Темы, механизмы и проверка знаний.';

  @override
  String get learnHeroCta => 'Смотреть темы';

  @override
  String get learnClassesSub => 'Преподаватель → задание → студент → результат';

  @override
  String get learnQuiz => 'Тест с объяснениями';

  @override
  String learnQuizSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учебного вопроса',
      many: '$count учебных вопросов',
      few: '$count учебных вопроса',
      one: '$count учебный вопрос',
    );
    return '$_temp0';
  }

  @override
  String get learnExam => 'Режим экзамена';

  @override
  String get learnExamSub => 'Время, тема и вопросы';

  @override
  String toifaTopic(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'safety_ethics': 'Безопасность и этика',
      'qc_lab_management': 'Контроль качества и управление',
      'preanalytics': 'Преаналитика',
      'hematology_cells': 'Клетки крови',
      'hemopoiesis_leukemia': 'Кроветворение и лейкозы',
      'anemias': 'Анемии',
      'hemostasis': 'Гемостаз',
      'biochemistry_proteins_enzymes': 'Белки и ферменты',
      'carbohydrates_diabetes': 'Углеводы и диабет',
      'lipids': 'Липиды',
      'liver_pigments': 'Печень и пигменты',
      'kidney_nitrogen': 'Почки и азотистый обмен',
      'water_electrolytes_acid_base':
          'Водно-электролитный и кислотно-основный баланс',
      'minerals_vitamins': 'Минералы и витамины',
      'hormones': 'Гормоны',
      'urinalysis': 'Анализ мочи',
      'stool_coprology': 'Копрология',
      'csf_body_fluids': 'Ликвор и биологические жидкости',
      'sputum_tb': 'Мокрота и туберкулёз',
      'cytology_gyn': 'Цитология',
      'std_microscopy': 'Микроскопия при ИППП',
      'parasitology': 'Паразитология',
      'immunology_serology': 'Иммунология и серология',
      'molecular_pcr': 'Молекулярная диагностика (ПЦР)',
      'tumor_markers': 'Онкомаркеры',
      'cardiac_markers': 'Кардиомаркеры',
      'orphan_screening': 'Скрининг и орфанные болезни',
      'other': 'Другие темы',
    });
    return '$_temp0';
  }

  @override
  String get toifaTitle => 'Подготовка к экзамену на категорию';

  @override
  String get toifaSubtitle => 'Клиническая лабораторная диагностика (КЛД)';

  @override
  String get toifaEyebrow => 'КЛД · категория';

  @override
  String get toifaEntryBody =>
      'Вопросы из официального списка аттестации: тест из 50 вопросов, практика по темам, устный билет и работа над ошибками.';

  @override
  String get toifaEntryBodyShort =>
      'Тест, устный билет и работа над ошибками — по официальному списку.';

  @override
  String get toifaEntryTagTest => 'Тест · 50 вопросов';

  @override
  String get toifaEntryTagOral => 'Устно · 5 вопросов';

  @override
  String toifaEntryTestActive(int done, int total) {
    return 'Тест продолжается: $done / $total ответов';
  }

  @override
  String toifaEntryTicketActive(int done, int total) {
    return 'Устный билет продолжается: $done / $total';
  }

  @override
  String get toifaOpen => 'Начать подготовку';

  @override
  String get toifaContinue => 'Продолжить';

  @override
  String get toifaUzbekOnly => 'Вопросы на узбекском языке';

  @override
  String get toifaUzbekNotice =>
      'Вопросы аттестации показаны на узбекском, как в официальном списке; кнопки и подсказки — на языке интерфейса.';

  @override
  String get toifaLoadError => 'Не удалось открыть банк вопросов';

  @override
  String get toifaYourCategory => 'Ваша категория';

  @override
  String get toifaCatSecond => '3–2 категория';

  @override
  String get toifaCatFirst => '1 категория';

  @override
  String get toifaCatHighest => 'Высшая категория';

  @override
  String get toifaCategoryHint =>
      'Устный билет составляется из списка этой категории. Тестовые вопросы общие для всех категорий.';

  @override
  String get toifaReadyTest => 'Тест';

  @override
  String get toifaReadyOral => 'Устно';

  @override
  String get toifaPrepare => 'Подготовка';

  @override
  String get toifaTestTitle => 'Тест на категорию';

  @override
  String toifaTestRowSub(int count, int bank) {
    return '$count случайных вопросов · в банке $bank';
  }

  @override
  String get toifaPracticeTitle => 'Практика по темам';

  @override
  String toifaPracticeRowSub(int count) {
    return '$count тем · ключ и пояснение сразу после ответа';
  }

  @override
  String get toifaOralTitle => 'Устный билет';

  @override
  String toifaOralRowSub(String category, int count) {
    return '$category: 5 из $count вопросов';
  }

  @override
  String get toifaOralRowPick => 'Сначала выберите категорию';

  @override
  String toifaOralRowActive(int done, int total) {
    return 'Продолжается: оценено $done / $total';
  }

  @override
  String get toifaMistakesTitle => 'Работа над ошибками';

  @override
  String toifaMistakesRowSub(int tests, int oral) {
    return 'Ошибки в тесте: $tests · устно «не знал»: $oral';
  }

  @override
  String get toifaMistakesRowEmpty => 'Пока ошибок нет';

  @override
  String get toifaProgressTitle => 'Прогресс';

  @override
  String get toifaProgressRowSub => 'Результаты по темам и готовность';

  @override
  String get toifaAboutTitle => 'Источник и проверка';

  @override
  String get toifaListSource =>
      'Источник: официальный список вопросов аттестации (КЛД, 119)';

  @override
  String toifaAboutList(int tests, int oral) {
    return 'В списке $tests тестовых и $oral устных вопросов (повторы между категориями объединены).';
  }

  @override
  String toifaAboutKeys(int disputed, int ambiguous) {
    return 'Ключ — ответ, отмеченный в списке; баллы считаются по нему. LabGuide считает ключ спорным в $disputed вопросах и неоднозначным в $ambiguous — там показаны пояснение и источник.';
  }

  @override
  String toifaAboutKeyless(int count) {
    return 'В $count вопросах ключ в списке не отмечен — они не включены в тест и практику.';
  }

  @override
  String toifaAboutOral(int ready, int total) {
    return 'Планы устных ответов подготовлены LabGuide и ждут проверки специалистом ($ready / $total планов с источниками).';
  }

  @override
  String toifaTestSubtitle(int count) {
    return '$count вопросов · случайно из официального списка';
  }

  @override
  String get toifaFormatTitle => 'Формат';

  @override
  String toifaFormatStep1(int count, int bank) {
    return 'Случайные $count из $bank вопросов банка.';
  }

  @override
  String get toifaFormatStep2 =>
      'В каждом вопросе один ответ; варианты в порядке списка.';

  @override
  String get toifaFormatStep3 =>
      'В конце разбор ошибок: официальный ключ и пояснение LabGuide.';

  @override
  String get toifaTimeLabel => 'Время, минут';

  @override
  String get toifaNoTime => 'Без времени';

  @override
  String get toifaTimeHelper =>
      'Официальный лимит времени в приложении не задан — выберите сами или оставьте пустым.';

  @override
  String get toifaTimeError => 'Введите от 1 до 240 минут или оставьте пустым';

  @override
  String get toifaPassLabel => 'Проходной порог, %';

  @override
  String get toifaNoPass => 'Не задан';

  @override
  String get toifaPassHelper =>
      'Это выбранный вами порог, а не официальный проходной балл.';

  @override
  String get toifaPassError => 'Введите от 1 до 100 % или оставьте пустым';

  @override
  String get toifaScoringNotice =>
      'Баллы считаются по официальному ключу — на экзамене требуется именно он. Для спорных ключей в результатах есть пояснение LabGuide.';

  @override
  String get toifaTestStart => 'Начать тест';

  @override
  String get toifaPracticeSubtitle => 'Ключ сразу после ответа';

  @override
  String toifaPracticeMixed(int count) {
    return 'Вперемешку: $count вопросов';
  }

  @override
  String get toifaPracticeMistakes => 'Повторить ошибки';

  @override
  String get toifaBackToTopics => 'Темы';

  @override
  String get toifaPracticeRight => 'Ваш ответ совпадает с официальным ключом.';

  @override
  String get toifaPracticeWrong =>
      'Ваш ответ не совпадает с официальным ключом.';

  @override
  String toifaListNumber(int number) {
    return '№ $number';
  }

  @override
  String get toifaOfficialKey => 'Официальный ключ';

  @override
  String get toifaLabGuideNote => 'Пояснение LabGuide';

  @override
  String get toifaVerdictDisputed => 'Ключ спорный';

  @override
  String get toifaVerdictAmbiguous => 'Вопрос неоднозначный';

  @override
  String toifaSuggested(String options) {
    return 'По мнению LabGuide: $options';
  }

  @override
  String get toifaScoredByOfficial =>
      'Баллы считаются по официальному ключу — на экзамене требуется именно этот ответ.';

  @override
  String get toifaNoOfficialKey =>
      'Ключ в списке не отмечен — вопрос не оценивается.';

  @override
  String get toifaNoteNoSource =>
      'Источник для пояснения не указан (не проверено).';

  @override
  String get toifaRelatedCards => 'Связанные карточки';

  @override
  String toifaOralSubtitle(int count) {
    return '$count вопросов · подготовка и самооценка';
  }

  @override
  String toifaOralPool(String category, int count) {
    return '$category: в списке $count вопросов';
  }

  @override
  String get toifaOralHowTitle => 'Как это работает';

  @override
  String toifaOralStep1(int count) {
    return 'Случайные $count вопросов из списка вашей категории.';
  }

  @override
  String get toifaOralStep2 => 'Подготовьте ответы — мысленно или письменно.';

  @override
  String get toifaOralStep3 =>
      'Посмотрите план ответа и оцените себя: знал, частично или не знал.';

  @override
  String get toifaPlanDisclaimer =>
      'Планы ответов подготовлены LabGuide и ждут проверки специалистом. Это не официальные ответы.';

  @override
  String get toifaPickCategoryFirst => 'Сначала выберите категорию';

  @override
  String get toifaDrawTicket => 'Взять билет';

  @override
  String get toifaTicketTitle => 'Ваш билет';

  @override
  String get toifaPrepHint =>
      'Подготовьте ответ на каждый вопрос. Затем откройте планы ответов по одному и оцените себя.';

  @override
  String get toifaShowPlans => 'Посмотреть план ответа';

  @override
  String get toifaShowPlan => 'Посмотреть план ответа';

  @override
  String get toifaNewTicket => 'Новый билет';

  @override
  String get toifaNewTicketBody =>
      'Вместо текущего билета будет взято 5 новых вопросов. Поставленные оценки сохранятся.';

  @override
  String get toifaRevealHint =>
      'Сначала вспомните или запишите ответ, затем откройте план.';

  @override
  String get toifaPlanTitle => 'План ответа';

  @override
  String get toifaPlanPending =>
      'Подготовлено LabGuide, ждёт проверки специалистом';

  @override
  String get toifaPlanMissing => 'План для этого вопроса ещё не подготовлен.';

  @override
  String get toifaPlanNotChecked => 'План не полностью проверен по источникам.';

  @override
  String get toifaReferenceTitle =>
      'Референсный интервал (образец, зависит от лаборатории)';

  @override
  String get toifaCutoffTitle => 'Диагностический порог (руководство)';

  @override
  String get toifaWrongLabel => 'Неверно';

  @override
  String get toifaRightLabel => 'Верно';

  @override
  String get toifaNeedsSource => 'Нужен источник — уточняется у преподавателя';

  @override
  String get toifaUnverifiedNote =>
      'Пояснение не подтверждено источником — вариант не предлагается.';

  @override
  String toifaAgentChecked(String date) {
    return 'Проверка агентом: $date (не подтверждено специалистом)';
  }

  @override
  String get toifaHeld => 'Уточняется';

  @override
  String get toifaHeldBody =>
      'Пока формулировка уточняется, вопрос не входит в билеты и оценку.';

  @override
  String toifaAboutHeld(int count) {
    return '$count вопрос(ов) исключены из билетов и теста до уточнения.';
  }

  @override
  String get toifaPitfallsTitle => 'Устаревшее / частая ошибка';

  @override
  String get toifaRateTitle => 'Оцените себя';

  @override
  String get toifaRateHint =>
      'Оценка хранится только на этом устройстве и видна в «Работе над ошибками».';

  @override
  String get toifaRateKnew => 'Знал';

  @override
  String get toifaRatePartial => 'Частично';

  @override
  String get toifaRateUnknown => 'Не знал';

  @override
  String get toifaTicketDone => 'Билет завершён';

  @override
  String toifaTicketSummary(int knew, int partial, int unknown) {
    return 'Знал: $knew · частично: $partial · не знал: $unknown';
  }

  @override
  String get toifaRatingsSaved =>
      'Оценки сохранены. Нажмите вопрос, чтобы снова открыть план и изменить оценку.';

  @override
  String get toifaRatingSaved => 'Оценка сохранена';

  @override
  String get toifaMistakesSubtitle => 'Ошибки теста и устные вопросы';

  @override
  String get toifaMistakesEmpty => 'Пока ошибок нет';

  @override
  String get toifaMistakesEmptyBody =>
      'Здесь собираются вопросы с ошибками из теста и практики, а также устные вопросы с оценкой «не знал».';

  @override
  String toifaMistakesTests(int count) {
    return 'Ошибки теста · $count';
  }

  @override
  String toifaMistakesOralUnknown(int count) {
    return 'Устно: не знал · $count';
  }

  @override
  String toifaMistakesOralPartial(int count) {
    return 'Устно: частично · $count';
  }

  @override
  String toifaMoreMistakes(int count) {
    return 'Ещё $count ошибок — отработайте их через «Повторить ошибки».';
  }

  @override
  String get toifaNothingHere => 'Здесь пока ничего нет.';

  @override
  String get toifaProgressSubtitle => 'Результаты по темам и готовность';

  @override
  String get toifaReadyTitle => 'Примерная готовность';

  @override
  String get toifaReadyCaption =>
      'Среднее теста и устной части. Расчёт LabGuide — не официальная оценка.';

  @override
  String toifaReadyTestDetail(int done, int total) {
    return 'Тест: освоено $done / $total вопросов';
  }

  @override
  String toifaReadyOralDetail(int done, int total) {
    return 'Устно: $done / $total «знал»';
  }

  @override
  String get toifaProgressPickCategory =>
      'Устный результат считается по списку вашей категории — выберите категорию:';

  @override
  String get toifaRecentTests => 'Последние тесты';

  @override
  String get toifaPassedShort => 'Порог пройден';

  @override
  String get toifaNotPassedShort => 'Порог не пройден';

  @override
  String get toifaByTopicNote =>
      'Сначала самые слабые темы. Тест — вопросы с последним верным ответом; устно — с оценкой «знал».';

  @override
  String toifaBarTest(int done, int total) {
    return 'Тест: $done / $total';
  }

  @override
  String toifaBarOral(int done, int total) {
    return 'Устно: $done / $total';
  }

  @override
  String examPassMet(int percent) {
    return 'Порог пройден (≥$percent%)';
  }

  @override
  String examPassMissed(int percent) {
    return 'Порог не достигнут ($percent%)';
  }

  @override
  String get learnLessonPlan => 'План занятия';

  @override
  String get learnLessonPlanSub => 'Пространство преподавателя';

  @override
  String quizProgress(int current, int total) {
    return 'Вопрос $current из $total';
  }

  @override
  String get quizCorrect => 'Верно.';

  @override
  String get quizIncorrect => 'Этот ответ неверен.';

  @override
  String get quizNext => 'Далее';

  @override
  String get quizFinish => 'Посмотреть результат';

  @override
  String get quizDoneTitle => 'Практика завершена';

  @override
  String quizScore(int correct, int total) {
    return 'Верно: $correct из $total';
  }

  @override
  String get quizRestart => 'Повторить';

  @override
  String quizBasis(String basis) {
    return 'Основание: $basis';
  }

  @override
  String get quizSources => 'Источник';

  @override
  String get quizReviewNote => 'Учебные вопросы ожидают экспертной проверки.';

  @override
  String get quizMistakes => 'Разбор ошибок';

  @override
  String get quizNoMistakes => 'Ошибок нет — отлично.';

  @override
  String get quizYourAnswer => 'Ваш ответ';

  @override
  String get quizCorrectAnswer => 'Правильный ответ';

  @override
  String get quizChooseTopic => 'Выберите тему';

  @override
  String quizTopicMixed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Вперемешку: $count случайного вопроса',
      many: 'Вперемешку: $count случайных вопросов',
      few: 'Вперемешку: $count случайных вопроса',
      one: 'Вперемешку: $count случайный вопрос',
    );
    return '$_temp0';
  }

  @override
  String get quizTopicGeneral => 'Лабораторные расчёты';

  @override
  String quizQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вопроса',
      many: '$count вопросов',
      few: '$count вопроса',
      one: '$count вопрос',
    );
    return '$_temp0';
  }

  @override
  String get quizOtherTopic => 'Другая тема';

  @override
  String get dailyTitle => 'Вопросы дня';

  @override
  String get dailyCardStart => '5 вопросов на сегодня';

  @override
  String get dailyCardStartSub =>
      '2–3 минуты. Каждый день новые вопросы, после ответа — пояснение и источник.';

  @override
  String dailyCardProgress(int count, int total) {
    return 'Отвечено: $count из $total';
  }

  @override
  String dailyCardDone(int correct, int total) {
    return 'Сегодня выполнено: верно $correct из $total';
  }

  @override
  String get dailyCardDoneSub => 'Завтра будут новые 5 вопросов.';

  @override
  String get dailyStart => 'Начать';

  @override
  String get dailyContinue => 'Продолжить';

  @override
  String get dailyShowResult => 'Посмотреть результат';

  @override
  String dailyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня подряд',
      many: '$count дней подряд',
      few: '$count дня подряд',
      one: '$count день подряд',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakTitle => 'Серия';

  @override
  String get dailyStreakCurrent => 'Текущая серия';

  @override
  String get dailyStreakBest => 'Самая длинная';

  @override
  String dailyDaysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get dailyFreezeAvailable => 'Заморозка на этой неделе доступна';

  @override
  String get dailyFreezeUsed => 'Заморозка на этой неделе использована';

  @override
  String get dailyFreezeRule =>
      'Если пропустить один день, серия не прервётся — раз в неделю (заморозка). Замороженный день в серию не засчитывается; если пропустить два дня подряд, серия начнётся заново.';

  @override
  String get dailyFreezeSaved =>
      'Вчера был пропуск — заморозка сохранила серию.';

  @override
  String get dailyStreakStart =>
      'Ответьте на сегодняшние вопросы — серия начнётся с этого дня.';

  @override
  String get dailyKeepStreak =>
      'Ответьте на сегодняшние вопросы, чтобы сохранить серию.';

  @override
  String get dailyEmpty => 'Вопросов на сегодня не найдено';

  @override
  String get dailyReviewTitle => 'Сегодняшние вопросы';

  @override
  String get dailySourceToifa =>
      'Вопросы берутся из официального списка аттестации — только те, чей ключ прошёл проверку LabGuide.';

  @override
  String get dailyReminderTitle => 'LabGuide: вопросы дня';

  @override
  String get dailyReminderBody => '5 вопросов на сегодня готовы — 2–3 минуты.';

  @override
  String get dailyReminderChannel => 'Ежедневное напоминание';

  @override
  String get dailyReminderSetting => 'Ежедневное напоминание';

  @override
  String dailyReminderAt(String time) {
    return 'Каждый день в $time';
  }

  @override
  String get dailyReminderOff => 'Выключено';

  @override
  String get dailyReminderTime => 'Время напоминания';

  @override
  String get dailyOfferTitle => 'Напоминать каждый день?';

  @override
  String get dailyOfferBody =>
      'Одно уведомление в выбранное время. В дни, когда вы уже ответили, напоминания не будет. Отключить можно в любой момент.';

  @override
  String get dailyOfferYes => 'Включить напоминание';

  @override
  String get dailyOfferNo => 'Не нужно';

  @override
  String get dailyReminderDenied =>
      'Разрешение на уведомления не дано, напоминание выключено. Включите уведомления для LabGuide в настройках телефона и попробуйте снова.';

  @override
  String get dailyReminderUnavailable =>
      'На этом устройстве не удалось включить напоминание.';

  @override
  String dailyReminderOnSnack(String time) {
    return 'Напоминание включено: каждый день в $time';
  }

  @override
  String get dailyReminderNote =>
      'Напоминание планируется только на этом устройстве (без сервера). Телефон может задержать его на несколько минут для экономии заряда. Если не открывать приложение 7 дней, напоминания прекратятся.';

  @override
  String get shareResult => 'Поделиться результатом';

  @override
  String get shareSheetTitle => 'Карточка результата';

  @override
  String get shareSheetBody =>
      'На картинке нет вашего имени и других личных данных.';

  @override
  String get shareFailed =>
      'Не удалось открыть окно «Поделиться». Попробуйте ещё раз.';

  @override
  String get shareKindDaily => 'Вопросы дня';

  @override
  String get shareKindExam => 'Тренировочный экзамен';

  @override
  String get shareKindToifa => 'Тренировка теста на категорию';

  @override
  String get shareCorrectCaption => 'верных ответов';

  @override
  String get shareFooter =>
      'Справочник и тренировки по лабораторной диагностике';

  @override
  String get shareToifaNote =>
      'Не официально — результат тренировки в LabGuide';

  @override
  String shareText(String kind, int correct, int total, int percent) {
    return 'LabGuide · $kind: $correct/$total ($percent%)';
  }

  @override
  String get quizTopicMistakes => 'Работа над ошибками';

  @override
  String quizMastered(int correct, int total) {
    return 'верно в прошлый раз: $correct из $total';
  }

  @override
  String get examTitle => 'Режим экзамена';

  @override
  String get classesTitle => 'Группы и задания';

  @override
  String get classesSignInTitle => 'Войдите, чтобы пользоваться группами';

  @override
  String get classesSignInBody =>
      'Создание групп, вступление и отправка заданий привязаны к аккаунту. Чтение контента остаётся доступным без входа.';

  @override
  String get classesSignIn => 'Войти';

  @override
  String get classesUnavailableTitle => 'Сервер групп пока не подключён';

  @override
  String get classesUnavailableBody =>
      'Ничего не отправляется и не сохраняется. После подключения преподаватель видит только свои группы, а студент — только свои результаты; это проверяется на сервере.';

  @override
  String get examSubtitle =>
      'Экзамен на время: выберите темы, число вопросов и время. Работает без интернета.';

  @override
  String get examActiveTitle => 'Незавершённый экзамен';

  @override
  String examActiveBody(int answered, int total, String time) {
    return 'Ответов: $answered/$total · осталось $time';
  }

  @override
  String get examResume => 'Продолжить';

  @override
  String get examDiscard => 'Прервать экзамен';

  @override
  String get examDiscardTitle => 'Прервать экзамен?';

  @override
  String get examDiscardBody =>
      'Ответы удалятся, результат не попадёт в историю.';

  @override
  String get examDiscardAction => 'Прервать';

  @override
  String get examTopics => 'Темы';

  @override
  String get examAllTopics => 'Все';

  @override
  String examPoolCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В выбранных темах $count вопроса',
      many: 'В выбранных темах $count вопросов',
      few: 'В выбранных темах $count вопроса',
      one: 'В выбранных темах $count вопрос',
    );
    return '$_temp0';
  }

  @override
  String get examSettings => 'Параметры';

  @override
  String get examCount => 'Число вопросов';

  @override
  String examCountHint(int max) {
    return 'От 1 до $max';
  }

  @override
  String examCountError(int max) {
    return 'Введите число от 1 до $max';
  }

  @override
  String examCountAll(int count) {
    return 'Все $count';
  }

  @override
  String get examTime => 'Время, мин';

  @override
  String get examTimeHint => '1–180 мин · обычно 1 мин на вопрос';

  @override
  String get examTimeError => 'Введите от 1 до 180 минут';

  @override
  String examMinutes(int count) {
    return '$count мин';
  }

  @override
  String get examDraftNotice =>
      'Вопросы ещё не проверены специалистом (черновик). Результат — для внутренней проверки, это не официальная оценка.';

  @override
  String get examRulesNotice =>
      'Вопросы и варианты — в случайном порядке. До завершения можно менять ответы и отмечать вопросы, чтобы вернуться к ним. Время идёт, даже если приложение закрыто; когда оно истечёт, экзамен завершится сам.';

  @override
  String get examStart => 'Начать экзамен';

  @override
  String get examReplaceTitle => 'Есть незавершённый экзамен';

  @override
  String get examReplaceBody =>
      'Если начать новый, предыдущий удалится вместе с ответами.';

  @override
  String get examHistory => 'История результатов';

  @override
  String get examHistoryEmpty =>
      'Экзаменов пока не было. Первый результат появится здесь — он хранится только на этом устройстве.';

  @override
  String examHistoryStats(int count, int avg, int best) {
    return 'Последние $count: в среднем $avg% · лучший $best%';
  }

  @override
  String examHistoryRow(String date, int correct, int total, String time) {
    return '$date · $correct/$total · $time';
  }

  @override
  String get examHistoryClear => 'Очистить историю';

  @override
  String get examHistoryClearBody =>
      'Все результаты экзаменов будут удалены с этого устройства.';

  @override
  String examHistoryHidden(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ещё $count более старого результата сохранены',
      many: 'Ещё $count более старых результатов сохранены',
      few: 'Ещё $count более старых результата сохранены',
      one: 'Ещё $count более старый результат сохранён',
    );
    return '$_temp0 — в бесплатном режиме видны последние $limit. Ничего не удалено.';
  }

  @override
  String examProgressLabel(String values) {
    return 'Последние результаты: $values';
  }

  @override
  String get examProgressOld => 'Раньше → сейчас';

  @override
  String get examProgressLast => 'Последний';

  @override
  String get examSettled => 'Предыдущий экзамен завершён: время истекло';

  @override
  String get examOpenResult => 'Результат';

  @override
  String get examTitleAll => 'Все темы';

  @override
  String examTitleTopics(String first, int more) {
    return '$first и ещё $more';
  }

  @override
  String get examReworkTitle => 'Работа над ошибками';

  @override
  String get examQuestionMissing =>
      'Этого вопроса нет в текущем пакете контента.';

  @override
  String get examMap => 'Карта вопросов';

  @override
  String get examFinish => 'Завершить';

  @override
  String get examFinishTitle => 'Завершить экзамен?';

  @override
  String examFinishBody(int unanswered, int flagged) {
    return 'Без ответа: $unanswered, отмечено: $flagged. После завершения ответы изменить нельзя.';
  }

  @override
  String get examFinishBodyAll =>
      'На все вопросы есть ответ. После завершения ответы изменить нельзя.';

  @override
  String get examFlag => 'Отметить';

  @override
  String get examFlagged => 'Отмечен';

  @override
  String get examLegendAnswered => 'Есть ответ';

  @override
  String get examLegendEmpty => 'Без ответа';

  @override
  String get examLegendFlagged => 'Отмечен';

  @override
  String examQuestionN(int n) {
    return 'Вопрос $n';
  }

  @override
  String examAnsweredOf(int answered, int total) {
    return 'Ответов: $answered/$total';
  }

  @override
  String get examPrev => 'Назад';

  @override
  String get examNext => 'Далее';

  @override
  String examTimeLeft(String time) {
    return 'Осталось: $time';
  }

  @override
  String examElapsed(String time) {
    return 'Прошло: $time';
  }

  @override
  String get examNoActive => 'Нет активного экзамена';

  @override
  String get examNoActiveBody =>
      'Он завершён или прерван. Настройте и начните новый.';

  @override
  String get examNew => 'Новый экзамен';

  @override
  String get examSaving => 'Сохраняем результат…';

  @override
  String get examResultTitle => 'Результат';

  @override
  String get examResultMissing => 'Результат не найден';

  @override
  String get examBand90 => 'Отличный результат!';

  @override
  String get examBand70 => 'Хороший результат!';

  @override
  String get examBand50 => 'Неплохо — разберите ошибки';

  @override
  String get examBand0 => 'Нужна практика — у вас получится';

  @override
  String get examCorrectN => 'Верно';

  @override
  String get examWrongN => 'Ошибки';

  @override
  String get examSkippedN => 'Без ответа';

  @override
  String get examSpent => 'Время';

  @override
  String get examTimedOut => 'Время вышло — завершено автоматически';

  @override
  String examDeltaUp(int n) {
    return '+$n% к прошлой попытке';
  }

  @override
  String examDeltaDown(int n) {
    return '−$n% к прошлой попытке';
  }

  @override
  String get examDeltaSame => 'Как в прошлой попытке';

  @override
  String examReworkMistakes(int count) {
    return 'Работа над ошибками · $count';
  }

  @override
  String get examAnalysis => 'Разбор ошибок';

  @override
  String examFilterMistakes(int count) {
    return 'Ошибки · $count';
  }

  @override
  String examFilterAll(int count) {
    return 'Все · $count';
  }

  @override
  String get examNoAnswer => 'Нет ответа';

  @override
  String get examWrongTag => 'Ошибка';

  @override
  String get examWhyWrong => 'Почему не этот ответ';

  @override
  String get examNoSource => 'Источник не указан — вопрос ещё не проверен.';

  @override
  String get examSourceMissing =>
      'Банк вопросов этого экзамена не найден в приложении';

  @override
  String get examMultiHint => 'Несколько верных ответов — отметьте все';

  @override
  String get examNoExplanation => 'Пояснение к этому вопросу ещё не написано.';

  @override
  String get examByTopic => 'По темам';

  @override
  String get examByTopicNote =>
      'Сначала — тема с самым низким результатом: начните с неё.';

  @override
  String get classesSubtitle =>
      'Преподаватель создаёт группу и даёт задания, студенты вступают по коду и решают.';

  @override
  String get classesTryExam => 'Открыть экзамен без интернета';

  @override
  String get classesLoading => 'Загрузка…';

  @override
  String get classesInvalid => 'Сервер не принял данные — проверьте поля.';

  @override
  String get classesCodeNotFound =>
      'Группа с таким кодом не найдена. Уточните код у преподавателя.';

  @override
  String get classesCreate => 'Создать группу';

  @override
  String get classesCreateSub =>
      'Для преподавателя: получите код и давайте задания';

  @override
  String get classesJoin => 'Вступить по коду';

  @override
  String get classesJoinSub => 'Для студента: 8-значный код от преподавателя';

  @override
  String get classesRoleNote =>
      'Роль в приложении не даёт прав на сервере: преподаватель группы — тот, кто её создал.';

  @override
  String get classesMine => 'Мои группы';

  @override
  String get classesEmpty => 'Групп пока нет';

  @override
  String get classesEmptyBody =>
      'Создайте группу или вступите по коду от преподавателя.';

  @override
  String get classesRoleTeacher => 'Преподаватель';

  @override
  String get classesRoleStudent => 'Студент';

  @override
  String classesMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участника',
      many: '$count участников',
      few: '$count участника',
      one: '$count участник',
    );
    return '$_temp0';
  }

  @override
  String get classesCreateIntro =>
      'Аккаунт, создавший группу, становится её преподавателем. Студенты вступают по вашему коду.';

  @override
  String get classesGroupName => 'Название группы';

  @override
  String get classesGroupNameHint => 'Например, Биохимия 2 курс';

  @override
  String classesLengthError(int min, int max) {
    return 'Введите от $min до $max символов';
  }

  @override
  String get classesDisplayName => 'Ваше имя в группе';

  @override
  String get classesDisplayNameHint => 'Например, Алиев Анвар';

  @override
  String get classesDisplayNameHintTeacher => 'Например, Каримова Н.А.';

  @override
  String get classesDisplayNameNote =>
      'Email не показывается — участники видят только это имя.';

  @override
  String get classesCreateAction => 'Создать группу';

  @override
  String get classesCreated => 'Группа создана — отправьте код студентам';

  @override
  String get classesJoinIntro => 'Введите код, который дал преподаватель.';

  @override
  String get classesCode => 'Код приглашения';

  @override
  String get classesCodeError => 'Код состоит из 8 букв и цифр';

  @override
  String get classesJoinNote =>
      'Преподаватель увидит указанное имя и результаты ваших заданий. Email не показывается.';

  @override
  String get classesJoinAction => 'Вступить';

  @override
  String get classesJoined => 'Вы вступили в группу';

  @override
  String classesYouTeacher(int count) {
    return 'Вы — преподаватель · участников: $count';
  }

  @override
  String get classesYouStudent => 'Вы — студент';

  @override
  String get classesGroupMissing =>
      'Группа не найдена или вы больше не участник';

  @override
  String get classesBackToList => 'К списку групп';

  @override
  String get classesAssignments => 'Задания';

  @override
  String get classesNewAssignment => 'Новое задание';

  @override
  String get classesNoAssignmentsTeacher =>
      'Заданий пока нет. Выберите темы и число вопросов из банка и дайте задание.';

  @override
  String get classesNoAssignmentsStudent => 'Пока заданий нет';

  @override
  String get classesNoAssignmentsStudentBody =>
      'Когда преподаватель даст задание, оно появится здесь.';

  @override
  String get classesNoDue => 'без срока';

  @override
  String classesDue(String date) {
    return 'срок $date';
  }

  @override
  String classesSubmittedOf(int done, int total) {
    return 'сдали $done/$total';
  }

  @override
  String classesMembersTitle(int count) {
    return 'Студенты · $count';
  }

  @override
  String get classesNoStudents => 'Студентов пока нет — отправьте код.';

  @override
  String get classesMemberNoWork => 'Пока ничего не сдано';

  @override
  String classesMemberSummary(int done, int total, int avg) {
    return 'Заданий: $done/$total · в среднем $avg%';
  }

  @override
  String get classesRemove => 'Исключить из группы';

  @override
  String classesRemoveTitle(String name) {
    return 'Исключить $name из группы?';
  }

  @override
  String get classesRemoveBody =>
      'Студент больше не увидит группу и новые задания. Сданные результаты сохранятся.';

  @override
  String get classesRemoveAction => 'Исключить';

  @override
  String classesStatusDone(int score, int total) {
    return 'Сдано · $score/$total';
  }

  @override
  String get classesStatusInProgress => 'В процессе';

  @override
  String get classesStatusPending => 'Не отправлено';

  @override
  String get classesStatusOverdue => 'Срок истёк';

  @override
  String get classesStatusNew => 'Новое';

  @override
  String get classesStudentNote =>
      'Преподаватель видит только ваше имя в группе и результаты заданий.';

  @override
  String get classesLeave => 'Выйти из группы';

  @override
  String get classesLeaveTitle => 'Выйти из группы?';

  @override
  String get classesLeaveBody =>
      'Чтобы вернуться, понадобится код преподавателя. Сданные результаты останутся у преподавателя.';

  @override
  String get classesLeaveAction => 'Выйти';

  @override
  String get classesInviteTitle => 'Код приглашения';

  @override
  String get classesInviteBody =>
      'Студентам: Обучение → Группы и задания → Вступить по коду.';

  @override
  String get classesCopyCode => 'Скопировать код';

  @override
  String get classesCopyInvite => 'Скопировать приглашение';

  @override
  String get classesCopied => 'Скопировано';

  @override
  String classesInviteText(String name, String code) {
    return 'Вступите в группу «$name» в приложении LabGuide: Обучение → Группы и задания → Вступить по коду. Код: $code';
  }

  @override
  String get classesNewAssignmentIntro =>
      'Выберите темы и число вопросов — они берутся из банка случайно.';

  @override
  String get classesAssignmentTitle => 'Название задания';

  @override
  String get classesAssignmentTitleHint => 'Например, Тема 1';

  @override
  String get classesTimeLimit => 'Ограничение времени, мин';

  @override
  String get classesTimeLimitHint =>
      'Необязательно, 1–180. Время идёт с момента начала и проверяется на сервере.';

  @override
  String get classesNoLimit => 'Без ограничения';

  @override
  String get classesDueTitle => 'Срок сдачи';

  @override
  String get classesDueNone => 'Без срока';

  @override
  String classesDueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get classesDuePick => 'Выбрать дату';

  @override
  String get classesDueNoneBody => 'Без срока — студенты сдают в любое время.';

  @override
  String classesDueAt(String date) {
    return 'Срок: до $date';
  }

  @override
  String classesPreview(int count) {
    return 'Выбранные вопросы · $count';
  }

  @override
  String get classesReshuffle => 'Другие вопросы';

  @override
  String get classesKeyNotice =>
      'Студенты не видят ключ заранее — баллы считает сервер. Каждый сдаёт один раз.';

  @override
  String get classesSendAssignment => 'Дать задание';

  @override
  String get classesAssignmentCreated => 'Задание отправлено';

  @override
  String get classesSubmitted => 'Ответы отправлены';

  @override
  String get classesSubmitNetwork =>
      'Нет интернета — ответы сохранены на устройстве. Отправьте позже.';

  @override
  String get classesSubmitRejected =>
      'Сервер не принял ответы: время или срок истекли, либо задание уже сдано.';

  @override
  String get classesAssignmentMissing => 'Задание не найдено';

  @override
  String get classesMetricQuestions => 'Вопросов';

  @override
  String get classesMetricLimit => 'Ограничение времени';

  @override
  String get classesMetricDue => 'Срок';

  @override
  String get classesMetricSubmitted => 'Сдали';

  @override
  String get classesMetricAverage => 'Средний балл';

  @override
  String get classesPendingTitle => 'Ответы ещё не отправлены';

  @override
  String get classesPendingBody =>
      'Они сохранены на устройстве. Отправьте, когда появится интернет, — сервер примет их в пределах лимита времени.';

  @override
  String get classesResend => 'Отправить снова';

  @override
  String get classesOverdueTitle => 'Срок истёк';

  @override
  String get classesOverdueBody => 'Это задание больше нельзя сдать.';

  @override
  String classesOutdatedPack(int count) {
    return 'В вашей версии приложения нет вопросов из этого задания: $count. Обновите приложение.';
  }

  @override
  String classesStartNotice(int minutes) {
    return 'После начала даётся $minutes мин — время не останавливается, по окончании ответы отправятся сами. Сдать можно один раз; для отправки нужен интернет.';
  }

  @override
  String get classesStartNoticeNoLimit =>
      'Без ограничения времени. Ответы отправляются один раз, пересдать нельзя; для отправки нужен интернет.';

  @override
  String get classesStart => 'Начать';

  @override
  String classesSubmittedAt(String date) {
    return 'Сдано: $date';
  }

  @override
  String get classesServerScore => 'Балл посчитан сервером';

  @override
  String get classesResults => 'Результаты';

  @override
  String get classesColStudent => 'Студент';

  @override
  String get classesColScore => 'Балл · %';

  @override
  String get classesNotSubmitted => 'Не сдано';

  @override
  String get classesByQuestion => 'По вопросам';

  @override
  String get classesByQuestionEmpty => 'Пока никто не сдал.';

  @override
  String classesWrongOf(int wrong, int total) {
    return 'ошибок $wrong/$total';
  }

  @override
  String get classesSending => 'Отправка ответов…';

  @override
  String get classesMyProgress => 'Мой прогресс';

  @override
  String classesDoneOf(int done, int total) {
    return 'Выполнено заданий: $done/$total';
  }

  @override
  String classesAverage(int avg) {
    return 'Средний балл: $avg%';
  }

  @override
  String get classesStudentResultTitle => 'Результат студента';

  @override
  String get classesStudentAnswer => 'Ответ студента';

  @override
  String get classesInviteMore => 'Пригласить ещё студентов';

  @override
  String get profileTitle => 'Профиль и настройки';

  @override
  String get profileGuest => 'Гость';

  @override
  String get profileGuestSub => 'Контент доступен без аккаунта';

  @override
  String get profileDemoSession => 'Демо-сессия · debug-сборка';

  @override
  String get profileRole => 'Направление';

  @override
  String get profileRoleSub => 'Главная адаптируется под вас';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileAppearance => 'Оформление';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get profilePurchase => 'Подписка и восстановление';

  @override
  String get profilePurchaseSub => 'Free · Pro';

  @override
  String get profilePrivacy => 'Конфиденциальность и помощь';

  @override
  String get profilePrivacySub => 'Данные и управление аккаунтом';

  @override
  String get supportTitle => 'Предложения и помощь';

  @override
  String get supportSub => 'Предложение, ошибка или вопрос — ответ придёт сюда';

  @override
  String get supportNew => 'Новое обращение';

  @override
  String get supportEmptyTitle => 'Обращений пока нет';

  @override
  String get supportEmptyBody =>
      'Напишите предложение, сообщите об ошибке или задайте вопрос — ответ появится здесь.';

  @override
  String get supportKind => 'Тип';

  @override
  String get supportKindSuggestion => 'Предложение';

  @override
  String get supportKindBug => 'Ошибка';

  @override
  String get supportKindQuestion => 'Вопрос';

  @override
  String get supportSubject => 'Тема';

  @override
  String get supportSubjectHint => 'Коротко: о чём?';

  @override
  String get supportMessage => 'Сообщение';

  @override
  String get supportMessageHint =>
      'Подробно: на каком экране, что вы сделали и что ожидали';

  @override
  String get supportAttach => 'Прикрепить скриншот (необязательно)';

  @override
  String get supportAttachRemove => 'Убрать изображение';

  @override
  String get supportAttachTooLarge =>
      'Изображение больше 5 МБ. Выберите изображение поменьше.';

  @override
  String get supportAttachType => 'Только PNG или JPEG.';

  @override
  String get supportPhiNotice =>
      'На скриншоте не должно быть имени пациента, даты рождения, номера карты и других персональных данных.';

  @override
  String get supportSend => 'Отправить';

  @override
  String get supportSent => 'Обращение отправлено';

  @override
  String get supportReplyHint => 'Напишите ответ…';

  @override
  String get supportTeam => 'Команда LabGuide';

  @override
  String get supportYou => 'Вы';

  @override
  String get supportUser => 'Пользователь';

  @override
  String get supportHumanReplies =>
      'Ответы пишет команда LabGuide; автоматических ответов нет.';

  @override
  String get supportStatusNew => 'Новое';

  @override
  String get supportStatusInReview => 'На рассмотрении';

  @override
  String get supportStatusAnswered => 'Отвечено';

  @override
  String get supportStatusClosed => 'Закрыто';

  @override
  String get supportUnread => 'Новый ответ';

  @override
  String supportUnreadCount(int count) {
    return 'Новых ответов: $count';
  }

  @override
  String get supportSignInTitle => 'Войдите, чтобы отправить обращение';

  @override
  String get supportSignInBody =>
      'Чтобы ответ дошёл до вас, нужно войти по email. Данные на устройстве не изменятся.';

  @override
  String get supportUnavailableTitle => 'Сервер ещё не подключён';

  @override
  String get supportUnavailableBody =>
      'В этой сборке сервер аккаунтов, обращений и групп не подключён. После подключения всё заработает здесь.';

  @override
  String get errNetwork => 'Нет соединения с интернетом. Попробуйте снова.';

  @override
  String get errRateLimited => 'Слишком много запросов. Попробуйте чуть позже.';

  @override
  String get errInvalidSupport =>
      'Тема — не короче 3 символов, сообщение не должно быть пустым.';

  @override
  String get errForbidden => 'Нет доступа к этому действию.';

  @override
  String get errSessionExpired => 'Сессия истекла. Войдите снова.';

  @override
  String get errGeneric => 'Не получилось. Попробуйте снова.';

  @override
  String get accountDelete => 'Удалить аккаунт';

  @override
  String get accountDeleteSub =>
      'Удалятся аккаунт на сервере, обращения и участие в группах';

  @override
  String get accountDeleteTitle => 'Удалить аккаунт?';

  @override
  String get accountDeleteBody =>
      'Аккаунт, обращения, вложения и результаты в группах будут полностью удалены с сервера. Отменить это нельзя. Записи КК и закладки на устройстве удаляются отдельно.';

  @override
  String get accountDeleted => 'Аккаунт удалён';

  @override
  String get adminTitle => 'Админ-панель';

  @override
  String get adminSub => 'Статистика, обращения, пользователи';

  @override
  String get adminMfaTitle => 'Двухфакторная защита';

  @override
  String get adminMfaEnrollBody =>
      'Для админ-панели нужно приложение-аутентификатор (Google Authenticator, Microsoft Authenticator, 1Password…). Добавьте ключ в приложение и введите показанный 6-значный код.';

  @override
  String get adminMfaVerifyBody =>
      'Введите 6-значный код из приложения-аутентификатора.';

  @override
  String get adminMfaSecret => 'Ключ';

  @override
  String get adminMfaCopy => 'Скопировать ключ';

  @override
  String get adminMfaOpen => 'Открыть в аутентификаторе';

  @override
  String get adminMfaCode => '6-значный код';

  @override
  String get adminMfaVerify => 'Подтвердить';

  @override
  String get adminMfaWrong =>
      'Код неверный или устарел. Введите новый код из приложения.';

  @override
  String get adminCopied => 'Скопировано';

  @override
  String get adminForbiddenTitle => 'Только для администратора';

  @override
  String get adminForbiddenBody =>
      'Права администратора выдаёт сервер — роль или email в приложении на это не влияют.';

  @override
  String get adminStats => 'Статистика';

  @override
  String get adminRegistered => 'Зарегистрировано';

  @override
  String get adminNewToday => 'Новых сегодня';

  @override
  String get adminNew7 => 'Новых за 7 дней';

  @override
  String get adminNew30 => 'Новых за 30 дней';

  @override
  String get adminActiveToday => 'Активны сегодня';

  @override
  String get adminActive7 => 'Активны за 7 дней';

  @override
  String get adminActive30 => 'Активны за 30 дней';

  @override
  String get adminDefinitions =>
      'Зарегистрирован — аккаунт с email, подтверждённым кодом; гости и неподтвердившие не считаются. Новый — день первого подтверждения email. Активный — хотя бы раз открыл приложение, будучи в аккаунте, за период. Дни по ташкентскому времени; «7 дней» включая сегодня.';

  @override
  String get adminByRole => 'По ролям';

  @override
  String get adminByLanguage => 'По языкам';

  @override
  String adminNoProfile(int count) {
    return 'Профиль ещё не создан: $count';
  }

  @override
  String get adminBilling => 'Free / Pro: биллинг не подключён — данных нет';

  @override
  String get adminInbox => 'Обращения';

  @override
  String adminAwaiting(int count) {
    return 'Ждут ответа: $count';
  }

  @override
  String get adminAllStatuses => 'Все';

  @override
  String get adminUsers => 'Пользователи';

  @override
  String get adminAudit => 'Журнал действий';

  @override
  String get adminAuditEmpty => 'Действий пока нет';

  @override
  String get adminSearchHint => 'Поиск по email';

  @override
  String get adminAllRoles => 'Все роли';

  @override
  String get adminAllLanguages => 'Все языки';

  @override
  String get adminShowEmail => 'Показать email (запишется в журнал)';

  @override
  String get adminReviewer => 'Рецензент контента';

  @override
  String adminPage(int from, int to, int total) {
    return '$from–$to из $total';
  }

  @override
  String get adminPrev => 'Назад';

  @override
  String get adminNext => 'Далее';

  @override
  String adminRegisteredOn(String date) {
    return 'Регистрация: $date';
  }

  @override
  String adminLastSeen(String date) {
    return 'Последняя активность: $date';
  }

  @override
  String get adminNoUsers => 'Пользователи не найдены';

  @override
  String get adminReplyHint => 'Напишите ответ сами';

  @override
  String get adminSendReply => 'Отправить ответ';

  @override
  String get adminStatus => 'Статус';

  @override
  String get adminRefresh => 'Обновить';

  @override
  String get adminActionSupportReply => 'Ответ на обращение';

  @override
  String get adminActionSupportStatus => 'Изменён статус обращения';

  @override
  String get adminActionRevealEmail => 'Просмотрен email';

  @override
  String get adminActionReviewerGranted => 'Выданы права рецензента';

  @override
  String get adminActionReviewerRevoked => 'Отозваны права рецензента';

  @override
  String get adminActionAdminGranted => 'Выданы права администратора';

  @override
  String get adminActionAdminRevoked => 'Отозваны права администратора';

  @override
  String get profileSignIn => 'Войти по email';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get profileRestartSetup => 'Начать настройку заново';

  @override
  String get profileSignOutTitle => 'Выйти из аккаунта?';

  @override
  String get profileSignOutBody =>
      'Закладки, записи контроля качества, заметки и результаты тренировок останутся на этом устройстве. Если устройством будет пользоваться кто-то другой, удалите и их.';

  @override
  String get profileSignOutDelete => 'Выйти и удалить';

  @override
  String profileVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get purchaseTitle => 'LabGuide Pro';

  @override
  String get purchaseFree =>
      'Бесплатно: счётчик лейкоформулы, проценты и абсолютные числа, основные руководства, в истории последние 3 результата.';

  @override
  String get purchasePro =>
      'Pro (помесячно или на год): неограниченная история результатов, экспорт в PDF, расширенные упражнения, полная подготовка к экзамену на категорию.';

  @override
  String get purchaseNotice =>
      'Товары магазина не подключены. Цены будут получены из App Store / Google Play в вашей валюте. Здесь ничего не списывается, а неготовые функции не продаются.';

  @override
  String get purchaseSubscribe => 'Оформить подписку';

  @override
  String get purchaseRestore => 'Восстановить покупки';

  @override
  String get purchaseStatusTitle => 'Статус';

  @override
  String get purchaseStatusAllOpen =>
      'Оплата ещё не включена; в TestFlight открыты все возможности.';

  @override
  String get purchaseStatusBillingOff =>
      'Оплата ещё не включена. Бесплатные возможности работают полностью; Pro включится после утверждения цены.';

  @override
  String purchaseStatusPro(String date) {
    return 'Pro активна · до $date';
  }

  @override
  String get purchaseStatusProNoEnd => 'Pro активна';

  @override
  String purchaseStatusOffline(String date) {
    return 'Без интернета: последняя проверка $date';
  }

  @override
  String get purchaseStatusFree => 'Сейчас: бесплатный режим';

  @override
  String get privacyTitle => 'Конфиденциальность и помощь';

  @override
  String get privacyBody =>
      'В гостевом режиме приложение ничего не отправляет на сервер: настройки, закладки, записи QC, ваши приборы и результаты тренировок хранятся на этом устройстве (могут попадать в системную резервную копию). При входе по email на сервере хранятся email, роль, язык, день последней активности, ваши обращения и результаты в группах; без рекламного отслеживания. Аккаунт можно удалить в любой момент.';

  @override
  String get privacyTerms => 'Условия использования';

  @override
  String get privacyTermsSub => 'Окончательный текст будет подготовлен';

  @override
  String get privacyDeleteLocal => 'Удалить локальные данные';

  @override
  String get privacyDeleteLocalSub =>
      'Настройки, закладки, черновики, записи контроля качества и результаты тренировок';

  @override
  String get privacyDeleteConfirmTitle => 'Удалить локальные данные?';

  @override
  String get privacyDeleteConfirmBody =>
      'Настройки, закладки, черновики, все записи контроля качества (серии и целевые значения) и результаты тренировок на этом устройстве будут удалены. Это нельзя отменить — при необходимости сначала сделайте резервную копию контроля качества (Лаборатория → Контроль качества).';

  @override
  String get privacyDeleted => 'Локальные данные удалены';

  @override
  String get termsTitle => 'Условия использования';

  @override
  String get termsBody =>
      'Окончательные условия, политика конфиденциальности и границы клинического применения будут подготовлены до выпуска. LabGuide — справочный и учебный инструмент: он не ставит диагнозы, не назначает лечение и не заменяет процедуры вашей лаборатории.';

  @override
  String citePage(String page) {
    return 'с. $page';
  }

  @override
  String get rightsUnknown => 'Право распространения не подтверждено';

  @override
  String get rightsPersonal =>
      'Только для личного изучения — не распространяется';

  @override
  String get rightsPermitted => 'Разрешение на распространение зафиксировано';

  @override
  String get rightsDenied => 'Распространение не разрешено';

  @override
  String get catBiochemistry => 'Биохимия';

  @override
  String get catClinicalLab => 'Клиническая лаборатория';

  @override
  String get catInstruments => 'Приборы';

  @override
  String get catMethods => 'Методики';

  @override
  String get catTests => 'Лабораторные анализы';

  @override
  String get kindBook => 'Книга';

  @override
  String get kindManual => 'Руководство';

  @override
  String get kindMethod => 'Методика';

  @override
  String get kindIfu => 'IFU';

  @override
  String get kindArticle => 'Статья';

  @override
  String get kindQuestionSet => 'Сборник вопросов';

  @override
  String get kindWebsite => 'Веб-ресурс';

  @override
  String libAccessOpen(String licence) {
    return 'Открытая лицензия · $licence';
  }

  @override
  String get libAccessFree => 'Бесплатно для чтения · только ссылка';

  @override
  String get libAccessCatalog => 'Только библиографическая запись';

  @override
  String get libOpenSource => 'Открыть официальную страницу';

  @override
  String libChecked(String date) {
    return 'Страница и лицензия проверены: $date';
  }

  @override
  String libItemPack(String size) {
    return 'Офлайн-пакет · $size';
  }

  @override
  String get libItemNoPack => 'Недоступно как общий офлайн-пакет';

  @override
  String libItemSupersedes(String title) {
    return 'Новое издание. Предыдущее: $title';
  }

  @override
  String get libForYou => 'Для вас';

  @override
  String get libMoreSections => 'Другие разделы';

  @override
  String get libSearchEntry => 'Поиск: книга, автор, тема';

  @override
  String libBooksCount(int count) {
    return 'Источников: $count · поиск и фильтры';
  }

  @override
  String get libIntake => 'Как добавляются материалы';

  @override
  String get libIntakeSub =>
      'Для преподавателя и редактора: что прислать, права, проверка';

  @override
  String get libContinueReading => 'Продолжить чтение';

  @override
  String get libSearchLabel => 'Поиск в библиотеке';

  @override
  String get libSearchHint => 'Название, автор, тема…';

  @override
  String get libFilterLanguage => 'Язык';

  @override
  String get libFilterTopic => 'Тема';

  @override
  String get libFilterType => 'Тип';

  @override
  String get libFilterSectionField => 'Направление';

  @override
  String get libFilterSectionGroup => 'Группа анализов';

  @override
  String get libFilterSectionKind => 'Вид материала';

  @override
  String get libFilterSectionOpen => 'Как открывается';

  @override
  String libFilterChoose(String filter) {
    return '$filter: выберите';
  }

  @override
  String libResultCount(int shown, int total) {
    return 'Материалов: $shown из $total';
  }

  @override
  String get libClearFilters => 'Сбросить';

  @override
  String get libFilteredEmptyTitle => 'По этим фильтрам материалов нет';

  @override
  String get libFilteredEmptyBody =>
      'Уберите один фильтр или попробуйте другое слово — например, фамилию автора или «моча».';

  @override
  String get libOpenLink => 'Ссылка · внешний сайт';

  @override
  String libOpenLinkHint(String host) {
    return 'Откроется в браузере: $host';
  }

  @override
  String get libOpenInApp => 'Файл в приложении';

  @override
  String get libOpenInAppHint => 'Читается в приложении — интернет не нужен';

  @override
  String get libOpenDownload => 'Книга для загрузки';

  @override
  String libOpenDownloadHint(String size) {
    return 'После загрузки читается в приложении · $size';
  }

  @override
  String get libOpenPending => 'Ожидается';

  @override
  String get libOpenPendingHint => 'Материал ещё не получен — открыть нельзя';

  @override
  String get libOpenReceivedHint =>
      'Файл получен и проверяется — пока не открывается';

  @override
  String get libOpenRecordHint =>
      'Право на распространение файла не зафиксировано — в приложении не открывается';

  @override
  String get libOpenLinkShort => 'Ссылка';

  @override
  String get libOpenInAppShort => 'В приложении';

  @override
  String get libOpenDownloadShort => 'Для загрузки';

  @override
  String get libOpenRecordShort => 'Только запись';

  @override
  String get libItemRead => 'Читать';

  @override
  String libItemContinue(int page) {
    return 'Продолжить со стр. $page';
  }

  @override
  String get libItemCannotOpen => 'Открыть нельзя';

  @override
  String get libDownloadUnavailable =>
      'Сервер загрузки ещё не подключён — книгу пока нельзя скачать.';

  @override
  String get libDetailsTitle => 'Сведения';

  @override
  String get libFieldAuthors => 'Автор';

  @override
  String get libFieldYear => 'Год';

  @override
  String get libFieldEdition => 'Издание';

  @override
  String get libFieldPublisher => 'Издательство';

  @override
  String get libFieldAccess => 'Доступ';

  @override
  String get libFieldStatus => 'Статус';

  @override
  String get libFieldRights => 'Право на распространение';

  @override
  String libFieldRightsRecorded(String date, String by) {
    return 'Зафиксировано: $date · $by';
  }

  @override
  String get libFieldTopics => 'Темы';

  @override
  String get libFieldPages => 'Страниц';

  @override
  String get libStateNotReceived => 'Ещё не получен';

  @override
  String get libStateReceived => 'Получен, проверяется';

  @override
  String get libStateCataloged => 'Каталогизирован';

  @override
  String get libStateLinked => 'Связан с карточками';

  @override
  String get libStateReviewed => 'Подтверждён преподавателем';

  @override
  String get libProvidedByTeacher => 'Материал от преподавателя';

  @override
  String get libItemNotFound => 'Материал не найден';

  @override
  String get libItemNotFoundBody =>
      'Возможно, пакет контента обновился. Вернитесь в каталог.';

  @override
  String get libBackToCatalog => 'Вернуться в каталог';

  @override
  String get readerTitle => 'Чтение';

  @override
  String readerPageOf(int page, int total) {
    return '$page из $total';
  }

  @override
  String get readerToc => 'Оглавление';

  @override
  String get readerTocEmpty => 'В этом файле нет оглавления';

  @override
  String get readerTocEmptyBody =>
      'Перейдите на страницу или поставьте закладку в нужном месте.';

  @override
  String get readerBookmarks => 'Закладки';

  @override
  String get readerAddBookmark => 'Добавить закладку';

  @override
  String get readerBookmarkName => 'Название закладки';

  @override
  String get readerBookmarkNameHint => 'Например: важная таблица';

  @override
  String readerBookmarkSaved(int page) {
    return 'Закладка сохранена: стр. $page';
  }

  @override
  String get readerBookmarkRemoved => 'Закладка удалена';

  @override
  String get readerBookmarkRemove => 'Удалить закладку';

  @override
  String get readerBookmarksEmpty => 'Закладок пока нет';

  @override
  String get readerBookmarksEmptyBody =>
      'На нужной странице нажмите «Добавить закладку» — потом вернётесь одним касанием.';

  @override
  String readerPageLabel(int page) {
    return 'Стр. $page';
  }

  @override
  String get readerGoTo => 'Перейти на страницу';

  @override
  String get readerGoToShort => 'Страница';

  @override
  String readerGoToHint(int total) {
    return 'От 1 до $total';
  }

  @override
  String readerGoToError(int total) {
    return 'Введите число от 1 до $total';
  }

  @override
  String get readerGo => 'Перейти';

  @override
  String get readerSave => 'Сохранить';

  @override
  String get readerRenameBookmark => 'Переименовать закладку';

  @override
  String get libFieldProvidedBy => 'От кого';

  @override
  String get libQueryEmptyBody =>
      'Попробуйте другое слово — например, фамилию автора, «моча» или «биохимия».';

  @override
  String get readerZoomIn => 'Увеличить';

  @override
  String get readerZoomOut => 'Уменьшить';

  @override
  String readerResumed(int page) {
    return 'Вы остановились на стр. $page';
  }

  @override
  String get readerFromStart => 'С начала';

  @override
  String get readerLoading => 'Открываем файл…';

  @override
  String get readerFileMissing => 'Файл не найден';

  @override
  String get readerFileMissingBody =>
      'Этого файла нет в приложении. Попробуйте обновить приложение.';

  @override
  String get readerFileCorrupted => 'Файл не прошёл проверку';

  @override
  String get readerFileCorruptedBody =>
      'Размер файла или контрольная сумма не совпадают с каталогом — файл мог быть повреждён или подменён, поэтому он не открыт.';

  @override
  String get readerOpenFailed => 'Не удалось открыть PDF';

  @override
  String get readerBlockedTitle => 'Не открывается в приложении';

  @override
  String get readerBlockedRights =>
      'В приложении открываются только файлы с полностью зафиксированным правом на распространение. Для этого материала такого файла нет.';

  @override
  String get readerBookmarkedPage => 'Эта страница в закладках';

  @override
  String get intakeTitle => 'Добавление материалов';

  @override
  String get intakeSubtitle => 'Краткий порядок для преподавателя и редактора';

  @override
  String intakeStatus(int count) {
    return 'Материалов от преподавателей: $count. Список пополняется по мере поступления.';
  }

  @override
  String get intakeWhatTitle => '1. Что прислать';

  @override
  String get intakeWhat1 =>
      'Файл книги, пособия, методики или IFU (PDF) и его данные: название, автор, год и издание, издательство, ISBN, язык.';

  @override
  String get intakeWhat2 =>
      'Тестовые вопросы: вопрос, варианты, верный ответ, пояснение к каждому варианту и страница источника.';

  @override
  String get intakeWhat3 =>
      'Если есть старое и новое издание — оба: расхождения рассматриваются отдельно.';

  @override
  String get intakeRightsTitle => '2. Право на распространение';

  @override
  String get intakeRights1 =>
      'Переданный PDF сам по себе не означает права раздавать его всем.';

  @override
  String get intakeRights2 =>
      'Чтобы файл открывался в приложении у всех, право фиксируется полностью: кто разрешил (автор или издательство), когда, кто зафиксировал и доказательство — письмо-разрешение или ссылка на лицензию.';

  @override
  String get intakeRights3 =>
      'Без такой записи материал остаётся только записью в каталоге или для личного использования.';

  @override
  String get intakeReviewTitle => '3. Как проверяется';

  @override
  String get intakeStep1 => 'Ожидается — материал ещё не пришёл.';

  @override
  String get intakeStep2 => 'Получен — файл пришёл и внесён в список.';

  @override
  String get intakeStep3 =>
      'Каталогизирован — проверены название, автор и издание. Только после этого его можно цитировать.';

  @override
  String get intakeStep4 =>
      'Связан — привязан к карточкам анализов и урокам с номером страницы.';

  @override
  String get intakeStep5 =>
      'Подтверждён — преподаватель проверил. До этого вопросы остаются «Черновиком».';

  @override
  String get intakeConflict =>
      'Если старый и новый источник расходятся, ни один не записывается как факт — обе позиции показываются проверяющему.';

  @override
  String get intakeNeverTitle => 'Чего мы не делаем';

  @override
  String get intakeNever1 =>
      'Показывать неполученный материал как «доступный».';

  @override
  String get intakeNever2 =>
      'Угадывать номер страницы или писать то, чего нет в источнике.';

  @override
  String get intakeNever3 => 'Раздавать всем книгу без зафиксированного права.';

  @override
  String get intakeContactTitle => '4. Связь';

  @override
  String get intakeContactBody =>
      'Напишите команде LabGuide о материале: название, автор, издание и правообладатель. Способ передачи файла согласуется с командой — загрузить PDF через приложение нельзя.';

  @override
  String get intakeContactAction => 'Написать команде LabGuide';

  @override
  String get libReview => 'Очередь проверки';

  @override
  String get libReviewSub => 'Расхождения источников и черновики';

  @override
  String get reviewDiscrepancies => 'Расхождения между источниками';

  @override
  String get rvGateTitle => 'Только для рецензентов';

  @override
  String get rvGateBody =>
      'Права рецензента выдаёт администратор. Роль в приложении (например, «Преподаватель») их не даёт.';

  @override
  String get rvSignInTitle => 'Войдите, чтобы рецензировать';

  @override
  String get rvAdminReadOnly =>
      'Как администратор вы видите решения. Чтобы рецензировать, выдайте своему аккаунту права рецензента (Админ → Пользователи).';

  @override
  String get rvTabCards => 'Карточки';

  @override
  String get rvTabQuestions => 'Вопросы';

  @override
  String get rvTabDiscrepancies => 'Расхождения';

  @override
  String rvMine(String decision) {
    return 'Ваше решение: $decision';
  }

  @override
  String get rvNotSeen => 'Вы ещё не смотрели';

  @override
  String rvCount(int count) {
    return 'Решений: $count';
  }

  @override
  String get rvApprove => 'Утверждаю';

  @override
  String get rvChanges => 'Нужны правки';

  @override
  String get rvDecisionApprove => 'утверждено';

  @override
  String get rvDecisionChanges => 'запрошены правки';

  @override
  String get rvComment => 'Комментарий';

  @override
  String get rvCommentHint =>
      'Что неверно или что проверить (источник, страница)';

  @override
  String get rvCommentRequired => 'Для «Нужны правки» напишите комментарий.';

  @override
  String get rvSubmit => 'Отправить решение';

  @override
  String get rvSubmitted => 'Решение записано';

  @override
  String get rvNotAuto =>
      'Решение само не меняет статус карточки: после редакции она станет «Проверено» в следующем пакете контента.';

  @override
  String get rvHistory => 'История решений';

  @override
  String get rvYou => 'Вы';

  @override
  String get rvReviewer => 'Рецензент';

  @override
  String get rvNoHistory => 'Решений пока нет';

  @override
  String get rvOpenCard => 'Открыть карточку';

  @override
  String get rvCorrect => 'Правильный ответ';

  @override
  String get rvBasis => 'Обоснование';

  @override
  String get rvYourDecision => 'Ваше решение';

  @override
  String get rvAllDone => 'Всё просмотрено';

  @override
  String get analytePreparedBy => 'Подготовил';

  @override
  String get analyteEditorial => 'Редакция LabGuide';

  @override
  String get analyteSourcesChecked => 'Источники просмотрены';

  @override
  String get reviewDiscrepanciesBody =>
      'Если старые и новые источники расходятся, обе позиции показываются здесь для экспертной проверки. До решения ни одна не публикуется как факт.';

  @override
  String get reviewNoDiscrepancies => 'Открытых расхождений нет.';

  @override
  String reviewDraftQuestions(int count) {
    return 'Черновики вопросов: $count';
  }

  @override
  String reviewDraftCards(int count) {
    return 'Карточки, ожидающие экспертизы: $count';
  }

  @override
  String reviewCatalog(int count) {
    return 'Материалов в каталоге: $count';
  }

  @override
  String reviewField(String field) {
    return 'Поле: $field';
  }

  @override
  String get quizDraftTag => 'Черновик · не проверено';

  @override
  String get lessonsTitle => 'Темы занятий';

  @override
  String get analyteTreatmentGoals => 'Цели лечения';

  @override
  String get analyteTreatmentGoalsNotice =>
      'Цель лечения устанавливает врач на основе полной оценки риска пациента; приложение не определяет категорию риска.';

  @override
  String get analyteTreatmentGoalsNotRef =>
      'Цели лечения — не референсные интервалы и не диагностические пороги. Рекомендации по-разному определяют группы риска — сравнивайте значения только внутри одной таблицы.';

  @override
  String analyteGoalGuideline(String name, String year) {
    return '$name · $year';
  }

  @override
  String get analyteAgentCheck => 'Автоматическая/агентная проверка';

  @override
  String analyteAgentCheckValue(String date) {
    return '$date (не экспертное подтверждение)';
  }

  @override
  String get analyteExpertApproval => 'Подтверждение эксперта';

  @override
  String get analyteExpertApprovalPending => 'ожидается';
}
