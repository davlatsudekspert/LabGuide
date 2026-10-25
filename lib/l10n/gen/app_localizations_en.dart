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
      'No account is needed to read content. Sign-in is used for sync and classes.';

  @override
  String get welcomeBenefitDoctorTitle => 'For doctors';

  @override
  String get welcomeBenefitDoctorBody =>
      'Results, interfering factors and tests by condition';

  @override
  String get welcomeBenefitLabTitle => 'For lab specialists';

  @override
  String get welcomeBenefitLabBody =>
      'Quality control, sampling, instruments and calculators';

  @override
  String get welcomeBenefitLearnTitle => 'For students and teachers';

  @override
  String get welcomeBenefitLearnBody =>
      'Topics, explained questions, exams and groups';

  @override
  String get stateLoading => 'Loading…';

  @override
  String get homeTileTests => 'Ranges, causes, meaning';

  @override
  String get homeTileCalculators => 'eGFR, ACR, dilution and more';

  @override
  String get homeTileSampling => 'Tubes, storage, transport';

  @override
  String get homeTileSaved => 'Quick access to bookmarks';

  @override
  String get homeTileDiff => 'Counter and cell atlas';

  @override
  String get homeTileCalibration => 'Analyzer, reagent and IFU match';

  @override
  String get homeTileInstruments => 'Principles and methods';

  @override
  String get homeTileExam => 'Timed practice exam';

  @override
  String get homeTileTopics => 'Topic, explanation, practice';

  @override
  String get homeTileClasses => 'Students and assignments';

  @override
  String get homeTileLecture => 'Slides and screen casting';

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
  String get authUnavailableTitle => 'Email sign-in isn’t connected yet';

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
      'The role only adapts the home screen. It doesn’t grant access to other people’s classes or data.';

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
  String get homeHeroDoctorCta => 'Search tests';

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
      'The guide helps plan testing. Clinical assessment and the final decision rest with the clinician. The text is based on the sources listed on each card.';

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
      'LabGuide guide. Not a diagnostic tool — the final decision rests with the clinician.';

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
  String get homeHeroStudentCta => 'Start daily questions';

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
  String get featureSaved => 'Saved';

  @override
  String get featureCalibration => 'Calibration';

  @override
  String get featureQc => 'Quality control (QC)';

  @override
  String get featureTopics => 'Topics';

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
  String get statusVerified => 'Verified';

  @override
  String get statusPublished => 'Published';

  @override
  String get statusSourcedSample => 'Source-based';

  @override
  String get statusStructureOnly => 'Structure only';

  @override
  String get contentLoading => 'Loading content…';

  @override
  String get contentErrorTitle => 'Content couldn’t be loaded';

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
  String get analyteNotFound => 'This test card wasn’t found.';

  @override
  String get analyteStructureOnlyTitle => 'Content in preparation';

  @override
  String get analyteStructureOnlyBody =>
      'This card shows the structure only for now. Clinical text is added together with its sources — generic text is never shown as ready.';

  @override
  String get analyteNotWritten =>
      'Not written yet: the text is added together with its sources.';

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
      'No reference interval is given here. Use the interval on your laboratory’s report: it depends on the method, specimen and population.';

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
      'LabGuide doesn’t interpret individual results or suggest diagnoses or doses.';

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
  String get analyteReview => 'Preparation and sources';

  @override
  String get analyteReviewPending => 'Expert review pending';

  @override
  String get analyteReviewApproved => 'Reviewed';

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
  String get labHeroEyebrow => 'Instrument → reagent → method';

  @override
  String get labHeroTitle => 'Calibration';

  @override
  String get labSectionsTitle => 'Sections and atlases';

  @override
  String get labToolsTitle => 'Work tools';

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
  String get labPreanalyticsSub =>
      'Collecting, storing and transporting samples';

  @override
  String get labCalculatorsSub => 'eGFR, ACR, dilution and more';

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
      'Calibration parameters are shown only from a verified IFU that matches the manufacturer, model, reagent REF, IFU revision and calibrator lot. Use the manufacturer’s current IFU.';

  @override
  String calCatalogCount(int count) {
    return 'Verified IFU records in this build: $count';
  }

  @override
  String get calBrandWarning =>
      'A brand name (e.g. Mindray or HUMAN) doesn’t mean all models share settings. The reagent IFU and the instrument manual are separate documents.';

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
  String get qcJumpToAddRun => 'Enter a run below';

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
  String get preTitle => 'Preanalytics';

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
      'Tube color, time and temperature depend on the specific tube, method and instructions. The times above are general guidance from the WHO table; your laboratory’s rules take priority.';

  @override
  String get diffTitle => 'Differential count';

  @override
  String get diffSubtitle => 'Identify, count and interpret white cells';

  @override
  String get diffLabCardBody =>
      'Manual count tally, cell atlas and interpretation';

  @override
  String get diffHeroTitle => 'Read a differential with confidence';

  @override
  String get diffHeroBody =>
      'Cell schematics, a big-button tally counter, interpretation and smear technique in one place.';

  @override
  String get diffStartCount => 'Start counting';

  @override
  String diffResumeCount(int count, int target) {
    return 'Continue counting ($count/$target)';
  }

  @override
  String get diffCellsTitle => 'Cell identification';

  @override
  String diffCellsSub(int count) {
    return '$count cells: size, nucleus, cytoplasm, granules';
  }

  @override
  String get diffConfusionsTitle => 'Common mix-ups';

  @override
  String get diffConfusionsSub =>
      'Reactive lymphocyte or monocyte? Band or segmented?';

  @override
  String get diffCounterTitle => 'Tally counter';

  @override
  String get diffCounterSub => 'Tap +1, long-press −1; 100 or 200 cells';

  @override
  String get diffHistoryTitle => 'Saved results';

  @override
  String diffHistorySub(int count) {
    return '$count results — on this device only';
  }

  @override
  String get diffInterpretTitle => 'Interpretation';

  @override
  String get diffInterpretSub =>
      'Left shift, neutrophilia, lymphocytosis and more';

  @override
  String get diffTechniqueTitle => 'Smear technique and errors';

  @override
  String get diffTechniqueSub => 'Making, staining, where to count';

  @override
  String get diffQuizTitle => '“Which cell is this?” practice';

  @override
  String diffQuizSub(int count) {
    return '$count questions with schematic images';
  }

  @override
  String get diffLearnSub =>
      'Cell atlas, tally counter and “Which cell is this?” practice';

  @override
  String get diffSourcesTitle => 'Sources';

  @override
  String get diffSchematicCaption =>
      'Schematic drawing (made by LabGuide) — not a micrograph';

  @override
  String get diffScaleNote =>
      'All schematics share one scale; the surrounding red cells (~7.5 µm) help compare size.';

  @override
  String get diffRelatedCards => 'Test cards';

  @override
  String get diffSize => 'Size';

  @override
  String get diffNucleus => 'Nucleus';

  @override
  String get diffCytoplasm => 'Cytoplasm';

  @override
  String get diffGranules => 'Granules';

  @override
  String get diffKeySign => 'Key sign';

  @override
  String get diffSeenIn => 'When it is seen';

  @override
  String get diffReferTitle => 'Refer to a physician or hematologist';

  @override
  String get diffReferBody =>
      'If you see a blast or a cell you cannot identify, do not interpret it yourself. Have a hematologist or physician review the smear according to your laboratory’s procedure.';

  @override
  String get diffCompareA => 'Left';

  @override
  String get diffCompareB => 'Right';

  @override
  String get diffFeature => 'Feature';

  @override
  String get diffTip => 'Tip';

  @override
  String get diffOpenCell => 'Details';

  @override
  String get diffTargetLabel => 'Cells to count';

  @override
  String get diffWbcLabel => 'White cell count (WBC), ×10⁹/L — optional';

  @override
  String get diffWbcHint => 'e.g. 7.5';

  @override
  String get diffWbcInvalid => 'Enter a positive number (e.g. 7.5)';

  @override
  String get diffTapHint => 'Tap: +1 · Long-press: −1';

  @override
  String get diffUndo => 'Undo last';

  @override
  String get diffReset => 'Start over';

  @override
  String get diffResetTitle => 'Clear the count?';

  @override
  String diffResetBody(int count) {
    return '$count counted cells will be cleared.';
  }

  @override
  String get diffResetConfirm => 'Clear';

  @override
  String diffDoneTitle(int target) {
    return '$target cells counted';
  }

  @override
  String get diffDoneBody =>
      'Counting has stopped. Check the result, then save or copy it.';

  @override
  String get diffBlocked => 'Target reached — tap not added';

  @override
  String get diffResultTitle => 'Result';

  @override
  String get diffColCell => 'Cell';

  @override
  String get diffColCount => 'Count';

  @override
  String get diffColAbs => '×10⁹/L';

  @override
  String get diffAbsNeedWbc => 'Enter the WBC to see absolute counts.';

  @override
  String get diffOtherWarning =>
      '“Other” cells were counted. If they are blasts or unidentified cells, have a hematologist or physician review the smear.';

  @override
  String get diffSave => 'Save to history';

  @override
  String get diffSaved => 'Result saved (on this device only)';

  @override
  String get diffLabelField => 'Sample label (optional, no patient names)';

  @override
  String get diffLabelHint => 'e.g. sample 12';

  @override
  String get diffCopy => 'Copy';

  @override
  String get diffCopied => 'Result copied';

  @override
  String diffCopyHeader(int total) {
    return 'Differential count ($total cells)';
  }

  @override
  String get diffCopyFooter =>
      'LabGuide · manual count. Reference intervals: see the laboratory report form.';

  @override
  String diffWbcLine(String value) {
    return 'WBC: $value ×10⁹/L';
  }

  @override
  String diffButtonSemantics(String cell, int count) {
    return '$cell: $count. Tap to add, long-press to subtract.';
  }

  @override
  String get diffDecrementAction => 'Subtract one';

  @override
  String get diffEfEntry => 'Microscope mode: eyes-free counting';

  @override
  String get diffEfEntrySub =>
      'Large screen zones; a sound and vibration on every tap';

  @override
  String get diffEfTitle => 'Eyes-free counting';

  @override
  String get diffEfExit => 'Exit';

  @override
  String get diffEfUndoZone => 'Undo';

  @override
  String get diffEfUndoHint => 'or tap with two fingers';

  @override
  String diffEfZoneSemantics(String cell, int count, int total, int target) {
    return '$cell: $count. Total $total / $target.';
  }

  @override
  String diffEfAnnounce(String cell, int count, int total) {
    return '$cell $count. Total $total';
  }

  @override
  String diffEfUndone(String cell, int total) {
    return 'Undone: $cell. Total $total';
  }

  @override
  String get diffEfNothingToUndo => 'Nothing to undo';

  @override
  String get diffEfShowResult => 'View result';

  @override
  String get diffEfVoiceOn => 'Turn on voice commands';

  @override
  String get diffEfVoiceOff => 'Stop voice commands';

  @override
  String get diffEfSettingsTitle => 'Microscope mode';

  @override
  String get diffEfSettingsSub =>
      'Count without looking away from the microscope';

  @override
  String get diffEfStart => 'Start counting';

  @override
  String get diffEfHowTitle => 'How it works';

  @override
  String get diffEfHowBody =>
      'Put the phone on the bench and tap the zones without looking away from the microscope. Every tap gives a short sound and a vibration pattern specific to the cell type; every 10th cell — a two-tone signal and a long vibration; at the target (100 or 200) — a three-note signal and counting stops. The count is shared with the regular counter.';

  @override
  String get diffEfZonesTitle => 'Zones';

  @override
  String get diffEfHandLabel => 'Which hand do you tap with';

  @override
  String get diffEfHandRight => 'Right hand';

  @override
  String get diffEfHandLeft => 'Left hand';

  @override
  String get diffEfHandHint =>
      'Zone 1 is closest to your thumb — in the bottom corner.';

  @override
  String get diffEfOtherZone => '“Other (blasts…)” zone';

  @override
  String get diffEfOtherZoneSub => 'Turn off for 6 larger zones';

  @override
  String get diffEfUndoSwitch => 'Large “Undo” zone at the top';

  @override
  String get diffEfUndoSwitchSub =>
      'A two-finger tap always undoes the last tap';

  @override
  String get diffEfOrderTitle => 'Zone order';

  @override
  String get diffEfOrderHint =>
      '1 is the zone closest to your thumb. Put the most frequent cells first.';

  @override
  String diffEfMoveUp(String cell) {
    return 'Move up: $cell';
  }

  @override
  String diffEfMoveDown(String cell) {
    return 'Move down: $cell';
  }

  @override
  String get diffEfSignalsTitle => 'Signals';

  @override
  String get diffEfSound => 'Sound';

  @override
  String get diffEfSoundSub => 'Volume follows the phone’s volume buttons';

  @override
  String get diffEfHaptics => 'Vibration';

  @override
  String get diffEfHapticsSub =>
      'Not felt if vibration is turned off in phone settings';

  @override
  String get diffEfPatternsTitle => 'Vibration patterns';

  @override
  String get diffEfPatternsHint =>
      'Tap a row to try it. How it feels depends on the phone model.';

  @override
  String diffEfPattern(int count, String strength) {
    return '$count × $strength';
  }

  @override
  String get diffEfPulseLight => 'light';

  @override
  String get diffEfPulseMedium => 'medium';

  @override
  String get diffEfPulseHeavy => 'strong';

  @override
  String get diffEfPatternTen => 'Every 10th cell';

  @override
  String get diffEfPatternTenDesc => '+ long vibration';

  @override
  String get diffEfPatternDone => 'Target reached';

  @override
  String get diffEfPatternDoneDesc => '2 × strong + long';

  @override
  String get diffEfPatternUndoDesc => 'strong + short';

  @override
  String get diffEfScreenTitle => 'Screen';

  @override
  String get diffEfAwake => 'Keep screen on';

  @override
  String get diffEfAwakeSub =>
      'The screen stays on while counting — uses more battery';

  @override
  String get diffVoiceTitle => 'Voice counting';

  @override
  String get diffVoiceExperimental => 'Experimental';

  @override
  String get diffVoiceSwitch => 'Voice commands';

  @override
  String get diffVoiceSwitchSub =>
      'Say a cell name — +1; “undo” — undo the last one';

  @override
  String get diffVoiceLangLabel => 'Command language';

  @override
  String get diffVoiceLangAuto => 'Auto';

  @override
  String get diffVoiceLangUz => 'Uzbek';

  @override
  String get diffVoiceLangRu => 'Russian';

  @override
  String get diffVoiceLangEn => 'English';

  @override
  String get diffVoiceLangHint =>
      'Auto: if the app language isn’t available on the device — Russian, then English. Uzbek is not in Apple’s dictation language list; on Android it depends on the device.';

  @override
  String get diffVoiceWordsTitle => 'Words to say';

  @override
  String get diffVoicePrivacyTitle => 'Where your voice is processed';

  @override
  String get diffVoicePrivacyIos =>
      'iOS: on-device recognition is required. If it isn’t available for the language, the mode won’t work — audio is not sent to a server. LabGuide does not store or send your voice anywhere.';

  @override
  String get diffVoicePrivacyAndroid =>
      'Android: works only with speech recognition on the phone itself (offline) — Android 12+ with on-device recognition is required. Otherwise the mode stays off and audio is not sent to a server. LabGuide does not store or send your voice anywhere.';

  @override
  String get diffVoiceNoNames =>
      'Say only cell names — never patient names or other details.';

  @override
  String get diffVoiceAccuracy =>
      'Accuracy depends on noise, pronunciation and the device. Listen for the signal after each command; say “undo” if it’s wrong. Check the result before saving.';

  @override
  String get diffVoiceConsentTitle => 'Turn on voice commands?';

  @override
  String get diffVoiceConsentAction => 'I understand, turn on';

  @override
  String get diffVoiceStarting => 'Starting microphone…';

  @override
  String diffVoiceListening(String lang) {
    return 'Listening · $lang';
  }

  @override
  String diffVoiceFallback(String lang) {
    return 'No speech recognition for the app language on this device — say the words in $lang.';
  }

  @override
  String diffVoiceHeard(String text) {
    return 'Heard: “$text”';
  }

  @override
  String diffVoiceNotUnderstood(String text) {
    return 'No command found: “$text”';
  }

  @override
  String get diffVoicePermissionDenied =>
      'Microphone or speech recognition permission was not granted, so voice commands don’t work. You can allow it for LabGuide in phone settings. Counting with zones keeps working.';

  @override
  String get diffVoiceUnavailable =>
      'Speech recognition isn’t available on this device. Counting with zones keeps working.';

  @override
  String get diffVoiceLanguageUnavailable =>
      'Speech recognition isn’t available for the chosen language on this device. Choose another language in settings.';

  @override
  String get diffVoiceOnDeviceUnavailable =>
      'On-device (offline) speech recognition isn’t available. Voice commands are off so audio is not sent to a server.';

  @override
  String get diffVoiceFailed => 'Speech recognition stopped. Please try again.';

  @override
  String get diffVoiceRetry => 'Try again';

  @override
  String get diffHistoryEmptyTitle => 'No saved results yet';

  @override
  String get diffHistoryEmptyBody =>
      'Finish a count and tap “Save to history”.';

  @override
  String get diffHistoryClear => 'Delete all';

  @override
  String get diffHistoryClearTitle => 'Delete history?';

  @override
  String diffHistoryClearBody(int count) {
    return '$count results will be deleted from this device.';
  }

  @override
  String get diffDeleted => 'Result deleted';

  @override
  String get diffHistoryLocalNote =>
      'Results stay on this device and are not sent to a server. “Delete local data” in Profile removes them too.';

  @override
  String get diffInterpretIntro =>
      'Interpretation always goes with the reference interval and the clinical picture. The reference is on your laboratory’s report form; the causes below are only possibilities, not a diagnosis.';

  @override
  String get diffPossibleCauses => 'Possible causes';

  @override
  String get diffAbsNote =>
      'A big rise in one cell type lowers the percentages of the others, so look at absolute counts (fraction × WBC).';

  @override
  String get diffRangesTitle => 'Why doesn’t the app give a “normal range”?';

  @override
  String get diffRangesBody =>
      'Open sources and a former-USSR textbook give different example adult ranges (%). Reports use only the reference on your laboratory’s form; children’s ranges depend on age.';

  @override
  String get diffRangesWho => 'WHO 2003';

  @override
  String get diffRangesMedline => 'MedlinePlus';

  @override
  String get diffRangesClassic => 'Former-USSR textbook (1984)';

  @override
  String get diffRangesClassicNote =>
      'The classic (former-USSR textbook) ranges are shown for comparison only: many local report forms still use them, but sources differ. Your laboratory’s report form is what counts.';

  @override
  String get refTitle => 'Tables and algorithms';

  @override
  String get refSub =>
      'Anemia, jaundice, liver patterns, parasites, obsolete methods';

  @override
  String get refIntro =>
      'Short tables based on textbooks and official sources. Sources are listed under each section.';

  @override
  String get refOpenSub => 'Table and algorithm';

  @override
  String get refNotFound => 'This table was not found.';

  @override
  String get analyteReuseCitationOnly =>
      'Book: cited as a source only, no text copied';

  @override
  String get diffQuizPrompt => 'Which cell is this?';

  @override
  String get diffQuizIntro =>
      'Pick the cell from the schematic. Questions are shuffled each time; after answering you see the distinguishing sign.';

  @override
  String get diffQuizStart => 'Start practice';

  @override
  String get diffRealSmear => 'Real smear';

  @override
  String get diffRealSmearNote =>
      'A licensed micrograph from the microscopy atlas. Author and license are shown when you open it.';

  @override
  String get diffAtlasRow => 'Real blood smears';

  @override
  String get diffAtlasRowSub =>
      'Licensed micrographs from the microscopy atlas';

  @override
  String diffQuizExtended(int count) {
    return 'Extended practice ($count questions)';
  }

  @override
  String get diffQuizExtendedIntro =>
      'On top of the picture questions: identify the cell from a description of its nucleus, cytoplasm and granules.';

  @override
  String get diffQuizDescribed => 'Which cell matches this description?';

  @override
  String diffHistoryMore(int count) {
    return '$count more results are stored on this device';
  }

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
  String get preIdTitle => 'Patient identification and labeling';

  @override
  String get prePatientTitle => 'Patient preparation';

  @override
  String get preTubeForTestTitle => 'Which tube for which test';

  @override
  String get preTubeForTestSub =>
      'Color and position follow the WHO order above. Tubes may differ between laboratories.';

  @override
  String preTubeSlot(String tube, int n) {
    return '$tube · no. $n in the order of draw';
  }

  @override
  String get preTubeNone => 'Separate tube — not in the WHO order';

  @override
  String get preMixTitle => 'Mixing the tube';

  @override
  String get preStabilityTitle => 'Sample stability';

  @override
  String get preStabilitySub =>
      'How long separated serum or plasma keeps (WHO, WHO/DIL/LAB/99.1). Your laboratory’s rules and the reagent insert take priority.';

  @override
  String get preStabilityRoom => '20–25 °C (room)';

  @override
  String get preStorageTitle => 'Storage rules';

  @override
  String get preUrgentTitle => 'Cannot be stored — test at once';

  @override
  String get preBooksNote =>
      'Textbooks (Selivanov 2005, Aripova 2007, Lyubina 1984) are a supporting source. Numbers are shown only where WHO or MedlinePlus confirm them.';

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
  String get mcColour => 'Color index';

  @override
  String get mcColourSub => 'Why the app recommends MCH and MCHC';

  @override
  String get mcNechiporenko => 'Nechiporenko count';

  @override
  String get mcNechiporenkoSub =>
      'Leukocytes, erythrocytes and casts per 1 ml of urine';

  @override
  String get mcAddis => 'Kakovsky–Addis count';

  @override
  String get mcAddisSub => 'Formed elements passed in urine per day';

  @override
  String get mcZimnitsky => 'Zimnitsky test';

  @override
  String get mcZimnitskySub => 'Day and night diuresis, specific-gravity range';

  @override
  String get mcClassicTag => 'Classic Soviet-school method';

  @override
  String get mcClassicTitle => 'Classic textbook intervals';

  @override
  String get mcClassicNote =>
      'This is a reference interval, not a diagnostic cut-off. The interval on your laboratory’s form comes first; the result is not compared with it automatically.';

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
  String get mfHct => 'Hematocrit (Hct)';

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
  String get mfLeukoCounted => 'Leukocytes (A, counted)';

  @override
  String get mfEryCounted => 'Erythrocytes (A, counted)';

  @override
  String get mfCastsCounted => 'Casts (A, counted)';

  @override
  String get mfUrineCentrifuged => 'Urine centrifuged, ml';

  @override
  String get mfCountedVolume => 'Ruling counted';

  @override
  String get mfGoryaevWhole => 'Goryaev, whole ruling — 0.9 µL';

  @override
  String get mfGoryaev100 => 'Goryaev, 100 large squares — 0.4 µL';

  @override
  String get mfFuchsWhole => 'Fuchs–Rosenthal, whole ruling — 3.2 µL';

  @override
  String get mfSediment => 'Sediment left';

  @override
  String get mfCollected => 'Urine collected, ml';

  @override
  String get mfCollectHours => 'Collection time, h';

  @override
  String mfPortion(int n, String time) {
    return 'Portion $n ($time), ml';
  }

  @override
  String mfPortionSg(int n) {
    return 'Portion $n, specific gravity';
  }

  @override
  String get mfFluidIntake => 'Fluid drunk in 24 h, ml';

  @override
  String get mfZimDay => 'Daytime portions (1–4)';

  @override
  String get mfZimNight => 'Night-time portions (5–8)';

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
  String get mrPerMlUrine => 'per 1 ml of urine';

  @override
  String get mrPerDay => 'Per day';

  @override
  String mrPerUlSediment(String value) {
    return 'per 1 µL of sediment: $value';
  }

  @override
  String get mrPortion12 => '12-minute urine to centrifuge';

  @override
  String get mrDiuresisTotal => '24-hour diuresis';

  @override
  String get mrDiuresisDay => 'Daytime diuresis (1–4)';

  @override
  String get mrDiuresisNight => 'Night-time diuresis (5–8)';

  @override
  String get mrDayNightRatio => 'Day : night';

  @override
  String get mrIntakePercent => 'Of fluid drunk';

  @override
  String get mrSgRange => 'Specific gravity: lowest – highest';

  @override
  String get mrSgAmplitude => 'Specific-gravity amplitude';

  @override
  String get mrNotGiven => 'not entered';

  @override
  String get mErrNoUrine =>
      'At least one portion needs a volume and specific gravity.';

  @override
  String get mErrSediment =>
      'The sediment volume must be less than the urine centrifuged.';

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
      'The color index is a relative measure traditionally used in CIS laboratories: it rates the hemoglobin content of one red cell against a “normal” value. It is used to describe hypo-, normo- or hyperchromia.';

  @override
  String get ciWhyTitle => 'Why the app does not calculate it';

  @override
  String get ciWhy =>
      'We found no primary open source for its formula that we could verify. The app gives no numbers or formulas without a source.';

  @override
  String get ciUseTitle => 'What to use instead';

  @override
  String get ciUse =>
      'The hemoglobin in one red cell is expressed directly by the MCH (mean cell hemoglobin, pg), and its concentration in the cell by the MCHC. Hematology analyzers report both. Judge hypo-/hyperchromia by these and your laboratory’s reference intervals.';

  @override
  String get dilC1 => 'C₁ · Stock concentration';

  @override
  String get dilC2 => 'C₂ · Target concentration';

  @override
  String get dilV2 => 'V₂ · Final volume (mL)';

  @override
  String get dilNote =>
      'Use the same units for C₁ and C₂. Simple dilution model: reactions, safety and volume changes are not modeled.';

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
      'C₂ can’t exceed C₁: dilution can’t raise the concentration.';

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
  String get calcCalciumCaution =>
      'Albumin-adjusted calcium often misclassifies calcium status, especially with low albumin or kidney impairment. Where available, measure ionized calcium — it is preferred.';

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
      'HDL cholesterol can’t be equal to or greater than total cholesterol.';

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
  String get micSearchHint => 'e.g. neutrophil, oxalate, malaria';

  @override
  String get micNoResultsTitle => 'Nothing found';

  @override
  String get micNoResultsBody =>
      'Try another name or another language (uz, ru, en).';

  @override
  String get micSections => 'Sections';

  @override
  String get micEduNotice =>
      'Teaching images — not for diagnosis. Every image shows its author, license and original caption.';

  @override
  String get micEduTag => 'Teaching image — not for diagnosis';

  @override
  String get micNoImageYet => 'No licensed image yet';

  @override
  String get micGapWhy => 'Why not?';

  @override
  String get micAllGroups => 'All';

  @override
  String get micSectionQuiz => 'Practice this section';

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
  String get micCreditTitle => 'Author and license';

  @override
  String get micAuthor => 'Author';

  @override
  String get micAuthorPage => 'Author page';

  @override
  String get micLabelBySource => 'Named per the source caption';

  @override
  String get micLabelNoQuiz => 'Not used in the quiz';

  @override
  String get micCredit => 'Source';

  @override
  String get micOwnWork => 'Own work';

  @override
  String get micLicense => 'License';

  @override
  String get micSourceDate => 'Date in the source';

  @override
  String micLicenseText(String license) {
    return 'License text: $license';
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
      'CC BY-SA: adapted versions of this image are shared under the same license.';

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
  String get micCreditsSub => 'Licenses and sources';

  @override
  String micCreditsIntro(String date) {
    return 'Each image’s license, author and original caption were re-checked on the source page ($date). Images are only downscaled: not cropped, no text added, EXIF removed. Only CC0, CC BY, CC BY-SA, public domain and CDC PHIL images are used.';
  }

  @override
  String get micLicenseTexts => 'License texts';

  @override
  String get micCreditsRow => 'Authors and licenses';

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
  String get micQuizPromptCentre => 'What is the cell in the center?';

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
  String get micQuizResultKeep => 'Keep practicing';

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
      'Schematic illustration (drawn by LabGuide) — decorative, not the actual appearance of any instrument.';

  @override
  String get instImageMissing => 'Model image not available yet';

  @override
  String get instImageMissingSub =>
      'No reusable image of this exact model was found. See its appearance on the manufacturer’s page.';

  @override
  String get instMakerSource => 'Manufacturer source';

  @override
  String get instImageTapToZoom => 'Tap the photo to enlarge';

  @override
  String instImageRightsChecked(String date) {
    return 'Rights checked: $date';
  }

  @override
  String instImageSemantics(String model) {
    return 'Photo of $model';
  }

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
      'Information provided by the partner companies. The catalog data above, its order and review status do not depend on partnerships.';

  @override
  String get partnerKindManufacturer => 'Manufacturer';

  @override
  String get partnerKindDistributor => 'Official distributor';

  @override
  String get partnerKindService => 'Service center';

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
      'This page is an advertisement. LabGuide does not endorse partner products; catalog data and review status do not depend on partnerships.';

  @override
  String get partnerOfferTitle => 'Your contacts, right on the instrument card';

  @override
  String get partnerOfferBody =>
      'A lab specialist reading about an instrument can call its official distributor or service center in one tap. For manufacturers, official distributors and service centers.';

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
      'Catalog facts, their order and review status do not depend on partnerships and cannot be bought.';

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
  String get adminPartnerLinks => 'Catalog links';

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
      'To publish: a description, at least one contact and at least one link. The ad always carries an “Ad” label and never changes catalog data.';

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
  String get instSaveFailed => 'Couldn’t save. Please try again.';

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
  String get libSources => 'Sources and licenses';

  @override
  String get libSourcesSub => 'Review and reuse conditions';

  @override
  String get booksEmptyTitle => 'No books yet';

  @override
  String get booksEmptyBody =>
      'Books are added only with confirmed distribution rights. A PDF you add yourself stays for personal study and isn’t shared.';

  @override
  String get booksCatalogNote =>
      'Catalog items link to their official pages. Full text is added to the app only under an open license or with confirmed distribution rights.';

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
    return 'License: $licence';
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
  String get packsCatalogLoading => 'Loading catalog…';

  @override
  String get packsCatalogCached => 'Showing the last saved catalog';

  @override
  String get packsCatalogEmpty => 'No packs to download yet';

  @override
  String get packsStatusTest => 'Test pack · not a clinical pack';

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
  String get sourcesTitle => 'Sources and licenses';

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
  String get learnTitle => 'Learn with insight';

  @override
  String get learnHeroTag => 'Topics and practice';

  @override
  String get learnHeroTitle => 'From molecule to practice';

  @override
  String get learnHeroBody =>
      'Pick a topic and check your knowledge with questions.';

  @override
  String get learnHeroCta => 'Choose a topic';

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
  String toifaTopic(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'safety_ethics': 'Safety and ethics',
      'qc_lab_management': 'Quality control and management',
      'preanalytics': 'Preanalytics',
      'hematology_cells': 'Blood cells',
      'hemopoiesis_leukemia': 'Hematopoiesis and leukemia',
      'anemias': 'Anaemias',
      'hemostasis': 'Haemostasis',
      'biochemistry_proteins_enzymes': 'Proteins and enzymes',
      'carbohydrates_diabetes': 'Carbohydrates and diabetes',
      'lipids': 'Lipids',
      'liver_pigments': 'Liver and pigments',
      'kidney_nitrogen': 'Kidney and nitrogen metabolism',
      'water_electrolytes_acid_base': 'Water, electrolytes and acid–base',
      'minerals_vitamins': 'Minerals and vitamins',
      'hormones': 'Hormones',
      'urinalysis': 'Urinalysis',
      'stool_coprology': 'Stool examination',
      'csf_body_fluids': 'CSF and body fluids',
      'sputum_tb': 'Sputum and tuberculosis',
      'cytology_gyn': 'Cytology',
      'std_microscopy': 'STI microscopy',
      'parasitology': 'Parasitology',
      'immunology_serology': 'Immunology and serology',
      'molecular_pcr': 'Molecular diagnostics (PCR)',
      'tumor_markers': 'Tumor markers',
      'cardiac_markers': 'Cardiac markers',
      'orphan_screening': 'Screening and rare diseases',
      'other': 'Other topics',
    });
    return '$_temp0';
  }

  @override
  String get toifaTitle => 'Knowledge & Skills Assessment';

  @override
  String get toifaSubtitle => 'Clinical laboratory diagnostics (CLD)';

  @override
  String get toifaEyebrow => 'CLD · knowledge and skills';

  @override
  String get toifaEntryBody =>
      'Questions from the official list: a 50-question test, topic practice, oral ticket and mistake review.';

  @override
  String get toifaEntryBodyShort =>
      'Test, oral ticket and mistake review — based on the official list.';

  @override
  String get toifaEntryTagTest => 'Test · 50 questions';

  @override
  String get toifaEntryTagOral => 'Oral · 5 questions';

  @override
  String toifaEntryTestActive(int done, int total) {
    return 'Test in progress: $done / $total answered';
  }

  @override
  String toifaEntryTicketActive(int done, int total) {
    return 'Oral ticket in progress: $done / $total';
  }

  @override
  String get toifaOpen => 'Start';

  @override
  String get toifaContinue => 'Continue';

  @override
  String get toifaUzbekOnly => 'Official text — Uzbek';

  @override
  String get toifaUzbekNotice =>
      'The official text of the certification questions is Uzbek. With a Russian or English interface an auxiliary translation is shown; the original can be opened at any time. Scoring follows the official Uzbek text and key.';

  @override
  String get toifaShowOriginal => 'Show original text';

  @override
  String get toifaHideOriginal => 'Hide original text';

  @override
  String get toifaOriginalTitle => 'Official text (Uzbek)';

  @override
  String get toifaTranslationAux =>
      'The translation is auxiliary; scoring follows the official Uzbek text.';

  @override
  String get toifaLoadError => 'Could not open the question bank';

  @override
  String get toifaYourCategory => 'Your category';

  @override
  String get toifaCatSecond => 'Category 3–2';

  @override
  String get toifaCatFirst => 'First category';

  @override
  String get toifaCatHighest => 'Highest category';

  @override
  String get toifaCategoryHint =>
      'The oral ticket is drawn from this category’s list. Test questions are shared by all categories.';

  @override
  String get toifaReadyTest => 'Test';

  @override
  String get toifaReadyOral => 'Oral';

  @override
  String get toifaPrepare => 'Assessment';

  @override
  String get toifaTestTitle => 'Knowledge test';

  @override
  String toifaTestRowSub(int count, int bank) {
    return '$count random questions · $bank in the bank';
  }

  @override
  String get toifaPracticeTitle => 'Topic practice';

  @override
  String toifaPracticeRowSub(int count) {
    return '$count topics · key and note right after answering';
  }

  @override
  String get toifaOralTitle => 'Oral ticket';

  @override
  String toifaOralRowSub(String category, int count) {
    return '$category: 5 of $count questions';
  }

  @override
  String get toifaOralRowPick => 'Choose your category first';

  @override
  String toifaOralRowActive(int done, int total) {
    return 'In progress: $done / $total rated';
  }

  @override
  String get toifaMistakesTitle => 'Mistake review';

  @override
  String toifaMistakesRowSub(int tests, int oral) {
    return 'Test mistakes: $tests · oral “didn’t know”: $oral';
  }

  @override
  String get toifaMistakesRowEmpty => 'No mistakes yet';

  @override
  String get toifaProgressTitle => 'Progress';

  @override
  String get toifaProgressRowSub => 'Results by topic and readiness';

  @override
  String get toifaAboutTitle => 'Source and review';

  @override
  String get toifaListSource =>
      'Source: official certification question list (CLD, 119)';

  @override
  String toifaAboutList(int tests, int oral) {
    return 'The list has $tests test and $oral oral questions (duplicates across categories merged).';
  }

  @override
  String toifaAboutKeys(int disputed, int ambiguous) {
    return 'The key is the answer marked in the list, and scoring follows it. LabGuide found the key disputed in $disputed questions and ambiguous in $ambiguous — those show a note and source.';
  }

  @override
  String toifaAboutKeyless(int count) {
    return '$count questions have no key marked in the list — they are left out of tests and practice.';
  }

  @override
  String toifaAboutOral(int ready, int total) {
    return 'Oral answer plans are a study aid prepared by LabGuide ($ready / $total plans with sources).';
  }

  @override
  String toifaTestSubtitle(int count) {
    return '$count questions · drawn from the official list';
  }

  @override
  String get toifaFormatTitle => 'Format';

  @override
  String toifaFormatStep1(int count, int bank) {
    return '$count random questions out of $bank in the bank.';
  }

  @override
  String get toifaFormatStep2 =>
      'One answer per question; options in list order.';

  @override
  String get toifaFormatStep3 =>
      'At the end: mistake review with the official key and LabGuide note.';

  @override
  String get toifaTimeLabel => 'Time, minutes';

  @override
  String get toifaNoTime => 'No time limit';

  @override
  String get toifaTimeHelper =>
      'No official time limit is set in the app — choose your own or leave empty.';

  @override
  String get toifaTimeError => 'Enter 1 to 240 minutes or leave empty';

  @override
  String get toifaPassLabel => 'Pass mark, %';

  @override
  String get toifaNoPass => 'Not set';

  @override
  String get toifaPassHelper =>
      'This is your own threshold, not the official pass mark.';

  @override
  String get toifaPassError => 'Enter 1 to 100% or leave empty';

  @override
  String get toifaScoringNotice =>
      'Scoring follows the official key — that is what the exam expects. Where the key is disputed, the results also show a LabGuide note.';

  @override
  String get toifaTestStart => 'Start test';

  @override
  String get toifaTodayEyebrow => 'Today';

  @override
  String toifaTodayGoal(int count) {
    return 'Goal: $count questions or 1 ticket';
  }

  @override
  String get toifaTodayDone => 'Today’s goal is done';

  @override
  String toifaTodayProgress(int answered, int goal) {
    return '$answered/$goal questions';
  }

  @override
  String toifaTodayCorrect(int percent) {
    return '$percent% correct';
  }

  @override
  String toifaTodayTickets(int count) {
    return 'tickets: $count';
  }

  @override
  String toifaStreakDays(int count) {
    return '$count-day streak';
  }

  @override
  String get toifaTodayNone => 'No practice yet today.';

  @override
  String get toifaTodayTomorrow => 'Come back tomorrow to keep your streak.';

  @override
  String toifaWeekLabel(String values) {
    return 'Last 7 days: $values';
  }

  @override
  String get toifaGoalLabel => 'Daily goal';

  @override
  String toifaGoalOption(int count) {
    return '$count questions';
  }

  @override
  String get toifaGoalHint => 'Or 1 oral ticket — whichever comes first.';

  @override
  String get toifaReminderTitle => 'LabGuide · Knowledge & Skills';

  @override
  String toifaReminderBody(int count) {
    return 'Today’s practice is waiting — $count questions or 1 ticket';
  }

  @override
  String get toifaReminderChannel => 'Knowledge & Skills reminder';

  @override
  String get toifaOfferTitle => 'Continue tomorrow?';

  @override
  String get toifaOfferBody =>
      'Pick a reminder time. There’s no reminder on days you’ve met the goal.';

  @override
  String toifaOfferOn(String time) {
    return 'We’ll remind you tomorrow at $time.';
  }

  @override
  String get toifaModeTitle => 'Mode';

  @override
  String get toifaModeExam => 'Exam mode';

  @override
  String get toifaModeExamSub =>
      'Timed; score and mistakes at the end — like the real exam.';

  @override
  String get toifaModePractice => 'Practice mode — mistakes shown right away';

  @override
  String get toifaModePracticeSub =>
      'After each answer: the correct option and note; no timer.';

  @override
  String get toifaDrillStep2 =>
      'Right after answering you see if it’s correct: the official key and (if any) a note and source.';

  @override
  String get toifaDrillStep3 =>
      'Resume where you left off even after closing the app; rework your mistakes at the end.';

  @override
  String get toifaDrillStart => 'Start practice';

  @override
  String toifaDrillActive(int answered, int total) {
    return 'Practice in progress: $answered/$total';
  }

  @override
  String get toifaDrillTitle => 'Practice mode';

  @override
  String get toifaDrillRework => 'Rework mistakes';

  @override
  String toifaDrillScore(int right, int wrong) {
    return 'Correct: $right · wrong: $wrong';
  }

  @override
  String get toifaDrillFinishEarly => 'Finish now';

  @override
  String get toifaDrillFinishBody =>
      'Unanswered questions count as wrong. Your answers stay in the mistakes list.';

  @override
  String get toifaDrillDiscardTitle => 'Abandon this practice?';

  @override
  String get toifaDrillNone => 'No practice in progress';

  @override
  String get toifaDrillNew => 'New test';

  @override
  String toifaDrillUnanswered(int count) {
    return 'Unanswered: $count';
  }

  @override
  String get toifaThinkHint =>
      'Think through your answer: say it out loud or jot it on paper. Then open the plan and compare.';

  @override
  String toifaThinkTimer(int minutes) {
    return '$minutes-min think timer';
  }

  @override
  String toifaThinkLeft(String time) {
    return 'Think time: $time';
  }

  @override
  String get toifaThinkUp => 'Time’s up — open the plan and compare.';

  @override
  String get toifaThinkStop => 'Stop timer';

  @override
  String get toifaChecklistToggle => 'Key points to compare with the plan';

  @override
  String get toifaChecklistHint =>
      'Tick what your answer covered (on this device only, no typing).';

  @override
  String toifaChecklistCount(int done, int total) {
    return '$done/$total ticked';
  }

  @override
  String get toifaRepeatTitle => 'To repeat';

  @override
  String get toifaRepeatNote =>
      '“Partly” and “Didn’t know” questions come back first in your next tickets.';

  @override
  String get toifaRepeatNone =>
      'You knew them all — new questions in the next ticket.';

  @override
  String get toifaPracticeSubtitle => 'Key right after each answer';

  @override
  String toifaPracticeMixed(int count) {
    return 'Mixed: $count questions';
  }

  @override
  String get toifaPracticeMistakes => 'Redo mistakes';

  @override
  String get toifaBackToTopics => 'Topics';

  @override
  String get toifaPracticeRight => 'Your answer matches the official key.';

  @override
  String get toifaPracticeWrong =>
      'Your answer does not match the official key.';

  @override
  String toifaListNumber(int number) {
    return 'No. $number';
  }

  @override
  String get toifaOfficialKey => 'Official key';

  @override
  String get toifaLabGuideNote => 'LabGuide note';

  @override
  String get toifaVerdictDisputed => 'Key disputed';

  @override
  String get toifaVerdictAmbiguous => 'Ambiguous question';

  @override
  String toifaSuggested(String options) {
    return 'LabGuide suggests: $options';
  }

  @override
  String get toifaScoredByOfficial =>
      'Scoring follows the official key — that answer is what the exam expects.';

  @override
  String get toifaNoOfficialKey =>
      'No key is marked in the list — this question is not scored.';

  @override
  String get toifaNoteNoSource => 'No source is given for this note.';

  @override
  String get toifaRelatedCards => 'Related cards';

  @override
  String toifaOralSubtitle(int count) {
    return '$count questions · prepare and self-assess';
  }

  @override
  String toifaOralPool(String category, int count) {
    return '$category: $count questions in the list';
  }

  @override
  String get toifaOralHowTitle => 'How it works';

  @override
  String toifaOralStep1(int count) {
    return '$count random questions from your category list.';
  }

  @override
  String get toifaOralStep2 =>
      'Prepare your answers — in your head or on paper.';

  @override
  String get toifaOralStep3 =>
      'Check the answer plan and rate yourself: knew, partly or didn’t know.';

  @override
  String get toifaPickCategoryFirst => 'Choose a category first';

  @override
  String get toifaDrawTicket => 'Draw a ticket';

  @override
  String get toifaTicketTitle => 'Your ticket';

  @override
  String get toifaPrepHint =>
      'No typing needed. Think through each answer — say it out loud or jot it on paper. Then compare with the answer plan and rate yourself.';

  @override
  String get toifaShowPlans => 'Answer one by one';

  @override
  String get toifaShowPlan => 'View answer plan';

  @override
  String get toifaNewTicket => 'New ticket';

  @override
  String get toifaNewTicketBody =>
      'Five new questions replace the current ticket. Ratings you gave are kept.';

  @override
  String get toifaRevealHint =>
      'First recall or write down your answer, then open the plan.';

  @override
  String get toifaPlanTitle => 'Answer plan';

  @override
  String get toifaPlanPending => 'Prepared by LabGuide';

  @override
  String get toifaPlanMissing => 'The plan for this question is not ready yet.';

  @override
  String get toifaPlanNotChecked => 'No source is attached to this plan yet.';

  @override
  String get toifaReferenceTitle =>
      'Reference interval (specimen, lab-specific)';

  @override
  String get toifaCutoffTitle => 'Diagnostic cut-off (guideline)';

  @override
  String get toifaWrongLabel => 'Wrong';

  @override
  String get toifaRightLabel => 'Right';

  @override
  String get toifaNeedsSource => 'Source needed — being checked with a teacher';

  @override
  String get toifaUnverifiedNote =>
      'The note is not confirmed by a source — no answer is suggested.';

  @override
  String toifaAgentChecked(String date) {
    return 'Compared with sources: $date';
  }

  @override
  String get toifaHeld => 'Being clarified';

  @override
  String get toifaHeldBody =>
      'Until the wording is clarified, this question is left out of tickets and scoring.';

  @override
  String toifaAboutHeld(int count) {
    return '$count question(s) are left out of tickets and tests until clarified.';
  }

  @override
  String get toifaPitfallsTitle => 'Outdated / common mistake';

  @override
  String get toifaRateTitle => 'Rate yourself';

  @override
  String get toifaRateHint =>
      'The rating stays on this device and appears in Mistake review.';

  @override
  String get toifaRateKnew => 'Knew it';

  @override
  String get toifaRatePartial => 'Partly';

  @override
  String get toifaRateUnknown => 'Didn’t know';

  @override
  String get toifaTicketDone => 'Ticket complete';

  @override
  String toifaTicketSummary(int knew, int partial, int unknown) {
    return 'Knew: $knew · partly: $partial · didn’t know: $unknown';
  }

  @override
  String get toifaRatingsSaved =>
      'Ratings saved. Tap a question to reopen the plan and change the rating.';

  @override
  String get toifaRatingSaved => 'Rating saved';

  @override
  String get toifaMistakesSubtitle => 'Test mistakes and oral questions';

  @override
  String get toifaMistakesEmpty => 'No mistakes yet';

  @override
  String get toifaMistakesEmptyBody =>
      'Questions you got wrong in tests or practice and oral questions rated “didn’t know” collect here.';

  @override
  String toifaMistakesTests(int count) {
    return 'Test mistakes · $count';
  }

  @override
  String toifaMistakesOralUnknown(int count) {
    return 'Oral: didn’t know · $count';
  }

  @override
  String toifaMistakesOralPartial(int count) {
    return 'Oral: partly · $count';
  }

  @override
  String toifaMoreMistakes(int count) {
    return '$count more mistakes — practice them via Redo mistakes.';
  }

  @override
  String get toifaNothingHere => 'Nothing here yet.';

  @override
  String get toifaProgressSubtitle => 'Results by topic and readiness';

  @override
  String get toifaReadyTitle => 'Estimated readiness';

  @override
  String get toifaReadyCaption =>
      'Average of test and oral results. A LabGuide estimate, not an official grade.';

  @override
  String toifaReadyTestDetail(int done, int total) {
    return 'Test: $done / $total questions mastered';
  }

  @override
  String toifaReadyOralDetail(int done, int total) {
    return 'Oral: $done / $total “knew it”';
  }

  @override
  String get toifaProgressPickCategory =>
      'Oral results use your category list — choose a category:';

  @override
  String get toifaRecentTests => 'Recent tests';

  @override
  String get toifaPassedShort => 'Passed';

  @override
  String get toifaNotPassedShort => 'Below mark';

  @override
  String get toifaByTopicNote =>
      'Weakest topics first. Test — questions last answered correctly; oral — rated “knew it”.';

  @override
  String toifaBarTest(int done, int total) {
    return 'Test: $done / $total';
  }

  @override
  String toifaBarOral(int done, int total) {
    return 'Oral: $done / $total';
  }

  @override
  String examPassMet(int percent) {
    return 'Mark reached (≥$percent%)';
  }

  @override
  String examPassMissed(int percent) {
    return 'Below your mark ($percent%)';
  }

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
  String get quizReviewNote =>
      'Practice questions are for learning; the result is not an official grade.';

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
  String get dailyTitle => 'Daily questions';

  @override
  String get dailyCardStart => 'Today’s 5 questions';

  @override
  String get dailyCardStartSub =>
      '2–3 minutes. New questions every day, with an explanation and source after each answer.';

  @override
  String dailyCardProgress(int count, int total) {
    return '$count of $total answered';
  }

  @override
  String dailyCardDone(int correct, int total) {
    return 'Done for today: $correct of $total correct';
  }

  @override
  String get dailyCardDoneSub => 'Five new questions tomorrow.';

  @override
  String get dailyStart => 'Start';

  @override
  String get dailyContinue => 'Continue';

  @override
  String get dailyShowResult => 'See result';

  @override
  String dailyStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in a row',
      one: '$count day in a row',
    );
    return '$_temp0';
  }

  @override
  String get dailyStreakTitle => 'Streak';

  @override
  String get dailyStreakCurrent => 'Current streak';

  @override
  String get dailyStreakBest => 'Longest streak';

  @override
  String dailyDaysShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get dailyFreezeAvailable => 'This week’s freeze is available';

  @override
  String get dailyFreezeUsed => 'This week’s freeze is used';

  @override
  String get dailyFreezeRule =>
      'Miss one day and your streak survives — once a week (a freeze). The frozen day doesn’t count towards the streak; miss two days in a row and it starts over.';

  @override
  String get dailyFreezeSaved =>
      'You missed yesterday — a freeze kept your streak.';

  @override
  String get dailyStreakStart => 'Answer today’s questions to start a streak.';

  @override
  String get dailyKeepStreak => 'Answer today’s questions to keep your streak.';

  @override
  String get dailyEmpty => 'No questions for today';

  @override
  String get dailyReviewTitle => 'Today’s questions';

  @override
  String get dailySourceToifa =>
      'Questions come from the official list — only those whose key passed the LabGuide check.';

  @override
  String get dailyReminderTitle => 'LabGuide: daily questions';

  @override
  String get dailyReminderBody =>
      'Today’s 5 questions are ready — 2–3 minutes.';

  @override
  String get dailyReminderChannel => 'Daily reminder';

  @override
  String get dailyReminderSetting => 'Daily reminder';

  @override
  String dailyReminderAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get dailyReminderOff => 'Off';

  @override
  String get dailyReminderTime => 'Reminder time';

  @override
  String get dailyOfferTitle => 'Want a daily reminder?';

  @override
  String get dailyOfferBody =>
      'One notification at the time you choose. No reminder on days you’ve already answered. Turn it off any time.';

  @override
  String get dailyOfferYes => 'Turn on reminder';

  @override
  String get dailyOfferNo => 'No thanks';

  @override
  String get dailyReminderDenied =>
      'Notification permission wasn’t granted, so the reminder stays off. Allow notifications for LabGuide in your phone settings and try again.';

  @override
  String get dailyReminderUnavailable =>
      'Couldn’t turn on reminders on this device.';

  @override
  String dailyReminderOnSnack(String time) {
    return 'Reminder on: every day at $time';
  }

  @override
  String get dailyReminderNote =>
      'The reminder is scheduled on this device only (no server). Your phone may delay it by a few minutes to save battery. If you don’t open the app for 7 days, reminders stop.';

  @override
  String get shareResult => 'Share result';

  @override
  String get shareSheetTitle => 'Result card';

  @override
  String get shareSheetBody => 'The image has no name or other personal data.';

  @override
  String get shareFailed => 'Couldn’t open the share sheet. Please try again.';

  @override
  String get shareKindDaily => 'Daily questions';

  @override
  String get shareKindExam => 'Practice exam';

  @override
  String get shareKindToifa => 'Knowledge test practice';

  @override
  String get shareCorrectCaption => 'correct answers';

  @override
  String get shareFooter => 'Lab reference and practice';

  @override
  String get shareToifaNote => 'LabGuide practice result';

  @override
  String shareText(String kind, int correct, int total, int percent) {
    return 'LabGuide · $kind: $correct/$total ($percent%)';
  }

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
  String get classesUnavailableTitle => 'The class server isn’t connected yet';

  @override
  String get classesUnavailableBody =>
      'Nothing is sent or stored. When it’s connected, teachers see only their own classes and students see only their own results — checked on the server.';

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
  String get examReworkTitle => 'Practice your mistakes';

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
  String get examFinishClassTitle => 'Finish the test?';

  @override
  String get examFinishClassBody =>
      'Your answers will be sent to your teacher.';

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
  String get examBand0 => 'Keep practicing — you’ve got this';

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
    return 'Practice mistakes · $count';
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
  String get examNoSource => 'No source is given for this question.';

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
      'Your role in the app grants no server rights: only an account registered as a teacher can open a class, and only manages its own classes.';

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
      'The teacher who opens a class manages only that class. Students join with your code or QR.';

  @override
  String get classesGroupName => 'Class name';

  @override
  String get classesGroupNameHint => 'e.g. Biochemistry year 2';

  @override
  String classesLengthError(int min, int max) {
    return 'Enter $min–$max characters';
  }

  @override
  String get classesDisplayName => 'Nickname (optional)';

  @override
  String get classesDisplayNameHint =>
      'e.g. Star — leave empty to use a number';

  @override
  String get classesDisplayNameHintTeacher => 'e.g. Dr N. Karimova';

  @override
  String get classesDisplayNameNote =>
      'Names aren’t stored on the server: students appear by nickname or number. You can note a real name only as a label on your own device.';

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
      'Don’t use your real name. The teacher sees only your nickname (or number) and your results; other students don’t see you. Your email isn’t shown.';

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
  String get classesDeleteGroup => 'Delete class';

  @override
  String classesDeleteGroupTitle(String name) {
    return 'Delete the class “$name”?';
  }

  @override
  String get classesDeleteGroupBody =>
      'The class, its assignments and student results will be deleted permanently.';

  @override
  String get classesDeleteGroupAction => 'Delete';

  @override
  String get classesInviteTitle => 'Invite code';

  @override
  String get classesInviteBody =>
      'Students scan the QR with the phone camera and tap “Open in app” — or: Learn → Classes and assignments → Join with a code.';

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
  String get classesAssignmentTitle => 'Assignment title';

  @override
  String get classesTimeLimit => 'Time limit, minutes';

  @override
  String get classesNoLimit => 'No limit';

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
  String get profileGuestLocal => 'Data stays on this device only';

  @override
  String get profileDemoSession => 'Demo session · debug build';

  @override
  String get profileRole => 'Role';

  @override
  String get profileRoleSub => 'Home adapts to your role';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileUnits => 'Units';

  @override
  String get profileUnitsSi => 'SI (mmol/L, µmol/L)';

  @override
  String get profileUnitsConventional => 'Conventional (mg/dL)';

  @override
  String get profileAttestation => 'Knowledge & Skills Assessment';

  @override
  String get profileAttestationAuto => 'Automatic';

  @override
  String get profileAttestationUz => 'Uzbekistan';

  @override
  String get profileAttestationNone => 'Hide';

  @override
  String get profileAttestationNote =>
      'Shows the Knowledge & Skills Assessment section (Uzbekistan) in any interface language. Automatic: shown when the language is Uzbek or the device region is Uzbekistan.';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeRowSub => 'App colors and title type';

  @override
  String get themeCurrent => 'Current theme';

  @override
  String get themeClassicName => 'Classic';

  @override
  String get themeClassicDesc => 'LabGuide’s signature green';

  @override
  String get themeIvoryName => 'Ivory';

  @override
  String get themeIvoryDesc => 'Ivory, ink and gold with elegant serif titles';

  @override
  String get themeModeSection => 'Light or dark';

  @override
  String get themeSelected => 'Selected';

  @override
  String get profilePrivacy => 'Privacy and data';

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
      'Your account, sign-in methods (Google/Apple links), group memberships and results, “Feedback & help” requests and your community questions and answers are permanently removed from the server. If you are a teacher, the groups you created are deleted too. This can’t be undone. The text of complaints you sent in the app stays, no longer linked to the account. Data on this device is cleared as well.';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get adminTitle => 'Admin panel';

  @override
  String get adminSub => 'Moderation, support, content, admins';

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
  String get privacyTitle => 'Privacy and data';

  @override
  String get privacyBody =>
      'The core features work without an account (guest mode): settings, bookmarks, QC records, your instruments and practice results stay on this device. An account is optional (email code, Google or Apple) and is needed for groups, the community and “Feedback & help”. Then data is stored on a Cloudflare server (Eastern Europe, outside Uzbekistan): your email only as a hash and a masked form, sign-in method, role, language, last activity time (to the minute); in a group — your nickname or sequence number, test answers and scores; the text of requests and complaints. From Google/Apple only the account identifier and email are used; the token is not stored. A teacher sees only their own group. No ads, analytics or tracking. Full text: the “Privacy policy” link.';

  @override
  String get privacyBodyLocal =>
      'This build has no server connected: the app sends nothing to a server. Settings, bookmarks, QC records, your instruments and practice results stay on this device (they may be included in the device backup). No ads or tracking.';

  @override
  String get privacyTerms => 'Terms of use';

  @override
  String get privacyTermsSub => 'Rules for using the app and your account';

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
      'LabGuide is a free clinical laboratory reference and learning app. By using the app you agree to these terms.\n\n1. Medical limitation. LabGuide does not diagnose, prescribe treatment or medicines, and does not replace your laboratory’s approved procedures, reagent and analyzer instructions (IFU) or a physician’s judgment. Every item shows its source; when making decisions, rely on the original source and your institution’s rules.\n\n2. Account. Some features (groups, tests, community, support requests) require signing up with email. You are responsible for your account’s security and for actions taken through it. You can delete your account at any time: Profile → Delete account.\n\n3. Teacher and student groups. When a student joins a group, the teacher sees their nickname (or seat number) and test results. Teachers use groups for educational purposes only.\n\n4. User content. You are responsible for what you post in the community and in support requests. Abuse, illegal content, advertising, other people’s personal data and non-consensual intimate images are strictly prohibited. Such content is removed, and the offending account may be restricted or deleted. You can report any message with “Report”.\n\n5. Copyright. The app’s texts, slides, tests and design belong to the LabGuide authors; external sources are shown with their own licenses. They may not be copied or distributed for commercial purposes.\n\n6. Service. The app is provided “as is”; outages and errors may occur, and we fix them as quickly as we can. We will notify you in the app if these terms change.\n\n7. Privacy. How your data is used is described in the privacy policy: labguide.nfcstore.uz/privacy\n\n8. Contact: labguide@nfcstore.uz';

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
    return 'Open license · $licence';
  }

  @override
  String get libAccessFree => 'Free to read · link only';

  @override
  String get libAccessCatalog => 'Catalog record only';

  @override
  String get libOpenSource => 'Open the official page';

  @override
  String libChecked(String date) {
    return 'Page and license checked: $date';
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
  String get libIntake => 'Adding materials';

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
  String get libStateCataloged => 'Cataloged';

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
  String get libItemUnavailable =>
      'This material is not available in your language';

  @override
  String get libItemUnavailableBody =>
      'This material is currently available only in another language. Change the interface language or go back to the catalog.';

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
      'For a file to open in the app for everyone, the rights are fully recorded: who granted them (author or publisher), when, who recorded it, and the evidence — a permission letter or a license link.';

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
      'Cataloged — title, author and edition were checked. Only then can it be cited.';

  @override
  String get intakeStep4 =>
      'Linked — tied to test cards and lessons with page numbers.';

  @override
  String get intakeStep5 => 'Approved — a teacher reviewed it.';

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
    return 'Cataloged materials: $count';
  }

  @override
  String reviewField(String field) {
    return 'Field: $field';
  }

  @override
  String get lessonsTitle => 'Lesson topics';

  @override
  String get analyteTreatmentGoals => 'Treatment goals';

  @override
  String get analyteTreatmentGoalsNotice =>
      'A treatment goal is set by a physician on the basis of the patient’s full risk assessment; the app does not determine a risk category.';

  @override
  String get analyteTreatmentGoalsNotRef =>
      'Treatment goals are neither reference intervals nor diagnostic limits. Guidelines define risk groups differently — compare values only within one table.';

  @override
  String analyteGoalHistorical(String current) {
    return 'Historical guideline, superseded by $current. Shown for context only — not for current treatment decisions.';
  }

  @override
  String analyteGoalGuideline(String name, String year) {
    return '$name · $year';
  }

  @override
  String get analyteAgentCheck => 'Compared with sources';

  @override
  String get analyteExpertApproval => 'Expert approval';

  @override
  String classesSeat(String n) {
    return 'Student $n';
  }

  @override
  String classesQrLabel(String code) {
    return 'Invite code QR: $code';
  }

  @override
  String get classesTeacherRegisterEyebrow => 'Teacher';

  @override
  String get classesTeacherRegisterTitle => 'Register as a teacher';

  @override
  String get classesTeacherRegisterBody =>
      'A teacher opens their own class and sees only their students’ results. This isn’t admin access and doesn’t affect other classes.';

  @override
  String get classesTeacherRegister => 'Register as a teacher';

  @override
  String get classesLocalNameTitle => 'Label (this device only)';

  @override
  String get classesLocalNameBody =>
      'For example, the student’s name. It isn’t sent to the server and the student can’t see it.';

  @override
  String get classesLocalNameHint => 'Empty — remove the label';

  @override
  String get classesLocalNameSave => 'Save';

  @override
  String get classroomPlanTitle => 'Course plan';

  @override
  String get classroomPlanSub => 'Topics by day: lecture, oral questions, test';

  @override
  String get classroomTopicsTitle => 'Topics';

  @override
  String get classroomTopicsSub => 'Topics and tests your teacher has opened';

  @override
  String get classroomProgramEyebrow => 'Curriculum';

  @override
  String classroomPlanProgress(int done, int total) {
    return '$done/$total topic tests finished';
  }

  @override
  String get classroomStartNone =>
      'No start date — the plan is shown by day number';

  @override
  String classroomStartAt(String date) {
    return 'Day 1: $date';
  }

  @override
  String get classroomStartNote =>
      'Dates are approximate (Sundays skipped, holidays not counted) and stored only on this device.';

  @override
  String get classroomStartPick => 'Set the start date';

  @override
  String classroomDayN(int n) {
    return 'Day $n';
  }

  @override
  String classroomWeekN(int n) {
    return 'Week $n';
  }

  @override
  String classroomHours(int n) {
    return '$n h';
  }

  @override
  String get classroomTypeLecture => 'Lecture';

  @override
  String get classroomTypePractical => 'Practical';

  @override
  String get classroomTypeSeminar => 'Seminar';

  @override
  String get classroomTypeAttestation => 'Assessment';

  @override
  String get classroomTypeOther => 'Session';

  @override
  String get classroomStatusClosed => 'Not opened';

  @override
  String get classroomStatusOpened => 'Opened';

  @override
  String get classroomStatusLectured => 'Taught';

  @override
  String get classroomStatusOral => 'Oral round done';

  @override
  String get classroomStatusTestRunning => 'Test in progress';

  @override
  String get classroomStatusTestDone => 'Test finished';

  @override
  String get classroomNoCurriculumTitle =>
      'The curriculum hasn’t been added yet';

  @override
  String get classroomNoCurriculumBody =>
      'The course plan (module → topic → materials) will come in a later app version. For now, use class assignments.';

  @override
  String get classroomCurriculumError => 'Couldn’t read the curriculum';

  @override
  String get classroomNoTopicsStudent =>
      'Your teacher hasn’t opened any topics yet';

  @override
  String get classroomNoTopicsStudentBody =>
      'When a topic opens, its materials and test will appear here.';

  @override
  String get classroomTopicTitle => 'Topic';

  @override
  String get classroomTopicMissing => 'Topic not found in the curriculum';

  @override
  String get classroomTopicNotOpened => 'This topic isn’t open yet';

  @override
  String get classroomOpenNote =>
      'Once opened, students see the topic materials.';

  @override
  String get classroomOpenTopic => 'Open to students';

  @override
  String classroomStep(int n) {
    return 'Step $n';
  }

  @override
  String get classroomStageLecture => 'Lecture';

  @override
  String get classroomStageLectureBody =>
      'Present the topic as slides on a big screen (works offline too).';

  @override
  String get classroomStageOral => 'Oral questions';

  @override
  String classroomStageOralBody(int count) {
    return 'Question list with answer outlines. Asked: $count.';
  }

  @override
  String get classroomStageTest => 'Class test';

  @override
  String get classroomStageTestBody =>
      'Pick questions and start the test — it opens for students right away.';

  @override
  String get classroomStageDone => 'Done';

  @override
  String get classroomMarkDone => 'Mark as done';

  @override
  String get classroomOralOpen => 'Question list';

  @override
  String get classroomTestPrepare => 'Prepare the test';

  @override
  String get classroomTestResults => 'Results panel';

  @override
  String get classroomTestFinish => 'Finish the test';

  @override
  String get classroomTestFinishTitle => 'Finish the test?';

  @override
  String get classroomTestFinishBody =>
      'No new attempts are accepted. Those who already started get 2 minutes to send their answers.';

  @override
  String classroomTestSubmitted(int done, int total) {
    return '$done/$total students submitted';
  }

  @override
  String get classroomTestNotStarted =>
      'Your teacher hasn’t started the test yet.';

  @override
  String get classroomTestOpenStudent => 'Test open — take it';

  @override
  String get classroomMaterials => 'Topic materials';

  @override
  String get classroomNoMaterials =>
      'The app has no linked materials for this topic yet.';

  @override
  String get classroomGapNote =>
      'The app has little material on this topic — the teacher adds their own sources.';

  @override
  String get classroomKindAnalyte => 'Test card';

  @override
  String get classroomKindCondition => 'Condition';

  @override
  String get classroomKindReference => 'Table';

  @override
  String get classroomKindAtlas => 'Microscopy atlas';

  @override
  String get classroomKindTool => 'Calculator and tool';

  @override
  String get classroomToolQc => 'Quality control';

  @override
  String get classroomToolPreanalytics => 'Preanalytics';

  @override
  String get classroomToolInstruments => 'Instruments';

  @override
  String get classroomToolCalibration => 'Calibration log';

  @override
  String get classroomToolDifferential => 'Differential count';

  @override
  String get classroomPlanRecommended => 'LabGuide recommended practical plan';

  @override
  String get classroomOralNotice =>
      'Questions are auto-picked candidates; answer outlines are a study aid. “Asked” marks and grades stay on this device only.';

  @override
  String get classroomOralEmpty => 'No oral questions for this topic';

  @override
  String classroomCandidate(int n) {
    return 'Candidate question $n';
  }

  @override
  String get classroomOralPlan => 'Short answer outline';

  @override
  String get classroomOralNoPlan => 'No answer outline yet.';

  @override
  String get classroomOralAsked => 'Asked';

  @override
  String classroomOralGrade(int count) {
    return 'Grade students ($count)';
  }

  @override
  String get classroomOralGradeTitle => 'How each student answered';

  @override
  String get classroomOralGradeNote =>
      'This device only; not sent to the server.';

  @override
  String get classroomGradeKnew => 'Knew';

  @override
  String get classroomGradePartial => 'Partly';

  @override
  String get classroomGradeDidNot => 'Didn’t know';

  @override
  String get classroomCandidatesNotice =>
      'Candidate questions were auto-picked. Look through each one and its key: the score is computed on the server using the key shown.';

  @override
  String classroomCandidatesTitle(int picked, int total) {
    return 'Candidates · picked $picked/$total';
  }

  @override
  String get classroomPickAll => 'All';

  @override
  String get classroomPickNone => 'None';

  @override
  String classroomKeyShown(String answer) {
    return 'Key: $answer';
  }

  @override
  String get classroomKeyFlagged => 'Disputed key';

  @override
  String get classroomPickAtLeastOne => 'Pick at least one question';

  @override
  String get classroomPickMax => 'At most 50 questions';

  @override
  String classroomTestStart(int count) {
    return 'Start the test · $count questions';
  }

  @override
  String get classroomTestStarted => 'Test started — open for students';

  @override
  String classroomTestTitle(String topic) {
    return 'Test: $topic';
  }

  @override
  String get classroomTestAlready => 'This topic’s test has already started';

  @override
  String get classroomTestNoCandidates => 'No test questions for this topic';

  @override
  String get classroomTestNoCandidatesBody =>
      'You can build an assignment by hand (New assignment).';

  @override
  String get lectureTitle => 'Lecture';

  @override
  String get lectureListTitle => 'Lecture mode';

  @override
  String get lectureListSub => 'Pick a topic — slides on a big screen, offline';

  @override
  String get lectureStart => 'Start the lecture';

  @override
  String get lectureClose => 'Close the lecture';

  @override
  String lectureCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get lecturePrev => 'Back';

  @override
  String get lectureNext => 'Next';

  @override
  String get lectureGoals => 'Goals';

  @override
  String get lectureKeyPoints => 'Key concepts';

  @override
  String get lectureConcepts => 'Key tests';

  @override
  String get lectureConditions => 'Clinical conditions';

  @override
  String get lectureTables => 'Tables and algorithms';

  @override
  String get lectureAtlas => 'Microscopy';

  @override
  String get lectureTools => 'Calculations and tools';

  @override
  String lectureQuestionN(int n) {
    return 'Question $n';
  }

  @override
  String get lectureEndEyebrow => 'Next step';

  @override
  String get lectureEndTitle => 'Questions and test';

  @override
  String get lectureEndOral => 'Oral questions — asked by the teacher';

  @override
  String get lectureEndTest => 'Class test — in the app, timed';

  @override
  String get lectureDraftNotice =>
      'The deck is based on sources — look through the content before class';

  @override
  String get lectureUzOnly => 'This presentation is in Uzbek only for now';

  @override
  String get lectureNotesShow => 'Show teacher notes';

  @override
  String get lectureNotesHide => 'Hide teacher notes';

  @override
  String get lectureTeacherNote => 'Teacher note';

  @override
  String get cmTitle => 'Community · Q&A';

  @override
  String get cmHomeSub => 'Questions answered by verified lab specialists';

  @override
  String get cmAsk => 'Ask a question';

  @override
  String get cmAllQuestions => 'All questions';

  @override
  String get cmEmptyTitle => 'No questions yet';

  @override
  String get cmEmptyBody => 'Be the first to ask.';

  @override
  String cmTopicLinkAnalyte(int count) {
    return 'Questions about this test ($count)';
  }

  @override
  String cmTopicLinkCondition(int count) {
    return 'Questions about this condition ($count)';
  }

  @override
  String get cmTopicLinkSub => 'Community · answers from specialists';

  @override
  String cmTopicLabel(String name) {
    return 'Topic: $name';
  }

  @override
  String get cmMyQuestions => 'My questions';

  @override
  String get cmMyQuestionsSub => 'Your questions and their answers';

  @override
  String get cmVerifyTitle => 'Specialist verification';

  @override
  String get cmVerifySub => 'Upload a document to answer questions';

  @override
  String get cmBadgeAi => '✓ Specialist (document checked automatically)';

  @override
  String get cmBadgeManual => '✓ Verified specialist';

  @override
  String get cmBadgeInfo =>
      '“Document checked automatically” means an AI model, not a person, checked the document. Users can report a wrong badge.';

  @override
  String get cmMember => 'Member';

  @override
  String get cmYou => 'you';

  @override
  String get cmVerifyInfoTitle => 'Automatic check — the file is not stored';

  @override
  String get cmVerifyInfo =>
      'The document is checked automatically by an AI model (Cloudflare Workers AI); no person looks at it. The file is not saved anywhere and is discarded right after the check. Only the result is kept on the server: role, country, status and date. An automatic check can make mistakes; if other users report a wrong badge, it is suspended until an administrator reviews it.';

  @override
  String get cmVerifyRole => 'Your profession';

  @override
  String get cmRoleLaborant => 'Lab technician';

  @override
  String get cmRoleBiochemist => 'Biochemist';

  @override
  String get cmRoleKdlDoctor => 'Clinical lab physician';

  @override
  String get cmRoleTeacher => 'Teacher';

  @override
  String get cmRoleOther => 'Other';

  @override
  String get cmRoleClinicalLab => 'Clinical laboratory diagnostics';

  @override
  String get cmVerifyCountry => 'Country (2-letter code, e.g. UZ)';

  @override
  String get cmVerifyCountryError => 'Enter a 2-letter country code';

  @override
  String get cmVerifyDocHint =>
      'Diploma, certificate or a document from your workplace. JPEG or PNG photo, up to 5 MB. For a PDF, take a photo of its first page. Cover any patient data.';

  @override
  String get cmVerifyCamera => 'Take a photo';

  @override
  String get cmVerifyGallery => 'Choose from gallery';

  @override
  String get cmVerifyRemove => 'Choose another';

  @override
  String get cmVerifySubmit => 'Send for automatic check';

  @override
  String get cmVerifyAttempts => 'Up to 3 attempts per day.';

  @override
  String get cmStatusNone => 'Not verified yet';

  @override
  String get cmStatusVerified => 'Verified';

  @override
  String get cmStatusRejected =>
      'The document was not accepted. Try again with a clearer photo where the institution and the field are visible.';

  @override
  String get cmStatusSuspended =>
      'Your community account is suspended after reports from users. An administrator will review it.';

  @override
  String cmVerifiedAt(String date) {
    return 'Verified: $date';
  }

  @override
  String get cmMethodAi => 'Method: automatic (AI)';

  @override
  String get cmMethodManual => 'Method: document reviewed manually';

  @override
  String get cmErrTooLarge => 'The file is larger than 5 MB.';

  @override
  String get cmErrType => 'Only a JPEG or PNG photo.';

  @override
  String get cmErrAi =>
      'The automatic check is not available right now. Try again later.';

  @override
  String get cmErrNotVerified =>
      'Only verified specialists can answer and vote.';

  @override
  String get cmErrContact =>
      'Remove email addresses and phone numbers (and any patient data) from the text.';

  @override
  String get cmErrLength => 'Title: 10–200 characters, text: 10–4000.';

  @override
  String get cmErrAlreadyVerified => 'You are already verified.';

  @override
  String get cmErrRevoked =>
      'Your specialist status was revoked by an administrator. Automatic re-verification is not available.';

  @override
  String get cmAskTitleField => 'Question title';

  @override
  String get cmAskBodyField => 'Details';

  @override
  String get cmAskNoPatient =>
      'Do not write a patient’s name, phone or other personal data. Answers are colleagues’ experience, not personal medical advice.';

  @override
  String get cmAskSend => 'Post question';

  @override
  String get cmAskSent => 'Question posted';

  @override
  String get cmSignInTitle => 'Sign in to take part';

  @override
  String get cmSignInBody =>
      'Anyone signed in can ask. Verified specialists answer.';

  @override
  String cmAnswers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers',
      one: '1 answer',
      zero: 'No answers',
    );
    return '$_temp0';
  }

  @override
  String get cmAnswerField => 'Your answer';

  @override
  String get cmAnswerSend => 'Post answer';

  @override
  String get cmAnswerOnlySpecialists =>
      'Answers are written only by verified specialists.';

  @override
  String get cmBest => 'Best answer';

  @override
  String get cmMarkBest => 'Mark as best';

  @override
  String get cmUnmarkBest => 'Remove mark';

  @override
  String cmUpvote(int count) {
    return 'Helpful ($count)';
  }

  @override
  String get cmReport => 'Report';

  @override
  String get cmReportTitle => 'Reason for the report';

  @override
  String get cmReasonSpam => 'Spam or advertising';

  @override
  String get cmReasonWrong => 'Wrong or dangerous information';

  @override
  String get cmReasonAbuse => 'Abusive';

  @override
  String get cmReasonFake => 'Fake specialist';

  @override
  String get cmReasonPatient => 'Contains patient data';

  @override
  String get cmReasonOther => 'Other';

  @override
  String get cmReportSent => 'Report sent. Thank you.';

  @override
  String get cmTranslate => 'Translate';

  @override
  String get cmMachineTranslation => 'Machine translation';

  @override
  String get cmShowOriginal => 'Original text';

  @override
  String get cmShowTranslation => 'Translation';

  @override
  String get cmPin => 'Pin';

  @override
  String get cmUnpin => 'Unpin';

  @override
  String get cmPinned => 'Pinned';

  @override
  String get cmDelete => 'Delete';

  @override
  String get cmDeleteConfirm => 'Delete this post?';

  @override
  String get cmDeleted => 'Deleted';

  @override
  String get cmLoadMore => 'Show more';

  @override
  String get cmNotAdvice =>
      'Answers are colleagues’ experience, not personal medical advice.';

  @override
  String get cmRulesTitle => 'Community rules';

  @override
  String get cmRulesIntro =>
      'The LabGuide community is a place to share experience in clinical laboratory diagnostics.';

  @override
  String get cmRulesExpand => 'Expand rules';

  @override
  String get cmRulesCollapse => 'Collapse rules';

  @override
  String get cmRulesH1 => 'What is discussed';

  @override
  String get cmRulesA1 =>
      'interpreting test results (inconsistent results, spurious increases/decreases)';

  @override
  String get cmRulesA2 =>
      'pre-analytics: blood collection, tubes, storage, hemolysis';

  @override
  String get cmRulesA3 => 'quality control (QC, Westgard rules), calibration';

  @override
  String get cmRulesA4 => 'experience working with analyzers and reagents';

  @override
  String get cmRulesA5 =>
      'hematology, microscopy, biochemistry, immunology, urinalysis';

  @override
  String get cmRulesA6 =>
      'questions about knowledge and skills assessment and study';

  @override
  String get cmRulesH2 => 'How to write';

  @override
  String get cmRulesB1 =>
      'put the essence of the question in the title (for example: “Potassium high, no hemolysis — what is the cause?”)';

  @override
  String get cmRulesB2 =>
      'in the details: which test, the result and its unit, the method or analyzer, what you have already tried';

  @override
  String get cmRulesB3 =>
      'state units precisely: SI first, conventional in parentheses (for example 7.0 mmol/L (126 mg/dL))';

  @override
  String get cmRulesB4 => 'one post — one question';

  @override
  String get cmRulesH3 => 'What is not allowed';

  @override
  String get cmRulesC1 =>
      'a patient’s name, phone, address, card number or any data that identifies a person';

  @override
  String get cmRulesC2 =>
      'advertising, off-topic posts, abusive language; posting intimate or private images or material without the person’s consent is strictly prohibited';

  @override
  String get cmRulesC3 =>
      'personal treatment advice for a patient — this is colleagues’ experience, not a doctor’s advice';

  @override
  String get cmRulesH4 => 'Who can write';

  @override
  String get cmRulesD1 => 'questions — any registered user';

  @override
  String get cmRulesD2Pre =>
      'answers — only verified specialists with the “✓ Specialist” badge (';

  @override
  String get cmRulesD2Link => 'Profile → Specialist verification';

  @override
  String get cmRulesD2Post =>
      '; upload a photo of your diploma or certificate; the document is not stored)';

  @override
  String get cmRulesD3 =>
      'if you see a post that breaks the rules, tap “Report”';

  @override
  String get cmRulesOutro =>
      'To read posts in another language, use the “Translate” button. Respect and accuracy are our main rule.';

  @override
  String get cmAdminTitle => 'Community moderation';

  @override
  String get cmAdminSub => 'Reported users: restore or revoke';

  @override
  String get cmAdminEmpty => 'Nobody here';

  @override
  String cmAdminReporters(int count) {
    return '$count reporters';
  }

  @override
  String get cmAdminRestore => 'Restore';

  @override
  String get cmAdminRevoke => 'Revoke verification';

  @override
  String get cmAdminSuspended => 'Suspended';

  @override
  String get cmAdminVerified => 'Verified';

  @override
  String get cmAdminRejected => 'Rejected';

  @override
  String get cmAdminDone => 'Done';

  @override
  String get cmOwnerTag => 'Owner';

  @override
  String get cmLaunchTitle => 'Launch the community';

  @override
  String get cmLaunchBody =>
      'Tap once: your account is confirmed as the founder and the starter questions and answers are added. Tapping again adds nothing twice.';

  @override
  String get cmLaunchButton => 'Launch';

  @override
  String cmLaunchDone(int questions, int answers) {
    return 'Done: founder confirmed. Added $questions questions and $answers answers.';
  }

  @override
  String get cmLaunchAlready =>
      'The community is already launched: founder confirmed, nothing new was added.';

  @override
  String get cmLaunchNotOwner =>
      'This account is not allowed as founder. Sign in with the founder’s email.';

  @override
  String get cmLaunchMfaHint =>
      'To launch the community, first confirm two-step protection: enter the 6-digit code from your authenticator app. The “Launch the community” button appears after that.';

  @override
  String get diffFbSound => 'Sound on tap';

  @override
  String get diffFbHaptics => 'Vibration on tap';

  @override
  String get diffFbOn => 'on';

  @override
  String get diffFbOff => 'off';

  @override
  String get admYouSuper => 'You are the owner (super admin)';

  @override
  String get admYouAdmin => 'You are an admin';

  @override
  String get adm2faOn =>
      'Two-step protection (2FA) is confirmed. It is required for every admin action.';

  @override
  String get admReportsQueue => 'Reports and members';

  @override
  String get admReportsSub => 'Suspended queue, verified and rejected members';

  @override
  String get admLaunchRow => 'Launch the community';

  @override
  String get admLaunchRowSub => 'Founder confirmation and starter Q&A (once)';

  @override
  String admPending(int count) {
    return 'Pending: $count';
  }

  @override
  String get admQueueEmpty => 'Queue is empty';

  @override
  String get admNotConnected => 'Not connected on this server yet';

  @override
  String get admReview => 'Content review';

  @override
  String admReviewSub(int cards, int questions) {
    return 'Not yet reviewed: $cards cards, $questions questions';
  }

  @override
  String get admTeam => 'Admin management';

  @override
  String admTeamCount(int count) {
    return 'Admins: $count';
  }

  @override
  String get admTeamSubManage => 'Add by email and remove';

  @override
  String get admTeamSubView => 'List (only the owner can change it)';

  @override
  String get admLegacyNote =>
      'Statistics, users, action history and partners are not on this server yet — they will appear here when ready.';

  @override
  String get admOther => 'Other sections';

  @override
  String get admTeamIntro =>
      'An admin gets full access to every admin section: community moderation, support threads, content review. Only the server grants this, and every action needs a 2FA code.';

  @override
  String get admTeamOwnerOnly =>
      'Only the owner (super admin) can add and remove admins.';

  @override
  String get admAddTitle => 'Add an admin';

  @override
  String get admAddEmail => 'Email (e.g. Gmail)';

  @override
  String get admAddHint =>
      'Access takes effect once they sign in with this email and set up 2FA; if the account exists — right away.';

  @override
  String get admAddButton => 'Make admin';

  @override
  String get admAddConfirmTitle => 'Make this person an admin?';

  @override
  String admAddConfirmBody(String email) {
    return '$email will get full access to every admin section. You can remove them at any time.';
  }

  @override
  String admAdded(String email) {
    return 'Added: $email';
  }

  @override
  String get admInvalidEmail => 'Invalid email. For example: name@gmail.com';

  @override
  String get admErrAlready => 'This email is already an admin.';

  @override
  String get admErrSuper =>
      'This is the owner’s email (super admin) — already an admin.';

  @override
  String admErrTooMany(int max) {
    return 'Admin limit: $max. Remove someone first.';
  }

  @override
  String admListTitle(int count) {
    return 'Admins ($count)';
  }

  @override
  String get admKindSuper => 'Owner · super admin';

  @override
  String admKindGranted(String date) {
    return 'Admin · added $date';
  }

  @override
  String get admNotSignedIn =>
      'Not signed in yet — access starts at first sign-in';

  @override
  String get admYou => 'You';

  @override
  String get admRemove => 'Remove';

  @override
  String get admRemoveTitle => 'Remove this admin?';

  @override
  String admRemoveBody(String email) {
    return '$email loses admin access immediately — on every device. Their account and data are not deleted.';
  }

  @override
  String admRemoved(String email) {
    return 'Removed: $email';
  }

  @override
  String get admSuperNote =>
      'The owner is set in a secret server setting (LG_ADMIN_EMAILS) and cannot be removed from the app.';

  @override
  String get admNoGranted => 'No admins added yet.';

  @override
  String get cmAdminRevokeTitle => 'Revoke verification?';

  @override
  String get cmAdminRevokeBody =>
      'The member loses the specialist badge and cannot be re-verified by AI. They can still ask questions.';

  @override
  String get cmAdminRestoreTitle => 'Restore this member?';

  @override
  String get cmAdminRestoreBody =>
      'The status before suspension returns and their posts become visible again. Old reports are not counted again.';

  @override
  String get adminActionGrantAdded => 'Admin added';

  @override
  String get adminActionGrantRemoved => 'Admin removed';

  @override
  String get cytoTitle => 'Cytology';

  @override
  String get cytoSubtitle => 'Gynecological smear: cells and reports';

  @override
  String get cytoHeroTitle => 'Read a smear with confidence';

  @override
  String get cytoHeroBody =>
      'Cell drawings, cleanliness grade, the Bethesda system and practice — in one place.';

  @override
  String get cytoHeroCta => 'View cells';

  @override
  String get cytoSchematicCaption =>
      'Annotated diagram (LabGuide) — not a micrograph; scale and colors are approximate.';

  @override
  String get cytoCellsTitle => 'Cells and organisms';

  @override
  String cytoCellsSub(int n) {
    return '$n items: drawing and key feature';
  }

  @override
  String get cytoDegreeTitle => 'Vaginal smear cleanliness grade';

  @override
  String get cytoDegreeSub => 'Grades I–IV: mark what you see';

  @override
  String get cytoBethesdaTitle => 'The Bethesda system';

  @override
  String get cytoBethesdaSub => 'What a Pap report means';

  @override
  String get cytoTechniqueTitle => 'Sampling and staining';

  @override
  String get cytoTechniqueSub => 'Preparation, fixation, staining, errors';

  @override
  String get cytoQuizTitle => 'Which cell is this?';

  @override
  String cytoQuizSub(int n) {
    return '$n picture questions';
  }

  @override
  String get cytoQuizIntro =>
      'Look at the drawing and pick the name: 4 options. The key feature is shown after you answer.';

  @override
  String get cytoQuizPrompt => 'What is this?';

  @override
  String get cytoQuizStart => 'Start practice';

  @override
  String get cytoLook => 'Appearance';

  @override
  String get cytoKey => 'Key feature';

  @override
  String get cytoMeaning => 'What it means';

  @override
  String get cytoConfuse => 'Often confused with';

  @override
  String get cytoRefer => 'Show to a cytologist or clinician';

  @override
  String get cytoDegreeIntro =>
      'Mark what you see under the microscope — the app shows the grade by the traditional scheme. The worst feature decides.';

  @override
  String get cytoLacto => 'Lactobacilli';

  @override
  String get cytoLeuko => 'Leukocytes';

  @override
  String get cytoFlora => 'Other flora';

  @override
  String get cytoMany => 'Many';

  @override
  String get cytoFew => 'Few';

  @override
  String get cytoNone => 'None';

  @override
  String get cytoSingle => 'Rare';

  @override
  String get cytoVeryMany => 'Very many';

  @override
  String get cytoMixed => 'Mixed (cocci)';

  @override
  String get cytoPathogenic => 'Pathogenic (trichomonads etc.)';

  @override
  String cytoDegreeResult(int n) {
    return 'Grade $n';
  }

  @override
  String get cytoDegreeTable => 'Grades at a glance';

  @override
  String get cytoDegreeNote =>
      'A traditional scheme (A. Heurlein, 1910; used in CIS countries). Russian guidelines (ROAG 2019) regard it as of historical interest only; the international criteria for bacterial vaginosis are Amsel and Nugent.';

  @override
  String get cytoDegreeSourceNote =>
      'Sources for the classification and for the bacterial vaginosis criteria are listed below; where they disagree, both are shown.';

  @override
  String get cytoBethesdaIntro =>
      'This is how a cervical smear is reported in the Bethesda system. The clinician decides next steps.';

  @override
  String get cytoMethod => 'Stain / preparation';

  @override
  String get cytoMarksTitle => 'What the numbers show';

  @override
  String get cytoNoPhoto =>
      'No real micrograph yet — only images with verified permission will be added.';

  @override
  String get cytoLabCardBody =>
      'Cell diagrams, cleanliness grade, Bethesda and practice';

  @override
  String get spermTitle => 'Semen analysis';

  @override
  String get spermLabCardBody =>
      'WHO 2021 limits, counter, result assessment and terms';

  @override
  String get homeSearchHint => 'Search tests, instruments or topics';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchPrompt =>
      'Type a name, abbreviation or synonym — in Uzbek (Latin or Cyrillic), Russian or English.';

  @override
  String get searchSectionLibrary => 'Learning materials';

  @override
  String get searchSectionSections => 'Sections';

  @override
  String get diffAssessTitle => 'Compared with reference';

  @override
  String get diffAssessNote =>
      'This is not a diagnosis: the result is compared with the report’s reference range and shows what it may point to. The clinician draws the conclusion.';

  @override
  String get diffAssessNeedWbc =>
      'Enter the white cell count (WBC) to assess absolute counts — only the band percentage was assessed.';

  @override
  String get diffAssessAllNormal =>
      'All values are within the reference range.';

  @override
  String diffAssessIncomplete(int counted, int target) {
    return 'The comparison appears when the count is complete: $counted of $target cells counted. Percentages from an incomplete count are not reliable.';
  }

  @override
  String get diffFlagHigh => 'High';

  @override
  String get diffFlagLow => 'Low';

  @override
  String get diffFlagNormal => 'Normal';

  @override
  String get diffMeasureNeutrophils => 'Neutrophils (total)';

  @override
  String get diffMeasureLymphocytes => 'Lymphocytes';

  @override
  String get diffMeasureMonocytes => 'Monocytes';

  @override
  String get diffMeasureEosinophils => 'Eosinophils';

  @override
  String get diffMeasureBasophils => 'Basophils';

  @override
  String get diffMeasureBands => 'Band neutrophils';

  @override
  String diffAssessRange(String range) {
    return 'reference $range';
  }

  @override
  String diffAssessMaySuggest(String finding) {
    return 'May point to: $finding';
  }

  @override
  String get diffAssessAboutFinding => 'More about this finding';

  @override
  String get diffAssessReferBody =>
      'Blasts or unidentified cells, severe neutropenia (< 0.5 ×10⁹/L) or marked eosinophilia (> 1.5 ×10⁹/L): show the result and the smear to a clinician or haematologist urgently.';

  @override
  String get diffLimitsTitle => 'Report reference ranges';

  @override
  String get diffLimitsSub =>
      'Enter the ranges printed on your laboratory’s report — assessment uses them. An empty lower limit is not checked.';

  @override
  String get diffLimitsLow => 'Lower limit';

  @override
  String get diffLimitsHigh => 'Upper limit';

  @override
  String get diffLimitsInvalid =>
      'Invalid range: the lower limit must be below the upper.';

  @override
  String get diffLimitsReset => 'Restore source values';

  @override
  String get diffLimitsSourceNote =>
      'Defaults are adult 95% intervals (Harrison’s Manual of Medicine, 20th ed., Table 64-1); bands — Lyubina 1984, Table 6. MSD Manual definitions differ: eosinophilia > 0.5 ×10⁹/L (default upper limit here 0.7) and lymphocytopenia < 1.0 ×10⁹/L (default lower limit here 1.5). Ranges differ in children and in some ethnic groups (e.g. Duffy-negative).';

  @override
  String get cytoAdequacyTitle => 'Specimen adequacy';

  @override
  String get cytoAdequacySub =>
      'Bethesda 2014: satisfactory or not, common artifacts';

  @override
  String get cytoArtefactsTitle => 'Common artifacts';

  @override
  String get cytoReactiveTitle => 'Reactive changes vs atypia';

  @override
  String get cytoReactiveSub =>
      'Inflammation, repair, radiation, IUD vs ASC-US and LSIL';

  @override
  String get cytoReactiveIntro =>
      'In the Bethesda system reactive cellular changes (inflammation including repair, lymphocytic cervicitis, radiation, IUD) are non-neoplastic findings within NILM.';

  @override
  String get cytoCompareTitle => 'Side by side';

  @override
  String get cytoCompareNone => 'no separate criterion in the cited sources';

  @override
  String get cytoReactiveTypesTitle => 'Types of reactive change';

  @override
  String get cytoMaturationTitle => 'Maturation index';

  @override
  String get cytoMaturationSub =>
      'Parabasal : intermediate : superficial — calculator';

  @override
  String get cytoMiCalcTitle => 'Calculator';

  @override
  String get cytoMiParabasal => 'Parabasal cells';

  @override
  String get cytoMiIntermediate => 'Intermediate cells';

  @override
  String get cytoMiSuperficial => 'Superficial cells';

  @override
  String get cytoMiEmpty =>
      'Enter the counts of single cells (whole numbers); at least one must be above 0.';

  @override
  String get cytoMiResult =>
      'Maturation index (parabasal : intermediate : superficial)';

  @override
  String cytoMiTotal(int n) {
    return 'Cells counted: $n';
  }

  @override
  String get cytoMiCaveat =>
      'This is arithmetic only. Interpretation depends on age, cycle day, pregnancy, hormones and inflammation — the cytologist or clinician interprets.';

  @override
  String get cytoOtherTitle => 'Other specimens';

  @override
  String get cytoOtherSub =>
      'Urine, serous fluids, sputum: reporting categories';

  @override
  String get cytoOtherIntro =>
      'A brief overview: only the names of the international reporting categories. Criteria and risk figures are in the sources.';

  @override
  String get cytoCategoriesTitle => 'Categories';

  @override
  String get contactPrivacyPolicy => 'Privacy policy';

  @override
  String get bloodGroupTitle => 'Blood grouping';

  @override
  String get bloodGroupLabCardBody =>
      'ABO and RhD: methods, compatibility, discrepancies, practice';

  @override
  String get autoPresTitle => 'Automatic presentation';

  @override
  String get autoPresEntrySub => 'Slides built from the app’s sourced content';

  @override
  String get autoPresPickerSub =>
      'Pick a topic or tests. Slides are assembled only from sourced content already in the app — nothing is made up.';

  @override
  String get autoPresLanguageNote =>
      'Slides use the app language. Content missing in this language is skipped — languages are never mixed.';

  @override
  String get autoPresModeTopic => 'By topic';

  @override
  String get autoPresModeTests => 'By tests';

  @override
  String get autoPresSearch => 'Search tests';

  @override
  String get autoPresSearchHint => 'Name, abbreviation or synonym';

  @override
  String autoPresSelectedCount(int count, int max) {
    return 'Selected: $count of $max';
  }

  @override
  String autoPresLimitReached(int max) {
    return 'No more than $max tests per presentation.';
  }

  @override
  String get autoPresNoResults => 'No tests found.';

  @override
  String get autoPresOptQuiz => 'Question slides';

  @override
  String get autoPresOptQuizSub =>
      'Practice questions of the selected content; the answer opens on tap.';

  @override
  String get autoPresOptGeneral => 'General preanalytics';

  @override
  String get autoPresOptGeneralSub =>
      'Order of draw, hemolysis, tourniquet (WHO, 2010).';

  @override
  String get autoPresPreview => 'Preview slides';

  @override
  String get autoPresPickFirst => 'Pick a topic or at least one test first.';

  @override
  String get autoPresPreviewTitle => 'Slide preview';

  @override
  String get autoPresPreviewSub => 'Reorder or remove slides, then start.';

  @override
  String autoPresSlideCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slides',
      one: '1 slide',
    );
    return '$_temp0';
  }

  @override
  String get autoPresStart => 'Start';

  @override
  String get autoPresMoveUp => 'Move up';

  @override
  String get autoPresMoveDown => 'Move down';

  @override
  String get autoPresRemove => 'Remove slide';

  @override
  String get autoPresRestore => 'Restore removed slides';

  @override
  String get autoPresSourcesPinned =>
      'Sources slide — built automatically from the slides you keep';

  @override
  String get autoPresEmptyTitle => 'Not enough sourced content';

  @override
  String get autoPresEmptyBody =>
      'The app has no sourced content for this selection in the current language, so no slides were made. Nothing is filled in with made-up text.';

  @override
  String autoPresNoticeStructureOnly(String name) {
    return '$name: the card has no written content yet — skipped.';
  }

  @override
  String autoPresNoticeNoContent(String name) {
    return '$name: no sourced text to build slides from — skipped.';
  }

  @override
  String autoPresNoticeLang(int count) {
    return 'Not available in this language, so skipped: $count. Languages are never mixed.';
  }

  @override
  String get autoPresDeckTitleTests => 'Laboratory tests';

  @override
  String autoPresMoreItems(int count) {
    return '+$count more';
  }

  @override
  String autoPresPackSource(String version) {
    return 'LabGuide, content pack $version — slides are assembled automatically from the cited cards';
  }

  @override
  String autoPresSourceLine(String text) {
    return 'Source: $text';
  }

  @override
  String get autoPresColIndicator => 'Indicator';

  @override
  String get autoPresColValue => 'Value';

  @override
  String get autoPresColTarget => 'Target';

  @override
  String get autoPresColTube => 'Tube';

  @override
  String get autoPresColCap => 'Cap color';

  @override
  String get autoPresShowAnswer => 'Show answer';

  @override
  String get autoPresHideAnswer => 'Hide answer';

  @override
  String get autoPresAnswerLabel => 'Answer';

  @override
  String get autoPresTplTitle => 'Title';

  @override
  String get autoPresTplBullets => 'Points';

  @override
  String get autoPresTplTable => 'Table';

  @override
  String get autoPresTplFigure => 'Image';

  @override
  String get autoPresTplQa => 'Question';

  @override
  String get instSchematicCaption =>
      'Schematic illustration — not a photo of this exact model';

  @override
  String get instSchematicTapToZoom => 'Tap the illustration to enlarge';

  @override
  String get instSchematicNotPhoto =>
      'An original generic class schematic drawn by LabGuide. It is not a real photograph of the manufacturer’s instrument; parts are shown at principle level and do not represent model-specific features.';

  @override
  String instSchematicSemantics(String kind) {
    return 'Schematic illustration: $kind';
  }

  @override
  String get histoTitle => 'Histology';

  @override
  String get histoLabCardBody =>
      'Tissues and organs: real micrographs, key features, practice';

  @override
  String get contactRowTitle => 'Contact & reports';

  @override
  String get contactRowSub => 'Questions, complaints, report a problem';

  @override
  String get contactTitle => 'Contact';

  @override
  String get contactIntro =>
      'Works without internet or an account: the message is sent from your mail app.';

  @override
  String get contactEmailLabel => 'Email';

  @override
  String get contactCopy => 'Copy address';

  @override
  String get contactCopied => 'Address copied';

  @override
  String get contactNoMailApp =>
      'Could not open a mail app. The address was copied: send your message from any mail service.';

  @override
  String get contactQuestionTitle => 'Questions and suggestions';

  @override
  String get contactQuestionBody =>
      'Ask about the app, suggest a topic or an improvement.';

  @override
  String get contactQuestionAction => 'Write an email';

  @override
  String get contactAdTitle => 'Advertising and partnership';

  @override
  String get contactAdBody =>
      'Laboratory equipment makers, distributors and service companies can advertise in LabGuide.\nWrite to us, or use the partner form if it is available in your version.';

  @override
  String get contactAdAction => 'Write about advertising';

  @override
  String get contactReportTitle => 'Report a problem';

  @override
  String get contactReportBody =>
      'Tell us about wrong medical content or inappropriate user content.';

  @override
  String get contactReportHint =>
      'Please name the section or card so we can find it quickly.';

  @override
  String get contactReportAction => 'Send a report';

  @override
  String get contactResponseNote =>
      'We read every report and fix confirmed errors, but we cannot promise a reply time. This address is not for medical emergencies.';

  @override
  String get contactPrivacyNote =>
      'If you write to us, we see your email address and what you write.';

  @override
  String contactMailBodyQuestion(String version, String platform) {
    return 'Your question or suggestion:\n\n\n---\nApp: LabGuide $version\nPlatform: $platform';
  }

  @override
  String contactMailBodyAd(String version, String platform) {
    return 'Company and what you would like to advertise:\n\n\n---\nApp: LabGuide $version\nPlatform: $platform';
  }

  @override
  String contactMailBodyReport(String version, String platform) {
    return 'Section / card name:\nWhat is wrong:\n(Please do not include patient data.)\n\n\n---\nApp: LabGuide $version\nPlatform: $platform';
  }

  @override
  String get partnerKindLaboratory => 'Laboratory service';

  @override
  String get partnerPlacementHomeLab => 'Home: laboratory service';

  @override
  String get partnerPlacementHomeEquipment => 'Home: equipment firm';

  @override
  String get homeAdDemoTitle => 'Sample / Demo — ad slot';

  @override
  String get homeAdDemoLabBody =>
      'A partner laboratory service ad will appear here';

  @override
  String get homeAdDemoEquipmentBody => 'An equipment firm ad will appear here';

  @override
  String get homeAdDemoCta => 'Place an ad';

  @override
  String get cmBlock => 'Block user';

  @override
  String get cmBlockConfirmTitle => 'Block this user?';

  @override
  String get cmBlockConfirmBody =>
      'You will no longer see their questions or answers on this device. You can undo this in the community list.';

  @override
  String get cmBlockedDone => 'User blocked. Their posts are hidden.';

  @override
  String get cmBlockedHidden =>
      'This post is hidden because you blocked its author.';

  @override
  String cmBlockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have blocked $count users.',
      one: 'You have blocked 1 user.',
    );
    return '$_temp0';
  }

  @override
  String get cmUnblockAll => 'Unblock everyone';

  @override
  String get cmContactLink => 'Contact LabGuide (report a problem)';

  @override
  String get authOr => 'or';

  @override
  String get authSignInApple => 'Sign in with Apple';

  @override
  String get authSignInGoogle => 'Sign in with Google';

  @override
  String get authSocialFailed =>
      'Couldn’t sign in. Check the connection and try again, or use the email code.';

  @override
  String get authSocialEmailUnverified =>
      'This account’s email isn’t verified, so it can’t be used to sign in. Use the email code instead.';

  @override
  String get authSocialEmailRequired =>
      'This account didn’t share an email address. Use the email code instead.';

  @override
  String get accountDeleteAppleNote =>
      'You signed in with Apple, so Apple will ask you to confirm before the account is deleted. This also disconnects LabGuide from your Apple ID.';

  @override
  String get accountDeleteAppleCancelled =>
      'Nothing was deleted: Apple confirmation was canceled.';

  @override
  String get urinTitle => 'Urinalysis';

  @override
  String get urinLabCardBody =>
      'Collection, strip test, sediment pictures, result reader, practice';

  @override
  String get coagTitle => 'Coagulogram';

  @override
  String get coagLabCardBody =>
      'PT/INR, APTT, fibrinogen, D-dimer, sample rules, DIC score';

  @override
  String get coproTitle => 'Stool analysis and parasites';

  @override
  String get coproLabCardBody =>
      'Coprogram, occult blood, egg and cyst key (schematic)';

  @override
  String get admPanelAccess =>
      'Access: the owner email (ADMIN_EMAILS) and an email code. The server re-checks every request.';

  @override
  String get admOverview => 'Overview';

  @override
  String admOverviewSub(int total, int online, int week) {
    return 'Registered: $total · online: $online · new in 7 days: $week';
  }

  @override
  String get admComplaintsRow => 'In-app complaints';

  @override
  String admComplaintsRowSub(int count) {
    return 'Open: $count';
  }

  @override
  String get admReportsRow => 'Community reports';

  @override
  String admReportsRowSub(int count) {
    return 'Unreviewed posts: $count';
  }

  @override
  String admEmailNote(String email) {
    return 'Complaints and questions sent by email arrive at $email — check them in the mailbox (they do not reach the app).';
  }

  @override
  String get admUsersSub => 'Search by email or nickname, role, suspension';

  @override
  String get admAuditSub => 'Every admin action is recorded';

  @override
  String get admStoreTitle => 'Downloads and sales';

  @override
  String get admStoreBody =>
      'The server cannot see store downloads — App Store Connect and Google Play Console show them. The app has no analytics SDK (privacy policy). Numbers in this panel are accounts that confirmed their email.';

  @override
  String get admSales => 'Sales: 0 (no payments yet)';

  @override
  String get admAppStoreConnect => 'App Store Connect';

  @override
  String get admPlayConsole => 'Google Play Console';

  @override
  String get admStatsAccounts => 'Accounts';

  @override
  String get admOnlineNow => 'Online now (5 minutes)';

  @override
  String get admSuspendedAccounts => 'Suspended accounts';

  @override
  String get admStatsActiveNote =>
      'Online and active — accounts that made a request to the server. Only the minute and day are stored; no IP or device.';

  @override
  String get admChartTitle => 'New accounts — last 14 days';

  @override
  String admChartBar(String date, int count) {
    return '$date: $count new accounts';
  }

  @override
  String admChartTotal(int count) {
    return 'Total in 14 days: $count';
  }

  @override
  String get admStatsObjects => 'Main objects';

  @override
  String get admStatsGroupsCount => 'Groups';

  @override
  String get admStatsTeachers => 'Registered teachers';

  @override
  String get admStatsStudents => 'Students in groups';

  @override
  String get admStatsAssignments => 'Test sessions';

  @override
  String get admStatsResults => 'Test results';

  @override
  String get admStatsQuestions => 'Community questions';

  @override
  String get admStatsAnswers => 'Community answers';

  @override
  String get admStatsComplaintsOpen => 'Open complaints';

  @override
  String get admStatsComplaintsResolved => 'Resolved complaints';

  @override
  String get admStatsReportsOpen => 'Community: unreviewed reports';

  @override
  String get admStatsAwaiting => 'Messages: awaiting reply';

  @override
  String admStatsUpdated(String time) {
    return 'Updated: $time';
  }

  @override
  String get admComplaintsTitle => 'In-app complaints';

  @override
  String get admApple12Note =>
      'Handle reports of objectionable content promptly (Apple 1.2 requires timely action; target — 24 hours).';

  @override
  String get admFilterOpen => 'Open';

  @override
  String get admFilterResolved => 'Resolved';

  @override
  String get admAllKinds => 'All types';

  @override
  String get complaintKindComplaint => 'Complaint';

  @override
  String get complaintKindInappropriate => 'Inappropriate content';

  @override
  String get complaintKindBug => 'Bug';

  @override
  String get complaintKindAd => 'Advertising';

  @override
  String get complaintKindOther => 'Other';

  @override
  String get admComplaintsEmpty => 'No complaints in this list';

  @override
  String get admComplaintAnon => 'Guest (no account)';

  @override
  String admComplaintFrom(String email) {
    return 'From: $email';
  }

  @override
  String admComplaintTarget(String ref) {
    return 'Reference: $ref';
  }

  @override
  String get admComplaintNote => 'Admin note';

  @override
  String get admComplaintNoteHint => 'What was done? (admins only)';

  @override
  String get admComplaintSaveNote => 'Save note';

  @override
  String get admComplaintResolve => 'Mark resolved';

  @override
  String get admComplaintReopen => 'Reopen';

  @override
  String admComplaintResolvedOn(String date) {
    return 'Resolved: $date';
  }

  @override
  String get admSaved => 'Saved';

  @override
  String get admReportsEmpty => 'No reports in this list';

  @override
  String get admReportOpen => 'Open';

  @override
  String get admReportDismissed => 'Dismissed';

  @override
  String get admReportResolved => 'Resolved';

  @override
  String get admReportKindQuestion => 'Question';

  @override
  String get admReportKindAnswer => 'Answer';

  @override
  String admReportCount(int reports, int reporters) {
    return '$reports reports · $reporters people';
  }

  @override
  String admReportReasons(String reasons) {
    return 'Reason: $reasons';
  }

  @override
  String get admReportDeleted => 'Post deleted';

  @override
  String get admReportAuthorSuspended => 'Author suspended';

  @override
  String get admReportOpenPost => 'Open post';

  @override
  String get admReportDismiss => 'Dismiss';

  @override
  String get admReportResolve => 'Resolved';

  @override
  String get admReportSuspend => 'Suspend author';

  @override
  String get admReportDismissTitle => 'Dismiss the report?';

  @override
  String get admReportDismissBody =>
      'The reports are closed and no longer count towards automatic suspension. The action is logged.';

  @override
  String get admReportResolveTitle => 'Mark as resolved?';

  @override
  String get admReportResolveBody =>
      'Action has been taken (for example, the post was deleted). The action is logged.';

  @override
  String get admReportSuspendTitle => 'Suspend the author?';

  @override
  String get admReportSuspendBody =>
      'The author can no longer post in the community and their posts are hidden. The action is logged.';

  @override
  String get admSearchModeEmail => 'Email';

  @override
  String get admSearchModeName => 'Nickname';

  @override
  String get admSearchEmail => 'Full email (exact match)';

  @override
  String get admSearchName => 'Group nickname (at least 2 characters)';

  @override
  String get admUsersSearchNote =>
      'Emails are not stored in plain text: an account is found only by its full email and is shown masked.';

  @override
  String get admSearch => 'Search';

  @override
  String get admStatusActive => 'Active';

  @override
  String get admStatusSuspended => 'Suspended';

  @override
  String get admUserAdminTag => 'Admin';

  @override
  String get admUserTitle => 'User';

  @override
  String get admUserRole => 'Role';

  @override
  String get admRoleChanged => 'Role changed';

  @override
  String get admRoleSelfNote =>
      'You cannot change your own role or status here.';

  @override
  String admUserFacts(int owned, int joined, int threads, int complaints) {
    return 'Groups: $owned (teacher) · $joined (student) · messages: $threads · complaints: $complaints';
  }

  @override
  String get admAccountTitle => 'Account status';

  @override
  String get admAccountSuspend => 'Suspend account';

  @override
  String get admAccountSuspendTitle => 'Suspend the account?';

  @override
  String get admAccountSuspendBody =>
      'The user is signed out on all devices and cannot sign in again (email code, Google, Apple). The app shows them the contact address. The action is logged.';

  @override
  String get admAccountReactivate => 'Reactivate';

  @override
  String get admAccountReactivateTitle => 'Reactivate the account?';

  @override
  String get admAccountReactivateBody =>
      'The user can sign in again. The action is logged.';

  @override
  String get admAccountAdminNote => 'An admin account cannot be suspended.';

  @override
  String get admUserCommunity => 'Community status';

  @override
  String get admCommunityNone => 'Regular member';

  @override
  String admUserCommunityFacts(int questions, int answers, int reporters) {
    return 'Questions: $questions · answers: $answers · reporters: $reporters';
  }

  @override
  String get admCommunitySuspend => 'Suspend in community';

  @override
  String get admCommunitySuspendTitle => 'Suspend in the community?';

  @override
  String get admCommunitySuspendBody =>
      'The account can no longer post questions or answers and its posts are hidden. The rest of the app keeps working. The action is logged.';

  @override
  String get admErrOwner => 'The owner account cannot be suspended.';

  @override
  String get admErrSelf => 'You cannot apply this action to yourself.';

  @override
  String get admErrName => 'Nickname must be 2–40 characters.';

  @override
  String admAuditBy(String actor) {
    return 'By: $actor';
  }

  @override
  String get admAuditSystem => 'System';

  @override
  String get adminActionReportDismissed => 'Community report dismissed';

  @override
  String get adminActionReportResolved => 'Community report resolved';

  @override
  String get adminActionCommunitySuspended => 'Suspended in community';

  @override
  String get adminActionCommunityRestored => 'Restored in community';

  @override
  String get adminActionCommunityRevoked => 'Specialist verification revoked';

  @override
  String get adminActionAutoSuspended =>
      'Automatically suspended after reports';

  @override
  String get adminActionPostDeleted => 'Post deleted';

  @override
  String get adminActionPinned => 'Question pin changed';

  @override
  String get adminActionAccountDeleted => 'Account deleted';

  @override
  String get adminActionMfa => '2FA enabled';

  @override
  String get adminActionTeacher => 'Teacher registered';

  @override
  String get adminActionRoleChanged => 'Role changed';

  @override
  String get adminActionAccountSuspended => 'Account suspended';

  @override
  String get adminActionAccountReactivated => 'Account reactivated';

  @override
  String get adminActionComplaintNote => 'Complaint note added';

  @override
  String get adminActionComplaintResolved => 'Complaint resolved';

  @override
  String get adminActionComplaintReopened => 'Complaint reopened';

  @override
  String get adminActionIdentityLinked => 'Sign-in method linked';

  @override
  String get complaintFormTitle => 'Send a complaint in the app';

  @override
  String get complaintFormBody =>
      'Tell us about objectionable content, a bug or another problem — the LabGuide team will review it (usually within 24 hours).';

  @override
  String get complaintKindLabel => 'Type';

  @override
  String get complaintText => 'Text';

  @override
  String get complaintTextHint => 'What happened? Which screen or post?';

  @override
  String complaintTarget(String ref) {
    return 'Reference: $ref';
  }

  @override
  String get complaintSend => 'Send complaint';

  @override
  String get complaintSent => 'Sent. Thank you — we will review it.';

  @override
  String get complaintTooShort => 'Write at least 5 characters.';

  @override
  String complaintRateLimited(int minutes) {
    return 'Too many complaints: up to 5 per hour. Try again in $minutes min.';
  }

  @override
  String get complaintAnonNote =>
      'Without an account we cannot reply to you. If you need a reply, sign in or send an email.';

  @override
  String get complaintPhiNote =>
      'Do not include patient names or other personal data.';

  @override
  String get complaintFailed =>
      'Not sent. Check your connection and try again.';

  @override
  String authAccountSuspended(String email) {
    return 'Your account has been suspended. If you have questions, write to: $email';
  }

  @override
  String get admSectionComplaints => 'Complaints';

  @override
  String get bloodMorphTitle => 'Blood morphology';

  @override
  String get bloodMorphLabCardBody =>
      'Red cells, platelets, anemias: real micrographs, helper, practice';

  @override
  String get lectureSearchLabel => 'Search presentations';

  @override
  String get lectureSearchHint => 'Topic, test or slide title (e.g. glucose)';

  @override
  String get lectureFilterAll => 'All';

  @override
  String get lectureFilterProtocols => 'Practical protocols';

  @override
  String lectureFilterModule(int n) {
    return 'Module $n';
  }

  @override
  String get lectureLangAll => 'All languages';

  @override
  String lectureDecksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presentations',
      one: '$count presentation',
    );
    return '$_temp0';
  }

  @override
  String lectureSlidesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slides',
      one: '$count slide',
    );
    return '$_temp0';
  }

  @override
  String lectureSlidesMatch(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count slides match',
      one: '$count slide matches',
    );
    return '$_temp0';
  }

  @override
  String lectureMoreSlides(int count) {
    return '+$count more';
  }

  @override
  String lectureResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count presentations found',
      one: '$count presentation found',
    );
    return '$_temp0';
  }

  @override
  String get lectureNoResultsTitle => 'Nothing found';

  @override
  String get lectureNoResultsBody =>
      'Try another word or filter. Search works in Uzbek (Latin or Cyrillic), Russian and English.';

  @override
  String get lectureClearFilters => 'Clear search and filters';

  @override
  String lectureLangFallback(String wanted, String shown) {
    return 'This presentation is not available in $wanted; shown in $shown';
  }

  @override
  String get lectureDeckLoadFailed => 'Could not open the presentation';

  @override
  String get lectureFullscreen => 'Full screen';

  @override
  String get lectureFullscreenExit => 'Exit full screen';

  @override
  String get lectureSourcesTitle => 'Slide sources';

  @override
  String get lectureSourcesOpen => 'Show full sources';

  @override
  String lectureSourcesCount(int count) {
    return 'Sources: $count';
  }

  @override
  String lectureSourceLocator(String loc) {
    return 'Section/page: $loc';
  }

  @override
  String get lectureSourcesHint =>
      'The full list is on the last “References” slide.';

  @override
  String get lectureRotateTitle => 'Rotate the screen to landscape?';

  @override
  String get lectureRotateBody =>
      'In landscape the slide fills the whole screen. “No” keeps the current orientation.';

  @override
  String get lectureRotateCastBody =>
      'TVs and monitors are landscape, so landscape is recommended when casting.';

  @override
  String get lectureRotateYes => 'Yes';

  @override
  String get lectureRotateNo => 'No';

  @override
  String get lectureRotateRemember => 'Don’t ask again';

  @override
  String get lectureOrientationMenu => 'Screen orientation when presenting';

  @override
  String get lectureOrientationAsk => 'Always ask';

  @override
  String get lectureOrientationLandscape => 'Always landscape';

  @override
  String get lectureOrientationKeep => 'Don’t rotate';

  @override
  String get lectureMore => 'More actions';

  @override
  String get lectureCast => 'Show on TV';

  @override
  String get lectureCastTitle => 'Show on a TV or monitor';

  @override
  String get lectureCastHow =>
      'Casting uses your phone’s built-in screen mirroring: the TV shows the phone screen. In presentation mode the screen shows only the slide (no buttons) and stays on.';

  @override
  String get lectureCastStepsAndroid =>
      '1. Connect the phone and the TV to the same Wi‑Fi network.\n2. Open “Cast screen” (Cast, Smart View, Miracast — the name depends on the phone) and pick the TV.\n3. Come back to the app and tap “Start presentation”.';

  @override
  String get lectureCastStepsIos =>
      '1. Connect the iPhone/iPad and the TV (Apple TV or AirPlay-compatible) to the same Wi‑Fi network.\n2. Open Control Center (swipe down from the top-right corner) → Screen Mirroring → pick the TV.\n3. Come back to the app and tap “Start presentation”.';

  @override
  String get lectureCastOpenSettings => 'Open cast settings';

  @override
  String get lectureCastSettingsFailed =>
      'Could not open the settings — find “Cast screen” in Settings or in the quick settings panel.';

  @override
  String get lectureCastStart => 'Start presentation';

  @override
  String get lecturePresenter => 'Presenter view';

  @override
  String get lecturePresenterNext => 'Next slide';

  @override
  String get lecturePresenterLast => 'This is the last slide';

  @override
  String get lecturePresenterTimer => 'Time';

  @override
  String get lecturePresenterReset => 'Reset timer';

  @override
  String get lecturePresenterNote =>
      'Presenter view is on this device only. When mirroring, the TV shows the same view — use “Full screen” for the audience.';

  @override
  String get topicTestAction => 'Topic test';

  @override
  String get topicTestPreparing =>
      'Questions for this topic are being prepared';

  @override
  String get topicTestPreparingShort => 'Questions in preparation';

  @override
  String topicTestPreparingBody(int count) {
    return 'Only verified questions go into the test. This topic has $count so far — at least 3 are needed.';
  }

  @override
  String topicTestIntro(int count) {
    return '$count questions · the correct answer and explanation after each one';
  }

  @override
  String get topicTestSavedNote =>
      'If you leave, your answers are kept — you will continue from the same place.';

  @override
  String get topicTestSourcesNote =>
      'Questions come only from verified sources: official questions with a confirmed key and practice questions with a cited source.';

  @override
  String get topicTestStart => 'Start the test';

  @override
  String topicTestResume(int answered, int total) {
    return 'Continue · $answered/$total';
  }

  @override
  String topicTestBest(int score, int total) {
    return 'Best score: $score/$total';
  }

  @override
  String topicTestBadgeLabel(int score, int total) {
    return 'Topic test, best score $score of $total';
  }

  @override
  String get topicTestRetake => 'Retake';

  @override
  String get topicTestNextTopic => 'Next topic';

  @override
  String get topicTestOpenSlide => 'View slide';

  @override
  String get topicTestOpenDeckStart => 'Open the presentation from the start';

  @override
  String get topicTestHistory => 'Result history';

  @override
  String get topicTestAssign => 'Assign to a group';

  @override
  String topicTestLimitBody(int minutes) {
    return 'Each student gets $minutes min from the moment they start. When time runs out, answers are submitted automatically.';
  }

  @override
  String get topicTestLimitNoneBody =>
      'No time limit — students can take the test any time before the deadline.';

  @override
  String get topicTestOpenFor => 'How long the test stays open';

  @override
  String get topicTestAssignSub =>
      'Students join by QR or code; you see the results';

  @override
  String get topicTestSelf => 'Try it myself';

  @override
  String get topicTestSelfSub =>
      'Saved only on your device; not sent to students';

  @override
  String get topicTestAssignIntro =>
      'Students take the test on their own phones before the deadline; the score is calculated on the server.';

  @override
  String get topicTestGroups => 'Groups';

  @override
  String get topicTestNoGroups => 'You have no groups yet';

  @override
  String get topicTestNoGroupsBody =>
      'Create a group and invite students first — then assign the test from here.';

  @override
  String get topicTestPickGroup => 'Pick at least one group';

  @override
  String get topicTestReveal => 'Correct answers shown to students';

  @override
  String get topicTestRevealNow => 'Right after submitting';

  @override
  String get topicTestRevealAfterDue => 'After the deadline';

  @override
  String get topicTestRevealNeedsDue =>
      'Choose a deadline to use “After the deadline”';

  @override
  String topicTestSent(int count) {
    return 'Test sent to groups: $count';
  }

  @override
  String topicTestTitle(String title) {
    return 'Topic test: $title';
  }

  @override
  String get topicTestSentList => 'Sent tests';

  @override
  String topicTestAnswersLater(String date) {
    return 'Correct answers open after the deadline ($date) or when the teacher closes the test';
  }

  @override
  String get topicTestDistribution => 'Score distribution';

  @override
  String get topicTestHardest => 'Hardest questions';

  @override
  String get topicTestAssignedTitle => 'Assigned tests';

  @override
  String get topicTestMenu => 'Actions';

  @override
  String get topicTestOpenLecture => 'Open the presentation';

  @override
  String get topicTestCreateGroup => 'Create a group';

  @override
  String topicTestStudents(int count) {
    return 'Students: $count';
  }

  @override
  String topicTestReworkMistakes(int count) {
    return 'Review mistakes · $count';
  }

  @override
  String get cmErrAbusive =>
      'The text contains offensive or abusive language. Please rephrase it respectfully — the community rules require this.';

  @override
  String get admDeleteTitle => 'Delete account';

  @override
  String get admDeleteNote =>
      'For deletion requests received by email (completed within 30 days). To confirm, enter the user’s full email — the server checks that it belongs to exactly this account. The account, group memberships, community posts, support threads and sign-in methods are deleted permanently; for Sign in with Apple users the server attempts to revoke the Apple token. This cannot be undone; the action is logged.';

  @override
  String get admDeleteEmail => 'User’s full email';

  @override
  String get admDeleteButton => 'Delete account permanently';

  @override
  String get admDeleteConfirmTitle => 'Delete this account permanently?';

  @override
  String admDeleteConfirmBody(String email) {
    return 'The account $email and all data linked to it will be deleted. This cannot be undone.';
  }

  @override
  String get admDeleteDone => 'Account deleted';

  @override
  String get admDeleteMismatch =>
      'This email does not belong to this account — check it and try again.';

  @override
  String analyteSourcesBased(String sources) {
    return 'Based on sources: $sources';
  }

  @override
  String get sourcesPanelTitle => 'Sources';

  @override
  String get sourcesDisclaimer =>
      'Educational reference, not a diagnosis: a physician interprets results with clinical data; reference intervals depend on the laboratory and method.';

  @override
  String get refBooksNote =>
      'Books are cited as sources only — no text or figures were copied. The conclusion is the doctor’s.';

  @override
  String sourceLine(String cite) {
    return 'Source: $cite';
  }

  @override
  String get packsCoreSources =>
      'Source-based learning reference — every card lists its literature';

  @override
  String get examPracticeNotice =>
      'The result is for internal practice, not an official grade.';

  @override
  String sourcesPanelMore(int count) {
    return '+ $count more — in the list below';
  }

  @override
  String get classesPasteLink => 'Paste link';

  @override
  String get classesPasteNoCode =>
      'No invite code in the copied text. Copy the link or code your teacher sent.';

  @override
  String get classesScanTip =>
      'Scan the QR code with your phone camera and tap “Open in app” on the page that opens — the code fills in by itself.';

  @override
  String get qrScanAction => 'Scan QR code';

  @override
  String get qrScanHint =>
      'Fit the group or test QR code from your teacher inside the frame';

  @override
  String get qrScanTorchOn => 'Turn on flashlight';

  @override
  String get qrScanTorchOff => 'Turn off flashlight';

  @override
  String get qrScanTypeCode => 'Type or paste the code';

  @override
  String get qrScanNotInvite => 'This QR code is not a LabGuide group invite';

  @override
  String get qrScanDeniedTitle => 'Camera access is off';

  @override
  String get qrScanDeniedBody =>
      'To read the QR code, allow LabGuide to use the camera in Settings. The camera image is read on the phone only — it is not saved or sent. Or type the code yourself or paste the link.';

  @override
  String get qrScanOpenSettings => 'Open settings';

  @override
  String get qrScanFailedTitle => 'Couldn’t open the camera';

  @override
  String get qrScanFailedBody =>
      'Type the code yourself or paste the link from your teacher.';

  @override
  String get qrScanStarting => 'Opening camera…';

  @override
  String get classesJoinOpensTest =>
      'After joining, your teacher’s test opens right away.';

  @override
  String get classesJoinSignInTitle => 'Sign in to join the group';

  @override
  String get classesJoinSignInBody =>
      'With Google, Apple or an email code — it takes a minute. Your result reaches the teacher through this account; the invite code is kept.';

  @override
  String get classesNicknameTaken =>
      'This nickname is taken in the group — choose another.';

  @override
  String get classesNicknameAbusive =>
      'The nickname contains an inappropriate word — choose another.';

  @override
  String get classesTestQr => 'Test QR';

  @override
  String get classesTestQrBody =>
      'Students scan → sign in → nickname → this test opens. Results on this page update by themselves.';

  @override
  String get classesInviteLink => 'Copy link';

  @override
  String get classesLiveNote =>
      'Results refresh every 10 seconds. Pull down to refresh now.';

  @override
  String get boardOpen => 'Big screen';

  @override
  String get boardJoined => 'In group';

  @override
  String get boardStarted => 'Solving';

  @override
  String get boardSubmitted => 'Submitted';

  @override
  String get boardStatusWaiting => 'Waiting';

  @override
  String get boardStatusSolving => 'Solving…';

  @override
  String get boardScan => 'Scan to join';

  @override
  String get boardAnswersAfterClose =>
      'Correct answers appear after the test is closed.';

  @override
  String get boardEmpty => 'Nobody yet — scan the QR.';

  @override
  String get boardClose => 'Exit big screen';

  @override
  String get actionClose => 'Close';

  @override
  String get variantToggle => 'Different questions for each student';

  @override
  String variantOnBody(int pool, int n) {
    return 'Each student gets $n of the topic’s $pool questions, balanced across sub-topics.';
  }

  @override
  String get variantOffBody =>
      'Everyone gets the same questions (in shuffled order).';

  @override
  String variantDisabledBody(int pool, int need) {
    return 'This topic has $pool questions — different sets need at least $need (twice the question count). Lower the question count.';
  }

  @override
  String get variantUnsupported =>
      'Variant tests are not supported by this server.';

  @override
  String variantPoolTitle(int pool) {
    return 'Question pool ($pool)';
  }

  @override
  String get variantLabel => 'Variant test';

  @override
  String variantPerStudent(int n, int pool) {
    return '$n questions per student from a pool of $pool';
  }

  @override
  String variantReceived(int n) {
    return 'Given to $n students';
  }

  @override
  String get homeResumeCta => 'Continue';

  @override
  String homeResumeBody(String title) {
    return 'Last opened: $title';
  }

  @override
  String get homeHeroLabToifaCta => 'Today’s assessment practice';

  @override
  String get helpTitle => 'Help & contact';

  @override
  String get helpSub =>
      'In the app or by email — question, suggestion, complaint';

  @override
  String get helpIntro =>
      'Choose what suits you: an in-app message thread (the reply arrives here) or email (complaint, privacy request).';

  @override
  String get learnSectionQuizzesTitle => 'Section practice';

  @override
  String learnSectionQuizRow(String section) {
    return '$section — practice';
  }

  @override
  String get classesNicknameInvalid =>
      'A nickname may contain only letters, digits, spaces and . _ \' -, and must start and end with a letter or digit (no emoji or symbols like !?@).';

  @override
  String get classesGroupFull =>
      'The group is full (200 people) — tell your teacher.';

  @override
  String get classesCodeAmbiguous =>
      'Codes never contain 0, O, 1 or I. Check the code with your teacher or scan the QR.';

  @override
  String get classesOwnGroupTitle => 'You are this group’s teacher';

  @override
  String get classesOwnGroupBody =>
      'This account created the group, so it can’t join it as a student (switching the role in Profile doesn’t change that). To try it as a student, sign in with another account or take the test in student view.';

  @override
  String get classesOwnGroupOpen => 'Open as teacher';

  @override
  String get classesSwitchAccount => 'Sign in with another account';

  @override
  String get classesPreviewAsStudent => 'Try as a student';

  @override
  String get classesPreviewNote =>
      'Trial mode: answers are not sent to the server and don’t appear in the results.';

  @override
  String classesPreviewResult(int correct, int total) {
    return 'Trial finished: $correct / $total correct. Nothing was submitted.';
  }

  @override
  String get classesGiveTopicTest => 'Give a topic test';

  @override
  String get classesGiveTopicTestSub =>
      'Pick a topic — the next page sets the number of questions, variants, due date and when answers open.';

  @override
  String get classesTopicSearchHint => 'Search topics (e.g. anemia)';

  @override
  String get classesTopicNoMatch => 'No topic with a ready test found';

  @override
  String classesTopicQuestions(int count) {
    return '$count questions';
  }

  @override
  String examDeadlineAt(String date) {
    return 'Due: $date';
  }

  @override
  String get classesScanAskNick =>
      'Before joining, enter a nickname — your teacher sees your result under it (optional: leave empty to show your seat number). Then tap “Join”.';

  @override
  String get classesMyNickname => 'My nickname';

  @override
  String get classesNoNickname => 'None — your teacher sees your seat number';

  @override
  String get classesNicknameSaved => 'Nickname saved';

  @override
  String get classesNicknameNote =>
      'Don’t use your real name. Leave empty to show your seat number.';

  @override
  String get rolesTeacherRegisterNote =>
      '“Continue” registers your account as a teacher: you manage only the groups you create and see their results (not admin rights).';

  @override
  String get rolesTeacherSignInNote =>
      'Sign in to create groups — the signed-in account registers as a teacher with one tap when creating a group.';

  @override
  String get classesGiveGeneralTest => 'Give a general test';

  @override
  String get generalTestSub => 'From several topics — up to 50 questions';

  @override
  String get generalTestIntro =>
      'Pick topics — questions are spread evenly across them. Students take the test on their phones; the server scores it.';

  @override
  String get generalTestSources => 'Where questions come from';

  @override
  String get generalTestSearchHint => 'Search topics (e.g. anemia)';

  @override
  String get generalSourceToifa => 'Knowledge & Skills Assessment questions';

  @override
  String get generalSourceToifaSub => 'Official CLD list, keys checked';

  @override
  String get generalSourceLecture => 'Lecture topics';

  @override
  String get generalSourceLectureSub => 'A whole module or single days';

  @override
  String get generalSourcePack => 'By lab tests';

  @override
  String get generalSourcePackSub => 'Questions from test cards';

  @override
  String get generalSourceToifaShort => 'Assessment';

  @override
  String get generalSourceLectureShort => 'Lectures';

  @override
  String get generalSourcePackShort => 'Lab tests';

  @override
  String get generalSelectAll => 'Select all';

  @override
  String get generalAllShort => 'all';

  @override
  String generalDays(int count) {
    return 'Days · $count';
  }

  @override
  String generalSelected(int topics, int questions) {
    return 'Selected: $topics topics · $questions questions';
  }

  @override
  String get generalPickTopic => 'Pick at least one topic';

  @override
  String generalTestTitle(String topics) {
    return 'General test: $topics';
  }

  @override
  String get generalTestNameHint => 'E.g. Midterm 1';

  @override
  String get calSafeKind => 'Record type';

  @override
  String get calSafeKindTraining => 'Training';

  @override
  String get calSafeKindLab => 'Laboratory';

  @override
  String get calSafeTrainingTag => 'Training';

  @override
  String get calSafeTrainingNote =>
      'Training record: this is not laboratory evidence.';

  @override
  String get calSafeApprovedBy => 'Approved by (name / role)';

  @override
  String get calSafeApprovedAt => 'Approved on';

  @override
  String get calSafeApproverRequired =>
      '“Accepted” needs the name or role of the authorized person.';

  @override
  String get calSafeQcAfter => 'QC after calibration';

  @override
  String get calSafeQcPass => 'QC passed';

  @override
  String get calSafeQcFail => 'QC failed';

  @override
  String get calSafeQcNotRun => 'QC not run';

  @override
  String get calSafeQcNotRunWarn => 'QC not run after calibration';

  @override
  String get calSafeQcPassRequired =>
      '“Accepted” is possible only when QC after calibration passed.';

  @override
  String get calSafeSopRef => 'SOP reference (optional)';

  @override
  String get calSafeLegacyTag => 'Legacy, unverified';

  @override
  String get calSafeHistory => 'History';

  @override
  String get calSafeHistoryEmpty => 'No history entries.';

  @override
  String get calSafeAuditCreated => 'Created';

  @override
  String get calSafeAuditEdited => 'Edited';

  @override
  String get calSafeAuditDeleted => 'Deleted';

  @override
  String get calSafeHistoryNote =>
      'History stays even after a record is deleted. It is removed only by “delete local data”.';

  @override
  String get labDirSection => 'Laboratory directions (reference)';

  @override
  String get labDirSectionSub => 'Platform and test on separate cards';

  @override
  String labDirRowTitle(String name) {
    return '$name — reference cards';
  }

  @override
  String get labDirTb => 'Tuberculosis (TB) diagnostics';

  @override
  String get labDirHiv => 'HIV laboratory diagnostics';

  @override
  String get labDirTag => 'Reference';

  @override
  String get labDirNotVerified => 'Not added yet';

  @override
  String get labDirKindPlatform => 'Platform (instrument)';

  @override
  String get labDirKindTest => 'Test';

  @override
  String get labDirKindMethod => 'Method';

  @override
  String get labDirVsTest => 'Platform vs test';

  @override
  String get labDirTechnology => 'Technology';

  @override
  String get labDirSpecimens => 'Specimens';

  @override
  String get labDirTasks => 'Tasks';

  @override
  String get labDirPrinciple => 'Principle';

  @override
  String get labDirLimitations => 'Limitations';

  @override
  String get labDirQc => 'QC and calibration';

  @override
  String get labDirErrors => 'Preanalytic and analytic errors';

  @override
  String get labDirBiosafety => 'Biosafety';

  @override
  String get labDirModels => 'Models confirmed by an official source';

  @override
  String get labDirLinked => 'Linked cards';

  @override
  String get labDirStatusNeedsReview =>
      'Check status: sources are listed below; specialist sign-off not yet recorded';

  @override
  String get labDirManufacturerNote =>
      'Manufacturer page (marketing material), not an instruction';

  @override
  String get labDirVirology => 'Virology';

  @override
  String get labDirBacteriology => 'Bacteriology';

  @override
  String get labDirMycology => 'Mycology';

  @override
  String get labDirParasitology => 'Parasitology';

  @override
  String get labDirHematology => 'Haematology';

  @override
  String get labDirCoagulation => 'Coagulation (haemostasis)';

  @override
  String get labDirTransfusion => 'Transfusion medicine';

  @override
  String get labDirBiochemistry => 'Clinical biochemistry';

  @override
  String get labDirImmunology => 'Immunology';

  @override
  String get labDirUrinalysis => 'Urinalysis';

  @override
  String get labDirCytology => 'Cytology';

  @override
  String get labDirHistology => 'Histology';

  @override
  String get labDirOncology => 'Oncology';

  @override
  String get labDirGenetics => 'Genetics';

  @override
  String get labDirMolecular => 'Molecular diagnostics';

  @override
  String get labDirToxicology => 'Toxicology';

  @override
  String get labDirReproductive => 'Reproductive medicine';

  @override
  String get labDirNeonatal => 'Neonatal laboratory diagnostics';

  @override
  String get labDirTransplant => 'Transplantation';

  @override
  String get labDirGeneral => 'General laboratory';

  @override
  String get labDirDisclaimer =>
      'Educational reference only. The app does not diagnose and is not an operating protocol; decisions rest with an authorised laboratory and clinician.';

  @override
  String get labDirEmpty => 'No cards in this direction.';

  @override
  String get labDirPlatformClassNote =>
      'Class/technology reference — not verified for a specific model';

  @override
  String get labSchemGcMs =>
      'GC-MS instrument class — carrier gas cylinder, gas chromatograph with autosampler and a capillary column in the oven, ion source, quadrupole mass analyser, detector, vacuum pumps and data system';

  @override
  String get labSchemLcMs =>
      'LC-MS instrument class — solvent bottles, pump, autosampler, column compartment, electrospray ion source, quadrupole mass analyser, detector, vacuum pumps and data system';

  @override
  String get labSchemMaldiTof =>
      'MALDI-TOF mass spectrometer class — target plate with sample spots, laser, acceleration grids, flight tube, detector, vacuum pump and spectrum display';

  @override
  String get labSchemMicrobialIdAst =>
      'Automated microbial identification and susceptibility system class — cassette with suspension tubes and test cards, incubator-reader with optical scanner, loading chamber and monitor';

  @override
  String get labSchemBloodCulture =>
      'Automated blood culture system class — incubator cabinet with rows of culture bottles (each with a sensor at the bottom and a status light) and a monitor; aerobic and anaerobic bottles beside it';

  @override
  String get labSchemMycobacterialCulture =>
      'Automated mycobacterial liquid-culture system class — incubator-reader with drawers of culture tubes and status lights, and a monitor; tubes with a fluorescent oxygen sensor at the bottom beside it';

  @override
  String get labSchemFlowCytometer =>
      'Flow cytometer class — sheath fluid and waste containers, hydrodynamic focusing, laser, flow cell, forward-scatter detector, side-scatter and fluorescence detectors behind dichroic mirrors, sample tube and dot-plot display';

  @override
  String get labSchemRealTimePcr =>
      'Real-time PCR instrument class — thermal block with wells, heated lid, cut-away of the fluorescence path (excitation source and filter → reaction tube in the block → emission filter → detector), tube strip and amplification-curve display';

  @override
  String get labSchemCartridgeMolecular =>
      'Cartridge-based closed molecular platform class — instrument with separate modules (one open with a cartridge inside), disposable multi-chamber cartridge, specimen container and monitor';

  @override
  String get labSchemCoagAnalyzer =>
      'Automated coagulation analyzer class — cooled reagent positions, measuring cuvettes, pipetting arm, citrate sample tubes, optical clot detection (light source, cuvette, photodetector) and clotting-curve display';

  @override
  String get labSchemElisaReader =>
      'Microplate (ELISA) reader and washer class — reader with plate carrier and a coloured 96-well plate, light path through a well to the detector, washer with a needle manifold, wash buffer and waste containers';

  @override
  String get labSchemBscClass2 =>
      'Class II biological safety cabinet, side section — room air enters the front opening into the front grille, HEPA-filtered air flows down over the work surface, returns through the rear plenum to the blower, and part is exhausted through a second HEPA filter';

  @override
  String get labSchemAutoclave =>
      'Benchtop steam autoclave class — chamber with a loading tray and wrapped items, open door with seal, pressure and temperature gauges, safety valve and water reservoir';

  @override
  String get labSchemBloodGasIse =>
      'Blood gas and electrolyte (ISE) analyzer class — display, printer, sample inlet probe with a blood-gas syringe, sensor cassette with electrodes along the measuring channel, and reagent pack';

  @override
  String get labSchemHba1cAnalyzer =>
      'Compact HbA1c analyzer class — display, keypad, printer, rack of EDTA whole-blood tubes with a sampling arm, reagent bottles and waste container';

  @override
  String get labSchemLabFridge =>
      'Laboratory refrigerator-freezer class with temperature monitoring — glass-door refrigerator with racks and reagents, freezer compartment, probe in a buffered bottle and a digital data logger outside the unit';

  @override
  String get labSchemFluorescenceMicroscope =>
      'LED fluorescence microscope class — upright microscope with an LED epi-illumination module and filter slider, objectives, stage with slide; inset: bright yellow-green rods on a dark background (how auramine-stained bacilli appear)';

  @override
  String get labSchemCasa =>
      'Computer-aided sperm analysis (CASA) class — microscope with camera and heated stage, chamber slide, cable to a computer display showing tracks of motile spermatozoa';

  @override
  String get labSchemGelCardSystem =>
      'Gel (microcolumn) card system class — card centrifuge, incubator and an enlarged gel card with six microtubes: in positive tubes red cells stay at the top of or within the gel, in negative tubes they form a button at the bottom';

  @override
  String get labSchemEsrAnalyzer =>
      'ESR class — Westergren stand with upright tubes (clear plasma above settled red cells) and an automated reader with closed tubes and an optical reading bar';

  @override
  String get labSchemAggregometer =>
      'Platelet aggregometer and viscoelastic analyzer class — light-transmission aggregometer with stirred cuvettes, light source and photodetector, aggregation curves; viscoelastic analyzer with cup-and-pin channels and a clot trace';

  @override
  String get labSchemElectrophoresis =>
      'Electrophoresis apparatus class — power supply with leads, chamber with buffer compartments, electrodes, wicks and a support medium with stained protein bands, lifted cover, and a densitometer showing the scan';

  @override
  String get labSchemOsmometer =>
      'Freezing-point osmometer class — cooling block with the sample tube, thermistor probe in the sample, stirring wire, display with the freezing curve, keypad and small sample tubes';

  @override
  String get labSchemTlc =>
      'Thin-layer chromatography setup — glass developing tank with lid, solvent and a plate (origin line, separated spots, solvent front); UV lamp over a developed plate: spots appear dark on a fluorescent background';

  @override
  String get labSchemAnalyticalBalance =>
      'Gravimetric calibration setup — analytical balance with a glass weighing chamber and weighing vessel, pipette dispensing water, water beaker with thermometer';

  @override
  String get imgDiagramCalibrationOverviewAlt =>
      'Diagram, calibration workflow: 1 model, reagent and instruction revision; 2 calibrator lot, with values from this lot’s value sheet; 3 method-specific preparation; 4 calibration according to the instructions. Decision: post-calibration QC passed? Yes — accepted by an authorized person; no — not accepted, troubleshoot per the IFU and SOP. Parameters come only from the matching IFU.';

  @override
  String get imgDiagramDifferentialCountAlt =>
      'Diagram, manual leukocyte differential: 1 check the film (even, no lines or holes; if poor, make a new one); 2 count in the monolayer with the ×100 oil objective, moving one way without repeating fields; 3 count to the SOP target, usually 100 cells; 4 percentage of each cell type, absolute count = fraction × WBC. Decision: blasts or unidentified cells? Yes — do not interpret yourself, a hematologist or physician reviews the smear; no — compare with the reference interval on your laboratory’s report form.';

  @override
  String get imgDiagramQcDecisionAlt =>
      'Diagram, QC run decision: 1 measure the control materials; 2 plot them on the Levey–Jennings chart against the target mean ± SD. Decision: is a rejection rule violated (1-3s, 2-2s, R-4s, 4-1s, 10x)? No — accept the run (1-2s alone is a warning only). Yes — reject: stop and do not report patient results; find the cause instead of just repeating QC; fix it and recheck QC and patient samples; report once QC is in control and record the actions.';

  @override
  String get imgDiagramPreanalyticsAlt =>
      'Diagram, preanalytical phase in five steps: 1 prepare for testing (patient preparation); 2 select specimen and additive (tube for the test, order of draw); 3 collect and identify (full name matches the request form); 4 separate and store within sample stability; 5 transport and receive, rechecking labels and forms. Decision: specimen acceptable? Yes — analysis; no — follow the laboratory SOP.';

  @override
  String get imgDiagramPhotometryAlt =>
      'Diagram, absorbance photometry: light source, filter (wavelength λ), cuvette with light path ℓ, detector and result. Incident light I0, transmitted light I; absorbance A = log10(I0/I); Beer–Lambert law A = ε·ℓ·c. Measure blank, standard and sample; C = (A sample ÷ A standard) × C standard. Above the linearity limit: dilute, repeat and multiply by the dilution factor. Wavelength, blank and limits follow the reagent IFU.';

  @override
  String get imgDiagramEducationalFeedbackAlt =>
      'Diagram, learning from a practice quiz: 1 answer the questions; 2 see your score. Decision: any mistakes? No — try again or choose another topic. Yes — 3 review your mistakes with the correct answer and explanation; 4 practice only the questions you missed, then answer again. An app workflow, not a laboratory procedure.';

  @override
  String get imgDiagramCaption =>
      'General diagram drawn for LabGuide. Your instrument’s IFU and your laboratory SOP take precedence.';

  @override
  String get imgDiagramTapToZoom => 'Tap the diagram to enlarge';

  @override
  String get stepUpTitle => 'Confirm it\'s you';

  @override
  String stepUpBodyEmail(String email) {
    return 'This action needs a fresh confirmation. Enter the 6-digit code sent to $email.';
  }

  @override
  String get stepUpBodyEmailNoAddress =>
      'This action needs a fresh confirmation. Enter the 6-digit code sent to your email.';

  @override
  String get stepUpBodyTotp =>
      'This action needs a fresh confirmation. Enter the 6-digit code from your authenticator app.';

  @override
  String get stepUpConfirm => 'Confirm';

  @override
  String get stepUpCancelled =>
      'Not done: this action needs a fresh confirmation code.';

  @override
  String get admRevokeSessions => 'Sign out of all devices';

  @override
  String get admRevokeSessionsBody =>
      'The user is signed out on every device. The account stays active and they can sign in again.';

  @override
  String admRevokeSessionsDone(int count) {
    return 'Sessions ended: $count.';
  }

  @override
  String get profileSignOutAll => 'Sign out of all devices';

  @override
  String get profileSignOutAllBody =>
      'You will be signed out on this phone and on every other device where you signed in. Data on this device is kept.';

  @override
  String get profileSignOutAllDone => 'Signed out on all devices.';

  @override
  String get schemPartsPanelTitle => 'Parts and how it works';

  @override
  String get schemPartsPanelHint =>
      'Numbered parts, working principle and result';

  @override
  String get schemPartsPartsTitle => 'Main parts';

  @override
  String get schemPartsPrincipleTitle => 'Working principle';

  @override
  String get schemPartsResultTitle => 'Result';

  @override
  String get schemPartsClassNote =>
      'Parts are shown for the instrument class at principle level; their layout and design in a specific model may differ.';

  @override
  String get schemPartsChemistrySamplesName => 'Sample area';

  @override
  String get schemPartsChemistrySamplesFn =>
      'Tubes sit in a rack; the probe draws the sample from here.';

  @override
  String get schemPartsChemistryReagentsName => 'Cooled reagent carousel';

  @override
  String get schemPartsChemistryReagentsFn =>
      'Reagent bottles are kept cool; the required one is turned under the probe.';

  @override
  String get schemPartsChemistryProbesName => 'Sample and reagent probes';

  @override
  String get schemPartsChemistryProbesFn =>
      'Aspirate exact volumes of sample and reagent and dispense them into the reaction cuvette.';

  @override
  String get schemPartsChemistryReactionName => 'Reaction carousel (cuvettes)';

  @override
  String get schemPartsChemistryReactionFn =>
      'The mixture in the cuvettes is held at 37 °C; the carousel moves them past the photometer.';

  @override
  String get schemPartsChemistryPhotometerName => 'Photometer';

  @override
  String get schemPartsChemistryPhotometerFn =>
      'Lamp light passes through the cuvette; grating or filter optics measure absorbance at the selected wavelength.';

  @override
  String get schemPartsChemistryWaterName => 'Purified water container';

  @override
  String get schemPartsChemistryWaterFn =>
      'Supplies water for washing probes and cuvettes and for dilution.';

  @override
  String get schemPartsChemistryWasteName => 'Liquid waste container';

  @override
  String get schemPartsChemistryWasteFn =>
      'Collects wash water and used reaction mixtures.';

  @override
  String get schemPartsChemistryComputerName => 'Computer and software';

  @override
  String get schemPartsChemistryComputerFn =>
      'Orders tests, manages calibration, calculates results and issues the report.';

  @override
  String get schemPartsChemistryPrinciple =>
      'Probes dispense sample and reagent into a reaction cuvette and the mixture is incubated at 37 °C. The photometer measures absorbance of the light passing through the cuvette at a selected wavelength. Concentration is calculated from calibration; many models also measure Na, K and Cl with an ion-selective electrode (ISE).';

  @override
  String get schemPartsChemistryResult =>
      'Analyte concentration for each test (e.g. glucose, enzyme activity, electrolytes): a value calculated from the absorbance change and calibration, plus a report.';

  @override
  String get schemPartsPhotometerDisplayName => 'Display and keypad';

  @override
  String get schemPartsPhotometerDisplayFn =>
      'Select the method, wavelength and standard; the result and curve appear here.';

  @override
  String get schemPartsPhotometerNeedleName => 'Aspiration needle';

  @override
  String get schemPartsPhotometerNeedleFn =>
      'Draws the prepared mixture from the tube into the measuring cell.';

  @override
  String get schemPartsPhotometerCellName => 'Measuring cell (flow cell)';

  @override
  String get schemPartsPhotometerCellFn =>
      'Lamp → interference filter → cuvette → photodetector: absorbance is measured here.';

  @override
  String get schemPartsPhotometerPrinterName => 'Thermal printer';

  @override
  String get schemPartsPhotometerPrinterFn => 'Prints the results on paper.';

  @override
  String get schemPartsPhotometerWasteName => 'Waste container';

  @override
  String get schemPartsPhotometerWasteFn =>
      'Measured mixture and wash liquid drain here.';

  @override
  String get schemPartsPhotometerReagentsName => 'Reagent bottles';

  @override
  String get schemPartsPhotometerReagentsFn =>
      'Reagents stand outside the instrument; the operator adds them to the sample by hand.';

  @override
  String get schemPartsPhotometerPrinciple =>
      'The operator pipettes sample and reagent by hand and incubates the mixture. The instrument aspirates it into a flow cell (or a square cuvette is inserted); lamp light passes the selected interference filter and a photodetector measures absorbance. Concentration is calculated from a standard or a factor.';

  @override
  String get schemPartsPhotometerResult =>
      'The absorbance value and the concentration calculated from it, shown on the display and printed.';

  @override
  String get schemPartsHematology5AutoloaderName => 'Autoloader with rack';

  @override
  String get schemPartsHematology5AutoloaderFn =>
      'Mixes closed tubes and feeds them one by one to the sampler.';

  @override
  String get schemPartsHematology5ProbeName => 'Sample probe (open mode)';

  @override
  String get schemPartsHematology5ProbeFn =>
      'Aspirates a set volume of blood from an open tube held up by hand.';

  @override
  String get schemPartsHematology5ImpedanceName => 'Impedance chamber';

  @override
  String get schemPartsHematology5ImpedanceFn =>
      'Each red cell or platelet passing the aperture gives an electrical pulse: counting and sizing.';

  @override
  String get schemPartsHematology5LaserName => 'Laser flow cell';

  @override
  String get schemPartsHematology5LaserFn =>
      'White cells pass the laser beam one at a time and are classified by scatter (and fluorescence).';

  @override
  String get schemPartsHematology5DisplayName => 'Display (scattergram)';

  @override
  String get schemPartsHematology5DisplayFn =>
      'Shows results, scattergrams and histograms.';

  @override
  String get schemPartsHematology5ReagentsName => 'Reagents';

  @override
  String get schemPartsHematology5ReagentsFn =>
      'Diluent, lysing and staining solutions are fed through tubing.';

  @override
  String get schemPartsHematology5WasteName => 'Waste container';

  @override
  String get schemPartsHematology5WasteFn =>
      'Collects used dilutions and wash solutions.';

  @override
  String get schemPartsHematology5Principle =>
      'Blood is aspirated, diluted and split into several channels. Red cells and platelets are counted by impedance: a cell passing a small aperture produces a resistance pulse whose size reflects cell volume. The WBC differential is made by flow cytometry from laser light scatter (in some models with dye fluorescence); haemoglobin is measured photometrically after the red cells are lysed.';

  @override
  String get schemPartsHematology5Result =>
      'Complete blood count (CBC) parameters: cell counts and red-cell indices, a 5-part WBC differential, scattergrams and histograms.';

  @override
  String get schemPartsHematology3PrinterName => 'Thermal printer';

  @override
  String get schemPartsHematology3PrinterFn => 'Prints results and histograms.';

  @override
  String get schemPartsHematology3DisplayName => 'Display (3 histograms)';

  @override
  String get schemPartsHematology3DisplayFn =>
      'Shows results and WBC, RBC and PLT histograms (shapes in the picture are schematic).';

  @override
  String get schemPartsHematology3ProbeName => 'Sample probe';

  @override
  String get schemPartsHematology3ProbeFn =>
      'Aspirates a small volume of blood from an open tube.';

  @override
  String get schemPartsHematology3ImpedanceName => 'Impedance chamber';

  @override
  String get schemPartsHematology3ImpedanceFn =>
      'A cell passing the aperture gives a pulse: the pulse count is the cell count, the pulse size the cell volume.';

  @override
  String get schemPartsHematology3ReagentsName => 'Diluent and lysing solution';

  @override
  String get schemPartsHematology3ReagentsFn =>
      'For diluting blood and lysing red cells.';

  @override
  String get schemPartsHematology3WasteName => 'Waste container';

  @override
  String get schemPartsHematology3WasteFn => 'Collects used liquids.';

  @override
  String get schemPartsHematology3Principle =>
      'Blood is diluted; red cells and platelets are counted by impedance (the Coulter principle) and a volume histogram is built. After lysis, white cells are split by volume into three groups; haemoglobin is measured photometrically.';

  @override
  String get schemPartsHematology3Result =>
      'CBC with a 3-part WBC differential (lymphocytes, mid-size cells, granulocytes) and three histograms (WBC, RBC, PLT).';

  @override
  String get schemPartsImmunoassaySamplesName => 'Sample rack';

  @override
  String get schemPartsImmunoassaySamplesFn =>
      'Tubes are placed here; the probe draws the sample.';

  @override
  String get schemPartsImmunoassayReagentsName => 'Cooled reagent packs';

  @override
  String get schemPartsImmunoassayReagentsFn =>
      'Microparticles, labelled conjugate and other reagents are kept cool.';

  @override
  String get schemPartsImmunoassayProbesName => 'Pipetting probes';

  @override
  String get schemPartsImmunoassayProbesFn =>
      'Dispense sample and reagents into the reaction cuvette.';

  @override
  String get schemPartsImmunoassayCuvettesName => 'Cuvette feeder';

  @override
  String get schemPartsImmunoassayCuvettesFn =>
      'Supplies single-use reaction cuvettes to the incubator.';

  @override
  String get schemPartsImmunoassayIncubatorName => 'Incubator ring';

  @override
  String get schemPartsImmunoassayIncubatorFn =>
      'Cuvettes are held at a constant temperature while the antigen–antibody reaction proceeds.';

  @override
  String get schemPartsImmunoassayWashName =>
      'Wash station (magnetic separation)';

  @override
  String get schemPartsImmunoassayWashFn =>
      'A magnet holds the microparticles while unbound material is washed away.';

  @override
  String get schemPartsImmunoassayLuminometerName => 'Luminometer (detector)';

  @override
  String get schemPartsImmunoassayLuminometerFn =>
      'Measures the light emitted by the label by photon counting.';

  @override
  String get schemPartsImmunoassaySolidwasteName => 'Solid waste drawer';

  @override
  String get schemPartsImmunoassaySolidwasteFn =>
      'Collects used cuvettes and tips.';

  @override
  String get schemPartsImmunoassayLiquidsName => 'System solutions';

  @override
  String get schemPartsImmunoassayLiquidsFn =>
      'Containers of wash and system solutions.';

  @override
  String get schemPartsImmunoassayPrinciple =>
      'The sample is incubated with reagent in a cuvette: the analyte binds an antibody or antigen on magnetic microparticles. While a magnet holds the particles, unbound material is washed away; then the label (enzyme, acridinium ester or ECL label) emits light. The luminometer counts photons and the signal is converted to concentration with a calibration curve.';

  @override
  String get schemPartsImmunoassayResult =>
      'Concentration of analytes such as hormones, tumour and cardiac markers, or a qualitative positive/negative result, calculated from the light signal by calibration.';

  @override
  String get schemPartsUrineStripSampleName => 'Urine sample and test strip';

  @override
  String get schemPartsUrineStripSampleFn =>
      'The strip is briefly dipped in urine and the pads react.';

  @override
  String get schemPartsUrineStripTrayName => 'Strip tray (transport)';

  @override
  String get schemPartsUrineStripTrayFn =>
      'The strip is placed here and moved under the reading head.';

  @override
  String get schemPartsUrineStripHeadName =>
      'Reading head (LEDs and photosensor)';

  @override
  String get schemPartsUrineStripHeadFn =>
      'Lights the pads at several wavelengths and measures the reflected light.';

  @override
  String get schemPartsUrineStripDisplayName => 'Display';

  @override
  String get schemPartsUrineStripDisplayFn =>
      'Shows results and instrument status.';

  @override
  String get schemPartsUrineStripPrinterName => 'Printer';

  @override
  String get schemPartsUrineStripPrinterFn => 'Prints the results.';

  @override
  String get schemPartsUrineStripBinName => 'Used strip bin';

  @override
  String get schemPartsUrineStripBinFn => 'Read strips drop in here.';

  @override
  String get schemPartsUrineStripPrinciple =>
      'The test strip is dipped in urine; the reagent in each pad changes colour with its analyte. The instrument moves the strip under the reading head: LEDs of different wavelengths light the pads and a photosensor measures the reflected light (reflectance photometry). Colour intensity is converted to a semi-quantitative grade.';

  @override
  String get schemPartsUrineStripResult =>
      'A qualitative or semi-quantitative result for each pad (e.g. glucose, protein, blood, leukocytes, nitrite, pH, specific gravity) and a printed report.';

  @override
  String get schemPartsUrineSystemTransportName => 'Sample transport line';

  @override
  String get schemPartsUrineSystemTransportFn =>
      'Moves tube racks past the modules in turn.';

  @override
  String get schemPartsUrineSystemStripName => 'Chemistry module (test strip)';

  @override
  String get schemPartsUrineSystemStripFn =>
      'Reads the strip pads by reflectance and imaging.';

  @override
  String get schemPartsUrineSystemNeedlesName => 'Sampling needles';

  @override
  String get schemPartsUrineSystemNeedlesFn =>
      'Each module draws sample from the tube with its own needle.';

  @override
  String get schemPartsUrineSystemCameraName =>
      'Sediment module (microscope and camera)';

  @override
  String get schemPartsUrineSystemCameraFn =>
      'Captures digital microscope images of urine particles.';

  @override
  String get schemPartsUrineSystemDisplayName => 'Display (particle images)';

  @override
  String get schemPartsUrineSystemDisplayFn =>
      'Review of classified particle images and results.';

  @override
  String get schemPartsUrineSystemReagentsName => 'Reagent and wash solution';

  @override
  String get schemPartsUrineSystemReagentsFn =>
      'Solutions for washing the modules and for measurement.';

  @override
  String get schemPartsUrineSystemWasteName => 'Waste container';

  @override
  String get schemPartsUrineSystemWasteFn => 'Collects used liquids.';

  @override
  String get schemPartsUrineSystemPrinciple =>
      'Sample racks travel along the transport line to two modules. The chemistry module reads the strip pads by reflectance. The sediment module takes digital microscope images of the urine; software classifies particles (red cells, white cells, casts, crystals, etc.) and the images can be reviewed on screen.';

  @override
  String get schemPartsUrineSystemResult =>
      'Strip chemistry results plus counts or categories of sediment elements (red cells, white cells, casts, crystals, bacteria, etc.) with images for review.';

  @override
  String get schemPartsMassSpecGcGasName => 'Carrier gas cylinder';

  @override
  String get schemPartsMassSpecGcGasFn =>
      'An inert gas (usually helium) carries the sample through the column.';

  @override
  String get schemPartsMassSpecGcAutosamplerName => 'Autosampler';

  @override
  String get schemPartsMassSpecGcAutosamplerFn =>
      'Takes the sample from a vial with a syringe and injects it.';

  @override
  String get schemPartsMassSpecGcInjectorName => 'Injector (inlet)';

  @override
  String get schemPartsMassSpecGcInjectorFn =>
      'Heated inlet: the liquid sample vaporises into the gas stream.';

  @override
  String get schemPartsMassSpecGcColumnName => 'Oven and capillary column';

  @override
  String get schemPartsMassSpecGcColumnFn =>
      'Heated by a temperature programme; compounds separate in the column.';

  @override
  String get schemPartsMassSpecGcTransferName => 'Heated transfer line';

  @override
  String get schemPartsMassSpecGcTransferFn =>
      'Carries separated compounds into the mass spectrometer without condensation.';

  @override
  String get schemPartsMassSpecGcSourceName => 'Ion source';

  @override
  String get schemPartsMassSpecGcSourceFn =>
      'Ionises molecules (in GC-MS usually by electron ionisation), producing fragments.';

  @override
  String get schemPartsMassSpecGcAnalyserName => 'Mass analyser (quadrupole)';

  @override
  String get schemPartsMassSpecGcAnalyserFn =>
      'Electric fields sort ions by m/z and pass them through in turn.';

  @override
  String get schemPartsMassSpecGcDetectorName =>
      'Detector (electron multiplier)';

  @override
  String get schemPartsMassSpecGcDetectorFn =>
      'Turns arriving ions into an amplified electrical signal.';

  @override
  String get schemPartsMassSpecGcVacuumName => 'Vacuum pumps';

  @override
  String get schemPartsMassSpecGcVacuumFn =>
      'Turbomolecular and roughing pumps keep a high vacuum so ions collide with air molecules less often.';

  @override
  String get schemPartsMassSpecGcDataName => 'Data system';

  @override
  String get schemPartsMassSpecGcDataFn =>
      'Records chromatograms and spectra and compares them with a library.';

  @override
  String get schemPartsMassSpecGcPrinciple =>
      'The sample is vaporised in the injector and a carrier gas (usually helium) carries it into a capillary column in the oven. Compounds leave the column at different times according to volatility and interaction with the column (retention time). In the mass spectrometer they are ionised, the ions are sorted by mass-to-charge ratio (m/z) and recorded by the detector.';

  @override
  String get schemPartsMassSpecGcResult =>
      'A chromatogram (signal against retention time) and a mass spectrum for each peak (m/z against relative intensity); compounds are identified against a spectral library or standards.';

  @override
  String get schemPartsMassSpecLcSolventsName => 'Mobile phase bottles';

  @override
  String get schemPartsMassSpecLcSolventsFn =>
      'Solvents (e.g. water and an organic solvent) feed the pump.';

  @override
  String get schemPartsMassSpecLcPumpName => 'High-pressure pump';

  @override
  String get schemPartsMassSpecLcPumpFn =>
      'Drives the solvents through the column at a steady flow.';

  @override
  String get schemPartsMassSpecLcAutosamplerName => 'Autosampler';

  @override
  String get schemPartsMassSpecLcAutosamplerFn =>
      'Takes the sample from a vial and injects it into the flow.';

  @override
  String get schemPartsMassSpecLcColumnName => 'Column (in a thermostat)';

  @override
  String get schemPartsMassSpecLcColumnFn =>
      'Compounds separate by their interaction with the column phase.';

  @override
  String get schemPartsMassSpecLcEsiName => 'Electrospray ion source (ESI)';

  @override
  String get schemPartsMassSpecLcEsiFn =>
      'Sprays the column eluate into charged droplets, producing ions.';

  @override
  String get schemPartsMassSpecLcAnalyserName => 'Mass analyser (quadrupole)';

  @override
  String get schemPartsMassSpecLcAnalyserFn =>
      'Electric fields sort ions by m/z and pass them through in turn.';

  @override
  String get schemPartsMassSpecLcDetectorName =>
      'Detector (electron multiplier)';

  @override
  String get schemPartsMassSpecLcDetectorFn =>
      'Turns arriving ions into an amplified electrical signal.';

  @override
  String get schemPartsMassSpecLcVacuumName => 'Vacuum pumps';

  @override
  String get schemPartsMassSpecLcVacuumFn =>
      'Keep a high vacuum inside the mass analyser.';

  @override
  String get schemPartsMassSpecLcDataName => 'Data system';

  @override
  String get schemPartsMassSpecLcDataFn =>
      'Records chromatograms and spectra and calculates amounts.';

  @override
  String get schemPartsMassSpecLcPrinciple =>
      'A pump drives the liquid mobile phase through the column at high pressure and the autosampler injects the sample into the flow. Compounds separate in the column and leave it at different times. In the electrospray (ESI) source the liquid is sprayed into charged droplets and the compounds become gas-phase ions; the ions are sorted by m/z and recorded by the detector.';

  @override
  String get schemPartsMassSpecLcResult =>
      'A chromatogram and mass spectra; target compounds (drugs, metabolites, biomarkers) are identified and their concentration is calculated against calibrators.';

  @override
  String get schemPartsMaldiTofTargetName => 'Target plate';

  @override
  String get schemPartsMaldiTofTargetFn =>
      'Holds the sample spots with matrix; the plate is loaded into the vacuum chamber.';

  @override
  String get schemPartsMaldiTofLaserName => 'Laser';

  @override
  String get schemPartsMaldiTofLaserFn =>
      'A short pulse desorbs and ionises proteins together with the matrix.';

  @override
  String get schemPartsMaldiTofGridsName => 'Accelerating electrodes';

  @override
  String get schemPartsMaldiTofGridsFn =>
      'High voltage accelerates the ions into the flight tube.';

  @override
  String get schemPartsMaldiTofTubeName => 'Flight tube (TOF)';

  @override
  String get schemPartsMaldiTofTubeFn =>
      'A vacuum tube where ions fly at different speeds according to m/z.';

  @override
  String get schemPartsMaldiTofDetectorName => 'Detector';

  @override
  String get schemPartsMaldiTofDetectorFn =>
      'Records the arrival time of each ion.';

  @override
  String get schemPartsMaldiTofVacuumName => 'Vacuum pump';

  @override
  String get schemPartsMaldiTofVacuumFn =>
      'Creates the vacuum in the source and tube.';

  @override
  String get schemPartsMaldiTofDatabaseName => 'Computer and spectral database';

  @override
  String get schemPartsMaldiTofDatabaseFn =>
      'Compares the spectrum with reference spectra and gives a probability score.';

  @override
  String get schemPartsMaldiTofPrinciple =>
      'A colony is smeared on the target and overlaid with matrix, which crystallises. A laser pulse desorbs and ionises proteins (mainly ribosomal). An electric field accelerates the ions; in the flight tube lighter ions reach the detector before heavier ones, so flight time reflects m/z. The spectrum is compared with reference spectra in the database.';

  @override
  String get schemPartsMaldiTofResult =>
      'A mass spectrum (protein fingerprint) and the organism name with a probability score (log score); the result is read together with other clinical and laboratory findings.';

  @override
  String get schemPartsMicrobialIdAstCardName => 'Test card (64 wells)';

  @override
  String get schemPartsMicrobialIdAstCardFn =>
      'Wells hold antimicrobial dilutions (AST) or biochemical substrates (ID).';

  @override
  String get schemPartsMicrobialIdAstSuspensionName => 'Suspension tube';

  @override
  String get schemPartsMicrobialIdAstSuspensionFn =>
      'Bacterial suspension of standard density; the straw of the card dips into it.';

  @override
  String get schemPartsMicrobialIdAstFillingName => 'Filling chamber';

  @override
  String get schemPartsMicrobialIdAstFillingFn =>
      'Vacuum draws the suspension through the straw into the card wells.';

  @override
  String get schemPartsMicrobialIdAstIncubatorName => 'Incubator';

  @override
  String get schemPartsMicrobialIdAstIncubatorFn =>
      'Cards are held at a constant temperature between readings.';

  @override
  String get schemPartsMicrobialIdAstScannerName => 'Optical scanner';

  @override
  String get schemPartsMicrobialIdAstScannerFn =>
      'Measures the light through every well every 15 minutes.';

  @override
  String get schemPartsMicrobialIdAstSoftwareName => 'Computer and software';

  @override
  String get schemPartsMicrobialIdAstSoftwareFn =>
      'Calculates the MIC and interpretive category from growth curves and issues a report.';

  @override
  String get schemPartsMicrobialIdAstPrinciple =>
      'A suspension of standard density is made from a pure culture and drawn into the card through its straw under vacuum. AST card wells contain antimicrobials at different dilutions (a miniaturised automated MIC method). An optical scanner measures light through the wells every 15 minutes: growth attenuates the light, and software calculates the MIC from the growth kinetics.';

  @override
  String get schemPartsMicrobialIdAstResult =>
      'An MIC value and interpretive category for each antimicrobial (e.g. susceptible or resistant); with an identification card, the organism species.';

  @override
  String get schemPartsBloodCultureVialsName => 'Blood culture vials';

  @override
  String get schemPartsBloodCultureVialsFn =>
      'Aerobic and anaerobic vials with culture medium; the patient’s blood is added.';

  @override
  String get schemPartsBloodCultureSensorName => 'CO₂ sensor (vial bottom)';

  @override
  String get schemPartsBloodCultureSensorFn =>
      'A dye reacts with CO₂ and changes its fluorescence.';

  @override
  String get schemPartsBloodCultureIncubatorName => 'Incubator cabinet';

  @override
  String get schemPartsBloodCultureIncubatorFn =>
      'Vials sit in cells at a constant temperature.';

  @override
  String get schemPartsBloodCultureReaderName => 'Reading system';

  @override
  String get schemPartsBloodCultureReaderFn =>
      'A light source and detector under each cell measure the sensor every ten minutes.';

  @override
  String get schemPartsBloodCulturePositiveName => 'Positive vial indicator';

  @override
  String get schemPartsBloodCulturePositiveFn =>
      'Shows which vial has detected growth.';

  @override
  String get schemPartsBloodCultureSoftwareName => 'Computer and software';

  @override
  String get schemPartsBloodCultureSoftwareFn =>
      'Shows the growth curve and status of each vial.';

  @override
  String get schemPartsBloodCulturePrinciple =>
      'Blood-filled vials are placed in the incubator. Growing microorganisms release CO₂; the dye in the sensor at the vial bottom reacts with CO₂ and its fluorescence rises. The instrument reads the sensor every ten minutes; an algorithm flags the vial positive from the rate of CO₂ production and its absolute increase.';

  @override
  String get schemPartsBloodCultureResult =>
      'Status of each vial: positive (growth detected) or negative at the end of the protocol, time to positivity and the growth curve. A positive vial goes on to further microbiological work-up.';

  @override
  String get schemPartsMycobacterialCultureTubeName => 'MGIT tube';

  @override
  String get schemPartsMycobacterialCultureTubeFn =>
      'With liquid 7H9 medium and growth supplement (OADC); the specimen is inoculated here.';

  @override
  String get schemPartsMycobacterialCultureSensorName =>
      'Fluorescent oxygen sensor';

  @override
  String get schemPartsMycobacterialCultureSensorFn =>
      'Fluoresces brightly under UV light as oxygen falls.';

  @override
  String get schemPartsMycobacterialCultureDrawerName =>
      'Tube drawer (incubation and reading)';

  @override
  String get schemPartsMycobacterialCultureDrawerFn =>
      'Each station incubates a tube and its fluorescence is measured regularly.';

  @override
  String get schemPartsMycobacterialCultureLightsName => 'Status lights';

  @override
  String get schemPartsMycobacterialCultureLightsFn =>
      'Indicate positive or completed tubes.';

  @override
  String get schemPartsMycobacterialCulturePanelName => 'Instrument display';

  @override
  String get schemPartsMycobacterialCulturePanelFn =>
      'Shows drawer status and alerts.';

  @override
  String get schemPartsMycobacterialCultureSoftwareName =>
      'Computer (GU curves)';

  @override
  String get schemPartsMycobacterialCultureSoftwareFn =>
      'Records growth and DST results; curves of control and drug tubes are compared.';

  @override
  String get schemPartsMycobacterialCulturePrinciple =>
      'The MGIT tube holds modified Middlebrook 7H9 liquid medium and an oxygen-quenched fluorescent sensor at the bottom. As mycobacteria grow, dissolved oxygen is used up and the sensor fluoresces more brightly under UV light. The instrument reads each tube automatically and records the intensity as growth units (GU). In drug-susceptibility testing (DST) the GU of a drug tube are compared with those of a control tube.';

  @override
  String get schemPartsMycobacterialCultureResult =>
      'A positive or negative culture and a GU curve; in DST the instrument interprets first-line drugs as susceptible or resistant, while for second-line drugs the user interprets the GU values.';

  @override
  String get schemPartsFlowCytometerSheathName => 'Sheath fluid container';

  @override
  String get schemPartsFlowCytometerSheathFn =>
      'Surrounds the sample stream and squeezes it into a thin central core.';

  @override
  String get schemPartsFlowCytometerSampleName => 'Sample tube and probe';

  @override
  String get schemPartsFlowCytometerSampleFn =>
      'The stained cell suspension is drawn up from here.';

  @override
  String get schemPartsFlowCytometerFlowcellName =>
      'Flow cell (hydrodynamic focusing)';

  @override
  String get schemPartsFlowCytometerFlowcellFn =>
      'Cells pass one by one through the point where the laser crosses.';

  @override
  String get schemPartsFlowCytometerLaserName => 'Laser';

  @override
  String get schemPartsFlowCytometerLaserFn =>
      'Illuminates the cells and excites the fluorochromes.';

  @override
  String get schemPartsFlowCytometerFscName => 'Forward-scatter (FSC) detector';

  @override
  String get schemPartsFlowCytometerFscFn =>
      'Measures light scattered along the beam, which relates to cell size.';

  @override
  String get schemPartsFlowCytometerSscName =>
      'Side-scatter and fluorescence detectors';

  @override
  String get schemPartsFlowCytometerSscFn =>
      'Light collected to the side of the beam is split by colour with dichroic mirrors and filters onto separate detectors.';

  @override
  String get schemPartsFlowCytometerWasteName => 'Waste container';

  @override
  String get schemPartsFlowCytometerWasteFn =>
      'Collects the measured sample and sheath fluid.';

  @override
  String get schemPartsFlowCytometerComputerName => 'Computer (dot plots)';

  @override
  String get schemPartsFlowCytometerComputerFn =>
      'Builds dot plots; populations are separated by gating.';

  @override
  String get schemPartsFlowCytometerPrinciple =>
      'Cells are usually stained with fluorochrome-labelled antibodies. Sheath fluid hydrodynamically focuses the sample stream so the cells pass in single file through the laser beam. Forward scatter (FSC) reflects cell size, side scatter (SSC) internal complexity and fluorescence the markers; electronics digitise the signals.';

  @override
  String get schemPartsFlowCytometerResult =>
      'Dot plots and histograms; the proportion and number of cell populations (e.g. the absolute CD4+ T-cell count using calibrator beads).';

  @override
  String get schemPartsRealTimePcrTubesName => 'PCR tubes (strip)';

  @override
  String get schemPartsRealTimePcrTubesFn =>
      'Reaction mix and sample; read through the clear caps.';

  @override
  String get schemPartsRealTimePcrLidName => 'Heated lid';

  @override
  String get schemPartsRealTimePcrLidFn =>
      'Prevents condensation on the tube caps.';

  @override
  String get schemPartsRealTimePcrBlockName => 'Thermal block (Peltier)';

  @override
  String get schemPartsRealTimePcrBlockFn =>
      'Rapidly switches between denaturation, annealing and extension temperatures.';

  @override
  String get schemPartsRealTimePcrSourceName => 'Excitation light source';

  @override
  String get schemPartsRealTimePcrSourceFn =>
      'Provides light that excites the dye or probe.';

  @override
  String get schemPartsRealTimePcrExfilterName =>
      'Excitation filter (channel selection)';

  @override
  String get schemPartsRealTimePcrExfilterFn =>
      'Selects the excitation light needed for each dye channel.';

  @override
  String get schemPartsRealTimePcrTubeName => 'Reaction tube in the block';

  @override
  String get schemPartsRealTimePcrTubeFn =>
      'Excitation light reaches the dye or probe in the tube, which emits fluorescence proportional to the amount of amplicon.';

  @override
  String get schemPartsRealTimePcrEmfilterName => 'Emission filter';

  @override
  String get schemPartsRealTimePcrEmfilterFn =>
      'Passes only the dye’s fluorescence and blocks the excitation light.';

  @override
  String get schemPartsRealTimePcrDetectorName => 'Detector';

  @override
  String get schemPartsRealTimePcrDetectorFn =>
      'Measures the fluorescence from the tubes in every cycle.';

  @override
  String get schemPartsRealTimePcrSoftwareName =>
      'Software (amplification curves)';

  @override
  String get schemPartsRealTimePcrSoftwareFn =>
      'Plots the curves, sets the threshold and calculates Cq values.';

  @override
  String get schemPartsRealTimePcrPrinciple =>
      'The thermal block changes temperature every cycle: heating separates the DNA strands, primers anneal on cooling and a heat-stable polymerase builds new strands, so the target roughly doubles each cycle (RNA is first converted to cDNA by reverse transcriptase). The optical module reads the fluorescence of an intercalating dye or probe every cycle; the signal is proportional to amplicon accumulation.';

  @override
  String get schemPartsRealTimePcrResult =>
      'Amplification curves and, for each sample, the Cq (Ct): the cycle at which fluorescence crosses the threshold; a lower Cq means more starting target. In quantitative tests the concentration is calculated against standards (e.g. HIV-1 viral load in copies/mL).';

  @override
  String get schemPartsCartridgeMolecularCartridgeName =>
      'Single-use cartridge';

  @override
  String get schemPartsCartridgeMolecularCartridgeFn =>
      'A closed cartridge with sample and reagent chambers; all steps run inside it.';

  @override
  String get schemPartsCartridgeMolecularTubeName => 'Reaction tube';

  @override
  String get schemPartsCartridgeMolecularTubeFn =>
      'Amplification and fluorescence detection take place in this part of the cartridge.';

  @override
  String get schemPartsCartridgeMolecularSpecimenName => 'Specimen container';

  @override
  String get schemPartsCartridgeMolecularSpecimenFn =>
      'Holds the specimen, such as sputum, which is mixed with reagent.';

  @override
  String get schemPartsCartridgeMolecularModuleName => 'Instrument module';

  @override
  String get schemPartsCartridgeMolecularModuleFn =>
      'The cartridge goes in here and is processed automatically; modules run independently.';

  @override
  String get schemPartsCartridgeMolecularSoftwareName =>
      'Computer and software';

  @override
  String get schemPartsCartridgeMolecularSoftwareFn =>
      'Controls the run and reports the interpreted result.';

  @override
  String get schemPartsCartridgeMolecularPrinciple =>
      'The sample is mixed with reagent and added to the cartridge, which is placed in a module. The next steps run automatically inside the closed cartridge: sample processing, nucleic acid extraction, amplification (real-time PCR) and detection. The operator never opens the cartridge, which lowers the risk of amplicon contamination.';

  @override
  String get schemPartsCartridgeMolecularResult =>
      'For Xpert MTB/RIF: M. tuberculosis complex detected or not detected, and rifampicin resistance detected or not detected, in under 2 hours.';

  @override
  String get schemPartsCoagAnalyzerSamplesName => 'Citrate tube rack';

  @override
  String get schemPartsCoagAnalyzerSamplesFn =>
      'Sodium citrate tubes (light-blue caps); plasma is drawn from here.';

  @override
  String get schemPartsCoagAnalyzerReagentsName => 'Cooled reagent block';

  @override
  String get schemPartsCoagAnalyzerReagentsFn =>
      'Thromboplastin and other reagents are kept cool.';

  @override
  String get schemPartsCoagAnalyzerArmName => 'Pipetting arm';

  @override
  String get schemPartsCoagAnalyzerArmFn =>
      'Dispenses plasma and reagent into the cuvette in exact volumes.';

  @override
  String get schemPartsCoagAnalyzerCuvettesName => 'Measuring cuvettes';

  @override
  String get schemPartsCoagAnalyzerCuvettesFn =>
      'Plasma is warmed; after reagent is added clot formation is followed.';

  @override
  String get schemPartsCoagAnalyzerLightName => 'Light source';

  @override
  String get schemPartsCoagAnalyzerLightFn =>
      'Provides the light that passes through the cuvette.';

  @override
  String get schemPartsCoagAnalyzerDetectorName => 'Photodetector';

  @override
  String get schemPartsCoagAnalyzerDetectorFn =>
      'Records the change in transmitted light as the clot forms.';

  @override
  String get schemPartsCoagAnalyzerDisplayName => 'Display (clotting curve)';

  @override
  String get schemPartsCoagAnalyzerDisplayFn =>
      'Clotting curve, time and calculated INR.';

  @override
  String get schemPartsCoagAnalyzerPrinciple =>
      'The probe dispenses citrated plasma into a cuvette and warms it, then reagent is added (for PT, thromboplastin: tissue factor, calcium and phospholipids). As a fibrin clot forms the mixture becomes turbid: optical detection records the change in transmitted light, mechanical detection the stopping of movement. The time to this point is the clotting time.';

  @override
  String get schemPartsCoagAnalyzerResult =>
      'Clotting time in seconds and a clotting curve; for PT the INR is calculated from the patient PT, the mean normal PT and the reagent ISI.';

  @override
  String get schemPartsElisaReaderPlateName => '96-well microplate';

  @override
  String get schemPartsElisaReaderPlateFn =>
      'The reaction and colour develop in the wells; the carrier moves the plate into the reader.';

  @override
  String get schemPartsElisaReaderLampName => 'Light source (lamp)';

  @override
  String get schemPartsElisaReaderLampFn =>
      'Provides the light that passes through the well.';

  @override
  String get schemPartsElisaReaderFilterName => 'Optical filter';

  @override
  String get schemPartsElisaReaderFilterFn =>
      'Passes only the required wavelength.';

  @override
  String get schemPartsElisaReaderWellName => 'Well being read';

  @override
  String get schemPartsElisaReaderWellFn =>
      'The coloured solution absorbs part of the light.';

  @override
  String get schemPartsElisaReaderDetectorName => 'Photodetector';

  @override
  String get schemPartsElisaReaderDetectorFn =>
      'Measures the transmitted light, from which absorbance is calculated.';

  @override
  String get schemPartsElisaReaderWasherName => 'Washer needle manifold';

  @override
  String get schemPartsElisaReaderWasherFn =>
      'Dispenses wash buffer into the wells and aspirates it.';

  @override
  String get schemPartsElisaReaderBufferName => 'Wash buffer container';

  @override
  String get schemPartsElisaReaderBufferFn => 'Supplies buffer to the washer.';

  @override
  String get schemPartsElisaReaderWasteName => 'Waste container';

  @override
  String get schemPartsElisaReaderWasteFn => 'Collects the aspirated liquid.';

  @override
  String get schemPartsElisaReaderPrinciple =>
      'The antigen–antibody reaction proceeds in steps in the plate wells; between steps the washer removes unbound material. Finally substrate is added and the enzyme produces colour. The reader passes light of a selected wavelength through each well and measures absorbance (optical density); unknowns are read from a standard curve.';

  @override
  String get schemPartsElisaReaderResult =>
      'Optical density (OD) values for each well; a concentration from the standard curve, or a qualitative positive/negative result against a cut-off.';

  @override
  String get schemPartsBscClass2OpeningName => 'Front opening (inflow)';

  @override
  String get schemPartsBscClass2OpeningFn =>
      'Room air is drawn in here, protecting the operator.';

  @override
  String get schemPartsBscClass2GrilleName => 'Front grille';

  @override
  String get schemPartsBscClass2GrilleFn =>
      'Inflow air and air from the front of the work zone go in here; keep it clear.';

  @override
  String get schemPartsBscClass2WorkzoneName => 'Work zone and surface';

  @override
  String get schemPartsBscClass2WorkzoneFn =>
      'Samples are handled here under a downward flow of clean air.';

  @override
  String get schemPartsBscClass2DownflowName => 'Downflow HEPA filter';

  @override
  String get schemPartsBscClass2DownflowFn =>
      'Cleans particles from the air entering the work zone.';

  @override
  String get schemPartsBscClass2FanName => 'Fan (blower)';

  @override
  String get schemPartsBscClass2FanFn => 'Moves the air through the plenums.';

  @override
  String get schemPartsBscClass2ExhaustName => 'Exhaust HEPA filter';

  @override
  String get schemPartsBscClass2ExhaustFn =>
      'Cleans the exhausted air, protecting the environment.';

  @override
  String get schemPartsBscClass2PlenumName => 'Rear plenum';

  @override
  String get schemPartsBscClass2PlenumFn =>
      'Returns air from the grille to the fan.';

  @override
  String get schemPartsBscClass2SashName => 'Sash (front window)';

  @override
  String get schemPartsBscClass2SashFn =>
      'Shields the operator’s face and sets the height of the front opening.';

  @override
  String get schemPartsBscClass2Principle =>
      'A fan circulates the air. Room air is drawn through the front opening into the front grille, protecting the operator. HEPA-filtered air flows down over the work surface, protecting the work material. Surplus air leaves through the exhaust HEPA filter, protecting the environment.';

  @override
  String get schemPartsBscClass2Result =>
      'Not a measuring instrument: the outcome is a safe working environment (protection of the operator, the material and the environment). Performance is confirmed by regular airflow and filter testing and certification.';

  @override
  String get schemPartsAutoclaveChamberName => 'Pressure chamber';

  @override
  String get schemPartsAutoclaveChamberFn =>
      'The load is held in saturated steam under pressure here.';

  @override
  String get schemPartsAutoclaveDoorName => 'Door with seal and lock';

  @override
  String get schemPartsAutoclaveDoorFn =>
      'Seals the chamber and cannot be opened while under pressure.';

  @override
  String get schemPartsAutoclaveTrayName => 'Loading tray';

  @override
  String get schemPartsAutoclaveTrayFn =>
      'Items are arranged so that steam can circulate freely.';

  @override
  String get schemPartsAutoclavePressureName => 'Pressure gauge';

  @override
  String get schemPartsAutoclavePressureFn => 'Shows the chamber pressure.';

  @override
  String get schemPartsAutoclaveThermometerName => 'Thermometer';

  @override
  String get schemPartsAutoclaveThermometerFn =>
      'Shows the chamber temperature.';

  @override
  String get schemPartsAutoclaveValveName => 'Safety valve';

  @override
  String get schemPartsAutoclaveValveFn =>
      'Releases steam if the pressure gets too high.';

  @override
  String get schemPartsAutoclaveWaterName => 'Water reservoir';

  @override
  String get schemPartsAutoclaveWaterFn =>
      'Holds the water used to make steam.';

  @override
  String get schemPartsAutoclavePrinciple =>
      'Air is removed from the chamber and replaced by saturated steam. Pressure raises the boiling point of water, so the steam reaches high temperatures such as 121 °C or 132 °C. Steam contacts the items and kills microorganisms with heat; the process is controlled by steam quality, pressure, temperature and time. Trapped air prevents steam from reaching the load.';

  @override
  String get schemPartsAutoclaveResult =>
      'A sterilised load and a record of the cycle parameters (time, temperature, pressure); effectiveness is checked with chemical and biological indicators.';

  @override
  String get schemPartsBloodGasIseSyringeName =>
      'Sample in a heparinised syringe';

  @override
  String get schemPartsBloodGasIseSyringeFn =>
      'Arterial or other whole blood is brought without air bubbles.';

  @override
  String get schemPartsBloodGasIseProbeName => 'Sample inlet probe';

  @override
  String get schemPartsBloodGasIseProbeFn =>
      'Draws blood from the syringe into the measuring channel.';

  @override
  String get schemPartsBloodGasIseSensorsName => 'Sensors (electrodes)';

  @override
  String get schemPartsBloodGasIseSensorsFn =>
      'Separate electrodes for pH, pCO₂, pO₂ and electrolytes.';

  @override
  String get schemPartsBloodGasIseChannelName => 'Measuring channel';

  @override
  String get schemPartsBloodGasIseChannelFn =>
      'The sample flows over all sensors; the channel is temperature-controlled.';

  @override
  String get schemPartsBloodGasIsePackName => 'Reagent pack';

  @override
  String get schemPartsBloodGasIsePackFn => 'Calibration and wash solutions.';

  @override
  String get schemPartsBloodGasIseDisplayName => 'Display';

  @override
  String get schemPartsBloodGasIseDisplayFn =>
      'Shows measured and calculated values.';

  @override
  String get schemPartsBloodGasIsePrinterName => 'Printer';

  @override
  String get schemPartsBloodGasIsePrinterFn => 'Prints the results.';

  @override
  String get schemPartsBloodGasIsePrinciple =>
      'Whole blood from a heparinised syringe is drawn through the probe into the measuring channel and over the sensors. pH and pCO₂ are measured by potentiometry and pO₂ by amperometry; Na, K, Cl and ionised Ca by ion-selective electrodes. sO₂ is measured by co-oximetry or calculated; total CO₂, bicarbonate and base excess (BE) are calculated from the measured values.';

  @override
  String get schemPartsBloodGasIseResult =>
      'pH, pCO₂, pO₂, sO₂, electrolytes and metabolites (glucose, lactate, etc.) plus calculated bicarbonate and BE: measures of acid–base status and oxygenation.';

  @override
  String get schemPartsHba1cAnalyzerRackName => 'EDTA tube rack';

  @override
  String get schemPartsHba1cAnalyzerRackFn =>
      'Whole-blood tubes with purple caps.';

  @override
  String get schemPartsHba1cAnalyzerArmName => 'Sampling arm';

  @override
  String get schemPartsHba1cAnalyzerArmFn =>
      'Automatically takes blood from the tube and passes it to the measuring system.';

  @override
  String get schemPartsHba1cAnalyzerReagentsName => 'Reagent bottles';

  @override
  String get schemPartsHba1cAnalyzerReagentsFn =>
      'Reagent or buffer solutions for the analyzer’s method.';

  @override
  String get schemPartsHba1cAnalyzerDisplayName => 'Display';

  @override
  String get schemPartsHba1cAnalyzerDisplayFn =>
      'Shows the HbA1c result and run status.';

  @override
  String get schemPartsHba1cAnalyzerPrinterName => 'Printer';

  @override
  String get schemPartsHba1cAnalyzerPrinterFn => 'Prints the results.';

  @override
  String get schemPartsHba1cAnalyzerWasteName => 'Waste container';

  @override
  String get schemPartsHba1cAnalyzerWasteFn =>
      'Collects used solutions and sample.';

  @override
  String get schemPartsHba1cAnalyzerPrinciple =>
      'The analyzer samples EDTA whole blood automatically and measures the HbA1c fraction. The measuring method depends on the analyzer: ion-exchange chromatography, boronate affinity chromatography, immunoassay, an enzymatic method or capillary electrophoresis; the drawing does not show the method. HbA1c forms by non-enzymatic binding of glucose to the N-terminal valine of the haemoglobin beta chain.';

  @override
  String get schemPartsHba1cAnalyzerResult =>
      'The HbA1c result in NGSP (%) and IFCC (mmol/mol) units; it reflects glycaemic control over roughly 2–3 months.';

  @override
  String get schemPartsLabFridgeControllerName => 'Control panel (thermostat)';

  @override
  String get schemPartsLabFridgeControllerFn =>
      'Holds the set temperature and shows the current one.';

  @override
  String get schemPartsLabFridgeFridgeName => 'Refrigerator compartment';

  @override
  String get schemPartsLabFridgeFridgeFn =>
      'Samples, reagents and control materials are stored on the shelves.';

  @override
  String get schemPartsLabFridgeProbeName => 'Probe in a buffered bottle';

  @override
  String get schemPartsLabFridgeProbeFn =>
      'Measures product temperature and smooths brief swings when the door opens.';

  @override
  String get schemPartsLabFridgeLoggerName => 'Digital data logger (DDL)';

  @override
  String get schemPartsLabFridgeLoggerFn =>
      'Records the temperature regularly and alarms on excursions.';

  @override
  String get schemPartsLabFridgeFreezerName => 'Freezer compartment';

  @override
  String get schemPartsLabFridgeFreezerFn =>
      'Holds frozen aliquots (e.g. of control material).';

  @override
  String get schemPartsLabFridgePrinciple =>
      'The refrigeration unit keeps the compartment within a set range under thermostat control. A probe in a buffered bottle reflects product temperature (brief air-temperature swings are smoothed). A digital data logger (DDL) records the temperature at regular intervals and alarms on out-of-range readings; a backup temperature monitoring device is also recommended.';

  @override
  String get schemPartsLabFridgeResult =>
      'A continuous temperature record (min/max, excursions and alarms) documenting that samples and reagents were stored correctly.';

  @override
  String get schemPartsFluorescenceMicroscopeEyepiecesName => 'Eyepieces';

  @override
  String get schemPartsFluorescenceMicroscopeEyepiecesFn =>
      'For viewing the image.';

  @override
  String get schemPartsFluorescenceMicroscopeLedName => 'LED illuminator';

  @override
  String get schemPartsFluorescenceMicroscopeLedFn =>
      'Supplies excitation light instead of a mercury lamp.';

  @override
  String get schemPartsFluorescenceMicroscopeCubeName => 'Filter cube';

  @override
  String get schemPartsFluorescenceMicroscopeCubeFn =>
      'The excitation filter, dichroic mirror and emission filter separate the light.';

  @override
  String get schemPartsFluorescenceMicroscopeObjectiveName => 'Objective';

  @override
  String get schemPartsFluorescenceMicroscopeObjectiveFn =>
      'Directs light onto the slide and magnifies the image.';

  @override
  String get schemPartsFluorescenceMicroscopeStageName => 'Stage with smear';

  @override
  String get schemPartsFluorescenceMicroscopeStageFn =>
      'The auramine-stained sputum smear sits here.';

  @override
  String get schemPartsFluorescenceMicroscopeFocusName => 'Focus knobs';

  @override
  String get schemPartsFluorescenceMicroscopeFocusFn => 'Adjust the sharpness.';

  @override
  String get schemPartsFluorescenceMicroscopeFieldName => 'Field of view';

  @override
  String get schemPartsFluorescenceMicroscopeFieldFn =>
      'Bright yellow-green rods on a dark background: stained bacilli.';

  @override
  String get schemPartsFluorescenceMicroscopePrinciple =>
      'The smear is stained with auramine (a fluorochrome), which the mycobacterial cell wall retains. The LED illuminator sends blue excitation light through the filter cube and objective onto the slide. Stained bacilli emit longer-wavelength (yellow-green) light; the emission filter blocks the excitation light, so the bacilli shine on a dark background.';

  @override
  String get schemPartsFluorescenceMicroscopeResult =>
      'A microscopy report: acid-fast bacilli (bright rods) seen or not seen, with a semi-quantitative grade when present.';

  @override
  String get schemPartsCasaCameraName => 'Digital camera';

  @override
  String get schemPartsCasaCameraFn =>
      'Records the microscope image as a sequence of frames.';

  @override
  String get schemPartsCasaMicroscopeName => 'Microscope (objective)';

  @override
  String get schemPartsCasaMicroscopeFn =>
      'Magnifies the spermatozoa, usually with phase contrast.';

  @override
  String get schemPartsCasaStageName => 'Heated stage';

  @override
  String get schemPartsCasaStageFn =>
      'Keeps the sample temperature stable, as motility depends on temperature.';

  @override
  String get schemPartsCasaChamberName => 'Counting chamber';

  @override
  String get schemPartsCasaChamberFn =>
      'A chamber of fixed depth gives a sample layer of even thickness.';

  @override
  String get schemPartsCasaSoftwareName => 'Computer and software';

  @override
  String get schemPartsCasaSoftwareFn =>
      'Reconstructs the tracks and calculates kinematic parameters.';

  @override
  String get schemPartsCasaPrinciple =>
      'Semen is loaded into a counting chamber on the heated stage. The camera records successive frames through the microscope; software finds the sperm heads, reconstructs the track of each motile cell and calculates movement kinematics. Tracks of at least 200 motile cells are analysed.';

  @override
  String get schemPartsCasaResult =>
      'Kinematic parameters (e.g. curvilinear, straight-line and average path velocity) and motion types; according to the WHO manual, percentage motility may be unreliable because debris can be mistaken for immotile cells.';

  @override
  String get schemPartsGelCardSystemCentrifugeName => 'Card centrifuge';

  @override
  String get schemPartsGelCardSystemCentrifugeFn =>
      'Spins the cards at a set speed and time.';

  @override
  String get schemPartsGelCardSystemIncubatorName => 'Incubator';

  @override
  String get schemPartsGelCardSystemIncubatorFn =>
      'Incubates the cards for the antiglobulin test.';

  @override
  String get schemPartsGelCardSystemCardName => 'Gel card';

  @override
  String get schemPartsGelCardSystemCardFn =>
      'A plastic card; each microtube holds a gel or glass-bead matrix.';

  @override
  String get schemPartsGelCardSystemChamberName => 'Reaction chamber';

  @override
  String get schemPartsGelCardSystemChamberFn =>
      'Red cells and serum (or reagent) mix here.';

  @override
  String get schemPartsGelCardSystemGelName => 'Gel column (matrix)';

  @override
  String get schemPartsGelCardSystemGelFn =>
      'Traps agglutinates and lets single red cells through; may contain antiglobulin or anti-A, anti-B.';

  @override
  String get schemPartsGelCardSystemPositiveName => 'Positive reaction';

  @override
  String get schemPartsGelCardSystemPositiveFn =>
      'Red cells stay on top of or within the gel.';

  @override
  String get schemPartsGelCardSystemNegativeName => 'Negative reaction';

  @override
  String get schemPartsGelCardSystemNegativeFn =>
      'Red cells form a button at the bottom.';

  @override
  String get schemPartsGelCardSystemPrinciple =>
      'Red cell suspension and serum (or reagent) are added to the upper reaction chamber of the microtube and incubated. On centrifugation the red cells are driven into the gel or glass-bead matrix while the serum stays above. Agglutinates (e.g. antibody-coated cells linked by antiglobulin) are trapped in the gel (positive); unagglutinated cells pass to the bottom as a button (negative). The antiglobulin test needs no washing step.';

  @override
  String get schemPartsGelCardSystemResult =>
      'A reaction in each microtube: positive (agglutinates on top of or within the gel, graded by strength) or negative (button at the bottom); these give the blood group or the direct antiglobulin test result.';

  @override
  String get schemPartsEsrAnalyzerStandName => 'Westergren stand';

  @override
  String get schemPartsEsrAnalyzerStandFn =>
      'Holds the tubes strictly upright.';

  @override
  String get schemPartsEsrAnalyzerTubeName => 'Westergren tube';

  @override
  String get schemPartsEsrAnalyzerTubeFn =>
      'A graduated standard tube with a 2.5 mm bore.';

  @override
  String get schemPartsEsrAnalyzerBoundaryName => 'Plasma–red cell boundary';

  @override
  String get schemPartsEsrAnalyzerBoundaryFn =>
      'After one hour the distance to this boundary is read in millimetres.';

  @override
  String get schemPartsEsrAnalyzerReaderName => 'Automated reader';

  @override
  String get schemPartsEsrAnalyzerReaderFn =>
      'Measures sedimentation automatically in closed tubes.';

  @override
  String get schemPartsEsrAnalyzerTubesName => 'Closed tubes';

  @override
  String get schemPartsEsrAnalyzerTubesFn => 'The sample tube stays closed.';

  @override
  String get schemPartsEsrAnalyzerSensorsName => 'Optical sensors';

  @override
  String get schemPartsEsrAnalyzerSensorsFn =>
      'Detect the boundary between plasma and the red cell column.';

  @override
  String get schemPartsEsrAnalyzerDisplayName => 'Display';

  @override
  String get schemPartsEsrAnalyzerDisplayFn => 'Shows the results.';

  @override
  String get schemPartsEsrAnalyzerPrinciple =>
      'Anticoagulated blood settles by gravity in a standard upright tube (Westergren, 2.5 mm internal diameter) for one hour; the height of the clear plasma column is read in millimetres. In inflammation raised proteins promote rouleaux formation, so the cells settle faster. Automated readers follow the plasma–red cell boundary in closed tubes with optical sensors.';

  @override
  String get schemPartsEsrAnalyzerResult =>
      'The ESR value in mm/h; a non-specific measure read together with other tests.';

  @override
  String get schemPartsAggregometerChannelsName => 'LTA measuring channels';

  @override
  String get schemPartsAggregometerChannelsFn =>
      'Cuvettes are warmed to 37 °C and stirred.';

  @override
  String get schemPartsAggregometerLightName => 'Light source';

  @override
  String get schemPartsAggregometerLightFn =>
      'Provides the light that passes through the cuvette.';

  @override
  String get schemPartsAggregometerCuvetteName =>
      'Cuvette (plasma and stir bar)';

  @override
  String get schemPartsAggregometerCuvetteFn =>
      'Platelet-rich plasma; the agonist is added here.';

  @override
  String get schemPartsAggregometerPhotodetectorName => 'Photodetector';

  @override
  String get schemPartsAggregometerPhotodetectorFn =>
      'Measures the rise in light transmission during aggregation.';

  @override
  String get schemPartsAggregometerCurvesName => 'Aggregation curves';

  @override
  String get schemPartsAggregometerCurvesFn =>
      'Light transmission over time for each channel.';

  @override
  String get schemPartsAggregometerCupName => 'Cup with blood';

  @override
  String get schemPartsAggregometerCupFn =>
      'Citrated blood is clotted here with calcium and an activator.';

  @override
  String get schemPartsAggregometerPinName => 'Pin and torsion sensor';

  @override
  String get schemPartsAggregometerPinFn =>
      'Fibrin couples the pin to the cup; the transmitted torque is recorded.';

  @override
  String get schemPartsAggregometerTraceName => 'Viscoelastic trace';

  @override
  String get schemPartsAggregometerTraceFn =>
      'A plot of clot formation, strength and lysis.';

  @override
  String get schemPartsAggregometerPrinciple =>
      'LTA: platelet-rich plasma is stirred in a cuvette at 37 °C. After an agonist is added, platelets aggregate, the plasma clears and light transmission rises; the photodetector records this as a curve. TEG/ROTEM: citrated blood in a rotating cup is clotted with calcium and an activator; fibrin couples the pin to the cup and the transmitted torque is plotted as a trace.';

  @override
  String get schemPartsAggregometerResult =>
      'LTA: an aggregation curve for each agonist (light transmission over time). TEG/ROTEM: a viscoelastic trace showing clot formation, clot strength and fibrinolysis.';

  @override
  String get schemPartsElectrophoresisPowerName => 'Power supply';

  @override
  String get schemPartsElectrophoresisPowerFn =>
      'Applies a constant voltage to the electrodes.';

  @override
  String get schemPartsElectrophoresisElectrodesName =>
      'Buffer compartments and electrodes';

  @override
  String get schemPartsElectrophoresisElectrodesFn =>
      'The buffer carries the current; the cathode (−) and anode (+) set up the field.';

  @override
  String get schemPartsElectrophoresisWicksName => 'Wicks';

  @override
  String get schemPartsElectrophoresisWicksFn =>
      'Carry buffer to the support medium and complete the circuit.';

  @override
  String get schemPartsElectrophoresisMediumName =>
      'Support medium and fractions';

  @override
  String get schemPartsElectrophoresisMediumFn =>
      'Molecules separate into zones on agarose or cellulose acetate.';

  @override
  String get schemPartsElectrophoresisCoverName => 'Cover';

  @override
  String get schemPartsElectrophoresisCoverFn =>
      'Reduces evaporation and protects against electric shock.';

  @override
  String get schemPartsElectrophoresisDensitometerName => 'Densitometer';

  @override
  String get schemPartsElectrophoresisDensitometerFn =>
      'Scans the optical density of the stained zones and draws a densitogram.';

  @override
  String get schemPartsElectrophoresisPrinciple =>
      'The sample is applied to a buffer-soaked support medium (agarose, cellulose acetate or polyacrylamide). The power supply creates an electric field through the electrodes; charged molecules migrate at different speeds according to charge, size and shape and separate into zones. The zones are then stained and measured by optical density on a densitometer.';

  @override
  String get schemPartsElectrophoresisResult =>
      'Stained fractions (e.g. for serum proteins: albumin, alpha-1, alpha-2, beta, gamma) and a densitogram giving the relative share of each fraction; runs are compared with control samples.';

  @override
  String get schemPartsOsmometerTubesName => 'Sample tubes';

  @override
  String get schemPartsOsmometerTubesFn => 'A small volume of urine or serum.';

  @override
  String get schemPartsOsmometerThermistorName => 'Thermistor probe';

  @override
  String get schemPartsOsmometerThermistorFn =>
      'Dips into the sample and measures temperature precisely.';

  @override
  String get schemPartsOsmometerBathName => 'Cooling block (bath)';

  @override
  String get schemPartsOsmometerBathFn =>
      'Cools the sample below its freezing point.';

  @override
  String get schemPartsOsmometerWireName => 'Stirring wire';

  @override
  String get schemPartsOsmometerWireFn =>
      'Vibrates to start freezing in the supercooled sample.';

  @override
  String get schemPartsOsmometerDisplayName => 'Display (freezing curve)';

  @override
  String get schemPartsOsmometerDisplayFn =>
      'The temperature curve and the osmolality result.';

  @override
  String get schemPartsOsmometerPrinciple =>
      'The sample is supercooled below its freezing point in the cooling block, then vibration of the stirring wire starts freezing. Released latent heat raises the temperature to the freezing point, giving a plateau that the thermistor in a Wheatstone bridge circuit measures. Dissolved particles lower the freezing point: 1 mole of dissolved particles (1 osmol) per kilogram of water lowers it by about 1.86 °C; for electrolytes the particle count depends on dissociation. Osmolality is calculated from the measured depression.';

  @override
  String get schemPartsOsmometerResult =>
      'Urine or serum osmolality in mOsm/kg: particles per kilogram of water (osmolarity, by contrast, is per litre of solution, mOsm/L).';

  @override
  String get schemPartsTlcTankName => 'Developing tank (with lid)';

  @override
  String get schemPartsTlcTankFn =>
      'A closed glass tank saturated with solvent vapour.';

  @override
  String get schemPartsTlcSolventName => 'Mobile phase (solvent)';

  @override
  String get schemPartsTlcSolventFn =>
      'Rises up the plate by capillary action.';

  @override
  String get schemPartsTlcPlateName => 'TLC plate (silica gel GF254)';

  @override
  String get schemPartsTlcPlateFn =>
      'A thin silica gel layer with a fluorescent indicator that glows under UV.';

  @override
  String get schemPartsTlcOriginName => 'Origin line';

  @override
  String get schemPartsTlcOriginFn =>
      'Sample and standard spots are applied here.';

  @override
  String get schemPartsTlcFrontName => 'Solvent front';

  @override
  String get schemPartsTlcFrontFn =>
      'The line the solvent reached, marked to calculate Rf.';

  @override
  String get schemPartsTlcCapillariesName => 'Capillaries';

  @override
  String get schemPartsTlcCapillariesFn =>
      'For applying the sample as a small spot.';

  @override
  String get schemPartsTlcLampName => 'UV lamp (254 nm)';

  @override
  String get schemPartsTlcLampFn =>
      'Lights the plate and makes the spots visible.';

  @override
  String get schemPartsTlcSpotsName => 'Spots under UV';

  @override
  String get schemPartsTlcSpotsFn =>
      'Compounds quench the fluorescence and appear as dark spots on a green background.';

  @override
  String get schemPartsTlcPrinciple =>
      'Sample and standard spots are applied on the origin line and the plate is placed in the saturated tank with its lower edge in the solvent. As the solvent rises, compounds partition between the silica gel (stationary phase) and the solvent (mobile phase) and travel different distances. The developed plate is viewed under 254 nm UV light or sprayed with visualising reagents.';

  @override
  String get schemPartsTlcResult =>
      'Spot positions and Rf values (spot distance / solvent-front distance), compared with a standard to identify the compound.';

  @override
  String get schemPartsAnalyticalBalancePipetteName =>
      'Pipette (air displacement)';

  @override
  String get schemPartsAnalyticalBalancePipetteFn =>
      'The device being calibrated: it delivers the set volume.';

  @override
  String get schemPartsAnalyticalBalanceVesselName => 'Weighing vessel';

  @override
  String get schemPartsAnalyticalBalanceVesselFn =>
      'Receives the dispensed water for weighing.';

  @override
  String get schemPartsAnalyticalBalancePanName => 'Weighing pan';

  @override
  String get schemPartsAnalyticalBalancePanFn => 'Mass is measured here.';

  @override
  String get schemPartsAnalyticalBalanceEnclosureName => 'Glass enclosure';

  @override
  String get schemPartsAnalyticalBalanceEnclosureFn =>
      'Shields the weighing from air currents and dust.';

  @override
  String get schemPartsAnalyticalBalanceDisplayName => 'Display and keys';

  @override
  String get schemPartsAnalyticalBalanceDisplayFn =>
      'Shows the mass; the tare key zeroes the vessel mass.';

  @override
  String get schemPartsAnalyticalBalanceWaterName => 'Water container';

  @override
  String get schemPartsAnalyticalBalanceWaterFn =>
      'Pure (distilled) water equilibrated to room temperature.';

  @override
  String get schemPartsAnalyticalBalanceThermometerName => 'Thermometer';

  @override
  String get schemPartsAnalyticalBalanceThermometerFn =>
      'Measures the water temperature for the density correction.';

  @override
  String get schemPartsAnalyticalBalancePrinciple =>
      'The pipette dispenses its set volume of water into the vessel on the balance and the water mass is weighed. Mass is converted to volume with corrections for water density (temperature) and air buoyancy, so water and air temperatures are recorded. The pipette is calibrated on a ‘to deliver’ basis.';

  @override
  String get schemPartsAnalyticalBalanceResult =>
      'The calculated volume of each delivery; comparison with the nominal volume gives the accuracy (systematic error) and repeatability.';

  @override
  String get howToButton => 'How to use?';

  @override
  String get howToStepsTitle => 'Steps';

  @override
  String get howToResultTitle => 'What you get';

  @override
  String get howToWatchVideo => 'Watch the video';

  @override
  String howToVideoMb(String mb) {
    return '$mb MB';
  }

  @override
  String howToVideoNote(String duration) {
    return 'Silent screen recording with subtitles · $duration · opens in your browser or video player';
  }

  @override
  String howToVideoStartsAt(String time) {
    return 'In the video, this section starts at $time.';
  }

  @override
  String get howToVideoOffline =>
      'The video needs an internet connection. The text guide is right here and works offline.';

  @override
  String get howToVideoUnavailable =>
      'The video can’t be opened right now. Try again later — the text guide is right here.';

  @override
  String get howToCalibrationStep1 =>
      '“1. Instrument”: choose the model from the catalog or add an instrument that isn’t listed.';

  @override
  String get howToCalibrationStep2 =>
      '“2. Analyte”: type the test name (e.g. glucose) and pick it from the list.';

  @override
  String get howToCalibrationStep3 =>
      '“3. Reagent”: enter the manufacturer, REF number and IFU revision.';

  @override
  String get howToCalibrationStep4 =>
      'Tap “Show guide” — the app checks the match and shows the matching guidance.';

  @override
  String get howToCalibrationStep5 =>
      '“Create a calibration record”: enter the lot, values and outcome, then save the record.';

  @override
  String get howToCalibrationStep6 =>
      'All records are in the “Calibration log” and stay on this device only.';

  @override
  String get howToCalibrationResult =>
      'Calibration guidance matched to your instrument, analyte and reagent, plus an on-device calibration log.';

  @override
  String get howToQcStep1 =>
      '“Add test”: enter the test name, unit and control levels.';

  @override
  String get howToQcStep2 =>
      'Enter the target mean and SD for each level — the app never makes them up.';

  @override
  String get howToQcStep3 =>
      'After each run, enter the control results and tap “Save run”.';

  @override
  String get howToQcStep4 =>
      'Check the Levey–Jennings chart and the Westgard verdict: in control, warning or rejected.';

  @override
  String get howToQcStep5 =>
      '“Guides”: what to do when QC is rejected, external quality assessment (EQA) and critical values.';

  @override
  String get howToQcStep6 =>
      'Backup: copy your data as text and restore it later.';

  @override
  String get howToQcResult =>
      'A Levey–Jennings chart per level and a Westgard verdict for every run — on this device.';

  @override
  String get howToPreanalyticsStep1 =>
      'At the top — 5 stages: from preparing for the test to transport and receipt.';

  @override
  String get howToPreanalyticsStep2 =>
      'Patient preparation: fasting, medicines, exercise — every point with its source.';

  @override
  String get howToPreanalyticsStep3 =>
      'Order of draw: which tube is filled when during venipuncture (with cap colours).';

  @override
  String get howToPreanalyticsStep4 =>
      'Further down: separation, storage, transport and receipt conditions.';

  @override
  String get howToPreanalyticsStep5 =>
      'Check each point against your laboratory’s SOP.';

  @override
  String get howToPreanalyticsResult =>
      'Rules to check before and after sample collection — with sources, on one page.';

  @override
  String get howToCalculatorsStep1 =>
      'Pick a calculator: clinical formulas, manual methods or laboratory.';

  @override
  String get howToCalculatorsStep2 => 'Enter the values and check the units.';

  @override
  String get howToCalculatorsStep3 =>
      'If needed, choose a parameter (e.g. sex) and tap “Calculate”.';

  @override
  String get howToCalculatorsStep4 =>
      'Read the note and sources under the result: the formula’s limits are there.';

  @override
  String get howToCalculatorsResult =>
      'A result computed only from the values you enter — with its formula and source.';

  @override
  String get howToInstrumentsStep1 =>
      'Choose a direction: chemistry, hematology, immunochemistry or urine.';

  @override
  String get howToInstrumentsStep2 =>
      'Pick the manufacturer and model, or type the model name into search.';

  @override
  String get howToInstrumentsStep3 =>
      'Model card: “Save as ‘My instrument’”, then go to calibration or QC.';

  @override
  String get howToInstrumentsStep4 =>
      '“Laboratory directions (reference)”: cards for TB, HIV, bacteriology and other directions.';

  @override
  String get howToInstrumentsStep5 =>
      'The schematic on a card shows the instrument class in general, not an exact model.';

  @override
  String get howToInstrumentsResult =>
      'Reference cards by instrument and direction, schematics and quick access to calibration/QC.';

  @override
  String get howToMicroscopyStep1 =>
      'Choose a section: urine sediment, peripheral blood film or blood parasites (malaria).';

  @override
  String get howToMicroscopyStep2 =>
      'Tap an image: the card shows key features, author and license.';

  @override
  String get howToMicroscopyStep3 =>
      'Type a name into search (e.g. oxalate or neutrophil).';

  @override
  String get howToMicroscopyStep4 =>
      '“Start practice”: pick the right name out of 4 options — the answer shows at once.';

  @override
  String get howToMicroscopyStep5 =>
      'At the end of a round you see your score and can retry mistakes.';

  @override
  String get howToMicroscopyResult =>
      'An atlas of licensed micrographs and a picture practice to check yourself.';

  @override
  String get howToCoprologyStep1 =>
      '“Specimen collection”: container, timing, multiple samples, preservative.';

  @override
  String get howToCoprologyStep2 =>
      '“Macroscopic examination”: form, colour, reaction, admixtures.';

  @override
  String get howToCoprologyStep3 =>
      '“Coprogram microscopy”: a card for each element (muscle fibres, fat, starch and more).';

  @override
  String get howToCoprologyStep4 =>
      '“Occult blood”: FIT and guaiac test, preparation, result.';

  @override
  String get howToCoprologyStep5 =>
      '“Intestinal parasites”: concentration methods, a key to eggs and cysts (schematic).';

  @override
  String get howToCoprologyStep6 =>
      'Below — practical protocols (slides) and test cards.';

  @override
  String get howToCoprologyResult =>
      'A coprology reference from collection to result — with sources; it is not a diagnosis.';

  @override
  String get howToAssessmentStep1 =>
      'Choose your category (3–2, first or highest) and set a daily goal.';

  @override
  String get howToAssessmentStep2 =>
      '“Knowledge test”: a test of random questions from the official list.';

  @override
  String get howToAssessmentStep3 =>
      '“Topic practice”: the key and an explanation right after each answer.';

  @override
  String get howToAssessmentStep4 =>
      '“Oral ticket”: draw a ticket, prepare, view the answer plan and rate yourself.';

  @override
  String get howToAssessmentStep5 =>
      '“Mistake review” and “Progress”: rework mistakes and follow your results by topic.';

  @override
  String get howToAssessmentStep6 =>
      'The section is for Uzbekistan: in Uzbek, or Profile → “Knowledge & Skills Assessment” → “Uzbekistan”.';

  @override
  String get howToAssessmentResult =>
      'Practice on the official question list, your results and a review of mistakes — to check your own knowledge.';

  @override
  String get howToDifferentialStep1 =>
      '“Cell identification”: size, nucleus, cytoplasm and granules of each cell.';

  @override
  String get howToDifferentialStep2 =>
      '“Start counting”: tap +1, long-press −1; 100 or 200 cells.';

  @override
  String get howToDifferentialStep3 =>
      'When done, save the result to history — “Saved results”, on this device only.';

  @override
  String get howToDifferentialStep4 =>
      '“Differential: absolute counts”: absolute numbers from WBC and percentages.';

  @override
  String get howToDifferentialStep5 =>
      'Build your skills with “Interpretation” and the “Which cell is this?” practice.';

  @override
  String get howToDifferentialResult =>
      'A percentage differential, results saved on the device, interpretation notes and practice.';

  @override
  String get howToCytologyStep1 =>
      '“Cells and organisms”: a drawing and the key feature of each item.';

  @override
  String get howToCytologyStep2 =>
      '“Vaginal smear cleanliness grade”: mark what you see — the app shows the grade.';

  @override
  String get howToCytologyStep3 =>
      '“The Bethesda system”: what a Pap report means.';

  @override
  String get howToCytologyStep4 =>
      'Sample adequacy, reactive changes and the maturation index — on separate pages.';

  @override
  String get howToCytologyStep5 => '“Which cell is this?”: a picture practice.';

  @override
  String get howToCytologyResult =>
      'A learning reference for the gynaecological smear, the cleanliness grade and practice; not a diagnosis.';

  @override
  String get howToSpermogramStep1 =>
      '“Key parameters”: the WHO 2021 lower reference limits.';

  @override
  String get howToSpermogramStep2 =>
      '“Counter”: count motility and morphology.';

  @override
  String get howToSpermogramStep3 =>
      '“Assess a result”: enter the values — they are compared with the WHO limits.';

  @override
  String get howToSpermogramStep4 =>
      '“Terms” and “Pre-analytics”: oligo-, astheno-, terato-; abstinence, collection, delivery.';

  @override
  String get howToSpermogramStep5 =>
      '“Practice”: check your knowledge with questions.';

  @override
  String get howToSpermogramResult =>
      'A result compared with the WHO 2021 limits, terms and practice — a learning reference.';

  @override
  String get howToBloodGroupStep1 =>
      '“ABO and RhD basics”: antigens, antibodies, forward and reverse grouping.';

  @override
  String get howToBloodGroupStep2 =>
      '“Methods” and “Compatibility”: slide, tube, gel card; compatibility testing.';

  @override
  String get howToBloodGroupStep3 =>
      '“Discrepancies and errors”: forward/reverse mismatch, weak D.';

  @override
  String get howToBloodGroupStep4 =>
      '“Reaction pattern reader”: mark the results — the app shows a learning interpretation.';

  @override
  String get howToBloodGroupStep5 =>
      '“Practice”; transfusion decisions follow your local protocol only.';

  @override
  String get howToBloodGroupResult =>
      'A learning reference on ABO and RhD and a learning interpretation of reaction patterns.';

  @override
  String get howToHistologyStep1 =>
      '“Tissues and organs”: epithelium, connective, muscle, nerve; liver, kidney.';

  @override
  String get howToHistologyStep2 =>
      'Open an image: a real micrograph, the key feature and what to look at.';

  @override
  String get howToHistologyStep3 =>
      '“Staining methods”: H&E, Masson, elastic, silver, PAS, LFB.';

  @override
  String get howToHistologyStep4 =>
      '“Which tissue is this?”: a picture practice.';

  @override
  String get howToHistologyStep5 =>
      '“Picture credits”: the author and license of every image.';

  @override
  String get howToHistologyResult =>
      'A tissue atlas with licensed micrographs, staining methods and practice.';

  @override
  String get howToUrinalysisStep1 =>
      '“Collection and preservation”: morning sample, midstream, timing, refrigeration.';

  @override
  String get howToUrinalysisStep2 =>
      '“Physical properties”: colour, clarity, odour, specific gravity.';

  @override
  String get howToUrinalysisStep3 =>
      '“Strip test (chemical examination)”: 10 pads — meaning, interferences, confirmation.';

  @override
  String get howToUrinalysisStep4 =>
      '“Sediment microscopy”: cells, casts, crystals, organisms.';

  @override
  String get howToUrinalysisStep5 =>
      '“Result reader” and “Practice: what is this?” — check yourself.';

  @override
  String get howToUrinalysisResult =>
      'A step-by-step urinalysis reference, a result reader and practice.';

  @override
  String get howToBloodMorphStep1 =>
      '“The normal red cell and what to look at”: size, colour, shape, inclusions.';

  @override
  String get howToBloodMorphStep2 =>
      '“Red cell changes”: picture cards — what you see and what it may point to.';

  @override
  String get howToBloodMorphStep3 =>
      '“Platelets” and “Reticulocytes”: counting principles and artefacts.';

  @override
  String get howToBloodMorphStep4 =>
      '“Anaemia classification helper”: Hb, MCV, RDW → morphological group.';

  @override
  String get howToBloodMorphStep5 =>
      '“Practice: which change is this?” — picture and knowledge questions.';

  @override
  String get howToBloodMorphResult =>
      'A picture reference for the peripheral blood film, an anaemia helper and practice.';

  @override
  String get howToCoagulogramStep1 =>
      '“What each test measures”: PT/INR, APTT, thrombin time, fibrinogen, D-dimer.';

  @override
  String get howToCoagulogramStep2 =>
      '“Sample requirements”: 3.2% citrate, 9:1 ratio, timing, pre-analytical errors.';

  @override
  String get howToCoagulogramStep3 =>
      '“Result reading helper”: PT, APTT and platelets → possible causes from the source.';

  @override
  String get howToCoagulogramStep4 =>
      '“ISTH overt DIC score”: enter the values — the score is calculated.';

  @override
  String get howToCoagulogramStep5 =>
      '“Anticoagulant monitoring”: warfarin — INR, heparin — APTT/anti-Xa.';

  @override
  String get howToCoagulogramResult =>
      'A hemostasis test reference, a result reading helper and the DIC score — with sources.';

  @override
  String get proPayTierPro => 'Pro';

  @override
  String get proPayTierProSub =>
      'Paid plans: Student Pro, Teacher Pro, Specialist Pro and Premium';

  @override
  String get proPayTierTeacher => 'Teacher Pro';

  @override
  String get proPayTierTeacherSub =>
      'For teachers (teacher panel): create tests, attach students, groups and manage results.';

  @override
  String get proPayFree =>
      'Free features stay free and have no daily limits. When a trial or subscription ends, only the paid features close.';

  @override
  String get proPayFeatQuestions => 'Practice by topic and card mini-tests';

  @override
  String get proPayFeatExam => 'Exam simulation (timed test)';

  @override
  String get proPayFeatToifa =>
      'The full qualification exam bank: official test and practice by topic';

  @override
  String get proPayFeatWeak => 'Weak-topic analysis in your results';

  @override
  String get proPayFeatAtlas => 'Microscopy atlas practice';

  @override
  String get proPayFeatHistory => 'Full results history';

  @override
  String get proPayFeatAllPro => 'Everything in Student Pro';

  @override
  String get proPayFeatGroups =>
      'Groups: add students, grades and results reports';

  @override
  String get proPayFeatAssignments => 'Group assignments (timed tests)';

  @override
  String get proPayFeatLecture =>
      'Lecture mode: automatic presentation for a topic';

  @override
  String get proPayFeatLabCount =>
      'Differential count: counting and saving the result';

  @override
  String get proPayFeatLabAbsolute =>
      'Differential count: percentages and absolute counts';

  @override
  String get proPayFeatLabEvaluate => 'Differential count: result evaluation';

  @override
  String get proPayFeatLabSections =>
      'Laboratory sections: cytology, semen analysis, blood group, histology, urinalysis, blood morphology, coprology';

  @override
  String get proPayFeatLabCoag => 'Coagulogram';

  @override
  String get proPayFeatLabInstruments => 'Instrument catalogue';

  @override
  String get proPayFeatLabDirections => 'Laboratory direction cards';

  @override
  String get proPayFeatLabCalibration => 'Calibration and calibration log';

  @override
  String get proPayFeatLabQc => 'Quality control (QC)';

  @override
  String get proPayFeatLabCalculators => 'Laboratory calculators';

  @override
  String get proPayPlanMonthly => 'Monthly';

  @override
  String get proPayPlanYearly => 'Yearly';

  @override
  String get proPayUnitDay => 'day';

  @override
  String get proPayUnitWeek => 'week';

  @override
  String get proPayUnitMonth => 'month';

  @override
  String get proPayUnitYear => 'year';

  @override
  String proPayDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String proPayWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String proPayMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String proPayYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String proPayPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String proPayTrial(String trial, String price) {
    return '$trial free, then $price. The price and renewal terms are those shown in the store sheet.';
  }

  @override
  String get proPayStartTrial => 'Start free trial';

  @override
  String get proPaySubscribe => 'Subscribe';

  @override
  String get proPayCurrent => 'Active subscription';

  @override
  String get proPayRestore => 'Restore purchases';

  @override
  String get proPayManage => 'Manage or cancel subscription';

  @override
  String get proPayTerms => 'Terms of Use (EULA)';

  @override
  String get proPayPrivacy => 'Privacy Policy';

  @override
  String proPayDisclosure(String store) {
    return 'Subscriptions renew automatically. The price and period are shown in the $store sheet before you buy; you are charged only after you confirm the purchase yourself in that sheet (if the store shows a free trial or introductory offer, after it ends, at the price and renewal terms shown by the store). Payment is charged to your $store account. Unless cancelled at least 24 hours before the end of the current period, the subscription renews for the same period and price, and your account is charged within 24 hours before the period ends. You can manage and cancel the subscription in your $store account settings; deleting your LabGuide account does not cancel it. Refund requests are handled by $store.';
  }

  @override
  String get proPayGuestNote =>
      'Sign in to subscribe, restore a purchase or start the free trial. The free part of the app works without an account too.';

  @override
  String get proPaySignInRequired =>
      'Please sign in first to subscribe or restore a purchase.';

  @override
  String get proPayLockedPro =>
      'This feature is part of the paid plans: Student Pro, Teacher Pro, Specialist Pro or Premium.';

  @override
  String get proPayLockedTeacher =>
      'This feature is part of the Teacher Pro and Premium plans.';

  @override
  String get proPayLockedLab =>
      'This feature is part of the Specialist Pro and Premium plans.';

  @override
  String get proPayAllOpen => 'All features are open right now.';

  @override
  String get proPayTestBuildOpen => 'Test build: all features are open.';

  @override
  String proPayStatusTeacher(String date) {
    return 'Teacher Pro is active · until $date';
  }

  @override
  String get proPayStatusTeacherNoEnd => 'Teacher Pro is active';

  @override
  String get proPayStatusDevice =>
      'The subscription is active on this device. Sign in to use it on your other devices too.';

  @override
  String get proPaySuccess => 'Your subscription is active. Thank you!';

  @override
  String get proPayRestored => 'Purchase restored.';

  @override
  String get proPayPending =>
      'Waiting for the payment to be approved. The subscription will unlock automatically once it is.';

  @override
  String get proPayNothingFound =>
      'No active subscription was found to restore.';

  @override
  String get proPayOwnedByOther =>
      'This purchase is linked to another LabGuide account. Sign in to that account.';

  @override
  String get proPayFailed =>
      'The purchase didn’t complete. Check your connection and try again. If you were charged, tap “Restore purchases”.';

  @override
  String get proPayUnavailable =>
      'The store isn’t responding right now. Please try again later.';

  @override
  String proPayDeleteAccountNote(String store) {
    return 'Deleting your account doesn’t cancel your subscription: cancel it in your $store settings.';
  }

  @override
  String get proRowTitle => 'Subscription and restore';

  @override
  String get proRowSub => 'Free · Pro · Premium';

  @override
  String get proPurchaseTitle => 'Pro and Premium plans';

  @override
  String get proStatusTitle => 'Status';

  @override
  String proStatusPro(String date) {
    return 'Pro is active · until $date';
  }

  @override
  String get proStatusProNoEnd => 'Pro is active';

  @override
  String proStatusOffline(String date) {
    return 'Offline: last checked $date';
  }

  @override
  String proHistoryHidden(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count older results are saved',
      one: '1 older result is saved',
    );
    return '$_temp0 — the free plan shows the last $limit. Nothing has been deleted.';
  }

  @override
  String get proNothingGated =>
      'No feature is marked as paid yet: everything is open.';

  @override
  String get proPlanStudent => 'Student Pro';

  @override
  String get proPlanTeacher => 'Teacher Pro';

  @override
  String get proPlanSpecialist => 'Specialist Pro';

  @override
  String get proPlanPremium => 'Premium';

  @override
  String get proPayTierStudent => 'Student Pro';

  @override
  String get proPayTierStudentSub =>
      'For learning: teacher-assigned tests, results history, exam simulation, PDF/CSV export and extra materials.';

  @override
  String get proPayTierSpecialist => 'Specialist Pro';

  @override
  String get proPayTierSpecialistSub =>
      'For laboratory specialists: professional laboratory functions.';

  @override
  String get proPayTierPremium => 'Premium';

  @override
  String get proPayTierPremiumSub =>
      'Everything together: Student Pro, Teacher Pro and Specialist Pro features.';

  @override
  String get proPayStatusAdminGrant => 'Pro granted by an administrator';

  @override
  String proPayStatusAdminGrantUntil(String date) {
    return 'Pro granted by an administrator · until $date';
  }

  @override
  String get proGrantRow => 'Grant Pro';

  @override
  String get proGrantRowSub => 'Give Pro to an email address or revoke it';

  @override
  String get proGrantTitle => 'Grant Pro';

  @override
  String get proGrantIntro =>
      'Give Pro to an email address. If there is no account yet, it takes effect when the account is created or first signs in. A store subscription is not changed: the higher of the two applies.';

  @override
  String get proGrantEmail => 'Email';

  @override
  String get proGrantTier => 'Plan';

  @override
  String get proGrantDuration => 'Duration';

  @override
  String get proGrantNote => 'Note (optional)';

  @override
  String proGrantDays(int count) {
    return '$count days';
  }

  @override
  String get proGrantUntilRevoked => 'Until revoked';

  @override
  String get proGrantExtend => 'Extend the existing grant (do not replace)';

  @override
  String get proGrantSubmit => 'Grant Pro';

  @override
  String get proGrantConfirmTitle => 'Grant Pro?';

  @override
  String proGrantConfirmBody(String email, String plan, String duration) {
    return '$email will get the “$plan” plan. Duration: $duration.';
  }

  @override
  String proGrantDone(String email) {
    return 'Pro granted: $email';
  }

  @override
  String proGrantReplaced(String email) {
    return 'Existing grant replaced: $email';
  }

  @override
  String proGrantExtended(String email) {
    return 'Grant extended: $email';
  }

  @override
  String proGrantListTitle(int count) {
    return 'Active and pending ($count)';
  }

  @override
  String get proGrantEmpty => 'No grants yet.';

  @override
  String get proGrantPending =>
      'Waiting for an account: starts at first sign-in';

  @override
  String proGrantUntil(String date) {
    return 'until $date';
  }

  @override
  String get proGrantRevoke => 'Revoke';

  @override
  String get proGrantRevokeTitle => 'Revoke this grant?';

  @override
  String proGrantRevokeBody(String email) {
    return '$email loses Pro immediately. A store subscription (if any) stays.';
  }

  @override
  String proGrantRevoked(String email) {
    return 'Revoked: $email';
  }

  @override
  String get proGrantErrNote =>
      'The note must be at most 200 characters, without control characters.';

  @override
  String get proGrantErrPending =>
      'A pending grant cannot be extended: replace it instead.';

  @override
  String get proGrantErrDuration => 'Choose a duration to extend.';

  @override
  String get proGrantErrMany =>
      'The active grant limit is reached. Revoke unused ones first.';

  @override
  String get proGrantErrTierMix =>
      'These plans do not include each other, so the grant cannot be extended. Choose the plan you need and replace the grant.';

  @override
  String get proSubTitle => 'Subscription';

  @override
  String get proSubRowSub => 'Plans, your status and restore purchases';

  @override
  String get proSubAllFree =>
      'Right now every feature is free. Plans are not active yet — nothing is on sale.';

  @override
  String get proSubStatusTitle => 'Your status';

  @override
  String get proSubStatusFree => 'Free';

  @override
  String proSubStatusTrial(String plan, String days) {
    return '$plan · free trial: $days left';
  }

  @override
  String proSubStatusPlan(String plan) {
    return '$plan plan active';
  }

  @override
  String proSubStatusPlanUntil(String plan, String date) {
    return '$plan plan active · until $date';
  }

  @override
  String proSubStatusAdmin(String plan) {
    return '$plan — granted by an administrator';
  }

  @override
  String proSubStatusAdminUntil(String plan, String date) {
    return '$plan — granted by an administrator · until $date';
  }

  @override
  String get proSubPlansTitle => 'Plans';

  @override
  String get proSubPriceNote =>
      'Prices come from the store and are shown in your local currency. The exact price and period appear in the store sheet before you buy.';

  @override
  String proSubUnlocks(String list) {
    return 'Includes: $list';
  }

  @override
  String get proSubCapLearner => 'Student Pro';

  @override
  String get proSubCapTeacherPanel => 'Teacher Pro';

  @override
  String get proSubCapLab => 'Specialist Pro';

  @override
  String get proSubNothingGated =>
      'Right now this plan closes nothing: everything is free.';

  @override
  String get proSubTeacherNote =>
      'The teacher panel comes only with Teacher Pro or Premium, and professional laboratory functions only with Specialist Pro or Premium. Changing your role does not unlock them. Today’s free features stay free.';

  @override
  String proSubTrialTitle(int days) {
    return '$days-day free trial';
  }

  @override
  String get proSubTrialOncePerPhone =>
      'Given only once: one trial per phone, account and email. Not given again to another account, nor after deleting and re-creating your account. You need to be signed in with a verified email.';

  @override
  String get proSubTrialUsed => 'This account has already used its free trial.';

  @override
  String get proSubTrialNotActive => 'The free trial is not switched on yet.';

  @override
  String get proSubTrialGuest => 'Sign in to use the free trial.';

  @override
  String get proPrivacyTrialNote =>
      'Free trial: the 7-day free trial is given once per phone. To enforce this the server keeps the dates, plan, platform and only one-way keyed hashes of your email (in canonical form) and of a device identifier — the email itself, any device identifier and the attestation token are not stored. When you delete your account the record is unlinked from it but kept for 24 months so the trial is not given again, then deleted automatically. Details are in the Privacy Policy.';

  @override
  String proSubTrialBody(int days) {
    return 'You can try the paid features of the plan you choose, free, for $days days. Given once; no card or payment method is needed, nothing is charged, and it does not turn into a paid subscription by itself. When it ends, only the paid features close; free features and your data stay.';
  }

  @override
  String proSubTrialStart(String plan) {
    return 'Start free trial: $plan';
  }

  @override
  String get proSubTrialConfirmTitle => 'Start the free trial?';

  @override
  String proSubTrialConfirmBody(String plan, String date) {
    return '$plan: paid features are free until $date. Given once, no payment method, nothing is charged, and the trial does not turn into a paid subscription. After that date only the paid features close; free features and your data stay.';
  }

  @override
  String get proSubTrialConfirm => 'Start trial';

  @override
  String get proSubTrialCancel => 'Not now';

  @override
  String proSubTrialStarted(String date) {
    return 'Free trial started — paid features are open until $date.';
  }

  @override
  String get proSubTrialNotOnPlatform =>
      'The free trial is not available on this device yet. All free features work as usual.';

  @override
  String get proSubTrialHasAccess =>
      'You already have a paid plan, so a trial is not needed.';

  @override
  String get proSubTrialPlanNotAllowed =>
      'The Teacher Pro trial is for teachers registered on the server, the Specialist Pro trial for verified specialists, and the Premium trial for people who are both. Try Student Pro.';

  @override
  String get proSubTrialEmail =>
      'The trial needs the verified email of your account.';

  @override
  String get proSubTrialDevice =>
      'This device could not be verified, so the trial cannot start here.';

  @override
  String get proSubTrialSubscribed =>
      'You already have an active subscription.';

  @override
  String get proSubEnded =>
      'Your paid plan has ended: only the paid features are closed. Free features keep working and your data stays.';

  @override
  String get proSubPriceYearlyNote =>
      'The yearly plan is billed once a year at the price shown.';

  @override
  String get proSubWithoutSubscription =>
      'You can use the app without a subscription: free features stay free.';

  @override
  String get proGrantCustom => 'Other duration (number)';

  @override
  String get proGrantUnitDays => 'days';

  @override
  String get proGrantUnitMonths => 'months (30 days)';

  @override
  String proGrantErrRange(int max) {
    return 'Duration must be 1 to $max days (1 month = 30 days).';
  }

  @override
  String get proPayGuestBuyNote =>
      'You can buy and restore the Student and Specialist plans without an account. Teacher Pro and Premium include the teacher panel and need an account. If you sign in later, the purchase moves to your account.';

  @override
  String get proPayGuestAccountOnly =>
      'This plan includes the teacher panel — sign in to subscribe.';

  @override
  String get proPayGuestLinked =>
      'This purchase is linked to a LabGuide account. Sign in to that account to use it.';

  @override
  String proPayIntroPrice(String intro, String length, String price) {
    return '$intro for $length, then $price';
  }

  @override
  String get proPayStoreOfferNote =>
      'This is an App Store / Google Play offer, separate from the LabGuide free trial. The store decides who is eligible; the subscription renews automatically unless you cancel.';

  @override
  String proSubWillNotRenew(String date) {
    return 'Auto-renewal is off: access stays until $date, then the plan ends.';
  }

  @override
  String get proSubStoreTrial =>
      'Store trial period — unless you cancel, the subscription renews automatically at the store price.';

  @override
  String proSubWillChange(String plan) {
    return 'From the next renewal: $plan plan.';
  }

  @override
  String get proPayCancelPathApple =>
      'On iPhone and iPad: Settings → your name → Subscriptions → LabGuide → Cancel Subscription.';

  @override
  String get proPayCancelPathGoogle =>
      'On Android: Google Play → profile icon → Payments & subscriptions → Subscriptions → LabGuide → Cancel subscription.';

  @override
  String proPayStoreTrialNote(String store) {
    return 'If the store shows a free trial or introductory offer, its length, the later price and the renewal terms are those shown in the $store sheet: read them before you confirm. This is separate from the in-app free trial.';
  }

  @override
  String proPayRefundNote(String store) {
    return 'Refund requests are handled by $store under its own rules: send the request through your $store account. LabGuide does not see your bank card details.';
  }

  @override
  String proPayRefundedStatus(String store) {
    return 'The purchase was refunded or cancelled by $store: paid features are closed. Free features and your data stay.';
  }

  @override
  String proPayCancelledUntil(String date) {
    return 'The subscription is cancelled: paid features work until $date, then only the paid features close.';
  }

  @override
  String proPayGraceNote(String store) {
    return 'There is a problem with the payment. Paid features are kept for now: update your payment method in $store.';
  }

  @override
  String get proPayOfflineNote =>
      'No internet: the last checked status is shown. Paid features work for a limited time and refresh once you are online; the free part works as usual.';

  @override
  String get proPayOfflineAction =>
      'No internet. To buy or restore, check your connection and try again.';

  @override
  String get proPayAgreeNote =>
      'By subscribing or starting the trial you accept the Terms of Use and the Privacy Policy (links below).';

  @override
  String get proPayFeatAssignedTests => 'Teacher-assigned tests';

  @override
  String get proPayFeatExport => 'Download results as PDF and CSV';

  @override
  String get proPayFeatMaterials => 'Extra materials';

  @override
  String get proPayFeatCreateTests => 'Create tests and give them to students';

  @override
  String get proPayFeatAttachStudents => 'Attach students';

  @override
  String get proPayFeatManageResults => 'Manage results';

  @override
  String get proPayFeatProLab => 'Professional laboratory functions';

  @override
  String get proTermsBody =>
      'LabGuide is a clinical laboratory reference and learning app. The core features are free; paid plans (Student Pro, Teacher Pro, Specialist Pro, Premium) add extra features. By using the app you agree to these terms.\n\n1. Medical limitation. LabGuide does not diagnose, prescribe treatment or medicines, and does not replace your laboratory’s approved procedures, reagent and analyzer instructions (IFU) or a physician’s judgment. Every item shows its source; when making decisions, rely on the original source and your institution’s rules.\n\n2. Account. Some features (groups, tests, community, support requests, paid plans and the free trial) require signing up with email. You are responsible for your account’s security and for actions taken through it. You can delete your account at any time: Profile → Delete account; this does not cancel a store subscription.\n\n3. Teacher and student groups. When a student joins a group, the teacher sees their nickname (or seat number) and test results. Teachers use groups for educational purposes only.\n\n4. User content. You are responsible for what you post in the community and in support requests. Abuse, illegal content, advertising, other people’s personal data and non-consensual intimate images are strictly prohibited. Such content is removed, and the offending account may be restricted or deleted. You can report any message with “Report”.\n\n5. Paid plans and the free trial. Paid plans are sold through the Apple App Store or Google Play as auto-renewing subscriptions. The price and period are shown in the store sheet before you buy; you are charged only after you confirm the purchase in that sheet. You can cancel in your store settings at any time; refund requests are handled by the store. The 7-day free trial is given once and needs no card. When a trial or subscription ends, only the paid features close; free features and your data stay.\n\n6. Copyright. The app’s texts, slides, tests and design belong to the LabGuide authors; external sources are shown with their own licenses. They may not be copied or distributed for commercial purposes.\n\n7. Service. The app is provided “as is”; outages and errors may occur, and we fix them as quickly as we can. We will notify you in the app if these terms change.\n\n8. Privacy. How your data is used is described in the privacy policy: labguide.nfcstore.uz/privacy. The full terms: labguide.nfcstore.uz/terms\n\n9. Contact: labguide@nfcstore.uz';

  @override
  String get proPrivacyBody =>
      'The core sections work without an account (guest mode): settings, bookmarks, QC records, your instruments and practice results stay on this device. An account is optional (email code, Google or Apple) — it is needed for groups, the community, “Suggestions and help”, paid plans and the free trial. Then data is stored on a Cloudflare server (Eastern Europe, outside Uzbekistan): email only as a hash and a masked form, sign-in method, role, language, last activity time (to the minute); in a group — a nickname or seat number, test answers and scores; support and report texts. From Google/Apple only the account identifier and email are taken, and the token is not stored. A teacher sees only their own group. Subscription payments are taken by Apple or Google: LabGuide does not see your bank card details; our server verifies the store’s transaction identifiers. For the free trial only the dates and keyed hashes (of your email and a device marker) are kept. No ads, analytics or tracking. The full text is behind the “Privacy Policy” link.';

  @override
  String get proAccountDeleteBody =>
      'Your account, sign-in methods (Google/Apple link), group memberships and results, “Suggestions and help” requests, your community questions and answers, and records tied to purchases are deleted from the server for good. If you are a teacher, the groups you created are deleted too. This cannot be undone. A store subscription is not cancelled: cancel it in your App Store or Google Play settings. So that the trial is not given again, the trial record is kept for a limited time, unlinked from your account. The text of reports you sent from the app stays, not linked to your account. Data on the device is cleared too.';

  @override
  String get proTierNameStudent => 'Student Pro';

  @override
  String get proTierNameTeacher => 'Teacher Pro';

  @override
  String get proTierNameSpecialist => 'Specialist Pro';

  @override
  String get proTierNamePremium => 'Premium';

  @override
  String get proTierSubStudent =>
      'Extra Pro features for studying. Everything that is free today stays free.';

  @override
  String get proTierSubTeacher =>
      'For teachers: Student Pro features plus the Pro features of the teacher panel. Today’s free groups stay free.';

  @override
  String get proTierSubSpecialist =>
      'For lab staff and doctors: Student Pro features plus professional laboratory functions. The Laboratory section stays free.';

  @override
  String get proTierSubPremium =>
      'All Pro features together: Student Pro, Teacher Pro and Specialist Pro.';

  @override
  String get proCapLabPro =>
      'professional laboratory functions (calibration log and QC export, QC summary report)';

  @override
  String get proTierNote =>
      'Teacher panel Pro features are only in Teacher Pro or Premium, and professional laboratory functions only in Specialist Pro or Premium. Changing your role in the app does not unlock them. Everything that is free today — the Laboratory section, atlas, tests, category exam, groups and assignments — stays free.';

  @override
  String get proLockedLearner =>
      'This feature is in Student Pro, Teacher Pro, Specialist Pro and Premium.';

  @override
  String get proLockedTeacher => 'This feature is in Teacher Pro or Premium.';

  @override
  String get proLockedLab => 'This feature is in Specialist Pro or Premium.';

  @override
  String get proFeatResultsAnalytics =>
      'Results analysis: full history, topic trends and weak topics';

  @override
  String get proFeatExamSimulation =>
      'Exam simulation: a test under exam conditions with a detailed report';

  @override
  String get proFeatResultsExport => 'Export results as PDF and CSV files';

  @override
  String get proFeatTeacherTests => 'Special tests created by your teacher';

  @override
  String get proFeatTeacherTestBuilder => 'Create and edit your own tests';

  @override
  String get proFeatTeacherTestAssign =>
      'Assign your tests to students and groups';

  @override
  String get proFeatTeacherResults =>
      'Manage results: per-student and per-question summary, export';

  @override
  String get proFeatCalibrationExport =>
      'Export the calibration log to CSV and PDF';

  @override
  String get proFeatQcReport =>
      'QC summary report and QC data export as CSV/PDF files';

  @override
  String proTrialConfirmBody(String plan, String date) {
    return '$plan is free until $date. No payment method, nothing is charged, and it does not turn into a paid subscription. When it ends only the paid features close; free features and all your data stay.';
  }

  @override
  String get proGateClosedTitle => 'This is a Pro feature';

  @override
  String get proGateClosedBody =>
      'To open it you need a subscription or the 7-day free trial. Free features and your data stay.';

  @override
  String get proGateOpenPlans => 'See plans';

  @override
  String get proExportAction => 'Export: PDF or CSV';

  @override
  String get proExportTitle => 'Export to a file';

  @override
  String get proExportPdf => 'PDF document';

  @override
  String get proExportPdfSub => 'For viewing, printing and archiving';

  @override
  String get proExportCsv => 'CSV table';

  @override
  String get proExportCsvSub => 'For Excel or Google Sheets';

  @override
  String get proExportBusy => 'Preparing the file…';

  @override
  String get proExportShared => 'File ready — the share sheet is open.';

  @override
  String get proExportFailed => 'Could not share the file. Please try again.';

  @override
  String get proExportNotClinical =>
      'Built only from the data you entered. Not a clinical decision and not a replacement for your laboratory’s official records.';

  @override
  String proExportCreated(String date) {
    return 'Created: $date';
  }

  @override
  String proExportPage(int page, int total) {
    return '$page / $total';
  }

  @override
  String proCalExportCount(int count) {
    return 'Records: $count';
  }

  @override
  String get proCalExportEntry => 'Export the log';

  @override
  String get proCalExportEntrySub =>
      'PDF or CSV: instrument, reagent, lot, levels, outcome, approver and history';

  @override
  String get proColDate => 'Date';

  @override
  String get proColAction => 'Action';

  @override
  String get proColDetail => 'Details';

  @override
  String get proColStatus => 'Status';

  @override
  String get proQcReportTitle => 'QC summary report';

  @override
  String get proQcReportEntrySub =>
      'Per level and lot: x̄, SD, CV, bias from target and rules fired; PDF / CSV';

  @override
  String get proQcSummary => 'Overview';

  @override
  String get proQcPeriodLabel => 'Period';

  @override
  String get proQcVerdictsLabel => 'Accepted / warning / rejected';

  @override
  String get proQcVerdictsHint =>
      'Level card counts use the rules that involve that level; the overview counts whole runs.';

  @override
  String get proQcRulesFired => 'Rules fired';

  @override
  String get proQcNoRules => 'No rule violations';

  @override
  String get proQcByLevel => 'By level and lot';

  @override
  String get proQcColLevel => 'Level';

  @override
  String get proQcColTarget => 'Target (x̄ ± SD)';

  @override
  String get proQcColObserved => 'Observed (n, x̄ ± SD)';

  @override
  String get proQcColBias => 'Bias from target';

  @override
  String get proQcNoRuns =>
      'No runs entered yet — there is no data for a report.';

  @override
  String get proSimTitle => 'Exam simulation';

  @override
  String get proSimSubtitle =>
      'A test under exam conditions: time limit, pass mark and a detailed report';

  @override
  String get proSimEntrySub =>
      'Required time limit and pass mark, questions in order, time per question in the report';

  @override
  String get proSimConditions => 'Exam conditions';

  @override
  String get proSimRule1 =>
      'A time limit is required: when time runs out the test finishes by itself.';

  @override
  String get proSimRule2 =>
      'Questions are drawn from every topic in proportion to its size.';

  @override
  String get proSimRule3 =>
      'Questions come in order: no going back and no flags.';

  @override
  String get proSimRule4 =>
      'The result is graded against the pass mark; the report shows time per question and a topic breakdown.';

  @override
  String get proSimBank => 'Question bank';

  @override
  String get proSimBankPack => 'Topic questions';

  @override
  String proSimPool(int count, int topics) {
    return '$count questions in $topics topics';
  }

  @override
  String get proSimTimeHelper => '1–240 minutes, required';

  @override
  String get proSimPassHelper => '1–100 %, required';

  @override
  String get proSimStart => 'Start the simulation';

  @override
  String get proSimHistory => 'Previous simulations';

  @override
  String get proSimReportTitle => 'Simulation report';

  @override
  String get proSimPace => 'Time';

  @override
  String get proSimAvgPerQuestion => 'Average per question';

  @override
  String get proSimSlowest => 'Questions that took the longest';

  @override
  String get proSimReview => 'Review answers';

  @override
  String get proSimTag => 'simulation';

  @override
  String get proResultsTitle => 'Results analysis';

  @override
  String get proResultsSubtitle =>
      'Full history across all tests, trend and weak topics';

  @override
  String get proResultsEntrySub =>
      'Trend across all banks, topics and weak spots; PDF / CSV export';

  @override
  String get proResultsEmpty => 'No results yet — take your first test.';

  @override
  String get proResultsBankOther => 'Other tests';

  @override
  String get proResultsSessions => 'Tests';

  @override
  String get proResultsAverage => 'Average';

  @override
  String get proResultsBest => 'Best';

  @override
  String get proResultsLast => 'Latest';

  @override
  String get proResultsTrend => 'Change';

  @override
  String get proResultsAnswered => 'Correct answers';

  @override
  String get proResultsChart => 'Last 20 results';

  @override
  String get proResultsWeak => 'Weak topics';

  @override
  String get proResultsNoWeak => 'No weak topics found.';

  @override
  String get proResultsWeakRule =>
      'Weak topic: at least 5 questions and accuracy below 60 %. Change compares the newer half of the tests with that topic to the older half.';

  @override
  String get proResultsTopics => 'By topic';

  @override
  String get proResultsNoTopics => 'These tests have no topic tags.';

  @override
  String proResultsTopicRow(int correct, int total, int sessions) {
    return '$correct/$total correct · in $sessions tests';
  }

  @override
  String get proResultsHistory => 'Full history';

  @override
  String get proResultsQuestions => 'Questions';

  @override
  String get proResultsSession => 'Test';

  @override
  String proPoints(String value) {
    return '$value pp';
  }

  @override
  String get ttEntrySection => 'Teacher tests';

  @override
  String get ttEntryTeacher => 'My tests';

  @override
  String get proTtEntryTeacherSub =>
      'Teacher Pro: your own tests, assignments and results';

  @override
  String get ttEntryStudent => 'Tests from my teacher';

  @override
  String get ttEntryStudentSub => 'Special tests your teacher assigned to you';

  @override
  String get ttEntryInvite => 'Invitation code';

  @override
  String get ttEntryInviteSub =>
      'Join a group with the 12-character code from your teacher';

  @override
  String get ttTestsTitle => 'My tests';

  @override
  String get ttNewTest => 'New test';

  @override
  String get ttTestsEmpty => 'No tests yet';

  @override
  String get ttTestsEmptyBody =>
      'Build a test from your own questions or from copies of the questions in the app.';

  @override
  String get ttStatusPublished => 'Published';

  @override
  String get ttStatusUnpublished => 'Not published';

  @override
  String ttQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions',
      one: '1 question',
    );
    return '$_temp0';
  }

  @override
  String ttAssignedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assignments',
      one: '1 assignment',
    );
    return '$_temp0';
  }

  @override
  String get proTtLockedNote =>
      'Creating, editing and assigning tests is part of Teacher Pro. Tests and results you already created stay visible.';

  @override
  String get ttOfflineCached => 'No internet — showing the last saved copy.';

  @override
  String get ttEdit => 'Edit';

  @override
  String get ttAssign => 'Assign';

  @override
  String get ttDeleteTest => 'Delete test';

  @override
  String get ttDeleteTestBody =>
      'The test, its assignments and results will be deleted. This cannot be undone.';

  @override
  String get ttAssignmentsTitle => 'Assignments';

  @override
  String get ttNoAssignments => 'This test has not been assigned yet.';

  @override
  String ttDueOn(String date) {
    return 'due $date';
  }

  @override
  String ttSubmittedOf(int done, int total) {
    return '$done/$total submitted';
  }

  @override
  String get ttClosed => 'Closed';

  @override
  String ttTimeLimit(int minutes) {
    return 'Time: $minutes min';
  }

  @override
  String get ttNoTimeLimit => 'No time limit';

  @override
  String ttPassMark(int percent) {
    return 'Pass mark: $percent%';
  }

  @override
  String get ttMustPublish => 'Publish the test to assign it to students.';

  @override
  String get ttQuestionsTitle => 'Questions';

  @override
  String ttQuestionNumber(int n) {
    return 'Question $n';
  }

  @override
  String get ttCorrectAnswer => 'Correct answer';

  @override
  String ttFromBank(String bank) {
    return 'Copy from the app: $bank';
  }

  @override
  String get ttSourceQuiz => 'Practice questions';

  @override
  String get ttSourceToifa => 'Category exam bank';

  @override
  String get ttSourceDeck => 'Topic test';

  @override
  String get ttEditTitleNew => 'New test';

  @override
  String get ttEditTitle => 'Edit test';

  @override
  String get ttFieldTitle => 'Test title';

  @override
  String get ttFieldDescription => 'Description (optional)';

  @override
  String get ttFieldTimeLimit => 'Time limit, minutes (optional, 1–180)';

  @override
  String get ttFieldPassPercent => 'Pass mark, % (optional, 1–100)';

  @override
  String get ttPublishToggle => 'Published';

  @override
  String get ttPublishNote =>
      'Only a published test can be assigned. Assignments already given keep their own copy of the questions.';

  @override
  String get ttNoQuestionsYet =>
      'No questions yet. Add your own or copy questions from the app.';

  @override
  String get ttAddQuestion => 'Add question';

  @override
  String get ttAddFromBank => 'From the app questions';

  @override
  String get ttMoveUp => 'Move up';

  @override
  String get ttMoveDown => 'Move down';

  @override
  String get ttRemoveQuestion => 'Remove question';

  @override
  String get ttSave => 'Save';

  @override
  String get ttSaved => 'Saved';

  @override
  String get ttVersionConflict =>
      'This test was changed on another device. Open it again and repeat your edits.';

  @override
  String get ttErrTitle => 'The title must be 3–120 characters.';

  @override
  String get ttErrDescription =>
      'The description is too long (up to 1000 characters).';

  @override
  String get ttErrNoQuestions =>
      'A published test needs at least one question.';

  @override
  String get ttErrTimeLimit => 'Time limit: 1–180 minutes.';

  @override
  String get ttErrPassPercent => 'Pass mark: 1–100%.';

  @override
  String get ttErrQuestionText =>
      'Write the question text (up to 1000 characters).';

  @override
  String get ttErrOptions => 'Fill in 2–6 options (each up to 300 characters).';

  @override
  String get ttErrDuplicateOptions => 'Options must not repeat.';

  @override
  String get ttErrCorrect => 'Mark the correct option.';

  @override
  String get ttErrQuestionGeneric =>
      'Check the questions: text, 2–6 different options and one correct answer.';

  @override
  String ttErrQuestionAt(int n, String error) {
    return 'Question $n: $error';
  }

  @override
  String get ttErrAbusive =>
      'The text contains offensive words — please rephrase.';

  @override
  String get ttErrLimitTests =>
      'You have reached the limit of 200 tests. Delete old ones to create new tests.';

  @override
  String get ttErrPlan => 'This action needs a plan with this feature.';

  @override
  String get ttErrTeacherRole =>
      'Register as a teacher first: create a group in “Groups”.';

  @override
  String get ttFieldQuestion => 'Question text';

  @override
  String get ttOptionsHint => 'Tap the circle next to the correct option.';

  @override
  String ttFieldOption(int n) {
    return 'Option $n';
  }

  @override
  String get ttMarkCorrect => 'Mark as the correct answer';

  @override
  String get ttRemoveOption => 'Remove option';

  @override
  String get ttAddOption => 'Add option';

  @override
  String get ttFieldExplanation =>
      'Explanation (optional, shown with the result)';

  @override
  String get ttDone => 'Done';

  @override
  String get ttBankTitle => 'Questions from the app';

  @override
  String get ttBankSubtitle =>
      'Selected questions are added to your test as copies; the source is kept.';

  @override
  String get ttBankSearch => 'Search';

  @override
  String get ttBankAll => 'All';

  @override
  String ttBankAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count questions',
      one: 'Add 1 question',
      zero: 'Select questions',
    );
    return '$_temp0';
  }

  @override
  String get ttBankEmpty => 'No questions found';

  @override
  String ttBankRefine(int count) {
    return 'Showing the first 100 of $count. Narrow the search.';
  }

  @override
  String get ttAssignTitle => 'Assign the test';

  @override
  String get ttAssignGroup => 'Group';

  @override
  String get ttAssignWho => 'To whom';

  @override
  String get ttAssignWholeGroup => 'Whole group';

  @override
  String get ttAssignNoGroups =>
      'Create a group first — students join it with a code or an invitation.';

  @override
  String get ttAssignNoStudents =>
      'No students in this group yet. Students who join later will also see the test.';

  @override
  String get ttAssignDue => 'Deadline';

  @override
  String get ttAssignAttempts => 'Attempts';

  @override
  String get ttAssignLate => 'Accept after the deadline (marked as late)';

  @override
  String get ttAssignPrivacy =>
      'You will see results only of students who joined the group themselves. Students see a notice that their result is visible to you.';

  @override
  String get ttAssignSubmit => 'Assign';

  @override
  String get ttAssigned => 'The test has been assigned';

  @override
  String get ttErrDue => 'Choose a deadline in the future (up to one year).';

  @override
  String get ttErrMemberGone => 'This student is no longer in the group.';

  @override
  String get ttErrLimitAssignments =>
      'Too many active assignments. Close old ones first.';

  @override
  String get ttInvitesTitle => 'Invitations';

  @override
  String get ttInvitesSubtitle =>
      'The student enters the code, reads what you will see and agrees.';

  @override
  String get ttInviteDays => 'Valid for';

  @override
  String get ttInviteMaxUses => 'How many students can join';

  @override
  String get ttInviteCreate => 'Create invitation';

  @override
  String get ttInviteHowTo =>
      'Send the code to students. In the app: Groups → Invitation code. Joining happens only after the student agrees.';

  @override
  String get ttInvitesActive => 'Active invitations';

  @override
  String get ttInvitesEmpty => 'No active invitations';

  @override
  String ttInviteUses(int uses, int max) {
    return 'used $uses/$max';
  }

  @override
  String ttInviteUntil(String date) {
    return 'until $date';
  }

  @override
  String get ttInviteCopy => 'Copy invitation';

  @override
  String get ttInviteCopied => 'Invitation copied';

  @override
  String ttInviteShareText(String group, String code, String link) {
    return 'LabGuide: invitation to the group “$group”. In the app open Groups → Invitation code and enter $code ($link)';
  }

  @override
  String get ttInviteRevoke => 'Revoke';

  @override
  String get ttInviteRevokeBody =>
      'The code will stop working right away. Students who already joined stay in the group.';

  @override
  String get ttErrLimitInvites =>
      'Too many active invitations for this group. Revoke unused ones.';

  @override
  String get ttInviteAcceptTitle => 'Invitation to a group';

  @override
  String get ttInviteCodeField => 'Invitation code (12 characters)';

  @override
  String get ttInviteCheck => 'Check';

  @override
  String get ttInviteGroupTitle => 'Group';

  @override
  String get ttInviteConsentTitle => 'What the teacher will see';

  @override
  String get ttInviteConsentBody =>
      'If you join, the teacher sees your alias (or seat number) in the member list and your results in teacher tests: answers, score and time. Your email is not shown. You can leave the group at any time — your teacher-test results are then deleted.';

  @override
  String get ttInviteConsentCheck => 'I agree';

  @override
  String get ttInviteNickname => 'Alias (optional)';

  @override
  String get ttInviteAccept => 'Join';

  @override
  String get ttInviteDecline => 'Decline';

  @override
  String get ttInviteJoined => 'You joined the group';

  @override
  String get ttInviteAlready => 'You are already in this group';

  @override
  String get ttInviteOpenGroup => 'Open the group';

  @override
  String get ttInviteOwn => 'This is your own group';

  @override
  String get ttInviteExpired =>
      'The invitation has expired or was revoked. Ask your teacher for a new code.';

  @override
  String get ttInviteNotFound => 'Code not found — check it and try again.';

  @override
  String get ttResultsTitle => 'Results';

  @override
  String get ttSummaryTitle => 'Summary';

  @override
  String get ttSumTargets => 'Students';

  @override
  String get ttSumSubmitted => 'Submitted';

  @override
  String get ttSumAverage => 'Average';

  @override
  String get ttSumPassRate => 'Passed';

  @override
  String get ttSumAvgTime => 'Average time';

  @override
  String get ttPrivacyTeacher =>
      'Only results of students who joined the group themselves are shown. When a student leaves the group, their results are deleted.';

  @override
  String get ttStudentsTitle => 'By student';

  @override
  String get ttNoStudentsYet => 'No students in the group yet.';

  @override
  String get ttMostMissed => 'Most missed questions';

  @override
  String get ttNoResultsYet => 'Nobody has submitted yet.';

  @override
  String get ttQuestionsStatTitle => 'By question';

  @override
  String get ttNoAnswersYet => 'no answers yet';

  @override
  String ttCorrectPercent(int percent) {
    return '$percent% correct';
  }

  @override
  String get ttStateAssigned => 'Not started';

  @override
  String get ttStateStarted => 'In progress';

  @override
  String get ttStateSubmitted => 'Submitted';

  @override
  String get ttStateExpired => 'Missed';

  @override
  String get ttPassed => 'passed';

  @override
  String get ttNotPassed => 'not passed';

  @override
  String get ttLate => 'late';

  @override
  String get ttLateAccepted => 'Late work accepted';

  @override
  String ttAttemptsN(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
    );
    return '$_temp0';
  }

  @override
  String ttMinSec(int m, int s) {
    return '$m min $s s';
  }

  @override
  String get ttExportCsv => 'Copy as CSV';

  @override
  String get ttExportCopied => 'CSV copied — paste it into a spreadsheet';

  @override
  String get ttCloseAssignment => 'Close assignment';

  @override
  String get ttCloseAssignmentBody =>
      'No new attempts can start; students who are already solving have 2 minutes to submit.';

  @override
  String get ttDeleteAssignment => 'Delete assignment';

  @override
  String get ttDeleteAssignmentBody =>
      'The assignment and its results will be deleted.';

  @override
  String get ttMyTitle => 'Teacher tests';

  @override
  String get ttMySubtitle => 'Special tests from your teacher';

  @override
  String get ttMyEmpty => 'No tests yet';

  @override
  String get ttMyEmptyBody =>
      'When your teacher assigns a test, it appears here.';

  @override
  String ttBest(int percent) {
    return 'best $percent%';
  }

  @override
  String get ttVisibleNoticeTitle => 'Your result is visible to your teacher';

  @override
  String get ttVisibleNotice =>
      'Your teacher will see your alias (or seat number), answers, score and time for this test. Your email is not shown.';

  @override
  String get proTtStudentLocked =>
      'Starting a teacher test is part of Student Pro. Your results stay visible.';

  @override
  String get ttLatePolicyAccept =>
      'Accepted after the deadline too (marked as late).';

  @override
  String get ttLatePolicyReject => 'Cannot be started after the deadline.';

  @override
  String get ttCantClosed => 'The teacher has closed this assignment.';

  @override
  String get ttCantPastDue => 'The deadline has passed.';

  @override
  String get ttCantNoAttempts => 'No attempts left.';

  @override
  String get ttStart => 'Start the test';

  @override
  String get ttContinue => 'Continue';

  @override
  String get ttYourAttempts => 'Your attempts';

  @override
  String ttAttemptN(int n) {
    return 'Attempt $n';
  }

  @override
  String get ttReviewHidden =>
      'Correct answers are shown when your attempts are used up, after the deadline or when the teacher closes the assignment.';

  @override
  String get ttYourAnswer => 'Your answer';

  @override
  String get ttNoAnswer => 'no answer';

  @override
  String ttSubmittedSnack(int score, int total) {
    return 'Submitted: $score/$total';
  }

  @override
  String get ttErrTimeOver => 'Time is over — this attempt was not accepted.';

  @override
  String get ttErrAlreadySubmitted =>
      'This attempt has already been submitted.';

  @override
  String ttTimeLeft(String time) {
    return 'Time left: $time';
  }

  @override
  String get ttSubmit => 'Submit';

  @override
  String get ttSubmitConfirmTitle => 'Submit your answers?';

  @override
  String ttSubmitUnanswered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions are unanswered.',
      one: '1 question is unanswered.',
    );
    return '$_temp0';
  }

  @override
  String get ttSubmitFinal => 'After submitting you cannot change the answers.';

  @override
  String get ttSubmitVisible => 'The result will be visible to your teacher.';

  @override
  String get ttSubmitFailedSaved =>
      'Could not submit. Your answers are saved on this device — try again.';
}
