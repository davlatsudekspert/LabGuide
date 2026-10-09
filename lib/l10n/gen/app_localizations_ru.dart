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
  String get micNotice =>
      'Место для изображения. Настоящие микрофотографии добавляются только после проверки прав и подписей.';

  @override
  String get micRedCells => 'Эритроциты';

  @override
  String get micWhiteCells => 'Лейкоциты';

  @override
  String get micEpithelium => 'Эпителий';

  @override
  String get micCasts => 'Цилиндры';

  @override
  String get micCrystals => 'Кристаллы';

  @override
  String get micItemSub => 'Вид · различия · ограничения';

  @override
  String get micImagePending => 'Права на изображение проверяются';

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
  String get libBooksSub => 'PDF · язык · версия · размер';

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
  String get quizTopicMistakes => 'Работа над ошибками';

  @override
  String quizMastered(int correct, int total) {
    return 'верно в прошлый раз: $correct из $total';
  }

  @override
  String get examTitle => 'Режим экзамена';

  @override
  String get examBody =>
      'Экзамены с таймером и история результатов появятся вместе с учебным модулем. Учебные вопросы доступны уже сейчас.';

  @override
  String get examOpenPractice => 'Открыть учебные вопросы';

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
  String get purchaseFree => 'Free: демо и базовые карточки.';

  @override
  String get purchasePro =>
      'Pro, помесячно или на год: полные опубликованные пакеты, расширенное обучение и лабораторные инструменты.';

  @override
  String get purchaseNotice =>
      'Товары магазина не подключены. Цены будут получены из App Store / Google Play в вашей валюте. Здесь ничего не списывается, а неготовые функции не продаются.';

  @override
  String get purchaseSubscribe => 'Оформить подписку';

  @override
  String get purchaseRestore => 'Восстановить покупки';

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
}
