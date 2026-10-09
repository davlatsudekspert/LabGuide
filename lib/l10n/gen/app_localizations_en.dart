// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'BIOCHEMISTRY · LABORATORY';

  @override
  String get navHome => 'Home';

  @override
  String get navTests => 'Tests';

  @override
  String get navLab => 'Lab';

  @override
  String get navLibrary => 'Library';

  @override
  String get navLearn => 'Learn';

  @override
  String get actionBack => 'Back';

  @override
  String get actionProfile => 'Profile and settings';

  @override
  String get actionLanguage => 'Language';

  @override
  String get actionOpen => 'Explore';

  @override
  String get actionRetry => 'Try again';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionCopyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String plannedStage(String stage) {
    return 'Planned for stage $stage';
  }

  @override
  String get notAvailableYet => 'Not available yet';

  @override
  String get debugBuildBadge => 'DEBUG · DEMO ADAPTERS';

  @override
  String get welcomeEyebrow => 'Your laboratory companion';

  @override
  String get welcomeTitle => 'Biochemistry.\nClear and practical.';

  @override
  String get welcomeSubtitle =>
      'Tests, laboratory practice and learning in one place.';

  @override
  String get welcomeDevices => 'Phone and tablet';

  @override
  String get welcomeRoles => 'Physician · lab professional · student · teacher';

  @override
  String get welcomeGetStarted => 'Get started / sign up';

  @override
  String get welcomeGuest => 'Explore as guest';

  @override
  String get welcomeSignIn => 'Sign in';

  @override
  String get welcomeGuestNote =>
      'No account is needed to read content. Sign-in is used for sync, classes and purchases.';

  @override
  String get authTitle => 'Welcome';

  @override
  String get authSubtitle => 'Sign in or create an account with email.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authEmailInvalid => 'Enter a valid email address.';

  @override
  String get authConsent => 'I accept the terms of use and privacy policy.';

  @override
  String get authConsentRequired => 'Accept the terms to continue.';

  @override
  String get authGetCode => 'Get code';

  @override
  String get authViewTerms => 'View terms';

  @override
  String get authDemoNotice =>
      'Debug build: demo sign-in. No email is sent; the code is shown on the next screen.';

  @override
  String get authUnavailableTitle => 'Email sign-in isn\'t connected yet';

  @override
  String get authUnavailableBody =>
      'All reading content is available to guests. Sign-in will be enabled once the email service is configured.';

  @override
  String get authContinueGuest => 'Continue as guest';

  @override
  String authRateLimited(int seconds) {
    return 'Too many requests. Try again in $seconds s.';
  }

  @override
  String get authGenericError =>
      'Something went wrong. Check the connection and try again.';

  @override
  String get otpTitle => 'Verify your email';

  @override
  String get otpCodeLabel => '6-digit code';

  @override
  String get otpVerify => 'Verify';

  @override
  String otpDemoCode(String code) {
    return 'Demo code: $code. No email was sent (debug build only).';
  }

  @override
  String otpInvalid(int attempts) {
    return 'Incorrect code. Attempts left: $attempts.';
  }

  @override
  String get otpExpired => 'The code has expired. Request a new one.';

  @override
  String get otpTooManyAttempts => 'Too many attempts. Request a new code.';

  @override
  String get otpNoActiveCode => 'No active code. Request a new one.';

  @override
  String get otpFormat => 'Enter the 6-digit code.';

  @override
  String get otpResend => 'Resend code';

  @override
  String otpResendIn(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String otpValidFor(int minutes) {
    return 'The code is valid for $minutes min.';
  }

  @override
  String get otpResent => 'A new code was issued.';

  @override
  String get rolesTitle => 'Your workspace';

  @override
  String get rolesSubtitle => 'Choose your main role. You can change it later.';

  @override
  String get rolesNote =>
      'The role only adapts the home screen. It doesn\'t grant access to other people\'s classes or data.';

  @override
  String get roleDoctor => 'Physician';

  @override
  String get roleDoctorDesc => 'Results and clinical context';

  @override
  String get roleLab => 'Laboratory professional';

  @override
  String get roleLabDesc => 'Methods, instruments and QC';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleStudentDesc => 'Learn, practice and prepare';

  @override
  String get roleTeacher => 'Teacher / researcher';

  @override
  String get roleTeacherDesc => 'Classes, assignments and research';

  @override
  String get homeTitle => 'Knowledge. Precision. Practice.';

  @override
  String get homeFocusTag => 'Your focus';

  @override
  String get homeHeroDoctorTitle => 'Understand the result in context';

  @override
  String get homeHeroDoctorBody =>
      'Tests, influencing factors and related investigations.';

  @override
  String get homeHeroDoctorCta => 'Explore tests';

  @override
  String get condGuideTitle => 'Tests by condition';

  @override
  String get condGuideEyebrow => 'Clinician’s guide';

  @override
  String get condGuideBody =>
      'For each condition: which tests come first, which follow — and what a result may point to.';

  @override
  String get condGuideSearch => 'Search a condition or test…';

  @override
  String get condGuideAll => 'All conditions';

  @override
  String condCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conditions',
      one: '$count condition',
    );
    return '$_temp0';
  }

  @override
  String condSystemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count body systems',
      one: '$count body system',
    );
    return '$_temp0';
  }

  @override
  String get condListSubtitle =>
      'Which tests for which condition — and what results may point to';

  @override
  String get condSearchLabel => 'Search conditions';

  @override
  String get condSearchHint => 'Diabetes, anemia, thyroid, TSH…';

  @override
  String get condEmptyTitle => 'No conditions found';

  @override
  String get condEmptyBody =>
      'Try another name, a common name or a test name (for example, “high cholesterol”).';

  @override
  String get condTierFirstLine => 'First-line';

  @override
  String get condTierAdditional => 'Additional';

  @override
  String get condTierMonitoring => 'Monitoring';

  @override
  String get condTierFirstLineHint =>
      'Ordered first when the condition is suspected';

  @override
  String get condTierAdditionalHint =>
      'To clarify, find the cause or tell conditions apart';

  @override
  String get condTierMonitoringHint => 'After diagnosis or during treatment';

  @override
  String get condPatternsTitle => 'Result patterns';

  @override
  String get condPatternsHint =>
      '“If you see this — this may be likely.” Interpretations are probabilistic: the clinician draws the final conclusion with the clinical picture.';

  @override
  String get condNotDiagnosticTitle => 'Not a diagnostic tool';

  @override
  String get condNotDiagnosticBody =>
      'The guide helps plan testing. Clinical assessment and the final decision rest with the clinician. The text is a sourced draft awaiting independent expert review.';

  @override
  String get condCautionsTitle => 'Keep in mind';

  @override
  String get condNoCard => 'No card yet';

  @override
  String get condCopyList => 'Copy test list';

  @override
  String get condCopyListSub => 'Ready text for a referral or message';

  @override
  String get condCopied => 'List copied';

  @override
  String condReferralTitle(String name) {
    return '$name — tests';
  }

  @override
  String get condReferralFooter =>
      'LabGuide guide (draft). Not a diagnostic tool — the final decision rests with the clinician.';

  @override
  String get condAnalyteSection => 'Conditions where it is ordered';

  @override
  String get condTestsEntrySub =>
      'Pick a condition — the tests and result patterns';

  @override
  String get condSearchSection => 'Conditions';

  @override
  String condRowFirstLine(String tests) {
    return 'First: $tests';
  }

  @override
  String get condSysEndocrine => 'Endocrine system';

  @override
  String get condSysKidney => 'Kidney and urinary tract';

  @override
  String get condSysLiver => 'Liver and bile ducts';

  @override
  String get condSysDigestive => 'Pancreas and bowel';

  @override
  String get condSysCardio => 'Heart and blood vessels';

  @override
  String get condSysBlood => 'Blood and clotting';

  @override
  String get condSysInfection => 'Infections';

  @override
  String get condSysRheumatology => 'Rheumatology';

  @override
  String get condSysBone => 'Bone and calcium';

  @override
  String get condSysPregnancy => 'Pregnancy and reproductive health';

  @override
  String get condSysProstate => 'Prostate';

  @override
  String get homeHeroLabTitle => 'Confidence at the bench';

  @override
  String get homeHeroLabBody =>
      'Samples, methods and quality control in one place.';

  @override
  String get homeHeroLabCta => 'Open quality control';

  @override
  String get homeHeroStudentTitle => 'Learn biochemistry with understanding';

  @override
  String get homeHeroStudentBody => 'Topic → explanation → practice → review.';

  @override
  String get homeHeroStudentCta => 'Start learning';

  @override
  String get homeHeroTeacherTitle => 'Turn knowledge into teaching';

  @override
  String get homeHeroTeacherBody =>
      'Classes, explained questions and assignments with deadlines.';

  @override
  String get homeHeroTeacherCta => 'Open classes';

  @override
  String get homeQuickAccess => 'Quick access';

  @override
  String get homeUsefulTests => 'Useful tests';

  @override
  String get featureTests => 'Tests';

  @override
  String get featureCalculators => 'Calculators';

  @override
  String get featureSampleFactors => 'Sample factors';

  @override
  String get featureSaved => 'Saved';

  @override
  String get featureCalibration => 'Calibration';

  @override
  String get featureQc => 'QC';

  @override
  String get featureSampling => 'Sampling';

  @override
  String get featureTopics => 'Topics';

  @override
  String get featureQuiz => 'Quiz';

  @override
  String get featureMicroscopy => 'Microscopy';

  @override
  String get featureExam => 'Exam';

  @override
  String get featureClasses => 'Classes';

  @override
  String get featureQuestionBank => 'Questions';

  @override
  String get featureSources => 'Sources';

  @override
  String get featureResearch => 'Research';

  @override
  String get testsTitle => 'Test atlas';

  @override
  String get testsSubtitle => 'From a marker to practical knowledge.';

  @override
  String get testsSearchLabel => 'Search tests';

  @override
  String get testsSearchHint => 'ALT, creatinine, HbA1c…';

  @override
  String get testsFilterAll => 'All';

  @override
  String get testsEmptyTitle => 'No results';

  @override
  String get testsEmptyBody => 'Try another name, abbreviation or synonym.';

  @override
  String get testsClearSearch => 'Clear search';

  @override
  String testsResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tests',
      one: '$count test',
    );
    return '$_temp0';
  }

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusPublished => 'Published';

  @override
  String get statusSourcedSample => 'Sourced sample';

  @override
  String get statusStructureOnly => 'Structure only';

  @override
  String get contentLoading => 'Loading content…';

  @override
  String get contentErrorTitle => 'Content couldn\'t be loaded';

  @override
  String get contentErrorBody =>
      'The content pack failed verification. Unverified data is never shown.';

  @override
  String get analyteSave => 'Save';

  @override
  String get analyteSaved => 'Saved';

  @override
  String get analyteSavedToast => 'Added to saved';

  @override
  String get analyteRemovedToast => 'Removed from saved';

  @override
  String get analyteNotFound => 'This test card wasn\'t found.';

  @override
  String get analyteStructureOnlyTitle => 'Content in preparation';

  @override
  String get analyteStructureOnlyBody =>
      'This card shows the structure only. Clinical text is added after sourcing and independent expert review — generic text is never shown as ready.';

  @override
  String get analyteSampleNotice =>
      'Learning sample based on the cited sources. Independent expert review is pending — not for clinical decisions.';

  @override
  String get analyteNotWritten =>
      'Not written yet: requires sources and review.';

  @override
  String get analyteAtAGlance => 'At a glance';

  @override
  String get analyteSpecimen => 'Specimen';

  @override
  String get analytePopulation => 'Population';

  @override
  String get analyteMethod => 'Method';

  @override
  String get analyteMethodNotSet =>
      'Not specified — depends on the reagent IFU';

  @override
  String get analyteUnits => 'Units';

  @override
  String get analyteRefIntervals => 'Reference intervals';

  @override
  String get analyteRefIntervalNone =>
      'No reference interval is given here. Use the interval on your laboratory\'s report: it depends on the method, specimen and population.';

  @override
  String get analyteDecisionLimits => 'Diagnostic thresholds';

  @override
  String get analyteDecisionNotRef =>
      'Diagnostic thresholds are not laboratory reference intervals.';

  @override
  String analyteSiNote(String unit, String mass) {
    return '$unit values are not given by the source — they are converted from the source’s mg/dL thresholds using the molar mass ($mass g/mol) and rounded. The source’s mg/dL value is the threshold.';
  }

  @override
  String analyteSiApprox(String value) {
    return '$value (converted)';
  }

  @override
  String get analyteNoInterpretation =>
      'LabGuide doesn\'t interpret individual results or suggest diagnoses or doses.';

  @override
  String get analyteSources => 'Sources';

  @override
  String analyteSourceAccessed(String date) {
    return 'Accessed $date';
  }

  @override
  String get analyteReuseRightsVerify =>
      'Reuse rights: verify before distribution';

  @override
  String get analyteReview => 'Review status';

  @override
  String get analyteReviewPending => 'Expert review pending';

  @override
  String get analyteReviewApproved => 'Reviewed';

  @override
  String get analyteReviewerNotAssigned => 'Reviewer not assigned';

  @override
  String get analyteTranslationPending => 'Translation review pending';

  @override
  String analyteContentVersion(String version) {
    return 'Content version $version';
  }

  @override
  String get analyteConvertUnits => 'Convert units';

  @override
  String get analyteConvertUnitsSub => 'Analyte-specific factor';

  @override
  String get analyteMethodCalibration => 'Method and calibration';

  @override
  String get analyteMethodCalibrationSub => 'IFU · QC';

  @override
  String get analyteCalculatorSub => 'Calculator · published formula';

  @override
  String get analytePractice => 'Practice the topic';

  @override
  String get analytePracticeSub => 'Explained questions';

  @override
  String get analyteRelated => 'Related tests';

  @override
  String get sectionPurpose => 'Purpose';

  @override
  String get sectionPhysiology => 'Physiology';

  @override
  String get sectionHighResult => 'High result';

  @override
  String get sectionLowResult => 'Low result';

  @override
  String get sectionPositiveResult => 'Positive result';

  @override
  String get sectionNegativeResult => 'Negative result';

  @override
  String get sectionResults => 'What the results mean';

  @override
  String get sectionPreanalytics => 'Specimen and preanalytics';

  @override
  String get sectionInterference => 'Interference';

  @override
  String get sectionLimitations => 'Limitations';

  @override
  String get labTitle => 'Laboratory';

  @override
  String get labSubtitle => 'A clear path at every stage.';

  @override
  String get labHeroEyebrow => 'At the bench';

  @override
  String get labHeroTitle => 'Instrument → reagent → method';

  @override
  String get labHeroBody =>
      'Instructions and controls matched to the exact model.';

  @override
  String get labHeroCta => 'Open calibration';

  @override
  String get labQcSub => 'Control charts and rules';

  @override
  String get labPreanalytics => 'Preanalytics';

  @override
  String get labPreanalyticsSub => 'Prepare, collect, store, transport';

  @override
  String get labCalculatorsSub => 'Dilution and units';

  @override
  String get labInstruments => 'Instruments and methods';

  @override
  String get labInstrumentsSub =>
      'Chemistry · hematology · immunochemistry · urine';

  @override
  String get labMicroscopySub => 'Compare images and structures';

  @override
  String get calTitle => 'Calibration workflow';

  @override
  String get calSubtitle =>
      'Exact matching is needed to select the correct instructions.';

  @override
  String get calManufacturer => 'Manufacturer';

  @override
  String get calManufacturerOther => 'Other';

  @override
  String get calModel => 'Instrument model';

  @override
  String get calModelHint => 'Exact model name';

  @override
  String get calReagentRef => 'Reagent REF';

  @override
  String get calIfuRevision => 'IFU revision';

  @override
  String get calCalibratorLot => 'Calibrator lot';

  @override
  String get calCheck => 'Check match';

  @override
  String get calFieldsRequired =>
      'Fill in the model, reagent REF and IFU revision.';

  @override
  String get calNoMatchTitle => 'No verified instructions for this combination';

  @override
  String get calNoMatchBody =>
      'Calibration parameters are shown only from a verified IFU that matches the manufacturer, model, reagent REF, IFU revision and calibrator lot. Use the manufacturer\'s current IFU.';

  @override
  String calCatalogCount(int count) {
    return 'Verified IFU records in this build: $count';
  }

  @override
  String get calBrandWarning =>
      'A brand name (e.g. Mindray or HUMAN) doesn\'t mean all models share settings. The reagent IFU and the instrument manual are separate documents.';

  @override
  String get calWorkflow => 'Workflow';

  @override
  String get calStep1 => 'Model, reagent and instruction revision';

  @override
  String get calStep2 => 'Calibrator lot and assigned values';

  @override
  String get calStep3 => 'Method-specific preparation';

  @override
  String get calStep4 => 'Calibration according to the instructions';

  @override
  String get calStep5 => 'Post-calibration QC';

  @override
  String get calStep6 => 'Records and troubleshooting';

  @override
  String get calNoServiceCodes =>
      'Service codes and safety-bypass procedures are not included.';

  @override
  String get qcTitle => 'Quality control';

  @override
  String get qcChartTitle => 'Levey–Jennings';

  @override
  String get qcChartBody =>
      'A chart needs the test, control lot, level, target mean and SD. No invented results are plotted.';

  @override
  String get qcEmptyTitle => 'No control records yet';

  @override
  String get qcEmptyBody =>
      'Add a test with its control levels to start a Levey–Jennings chart. Data is stored only on this device.';

  @override
  String get qcIntro =>
      'Enter each control level’s target mean and SD, then record every run. The app checks Westgard rules; it never invents target values or results.';

  @override
  String get qcLoadError =>
      'Saved QC data could not be read. Nothing was overwritten.';

  @override
  String get qcAddSet => 'Add test';

  @override
  String get qcSetName => 'Test name';

  @override
  String get qcUnit => 'Unit';

  @override
  String get qcTargetSource => 'Source of the target mean and SD';

  @override
  String get qcSourceLab => 'Our laboratory’s data';

  @override
  String get qcSourceManufacturer => 'Manufacturer’s sheet';

  @override
  String qcLevel(String label) {
    return 'Level $label';
  }

  @override
  String qcLevelNamed(String label) {
    return 'Level “$label”';
  }

  @override
  String qcLevelsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count levels',
      one: '1 level',
    );
    return '$_temp0';
  }

  @override
  String qcRunsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count runs',
      one: '1 run',
      zero: 'no runs',
    );
    return '$_temp0';
  }

  @override
  String get qcLot => 'Lot';

  @override
  String get qcMean => 'Target mean';

  @override
  String get qcSd => 'Target SD';

  @override
  String get qcAddLevel => 'Add level';

  @override
  String get qcRemoveLevel => 'Remove level';

  @override
  String get qcSave => 'Save';

  @override
  String get qcTargetNote =>
      'Westgard et al. (1981) calculate the mean and SD from the laboratory’s own control measurements — initially about 20 (one run a day), then revised as more data accumulate. The app does not supply these values.';

  @override
  String get qcManufacturerWarning =>
      'Manufacturer’s values are a guide only; Westgard’s lessons recommend limits calculated from your own control data — the assay sheet’s ranges are often too wide.';

  @override
  String get qcErrName => 'Enter the test name.';

  @override
  String qcErrLevel(String label) {
    return '$label: enter the mean and an SD greater than zero.';
  }

  @override
  String get qcAccept => 'Accepted';

  @override
  String get qcWarning => 'Warning';

  @override
  String get qcReject => 'Rejected';

  @override
  String get qcAcceptBody => 'No rule violated.';

  @override
  String get qcLatestRun => 'Latest run';

  @override
  String get qcNoRunsYet => 'No runs yet — add the first one below.';

  @override
  String get qcAddRun => 'Add run';

  @override
  String get qcNote => 'Note (optional)';

  @override
  String get qcSaveRun => 'Save run';

  @override
  String get qcErrRunEmpty => 'Enter at least one control value.';

  @override
  String qcErrRunInvalid(String label) {
    return '$label: not a number.';
  }

  @override
  String get qcRunHistory => 'Runs';

  @override
  String get qcStats => 'Observed';

  @override
  String get qcChartLegend => '● in control   ▲ warning   ■ rejected';

  @override
  String qcChartSemantics(String label, int count) {
    return 'Levey–Jennings chart, $label: $count values';
  }

  @override
  String get qcDeleteRun => 'Delete run';

  @override
  String get qcDeleteSet => 'Delete test and all runs';

  @override
  String get qcConfirmDelete => 'This can’t be undone.';

  @override
  String get qcSetMissing => 'This test no longer exists.';

  @override
  String get qcCopyCsv => 'Copy runs as a table (CSV)';

  @override
  String qcCopied(int count) {
    return 'Copied $count rows — paste into Excel or Google Sheets';
  }

  @override
  String get qcChangeTarget => 'Change target or lot';

  @override
  String get qcChangeTargetBody =>
      'Use this when a new control lot starts or your laboratory recalculates the mean and SD. The new values apply from the chosen time (usually now); earlier runs keep being evaluated against the targets that were in effect then.';

  @override
  String get qcErrTarget => 'Enter the mean and an SD greater than zero.';

  @override
  String qcSince(String date) {
    return 'since $date';
  }

  @override
  String qcPreviousTarget(String target, String date) {
    return 'Previous: $target (from $date)';
  }

  @override
  String get qcRulesSource =>
      'Rules: Westgard multirule procedure (Westgard JO et al., Clin Chem 1981; doi:10.1093/clinchem/27.3.493). A learning and checking aid — it does not replace your laboratory’s QC procedure.';

  @override
  String get qcGuidesTitle => 'Guides';

  @override
  String get qgRejected => 'What to do when QC is rejected';

  @override
  String get qgRejectedSub => 'Stop, find the cause, recheck';

  @override
  String get qgEqa => 'External quality assessment (EQA)';

  @override
  String get qgEqaSub => 'What it is, how it works, poor results';

  @override
  String get qgCritical => 'Critical values';

  @override
  String get qgCriticalSub => 'Who sets the list and how to notify';

  @override
  String get qgWhatToDo => 'What to do?';

  @override
  String get qcErrSave => 'Couldn’t save. Please try again.';

  @override
  String qcErrNotFinite(String label) {
    return '$label: the value is too large or too small.';
  }

  @override
  String get qcLevelName => 'Level name (optional, e.g. “Low”)';

  @override
  String get qcStatsExcluded => 'Rejected runs are excluded.';

  @override
  String qcStatsFew(int count) {
    return 'n = $count: still few values — Westgard et al. (1981) initially calculate targets from about 20 values.';
  }

  @override
  String qcUseObserved(int count) {
    return 'Use observed x̄ and SD (n = $count)';
  }

  @override
  String get qcEffectiveFrom => 'Effective from';

  @override
  String get qcFromNow => 'From now';

  @override
  String qcFromDate(String date) {
    return 'From $date';
  }

  @override
  String get qcPickDate => 'Pick a date';

  @override
  String qcRunTime(String time) {
    return 'Run time: $time';
  }

  @override
  String get qcRunTimeNow => 'now';

  @override
  String get qcRunTimeHint =>
      'For a run entered late, pick the actual measurement time — the rules check runs in time order.';

  @override
  String qcShowAllRuns(int count) {
    return 'Show all ($count)';
  }

  @override
  String get qcRejectedExcluded => 'Not used in later rules or statistics';

  @override
  String qcAtEntry(String verdict) {
    return 'At entry: $verdict';
  }

  @override
  String get qcUndoTarget => 'Undo the last change';

  @override
  String qcUndoTargetBody(String target) {
    return 'The current target is removed and the previous one is restored: $target. Runs are re-evaluated.';
  }

  @override
  String get qcBackupTitle => 'Backup';

  @override
  String get qcBackupBody =>
      'QC data is stored only on this device. Copy the backup (JSON) and keep it somewhere safe; on another device you can restore it from the clipboard.';

  @override
  String get qcBackupCopy => 'Copy backup';

  @override
  String get qcBackupCopied => 'Backup copied to the clipboard';

  @override
  String get qcBackupRestore => 'Restore from clipboard';

  @override
  String qcRestoreConfirm(int sets, int runs) {
    return 'Current QC data will be replaced by the backup from the clipboard: $sets tests, $runs runs.';
  }

  @override
  String get qcRestoreAction => 'Replace';

  @override
  String get qcRestoreInvalid =>
      'The clipboard does not contain a valid QC backup.';

  @override
  String get qcRestored => 'QC data restored';

  @override
  String get qcCopyRaw => 'Copy the saved text';

  @override
  String get qcDiscard => 'Delete the unreadable data';

  @override
  String get qcDiscardConfirm =>
      'Copy the saved text first. Once deleted, it cannot be recovered.';

  @override
  String get preTitle => 'Specimen journey';

  @override
  String get preStep1 => 'Prepare for testing';

  @override
  String get preStep2 => 'Select specimen and additive';

  @override
  String get preStep3 => 'Collect and identify';

  @override
  String get preStep4 => 'Separate and store';

  @override
  String get preStep5 => 'Transport and receive';

  @override
  String get preNotice =>
      'Tube color, time and temperature are tied to the specific tube, method and instructions. No universal parameters are given.';

  @override
  String get preOrderTitle => 'Order of draw (venepuncture)';

  @override
  String get preOrderSub =>
      'WHO 2010, Table 2.3 (based on the NCCLS 2003 consensus). Check your laboratory’s current procedure.';

  @override
  String preCap(String cap) {
    return 'Cap: $cap';
  }

  @override
  String get preHaemolysisTitle => 'Causes of hemolysis';

  @override
  String get preTourniquetTitle => 'Tourniquet';

  @override
  String get preIdTitle => 'Patient identification and labelling';

  @override
  String get calcTitle => 'Calculators';

  @override
  String get calcLearningTag => 'Learning calculator';

  @override
  String get calcDilution => 'Dilution';

  @override
  String get calcDilutionSub => 'C₁V₁ = C₂V₂';

  @override
  String get calcUnits => 'Unit conversion';

  @override
  String get calcUnitsSub => 'Analyte-specific';

  @override
  String get calcSectionManual => 'Manual methods';

  @override
  String get mcChamber => 'Counting chamber';

  @override
  String get mcChamberSub => 'Goryaev, Neubauer: cells/µL and ×10⁹/L';

  @override
  String get mcDiff => 'Differential: absolute counts';

  @override
  String get mcDiffSub => 'WBC × %, nucleated RBC correction';

  @override
  String get mcRetic => 'Reticulocytes';

  @override
  String get mcReticSub => '%, corrected % and RPI';

  @override
  String get mcLight => 'Light’s criteria';

  @override
  String get mcLightSub => 'Pleural fluid: exudate or transudate';

  @override
  String get mcColour => 'Colour index';

  @override
  String get mcColourSub => 'Why the app recommends MCH and MCHC';

  @override
  String get mfCells => 'Cells counted';

  @override
  String get mfSquares => 'Squares counted';

  @override
  String get mfSquareArea => 'Area of one square';

  @override
  String get mfDepth => 'Chamber depth';

  @override
  String get mfDilution => 'Dilution factor (20 for 1 in 20)';

  @override
  String get mfWbc => 'Leukocytes (WBC)';

  @override
  String get mfSeg => 'Segmented neutrophils';

  @override
  String get mfBand => 'Band neutrophils';

  @override
  String get mfEos => 'Eosinophils';

  @override
  String get mfBaso => 'Basophils';

  @override
  String get mfLymph => 'Lymphocytes';

  @override
  String get mfMono => 'Monocytes';

  @override
  String get mfOther => 'Other cells';

  @override
  String get mfNrbc => 'Nucleated RBCs per 100 leukocytes';

  @override
  String get mfReticCounted => 'Reticulocytes counted';

  @override
  String get mfRbcExamined => 'Erythrocytes examined';

  @override
  String get mfHct => 'Haematocrit (Hct)';

  @override
  String get mfRbc => 'Erythrocytes (RBC)';

  @override
  String get mfMaturation => 'Maturation factor';

  @override
  String get mfMaturationAuto => 'Auto';

  @override
  String get mfPfProtein => 'Fluid: total protein';

  @override
  String get mfSerumProtein => 'Serum: total protein';

  @override
  String get mfPfLdh => 'Fluid: LDH';

  @override
  String get mfSerumLdh => 'Serum: LDH';

  @override
  String get mfLdhUln => 'Serum LDH upper limit of normal';

  @override
  String get mfSameUnit =>
      'Both values in a pair must use the same unit (e.g. both g/L, both U/L).';

  @override
  String get mrCellsPerUl => 'cells/µL';

  @override
  String get mrVolume => 'Volume counted';

  @override
  String get mrWbcUsed => 'Corrected WBC';

  @override
  String get mrNrbc => 'Nucleated RBCs';

  @override
  String get mrPercentSum => 'Sum of percentages';

  @override
  String get mrAbsolute => 'Absolute counts';

  @override
  String get mrNoCorrection => 'No nucleated RBCs entered — WBC not corrected.';

  @override
  String get mrReticAbs => 'Absolute count';

  @override
  String get mrReticCorrected => 'Corrected %';

  @override
  String get mrRpi => 'Reticulocyte production index (RPI)';

  @override
  String mrMaturationAuto(String factor, String hct) {
    return 'Factor $factor: the table point nearest to Hct $hct% (app rule).';
  }

  @override
  String mrMaturationChosen(String factor) {
    return 'Factor $factor: chosen by you.';
  }

  @override
  String get mrNoRbc => 'Enter the RBC for the absolute count.';

  @override
  String get mrExudate => 'Meets exudate criteria';

  @override
  String get mrTransudate => 'No criterion met — consistent with a transudate';

  @override
  String get mrIncomplete =>
      'Two criteria not met; enter the LDH upper limit for the third';

  @override
  String get mrProteinRatio => 'Protein: fluid ÷ serum (> 0.5)';

  @override
  String get mrLdhRatio => 'LDH: fluid ÷ serum (> 0.6)';

  @override
  String get mrLdhUln => 'Fluid LDH ÷ upper limit (> 2/3)';

  @override
  String get mrMet => 'met';

  @override
  String get mrNotMet => 'not met';

  @override
  String get mrNotAssessed => 'not assessed';

  @override
  String mErrSum(String sum) {
    return 'Percentages add up to $sum — they must total 100. Check the rows.';
  }

  @override
  String get mErrReticGtExamined =>
      'Reticulocytes cannot exceed the erythrocytes examined.';

  @override
  String mErrWhole(String field, String min, String max) {
    return '$field: enter a whole number ($min–$max).';
  }

  @override
  String get ciWhatTitle => 'What is it?';

  @override
  String get ciWhat =>
      'The colour index is a relative measure traditionally used in CIS laboratories: it rates the haemoglobin content of one red cell against a “normal” value. It is used to describe hypo-, normo- or hyperchromia.';

  @override
  String get ciWhyTitle => 'Why the app does not calculate it';

  @override
  String get ciWhy =>
      'We found no primary open source for its formula that we could verify. The app gives no numbers or formulas without a source.';

  @override
  String get ciUseTitle => 'What to use instead';

  @override
  String get ciUse =>
      'The haemoglobin in one red cell is expressed directly by the MCH (mean cell haemoglobin, pg), and its concentration in the cell by the MCHC. Haematology analysers report both. Judge hypo-/hyperchromia by these and your laboratory’s reference intervals.';

  @override
  String get dilC1 => 'C₁ · Stock concentration';

  @override
  String get dilC2 => 'C₂ · Target concentration';

  @override
  String get dilV2 => 'V₂ · Final volume (mL)';

  @override
  String get dilNote =>
      'Use the same units for C₁ and C₂. Simple dilution model: reactions, safety and volume changes are not modelled.';

  @override
  String get dilCalculate => 'Calculate';

  @override
  String dilResult(String volume) {
    return 'V₁ = $volume mL';
  }

  @override
  String get dilResultBody =>
      'Volume of stock solution. Bring the total final volume to V₂.';

  @override
  String dilDiluent(String volume) {
    return 'Diluent ≈ $volume mL (assuming volumes add up)';
  }

  @override
  String get dilNoDilution => 'C₂ equals C₁: no dilution is needed.';

  @override
  String get dilErrorInvalid =>
      'Enter a number greater than zero in every field.';

  @override
  String get dilErrorC2GtC1 =>
      'C₂ can\'t exceed C₁: dilution can\'t raise the concentration.';

  @override
  String get dilErrorRange => 'The values are outside the calculable range.';

  @override
  String get ucTitle => 'Unit conversion';

  @override
  String get ucSubtitle =>
      'Each substance has its own factor — one shared mg/dL → mmol/L factor would be wrong.';

  @override
  String get ucAnalyte => 'Analyte';

  @override
  String get ucValue => 'Value';

  @override
  String get ucSwap => 'Swap units';

  @override
  String get ucConvert => 'Convert';

  @override
  String ucNote(String mass) {
    return 'Calculated from the molar mass $mass g/mol. Laboratories may round differently; report the units your laboratory uses.';
  }

  @override
  String get ucNotAvailable =>
      'No verified molar mass for this analyte, so conversion is not offered.';

  @override
  String get ucErrorInvalid => 'Enter a number of 0 or more.';

  @override
  String get ucErrorRange => 'The value is outside the calculable range.';

  @override
  String get calcSectionClinical => 'Clinical formulas';

  @override
  String get calcSectionLab => 'Laboratory';

  @override
  String get calcEgfr => 'eGFR · CKD‑EPI 2021';

  @override
  String get calcEgfrSub => 'Creatinine, age, sex';

  @override
  String get calcAcr => 'Albumin/creatinine ratio';

  @override
  String get calcAcrSub => 'Urine ACR · KDIGO A category';

  @override
  String get calcAnionGap => 'Anion gap';

  @override
  String get calcAnionGapSub => 'Na, Cl, HCO₃ · K and albumin optional';

  @override
  String get calcCalcium => 'Corrected calcium';

  @override
  String get calcCalciumSub => 'By albumin · Payne 1973';

  @override
  String get calcLdl => 'LDL-C and non-HDL-C';

  @override
  String get calcLdlSub => 'Friedewald · Sampson';

  @override
  String get calcOsmo => 'Calculated osmolality';

  @override
  String get calcOsmoSub => 'And osmolal gap';

  @override
  String get calcHba1c => 'HbA1c units and eAG';

  @override
  String get calcHba1cSub => 'NGSP ↔ IFCC · ADAG';

  @override
  String get calcFormulaTag => 'Published formula';

  @override
  String get calcOptional => 'optional';

  @override
  String get calcNotDiagnosis =>
      'A calculation aid for learning and checking. It does not diagnose: interpret the result with the clinical picture and your laboratory’s reference intervals.';

  @override
  String calcUnitCheck(String field, String value, String unit) {
    return '$field: $value $unit is unusual for this unit — check that the right unit is selected.';
  }

  @override
  String calcInputs(String list) {
    return 'Entered: $list';
  }

  @override
  String calcNegativeCheck(String name) {
    return '$name is negative — check the entered values and units.';
  }

  @override
  String calcUnitGroup(String field) {
    return '$field unit';
  }

  @override
  String get calcFormula => 'Formula';

  @override
  String get calcLimitations => 'Limitations';

  @override
  String get calcSources => 'Sources';

  @override
  String get fieldCreatinine => 'Serum creatinine';

  @override
  String get fieldAge => 'Age, years';

  @override
  String get fieldSex => 'Sex';

  @override
  String get fieldSodium => 'Sodium (Na⁺)';

  @override
  String get fieldChloride => 'Chloride (Cl⁻)';

  @override
  String get fieldBicarbonate => 'Bicarbonate (HCO₃⁻)';

  @override
  String get fieldPotassium => 'Potassium (K⁺)';

  @override
  String get fieldAlbumin => 'Serum albumin';

  @override
  String get fieldNormalAlbumin => 'Normal albumin used by your laboratory';

  @override
  String get fieldCalcium => 'Total serum calcium';

  @override
  String get fieldTotalCholesterol => 'Total cholesterol';

  @override
  String get fieldHdl => 'HDL cholesterol';

  @override
  String get fieldTriglycerides => 'Triglycerides';

  @override
  String get fieldGlucose => 'Glucose';

  @override
  String get fieldUrea => 'Urea (or BUN)';

  @override
  String get fieldMeasuredOsmolality => 'Measured osmolality';

  @override
  String get fieldHba1c => 'HbA1c';

  @override
  String get fieldUrineAlbumin => 'Urine albumin';

  @override
  String get fieldUrineCreatinine => 'Urine creatinine';

  @override
  String get sexFemale => 'Female';

  @override
  String get sexMale => 'Male';

  @override
  String resGfrCategory(String code) {
    return 'KDIGO GFR category $code';
  }

  @override
  String resAlbCategory(String code) {
    return 'KDIGO albuminuria category $code';
  }

  @override
  String get resCategoryBasisSi => 'Determined on the mg/mmol cut-offs.';

  @override
  String get resCategoryBasisConv => 'Determined on the mg/g cut-offs.';

  @override
  String get resAnionGap => 'Anion gap';

  @override
  String get resAnionGapK => 'With potassium';

  @override
  String get resAnionGapAlb => 'Albumin-corrected (Figge)';

  @override
  String get resCorrectedCa => 'Corrected calcium (Payne)';

  @override
  String get resNonHdl => 'Non-HDL cholesterol';

  @override
  String get resLdlFriedewald => 'LDL-C · Friedewald';

  @override
  String get resLdlSampson => 'LDL-C · Sampson';

  @override
  String get resOsmCalc => 'Calculated osmolality';

  @override
  String get resOsmGap => 'Osmolal gap';

  @override
  String get resEag => 'Estimated average glucose (eAG)';

  @override
  String errCalcMissing(String field) {
    return 'Enter a number: $field.';
  }

  @override
  String errCalcImplausible(String field, String min, String max, String unit) {
    return '$field: outside the range this calculator accepts ($min–$max$unit). Check the value and the unit.';
  }

  @override
  String get errEgfrAge =>
      'The CKD-EPI 2021 equation was developed in participants aged 18 or older; it is not calculated for children.';

  @override
  String errFriedewaldTg(String limit) {
    return 'Not calculated: Friedewald is not reliable when triglycerides exceed $limit.';
  }

  @override
  String errSampsonTg(String limit) {
    return 'Not calculated: the Sampson equation was validated for triglycerides up to $limit.';
  }

  @override
  String errEagRange(String range) {
    return 'eAG not shown: the ADAG data cover HbA1c $range.';
  }

  @override
  String get errHdlGeTc =>
      'HDL cholesterol can\'t be equal to or greater than total cholesterol.';

  @override
  String get errNotPositive =>
      'Not calculated: the result is not positive — check the values.';

  @override
  String get errSexMissing => 'Choose sex.';

  @override
  String get micTitle => 'Microscopy atlas';

  @override
  String get micSubtitle => 'Urine, blood and parasites — licensed micrographs';

  @override
  String get micAtlasError => 'Couldn’t open the atlas';

  @override
  String get micNotFound => 'This image or section was not found';

  @override
  String micImagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count images',
      one: '1 image',
    );
    return '$_temp0';
  }

  @override
  String micGapsCount(int count) {
    return '$count still without an image';
  }

  @override
  String micResultsCount(int count) {
    return 'Found: $count';
  }

  @override
  String get micSearchLabel => 'Search the atlas';

  @override
  String get micSearchHint => 'e.g. neutrophil, оксалат, bezgak';

  @override
  String get micNoResultsTitle => 'Nothing found';

  @override
  String get micNoResultsBody =>
      'Try another name or another language (uz, ru, en).';

  @override
  String get micSections => 'Sections';

  @override
  String get micEduNotice =>
      'Teaching images — not for diagnosis. Every image shows its author, licence and original caption. LabGuide notes are drafts awaiting expert review.';

  @override
  String get micEduTag => 'Teaching image — not for diagnosis';

  @override
  String get micNoImageYet => 'No licensed image yet';

  @override
  String get micGapWhy => 'Why not?';

  @override
  String get micAllGroups => 'All';

  @override
  String get micSectionQuiz => 'Practise this section';

  @override
  String get micZoom => 'Zoom';

  @override
  String micOpenFull(String name) {
    return '$name — open full screen';
  }

  @override
  String micImageSemantics(String name) {
    return 'Micrograph: $name';
  }

  @override
  String get micNames => 'Name in three languages';

  @override
  String get micOriginalCaption => 'Original caption';

  @override
  String micCaptionLang(String lang) {
    return 'Verbatim, in the source language · $lang';
  }

  @override
  String get micTranslation => 'Translation (LabGuide)';

  @override
  String get micLangEn => 'English';

  @override
  String get micLangEs => 'Spanish';

  @override
  String get micLangRu => 'Russian';

  @override
  String get micPreparation => 'Preparation';

  @override
  String get micMagnification => 'Magnification';

  @override
  String get micStain => 'Stain';

  @override
  String get micNotStated => 'not stated in the source';

  @override
  String get micOnlySource => 'Only what the source states is shown.';

  @override
  String get micDraftTitle => 'What to look for';

  @override
  String get micDraftTag => 'Draft · awaiting expert review';

  @override
  String get micCreditTitle => 'Author and licence';

  @override
  String get micAuthor => 'Author';

  @override
  String get micCredit => 'Source';

  @override
  String get micOwnWork => 'Own work';

  @override
  String get micLicense => 'Licence';

  @override
  String get micSourceDate => 'Date in the source';

  @override
  String micLicenseText(String license) {
    return 'Licence text: $license';
  }

  @override
  String get micSourcePage => 'Source page';

  @override
  String get micOriginalFile => 'Original file';

  @override
  String micResized(int width, int height, int origWidth, int origHeight) {
    return 'In-app copy: $width×$height px (original $origWidth×$origHeight px, downscaled only). Not cropped, no text added.';
  }

  @override
  String micNotResized(int width, int height) {
    return 'In-app copy: $width×$height px, original size. Not cropped, no text added.';
  }

  @override
  String get micShareAlike =>
      'CC BY-SA: adapted versions of this image are shared under the same licence.';

  @override
  String get micCdcTerms => 'Terms of use (from the CDC PHIL page, verbatim)';

  @override
  String get micCdcFree =>
      'Free source: CDC Public Health Image Library (PHIL), wwwn.cdc.gov/phil';

  @override
  String get micSameEntity => 'More images of this type';

  @override
  String get micCreditsTitle => 'Image credits';

  @override
  String get micCreditsSub => 'Licences and sources';

  @override
  String micCreditsIntro(String date) {
    return 'Each image’s licence, author and original caption were re-checked on the source page ($date). Images are only downscaled: not cropped, no text added, EXIF removed. Only CC0, CC BY, CC BY-SA, public domain and CDC PHIL images are used.';
  }

  @override
  String get micLicenseTexts => 'Licence texts';

  @override
  String get micCreditsRow => 'Authors and licences';

  @override
  String get micCreditsRowSub => 'Source and terms of use for every image';

  @override
  String get micClose => 'Close';

  @override
  String get micZoomIn => 'Zoom in';

  @override
  String get micZoomOut => 'Zoom out';

  @override
  String get micZoomReset => 'Reset view';

  @override
  String get micViewerHint => 'Pinch or double-tap to zoom';

  @override
  String get micHeroEyebrow => 'Practice';

  @override
  String get micQuizTitle => 'What is it?';

  @override
  String get micQuizSubtitle => 'Microscopy practice';

  @override
  String get micQuizHeroBody =>
      'Look at the image and pick the right name: 4 options, all from the atlas. Instant feedback.';

  @override
  String get micQuizCta => 'Start practice';

  @override
  String get micQuizScope => 'Which section?';

  @override
  String micQuizScopeChip(String name, int count) {
    return '$name · $count';
  }

  @override
  String micQuizStart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Start · $count questions',
      one: 'Start · 1 question',
    );
    return '$_temp0';
  }

  @override
  String micQuizBest(int correct, int total) {
    return 'Best result: $correct/$total';
  }

  @override
  String get micQuizNoBest => 'No result yet — start your first round';

  @override
  String get micQuizRules =>
      'Options come only from atlas names. Mixed fields and journal panels are left out. Results are stored only on this device.';

  @override
  String micQuizProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String micQuizStreak(int count) {
    return '$count in a row';
  }

  @override
  String get micQuizPromptArrow => 'What is the cell marked by the arrowhead?';

  @override
  String get micQuizPromptCentre => 'What is the cell in the centre?';

  @override
  String get micQuizPromptField => 'What is mainly shown in this field?';

  @override
  String get micQuizCorrect => 'Correct!';

  @override
  String micQuizWrong(String answer) {
    return 'Not quite. Correct answer: $answer';
  }

  @override
  String get micQuizOpenCard => 'Open the image card';

  @override
  String get micQuizTapToZoom => 'Tap the image to zoom';

  @override
  String get micQuizResultGreat => 'Excellent!';

  @override
  String get micQuizResultGood => 'Good result';

  @override
  String get micQuizResultKeep => 'Keep practising';

  @override
  String micQuizScore(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String micQuizBestStreak(int count) {
    return 'Longest streak: $count';
  }

  @override
  String get micQuizNewRecord => 'New record';

  @override
  String micQuizRetryMistakes(int count) {
    return 'Retry mistakes ($count)';
  }

  @override
  String get micQuizNewRound => 'New round';

  @override
  String get micQuizChangeScope => 'Another section';

  @override
  String get micQuizBackToAtlas => 'Back to the atlas';

  @override
  String get insTitle => 'Instruments';

  @override
  String get insMindraySub => 'Exact model required';

  @override
  String get insHumanSub => 'Instrument and reagent documents are separate';

  @override
  String get insOther => 'Other manufacturer';

  @override
  String get insOtherSub => 'Match by exact model and IFU';

  @override
  String get instSearchLabel => 'Search instruments';

  @override
  String get instSearchHint => 'Model or manufacturer';

  @override
  String get instNoResultsTitle => 'No model found';

  @override
  String get instNoResultsBody =>
      'You can add an instrument that is not in the catalog with the button below.';

  @override
  String get instMine => 'My instruments';

  @override
  String get instDirections => 'Sections';

  @override
  String instModelsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count models',
      one: '1 model',
    );
    return '$_temp0';
  }

  @override
  String instPlanned(String names) {
    return 'Next phase: $names';
  }

  @override
  String get instPlannedBody =>
      'Models from these manufacturers will be added once checked against official sources.';

  @override
  String get instAddCustom => 'Add an instrument not in the list';

  @override
  String get instAddCustomSub =>
      'You enter the manufacturer and model yourself';

  @override
  String get instCustomTag => 'Entered by you';

  @override
  String instCatalogNote(String date) {
    return 'The catalog is compiled from manufacturers’ official pages and documents (as of $date). Every fact shows its source.';
  }

  @override
  String get instChooseMaker => 'Choose a manufacturer';

  @override
  String get instChooseModel => 'Choose a model';

  @override
  String get instStatusTitle => 'Information status';

  @override
  String get instStatusDevice => 'Instrument information available';

  @override
  String get instStatusDeviceSub =>
      'From the official page, brochure or regulatory document';

  @override
  String get instStatusIfu => 'Manual available';

  @override
  String get instStatusIfuSub =>
      'Checked against the official operator’s manual (with version)';

  @override
  String get instStatusExpert => 'Expert reviewed';

  @override
  String get instStatusExpertSub =>
      'Reviewed by an independent laboratory specialist';

  @override
  String get instStatusDone => 'yes';

  @override
  String get instStatusNotYet => 'not yet';

  @override
  String get instPurpose => 'Purpose';

  @override
  String get instPrinciple => 'Principle';

  @override
  String get instNotStated => 'Not stated in the official source.';

  @override
  String get instOfficialText => 'Official wording';

  @override
  String get instKeyFacts => 'Key facts';

  @override
  String get instManual => 'Operator’s manual';

  @override
  String get instManualPublic => 'Publicly available';

  @override
  String get instManualLogin => 'Login required';

  @override
  String get instManualNotPublic => 'Not publicly available';

  @override
  String get instDocsPortal => 'Documents portal';

  @override
  String get instLoginYes => 'login required';

  @override
  String get instLoginNo => 'no login';

  @override
  String get instLoginUnknown => 'login not verified';

  @override
  String get instMaintenance => 'Daily maintenance';

  @override
  String get instMaintenanceNone =>
      'The manufacturer does not publish daily maintenance steps openly. Follow the “Maintenance” section of your instrument’s operator’s manual — LabGuide does not guess the steps.';

  @override
  String get instMaintenanceQuotes => 'What the manufacturer states publicly:';

  @override
  String get instReagentSystem => 'Reagent system';

  @override
  String get instReagentOpen =>
      'Open — reagents from other manufacturers can be set up';

  @override
  String get instReagentPartly =>
      'Partly open — user-defined channels available';

  @override
  String get instReagentClosed => 'Closed — system reagents only';

  @override
  String get instReagentUnknown => 'Openness not stated in the official source';

  @override
  String instValidatedReagents(int count) {
    return 'Reagents with preinstalled settings (per official source): $count';
  }

  @override
  String get instImageNone =>
      'No clearly licensed image found — we do not reuse manufacturer photos without permission.';

  @override
  String instImageCredit(String author, String license) {
    return 'Image: $author · $license';
  }

  @override
  String get instIllustration =>
      'Schematic illustration (drawn by LabGuide) — not the actual appearance of this model.';

  @override
  String get instSources => 'Sources';

  @override
  String instAccessed(String date) {
    return 'accessed $date';
  }

  @override
  String get instSaveMine => 'Save as “My instrument”';

  @override
  String instSavedCount(int count) {
    return 'In “My instruments”: $count';
  }

  @override
  String get instCalibrate => 'Calibration';

  @override
  String get instQc => 'Quality control (QC)';

  @override
  String get instSaveTitle => 'Save instrument';

  @override
  String get instLabel => 'Name (optional)';

  @override
  String get instLabelHint => 'e.g. room 1 or back-up';

  @override
  String get instSerial => 'Serial number (optional)';

  @override
  String get instManualVersion => 'Manual version (optional)';

  @override
  String get instManualVersionHint => 'version or date on the manual cover';

  @override
  String get instSave => 'Save';

  @override
  String get instSaved => 'Saved';

  @override
  String get instRemove => 'Remove from list';

  @override
  String get instRemoveConfirm =>
      'Remove this instrument? Calibration log entries are kept.';

  @override
  String get instMaker => 'Manufacturer';

  @override
  String get instModel => 'Model';

  @override
  String get instCategory => 'Section';

  @override
  String get instCustomRequired => 'Enter the manufacturer and model.';

  @override
  String get instCatalogError => 'Could not read the instrument catalog';

  @override
  String get instOpenCard => 'Instrument card';

  @override
  String get partnerAdLabel => 'Ad';

  @override
  String get partnerLabel => 'Partner';

  @override
  String get partnerOfficialTitle => 'Official partners';

  @override
  String get partnerSectionNote =>
      'Information provided by the partner companies. The catalogue data above, its order and review status do not depend on partnerships.';

  @override
  String get partnerKindManufacturer => 'Manufacturer';

  @override
  String get partnerKindDistributor => 'Official distributor';

  @override
  String get partnerKindService => 'Service centre';

  @override
  String get partnerCall => 'Call';

  @override
  String get partnerTelegram => 'Telegram';

  @override
  String get partnerWebsite => 'Website';

  @override
  String get partnerEmail => 'Email';

  @override
  String get partnerBrochure => 'Brochure';

  @override
  String get partnerMore => 'Details';

  @override
  String partnerRegions(String regions) {
    return 'Regions: $regions';
  }

  @override
  String partnerRegistration(String number) {
    return 'Registration certificate in Uzbekistan: $number';
  }

  @override
  String get partnerRegistrationNote => 'Number provided by the partner.';

  @override
  String get partnerBecome => 'Become a partner';

  @override
  String get partnerBecomeSub => 'For companies: your instruments in LabGuide';

  @override
  String get partnerNotFoundTitle => 'Partner not found';

  @override
  String get partnerNotFoundBody =>
      'The listing may have ended or been paused.';

  @override
  String get partnerContacts => 'Contacts';

  @override
  String get partnerAbout => 'About the company';

  @override
  String get partnerInstruments => 'Related instruments';

  @override
  String partnerAllModels(String maker) {
    return '$maker: all models';
  }

  @override
  String get partnerPageNote =>
      'This page is an advertisement. LabGuide does not endorse partner products; catalogue data and review status do not depend on partnerships.';

  @override
  String get partnerOfferTitle => 'Your contacts, right on the instrument card';

  @override
  String get partnerOfferBody =>
      'A lab specialist reading about an instrument can call its official distributor or service centre in one tap. For manufacturers, official distributors and service centres.';

  @override
  String get partnerWhatTitle => 'What you get';

  @override
  String get partnerWhatCard =>
      'An “Official partners” section on the instrument card: logo, short description, regions, call and Telegram buttons.';

  @override
  String get partnerWhatCategory =>
      'A compact “Partner” card inside the instrument category (e.g. Chemistry).';

  @override
  String get partnerWhatLabHome =>
      'One ad card on the Lab tab home, shown in rotation.';

  @override
  String get partnerWhatPage =>
      'A partner page: related models, registration numbers, brochure.';

  @override
  String get partnerWhatReport =>
      'A report: impressions and contact taps by day and placement (no personal data).';

  @override
  String get partnerAudienceTitle => 'Audience';

  @override
  String get partnerAudienceBody =>
      'LabGuide serves laboratory specialists, doctors, students and teachers in Uzbek, Russian and English. We show user numbers and the role breakdown from server statistics during negotiation; we don’t quote estimates.';

  @override
  String get partnerRulesTitle => 'Rules';

  @override
  String get partnerRule1 =>
      'Every placement carries a clear “Ad” or “Partner” label.';

  @override
  String get partnerRule2 =>
      'Catalogue facts, their order and review status do not depend on partnerships and cannot be bought.';

  @override
  String get partnerRule3 =>
      'Medical device ads: the instrument must be registered in Uzbekistan; the certificate number is shown on the card.';

  @override
  String get partnerRule4 =>
      'Verifiable information only: unproven claims such as “the best” or “100% accurate” are not accepted.';

  @override
  String get partnerRule5 =>
      'Users’ personal data is never shared with partners.';

  @override
  String get partnerPriceTitle => 'Price';

  @override
  String get partnerPriceBody =>
      'Price is agreed individually, depending on placements, period and regions.';

  @override
  String get partnerHowTitle => 'How it works';

  @override
  String get partnerHow1 => 'Send an application using the form below.';

  @override
  String get partnerHow2 => 'We contact you and agree the terms.';

  @override
  String get partnerHow3 =>
      'You send the logo, description (uz/ru/en), contacts and registration numbers.';

  @override
  String get partnerHow4 =>
      'After review the listing goes live; we send reports regularly.';

  @override
  String get partnerFormTitle => 'Application';

  @override
  String get partnerFormCompany => 'Company';

  @override
  String get partnerFormContact => 'Contact person';

  @override
  String get partnerFormPhone => 'Phone';

  @override
  String get partnerFormEmail => 'Email';

  @override
  String get partnerFormProducts => 'Products (instruments, models)';

  @override
  String get partnerFormMessage => 'Message';

  @override
  String get partnerFormHint => 'A phone number or an email is required.';

  @override
  String get partnerFormSend => 'Send application';

  @override
  String get partnerFormInvalid =>
      'Enter the company and contact person, and a valid phone or email.';

  @override
  String get partnerSentTitle => 'Application sent';

  @override
  String get partnerSentBody =>
      'The reply will appear on this page under “Your applications”. If needed, we will contact you by the phone or email you gave.';

  @override
  String get partnerSendAnother => 'Send another application';

  @override
  String get partnerFormSignIn =>
      'Sign in with email to send an application — the reply comes to that account.';

  @override
  String get partnerFormUnavailable =>
      'Applications are not connected yet: this build has no server.';

  @override
  String get partnerMyRequests => 'Your applications';

  @override
  String get partnerReqStatusNew => 'New';

  @override
  String get partnerReqStatusInReview => 'In review';

  @override
  String get partnerReqStatusAccepted => 'Accepted';

  @override
  String get partnerReqStatusDeclined => 'Declined';

  @override
  String partnerReqReply(String text) {
    return 'LabGuide reply: $text';
  }

  @override
  String get partnerPlacementCard => 'Instrument card';

  @override
  String get partnerPlacementCategory => 'Category';

  @override
  String get partnerPlacementLabHome => 'Lab home';

  @override
  String get partnerPlacementPage => 'Partner page';

  @override
  String get adminPartners => 'Partners';

  @override
  String get adminPartnersSub => 'Ads: create, publish, statistics';

  @override
  String get adminPartnerRequests => 'Partnership applications';

  @override
  String adminPartnerRequestsNew(int count) {
    return 'New applications: $count';
  }

  @override
  String get adminPartnerNew => 'New partner';

  @override
  String get adminPartnersEmpty => 'No partners yet';

  @override
  String get adminPartnerStatusDraft => 'Draft';

  @override
  String get adminPartnerStatusLive => 'Published';

  @override
  String get adminPartnerStatusPaused => 'Paused';

  @override
  String get adminPartnerExpired => 'Expired';

  @override
  String get adminPartnerUpcoming => 'Not started yet';

  @override
  String get adminPartnerName => 'Company name';

  @override
  String get adminPartnerKind => 'Type';

  @override
  String get adminPartnerLogo => 'Logo link (https://…)';

  @override
  String get adminPartnerLogoUpload => 'Upload logo (PNG/JPEG, ≤ 1 MB)';

  @override
  String get adminPartnerLogoTooLarge =>
      'The logo is larger than 1 MB or not PNG/JPEG.';

  @override
  String adminPartnerSummary(String lang) {
    return 'Short description ($lang)';
  }

  @override
  String get adminPartnerRegions => 'Regions';

  @override
  String get adminPartnerTelegram => 'Telegram (username)';

  @override
  String get adminPartnerWebsite => 'Website (https://…)';

  @override
  String get adminPartnerBrochure => 'Brochure link (https://…)';

  @override
  String get adminPartnerLinks => 'Catalogue links';

  @override
  String get adminPartnerMakers => 'Manufacturers (all models)';

  @override
  String get adminPartnerModels => 'Models';

  @override
  String get adminPartnerAddModel => 'Add a model';

  @override
  String get adminPartnerRegNo => 'Certificate number (optional)';

  @override
  String get adminPartnerUnlink => 'Remove';

  @override
  String get adminPartnerPeriodTitle => 'Active period';

  @override
  String get adminPartnerStarts => 'Starts';

  @override
  String get adminPartnerEnds => 'Ends';

  @override
  String get adminPartnerSave => 'Save';

  @override
  String get adminPartnerSaved => 'Saved';

  @override
  String get adminPartnerPublish => 'Publish';

  @override
  String get adminPartnerPause => 'Pause';

  @override
  String get adminPartnerPublished => 'Published';

  @override
  String get adminPartnerPausedMsg => 'Paused';

  @override
  String get adminPartnerPublishRules =>
      'To publish: a description, at least one contact and at least one link. The ad always carries an “Ad” label and never changes catalogue data.';

  @override
  String get adminPartnerInvalid =>
      'Check the data: name (2–120 characters), phone, Telegram (5–32 characters), https links, email, dates; to publish — description, contact and a link.';

  @override
  String get adminPartnerStats => 'Statistics';

  @override
  String get adminStatsImpressions => 'Impressions';

  @override
  String get adminStatsContacts => 'Contact taps';

  @override
  String get adminStatsCtr => 'Click-through rate';

  @override
  String get adminStats7 => 'Last 7 days';

  @override
  String get adminStats30 => 'Last 30 days';

  @override
  String get adminStatsAll => 'All time';

  @override
  String get adminStatsPeriods => 'By period';

  @override
  String get adminStatsByPlacement => 'By placement (30 days)';

  @override
  String get adminStatsDaily => 'By day';

  @override
  String get adminStatsEmpty => 'No events yet';

  @override
  String get adminStatsNote =>
      'How it is counted: an impression means the partner block was drawn on screen; once per device per day per placement. Only signed-in users are counted (not guests or the admin). No personal data is stored, only daily counters (Tashkent time).';

  @override
  String get adminStatsCopy => 'Copy report';

  @override
  String get adminRequestsEmpty => 'No applications';

  @override
  String get adminRequestReply => 'Reply (the applicant sees it)';

  @override
  String get adminRequestSave => 'Save status and reply';

  @override
  String get adminActionPartnerCreated => 'Partner created';

  @override
  String get adminActionPartnerUpdated => 'Partner edited';

  @override
  String get adminActionPartnerPublished => 'Partner published';

  @override
  String get adminActionPartnerPaused => 'Partner paused';

  @override
  String get adminActionPartnerDraft => 'Partner moved to draft';

  @override
  String get adminActionPartnerRequest => 'Partnership application handled';

  @override
  String get calStepInstrument => '1. Instrument';

  @override
  String get calStepAnalyte => '2. Analyte';

  @override
  String get calStepReagent => '3. Reagent';

  @override
  String get calChooseInstrument =>
      'First choose the instrument: from saved ones or the catalog.';

  @override
  String get calChange => 'Change';

  @override
  String get calFromCatalog => 'Choose from catalog';

  @override
  String get calAnalyteHint => 'e.g. glucose';

  @override
  String get calReagentMaker => 'Reagent manufacturer';

  @override
  String get calReagentMakerName => 'Manufacturer name';

  @override
  String get calDifferentMaker =>
      'The reagent manufacturer differs from the instrument’s. Check compatibility separately: the instrument list (applications) in the reagent IFU and the instrument’s reagent system.';

  @override
  String calValidated(String doc) {
    return 'Per the official source ($doc), this instrument has preinstalled settings for:';
  }

  @override
  String get calRefListed => 'The entered REF is in this list.';

  @override
  String get calRefNotListed =>
      'The entered REF is not in this list — re-check the reagent box and IFU.';

  @override
  String get calShowGuide => 'Show guide';

  @override
  String get calGuideNeeds =>
      'Enter the instrument, analyte, reagent REF and IFU version. The lot is not needed at this step.';

  @override
  String get calGuideFound => 'Verified guide found';

  @override
  String get calGuideNoneTitle => 'No verified guide yet';

  @override
  String get calGuideNoneBody =>
      'LabGuide has no checked record for this instrument + reagent REF + IFU version. We do not guess parameters — take them from these documents:';

  @override
  String get calGuide1 =>
      'Calibrator name and REF — in the “Calibration” section of the reagent IFU.';

  @override
  String get calGuide2 =>
      'Number of calibration points and method — in the same section.';

  @override
  String get calGuide3 =>
      'Assigned values for each lot — on the calibrator value sheet (the lot number must match).';

  @override
  String get calGuide4 =>
      'When to recalibrate (new lot, QC failure, interval) — in the IFU.';

  @override
  String get calGuide5 => 'After calibrating, run QC and record the result.';

  @override
  String get calDocsWhere => 'Where to find the documents';

  @override
  String get calRecordCreate => 'Create a calibration record';

  @override
  String get calRecordTitle => 'Calibration record';

  @override
  String get calCalibratorName => 'Calibrator name or REF (optional)';

  @override
  String get calLotExpiry => 'Lot expiry (optional)';

  @override
  String get calLevels => 'Calibrator levels';

  @override
  String get calLevelName => 'Level';

  @override
  String get calLevelValue => 'Assigned value';

  @override
  String get calLevelUnit => 'Unit';

  @override
  String get calAddLevel => 'Add level';

  @override
  String get calRemoveLevel => 'Remove level';

  @override
  String get calValuesFromSheet =>
      'Copy the values from the value sheet of this exact lot. LabGuide does not guess or check them.';

  @override
  String get calPerformedOn => 'Date performed';

  @override
  String get calOutcome => 'Outcome';

  @override
  String get calOutcomeAccepted => 'Accepted';

  @override
  String get calOutcomeRejected => 'Rejected';

  @override
  String get calOutcomePending => 'Pending';

  @override
  String get calNote => 'Note (optional)';

  @override
  String get calRecordSave => 'Save record';

  @override
  String get calRecordSaved => 'Calibration record saved';

  @override
  String get calLotRequired => 'Enter the calibrator lot.';

  @override
  String get calLevelInvalid =>
      'Enter a name, a numeric value and a unit for each level.';

  @override
  String get calLog => 'Calibration log';

  @override
  String get calLogSub => 'Lot, values and outcome — on this device';

  @override
  String get calLogEmpty => 'No records yet';

  @override
  String get calLogEmptyBody =>
      'Create a record after calibrating — lot, values and outcome are kept here.';

  @override
  String get calDeleteRecord => 'Delete record';

  @override
  String get calDeleteRecordConfirm => 'Delete this calibration record?';

  @override
  String get calUserEntered => 'Values entered by the user.';

  @override
  String get calDetailInstrument => 'Instrument';

  @override
  String get calDetailManual => 'Manual version';

  @override
  String get calDetailCalibrator => 'Calibrator';

  @override
  String get calDetailLotExpiry => 'Lot expiry';

  @override
  String get calLot => 'Lot';

  @override
  String calAnalyteSelected(String name) {
    return 'Analyte: $name';
  }

  @override
  String get libTitle => 'Library';

  @override
  String get libSubtitle => 'Your knowledge in one place.';

  @override
  String get libBooks => 'Books and guides';

  @override
  String get libBooksSub => 'Catalog of books, manuals and websites';

  @override
  String get libPacks => 'Offline packs';

  @override
  String get libPacksSub => 'Installed and upcoming packs';

  @override
  String get libSavedSub => 'Bookmarked tests';

  @override
  String get libResearchSub => 'Question, plan, real data and sources';

  @override
  String get libSources => 'Sources and licences';

  @override
  String get libSourcesSub => 'Review and reuse conditions';

  @override
  String get booksEmptyTitle => 'No books yet';

  @override
  String get booksEmptyBody =>
      'Books are added only with confirmed distribution rights. A PDF you add yourself stays for personal study and isn\'t shared.';

  @override
  String get booksCatalogNote =>
      'Catalog items link to their official pages. Full text is added to the app only under an open licence or with confirmed distribution rights.';

  @override
  String get booksResetFilters => 'Clear filters';

  @override
  String get packsInstalled => 'Installed';

  @override
  String get packsCoreTitle => 'Core content';

  @override
  String packsVersion(String version) {
    return 'Version $version';
  }

  @override
  String packsSize(String size) {
    return 'Size: $size';
  }

  @override
  String packsLanguages(String languages) {
    return 'Languages: $languages';
  }

  @override
  String packsLicence(String licence) {
    return 'Licence: $licence';
  }

  @override
  String get packsVerified => 'Integrity verified (SHA-256)';

  @override
  String get packsUpcoming => 'Upcoming packs';

  @override
  String get packsUpcomingBody =>
      'The size is shown before any download. Packs are published only after content review.';

  @override
  String get packsBiochem => 'Biochemistry essentials';

  @override
  String get packsSpecimensQc => 'Specimens and QC';

  @override
  String get packsMicroscopy => 'Microscopy atlas';

  @override
  String get packsNotPublished => 'Not published yet';

  @override
  String get packsBuiltIn => 'Built into the app';

  @override
  String get packsOffline => 'Works offline';

  @override
  String get packsCoreState =>
      'Status: draft — sourced learning material, not yet independently reviewed';

  @override
  String packsContents(int cards, int questions, int sources) {
    String _temp0 = intl.Intl.pluralLogic(
      cards,
      locale: localeName,
      other: '$cards cards',
      one: '1 card',
    );
    String _temp1 = intl.Intl.pluralLogic(
      questions,
      locale: localeName,
      other: '$questions questions',
      one: '1 question',
    );
    String _temp2 = intl.Intl.pluralLogic(
      sources,
      locale: localeName,
      other: '$sources sources',
      one: '1 source',
    );
    return 'Contents: $_temp0, $_temp1, $_temp2';
  }

  @override
  String get packsDownloadable => 'Packs to download';

  @override
  String get packsCatalogLoading => 'Loading catalogue…';

  @override
  String get packsCatalogCached => 'Showing the last saved catalogue';

  @override
  String get packsCatalogEmpty => 'No packs to download yet';

  @override
  String get packsStatusTest => 'Test pack · not a clinical pack';

  @override
  String get packsStatusDraft => 'Draft · not expert-reviewed';

  @override
  String get packsStatusReviewed => 'Expert-reviewed';

  @override
  String packsMeta(String version, String size, String languages) {
    return 'Version $version · $size · $languages';
  }

  @override
  String packsDownload(String size) {
    return 'Download · $size';
  }

  @override
  String packsDownloading(int percent) {
    return 'Downloading… $percent%';
  }

  @override
  String packsInstalledVersion(String version, String size) {
    return 'Installed: $version · $size';
  }

  @override
  String packsUpdate(String version) {
    return 'Update to $version';
  }

  @override
  String get packsRemove => 'Remove';

  @override
  String get packsRemoveTitle => 'Remove this pack?';

  @override
  String get packsRemoveBody =>
      'The pack is removed from this device. You can download it again later.';

  @override
  String get packsFailNetwork =>
      'Couldn’t connect to the internet. Check your connection and try again.';

  @override
  String get packsFailServer => 'The server didn’t respond. Try again later.';

  @override
  String get packsFailIntegrity =>
      'The pack failed verification (size or SHA-256 mismatch) and wasn’t installed. Nothing else changed.';

  @override
  String get packsFailIncompatible =>
      'This pack needs a newer version of the app.';

  @override
  String get packsFailStorage =>
      'Couldn’t save to this device. Check free storage.';

  @override
  String get packsPlanned => 'Planned';

  @override
  String get packsPlannedBody =>
      'Published after independent review; the size is shown before download.';

  @override
  String get savedEmptyTitle => 'No bookmarks yet';

  @override
  String get savedEmptyBody => 'Select Save on a test card to keep it here.';

  @override
  String get sourcesTitle => 'Sources and licences';

  @override
  String get sourcesContent => 'Analyte cards';

  @override
  String get sourcesMethods => 'Calculators, QC and preanalytics';

  @override
  String get sourcesBody =>
      'Every published claim links to its original source, access date, scope and review status.';

  @override
  String get researchTitle => 'Research workspace';

  @override
  String get researchQuestion => 'Topic or research question';

  @override
  String get researchQuestionHint => 'Enter a topic';

  @override
  String get researchNotes => 'Aim and notes';

  @override
  String get researchNotesHint => 'Your own data and sources';

  @override
  String get researchSave => 'Save draft';

  @override
  String get researchSaved => 'Draft saved on this device';

  @override
  String get researchAutosave =>
      'The draft saves automatically on this device as you type.';

  @override
  String get researchOutline => 'Outline structure';

  @override
  String get researchStep1 => 'Question and aim';

  @override
  String get researchStep2 => 'Literature review';

  @override
  String get researchStep3 => 'Methods and real data';

  @override
  String get researchStep4 => 'Results, limitations and conclusions';

  @override
  String get researchNoFabrication =>
      'LabGuide never generates results, patient data or citations. Use only your own data and sources.';

  @override
  String get learnTitle => 'Learn with understanding';

  @override
  String get learnHeroTag => 'Visual biochemistry';

  @override
  String get learnHeroTitle => 'From molecule to practice';

  @override
  String get learnHeroBody => 'Topics, mechanisms and knowledge checks.';

  @override
  String get learnHeroCta => 'Explore topics';

  @override
  String get learnClassesSub => 'Teacher → assignment → student → results';

  @override
  String get learnQuiz => 'Explained quiz';

  @override
  String learnQuizSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count practice questions',
      one: '$count practice question',
    );
    return '$_temp0';
  }

  @override
  String get learnExam => 'Exam mode';

  @override
  String get learnExamSub => 'Time, topic and questions';

  @override
  String get learnLessonPlan => 'Lesson plan';

  @override
  String get learnLessonPlanSub => 'Teacher workspace';

  @override
  String quizProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get quizCorrect => 'Correct.';

  @override
  String get quizIncorrect => 'This answer is incorrect.';

  @override
  String get quizNext => 'Next';

  @override
  String get quizFinish => 'See result';

  @override
  String get quizDoneTitle => 'Practice complete';

  @override
  String quizScore(int correct, int total) {
    return '$correct of $total correct';
  }

  @override
  String get quizRestart => 'Try again';

  @override
  String quizBasis(String basis) {
    return 'Basis: $basis';
  }

  @override
  String get quizSources => 'Source';

  @override
  String get quizReviewNote => 'Practice questions are pending expert review.';

  @override
  String get quizMistakes => 'Review your mistakes';

  @override
  String get quizNoMistakes => 'No mistakes — well done.';

  @override
  String get quizYourAnswer => 'Your answer';

  @override
  String get quizCorrectAnswer => 'Correct answer';

  @override
  String get quizChooseTopic => 'Choose a topic';

  @override
  String quizTopicMixed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mixed: $count random questions',
      one: 'Mixed: 1 random question',
    );
    return '$_temp0';
  }

  @override
  String get quizTopicGeneral => 'Laboratory calculations';

  @override
  String quizQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String get quizOtherTopic => 'Another topic';

  @override
  String get quizTopicMistakes => 'Review my mistakes';

  @override
  String quizMastered(int correct, int total) {
    return '$correct of $total correct last time';
  }

  @override
  String get examTitle => 'Exam mode';

  @override
  String get classesTitle => 'Classes and assignments';

  @override
  String get classesSignInTitle => 'Sign in to use classes';

  @override
  String get classesSignInBody =>
      'Creating, joining and submitting assignments is tied to an account. Reading content stays open without sign-in.';

  @override
  String get classesSignIn => 'Sign in';

  @override
  String get classesUnavailableTitle => 'The class server isn\'t connected yet';

  @override
  String get classesUnavailableBody =>
      'Nothing is sent or stored. When it\'s connected, teachers see only their own classes and students see only their own results — checked on the server.';

  @override
  String get examSubtitle =>
      'A timed test: pick topics, number of questions and time. Works offline.';

  @override
  String get examActiveTitle => 'Unfinished exam';

  @override
  String examActiveBody(int answered, int total, String time) {
    return '$answered/$total answered · $time left';
  }

  @override
  String get examResume => 'Resume';

  @override
  String get examDiscard => 'Abandon exam';

  @override
  String get examDiscardTitle => 'Abandon this exam?';

  @override
  String get examDiscardBody =>
      'Your answers will be deleted and no result will be saved.';

  @override
  String get examDiscardAction => 'Abandon';

  @override
  String get examTopics => 'Topics';

  @override
  String get examAllTopics => 'All';

  @override
  String examPoolCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions in the selected topics',
      one: '1 question in the selected topics',
    );
    return '$_temp0';
  }

  @override
  String get examSettings => 'Settings';

  @override
  String get examCount => 'Number of questions';

  @override
  String examCountHint(int max) {
    return 'From 1 to $max';
  }

  @override
  String examCountError(int max) {
    return 'Enter a number from 1 to $max';
  }

  @override
  String examCountAll(int count) {
    return 'All $count';
  }

  @override
  String get examTime => 'Time, minutes';

  @override
  String get examTimeHint => '1–180 min · usually 1 min per question';

  @override
  String get examTimeError => 'Enter 1 to 180 minutes';

  @override
  String examMinutes(int count) {
    return '$count min';
  }

  @override
  String get examDraftNotice =>
      'These questions haven’t been expert-reviewed yet (draft). The result is for internal testing, not an official grade.';

  @override
  String get examRulesNotice =>
      'Questions and options are shuffled. Until you finish you can change answers and bookmark questions to revisit. The clock keeps running even if the app is closed; when time is up, the exam ends by itself.';

  @override
  String get examStart => 'Start exam';

  @override
  String get examReplaceTitle => 'You have an unfinished exam';

  @override
  String get examReplaceBody =>
      'Starting a new one deletes the previous exam and its answers.';

  @override
  String get examHistory => 'Result history';

  @override
  String get examHistoryEmpty =>
      'No exams yet. Your first result will appear here — it’s stored only on this device.';

  @override
  String examHistoryStats(int count, int avg, int best) {
    return 'Last $count: average $avg% · best $best%';
  }

  @override
  String examHistoryRow(String date, int correct, int total, String time) {
    return '$date · $correct/$total · $time';
  }

  @override
  String get examHistoryClear => 'Clear history';

  @override
  String get examHistoryClearBody =>
      'All exam results will be deleted from this device.';

  @override
  String examHistoryHidden(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count older results are saved',
      one: '1 older result is saved',
    );
    return '$_temp0 — the free plan shows the last $limit. Nothing has been deleted.';
  }

  @override
  String examProgressLabel(String values) {
    return 'Recent results: $values';
  }

  @override
  String get examProgressOld => 'Older → newer';

  @override
  String get examProgressLast => 'Latest';

  @override
  String get examSettled => 'Your previous exam ended because time ran out';

  @override
  String get examOpenResult => 'Result';

  @override
  String get examTitleAll => 'All topics';

  @override
  String examTitleTopics(String first, int more) {
    return '$first + $more more';
  }

  @override
  String get examReworkTitle => 'Practise your mistakes';

  @override
  String get examQuestionMissing =>
      'This question isn’t in the current content pack.';

  @override
  String get examMap => 'Question map';

  @override
  String get examFinish => 'Finish';

  @override
  String get examFinishTitle => 'Finish the exam?';

  @override
  String examFinishBody(int unanswered, int flagged) {
    return 'Unanswered: $unanswered, bookmarked: $flagged. You can’t change answers after finishing.';
  }

  @override
  String get examFinishBodyAll =>
      'All questions are answered. You can’t change answers after finishing.';

  @override
  String get examFlag => 'Bookmark';

  @override
  String get examFlagged => 'Bookmarked';

  @override
  String get examLegendAnswered => 'Answered';

  @override
  String get examLegendEmpty => 'Unanswered';

  @override
  String get examLegendFlagged => 'Bookmarked';

  @override
  String examQuestionN(int n) {
    return 'Question $n';
  }

  @override
  String examAnsweredOf(int answered, int total) {
    return '$answered/$total answered';
  }

  @override
  String get examPrev => 'Previous';

  @override
  String get examNext => 'Next';

  @override
  String examTimeLeft(String time) {
    return 'Time left: $time';
  }

  @override
  String examElapsed(String time) {
    return 'Elapsed: $time';
  }

  @override
  String get examNoActive => 'No active exam';

  @override
  String get examNoActiveBody =>
      'It was finished or abandoned. Set up and start a new one.';

  @override
  String get examNew => 'New exam';

  @override
  String get examSaving => 'Saving the result…';

  @override
  String get examResultTitle => 'Result';

  @override
  String get examResultMissing => 'Result not found';

  @override
  String get examBand90 => 'Excellent!';

  @override
  String get examBand70 => 'Good result!';

  @override
  String get examBand50 => 'Not bad — review your mistakes';

  @override
  String get examBand0 => 'Keep practising — you’ve got this';

  @override
  String get examCorrectN => 'Correct';

  @override
  String get examWrongN => 'Wrong';

  @override
  String get examSkippedN => 'Unanswered';

  @override
  String get examSpent => 'Time';

  @override
  String get examTimedOut => 'Time ran out — finished automatically';

  @override
  String examDeltaUp(int n) {
    return '+$n% vs last attempt';
  }

  @override
  String examDeltaDown(int n) {
    return '−$n% vs last attempt';
  }

  @override
  String get examDeltaSame => 'Same as last attempt';

  @override
  String examReworkMistakes(int count) {
    return 'Practise mistakes · $count';
  }

  @override
  String get examAnalysis => 'Mistake analysis';

  @override
  String examFilterMistakes(int count) {
    return 'Mistakes · $count';
  }

  @override
  String examFilterAll(int count) {
    return 'All · $count';
  }

  @override
  String get examNoAnswer => 'Not answered';

  @override
  String get examWrongTag => 'Wrong';

  @override
  String get examWhyWrong => 'Why not this answer';

  @override
  String get examNoSource =>
      'No source given — the question hasn’t been reviewed yet.';

  @override
  String get examSourceMissing =>
      'This exam’s question bank isn’t available in the app';

  @override
  String get examMultiHint => 'Several correct answers — select all';

  @override
  String get examNoExplanation =>
      'No explanation has been written for this question yet.';

  @override
  String get examByTopic => 'By topic';

  @override
  String get examByTopicNote => 'Weakest topic first — start there.';

  @override
  String get classesSubtitle =>
      'A teacher creates a class and sets assignments; students join with a code and solve them.';

  @override
  String get classesTryExam => 'Open the offline exam';

  @override
  String get classesLoading => 'Loading…';

  @override
  String get classesInvalid =>
      'The server didn’t accept this — check the fields.';

  @override
  String get classesCodeNotFound =>
      'No class found with this code. Check the code with your teacher.';

  @override
  String get classesCreate => 'Create a class';

  @override
  String get classesCreateSub => 'For teachers: get a code and set assignments';

  @override
  String get classesJoin => 'Join with a code';

  @override
  String get classesJoinSub =>
      'For students: the 8-character code from your teacher';

  @override
  String get classesRoleNote =>
      'Your role in the app grants no server rights: whoever creates a class is its teacher.';

  @override
  String get classesMine => 'My classes';

  @override
  String get classesEmpty => 'No classes yet';

  @override
  String get classesEmptyBody =>
      'Create a class or join one with the code from your teacher.';

  @override
  String get classesRoleTeacher => 'Teacher';

  @override
  String get classesRoleStudent => 'Student';

  @override
  String classesMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get classesCreateIntro =>
      'The account that creates a class becomes its teacher. Students join with the code you share.';

  @override
  String get classesGroupName => 'Class name';

  @override
  String get classesGroupNameHint => 'e.g. Biochemistry year 2';

  @override
  String classesLengthError(int min, int max) {
    return 'Enter $min–$max characters';
  }

  @override
  String get classesDisplayName => 'Your name in the class';

  @override
  String get classesDisplayNameHint => 'e.g. Anvar Aliyev';

  @override
  String get classesDisplayNameHintTeacher => 'e.g. Dr N. Karimova';

  @override
  String get classesDisplayNameNote =>
      'Your email isn’t shown — members see only this name.';

  @override
  String get classesCreateAction => 'Create class';

  @override
  String get classesCreated => 'Class created — send the code to your students';

  @override
  String get classesJoinIntro => 'Enter the code your teacher gave you.';

  @override
  String get classesCode => 'Invite code';

  @override
  String get classesCodeError => 'The code has 8 letters and digits';

  @override
  String get classesJoinNote =>
      'The teacher sees this name and your assignment results. Your email isn’t shown.';

  @override
  String get classesJoinAction => 'Join';

  @override
  String get classesJoined => 'You joined the class';

  @override
  String classesYouTeacher(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You’re the teacher · $count members',
      one: 'You’re the teacher · 1 member',
    );
    return '$_temp0';
  }

  @override
  String get classesYouStudent => 'You’re a student';

  @override
  String get classesGroupMissing =>
      'Class not found, or you’re no longer a member';

  @override
  String get classesBackToList => 'Back to classes';

  @override
  String get classesAssignments => 'Assignments';

  @override
  String get classesNewAssignment => 'New assignment';

  @override
  String get classesNoAssignmentsTeacher =>
      'No assignments yet. Pick topics and a number of questions from the bank to set one.';

  @override
  String get classesNoAssignmentsStudent => 'No assignments yet';

  @override
  String get classesNoAssignmentsStudentBody =>
      'When your teacher sets one, it will appear here.';

  @override
  String get classesNoDue => 'no due date';

  @override
  String classesDue(String date) {
    return 'due $date';
  }

  @override
  String classesSubmittedOf(int done, int total) {
    return '$done/$total submitted';
  }

  @override
  String classesMembersTitle(int count) {
    return 'Students · $count';
  }

  @override
  String get classesNoStudents => 'No students yet — share the code.';

  @override
  String get classesMemberNoWork => 'Nothing submitted yet';

  @override
  String classesMemberSummary(int done, int total, int avg) {
    return '$done/$total assignments · average $avg%';
  }

  @override
  String get classesRemove => 'Remove from class';

  @override
  String classesRemoveTitle(String name) {
    return 'Remove $name from the class?';
  }

  @override
  String get classesRemoveBody =>
      'They’ll no longer see the class or new assignments. Submitted results are kept.';

  @override
  String get classesRemoveAction => 'Remove';

  @override
  String classesStatusDone(int score, int total) {
    return 'Submitted · $score/$total';
  }

  @override
  String get classesStatusInProgress => 'In progress';

  @override
  String get classesStatusPending => 'Not sent';

  @override
  String get classesStatusOverdue => 'Past due';

  @override
  String get classesStatusNew => 'New';

  @override
  String get classesStudentNote =>
      'Your teacher sees only your name in the class and your assignment results.';

  @override
  String get classesLeave => 'Leave class';

  @override
  String get classesLeaveTitle => 'Leave the class?';

  @override
  String get classesLeaveBody =>
      'To rejoin you’ll need the teacher’s code. Results you’ve submitted stay with the teacher.';

  @override
  String get classesLeaveAction => 'Leave';

  @override
  String get classesInviteTitle => 'Invite code';

  @override
  String get classesInviteBody =>
      'Students: Learn → Classes and assignments → Join with a code.';

  @override
  String get classesCopyCode => 'Copy code';

  @override
  String get classesCopyInvite => 'Copy invitation text';

  @override
  String get classesCopied => 'Copied';

  @override
  String classesInviteText(String name, String code) {
    return 'Join the class “$name” in the LabGuide app: Learn → Classes and assignments → Join with a code. Code: $code';
  }

  @override
  String get classesNewAssignmentIntro =>
      'Pick topics and a number — questions are drawn from the bank at random.';

  @override
  String get classesAssignmentTitle => 'Assignment title';

  @override
  String get classesAssignmentTitleHint => 'e.g. Topic 1';

  @override
  String get classesTimeLimit => 'Time limit, minutes';

  @override
  String get classesTimeLimitHint =>
      'Optional, 1–180. Time runs from when the student starts and is checked on the server.';

  @override
  String get classesNoLimit => 'No limit';

  @override
  String get classesDueTitle => 'Due date';

  @override
  String get classesDueNone => 'No due date';

  @override
  String classesDueDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get classesDuePick => 'Pick a date';

  @override
  String get classesDueNoneBody =>
      'No due date — students can submit any time.';

  @override
  String classesDueAt(String date) {
    return 'Due by $date';
  }

  @override
  String classesPreview(int count) {
    return 'Selected questions · $count';
  }

  @override
  String get classesReshuffle => 'Reshuffle';

  @override
  String get classesKeyNotice =>
      'Students can’t see the answer key in advance — the server does the scoring. Each student submits once.';

  @override
  String get classesSendAssignment => 'Set assignment';

  @override
  String get classesAssignmentCreated => 'Assignment set';

  @override
  String get classesSubmitted => 'Answers submitted';

  @override
  String get classesSubmitNetwork =>
      'No connection — answers are saved on this device. Send them again later.';

  @override
  String get classesSubmitRejected =>
      'The server didn’t accept the answers: time or the due date ran out, or it was already submitted.';

  @override
  String get classesAssignmentMissing => 'Assignment not found';

  @override
  String get classesMetricQuestions => 'Questions';

  @override
  String get classesMetricLimit => 'Time limit';

  @override
  String get classesMetricDue => 'Due';

  @override
  String get classesMetricSubmitted => 'Submitted';

  @override
  String get classesMetricAverage => 'Average score';

  @override
  String get classesPendingTitle => 'Answers not sent yet';

  @override
  String get classesPendingBody =>
      'They’re saved on this device. Send them once you’re online — the server accepts them within the time limit.';

  @override
  String get classesResend => 'Send again';

  @override
  String get classesOverdueTitle => 'Past due';

  @override
  String get classesOverdueBody =>
      'This assignment can no longer be submitted.';

  @override
  String classesOutdatedPack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count questions in this assignment aren’t in your app’s content. Update the app.',
      one: '1 question in this assignment isn’t in your app’s content. Update the app.',
    );
    return '$_temp0';
  }

  @override
  String classesStartNotice(int minutes) {
    return 'Once you start you have $minutes min — the clock doesn’t stop, and answers are sent automatically when time is up. One submission only; sending needs internet.';
  }

  @override
  String get classesStartNoticeNoLimit =>
      'No time limit. Answers are sent once and can’t be resubmitted; sending needs internet.';

  @override
  String get classesStart => 'Start';

  @override
  String classesSubmittedAt(String date) {
    return 'Submitted $date';
  }

  @override
  String get classesServerScore => 'Scored by the server';

  @override
  String get classesResults => 'Results';

  @override
  String get classesColStudent => 'Student';

  @override
  String get classesColScore => 'Score · %';

  @override
  String get classesNotSubmitted => 'Not submitted';

  @override
  String get classesByQuestion => 'By question';

  @override
  String get classesByQuestionEmpty => 'No one has submitted yet.';

  @override
  String classesWrongOf(int wrong, int total) {
    return '$wrong/$total wrong';
  }

  @override
  String get classesSending => 'Sending answers…';

  @override
  String get classesMyProgress => 'My progress';

  @override
  String classesDoneOf(int done, int total) {
    return '$done/$total assignments done';
  }

  @override
  String classesAverage(int avg) {
    return 'Average score: $avg%';
  }

  @override
  String get classesStudentResultTitle => 'Student’s result';

  @override
  String get classesStudentAnswer => 'Student’s answer';

  @override
  String get classesInviteMore => 'Invite more students';

  @override
  String get profileTitle => 'Profile and settings';

  @override
  String get profileGuest => 'Guest';

  @override
  String get profileGuestSub => 'Content is open without an account';

  @override
  String get profileDemoSession => 'Demo session · debug build';

  @override
  String get profileRole => 'Role';

  @override
  String get profileRoleSub => 'Home adapts to your role';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get profilePurchase => 'Subscription and restore';

  @override
  String get profilePurchaseSub => 'Free · Pro';

  @override
  String get profilePrivacy => 'Privacy and help';

  @override
  String get profilePrivacySub => 'Data and account controls';

  @override
  String get supportTitle => 'Feedback & help';

  @override
  String get supportSub => 'Suggestion, bug or question — replies arrive here';

  @override
  String get supportNew => 'New request';

  @override
  String get supportEmptyTitle => 'No requests yet';

  @override
  String get supportEmptyBody =>
      'Send a suggestion, report a bug or ask a question — the reply appears here.';

  @override
  String get supportKind => 'Type';

  @override
  String get supportKindSuggestion => 'Suggestion';

  @override
  String get supportKindBug => 'Bug';

  @override
  String get supportKindQuestion => 'Question';

  @override
  String get supportSubject => 'Subject';

  @override
  String get supportSubjectHint => 'In short: what is it about?';

  @override
  String get supportMessage => 'Message';

  @override
  String get supportMessageHint =>
      'Details: which screen, what you did and what you expected';

  @override
  String get supportAttach => 'Attach a screenshot (optional)';

  @override
  String get supportAttachRemove => 'Remove image';

  @override
  String get supportAttachTooLarge =>
      'The image is larger than 5 MB. Choose a smaller one.';

  @override
  String get supportAttachType => 'PNG or JPEG only.';

  @override
  String get supportPhiNotice =>
      'Make sure the screenshot shows no patient name, date of birth, record number or other personal data.';

  @override
  String get supportSend => 'Send';

  @override
  String get supportSent => 'Request sent';

  @override
  String get supportReplyHint => 'Write a reply…';

  @override
  String get supportTeam => 'LabGuide team';

  @override
  String get supportYou => 'You';

  @override
  String get supportUser => 'User';

  @override
  String get supportHumanReplies =>
      'Replies are written by the LabGuide team; nothing is sent automatically.';

  @override
  String get supportStatusNew => 'New';

  @override
  String get supportStatusInReview => 'In review';

  @override
  String get supportStatusAnswered => 'Answered';

  @override
  String get supportStatusClosed => 'Closed';

  @override
  String get supportUnread => 'New reply';

  @override
  String supportUnreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'replies',
      one: 'reply',
    );
    return '$count new $_temp0';
  }

  @override
  String get supportSignInTitle => 'Sign in to send a request';

  @override
  String get supportSignInBody =>
      'Signing in with email lets us deliver the reply to you. Data on this device stays as it is.';

  @override
  String get supportUnavailableTitle => 'Server not connected yet';

  @override
  String get supportUnavailableBody =>
      'This build has no account, feedback or groups server yet. Once connected, it works right here.';

  @override
  String get errNetwork =>
      'Couldn’t connect. Check the internet and try again.';

  @override
  String get errRateLimited => 'Too many requests. Try again a bit later.';

  @override
  String get errInvalidSupport =>
      'The subject needs at least 3 characters and the message can’t be empty.';

  @override
  String get errForbidden => 'You don’t have access to this.';

  @override
  String get errSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errGeneric => 'That didn’t work. Please try again.';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteSub =>
      'Removes your server account, requests and group memberships';

  @override
  String get accountDeleteTitle => 'Delete your account?';

  @override
  String get accountDeleteBody =>
      'Your account, requests, attachments and group results are permanently removed from the server. This can’t be undone. QC records and bookmarks on this device are deleted separately.';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get adminTitle => 'Admin panel';

  @override
  String get adminSub => 'Statistics, requests, users';

  @override
  String get adminMfaTitle => 'Two-step protection';

  @override
  String get adminMfaEnrollBody =>
      'The admin panel needs an authenticator app (Google Authenticator, Microsoft Authenticator, 1Password…). Add the key to the app and enter the 6-digit code it shows.';

  @override
  String get adminMfaVerifyBody =>
      'Enter the 6-digit code from your authenticator app.';

  @override
  String get adminMfaSecret => 'Key';

  @override
  String get adminMfaCopy => 'Copy key';

  @override
  String get adminMfaOpen => 'Open in authenticator';

  @override
  String get adminMfaCode => '6-digit code';

  @override
  String get adminMfaVerify => 'Verify';

  @override
  String get adminMfaWrong =>
      'The code is wrong or expired. Enter the current code from the app.';

  @override
  String get adminCopied => 'Copied';

  @override
  String get adminForbiddenTitle => 'Admins only';

  @override
  String get adminForbiddenBody =>
      'Admin access is granted by the server — the role or email in the app can’t change that.';

  @override
  String get adminStats => 'Statistics';

  @override
  String get adminRegistered => 'Registered';

  @override
  String get adminNewToday => 'New today';

  @override
  String get adminNew7 => 'New, 7 days';

  @override
  String get adminNew30 => 'New, 30 days';

  @override
  String get adminActiveToday => 'Active today';

  @override
  String get adminActive7 => 'Active, 7 days';

  @override
  String get adminActive30 => 'Active, 30 days';

  @override
  String get adminDefinitions =>
      'Registered — an account whose email was confirmed with a code; guests and unconfirmed sign-ups aren’t counted. New — the day the email was first confirmed. Active — opened the app while signed in at least once in the period. Days use Tashkent time; “7 days” includes today.';

  @override
  String get adminByRole => 'By role';

  @override
  String get adminByLanguage => 'By language';

  @override
  String adminNoProfile(int count) {
    return 'No profile yet: $count';
  }

  @override
  String get adminBilling => 'Free / Pro: billing not connected — no data';

  @override
  String get adminInbox => 'Requests';

  @override
  String adminAwaiting(int count) {
    return 'Awaiting reply: $count';
  }

  @override
  String get adminAllStatuses => 'All';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminAudit => 'Action log';

  @override
  String get adminAuditEmpty => 'No actions yet';

  @override
  String get adminSearchHint => 'Search by email';

  @override
  String get adminAllRoles => 'All roles';

  @override
  String get adminAllLanguages => 'All languages';

  @override
  String get adminShowEmail => 'Show email (logged)';

  @override
  String get adminReviewer => 'Content reviewer';

  @override
  String adminPage(int from, int to, int total) {
    return '$from–$to of $total';
  }

  @override
  String get adminPrev => 'Previous';

  @override
  String get adminNext => 'Next';

  @override
  String adminRegisteredOn(String date) {
    return 'Registered: $date';
  }

  @override
  String adminLastSeen(String date) {
    return 'Last active: $date';
  }

  @override
  String get adminNoUsers => 'No users found';

  @override
  String get adminReplyHint => 'Write your reply';

  @override
  String get adminSendReply => 'Send reply';

  @override
  String get adminStatus => 'Status';

  @override
  String get adminRefresh => 'Refresh';

  @override
  String get adminActionSupportReply => 'Replied to request';

  @override
  String get adminActionSupportStatus => 'Request status changed';

  @override
  String get adminActionRevealEmail => 'Email viewed';

  @override
  String get adminActionReviewerGranted => 'Reviewer access granted';

  @override
  String get adminActionReviewerRevoked => 'Reviewer access revoked';

  @override
  String get adminActionAdminGranted => 'Admin access granted';

  @override
  String get adminActionAdminRevoked => 'Admin access revoked';

  @override
  String get profileSignIn => 'Sign in with email';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileRestartSetup => 'Restart setup';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutBody =>
      'Bookmarks, QC records, notes and practice progress stay on this device. If someone else will use it, delete them too.';

  @override
  String get profileSignOutDelete => 'Sign out and delete';

  @override
  String profileVersion(String version) {
    return 'Version $version';
  }

  @override
  String get purchaseTitle => 'LabGuide Pro';

  @override
  String get purchaseFree =>
      'Free: leukocyte differential counter, percentages and absolute counts, core guides, the last 3 results in history.';

  @override
  String get purchasePro =>
      'Pro (monthly or yearly): unlimited results history, PDF export, extended practice, full preparation for the qualification category exam.';

  @override
  String get purchaseNotice =>
      'Store products aren\'t connected. Prices will come from the App Store / Google Play in your currency. Nothing is charged here, and features that aren\'t built yet are not sold.';

  @override
  String get purchaseSubscribe => 'Subscribe';

  @override
  String get purchaseRestore => 'Restore purchases';

  @override
  String get purchaseStatusTitle => 'Status';

  @override
  String get purchaseStatusAllOpen =>
      'Payments aren’t enabled yet; every feature is open in TestFlight.';

  @override
  String get purchaseStatusBillingOff =>
      'Payments aren’t enabled yet. Free features work fully; Pro will be switched on once the price is approved.';

  @override
  String purchaseStatusPro(String date) {
    return 'Pro is active · until $date';
  }

  @override
  String get purchaseStatusProNoEnd => 'Pro is active';

  @override
  String purchaseStatusOffline(String date) {
    return 'Offline: last checked $date';
  }

  @override
  String get purchaseStatusFree => 'Current plan: free';

  @override
  String get privacyTitle => 'Privacy and help';

  @override
  String get privacyBody =>
      'In guest mode the app sends nothing to a server: settings, bookmarks, QC records, your instruments and practice results stay on this device (they may be included in the device backup). If you sign in with email, the server stores your email, role, language, last active day, your support requests and group results; no ad tracking. You can delete your account at any time.';

  @override
  String get privacyTerms => 'Terms of use';

  @override
  String get privacyTermsSub => 'Final text to be prepared';

  @override
  String get privacyDeleteLocal => 'Delete local data';

  @override
  String get privacyDeleteLocalSub =>
      'Settings, bookmarks, drafts, QC records and practice progress';

  @override
  String get privacyDeleteConfirmTitle => 'Delete local data?';

  @override
  String get privacyDeleteConfirmBody =>
      'Settings, bookmarks, drafts, all QC records (runs and targets) and practice progress on this device will be removed. This can’t be undone — if needed, copy a QC backup first (Lab → Quality control).';

  @override
  String get privacyDeleted => 'Local data deleted';

  @override
  String get termsTitle => 'Terms of use';

  @override
  String get termsBody =>
      'Final terms, the privacy policy and clinical-use boundaries will be prepared before release. LabGuide is a reference and learning tool: it doesn\'t diagnose, prescribe or replace your laboratory\'s procedures.';

  @override
  String citePage(String page) {
    return 'p. $page';
  }

  @override
  String get rightsUnknown => 'Distribution rights not confirmed';

  @override
  String get rightsPersonal => 'Personal study only — not distributed';

  @override
  String get rightsPermitted => 'Distribution permission recorded';

  @override
  String get rightsDenied => 'Distribution not permitted';

  @override
  String get catBiochemistry => 'Biochemistry';

  @override
  String get catClinicalLab => 'Clinical laboratory';

  @override
  String get catInstruments => 'Instruments';

  @override
  String get catMethods => 'Methods';

  @override
  String get catTests => 'Laboratory tests';

  @override
  String get kindBook => 'Book';

  @override
  String get kindManual => 'Manual';

  @override
  String get kindMethod => 'Method';

  @override
  String get kindIfu => 'IFU';

  @override
  String get kindArticle => 'Article';

  @override
  String get kindQuestionSet => 'Question set';

  @override
  String get kindWebsite => 'Website';

  @override
  String libAccessOpen(String licence) {
    return 'Open licence · $licence';
  }

  @override
  String get libAccessFree => 'Free to read · link only';

  @override
  String get libAccessCatalog => 'Catalogue record only';

  @override
  String get libOpenSource => 'Open the official page';

  @override
  String libChecked(String date) {
    return 'Page and licence checked: $date';
  }

  @override
  String libItemPack(String size) {
    return 'Offline pack · $size';
  }

  @override
  String get libItemNoPack => 'Not available as a shared offline pack';

  @override
  String libItemSupersedes(String title) {
    return 'Newer edition of: $title';
  }

  @override
  String get libForYou => 'For you';

  @override
  String get libMoreSections => 'More sections';

  @override
  String get libSearchEntry => 'Search books, authors, topics';

  @override
  String libBooksCount(int count) {
    return '$count sources · search and filters';
  }

  @override
  String get libIntake => 'How materials are added';

  @override
  String get libIntakeSub =>
      'For teachers and editors: what to send, rights, review';

  @override
  String get libContinueReading => 'Continue reading';

  @override
  String get libSearchLabel => 'Search the library';

  @override
  String get libSearchHint => 'Title, author, topic…';

  @override
  String get libFilterLanguage => 'Language';

  @override
  String get libFilterTopic => 'Topic';

  @override
  String get libFilterType => 'Type';

  @override
  String get libFilterSectionField => 'Field';

  @override
  String get libFilterSectionGroup => 'Test group';

  @override
  String get libFilterSectionKind => 'Material type';

  @override
  String get libFilterSectionOpen => 'How it opens';

  @override
  String libFilterChoose(String filter) {
    return '$filter: choose';
  }

  @override
  String libResultCount(int shown, int total) {
    return '$shown of $total materials';
  }

  @override
  String get libClearFilters => 'Clear';

  @override
  String get libFilteredEmptyTitle => 'No materials match these filters';

  @override
  String get libFilteredEmptyBody =>
      'Remove one filter or try another word — for example an author’s surname or “urine”.';

  @override
  String get libOpenLink => 'Link · external website';

  @override
  String libOpenLinkHint(String host) {
    return 'Opens in your browser: $host';
  }

  @override
  String get libOpenInApp => 'In-app file';

  @override
  String get libOpenInAppHint => 'Read inside the app — no internet needed';

  @override
  String get libOpenDownload => 'Downloadable book';

  @override
  String libOpenDownloadHint(String size) {
    return 'Read in the app after download · $size';
  }

  @override
  String get libOpenPending => 'Pending';

  @override
  String get libOpenPendingHint => 'Not received yet — cannot be opened';

  @override
  String get libOpenReceivedHint =>
      'File received and being checked — not available yet';

  @override
  String get libOpenRecordHint =>
      'No distribution rights recorded — not opened in the app';

  @override
  String get libOpenLinkShort => 'Link';

  @override
  String get libOpenInAppShort => 'In the app';

  @override
  String get libOpenDownloadShort => 'Download';

  @override
  String get libOpenRecordShort => 'Record only';

  @override
  String get libItemRead => 'Read';

  @override
  String libItemContinue(int page) {
    return 'Continue from page $page';
  }

  @override
  String get libItemCannotOpen => 'Cannot be opened';

  @override
  String get libDownloadUnavailable =>
      'The download server is not connected yet — the book can’t be downloaded for now.';

  @override
  String get libDetailsTitle => 'Details';

  @override
  String get libFieldAuthors => 'Author';

  @override
  String get libFieldYear => 'Year';

  @override
  String get libFieldEdition => 'Edition';

  @override
  String get libFieldPublisher => 'Publisher';

  @override
  String get libFieldAccess => 'Access';

  @override
  String get libFieldStatus => 'Status';

  @override
  String get libFieldRights => 'Distribution rights';

  @override
  String libFieldRightsRecorded(String date, String by) {
    return 'Recorded: $date · $by';
  }

  @override
  String get libFieldTopics => 'Topics';

  @override
  String get libFieldPages => 'Pages';

  @override
  String get libStateNotReceived => 'Not received yet';

  @override
  String get libStateReceived => 'Received, being checked';

  @override
  String get libStateCataloged => 'Catalogued';

  @override
  String get libStateLinked => 'Linked to cards';

  @override
  String get libStateReviewed => 'Approved by a teacher';

  @override
  String get libProvidedByTeacher => 'Provided by a teacher';

  @override
  String get libItemNotFound => 'Material not found';

  @override
  String get libItemNotFoundBody =>
      'The content pack may have been updated. Go back to the catalog.';

  @override
  String get libBackToCatalog => 'Back to catalog';

  @override
  String get readerTitle => 'Reader';

  @override
  String readerPageOf(int page, int total) {
    return '$page of $total';
  }

  @override
  String get readerToc => 'Contents';

  @override
  String get readerTocEmpty => 'This file has no table of contents';

  @override
  String get readerTocEmptyBody =>
      'Go to a page or bookmark the place you need.';

  @override
  String get readerBookmarks => 'Bookmarks';

  @override
  String get readerAddBookmark => 'Bookmark this page';

  @override
  String get readerBookmarkName => 'Bookmark name';

  @override
  String get readerBookmarkNameHint => 'For example: key table';

  @override
  String readerBookmarkSaved(int page) {
    return 'Bookmark saved: page $page';
  }

  @override
  String get readerBookmarkRemoved => 'Bookmark removed';

  @override
  String get readerBookmarkRemove => 'Remove bookmark';

  @override
  String get readerBookmarksEmpty => 'No bookmarks yet';

  @override
  String get readerBookmarksEmptyBody =>
      'On the page you need, tap “Bookmark this page” — then return with one tap.';

  @override
  String readerPageLabel(int page) {
    return 'Page $page';
  }

  @override
  String get readerGoTo => 'Go to page';

  @override
  String get readerGoToShort => 'Page';

  @override
  String readerGoToHint(int total) {
    return '1 to $total';
  }

  @override
  String readerGoToError(int total) {
    return 'Enter a number from 1 to $total';
  }

  @override
  String get readerGo => 'Go';

  @override
  String get readerSave => 'Save';

  @override
  String get readerRenameBookmark => 'Rename bookmark';

  @override
  String get libFieldProvidedBy => 'Provided by';

  @override
  String get libQueryEmptyBody =>
      'Try another word — for example an author’s surname, “urine” or “biochemistry”.';

  @override
  String get readerZoomIn => 'Zoom in';

  @override
  String get readerZoomOut => 'Zoom out';

  @override
  String readerResumed(int page) {
    return 'Resumed at page $page';
  }

  @override
  String get readerFromStart => 'From start';

  @override
  String get readerLoading => 'Opening the file…';

  @override
  String get readerFileMissing => 'File not found';

  @override
  String get readerFileMissingBody =>
      'This file isn’t in the app. Try updating the app.';

  @override
  String get readerFileCorrupted => 'The file failed verification';

  @override
  String get readerFileCorruptedBody =>
      'The file size or checksum doesn’t match the catalog — it may be damaged or replaced, so it wasn’t opened.';

  @override
  String get readerOpenFailed => 'Couldn’t open the PDF';

  @override
  String get readerBlockedTitle => 'Not available in the app';

  @override
  String get readerBlockedRights =>
      'Only files with fully recorded distribution rights open in the app. This material has no such file.';

  @override
  String get readerBookmarkedPage => 'This page is bookmarked';

  @override
  String get intakeTitle => 'Adding materials';

  @override
  String get intakeSubtitle => 'A short guide for teachers and editors';

  @override
  String intakeStatus(int count) {
    return 'Materials from teachers: $count. The list grows as materials arrive.';
  }

  @override
  String get intakeWhatTitle => '1. What to send';

  @override
  String get intakeWhat1 =>
      'The book, manual, method or IFU file (PDF) and its details: title, author, year and edition, publisher, ISBN, language.';

  @override
  String get intakeWhat2 =>
      'Test questions: the question, options, the correct answer, an explanation for each option and the source page.';

  @override
  String get intakeWhat3 =>
      'If there is an old and a new edition — both: differences are reviewed separately.';

  @override
  String get intakeRightsTitle => '2. Distribution rights';

  @override
  String get intakeRights1 =>
      'A shared PDF does not by itself mean it may be distributed to everyone.';

  @override
  String get intakeRights2 =>
      'For a file to open in the app for everyone, the rights are fully recorded: who granted them (author or publisher), when, who recorded it, and the evidence — a permission letter or a licence link.';

  @override
  String get intakeRights3 =>
      'Without that record, the material stays a catalog entry only or for personal use.';

  @override
  String get intakeReviewTitle => '3. How it is checked';

  @override
  String get intakeStep1 => 'Pending — the material hasn’t arrived yet.';

  @override
  String get intakeStep2 => 'Received — the file arrived and was logged.';

  @override
  String get intakeStep3 =>
      'Catalogued — title, author and edition were checked. Only then can it be cited.';

  @override
  String get intakeStep4 =>
      'Linked — tied to test cards and lessons with page numbers.';

  @override
  String get intakeStep5 =>
      'Approved — a teacher reviewed it. Until then questions stay as “Draft”.';

  @override
  String get intakeConflict =>
      'If an old and a new source disagree, neither is written as fact — both positions go to a reviewer.';

  @override
  String get intakeNeverTitle => 'What we never do';

  @override
  String get intakeNever1 =>
      'Show a material that hasn’t arrived as “available”.';

  @override
  String get intakeNever2 =>
      'Guess a page number or write anything the source doesn’t say.';

  @override
  String get intakeNever3 =>
      'Distribute a book to everyone without recorded rights.';

  @override
  String get intakeContactTitle => '4. Contact';

  @override
  String get intakeContactBody =>
      'Write to the LabGuide team about the material: title, author, edition and rights holder. How to hand over the file is agreed with the team — PDFs can’t be uploaded through the app.';

  @override
  String get intakeContactAction => 'Write to the LabGuide team';

  @override
  String get libReview => 'Review queue';

  @override
  String get libReviewSub => 'Source discrepancies and drafts';

  @override
  String get reviewDiscrepancies => 'Source discrepancies';

  @override
  String get rvGateTitle => 'Reviewers only';

  @override
  String get rvGateBody =>
      'Reviewer rights are granted by an admin. An in-app role (for example, “Teacher”) does not grant them.';

  @override
  String get rvSignInTitle => 'Sign in to review';

  @override
  String get rvAdminReadOnly =>
      'As an admin you can see decisions. To review, grant your account reviewer rights (Admin → Users).';

  @override
  String get rvTabCards => 'Cards';

  @override
  String get rvTabQuestions => 'Questions';

  @override
  String get rvTabDiscrepancies => 'Discrepancies';

  @override
  String rvMine(String decision) {
    return 'Your decision: $decision';
  }

  @override
  String get rvNotSeen => 'Not reviewed by you yet';

  @override
  String rvCount(int count) {
    return 'Decisions: $count';
  }

  @override
  String get rvApprove => 'Approve';

  @override
  String get rvChanges => 'Changes needed';

  @override
  String get rvDecisionApprove => 'approved';

  @override
  String get rvDecisionChanges => 'changes requested';

  @override
  String get rvComment => 'Comment';

  @override
  String get rvCommentHint => 'What is wrong or what to check (source, page)';

  @override
  String get rvCommentRequired => 'Write a comment for “Changes needed”.';

  @override
  String get rvSubmit => 'Submit decision';

  @override
  String get rvSubmitted => 'Decision recorded';

  @override
  String get rvNotAuto =>
      'A decision does not change the card status by itself: after editorial review it becomes “Reviewed” in the next content pack.';

  @override
  String get rvHistory => 'Decision history';

  @override
  String get rvYou => 'You';

  @override
  String get rvReviewer => 'Reviewer';

  @override
  String get rvNoHistory => 'No decisions yet';

  @override
  String get rvOpenCard => 'Open card';

  @override
  String get rvCorrect => 'Correct answer';

  @override
  String get rvBasis => 'Basis';

  @override
  String get rvYourDecision => 'Your decision';

  @override
  String get rvAllDone => 'All reviewed';

  @override
  String get analytePreparedBy => 'Prepared by';

  @override
  String get analyteEditorial => 'LabGuide editorial team';

  @override
  String get analyteSourcesChecked => 'Sources accessed';

  @override
  String get reviewDiscrepanciesBody =>
      'When older and newer sources disagree, both positions are listed here for expert review. Neither is published as fact until resolved.';

  @override
  String get reviewNoDiscrepancies => 'No open discrepancies.';

  @override
  String reviewDraftQuestions(int count) {
    return 'Draft questions: $count';
  }

  @override
  String reviewDraftCards(int count) {
    return 'Cards awaiting expert review: $count';
  }

  @override
  String reviewCatalog(int count) {
    return 'Catalogued materials: $count';
  }

  @override
  String reviewField(String field) {
    return 'Field: $field';
  }

  @override
  String get quizDraftTag => 'Draft · not reviewed';

  @override
  String get lessonsTitle => 'Lesson topics';
}
