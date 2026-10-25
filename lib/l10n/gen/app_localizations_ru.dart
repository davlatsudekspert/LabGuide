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
      'Для чтения контента аккаунт не нужен. Вход нужен для синхронизации и групп.';

  @override
  String get welcomeBenefitDoctorTitle => 'Врачу';

  @override
  String get welcomeBenefitDoctorBody =>
      'Результат, влияющие факторы и анализы по заболеваниям';

  @override
  String get welcomeBenefitLabTitle => 'Специалисту лаборатории';

  @override
  String get welcomeBenefitLabBody =>
      'Контроль качества, взятие образцов, приборы и калькуляторы';

  @override
  String get welcomeBenefitLearnTitle => 'Студенту и преподавателю';

  @override
  String get welcomeBenefitLearnBody =>
      'Темы, вопросы с разбором, экзамен и группы';

  @override
  String get stateLoading => 'Загрузка…';

  @override
  String get homeTileTests => 'Норма, причины и трактовка';

  @override
  String get homeTileCalculators => 'eGFR, ACR, разведение и др.';

  @override
  String get homeTileSampling => 'Пробирки, хранение, доставка';

  @override
  String get homeTileSaved => 'Быстрый доступ к отмеченному';

  @override
  String get homeTileDiff => 'Счётчик и атлас клеток';

  @override
  String get homeTileCalibration => 'Прибор, реагент и IFU';

  @override
  String get homeTileInstruments => 'Принципы работы и методики';

  @override
  String get homeTileExam => 'Пробный экзамен на время';

  @override
  String get homeTileTopics => 'Тема, разбор и практика';

  @override
  String get homeTileClasses => 'Студенты и задания';

  @override
  String get homeTileLecture => 'Слайды и показ на экране';

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
  String get homeHeroDoctorCta => 'Найти анализ';

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
      'Справочник помогает планировать обследование. Клиническая оценка и окончательное решение — за врачом. Текст основан на источниках, они указаны в каждой карточке.';

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
      'Справочник LabGuide. Не инструмент диагностики — окончательное решение за врачом.';

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
  String get homeHeroStudentCta => 'Начать вопросы дня';

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
  String get featureSaved => 'Сохранённое';

  @override
  String get featureCalibration => 'Калибровка';

  @override
  String get featureQc => 'Контроль качества (QC)';

  @override
  String get featureTopics => 'Темы';

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
  String get statusVerified => 'Проверено';

  @override
  String get statusPublished => 'Опубликовано';

  @override
  String get statusSourcedSample => 'На основе источников';

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
      'В карточке пока только структура. Клинический текст добавляется вместе с источниками — общий текст не выдаётся за готовый.';

  @override
  String get analyteNotWritten =>
      'Ещё не написано: текст добавляется вместе с источниками.';

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
  String get analyteRefIntervals => 'Референтные интервалы';

  @override
  String get analyteRefIntervalNone =>
      'Референтный интервал здесь не приводится. Используйте интервал из бланка вашей лаборатории: он зависит от метода, образца и популяции.';

  @override
  String get analyteDecisionLimits => 'Диагностические пороги';

  @override
  String get analyteDecisionNotRef =>
      'Диагностические пороги — это не лабораторный референтный интервал.';

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
  String get analyteReview => 'Подготовка и источники';

  @override
  String get analyteReviewPending => 'Ожидает экспертизы';

  @override
  String get analyteReviewApproved => 'Проверено';

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
  String get labHeroEyebrow => 'Прибор → реагент → метод';

  @override
  String get labHeroTitle => 'Калибровка';

  @override
  String get labSectionsTitle => 'Разделы и атласы';

  @override
  String get labToolsTitle => 'Рабочие инструменты';

  @override
  String get labHeroBody => 'Инструкции и контроль для конкретной модели.';

  @override
  String get labHeroCta => 'Открыть калибровку';

  @override
  String get labQcSub => 'Контрольные карты и правила';

  @override
  String get labPreanalytics => 'Преаналитика';

  @override
  String get labPreanalyticsSub => 'Взятие, хранение и доставка образца';

  @override
  String get labCalculatorsSub => 'eGFR, ACR, разведение и др.';

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
  String get calStep5 => 'КК после калибровки';

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
  String get qcJumpToAddRun => 'Ввести серию ниже';

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
  String get preTitle => 'Преаналитика';

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
      'Цвет пробирки, время и температура зависят от конкретной пробирки, метода и инструкции. Сроки выше — общий ориентир по таблице ВОЗ; правила вашей лаборатории важнее.';

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
      'LabGuide · ручной подсчёт. Референтный интервал — на бланке лаборатории.';

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
  String get diffEfEntry => 'Режим микроскопа: подсчёт вслепую';

  @override
  String get diffEfEntrySub =>
      'Экран делится на крупные зоны; звук и вибрация при каждом нажатии';

  @override
  String get diffEfTitle => 'Подсчёт вслепую';

  @override
  String get diffEfExit => 'Выйти';

  @override
  String get diffEfUndoZone => 'Отменить';

  @override
  String get diffEfUndoHint => 'или нажмите двумя пальцами';

  @override
  String diffEfZoneSemantics(String cell, int count, int total, int target) {
    return '$cell: $count. Всего $total / $target.';
  }

  @override
  String diffEfAnnounce(String cell, int count, int total) {
    return '$cell $count. Всего $total';
  }

  @override
  String diffEfUndone(String cell, int total) {
    return 'Отменено: $cell. Всего $total';
  }

  @override
  String get diffEfNothingToUndo => 'Нечего отменять';

  @override
  String get diffEfShowResult => 'Посмотреть результат';

  @override
  String get diffEfVoiceOn => 'Включить голосовые команды';

  @override
  String get diffEfVoiceOff => 'Остановить голосовые команды';

  @override
  String get diffEfSettingsTitle => 'Режим микроскопа';

  @override
  String get diffEfSettingsSub => 'Чтобы считать, не отрываясь от микроскопа';

  @override
  String get diffEfStart => 'Начать подсчёт';

  @override
  String get diffEfHowTitle => 'Как это работает';

  @override
  String get diffEfHowBody =>
      'Положите телефон на стол и нажимайте зоны, не отрываясь от микроскопа. При каждом нажатии — короткий звук и вибрация, своя для каждого типа клеток; каждые 10 клеток — двухтональный сигнал и длинная вибрация; при достижении цели (100 или 200) — сигнал из трёх нот, подсчёт останавливается. Подсчёт общий с обычным счётчиком.';

  @override
  String get diffEfZonesTitle => 'Зоны';

  @override
  String get diffEfHandLabel => 'Какой рукой нажимаете';

  @override
  String get diffEfHandRight => 'Правая';

  @override
  String get diffEfHandLeft => 'Левая';

  @override
  String get diffEfHandHint =>
      'Зона 1 ближе всего к большому пальцу — в нижнем углу.';

  @override
  String get diffEfOtherZone => 'Зона «Другие (бласты…)»';

  @override
  String get diffEfOtherZoneSub => 'Если выключить — 6 зон, каждая крупнее';

  @override
  String get diffEfUndoSwitch => 'Большая зона «Отменить» сверху';

  @override
  String get diffEfUndoSwitchSub =>
      'Нажатие двумя пальцами всегда отменяет последнее нажатие';

  @override
  String get diffEfOrderTitle => 'Порядок зон';

  @override
  String get diffEfOrderHint =>
      '1 — зона ближе всего к большому пальцу. Частые клетки ставьте выше.';

  @override
  String diffEfMoveUp(String cell) {
    return 'Выше: $cell';
  }

  @override
  String diffEfMoveDown(String cell) {
    return 'Ниже: $cell';
  }

  @override
  String get diffEfSignalsTitle => 'Сигналы';

  @override
  String get diffEfSound => 'Звук';

  @override
  String get diffEfSoundSub => 'Громкость — кнопками громкости телефона';

  @override
  String get diffEfHaptics => 'Вибрация';

  @override
  String get diffEfHapticsSub =>
      'Не ощущается, если вибрация выключена в настройках телефона';

  @override
  String get diffEfPatternsTitle => 'Рисунки вибрации';

  @override
  String get diffEfPatternsHint =>
      'Нажмите строку, чтобы попробовать. Ощущение зависит от модели телефона.';

  @override
  String diffEfPattern(int count, String strength) {
    return '$count × $strength';
  }

  @override
  String get diffEfPulseLight => 'лёгкая';

  @override
  String get diffEfPulseMedium => 'средняя';

  @override
  String get diffEfPulseHeavy => 'сильная';

  @override
  String get diffEfPatternTen => 'Каждые 10 клеток';

  @override
  String get diffEfPatternTenDesc => '+ длинная вибрация';

  @override
  String get diffEfPatternDone => 'Цель достигнута';

  @override
  String get diffEfPatternDoneDesc => '2 × сильная + длинная';

  @override
  String get diffEfPatternUndoDesc => 'сильная + короткая';

  @override
  String get diffEfScreenTitle => 'Экран';

  @override
  String get diffEfAwake => 'Не выключать экран';

  @override
  String get diffEfAwakeSub =>
      'Экран не гаснет во время подсчёта — батарея расходуется быстрее';

  @override
  String get diffVoiceTitle => 'Подсчёт голосом';

  @override
  String get diffVoiceExperimental => 'Экспериментально';

  @override
  String get diffVoiceSwitch => 'Голосовые команды';

  @override
  String get diffVoiceSwitchSub =>
      'Назовите клетку — +1; «отмена» — отменить последнее';

  @override
  String get diffVoiceLangLabel => 'Язык команд';

  @override
  String get diffVoiceLangAuto => 'Авто';

  @override
  String get diffVoiceLangUz => 'Узбекский';

  @override
  String get diffVoiceLangRu => 'Русский';

  @override
  String get diffVoiceLangEn => 'Английский';

  @override
  String get diffVoiceLangHint =>
      'Авто: если язык приложения недоступен на устройстве — русский, затем английский. Узбекского нет в списке языков диктовки Apple; на Android зависит от устройства.';

  @override
  String get diffVoiceWordsTitle => 'Какие слова говорить';

  @override
  String get diffVoicePrivacyTitle => 'Где обрабатывается голос';

  @override
  String get diffVoicePrivacyIos =>
      'iOS: требуется распознавание только на устройстве. Если для языка его нет, режим не работает — голос на сервер не отправляется. LabGuide не сохраняет и никуда не отправляет голос.';

  @override
  String get diffVoicePrivacyAndroid =>
      'Android: работает только при распознавании речи на самом телефоне (офлайн) — нужен Android 12+ и офлайн-распознавание на устройстве. Иначе режим не включается, голос на сервер не отправляется. LabGuide не сохраняет и никуда не отправляет голос.';

  @override
  String get diffVoiceNoNames =>
      'Говорите только названия клеток — не называйте пациента и другие данные.';

  @override
  String get diffVoiceAccuracy =>
      'Точность зависит от шума, произношения и устройства. Слушайте сигнал после каждой команды; при ошибке скажите «отмена». Проверяйте результат перед сохранением.';

  @override
  String get diffVoiceConsentTitle => 'Включить голосовые команды?';

  @override
  String get diffVoiceConsentAction => 'Понятно, включить';

  @override
  String get diffVoiceStarting => 'Запуск микрофона…';

  @override
  String diffVoiceListening(String lang) {
    return 'Слушаю · $lang';
  }

  @override
  String diffVoiceFallback(String lang) {
    return 'Для языка приложения распознавание на устройстве не найдено — говорите слова на языке: $lang.';
  }

  @override
  String diffVoiceHeard(String text) {
    return 'Услышано: «$text»';
  }

  @override
  String diffVoiceNotUnderstood(String text) {
    return 'Команда не распознана: «$text»';
  }

  @override
  String get diffVoicePermissionDenied =>
      'Нет разрешения на микрофон или распознавание речи, поэтому голосовые команды не работают. Разрешение можно дать LabGuide в настройках телефона. Подсчёт зонами продолжает работать.';

  @override
  String get diffVoiceUnavailable =>
      'На этом устройстве нет службы распознавания речи. Подсчёт зонами продолжает работать.';

  @override
  String get diffVoiceLanguageUnavailable =>
      'Для выбранного языка распознавания на устройстве нет. Выберите другой язык в настройках.';

  @override
  String get diffVoiceOnDeviceUnavailable =>
      'На устройстве нет распознавания речи (офлайн). Чтобы голос не уходил на сервер, голосовые команды отключены.';

  @override
  String get diffVoiceFailed =>
      'Распознавание остановилось. Попробуйте ещё раз.';

  @override
  String get diffVoiceRetry => 'Повторить';

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
      'Интерпретация всегда — вместе с референтным интервалом и клиникой. Референтный интервал — на бланке вашей лаборатории; причины ниже лишь возможные, это не диагноз.';

  @override
  String get diffPossibleCauses => 'Возможные причины';

  @override
  String get diffAbsNote =>
      'Если резко растёт один тип, проценты остальных падают. Поэтому смотрите абсолютные числа (доля × WBC).';

  @override
  String get diffRangesTitle => 'Почему приложение не даёт «норму»?';

  @override
  String get diffRangesBody =>
      'В открытых источниках и учебнике СНГ примерные интервалы для взрослых (%) различаются. В отчёте используется только референтный интервал с бланка вашей лаборатории; у детей интервалы зависят от возраста.';

  @override
  String get diffRangesWho => 'ВОЗ 2003';

  @override
  String get diffRangesMedline => 'MedlinePlus';

  @override
  String get diffRangesClassic => 'Учебник СНГ (1984)';

  @override
  String get diffRangesClassicNote =>
      'Классические интервалы (учебники СНГ) даны только для сравнения: они ещё встречаются во многих бланках, но источники расходятся. Главное — референтный интервал на бланке вашей лаборатории.';

  @override
  String get refTitle => 'Таблицы и алгоритмы';

  @override
  String get refSub =>
      'Анемия, желтуха, синдромы печени, паразиты, устаревшие методы';

  @override
  String get refIntro =>
      'Краткие таблицы по книгам и официальным источникам. Под каждым разделом указаны источники.';

  @override
  String get refOpenSub => 'Таблица и алгоритм';

  @override
  String get refNotFound => 'Такая таблица не найдена.';

  @override
  String get analyteReuseCitationOnly =>
      'Книга: приведена только как источник, текст не копировался';

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
  String get prePatientTitle => 'Подготовка пациента';

  @override
  String get preTubeForTestTitle => 'Какая пробирка для какого анализа';

  @override
  String get preTubeForTestSub =>
      'Цвет и место — из порядка ВОЗ выше. Пробирки в лабораториях могут отличаться.';

  @override
  String preTubeSlot(String tube, int n) {
    return '$tube · $n-я в порядке взятия';
  }

  @override
  String get preTubeNone => 'Отдельная пробирка — нет в порядке ВОЗ';

  @override
  String get preMixTitle => 'Перемешивание пробирки';

  @override
  String get preStabilityTitle => 'Стабильность образца';

  @override
  String get preStabilitySub =>
      'Сколько хранится отделённая сыворотка или плазма (ВОЗ, WHO/DIL/LAB/99.1). Указания вашей лаборатории и инструкция к реагенту важнее.';

  @override
  String get preStabilityRoom => '20–25 °C (комн.)';

  @override
  String get preStorageTitle => 'Правила хранения';

  @override
  String get preUrgentTitle => 'Не хранят — исследуют сразу';

  @override
  String get preBooksNote =>
      'Учебники (Селиванов 2005, Арипова 2007, Любина 1984) — дополнительный источник. Числа показаны, только если их подтверждают ВОЗ или MedlinePlus.';

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
  String get mcNechiporenko => 'Метод Нечипоренко';

  @override
  String get mcNechiporenkoSub =>
      'Лейкоциты, эритроциты и цилиндры в 1 мл мочи';

  @override
  String get mcAddis => 'Метод Каковского — Аддиса';

  @override
  String get mcAddisSub => 'Форменные элементы, выделяемые с мочой за сутки';

  @override
  String get mcZimnitsky => 'Проба Зимницкого';

  @override
  String get mcZimnitskySub => 'Дневной и ночной диурез, амплитуда плотности';

  @override
  String get mcClassicTag => 'Классический метод СССР';

  @override
  String get mcClassicTitle => 'Классические интервалы из учебников';

  @override
  String get mcClassicNote =>
      'Это референтный интервал, а не диагностический порог. Главный — интервал на бланке вашей лаборатории; результат с ним автоматически не сравнивается.';

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
  String get mfLeukoCounted => 'Лейкоциты (A, подсчитано)';

  @override
  String get mfEryCounted => 'Эритроциты (A, подсчитано)';

  @override
  String get mfCastsCounted => 'Цилиндры (A, подсчитано)';

  @override
  String get mfUrineCentrifuged => 'Центрифугированная моча, мл';

  @override
  String get mfCountedVolume => 'Подсчитанная сетка';

  @override
  String get mfGoryaevWhole => 'Горяев, вся сетка — 0,9 мкл';

  @override
  String get mfGoryaev100 => 'Горяев, 100 больших квадратов — 0,4 мкл';

  @override
  String get mfFuchsWhole => 'Фукс — Розенталь, вся сетка — 3,2 мкл';

  @override
  String get mfSediment => 'Оставленный осадок';

  @override
  String get mfCollected => 'Собранная моча, мл';

  @override
  String get mfCollectHours => 'Время сбора, ч';

  @override
  String mfPortion(int n, String time) {
    return '$n-я порция ($time), мл';
  }

  @override
  String mfPortionSg(int n) {
    return '$n-я порция, плотность';
  }

  @override
  String get mfFluidIntake => 'Выпито жидкости за сутки, мл';

  @override
  String get mfZimDay => 'Дневные порции (1–4)';

  @override
  String get mfZimNight => 'Ночные порции (5–8)';

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
  String get mrPerMlUrine => 'в 1 мл мочи';

  @override
  String get mrPerDay => 'За сутки';

  @override
  String mrPerUlSediment(String value) {
    return 'в 1 мкл осадка: $value';
  }

  @override
  String get mrPortion12 => 'Моча за 12 минут для центрифугирования';

  @override
  String get mrDiuresisTotal => 'Суточный диурез';

  @override
  String get mrDiuresisDay => 'Дневной диурез (1–4)';

  @override
  String get mrDiuresisNight => 'Ночной диурез (5–8)';

  @override
  String get mrDayNightRatio => 'Дневной : ночной';

  @override
  String get mrIntakePercent => 'От выпитой жидкости';

  @override
  String get mrSgRange => 'Плотность: мин. – макс.';

  @override
  String get mrSgAmplitude => 'Амплитуда плотности';

  @override
  String get mrNotGiven => 'не введено';

  @override
  String get mErrNoUrine => 'Нужны объём и плотность хотя бы одной порции.';

  @override
  String get mErrSediment =>
      'Объём осадка должен быть меньше объёма центрифугированной мочи.';

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
      'Гемоглобин в одном эритроците прямо выражает MCH (среднее содержание гемоглобина, пг), а концентрацию гемоглобина в эритроците — MCHC. Гематологический анализатор выдаёт оба. Гипо-/гиперхромию оценивайте по ним и референтным интервалам вашей лаборатории.';

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
  String get calcCalciumCaution =>
      'Кальций, скорректированный по альбумину, часто неверно отражает статус кальция, особенно при низком альбумине и нарушении функции почек. Если доступно, измеряйте ионизированный кальций — он предпочтителен.';

  @override
  String get calcNotDiagnosis =>
      'Вспомогательный расчёт для обучения и проверки. Не ставит диагноз: интерпретируйте результат с учётом клинической картины и референтных интервалов вашей лаборатории.';

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
  String get micSearchHint => 'Например: нейтрофил, оксалат, малярия';

  @override
  String get micNoResultsTitle => 'Ничего не найдено';

  @override
  String get micNoResultsBody =>
      'Попробуйте другое название или другой язык (uz, ru, en).';

  @override
  String get micSections => 'Разделы';

  @override
  String get micEduNotice =>
      'Учебные изображения — не для диагностики. У каждого снимка указаны автор, лицензия и исходная подпись.';

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
      'Схематичное изображение (нарисовано LabGuide) — для оформления раздела, не внешний вид конкретного прибора.';

  @override
  String get instImageMissing => 'Изображение модели пока недоступно';

  @override
  String get instImageMissingSub =>
      'Разрешённое к использованию изображение именно этой модели не найдено. Внешний вид — на странице производителя.';

  @override
  String get instMakerSource => 'Источник производителя';

  @override
  String get instImageTapToZoom => 'Нажмите на фото, чтобы увеличить';

  @override
  String instImageRightsChecked(String date) {
    return 'Права проверены: $date';
  }

  @override
  String instImageSemantics(String model) {
    return 'Фото $model';
  }

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
      'Когда нужна повторная калибровка (смена лота, КК не пройден, срок) — в IFU.';

  @override
  String get calGuide5 =>
      'После калибровки проведите КК и внесите результат в запись.';

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
  String get instSaveFailed => 'Не удалось сохранить. Попробуйте ещё раз.';

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
  String get learnTitle => 'Учитесь осознанно';

  @override
  String get learnHeroTag => 'Темы и практика';

  @override
  String get learnHeroTitle => 'От молекулы к практике';

  @override
  String get learnHeroBody => 'Выберите тему и проверьте знания вопросами.';

  @override
  String get learnHeroCta => 'Выбрать тему';

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
  String get toifaTitle => 'Проверка знаний и компетенций';

  @override
  String get toifaSubtitle => 'Клиническая лабораторная диагностика (КЛД)';

  @override
  String get toifaEyebrow => 'КЛД · знания и компетенции';

  @override
  String get toifaEntryBody =>
      'Вопросы из официального списка: тест из 50 вопросов, практика по темам, устный билет и работа над ошибками.';

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
  String get toifaOpen => 'Начать';

  @override
  String get toifaContinue => 'Продолжить';

  @override
  String get toifaUzbekOnly => 'Официальный текст — на узбекском';

  @override
  String get toifaUzbekNotice =>
      'Официальный текст вопросов аттестации — на узбекском. При русском или английском интерфейсе показан вспомогательный перевод; оригинал можно открыть в любой момент. Оценка — по официальному узбекскому тексту и ключу.';

  @override
  String get toifaShowOriginal => 'Показать оригинал';

  @override
  String get toifaHideOriginal => 'Скрыть оригинал';

  @override
  String get toifaOriginalTitle => 'Официальный текст (на узбекском)';

  @override
  String get toifaTranslationAux =>
      'Перевод вспомогательный; оценка — по официальному узбекскому тексту.';

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
  String get toifaPrepare => 'Проверка';

  @override
  String get toifaTestTitle => 'Тест знаний';

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
    return 'Планы устных ответов — учебная помощь, подготовленная LabGuide ($ready / $total планов с источниками).';
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
  String get toifaTodayEyebrow => 'Сегодня';

  @override
  String toifaTodayGoal(int count) {
    return 'Цель: $count вопросов или 1 билет';
  }

  @override
  String get toifaTodayDone => 'Цель на сегодня выполнена';

  @override
  String toifaTodayProgress(int answered, int goal) {
    return '$answered/$goal вопросов';
  }

  @override
  String toifaTodayCorrect(int percent) {
    return '$percent% верно';
  }

  @override
  String toifaTodayTickets(int count) {
    return 'билетов: $count';
  }

  @override
  String toifaStreakDays(int count) {
    return 'Дней подряд: $count';
  }

  @override
  String get toifaTodayNone => 'Сегодня ещё не занимались.';

  @override
  String get toifaTodayTomorrow => 'Продолжайте завтра — не прерывайте серию.';

  @override
  String toifaWeekLabel(String values) {
    return 'Последние 7 дней: $values';
  }

  @override
  String get toifaGoalLabel => 'Цель на день';

  @override
  String toifaGoalOption(int count) {
    return '$count вопросов';
  }

  @override
  String get toifaGoalHint => 'Или 1 устный билет — что будет раньше.';

  @override
  String get toifaReminderTitle => 'LabGuide · Знания и компетенции';

  @override
  String toifaReminderBody(int count) {
    return 'Сегодняшнее занятие ждёт вас — $count вопросов или 1 билет';
  }

  @override
  String get toifaReminderChannel => 'Напоминание о проверке знаний';

  @override
  String get toifaOfferTitle => 'Продолжим завтра?';

  @override
  String get toifaOfferBody =>
      'Выберите время напоминания. В день, когда цель выполнена, напоминания не будет.';

  @override
  String toifaOfferOn(String time) {
    return 'Напомним завтра в $time.';
  }

  @override
  String get toifaModeTitle => 'Режим';

  @override
  String get toifaModeExam => 'Режим экзамена';

  @override
  String get toifaModeExamSub =>
      'С таймером; баллы и ошибки в конце — как на экзамене.';

  @override
  String get toifaModePractice => 'Режим практики — ошибка видна сразу';

  @override
  String get toifaModePracticeSub =>
      'После каждого ответа — правильный ответ и пояснение; без таймера.';

  @override
  String get toifaDrillStep2 =>
      'Сразу после ответа видно, верно или нет: официальный ключ и (если есть) пояснение, источник.';

  @override
  String get toifaDrillStep3 =>
      'Можно продолжить с того же места после закрытия приложения; в конце — работа над ошибками.';

  @override
  String get toifaDrillStart => 'Начать практику';

  @override
  String toifaDrillActive(int answered, int total) {
    return 'Практика идёт: $answered/$total';
  }

  @override
  String get toifaDrillTitle => 'Режим практики';

  @override
  String get toifaDrillRework => 'Работа над ошибками';

  @override
  String toifaDrillScore(int right, int wrong) {
    return 'Верно: $right · ошибок: $wrong';
  }

  @override
  String get toifaDrillFinishEarly => 'Завершить сейчас';

  @override
  String get toifaDrillFinishBody =>
      'Вопросы без ответа засчитываются как неверные. Данные ответы останутся в списке ошибок.';

  @override
  String get toifaDrillDiscardTitle => 'Прервать практику?';

  @override
  String get toifaDrillNone => 'Нет начатой практики';

  @override
  String get toifaDrillNew => 'Новый тест';

  @override
  String toifaDrillUnanswered(int count) {
    return 'Без ответа: $count';
  }

  @override
  String get toifaThinkHint =>
      'Продумайте ответ: проговорите вслух или запишите на бумаге. Затем откройте план и сравните.';

  @override
  String toifaThinkTimer(int minutes) {
    return '$minutes мин на обдумывание';
  }

  @override
  String toifaThinkLeft(String time) {
    return 'Время на обдумывание: $time';
  }

  @override
  String get toifaThinkUp => 'Время вышло — откройте план и сравните.';

  @override
  String get toifaThinkStop => 'Остановить таймер';

  @override
  String get toifaChecklistToggle => 'Ключевые пункты для сверки с планом';

  @override
  String get toifaChecklistHint =>
      'Отметьте то, что было в вашем ответе (только на устройстве, печатать не нужно).';

  @override
  String toifaChecklistCount(int done, int total) {
    return 'Отмечено: $done/$total';
  }

  @override
  String get toifaRepeatTitle => 'Нужно повторить';

  @override
  String get toifaRepeatNote =>
      'Вопросы «Частично» и «Не знал» первыми вернутся в следующих билетах.';

  @override
  String get toifaRepeatNone =>
      'Всё знали — в следующем билете будут новые вопросы.';

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
  String get toifaNoteNoSource => 'Источник для пояснения не указан.';

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
  String get toifaPickCategoryFirst => 'Сначала выберите категорию';

  @override
  String get toifaDrawTicket => 'Взять билет';

  @override
  String get toifaTicketTitle => 'Ваш билет';

  @override
  String get toifaPrepHint =>
      'Печатать в приложении не нужно. Продумайте ответ на каждый вопрос — проговорите вслух или запишите на бумаге. Затем сравните с планом ответа и оцените себя.';

  @override
  String get toifaShowPlans => 'Отвечать по очереди';

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
  String get toifaPlanPending => 'Подготовлено LabGuide';

  @override
  String get toifaPlanMissing => 'План для этого вопроса ещё не подготовлен.';

  @override
  String get toifaPlanNotChecked => 'К этому плану источник ещё не привязан.';

  @override
  String get toifaReferenceTitle =>
      'Референтный интервал (образец, зависит от лаборатории)';

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
    return 'Сверено с источниками: $date';
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
  String get quizReviewNote =>
      'Учебные вопросы — для тренировки; результат не является официальной оценкой.';

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
      'Вопросы берутся из официального списка — только те, чей ключ прошёл проверку LabGuide.';

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
  String get shareKindToifa => 'Тренировка теста знаний';

  @override
  String get shareCorrectCaption => 'верных ответов';

  @override
  String get shareFooter =>
      'Справочник и тренировки по лабораторной диагностике';

  @override
  String get shareToifaNote => 'Результат тренировки LabGuide';

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
  String get examFinishClassTitle => 'Завершить тест?';

  @override
  String get examFinishClassBody => 'Ответы будут отправлены преподавателю.';

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
  String get examNoSource => 'Для этого вопроса источник не указан.';

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
      'Роль в приложении не даёт прав на сервере: группу открывает только аккаунт, зарегистрированный как преподаватель, и он управляет только своими группами.';

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
      'Преподаватель, открывший группу, управляет только ею. Студенты вступают по вашему коду или QR.';

  @override
  String get classesGroupName => 'Название группы';

  @override
  String get classesGroupNameHint => 'Например, Биохимия 2 курс';

  @override
  String classesLengthError(int min, int max) {
    return 'Введите от $min до $max символов';
  }

  @override
  String get classesDisplayName => 'Псевдоним (необязательно)';

  @override
  String get classesDisplayNameHint =>
      'Например, Звезда — если пусто, порядковый номер';

  @override
  String get classesDisplayNameHintTeacher => 'Например, Каримова Н.А.';

  @override
  String get classesDisplayNameNote =>
      'ФИО на сервере не хранятся: студенты видны по псевдониму или порядковому номеру. Настоящее имя можно записать только как метку на своём устройстве.';

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
      'Не указывайте настоящее имя. Преподаватель видит только ваш псевдоним (или номер) и результаты заданий; другие студенты вас не видят. Email не показывается.';

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
  String get classesDeleteGroup => 'Удалить группу';

  @override
  String classesDeleteGroupTitle(String name) {
    return 'Удалить группу «$name»?';
  }

  @override
  String get classesDeleteGroupBody =>
      'Группа, её задания и результаты студентов будут удалены безвозвратно.';

  @override
  String get classesDeleteGroupAction => 'Удалить';

  @override
  String get classesInviteTitle => 'Код приглашения';

  @override
  String get classesInviteBody =>
      'Студенты сканируют QR камерой телефона и нажимают «Открыть в приложении» — или: Обучение → Группы и задания → Вступить по коду.';

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
  String get classesAssignmentTitle => 'Название задания';

  @override
  String get classesTimeLimit => 'Ограничение времени, мин';

  @override
  String get classesNoLimit => 'Без ограничения';

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
  String get profileGuestLocal => 'Данные только на этом устройстве';

  @override
  String get profileDemoSession => 'Демо-сессия · debug-сборка';

  @override
  String get profileRole => 'Направление';

  @override
  String get profileRoleSub => 'Главная адаптируется под вас';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileUnits => 'Единицы измерения';

  @override
  String get profileUnitsSi => 'СИ (ммоль/л, мкмоль/л)';

  @override
  String get profileUnitsConventional => 'Обычные (мг/дл)';

  @override
  String get profileAttestation => 'Проверка знаний и компетенций';

  @override
  String get profileAttestationAuto => 'Автоматически';

  @override
  String get profileAttestationUz => 'Узбекистан';

  @override
  String get profileAttestationNone => 'Скрыть';

  @override
  String get profileAttestationNote =>
      'Показывает раздел проверки знаний и компетенций (Узбекистан) на любом языке интерфейса. Автоматически: раздел виден, если язык узбекский или регион устройства — Узбекистан.';

  @override
  String get profileAppearance => 'Оформление';

  @override
  String get themeSystem => 'Система';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeTitle => 'Тема';

  @override
  String get themeRowSub => 'Цвета приложения и шрифт заголовков';

  @override
  String get themeCurrent => 'Текущая тема';

  @override
  String get themeClassicName => 'Классика';

  @override
  String get themeClassicDesc => 'Фирменная зелёная палитра LabGuide';

  @override
  String get themeIvoryName => 'Ivory';

  @override
  String get themeIvoryDesc =>
      'Слоновая кость, чёрный и золото, изящные заголовки с засечками';

  @override
  String get themeModeSection => 'Светлая или тёмная';

  @override
  String get themeSelected => 'Выбрано';

  @override
  String get profilePrivacy => 'Конфиденциальность и данные';

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
      'Аккаунт, способы входа (привязка Google/Apple), участие и результаты в группах, обращения в «Предложения и помощь» и ваши вопросы и ответы в сообществе будут полностью удалены с сервера. Если вы преподаватель, созданные вами группы тоже удалятся. Отменить это нельзя. Тексты жалоб, отправленных в приложении, остаются без привязки к аккаунту. Данные на устройстве тоже очищаются.';

  @override
  String get accountDeleted => 'Аккаунт удалён';

  @override
  String get adminTitle => 'Админ-панель';

  @override
  String get adminSub => 'Модерация, обращения, контент, администраторы';

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
  String get privacyTitle => 'Конфиденциальность и данные';

  @override
  String get privacyBody =>
      'Основные разделы работают без аккаунта (гостевой режим): настройки, закладки, записи КК, ваши приборы и результаты тренировок хранятся на этом устройстве. Аккаунт по желанию (код по email, Google или Apple) — нужен для групп, сообщества и «Предложений и помощи». Тогда данные хранятся на сервере Cloudflare (Восточная Европа, за пределами Узбекистана): email — только в виде хеша и маскированного вида, способ входа, роль, язык, время последней активности (до минуты); в группе — псевдоним или порядковый номер, ответы и баллы; тексты обращений и жалоб. От Google/Apple берутся только идентификатор аккаунта и email, токен не хранится. Преподаватель видит только свою группу. Без рекламы, аналитики и отслеживания. Полный текст — по ссылке «Политика конфиденциальности».';

  @override
  String get privacyBodyLocal =>
      'В этой сборке сервер не подключён: приложение ничего не отправляет на сервер. Настройки, закладки, записи КК, ваши приборы и результаты тренировок хранятся на этом устройстве (могут попадать в системную резервную копию). Без рекламы и отслеживания.';

  @override
  String get privacyTerms => 'Условия использования';

  @override
  String get privacyTermsSub => 'Правила пользования приложением и аккаунтом';

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
      'LabGuide — бесплатный справочник и обучающее приложение по клинической лабораторной диагностике. Пользуясь приложением, вы соглашаетесь со следующими условиями.\n\n1. Медицинское ограничение. LabGuide не ставит диагноз, не назначает лечение или лекарства и не заменяет утверждённые процедуры вашей лаборатории, инструкции к реагентам и анализаторам (IFU) и заключение врача. Под каждым сведением указан источник; принимая решения, опирайтесь на первоисточник и правила своего учреждения.\n\n2. Аккаунт. Для некоторых функций (группы, тесты, сообщество, обращения) нужна регистрация по email. Вы отвечаете за безопасность аккаунта и действия, совершённые через него. Удалить аккаунт можно в любой момент: Профиль → Удалить аккаунт.\n\n3. Группы преподавателя и студентов. Когда студент вступает в группу, преподаватель видит его псевдоним (или порядковый номер) и результаты тестов. Преподаватель использует группу только в учебных целях.\n\n4. Пользовательский контент. Вы отвечаете за то, что пишете в сообществе и обращениях. Строго запрещены оскорбления, незаконный контент, реклама, чужие персональные данные и интимные изображения без согласия. Такой контент удаляется, аккаунт нарушителя может быть ограничен или удалён. О любом сообщении можно сообщить через «Пожаловаться».\n\n5. Авторские права. Тексты, слайды, тесты и дизайн приложения принадлежат авторам LabGuide; внешние источники указаны со своими лицензиями. Их нельзя копировать и распространять в коммерческих целях.\n\n6. Сервис. Приложение предоставляется «как есть»; возможны перебои и ошибки, мы исправляем их как можно скорее. Об изменении условий сообщим в приложении.\n\n7. Конфиденциальность. Как используются ваши данные — в политике конфиденциальности: labguide.nfcstore.uz/privacy\n\n8. Связь: labguide@nfcstore.uz';

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
  String get libIntake => 'Добавление материалов';

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
  String get libItemUnavailable => 'Материал недоступен на вашем языке';

  @override
  String get libItemUnavailableBody =>
      'Этот материал пока есть только на другом языке. Смените язык интерфейса или вернитесь в каталог.';

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
  String get intakeStep5 => 'Подтверждён — преподаватель проверил.';

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
  String get lessonsTitle => 'Темы занятий';

  @override
  String get analyteTreatmentGoals => 'Цели лечения';

  @override
  String get analyteTreatmentGoalsNotice =>
      'Цель лечения устанавливает врач на основе полной оценки риска пациента; приложение не определяет категорию риска.';

  @override
  String get analyteTreatmentGoalsNotRef =>
      'Цели лечения — не референтные интервалы и не диагностические пороги. Рекомендации по-разному определяют группы риска — сравнивайте значения только внутри одной таблицы.';

  @override
  String analyteGoalHistorical(String current) {
    return 'Исторические рекомендации, заменены: $current. Приведены только для контекста — не для текущих решений о лечении.';
  }

  @override
  String analyteGoalGuideline(String name, String year) {
    return '$name · $year';
  }

  @override
  String get analyteAgentCheck => 'Сверено с источниками';

  @override
  String get analyteExpertApproval => 'Подтверждение эксперта';

  @override
  String classesSeat(String n) {
    return 'Студент $n';
  }

  @override
  String classesQrLabel(String code) {
    return 'QR кода приглашения: $code';
  }

  @override
  String get classesTeacherRegisterEyebrow => 'Преподаватель';

  @override
  String get classesTeacherRegisterTitle =>
      'Зарегистрируйтесь как преподаватель';

  @override
  String get classesTeacherRegisterBody =>
      'Преподаватель открывает свою группу и видит результаты только своих студентов. Это не права администратора и не влияет на другие группы.';

  @override
  String get classesTeacherRegister => 'Зарегистрироваться как преподаватель';

  @override
  String get classesLocalNameTitle => 'Метка (только на этом устройстве)';

  @override
  String get classesLocalNameBody =>
      'Например, имя студента. Не отправляется на сервер и не видна студенту.';

  @override
  String get classesLocalNameHint => 'Пусто — удалить метку';

  @override
  String get classesLocalNameSave => 'Сохранить';

  @override
  String get classroomPlanTitle => 'Учебный план';

  @override
  String get classroomPlanSub => 'Темы по дням: лекция, опрос, тест';

  @override
  String get classroomTopicsTitle => 'Темы';

  @override
  String get classroomTopicsSub => 'Открытые преподавателем темы и тесты';

  @override
  String get classroomProgramEyebrow => 'Учебная программа';

  @override
  String classroomPlanProgress(int done, int total) {
    return 'Тестов по темам завершено: $done/$total';
  }

  @override
  String get classroomStartNone =>
      'Дата начала не задана — план по порядку дней';

  @override
  String classroomStartAt(String date) {
    return '1-й учебный день: $date';
  }

  @override
  String get classroomStartNote =>
      'Даты примерные (воскресенья пропускаются, праздники не учитываются) и хранятся только на этом устройстве.';

  @override
  String get classroomStartPick => 'Указать дату начала';

  @override
  String classroomDayN(int n) {
    return 'День $n';
  }

  @override
  String classroomWeekN(int n) {
    return 'Неделя $n';
  }

  @override
  String classroomHours(int n) {
    return '$n ч';
  }

  @override
  String get classroomTypeLecture => 'Лекция';

  @override
  String get classroomTypePractical => 'Практика';

  @override
  String get classroomTypeSeminar => 'Семинар';

  @override
  String get classroomTypeAttestation => 'Аттестация';

  @override
  String get classroomTypeOther => 'Занятие';

  @override
  String get classroomStatusClosed => 'Не открыта';

  @override
  String get classroomStatusOpened => 'Открыта';

  @override
  String get classroomStatusLectured => 'Пройдена';

  @override
  String get classroomStatusOral => 'Опрос проведён';

  @override
  String get classroomStatusTestRunning => 'Идёт тест';

  @override
  String get classroomStatusTestDone => 'Тест завершён';

  @override
  String get classroomNoCurriculumTitle => 'Учебная программа ещё не добавлена';

  @override
  String get classroomNoCurriculumBody =>
      'План курса (модуль → тема → материалы) появится в следующей версии приложения. Пока используйте задания группы.';

  @override
  String get classroomCurriculumError =>
      'Не удалось прочитать учебную программу';

  @override
  String get classroomNoTopicsStudent => 'Преподаватель ещё не открыл темы';

  @override
  String get classroomNoTopicsStudentBody =>
      'Когда тема откроется, материалы и тест появятся здесь.';

  @override
  String get classroomTopicTitle => 'Тема';

  @override
  String get classroomTopicMissing => 'Тема не найдена в программе';

  @override
  String get classroomTopicNotOpened => 'Эта тема ещё не открыта';

  @override
  String get classroomOpenNote =>
      'После открытия студенты увидят материалы темы.';

  @override
  String get classroomOpenTopic => 'Открыть студентам';

  @override
  String classroomStep(int n) {
    return 'Этап $n';
  }

  @override
  String get classroomStageLecture => 'Лекция';

  @override
  String get classroomStageLectureBody =>
      'Покажите тему слайдами на большом экране (работает и без интернета).';

  @override
  String get classroomStageOral => 'Устный опрос';

  @override
  String classroomStageOralBody(int count) {
    return 'Список вопросов и план ответа. Задано: $count.';
  }

  @override
  String get classroomStageTest => 'Тест группы';

  @override
  String get classroomStageTestBody =>
      'Выберите вопросы и запустите тест — он сразу откроется у студентов.';

  @override
  String get classroomStageDone => 'Пройдено';

  @override
  String get classroomMarkDone => 'Отметить как пройденное';

  @override
  String get classroomOralOpen => 'Список вопросов';

  @override
  String get classroomTestPrepare => 'Подготовить тест';

  @override
  String get classroomTestResults => 'Панель результатов';

  @override
  String get classroomTestFinish => 'Завершить тест';

  @override
  String get classroomTestFinishTitle => 'Завершить тест?';

  @override
  String get classroomTestFinishBody =>
      'Новые попытки не принимаются. Начавшим остаётся 2 минуты, чтобы отправить ответы.';

  @override
  String classroomTestSubmitted(int done, int total) {
    return 'Сдали: $done/$total';
  }

  @override
  String get classroomTestNotStarted => 'Преподаватель ещё не начал тест.';

  @override
  String get classroomTestOpenStudent => 'Тест открыт — пройти';

  @override
  String get classroomMaterials => 'Материалы темы';

  @override
  String get classroomNoMaterials =>
      'В приложении пока нет материалов по этой теме.';

  @override
  String get classroomGapNote =>
      'Материалов по этой теме в приложении мало — преподаватель дополняет из своих источников.';

  @override
  String get classroomKindAnalyte => 'Карточка анализа';

  @override
  String get classroomKindCondition => 'Состояние';

  @override
  String get classroomKindReference => 'Таблица';

  @override
  String get classroomKindAtlas => 'Атлас микроскопии';

  @override
  String get classroomKindTool => 'Калькулятор и инструмент';

  @override
  String get classroomToolQc => 'Контроль качества';

  @override
  String get classroomToolPreanalytics => 'Преаналитика';

  @override
  String get classroomToolInstruments => 'Анализаторы';

  @override
  String get classroomToolCalibration => 'Журнал калибровки';

  @override
  String get classroomToolDifferential => 'Лейкоформула';

  @override
  String get classroomPlanRecommended =>
      'Рекомендованный LabGuide план практики';

  @override
  String get classroomOralNotice =>
      'Вопросы — автоматически подобранные кандидаты; план ответа — учебная помощь. Отметки «задан» и оценки хранятся только на этом устройстве.';

  @override
  String get classroomOralEmpty => 'Для этой темы нет устных вопросов';

  @override
  String classroomCandidate(int n) {
    return 'Вопрос-кандидат $n';
  }

  @override
  String get classroomOralPlan => 'Краткий план ответа';

  @override
  String get classroomOralNoPlan => 'План ответа ещё не написан.';

  @override
  String get classroomOralAsked => 'Задан';

  @override
  String classroomOralGrade(int count) {
    return 'Оценить студентов ($count)';
  }

  @override
  String get classroomOralGradeTitle => 'Кто как ответил';

  @override
  String get classroomOralGradeNote =>
      'Только на этом устройстве; на сервер не отправляется.';

  @override
  String get classroomGradeKnew => 'Знал';

  @override
  String get classroomGradePartial => 'Частично';

  @override
  String get classroomGradeDidNot => 'Не знал';

  @override
  String get classroomCandidatesNotice =>
      'Вопросы-кандидаты подобраны автоматически. Просмотрите каждый вопрос и его ключ: балл считается на сервере по показанному ключу.';

  @override
  String classroomCandidatesTitle(int picked, int total) {
    return 'Кандидаты · выбрано $picked/$total';
  }

  @override
  String get classroomPickAll => 'Все';

  @override
  String get classroomPickNone => 'Снять';

  @override
  String classroomKeyShown(String answer) {
    return 'Ключ: $answer';
  }

  @override
  String get classroomKeyFlagged => 'Спорный ключ';

  @override
  String get classroomPickAtLeastOne => 'Выберите хотя бы один вопрос';

  @override
  String get classroomPickMax => 'Не более 50 вопросов';

  @override
  String classroomTestStart(int count) {
    return 'Начать тест · $count вопр.';
  }

  @override
  String get classroomTestStarted => 'Тест начат — открыт у студентов';

  @override
  String classroomTestTitle(String topic) {
    return 'Тест: $topic';
  }

  @override
  String get classroomTestAlready => 'Тест по этой теме уже начат';

  @override
  String get classroomTestNoCandidates => 'Для этой темы нет тестовых вопросов';

  @override
  String get classroomTestNoCandidatesBody =>
      'Можно составить задание вручную (Новое задание).';

  @override
  String get lectureTitle => 'Лекция';

  @override
  String get lectureListTitle => 'Режим лекции';

  @override
  String get lectureListSub =>
      'Выберите тему — слайды на большом экране, без интернета';

  @override
  String get lectureStart => 'Начать лекцию';

  @override
  String get lectureClose => 'Закрыть лекцию';

  @override
  String lectureCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get lecturePrev => 'Назад';

  @override
  String get lectureNext => 'Далее';

  @override
  String get lectureGoals => 'Цель';

  @override
  String get lectureKeyPoints => 'Ключевые понятия';

  @override
  String get lectureConcepts => 'Основные анализы';

  @override
  String get lectureConditions => 'Клинические состояния';

  @override
  String get lectureTables => 'Таблицы и алгоритмы';

  @override
  String get lectureAtlas => 'Микроскопия';

  @override
  String get lectureTools => 'Расчёты и инструменты';

  @override
  String lectureQuestionN(int n) {
    return 'Вопрос $n';
  }

  @override
  String get lectureEndEyebrow => 'Дальше';

  @override
  String get lectureEndTitle => 'Опрос и тест';

  @override
  String get lectureEndOral => 'Устный опрос — спрашивает преподаватель';

  @override
  String get lectureEndTest => 'Тест группы — в приложении, на время';

  @override
  String get lectureDraftNotice =>
      'Презентация основана на источниках — просмотрите содержание перед занятием';

  @override
  String get lectureUzOnly => 'Эта презентация пока только на узбекском языке';

  @override
  String get lectureNotesShow => 'Показать заметки преподавателя';

  @override
  String get lectureNotesHide => 'Скрыть заметки преподавателя';

  @override
  String get lectureTeacherNote => 'Заметка для преподавателя';

  @override
  String get cmTitle => 'Сообщество · Вопросы и ответы';

  @override
  String get cmHomeSub => 'Отвечают подтверждённые специалисты лаборатории';

  @override
  String get cmAsk => 'Задать вопрос';

  @override
  String get cmAllQuestions => 'Все вопросы';

  @override
  String get cmEmptyTitle => 'Вопросов пока нет';

  @override
  String get cmEmptyBody => 'Задайте первый вопрос.';

  @override
  String cmTopicLinkAnalyte(int count) {
    return 'Вопросы по этому анализу ($count)';
  }

  @override
  String cmTopicLinkCondition(int count) {
    return 'Вопросы по этому состоянию ($count)';
  }

  @override
  String get cmTopicLinkSub => 'Сообщество · ответы специалистов';

  @override
  String cmTopicLabel(String name) {
    return 'Тема: $name';
  }

  @override
  String get cmMyQuestions => 'Мои вопросы';

  @override
  String get cmMyQuestionsSub => 'Ваши вопросы и ответы на них';

  @override
  String get cmVerifyTitle => 'Подтверждение специалиста';

  @override
  String get cmVerifySub => 'Загрузите документ, чтобы отвечать на вопросы';

  @override
  String get cmBadgeAi => '✓ Специалист (документ проверен автоматически)';

  @override
  String get cmBadgeManual => '✓ Подтверждённый специалист';

  @override
  String get cmBadgeInfo =>
      '«Документ проверен автоматически» — документ проверял не человек, а модель ИИ. На неверный значок можно пожаловаться.';

  @override
  String get cmMember => 'Участник';

  @override
  String get cmYou => 'вы';

  @override
  String get cmVerifyInfoTitle => 'Автоматическая проверка — файл не хранится';

  @override
  String get cmVerifyInfo =>
      'Документ автоматически проверяет модель ИИ (Cloudflare Workers AI) — человек его не видит. Файл нигде не сохраняется и удаляется сразу после проверки. На сервере остаётся только результат: роль, страна, статус и дата. Автоматическая проверка может ошибаться; если другие пользователи пожалуются на неверный значок, он приостанавливается до проверки администратором.';

  @override
  String get cmVerifyRole => 'Ваша профессия';

  @override
  String get cmRoleLaborant => 'Лаборант';

  @override
  String get cmRoleBiochemist => 'Биохимик';

  @override
  String get cmRoleKdlDoctor => 'Врач КДЛ';

  @override
  String get cmRoleTeacher => 'Преподаватель';

  @override
  String get cmRoleOther => 'Другое';

  @override
  String get cmRoleClinicalLab => 'Клиническая лабораторная диагностика';

  @override
  String get cmVerifyCountry => 'Страна (код из 2 букв, например UZ)';

  @override
  String get cmVerifyCountryError => 'Введите код страны из 2 букв';

  @override
  String get cmVerifyDocHint =>
      'Диплом, сертификат или документ с места работы. Фото JPEG или PNG до 5 МБ. Для PDF сфотографируйте первую страницу. Закройте данные пациентов.';

  @override
  String get cmVerifyCamera => 'Сфотографировать';

  @override
  String get cmVerifyGallery => 'Выбрать из галереи';

  @override
  String get cmVerifyRemove => 'Выбрать другой';

  @override
  String get cmVerifySubmit => 'Отправить на автоматическую проверку';

  @override
  String get cmVerifyAttempts => 'До 3 попыток в день.';

  @override
  String get cmStatusNone => 'Ещё не подтверждено';

  @override
  String get cmStatusVerified => 'Подтверждено';

  @override
  String get cmStatusRejected =>
      'Документ не принят. Попробуйте ещё раз с более чётким фото, где видны учреждение и специальность.';

  @override
  String get cmStatusSuspended =>
      'Ваш аккаунт в сообществе приостановлен после жалоб пользователей. Администратор рассмотрит его.';

  @override
  String cmVerifiedAt(String date) {
    return 'Подтверждено: $date';
  }

  @override
  String get cmMethodAi => 'Способ: автоматически (ИИ)';

  @override
  String get cmMethodManual => 'Способ: документ проверен вручную';

  @override
  String get cmErrTooLarge => 'Файл больше 5 МБ.';

  @override
  String get cmErrType => 'Только фото JPEG или PNG.';

  @override
  String get cmErrAi =>
      'Автоматическая проверка сейчас недоступна. Попробуйте позже.';

  @override
  String get cmErrNotVerified =>
      'Отвечать и голосовать могут только подтверждённые специалисты.';

  @override
  String get cmErrContact =>
      'Уберите из текста email и номера телефонов (и данные пациентов).';

  @override
  String get cmErrLength => 'Заголовок 10–200 символов, текст 10–4000.';

  @override
  String get cmErrAlreadyVerified => 'Вы уже подтверждены.';

  @override
  String get cmErrRevoked =>
      'Администратор отменил ваш статус специалиста. Повторная автоматическая проверка недоступна.';

  @override
  String get cmAskTitleField => 'Заголовок вопроса';

  @override
  String get cmAskBodyField => 'Подробности';

  @override
  String get cmAskNoPatient =>
      'Не указывайте имя, телефон и другие личные данные пациента. Ответы — опыт коллег, а не персональная медицинская консультация.';

  @override
  String get cmAskSend => 'Опубликовать вопрос';

  @override
  String get cmAskSent => 'Вопрос опубликован';

  @override
  String get cmSignInTitle => 'Войдите, чтобы участвовать';

  @override
  String get cmSignInBody =>
      'Задать вопрос может любой вошедший пользователь. Отвечают подтверждённые специалисты.';

  @override
  String cmAnswers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответов',
      few: '$count ответа',
      one: '$count ответ',
      zero: 'Нет ответов',
    );
    return '$_temp0';
  }

  @override
  String get cmAnswerField => 'Ваш ответ';

  @override
  String get cmAnswerSend => 'Отправить ответ';

  @override
  String get cmAnswerOnlySpecialists =>
      'Ответы пишут только подтверждённые специалисты.';

  @override
  String get cmBest => 'Лучший ответ';

  @override
  String get cmMarkBest => 'Отметить как лучший';

  @override
  String get cmUnmarkBest => 'Снять отметку';

  @override
  String cmUpvote(int count) {
    return 'Полезно ($count)';
  }

  @override
  String get cmReport => 'Пожаловаться';

  @override
  String get cmReportTitle => 'Причина жалобы';

  @override
  String get cmReasonSpam => 'Спам или реклама';

  @override
  String get cmReasonWrong => 'Неверная или опасная информация';

  @override
  String get cmReasonAbuse => 'Оскорбление';

  @override
  String get cmReasonFake => 'Ненастоящий специалист';

  @override
  String get cmReasonPatient => 'Есть данные пациента';

  @override
  String get cmReasonOther => 'Другое';

  @override
  String get cmReportSent => 'Жалоба отправлена. Спасибо.';

  @override
  String get cmTranslate => 'Перевести';

  @override
  String get cmMachineTranslation => 'Машинный перевод';

  @override
  String get cmShowOriginal => 'Исходный текст';

  @override
  String get cmShowTranslation => 'Перевод';

  @override
  String get cmPin => 'Закрепить';

  @override
  String get cmUnpin => 'Открепить';

  @override
  String get cmPinned => 'Закреплено';

  @override
  String get cmDelete => 'Удалить';

  @override
  String get cmDeleteConfirm => 'Удалить эту запись?';

  @override
  String get cmDeleted => 'Удалено';

  @override
  String get cmLoadMore => 'Показать ещё';

  @override
  String get cmNotAdvice =>
      'Ответы — опыт коллег, а не персональная медицинская консультация.';

  @override
  String get cmRulesTitle => 'Правила сообщества';

  @override
  String get cmRulesIntro =>
      'Сообщество LabGuide — место для обмена опытом по клинической лабораторной диагностике.';

  @override
  String get cmRulesExpand => 'Развернуть правила';

  @override
  String get cmRulesCollapse => 'Свернуть правила';

  @override
  String get cmRulesH1 => 'Что обсуждается';

  @override
  String get cmRulesA1 =>
      'интерпретация результатов анализов (несоответствующие результаты, ложное повышение/понижение)';

  @override
  String get cmRulesA2 =>
      'преаналитика: забор крови, пробирки, хранение, гемолиз';

  @override
  String get cmRulesA3 =>
      'контроль качества (QC, правила Вестгарда), калибровка';

  @override
  String get cmRulesA4 => 'опыт работы с анализаторами и реагентами';

  @override
  String get cmRulesA5 =>
      'гематология, микроскопия, биохимия, иммунология, анализ мочи';

  @override
  String get cmRulesA6 => 'вопросы по проверке знаний и компетенций и обучению';

  @override
  String get cmRulesH2 => 'Как писать';

  @override
  String get cmRulesB1 =>
      'в заголовке — суть вопроса (например: «Калий повышен, гемолиза нет — в чём причина?»)';

  @override
  String get cmRulesB2 =>
      'в подробной части: какой анализ, результат и единицы, метод или анализатор, что вы уже пробовали';

  @override
  String get cmRulesB3 =>
      'указывайте единицы точно: сначала СИ, в скобках традиционные (например, 7,0 ммоль/л (126 мг/дл))';

  @override
  String get cmRulesB4 => 'один пост — один вопрос';

  @override
  String get cmRulesH3 => 'Что не публикуется';

  @override
  String get cmRulesC1 =>
      'имя, телефон, адрес, номер карты пациента и любые данные, позволяющие установить личность';

  @override
  String get cmRulesC2 =>
      'реклама, посторонние темы, оскорбления; публикация интимных или личных изображений и материалов без согласия человека строго запрещена';

  @override
  String get cmRulesC3 =>
      'личные рекомендации по лечению для пациента — здесь опыт коллег, а не совет врача';

  @override
  String get cmRulesH4 => 'Кто может писать';

  @override
  String get cmRulesD1 => 'вопрос — любой зарегистрированный пользователь';

  @override
  String get cmRulesD2Pre =>
      'ответ — только подтверждённые специалисты со значком «✓ Специалист» (';

  @override
  String get cmRulesD2Link => 'Профиль → Подтверждение специалиста';

  @override
  String get cmRulesD2Post =>
      '; загрузите фото диплома или сертификата; документ не сохраняется)';

  @override
  String get cmRulesD3 =>
      'если видите пост, нарушающий правила, нажмите «Пожаловаться»';

  @override
  String get cmRulesOutro =>
      'Чтобы прочитать посты на другом языке, используйте кнопку «Перевести». Уважение и точность — наше главное правило.';

  @override
  String get cmAdminTitle => 'Модерация сообщества';

  @override
  String get cmAdminSub => 'Пользователи с жалобами: восстановить или отозвать';

  @override
  String get cmAdminEmpty => 'Список пуст';

  @override
  String cmAdminReporters(int count) {
    return 'Жалоб от пользователей: $count';
  }

  @override
  String get cmAdminRestore => 'Восстановить';

  @override
  String get cmAdminRevoke => 'Отозвать подтверждение';

  @override
  String get cmAdminSuspended => 'Приостановлены';

  @override
  String get cmAdminVerified => 'Подтверждены';

  @override
  String get cmAdminRejected => 'Отклонены';

  @override
  String get cmAdminDone => 'Готово';

  @override
  String get cmOwnerTag => 'Основатель';

  @override
  String get cmLaunchTitle => 'Запуск сообщества';

  @override
  String get cmLaunchBody =>
      'Нажмите один раз: ваш аккаунт будет подтверждён как основатель, а начальные вопросы и ответы добавятся. Повторное нажатие ничего не дублирует.';

  @override
  String get cmLaunchButton => 'Запустить';

  @override
  String cmLaunchDone(int questions, int answers) {
    return 'Готово: основатель подтверждён. Добавлено: вопросов — $questions, ответов — $answers.';
  }

  @override
  String get cmLaunchAlready =>
      'Сообщество уже запущено: основатель подтверждён, ничего нового не добавлено.';

  @override
  String get cmLaunchNotOwner =>
      'Этому аккаунту не разрешён статус основателя. Войдите с почтой основателя.';

  @override
  String get cmLaunchMfaHint =>
      'Чтобы запустить сообщество, сначала подтвердите двухэтапную защиту: введите 6-значный код из приложения-аутентификатора. После этого появится кнопка «Запуск сообщества».';

  @override
  String get diffFbSound => 'Звук при нажатии';

  @override
  String get diffFbHaptics => 'Вибрация при нажатии';

  @override
  String get diffFbOn => 'включено';

  @override
  String get diffFbOff => 'выключено';

  @override
  String get admYouSuper => 'Вы — владелец (суперадмин)';

  @override
  String get admYouAdmin => 'Вы — администратор';

  @override
  String get adm2faOn =>
      'Двухэтапная защита (2FA) подтверждена. Она требуется для каждого действия администратора.';

  @override
  String get admReportsQueue => 'Жалобы и участники';

  @override
  String get admReportsSub =>
      'Очередь приостановленных, подтверждённые и отклонённые участники';

  @override
  String get admLaunchRow => 'Запуск сообщества';

  @override
  String get admLaunchRowSub =>
      'Подтверждение основателя и стартовые вопросы (один раз)';

  @override
  String admPending(int count) {
    return 'Ожидают: $count';
  }

  @override
  String get admQueueEmpty => 'Очередь пуста';

  @override
  String get admNotConnected => 'На этом сервере пока не подключено';

  @override
  String get admReview => 'Проверка контента';

  @override
  String admReviewSub(int cards, int questions) {
    return 'Не проверено: карточек — $cards, вопросов — $questions';
  }

  @override
  String get admTeam => 'Управление администраторами';

  @override
  String admTeamCount(int count) {
    return 'Администраторов: $count';
  }

  @override
  String get admTeamSubManage => 'Добавление по email и удаление';

  @override
  String get admTeamSubView => 'Список (изменяет только владелец)';

  @override
  String get admLegacyNote =>
      'Статистика, пользователи, журнал действий и партнёры ещё не перенесены на этот сервер — они появятся здесь, когда будут готовы.';

  @override
  String get admOther => 'Другие разделы';

  @override
  String get admTeamIntro =>
      'Администратор получает полный доступ ко всем разделам: модерация сообщества, обращения, проверка контента. Права выдаёт только сервер, и для каждого действия нужен код 2FA.';

  @override
  String get admTeamOwnerOnly =>
      'Добавлять и удалять администраторов может только владелец (суперадмин).';

  @override
  String get admAddTitle => 'Добавить администратора';

  @override
  String get admAddEmail => 'Email (например, Gmail)';

  @override
  String get admAddHint =>
      'Права вступят в силу, когда человек войдёт с этим email и включит 2FA; если аккаунт уже есть — сразу.';

  @override
  String get admAddButton => 'Сделать администратором';

  @override
  String get admAddConfirmTitle => 'Сделать администратором?';

  @override
  String admAddConfirmBody(String email) {
    return '$email получит полный доступ ко всем разделам администратора. Вы можете удалить его в любой момент.';
  }

  @override
  String admAdded(String email) {
    return 'Добавлен: $email';
  }

  @override
  String get admInvalidEmail => 'Неверный email. Например: name@gmail.com';

  @override
  String get admErrAlready => 'Этот email уже администратор.';

  @override
  String get admErrSuper =>
      'Это email владельца (суперадмин) — он уже администратор.';

  @override
  String admErrTooMany(int max) {
    return 'Лимит администраторов: $max. Сначала удалите кого-нибудь.';
  }

  @override
  String admListTitle(int count) {
    return 'Администраторы ($count)';
  }

  @override
  String get admKindSuper => 'Владелец · суперадмин';

  @override
  String admKindGranted(String date) {
    return 'Админ · добавлен $date';
  }

  @override
  String get admNotSignedIn =>
      'Ещё не входил(а) — права вступят в силу при первом входе';

  @override
  String get admYou => 'Вы';

  @override
  String get admRemove => 'Удалить';

  @override
  String get admRemoveTitle => 'Удалить администратора?';

  @override
  String admRemoveBody(String email) {
    return '$email сразу потеряет права администратора — на всех устройствах. Аккаунт и данные не удаляются.';
  }

  @override
  String admRemoved(String email) {
    return 'Удалён: $email';
  }

  @override
  String get admSuperNote =>
      'Владелец задан в секретной настройке сервера (LG_ADMIN_EMAILS) — из приложения не удаляется.';

  @override
  String get admNoGranted => 'Добавленных администраторов пока нет.';

  @override
  String get cmAdminRevokeTitle => 'Отменить подтверждение?';

  @override
  String get cmAdminRevokeBody =>
      'Участник потеряет значок специалиста и не сможет снова пройти AI-проверку. Задавать вопросы он сможет.';

  @override
  String get cmAdminRestoreTitle => 'Восстановить участника?';

  @override
  String get cmAdminRestoreBody =>
      'Вернётся статус до приостановки, публикации снова станут видны. Старые жалобы не учитываются повторно.';

  @override
  String get adminActionGrantAdded => 'Добавлен администратор';

  @override
  String get adminActionGrantRemoved => 'Администратор удалён';

  @override
  String get cytoTitle => 'Цитология';

  @override
  String get cytoSubtitle => 'Гинекологический мазок: клетки и заключения';

  @override
  String get cytoHeroTitle => 'Читайте мазок с пониманием';

  @override
  String get cytoHeroBody =>
      'Схемы клеток, степень чистоты, классификация Bethesda и тренировка — в одном месте.';

  @override
  String get cytoHeroCta => 'Смотреть клетки';

  @override
  String get cytoSchematicCaption =>
      'Схема с пояснениями (LabGuide) — не микрофото, масштаб и цвета условны.';

  @override
  String get cytoCellsTitle => 'Знакомство с клетками';

  @override
  String cytoCellsSub(int n) {
    return '$n элементов: рисунок и главный признак';
  }

  @override
  String get cytoDegreeTitle => 'Степень чистоты влагалищного мазка';

  @override
  String get cytoDegreeSub => 'I–IV степень: отметьте увиденное';

  @override
  String get cytoBethesdaTitle => 'Классификация Bethesda';

  @override
  String get cytoBethesdaSub => 'Что означает заключение ПАП-теста';

  @override
  String get cytoTechniqueTitle => 'Взятие и окраска мазка';

  @override
  String get cytoTechniqueSub => 'Подготовка, фиксация, окраска, ошибки';

  @override
  String get cytoQuizTitle => 'Что это за клетка?';

  @override
  String cytoQuizSub(int n) {
    return '$n вопросов по рисунку';
  }

  @override
  String get cytoQuizIntro =>
      'Посмотрите на рисунок и выберите название: 4 варианта. После ответа показывается главный признак.';

  @override
  String get cytoQuizPrompt => 'Что это?';

  @override
  String get cytoQuizStart => 'Начать тренировку';

  @override
  String get cytoLook => 'Как выглядит';

  @override
  String get cytoKey => 'Главный признак';

  @override
  String get cytoMeaning => 'Что означает';

  @override
  String get cytoConfuse => 'С чем путают';

  @override
  String get cytoRefer => 'Покажите цитологу или врачу';

  @override
  String get cytoDegreeIntro =>
      'Отметьте, что видите в микроскоп, — приложение покажет степень по традиционной классификации. Решает самый тяжёлый признак.';

  @override
  String get cytoLacto => 'Лактобациллы';

  @override
  String get cytoLeuko => 'Лейкоциты';

  @override
  String get cytoFlora => 'Другая флора';

  @override
  String get cytoMany => 'Много';

  @override
  String get cytoFew => 'Мало';

  @override
  String get cytoNone => 'Нет';

  @override
  String get cytoSingle => 'Единичные';

  @override
  String get cytoVeryMany => 'Очень много';

  @override
  String get cytoMixed => 'Смешанная (кокки)';

  @override
  String get cytoPathogenic => 'Патогенная (трихомонады и др.)';

  @override
  String cytoDegreeResult(int n) {
    return '$n-я степень';
  }

  @override
  String get cytoDegreeTable => 'Таблица степеней';

  @override
  String get cytoDegreeNote =>
      'Традиционная классификация (A. Heurlein, 1910; практика стран СНГ). Российские рекомендации (РОАГ 2019) считают, что она имеет лишь историческое значение; международные критерии бактериального вагиноза — Амсел и Ньюджент.';

  @override
  String get cytoDegreeSourceNote =>
      'Ниже — источники классификации и критериев бактериального вагиноза; где они расходятся, приведены оба.';

  @override
  String get cytoBethesdaIntro =>
      'Так записывают заключение мазка шейки матки по системе Bethesda. Дальнейшую тактику определяет врач.';

  @override
  String get cytoMethod => 'Окраска / препарат';

  @override
  String get cytoMarksTitle => 'Обозначения на рисунке';

  @override
  String get cytoNoPhoto =>
      'Настоящее микрофото пока не добавлено — добавляются только изображения с проверенной лицензией.';

  @override
  String get cytoLabCardBody =>
      'Схемы клеток, степень чистоты, Bethesda и тренировка';

  @override
  String get spermTitle => 'Спермограмма';

  @override
  String get spermLabCardBody =>
      'Нормы ВОЗ 2021, счётчик, оценка результата и термины';

  @override
  String get homeSearchHint => 'Поиск анализа, прибора или темы';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchPrompt =>
      'Введите название, сокращение или синоним — на узбекском (латиница или кириллица), русском или английском.';

  @override
  String get searchSectionLibrary => 'Учебные материалы';

  @override
  String get searchSectionSections => 'Разделы';

  @override
  String get diffAssessTitle => 'Сравнение с нормой';

  @override
  String get diffAssessNote =>
      'Это не диагноз: результат сопоставлен с референтным интервалом бланка и показано, на что он может указывать. Заключение даёт врач.';

  @override
  String get diffAssessNeedWbc =>
      'Для оценки по абсолютным числам введите количество лейкоцитов (WBC) — сейчас оценена только доля палочкоядерных.';

  @override
  String get diffAssessAllNormal => 'Все показатели в пределах нормы.';

  @override
  String diffAssessIncomplete(int counted, int target) {
    return 'Сравнение появится, когда подсчёт будет завершён: сосчитано $counted из $target клеток. Доли по незавершённому подсчёту ненадёжны.';
  }

  @override
  String get diffFlagHigh => 'Повышено';

  @override
  String get diffFlagLow => 'Понижено';

  @override
  String get diffFlagNormal => 'В норме';

  @override
  String get diffMeasureNeutrophils => 'Нейтрофилы (всего)';

  @override
  String get diffMeasureLymphocytes => 'Лимфоциты';

  @override
  String get diffMeasureMonocytes => 'Моноциты';

  @override
  String get diffMeasureEosinophils => 'Эозинофилы';

  @override
  String get diffMeasureBasophils => 'Базофилы';

  @override
  String get diffMeasureBands => 'Палочкоядерные нейтрофилы';

  @override
  String diffAssessRange(String range) {
    return 'норма $range';
  }

  @override
  String diffAssessMaySuggest(String finding) {
    return 'Возможная трактовка: $finding';
  }

  @override
  String get diffAssessAboutFinding => 'Подробнее об этой трактовке';

  @override
  String get diffAssessReferBody =>
      'Бласты или неопознанные клетки, тяжёлая нейтропения (< 0,5 ×10⁹/л) или выраженная эозинофилия (> 1,5 ×10⁹/л): срочно покажите результат и мазок врачу или гематологу.';

  @override
  String get diffLimitsTitle => 'Референтные интервалы бланка';

  @override
  String get diffLimitsSub =>
      'Введите интервалы из бланка вашей лаборатории — оценка будет по ним. Если нижняя граница пуста, она не проверяется.';

  @override
  String get diffLimitsLow => 'Нижняя граница';

  @override
  String get diffLimitsHigh => 'Верхняя граница';

  @override
  String get diffLimitsInvalid =>
      'Неверный интервал: нижняя граница должна быть меньше верхней.';

  @override
  String get diffLimitsReset => 'Вернуть значения из источника';

  @override
  String get diffLimitsSourceNote =>
      'Значения по умолчанию — 95 % интервал для взрослых (Harrison’s Manual of Medicine, 20-е изд., табл. 64-1); палочкоядерные — Любина 1984, табл. 6. Определения руководства MSD отличаются: эозинофилия > 0,5 ×10⁹/л (здесь верхняя граница по умолчанию 0,7), лимфопения < 1,0 ×10⁹/л (здесь нижняя граница по умолчанию 1,5). У детей и в некоторых этнических группах (например, Duffy-отрицательных) норма другая.';

  @override
  String get cytoAdequacyTitle => 'Качество образца';

  @override
  String get cytoAdequacySub =>
      'Bethesda 2014: пригоден или нет, частые артефакты';

  @override
  String get cytoArtefactsTitle => 'Частые артефакты';

  @override
  String get cytoReactiveTitle => 'Реактивные изменения и атипия';

  @override
  String get cytoReactiveSub =>
      'Воспаление, репарация, облучение, ВМС против ASC-US и LSIL';

  @override
  String get cytoReactiveIntro =>
      'В системе Bethesda реактивные клеточные изменения (воспаление, включая репарацию, лимфоцитарный цервицит, облучение, ВМС) — неопухолевые находки в рамках NILM.';

  @override
  String get cytoCompareTitle => 'Сравнение';

  @override
  String get cytoCompareNone =>
      'в указанных источниках отдельного критерия нет';

  @override
  String get cytoReactiveTypesTitle => 'Виды реактивных изменений';

  @override
  String get cytoMaturationTitle => 'Индекс созревания';

  @override
  String get cytoMaturationSub =>
      'Парабазальные : промежуточные : поверхностные — калькулятор';

  @override
  String get cytoMiCalcTitle => 'Калькулятор';

  @override
  String get cytoMiParabasal => 'Парабазальные клетки';

  @override
  String get cytoMiIntermediate => 'Промежуточные клетки';

  @override
  String get cytoMiSuperficial => 'Поверхностные клетки';

  @override
  String get cytoMiEmpty =>
      'Введите число одиночных клеток (целые числа); хотя бы одно больше 0.';

  @override
  String get cytoMiResult =>
      'Индекс созревания (парабазальные : промежуточные : поверхностные)';

  @override
  String cytoMiTotal(int n) {
    return 'Подсчитано клеток: $n';
  }

  @override
  String get cytoMiCaveat =>
      'Это только арифметика. Трактовка зависит от возраста, дня цикла, беременности, гормонов и воспаления — её даёт цитолог или врач.';

  @override
  String get cytoOtherTitle => 'Другие материалы';

  @override
  String get cytoOtherSub =>
      'Моча, серозные жидкости, мокрота: категории заключений';

  @override
  String get cytoOtherIntro =>
      'Краткий обзор: только названия международных категорий заключений. Критерии и показатели риска — в источниках.';

  @override
  String get cytoCategoriesTitle => 'Категории';

  @override
  String get contactPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get bloodGroupTitle => 'Группа крови';

  @override
  String get bloodGroupLabCardBody =>
      'AB0 и RhD: методы, совместимость, расхождения, тренировка';

  @override
  String get autoPresTitle => 'Автоматическая презентация';

  @override
  String get autoPresEntrySub =>
      'Слайды из материалов приложения с источниками';

  @override
  String get autoPresPickerSub =>
      'Выберите тему или анализы. Слайды собираются только из материалов приложения с источниками — ничего не выдумывается.';

  @override
  String get autoPresLanguageNote =>
      'Слайды создаются на языке приложения. Материалы, которых нет на этом языке, пропускаются — языки не смешиваются.';

  @override
  String get autoPresModeTopic => 'По теме';

  @override
  String get autoPresModeTests => 'По анализам';

  @override
  String get autoPresSearch => 'Поиск анализов';

  @override
  String get autoPresSearchHint => 'Название, сокращение или синоним';

  @override
  String autoPresSelectedCount(int count, int max) {
    return 'Выбрано: $count из $max';
  }

  @override
  String autoPresLimitReached(int max) {
    return 'Не больше $max анализов в одной презентации.';
  }

  @override
  String get autoPresNoResults => 'Анализы не найдены.';

  @override
  String get autoPresOptQuiz => 'Слайды с вопросами';

  @override
  String get autoPresOptQuizSub =>
      'Вопросы по выбранным материалам; ответ открывается по нажатию.';

  @override
  String get autoPresOptGeneral => 'Общая преаналитика';

  @override
  String get autoPresOptGeneralSub =>
      'Порядок взятия, гемолиз, жгут (ВОЗ, 2010).';

  @override
  String get autoPresPreview => 'Просмотреть слайды';

  @override
  String get autoPresPickFirst =>
      'Сначала выберите тему или хотя бы один анализ.';

  @override
  String get autoPresPreviewTitle => 'Предпросмотр слайдов';

  @override
  String get autoPresPreviewSub =>
      'Измените порядок или уберите слайды, затем начните.';

  @override
  String autoPresSlideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count слайда',
      many: '$count слайдов',
      few: '$count слайда',
      one: '$count слайд',
    );
    return '$_temp0';
  }

  @override
  String get autoPresStart => 'Начать';

  @override
  String get autoPresMoveUp => 'Выше';

  @override
  String get autoPresMoveDown => 'Ниже';

  @override
  String get autoPresRemove => 'Убрать слайд';

  @override
  String get autoPresRestore => 'Вернуть убранные слайды';

  @override
  String get autoPresSourcesPinned =>
      'Слайд с источниками — собирается автоматически из оставшихся слайдов';

  @override
  String get autoPresEmptyTitle => 'Недостаточно материалов с источниками';

  @override
  String get autoPresEmptyBody =>
      'Для этого выбора в приложении нет материалов с источниками на текущем языке, поэтому слайды не созданы. Ничего не дописывается от себя.';

  @override
  String autoPresNoticeStructureOnly(String name) {
    return '$name: в карточке ещё нет текста — пропущено.';
  }

  @override
  String autoPresNoticeNoContent(String name) {
    return '$name: нет текста с источниками для слайдов — пропущено.';
  }

  @override
  String autoPresNoticeLang(int count) {
    return 'Нет на этом языке, поэтому пропущено: $count. Языки не смешиваются.';
  }

  @override
  String get autoPresDeckTitleTests => 'Лабораторные анализы';

  @override
  String autoPresMoreItems(int count) {
    return 'и ещё $count';
  }

  @override
  String autoPresPackSource(String version) {
    return 'LabGuide, пакет контента $version — слайды собраны автоматически из карточек с источниками';
  }

  @override
  String autoPresSourceLine(String text) {
    return 'Источник: $text';
  }

  @override
  String get autoPresColIndicator => 'Показатель';

  @override
  String get autoPresColValue => 'Значение';

  @override
  String get autoPresColTarget => 'Цель';

  @override
  String get autoPresColTube => 'Пробирка';

  @override
  String get autoPresColCap => 'Цвет крышки';

  @override
  String get autoPresShowAnswer => 'Показать ответ';

  @override
  String get autoPresHideAnswer => 'Скрыть ответ';

  @override
  String get autoPresAnswerLabel => 'Ответ';

  @override
  String get autoPresTplTitle => 'Заголовок';

  @override
  String get autoPresTplBullets => 'Пункты';

  @override
  String get autoPresTplTable => 'Таблица';

  @override
  String get autoPresTplFigure => 'Рисунок';

  @override
  String get autoPresTplQa => 'Вопрос';

  @override
  String get instSchematicCaption =>
      'Схематичное изображение — не фото конкретной модели';

  @override
  String get instSchematicTapToZoom =>
      'Нажмите на изображение, чтобы увеличить';

  @override
  String get instSchematicNotPhoto =>
      'Оригинальная схема класса приборов, нарисованная в LabGuide. Это не реальная фотография прибора производителя; узлы показаны на уровне принципа и не отражают особенностей конкретной модели.';

  @override
  String instSchematicSemantics(String kind) {
    return 'Схематичное изображение: $kind';
  }

  @override
  String get histoTitle => 'Гистология';

  @override
  String get histoLabCardBody =>
      'Ткани и органы: настоящие микрофото, признаки, тренировка';

  @override
  String get contactRowTitle => 'Контакты и жалобы';

  @override
  String get contactRowSub => 'Вопросы, жалобы, сообщить об ошибке';

  @override
  String get contactTitle => 'Связь';

  @override
  String get contactIntro =>
      'Работает без интернета и аккаунта: письмо отправляется из вашего почтового приложения.';

  @override
  String get contactEmailLabel => 'Электронная почта';

  @override
  String get contactCopy => 'Скопировать адрес';

  @override
  String get contactCopied => 'Адрес скопирован';

  @override
  String get contactNoMailApp =>
      'Не удалось открыть почтовое приложение. Адрес скопирован: отправьте письмо из любой почты.';

  @override
  String get contactQuestionTitle => 'Вопросы и предложения';

  @override
  String get contactQuestionBody =>
      'Задайте вопрос о приложении, предложите тему или улучшение.';

  @override
  String get contactQuestionAction => 'Написать письмо';

  @override
  String get contactAdTitle => 'Реклама и партнёрство';

  @override
  String get contactAdBody =>
      'Производители, дистрибьюторы и сервисные фирмы лабораторного оборудования могут размещать рекламу в LabGuide.\nНапишите нам или (если доступно в вашей версии) используйте форму партнёра.';

  @override
  String get contactAdAction => 'Написать по рекламе';

  @override
  String get contactReportTitle => 'Жалоба / сообщить об ошибке';

  @override
  String get contactReportBody =>
      'Сообщите о неверных медицинских данных или неуместном пользовательском контенте.';

  @override
  String get contactReportHint =>
      'Укажите в письме раздел или карточку, чтобы мы быстрее нашли.';

  @override
  String get contactReportAction => 'Отправить жалобу';

  @override
  String get contactResponseNote =>
      'Мы читаем каждое сообщение и исправляем подтверждённые ошибки, но не обещаем срок ответа. Этот адрес не предназначен для экстренной медицинской помощи.';

  @override
  String get contactPrivacyNote =>
      'Если вы нам пишете, мы видим ваш адрес и текст письма.';

  @override
  String contactMailBodyQuestion(String version, String platform) {
    return 'Ваш вопрос или предложение:\n\n\n---\nПриложение: LabGuide $version\nПлатформа: $platform';
  }

  @override
  String contactMailBodyAd(String version, String platform) {
    return 'Фирма и что вы хотите рекламировать:\n\n\n---\nПриложение: LabGuide $version\nПлатформа: $platform';
  }

  @override
  String contactMailBodyReport(String version, String platform) {
    return 'Раздел / название карточки:\nЧто не так:\n(Не указывайте данные пациентов.)\n\n\n---\nПриложение: LabGuide $version\nПлатформа: $platform';
  }

  @override
  String get partnerKindLaboratory => 'Лабораторная служба';

  @override
  String get partnerPlacementHomeLab => 'Главная: лабораторная служба';

  @override
  String get partnerPlacementHomeEquipment =>
      'Главная: фирма-поставщик оборудования';

  @override
  String get homeAdDemoTitle => 'Образец / Демо — рекламное место';

  @override
  String get homeAdDemoLabBody =>
      'Здесь появится реклама партнёрской лабораторной службы';

  @override
  String get homeAdDemoEquipmentBody =>
      'Здесь появится реклама фирмы-поставщика оборудования';

  @override
  String get homeAdDemoCta => 'Разместить рекламу';

  @override
  String get cmBlock => 'Заблокировать пользователя';

  @override
  String get cmBlockConfirmTitle => 'Заблокировать пользователя?';

  @override
  String get cmBlockConfirmBody =>
      'Его вопросы и ответы больше не будут видны на этом устройстве. Блокировку можно снять в списке сообщества.';

  @override
  String get cmBlockedDone =>
      'Пользователь заблокирован. Его публикации скрыты.';

  @override
  String get cmBlockedHidden =>
      'Публикация скрыта, потому что вы заблокировали её автора.';

  @override
  String cmBlockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Вы заблокировали $count пользователей.',
      few: 'Вы заблокировали $count пользователей.',
      one: 'Вы заблокировали $count пользователя.',
    );
    return '$_temp0';
  }

  @override
  String get cmUnblockAll => 'Разблокировать всех';

  @override
  String get cmContactLink => 'Связаться с LabGuide (сообщить о проблеме)';

  @override
  String get authOr => 'или';

  @override
  String get authSignInApple => 'Войти с Apple';

  @override
  String get authSignInGoogle => 'Войти через Google';

  @override
  String get authSocialFailed =>
      'Не удалось войти. Проверьте соединение и попробуйте ещё раз или войдите по коду из письма.';

  @override
  String get authSocialEmailUnverified =>
      'Email этого аккаунта не подтверждён, поэтому войти с ним нельзя. Войдите по коду из письма.';

  @override
  String get authSocialEmailRequired =>
      'Этот аккаунт не передал адрес email. Войдите по коду из письма.';

  @override
  String get accountDeleteAppleNote =>
      'Вы вошли через Apple, поэтому перед удалением Apple попросит подтверждение. Это также отключит LabGuide от вашего Apple ID.';

  @override
  String get accountDeleteAppleCancelled =>
      'Ничего не удалено: подтверждение Apple отменено.';

  @override
  String get urinTitle => 'Анализ мочи';

  @override
  String get urinLabCardBody =>
      'Сбор, тест-полоска, снимки осадка, чтение результата, тренировка';

  @override
  String get coagTitle => 'Коагулограмма';

  @override
  String get coagLabCardBody =>
      'ПВ/МНО, АЧТВ, фибриноген, D-димер, проба, балл ДВС';

  @override
  String get coproTitle => 'Копрология и паразиты';

  @override
  String get coproLabCardBody =>
      'Копрограмма, скрытая кровь, ключ яиц и цист (схемы)';

  @override
  String get admPanelAccess =>
      'Доступ: email владельца (ADMIN_EMAILS) и код из письма. Сервер проверяет каждый запрос.';

  @override
  String get admOverview => 'Общие показатели';

  @override
  String admOverviewSub(int total, int online, int week) {
    return 'Зарегистрировано: $total · онлайн: $online · новых за 7 дней: $week';
  }

  @override
  String get admComplaintsRow => 'Жалобы из приложения';

  @override
  String admComplaintsRowSub(int count) {
    return 'Открытые: $count';
  }

  @override
  String get admReportsRow => 'Жалобы в сообществе';

  @override
  String admReportsRowSub(int count) {
    return 'Нерассмотренные посты: $count';
  }

  @override
  String admEmailNote(String email) {
    return 'Жалобы и вопросы по email приходят на $email — смотрите их в почте (в приложение они не попадают).';
  }

  @override
  String get admUsersSub => 'Поиск по email или псевдониму, роль, приостановка';

  @override
  String get admAuditSub => 'Каждое действие админа записывается';

  @override
  String get admStoreTitle => 'Загрузки и продажи';

  @override
  String get admStoreBody =>
      'Сервер не видит загрузки из магазинов — их показывают App Store Connect и Google Play Console. В приложении нет аналитических SDK (политика конфиденциальности). Числа в этой панели — аккаунты, подтвердившие email.';

  @override
  String get admSales => 'Продажи: 0 (оплаты пока нет)';

  @override
  String get admAppStoreConnect => 'App Store Connect';

  @override
  String get admPlayConsole => 'Google Play Console';

  @override
  String get admStatsAccounts => 'Аккаунты';

  @override
  String get admOnlineNow => 'Сейчас онлайн (5 минут)';

  @override
  String get admSuspendedAccounts => 'Приостановленные аккаунты';

  @override
  String get admStatsActiveNote =>
      'Онлайн и активные — аккаунты, отправившие запрос на сервер. Хранятся только минута и день; IP и устройство не сохраняются.';

  @override
  String get admChartTitle => 'Новые аккаунты — последние 14 дней';

  @override
  String admChartBar(String date, int count) {
    return '$date: новых аккаунтов — $count';
  }

  @override
  String admChartTotal(int count) {
    return 'Всего за 14 дней: $count';
  }

  @override
  String get admStatsObjects => 'Основные объекты';

  @override
  String get admStatsGroupsCount => 'Группы';

  @override
  String get admStatsTeachers => 'Зарегистрированные преподаватели';

  @override
  String get admStatsStudents => 'Студенты в группах';

  @override
  String get admStatsAssignments => 'Тестовые сессии';

  @override
  String get admStatsResults => 'Результаты тестов';

  @override
  String get admStatsQuestions => 'Вопросы сообщества';

  @override
  String get admStatsAnswers => 'Ответы сообщества';

  @override
  String get admStatsComplaintsOpen => 'Открытые жалобы';

  @override
  String get admStatsComplaintsResolved => 'Решённые жалобы';

  @override
  String get admStatsReportsOpen => 'Сообщество: нерассмотренные жалобы';

  @override
  String get admStatsAwaiting => 'Обращения: ждут ответа';

  @override
  String admStatsUpdated(String time) {
    return 'Обновлено: $time';
  }

  @override
  String get admComplaintsTitle => 'Жалобы из приложения';

  @override
  String get admApple12Note =>
      'Рассматривайте жалобы на неприемлемый контент быстро (Apple 1.2 требует своевременной реакции; цель — 24 часа).';

  @override
  String get admFilterOpen => 'Открытые';

  @override
  String get admFilterResolved => 'Решённые';

  @override
  String get admAllKinds => 'Все типы';

  @override
  String get complaintKindComplaint => 'Жалоба';

  @override
  String get complaintKindInappropriate => 'Неприемлемый контент';

  @override
  String get complaintKindBug => 'Ошибка';

  @override
  String get complaintKindAd => 'Реклама';

  @override
  String get complaintKindOther => 'Другое';

  @override
  String get admComplaintsEmpty => 'В этом списке жалоб нет';

  @override
  String get admComplaintAnon => 'Гость (без аккаунта)';

  @override
  String admComplaintFrom(String email) {
    return 'Отправитель: $email';
  }

  @override
  String admComplaintTarget(String ref) {
    return 'Ссылка: $ref';
  }

  @override
  String get admComplaintNote => 'Заметка админа';

  @override
  String get admComplaintNoteHint => 'Что сделано? (видят только админы)';

  @override
  String get admComplaintSaveNote => 'Сохранить заметку';

  @override
  String get admComplaintResolve => 'Решено';

  @override
  String get admComplaintReopen => 'Открыть снова';

  @override
  String admComplaintResolvedOn(String date) {
    return 'Решено: $date';
  }

  @override
  String get admSaved => 'Сохранено';

  @override
  String get admReportsEmpty => 'В этом списке жалоб нет';

  @override
  String get admReportOpen => 'Открытые';

  @override
  String get admReportDismissed => 'Отклонённые';

  @override
  String get admReportResolved => 'Решённые';

  @override
  String get admReportKindQuestion => 'Вопрос';

  @override
  String get admReportKindAnswer => 'Ответ';

  @override
  String admReportCount(int reports, int reporters) {
    return 'Жалоб: $reports · людей: $reporters';
  }

  @override
  String admReportReasons(String reasons) {
    return 'Причина: $reasons';
  }

  @override
  String get admReportDeleted => 'Пост удалён';

  @override
  String get admReportAuthorSuspended => 'Автор приостановлен';

  @override
  String get admReportOpenPost => 'Открыть пост';

  @override
  String get admReportDismiss => 'Необоснованна';

  @override
  String get admReportResolve => 'Решено';

  @override
  String get admReportSuspend => 'Приостановить автора';

  @override
  String get admReportDismissTitle => 'Отклонить жалобу?';

  @override
  String get admReportDismissBody =>
      'Жалобы закрываются и не учитываются для автоматической приостановки. Действие записывается в журнал.';

  @override
  String get admReportResolveTitle => 'Отметить как решённую?';

  @override
  String get admReportResolveBody =>
      'Меры приняты (например, пост удалён). Действие записывается в журнал.';

  @override
  String get admReportSuspendTitle => 'Приостановить автора?';

  @override
  String get admReportSuspendBody =>
      'Автор не сможет писать в сообществе, его посты скрываются. Действие записывается в журнал.';

  @override
  String get admSearchModeEmail => 'Email';

  @override
  String get admSearchModeName => 'Псевдоним';

  @override
  String get admSearchEmail => 'Полный email (точное совпадение)';

  @override
  String get admSearchName => 'Псевдоним в группе (минимум 2 символа)';

  @override
  String get admUsersSearchNote =>
      'Email не хранится на сервере в открытом виде: аккаунт находится только по полному email и показывается замаскированным.';

  @override
  String get admSearch => 'Искать';

  @override
  String get admStatusActive => 'Активен';

  @override
  String get admStatusSuspended => 'Приостановлен';

  @override
  String get admUserAdminTag => 'Админ';

  @override
  String get admUserTitle => 'Пользователь';

  @override
  String get admUserRole => 'Роль';

  @override
  String get admRoleChanged => 'Роль изменена';

  @override
  String get admRoleSelfNote => 'Свою роль и статус здесь изменить нельзя.';

  @override
  String admUserFacts(int owned, int joined, int threads, int complaints) {
    return 'Группы: $owned (преподаватель) · $joined (студент) · обращения: $threads · жалобы: $complaints';
  }

  @override
  String get admAccountTitle => 'Статус аккаунта';

  @override
  String get admAccountSuspend => 'Приостановить аккаунт';

  @override
  String get admAccountSuspendTitle => 'Приостановить аккаунт?';

  @override
  String get admAccountSuspendBody =>
      'Пользователь выйдет на всех устройствах и не сможет войти снова (код из письма, Google, Apple). Приложение покажет ему контактный адрес. Действие записывается в журнал.';

  @override
  String get admAccountReactivate => 'Восстановить доступ';

  @override
  String get admAccountReactivateTitle => 'Восстановить аккаунт?';

  @override
  String get admAccountReactivateBody =>
      'Пользователь снова сможет войти. Действие записывается в журнал.';

  @override
  String get admAccountAdminNote => 'Аккаунт админа нельзя приостановить.';

  @override
  String get admUserCommunity => 'Статус в сообществе';

  @override
  String get admCommunityNone => 'Обычный участник';

  @override
  String admUserCommunityFacts(int questions, int answers, int reporters) {
    return 'Вопросы: $questions · ответы: $answers · пожаловались: $reporters';
  }

  @override
  String get admCommunitySuspend => 'Приостановить в сообществе';

  @override
  String get admCommunitySuspendTitle => 'Приостановить в сообществе?';

  @override
  String get admCommunitySuspendBody =>
      'Аккаунт не сможет писать вопросы и ответы, его посты скрываются. Остальное приложение работает. Действие записывается в журнал.';

  @override
  String get admErrOwner => 'Аккаунт владельца нельзя приостановить.';

  @override
  String get admErrSelf => 'Это действие нельзя применить к себе.';

  @override
  String get admErrName => 'Псевдоним: 2–40 символов.';

  @override
  String admAuditBy(String actor) {
    return 'Исполнитель: $actor';
  }

  @override
  String get admAuditSystem => 'Система';

  @override
  String get adminActionReportDismissed => 'Жалоба в сообществе отклонена';

  @override
  String get adminActionReportResolved => 'Жалоба в сообществе решена';

  @override
  String get adminActionCommunitySuspended => 'Приостановлен в сообществе';

  @override
  String get adminActionCommunityRestored => 'Восстановлен в сообществе';

  @override
  String get adminActionCommunityRevoked =>
      'Подтверждение специалиста отменено';

  @override
  String get adminActionAutoSuspended =>
      'Автоматически приостановлен по жалобам';

  @override
  String get adminActionPostDeleted => 'Пост удалён';

  @override
  String get adminActionPinned => 'Закрепление вопроса изменено';

  @override
  String get adminActionAccountDeleted => 'Аккаунт удалён';

  @override
  String get adminActionMfa => '2FA включена';

  @override
  String get adminActionTeacher => 'Преподаватель зарегистрирован';

  @override
  String get adminActionRoleChanged => 'Роль изменена';

  @override
  String get adminActionAccountSuspended => 'Аккаунт приостановлен';

  @override
  String get adminActionAccountReactivated => 'Аккаунт восстановлен';

  @override
  String get adminActionComplaintNote => 'Добавлена заметка к жалобе';

  @override
  String get adminActionComplaintResolved => 'Жалоба решена';

  @override
  String get adminActionComplaintReopened => 'Жалоба открыта снова';

  @override
  String get adminActionIdentityLinked => 'Привязан способ входа';

  @override
  String get complaintFormTitle => 'Отправить жалобу из приложения';

  @override
  String get complaintFormBody =>
      'Напишите о неприемлемом контенте, ошибке или другой проблеме — команда LabGuide рассмотрит (обычно в течение 24 часов).';

  @override
  String get complaintKindLabel => 'Тип';

  @override
  String get complaintText => 'Текст';

  @override
  String get complaintTextHint => 'Что случилось? Какой экран или пост?';

  @override
  String complaintTarget(String ref) {
    return 'Ссылка: $ref';
  }

  @override
  String get complaintSend => 'Отправить жалобу';

  @override
  String get complaintSent => 'Отправлено. Спасибо — рассмотрим.';

  @override
  String get complaintTooShort => 'Напишите хотя бы 5 символов.';

  @override
  String complaintRateLimited(int minutes) {
    return 'Слишком много отправок: не более 5 в час. Попробуйте через $minutes мин.';
  }

  @override
  String get complaintAnonNote =>
      'Без аккаунта мы не сможем вам ответить. Если нужен ответ — войдите или напишите на email.';

  @override
  String get complaintPhiNote =>
      'Не указывайте имя пациента и другие личные данные.';

  @override
  String get complaintFailed =>
      'Не отправлено. Проверьте интернет и попробуйте снова.';

  @override
  String authAccountSuspended(String email) {
    return 'Ваш аккаунт приостановлен. Если есть вопросы, напишите: $email';
  }

  @override
  String get admSectionComplaints => 'Жалобы';

  @override
  String get bloodMorphTitle => 'Морфология крови';

  @override
  String get bloodMorphLabCardBody =>
      'Эритроциты, тромбоциты, анемии: настоящие микрофото, помощник, тренировка';

  @override
  String get lectureSearchLabel => 'Поиск презентаций';

  @override
  String get lectureSearchHint =>
      'Тема, анализ или заголовок слайда (например: глюкоза)';

  @override
  String get lectureFilterAll => 'Все';

  @override
  String get lectureFilterProtocols => 'Практические протоколы';

  @override
  String lectureFilterModule(int n) {
    return 'Модуль $n';
  }

  @override
  String get lectureLangAll => 'Все языки';

  @override
  String lectureDecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count презентации',
      many: '$count презентаций',
      few: '$count презентации',
      one: '$count презентация',
    );
    return '$_temp0';
  }

  @override
  String lectureSlidesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count слайда',
      many: '$count слайдов',
      few: '$count слайда',
      one: '$count слайд',
    );
    return '$_temp0';
  }

  @override
  String lectureSlidesMatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count слайда подходят',
      many: '$count слайдов подходят',
      few: '$count слайда подходят',
      one: '$count слайд подходит',
    );
    return '$_temp0';
  }

  @override
  String lectureMoreSlides(int count) {
    return 'ещё $count';
  }

  @override
  String lectureResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count презентации',
      many: 'Найдено $count презентаций',
      few: 'Найдено $count презентации',
      one: 'Найдена $count презентация',
    );
    return '$_temp0';
  }

  @override
  String get lectureNoResultsTitle => 'Ничего не найдено';

  @override
  String get lectureNoResultsBody =>
      'Попробуйте другое слово или фильтр. Поиск работает по-узбекски (латиница или кириллица), по-русски и по-английски.';

  @override
  String get lectureClearFilters => 'Сбросить поиск и фильтры';

  @override
  String lectureLangFallback(String wanted, String shown) {
    return 'Эта презентация недоступна на языке «$wanted» — показана на языке «$shown»';
  }

  @override
  String get lectureDeckLoadFailed => 'Не удалось открыть презентацию';

  @override
  String get lectureFullscreen => 'Полный экран';

  @override
  String get lectureFullscreenExit => 'Выйти из полноэкранного режима';

  @override
  String get lectureSourcesTitle => 'Источники слайда';

  @override
  String get lectureSourcesOpen => 'Показать источники полностью';

  @override
  String lectureSourcesCount(int count) {
    return 'Источники: $count';
  }

  @override
  String lectureSourceLocator(String loc) {
    return 'Раздел/страница: $loc';
  }

  @override
  String get lectureSourcesHint =>
      'Полный список — на последнем слайде «Литература».';

  @override
  String get lectureRotateTitle =>
      'Повернуть экран горизонтально (альбомная ориентация)?';

  @override
  String get lectureRotateBody =>
      'В альбомной ориентации слайд займёт весь экран. «Нет» — экран не поворачивается, слайд показывается в текущей ориентации.';

  @override
  String get lectureRotateCastBody =>
      'Телевизоры и мониторы горизонтальные: для трансляции рекомендуется альбомная ориентация.';

  @override
  String get lectureRotateYes => 'Да';

  @override
  String get lectureRotateNo => 'Нет';

  @override
  String get lectureRotateRemember => 'Больше не спрашивать';

  @override
  String get lectureOrientationMenu => 'Ориентация экрана при показе';

  @override
  String get lectureOrientationAsk => 'Всегда спрашивать';

  @override
  String get lectureOrientationLandscape => 'Всегда горизонтально';

  @override
  String get lectureOrientationKeep => 'Не поворачивать';

  @override
  String get lectureMore => 'Другие действия';

  @override
  String get lectureCast => 'Вывести на экран';

  @override
  String get lectureCastTitle => 'Показ на телевизоре или мониторе';

  @override
  String get lectureCastHow =>
      'Показ работает через встроенное в телефон «дублирование экрана»: на телевизоре виден экран телефона. В режиме показа на экране только слайд (без кнопок), экран не гаснет.';

  @override
  String get lectureCastStepsAndroid =>
      '1. Телефон и телевизор должны быть в одной сети Wi‑Fi.\n2. Откройте «Трансляцию экрана» (Cast, Smart View, Miracast — зависит от телефона) и выберите телевизор.\n3. Вернитесь в приложение и нажмите «Начать показ».';

  @override
  String get lectureCastStepsIos =>
      '1. iPhone/iPad и телевизор (Apple TV или с поддержкой AirPlay) должны быть в одной сети Wi‑Fi.\n2. Откройте Пункт управления (свайп вниз от правого верхнего угла) → «Повтор экрана» → выберите телевизор.\n3. Вернитесь в приложение и нажмите «Начать показ».';

  @override
  String get lectureCastOpenSettings => 'Открыть настройки трансляции';

  @override
  String get lectureCastSettingsFailed =>
      'Не удалось открыть настройки — найдите «Трансляцию экрана» в настройках или в быстрой панели.';

  @override
  String get lectureCastStart => 'Начать показ';

  @override
  String get lecturePresenter => 'Режим докладчика';

  @override
  String get lecturePresenterNext => 'Следующий слайд';

  @override
  String get lecturePresenterLast => 'Это последний слайд';

  @override
  String get lecturePresenterTimer => 'Время';

  @override
  String get lecturePresenterReset => 'Сбросить время';

  @override
  String get lecturePresenterNote =>
      'Режим докладчика — только на этом устройстве. При трансляции телевизор покажет то же самое (дублирование экрана) — для зрителей используйте «Полный экран».';

  @override
  String get topicTestAction => 'Тест по теме';

  @override
  String get topicTestPreparing => 'Вопросы по этой теме готовятся';

  @override
  String get topicTestPreparingShort => 'Вопросы готовятся';

  @override
  String topicTestPreparingBody(int count) {
    return 'В тест входят только проверенные вопросы. Сейчас по этой теме их $count — нужно не меньше 3.';
  }

  @override
  String topicTestIntro(int count) {
    return 'Вопросов: $count · после каждого ответа — правильный ответ и пояснение';
  }

  @override
  String get topicTestSavedNote =>
      'Если выйдете, ответы сохранятся — продолжите с того же места.';

  @override
  String get topicTestSourcesNote =>
      'Вопросы только из проверенных источников: официальные вопросы с подтверждённым ключом и учебные вопросы с указанным источником.';

  @override
  String get topicTestStart => 'Начать тест';

  @override
  String topicTestResume(int answered, int total) {
    return 'Продолжить · $answered/$total';
  }

  @override
  String topicTestBest(int score, int total) {
    return 'Лучший результат: $score/$total';
  }

  @override
  String topicTestBadgeLabel(int score, int total) {
    return 'Тест по теме, лучший результат $score из $total';
  }

  @override
  String get topicTestRetake => 'Пройти заново';

  @override
  String get topicTestNextTopic => 'Следующая тема';

  @override
  String get topicTestOpenSlide => 'Открыть слайд';

  @override
  String get topicTestOpenDeckStart => 'Открыть презентацию с начала';

  @override
  String get topicTestHistory => 'История результатов';

  @override
  String get topicTestAssign => 'Задать группе';

  @override
  String topicTestLimitBody(int minutes) {
    return 'Каждому студенту даётся $minutes мин с момента начала. Когда время выйдет, ответы отправятся сами.';
  }

  @override
  String get topicTestLimitNoneBody =>
      'Без ограничения времени — студент решает тест в любое время до срока.';

  @override
  String get topicTestOpenFor => 'Сколько тест открыт';

  @override
  String get topicTestAssignSub =>
      'Студенты подключаются по QR или коду, результаты видите вы';

  @override
  String get topicTestSelf => 'Пройти самому';

  @override
  String get topicTestSelfSub =>
      'Сохраняется только у вас, студентам не отправляется';

  @override
  String get topicTestAssignIntro =>
      'Студенты сдают тест на своём телефоне до срока; балл считается на сервере.';

  @override
  String get topicTestGroups => 'Группы';

  @override
  String get topicTestNoGroups => 'У вас пока нет групп';

  @override
  String get topicTestNoGroupsBody =>
      'Сначала создайте группу и пригласите студентов — затем задайте тест отсюда.';

  @override
  String get topicTestPickGroup => 'Выберите хотя бы одну группу';

  @override
  String get topicTestReveal => 'Правильные ответы студенту';

  @override
  String get topicTestRevealNow => 'Сразу после сдачи';

  @override
  String get topicTestRevealAfterDue => 'После срока';

  @override
  String get topicTestRevealNeedsDue => 'Для «После срока» выберите срок сдачи';

  @override
  String topicTestSent(int count) {
    return 'Тест отправлен, групп: $count';
  }

  @override
  String topicTestTitle(String title) {
    return 'Тест по теме: $title';
  }

  @override
  String get topicTestSentList => 'Отправленные тесты';

  @override
  String topicTestAnswersLater(String date) {
    return 'Правильные ответы откроются после срока ($date) или когда преподаватель завершит тест';
  }

  @override
  String get topicTestDistribution => 'Распределение результатов';

  @override
  String get topicTestHardest => 'Самые трудные вопросы';

  @override
  String get topicTestAssignedTitle => 'Заданные тесты';

  @override
  String get topicTestMenu => 'Действия';

  @override
  String get topicTestOpenLecture => 'Открыть презентацию';

  @override
  String get topicTestCreateGroup => 'Создать группу';

  @override
  String topicTestStudents(int count) {
    return 'Студентов: $count';
  }

  @override
  String topicTestReworkMistakes(int count) {
    return 'Повторить ошибки · $count';
  }

  @override
  String get cmErrAbusive =>
      'В тексте есть оскорбительные или нецензурные слова. Пожалуйста, перепишите его уважительно — этого требуют правила сообщества.';

  @override
  String get admDeleteTitle => 'Удаление аккаунта';

  @override
  String get admDeleteNote =>
      'Для запросов на удаление, пришедших по email (выполняется в течение 30 дней). Для подтверждения введите полный email пользователя — сервер проверит, что он принадлежит именно этому аккаунту. Аккаунт, участие в группах, посты в сообществе, обращения и способы входа удаляются полностью; если пользователь входил через Apple, сервер попытается отозвать токен Apple. Отменить нельзя; действие записывается в журнал.';

  @override
  String get admDeleteEmail => 'Полный email пользователя';

  @override
  String get admDeleteButton => 'Удалить аккаунт навсегда';

  @override
  String get admDeleteConfirmTitle => 'Удалить аккаунт навсегда?';

  @override
  String admDeleteConfirmBody(String email) {
    return 'Аккаунт $email и все связанные с ним данные будут удалены. Это действие нельзя отменить.';
  }

  @override
  String get admDeleteDone => 'Аккаунт удалён';

  @override
  String get admDeleteMismatch =>
      'Этот email не принадлежит этому аккаунту — проверьте и введите снова.';

  @override
  String analyteSourcesBased(String sources) {
    return 'Основано на источниках: $sources';
  }

  @override
  String get sourcesPanelTitle => 'Источники';

  @override
  String get sourcesDisclaimer =>
      'Учебный справочник, не диагноз: результат оценивает врач с учётом клинических данных; референтные интервалы зависят от лаборатории и метода.';

  @override
  String get refBooksNote =>
      'Книги приведены только как источники — текст и рисунки не копировались. Заключение — за врачом.';

  @override
  String sourceLine(String cite) {
    return 'Источник: $cite';
  }

  @override
  String get packsCoreSources =>
      'Учебный справочник на основе источников — в каждой карточке список литературы';

  @override
  String get examPracticeNotice =>
      'Результат — для внутренней тренировки, это не официальная оценка.';

  @override
  String sourcesPanelMore(int count) {
    return '+ ещё $count — в списке ниже';
  }

  @override
  String get classesPasteLink => 'Вставить ссылку';

  @override
  String get classesPasteNoCode =>
      'В скопированном тексте нет кода приглашения. Скопируйте ссылку или код от преподавателя.';

  @override
  String get classesScanTip =>
      'Отсканируйте QR-код камерой телефона и нажмите «Открыть в приложении» на открывшейся странице — код подставится сам.';

  @override
  String get qrScanAction => 'Сканировать QR-код';

  @override
  String get qrScanHint =>
      'Наведите рамку на QR-код группы или теста от преподавателя';

  @override
  String get qrScanTorchOn => 'Включить фонарик';

  @override
  String get qrScanTorchOff => 'Выключить фонарик';

  @override
  String get qrScanTypeCode => 'Ввести или вставить код';

  @override
  String get qrScanNotInvite =>
      'Этот QR-код не является приглашением в группу LabGuide';

  @override
  String get qrScanDeniedTitle => 'Нет доступа к камере';

  @override
  String get qrScanDeniedBody =>
      'Чтобы прочитать QR-код, разрешите LabGuide доступ к камере в настройках. Кадр обрабатывается только на телефоне — изображение не сохраняется и не отправляется. Или введите код вручную либо вставьте ссылку.';

  @override
  String get qrScanOpenSettings => 'Открыть настройки';

  @override
  String get qrScanFailedTitle => 'Не удалось открыть камеру';

  @override
  String get qrScanFailedBody =>
      'Введите код вручную или вставьте ссылку от преподавателя.';

  @override
  String get qrScanStarting => 'Камера открывается…';

  @override
  String get classesJoinOpensTest =>
      'После вступления сразу откроется тест от преподавателя.';

  @override
  String get classesJoinSignInTitle => 'Войдите, чтобы вступить в группу';

  @override
  String get classesJoinSignInBody =>
      'Через Google, Apple или код на email — это минута. Результат попадёт к преподавателю через этот аккаунт; код приглашения сохранится.';

  @override
  String get classesNicknameTaken =>
      'Этот псевдоним в группе занят — выберите другой.';

  @override
  String get classesNicknameAbusive =>
      'В псевдониме недопустимое слово — выберите другой.';

  @override
  String get classesTestQr => 'QR теста';

  @override
  String get classesTestQrBody =>
      'Студенты сканируют → входят → псевдоним → открывается этот тест. Результаты на этой странице обновляются сами.';

  @override
  String get classesInviteLink => 'Скопировать ссылку';

  @override
  String get classesLiveNote =>
      'Результаты обновляются каждые 10 секунд. Потяните вниз — обновить сейчас.';

  @override
  String get boardOpen => 'Большой экран';

  @override
  String get boardJoined => 'В группе';

  @override
  String get boardStarted => 'Решают';

  @override
  String get boardSubmitted => 'Сдали';

  @override
  String get boardStatusWaiting => 'Ожидание';

  @override
  String get boardStatusSolving => 'Решает…';

  @override
  String get boardScan => 'Сканируйте и вступайте';

  @override
  String get boardAnswersAfterClose =>
      'Правильные ответы покажем после завершения теста.';

  @override
  String get boardEmpty => 'Пока никого — сканируйте QR.';

  @override
  String get boardClose => 'Выйти из большого экрана';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get variantToggle => 'Каждому студенту — свои вопросы';

  @override
  String variantOnBody(int pool, int n) {
    return 'Каждый студент получает $n из $pool вопросов темы — поровну по подтемам.';
  }

  @override
  String get variantOffBody =>
      'Всем одни и те же вопросы (в перемешанном порядке).';

  @override
  String variantDisabledBody(int pool, int need) {
    return 'В теме $pool вопросов — для разных наборов нужно не меньше $need (вдвое больше числа вопросов). Уменьшите число вопросов.';
  }

  @override
  String get variantUnsupported =>
      'Этот сервер не поддерживает вариантные тесты.';

  @override
  String variantPoolTitle(int pool) {
    return 'Пул вопросов ($pool)';
  }

  @override
  String get variantLabel => 'Вариантный тест';

  @override
  String variantPerStudent(int n, int pool) {
    return '$n вопросов каждому из пула в $pool';
  }

  @override
  String variantReceived(int n) {
    return 'Попался $n студентам';
  }

  @override
  String get homeResumeCta => 'Продолжить';

  @override
  String homeResumeBody(String title) {
    return 'Последнее открытое: $title';
  }

  @override
  String get homeHeroLabToifaCta => 'Занятие на сегодня';

  @override
  String get helpTitle => 'Помощь и связь';

  @override
  String get helpSub =>
      'В приложении или по email — вопрос, предложение, жалоба';

  @override
  String get helpIntro =>
      'Выберите удобный способ: переписка в приложении (ответ придёт сюда) или email (жалоба, запрос о конфиденциальности).';

  @override
  String get learnSectionQuizzesTitle => 'Тренировки по разделам';

  @override
  String learnSectionQuizRow(String section) {
    return '$section — тренировка';
  }

  @override
  String get classesNicknameInvalid =>
      'В псевдониме допустимы только буквы, цифры, пробел и . _ \' -; он должен начинаться и заканчиваться буквой или цифрой (без эмодзи и знаков вроде !?@).';

  @override
  String get classesGroupFull =>
      'Группа заполнена (200 человек) — сообщите преподавателю.';

  @override
  String get classesCodeAmbiguous =>
      'В коде нет символов 0, O, 1 и I. Уточните код у преподавателя или отсканируйте QR.';

  @override
  String get classesOwnGroupTitle => 'Вы преподаватель этой группы';

  @override
  String get classesOwnGroupBody =>
      'Этот аккаунт создал группу, поэтому не может вступить в неё как студент (смена роли в профиле этого не меняет). Чтобы проверить как студент, войдите с другим аккаунтом или пройдите тест в режиме студента.';

  @override
  String get classesOwnGroupOpen => 'Открыть как преподаватель';

  @override
  String get classesSwitchAccount => 'Войти с другим аккаунтом';

  @override
  String get classesPreviewAsStudent => 'Пройти как студент';

  @override
  String get classesPreviewNote =>
      'Пробный режим: ответы не отправляются на сервер и не попадают в результаты.';

  @override
  String classesPreviewResult(int correct, int total) {
    return 'Проба завершена: $correct / $total верно. Результат не отправлен.';
  }

  @override
  String get classesGiveTopicTest => 'Дать тест по теме';

  @override
  String get classesGiveTopicTestSub =>
      'Выберите тему — на следующей странице: число вопросов, варианты, срок и когда открыть ответы.';

  @override
  String get classesTopicSearchHint => 'Поиск темы (например, анемия)';

  @override
  String get classesTopicNoMatch => 'Нет темы с готовым тестом';

  @override
  String classesTopicQuestions(int count) {
    return 'Вопросов: $count';
  }

  @override
  String examDeadlineAt(String date) {
    return 'Срок: $date';
  }

  @override
  String get classesScanAskNick =>
      'Перед вступлением укажите псевдоним — под ним преподаватель увидит ваш результат (необязательно: без него — номер по порядку). Затем «Вступить».';

  @override
  String get classesMyNickname => 'Мой псевдоним';

  @override
  String get classesNoNickname => 'Нет — преподаватель видит ваш номер';

  @override
  String get classesNicknameSaved => 'Псевдоним сохранён';

  @override
  String get classesNicknameNote =>
      'Не пишите настоящее имя. Если оставить пустым — номер по порядку.';

  @override
  String get rolesTeacherRegisterNote =>
      '«Продолжить» зарегистрирует аккаунт как преподавателя: вы управляете только своими группами и видите их результаты (это не права администратора).';

  @override
  String get rolesTeacherSignInNote =>
      'Чтобы создать группу, войдите в аккаунт — регистрация преподавателя займёт одно нажатие при создании группы.';

  @override
  String get classesGiveGeneralTest => 'Дать общий тест';

  @override
  String get generalTestSub => 'Из нескольких тем — до 50 вопросов';

  @override
  String get generalTestIntro =>
      'Выберите темы — вопросы распределятся между ними поровну. Студенты сдают тест на своём телефоне, балл считает сервер.';

  @override
  String get generalTestSources => 'Откуда вопросы';

  @override
  String get generalTestSearchHint => 'Найти тему (например, анемия)';

  @override
  String get generalSourceToifa => 'Вопросы проверки знаний и компетенций';

  @override
  String get generalSourceToifaSub => 'Официальный список КДЛ, ключи проверены';

  @override
  String get generalSourceLecture => 'Темы лекций';

  @override
  String get generalSourceLectureSub => 'Весь модуль или отдельный день';

  @override
  String get generalSourcePack => 'По анализам';

  @override
  String get generalSourcePackSub => 'Вопросы карточек анализов';

  @override
  String get generalSourceToifaShort => 'Знания';

  @override
  String get generalSourceLectureShort => 'Лекции';

  @override
  String get generalSourcePackShort => 'Анализы';

  @override
  String get generalSelectAll => 'Выбрать все';

  @override
  String get generalAllShort => 'все';

  @override
  String generalDays(int count) {
    return 'Дни · $count';
  }

  @override
  String generalSelected(int topics, int questions) {
    return 'Выбрано тем: $topics · вопросов: $questions';
  }

  @override
  String get generalPickTopic => 'Выберите хотя бы одну тему';

  @override
  String generalTestTitle(String topics) {
    return 'Общий тест: $topics';
  }

  @override
  String get generalTestNameHint => 'Например, 1-й рубежный контроль';

  @override
  String get calSafeKind => 'Тип записи';

  @override
  String get calSafeKindTraining => 'Учебная';

  @override
  String get calSafeKindLab => 'Лабораторная';

  @override
  String get calSafeTrainingTag => 'Учебная';

  @override
  String get calSafeTrainingNote =>
      'Учебная запись: это не лабораторное свидетельство.';

  @override
  String get calSafeApprovedBy => 'Утвердил (имя / должность)';

  @override
  String get calSafeApprovedAt => 'Дата утверждения';

  @override
  String get calSafeApproverRequired =>
      'Для «Принята» укажите имя или должность уполномоченного лица.';

  @override
  String get calSafeQcAfter => 'КК после калибровки';

  @override
  String get calSafeQcPass => 'КК пройден';

  @override
  String get calSafeQcFail => 'КК не пройден';

  @override
  String get calSafeQcNotRun => 'КК не проводился';

  @override
  String get calSafeQcNotRunWarn => 'КК после калибровки не проводился';

  @override
  String get calSafeQcPassRequired =>
      '«Принята» возможна только при пройденном КК после калибровки.';

  @override
  String get calSafeSopRef => 'Ссылка на СОП (необязательно)';

  @override
  String get calSafeLegacyTag => 'Старая запись, не проверена';

  @override
  String get calSafeHistory => 'История';

  @override
  String get calSafeHistoryEmpty => 'Записей истории нет.';

  @override
  String get calSafeAuditCreated => 'Создано';

  @override
  String get calSafeAuditEdited => 'Изменено';

  @override
  String get calSafeAuditDeleted => 'Удалено';

  @override
  String get calSafeHistoryNote =>
      'История сохраняется и после удаления записи. Её стирает только «удалить локальные данные».';

  @override
  String get labDirSection => 'Направления лаборатории (справочник)';

  @override
  String get labDirSectionSub => 'Платформа и тест — в отдельных карточках';

  @override
  String labDirRowTitle(String name) {
    return '$name — справочные карточки';
  }

  @override
  String get labDirTb => 'Диагностика туберкулёза (ТБ)';

  @override
  String get labDirHiv => 'Лабораторная диагностика ВИЧ';

  @override
  String get labDirTag => 'Справочно';

  @override
  String get labDirNotVerified => 'Пока не добавлено';

  @override
  String get labDirKindPlatform => 'Платформа (прибор)';

  @override
  String get labDirKindTest => 'Тест';

  @override
  String get labDirKindMethod => 'Метод';

  @override
  String get labDirVsTest => 'Платформа и тест';

  @override
  String get labDirTechnology => 'Технология';

  @override
  String get labDirSpecimens => 'Образцы';

  @override
  String get labDirTasks => 'Задачи';

  @override
  String get labDirPrinciple => 'Принцип';

  @override
  String get labDirLimitations => 'Ограничения';

  @override
  String get labDirQc => 'Контроль качества и калибровка';

  @override
  String get labDirErrors => 'Преаналитические и аналитические ошибки';

  @override
  String get labDirBiosafety => 'Биобезопасность';

  @override
  String get labDirModels => 'Модели, подтверждённые официальным источником';

  @override
  String get labDirLinked => 'Связанные карточки';

  @override
  String get labDirStatusNeedsReview =>
      'Статус проверки: источники указаны ниже; заключение специалиста пока не внесено';

  @override
  String get labDirManufacturerNote =>
      'Страница производителя (рекламный материал), не инструкция';

  @override
  String get labDirVirology => 'Вирусология';

  @override
  String get labDirBacteriology => 'Бактериология';

  @override
  String get labDirMycology => 'Микология';

  @override
  String get labDirParasitology => 'Паразитология';

  @override
  String get labDirHematology => 'Гематология';

  @override
  String get labDirCoagulation => 'Коагулология (гемостаз)';

  @override
  String get labDirTransfusion => 'Трансфузиология';

  @override
  String get labDirBiochemistry => 'Клиническая биохимия';

  @override
  String get labDirImmunology => 'Иммунология';

  @override
  String get labDirUrinalysis => 'Анализ мочи';

  @override
  String get labDirCytology => 'Цитология';

  @override
  String get labDirHistology => 'Гистология';

  @override
  String get labDirOncology => 'Онкология';

  @override
  String get labDirGenetics => 'Генетика';

  @override
  String get labDirMolecular => 'Молекулярная диагностика';

  @override
  String get labDirToxicology => 'Токсикология';

  @override
  String get labDirReproductive => 'Репродуктивная медицина';

  @override
  String get labDirNeonatal => 'Неонатальная лабораторная диагностика';

  @override
  String get labDirTransplant => 'Трансплантология';

  @override
  String get labDirGeneral => 'Общая лаборатория';

  @override
  String get labDirDisclaimer =>
      'Только учебный справочник. Приложение не ставит диагноз и не является рабочим протоколом; решение за уполномоченной лабораторией и врачом.';

  @override
  String get labDirEmpty => 'В этом направлении нет карточек.';

  @override
  String get labDirPlatformClassNote =>
      'Справка по классу/технологии — для конкретной модели не подтверждено';

  @override
  String get labSchemGcMs =>
      'Класс приборов ГХ-МС — баллон с газом-носителем, газовый хроматограф с автосэмплером и капиллярной колонкой в термостате, ионный источник, квадрупольный масс-анализатор, детектор, вакуумные насосы и система обработки данных';

  @override
  String get labSchemLcMs =>
      'Класс приборов ЖХ-МС — ёмкости с растворителями, насос, автосэмплер, термостат колонки, источник ионизации электрораспылением, квадрупольный масс-анализатор, детектор, вакуумные насосы и система обработки данных';

  @override
  String get labSchemMaldiTof =>
      'Класс масс-спектрометров MALDI-TOF — мишень с пятнами образцов, лазер, ускоряющие сетки, времяпролётная труба, детектор, вакуумный насос и экран спектра';

  @override
  String get labSchemMicrobialIdAst =>
      'Класс автоматических систем идентификации микроорганизмов и определения чувствительности — кассета с пробирками суспензии и тест-картами, инкубатор-ридер с оптическим сканером, камера загрузки и монитор';

  @override
  String get labSchemBloodCulture =>
      'Класс автоматических систем гемокультур — шкаф-инкубатор с рядами флаконов (у каждого датчик на дне и индикатор) и монитор; рядом аэробный и анаэробный флаконы';

  @override
  String get labSchemMycobacterialCulture =>
      'Класс автоматических систем жидкой культуры микобактерий — инкубатор-ридер с ящиками пробирок и индикаторами, монитор; рядом пробирки с флуоресцентным кислородным датчиком на дне';

  @override
  String get labSchemFlowCytometer =>
      'Класс проточных цитометров — ёмкости обжимающей жидкости и отходов, гидродинамическая фокусировка, лазер, проточная ячейка, детектор прямого светорассеяния, детекторы бокового рассеяния и флуоресценции за дихроичными зеркалами, пробирка с образцом и экран точечной диаграммы';

  @override
  String get labSchemRealTimePcr =>
      'Класс амплификаторов для ПЦР в реальном времени — термоблок с лунками, нагреваемая крышка, оптический модуль с источником света, колесом фильтров и детектором, стрип пробирок и экран кривых амплификации';

  @override
  String get labSchemCartridgeMolecular =>
      'Класс закрытых картриджных молекулярных платформ — прибор с отдельными модулями (один открыт, внутри картридж), одноразовый многокамерный картридж, контейнер для образца и монитор';

  @override
  String get labSchemCoagAnalyzer =>
      'Класс автоматических коагулометров — охлаждаемые позиции реагентов, измерительные кюветы, пипетирующая рука, цитратные пробирки, оптическая детекция сгустка (источник света, кювета, фотодетектор) и экран кривой свёртывания';

  @override
  String get labSchemElisaReader =>
      'Класс ридеров и вошеров микропланшетов (ИФА) — ридер с выдвижным держателем и окрашенным 96-луночным планшетом, оптический путь через лунку к детектору, вошер с гребёнкой игл, ёмкости промывочного буфера и отходов';

  @override
  String get labSchemBscClass2 =>
      'Бокс биологической безопасности II класса, боковой разрез — воздух помещения входит через переднее окно в переднюю решётку, воздух после HEPA-фильтра опускается над рабочей поверхностью, по заднему каналу возвращается к вентилятору, часть выводится через второй HEPA-фильтр';

  @override
  String get labSchemAutoclave =>
      'Класс настольных паровых автоклавов — камера с лотком и упакованными изделиями, открытая дверца с уплотнителем, манометр и термометр, предохранительный клапан и резервуар для воды';

  @override
  String get labSchemBloodGasIse =>
      'Класс анализаторов газов крови и электролитов (ИСЭ) — дисплей, принтер, пробоотборник со шприцем для газов крови, сенсорная кассета с электродами вдоль измерительного канала и пакет реагентов';

  @override
  String get labSchemHba1cAnalyzer =>
      'Класс компактных анализаторов HbA1c — дисплей, клавиатура, принтер, штатив пробирок с цельной кровью на ЭДТА и пробоотборная рука, флаконы реагентов и ёмкость для отходов';

  @override
  String get labSchemLabFridge =>
      'Класс лабораторных холодильников-морозильников с мониторингом температуры — холодильник со стеклянной дверцей, штативами и реагентами, морозильная камера, датчик в буферном флаконе и цифровой регистратор данных снаружи';

  @override
  String get labSchemFluorescenceMicroscope =>
      'Класс светодиодных флуоресцентных микроскопов — прямой микроскоп с LED-модулем эпиосвещения и слайдером фильтров, объективы, столик с препаратом; во врезке яркие жёлто-зелёные палочки на тёмном фоне (так выглядят бациллы при окраске аурамином)';

  @override
  String get labSchemCasa =>
      'Класс систем компьютерного анализа спермы (CASA) — микроскоп с камерой и подогреваемым столиком, счётная камера, кабель к монитору с треками подвижных сперматозоидов';

  @override
  String get labSchemGelCardSystem =>
      'Класс систем гелевых (микроколоночных) карт — центрифуга для карт, инкубатор и увеличенная гелевая карта с шестью микропробирками: в положительных эритроциты остаются вверху или в толще геля, в отрицательных образуют осадок на дне';

  @override
  String get labSchemEsrAnalyzer =>
      'Класс СОЭ — штатив Вестергрена с вертикальными трубками (прозрачная плазма над осевшими эритроцитами) и автоматический анализатор с закрытыми пробирками и оптической считывающей линейкой';

  @override
  String get labSchemAggregometer =>
      'Класс агрегометров тромбоцитов и вязкоэластических анализаторов — агрегометр светопропускания с перемешиваемыми кюветами, источником света и фотодетектором, кривые агрегации; вязкоэластический анализатор с каналами «чашка — штифт» и кривой сгустка';

  @override
  String get labSchemElectrophoresis =>
      'Класс аппаратов для электрофореза — источник питания с проводами, камера с буферными отсеками, электродами, фитилями и носителем с окрашенными белковыми фракциями, поднятая крышка и денситометр с денситограммой';

  @override
  String get labSchemOsmometer =>
      'Класс криоскопических осмометров — охлаждающий блок с пробиркой, термисторный зонд в образце, проволока-мешалка, дисплей с кривой замерзания, клавиатура и маленькие пробирки';

  @override
  String get labSchemTlc =>
      'Оснащение для тонкослойной хроматографии — стеклянная камера с крышкой, растворителем и пластинкой (линия старта, разделённые пятна, фронт растворителя); УФ-лампа над проявленной пластинкой: пятна тёмные на флуоресцирующем фоне';

  @override
  String get labSchemAnalyticalBalance =>
      'Оснащение для гравиметрической калибровки — аналитические весы с ветрозащитой и сосудом для взвешивания, пипетка, дозирующая воду, стакан с водой и термометр';

  @override
  String get imgDiagramCalibrationOverviewAlt =>
      'Схема порядка калибровки: 1 модель, реагент и версия инструкции; 2 лот калибратора, значения — из листа значений этого лота; 3 подготовка согласно методике; 4 калибровка по инструкции. Решение: КК после калибровки пройден? Да — калибровка принята уполномоченным лицом; нет — не принята, поиск причины по IFU и СОП. Параметры — только из подходящей IFU.';

  @override
  String get imgDiagramDifferentialCountAlt =>
      'Схема ручного подсчёта лейкоцитарной формулы: 1 оцените мазок (ровный, без полос и «дыр»; плохой — переделать); 2 считайте в монослое с иммерсией ×100, в одном направлении, без повторов полей; 3 считайте до цели СОП, обычно 100 клеток; 4 процент каждого вида клеток, абсолютное число = доля × WBC. Решение: бласты или неопознанные клетки? Да — не интерпретируйте сами, мазок смотрит гематолог или врач; нет — сравните с референтным интервалом с бланка лаборатории.';

  @override
  String get imgDiagramQcDecisionAlt =>
      'Схема решения по серии КК: 1 измерьте контрольные материалы; 2 нанесите значения на карту Леви–Дженнингса относительно целевого среднего ± SD. Решение: нарушено правило отклонения (1-3s, 2-2s, R-4s, 4-1s, 10x)? Нет — серия принята (только 1-2s — предупреждение). Да — серия отклонена: остановить, результаты пациентов не выдавать; найдите причину, не повторяйте КК вслепую; устраните, повторите КК и пробы пациентов; выдача — после восстановления КК, меры записать.';

  @override
  String get imgDiagramPreanalyticsAlt =>
      'Схема преаналитического этапа в пять шагов: 1 подготовка к анализу (подготовка пациента); 2 выбор образца и добавки (пробирка по тесту, порядок взятия); 3 взятие и идентификация (ФИО совпадает с направлением); 4 разделение и хранение в пределах стабильности; 5 доставка и приём со сверкой этикеток и направлений. Решение: образец пригоден? Да — анализ; нет — по СОП лаборатории.';

  @override
  String get imgDiagramPhotometryAlt =>
      'Схема абсорбционной фотометрии: источник света, фильтр (длина волны λ), кювета с оптическим путём ℓ, детектор и результат. Падающий свет I0, прошедший свет I; поглощение (оптическая плотность) A = log10(I0/I); закон Бугера–Ламберта–Бера A = ε·ℓ·c. Измерьте бланк, стандарт и пробу; C = (A пробы ÷ A стандарта) × C стандарта. Выше границы линейности — развести, повторить и умножить на степень разведения. Длина волны, бланк и границы — по IFU реагента.';

  @override
  String get imgDiagramEducationalFeedbackAlt =>
      'Схема работы с результатами теста: 1 ответьте на вопросы; 2 посмотрите результат. Решение: есть ошибки? Нет — повторить или выбрать другую тему. Да — 3 разбор ошибок с правильным ответом и объяснением; 4 работа над ошибками только по вопросам с ошибкой, затем снова ответы. Порядок работы приложения, не лабораторная процедура.';

  @override
  String get imgDiagramCaption =>
      'Общая схема LabGuide. Приоритет — у IFU вашего прибора и СОП вашей лаборатории.';

  @override
  String get imgDiagramTapToZoom => 'Нажмите на схему, чтобы увеличить';

  @override
  String get stepUpTitle => 'Подтвердите, что это вы';

  @override
  String stepUpBodyEmail(String email) {
    return 'Для этого действия нужно повторное подтверждение. Введите 6-значный код, отправленный на $email.';
  }

  @override
  String get stepUpBodyEmailNoAddress =>
      'Для этого действия нужно повторное подтверждение. Введите 6-значный код из письма.';

  @override
  String get stepUpBodyTotp =>
      'Для этого действия нужно повторное подтверждение. Введите 6-значный код из приложения-аутентификатора.';

  @override
  String get stepUpConfirm => 'Подтвердить';

  @override
  String get stepUpCancelled =>
      'Не выполнено: для этого действия нужен новый код подтверждения.';

  @override
  String get admRevokeSessions => 'Завершить сеансы на всех устройствах';

  @override
  String get admRevokeSessionsBody =>
      'Пользователь выйдет на всех устройствах. Аккаунт останется активным, войти снова можно.';

  @override
  String admRevokeSessionsDone(int count) {
    return 'Завершено сеансов: $count.';
  }

  @override
  String get profileSignOutAll => 'Выйти на всех устройствах';

  @override
  String get profileSignOutAllBody =>
      'Вы выйдете из аккаунта на этом телефоне и на всех других устройствах. Данные на этом устройстве сохранятся.';

  @override
  String get profileSignOutAllDone => 'Выполнен выход на всех устройствах.';

  @override
  String get schemPartsPanelTitle => 'Узлы и принцип работы';

  @override
  String get schemPartsPanelHint =>
      'Узлы по номерам на рисунке, принцип и результат';

  @override
  String get schemPartsPartsTitle => 'Основные узлы';

  @override
  String get schemPartsPrincipleTitle => 'Принцип работы';

  @override
  String get schemPartsResultTitle => 'Результат';

  @override
  String get schemPartsClassNote =>
      'Узлы показаны для класса приборов на уровне принципа; в конкретной модели расположение и устройство могут отличаться.';

  @override
  String get schemPartsChemistrySamplesName => 'Позиции образцов';

  @override
  String get schemPartsChemistrySamplesFn =>
      'Пробирки стоят в штативе; зонд забирает образец отсюда.';

  @override
  String get schemPartsChemistryReagentsName =>
      'Охлаждаемая карусель реагентов';

  @override
  String get schemPartsChemistryReagentsFn =>
      'Флаконы реагентов хранятся охлаждёнными; нужный реагент подводится под зонд.';

  @override
  String get schemPartsChemistryProbesName => 'Зонды образца и реагента';

  @override
  String get schemPartsChemistryProbesFn =>
      'Забирают точные объёмы образца и реагента и вносят их в реакционную кювету.';

  @override
  String get schemPartsChemistryReactionName => 'Реакционная карусель (кюветы)';

  @override
  String get schemPartsChemistryReactionFn =>
      'Смесь в кюветах термостатируется при 37 °C; карусель проводит кюветы через фотометр.';

  @override
  String get schemPartsChemistryPhotometerName => 'Фотометр';

  @override
  String get schemPartsChemistryPhotometerFn =>
      'Свет лампы проходит через кювету; оптика с решёткой или фильтрами измеряет поглощение на выбранной длине волны.';

  @override
  String get schemPartsChemistryWaterName => 'Ёмкость очищенной воды';

  @override
  String get schemPartsChemistryWaterFn =>
      'Подаёт воду для промывки зондов и кювет и для разведения.';

  @override
  String get schemPartsChemistryWasteName => 'Ёмкость жидких отходов';

  @override
  String get schemPartsChemistryWasteFn =>
      'Сюда собираются промывная вода и отработанные реакционные смеси.';

  @override
  String get schemPartsChemistryComputerName => 'Компьютер и программа';

  @override
  String get schemPartsChemistryComputerFn =>
      'Назначает тесты, ведёт калибровку, рассчитывает результаты и выдаёт отчёт.';

  @override
  String get schemPartsChemistryPrinciple =>
      'Зонды вносят образец и реагент в реакционную кювету, смесь инкубируется при 37 °C. Фотометр измеряет поглощение света, прошедшего через кювету, на выбранной длине волны. Концентрацию рассчитывают по калибровке; во многих моделях Na, K, Cl измеряют ион-селективным электродом (ИСЭ).';

  @override
  String get schemPartsChemistryResult =>
      'Концентрация аналита по каждому тесту (например, глюкоза, активность ферментов, электролиты): значение, рассчитанное по изменению поглощения и калибровке, и отчёт.';

  @override
  String get schemPartsPhotometerDisplayName => 'Дисплей и клавиатура';

  @override
  String get schemPartsPhotometerDisplayFn =>
      'Выбор метода, длины волны и стандарта; здесь видны результат и кривая.';

  @override
  String get schemPartsPhotometerNeedleName => 'Аспирационная игла';

  @override
  String get schemPartsPhotometerNeedleFn =>
      'Засасывает готовую смесь из пробирки в измерительную кювету.';

  @override
  String get schemPartsPhotometerCellName =>
      'Измерительная ячейка (проточная кювета)';

  @override
  String get schemPartsPhotometerCellFn =>
      'Лампа → интерференционный фильтр → кювета → фотодетектор: здесь измеряется поглощение.';

  @override
  String get schemPartsPhotometerPrinterName => 'Термопринтер';

  @override
  String get schemPartsPhotometerPrinterFn => 'Печатает результаты на бумаге.';

  @override
  String get schemPartsPhotometerWasteName => 'Ёмкость для отходов';

  @override
  String get schemPartsPhotometerWasteFn =>
      'Сюда сливаются измеренная смесь и промывочная жидкость.';

  @override
  String get schemPartsPhotometerReagentsName => 'Флаконы реагентов';

  @override
  String get schemPartsPhotometerReagentsFn =>
      'Реагенты стоят вне прибора; оператор добавляет их к образцу вручную.';

  @override
  String get schemPartsPhotometerPrinciple =>
      'Оператор вручную дозирует образец и реагент и инкубирует смесь. Прибор засасывает её иглой в проточную кювету (или ставится квадратная кювета); свет лампы проходит через выбранный интерференционный фильтр, фотодетектор измеряет поглощение. Концентрацию рассчитывают по стандарту или фактору.';

  @override
  String get schemPartsPhotometerResult =>
      'Значение поглощения и рассчитанная по нему концентрация; результат выводится на дисплей и печатается.';

  @override
  String get schemPartsHematology5AutoloaderName => 'Автозагрузчик со штативом';

  @override
  String get schemPartsHematology5AutoloaderFn =>
      'Перемешивает закрытые пробирки и по очереди подаёт их к пробоотборнику.';

  @override
  String get schemPartsHematology5ProbeName => 'Пробоотборник (открытый режим)';

  @override
  String get schemPartsHematology5ProbeFn =>
      'Забирает заданный объём крови из открытой пробирки, поднесённой вручную.';

  @override
  String get schemPartsHematology5ImpedanceName => 'Импедансная камера';

  @override
  String get schemPartsHematology5ImpedanceFn =>
      'Каждый эритроцит и тромбоцит, проходя через апертуру, даёт электрический импульс: подсчёт и объём.';

  @override
  String get schemPartsHematology5LaserName => 'Проточная ячейка с лазером';

  @override
  String get schemPartsHematology5LaserFn =>
      'Лейкоциты по одному проходят через лазерный луч и классифицируются по рассеянию (и флуоресценции).';

  @override
  String get schemPartsHematology5DisplayName => 'Дисплей (скаттерграмма)';

  @override
  String get schemPartsHematology5DisplayFn =>
      'Показывает результаты, скаттерграммы и гистограммы.';

  @override
  String get schemPartsHematology5ReagentsName => 'Реагенты';

  @override
  String get schemPartsHematology5ReagentsFn =>
      'Разбавитель, лизирующие и красящие растворы подаются по шлангам.';

  @override
  String get schemPartsHematology5WasteName => 'Ёмкость для отходов';

  @override
  String get schemPartsHematology5WasteFn =>
      'Собирает отработанные разведения и промывочные растворы.';

  @override
  String get schemPartsHematology5Principle =>
      'Кровь аспирируется, разводится и распределяется по нескольким каналам. Эритроциты и тромбоциты считаются импедансным методом: при прохождении клетки через узкую апертуру возникает импульс сопротивления, его величина отражает объём клетки. Лейкоцитарная формула определяется методом проточной цитометрии по рассеянию лазерного луча (в ряде моделей с флуоресценцией красителя); гемоглобин измеряется фотометрически после лизиса эритроцитов.';

  @override
  String get schemPartsHematology5Result =>
      'Параметры общего анализа крови: количество клеток и эритроцитарные индексы, 5-частная лейкоцитарная формула, скаттерграммы и гистограммы.';

  @override
  String get schemPartsHematology3PrinterName => 'Термопринтер';

  @override
  String get schemPartsHematology3PrinterFn =>
      'Печатает результаты и гистограммы.';

  @override
  String get schemPartsHematology3DisplayName => 'Дисплей (3 гистограммы)';

  @override
  String get schemPartsHematology3DisplayFn =>
      'Показывает результаты и гистограммы WBC, RBC и PLT (формы на рисунке схематичны).';

  @override
  String get schemPartsHematology3ProbeName => 'Пробоотборник';

  @override
  String get schemPartsHematology3ProbeFn =>
      'Забирает малый объём крови из открытой пробирки.';

  @override
  String get schemPartsHematology3ImpedanceName => 'Импедансная камера';

  @override
  String get schemPartsHematology3ImpedanceFn =>
      'При прохождении клетки через апертуру возникает импульс: число импульсов — число клеток, амплитуда — объём.';

  @override
  String get schemPartsHematology3ReagentsName =>
      'Разбавитель и лизирующий раствор';

  @override
  String get schemPartsHematology3ReagentsFn =>
      'Для разведения крови и лизиса эритроцитов.';

  @override
  String get schemPartsHematology3WasteName => 'Ёмкость для отходов';

  @override
  String get schemPartsHematology3WasteFn =>
      'Сюда собираются отработанные жидкости.';

  @override
  String get schemPartsHematology3Principle =>
      'Кровь разводится; эритроциты и тромбоциты считаются импедансным методом (Коултера), строится гистограмма по объёму. Лейкоциты после лизиса делятся по объёму на три группы; гемоглобин измеряется фотометрически.';

  @override
  String get schemPartsHematology3Result =>
      'ОАК и 3-частная лейкоцитарная формула (лимфоциты, средние клетки, гранулоциты), три гистограммы (WBC, RBC, PLT).';

  @override
  String get schemPartsImmunoassaySamplesName => 'Штатив с образцами';

  @override
  String get schemPartsImmunoassaySamplesFn =>
      'Здесь стоят пробирки; зонд забирает образец.';

  @override
  String get schemPartsImmunoassayReagentsName =>
      'Охлаждаемые реагентные упаковки';

  @override
  String get schemPartsImmunoassayReagentsFn =>
      'Микрочастицы, меченый конъюгат и другие реагенты хранятся охлаждёнными.';

  @override
  String get schemPartsImmunoassayProbesName => 'Пипетирующие зонды';

  @override
  String get schemPartsImmunoassayProbesFn =>
      'Вносят образец и реагенты в реакционную кювету.';

  @override
  String get schemPartsImmunoassayCuvettesName => 'Бункер кювет';

  @override
  String get schemPartsImmunoassayCuvettesFn =>
      'Подаёт одноразовые реакционные кюветы в инкубатор.';

  @override
  String get schemPartsImmunoassayIncubatorName => 'Кольцо инкубатора';

  @override
  String get schemPartsImmunoassayIncubatorFn =>
      'Кюветы выдерживаются при постоянной температуре, идёт реакция антиген–антитело.';

  @override
  String get schemPartsImmunoassayWashName =>
      'Станция промывки (магнитная сепарация)';

  @override
  String get schemPartsImmunoassayWashFn =>
      'Магнит удерживает микрочастицы, несвязанные вещества отмываются.';

  @override
  String get schemPartsImmunoassayLuminometerName => 'Люминометр (детектор)';

  @override
  String get schemPartsImmunoassayLuminometerFn =>
      'Измеряет свет, испускаемый меткой, методом счёта фотонов.';

  @override
  String get schemPartsImmunoassaySolidwasteName => 'Ящик твёрдых отходов';

  @override
  String get schemPartsImmunoassaySolidwasteFn =>
      'Собираются использованные кюветы и наконечники.';

  @override
  String get schemPartsImmunoassayLiquidsName => 'Системные растворы';

  @override
  String get schemPartsImmunoassayLiquidsFn =>
      'Ёмкости с промывочным и системными растворами.';

  @override
  String get schemPartsImmunoassayPrinciple =>
      'Образец инкубируется с реагентом в кювете: аналит связывается с антителом или антигеном на магнитных микрочастицах. Пока магнит удерживает частицы, несвязанные вещества отмываются; затем метка (фермент, акридиниевый эфир или ЭХЛ-метка) испускает свет. Люминометр считает фотоны, сигнал переводится в концентрацию по калибровочной кривой.';

  @override
  String get schemPartsImmunoassayResult =>
      'Концентрация аналитов (гормоны, онкомаркеры, кардиомаркеры и др.) или качественный результат (положительно/отрицательно), рассчитанные по световому сигналу и калибровке.';

  @override
  String get schemPartsUrineStripSampleName => 'Проба мочи и тест-полоска';

  @override
  String get schemPartsUrineStripSampleFn =>
      'Полоску кратко погружают в мочу; зоны вступают в реакцию.';

  @override
  String get schemPartsUrineStripTrayName => 'Лоток для полосок (транспорт)';

  @override
  String get schemPartsUrineStripTrayFn =>
      'Полоску кладут сюда, и она подаётся под считывающую головку.';

  @override
  String get schemPartsUrineStripHeadName =>
      'Считывающая головка (светодиоды и фотосенсор)';

  @override
  String get schemPartsUrineStripHeadFn =>
      'Освещает зоны светом нескольких длин волн и измеряет отражённый свет.';

  @override
  String get schemPartsUrineStripDisplayName => 'Дисплей';

  @override
  String get schemPartsUrineStripDisplayFn =>
      'Показывает результаты и состояние прибора.';

  @override
  String get schemPartsUrineStripPrinterName => 'Принтер';

  @override
  String get schemPartsUrineStripPrinterFn => 'Печатает результаты.';

  @override
  String get schemPartsUrineStripBinName =>
      'Контейнер для использованных полосок';

  @override
  String get schemPartsUrineStripBinFn =>
      'Сюда сбрасываются прочитанные полоски.';

  @override
  String get schemPartsUrineStripPrinciple =>
      'Тест-полоску погружают в мочу; реагент каждой зоны даёт окраску со своим веществом. Прибор проводит полоску под считывающей головкой: светодиоды разных длин волн освещают зоны, фотосенсор измеряет отражённый свет (рефлектометрия). Интенсивность окраски переводится в полуколичественную градацию.';

  @override
  String get schemPartsUrineStripResult =>
      'Качественный или полуколичественный результат по каждой зоне (например, глюкоза, белок, кровь, лейкоциты, нитриты, pH, удельный вес) и печатный отчёт.';

  @override
  String get schemPartsUrineSystemTransportName => 'Транспортная линия';

  @override
  String get schemPartsUrineSystemTransportFn =>
      'Проводит штативы с пробирками мимо модулей по очереди.';

  @override
  String get schemPartsUrineSystemStripName =>
      'Химический модуль (тест-полоска)';

  @override
  String get schemPartsUrineSystemStripFn =>
      'Считывает зоны полоски рефлектометрически и по изображению.';

  @override
  String get schemPartsUrineSystemNeedlesName => 'Пробоотборные иглы';

  @override
  String get schemPartsUrineSystemNeedlesFn =>
      'Каждый модуль забирает пробу из пробирки своей иглой.';

  @override
  String get schemPartsUrineSystemCameraName =>
      'Модуль осадка (микроскоп и камера)';

  @override
  String get schemPartsUrineSystemCameraFn =>
      'Получает цифровые микроскопические изображения частиц мочи.';

  @override
  String get schemPartsUrineSystemDisplayName => 'Дисплей (изображения частиц)';

  @override
  String get schemPartsUrineSystemDisplayFn =>
      'Просмотр классифицированных изображений частиц и результатов.';

  @override
  String get schemPartsUrineSystemReagentsName =>
      'Реагент и промывочный раствор';

  @override
  String get schemPartsUrineSystemReagentsFn =>
      'Растворы для промывки модулей и измерения.';

  @override
  String get schemPartsUrineSystemWasteName => 'Ёмкость для отходов';

  @override
  String get schemPartsUrineSystemWasteFn => 'Собирает отработанные жидкости.';

  @override
  String get schemPartsUrineSystemPrinciple =>
      'Штативы с пробами по транспортной линии идут к двум модулям. Химический модуль считывает зоны тест-полоски рефлектометрически. Модуль осадка получает цифровые микроскопические изображения мочи; программа классифицирует частицы (эритроциты, лейкоциты, цилиндры, кристаллы и др.), изображения можно просмотреть на экране.';

  @override
  String get schemPartsUrineSystemResult =>
      'Результаты химического анализа полоской и количество или категории элементов осадка (эритроциты, лейкоциты, цилиндры, кристаллы, бактерии и др.) с изображениями для просмотра.';

  @override
  String get schemPartsMassSpecGcGasName => 'Баллон с газом-носителем';

  @override
  String get schemPartsMassSpecGcGasFn =>
      'Инертный газ (обычно гелий) переносит пробу по колонке.';

  @override
  String get schemPartsMassSpecGcAutosamplerName => 'Автосэмплер';

  @override
  String get schemPartsMassSpecGcAutosamplerFn =>
      'Отбирает пробу из флакона шприцем и вводит её в инжектор.';

  @override
  String get schemPartsMassSpecGcInjectorName => 'Инжектор (испаритель)';

  @override
  String get schemPartsMassSpecGcInjectorFn =>
      'Нагреваемый ввод: жидкая проба испаряется и попадает в поток газа.';

  @override
  String get schemPartsMassSpecGcColumnName =>
      'Термостат и капиллярная колонка';

  @override
  String get schemPartsMassSpecGcColumnFn =>
      'Нагревается по температурной программе; вещества разделяются в колонке.';

  @override
  String get schemPartsMassSpecGcTransferName => 'Обогреваемая линия переноса';

  @override
  String get schemPartsMassSpecGcTransferFn =>
      'Переносит разделённые вещества в масс-спектрометр без конденсации.';

  @override
  String get schemPartsMassSpecGcSourceName => 'Ионный источник';

  @override
  String get schemPartsMassSpecGcSourceFn =>
      'Ионизирует молекулы (в ГХ-МС чаще электронным ударом) с образованием фрагментов.';

  @override
  String get schemPartsMassSpecGcAnalyserName => 'Масс-анализатор (квадруполь)';

  @override
  String get schemPartsMassSpecGcAnalyserFn =>
      'Электрическое поле разделяет ионы по m/z и пропускает их по очереди.';

  @override
  String get schemPartsMassSpecGcDetectorName =>
      'Детектор (электронный умножитель)';

  @override
  String get schemPartsMassSpecGcDetectorFn =>
      'Превращает приходящие ионы в усиленный электрический сигнал.';

  @override
  String get schemPartsMassSpecGcVacuumName => 'Вакуумные насосы';

  @override
  String get schemPartsMassSpecGcVacuumFn =>
      'Турбомолекулярный и форвакуумный насосы создают высокий вакуум, чтобы ионы реже сталкивались с молекулами воздуха.';

  @override
  String get schemPartsMassSpecGcDataName => 'Система обработки данных';

  @override
  String get schemPartsMassSpecGcDataFn =>
      'Записывает хроматограммы и спектры, сравнивает с библиотекой.';

  @override
  String get schemPartsMassSpecGcPrinciple =>
      'Проба испаряется в инжекторе, газ-носитель (обычно гелий) переносит её в капиллярную колонку в термостате. Вещества выходят из колонки в разное время в зависимости от летучести и взаимодействия с колонкой (время удерживания). В масс-спектрометре они ионизируются, ионы разделяются по отношению массы к заряду (m/z) и регистрируются детектором.';

  @override
  String get schemPartsMassSpecGcResult =>
      'Хроматограмма (сигнал по времени удерживания) и масс-спектр каждого пика (m/z — относительная интенсивность); вещества идентифицируют сравнением с библиотекой спектров или стандартами.';

  @override
  String get schemPartsMassSpecLcSolventsName => 'Ёмкости подвижной фазы';

  @override
  String get schemPartsMassSpecLcSolventsFn =>
      'Растворители (например, вода и органический растворитель) подаются в насос.';

  @override
  String get schemPartsMassSpecLcPumpName => 'Насос высокого давления';

  @override
  String get schemPartsMassSpecLcPumpFn =>
      'Прокачивает растворители через колонку стабильным потоком.';

  @override
  String get schemPartsMassSpecLcAutosamplerName => 'Автосэмплер';

  @override
  String get schemPartsMassSpecLcAutosamplerFn =>
      'Отбирает пробу из флакона и вводит её в поток.';

  @override
  String get schemPartsMassSpecLcColumnName => 'Колонка (в термостате)';

  @override
  String get schemPartsMassSpecLcColumnFn =>
      'Вещества разделяются по взаимодействию с фазой колонки.';

  @override
  String get schemPartsMassSpecLcEsiName => 'Источник электрораспыления (ESI)';

  @override
  String get schemPartsMassSpecLcEsiFn =>
      'Распыляет элюат в заряженные капли, образуя ионы.';

  @override
  String get schemPartsMassSpecLcAnalyserName => 'Масс-анализатор (квадруполь)';

  @override
  String get schemPartsMassSpecLcAnalyserFn =>
      'Электрическое поле разделяет ионы по m/z и пропускает их по очереди.';

  @override
  String get schemPartsMassSpecLcDetectorName =>
      'Детектор (электронный умножитель)';

  @override
  String get schemPartsMassSpecLcDetectorFn =>
      'Превращает приходящие ионы в усиленный электрический сигнал.';

  @override
  String get schemPartsMassSpecLcVacuumName => 'Вакуумные насосы';

  @override
  String get schemPartsMassSpecLcVacuumFn =>
      'Поддерживают высокий вакуум в масс-анализаторе.';

  @override
  String get schemPartsMassSpecLcDataName => 'Система обработки данных';

  @override
  String get schemPartsMassSpecLcDataFn =>
      'Записывает хроматограммы и спектры, рассчитывает количество.';

  @override
  String get schemPartsMassSpecLcPrinciple =>
      'Насос под высоким давлением прокачивает жидкую подвижную фазу через колонку, автосэмплер вводит пробу в поток. Вещества разделяются в колонке и выходят в разное время. В источнике электрораспыления (ESI) жидкость распыляется в заряженные капли, вещества переходят в газофазные ионы; ионы разделяются по m/z и регистрируются детектором.';

  @override
  String get schemPartsMassSpecLcResult =>
      'Хроматограмма и масс-спектры; целевые вещества (лекарства, метаболиты, биомаркеры) идентифицируются, их концентрация рассчитывается по калибраторам.';

  @override
  String get schemPartsMaldiTofTargetName => 'Мишень';

  @override
  String get schemPartsMaldiTofTargetFn =>
      'Здесь пятна образца с матрицей; мишень вводится в вакуумную камеру.';

  @override
  String get schemPartsMaldiTofLaserName => 'Лазер';

  @override
  String get schemPartsMaldiTofLaserFn =>
      'Короткий импульс испаряет и ионизирует белки вместе с матрицей.';

  @override
  String get schemPartsMaldiTofGridsName => 'Ускоряющие электроды';

  @override
  String get schemPartsMaldiTofGridsFn =>
      'Высокое напряжение ускоряет ионы и направляет их во времяпролётную трубу.';

  @override
  String get schemPartsMaldiTofTubeName => 'Времяпролётная труба (TOF)';

  @override
  String get schemPartsMaldiTofTubeFn =>
      'Вакуумная труба: ионы летят с разной скоростью в зависимости от m/z.';

  @override
  String get schemPartsMaldiTofDetectorName => 'Детектор';

  @override
  String get schemPartsMaldiTofDetectorFn =>
      'Регистрирует время прихода каждого иона.';

  @override
  String get schemPartsMaldiTofVacuumName => 'Вакуумный насос';

  @override
  String get schemPartsMaldiTofVacuumFn =>
      'Создаёт вакуум в источнике и трубе.';

  @override
  String get schemPartsMaldiTofDatabaseName => 'Компьютер и база спектров';

  @override
  String get schemPartsMaldiTofDatabaseFn =>
      'Сравнивает спектр с эталонными и выдаёт оценку вероятности.';

  @override
  String get schemPartsMaldiTofPrinciple =>
      'Колонию наносят на мишень и покрывают матрицей, которая кристаллизуется. Импульс лазера испаряет и ионизирует белки (в основном рибосомальные). Электрическое поле ускоряет ионы; во времяпролётной трубе лёгкие ионы достигают детектора раньше тяжёлых — время пролёта отражает m/z. Спектр сравнивается с эталонными спектрами базы данных.';

  @override
  String get schemPartsMaldiTofResult =>
      'Масс-спектр (белковый «отпечаток») и название микроорганизма с оценкой вероятности (log score); результат интерпретируют вместе с другими клиническими и лабораторными данными.';

  @override
  String get schemPartsMicrobialIdAstCardName => 'Тест-карта (64 лунки)';

  @override
  String get schemPartsMicrobialIdAstCardFn =>
      'В лунках разведения антибиотиков (AST) или биохимические субстраты (ID).';

  @override
  String get schemPartsMicrobialIdAstSuspensionName => 'Пробирка с суспензией';

  @override
  String get schemPartsMicrobialIdAstSuspensionFn =>
      'Бактериальная суспензия стандартной плотности; соломинка карты опущена в неё.';

  @override
  String get schemPartsMicrobialIdAstFillingName => 'Камера заполнения';

  @override
  String get schemPartsMicrobialIdAstFillingFn =>
      'Вакуум затягивает суспензию через соломинку в лунки карты.';

  @override
  String get schemPartsMicrobialIdAstIncubatorName => 'Инкубатор';

  @override
  String get schemPartsMicrobialIdAstIncubatorFn =>
      'Карты выдерживаются при постоянной температуре между считываниями.';

  @override
  String get schemPartsMicrobialIdAstScannerName => 'Оптический сканер';

  @override
  String get schemPartsMicrobialIdAstScannerFn =>
      'Каждые 15 минут измеряет свет, прошедший через каждую лунку.';

  @override
  String get schemPartsMicrobialIdAstSoftwareName => 'Компьютер и программа';

  @override
  String get schemPartsMicrobialIdAstSoftwareFn =>
      'По кривым роста рассчитывает МПК и категорию интерпретации, выдаёт отчёт.';

  @override
  String get schemPartsMicrobialIdAstPrinciple =>
      'Из чистой культуры готовят суспензию стандартной плотности, карта заполняется ею через соломинку под вакуумом. В лунках AST-карты антибиотики в разных разведениях (миниатюрный автоматический вариант метода МПК). Оптический сканер каждые 15 минут измеряет свет, прошедший через лунки: рост ослабляет свет; программа рассчитывает МПК по динамике роста.';

  @override
  String get schemPartsMicrobialIdAstResult =>
      'Значение МПК и категория интерпретации для каждого антибиотика (например, чувствителен или устойчив); на карте идентификации — вид микроорганизма.';

  @override
  String get schemPartsBloodCultureVialsName => 'Флаконы для гемокультуры';

  @override
  String get schemPartsBloodCultureVialsFn =>
      'Аэробные и анаэробные флаконы с питательной средой; в них вносят кровь пациента.';

  @override
  String get schemPartsBloodCultureSensorName => 'Датчик CO₂ (на дне флакона)';

  @override
  String get schemPartsBloodCultureSensorFn =>
      'Краситель реагирует с CO₂ и меняет флуоресценцию.';

  @override
  String get schemPartsBloodCultureIncubatorName => 'Шкаф-инкубатор';

  @override
  String get schemPartsBloodCultureIncubatorFn =>
      'Флаконы находятся в ячейках при постоянной температуре.';

  @override
  String get schemPartsBloodCultureReaderName => 'Система считывания';

  @override
  String get schemPartsBloodCultureReaderFn =>
      'Источник света и детектор под каждой ячейкой измеряют датчик каждые десять минут.';

  @override
  String get schemPartsBloodCulturePositiveName =>
      'Индикатор положительного флакона';

  @override
  String get schemPartsBloodCulturePositiveFn =>
      'Указывает флакон, в котором обнаружен рост.';

  @override
  String get schemPartsBloodCultureSoftwareName => 'Компьютер и программа';

  @override
  String get schemPartsBloodCultureSoftwareFn =>
      'Показывает кривую роста и статус каждого флакона.';

  @override
  String get schemPartsBloodCulturePrinciple =>
      'Флаконы с кровью помещают в инкубатор. При росте микроорганизмов выделяется CO₂; краситель датчика на дне флакона реагирует с CO₂, флуоресценция растёт. Прибор считывает датчик каждые десять минут; алгоритм помечает флакон положительным по скорости образования CO₂ и его абсолютному приросту.';

  @override
  String get schemPartsBloodCultureResult =>
      'Статус каждого флакона: положительный (рост обнаружен) или отрицательный по окончании протокола, время до положительности и кривая роста. Положительный флакон передают на дальнейшее микробиологическое исследование.';

  @override
  String get schemPartsMycobacterialCultureTubeName => 'Пробирка MGIT';

  @override
  String get schemPartsMycobacterialCultureTubeFn =>
      'С жидкой средой 7H9 и ростовой добавкой (OADC); сюда засевают образец.';

  @override
  String get schemPartsMycobacterialCultureSensorName =>
      'Флуоресцентный датчик кислорода';

  @override
  String get schemPartsMycobacterialCultureSensorFn =>
      'При снижении кислорода ярко флуоресцирует в УФ-свете.';

  @override
  String get schemPartsMycobacterialCultureDrawerName =>
      'Ящик для пробирок (инкубация и считывание)';

  @override
  String get schemPartsMycobacterialCultureDrawerFn =>
      'В каждой ячейке пробирка инкубируется, флуоресценция регулярно измеряется.';

  @override
  String get schemPartsMycobacterialCultureLightsName => 'Индикаторы состояния';

  @override
  String get schemPartsMycobacterialCultureLightsFn =>
      'Указывают положительные или завершённые пробирки.';

  @override
  String get schemPartsMycobacterialCulturePanelName => 'Дисплей прибора';

  @override
  String get schemPartsMycobacterialCulturePanelFn =>
      'Показывает состояние ящиков и предупреждения.';

  @override
  String get schemPartsMycobacterialCultureSoftwareName =>
      'Компьютер (кривые GU)';

  @override
  String get schemPartsMycobacterialCultureSoftwareFn =>
      'Записывает рост и результаты ТЛЧ; сравниваются кривые контрольной и опытной пробирок.';

  @override
  String get schemPartsMycobacterialCulturePrinciple =>
      'В пробирке MGIT модифицированная жидкая среда Миддлбрука 7H9 и флуоресцентный датчик кислорода на дне. При росте микобактерий растворённый кислород расходуется, и датчик ярче флуоресцирует в УФ-свете. Прибор автоматически считывает каждую пробирку и записывает интенсивность в единицах роста (GU). При определении лекарственной чувствительности (ТЛЧ) GU пробирки с препаратом сравнивают с контрольной.';

  @override
  String get schemPartsMycobacterialCultureResult =>
      'Положительная или отрицательная культура и кривая GU; при ТЛЧ для препаратов первого ряда прибор даёт интерпретацию «чувствителен/устойчив», для второго ряда значения GU интерпретирует пользователь.';

  @override
  String get schemPartsFlowCytometerSheathName => 'Ёмкость обжимающей жидкости';

  @override
  String get schemPartsFlowCytometerSheathFn =>
      'Окружает поток пробы и сжимает его в тонкую центральную струю.';

  @override
  String get schemPartsFlowCytometerSampleName => 'Пробирка с образцом и зонд';

  @override
  String get schemPartsFlowCytometerSampleFn =>
      'Отсюда засасывается окрашенная суспензия клеток.';

  @override
  String get schemPartsFlowCytometerFlowcellName =>
      'Проточная ячейка (гидродинамическая фокусировка)';

  @override
  String get schemPartsFlowCytometerFlowcellFn =>
      'Клетки по одной проходят точку пересечения с лазерным лучом.';

  @override
  String get schemPartsFlowCytometerLaserName => 'Лазер';

  @override
  String get schemPartsFlowCytometerLaserFn =>
      'Освещает клетки и возбуждает флуорохромы.';

  @override
  String get schemPartsFlowCytometerFscName =>
      'Детектор прямого рассеяния (FSC)';

  @override
  String get schemPartsFlowCytometerFscFn =>
      'Измеряет рассеяние по ходу луча — оно зависит от размера клетки.';

  @override
  String get schemPartsFlowCytometerSscName =>
      'Детекторы бокового рассеяния и флуоресценции';

  @override
  String get schemPartsFlowCytometerSscFn =>
      'Свет, собранный сбоку от луча, разделяется по цвету дихроичными зеркалами и фильтрами на отдельные детекторы.';

  @override
  String get schemPartsFlowCytometerWasteName => 'Ёмкость для отходов';

  @override
  String get schemPartsFlowCytometerWasteFn =>
      'Собирает измеренную пробу и обжимающую жидкость.';

  @override
  String get schemPartsFlowCytometerComputerName =>
      'Компьютер (точечные диаграммы)';

  @override
  String get schemPartsFlowCytometerComputerFn =>
      'Строит точечные диаграммы; популяции выделяются гейтированием.';

  @override
  String get schemPartsFlowCytometerPrinciple =>
      'Клетки обычно окрашивают антителами, мечеными флуорохромами. Обжимающая жидкость гидродинамически фокусирует поток пробы и выстраивает клетки в ряд; каждая клетка пересекает лазерный луч. Прямое рассеяние (FSC) отражает размер клетки, боковое (SSC) — внутреннюю структуру, флуоресценция — метки; электроника оцифровывает сигналы.';

  @override
  String get schemPartsFlowCytometerResult =>
      'Точечные диаграммы и гистограммы; доля и число клеточных популяций (например, абсолютное число CD4+ T-клеток с калибровочными частицами).';

  @override
  String get schemPartsRealTimePcrTubesName => 'ПЦР-пробирки (стрип)';

  @override
  String get schemPartsRealTimePcrTubesFn =>
      'Реакционная смесь и образец; считываются через прозрачные крышки.';

  @override
  String get schemPartsRealTimePcrLidName => 'Нагреваемая крышка';

  @override
  String get schemPartsRealTimePcrLidFn =>
      'Предотвращает конденсацию на крышках пробирок.';

  @override
  String get schemPartsRealTimePcrBlockName => 'Термоблок (Пельтье)';

  @override
  String get schemPartsRealTimePcrBlockFn =>
      'Быстро меняет температуры денатурации, отжига праймеров и синтеза.';

  @override
  String get schemPartsRealTimePcrSourceName => 'Источник возбуждающего света';

  @override
  String get schemPartsRealTimePcrSourceFn =>
      'Даёт свет, возбуждающий краситель или зонд.';

  @override
  String get schemPartsRealTimePcrFiltersName => 'Колесо фильтров';

  @override
  String get schemPartsRealTimePcrFiltersFn =>
      'Выбирает фильтры возбуждения и эмиссии для каждого красителя (канала).';

  @override
  String get schemPartsRealTimePcrDetectorName => 'Детектор';

  @override
  String get schemPartsRealTimePcrDetectorFn =>
      'Измеряет флуоресценцию в каждом цикле.';

  @override
  String get schemPartsRealTimePcrSoftwareName =>
      'Программа (кривые амплификации)';

  @override
  String get schemPartsRealTimePcrSoftwareFn =>
      'Строит кривые, задаёт порог и рассчитывает Cq.';

  @override
  String get schemPartsRealTimePcrPrinciple =>
      'Термоблок в каждом цикле меняет температуру: нагрев разделяет цепи ДНК, при охлаждении присоединяются праймеры, термостабильная полимераза достраивает новые цепи — мишень примерно удваивается за цикл (РНК предварительно переводят в кДНК обратной транскриптазой). Оптический модуль в каждом цикле измеряет флуоресценцию интеркалирующего красителя или зонда; сигнал пропорционален накоплению ампликона.';

  @override
  String get schemPartsRealTimePcrResult =>
      'Кривые амплификации и для каждой пробы Cq (Ct) — цикл, на котором флуоресценция пересекает порог; чем ниже Cq, тем больше исходной мишени. В количественных тестах концентрацию рассчитывают по стандартам (например, вирусная нагрузка ВИЧ-1, копий/мл).';

  @override
  String get schemPartsCartridgeMolecularCartridgeName =>
      'Одноразовый картридж';

  @override
  String get schemPartsCartridgeMolecularCartridgeFn =>
      'Закрытый картридж с камерами для образца и реагентов; все этапы проходят внутри.';

  @override
  String get schemPartsCartridgeMolecularTubeName => 'Реакционная трубка';

  @override
  String get schemPartsCartridgeMolecularTubeFn =>
      'В этой части картриджа идут амплификация и флуоресцентная детекция.';

  @override
  String get schemPartsCartridgeMolecularSpecimenName =>
      'Контейнер для образца';

  @override
  String get schemPartsCartridgeMolecularSpecimenFn =>
      'Сюда собирают образец, например мокроту, и смешивают с реагентом.';

  @override
  String get schemPartsCartridgeMolecularModuleName => 'Модуль прибора';

  @override
  String get schemPartsCartridgeMolecularModuleFn =>
      'Сюда ставят картридж, он обрабатывается автоматически; модули работают независимо.';

  @override
  String get schemPartsCartridgeMolecularSoftwareName =>
      'Компьютер и программа';

  @override
  String get schemPartsCartridgeMolecularSoftwareFn =>
      'Управляет процессом и выдаёт интерпретированный результат.';

  @override
  String get schemPartsCartridgeMolecularPrinciple =>
      'Образец смешивают с реагентом и вносят в картридж, картридж ставят в модуль. Дальнейшие этапы автоматически проходят внутри закрытого картриджа: обработка образца, выделение нуклеиновой кислоты, амплификация (ПЦР в реальном времени) и детекция. Оператор не вскрывает картридж, что снижает риск загрязнения ампликонами.';

  @override
  String get schemPartsCartridgeMolecularResult =>
      'Для Xpert MTB/RIF: комплекс M. tuberculosis обнаружен или не обнаружен, устойчивость к рифампицину обнаружена или не обнаружена — менее чем за 2 часа.';

  @override
  String get schemPartsCoagAnalyzerSamplesName =>
      'Штатив с цитратными пробирками';

  @override
  String get schemPartsCoagAnalyzerSamplesFn =>
      'Пробирки с цитратом натрия (голубая крышка); отсюда забирается плазма.';

  @override
  String get schemPartsCoagAnalyzerReagentsName => 'Охлаждаемый блок реагентов';

  @override
  String get schemPartsCoagAnalyzerReagentsFn =>
      'Тромбопластин и другие реагенты хранятся охлаждёнными.';

  @override
  String get schemPartsCoagAnalyzerArmName => 'Пипетирующая рука';

  @override
  String get schemPartsCoagAnalyzerArmFn =>
      'Вносит плазму и реагент в кювету в точных объёмах.';

  @override
  String get schemPartsCoagAnalyzerCuvettesName => 'Измерительные кюветы';

  @override
  String get schemPartsCoagAnalyzerCuvettesFn =>
      'Плазма прогревается; после добавления реагента отслеживается образование сгустка.';

  @override
  String get schemPartsCoagAnalyzerLightName => 'Источник света';

  @override
  String get schemPartsCoagAnalyzerLightFn =>
      'Даёт свет, проходящий через кювету.';

  @override
  String get schemPartsCoagAnalyzerDetectorName => 'Фотодетектор';

  @override
  String get schemPartsCoagAnalyzerDetectorFn =>
      'Регистрирует изменение прошедшего света при образовании сгустка.';

  @override
  String get schemPartsCoagAnalyzerDisplayName =>
      'Дисплей (кривая свёртывания)';

  @override
  String get schemPartsCoagAnalyzerDisplayFn =>
      'Кривая свёртывания, время и рассчитанное МНО.';

  @override
  String get schemPartsCoagAnalyzerPrinciple =>
      'Зонд вносит цитратную плазму в кювету и прогревает её, затем добавляется реагент (для ПВ — тромбопластин: тканевый фактор, кальций и фосфолипиды). При образовании фибринового сгустка смесь мутнеет: оптический метод регистрирует изменение прошедшего света, механический — остановку движения. Время до этого момента — время свёртывания.';

  @override
  String get schemPartsCoagAnalyzerResult =>
      'Время свёртывания в секундах и кривая свёртывания; для ПВ рассчитывается МНО по ПВ пациента, среднему нормальному ПВ и МИЧ реагента.';

  @override
  String get schemPartsElisaReaderPlateName => '96-луночный микропланшет';

  @override
  String get schemPartsElisaReaderPlateFn =>
      'В лунках идут реакция и окраска; держатель вводит планшет в ридер.';

  @override
  String get schemPartsElisaReaderLampName => 'Источник света (лампа)';

  @override
  String get schemPartsElisaReaderLampFn =>
      'Даёт свет, проходящий через лунку.';

  @override
  String get schemPartsElisaReaderFilterName => 'Оптический фильтр';

  @override
  String get schemPartsElisaReaderFilterFn =>
      'Пропускает только нужную длину волны.';

  @override
  String get schemPartsElisaReaderWellName => 'Измеряемая лунка';

  @override
  String get schemPartsElisaReaderWellFn =>
      'Окрашенный раствор поглощает часть света.';

  @override
  String get schemPartsElisaReaderDetectorName => 'Фотодетектор';

  @override
  String get schemPartsElisaReaderDetectorFn =>
      'Измеряет прошедший свет; по нему рассчитывается поглощение.';

  @override
  String get schemPartsElisaReaderWasherName => 'Гребёнка игл вошера';

  @override
  String get schemPartsElisaReaderWasherFn =>
      'Наливает в лунки промывочный раствор и отсасывает его.';

  @override
  String get schemPartsElisaReaderBufferName => 'Ёмкость промывочного буфера';

  @override
  String get schemPartsElisaReaderBufferFn => 'Подаёт буфер в вошер.';

  @override
  String get schemPartsElisaReaderWasteName => 'Ёмкость для отходов';

  @override
  String get schemPartsElisaReaderWasteFn => 'Собирает отсосанную жидкость.';

  @override
  String get schemPartsElisaReaderPrinciple =>
      'В лунках планшета поэтапно идёт реакция антиген–антитело; между этапами вошер отмывает несвязанные вещества. В конце добавляют субстрат, и фермент даёт окраску. Ридер пропускает через каждую лунку свет выбранной длины волны и измеряет поглощение (оптическую плотность); неизвестные пробы рассчитывают по стандартной кривой.';

  @override
  String get schemPartsElisaReaderResult =>
      'Оптическая плотность (OD) каждой лунки; концентрация по стандартной кривой или качественный результат (положительно/отрицательно) относительно порогового значения (cut-off).';

  @override
  String get schemPartsBscClass2OpeningName =>
      'Переднее окно (входящий воздух)';

  @override
  String get schemPartsBscClass2OpeningFn =>
      'Сюда засасывается воздух помещения — защита оператора.';

  @override
  String get schemPartsBscClass2GrilleName => 'Передняя решётка';

  @override
  String get schemPartsBscClass2GrilleFn =>
      'Сюда уходят входящий воздух и воздух передней части рабочей зоны; её нельзя загораживать.';

  @override
  String get schemPartsBscClass2WorkzoneName => 'Рабочая зона и поверхность';

  @override
  String get schemPartsBscClass2WorkzoneFn =>
      'Здесь работают с образцами; сверху опускается чистый воздух.';

  @override
  String get schemPartsBscClass2DownflowName =>
      'HEPA-фильтр нисходящего потока';

  @override
  String get schemPartsBscClass2DownflowFn =>
      'Очищает от частиц воздух, поступающий в рабочую зону.';

  @override
  String get schemPartsBscClass2FanName => 'Вентилятор';

  @override
  String get schemPartsBscClass2FanFn => 'Перемещает воздух по каналам.';

  @override
  String get schemPartsBscClass2ExhaustName => 'Выходной HEPA-фильтр';

  @override
  String get schemPartsBscClass2ExhaustFn =>
      'Очищает удаляемый воздух — защита окружающей среды.';

  @override
  String get schemPartsBscClass2PlenumName => 'Задний воздушный канал';

  @override
  String get schemPartsBscClass2PlenumFn =>
      'Возвращает воздух от решётки к вентилятору.';

  @override
  String get schemPartsBscClass2SashName => 'Переднее стекло';

  @override
  String get schemPartsBscClass2SashFn =>
      'Защищает лицо оператора и задаёт высоту переднего проёма.';

  @override
  String get schemPartsBscClass2Principle =>
      'Вентилятор обеспечивает циркуляцию воздуха. Воздух помещения засасывается через переднее окно в переднюю решётку — защита оператора. Воздух после HEPA-фильтра опускается над рабочей поверхностью — защита материала. Избыток воздуха удаляется через выходной HEPA-фильтр — защита окружающей среды.';

  @override
  String get schemPartsBscClass2Result =>
      'Это не измерительный прибор: результат — безопасная рабочая среда (защита оператора, материала и окружающей среды). Эффективность подтверждают регулярной проверкой воздушных потоков и фильтров и сертификацией.';

  @override
  String get schemPartsAutoclaveChamberName => 'Камера под давлением';

  @override
  String get schemPartsAutoclaveChamberFn =>
      'Здесь загрузка выдерживается в насыщенном паре под давлением.';

  @override
  String get schemPartsAutoclaveDoorName => 'Дверца с уплотнителем и замком';

  @override
  String get schemPartsAutoclaveDoorFn =>
      'Герметично закрывает камеру; не открывается под давлением.';

  @override
  String get schemPartsAutoclaveTrayName => 'Лоток для загрузки';

  @override
  String get schemPartsAutoclaveTrayFn =>
      'Изделия укладывают так, чтобы пар свободно проходил.';

  @override
  String get schemPartsAutoclavePressureName => 'Манометр';

  @override
  String get schemPartsAutoclavePressureFn => 'Показывает давление в камере.';

  @override
  String get schemPartsAutoclaveThermometerName => 'Термометр';

  @override
  String get schemPartsAutoclaveThermometerFn =>
      'Показывает температуру в камере.';

  @override
  String get schemPartsAutoclaveValveName => 'Предохранительный клапан';

  @override
  String get schemPartsAutoclaveValveFn =>
      'Сбрасывает пар при превышении давления.';

  @override
  String get schemPartsAutoclaveWaterName => 'Резервуар для воды';

  @override
  String get schemPartsAutoclaveWaterFn =>
      'Сюда заливают воду для получения пара.';

  @override
  String get schemPartsAutoclavePrinciple =>
      'Воздух из камеры удаляется и замещается насыщенным паром. Давление повышает температуру кипения воды, поэтому пар достигает высоких температур, например 121 °C или 132 °C. Пар контактирует с изделиями и убивает микроорганизмы теплом; процесс определяют качество пара, давление, температура и время. Оставшийся воздух мешает контакту пара с загрузкой.';

  @override
  String get schemPartsAutoclaveResult =>
      'Стерилизованная загрузка и запись параметров цикла (время, температура, давление); эффективность проверяют химическими и биологическими индикаторами.';

  @override
  String get schemPartsBloodGasIseSyringeName =>
      'Образец в гепаринизированном шприце';

  @override
  String get schemPartsBloodGasIseSyringeFn =>
      'Артериальная или другая цельная кровь доставляется без пузырьков воздуха.';

  @override
  String get schemPartsBloodGasIseProbeName => 'Зонд ввода пробы';

  @override
  String get schemPartsBloodGasIseProbeFn =>
      'Засасывает кровь из шприца в измерительный канал.';

  @override
  String get schemPartsBloodGasIseSensorsName => 'Сенсоры (электроды)';

  @override
  String get schemPartsBloodGasIseSensorsFn =>
      'Отдельные электроды для pH, pCO₂, pO₂ и электролитов.';

  @override
  String get schemPartsBloodGasIseChannelName => 'Измерительный канал';

  @override
  String get schemPartsBloodGasIseChannelFn =>
      'Проба проходит над всеми сенсорами; канал термостатирован.';

  @override
  String get schemPartsBloodGasIsePackName => 'Пакет реагентов';

  @override
  String get schemPartsBloodGasIsePackFn =>
      'Калибровочные и промывочные растворы.';

  @override
  String get schemPartsBloodGasIseDisplayName => 'Дисплей';

  @override
  String get schemPartsBloodGasIseDisplayFn =>
      'Показывает измеренные и расчётные величины.';

  @override
  String get schemPartsBloodGasIsePrinterName => 'Принтер';

  @override
  String get schemPartsBloodGasIsePrinterFn => 'Печатает результаты.';

  @override
  String get schemPartsBloodGasIsePrinciple =>
      'Цельная кровь из гепаринизированного шприца через зонд засасывается в измерительный канал и проходит над сенсорами. pH и pCO₂ измеряются потенциометрически, pO₂ — амперометрически; Na, K, Cl и ионизированный Ca — ион-селективными электродами. sO₂ измеряется кооксиметрией или рассчитывается; общий CO₂, бикарбонат и избыток оснований (BE) рассчитываются из измеренных величин.';

  @override
  String get schemPartsBloodGasIseResult =>
      'pH, pCO₂, pO₂, sO₂, электролиты и метаболиты (глюкоза, лактат и др.), а также расчётные бикарбонат и BE — показатели кислотно-основного состояния и оксигенации.';

  @override
  String get schemPartsHba1cAnalyzerRackName => 'Штатив с пробирками ЭДТА';

  @override
  String get schemPartsHba1cAnalyzerRackFn =>
      'Пробирки с цельной кровью (фиолетовая крышка).';

  @override
  String get schemPartsHba1cAnalyzerArmName => 'Пробоотборная рука';

  @override
  String get schemPartsHba1cAnalyzerArmFn =>
      'Автоматически забирает кровь из пробирки и подаёт в измерительную систему.';

  @override
  String get schemPartsHba1cAnalyzerReagentsName => 'Флаконы реагентов';

  @override
  String get schemPartsHba1cAnalyzerReagentsFn =>
      'Реагенты или буферные растворы для метода анализатора.';

  @override
  String get schemPartsHba1cAnalyzerDisplayName => 'Дисплей';

  @override
  String get schemPartsHba1cAnalyzerDisplayFn =>
      'Показывает результат HbA1c и состояние работы.';

  @override
  String get schemPartsHba1cAnalyzerPrinterName => 'Принтер';

  @override
  String get schemPartsHba1cAnalyzerPrinterFn => 'Печатает результаты.';

  @override
  String get schemPartsHba1cAnalyzerWasteName => 'Ёмкость для отходов';

  @override
  String get schemPartsHba1cAnalyzerWasteFn =>
      'Собирает отработанные растворы и пробу.';

  @override
  String get schemPartsHba1cAnalyzerPrinciple =>
      'Анализатор автоматически отбирает цельную кровь с ЭДТА и измеряет долю HbA1c. Метод измерения зависит от анализатора: ионообменная хроматография, боронат-аффинная хроматография, иммуноанализ, ферментативный метод или капиллярный электрофорез — рисунок метод не показывает. HbA1c образуется при неферментативном присоединении глюкозы к N-концевому валину бета-цепи гемоглобина.';

  @override
  String get schemPartsHba1cAnalyzerResult =>
      'Результат HbA1c в единицах NGSP (%) и IFCC (ммоль/моль); он отражает контроль гликемии примерно за 2–3 месяца.';

  @override
  String get schemPartsLabFridgeControllerName =>
      'Панель управления (термостат)';

  @override
  String get schemPartsLabFridgeControllerFn =>
      'Поддерживает заданную температуру и показывает текущую.';

  @override
  String get schemPartsLabFridgeFridgeName => 'Холодильная камера';

  @override
  String get schemPartsLabFridgeFridgeFn =>
      'На полках хранятся образцы, реагенты и контрольные материалы.';

  @override
  String get schemPartsLabFridgeProbeName => 'Датчик в буферном флаконе';

  @override
  String get schemPartsLabFridgeProbeFn =>
      'Измеряет температуру продукта и сглаживает кратковременные колебания при открытии дверцы.';

  @override
  String get schemPartsLabFridgeLoggerName =>
      'Цифровой регистратор данных (DDL)';

  @override
  String get schemPartsLabFridgeLoggerFn =>
      'Регулярно записывает температуру и подаёт сигнал при отклонениях.';

  @override
  String get schemPartsLabFridgeFreezerName => 'Морозильная камера';

  @override
  String get schemPartsLabFridgeFreezerFn =>
      'Хранятся замороженные аликвоты (например, контрольного материала).';

  @override
  String get schemPartsLabFridgePrinciple =>
      'Холодильный агрегат поддерживает температуру в заданном диапазоне, ею управляет термостат. Датчик в буферном флаконе отражает температуру продукта (кратковременные колебания температуры воздуха сглаживаются). Цифровой регистратор данных (DDL) регулярно записывает температуру и подаёт сигнал при выходе за пределы; рекомендуется и резервное устройство контроля температуры.';

  @override
  String get schemPartsLabFridgeResult =>
      'Непрерывная запись температуры (мин./макс., отклонения и сигналы тревоги) — документ о правильном хранении образцов и реагентов.';

  @override
  String get schemPartsFluorescenceMicroscopeEyepiecesName => 'Окуляры';

  @override
  String get schemPartsFluorescenceMicroscopeEyepiecesFn =>
      'Для наблюдения изображения.';

  @override
  String get schemPartsFluorescenceMicroscopeLedName => 'LED-осветитель';

  @override
  String get schemPartsFluorescenceMicroscopeLedFn =>
      'Даёт возбуждающий свет вместо ртутной лампы.';

  @override
  String get schemPartsFluorescenceMicroscopeCubeName => 'Фильтровый куб';

  @override
  String get schemPartsFluorescenceMicroscopeCubeFn =>
      'Возбуждающий фильтр, дихроичное зеркало и эмиссионный фильтр разделяют свет.';

  @override
  String get schemPartsFluorescenceMicroscopeObjectiveName => 'Объектив';

  @override
  String get schemPartsFluorescenceMicroscopeObjectiveFn =>
      'Направляет свет на препарат и увеличивает изображение.';

  @override
  String get schemPartsFluorescenceMicroscopeStageName => 'Столик с препаратом';

  @override
  String get schemPartsFluorescenceMicroscopeStageFn =>
      'Сюда кладут мазок мокроты, окрашенный аурамином.';

  @override
  String get schemPartsFluorescenceMicroscopeFocusName => 'Винты фокусировки';

  @override
  String get schemPartsFluorescenceMicroscopeFocusFn => 'Настраивают резкость.';

  @override
  String get schemPartsFluorescenceMicroscopeFieldName => 'Поле зрения';

  @override
  String get schemPartsFluorescenceMicroscopeFieldFn =>
      'Ярко-жёлто-зелёные палочки на тёмном фоне — окрашенные бациллы.';

  @override
  String get schemPartsFluorescenceMicroscopePrinciple =>
      'Мазок окрашивают аурамином (флуорохромом); стенка микобактерий удерживает краситель. LED-осветитель направляет возбуждающий синий свет через фильтровый куб и объектив на препарат. Окрашенные бациллы испускают более длинноволновый (жёлто-зелёный) свет; эмиссионный фильтр задерживает возбуждающий свет, поэтому бациллы ярко светятся на тёмном фоне.';

  @override
  String get schemPartsFluorescenceMicroscopeResult =>
      'Заключение микроскопии: кислотоустойчивые бациллы (светящиеся палочки) обнаружены или не обнаружены, при обнаружении — полуколичественная градация.';

  @override
  String get schemPartsCasaCameraName => 'Цифровая камера';

  @override
  String get schemPartsCasaCameraFn =>
      'Записывает изображение микроскопа как последовательность кадров.';

  @override
  String get schemPartsCasaMicroscopeName => 'Микроскоп (объектив)';

  @override
  String get schemPartsCasaMicroscopeFn =>
      'Увеличивает сперматозоиды, обычно с фазовым контрастом.';

  @override
  String get schemPartsCasaStageName => 'Подогреваемый столик';

  @override
  String get schemPartsCasaStageFn =>
      'Поддерживает постоянную температуру пробы — подвижность зависит от температуры.';

  @override
  String get schemPartsCasaChamberName => 'Счётная камера';

  @override
  String get schemPartsCasaChamberFn =>
      'Камера заданной глубины даёт слой пробы одинаковой толщины.';

  @override
  String get schemPartsCasaSoftwareName => 'Компьютер и программа';

  @override
  String get schemPartsCasaSoftwareFn =>
      'Восстанавливает треки и рассчитывает кинематические показатели.';

  @override
  String get schemPartsCasaPrinciple =>
      'Пробу спермы вносят в счётную камеру на подогреваемом столике. Камера через микроскоп снимает последовательные кадры; программа находит головки, восстанавливает трек каждого подвижного сперматозоида и рассчитывает кинематику движения. Анализируют треки не менее 200 подвижных клеток.';

  @override
  String get schemPartsCasaResult =>
      'Кинематические показатели (например, криволинейная, прямолинейная и средняя скорость по траектории) и типы движения; по руководству ВОЗ процент подвижных может быть ненадёжным — частицы детрита можно принять за неподвижные клетки.';

  @override
  String get schemPartsGelCardSystemCentrifugeName => 'Центрифуга для карт';

  @override
  String get schemPartsGelCardSystemCentrifugeFn =>
      'Вращает карты с заданной скоростью и временем.';

  @override
  String get schemPartsGelCardSystemIncubatorName => 'Инкубатор';

  @override
  String get schemPartsGelCardSystemIncubatorFn =>
      'Инкубирует карты для антиглобулинового теста.';

  @override
  String get schemPartsGelCardSystemCardName => 'Гелевая карта';

  @override
  String get schemPartsGelCardSystemCardFn =>
      'Пластиковая карта: в каждой микропробирке гелевая или стеклянная матрица.';

  @override
  String get schemPartsGelCardSystemChamberName => 'Реакционная камера';

  @override
  String get schemPartsGelCardSystemChamberFn =>
      'Здесь смешиваются эритроциты и сыворотка (или реагент).';

  @override
  String get schemPartsGelCardSystemGelName => 'Гелевая колонка (матрица)';

  @override
  String get schemPartsGelCardSystemGelFn =>
      'Задерживает агглютинаты и пропускает отдельные эритроциты; может содержать антиглобулин или анти-A, анти-B.';

  @override
  String get schemPartsGelCardSystemPositiveName => 'Положительная реакция';

  @override
  String get schemPartsGelCardSystemPositiveFn =>
      'Эритроциты остаются на поверхности или в толще геля.';

  @override
  String get schemPartsGelCardSystemNegativeName => 'Отрицательная реакция';

  @override
  String get schemPartsGelCardSystemNegativeFn =>
      'Эритроциты образуют осадок на дне.';

  @override
  String get schemPartsGelCardSystemPrinciple =>
      'В верхнюю реакционную камеру микропробирки вносят суспензию эритроцитов и сыворотку (или реагент) и инкубируют. При центрифугировании эритроциты проходят в гелевую или стеклянную матрицу, сыворотка остаётся сверху. Агглютинаты (например, клетки, покрытые антителом и связанные антиглобулином) задерживаются в геле — положительно; неагглютинированные клетки опускаются на дно и образуют осадок — отрицательно. Для антиглобулинового теста отмывка не нужна.';

  @override
  String get schemPartsGelCardSystemResult =>
      'Реакция в каждой микропробирке: положительная (агглютинаты на поверхности или в толще геля, оценивается степень) или отрицательная (осадок на дне); по ним делают вывод о группе крови или о прямой антиглобулиновой пробе.';

  @override
  String get schemPartsEsrAnalyzerStandName => 'Штатив Вестергрена';

  @override
  String get schemPartsEsrAnalyzerStandFn =>
      'Удерживает трубки строго вертикально.';

  @override
  String get schemPartsEsrAnalyzerTubeName => 'Трубка Вестергрена';

  @override
  String get schemPartsEsrAnalyzerTubeFn =>
      'Градуированная стандартная трубка с внутренним диаметром 2,5 мм.';

  @override
  String get schemPartsEsrAnalyzerBoundaryName => 'Граница плазма–эритроциты';

  @override
  String get schemPartsEsrAnalyzerBoundaryFn =>
      'Через час расстояние до этой границы считывают в миллиметрах.';

  @override
  String get schemPartsEsrAnalyzerReaderName => 'Автоматический анализатор';

  @override
  String get schemPartsEsrAnalyzerReaderFn =>
      'Автоматически измеряет оседание в закрытых пробирках.';

  @override
  String get schemPartsEsrAnalyzerTubesName => 'Закрытые пробирки';

  @override
  String get schemPartsEsrAnalyzerTubesFn =>
      'Пробирка с образцом не вскрывается.';

  @override
  String get schemPartsEsrAnalyzerSensorsName => 'Оптические датчики';

  @override
  String get schemPartsEsrAnalyzerSensorsFn =>
      'Определяют границу плазмы и столба эритроцитов.';

  @override
  String get schemPartsEsrAnalyzerDisplayName => 'Дисплей';

  @override
  String get schemPartsEsrAnalyzerDisplayFn => 'Показывает результаты.';

  @override
  String get schemPartsEsrAnalyzerPrinciple =>
      'Кровь с антикоагулянтом оседает под действием силы тяжести в стандартной вертикальной трубке (Вестергрен, внутренний диаметр 2,5 мм) в течение часа; высоту столба прозрачной плазмы считывают в миллиметрах. При воспалении повышение белков усиливает образование «монетных столбиков», и оседание ускоряется. Автоматические анализаторы отслеживают границу плазма–эритроциты в закрытых пробирках оптическими датчиками.';

  @override
  String get schemPartsEsrAnalyzerResult =>
      'Значение СОЭ в мм/ч; неспецифический показатель, оценивается вместе с другими исследованиями.';

  @override
  String get schemPartsAggregometerChannelsName => 'Измерительные каналы LTA';

  @override
  String get schemPartsAggregometerChannelsFn =>
      'Кюветы прогреваются до 37 °C и перемешиваются.';

  @override
  String get schemPartsAggregometerLightName => 'Источник света';

  @override
  String get schemPartsAggregometerLightFn =>
      'Даёт свет, проходящий через кювету.';

  @override
  String get schemPartsAggregometerCuvetteName =>
      'Кювета (плазма и магнитная мешалка)';

  @override
  String get schemPartsAggregometerCuvetteFn =>
      'Богатая тромбоцитами плазма; сюда добавляют агонист.';

  @override
  String get schemPartsAggregometerPhotodetectorName => 'Фотодетектор';

  @override
  String get schemPartsAggregometerPhotodetectorFn =>
      'Измеряет рост светопропускания при агрегации.';

  @override
  String get schemPartsAggregometerCurvesName => 'Кривые агрегации';

  @override
  String get schemPartsAggregometerCurvesFn =>
      'Светопропускание во времени для каждого канала.';

  @override
  String get schemPartsAggregometerCupName => 'Чашка с кровью';

  @override
  String get schemPartsAggregometerCupFn =>
      'Здесь цитратная кровь свёртывается с кальцием и активатором.';

  @override
  String get schemPartsAggregometerPinName => 'Штифт и датчик кручения';

  @override
  String get schemPartsAggregometerPinFn =>
      'Фибрин связывает штифт с чашкой; регистрируется передаваемый момент.';

  @override
  String get schemPartsAggregometerTraceName => 'Вязкоэластическая кривая';

  @override
  String get schemPartsAggregometerTraceFn =>
      'График образования, прочности и лизиса сгустка.';

  @override
  String get schemPartsAggregometerPrinciple =>
      'LTA: богатая тромбоцитами плазма перемешивается в кювете при 37 °C. После добавления агониста тромбоциты агрегируют, плазма просветляется и светопропускание растёт — фотодетектор записывает кривую. TEG/ROTEM: цитратная кровь во вращающейся чашке свёртывается с кальцием и активатором; фибрин связывает штифт с чашкой, передаваемый крутящий момент записывается в виде кривой.';

  @override
  String get schemPartsAggregometerResult =>
      'LTA: кривая агрегации для каждого агониста (светопропускание во времени). TEG/ROTEM: вязкоэластическая кривая, отражающая образование и прочность сгустка и фибринолиз.';

  @override
  String get schemPartsElectrophoresisPowerName => 'Источник питания';

  @override
  String get schemPartsElectrophoresisPowerFn =>
      'Подаёт постоянное напряжение на электроды.';

  @override
  String get schemPartsElectrophoresisElectrodesName =>
      'Буферные отсеки и электроды';

  @override
  String get schemPartsElectrophoresisElectrodesFn =>
      'Буфер проводит ток; катод (−) и анод (+) создают электрическое поле.';

  @override
  String get schemPartsElectrophoresisWicksName => 'Фитили';

  @override
  String get schemPartsElectrophoresisWicksFn =>
      'Подводят буфер к носителю и замыкают электрическую цепь.';

  @override
  String get schemPartsElectrophoresisMediumName => 'Носитель и фракции';

  @override
  String get schemPartsElectrophoresisMediumFn =>
      'На агарозе или ацетате целлюлозы молекулы разделяются на зоны.';

  @override
  String get schemPartsElectrophoresisCoverName => 'Крышка';

  @override
  String get schemPartsElectrophoresisCoverFn =>
      'Уменьшает испарение и защищает от поражения током.';

  @override
  String get schemPartsElectrophoresisDensitometerName => 'Денситометр';

  @override
  String get schemPartsElectrophoresisDensitometerFn =>
      'Сканирует оптическую плотность окрашенных зон и строит денситограмму.';

  @override
  String get schemPartsElectrophoresisPrinciple =>
      'Пробу наносят на смоченный буфером носитель (агароза, ацетат целлюлозы или полиакриламид). Источник питания через электроды создаёт электрическое поле; заряженные молекулы движутся с разной скоростью в зависимости от заряда, размера и формы и разделяются на зоны. Затем зоны окрашивают и измеряют по оптической плотности на денситометре.';

  @override
  String get schemPartsElectrophoresisResult =>
      'Окрашенные фракции (например, для белков сыворотки — альбумин, альфа-1, альфа-2, бета, гамма) и денситограмма с относительной долей каждой фракции; образец сравнивают с контрольными.';

  @override
  String get schemPartsOsmometerTubesName => 'Пробирки с образцом';

  @override
  String get schemPartsOsmometerTubesFn => 'Малый объём мочи или сыворотки.';

  @override
  String get schemPartsOsmometerThermistorName => 'Термисторный зонд';

  @override
  String get schemPartsOsmometerThermistorFn =>
      'Погружается в пробу и точно измеряет температуру.';

  @override
  String get schemPartsOsmometerBathName => 'Охлаждающий блок (баня)';

  @override
  String get schemPartsOsmometerBathFn =>
      'Охлаждает пробу ниже точки замерзания.';

  @override
  String get schemPartsOsmometerWireName => 'Проволока-мешалка';

  @override
  String get schemPartsOsmometerWireFn =>
      'Вибрацией запускает кристаллизацию переохлаждённой пробы.';

  @override
  String get schemPartsOsmometerDisplayName => 'Дисплей (кривая замерзания)';

  @override
  String get schemPartsOsmometerDisplayFn =>
      'Кривая температуры и результат осмоляльности.';

  @override
  String get schemPartsOsmometerPrinciple =>
      'Проба в охлаждающем блоке переохлаждается ниже точки замерзания, затем вибрация проволоки-мешалки запускает кристаллизацию. Выделившаяся скрытая теплота поднимает температуру до точки замерзания, образуется плато; его измеряет термистор в схеме моста Уитстона. Растворённые частицы понижают точку замерзания: 1 моль вещества понижает её у воды примерно на 1,86 °C — отсюда рассчитывается осмоляльность.';

  @override
  String get schemPartsOsmometerResult =>
      'Осмоляльность мочи или сыворотки, мОсм/кг (ммоль/кг).';

  @override
  String get schemPartsTlcTankName => 'Камера для проявления (с крышкой)';

  @override
  String get schemPartsTlcTankFn =>
      'Закрытая стеклянная камера, насыщенная парами растворителя.';

  @override
  String get schemPartsTlcSolventName => 'Подвижная фаза (растворитель)';

  @override
  String get schemPartsTlcSolventFn =>
      'Поднимается по пластинке за счёт капиллярных сил.';

  @override
  String get schemPartsTlcPlateName => 'Пластинка ТСХ (силикагель GF254)';

  @override
  String get schemPartsTlcPlateFn =>
      'Тонкий слой силикагеля; флуоресцентный индикатор светится в УФ-свете.';

  @override
  String get schemPartsTlcOriginName => 'Линия старта';

  @override
  String get schemPartsTlcOriginFn =>
      'На неё наносят пятна образца и стандарта.';

  @override
  String get schemPartsTlcFrontName => 'Фронт растворителя';

  @override
  String get schemPartsTlcFrontFn =>
      'Линия, до которой дошёл растворитель; её отмечают для расчёта Rf.';

  @override
  String get schemPartsTlcCapillariesName => 'Капилляры';

  @override
  String get schemPartsTlcCapillariesFn =>
      'Для нанесения пробы маленьким пятном.';

  @override
  String get schemPartsTlcLampName => 'УФ-лампа (254 нм)';

  @override
  String get schemPartsTlcLampFn =>
      'Освещает пластинку и делает пятна видимыми.';

  @override
  String get schemPartsTlcSpotsName => 'Пятна в УФ-свете';

  @override
  String get schemPartsTlcSpotsFn =>
      'Вещества гасят флуоресценцию и видны тёмными пятнами на зелёном фоне.';

  @override
  String get schemPartsTlcPrinciple =>
      'Пятна пробы и стандарта наносят на линию старта, пластинку ставят в насыщенную камеру так, чтобы нижний край касался растворителя. Пока растворитель поднимается, вещества распределяются между силикагелем (неподвижная фаза) и растворителем (подвижная фаза) и проходят разное расстояние. Проявленную пластинку просматривают в УФ-свете 254 нм или опрыскивают реагентами-проявителями.';

  @override
  String get schemPartsTlcResult =>
      'Положение пятен и значения Rf (путь пятна / путь фронта растворителя); для идентификации вещества их сравнивают со стандартом.';

  @override
  String get schemPartsAnalyticalBalancePipetteName =>
      'Пипетка (воздушного вытеснения)';

  @override
  String get schemPartsAnalyticalBalancePipetteFn =>
      'Калибруемый дозатор: выдаёт заданный объём.';

  @override
  String get schemPartsAnalyticalBalanceVesselName => 'Сосуд для взвешивания';

  @override
  String get schemPartsAnalyticalBalanceVesselFn =>
      'Сюда поступает дозированная вода и взвешивается.';

  @override
  String get schemPartsAnalyticalBalancePanName => 'Чашка весов';

  @override
  String get schemPartsAnalyticalBalancePanFn => 'На ней измеряется масса.';

  @override
  String get schemPartsAnalyticalBalanceEnclosureName =>
      'Стеклянный ветрозащитный кожух';

  @override
  String get schemPartsAnalyticalBalanceEnclosureFn =>
      'Уменьшает влияние потоков воздуха и пыли на взвешивание.';

  @override
  String get schemPartsAnalyticalBalanceDisplayName => 'Дисплей и клавиши';

  @override
  String get schemPartsAnalyticalBalanceDisplayFn =>
      'Показывает массу; клавиша тары обнуляет массу сосуда.';

  @override
  String get schemPartsAnalyticalBalanceWaterName => 'Ёмкость с водой';

  @override
  String get schemPartsAnalyticalBalanceWaterFn =>
      'Чистая (дистиллированная) вода, уравновешенная по температуре с помещением.';

  @override
  String get schemPartsAnalyticalBalanceThermometerName => 'Термометр';

  @override
  String get schemPartsAnalyticalBalanceThermometerFn =>
      'Измеряет температуру воды для поправки на плотность.';

  @override
  String get schemPartsAnalyticalBalancePrinciple =>
      'Пипетка дозирует заданный объём воды в сосуд на весах, массу воды взвешивают. Массу переводят в объём с поправками на плотность воды (по температуре) и выталкивающую силу воздуха, поэтому регистрируют температуру воды и воздуха. Пипетку калибруют «на выливание».';

  @override
  String get schemPartsAnalyticalBalanceResult =>
      'Рассчитанный объём каждой дозы; сравнение с номинальным объёмом даёт оценку точности (систематической погрешности) и воспроизводимости.';

  @override
  String get howToButton => 'Как пользоваться?';

  @override
  String get howToStepsTitle => 'Шаги';

  @override
  String get howToResultTitle => 'Что вы получите';

  @override
  String get howToWatchVideo => 'Смотреть видео';

  @override
  String howToVideoMb(String mb) {
    return '$mb МБ';
  }

  @override
  String howToVideoNote(String duration) {
    return 'Запись экрана без звука, с субтитрами · $duration · откроется в браузере или видеоплеере';
  }

  @override
  String howToVideoStartsAt(String time) {
    return 'В видео этот раздел начинается с $time.';
  }

  @override
  String get howToVideoOffline =>
      'Для видео нужен интернет. Текстовая инструкция — здесь, она работает без интернета.';

  @override
  String get howToVideoUnavailable =>
      'Видео сейчас не открывается. Попробуйте позже — текстовая инструкция здесь.';

  @override
  String get howToCalibrationStep1 =>
      '«1. Прибор»: выберите модель из каталога или добавьте прибор, которого нет в списке.';

  @override
  String get howToCalibrationStep2 =>
      '«2. Аналит»: введите название анализа (например, глюкоза) и выберите его в списке.';

  @override
  String get howToCalibrationStep3 =>
      '«3. Реагент»: укажите производителя, номер REF и версию IFU.';

  @override
  String get howToCalibrationStep4 =>
      'Нажмите «Показать руководство» — приложение проверит соответствие и покажет подходящее руководство.';

  @override
  String get howToCalibrationStep5 =>
      '«Создать запись калибровки»: введите лот, значения и результат, затем сохраните запись.';

  @override
  String get howToCalibrationStep6 =>
      'Все записи — в «Журнале калибровок», хранятся только на этом устройстве.';

  @override
  String get howToCalibrationResult =>
      'Руководство по калибровке под ваш прибор, аналит и реагент и журнал калибровок на устройстве.';

  @override
  String get howToQcStep1 =>
      '«Добавить тест»: введите название теста, единицы и уровни контроля.';

  @override
  String get howToQcStep2 =>
      'Для каждого уровня введите целевое среднее и SD — приложение не придумывает их само.';

  @override
  String get howToQcStep3 =>
      'После каждой серии введите результаты контроля и нажмите «Сохранить серию».';

  @override
  String get howToQcStep4 =>
      'Смотрите график Леви–Дженнингса и вывод по правилам Вестгарда: в пределах, предупреждение или отклонено.';

  @override
  String get howToQcStep5 =>
      '«Памятки»: что делать при отклонении QC, внешний контроль качества (EQA) и критические значения.';

  @override
  String get howToQcStep6 =>
      'Резервная копия: данные можно скопировать текстом и затем восстановить.';

  @override
  String get howToQcResult =>
      'График Леви–Дженнингса по каждому уровню и вывод по Вестгарду для каждой серии — на этом устройстве.';

  @override
  String get howToPreanalyticsStep1 =>
      'Вверху — 5 этапов: от подготовки к анализу до транспортировки и приёма.';

  @override
  String get howToPreanalyticsStep2 =>
      'Подготовка пациента: натощак, лекарства, нагрузка — каждый пункт со ссылкой на источник.';

  @override
  String get howToPreanalyticsStep3 =>
      'Порядок пробирок: какую пробирку заполнять за какой при венепункции (с цветом крышки).';

  @override
  String get howToPreanalyticsStep4 =>
      'Ниже: условия разделения, хранения, транспортировки и приёма.';

  @override
  String get howToPreanalyticsStep5 =>
      'Сверяйте каждый пункт с СОП вашей лаборатории.';

  @override
  String get howToPreanalyticsResult =>
      'Правила до и после взятия образца — с источниками, на одной странице.';

  @override
  String get howToCalculatorsStep1 =>
      'Выберите калькулятор: клинические формулы, ручные методы или лабораторные.';

  @override
  String get howToCalculatorsStep2 => 'Введите значения и проверьте единицы.';

  @override
  String get howToCalculatorsStep3 =>
      'При необходимости выберите параметр (например, пол) и нажмите «Рассчитать».';

  @override
  String get howToCalculatorsStep4 =>
      'Прочитайте пояснение и источники под результатом: ограничения формулы — там.';

  @override
  String get howToCalculatorsResult =>
      'Результат, рассчитанный только по введённым вами значениям, — с формулой и источником.';

  @override
  String get howToInstrumentsStep1 =>
      'Выберите направление: биохимия, гематология, иммунохимия или анализ мочи.';

  @override
  String get howToInstrumentsStep2 =>
      'Выберите производителя и модель или введите название модели в поиск.';

  @override
  String get howToInstrumentsStep3 =>
      'Карточка модели: «Сохранить как „Мой прибор“», затем переход к калибровке или QC.';

  @override
  String get howToInstrumentsStep4 =>
      '«Направления лаборатории (справочник)»: карточки по туберкулёзу, ВИЧ, бактериологии и другим направлениям.';

  @override
  String get howToInstrumentsStep5 =>
      'Схема в карточке — общее изображение класса приборов, а не конкретная модель.';

  @override
  String get howToInstrumentsResult =>
      'Справочные карточки по приборам и направлениям, схемы и быстрый переход к калибровке/QC.';

  @override
  String get howToMicroscopyStep1 =>
      'Выберите раздел: осадок мочи, мазок периферической крови или паразиты крови (малярия).';

  @override
  String get howToMicroscopyStep2 =>
      'Нажмите на снимок: в карточке — признаки, автор и лицензия.';

  @override
  String get howToMicroscopyStep3 =>
      'Введите название в поиск (например, оксалат или нейтрофил).';

  @override
  String get howToMicroscopyStep4 =>
      '«Начать тренировку»: выберите верное название из 4 вариантов — ответ виден сразу.';

  @override
  String get howToMicroscopyStep5 =>
      'В конце раунда — результат; ошибки можно повторить.';

  @override
  String get howToMicroscopyResult =>
      'Атлас лицензированных микрофотографий и тренировка по снимкам для самопроверки.';

  @override
  String get howToCoprologyStep1 =>
      '«Сбор пробы»: контейнер, сроки, несколько проб, консервант.';

  @override
  String get howToCoprologyStep2 =>
      '«Макроскопическое исследование»: форма, цвет, реакция, примеси.';

  @override
  String get howToCoprologyStep3 =>
      '«Микроскопия копрограммы»: карточка каждого элемента (мышечные волокна, жир, крахмал и др.).';

  @override
  String get howToCoprologyStep4 =>
      '«Скрытая кровь»: FIT и гваяковый тест, подготовка, результат.';

  @override
  String get howToCoprologyStep5 =>
      '«Кишечные паразиты»: методы обогащения, ключ яиц и цист (схема).';

  @override
  String get howToCoprologyStep6 =>
      'Ниже — практические протоколы (презентации) и карточки анализов.';

  @override
  String get howToCoprologyResult =>
      'Справочник по копрологии от сбора пробы до результата — с источниками; это не диагноз.';

  @override
  String get howToAssessmentStep1 =>
      'Выберите свою категорию (3–2, первая или высшая) и задайте дневную цель.';

  @override
  String get howToAssessmentStep2 =>
      '«Тест знаний»: тест из случайных вопросов официального перечня.';

  @override
  String get howToAssessmentStep3 =>
      '«Практика по темам»: ключ и пояснение сразу после ответа.';

  @override
  String get howToAssessmentStep4 =>
      '«Устный билет»: возьмите билет, подготовьтесь, посмотрите план ответа и оцените себя.';

  @override
  String get howToAssessmentStep5 =>
      '«Работа над ошибками» и «Прогресс»: повторяйте ошибки и следите за результатами по темам.';

  @override
  String get howToAssessmentStep6 =>
      'Раздел для Узбекистана: на узбекском языке или Профиль → «Проверка знаний и компетенций» → «Узбекистан».';

  @override
  String get howToAssessmentResult =>
      'Практика по вопросам официального перечня, ваши результаты и разбор ошибок — для самопроверки знаний.';

  @override
  String get howToDifferentialStep1 =>
      '«Как узнать клетку»: размер, ядро, цитоплазма и гранулы каждой клетки.';

  @override
  String get howToDifferentialStep2 =>
      '«Начать подсчёт»: нажатие +1, долгое нажатие −1; 100 или 200 клеток.';

  @override
  String get howToDifferentialStep3 =>
      'После подсчёта сохраните результат в историю — «Сохранённые результаты», только на этом устройстве.';

  @override
  String get howToDifferentialStep4 =>
      '«Лейкоформула: абсолютные числа»: абсолютные значения из WBC и процентов.';

  @override
  String get howToDifferentialStep5 =>
      'Закрепите знания: «Интерпретация» и «Тренажёр «Что это за клетка?»».';

  @override
  String get howToDifferentialResult =>
      'Лейкоформула в процентах, результаты на устройстве, справка по интерпретации и тренировка.';

  @override
  String get howToCytologyStep1 =>
      '«Знакомство с клетками»: рисунок и главный признак каждого элемента.';

  @override
  String get howToCytologyStep2 =>
      '«Степень чистоты влагалищного мазка»: отметьте увиденное — приложение покажет степень.';

  @override
  String get howToCytologyStep3 =>
      '«Классификация Bethesda»: что означает заключение ПАП-теста.';

  @override
  String get howToCytologyStep4 =>
      'Качество образца, реактивные изменения и индекс созревания — на отдельных страницах.';

  @override
  String get howToCytologyStep5 =>
      '«Что это за клетка?»: тренировка по рисункам.';

  @override
  String get howToCytologyResult =>
      'Учебный справочник по гинекологическому мазку, степень чистоты и тренировка; не диагноз.';

  @override
  String get howToSpermogramStep1 =>
      '«Основные показатели»: нижние референтные пределы ВОЗ 2021.';

  @override
  String get howToSpermogramStep2 =>
      '«Счётчик»: подсчёт подвижности и морфологии.';

  @override
  String get howToSpermogramStep3 =>
      '«Оценка результата»: введите значения — они сравниваются с пределами ВОЗ.';

  @override
  String get howToSpermogramStep4 =>
      '«Термины» и «Преаналитика»: олиго-, астено-, терато-; воздержание, сбор, доставка.';

  @override
  String get howToSpermogramStep5 =>
      '«Тренировка»: проверьте знания на вопросах.';

  @override
  String get howToSpermogramResult =>
      'Результат в сравнении с пределами ВОЗ 2021, термины и тренировка — учебный справочник.';

  @override
  String get howToBloodGroupStep1 =>
      '«Основы AB0 и RhD»: антигены, антитела, прямой и обратный метод.';

  @override
  String get howToBloodGroupStep2 =>
      '«Методы» и «Совместимость»: плоскость, пробирка, гелевая карта; пробы на совместимость.';

  @override
  String get howToBloodGroupStep3 =>
      '«Расхождения и ошибки»: расхождение прямой и обратной реакции, слабый D.';

  @override
  String get howToBloodGroupStep4 =>
      '«Чтение картины реакций»: отметьте результаты — приложение покажет учебную интерпретацию.';

  @override
  String get howToBloodGroupStep5 =>
      '«Тренировка»; решения по трансфузии — только по местному протоколу.';

  @override
  String get howToBloodGroupResult =>
      'Учебный справочник по AB0 и RhD и учебная интерпретация картины реакций.';

  @override
  String get howToHistologyStep1 =>
      '«Ткани и органы»: эпителий, соединительная, мышечная, нервная; печень, почка.';

  @override
  String get howToHistologyStep2 =>
      'Откройте снимок: настоящая микрофотография, главный признак и на что смотреть.';

  @override
  String get howToHistologyStep3 =>
      '«Методы окраски»: H&E, Массон, эластик, серебро, PAS, LFB.';

  @override
  String get howToHistologyStep4 =>
      '«Какая это ткань?»: тренировка по снимкам.';

  @override
  String get howToHistologyStep5 =>
      '«Авторы снимков»: автор и лицензия каждого снимка.';

  @override
  String get howToHistologyResult =>
      'Атлас тканей с лицензированными микрофотографиями, методы окраски и тренировка.';

  @override
  String get howToUrinalysisStep1 =>
      '«Сбор и хранение пробы»: утренняя, средняя порция, сроки, охлаждение.';

  @override
  String get howToUrinalysisStep2 =>
      '«Физические свойства»: цвет, прозрачность, запах, плотность.';

  @override
  String get howToUrinalysisStep3 =>
      '«Тест-полоска (химическое исследование)»: 10 зон — значение, помехи, подтверждение.';

  @override
  String get howToUrinalysisStep4 =>
      '«Микроскопия осадка»: клетки, цилиндры, кристаллы, микроорганизмы.';

  @override
  String get howToUrinalysisStep5 =>
      '«Чтение результата» и «Тренировка: что это?» — проверьте себя.';

  @override
  String get howToUrinalysisResult =>
      'Пошаговый справочник по анализу мочи, помощник чтения результата и тренировка.';

  @override
  String get howToBloodMorphStep1 =>
      '«Нормальный эритроцит и на что смотреть»: размер, цвет, форма, включения.';

  @override
  String get howToBloodMorphStep2 =>
      '«Изменения эритроцитов»: карточки со снимками — что видно и на что указывает.';

  @override
  String get howToBloodMorphStep3 =>
      '«Тромбоциты» и «Ретикулоциты»: принцип подсчёта и артефакты.';

  @override
  String get howToBloodMorphStep4 =>
      '«Помощник классификации анемии»: Hb, MCV, RDW → морфологическая группа.';

  @override
  String get howToBloodMorphStep5 =>
      '«Тренировка: что это за изменение?» — вопросы по снимкам и знаниям.';

  @override
  String get howToBloodMorphResult =>
      'Справочник по мазку периферической крови со снимками, помощник по анемии и тренировка.';

  @override
  String get howToCoagulogramStep1 =>
      '«Что измеряет каждый тест»: ПВ/МНО, АЧТВ, тромбиновое время, фибриноген, D-димер.';

  @override
  String get howToCoagulogramStep2 =>
      '«Требования к пробе»: цитрат 3,2 %, соотношение 9:1, время, преаналитические ошибки.';

  @override
  String get howToCoagulogramStep3 =>
      '«Помощник чтения результата»: ПВ, АЧТВ и тромбоциты → вероятные причины по источнику.';

  @override
  String get howToCoagulogramStep4 =>
      '«Балл явного ДВС ISTH»: введите значения — балл будет рассчитан.';

  @override
  String get howToCoagulogramStep5 =>
      '«Мониторинг антикоагулянтов»: варфарин — МНО, гепарин — АЧТВ/анти-Xa.';

  @override
  String get howToCoagulogramResult =>
      'Справочник по тестам гемостаза, помощник чтения результата и балл ДВС — с источниками.';
}
