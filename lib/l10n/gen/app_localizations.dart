import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'BIOCHEMISTRY · LABORATORY'**
  String get appTagline;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get navTests;

  /// No description provided for @navLab.
  ///
  /// In en, this message translates to:
  /// **'Lab'**
  String get navLab;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile and settings'**
  String get actionProfile;

  /// No description provided for @actionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get actionLanguage;

  /// No description provided for @actionOpen.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get actionOpen;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionRetry;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get actionCopyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @plannedStage.
  ///
  /// In en, this message translates to:
  /// **'Planned for stage {stage}'**
  String plannedStage(String stage);

  /// No description provided for @notAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'Not available yet'**
  String get notAvailableYet;

  /// No description provided for @debugBuildBadge.
  ///
  /// In en, this message translates to:
  /// **'DEBUG · DEMO ADAPTERS'**
  String get debugBuildBadge;

  /// No description provided for @welcomeEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your laboratory companion'**
  String get welcomeEyebrow;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Biochemistry.\nClear and practical.'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tests, laboratory practice and learning in one place.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeDevices.
  ///
  /// In en, this message translates to:
  /// **'Phone and tablet'**
  String get welcomeDevices;

  /// No description provided for @welcomeRoles.
  ///
  /// In en, this message translates to:
  /// **'Physician · lab professional · student · teacher'**
  String get welcomeRoles;

  /// No description provided for @welcomeGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started / sign up'**
  String get welcomeGetStarted;

  /// No description provided for @welcomeGuest.
  ///
  /// In en, this message translates to:
  /// **'Explore as guest'**
  String get welcomeGuest;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get welcomeSignIn;

  /// No description provided for @welcomeGuestNote.
  ///
  /// In en, this message translates to:
  /// **'No account is needed to read content. Sign-in is used for sync and classes.'**
  String get welcomeGuestNote;

  /// No description provided for @welcomeBenefitDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'For doctors'**
  String get welcomeBenefitDoctorTitle;

  /// No description provided for @welcomeBenefitDoctorBody.
  ///
  /// In en, this message translates to:
  /// **'Results, interfering factors and tests by condition'**
  String get welcomeBenefitDoctorBody;

  /// No description provided for @welcomeBenefitLabTitle.
  ///
  /// In en, this message translates to:
  /// **'For lab specialists'**
  String get welcomeBenefitLabTitle;

  /// No description provided for @welcomeBenefitLabBody.
  ///
  /// In en, this message translates to:
  /// **'Quality control, sampling, instruments and calculators'**
  String get welcomeBenefitLabBody;

  /// No description provided for @welcomeBenefitLearnTitle.
  ///
  /// In en, this message translates to:
  /// **'For students and teachers'**
  String get welcomeBenefitLearnTitle;

  /// No description provided for @welcomeBenefitLearnBody.
  ///
  /// In en, this message translates to:
  /// **'Topics, explained questions, exams and groups'**
  String get welcomeBenefitLearnBody;

  /// No description provided for @stateLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get stateLoading;

  /// No description provided for @homeTileTests.
  ///
  /// In en, this message translates to:
  /// **'Ranges, causes, meaning'**
  String get homeTileTests;

  /// No description provided for @homeTileCalculators.
  ///
  /// In en, this message translates to:
  /// **'eGFR, ACR, dilution and more'**
  String get homeTileCalculators;

  /// No description provided for @homeTileSampling.
  ///
  /// In en, this message translates to:
  /// **'Tubes, storage, transport'**
  String get homeTileSampling;

  /// No description provided for @homeTileSaved.
  ///
  /// In en, this message translates to:
  /// **'Quick access to bookmarks'**
  String get homeTileSaved;

  /// No description provided for @homeTileDiff.
  ///
  /// In en, this message translates to:
  /// **'Counter and cell atlas'**
  String get homeTileDiff;

  /// No description provided for @homeTileCalibration.
  ///
  /// In en, this message translates to:
  /// **'Analyzer, reagent and IFU match'**
  String get homeTileCalibration;

  /// No description provided for @homeTileInstruments.
  ///
  /// In en, this message translates to:
  /// **'Principles and methods'**
  String get homeTileInstruments;

  /// No description provided for @homeTileExam.
  ///
  /// In en, this message translates to:
  /// **'Timed practice exam'**
  String get homeTileExam;

  /// No description provided for @homeTileTopics.
  ///
  /// In en, this message translates to:
  /// **'Topic, explanation, practice'**
  String get homeTileTopics;

  /// No description provided for @homeTileClasses.
  ///
  /// In en, this message translates to:
  /// **'Students and assignments'**
  String get homeTileClasses;

  /// No description provided for @homeTileLecture.
  ///
  /// In en, this message translates to:
  /// **'Slides and screen casting'**
  String get homeTileLecture;

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in or create an account with email.'**
  String get authSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get authEmailHint;

  /// No description provided for @authEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEmailInvalid;

  /// No description provided for @authConsent.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms of use and privacy policy.'**
  String get authConsent;

  /// No description provided for @authConsentRequired.
  ///
  /// In en, this message translates to:
  /// **'Accept the terms to continue.'**
  String get authConsentRequired;

  /// No description provided for @authGetCode.
  ///
  /// In en, this message translates to:
  /// **'Get code'**
  String get authGetCode;

  /// No description provided for @authViewTerms.
  ///
  /// In en, this message translates to:
  /// **'View terms'**
  String get authViewTerms;

  /// No description provided for @authDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'Debug build: demo sign-in. No email is sent; the code is shown on the next screen.'**
  String get authDemoNotice;

  /// No description provided for @authUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Email sign-in isn’t connected yet'**
  String get authUnavailableTitle;

  /// No description provided for @authUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'All reading content is available to guests. Sign-in will be enabled once the email service is configured.'**
  String get authUnavailableBody;

  /// No description provided for @authContinueGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get authContinueGuest;

  /// No description provided for @authRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again in {seconds} s.'**
  String authRateLimited(int seconds);

  /// No description provided for @authGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Check the connection and try again.'**
  String get authGenericError;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get otpTitle;

  /// No description provided for @otpCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get otpCodeLabel;

  /// No description provided for @otpVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// No description provided for @otpDemoCode.
  ///
  /// In en, this message translates to:
  /// **'Demo code: {code}. No email was sent (debug build only).'**
  String otpDemoCode(String code);

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code. Attempts left: {attempts}.'**
  String otpInvalid(int attempts);

  /// No description provided for @otpExpired.
  ///
  /// In en, this message translates to:
  /// **'The code has expired. Request a new one.'**
  String get otpExpired;

  /// No description provided for @otpTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Request a new code.'**
  String get otpTooManyAttempts;

  /// No description provided for @otpNoActiveCode.
  ///
  /// In en, this message translates to:
  /// **'No active code. Request a new one.'**
  String get otpNoActiveCode;

  /// No description provided for @otpFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code.'**
  String get otpFormat;

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get otpResend;

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpValidFor.
  ///
  /// In en, this message translates to:
  /// **'The code is valid for {minutes} min.'**
  String otpValidFor(int minutes);

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'A new code was issued.'**
  String get otpResent;

  /// No description provided for @rolesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your workspace'**
  String get rolesTitle;

  /// No description provided for @rolesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your main role. You can change it later.'**
  String get rolesSubtitle;

  /// No description provided for @rolesNote.
  ///
  /// In en, this message translates to:
  /// **'The role only adapts the home screen. It doesn’t grant access to other people’s classes or data.'**
  String get rolesNote;

  /// No description provided for @roleDoctor.
  ///
  /// In en, this message translates to:
  /// **'Physician'**
  String get roleDoctor;

  /// No description provided for @roleDoctorDesc.
  ///
  /// In en, this message translates to:
  /// **'Results and clinical context'**
  String get roleDoctorDesc;

  /// No description provided for @roleLab.
  ///
  /// In en, this message translates to:
  /// **'Laboratory professional'**
  String get roleLab;

  /// No description provided for @roleLabDesc.
  ///
  /// In en, this message translates to:
  /// **'Methods, instruments and QC'**
  String get roleLabDesc;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @roleStudentDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn, practice and prepare'**
  String get roleStudentDesc;

  /// No description provided for @roleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher / researcher'**
  String get roleTeacher;

  /// No description provided for @roleTeacherDesc.
  ///
  /// In en, this message translates to:
  /// **'Classes, assignments and research'**
  String get roleTeacherDesc;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge. Precision. Practice.'**
  String get homeTitle;

  /// No description provided for @homeFocusTag.
  ///
  /// In en, this message translates to:
  /// **'Your focus'**
  String get homeFocusTag;

  /// No description provided for @homeHeroDoctorTitle.
  ///
  /// In en, this message translates to:
  /// **'Understand the result in context'**
  String get homeHeroDoctorTitle;

  /// No description provided for @homeHeroDoctorBody.
  ///
  /// In en, this message translates to:
  /// **'Tests, influencing factors and related investigations.'**
  String get homeHeroDoctorBody;

  /// No description provided for @homeHeroDoctorCta.
  ///
  /// In en, this message translates to:
  /// **'Search tests'**
  String get homeHeroDoctorCta;

  /// No description provided for @condGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Tests by condition'**
  String get condGuideTitle;

  /// No description provided for @condGuideEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Clinician’s guide'**
  String get condGuideEyebrow;

  /// No description provided for @condGuideBody.
  ///
  /// In en, this message translates to:
  /// **'For each condition: which tests come first, which follow — and what a result may point to.'**
  String get condGuideBody;

  /// No description provided for @condGuideSearch.
  ///
  /// In en, this message translates to:
  /// **'Search a condition or test…'**
  String get condGuideSearch;

  /// No description provided for @condGuideAll.
  ///
  /// In en, this message translates to:
  /// **'All conditions'**
  String get condGuideAll;

  /// No description provided for @condCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} condition} other{{count} conditions}}'**
  String condCount(int count);

  /// No description provided for @condSystemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} body system} other{{count} body systems}}'**
  String condSystemCount(int count);

  /// No description provided for @condListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Which tests for which condition — and what results may point to'**
  String get condListSubtitle;

  /// No description provided for @condSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search conditions'**
  String get condSearchLabel;

  /// No description provided for @condSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Diabetes, anemia, thyroid, TSH…'**
  String get condSearchHint;

  /// No description provided for @condEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conditions found'**
  String get condEmptyTitle;

  /// No description provided for @condEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another name, a common name or a test name (for example, “high cholesterol”).'**
  String get condEmptyBody;

  /// No description provided for @condTierFirstLine.
  ///
  /// In en, this message translates to:
  /// **'First-line'**
  String get condTierFirstLine;

  /// No description provided for @condTierAdditional.
  ///
  /// In en, this message translates to:
  /// **'Additional'**
  String get condTierAdditional;

  /// No description provided for @condTierMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get condTierMonitoring;

  /// No description provided for @condTierFirstLineHint.
  ///
  /// In en, this message translates to:
  /// **'Ordered first when the condition is suspected'**
  String get condTierFirstLineHint;

  /// No description provided for @condTierAdditionalHint.
  ///
  /// In en, this message translates to:
  /// **'To clarify, find the cause or tell conditions apart'**
  String get condTierAdditionalHint;

  /// No description provided for @condTierMonitoringHint.
  ///
  /// In en, this message translates to:
  /// **'After diagnosis or during treatment'**
  String get condTierMonitoringHint;

  /// No description provided for @condPatternsTitle.
  ///
  /// In en, this message translates to:
  /// **'Result patterns'**
  String get condPatternsTitle;

  /// No description provided for @condPatternsHint.
  ///
  /// In en, this message translates to:
  /// **'“If you see this — this may be likely.” Interpretations are probabilistic: the clinician draws the final conclusion with the clinical picture.'**
  String get condPatternsHint;

  /// No description provided for @condNotDiagnosticTitle.
  ///
  /// In en, this message translates to:
  /// **'Not a diagnostic tool'**
  String get condNotDiagnosticTitle;

  /// No description provided for @condNotDiagnosticBody.
  ///
  /// In en, this message translates to:
  /// **'The guide helps plan testing. Clinical assessment and the final decision rest with the clinician. The text is based on the sources listed on each card.'**
  String get condNotDiagnosticBody;

  /// No description provided for @condCautionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep in mind'**
  String get condCautionsTitle;

  /// No description provided for @condNoCard.
  ///
  /// In en, this message translates to:
  /// **'No card yet'**
  String get condNoCard;

  /// No description provided for @condCopyList.
  ///
  /// In en, this message translates to:
  /// **'Copy test list'**
  String get condCopyList;

  /// No description provided for @condCopyListSub.
  ///
  /// In en, this message translates to:
  /// **'Ready text for a referral or message'**
  String get condCopyListSub;

  /// No description provided for @condCopied.
  ///
  /// In en, this message translates to:
  /// **'List copied'**
  String get condCopied;

  /// No description provided for @condReferralTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} — tests'**
  String condReferralTitle(String name);

  /// No description provided for @condReferralFooter.
  ///
  /// In en, this message translates to:
  /// **'LabGuide guide. Not a diagnostic tool — the final decision rests with the clinician.'**
  String get condReferralFooter;

  /// No description provided for @condAnalyteSection.
  ///
  /// In en, this message translates to:
  /// **'Conditions where it is ordered'**
  String get condAnalyteSection;

  /// No description provided for @condTestsEntrySub.
  ///
  /// In en, this message translates to:
  /// **'Pick a condition — the tests and result patterns'**
  String get condTestsEntrySub;

  /// No description provided for @condSearchSection.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get condSearchSection;

  /// No description provided for @condRowFirstLine.
  ///
  /// In en, this message translates to:
  /// **'First: {tests}'**
  String condRowFirstLine(String tests);

  /// No description provided for @condSysEndocrine.
  ///
  /// In en, this message translates to:
  /// **'Endocrine system'**
  String get condSysEndocrine;

  /// No description provided for @condSysKidney.
  ///
  /// In en, this message translates to:
  /// **'Kidney and urinary tract'**
  String get condSysKidney;

  /// No description provided for @condSysLiver.
  ///
  /// In en, this message translates to:
  /// **'Liver and bile ducts'**
  String get condSysLiver;

  /// No description provided for @condSysDigestive.
  ///
  /// In en, this message translates to:
  /// **'Pancreas and bowel'**
  String get condSysDigestive;

  /// No description provided for @condSysCardio.
  ///
  /// In en, this message translates to:
  /// **'Heart and blood vessels'**
  String get condSysCardio;

  /// No description provided for @condSysBlood.
  ///
  /// In en, this message translates to:
  /// **'Blood and clotting'**
  String get condSysBlood;

  /// No description provided for @condSysInfection.
  ///
  /// In en, this message translates to:
  /// **'Infections'**
  String get condSysInfection;

  /// No description provided for @condSysRheumatology.
  ///
  /// In en, this message translates to:
  /// **'Rheumatology'**
  String get condSysRheumatology;

  /// No description provided for @condSysBone.
  ///
  /// In en, this message translates to:
  /// **'Bone and calcium'**
  String get condSysBone;

  /// No description provided for @condSysPregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy and reproductive health'**
  String get condSysPregnancy;

  /// No description provided for @condSysProstate.
  ///
  /// In en, this message translates to:
  /// **'Prostate'**
  String get condSysProstate;

  /// No description provided for @homeHeroLabTitle.
  ///
  /// In en, this message translates to:
  /// **'Confidence at the bench'**
  String get homeHeroLabTitle;

  /// No description provided for @homeHeroLabBody.
  ///
  /// In en, this message translates to:
  /// **'Samples, methods and quality control in one place.'**
  String get homeHeroLabBody;

  /// No description provided for @homeHeroLabCta.
  ///
  /// In en, this message translates to:
  /// **'Open quality control'**
  String get homeHeroLabCta;

  /// No description provided for @homeHeroStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn biochemistry with understanding'**
  String get homeHeroStudentTitle;

  /// No description provided for @homeHeroStudentBody.
  ///
  /// In en, this message translates to:
  /// **'Topic → explanation → practice → review.'**
  String get homeHeroStudentBody;

  /// No description provided for @homeHeroStudentCta.
  ///
  /// In en, this message translates to:
  /// **'Start daily questions'**
  String get homeHeroStudentCta;

  /// No description provided for @homeHeroTeacherTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn knowledge into teaching'**
  String get homeHeroTeacherTitle;

  /// No description provided for @homeHeroTeacherBody.
  ///
  /// In en, this message translates to:
  /// **'Classes, explained questions and assignments with deadlines.'**
  String get homeHeroTeacherBody;

  /// No description provided for @homeHeroTeacherCta.
  ///
  /// In en, this message translates to:
  /// **'Open classes'**
  String get homeHeroTeacherCta;

  /// No description provided for @homeQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick access'**
  String get homeQuickAccess;

  /// No description provided for @homeUsefulTests.
  ///
  /// In en, this message translates to:
  /// **'Useful tests'**
  String get homeUsefulTests;

  /// No description provided for @featureTests.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get featureTests;

  /// No description provided for @featureCalculators.
  ///
  /// In en, this message translates to:
  /// **'Calculators'**
  String get featureCalculators;

  /// No description provided for @featureSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get featureSaved;

  /// No description provided for @featureCalibration.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get featureCalibration;

  /// No description provided for @featureQc.
  ///
  /// In en, this message translates to:
  /// **'Quality control (QC)'**
  String get featureQc;

  /// No description provided for @featureTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get featureTopics;

  /// No description provided for @featureMicroscopy.
  ///
  /// In en, this message translates to:
  /// **'Microscopy'**
  String get featureMicroscopy;

  /// No description provided for @featureExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get featureExam;

  /// No description provided for @featureClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get featureClasses;

  /// No description provided for @featureQuestionBank.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get featureQuestionBank;

  /// No description provided for @featureSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get featureSources;

  /// No description provided for @featureResearch.
  ///
  /// In en, this message translates to:
  /// **'Research'**
  String get featureResearch;

  /// No description provided for @testsTitle.
  ///
  /// In en, this message translates to:
  /// **'Test atlas'**
  String get testsTitle;

  /// No description provided for @testsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From a marker to practical knowledge.'**
  String get testsSubtitle;

  /// No description provided for @testsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search tests'**
  String get testsSearchLabel;

  /// No description provided for @testsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'ALT, creatinine, HbA1c…'**
  String get testsSearchHint;

  /// No description provided for @testsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get testsFilterAll;

  /// No description provided for @testsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get testsEmptyTitle;

  /// No description provided for @testsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another name, abbreviation or synonym.'**
  String get testsEmptyBody;

  /// No description provided for @testsClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get testsClearSearch;

  /// No description provided for @testsResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} test} other{{count} tests}}'**
  String testsResultCount(int count);

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @statusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get statusPublished;

  /// No description provided for @statusSourcedSample.
  ///
  /// In en, this message translates to:
  /// **'Source-based'**
  String get statusSourcedSample;

  /// No description provided for @statusStructureOnly.
  ///
  /// In en, this message translates to:
  /// **'Structure only'**
  String get statusStructureOnly;

  /// No description provided for @contentLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading content…'**
  String get contentLoading;

  /// No description provided for @contentErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Content couldn’t be loaded'**
  String get contentErrorTitle;

  /// No description provided for @contentErrorBody.
  ///
  /// In en, this message translates to:
  /// **'The content pack failed verification. Unverified data is never shown.'**
  String get contentErrorBody;

  /// No description provided for @analyteSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get analyteSave;

  /// No description provided for @analyteSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get analyteSaved;

  /// No description provided for @analyteSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Added to saved'**
  String get analyteSavedToast;

  /// No description provided for @analyteRemovedToast.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved'**
  String get analyteRemovedToast;

  /// No description provided for @analyteNotFound.
  ///
  /// In en, this message translates to:
  /// **'This test card wasn’t found.'**
  String get analyteNotFound;

  /// No description provided for @analyteStructureOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Content in preparation'**
  String get analyteStructureOnlyTitle;

  /// No description provided for @analyteStructureOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'This card shows the structure only for now. Clinical text is added together with its sources — generic text is never shown as ready.'**
  String get analyteStructureOnlyBody;

  /// No description provided for @analyteNotWritten.
  ///
  /// In en, this message translates to:
  /// **'Not written yet: the text is added together with its sources.'**
  String get analyteNotWritten;

  /// No description provided for @analyteAtAGlance.
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get analyteAtAGlance;

  /// No description provided for @analyteSpecimen.
  ///
  /// In en, this message translates to:
  /// **'Specimen'**
  String get analyteSpecimen;

  /// No description provided for @analytePopulation.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get analytePopulation;

  /// No description provided for @analyteMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get analyteMethod;

  /// No description provided for @analyteMethodNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not specified — depends on the reagent IFU'**
  String get analyteMethodNotSet;

  /// No description provided for @analyteUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get analyteUnits;

  /// No description provided for @analyteRefIntervals.
  ///
  /// In en, this message translates to:
  /// **'Reference intervals'**
  String get analyteRefIntervals;

  /// No description provided for @analyteRefIntervalNone.
  ///
  /// In en, this message translates to:
  /// **'No reference interval is given here. Use the interval on your laboratory’s report: it depends on the method, specimen and population.'**
  String get analyteRefIntervalNone;

  /// No description provided for @analyteDecisionLimits.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic thresholds'**
  String get analyteDecisionLimits;

  /// No description provided for @analyteDecisionNotRef.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic thresholds are not laboratory reference intervals.'**
  String get analyteDecisionNotRef;

  /// No description provided for @analyteSiNote.
  ///
  /// In en, this message translates to:
  /// **'{unit} values are not given by the source — they are converted from the source’s mg/dL thresholds using the molar mass ({mass} g/mol) and rounded. The source’s mg/dL value is the threshold.'**
  String analyteSiNote(String unit, String mass);

  /// No description provided for @analyteSiApprox.
  ///
  /// In en, this message translates to:
  /// **'{value} (converted)'**
  String analyteSiApprox(String value);

  /// No description provided for @analyteNoInterpretation.
  ///
  /// In en, this message translates to:
  /// **'LabGuide doesn’t interpret individual results or suggest diagnoses or doses.'**
  String get analyteNoInterpretation;

  /// No description provided for @analyteSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get analyteSources;

  /// No description provided for @analyteSourceAccessed.
  ///
  /// In en, this message translates to:
  /// **'Accessed {date}'**
  String analyteSourceAccessed(String date);

  /// No description provided for @analyteReuseRightsVerify.
  ///
  /// In en, this message translates to:
  /// **'Reuse rights: verify before distribution'**
  String get analyteReuseRightsVerify;

  /// No description provided for @analyteReview.
  ///
  /// In en, this message translates to:
  /// **'Preparation and sources'**
  String get analyteReview;

  /// No description provided for @analyteReviewPending.
  ///
  /// In en, this message translates to:
  /// **'Expert review pending'**
  String get analyteReviewPending;

  /// No description provided for @analyteReviewApproved.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get analyteReviewApproved;

  /// No description provided for @analyteContentVersion.
  ///
  /// In en, this message translates to:
  /// **'Content version {version}'**
  String analyteContentVersion(String version);

  /// No description provided for @analyteConvertUnits.
  ///
  /// In en, this message translates to:
  /// **'Convert units'**
  String get analyteConvertUnits;

  /// No description provided for @analyteConvertUnitsSub.
  ///
  /// In en, this message translates to:
  /// **'Analyte-specific factor'**
  String get analyteConvertUnitsSub;

  /// No description provided for @analyteMethodCalibration.
  ///
  /// In en, this message translates to:
  /// **'Method and calibration'**
  String get analyteMethodCalibration;

  /// No description provided for @analyteMethodCalibrationSub.
  ///
  /// In en, this message translates to:
  /// **'IFU · QC'**
  String get analyteMethodCalibrationSub;

  /// No description provided for @analyteCalculatorSub.
  ///
  /// In en, this message translates to:
  /// **'Calculator · published formula'**
  String get analyteCalculatorSub;

  /// No description provided for @analytePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice the topic'**
  String get analytePractice;

  /// No description provided for @analytePracticeSub.
  ///
  /// In en, this message translates to:
  /// **'Explained questions'**
  String get analytePracticeSub;

  /// No description provided for @analyteRelated.
  ///
  /// In en, this message translates to:
  /// **'Related tests'**
  String get analyteRelated;

  /// No description provided for @sectionPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get sectionPurpose;

  /// No description provided for @sectionPhysiology.
  ///
  /// In en, this message translates to:
  /// **'Physiology'**
  String get sectionPhysiology;

  /// No description provided for @sectionHighResult.
  ///
  /// In en, this message translates to:
  /// **'High result'**
  String get sectionHighResult;

  /// No description provided for @sectionLowResult.
  ///
  /// In en, this message translates to:
  /// **'Low result'**
  String get sectionLowResult;

  /// No description provided for @sectionPositiveResult.
  ///
  /// In en, this message translates to:
  /// **'Positive result'**
  String get sectionPositiveResult;

  /// No description provided for @sectionNegativeResult.
  ///
  /// In en, this message translates to:
  /// **'Negative result'**
  String get sectionNegativeResult;

  /// No description provided for @sectionResults.
  ///
  /// In en, this message translates to:
  /// **'What the results mean'**
  String get sectionResults;

  /// No description provided for @sectionPreanalytics.
  ///
  /// In en, this message translates to:
  /// **'Specimen and preanalytics'**
  String get sectionPreanalytics;

  /// No description provided for @sectionInterference.
  ///
  /// In en, this message translates to:
  /// **'Interference'**
  String get sectionInterference;

  /// No description provided for @sectionLimitations.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get sectionLimitations;

  /// No description provided for @labTitle.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get labTitle;

  /// No description provided for @labSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clear path at every stage.'**
  String get labSubtitle;

  /// No description provided for @labHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Instrument → reagent → method'**
  String get labHeroEyebrow;

  /// No description provided for @labHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get labHeroTitle;

  /// No description provided for @labSectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sections and atlases'**
  String get labSectionsTitle;

  /// No description provided for @labToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Work tools'**
  String get labToolsTitle;

  /// No description provided for @labHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Instructions and controls matched to the exact model.'**
  String get labHeroBody;

  /// No description provided for @labHeroCta.
  ///
  /// In en, this message translates to:
  /// **'Open calibration'**
  String get labHeroCta;

  /// No description provided for @labQcSub.
  ///
  /// In en, this message translates to:
  /// **'Control charts and rules'**
  String get labQcSub;

  /// No description provided for @labPreanalytics.
  ///
  /// In en, this message translates to:
  /// **'Preanalytics'**
  String get labPreanalytics;

  /// No description provided for @labPreanalyticsSub.
  ///
  /// In en, this message translates to:
  /// **'Collecting, storing and transporting samples'**
  String get labPreanalyticsSub;

  /// No description provided for @labCalculatorsSub.
  ///
  /// In en, this message translates to:
  /// **'eGFR, ACR, dilution and more'**
  String get labCalculatorsSub;

  /// No description provided for @labInstruments.
  ///
  /// In en, this message translates to:
  /// **'Instruments and methods'**
  String get labInstruments;

  /// No description provided for @labInstrumentsSub.
  ///
  /// In en, this message translates to:
  /// **'Chemistry · hematology · immunochemistry · urine'**
  String get labInstrumentsSub;

  /// No description provided for @labMicroscopySub.
  ///
  /// In en, this message translates to:
  /// **'Compare images and structures'**
  String get labMicroscopySub;

  /// No description provided for @calTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration workflow'**
  String get calTitle;

  /// No description provided for @calSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Exact matching is needed to select the correct instructions.'**
  String get calSubtitle;

  /// No description provided for @calManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get calManufacturer;

  /// No description provided for @calManufacturerOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get calManufacturerOther;

  /// No description provided for @calModel.
  ///
  /// In en, this message translates to:
  /// **'Instrument model'**
  String get calModel;

  /// No description provided for @calModelHint.
  ///
  /// In en, this message translates to:
  /// **'Exact model name'**
  String get calModelHint;

  /// No description provided for @calReagentRef.
  ///
  /// In en, this message translates to:
  /// **'Reagent REF'**
  String get calReagentRef;

  /// No description provided for @calIfuRevision.
  ///
  /// In en, this message translates to:
  /// **'IFU revision'**
  String get calIfuRevision;

  /// No description provided for @calCalibratorLot.
  ///
  /// In en, this message translates to:
  /// **'Calibrator lot'**
  String get calCalibratorLot;

  /// No description provided for @calCheck.
  ///
  /// In en, this message translates to:
  /// **'Check match'**
  String get calCheck;

  /// No description provided for @calFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'Fill in the model, reagent REF and IFU revision.'**
  String get calFieldsRequired;

  /// No description provided for @calNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No verified instructions for this combination'**
  String get calNoMatchTitle;

  /// No description provided for @calNoMatchBody.
  ///
  /// In en, this message translates to:
  /// **'Calibration parameters are shown only from a verified IFU that matches the manufacturer, model, reagent REF, IFU revision and calibrator lot. Use the manufacturer’s current IFU.'**
  String get calNoMatchBody;

  /// No description provided for @calCatalogCount.
  ///
  /// In en, this message translates to:
  /// **'Verified IFU records in this build: {count}'**
  String calCatalogCount(int count);

  /// No description provided for @calBrandWarning.
  ///
  /// In en, this message translates to:
  /// **'A brand name (e.g. Mindray or HUMAN) doesn’t mean all models share settings. The reagent IFU and the instrument manual are separate documents.'**
  String get calBrandWarning;

  /// No description provided for @calWorkflow.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get calWorkflow;

  /// No description provided for @calStep1.
  ///
  /// In en, this message translates to:
  /// **'Model, reagent and instruction revision'**
  String get calStep1;

  /// No description provided for @calStep2.
  ///
  /// In en, this message translates to:
  /// **'Calibrator lot and assigned values'**
  String get calStep2;

  /// No description provided for @calStep3.
  ///
  /// In en, this message translates to:
  /// **'Method-specific preparation'**
  String get calStep3;

  /// No description provided for @calStep4.
  ///
  /// In en, this message translates to:
  /// **'Calibration according to the instructions'**
  String get calStep4;

  /// No description provided for @calStep5.
  ///
  /// In en, this message translates to:
  /// **'Post-calibration QC'**
  String get calStep5;

  /// No description provided for @calStep6.
  ///
  /// In en, this message translates to:
  /// **'Records and troubleshooting'**
  String get calStep6;

  /// No description provided for @calNoServiceCodes.
  ///
  /// In en, this message translates to:
  /// **'Service codes and safety-bypass procedures are not included.'**
  String get calNoServiceCodes;

  /// No description provided for @qcTitle.
  ///
  /// In en, this message translates to:
  /// **'Quality control'**
  String get qcTitle;

  /// No description provided for @qcChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Levey–Jennings'**
  String get qcChartTitle;

  /// No description provided for @qcChartBody.
  ///
  /// In en, this message translates to:
  /// **'A chart needs the test, control lot, level, target mean and SD. No invented results are plotted.'**
  String get qcChartBody;

  /// No description provided for @qcEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No control records yet'**
  String get qcEmptyTitle;

  /// No description provided for @qcEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add a test with its control levels to start a Levey–Jennings chart. Data is stored only on this device.'**
  String get qcEmptyBody;

  /// No description provided for @qcIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter each control level’s target mean and SD, then record every run. The app checks Westgard rules; it never invents target values or results.'**
  String get qcIntro;

  /// No description provided for @qcLoadError.
  ///
  /// In en, this message translates to:
  /// **'Saved QC data could not be read. Nothing was overwritten.'**
  String get qcLoadError;

  /// No description provided for @qcAddSet.
  ///
  /// In en, this message translates to:
  /// **'Add test'**
  String get qcAddSet;

  /// No description provided for @qcSetName.
  ///
  /// In en, this message translates to:
  /// **'Test name'**
  String get qcSetName;

  /// No description provided for @qcUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get qcUnit;

  /// No description provided for @qcTargetSource.
  ///
  /// In en, this message translates to:
  /// **'Source of the target mean and SD'**
  String get qcTargetSource;

  /// No description provided for @qcSourceLab.
  ///
  /// In en, this message translates to:
  /// **'Our laboratory’s data'**
  String get qcSourceLab;

  /// No description provided for @qcSourceManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer’s sheet'**
  String get qcSourceManufacturer;

  /// No description provided for @qcLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {label}'**
  String qcLevel(String label);

  /// No description provided for @qcLevelNamed.
  ///
  /// In en, this message translates to:
  /// **'Level “{label}”'**
  String qcLevelNamed(String label);

  /// No description provided for @qcLevelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 level} other{{count} levels}}'**
  String qcLevelsCount(int count);

  /// No description provided for @qcRunsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{no runs} =1{1 run} other{{count} runs}}'**
  String qcRunsCount(int count);

  /// No description provided for @qcLot.
  ///
  /// In en, this message translates to:
  /// **'Lot'**
  String get qcLot;

  /// No description provided for @qcMean.
  ///
  /// In en, this message translates to:
  /// **'Target mean'**
  String get qcMean;

  /// No description provided for @qcSd.
  ///
  /// In en, this message translates to:
  /// **'Target SD'**
  String get qcSd;

  /// No description provided for @qcAddLevel.
  ///
  /// In en, this message translates to:
  /// **'Add level'**
  String get qcAddLevel;

  /// No description provided for @qcRemoveLevel.
  ///
  /// In en, this message translates to:
  /// **'Remove level'**
  String get qcRemoveLevel;

  /// No description provided for @qcSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get qcSave;

  /// No description provided for @qcTargetNote.
  ///
  /// In en, this message translates to:
  /// **'Westgard et al. (1981) calculate the mean and SD from the laboratory’s own control measurements — initially about 20 (one run a day), then revised as more data accumulate. The app does not supply these values.'**
  String get qcTargetNote;

  /// No description provided for @qcManufacturerWarning.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer’s values are a guide only; Westgard’s lessons recommend limits calculated from your own control data — the assay sheet’s ranges are often too wide.'**
  String get qcManufacturerWarning;

  /// No description provided for @qcErrName.
  ///
  /// In en, this message translates to:
  /// **'Enter the test name.'**
  String get qcErrName;

  /// No description provided for @qcErrLevel.
  ///
  /// In en, this message translates to:
  /// **'{label}: enter the mean and an SD greater than zero.'**
  String qcErrLevel(String label);

  /// No description provided for @qcAccept.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get qcAccept;

  /// No description provided for @qcWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get qcWarning;

  /// No description provided for @qcReject.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get qcReject;

  /// No description provided for @qcAcceptBody.
  ///
  /// In en, this message translates to:
  /// **'No rule violated.'**
  String get qcAcceptBody;

  /// No description provided for @qcLatestRun.
  ///
  /// In en, this message translates to:
  /// **'Latest run'**
  String get qcLatestRun;

  /// No description provided for @qcNoRunsYet.
  ///
  /// In en, this message translates to:
  /// **'No runs yet — add the first one below.'**
  String get qcNoRunsYet;

  /// No description provided for @qcAddRun.
  ///
  /// In en, this message translates to:
  /// **'Add run'**
  String get qcAddRun;

  /// No description provided for @qcJumpToAddRun.
  ///
  /// In en, this message translates to:
  /// **'Enter a run below'**
  String get qcJumpToAddRun;

  /// No description provided for @qcNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get qcNote;

  /// No description provided for @qcSaveRun.
  ///
  /// In en, this message translates to:
  /// **'Save run'**
  String get qcSaveRun;

  /// No description provided for @qcErrRunEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one control value.'**
  String get qcErrRunEmpty;

  /// No description provided for @qcErrRunInvalid.
  ///
  /// In en, this message translates to:
  /// **'{label}: not a number.'**
  String qcErrRunInvalid(String label);

  /// No description provided for @qcRunHistory.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get qcRunHistory;

  /// No description provided for @qcStats.
  ///
  /// In en, this message translates to:
  /// **'Observed'**
  String get qcStats;

  /// No description provided for @qcChartLegend.
  ///
  /// In en, this message translates to:
  /// **'● in control   ▲ warning   ■ rejected'**
  String get qcChartLegend;

  /// No description provided for @qcChartSemantics.
  ///
  /// In en, this message translates to:
  /// **'Levey–Jennings chart, {label}: {count} values'**
  String qcChartSemantics(String label, int count);

  /// No description provided for @qcDeleteRun.
  ///
  /// In en, this message translates to:
  /// **'Delete run'**
  String get qcDeleteRun;

  /// No description provided for @qcDeleteSet.
  ///
  /// In en, this message translates to:
  /// **'Delete test and all runs'**
  String get qcDeleteSet;

  /// No description provided for @qcConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'This can’t be undone.'**
  String get qcConfirmDelete;

  /// No description provided for @qcSetMissing.
  ///
  /// In en, this message translates to:
  /// **'This test no longer exists.'**
  String get qcSetMissing;

  /// No description provided for @qcCopyCsv.
  ///
  /// In en, this message translates to:
  /// **'Copy runs as a table (CSV)'**
  String get qcCopyCsv;

  /// No description provided for @qcCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied {count} rows — paste into Excel or Google Sheets'**
  String qcCopied(int count);

  /// No description provided for @qcChangeTarget.
  ///
  /// In en, this message translates to:
  /// **'Change target or lot'**
  String get qcChangeTarget;

  /// No description provided for @qcChangeTargetBody.
  ///
  /// In en, this message translates to:
  /// **'Use this when a new control lot starts or your laboratory recalculates the mean and SD. The new values apply from the chosen time (usually now); earlier runs keep being evaluated against the targets that were in effect then.'**
  String get qcChangeTargetBody;

  /// No description provided for @qcErrTarget.
  ///
  /// In en, this message translates to:
  /// **'Enter the mean and an SD greater than zero.'**
  String get qcErrTarget;

  /// No description provided for @qcSince.
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String qcSince(String date);

  /// No description provided for @qcPreviousTarget.
  ///
  /// In en, this message translates to:
  /// **'Previous: {target} (from {date})'**
  String qcPreviousTarget(String target, String date);

  /// No description provided for @qcRulesSource.
  ///
  /// In en, this message translates to:
  /// **'Rules: Westgard multirule procedure (Westgard JO et al., Clin Chem 1981; doi:10.1093/clinchem/27.3.493). A learning and checking aid — it does not replace your laboratory’s QC procedure.'**
  String get qcRulesSource;

  /// No description provided for @qcGuidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Guides'**
  String get qcGuidesTitle;

  /// No description provided for @qgRejected.
  ///
  /// In en, this message translates to:
  /// **'What to do when QC is rejected'**
  String get qgRejected;

  /// No description provided for @qgRejectedSub.
  ///
  /// In en, this message translates to:
  /// **'Stop, find the cause, recheck'**
  String get qgRejectedSub;

  /// No description provided for @qgEqa.
  ///
  /// In en, this message translates to:
  /// **'External quality assessment (EQA)'**
  String get qgEqa;

  /// No description provided for @qgEqaSub.
  ///
  /// In en, this message translates to:
  /// **'What it is, how it works, poor results'**
  String get qgEqaSub;

  /// No description provided for @qgCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical values'**
  String get qgCritical;

  /// No description provided for @qgCriticalSub.
  ///
  /// In en, this message translates to:
  /// **'Who sets the list and how to notify'**
  String get qgCriticalSub;

  /// No description provided for @qgWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do?'**
  String get qgWhatToDo;

  /// No description provided for @qcErrSave.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save. Please try again.'**
  String get qcErrSave;

  /// No description provided for @qcErrNotFinite.
  ///
  /// In en, this message translates to:
  /// **'{label}: the value is too large or too small.'**
  String qcErrNotFinite(String label);

  /// No description provided for @qcLevelName.
  ///
  /// In en, this message translates to:
  /// **'Level name (optional, e.g. “Low”)'**
  String get qcLevelName;

  /// No description provided for @qcStatsExcluded.
  ///
  /// In en, this message translates to:
  /// **'Rejected runs are excluded.'**
  String get qcStatsExcluded;

  /// No description provided for @qcStatsFew.
  ///
  /// In en, this message translates to:
  /// **'n = {count}: still few values — Westgard et al. (1981) initially calculate targets from about 20 values.'**
  String qcStatsFew(int count);

  /// No description provided for @qcUseObserved.
  ///
  /// In en, this message translates to:
  /// **'Use observed x̄ and SD (n = {count})'**
  String qcUseObserved(int count);

  /// No description provided for @qcEffectiveFrom.
  ///
  /// In en, this message translates to:
  /// **'Effective from'**
  String get qcEffectiveFrom;

  /// No description provided for @qcFromNow.
  ///
  /// In en, this message translates to:
  /// **'From now'**
  String get qcFromNow;

  /// No description provided for @qcFromDate.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String qcFromDate(String date);

  /// No description provided for @qcPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get qcPickDate;

  /// No description provided for @qcRunTime.
  ///
  /// In en, this message translates to:
  /// **'Run time: {time}'**
  String qcRunTime(String time);

  /// No description provided for @qcRunTimeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get qcRunTimeNow;

  /// No description provided for @qcRunTimeHint.
  ///
  /// In en, this message translates to:
  /// **'For a run entered late, pick the actual measurement time — the rules check runs in time order.'**
  String get qcRunTimeHint;

  /// No description provided for @qcShowAllRuns.
  ///
  /// In en, this message translates to:
  /// **'Show all ({count})'**
  String qcShowAllRuns(int count);

  /// No description provided for @qcRejectedExcluded.
  ///
  /// In en, this message translates to:
  /// **'Not used in later rules or statistics'**
  String get qcRejectedExcluded;

  /// No description provided for @qcAtEntry.
  ///
  /// In en, this message translates to:
  /// **'At entry: {verdict}'**
  String qcAtEntry(String verdict);

  /// No description provided for @qcUndoTarget.
  ///
  /// In en, this message translates to:
  /// **'Undo the last change'**
  String get qcUndoTarget;

  /// No description provided for @qcUndoTargetBody.
  ///
  /// In en, this message translates to:
  /// **'The current target is removed and the previous one is restored: {target}. Runs are re-evaluated.'**
  String qcUndoTargetBody(String target);

  /// No description provided for @qcBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get qcBackupTitle;

  /// No description provided for @qcBackupBody.
  ///
  /// In en, this message translates to:
  /// **'QC data is stored only on this device. Copy the backup (JSON) and keep it somewhere safe; on another device you can restore it from the clipboard.'**
  String get qcBackupBody;

  /// No description provided for @qcBackupCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy backup'**
  String get qcBackupCopy;

  /// No description provided for @qcBackupCopied.
  ///
  /// In en, this message translates to:
  /// **'Backup copied to the clipboard'**
  String get qcBackupCopied;

  /// No description provided for @qcBackupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from clipboard'**
  String get qcBackupRestore;

  /// No description provided for @qcRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Current QC data will be replaced by the backup from the clipboard: {sets} tests, {runs} runs.'**
  String qcRestoreConfirm(int sets, int runs);

  /// No description provided for @qcRestoreAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get qcRestoreAction;

  /// No description provided for @qcRestoreInvalid.
  ///
  /// In en, this message translates to:
  /// **'The clipboard does not contain a valid QC backup.'**
  String get qcRestoreInvalid;

  /// No description provided for @qcRestored.
  ///
  /// In en, this message translates to:
  /// **'QC data restored'**
  String get qcRestored;

  /// No description provided for @qcCopyRaw.
  ///
  /// In en, this message translates to:
  /// **'Copy the saved text'**
  String get qcCopyRaw;

  /// No description provided for @qcDiscard.
  ///
  /// In en, this message translates to:
  /// **'Delete the unreadable data'**
  String get qcDiscard;

  /// No description provided for @qcDiscardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Copy the saved text first. Once deleted, it cannot be recovered.'**
  String get qcDiscardConfirm;

  /// No description provided for @preTitle.
  ///
  /// In en, this message translates to:
  /// **'Preanalytics'**
  String get preTitle;

  /// No description provided for @preStep1.
  ///
  /// In en, this message translates to:
  /// **'Prepare for testing'**
  String get preStep1;

  /// No description provided for @preStep2.
  ///
  /// In en, this message translates to:
  /// **'Select specimen and additive'**
  String get preStep2;

  /// No description provided for @preStep3.
  ///
  /// In en, this message translates to:
  /// **'Collect and identify'**
  String get preStep3;

  /// No description provided for @preStep4.
  ///
  /// In en, this message translates to:
  /// **'Separate and store'**
  String get preStep4;

  /// No description provided for @preStep5.
  ///
  /// In en, this message translates to:
  /// **'Transport and receive'**
  String get preStep5;

  /// No description provided for @preNotice.
  ///
  /// In en, this message translates to:
  /// **'Tube color, time and temperature depend on the specific tube, method and instructions. The times above are general guidance from the WHO table; your laboratory’s rules take priority.'**
  String get preNotice;

  /// No description provided for @diffTitle.
  ///
  /// In en, this message translates to:
  /// **'Differential count'**
  String get diffTitle;

  /// No description provided for @diffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Identify, count and interpret white cells'**
  String get diffSubtitle;

  /// No description provided for @diffLabCardBody.
  ///
  /// In en, this message translates to:
  /// **'Manual count tally, cell atlas and interpretation'**
  String get diffLabCardBody;

  /// No description provided for @diffHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Read a differential with confidence'**
  String get diffHeroTitle;

  /// No description provided for @diffHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Cell schematics, a big-button tally counter, interpretation and smear technique in one place.'**
  String get diffHeroBody;

  /// No description provided for @diffStartCount.
  ///
  /// In en, this message translates to:
  /// **'Start counting'**
  String get diffStartCount;

  /// No description provided for @diffResumeCount.
  ///
  /// In en, this message translates to:
  /// **'Continue counting ({count}/{target})'**
  String diffResumeCount(int count, int target);

  /// No description provided for @diffCellsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cell identification'**
  String get diffCellsTitle;

  /// No description provided for @diffCellsSub.
  ///
  /// In en, this message translates to:
  /// **'{count} cells: size, nucleus, cytoplasm, granules'**
  String diffCellsSub(int count);

  /// No description provided for @diffConfusionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Common mix-ups'**
  String get diffConfusionsTitle;

  /// No description provided for @diffConfusionsSub.
  ///
  /// In en, this message translates to:
  /// **'Reactive lymphocyte or monocyte? Band or segmented?'**
  String get diffConfusionsSub;

  /// No description provided for @diffCounterTitle.
  ///
  /// In en, this message translates to:
  /// **'Tally counter'**
  String get diffCounterTitle;

  /// No description provided for @diffCounterSub.
  ///
  /// In en, this message translates to:
  /// **'Tap +1, long-press −1; 100 or 200 cells'**
  String get diffCounterSub;

  /// No description provided for @diffHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved results'**
  String get diffHistoryTitle;

  /// No description provided for @diffHistorySub.
  ///
  /// In en, this message translates to:
  /// **'{count} results — on this device only'**
  String diffHistorySub(int count);

  /// No description provided for @diffInterpretTitle.
  ///
  /// In en, this message translates to:
  /// **'Interpretation'**
  String get diffInterpretTitle;

  /// No description provided for @diffInterpretSub.
  ///
  /// In en, this message translates to:
  /// **'Left shift, neutrophilia, lymphocytosis and more'**
  String get diffInterpretSub;

  /// No description provided for @diffTechniqueTitle.
  ///
  /// In en, this message translates to:
  /// **'Smear technique and errors'**
  String get diffTechniqueTitle;

  /// No description provided for @diffTechniqueSub.
  ///
  /// In en, this message translates to:
  /// **'Making, staining, where to count'**
  String get diffTechniqueSub;

  /// No description provided for @diffQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'“Which cell is this?” practice'**
  String get diffQuizTitle;

  /// No description provided for @diffQuizSub.
  ///
  /// In en, this message translates to:
  /// **'{count} questions with schematic images'**
  String diffQuizSub(int count);

  /// No description provided for @diffLearnSub.
  ///
  /// In en, this message translates to:
  /// **'Cell atlas, tally counter and “Which cell is this?” practice'**
  String get diffLearnSub;

  /// No description provided for @diffSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get diffSourcesTitle;

  /// No description provided for @diffSchematicCaption.
  ///
  /// In en, this message translates to:
  /// **'Schematic drawing (made by LabGuide) — not a micrograph'**
  String get diffSchematicCaption;

  /// No description provided for @diffScaleNote.
  ///
  /// In en, this message translates to:
  /// **'All schematics share one scale; the surrounding red cells (~7.5 µm) help compare size.'**
  String get diffScaleNote;

  /// No description provided for @diffRelatedCards.
  ///
  /// In en, this message translates to:
  /// **'Test cards'**
  String get diffRelatedCards;

  /// No description provided for @diffSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get diffSize;

  /// No description provided for @diffNucleus.
  ///
  /// In en, this message translates to:
  /// **'Nucleus'**
  String get diffNucleus;

  /// No description provided for @diffCytoplasm.
  ///
  /// In en, this message translates to:
  /// **'Cytoplasm'**
  String get diffCytoplasm;

  /// No description provided for @diffGranules.
  ///
  /// In en, this message translates to:
  /// **'Granules'**
  String get diffGranules;

  /// No description provided for @diffKeySign.
  ///
  /// In en, this message translates to:
  /// **'Key sign'**
  String get diffKeySign;

  /// No description provided for @diffSeenIn.
  ///
  /// In en, this message translates to:
  /// **'When it is seen'**
  String get diffSeenIn;

  /// No description provided for @diffReferTitle.
  ///
  /// In en, this message translates to:
  /// **'Refer to a physician or hematologist'**
  String get diffReferTitle;

  /// No description provided for @diffReferBody.
  ///
  /// In en, this message translates to:
  /// **'If you see a blast or a cell you cannot identify, do not interpret it yourself. Have a hematologist or physician review the smear according to your laboratory’s procedure.'**
  String get diffReferBody;

  /// No description provided for @diffCompareA.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get diffCompareA;

  /// No description provided for @diffCompareB.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get diffCompareB;

  /// No description provided for @diffFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get diffFeature;

  /// No description provided for @diffTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get diffTip;

  /// No description provided for @diffOpenCell.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get diffOpenCell;

  /// No description provided for @diffTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Cells to count'**
  String get diffTargetLabel;

  /// No description provided for @diffWbcLabel.
  ///
  /// In en, this message translates to:
  /// **'White cell count (WBC), ×10⁹/L — optional'**
  String get diffWbcLabel;

  /// No description provided for @diffWbcHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 7.5'**
  String get diffWbcHint;

  /// No description provided for @diffWbcInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number (e.g. 7.5)'**
  String get diffWbcInvalid;

  /// No description provided for @diffTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap: +1 · Long-press: −1'**
  String get diffTapHint;

  /// No description provided for @diffUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo last'**
  String get diffUndo;

  /// No description provided for @diffReset.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get diffReset;

  /// No description provided for @diffResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the count?'**
  String get diffResetTitle;

  /// No description provided for @diffResetBody.
  ///
  /// In en, this message translates to:
  /// **'{count} counted cells will be cleared.'**
  String diffResetBody(int count);

  /// No description provided for @diffResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get diffResetConfirm;

  /// No description provided for @diffDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{target} cells counted'**
  String diffDoneTitle(int target);

  /// No description provided for @diffDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Counting has stopped. Check the result, then save or copy it.'**
  String get diffDoneBody;

  /// No description provided for @diffBlocked.
  ///
  /// In en, this message translates to:
  /// **'Target reached — tap not added'**
  String get diffBlocked;

  /// No description provided for @diffResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get diffResultTitle;

  /// No description provided for @diffColCell.
  ///
  /// In en, this message translates to:
  /// **'Cell'**
  String get diffColCell;

  /// No description provided for @diffColCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get diffColCount;

  /// No description provided for @diffColAbs.
  ///
  /// In en, this message translates to:
  /// **'×10⁹/L'**
  String get diffColAbs;

  /// No description provided for @diffAbsNeedWbc.
  ///
  /// In en, this message translates to:
  /// **'Enter the WBC to see absolute counts.'**
  String get diffAbsNeedWbc;

  /// No description provided for @diffOtherWarning.
  ///
  /// In en, this message translates to:
  /// **'“Other” cells were counted. If they are blasts or unidentified cells, have a hematologist or physician review the smear.'**
  String get diffOtherWarning;

  /// No description provided for @diffSave.
  ///
  /// In en, this message translates to:
  /// **'Save to history'**
  String get diffSave;

  /// No description provided for @diffSaved.
  ///
  /// In en, this message translates to:
  /// **'Result saved (on this device only)'**
  String get diffSaved;

  /// No description provided for @diffLabelField.
  ///
  /// In en, this message translates to:
  /// **'Sample label (optional, no patient names)'**
  String get diffLabelField;

  /// No description provided for @diffLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. sample 12'**
  String get diffLabelHint;

  /// No description provided for @diffCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get diffCopy;

  /// No description provided for @diffCopied.
  ///
  /// In en, this message translates to:
  /// **'Result copied'**
  String get diffCopied;

  /// No description provided for @diffCopyHeader.
  ///
  /// In en, this message translates to:
  /// **'Differential count ({total} cells)'**
  String diffCopyHeader(int total);

  /// No description provided for @diffCopyFooter.
  ///
  /// In en, this message translates to:
  /// **'LabGuide · manual count. Reference intervals: see the laboratory report form.'**
  String get diffCopyFooter;

  /// No description provided for @diffWbcLine.
  ///
  /// In en, this message translates to:
  /// **'WBC: {value} ×10⁹/L'**
  String diffWbcLine(String value);

  /// No description provided for @diffButtonSemantics.
  ///
  /// In en, this message translates to:
  /// **'{cell}: {count}. Tap to add, long-press to subtract.'**
  String diffButtonSemantics(String cell, int count);

  /// No description provided for @diffDecrementAction.
  ///
  /// In en, this message translates to:
  /// **'Subtract one'**
  String get diffDecrementAction;

  /// No description provided for @diffEfEntry.
  ///
  /// In en, this message translates to:
  /// **'Microscope mode: eyes-free counting'**
  String get diffEfEntry;

  /// No description provided for @diffEfEntrySub.
  ///
  /// In en, this message translates to:
  /// **'Large screen zones; a sound and vibration on every tap'**
  String get diffEfEntrySub;

  /// No description provided for @diffEfTitle.
  ///
  /// In en, this message translates to:
  /// **'Eyes-free counting'**
  String get diffEfTitle;

  /// No description provided for @diffEfExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get diffEfExit;

  /// No description provided for @diffEfUndoZone.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get diffEfUndoZone;

  /// No description provided for @diffEfUndoHint.
  ///
  /// In en, this message translates to:
  /// **'or tap with two fingers'**
  String get diffEfUndoHint;

  /// No description provided for @diffEfZoneSemantics.
  ///
  /// In en, this message translates to:
  /// **'{cell}: {count}. Total {total} / {target}.'**
  String diffEfZoneSemantics(String cell, int count, int total, int target);

  /// No description provided for @diffEfAnnounce.
  ///
  /// In en, this message translates to:
  /// **'{cell} {count}. Total {total}'**
  String diffEfAnnounce(String cell, int count, int total);

  /// No description provided for @diffEfUndone.
  ///
  /// In en, this message translates to:
  /// **'Undone: {cell}. Total {total}'**
  String diffEfUndone(String cell, int total);

  /// No description provided for @diffEfNothingToUndo.
  ///
  /// In en, this message translates to:
  /// **'Nothing to undo'**
  String get diffEfNothingToUndo;

  /// No description provided for @diffEfShowResult.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get diffEfShowResult;

  /// No description provided for @diffEfVoiceOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on voice commands'**
  String get diffEfVoiceOn;

  /// No description provided for @diffEfVoiceOff.
  ///
  /// In en, this message translates to:
  /// **'Stop voice commands'**
  String get diffEfVoiceOff;

  /// No description provided for @diffEfSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Microscope mode'**
  String get diffEfSettingsTitle;

  /// No description provided for @diffEfSettingsSub.
  ///
  /// In en, this message translates to:
  /// **'Count without looking away from the microscope'**
  String get diffEfSettingsSub;

  /// No description provided for @diffEfStart.
  ///
  /// In en, this message translates to:
  /// **'Start counting'**
  String get diffEfStart;

  /// No description provided for @diffEfHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get diffEfHowTitle;

  /// No description provided for @diffEfHowBody.
  ///
  /// In en, this message translates to:
  /// **'Put the phone on the bench and tap the zones without looking away from the microscope. Every tap gives a short sound and a vibration pattern specific to the cell type; every 10th cell — a two-tone signal and a long vibration; at the target (100 or 200) — a three-note signal and counting stops. The count is shared with the regular counter.'**
  String get diffEfHowBody;

  /// No description provided for @diffEfZonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get diffEfZonesTitle;

  /// No description provided for @diffEfHandLabel.
  ///
  /// In en, this message translates to:
  /// **'Which hand do you tap with'**
  String get diffEfHandLabel;

  /// No description provided for @diffEfHandRight.
  ///
  /// In en, this message translates to:
  /// **'Right hand'**
  String get diffEfHandRight;

  /// No description provided for @diffEfHandLeft.
  ///
  /// In en, this message translates to:
  /// **'Left hand'**
  String get diffEfHandLeft;

  /// No description provided for @diffEfHandHint.
  ///
  /// In en, this message translates to:
  /// **'Zone 1 is closest to your thumb — in the bottom corner.'**
  String get diffEfHandHint;

  /// No description provided for @diffEfOtherZone.
  ///
  /// In en, this message translates to:
  /// **'“Other (blasts…)” zone'**
  String get diffEfOtherZone;

  /// No description provided for @diffEfOtherZoneSub.
  ///
  /// In en, this message translates to:
  /// **'Turn off for 6 larger zones'**
  String get diffEfOtherZoneSub;

  /// No description provided for @diffEfUndoSwitch.
  ///
  /// In en, this message translates to:
  /// **'Large “Undo” zone at the top'**
  String get diffEfUndoSwitch;

  /// No description provided for @diffEfUndoSwitchSub.
  ///
  /// In en, this message translates to:
  /// **'A two-finger tap always undoes the last tap'**
  String get diffEfUndoSwitchSub;

  /// No description provided for @diffEfOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Zone order'**
  String get diffEfOrderTitle;

  /// No description provided for @diffEfOrderHint.
  ///
  /// In en, this message translates to:
  /// **'1 is the zone closest to your thumb. Put the most frequent cells first.'**
  String get diffEfOrderHint;

  /// No description provided for @diffEfMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up: {cell}'**
  String diffEfMoveUp(String cell);

  /// No description provided for @diffEfMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down: {cell}'**
  String diffEfMoveDown(String cell);

  /// No description provided for @diffEfSignalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Signals'**
  String get diffEfSignalsTitle;

  /// No description provided for @diffEfSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get diffEfSound;

  /// No description provided for @diffEfSoundSub.
  ///
  /// In en, this message translates to:
  /// **'Volume follows the phone’s volume buttons'**
  String get diffEfSoundSub;

  /// No description provided for @diffEfHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get diffEfHaptics;

  /// No description provided for @diffEfHapticsSub.
  ///
  /// In en, this message translates to:
  /// **'Not felt if vibration is turned off in phone settings'**
  String get diffEfHapticsSub;

  /// No description provided for @diffEfPatternsTitle.
  ///
  /// In en, this message translates to:
  /// **'Vibration patterns'**
  String get diffEfPatternsTitle;

  /// No description provided for @diffEfPatternsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a row to try it. How it feels depends on the phone model.'**
  String get diffEfPatternsHint;

  /// No description provided for @diffEfPattern.
  ///
  /// In en, this message translates to:
  /// **'{count} × {strength}'**
  String diffEfPattern(int count, String strength);

  /// No description provided for @diffEfPulseLight.
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get diffEfPulseLight;

  /// No description provided for @diffEfPulseMedium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get diffEfPulseMedium;

  /// No description provided for @diffEfPulseHeavy.
  ///
  /// In en, this message translates to:
  /// **'strong'**
  String get diffEfPulseHeavy;

  /// No description provided for @diffEfPatternTen.
  ///
  /// In en, this message translates to:
  /// **'Every 10th cell'**
  String get diffEfPatternTen;

  /// No description provided for @diffEfPatternTenDesc.
  ///
  /// In en, this message translates to:
  /// **'+ long vibration'**
  String get diffEfPatternTenDesc;

  /// No description provided for @diffEfPatternDone.
  ///
  /// In en, this message translates to:
  /// **'Target reached'**
  String get diffEfPatternDone;

  /// No description provided for @diffEfPatternDoneDesc.
  ///
  /// In en, this message translates to:
  /// **'2 × strong + long'**
  String get diffEfPatternDoneDesc;

  /// No description provided for @diffEfPatternUndoDesc.
  ///
  /// In en, this message translates to:
  /// **'strong + short'**
  String get diffEfPatternUndoDesc;

  /// No description provided for @diffEfScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Screen'**
  String get diffEfScreenTitle;

  /// No description provided for @diffEfAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get diffEfAwake;

  /// No description provided for @diffEfAwakeSub.
  ///
  /// In en, this message translates to:
  /// **'The screen stays on while counting — uses more battery'**
  String get diffEfAwakeSub;

  /// No description provided for @diffVoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice counting'**
  String get diffVoiceTitle;

  /// No description provided for @diffVoiceExperimental.
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get diffVoiceExperimental;

  /// No description provided for @diffVoiceSwitch.
  ///
  /// In en, this message translates to:
  /// **'Voice commands'**
  String get diffVoiceSwitch;

  /// No description provided for @diffVoiceSwitchSub.
  ///
  /// In en, this message translates to:
  /// **'Say a cell name — +1; “undo” — undo the last one'**
  String get diffVoiceSwitchSub;

  /// No description provided for @diffVoiceLangLabel.
  ///
  /// In en, this message translates to:
  /// **'Command language'**
  String get diffVoiceLangLabel;

  /// No description provided for @diffVoiceLangAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get diffVoiceLangAuto;

  /// No description provided for @diffVoiceLangUz.
  ///
  /// In en, this message translates to:
  /// **'Uzbek'**
  String get diffVoiceLangUz;

  /// No description provided for @diffVoiceLangRu.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get diffVoiceLangRu;

  /// No description provided for @diffVoiceLangEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get diffVoiceLangEn;

  /// No description provided for @diffVoiceLangHint.
  ///
  /// In en, this message translates to:
  /// **'Auto: if the app language isn’t available on the device — Russian, then English. Uzbek is not in Apple’s dictation language list; on Android it depends on the device.'**
  String get diffVoiceLangHint;

  /// No description provided for @diffVoiceWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Words to say'**
  String get diffVoiceWordsTitle;

  /// No description provided for @diffVoicePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Where your voice is processed'**
  String get diffVoicePrivacyTitle;

  /// No description provided for @diffVoicePrivacyIos.
  ///
  /// In en, this message translates to:
  /// **'iOS: on-device recognition is required. If it isn’t available for the language, the mode won’t work — audio is not sent to a server. LabGuide does not store or send your voice anywhere.'**
  String get diffVoicePrivacyIos;

  /// No description provided for @diffVoicePrivacyAndroid.
  ///
  /// In en, this message translates to:
  /// **'Android: works only with speech recognition on the phone itself (offline) — Android 12+ with on-device recognition is required. Otherwise the mode stays off and audio is not sent to a server. LabGuide does not store or send your voice anywhere.'**
  String get diffVoicePrivacyAndroid;

  /// No description provided for @diffVoiceNoNames.
  ///
  /// In en, this message translates to:
  /// **'Say only cell names — never patient names or other details.'**
  String get diffVoiceNoNames;

  /// No description provided for @diffVoiceAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy depends on noise, pronunciation and the device. Listen for the signal after each command; say “undo” if it’s wrong. Check the result before saving.'**
  String get diffVoiceAccuracy;

  /// No description provided for @diffVoiceConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on voice commands?'**
  String get diffVoiceConsentTitle;

  /// No description provided for @diffVoiceConsentAction.
  ///
  /// In en, this message translates to:
  /// **'I understand, turn on'**
  String get diffVoiceConsentAction;

  /// No description provided for @diffVoiceStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting microphone…'**
  String get diffVoiceStarting;

  /// No description provided for @diffVoiceListening.
  ///
  /// In en, this message translates to:
  /// **'Listening · {lang}'**
  String diffVoiceListening(String lang);

  /// No description provided for @diffVoiceFallback.
  ///
  /// In en, this message translates to:
  /// **'No speech recognition for the app language on this device — say the words in {lang}.'**
  String diffVoiceFallback(String lang);

  /// No description provided for @diffVoiceHeard.
  ///
  /// In en, this message translates to:
  /// **'Heard: “{text}”'**
  String diffVoiceHeard(String text);

  /// No description provided for @diffVoiceNotUnderstood.
  ///
  /// In en, this message translates to:
  /// **'No command found: “{text}”'**
  String diffVoiceNotUnderstood(String text);

  /// No description provided for @diffVoicePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone or speech recognition permission was not granted, so voice commands don’t work. You can allow it for LabGuide in phone settings. Counting with zones keeps working.'**
  String get diffVoicePermissionDenied;

  /// No description provided for @diffVoiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition isn’t available on this device. Counting with zones keeps working.'**
  String get diffVoiceUnavailable;

  /// No description provided for @diffVoiceLanguageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition isn’t available for the chosen language on this device. Choose another language in settings.'**
  String get diffVoiceLanguageUnavailable;

  /// No description provided for @diffVoiceOnDeviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'On-device (offline) speech recognition isn’t available. Voice commands are off so audio is not sent to a server.'**
  String get diffVoiceOnDeviceUnavailable;

  /// No description provided for @diffVoiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Speech recognition stopped. Please try again.'**
  String get diffVoiceFailed;

  /// No description provided for @diffVoiceRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get diffVoiceRetry;

  /// No description provided for @diffHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved results yet'**
  String get diffHistoryEmptyTitle;

  /// No description provided for @diffHistoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Finish a count and tap “Save to history”.'**
  String get diffHistoryEmptyBody;

  /// No description provided for @diffHistoryClear.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get diffHistoryClear;

  /// No description provided for @diffHistoryClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete history?'**
  String get diffHistoryClearTitle;

  /// No description provided for @diffHistoryClearBody.
  ///
  /// In en, this message translates to:
  /// **'{count} results will be deleted from this device.'**
  String diffHistoryClearBody(int count);

  /// No description provided for @diffDeleted.
  ///
  /// In en, this message translates to:
  /// **'Result deleted'**
  String get diffDeleted;

  /// No description provided for @diffHistoryLocalNote.
  ///
  /// In en, this message translates to:
  /// **'Results stay on this device and are not sent to a server. “Delete local data” in Profile removes them too.'**
  String get diffHistoryLocalNote;

  /// No description provided for @diffInterpretIntro.
  ///
  /// In en, this message translates to:
  /// **'Interpretation always goes with the reference interval and the clinical picture. The reference is on your laboratory’s report form; the causes below are only possibilities, not a diagnosis.'**
  String get diffInterpretIntro;

  /// No description provided for @diffPossibleCauses.
  ///
  /// In en, this message translates to:
  /// **'Possible causes'**
  String get diffPossibleCauses;

  /// No description provided for @diffAbsNote.
  ///
  /// In en, this message translates to:
  /// **'A big rise in one cell type lowers the percentages of the others, so look at absolute counts (fraction × WBC).'**
  String get diffAbsNote;

  /// No description provided for @diffRangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Why doesn’t the app give a “normal range”?'**
  String get diffRangesTitle;

  /// No description provided for @diffRangesBody.
  ///
  /// In en, this message translates to:
  /// **'Open sources and a former-USSR textbook give different example adult ranges (%). Reports use only the reference on your laboratory’s form; children’s ranges depend on age.'**
  String get diffRangesBody;

  /// No description provided for @diffRangesWho.
  ///
  /// In en, this message translates to:
  /// **'WHO 2003'**
  String get diffRangesWho;

  /// No description provided for @diffRangesMedline.
  ///
  /// In en, this message translates to:
  /// **'MedlinePlus'**
  String get diffRangesMedline;

  /// No description provided for @diffRangesClassic.
  ///
  /// In en, this message translates to:
  /// **'Former-USSR textbook (1984)'**
  String get diffRangesClassic;

  /// No description provided for @diffRangesClassicNote.
  ///
  /// In en, this message translates to:
  /// **'The classic (former-USSR textbook) ranges are shown for comparison only: many local report forms still use them, but sources differ. Your laboratory’s report form is what counts.'**
  String get diffRangesClassicNote;

  /// No description provided for @refTitle.
  ///
  /// In en, this message translates to:
  /// **'Tables and algorithms'**
  String get refTitle;

  /// No description provided for @refSub.
  ///
  /// In en, this message translates to:
  /// **'Anemia, jaundice, liver patterns, parasites, obsolete methods'**
  String get refSub;

  /// No description provided for @refIntro.
  ///
  /// In en, this message translates to:
  /// **'Short tables based on textbooks and official sources. Sources are listed under each section.'**
  String get refIntro;

  /// No description provided for @refOpenSub.
  ///
  /// In en, this message translates to:
  /// **'Table and algorithm'**
  String get refOpenSub;

  /// No description provided for @refNotFound.
  ///
  /// In en, this message translates to:
  /// **'This table was not found.'**
  String get refNotFound;

  /// No description provided for @analyteReuseCitationOnly.
  ///
  /// In en, this message translates to:
  /// **'Book: cited as a source only, no text copied'**
  String get analyteReuseCitationOnly;

  /// No description provided for @diffQuizPrompt.
  ///
  /// In en, this message translates to:
  /// **'Which cell is this?'**
  String get diffQuizPrompt;

  /// No description provided for @diffQuizIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick the cell from the schematic. Questions are shuffled each time; after answering you see the distinguishing sign.'**
  String get diffQuizIntro;

  /// No description provided for @diffQuizStart.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get diffQuizStart;

  /// No description provided for @diffRealSmear.
  ///
  /// In en, this message translates to:
  /// **'Real smear'**
  String get diffRealSmear;

  /// No description provided for @diffRealSmearNote.
  ///
  /// In en, this message translates to:
  /// **'A licensed micrograph from the microscopy atlas. Author and license are shown when you open it.'**
  String get diffRealSmearNote;

  /// No description provided for @diffAtlasRow.
  ///
  /// In en, this message translates to:
  /// **'Real blood smears'**
  String get diffAtlasRow;

  /// No description provided for @diffAtlasRowSub.
  ///
  /// In en, this message translates to:
  /// **'Licensed micrographs from the microscopy atlas'**
  String get diffAtlasRowSub;

  /// No description provided for @diffQuizExtended.
  ///
  /// In en, this message translates to:
  /// **'Extended practice ({count} questions)'**
  String diffQuizExtended(int count);

  /// No description provided for @diffQuizExtendedIntro.
  ///
  /// In en, this message translates to:
  /// **'On top of the picture questions: identify the cell from a description of its nucleus, cytoplasm and granules.'**
  String get diffQuizExtendedIntro;

  /// No description provided for @diffQuizDescribed.
  ///
  /// In en, this message translates to:
  /// **'Which cell matches this description?'**
  String get diffQuizDescribed;

  /// No description provided for @diffHistoryMore.
  ///
  /// In en, this message translates to:
  /// **'{count} more results are stored on this device'**
  String diffHistoryMore(int count);

  /// No description provided for @preOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'Order of draw (venepuncture)'**
  String get preOrderTitle;

  /// No description provided for @preOrderSub.
  ///
  /// In en, this message translates to:
  /// **'WHO 2010, Table 2.3 (based on the NCCLS 2003 consensus). Check your laboratory’s current procedure.'**
  String get preOrderSub;

  /// No description provided for @preCap.
  ///
  /// In en, this message translates to:
  /// **'Cap: {cap}'**
  String preCap(String cap);

  /// No description provided for @preHaemolysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Causes of hemolysis'**
  String get preHaemolysisTitle;

  /// No description provided for @preTourniquetTitle.
  ///
  /// In en, this message translates to:
  /// **'Tourniquet'**
  String get preTourniquetTitle;

  /// No description provided for @preIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient identification and labeling'**
  String get preIdTitle;

  /// No description provided for @prePatientTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient preparation'**
  String get prePatientTitle;

  /// No description provided for @preTubeForTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Which tube for which test'**
  String get preTubeForTestTitle;

  /// No description provided for @preTubeForTestSub.
  ///
  /// In en, this message translates to:
  /// **'Color and position follow the WHO order above. Tubes may differ between laboratories.'**
  String get preTubeForTestSub;

  /// No description provided for @preTubeSlot.
  ///
  /// In en, this message translates to:
  /// **'{tube} · no. {n} in the order of draw'**
  String preTubeSlot(String tube, int n);

  /// No description provided for @preTubeNone.
  ///
  /// In en, this message translates to:
  /// **'Separate tube — not in the WHO order'**
  String get preTubeNone;

  /// No description provided for @preMixTitle.
  ///
  /// In en, this message translates to:
  /// **'Mixing the tube'**
  String get preMixTitle;

  /// No description provided for @preStabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Sample stability'**
  String get preStabilityTitle;

  /// No description provided for @preStabilitySub.
  ///
  /// In en, this message translates to:
  /// **'How long separated serum or plasma keeps (WHO, WHO/DIL/LAB/99.1). Your laboratory’s rules and the reagent insert take priority.'**
  String get preStabilitySub;

  /// No description provided for @preStabilityRoom.
  ///
  /// In en, this message translates to:
  /// **'20–25 °C (room)'**
  String get preStabilityRoom;

  /// No description provided for @preStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage rules'**
  String get preStorageTitle;

  /// No description provided for @preUrgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Cannot be stored — test at once'**
  String get preUrgentTitle;

  /// No description provided for @preBooksNote.
  ///
  /// In en, this message translates to:
  /// **'Textbooks (Selivanov 2005, Aripova 2007, Lyubina 1984) are a supporting source. Numbers are shown only where WHO or MedlinePlus confirm them.'**
  String get preBooksNote;

  /// No description provided for @calcTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculators'**
  String get calcTitle;

  /// No description provided for @calcLearningTag.
  ///
  /// In en, this message translates to:
  /// **'Learning calculator'**
  String get calcLearningTag;

  /// No description provided for @calcDilution.
  ///
  /// In en, this message translates to:
  /// **'Dilution'**
  String get calcDilution;

  /// No description provided for @calcDilutionSub.
  ///
  /// In en, this message translates to:
  /// **'C₁V₁ = C₂V₂'**
  String get calcDilutionSub;

  /// No description provided for @calcUnits.
  ///
  /// In en, this message translates to:
  /// **'Unit conversion'**
  String get calcUnits;

  /// No description provided for @calcUnitsSub.
  ///
  /// In en, this message translates to:
  /// **'Analyte-specific'**
  String get calcUnitsSub;

  /// No description provided for @calcSectionManual.
  ///
  /// In en, this message translates to:
  /// **'Manual methods'**
  String get calcSectionManual;

  /// No description provided for @mcChamber.
  ///
  /// In en, this message translates to:
  /// **'Counting chamber'**
  String get mcChamber;

  /// No description provided for @mcChamberSub.
  ///
  /// In en, this message translates to:
  /// **'Goryaev, Neubauer: cells/µL and ×10⁹/L'**
  String get mcChamberSub;

  /// No description provided for @mcDiff.
  ///
  /// In en, this message translates to:
  /// **'Differential: absolute counts'**
  String get mcDiff;

  /// No description provided for @mcDiffSub.
  ///
  /// In en, this message translates to:
  /// **'WBC × %, nucleated RBC correction'**
  String get mcDiffSub;

  /// No description provided for @mcRetic.
  ///
  /// In en, this message translates to:
  /// **'Reticulocytes'**
  String get mcRetic;

  /// No description provided for @mcReticSub.
  ///
  /// In en, this message translates to:
  /// **'%, corrected % and RPI'**
  String get mcReticSub;

  /// No description provided for @mcLight.
  ///
  /// In en, this message translates to:
  /// **'Light’s criteria'**
  String get mcLight;

  /// No description provided for @mcLightSub.
  ///
  /// In en, this message translates to:
  /// **'Pleural fluid: exudate or transudate'**
  String get mcLightSub;

  /// No description provided for @mcColour.
  ///
  /// In en, this message translates to:
  /// **'Color index'**
  String get mcColour;

  /// No description provided for @mcColourSub.
  ///
  /// In en, this message translates to:
  /// **'Why the app recommends MCH and MCHC'**
  String get mcColourSub;

  /// No description provided for @mcNechiporenko.
  ///
  /// In en, this message translates to:
  /// **'Nechiporenko count'**
  String get mcNechiporenko;

  /// No description provided for @mcNechiporenkoSub.
  ///
  /// In en, this message translates to:
  /// **'Leukocytes, erythrocytes and casts per 1 ml of urine'**
  String get mcNechiporenkoSub;

  /// No description provided for @mcAddis.
  ///
  /// In en, this message translates to:
  /// **'Kakovsky–Addis count'**
  String get mcAddis;

  /// No description provided for @mcAddisSub.
  ///
  /// In en, this message translates to:
  /// **'Formed elements passed in urine per day'**
  String get mcAddisSub;

  /// No description provided for @mcZimnitsky.
  ///
  /// In en, this message translates to:
  /// **'Zimnitsky test'**
  String get mcZimnitsky;

  /// No description provided for @mcZimnitskySub.
  ///
  /// In en, this message translates to:
  /// **'Day and night diuresis, specific-gravity range'**
  String get mcZimnitskySub;

  /// No description provided for @mcClassicTag.
  ///
  /// In en, this message translates to:
  /// **'Classic Soviet-school method'**
  String get mcClassicTag;

  /// No description provided for @mcClassicTitle.
  ///
  /// In en, this message translates to:
  /// **'Classic textbook intervals'**
  String get mcClassicTitle;

  /// No description provided for @mcClassicNote.
  ///
  /// In en, this message translates to:
  /// **'This is a reference interval, not a diagnostic cut-off. The interval on your laboratory’s form comes first; the result is not compared with it automatically.'**
  String get mcClassicNote;

  /// No description provided for @mfCells.
  ///
  /// In en, this message translates to:
  /// **'Cells counted'**
  String get mfCells;

  /// No description provided for @mfSquares.
  ///
  /// In en, this message translates to:
  /// **'Squares counted'**
  String get mfSquares;

  /// No description provided for @mfSquareArea.
  ///
  /// In en, this message translates to:
  /// **'Area of one square'**
  String get mfSquareArea;

  /// No description provided for @mfDepth.
  ///
  /// In en, this message translates to:
  /// **'Chamber depth'**
  String get mfDepth;

  /// No description provided for @mfDilution.
  ///
  /// In en, this message translates to:
  /// **'Dilution factor (20 for 1 in 20)'**
  String get mfDilution;

  /// No description provided for @mfWbc.
  ///
  /// In en, this message translates to:
  /// **'Leukocytes (WBC)'**
  String get mfWbc;

  /// No description provided for @mfSeg.
  ///
  /// In en, this message translates to:
  /// **'Segmented neutrophils'**
  String get mfSeg;

  /// No description provided for @mfBand.
  ///
  /// In en, this message translates to:
  /// **'Band neutrophils'**
  String get mfBand;

  /// No description provided for @mfEos.
  ///
  /// In en, this message translates to:
  /// **'Eosinophils'**
  String get mfEos;

  /// No description provided for @mfBaso.
  ///
  /// In en, this message translates to:
  /// **'Basophils'**
  String get mfBaso;

  /// No description provided for @mfLymph.
  ///
  /// In en, this message translates to:
  /// **'Lymphocytes'**
  String get mfLymph;

  /// No description provided for @mfMono.
  ///
  /// In en, this message translates to:
  /// **'Monocytes'**
  String get mfMono;

  /// No description provided for @mfOther.
  ///
  /// In en, this message translates to:
  /// **'Other cells'**
  String get mfOther;

  /// No description provided for @mfNrbc.
  ///
  /// In en, this message translates to:
  /// **'Nucleated RBCs per 100 leukocytes'**
  String get mfNrbc;

  /// No description provided for @mfReticCounted.
  ///
  /// In en, this message translates to:
  /// **'Reticulocytes counted'**
  String get mfReticCounted;

  /// No description provided for @mfRbcExamined.
  ///
  /// In en, this message translates to:
  /// **'Erythrocytes examined'**
  String get mfRbcExamined;

  /// No description provided for @mfHct.
  ///
  /// In en, this message translates to:
  /// **'Hematocrit (Hct)'**
  String get mfHct;

  /// No description provided for @mfRbc.
  ///
  /// In en, this message translates to:
  /// **'Erythrocytes (RBC)'**
  String get mfRbc;

  /// No description provided for @mfMaturation.
  ///
  /// In en, this message translates to:
  /// **'Maturation factor'**
  String get mfMaturation;

  /// No description provided for @mfMaturationAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get mfMaturationAuto;

  /// No description provided for @mfPfProtein.
  ///
  /// In en, this message translates to:
  /// **'Fluid: total protein'**
  String get mfPfProtein;

  /// No description provided for @mfSerumProtein.
  ///
  /// In en, this message translates to:
  /// **'Serum: total protein'**
  String get mfSerumProtein;

  /// No description provided for @mfPfLdh.
  ///
  /// In en, this message translates to:
  /// **'Fluid: LDH'**
  String get mfPfLdh;

  /// No description provided for @mfSerumLdh.
  ///
  /// In en, this message translates to:
  /// **'Serum: LDH'**
  String get mfSerumLdh;

  /// No description provided for @mfLdhUln.
  ///
  /// In en, this message translates to:
  /// **'Serum LDH upper limit of normal'**
  String get mfLdhUln;

  /// No description provided for @mfLeukoCounted.
  ///
  /// In en, this message translates to:
  /// **'Leukocytes (A, counted)'**
  String get mfLeukoCounted;

  /// No description provided for @mfEryCounted.
  ///
  /// In en, this message translates to:
  /// **'Erythrocytes (A, counted)'**
  String get mfEryCounted;

  /// No description provided for @mfCastsCounted.
  ///
  /// In en, this message translates to:
  /// **'Casts (A, counted)'**
  String get mfCastsCounted;

  /// No description provided for @mfUrineCentrifuged.
  ///
  /// In en, this message translates to:
  /// **'Urine centrifuged, ml'**
  String get mfUrineCentrifuged;

  /// No description provided for @mfCountedVolume.
  ///
  /// In en, this message translates to:
  /// **'Ruling counted'**
  String get mfCountedVolume;

  /// No description provided for @mfGoryaevWhole.
  ///
  /// In en, this message translates to:
  /// **'Goryaev, whole ruling — 0.9 µL'**
  String get mfGoryaevWhole;

  /// No description provided for @mfGoryaev100.
  ///
  /// In en, this message translates to:
  /// **'Goryaev, 100 large squares — 0.4 µL'**
  String get mfGoryaev100;

  /// No description provided for @mfFuchsWhole.
  ///
  /// In en, this message translates to:
  /// **'Fuchs–Rosenthal, whole ruling — 3.2 µL'**
  String get mfFuchsWhole;

  /// No description provided for @mfSediment.
  ///
  /// In en, this message translates to:
  /// **'Sediment left'**
  String get mfSediment;

  /// No description provided for @mfCollected.
  ///
  /// In en, this message translates to:
  /// **'Urine collected, ml'**
  String get mfCollected;

  /// No description provided for @mfCollectHours.
  ///
  /// In en, this message translates to:
  /// **'Collection time, h'**
  String get mfCollectHours;

  /// No description provided for @mfPortion.
  ///
  /// In en, this message translates to:
  /// **'Portion {n} ({time}), ml'**
  String mfPortion(int n, String time);

  /// No description provided for @mfPortionSg.
  ///
  /// In en, this message translates to:
  /// **'Portion {n}, specific gravity'**
  String mfPortionSg(int n);

  /// No description provided for @mfFluidIntake.
  ///
  /// In en, this message translates to:
  /// **'Fluid drunk in 24 h, ml'**
  String get mfFluidIntake;

  /// No description provided for @mfZimDay.
  ///
  /// In en, this message translates to:
  /// **'Daytime portions (1–4)'**
  String get mfZimDay;

  /// No description provided for @mfZimNight.
  ///
  /// In en, this message translates to:
  /// **'Night-time portions (5–8)'**
  String get mfZimNight;

  /// No description provided for @mfSameUnit.
  ///
  /// In en, this message translates to:
  /// **'Both values in a pair must use the same unit (e.g. both g/L, both U/L).'**
  String get mfSameUnit;

  /// No description provided for @mrCellsPerUl.
  ///
  /// In en, this message translates to:
  /// **'cells/µL'**
  String get mrCellsPerUl;

  /// No description provided for @mrVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume counted'**
  String get mrVolume;

  /// No description provided for @mrWbcUsed.
  ///
  /// In en, this message translates to:
  /// **'Corrected WBC'**
  String get mrWbcUsed;

  /// No description provided for @mrNrbc.
  ///
  /// In en, this message translates to:
  /// **'Nucleated RBCs'**
  String get mrNrbc;

  /// No description provided for @mrPercentSum.
  ///
  /// In en, this message translates to:
  /// **'Sum of percentages'**
  String get mrPercentSum;

  /// No description provided for @mrAbsolute.
  ///
  /// In en, this message translates to:
  /// **'Absolute counts'**
  String get mrAbsolute;

  /// No description provided for @mrNoCorrection.
  ///
  /// In en, this message translates to:
  /// **'No nucleated RBCs entered — WBC not corrected.'**
  String get mrNoCorrection;

  /// No description provided for @mrReticAbs.
  ///
  /// In en, this message translates to:
  /// **'Absolute count'**
  String get mrReticAbs;

  /// No description provided for @mrReticCorrected.
  ///
  /// In en, this message translates to:
  /// **'Corrected %'**
  String get mrReticCorrected;

  /// No description provided for @mrRpi.
  ///
  /// In en, this message translates to:
  /// **'Reticulocyte production index (RPI)'**
  String get mrRpi;

  /// No description provided for @mrMaturationAuto.
  ///
  /// In en, this message translates to:
  /// **'Factor {factor}: the table point nearest to Hct {hct}% (app rule).'**
  String mrMaturationAuto(String factor, String hct);

  /// No description provided for @mrMaturationChosen.
  ///
  /// In en, this message translates to:
  /// **'Factor {factor}: chosen by you.'**
  String mrMaturationChosen(String factor);

  /// No description provided for @mrNoRbc.
  ///
  /// In en, this message translates to:
  /// **'Enter the RBC for the absolute count.'**
  String get mrNoRbc;

  /// No description provided for @mrExudate.
  ///
  /// In en, this message translates to:
  /// **'Meets exudate criteria'**
  String get mrExudate;

  /// No description provided for @mrTransudate.
  ///
  /// In en, this message translates to:
  /// **'No criterion met — consistent with a transudate'**
  String get mrTransudate;

  /// No description provided for @mrIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Two criteria not met; enter the LDH upper limit for the third'**
  String get mrIncomplete;

  /// No description provided for @mrPerMlUrine.
  ///
  /// In en, this message translates to:
  /// **'per 1 ml of urine'**
  String get mrPerMlUrine;

  /// No description provided for @mrPerDay.
  ///
  /// In en, this message translates to:
  /// **'Per day'**
  String get mrPerDay;

  /// No description provided for @mrPerUlSediment.
  ///
  /// In en, this message translates to:
  /// **'per 1 µL of sediment: {value}'**
  String mrPerUlSediment(String value);

  /// No description provided for @mrPortion12.
  ///
  /// In en, this message translates to:
  /// **'12-minute urine to centrifuge'**
  String get mrPortion12;

  /// No description provided for @mrDiuresisTotal.
  ///
  /// In en, this message translates to:
  /// **'24-hour diuresis'**
  String get mrDiuresisTotal;

  /// No description provided for @mrDiuresisDay.
  ///
  /// In en, this message translates to:
  /// **'Daytime diuresis (1–4)'**
  String get mrDiuresisDay;

  /// No description provided for @mrDiuresisNight.
  ///
  /// In en, this message translates to:
  /// **'Night-time diuresis (5–8)'**
  String get mrDiuresisNight;

  /// No description provided for @mrDayNightRatio.
  ///
  /// In en, this message translates to:
  /// **'Day : night'**
  String get mrDayNightRatio;

  /// No description provided for @mrIntakePercent.
  ///
  /// In en, this message translates to:
  /// **'Of fluid drunk'**
  String get mrIntakePercent;

  /// No description provided for @mrSgRange.
  ///
  /// In en, this message translates to:
  /// **'Specific gravity: lowest – highest'**
  String get mrSgRange;

  /// No description provided for @mrSgAmplitude.
  ///
  /// In en, this message translates to:
  /// **'Specific-gravity amplitude'**
  String get mrSgAmplitude;

  /// No description provided for @mrNotGiven.
  ///
  /// In en, this message translates to:
  /// **'not entered'**
  String get mrNotGiven;

  /// No description provided for @mErrNoUrine.
  ///
  /// In en, this message translates to:
  /// **'At least one portion needs a volume and specific gravity.'**
  String get mErrNoUrine;

  /// No description provided for @mErrSediment.
  ///
  /// In en, this message translates to:
  /// **'The sediment volume must be less than the urine centrifuged.'**
  String get mErrSediment;

  /// No description provided for @mrProteinRatio.
  ///
  /// In en, this message translates to:
  /// **'Protein: fluid ÷ serum (> 0.5)'**
  String get mrProteinRatio;

  /// No description provided for @mrLdhRatio.
  ///
  /// In en, this message translates to:
  /// **'LDH: fluid ÷ serum (> 0.6)'**
  String get mrLdhRatio;

  /// No description provided for @mrLdhUln.
  ///
  /// In en, this message translates to:
  /// **'Fluid LDH ÷ upper limit (> 2/3)'**
  String get mrLdhUln;

  /// No description provided for @mrMet.
  ///
  /// In en, this message translates to:
  /// **'met'**
  String get mrMet;

  /// No description provided for @mrNotMet.
  ///
  /// In en, this message translates to:
  /// **'not met'**
  String get mrNotMet;

  /// No description provided for @mrNotAssessed.
  ///
  /// In en, this message translates to:
  /// **'not assessed'**
  String get mrNotAssessed;

  /// No description provided for @mErrSum.
  ///
  /// In en, this message translates to:
  /// **'Percentages add up to {sum} — they must total 100. Check the rows.'**
  String mErrSum(String sum);

  /// No description provided for @mErrReticGtExamined.
  ///
  /// In en, this message translates to:
  /// **'Reticulocytes cannot exceed the erythrocytes examined.'**
  String get mErrReticGtExamined;

  /// No description provided for @mErrWhole.
  ///
  /// In en, this message translates to:
  /// **'{field}: enter a whole number ({min}–{max}).'**
  String mErrWhole(String field, String min, String max);

  /// No description provided for @ciWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get ciWhatTitle;

  /// No description provided for @ciWhat.
  ///
  /// In en, this message translates to:
  /// **'The color index is a relative measure traditionally used in CIS laboratories: it rates the hemoglobin content of one red cell against a “normal” value. It is used to describe hypo-, normo- or hyperchromia.'**
  String get ciWhat;

  /// No description provided for @ciWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why the app does not calculate it'**
  String get ciWhyTitle;

  /// No description provided for @ciWhy.
  ///
  /// In en, this message translates to:
  /// **'We found no primary open source for its formula that we could verify. The app gives no numbers or formulas without a source.'**
  String get ciWhy;

  /// No description provided for @ciUseTitle.
  ///
  /// In en, this message translates to:
  /// **'What to use instead'**
  String get ciUseTitle;

  /// No description provided for @ciUse.
  ///
  /// In en, this message translates to:
  /// **'The hemoglobin in one red cell is expressed directly by the MCH (mean cell hemoglobin, pg), and its concentration in the cell by the MCHC. Hematology analyzers report both. Judge hypo-/hyperchromia by these and your laboratory’s reference intervals.'**
  String get ciUse;

  /// No description provided for @dilC1.
  ///
  /// In en, this message translates to:
  /// **'C₁ · Stock concentration'**
  String get dilC1;

  /// No description provided for @dilC2.
  ///
  /// In en, this message translates to:
  /// **'C₂ · Target concentration'**
  String get dilC2;

  /// No description provided for @dilV2.
  ///
  /// In en, this message translates to:
  /// **'V₂ · Final volume (mL)'**
  String get dilV2;

  /// No description provided for @dilNote.
  ///
  /// In en, this message translates to:
  /// **'Use the same units for C₁ and C₂. Simple dilution model: reactions, safety and volume changes are not modeled.'**
  String get dilNote;

  /// No description provided for @dilCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get dilCalculate;

  /// No description provided for @dilResult.
  ///
  /// In en, this message translates to:
  /// **'V₁ = {volume} mL'**
  String dilResult(String volume);

  /// No description provided for @dilResultBody.
  ///
  /// In en, this message translates to:
  /// **'Volume of stock solution. Bring the total final volume to V₂.'**
  String get dilResultBody;

  /// No description provided for @dilDiluent.
  ///
  /// In en, this message translates to:
  /// **'Diluent ≈ {volume} mL (assuming volumes add up)'**
  String dilDiluent(String volume);

  /// No description provided for @dilNoDilution.
  ///
  /// In en, this message translates to:
  /// **'C₂ equals C₁: no dilution is needed.'**
  String get dilNoDilution;

  /// No description provided for @dilErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number greater than zero in every field.'**
  String get dilErrorInvalid;

  /// No description provided for @dilErrorC2GtC1.
  ///
  /// In en, this message translates to:
  /// **'C₂ can’t exceed C₁: dilution can’t raise the concentration.'**
  String get dilErrorC2GtC1;

  /// No description provided for @dilErrorRange.
  ///
  /// In en, this message translates to:
  /// **'The values are outside the calculable range.'**
  String get dilErrorRange;

  /// No description provided for @ucTitle.
  ///
  /// In en, this message translates to:
  /// **'Unit conversion'**
  String get ucTitle;

  /// No description provided for @ucSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Each substance has its own factor — one shared mg/dL → mmol/L factor would be wrong.'**
  String get ucSubtitle;

  /// No description provided for @ucAnalyte.
  ///
  /// In en, this message translates to:
  /// **'Analyte'**
  String get ucAnalyte;

  /// No description provided for @ucValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get ucValue;

  /// No description provided for @ucSwap.
  ///
  /// In en, this message translates to:
  /// **'Swap units'**
  String get ucSwap;

  /// No description provided for @ucConvert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get ucConvert;

  /// No description provided for @ucNote.
  ///
  /// In en, this message translates to:
  /// **'Calculated from the molar mass {mass} g/mol. Laboratories may round differently; report the units your laboratory uses.'**
  String ucNote(String mass);

  /// No description provided for @ucNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'No verified molar mass for this analyte, so conversion is not offered.'**
  String get ucNotAvailable;

  /// No description provided for @ucErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a number of 0 or more.'**
  String get ucErrorInvalid;

  /// No description provided for @ucErrorRange.
  ///
  /// In en, this message translates to:
  /// **'The value is outside the calculable range.'**
  String get ucErrorRange;

  /// No description provided for @calcSectionClinical.
  ///
  /// In en, this message translates to:
  /// **'Clinical formulas'**
  String get calcSectionClinical;

  /// No description provided for @calcSectionLab.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get calcSectionLab;

  /// No description provided for @calcEgfr.
  ///
  /// In en, this message translates to:
  /// **'eGFR · CKD‑EPI 2021'**
  String get calcEgfr;

  /// No description provided for @calcEgfrSub.
  ///
  /// In en, this message translates to:
  /// **'Creatinine, age, sex'**
  String get calcEgfrSub;

  /// No description provided for @calcAcr.
  ///
  /// In en, this message translates to:
  /// **'Albumin/creatinine ratio'**
  String get calcAcr;

  /// No description provided for @calcAcrSub.
  ///
  /// In en, this message translates to:
  /// **'Urine ACR · KDIGO A category'**
  String get calcAcrSub;

  /// No description provided for @calcAnionGap.
  ///
  /// In en, this message translates to:
  /// **'Anion gap'**
  String get calcAnionGap;

  /// No description provided for @calcAnionGapSub.
  ///
  /// In en, this message translates to:
  /// **'Na, Cl, HCO₃ · K and albumin optional'**
  String get calcAnionGapSub;

  /// No description provided for @calcCalcium.
  ///
  /// In en, this message translates to:
  /// **'Corrected calcium'**
  String get calcCalcium;

  /// No description provided for @calcCalciumSub.
  ///
  /// In en, this message translates to:
  /// **'By albumin · Payne 1973'**
  String get calcCalciumSub;

  /// No description provided for @calcLdl.
  ///
  /// In en, this message translates to:
  /// **'LDL-C and non-HDL-C'**
  String get calcLdl;

  /// No description provided for @calcLdlSub.
  ///
  /// In en, this message translates to:
  /// **'Friedewald · Sampson'**
  String get calcLdlSub;

  /// No description provided for @calcOsmo.
  ///
  /// In en, this message translates to:
  /// **'Calculated osmolality'**
  String get calcOsmo;

  /// No description provided for @calcOsmoSub.
  ///
  /// In en, this message translates to:
  /// **'And osmolal gap'**
  String get calcOsmoSub;

  /// No description provided for @calcHba1c.
  ///
  /// In en, this message translates to:
  /// **'HbA1c units and eAG'**
  String get calcHba1c;

  /// No description provided for @calcHba1cSub.
  ///
  /// In en, this message translates to:
  /// **'NGSP ↔ IFCC · ADAG'**
  String get calcHba1cSub;

  /// No description provided for @calcFormulaTag.
  ///
  /// In en, this message translates to:
  /// **'Published formula'**
  String get calcFormulaTag;

  /// No description provided for @calcOptional.
  ///
  /// In en, this message translates to:
  /// **'optional'**
  String get calcOptional;

  /// Always-visible warning on the albumin-corrected calcium calculator.
  ///
  /// In en, this message translates to:
  /// **'Albumin-adjusted calcium often misclassifies calcium status, especially with low albumin or kidney impairment. Where available, measure ionized calcium — it is preferred.'**
  String get calcCalciumCaution;

  /// No description provided for @calcNotDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'A calculation aid for learning and checking. It does not diagnose: interpret the result with the clinical picture and your laboratory’s reference intervals.'**
  String get calcNotDiagnosis;

  /// No description provided for @calcUnitCheck.
  ///
  /// In en, this message translates to:
  /// **'{field}: {value} {unit} is unusual for this unit — check that the right unit is selected.'**
  String calcUnitCheck(String field, String value, String unit);

  /// No description provided for @calcInputs.
  ///
  /// In en, this message translates to:
  /// **'Entered: {list}'**
  String calcInputs(String list);

  /// No description provided for @calcNegativeCheck.
  ///
  /// In en, this message translates to:
  /// **'{name} is negative — check the entered values and units.'**
  String calcNegativeCheck(String name);

  /// No description provided for @calcUnitGroup.
  ///
  /// In en, this message translates to:
  /// **'{field} unit'**
  String calcUnitGroup(String field);

  /// No description provided for @calcFormula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get calcFormula;

  /// No description provided for @calcLimitations.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get calcLimitations;

  /// No description provided for @calcSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get calcSources;

  /// No description provided for @fieldCreatinine.
  ///
  /// In en, this message translates to:
  /// **'Serum creatinine'**
  String get fieldCreatinine;

  /// No description provided for @fieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age, years'**
  String get fieldAge;

  /// No description provided for @fieldSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get fieldSex;

  /// No description provided for @fieldSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium (Na⁺)'**
  String get fieldSodium;

  /// No description provided for @fieldChloride.
  ///
  /// In en, this message translates to:
  /// **'Chloride (Cl⁻)'**
  String get fieldChloride;

  /// No description provided for @fieldBicarbonate.
  ///
  /// In en, this message translates to:
  /// **'Bicarbonate (HCO₃⁻)'**
  String get fieldBicarbonate;

  /// No description provided for @fieldPotassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K⁺)'**
  String get fieldPotassium;

  /// No description provided for @fieldAlbumin.
  ///
  /// In en, this message translates to:
  /// **'Serum albumin'**
  String get fieldAlbumin;

  /// No description provided for @fieldNormalAlbumin.
  ///
  /// In en, this message translates to:
  /// **'Normal albumin used by your laboratory'**
  String get fieldNormalAlbumin;

  /// No description provided for @fieldCalcium.
  ///
  /// In en, this message translates to:
  /// **'Total serum calcium'**
  String get fieldCalcium;

  /// No description provided for @fieldTotalCholesterol.
  ///
  /// In en, this message translates to:
  /// **'Total cholesterol'**
  String get fieldTotalCholesterol;

  /// No description provided for @fieldHdl.
  ///
  /// In en, this message translates to:
  /// **'HDL cholesterol'**
  String get fieldHdl;

  /// No description provided for @fieldTriglycerides.
  ///
  /// In en, this message translates to:
  /// **'Triglycerides'**
  String get fieldTriglycerides;

  /// No description provided for @fieldGlucose.
  ///
  /// In en, this message translates to:
  /// **'Glucose'**
  String get fieldGlucose;

  /// No description provided for @fieldUrea.
  ///
  /// In en, this message translates to:
  /// **'Urea (or BUN)'**
  String get fieldUrea;

  /// No description provided for @fieldMeasuredOsmolality.
  ///
  /// In en, this message translates to:
  /// **'Measured osmolality'**
  String get fieldMeasuredOsmolality;

  /// No description provided for @fieldHba1c.
  ///
  /// In en, this message translates to:
  /// **'HbA1c'**
  String get fieldHba1c;

  /// No description provided for @fieldUrineAlbumin.
  ///
  /// In en, this message translates to:
  /// **'Urine albumin'**
  String get fieldUrineAlbumin;

  /// No description provided for @fieldUrineCreatinine.
  ///
  /// In en, this message translates to:
  /// **'Urine creatinine'**
  String get fieldUrineCreatinine;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get sexFemale;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get sexMale;

  /// No description provided for @resGfrCategory.
  ///
  /// In en, this message translates to:
  /// **'KDIGO GFR category {code}'**
  String resGfrCategory(String code);

  /// No description provided for @resAlbCategory.
  ///
  /// In en, this message translates to:
  /// **'KDIGO albuminuria category {code}'**
  String resAlbCategory(String code);

  /// No description provided for @resCategoryBasisSi.
  ///
  /// In en, this message translates to:
  /// **'Determined on the mg/mmol cut-offs.'**
  String get resCategoryBasisSi;

  /// No description provided for @resCategoryBasisConv.
  ///
  /// In en, this message translates to:
  /// **'Determined on the mg/g cut-offs.'**
  String get resCategoryBasisConv;

  /// No description provided for @resAnionGap.
  ///
  /// In en, this message translates to:
  /// **'Anion gap'**
  String get resAnionGap;

  /// No description provided for @resAnionGapK.
  ///
  /// In en, this message translates to:
  /// **'With potassium'**
  String get resAnionGapK;

  /// No description provided for @resAnionGapAlb.
  ///
  /// In en, this message translates to:
  /// **'Albumin-corrected (Figge)'**
  String get resAnionGapAlb;

  /// No description provided for @resCorrectedCa.
  ///
  /// In en, this message translates to:
  /// **'Corrected calcium (Payne)'**
  String get resCorrectedCa;

  /// No description provided for @resNonHdl.
  ///
  /// In en, this message translates to:
  /// **'Non-HDL cholesterol'**
  String get resNonHdl;

  /// No description provided for @resLdlFriedewald.
  ///
  /// In en, this message translates to:
  /// **'LDL-C · Friedewald'**
  String get resLdlFriedewald;

  /// No description provided for @resLdlSampson.
  ///
  /// In en, this message translates to:
  /// **'LDL-C · Sampson'**
  String get resLdlSampson;

  /// No description provided for @resOsmCalc.
  ///
  /// In en, this message translates to:
  /// **'Calculated osmolality'**
  String get resOsmCalc;

  /// No description provided for @resOsmGap.
  ///
  /// In en, this message translates to:
  /// **'Osmolal gap'**
  String get resOsmGap;

  /// No description provided for @resEag.
  ///
  /// In en, this message translates to:
  /// **'Estimated average glucose (eAG)'**
  String get resEag;

  /// No description provided for @errCalcMissing.
  ///
  /// In en, this message translates to:
  /// **'Enter a number: {field}.'**
  String errCalcMissing(String field);

  /// No description provided for @errCalcImplausible.
  ///
  /// In en, this message translates to:
  /// **'{field}: outside the range this calculator accepts ({min}–{max}{unit}). Check the value and the unit.'**
  String errCalcImplausible(String field, String min, String max, String unit);

  /// No description provided for @errEgfrAge.
  ///
  /// In en, this message translates to:
  /// **'The CKD-EPI 2021 equation was developed in participants aged 18 or older; it is not calculated for children.'**
  String get errEgfrAge;

  /// No description provided for @errFriedewaldTg.
  ///
  /// In en, this message translates to:
  /// **'Not calculated: Friedewald is not reliable when triglycerides exceed {limit}.'**
  String errFriedewaldTg(String limit);

  /// No description provided for @errSampsonTg.
  ///
  /// In en, this message translates to:
  /// **'Not calculated: the Sampson equation was validated for triglycerides up to {limit}.'**
  String errSampsonTg(String limit);

  /// No description provided for @errEagRange.
  ///
  /// In en, this message translates to:
  /// **'eAG not shown: the ADAG data cover HbA1c {range}.'**
  String errEagRange(String range);

  /// No description provided for @errHdlGeTc.
  ///
  /// In en, this message translates to:
  /// **'HDL cholesterol can’t be equal to or greater than total cholesterol.'**
  String get errHdlGeTc;

  /// No description provided for @errNotPositive.
  ///
  /// In en, this message translates to:
  /// **'Not calculated: the result is not positive — check the values.'**
  String get errNotPositive;

  /// No description provided for @errSexMissing.
  ///
  /// In en, this message translates to:
  /// **'Choose sex.'**
  String get errSexMissing;

  /// No description provided for @micTitle.
  ///
  /// In en, this message translates to:
  /// **'Microscopy atlas'**
  String get micTitle;

  /// No description provided for @micSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Urine, blood and parasites — licensed micrographs'**
  String get micSubtitle;

  /// No description provided for @micAtlasError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the atlas'**
  String get micAtlasError;

  /// No description provided for @micNotFound.
  ///
  /// In en, this message translates to:
  /// **'This image or section was not found'**
  String get micNotFound;

  /// No description provided for @micImagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 image} other{{count} images}}'**
  String micImagesCount(int count);

  /// No description provided for @micGapsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} still without an image'**
  String micGapsCount(int count);

  /// No description provided for @micResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Found: {count}'**
  String micResultsCount(int count);

  /// No description provided for @micSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search the atlas'**
  String get micSearchLabel;

  /// No description provided for @micSearchHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. neutrophil, oxalate, malaria'**
  String get micSearchHint;

  /// No description provided for @micNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get micNoResultsTitle;

  /// No description provided for @micNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another name or another language (uz, ru, en).'**
  String get micNoResultsBody;

  /// No description provided for @micSections.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get micSections;

  /// No description provided for @micEduNotice.
  ///
  /// In en, this message translates to:
  /// **'Teaching images — not for diagnosis. Every image shows its author, license and original caption.'**
  String get micEduNotice;

  /// No description provided for @micEduTag.
  ///
  /// In en, this message translates to:
  /// **'Teaching image — not for diagnosis'**
  String get micEduTag;

  /// No description provided for @micNoImageYet.
  ///
  /// In en, this message translates to:
  /// **'No licensed image yet'**
  String get micNoImageYet;

  /// No description provided for @micGapWhy.
  ///
  /// In en, this message translates to:
  /// **'Why not?'**
  String get micGapWhy;

  /// No description provided for @micAllGroups.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get micAllGroups;

  /// No description provided for @micSectionQuiz.
  ///
  /// In en, this message translates to:
  /// **'Practice this section'**
  String get micSectionQuiz;

  /// No description provided for @micZoom.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get micZoom;

  /// No description provided for @micOpenFull.
  ///
  /// In en, this message translates to:
  /// **'{name} — open full screen'**
  String micOpenFull(String name);

  /// No description provided for @micImageSemantics.
  ///
  /// In en, this message translates to:
  /// **'Micrograph: {name}'**
  String micImageSemantics(String name);

  /// No description provided for @micNames.
  ///
  /// In en, this message translates to:
  /// **'Name in three languages'**
  String get micNames;

  /// No description provided for @micOriginalCaption.
  ///
  /// In en, this message translates to:
  /// **'Original caption'**
  String get micOriginalCaption;

  /// No description provided for @micCaptionLang.
  ///
  /// In en, this message translates to:
  /// **'Verbatim, in the source language · {lang}'**
  String micCaptionLang(String lang);

  /// No description provided for @micTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation (LabGuide)'**
  String get micTranslation;

  /// No description provided for @micLangEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get micLangEn;

  /// No description provided for @micLangEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get micLangEs;

  /// No description provided for @micLangRu.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get micLangRu;

  /// No description provided for @micPreparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get micPreparation;

  /// No description provided for @micMagnification.
  ///
  /// In en, this message translates to:
  /// **'Magnification'**
  String get micMagnification;

  /// No description provided for @micStain.
  ///
  /// In en, this message translates to:
  /// **'Stain'**
  String get micStain;

  /// No description provided for @micNotStated.
  ///
  /// In en, this message translates to:
  /// **'not stated in the source'**
  String get micNotStated;

  /// No description provided for @micOnlySource.
  ///
  /// In en, this message translates to:
  /// **'Only what the source states is shown.'**
  String get micOnlySource;

  /// No description provided for @micDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'What to look for'**
  String get micDraftTitle;

  /// No description provided for @micCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'Author and license'**
  String get micCreditTitle;

  /// No description provided for @micAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get micAuthor;

  /// No description provided for @micAuthorPage.
  ///
  /// In en, this message translates to:
  /// **'Author page'**
  String get micAuthorPage;

  /// No description provided for @micLabelBySource.
  ///
  /// In en, this message translates to:
  /// **'Named per the source caption'**
  String get micLabelBySource;

  /// No description provided for @micLabelNoQuiz.
  ///
  /// In en, this message translates to:
  /// **'Not used in the quiz'**
  String get micLabelNoQuiz;

  /// No description provided for @micCredit.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get micCredit;

  /// No description provided for @micOwnWork.
  ///
  /// In en, this message translates to:
  /// **'Own work'**
  String get micOwnWork;

  /// No description provided for @micLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get micLicense;

  /// No description provided for @micSourceDate.
  ///
  /// In en, this message translates to:
  /// **'Date in the source'**
  String get micSourceDate;

  /// No description provided for @micLicenseText.
  ///
  /// In en, this message translates to:
  /// **'License text: {license}'**
  String micLicenseText(String license);

  /// No description provided for @micSourcePage.
  ///
  /// In en, this message translates to:
  /// **'Source page'**
  String get micSourcePage;

  /// No description provided for @micOriginalFile.
  ///
  /// In en, this message translates to:
  /// **'Original file'**
  String get micOriginalFile;

  /// No description provided for @micResized.
  ///
  /// In en, this message translates to:
  /// **'In-app copy: {width}×{height} px (original {origWidth}×{origHeight} px, downscaled only). Not cropped, no text added.'**
  String micResized(int width, int height, int origWidth, int origHeight);

  /// No description provided for @micNotResized.
  ///
  /// In en, this message translates to:
  /// **'In-app copy: {width}×{height} px, original size. Not cropped, no text added.'**
  String micNotResized(int width, int height);

  /// No description provided for @micShareAlike.
  ///
  /// In en, this message translates to:
  /// **'CC BY-SA: adapted versions of this image are shared under the same license.'**
  String get micShareAlike;

  /// No description provided for @micCdcTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use (from the CDC PHIL page, verbatim)'**
  String get micCdcTerms;

  /// No description provided for @micCdcFree.
  ///
  /// In en, this message translates to:
  /// **'Free source: CDC Public Health Image Library (PHIL), wwwn.cdc.gov/phil'**
  String get micCdcFree;

  /// No description provided for @micSameEntity.
  ///
  /// In en, this message translates to:
  /// **'More images of this type'**
  String get micSameEntity;

  /// No description provided for @micCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Image credits'**
  String get micCreditsTitle;

  /// No description provided for @micCreditsSub.
  ///
  /// In en, this message translates to:
  /// **'Licenses and sources'**
  String get micCreditsSub;

  /// No description provided for @micCreditsIntro.
  ///
  /// In en, this message translates to:
  /// **'Each image’s license, author and original caption were re-checked on the source page ({date}). Images are only downscaled: not cropped, no text added, EXIF removed. Only CC0, CC BY, CC BY-SA, public domain and CDC PHIL images are used.'**
  String micCreditsIntro(String date);

  /// No description provided for @micLicenseTexts.
  ///
  /// In en, this message translates to:
  /// **'License texts'**
  String get micLicenseTexts;

  /// No description provided for @micCreditsRow.
  ///
  /// In en, this message translates to:
  /// **'Authors and licenses'**
  String get micCreditsRow;

  /// No description provided for @micCreditsRowSub.
  ///
  /// In en, this message translates to:
  /// **'Source and terms of use for every image'**
  String get micCreditsRowSub;

  /// No description provided for @micClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get micClose;

  /// No description provided for @micZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get micZoomIn;

  /// No description provided for @micZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get micZoomOut;

  /// No description provided for @micZoomReset.
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get micZoomReset;

  /// No description provided for @micViewerHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch or double-tap to zoom'**
  String get micViewerHint;

  /// No description provided for @micHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get micHeroEyebrow;

  /// No description provided for @micQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'What is it?'**
  String get micQuizTitle;

  /// No description provided for @micQuizSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Microscopy practice'**
  String get micQuizSubtitle;

  /// No description provided for @micQuizHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Look at the image and pick the right name: 4 options, all from the atlas. Instant feedback.'**
  String get micQuizHeroBody;

  /// No description provided for @micQuizCta.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get micQuizCta;

  /// No description provided for @micQuizScope.
  ///
  /// In en, this message translates to:
  /// **'Which section?'**
  String get micQuizScope;

  /// No description provided for @micQuizScopeChip.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count}'**
  String micQuizScopeChip(String name, int count);

  /// No description provided for @micQuizStart.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Start · 1 question} other{Start · {count} questions}}'**
  String micQuizStart(int count);

  /// No description provided for @micQuizBest.
  ///
  /// In en, this message translates to:
  /// **'Best result: {correct}/{total}'**
  String micQuizBest(int correct, int total);

  /// No description provided for @micQuizNoBest.
  ///
  /// In en, this message translates to:
  /// **'No result yet — start your first round'**
  String get micQuizNoBest;

  /// No description provided for @micQuizRules.
  ///
  /// In en, this message translates to:
  /// **'Options come only from atlas names. Mixed fields and journal panels are left out. Results are stored only on this device.'**
  String get micQuizRules;

  /// No description provided for @micQuizProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String micQuizProgress(int current, int total);

  /// No description provided for @micQuizStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} in a row'**
  String micQuizStreak(int count);

  /// No description provided for @micQuizPromptArrow.
  ///
  /// In en, this message translates to:
  /// **'What is the cell marked by the arrowhead?'**
  String get micQuizPromptArrow;

  /// No description provided for @micQuizPromptCentre.
  ///
  /// In en, this message translates to:
  /// **'What is the cell in the center?'**
  String get micQuizPromptCentre;

  /// No description provided for @micQuizPromptField.
  ///
  /// In en, this message translates to:
  /// **'What is mainly shown in this field?'**
  String get micQuizPromptField;

  /// No description provided for @micQuizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get micQuizCorrect;

  /// No description provided for @micQuizWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Correct answer: {answer}'**
  String micQuizWrong(String answer);

  /// No description provided for @micQuizOpenCard.
  ///
  /// In en, this message translates to:
  /// **'Open the image card'**
  String get micQuizOpenCard;

  /// No description provided for @micQuizTapToZoom.
  ///
  /// In en, this message translates to:
  /// **'Tap the image to zoom'**
  String get micQuizTapToZoom;

  /// No description provided for @micQuizResultGreat.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get micQuizResultGreat;

  /// No description provided for @micQuizResultGood.
  ///
  /// In en, this message translates to:
  /// **'Good result'**
  String get micQuizResultGood;

  /// No description provided for @micQuizResultKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing'**
  String get micQuizResultKeep;

  /// No description provided for @micQuizScore.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String micQuizScore(int correct, int total);

  /// No description provided for @micQuizBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak: {count}'**
  String micQuizBestStreak(int count);

  /// No description provided for @micQuizNewRecord.
  ///
  /// In en, this message translates to:
  /// **'New record'**
  String get micQuizNewRecord;

  /// No description provided for @micQuizRetryMistakes.
  ///
  /// In en, this message translates to:
  /// **'Retry mistakes ({count})'**
  String micQuizRetryMistakes(int count);

  /// No description provided for @micQuizNewRound.
  ///
  /// In en, this message translates to:
  /// **'New round'**
  String get micQuizNewRound;

  /// No description provided for @micQuizChangeScope.
  ///
  /// In en, this message translates to:
  /// **'Another section'**
  String get micQuizChangeScope;

  /// No description provided for @micQuizBackToAtlas.
  ///
  /// In en, this message translates to:
  /// **'Back to the atlas'**
  String get micQuizBackToAtlas;

  /// No description provided for @insTitle.
  ///
  /// In en, this message translates to:
  /// **'Instruments'**
  String get insTitle;

  /// No description provided for @insMindraySub.
  ///
  /// In en, this message translates to:
  /// **'Exact model required'**
  String get insMindraySub;

  /// No description provided for @insHumanSub.
  ///
  /// In en, this message translates to:
  /// **'Instrument and reagent documents are separate'**
  String get insHumanSub;

  /// No description provided for @insOther.
  ///
  /// In en, this message translates to:
  /// **'Other manufacturer'**
  String get insOther;

  /// No description provided for @insOtherSub.
  ///
  /// In en, this message translates to:
  /// **'Match by exact model and IFU'**
  String get insOtherSub;

  /// No description provided for @instSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search instruments'**
  String get instSearchLabel;

  /// No description provided for @instSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Model or manufacturer'**
  String get instSearchHint;

  /// No description provided for @instNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No model found'**
  String get instNoResultsTitle;

  /// No description provided for @instNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'You can add an instrument that is not in the catalog with the button below.'**
  String get instNoResultsBody;

  /// No description provided for @instMine.
  ///
  /// In en, this message translates to:
  /// **'My instruments'**
  String get instMine;

  /// No description provided for @instDirections.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get instDirections;

  /// No description provided for @instModelsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 model} other{{count} models}}'**
  String instModelsCount(int count);

  /// No description provided for @instPlanned.
  ///
  /// In en, this message translates to:
  /// **'Next phase: {names}'**
  String instPlanned(String names);

  /// No description provided for @instPlannedBody.
  ///
  /// In en, this message translates to:
  /// **'Models from these manufacturers will be added once checked against official sources.'**
  String get instPlannedBody;

  /// No description provided for @instAddCustom.
  ///
  /// In en, this message translates to:
  /// **'Add an instrument not in the list'**
  String get instAddCustom;

  /// No description provided for @instAddCustomSub.
  ///
  /// In en, this message translates to:
  /// **'You enter the manufacturer and model yourself'**
  String get instAddCustomSub;

  /// No description provided for @instCustomTag.
  ///
  /// In en, this message translates to:
  /// **'Entered by you'**
  String get instCustomTag;

  /// No description provided for @instCatalogNote.
  ///
  /// In en, this message translates to:
  /// **'The catalog is compiled from manufacturers’ official pages and documents (as of {date}). Every fact shows its source.'**
  String instCatalogNote(String date);

  /// No description provided for @instChooseMaker.
  ///
  /// In en, this message translates to:
  /// **'Choose a manufacturer'**
  String get instChooseMaker;

  /// No description provided for @instChooseModel.
  ///
  /// In en, this message translates to:
  /// **'Choose a model'**
  String get instChooseModel;

  /// No description provided for @instStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Information status'**
  String get instStatusTitle;

  /// No description provided for @instStatusDevice.
  ///
  /// In en, this message translates to:
  /// **'Instrument information available'**
  String get instStatusDevice;

  /// No description provided for @instStatusDeviceSub.
  ///
  /// In en, this message translates to:
  /// **'From the official page, brochure or regulatory document'**
  String get instStatusDeviceSub;

  /// No description provided for @instStatusIfu.
  ///
  /// In en, this message translates to:
  /// **'Manual available'**
  String get instStatusIfu;

  /// No description provided for @instStatusIfuSub.
  ///
  /// In en, this message translates to:
  /// **'Checked against the official operator’s manual (with version)'**
  String get instStatusIfuSub;

  /// No description provided for @instStatusExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert reviewed'**
  String get instStatusExpert;

  /// No description provided for @instStatusExpertSub.
  ///
  /// In en, this message translates to:
  /// **'Reviewed by an independent laboratory specialist'**
  String get instStatusExpertSub;

  /// No description provided for @instStatusDone.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get instStatusDone;

  /// No description provided for @instStatusNotYet.
  ///
  /// In en, this message translates to:
  /// **'not yet'**
  String get instStatusNotYet;

  /// No description provided for @instPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get instPurpose;

  /// No description provided for @instPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Principle'**
  String get instPrinciple;

  /// No description provided for @instNotStated.
  ///
  /// In en, this message translates to:
  /// **'Not stated in the official source.'**
  String get instNotStated;

  /// No description provided for @instOfficialText.
  ///
  /// In en, this message translates to:
  /// **'Official wording'**
  String get instOfficialText;

  /// No description provided for @instKeyFacts.
  ///
  /// In en, this message translates to:
  /// **'Key facts'**
  String get instKeyFacts;

  /// No description provided for @instManual.
  ///
  /// In en, this message translates to:
  /// **'Operator’s manual'**
  String get instManual;

  /// No description provided for @instManualPublic.
  ///
  /// In en, this message translates to:
  /// **'Publicly available'**
  String get instManualPublic;

  /// No description provided for @instManualLogin.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get instManualLogin;

  /// No description provided for @instManualNotPublic.
  ///
  /// In en, this message translates to:
  /// **'Not publicly available'**
  String get instManualNotPublic;

  /// No description provided for @instDocsPortal.
  ///
  /// In en, this message translates to:
  /// **'Documents portal'**
  String get instDocsPortal;

  /// No description provided for @instLoginYes.
  ///
  /// In en, this message translates to:
  /// **'login required'**
  String get instLoginYes;

  /// No description provided for @instLoginNo.
  ///
  /// In en, this message translates to:
  /// **'no login'**
  String get instLoginNo;

  /// No description provided for @instLoginUnknown.
  ///
  /// In en, this message translates to:
  /// **'login not verified'**
  String get instLoginUnknown;

  /// No description provided for @instMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Daily maintenance'**
  String get instMaintenance;

  /// No description provided for @instMaintenanceNone.
  ///
  /// In en, this message translates to:
  /// **'The manufacturer does not publish daily maintenance steps openly. Follow the “Maintenance” section of your instrument’s operator’s manual — LabGuide does not guess the steps.'**
  String get instMaintenanceNone;

  /// No description provided for @instMaintenanceQuotes.
  ///
  /// In en, this message translates to:
  /// **'What the manufacturer states publicly:'**
  String get instMaintenanceQuotes;

  /// No description provided for @instReagentSystem.
  ///
  /// In en, this message translates to:
  /// **'Reagent system'**
  String get instReagentSystem;

  /// No description provided for @instReagentOpen.
  ///
  /// In en, this message translates to:
  /// **'Open — reagents from other manufacturers can be set up'**
  String get instReagentOpen;

  /// No description provided for @instReagentPartly.
  ///
  /// In en, this message translates to:
  /// **'Partly open — user-defined channels available'**
  String get instReagentPartly;

  /// No description provided for @instReagentClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed — system reagents only'**
  String get instReagentClosed;

  /// No description provided for @instReagentUnknown.
  ///
  /// In en, this message translates to:
  /// **'Openness not stated in the official source'**
  String get instReagentUnknown;

  /// No description provided for @instValidatedReagents.
  ///
  /// In en, this message translates to:
  /// **'Reagents with preinstalled settings (per official source): {count}'**
  String instValidatedReagents(int count);

  /// No description provided for @instImageNone.
  ///
  /// In en, this message translates to:
  /// **'No clearly licensed image found — we do not reuse manufacturer photos without permission.'**
  String get instImageNone;

  /// No description provided for @instImageCredit.
  ///
  /// In en, this message translates to:
  /// **'Image: {author} · {license}'**
  String instImageCredit(String author, String license);

  /// No description provided for @instIllustration.
  ///
  /// In en, this message translates to:
  /// **'Schematic illustration (drawn by LabGuide) — decorative, not the actual appearance of any instrument.'**
  String get instIllustration;

  /// No description provided for @instImageMissing.
  ///
  /// In en, this message translates to:
  /// **'Model image not available yet'**
  String get instImageMissing;

  /// No description provided for @instImageMissingSub.
  ///
  /// In en, this message translates to:
  /// **'No reusable image of this exact model was found. See its appearance on the manufacturer’s page.'**
  String get instImageMissingSub;

  /// No description provided for @instMakerSource.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer source'**
  String get instMakerSource;

  /// No description provided for @instImageTapToZoom.
  ///
  /// In en, this message translates to:
  /// **'Tap the photo to enlarge'**
  String get instImageTapToZoom;

  /// No description provided for @instImageRightsChecked.
  ///
  /// In en, this message translates to:
  /// **'Rights checked: {date}'**
  String instImageRightsChecked(String date);

  /// No description provided for @instImageSemantics.
  ///
  /// In en, this message translates to:
  /// **'Photo of {model}'**
  String instImageSemantics(String model);

  /// No description provided for @instSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get instSources;

  /// No description provided for @instAccessed.
  ///
  /// In en, this message translates to:
  /// **'accessed {date}'**
  String instAccessed(String date);

  /// No description provided for @instSaveMine.
  ///
  /// In en, this message translates to:
  /// **'Save as “My instrument”'**
  String get instSaveMine;

  /// No description provided for @instSavedCount.
  ///
  /// In en, this message translates to:
  /// **'In “My instruments”: {count}'**
  String instSavedCount(int count);

  /// No description provided for @instCalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibration'**
  String get instCalibrate;

  /// No description provided for @instQc.
  ///
  /// In en, this message translates to:
  /// **'Quality control (QC)'**
  String get instQc;

  /// No description provided for @instSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save instrument'**
  String get instSaveTitle;

  /// No description provided for @instLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get instLabel;

  /// No description provided for @instLabelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. room 1 or back-up'**
  String get instLabelHint;

  /// No description provided for @instSerial.
  ///
  /// In en, this message translates to:
  /// **'Serial number (optional)'**
  String get instSerial;

  /// No description provided for @instManualVersion.
  ///
  /// In en, this message translates to:
  /// **'Manual version (optional)'**
  String get instManualVersion;

  /// No description provided for @instManualVersionHint.
  ///
  /// In en, this message translates to:
  /// **'version or date on the manual cover'**
  String get instManualVersionHint;

  /// No description provided for @instSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get instSave;

  /// No description provided for @instSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get instSaved;

  /// No description provided for @instRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get instRemove;

  /// No description provided for @instRemoveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove this instrument? Calibration log entries are kept.'**
  String get instRemoveConfirm;

  /// No description provided for @instMaker.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get instMaker;

  /// No description provided for @instModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get instModel;

  /// No description provided for @instCategory.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get instCategory;

  /// No description provided for @instCustomRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the manufacturer and model.'**
  String get instCustomRequired;

  /// No description provided for @instCatalogError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the instrument catalog'**
  String get instCatalogError;

  /// No description provided for @instOpenCard.
  ///
  /// In en, this message translates to:
  /// **'Instrument card'**
  String get instOpenCard;

  /// No description provided for @partnerAdLabel.
  ///
  /// In en, this message translates to:
  /// **'Ad'**
  String get partnerAdLabel;

  /// No description provided for @partnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get partnerLabel;

  /// No description provided for @partnerOfficialTitle.
  ///
  /// In en, this message translates to:
  /// **'Official partners'**
  String get partnerOfficialTitle;

  /// No description provided for @partnerSectionNote.
  ///
  /// In en, this message translates to:
  /// **'Information provided by the partner companies. The catalog data above, its order and review status do not depend on partnerships.'**
  String get partnerSectionNote;

  /// No description provided for @partnerKindManufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get partnerKindManufacturer;

  /// No description provided for @partnerKindDistributor.
  ///
  /// In en, this message translates to:
  /// **'Official distributor'**
  String get partnerKindDistributor;

  /// No description provided for @partnerKindService.
  ///
  /// In en, this message translates to:
  /// **'Service center'**
  String get partnerKindService;

  /// No description provided for @partnerCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get partnerCall;

  /// No description provided for @partnerTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get partnerTelegram;

  /// No description provided for @partnerWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get partnerWebsite;

  /// No description provided for @partnerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get partnerEmail;

  /// No description provided for @partnerBrochure.
  ///
  /// In en, this message translates to:
  /// **'Brochure'**
  String get partnerBrochure;

  /// No description provided for @partnerMore.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get partnerMore;

  /// No description provided for @partnerRegions.
  ///
  /// In en, this message translates to:
  /// **'Regions: {regions}'**
  String partnerRegions(String regions);

  /// No description provided for @partnerRegistration.
  ///
  /// In en, this message translates to:
  /// **'Registration certificate in Uzbekistan: {number}'**
  String partnerRegistration(String number);

  /// No description provided for @partnerRegistrationNote.
  ///
  /// In en, this message translates to:
  /// **'Number provided by the partner.'**
  String get partnerRegistrationNote;

  /// No description provided for @partnerBecome.
  ///
  /// In en, this message translates to:
  /// **'Become a partner'**
  String get partnerBecome;

  /// No description provided for @partnerBecomeSub.
  ///
  /// In en, this message translates to:
  /// **'For companies: your instruments in LabGuide'**
  String get partnerBecomeSub;

  /// No description provided for @partnerNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Partner not found'**
  String get partnerNotFoundTitle;

  /// No description provided for @partnerNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The listing may have ended or been paused.'**
  String get partnerNotFoundBody;

  /// No description provided for @partnerContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get partnerContacts;

  /// No description provided for @partnerAbout.
  ///
  /// In en, this message translates to:
  /// **'About the company'**
  String get partnerAbout;

  /// No description provided for @partnerInstruments.
  ///
  /// In en, this message translates to:
  /// **'Related instruments'**
  String get partnerInstruments;

  /// No description provided for @partnerAllModels.
  ///
  /// In en, this message translates to:
  /// **'{maker}: all models'**
  String partnerAllModels(String maker);

  /// No description provided for @partnerPageNote.
  ///
  /// In en, this message translates to:
  /// **'This page is an advertisement. LabGuide does not endorse partner products; catalog data and review status do not depend on partnerships.'**
  String get partnerPageNote;

  /// No description provided for @partnerOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Your contacts, right on the instrument card'**
  String get partnerOfferTitle;

  /// No description provided for @partnerOfferBody.
  ///
  /// In en, this message translates to:
  /// **'A lab specialist reading about an instrument can call its official distributor or service center in one tap. For manufacturers, official distributors and service centers.'**
  String get partnerOfferBody;

  /// No description provided for @partnerWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get partnerWhatTitle;

  /// No description provided for @partnerWhatCard.
  ///
  /// In en, this message translates to:
  /// **'An “Official partners” section on the instrument card: logo, short description, regions, call and Telegram buttons.'**
  String get partnerWhatCard;

  /// No description provided for @partnerWhatCategory.
  ///
  /// In en, this message translates to:
  /// **'A compact “Partner” card inside the instrument category (e.g. Chemistry).'**
  String get partnerWhatCategory;

  /// No description provided for @partnerWhatLabHome.
  ///
  /// In en, this message translates to:
  /// **'One ad card on the Lab tab home, shown in rotation.'**
  String get partnerWhatLabHome;

  /// No description provided for @partnerWhatPage.
  ///
  /// In en, this message translates to:
  /// **'A partner page: related models, registration numbers, brochure.'**
  String get partnerWhatPage;

  /// No description provided for @partnerWhatReport.
  ///
  /// In en, this message translates to:
  /// **'A report: impressions and contact taps by day and placement (no personal data).'**
  String get partnerWhatReport;

  /// No description provided for @partnerAudienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get partnerAudienceTitle;

  /// No description provided for @partnerAudienceBody.
  ///
  /// In en, this message translates to:
  /// **'LabGuide serves laboratory specialists, doctors, students and teachers in Uzbek, Russian and English. We show user numbers and the role breakdown from server statistics during negotiation; we don’t quote estimates.'**
  String get partnerAudienceBody;

  /// No description provided for @partnerRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get partnerRulesTitle;

  /// No description provided for @partnerRule1.
  ///
  /// In en, this message translates to:
  /// **'Every placement carries a clear “Ad” or “Partner” label.'**
  String get partnerRule1;

  /// No description provided for @partnerRule2.
  ///
  /// In en, this message translates to:
  /// **'Catalog facts, their order and review status do not depend on partnerships and cannot be bought.'**
  String get partnerRule2;

  /// No description provided for @partnerRule3.
  ///
  /// In en, this message translates to:
  /// **'Medical device ads: the instrument must be registered in Uzbekistan; the certificate number is shown on the card.'**
  String get partnerRule3;

  /// No description provided for @partnerRule4.
  ///
  /// In en, this message translates to:
  /// **'Verifiable information only: unproven claims such as “the best” or “100% accurate” are not accepted.'**
  String get partnerRule4;

  /// No description provided for @partnerRule5.
  ///
  /// In en, this message translates to:
  /// **'Users’ personal data is never shared with partners.'**
  String get partnerRule5;

  /// No description provided for @partnerPriceTitle.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get partnerPriceTitle;

  /// No description provided for @partnerPriceBody.
  ///
  /// In en, this message translates to:
  /// **'Price is agreed individually, depending on placements, period and regions.'**
  String get partnerPriceBody;

  /// No description provided for @partnerHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get partnerHowTitle;

  /// No description provided for @partnerHow1.
  ///
  /// In en, this message translates to:
  /// **'Send an application using the form below.'**
  String get partnerHow1;

  /// No description provided for @partnerHow2.
  ///
  /// In en, this message translates to:
  /// **'We contact you and agree the terms.'**
  String get partnerHow2;

  /// No description provided for @partnerHow3.
  ///
  /// In en, this message translates to:
  /// **'You send the logo, description (uz/ru/en), contacts and registration numbers.'**
  String get partnerHow3;

  /// No description provided for @partnerHow4.
  ///
  /// In en, this message translates to:
  /// **'After review the listing goes live; we send reports regularly.'**
  String get partnerHow4;

  /// No description provided for @partnerFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get partnerFormTitle;

  /// No description provided for @partnerFormCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get partnerFormCompany;

  /// No description provided for @partnerFormContact.
  ///
  /// In en, this message translates to:
  /// **'Contact person'**
  String get partnerFormContact;

  /// No description provided for @partnerFormPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get partnerFormPhone;

  /// No description provided for @partnerFormEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get partnerFormEmail;

  /// No description provided for @partnerFormProducts.
  ///
  /// In en, this message translates to:
  /// **'Products (instruments, models)'**
  String get partnerFormProducts;

  /// No description provided for @partnerFormMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get partnerFormMessage;

  /// No description provided for @partnerFormHint.
  ///
  /// In en, this message translates to:
  /// **'A phone number or an email is required.'**
  String get partnerFormHint;

  /// No description provided for @partnerFormSend.
  ///
  /// In en, this message translates to:
  /// **'Send application'**
  String get partnerFormSend;

  /// No description provided for @partnerFormInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the company and contact person, and a valid phone or email.'**
  String get partnerFormInvalid;

  /// No description provided for @partnerSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Application sent'**
  String get partnerSentTitle;

  /// No description provided for @partnerSentBody.
  ///
  /// In en, this message translates to:
  /// **'The reply will appear on this page under “Your applications”. If needed, we will contact you by the phone or email you gave.'**
  String get partnerSentBody;

  /// No description provided for @partnerSendAnother.
  ///
  /// In en, this message translates to:
  /// **'Send another application'**
  String get partnerSendAnother;

  /// No description provided for @partnerFormSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email to send an application — the reply comes to that account.'**
  String get partnerFormSignIn;

  /// No description provided for @partnerFormUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Applications are not connected yet: this build has no server.'**
  String get partnerFormUnavailable;

  /// No description provided for @partnerMyRequests.
  ///
  /// In en, this message translates to:
  /// **'Your applications'**
  String get partnerMyRequests;

  /// No description provided for @partnerReqStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get partnerReqStatusNew;

  /// No description provided for @partnerReqStatusInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get partnerReqStatusInReview;

  /// No description provided for @partnerReqStatusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get partnerReqStatusAccepted;

  /// No description provided for @partnerReqStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get partnerReqStatusDeclined;

  /// No description provided for @partnerReqReply.
  ///
  /// In en, this message translates to:
  /// **'LabGuide reply: {text}'**
  String partnerReqReply(String text);

  /// No description provided for @partnerPlacementCard.
  ///
  /// In en, this message translates to:
  /// **'Instrument card'**
  String get partnerPlacementCard;

  /// No description provided for @partnerPlacementCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get partnerPlacementCategory;

  /// No description provided for @partnerPlacementLabHome.
  ///
  /// In en, this message translates to:
  /// **'Lab home'**
  String get partnerPlacementLabHome;

  /// No description provided for @partnerPlacementPage.
  ///
  /// In en, this message translates to:
  /// **'Partner page'**
  String get partnerPlacementPage;

  /// No description provided for @adminPartners.
  ///
  /// In en, this message translates to:
  /// **'Partners'**
  String get adminPartners;

  /// No description provided for @adminPartnersSub.
  ///
  /// In en, this message translates to:
  /// **'Ads: create, publish, statistics'**
  String get adminPartnersSub;

  /// No description provided for @adminPartnerRequests.
  ///
  /// In en, this message translates to:
  /// **'Partnership applications'**
  String get adminPartnerRequests;

  /// No description provided for @adminPartnerRequestsNew.
  ///
  /// In en, this message translates to:
  /// **'New applications: {count}'**
  String adminPartnerRequestsNew(int count);

  /// No description provided for @adminPartnerNew.
  ///
  /// In en, this message translates to:
  /// **'New partner'**
  String get adminPartnerNew;

  /// No description provided for @adminPartnersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No partners yet'**
  String get adminPartnersEmpty;

  /// No description provided for @adminPartnerStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get adminPartnerStatusDraft;

  /// No description provided for @adminPartnerStatusLive.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get adminPartnerStatusLive;

  /// No description provided for @adminPartnerStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get adminPartnerStatusPaused;

  /// No description provided for @adminPartnerExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get adminPartnerExpired;

  /// No description provided for @adminPartnerUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Not started yet'**
  String get adminPartnerUpcoming;

  /// No description provided for @adminPartnerName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get adminPartnerName;

  /// No description provided for @adminPartnerKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get adminPartnerKind;

  /// No description provided for @adminPartnerLogo.
  ///
  /// In en, this message translates to:
  /// **'Logo link (https://…)'**
  String get adminPartnerLogo;

  /// No description provided for @adminPartnerLogoUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload logo (PNG/JPEG, ≤ 1 MB)'**
  String get adminPartnerLogoUpload;

  /// No description provided for @adminPartnerLogoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The logo is larger than 1 MB or not PNG/JPEG.'**
  String get adminPartnerLogoTooLarge;

  /// No description provided for @adminPartnerSummary.
  ///
  /// In en, this message translates to:
  /// **'Short description ({lang})'**
  String adminPartnerSummary(String lang);

  /// No description provided for @adminPartnerRegions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get adminPartnerRegions;

  /// No description provided for @adminPartnerTelegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram (username)'**
  String get adminPartnerTelegram;

  /// No description provided for @adminPartnerWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website (https://…)'**
  String get adminPartnerWebsite;

  /// No description provided for @adminPartnerBrochure.
  ///
  /// In en, this message translates to:
  /// **'Brochure link (https://…)'**
  String get adminPartnerBrochure;

  /// No description provided for @adminPartnerLinks.
  ///
  /// In en, this message translates to:
  /// **'Catalog links'**
  String get adminPartnerLinks;

  /// No description provided for @adminPartnerMakers.
  ///
  /// In en, this message translates to:
  /// **'Manufacturers (all models)'**
  String get adminPartnerMakers;

  /// No description provided for @adminPartnerModels.
  ///
  /// In en, this message translates to:
  /// **'Models'**
  String get adminPartnerModels;

  /// No description provided for @adminPartnerAddModel.
  ///
  /// In en, this message translates to:
  /// **'Add a model'**
  String get adminPartnerAddModel;

  /// No description provided for @adminPartnerRegNo.
  ///
  /// In en, this message translates to:
  /// **'Certificate number (optional)'**
  String get adminPartnerRegNo;

  /// No description provided for @adminPartnerUnlink.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminPartnerUnlink;

  /// No description provided for @adminPartnerPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Active period'**
  String get adminPartnerPeriodTitle;

  /// No description provided for @adminPartnerStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get adminPartnerStarts;

  /// No description provided for @adminPartnerEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get adminPartnerEnds;

  /// No description provided for @adminPartnerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminPartnerSave;

  /// No description provided for @adminPartnerSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get adminPartnerSaved;

  /// No description provided for @adminPartnerPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get adminPartnerPublish;

  /// No description provided for @adminPartnerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get adminPartnerPause;

  /// No description provided for @adminPartnerPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get adminPartnerPublished;

  /// No description provided for @adminPartnerPausedMsg.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get adminPartnerPausedMsg;

  /// No description provided for @adminPartnerPublishRules.
  ///
  /// In en, this message translates to:
  /// **'To publish: a description, at least one contact and at least one link. The ad always carries an “Ad” label and never changes catalog data.'**
  String get adminPartnerPublishRules;

  /// No description provided for @adminPartnerInvalid.
  ///
  /// In en, this message translates to:
  /// **'Check the data: name (2–120 characters), phone, Telegram (5–32 characters), https links, email, dates; to publish — description, contact and a link.'**
  String get adminPartnerInvalid;

  /// No description provided for @adminPartnerStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get adminPartnerStats;

  /// No description provided for @adminStatsImpressions.
  ///
  /// In en, this message translates to:
  /// **'Impressions'**
  String get adminStatsImpressions;

  /// No description provided for @adminStatsContacts.
  ///
  /// In en, this message translates to:
  /// **'Contact taps'**
  String get adminStatsContacts;

  /// No description provided for @adminStatsCtr.
  ///
  /// In en, this message translates to:
  /// **'Click-through rate'**
  String get adminStatsCtr;

  /// No description provided for @adminStats7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get adminStats7;

  /// No description provided for @adminStats30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get adminStats30;

  /// No description provided for @adminStatsAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get adminStatsAll;

  /// No description provided for @adminStatsPeriods.
  ///
  /// In en, this message translates to:
  /// **'By period'**
  String get adminStatsPeriods;

  /// No description provided for @adminStatsByPlacement.
  ///
  /// In en, this message translates to:
  /// **'By placement (30 days)'**
  String get adminStatsByPlacement;

  /// No description provided for @adminStatsDaily.
  ///
  /// In en, this message translates to:
  /// **'By day'**
  String get adminStatsDaily;

  /// No description provided for @adminStatsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get adminStatsEmpty;

  /// No description provided for @adminStatsNote.
  ///
  /// In en, this message translates to:
  /// **'How it is counted: an impression means the partner block was drawn on screen; once per device per day per placement. Only signed-in users are counted (not guests or the admin). No personal data is stored, only daily counters (Tashkent time).'**
  String get adminStatsNote;

  /// No description provided for @adminStatsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy report'**
  String get adminStatsCopy;

  /// No description provided for @adminRequestsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No applications'**
  String get adminRequestsEmpty;

  /// No description provided for @adminRequestReply.
  ///
  /// In en, this message translates to:
  /// **'Reply (the applicant sees it)'**
  String get adminRequestReply;

  /// No description provided for @adminRequestSave.
  ///
  /// In en, this message translates to:
  /// **'Save status and reply'**
  String get adminRequestSave;

  /// No description provided for @adminActionPartnerCreated.
  ///
  /// In en, this message translates to:
  /// **'Partner created'**
  String get adminActionPartnerCreated;

  /// No description provided for @adminActionPartnerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Partner edited'**
  String get adminActionPartnerUpdated;

  /// No description provided for @adminActionPartnerPublished.
  ///
  /// In en, this message translates to:
  /// **'Partner published'**
  String get adminActionPartnerPublished;

  /// No description provided for @adminActionPartnerPaused.
  ///
  /// In en, this message translates to:
  /// **'Partner paused'**
  String get adminActionPartnerPaused;

  /// No description provided for @adminActionPartnerDraft.
  ///
  /// In en, this message translates to:
  /// **'Partner moved to draft'**
  String get adminActionPartnerDraft;

  /// No description provided for @adminActionPartnerRequest.
  ///
  /// In en, this message translates to:
  /// **'Partnership application handled'**
  String get adminActionPartnerRequest;

  /// No description provided for @calStepInstrument.
  ///
  /// In en, this message translates to:
  /// **'1. Instrument'**
  String get calStepInstrument;

  /// No description provided for @calStepAnalyte.
  ///
  /// In en, this message translates to:
  /// **'2. Analyte'**
  String get calStepAnalyte;

  /// No description provided for @calStepReagent.
  ///
  /// In en, this message translates to:
  /// **'3. Reagent'**
  String get calStepReagent;

  /// No description provided for @calChooseInstrument.
  ///
  /// In en, this message translates to:
  /// **'First choose the instrument: from saved ones or the catalog.'**
  String get calChooseInstrument;

  /// No description provided for @calChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get calChange;

  /// No description provided for @calFromCatalog.
  ///
  /// In en, this message translates to:
  /// **'Choose from catalog'**
  String get calFromCatalog;

  /// No description provided for @calAnalyteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. glucose'**
  String get calAnalyteHint;

  /// No description provided for @calReagentMaker.
  ///
  /// In en, this message translates to:
  /// **'Reagent manufacturer'**
  String get calReagentMaker;

  /// No description provided for @calReagentMakerName.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer name'**
  String get calReagentMakerName;

  /// No description provided for @calDifferentMaker.
  ///
  /// In en, this message translates to:
  /// **'The reagent manufacturer differs from the instrument’s. Check compatibility separately: the instrument list (applications) in the reagent IFU and the instrument’s reagent system.'**
  String get calDifferentMaker;

  /// No description provided for @calValidated.
  ///
  /// In en, this message translates to:
  /// **'Per the official source ({doc}), this instrument has preinstalled settings for:'**
  String calValidated(String doc);

  /// No description provided for @calRefListed.
  ///
  /// In en, this message translates to:
  /// **'The entered REF is in this list.'**
  String get calRefListed;

  /// No description provided for @calRefNotListed.
  ///
  /// In en, this message translates to:
  /// **'The entered REF is not in this list — re-check the reagent box and IFU.'**
  String get calRefNotListed;

  /// No description provided for @calShowGuide.
  ///
  /// In en, this message translates to:
  /// **'Show guide'**
  String get calShowGuide;

  /// No description provided for @calGuideNeeds.
  ///
  /// In en, this message translates to:
  /// **'Enter the instrument, analyte, reagent REF and IFU version. The lot is not needed at this step.'**
  String get calGuideNeeds;

  /// No description provided for @calGuideFound.
  ///
  /// In en, this message translates to:
  /// **'Verified guide found'**
  String get calGuideFound;

  /// No description provided for @calGuideNoneTitle.
  ///
  /// In en, this message translates to:
  /// **'No verified guide yet'**
  String get calGuideNoneTitle;

  /// No description provided for @calGuideNoneBody.
  ///
  /// In en, this message translates to:
  /// **'LabGuide has no checked record for this instrument + reagent REF + IFU version. We do not guess parameters — take them from these documents:'**
  String get calGuideNoneBody;

  /// No description provided for @calGuide1.
  ///
  /// In en, this message translates to:
  /// **'Calibrator name and REF — in the “Calibration” section of the reagent IFU.'**
  String get calGuide1;

  /// No description provided for @calGuide2.
  ///
  /// In en, this message translates to:
  /// **'Number of calibration points and method — in the same section.'**
  String get calGuide2;

  /// No description provided for @calGuide3.
  ///
  /// In en, this message translates to:
  /// **'Assigned values for each lot — on the calibrator value sheet (the lot number must match).'**
  String get calGuide3;

  /// No description provided for @calGuide4.
  ///
  /// In en, this message translates to:
  /// **'When to recalibrate (new lot, QC failure, interval) — in the IFU.'**
  String get calGuide4;

  /// No description provided for @calGuide5.
  ///
  /// In en, this message translates to:
  /// **'After calibrating, run QC and record the result.'**
  String get calGuide5;

  /// No description provided for @calDocsWhere.
  ///
  /// In en, this message translates to:
  /// **'Where to find the documents'**
  String get calDocsWhere;

  /// No description provided for @calRecordCreate.
  ///
  /// In en, this message translates to:
  /// **'Create a calibration record'**
  String get calRecordCreate;

  /// No description provided for @calRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibration record'**
  String get calRecordTitle;

  /// No description provided for @calCalibratorName.
  ///
  /// In en, this message translates to:
  /// **'Calibrator name or REF (optional)'**
  String get calCalibratorName;

  /// No description provided for @calLotExpiry.
  ///
  /// In en, this message translates to:
  /// **'Lot expiry (optional)'**
  String get calLotExpiry;

  /// No description provided for @calLevels.
  ///
  /// In en, this message translates to:
  /// **'Calibrator levels'**
  String get calLevels;

  /// No description provided for @calLevelName.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get calLevelName;

  /// No description provided for @calLevelValue.
  ///
  /// In en, this message translates to:
  /// **'Assigned value'**
  String get calLevelValue;

  /// No description provided for @calLevelUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get calLevelUnit;

  /// No description provided for @calAddLevel.
  ///
  /// In en, this message translates to:
  /// **'Add level'**
  String get calAddLevel;

  /// No description provided for @calRemoveLevel.
  ///
  /// In en, this message translates to:
  /// **'Remove level'**
  String get calRemoveLevel;

  /// No description provided for @calValuesFromSheet.
  ///
  /// In en, this message translates to:
  /// **'Copy the values from the value sheet of this exact lot. LabGuide does not guess or check them.'**
  String get calValuesFromSheet;

  /// No description provided for @calPerformedOn.
  ///
  /// In en, this message translates to:
  /// **'Date performed'**
  String get calPerformedOn;

  /// No description provided for @calOutcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get calOutcome;

  /// No description provided for @calOutcomeAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get calOutcomeAccepted;

  /// No description provided for @calOutcomeRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get calOutcomeRejected;

  /// No description provided for @calOutcomePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get calOutcomePending;

  /// No description provided for @calNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get calNote;

  /// No description provided for @calRecordSave.
  ///
  /// In en, this message translates to:
  /// **'Save record'**
  String get calRecordSave;

  /// No description provided for @calRecordSaved.
  ///
  /// In en, this message translates to:
  /// **'Calibration record saved'**
  String get calRecordSaved;

  /// No description provided for @calLotRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the calibrator lot.'**
  String get calLotRequired;

  /// No description provided for @calLevelInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a name, a numeric value and a unit for each level.'**
  String get calLevelInvalid;

  /// Shown when an instrument or calibration record could not be saved (storage error).
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save. Please try again.'**
  String get instSaveFailed;

  /// No description provided for @calLog.
  ///
  /// In en, this message translates to:
  /// **'Calibration log'**
  String get calLog;

  /// No description provided for @calLogSub.
  ///
  /// In en, this message translates to:
  /// **'Lot, values and outcome — on this device'**
  String get calLogSub;

  /// No description provided for @calLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get calLogEmpty;

  /// No description provided for @calLogEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a record after calibrating — lot, values and outcome are kept here.'**
  String get calLogEmptyBody;

  /// No description provided for @calDeleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get calDeleteRecord;

  /// No description provided for @calDeleteRecordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this calibration record?'**
  String get calDeleteRecordConfirm;

  /// No description provided for @calUserEntered.
  ///
  /// In en, this message translates to:
  /// **'Values entered by the user.'**
  String get calUserEntered;

  /// No description provided for @calDetailInstrument.
  ///
  /// In en, this message translates to:
  /// **'Instrument'**
  String get calDetailInstrument;

  /// No description provided for @calDetailManual.
  ///
  /// In en, this message translates to:
  /// **'Manual version'**
  String get calDetailManual;

  /// No description provided for @calDetailCalibrator.
  ///
  /// In en, this message translates to:
  /// **'Calibrator'**
  String get calDetailCalibrator;

  /// No description provided for @calDetailLotExpiry.
  ///
  /// In en, this message translates to:
  /// **'Lot expiry'**
  String get calDetailLotExpiry;

  /// No description provided for @calLot.
  ///
  /// In en, this message translates to:
  /// **'Lot'**
  String get calLot;

  /// No description provided for @calAnalyteSelected.
  ///
  /// In en, this message translates to:
  /// **'Analyte: {name}'**
  String calAnalyteSelected(String name);

  /// No description provided for @libTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libTitle;

  /// No description provided for @libSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your knowledge in one place.'**
  String get libSubtitle;

  /// No description provided for @libBooks.
  ///
  /// In en, this message translates to:
  /// **'Books and guides'**
  String get libBooks;

  /// No description provided for @libBooksSub.
  ///
  /// In en, this message translates to:
  /// **'Catalog of books, manuals and websites'**
  String get libBooksSub;

  /// No description provided for @libPacks.
  ///
  /// In en, this message translates to:
  /// **'Offline packs'**
  String get libPacks;

  /// No description provided for @libPacksSub.
  ///
  /// In en, this message translates to:
  /// **'Installed and upcoming packs'**
  String get libPacksSub;

  /// No description provided for @libSavedSub.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked tests'**
  String get libSavedSub;

  /// No description provided for @libResearchSub.
  ///
  /// In en, this message translates to:
  /// **'Question, plan, real data and sources'**
  String get libResearchSub;

  /// No description provided for @libSources.
  ///
  /// In en, this message translates to:
  /// **'Sources and licenses'**
  String get libSources;

  /// No description provided for @libSourcesSub.
  ///
  /// In en, this message translates to:
  /// **'Review and reuse conditions'**
  String get libSourcesSub;

  /// No description provided for @booksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No books yet'**
  String get booksEmptyTitle;

  /// No description provided for @booksEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Books are added only with confirmed distribution rights. A PDF you add yourself stays for personal study and isn’t shared.'**
  String get booksEmptyBody;

  /// No description provided for @booksCatalogNote.
  ///
  /// In en, this message translates to:
  /// **'Catalog items link to their official pages. Full text is added to the app only under an open license or with confirmed distribution rights.'**
  String get booksCatalogNote;

  /// No description provided for @booksResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get booksResetFilters;

  /// No description provided for @packsInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get packsInstalled;

  /// No description provided for @packsCoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Core content'**
  String get packsCoreTitle;

  /// No description provided for @packsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String packsVersion(String version);

  /// No description provided for @packsSize.
  ///
  /// In en, this message translates to:
  /// **'Size: {size}'**
  String packsSize(String size);

  /// No description provided for @packsLanguages.
  ///
  /// In en, this message translates to:
  /// **'Languages: {languages}'**
  String packsLanguages(String languages);

  /// No description provided for @packsLicence.
  ///
  /// In en, this message translates to:
  /// **'License: {licence}'**
  String packsLicence(String licence);

  /// No description provided for @packsVerified.
  ///
  /// In en, this message translates to:
  /// **'Integrity verified (SHA-256)'**
  String get packsVerified;

  /// No description provided for @packsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming packs'**
  String get packsUpcoming;

  /// No description provided for @packsUpcomingBody.
  ///
  /// In en, this message translates to:
  /// **'The size is shown before any download. Packs are published only after content review.'**
  String get packsUpcomingBody;

  /// No description provided for @packsBiochem.
  ///
  /// In en, this message translates to:
  /// **'Biochemistry essentials'**
  String get packsBiochem;

  /// No description provided for @packsSpecimensQc.
  ///
  /// In en, this message translates to:
  /// **'Specimens and QC'**
  String get packsSpecimensQc;

  /// No description provided for @packsMicroscopy.
  ///
  /// In en, this message translates to:
  /// **'Microscopy atlas'**
  String get packsMicroscopy;

  /// No description provided for @packsNotPublished.
  ///
  /// In en, this message translates to:
  /// **'Not published yet'**
  String get packsNotPublished;

  /// No description provided for @packsBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built into the app'**
  String get packsBuiltIn;

  /// No description provided for @packsOffline.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get packsOffline;

  /// No description provided for @packsContents.
  ///
  /// In en, this message translates to:
  /// **'Contents: {cards, plural, =1{1 card} other{{cards} cards}}, {questions, plural, =1{1 question} other{{questions} questions}}, {sources, plural, =1{1 source} other{{sources} sources}}'**
  String packsContents(int cards, int questions, int sources);

  /// No description provided for @packsDownloadable.
  ///
  /// In en, this message translates to:
  /// **'Packs to download'**
  String get packsDownloadable;

  /// No description provided for @packsCatalogLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading catalog…'**
  String get packsCatalogLoading;

  /// No description provided for @packsCatalogCached.
  ///
  /// In en, this message translates to:
  /// **'Showing the last saved catalog'**
  String get packsCatalogCached;

  /// No description provided for @packsCatalogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No packs to download yet'**
  String get packsCatalogEmpty;

  /// No description provided for @packsStatusTest.
  ///
  /// In en, this message translates to:
  /// **'Test pack · not a clinical pack'**
  String get packsStatusTest;

  /// No description provided for @packsStatusReviewed.
  ///
  /// In en, this message translates to:
  /// **'Expert-reviewed'**
  String get packsStatusReviewed;

  /// No description provided for @packsMeta.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · {size} · {languages}'**
  String packsMeta(String version, String size, String languages);

  /// No description provided for @packsDownload.
  ///
  /// In en, this message translates to:
  /// **'Download · {size}'**
  String packsDownload(String size);

  /// No description provided for @packsDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}%'**
  String packsDownloading(int percent);

  /// No description provided for @packsInstalledVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed: {version} · {size}'**
  String packsInstalledVersion(String version, String size);

  /// No description provided for @packsUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update to {version}'**
  String packsUpdate(String version);

  /// No description provided for @packsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get packsRemove;

  /// No description provided for @packsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this pack?'**
  String get packsRemoveTitle;

  /// No description provided for @packsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'The pack is removed from this device. You can download it again later.'**
  String get packsRemoveBody;

  /// No description provided for @packsFailNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t connect to the internet. Check your connection and try again.'**
  String get packsFailNetwork;

  /// No description provided for @packsFailServer.
  ///
  /// In en, this message translates to:
  /// **'The server didn’t respond. Try again later.'**
  String get packsFailServer;

  /// No description provided for @packsFailIntegrity.
  ///
  /// In en, this message translates to:
  /// **'The pack failed verification (size or SHA-256 mismatch) and wasn’t installed. Nothing else changed.'**
  String get packsFailIntegrity;

  /// No description provided for @packsFailIncompatible.
  ///
  /// In en, this message translates to:
  /// **'This pack needs a newer version of the app.'**
  String get packsFailIncompatible;

  /// No description provided for @packsFailStorage.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t save to this device. Check free storage.'**
  String get packsFailStorage;

  /// No description provided for @packsPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get packsPlanned;

  /// No description provided for @packsPlannedBody.
  ///
  /// In en, this message translates to:
  /// **'Published after independent review; the size is shown before download.'**
  String get packsPlannedBody;

  /// No description provided for @savedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get savedEmptyTitle;

  /// No description provided for @savedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Select Save on a test card to keep it here.'**
  String get savedEmptyBody;

  /// No description provided for @sourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources and licenses'**
  String get sourcesTitle;

  /// No description provided for @sourcesContent.
  ///
  /// In en, this message translates to:
  /// **'Analyte cards'**
  String get sourcesContent;

  /// No description provided for @sourcesMethods.
  ///
  /// In en, this message translates to:
  /// **'Calculators, QC and preanalytics'**
  String get sourcesMethods;

  /// No description provided for @sourcesBody.
  ///
  /// In en, this message translates to:
  /// **'Every published claim links to its original source, access date, scope and review status.'**
  String get sourcesBody;

  /// No description provided for @researchTitle.
  ///
  /// In en, this message translates to:
  /// **'Research workspace'**
  String get researchTitle;

  /// No description provided for @researchQuestion.
  ///
  /// In en, this message translates to:
  /// **'Topic or research question'**
  String get researchQuestion;

  /// No description provided for @researchQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a topic'**
  String get researchQuestionHint;

  /// No description provided for @researchNotes.
  ///
  /// In en, this message translates to:
  /// **'Aim and notes'**
  String get researchNotes;

  /// No description provided for @researchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Your own data and sources'**
  String get researchNotesHint;

  /// No description provided for @researchSave.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get researchSave;

  /// No description provided for @researchSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved on this device'**
  String get researchSaved;

  /// No description provided for @researchAutosave.
  ///
  /// In en, this message translates to:
  /// **'The draft saves automatically on this device as you type.'**
  String get researchAutosave;

  /// No description provided for @researchOutline.
  ///
  /// In en, this message translates to:
  /// **'Outline structure'**
  String get researchOutline;

  /// No description provided for @researchStep1.
  ///
  /// In en, this message translates to:
  /// **'Question and aim'**
  String get researchStep1;

  /// No description provided for @researchStep2.
  ///
  /// In en, this message translates to:
  /// **'Literature review'**
  String get researchStep2;

  /// No description provided for @researchStep3.
  ///
  /// In en, this message translates to:
  /// **'Methods and real data'**
  String get researchStep3;

  /// No description provided for @researchStep4.
  ///
  /// In en, this message translates to:
  /// **'Results, limitations and conclusions'**
  String get researchStep4;

  /// No description provided for @researchNoFabrication.
  ///
  /// In en, this message translates to:
  /// **'LabGuide never generates results, patient data or citations. Use only your own data and sources.'**
  String get researchNoFabrication;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn with insight'**
  String get learnTitle;

  /// No description provided for @learnHeroTag.
  ///
  /// In en, this message translates to:
  /// **'Topics and practice'**
  String get learnHeroTag;

  /// No description provided for @learnHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'From molecule to practice'**
  String get learnHeroTitle;

  /// No description provided for @learnHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a topic and check your knowledge with questions.'**
  String get learnHeroBody;

  /// No description provided for @learnHeroCta.
  ///
  /// In en, this message translates to:
  /// **'Choose a topic'**
  String get learnHeroCta;

  /// No description provided for @learnClassesSub.
  ///
  /// In en, this message translates to:
  /// **'Teacher → assignment → student → results'**
  String get learnClassesSub;

  /// No description provided for @learnQuiz.
  ///
  /// In en, this message translates to:
  /// **'Explained quiz'**
  String get learnQuiz;

  /// No description provided for @learnQuizSub.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} practice question} other{{count} practice questions}}'**
  String learnQuizSub(int count);

  /// No description provided for @learnExam.
  ///
  /// In en, this message translates to:
  /// **'Exam mode'**
  String get learnExam;

  /// No description provided for @learnExamSub.
  ///
  /// In en, this message translates to:
  /// **'Time, topic and questions'**
  String get learnExamSub;

  /// No description provided for @toifaTopic.
  ///
  /// In en, this message translates to:
  /// **'{topic, select, safety_ethics{Safety and ethics} qc_lab_management{Quality control and management} preanalytics{Preanalytics} hematology_cells{Blood cells} hemopoiesis_leukemia{Hematopoiesis and leukemia} anemias{Anaemias} hemostasis{Haemostasis} biochemistry_proteins_enzymes{Proteins and enzymes} carbohydrates_diabetes{Carbohydrates and diabetes} lipids{Lipids} liver_pigments{Liver and pigments} kidney_nitrogen{Kidney and nitrogen metabolism} water_electrolytes_acid_base{Water, electrolytes and acid–base} minerals_vitamins{Minerals and vitamins} hormones{Hormones} urinalysis{Urinalysis} stool_coprology{Stool examination} csf_body_fluids{CSF and body fluids} sputum_tb{Sputum and tuberculosis} cytology_gyn{Cytology} std_microscopy{STI microscopy} parasitology{Parasitology} immunology_serology{Immunology and serology} molecular_pcr{Molecular diagnostics (PCR)} tumor_markers{Tumor markers} cardiac_markers{Cardiac markers} orphan_screening{Screening and rare diseases} other{Other topics}}'**
  String toifaTopic(String topic);

  /// No description provided for @toifaTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge & Skills Assessment'**
  String get toifaTitle;

  /// No description provided for @toifaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clinical laboratory diagnostics (CLD)'**
  String get toifaSubtitle;

  /// No description provided for @toifaEyebrow.
  ///
  /// In en, this message translates to:
  /// **'CLD · knowledge and skills'**
  String get toifaEyebrow;

  /// No description provided for @toifaEntryBody.
  ///
  /// In en, this message translates to:
  /// **'Questions from the official list: a 50-question test, topic practice, oral ticket and mistake review.'**
  String get toifaEntryBody;

  /// No description provided for @toifaEntryBodyShort.
  ///
  /// In en, this message translates to:
  /// **'Test, oral ticket and mistake review — based on the official list.'**
  String get toifaEntryBodyShort;

  /// No description provided for @toifaEntryTagTest.
  ///
  /// In en, this message translates to:
  /// **'Test · 50 questions'**
  String get toifaEntryTagTest;

  /// No description provided for @toifaEntryTagOral.
  ///
  /// In en, this message translates to:
  /// **'Oral · 5 questions'**
  String get toifaEntryTagOral;

  /// No description provided for @toifaEntryTestActive.
  ///
  /// In en, this message translates to:
  /// **'Test in progress: {done} / {total} answered'**
  String toifaEntryTestActive(int done, int total);

  /// No description provided for @toifaEntryTicketActive.
  ///
  /// In en, this message translates to:
  /// **'Oral ticket in progress: {done} / {total}'**
  String toifaEntryTicketActive(int done, int total);

  /// No description provided for @toifaOpen.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get toifaOpen;

  /// No description provided for @toifaContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get toifaContinue;

  /// No description provided for @toifaUzbekOnly.
  ///
  /// In en, this message translates to:
  /// **'Official text — Uzbek'**
  String get toifaUzbekOnly;

  /// No description provided for @toifaUzbekNotice.
  ///
  /// In en, this message translates to:
  /// **'The official text of the certification questions is Uzbek. With a Russian or English interface an auxiliary translation is shown; the original can be opened at any time. Scoring follows the official Uzbek text and key.'**
  String get toifaUzbekNotice;

  /// No description provided for @toifaShowOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show original text'**
  String get toifaShowOriginal;

  /// No description provided for @toifaHideOriginal.
  ///
  /// In en, this message translates to:
  /// **'Hide original text'**
  String get toifaHideOriginal;

  /// No description provided for @toifaOriginalTitle.
  ///
  /// In en, this message translates to:
  /// **'Official text (Uzbek)'**
  String get toifaOriginalTitle;

  /// No description provided for @toifaTranslationAux.
  ///
  /// In en, this message translates to:
  /// **'The translation is auxiliary; scoring follows the official Uzbek text.'**
  String get toifaTranslationAux;

  /// No description provided for @toifaLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not open the question bank'**
  String get toifaLoadError;

  /// No description provided for @toifaYourCategory.
  ///
  /// In en, this message translates to:
  /// **'Your category'**
  String get toifaYourCategory;

  /// No description provided for @toifaCatSecond.
  ///
  /// In en, this message translates to:
  /// **'Category 3–2'**
  String get toifaCatSecond;

  /// No description provided for @toifaCatFirst.
  ///
  /// In en, this message translates to:
  /// **'First category'**
  String get toifaCatFirst;

  /// No description provided for @toifaCatHighest.
  ///
  /// In en, this message translates to:
  /// **'Highest category'**
  String get toifaCatHighest;

  /// No description provided for @toifaCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'The oral ticket is drawn from this category’s list. Test questions are shared by all categories.'**
  String get toifaCategoryHint;

  /// No description provided for @toifaReadyTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get toifaReadyTest;

  /// No description provided for @toifaReadyOral.
  ///
  /// In en, this message translates to:
  /// **'Oral'**
  String get toifaReadyOral;

  /// No description provided for @toifaPrepare.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get toifaPrepare;

  /// No description provided for @toifaTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Knowledge test'**
  String get toifaTestTitle;

  /// No description provided for @toifaTestRowSub.
  ///
  /// In en, this message translates to:
  /// **'{count} random questions · {bank} in the bank'**
  String toifaTestRowSub(int count, int bank);

  /// No description provided for @toifaPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic practice'**
  String get toifaPracticeTitle;

  /// No description provided for @toifaPracticeRowSub.
  ///
  /// In en, this message translates to:
  /// **'{count} topics · key and note right after answering'**
  String toifaPracticeRowSub(int count);

  /// No description provided for @toifaOralTitle.
  ///
  /// In en, this message translates to:
  /// **'Oral ticket'**
  String get toifaOralTitle;

  /// No description provided for @toifaOralRowSub.
  ///
  /// In en, this message translates to:
  /// **'{category}: 5 of {count} questions'**
  String toifaOralRowSub(String category, int count);

  /// No description provided for @toifaOralRowPick.
  ///
  /// In en, this message translates to:
  /// **'Choose your category first'**
  String get toifaOralRowPick;

  /// No description provided for @toifaOralRowActive.
  ///
  /// In en, this message translates to:
  /// **'In progress: {done} / {total} rated'**
  String toifaOralRowActive(int done, int total);

  /// No description provided for @toifaMistakesTitle.
  ///
  /// In en, this message translates to:
  /// **'Mistake review'**
  String get toifaMistakesTitle;

  /// No description provided for @toifaMistakesRowSub.
  ///
  /// In en, this message translates to:
  /// **'Test mistakes: {tests} · oral “didn’t know”: {oral}'**
  String toifaMistakesRowSub(int tests, int oral);

  /// No description provided for @toifaMistakesRowEmpty.
  ///
  /// In en, this message translates to:
  /// **'No mistakes yet'**
  String get toifaMistakesRowEmpty;

  /// No description provided for @toifaProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get toifaProgressTitle;

  /// No description provided for @toifaProgressRowSub.
  ///
  /// In en, this message translates to:
  /// **'Results by topic and readiness'**
  String get toifaProgressRowSub;

  /// No description provided for @toifaAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'Source and review'**
  String get toifaAboutTitle;

  /// No description provided for @toifaListSource.
  ///
  /// In en, this message translates to:
  /// **'Source: official certification question list (CLD, 119)'**
  String get toifaListSource;

  /// No description provided for @toifaAboutList.
  ///
  /// In en, this message translates to:
  /// **'The list has {tests} test and {oral} oral questions (duplicates across categories merged).'**
  String toifaAboutList(int tests, int oral);

  /// No description provided for @toifaAboutKeys.
  ///
  /// In en, this message translates to:
  /// **'The key is the answer marked in the list, and scoring follows it. LabGuide found the key disputed in {disputed} questions and ambiguous in {ambiguous} — those show a note and source.'**
  String toifaAboutKeys(int disputed, int ambiguous);

  /// No description provided for @toifaAboutKeyless.
  ///
  /// In en, this message translates to:
  /// **'{count} questions have no key marked in the list — they are left out of tests and practice.'**
  String toifaAboutKeyless(int count);

  /// No description provided for @toifaAboutOral.
  ///
  /// In en, this message translates to:
  /// **'Oral answer plans are a study aid prepared by LabGuide ({ready} / {total} plans with sources).'**
  String toifaAboutOral(int ready, int total);

  /// No description provided for @toifaTestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} questions · drawn from the official list'**
  String toifaTestSubtitle(int count);

  /// No description provided for @toifaFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get toifaFormatTitle;

  /// No description provided for @toifaFormatStep1.
  ///
  /// In en, this message translates to:
  /// **'{count} random questions out of {bank} in the bank.'**
  String toifaFormatStep1(int count, int bank);

  /// No description provided for @toifaFormatStep2.
  ///
  /// In en, this message translates to:
  /// **'One answer per question; options in list order.'**
  String get toifaFormatStep2;

  /// No description provided for @toifaFormatStep3.
  ///
  /// In en, this message translates to:
  /// **'At the end: mistake review with the official key and LabGuide note.'**
  String get toifaFormatStep3;

  /// No description provided for @toifaTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time, minutes'**
  String get toifaTimeLabel;

  /// No description provided for @toifaNoTime.
  ///
  /// In en, this message translates to:
  /// **'No time limit'**
  String get toifaNoTime;

  /// No description provided for @toifaTimeHelper.
  ///
  /// In en, this message translates to:
  /// **'No official time limit is set in the app — choose your own or leave empty.'**
  String get toifaTimeHelper;

  /// No description provided for @toifaTimeError.
  ///
  /// In en, this message translates to:
  /// **'Enter 1 to 240 minutes or leave empty'**
  String get toifaTimeError;

  /// No description provided for @toifaPassLabel.
  ///
  /// In en, this message translates to:
  /// **'Pass mark, %'**
  String get toifaPassLabel;

  /// No description provided for @toifaNoPass.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get toifaNoPass;

  /// No description provided for @toifaPassHelper.
  ///
  /// In en, this message translates to:
  /// **'This is your own threshold, not the official pass mark.'**
  String get toifaPassHelper;

  /// No description provided for @toifaPassError.
  ///
  /// In en, this message translates to:
  /// **'Enter 1 to 100% or leave empty'**
  String get toifaPassError;

  /// No description provided for @toifaScoringNotice.
  ///
  /// In en, this message translates to:
  /// **'Scoring follows the official key — that is what the exam expects. Where the key is disputed, the results also show a LabGuide note.'**
  String get toifaScoringNotice;

  /// No description provided for @toifaTestStart.
  ///
  /// In en, this message translates to:
  /// **'Start test'**
  String get toifaTestStart;

  /// No description provided for @toifaTodayEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get toifaTodayEyebrow;

  /// No description provided for @toifaTodayGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal: {count} questions or 1 ticket'**
  String toifaTodayGoal(int count);

  /// No description provided for @toifaTodayDone.
  ///
  /// In en, this message translates to:
  /// **'Today’s goal is done'**
  String get toifaTodayDone;

  /// No description provided for @toifaTodayProgress.
  ///
  /// In en, this message translates to:
  /// **'{answered}/{goal} questions'**
  String toifaTodayProgress(int answered, int goal);

  /// No description provided for @toifaTodayCorrect.
  ///
  /// In en, this message translates to:
  /// **'{percent}% correct'**
  String toifaTodayCorrect(int percent);

  /// No description provided for @toifaTodayTickets.
  ///
  /// In en, this message translates to:
  /// **'tickets: {count}'**
  String toifaTodayTickets(int count);

  /// No description provided for @toifaStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count}-day streak'**
  String toifaStreakDays(int count);

  /// No description provided for @toifaTodayNone.
  ///
  /// In en, this message translates to:
  /// **'No practice yet today.'**
  String get toifaTodayNone;

  /// No description provided for @toifaTodayTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow to keep your streak.'**
  String get toifaTodayTomorrow;

  /// No description provided for @toifaWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days: {values}'**
  String toifaWeekLabel(String values);

  /// No description provided for @toifaGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get toifaGoalLabel;

  /// No description provided for @toifaGoalOption.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String toifaGoalOption(int count);

  /// No description provided for @toifaGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Or 1 oral ticket — whichever comes first.'**
  String get toifaGoalHint;

  /// No description provided for @toifaReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'LabGuide · Knowledge & Skills'**
  String get toifaReminderTitle;

  /// No description provided for @toifaReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Today’s practice is waiting — {count} questions or 1 ticket'**
  String toifaReminderBody(int count);

  /// No description provided for @toifaReminderChannel.
  ///
  /// In en, this message translates to:
  /// **'Knowledge & Skills reminder'**
  String get toifaReminderChannel;

  /// No description provided for @toifaOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue tomorrow?'**
  String get toifaOfferTitle;

  /// No description provided for @toifaOfferBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a reminder time. There’s no reminder on days you’ve met the goal.'**
  String get toifaOfferBody;

  /// No description provided for @toifaOfferOn.
  ///
  /// In en, this message translates to:
  /// **'We’ll remind you tomorrow at {time}.'**
  String toifaOfferOn(String time);

  /// No description provided for @toifaModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get toifaModeTitle;

  /// No description provided for @toifaModeExam.
  ///
  /// In en, this message translates to:
  /// **'Exam mode'**
  String get toifaModeExam;

  /// No description provided for @toifaModeExamSub.
  ///
  /// In en, this message translates to:
  /// **'Timed; score and mistakes at the end — like the real exam.'**
  String get toifaModeExamSub;

  /// No description provided for @toifaModePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice mode — mistakes shown right away'**
  String get toifaModePractice;

  /// No description provided for @toifaModePracticeSub.
  ///
  /// In en, this message translates to:
  /// **'After each answer: the correct option and note; no timer.'**
  String get toifaModePracticeSub;

  /// No description provided for @toifaDrillStep2.
  ///
  /// In en, this message translates to:
  /// **'Right after answering you see if it’s correct: the official key and (if any) a note and source.'**
  String get toifaDrillStep2;

  /// No description provided for @toifaDrillStep3.
  ///
  /// In en, this message translates to:
  /// **'Resume where you left off even after closing the app; rework your mistakes at the end.'**
  String get toifaDrillStep3;

  /// No description provided for @toifaDrillStart.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get toifaDrillStart;

  /// No description provided for @toifaDrillActive.
  ///
  /// In en, this message translates to:
  /// **'Practice in progress: {answered}/{total}'**
  String toifaDrillActive(int answered, int total);

  /// No description provided for @toifaDrillTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice mode'**
  String get toifaDrillTitle;

  /// No description provided for @toifaDrillRework.
  ///
  /// In en, this message translates to:
  /// **'Rework mistakes'**
  String get toifaDrillRework;

  /// No description provided for @toifaDrillScore.
  ///
  /// In en, this message translates to:
  /// **'Correct: {right} · wrong: {wrong}'**
  String toifaDrillScore(int right, int wrong);

  /// No description provided for @toifaDrillFinishEarly.
  ///
  /// In en, this message translates to:
  /// **'Finish now'**
  String get toifaDrillFinishEarly;

  /// No description provided for @toifaDrillFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Unanswered questions count as wrong. Your answers stay in the mistakes list.'**
  String get toifaDrillFinishBody;

  /// No description provided for @toifaDrillDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Abandon this practice?'**
  String get toifaDrillDiscardTitle;

  /// No description provided for @toifaDrillNone.
  ///
  /// In en, this message translates to:
  /// **'No practice in progress'**
  String get toifaDrillNone;

  /// No description provided for @toifaDrillNew.
  ///
  /// In en, this message translates to:
  /// **'New test'**
  String get toifaDrillNew;

  /// No description provided for @toifaDrillUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Unanswered: {count}'**
  String toifaDrillUnanswered(int count);

  /// No description provided for @toifaThinkHint.
  ///
  /// In en, this message translates to:
  /// **'Think through your answer: say it out loud or jot it on paper. Then open the plan and compare.'**
  String get toifaThinkHint;

  /// No description provided for @toifaThinkTimer.
  ///
  /// In en, this message translates to:
  /// **'{minutes}-min think timer'**
  String toifaThinkTimer(int minutes);

  /// No description provided for @toifaThinkLeft.
  ///
  /// In en, this message translates to:
  /// **'Think time: {time}'**
  String toifaThinkLeft(String time);

  /// No description provided for @toifaThinkUp.
  ///
  /// In en, this message translates to:
  /// **'Time’s up — open the plan and compare.'**
  String get toifaThinkUp;

  /// No description provided for @toifaThinkStop.
  ///
  /// In en, this message translates to:
  /// **'Stop timer'**
  String get toifaThinkStop;

  /// No description provided for @toifaChecklistToggle.
  ///
  /// In en, this message translates to:
  /// **'Key points to compare with the plan'**
  String get toifaChecklistToggle;

  /// No description provided for @toifaChecklistHint.
  ///
  /// In en, this message translates to:
  /// **'Tick what your answer covered (on this device only, no typing).'**
  String get toifaChecklistHint;

  /// No description provided for @toifaChecklistCount.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} ticked'**
  String toifaChecklistCount(int done, int total);

  /// No description provided for @toifaRepeatTitle.
  ///
  /// In en, this message translates to:
  /// **'To repeat'**
  String get toifaRepeatTitle;

  /// No description provided for @toifaRepeatNote.
  ///
  /// In en, this message translates to:
  /// **'“Partly” and “Didn’t know” questions come back first in your next tickets.'**
  String get toifaRepeatNote;

  /// No description provided for @toifaRepeatNone.
  ///
  /// In en, this message translates to:
  /// **'You knew them all — new questions in the next ticket.'**
  String get toifaRepeatNone;

  /// No description provided for @toifaPracticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Key right after each answer'**
  String get toifaPracticeSubtitle;

  /// No description provided for @toifaPracticeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed: {count} questions'**
  String toifaPracticeMixed(int count);

  /// No description provided for @toifaPracticeMistakes.
  ///
  /// In en, this message translates to:
  /// **'Redo mistakes'**
  String get toifaPracticeMistakes;

  /// No description provided for @toifaBackToTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get toifaBackToTopics;

  /// No description provided for @toifaPracticeRight.
  ///
  /// In en, this message translates to:
  /// **'Your answer matches the official key.'**
  String get toifaPracticeRight;

  /// No description provided for @toifaPracticeWrong.
  ///
  /// In en, this message translates to:
  /// **'Your answer does not match the official key.'**
  String get toifaPracticeWrong;

  /// No description provided for @toifaListNumber.
  ///
  /// In en, this message translates to:
  /// **'No. {number}'**
  String toifaListNumber(int number);

  /// No description provided for @toifaOfficialKey.
  ///
  /// In en, this message translates to:
  /// **'Official key'**
  String get toifaOfficialKey;

  /// No description provided for @toifaLabGuideNote.
  ///
  /// In en, this message translates to:
  /// **'LabGuide note'**
  String get toifaLabGuideNote;

  /// No description provided for @toifaVerdictDisputed.
  ///
  /// In en, this message translates to:
  /// **'Key disputed'**
  String get toifaVerdictDisputed;

  /// No description provided for @toifaVerdictAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Ambiguous question'**
  String get toifaVerdictAmbiguous;

  /// No description provided for @toifaSuggested.
  ///
  /// In en, this message translates to:
  /// **'LabGuide suggests: {options}'**
  String toifaSuggested(String options);

  /// No description provided for @toifaScoredByOfficial.
  ///
  /// In en, this message translates to:
  /// **'Scoring follows the official key — that answer is what the exam expects.'**
  String get toifaScoredByOfficial;

  /// No description provided for @toifaNoOfficialKey.
  ///
  /// In en, this message translates to:
  /// **'No key is marked in the list — this question is not scored.'**
  String get toifaNoOfficialKey;

  /// No description provided for @toifaNoteNoSource.
  ///
  /// In en, this message translates to:
  /// **'No source is given for this note.'**
  String get toifaNoteNoSource;

  /// No description provided for @toifaRelatedCards.
  ///
  /// In en, this message translates to:
  /// **'Related cards'**
  String get toifaRelatedCards;

  /// No description provided for @toifaOralSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} questions · prepare and self-assess'**
  String toifaOralSubtitle(int count);

  /// No description provided for @toifaOralPool.
  ///
  /// In en, this message translates to:
  /// **'{category}: {count} questions in the list'**
  String toifaOralPool(String category, int count);

  /// No description provided for @toifaOralHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get toifaOralHowTitle;

  /// No description provided for @toifaOralStep1.
  ///
  /// In en, this message translates to:
  /// **'{count} random questions from your category list.'**
  String toifaOralStep1(int count);

  /// No description provided for @toifaOralStep2.
  ///
  /// In en, this message translates to:
  /// **'Prepare your answers — in your head or on paper.'**
  String get toifaOralStep2;

  /// No description provided for @toifaOralStep3.
  ///
  /// In en, this message translates to:
  /// **'Check the answer plan and rate yourself: knew, partly or didn’t know.'**
  String get toifaOralStep3;

  /// No description provided for @toifaPickCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a category first'**
  String get toifaPickCategoryFirst;

  /// No description provided for @toifaDrawTicket.
  ///
  /// In en, this message translates to:
  /// **'Draw a ticket'**
  String get toifaDrawTicket;

  /// No description provided for @toifaTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Your ticket'**
  String get toifaTicketTitle;

  /// No description provided for @toifaPrepHint.
  ///
  /// In en, this message translates to:
  /// **'No typing needed. Think through each answer — say it out loud or jot it on paper. Then compare with the answer plan and rate yourself.'**
  String get toifaPrepHint;

  /// No description provided for @toifaShowPlans.
  ///
  /// In en, this message translates to:
  /// **'Answer one by one'**
  String get toifaShowPlans;

  /// No description provided for @toifaShowPlan.
  ///
  /// In en, this message translates to:
  /// **'View answer plan'**
  String get toifaShowPlan;

  /// No description provided for @toifaNewTicket.
  ///
  /// In en, this message translates to:
  /// **'New ticket'**
  String get toifaNewTicket;

  /// No description provided for @toifaNewTicketBody.
  ///
  /// In en, this message translates to:
  /// **'Five new questions replace the current ticket. Ratings you gave are kept.'**
  String get toifaNewTicketBody;

  /// No description provided for @toifaRevealHint.
  ///
  /// In en, this message translates to:
  /// **'First recall or write down your answer, then open the plan.'**
  String get toifaRevealHint;

  /// No description provided for @toifaPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Answer plan'**
  String get toifaPlanTitle;

  /// No description provided for @toifaPlanPending.
  ///
  /// In en, this message translates to:
  /// **'Prepared by LabGuide'**
  String get toifaPlanPending;

  /// No description provided for @toifaPlanMissing.
  ///
  /// In en, this message translates to:
  /// **'The plan for this question is not ready yet.'**
  String get toifaPlanMissing;

  /// No description provided for @toifaPlanNotChecked.
  ///
  /// In en, this message translates to:
  /// **'No source is attached to this plan yet.'**
  String get toifaPlanNotChecked;

  /// No description provided for @toifaReferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Reference interval (specimen, lab-specific)'**
  String get toifaReferenceTitle;

  /// No description provided for @toifaCutoffTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic cut-off (guideline)'**
  String get toifaCutoffTitle;

  /// No description provided for @toifaWrongLabel.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get toifaWrongLabel;

  /// No description provided for @toifaRightLabel.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get toifaRightLabel;

  /// No description provided for @toifaNeedsSource.
  ///
  /// In en, this message translates to:
  /// **'Source needed — being checked with a teacher'**
  String get toifaNeedsSource;

  /// No description provided for @toifaUnverifiedNote.
  ///
  /// In en, this message translates to:
  /// **'The note is not confirmed by a source — no answer is suggested.'**
  String get toifaUnverifiedNote;

  /// No description provided for @toifaAgentChecked.
  ///
  /// In en, this message translates to:
  /// **'Compared with sources: {date}'**
  String toifaAgentChecked(String date);

  /// No description provided for @toifaHeld.
  ///
  /// In en, this message translates to:
  /// **'Being clarified'**
  String get toifaHeld;

  /// No description provided for @toifaHeldBody.
  ///
  /// In en, this message translates to:
  /// **'Until the wording is clarified, this question is left out of tickets and scoring.'**
  String get toifaHeldBody;

  /// No description provided for @toifaAboutHeld.
  ///
  /// In en, this message translates to:
  /// **'{count} question(s) are left out of tickets and tests until clarified.'**
  String toifaAboutHeld(int count);

  /// No description provided for @toifaPitfallsTitle.
  ///
  /// In en, this message translates to:
  /// **'Outdated / common mistake'**
  String get toifaPitfallsTitle;

  /// No description provided for @toifaRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rate yourself'**
  String get toifaRateTitle;

  /// No description provided for @toifaRateHint.
  ///
  /// In en, this message translates to:
  /// **'The rating stays on this device and appears in Mistake review.'**
  String get toifaRateHint;

  /// No description provided for @toifaRateKnew.
  ///
  /// In en, this message translates to:
  /// **'Knew it'**
  String get toifaRateKnew;

  /// No description provided for @toifaRatePartial.
  ///
  /// In en, this message translates to:
  /// **'Partly'**
  String get toifaRatePartial;

  /// No description provided for @toifaRateUnknown.
  ///
  /// In en, this message translates to:
  /// **'Didn’t know'**
  String get toifaRateUnknown;

  /// No description provided for @toifaTicketDone.
  ///
  /// In en, this message translates to:
  /// **'Ticket complete'**
  String get toifaTicketDone;

  /// No description provided for @toifaTicketSummary.
  ///
  /// In en, this message translates to:
  /// **'Knew: {knew} · partly: {partial} · didn’t know: {unknown}'**
  String toifaTicketSummary(int knew, int partial, int unknown);

  /// No description provided for @toifaRatingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Ratings saved. Tap a question to reopen the plan and change the rating.'**
  String get toifaRatingsSaved;

  /// No description provided for @toifaRatingSaved.
  ///
  /// In en, this message translates to:
  /// **'Rating saved'**
  String get toifaRatingSaved;

  /// No description provided for @toifaMistakesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Test mistakes and oral questions'**
  String get toifaMistakesSubtitle;

  /// No description provided for @toifaMistakesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No mistakes yet'**
  String get toifaMistakesEmpty;

  /// No description provided for @toifaMistakesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Questions you got wrong in tests or practice and oral questions rated “didn’t know” collect here.'**
  String get toifaMistakesEmptyBody;

  /// No description provided for @toifaMistakesTests.
  ///
  /// In en, this message translates to:
  /// **'Test mistakes · {count}'**
  String toifaMistakesTests(int count);

  /// No description provided for @toifaMistakesOralUnknown.
  ///
  /// In en, this message translates to:
  /// **'Oral: didn’t know · {count}'**
  String toifaMistakesOralUnknown(int count);

  /// No description provided for @toifaMistakesOralPartial.
  ///
  /// In en, this message translates to:
  /// **'Oral: partly · {count}'**
  String toifaMistakesOralPartial(int count);

  /// No description provided for @toifaMoreMistakes.
  ///
  /// In en, this message translates to:
  /// **'{count} more mistakes — practice them via Redo mistakes.'**
  String toifaMoreMistakes(int count);

  /// No description provided for @toifaNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get toifaNothingHere;

  /// No description provided for @toifaProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Results by topic and readiness'**
  String get toifaProgressSubtitle;

  /// No description provided for @toifaReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated readiness'**
  String get toifaReadyTitle;

  /// No description provided for @toifaReadyCaption.
  ///
  /// In en, this message translates to:
  /// **'Average of test and oral results. A LabGuide estimate, not an official grade.'**
  String get toifaReadyCaption;

  /// No description provided for @toifaReadyTestDetail.
  ///
  /// In en, this message translates to:
  /// **'Test: {done} / {total} questions mastered'**
  String toifaReadyTestDetail(int done, int total);

  /// No description provided for @toifaReadyOralDetail.
  ///
  /// In en, this message translates to:
  /// **'Oral: {done} / {total} “knew it”'**
  String toifaReadyOralDetail(int done, int total);

  /// No description provided for @toifaProgressPickCategory.
  ///
  /// In en, this message translates to:
  /// **'Oral results use your category list — choose a category:'**
  String get toifaProgressPickCategory;

  /// No description provided for @toifaRecentTests.
  ///
  /// In en, this message translates to:
  /// **'Recent tests'**
  String get toifaRecentTests;

  /// No description provided for @toifaPassedShort.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get toifaPassedShort;

  /// No description provided for @toifaNotPassedShort.
  ///
  /// In en, this message translates to:
  /// **'Below mark'**
  String get toifaNotPassedShort;

  /// No description provided for @toifaByTopicNote.
  ///
  /// In en, this message translates to:
  /// **'Weakest topics first. Test — questions last answered correctly; oral — rated “knew it”.'**
  String get toifaByTopicNote;

  /// No description provided for @toifaBarTest.
  ///
  /// In en, this message translates to:
  /// **'Test: {done} / {total}'**
  String toifaBarTest(int done, int total);

  /// No description provided for @toifaBarOral.
  ///
  /// In en, this message translates to:
  /// **'Oral: {done} / {total}'**
  String toifaBarOral(int done, int total);

  /// No description provided for @examPassMet.
  ///
  /// In en, this message translates to:
  /// **'Mark reached (≥{percent}%)'**
  String examPassMet(int percent);

  /// No description provided for @examPassMissed.
  ///
  /// In en, this message translates to:
  /// **'Below your mark ({percent}%)'**
  String examPassMissed(int percent);

  /// No description provided for @learnLessonPlan.
  ///
  /// In en, this message translates to:
  /// **'Lesson plan'**
  String get learnLessonPlan;

  /// No description provided for @learnLessonPlanSub.
  ///
  /// In en, this message translates to:
  /// **'Teacher workspace'**
  String get learnLessonPlanSub;

  /// No description provided for @quizProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizProgress(int current, int total);

  /// No description provided for @quizCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct.'**
  String get quizCorrect;

  /// No description provided for @quizIncorrect.
  ///
  /// In en, this message translates to:
  /// **'This answer is incorrect.'**
  String get quizIncorrect;

  /// No description provided for @quizNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// No description provided for @quizFinish.
  ///
  /// In en, this message translates to:
  /// **'See result'**
  String get quizFinish;

  /// No description provided for @quizDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice complete'**
  String get quizDoneTitle;

  /// No description provided for @quizScore.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct'**
  String quizScore(int correct, int total);

  /// No description provided for @quizRestart.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get quizRestart;

  /// No description provided for @quizBasis.
  ///
  /// In en, this message translates to:
  /// **'Basis: {basis}'**
  String quizBasis(String basis);

  /// No description provided for @quizSources.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get quizSources;

  /// No description provided for @quizReviewNote.
  ///
  /// In en, this message translates to:
  /// **'Practice questions are for learning; the result is not an official grade.'**
  String get quizReviewNote;

  /// No description provided for @quizMistakes.
  ///
  /// In en, this message translates to:
  /// **'Review your mistakes'**
  String get quizMistakes;

  /// No description provided for @quizNoMistakes.
  ///
  /// In en, this message translates to:
  /// **'No mistakes — well done.'**
  String get quizNoMistakes;

  /// No description provided for @quizYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get quizYourAnswer;

  /// No description provided for @quizCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get quizCorrectAnswer;

  /// No description provided for @quizChooseTopic.
  ///
  /// In en, this message translates to:
  /// **'Choose a topic'**
  String get quizChooseTopic;

  /// No description provided for @quizTopicMixed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Mixed: 1 random question} other{Mixed: {count} random questions}}'**
  String quizTopicMixed(int count);

  /// No description provided for @quizTopicGeneral.
  ///
  /// In en, this message translates to:
  /// **'Laboratory calculations'**
  String get quizTopicGeneral;

  /// No description provided for @quizQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question} other{{count} questions}}'**
  String quizQuestionCount(int count);

  /// No description provided for @quizOtherTopic.
  ///
  /// In en, this message translates to:
  /// **'Another topic'**
  String get quizOtherTopic;

  /// No description provided for @dailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily questions'**
  String get dailyTitle;

  /// No description provided for @dailyCardStart.
  ///
  /// In en, this message translates to:
  /// **'Today’s 5 questions'**
  String get dailyCardStart;

  /// No description provided for @dailyCardStartSub.
  ///
  /// In en, this message translates to:
  /// **'2–3 minutes. New questions every day, with an explanation and source after each answer.'**
  String get dailyCardStartSub;

  /// No description provided for @dailyCardProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} answered'**
  String dailyCardProgress(int count, int total);

  /// No description provided for @dailyCardDone.
  ///
  /// In en, this message translates to:
  /// **'Done for today: {correct} of {total} correct'**
  String dailyCardDone(int correct, int total);

  /// No description provided for @dailyCardDoneSub.
  ///
  /// In en, this message translates to:
  /// **'Five new questions tomorrow.'**
  String get dailyCardDoneSub;

  /// No description provided for @dailyStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get dailyStart;

  /// No description provided for @dailyContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get dailyContinue;

  /// No description provided for @dailyShowResult.
  ///
  /// In en, this message translates to:
  /// **'See result'**
  String get dailyShowResult;

  /// No description provided for @dailyStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day in a row} other{{count} days in a row}}'**
  String dailyStreakDays(int count);

  /// No description provided for @dailyStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get dailyStreakTitle;

  /// No description provided for @dailyStreakCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get dailyStreakCurrent;

  /// No description provided for @dailyStreakBest.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get dailyStreakBest;

  /// No description provided for @dailyDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String dailyDaysShort(int count);

  /// No description provided for @dailyFreezeAvailable.
  ///
  /// In en, this message translates to:
  /// **'This week’s freeze is available'**
  String get dailyFreezeAvailable;

  /// No description provided for @dailyFreezeUsed.
  ///
  /// In en, this message translates to:
  /// **'This week’s freeze is used'**
  String get dailyFreezeUsed;

  /// No description provided for @dailyFreezeRule.
  ///
  /// In en, this message translates to:
  /// **'Miss one day and your streak survives — once a week (a freeze). The frozen day doesn’t count towards the streak; miss two days in a row and it starts over.'**
  String get dailyFreezeRule;

  /// No description provided for @dailyFreezeSaved.
  ///
  /// In en, this message translates to:
  /// **'You missed yesterday — a freeze kept your streak.'**
  String get dailyFreezeSaved;

  /// No description provided for @dailyStreakStart.
  ///
  /// In en, this message translates to:
  /// **'Answer today’s questions to start a streak.'**
  String get dailyStreakStart;

  /// No description provided for @dailyKeepStreak.
  ///
  /// In en, this message translates to:
  /// **'Answer today’s questions to keep your streak.'**
  String get dailyKeepStreak;

  /// No description provided for @dailyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No questions for today'**
  String get dailyEmpty;

  /// No description provided for @dailyReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Today’s questions'**
  String get dailyReviewTitle;

  /// No description provided for @dailySourceToifa.
  ///
  /// In en, this message translates to:
  /// **'Questions come from the official list — only those whose key passed the LabGuide check.'**
  String get dailySourceToifa;

  /// No description provided for @dailyReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'LabGuide: daily questions'**
  String get dailyReminderTitle;

  /// No description provided for @dailyReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Today’s 5 questions are ready — 2–3 minutes.'**
  String get dailyReminderBody;

  /// No description provided for @dailyReminderChannel.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminderChannel;

  /// No description provided for @dailyReminderSetting.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get dailyReminderSetting;

  /// No description provided for @dailyReminderAt.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String dailyReminderAt(String time);

  /// No description provided for @dailyReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get dailyReminderOff;

  /// No description provided for @dailyReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get dailyReminderTime;

  /// No description provided for @dailyOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Want a daily reminder?'**
  String get dailyOfferTitle;

  /// No description provided for @dailyOfferBody.
  ///
  /// In en, this message translates to:
  /// **'One notification at the time you choose. No reminder on days you’ve already answered. Turn it off any time.'**
  String get dailyOfferBody;

  /// No description provided for @dailyOfferYes.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminder'**
  String get dailyOfferYes;

  /// No description provided for @dailyOfferNo.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get dailyOfferNo;

  /// No description provided for @dailyReminderDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission wasn’t granted, so the reminder stays off. Allow notifications for LabGuide in your phone settings and try again.'**
  String get dailyReminderDenied;

  /// No description provided for @dailyReminderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t turn on reminders on this device.'**
  String get dailyReminderUnavailable;

  /// No description provided for @dailyReminderOnSnack.
  ///
  /// In en, this message translates to:
  /// **'Reminder on: every day at {time}'**
  String dailyReminderOnSnack(String time);

  /// No description provided for @dailyReminderNote.
  ///
  /// In en, this message translates to:
  /// **'The reminder is scheduled on this device only (no server). Your phone may delay it by a few minutes to save battery. If you don’t open the app for 7 days, reminders stop.'**
  String get dailyReminderNote;

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share result'**
  String get shareResult;

  /// No description provided for @shareSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Result card'**
  String get shareSheetTitle;

  /// No description provided for @shareSheetBody.
  ///
  /// In en, this message translates to:
  /// **'The image has no name or other personal data.'**
  String get shareSheetBody;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the share sheet. Please try again.'**
  String get shareFailed;

  /// No description provided for @shareKindDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily questions'**
  String get shareKindDaily;

  /// No description provided for @shareKindExam.
  ///
  /// In en, this message translates to:
  /// **'Practice exam'**
  String get shareKindExam;

  /// No description provided for @shareKindToifa.
  ///
  /// In en, this message translates to:
  /// **'Knowledge test practice'**
  String get shareKindToifa;

  /// No description provided for @shareCorrectCaption.
  ///
  /// In en, this message translates to:
  /// **'correct answers'**
  String get shareCorrectCaption;

  /// No description provided for @shareFooter.
  ///
  /// In en, this message translates to:
  /// **'Lab reference and practice'**
  String get shareFooter;

  /// No description provided for @shareToifaNote.
  ///
  /// In en, this message translates to:
  /// **'LabGuide practice result'**
  String get shareToifaNote;

  /// No description provided for @shareText.
  ///
  /// In en, this message translates to:
  /// **'LabGuide · {kind}: {correct}/{total} ({percent}%)'**
  String shareText(String kind, int correct, int total, int percent);

  /// No description provided for @quizTopicMistakes.
  ///
  /// In en, this message translates to:
  /// **'Review my mistakes'**
  String get quizTopicMistakes;

  /// No description provided for @quizMastered.
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total} correct last time'**
  String quizMastered(int correct, int total);

  /// No description provided for @examTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam mode'**
  String get examTitle;

  /// No description provided for @classesTitle.
  ///
  /// In en, this message translates to:
  /// **'Classes and assignments'**
  String get classesTitle;

  /// No description provided for @classesSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use classes'**
  String get classesSignInTitle;

  /// No description provided for @classesSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Creating, joining and submitting assignments is tied to an account. Reading content stays open without sign-in.'**
  String get classesSignInBody;

  /// No description provided for @classesSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get classesSignIn;

  /// No description provided for @classesUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'The class server isn’t connected yet'**
  String get classesUnavailableTitle;

  /// No description provided for @classesUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is sent or stored. When it’s connected, teachers see only their own classes and students see only their own results — checked on the server.'**
  String get classesUnavailableBody;

  /// No description provided for @examSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A timed test: pick topics, number of questions and time. Works offline.'**
  String get examSubtitle;

  /// No description provided for @examActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfinished exam'**
  String get examActiveTitle;

  /// No description provided for @examActiveBody.
  ///
  /// In en, this message translates to:
  /// **'{answered}/{total} answered · {time} left'**
  String examActiveBody(int answered, int total, String time);

  /// No description provided for @examResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get examResume;

  /// No description provided for @examDiscard.
  ///
  /// In en, this message translates to:
  /// **'Abandon exam'**
  String get examDiscard;

  /// No description provided for @examDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Abandon this exam?'**
  String get examDiscardTitle;

  /// No description provided for @examDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers will be deleted and no result will be saved.'**
  String get examDiscardBody;

  /// No description provided for @examDiscardAction.
  ///
  /// In en, this message translates to:
  /// **'Abandon'**
  String get examDiscardAction;

  /// No description provided for @examTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get examTopics;

  /// No description provided for @examAllTopics.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get examAllTopics;

  /// No description provided for @examPoolCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question in the selected topics} other{{count} questions in the selected topics}}'**
  String examPoolCount(int count);

  /// No description provided for @examSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get examSettings;

  /// No description provided for @examCount.
  ///
  /// In en, this message translates to:
  /// **'Number of questions'**
  String get examCount;

  /// No description provided for @examCountHint.
  ///
  /// In en, this message translates to:
  /// **'From 1 to {max}'**
  String examCountHint(int max);

  /// No description provided for @examCountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 1 to {max}'**
  String examCountError(int max);

  /// No description provided for @examCountAll.
  ///
  /// In en, this message translates to:
  /// **'All {count}'**
  String examCountAll(int count);

  /// No description provided for @examTime.
  ///
  /// In en, this message translates to:
  /// **'Time, minutes'**
  String get examTime;

  /// No description provided for @examTimeHint.
  ///
  /// In en, this message translates to:
  /// **'1–180 min · usually 1 min per question'**
  String get examTimeHint;

  /// No description provided for @examTimeError.
  ///
  /// In en, this message translates to:
  /// **'Enter 1 to 180 minutes'**
  String get examTimeError;

  /// No description provided for @examMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String examMinutes(int count);

  /// No description provided for @examRulesNotice.
  ///
  /// In en, this message translates to:
  /// **'Questions and options are shuffled. Until you finish you can change answers and bookmark questions to revisit. The clock keeps running even if the app is closed; when time is up, the exam ends by itself.'**
  String get examRulesNotice;

  /// No description provided for @examStart.
  ///
  /// In en, this message translates to:
  /// **'Start exam'**
  String get examStart;

  /// No description provided for @examReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'You have an unfinished exam'**
  String get examReplaceTitle;

  /// No description provided for @examReplaceBody.
  ///
  /// In en, this message translates to:
  /// **'Starting a new one deletes the previous exam and its answers.'**
  String get examReplaceBody;

  /// No description provided for @examHistory.
  ///
  /// In en, this message translates to:
  /// **'Result history'**
  String get examHistory;

  /// No description provided for @examHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No exams yet. Your first result will appear here — it’s stored only on this device.'**
  String get examHistoryEmpty;

  /// No description provided for @examHistoryStats.
  ///
  /// In en, this message translates to:
  /// **'Last {count}: average {avg}% · best {best}%'**
  String examHistoryStats(int count, int avg, int best);

  /// No description provided for @examHistoryRow.
  ///
  /// In en, this message translates to:
  /// **'{date} · {correct}/{total} · {time}'**
  String examHistoryRow(String date, int correct, int total, String time);

  /// No description provided for @examHistoryClear.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get examHistoryClear;

  /// No description provided for @examHistoryClearBody.
  ///
  /// In en, this message translates to:
  /// **'All exam results will be deleted from this device.'**
  String get examHistoryClearBody;

  /// No description provided for @examProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Recent results: {values}'**
  String examProgressLabel(String values);

  /// No description provided for @examProgressOld.
  ///
  /// In en, this message translates to:
  /// **'Older → newer'**
  String get examProgressOld;

  /// No description provided for @examProgressLast.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get examProgressLast;

  /// No description provided for @examSettled.
  ///
  /// In en, this message translates to:
  /// **'Your previous exam ended because time ran out'**
  String get examSettled;

  /// No description provided for @examOpenResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get examOpenResult;

  /// No description provided for @examTitleAll.
  ///
  /// In en, this message translates to:
  /// **'All topics'**
  String get examTitleAll;

  /// No description provided for @examTitleTopics.
  ///
  /// In en, this message translates to:
  /// **'{first} + {more} more'**
  String examTitleTopics(String first, int more);

  /// No description provided for @examReworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice your mistakes'**
  String get examReworkTitle;

  /// No description provided for @examQuestionMissing.
  ///
  /// In en, this message translates to:
  /// **'This question isn’t in the current content pack.'**
  String get examQuestionMissing;

  /// No description provided for @examMap.
  ///
  /// In en, this message translates to:
  /// **'Question map'**
  String get examMap;

  /// No description provided for @examFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get examFinish;

  /// No description provided for @examFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish the exam?'**
  String get examFinishTitle;

  /// No description provided for @examFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Unanswered: {unanswered}, bookmarked: {flagged}. You can’t change answers after finishing.'**
  String examFinishBody(int unanswered, int flagged);

  /// No description provided for @examFinishBodyAll.
  ///
  /// In en, this message translates to:
  /// **'All questions are answered. You can’t change answers after finishing.'**
  String get examFinishBodyAll;

  /// No description provided for @examFinishClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish the test?'**
  String get examFinishClassTitle;

  /// No description provided for @examFinishClassBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers will be sent to your teacher.'**
  String get examFinishClassBody;

  /// No description provided for @examFlag.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get examFlag;

  /// No description provided for @examFlagged.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get examFlagged;

  /// No description provided for @examLegendAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get examLegendAnswered;

  /// No description provided for @examLegendEmpty.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get examLegendEmpty;

  /// No description provided for @examLegendFlagged.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked'**
  String get examLegendFlagged;

  /// No description provided for @examQuestionN.
  ///
  /// In en, this message translates to:
  /// **'Question {n}'**
  String examQuestionN(int n);

  /// No description provided for @examAnsweredOf.
  ///
  /// In en, this message translates to:
  /// **'{answered}/{total} answered'**
  String examAnsweredOf(int answered, int total);

  /// No description provided for @examPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get examPrev;

  /// No description provided for @examNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get examNext;

  /// No description provided for @examTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Time left: {time}'**
  String examTimeLeft(String time);

  /// No description provided for @examElapsed.
  ///
  /// In en, this message translates to:
  /// **'Elapsed: {time}'**
  String examElapsed(String time);

  /// No description provided for @examNoActive.
  ///
  /// In en, this message translates to:
  /// **'No active exam'**
  String get examNoActive;

  /// No description provided for @examNoActiveBody.
  ///
  /// In en, this message translates to:
  /// **'It was finished or abandoned. Set up and start a new one.'**
  String get examNoActiveBody;

  /// No description provided for @examNew.
  ///
  /// In en, this message translates to:
  /// **'New exam'**
  String get examNew;

  /// No description provided for @examSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving the result…'**
  String get examSaving;

  /// No description provided for @examResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get examResultTitle;

  /// No description provided for @examResultMissing.
  ///
  /// In en, this message translates to:
  /// **'Result not found'**
  String get examResultMissing;

  /// No description provided for @examBand90.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get examBand90;

  /// No description provided for @examBand70.
  ///
  /// In en, this message translates to:
  /// **'Good result!'**
  String get examBand70;

  /// No description provided for @examBand50.
  ///
  /// In en, this message translates to:
  /// **'Not bad — review your mistakes'**
  String get examBand50;

  /// No description provided for @examBand0.
  ///
  /// In en, this message translates to:
  /// **'Keep practicing — you’ve got this'**
  String get examBand0;

  /// No description provided for @examCorrectN.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get examCorrectN;

  /// No description provided for @examWrongN.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get examWrongN;

  /// No description provided for @examSkippedN.
  ///
  /// In en, this message translates to:
  /// **'Unanswered'**
  String get examSkippedN;

  /// No description provided for @examSpent.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get examSpent;

  /// No description provided for @examTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Time ran out — finished automatically'**
  String get examTimedOut;

  /// No description provided for @examDeltaUp.
  ///
  /// In en, this message translates to:
  /// **'+{n}% vs last attempt'**
  String examDeltaUp(int n);

  /// No description provided for @examDeltaDown.
  ///
  /// In en, this message translates to:
  /// **'−{n}% vs last attempt'**
  String examDeltaDown(int n);

  /// No description provided for @examDeltaSame.
  ///
  /// In en, this message translates to:
  /// **'Same as last attempt'**
  String get examDeltaSame;

  /// No description provided for @examReworkMistakes.
  ///
  /// In en, this message translates to:
  /// **'Practice mistakes · {count}'**
  String examReworkMistakes(int count);

  /// No description provided for @examAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Mistake analysis'**
  String get examAnalysis;

  /// No description provided for @examFilterMistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes · {count}'**
  String examFilterMistakes(int count);

  /// No description provided for @examFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All · {count}'**
  String examFilterAll(int count);

  /// No description provided for @examNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get examNoAnswer;

  /// No description provided for @examWrongTag.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get examWrongTag;

  /// No description provided for @examWhyWrong.
  ///
  /// In en, this message translates to:
  /// **'Why not this answer'**
  String get examWhyWrong;

  /// No description provided for @examNoSource.
  ///
  /// In en, this message translates to:
  /// **'No source is given for this question.'**
  String get examNoSource;

  /// No description provided for @examSourceMissing.
  ///
  /// In en, this message translates to:
  /// **'This exam’s question bank isn’t available in the app'**
  String get examSourceMissing;

  /// No description provided for @examMultiHint.
  ///
  /// In en, this message translates to:
  /// **'Several correct answers — select all'**
  String get examMultiHint;

  /// No description provided for @examNoExplanation.
  ///
  /// In en, this message translates to:
  /// **'No explanation has been written for this question yet.'**
  String get examNoExplanation;

  /// No description provided for @examByTopic.
  ///
  /// In en, this message translates to:
  /// **'By topic'**
  String get examByTopic;

  /// No description provided for @examByTopicNote.
  ///
  /// In en, this message translates to:
  /// **'Weakest topic first — start there.'**
  String get examByTopicNote;

  /// No description provided for @classesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A teacher creates a class and sets assignments; students join with a code and solve them.'**
  String get classesSubtitle;

  /// No description provided for @classesTryExam.
  ///
  /// In en, this message translates to:
  /// **'Open the offline exam'**
  String get classesTryExam;

  /// No description provided for @classesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get classesLoading;

  /// No description provided for @classesInvalid.
  ///
  /// In en, this message translates to:
  /// **'The server didn’t accept this — check the fields.'**
  String get classesInvalid;

  /// No description provided for @classesCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'No class found with this code. Check the code with your teacher.'**
  String get classesCodeNotFound;

  /// No description provided for @classesCreate.
  ///
  /// In en, this message translates to:
  /// **'Create a class'**
  String get classesCreate;

  /// No description provided for @classesCreateSub.
  ///
  /// In en, this message translates to:
  /// **'For teachers: get a code and set assignments'**
  String get classesCreateSub;

  /// No description provided for @classesJoin.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get classesJoin;

  /// No description provided for @classesJoinSub.
  ///
  /// In en, this message translates to:
  /// **'For students: the 8-character code from your teacher'**
  String get classesJoinSub;

  /// No description provided for @classesRoleNote.
  ///
  /// In en, this message translates to:
  /// **'Your role in the app grants no server rights: only an account registered as a teacher can open a class, and only manages its own classes.'**
  String get classesRoleNote;

  /// No description provided for @classesMine.
  ///
  /// In en, this message translates to:
  /// **'My classes'**
  String get classesMine;

  /// No description provided for @classesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No classes yet'**
  String get classesEmpty;

  /// No description provided for @classesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a class or join one with the code from your teacher.'**
  String get classesEmptyBody;

  /// No description provided for @classesRoleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get classesRoleTeacher;

  /// No description provided for @classesRoleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get classesRoleStudent;

  /// No description provided for @classesMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String classesMembers(int count);

  /// No description provided for @classesCreateIntro.
  ///
  /// In en, this message translates to:
  /// **'The teacher who opens a class manages only that class. Students join with your code or QR.'**
  String get classesCreateIntro;

  /// No description provided for @classesGroupName.
  ///
  /// In en, this message translates to:
  /// **'Class name'**
  String get classesGroupName;

  /// No description provided for @classesGroupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Biochemistry year 2'**
  String get classesGroupNameHint;

  /// No description provided for @classesLengthError.
  ///
  /// In en, this message translates to:
  /// **'Enter {min}–{max} characters'**
  String classesLengthError(int min, int max);

  /// No description provided for @classesDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Nickname (optional)'**
  String get classesDisplayName;

  /// No description provided for @classesDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Star — leave empty to use a number'**
  String get classesDisplayNameHint;

  /// No description provided for @classesDisplayNameHintTeacher.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dr N. Karimova'**
  String get classesDisplayNameHintTeacher;

  /// No description provided for @classesDisplayNameNote.
  ///
  /// In en, this message translates to:
  /// **'Names aren’t stored on the server: students appear by nickname or number. You can note a real name only as a label on your own device.'**
  String get classesDisplayNameNote;

  /// No description provided for @classesCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create class'**
  String get classesCreateAction;

  /// No description provided for @classesCreated.
  ///
  /// In en, this message translates to:
  /// **'Class created — send the code to your students'**
  String get classesCreated;

  /// No description provided for @classesJoinIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter the code your teacher gave you.'**
  String get classesJoinIntro;

  /// No description provided for @classesCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get classesCode;

  /// No description provided for @classesCodeError.
  ///
  /// In en, this message translates to:
  /// **'The code has 8 letters and digits'**
  String get classesCodeError;

  /// No description provided for @classesJoinNote.
  ///
  /// In en, this message translates to:
  /// **'Don’t use your real name. The teacher sees only your nickname (or number) and your results; other students don’t see you. Your email isn’t shown.'**
  String get classesJoinNote;

  /// No description provided for @classesJoinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get classesJoinAction;

  /// No description provided for @classesJoined.
  ///
  /// In en, this message translates to:
  /// **'You joined the class'**
  String get classesJoined;

  /// No description provided for @classesYouTeacher.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You’re the teacher · 1 member} other{You’re the teacher · {count} members}}'**
  String classesYouTeacher(int count);

  /// No description provided for @classesYouStudent.
  ///
  /// In en, this message translates to:
  /// **'You’re a student'**
  String get classesYouStudent;

  /// No description provided for @classesGroupMissing.
  ///
  /// In en, this message translates to:
  /// **'Class not found, or you’re no longer a member'**
  String get classesGroupMissing;

  /// No description provided for @classesBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to classes'**
  String get classesBackToList;

  /// No description provided for @classesAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get classesAssignments;

  /// No description provided for @classesNoAssignmentsTeacher.
  ///
  /// In en, this message translates to:
  /// **'No assignments yet. Pick topics and a number of questions from the bank to set one.'**
  String get classesNoAssignmentsTeacher;

  /// No description provided for @classesNoAssignmentsStudent.
  ///
  /// In en, this message translates to:
  /// **'No assignments yet'**
  String get classesNoAssignmentsStudent;

  /// No description provided for @classesNoAssignmentsStudentBody.
  ///
  /// In en, this message translates to:
  /// **'When your teacher sets one, it will appear here.'**
  String get classesNoAssignmentsStudentBody;

  /// No description provided for @classesNoDue.
  ///
  /// In en, this message translates to:
  /// **'no due date'**
  String get classesNoDue;

  /// No description provided for @classesDue.
  ///
  /// In en, this message translates to:
  /// **'due {date}'**
  String classesDue(String date);

  /// No description provided for @classesSubmittedOf.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} submitted'**
  String classesSubmittedOf(int done, int total);

  /// No description provided for @classesMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Students · {count}'**
  String classesMembersTitle(int count);

  /// No description provided for @classesNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students yet — share the code.'**
  String get classesNoStudents;

  /// No description provided for @classesMemberNoWork.
  ///
  /// In en, this message translates to:
  /// **'Nothing submitted yet'**
  String get classesMemberNoWork;

  /// No description provided for @classesMemberSummary.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} assignments · average {avg}%'**
  String classesMemberSummary(int done, int total, int avg);

  /// No description provided for @classesRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from class'**
  String get classesRemove;

  /// No description provided for @classesRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the class?'**
  String classesRemoveTitle(String name);

  /// No description provided for @classesRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'They’ll no longer see the class or new assignments. Submitted results are kept.'**
  String get classesRemoveBody;

  /// No description provided for @classesRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get classesRemoveAction;

  /// No description provided for @classesStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Submitted · {score}/{total}'**
  String classesStatusDone(int score, int total);

  /// No description provided for @classesStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get classesStatusInProgress;

  /// No description provided for @classesStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get classesStatusPending;

  /// No description provided for @classesStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Past due'**
  String get classesStatusOverdue;

  /// No description provided for @classesStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get classesStatusNew;

  /// No description provided for @classesStudentNote.
  ///
  /// In en, this message translates to:
  /// **'Your teacher sees only your name in the class and your assignment results.'**
  String get classesStudentNote;

  /// No description provided for @classesLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave class'**
  String get classesLeave;

  /// No description provided for @classesLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave the class?'**
  String get classesLeaveTitle;

  /// No description provided for @classesLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'To rejoin you’ll need the teacher’s code. Results you’ve submitted stay with the teacher.'**
  String get classesLeaveBody;

  /// No description provided for @classesLeaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get classesLeaveAction;

  /// No description provided for @classesDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete class'**
  String get classesDeleteGroup;

  /// No description provided for @classesDeleteGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete the class “{name}”?'**
  String classesDeleteGroupTitle(String name);

  /// No description provided for @classesDeleteGroupBody.
  ///
  /// In en, this message translates to:
  /// **'The class, its assignments and student results will be deleted permanently.'**
  String get classesDeleteGroupBody;

  /// No description provided for @classesDeleteGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get classesDeleteGroupAction;

  /// No description provided for @classesInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get classesInviteTitle;

  /// No description provided for @classesInviteBody.
  ///
  /// In en, this message translates to:
  /// **'Students scan the QR with the phone camera and tap “Open in app” — or: Learn → Classes and assignments → Join with a code.'**
  String get classesInviteBody;

  /// No description provided for @classesCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get classesCopyCode;

  /// No description provided for @classesCopyInvite.
  ///
  /// In en, this message translates to:
  /// **'Copy invitation text'**
  String get classesCopyInvite;

  /// No description provided for @classesCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get classesCopied;

  /// No description provided for @classesInviteText.
  ///
  /// In en, this message translates to:
  /// **'Join the class “{name}” in the LabGuide app: Learn → Classes and assignments → Join with a code. Code: {code}'**
  String classesInviteText(String name, String code);

  /// No description provided for @classesAssignmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment title'**
  String get classesAssignmentTitle;

  /// No description provided for @classesTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'Time limit, minutes'**
  String get classesTimeLimit;

  /// No description provided for @classesNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get classesNoLimit;

  /// No description provided for @classesDueNone.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get classesDueNone;

  /// No description provided for @classesDueDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String classesDueDays(int count);

  /// No description provided for @classesDuePick.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get classesDuePick;

  /// No description provided for @classesDueNoneBody.
  ///
  /// In en, this message translates to:
  /// **'No due date — students can submit any time.'**
  String get classesDueNoneBody;

  /// No description provided for @classesDueAt.
  ///
  /// In en, this message translates to:
  /// **'Due by {date}'**
  String classesDueAt(String date);

  /// No description provided for @classesPreview.
  ///
  /// In en, this message translates to:
  /// **'Selected questions · {count}'**
  String classesPreview(int count);

  /// No description provided for @classesReshuffle.
  ///
  /// In en, this message translates to:
  /// **'Reshuffle'**
  String get classesReshuffle;

  /// No description provided for @classesKeyNotice.
  ///
  /// In en, this message translates to:
  /// **'Students can’t see the answer key in advance — the server does the scoring. Each student submits once.'**
  String get classesKeyNotice;

  /// No description provided for @classesSendAssignment.
  ///
  /// In en, this message translates to:
  /// **'Set assignment'**
  String get classesSendAssignment;

  /// No description provided for @classesSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Answers submitted'**
  String get classesSubmitted;

  /// No description provided for @classesSubmitNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection — answers are saved on this device. Send them again later.'**
  String get classesSubmitNetwork;

  /// No description provided for @classesSubmitRejected.
  ///
  /// In en, this message translates to:
  /// **'The server didn’t accept the answers: time or the due date ran out, or it was already submitted.'**
  String get classesSubmitRejected;

  /// No description provided for @classesAssignmentMissing.
  ///
  /// In en, this message translates to:
  /// **'Assignment not found'**
  String get classesAssignmentMissing;

  /// No description provided for @classesMetricQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get classesMetricQuestions;

  /// No description provided for @classesMetricLimit.
  ///
  /// In en, this message translates to:
  /// **'Time limit'**
  String get classesMetricLimit;

  /// No description provided for @classesMetricDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get classesMetricDue;

  /// No description provided for @classesMetricSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get classesMetricSubmitted;

  /// No description provided for @classesMetricAverage.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get classesMetricAverage;

  /// No description provided for @classesPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Answers not sent yet'**
  String get classesPendingTitle;

  /// No description provided for @classesPendingBody.
  ///
  /// In en, this message translates to:
  /// **'They’re saved on this device. Send them once you’re online — the server accepts them within the time limit.'**
  String get classesPendingBody;

  /// No description provided for @classesResend.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get classesResend;

  /// No description provided for @classesOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Past due'**
  String get classesOverdueTitle;

  /// No description provided for @classesOverdueBody.
  ///
  /// In en, this message translates to:
  /// **'This assignment can no longer be submitted.'**
  String get classesOverdueBody;

  /// No description provided for @classesOutdatedPack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question in this assignment isn’t in your app’s content. Update the app.} other{{count} questions in this assignment aren’t in your app’s content. Update the app.}}'**
  String classesOutdatedPack(int count);

  /// No description provided for @classesStartNotice.
  ///
  /// In en, this message translates to:
  /// **'Once you start you have {minutes} min — the clock doesn’t stop, and answers are sent automatically when time is up. One submission only; sending needs internet.'**
  String classesStartNotice(int minutes);

  /// No description provided for @classesStartNoticeNoLimit.
  ///
  /// In en, this message translates to:
  /// **'No time limit. Answers are sent once and can’t be resubmitted; sending needs internet.'**
  String get classesStartNoticeNoLimit;

  /// No description provided for @classesStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get classesStart;

  /// No description provided for @classesSubmittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String classesSubmittedAt(String date);

  /// No description provided for @classesServerScore.
  ///
  /// In en, this message translates to:
  /// **'Scored by the server'**
  String get classesServerScore;

  /// No description provided for @classesResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get classesResults;

  /// No description provided for @classesColStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get classesColStudent;

  /// No description provided for @classesColScore.
  ///
  /// In en, this message translates to:
  /// **'Score · %'**
  String get classesColScore;

  /// No description provided for @classesNotSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Not submitted'**
  String get classesNotSubmitted;

  /// No description provided for @classesByQuestion.
  ///
  /// In en, this message translates to:
  /// **'By question'**
  String get classesByQuestion;

  /// No description provided for @classesByQuestionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No one has submitted yet.'**
  String get classesByQuestionEmpty;

  /// No description provided for @classesWrongOf.
  ///
  /// In en, this message translates to:
  /// **'{wrong}/{total} wrong'**
  String classesWrongOf(int wrong, int total);

  /// No description provided for @classesSending.
  ///
  /// In en, this message translates to:
  /// **'Sending answers…'**
  String get classesSending;

  /// No description provided for @classesMyProgress.
  ///
  /// In en, this message translates to:
  /// **'My progress'**
  String get classesMyProgress;

  /// No description provided for @classesDoneOf.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} assignments done'**
  String classesDoneOf(int done, int total);

  /// No description provided for @classesAverage.
  ///
  /// In en, this message translates to:
  /// **'Average score: {avg}%'**
  String classesAverage(int avg);

  /// No description provided for @classesStudentResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Student’s result'**
  String get classesStudentResultTitle;

  /// No description provided for @classesStudentAnswer.
  ///
  /// In en, this message translates to:
  /// **'Student’s answer'**
  String get classesStudentAnswer;

  /// No description provided for @classesInviteMore.
  ///
  /// In en, this message translates to:
  /// **'Invite more students'**
  String get classesInviteMore;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile and settings'**
  String get profileTitle;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @profileGuestSub.
  ///
  /// In en, this message translates to:
  /// **'Content is open without an account'**
  String get profileGuestSub;

  /// No description provided for @profileGuestLocal.
  ///
  /// In en, this message translates to:
  /// **'Data stays on this device only'**
  String get profileGuestLocal;

  /// No description provided for @profileDemoSession.
  ///
  /// In en, this message translates to:
  /// **'Demo session · debug build'**
  String get profileDemoSession;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// No description provided for @profileRoleSub.
  ///
  /// In en, this message translates to:
  /// **'Home adapts to your role'**
  String get profileRoleSub;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get profileUnits;

  /// No description provided for @profileUnitsSi.
  ///
  /// In en, this message translates to:
  /// **'SI (mmol/L, µmol/L)'**
  String get profileUnitsSi;

  /// No description provided for @profileUnitsConventional.
  ///
  /// In en, this message translates to:
  /// **'Conventional (mg/dL)'**
  String get profileUnitsConventional;

  /// No description provided for @profileAttestation.
  ///
  /// In en, this message translates to:
  /// **'Knowledge & Skills Assessment'**
  String get profileAttestation;

  /// No description provided for @profileAttestationAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get profileAttestationAuto;

  /// No description provided for @profileAttestationUz.
  ///
  /// In en, this message translates to:
  /// **'Uzbekistan'**
  String get profileAttestationUz;

  /// No description provided for @profileAttestationNone.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get profileAttestationNone;

  /// No description provided for @profileAttestationNote.
  ///
  /// In en, this message translates to:
  /// **'Shows the Knowledge & Skills Assessment section (Uzbekistan) in any interface language. Automatic: shown when the language is Uzbek or the device region is Uzbekistan.'**
  String get profileAttestationNote;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeRowSub.
  ///
  /// In en, this message translates to:
  /// **'App colors and title type'**
  String get themeRowSub;

  /// No description provided for @themeCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current theme'**
  String get themeCurrent;

  /// No description provided for @themeClassicName.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get themeClassicName;

  /// No description provided for @themeClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'LabGuide’s signature green'**
  String get themeClassicDesc;

  /// No description provided for @themeIvoryName.
  ///
  /// In en, this message translates to:
  /// **'Ivory'**
  String get themeIvoryName;

  /// No description provided for @themeIvoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Ivory, ink and gold with elegant serif titles'**
  String get themeIvoryDesc;

  /// No description provided for @themeModeSection.
  ///
  /// In en, this message translates to:
  /// **'Light or dark'**
  String get themeModeSection;

  /// No description provided for @themeSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get themeSelected;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy and data'**
  String get profilePrivacy;

  /// No description provided for @profilePrivacySub.
  ///
  /// In en, this message translates to:
  /// **'Data and account controls'**
  String get profilePrivacySub;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback & help'**
  String get supportTitle;

  /// No description provided for @supportSub.
  ///
  /// In en, this message translates to:
  /// **'Suggestion, bug or question — replies arrive here'**
  String get supportSub;

  /// No description provided for @supportNew.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get supportNew;

  /// No description provided for @supportEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get supportEmptyTitle;

  /// No description provided for @supportEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Send a suggestion, report a bug or ask a question — the reply appears here.'**
  String get supportEmptyBody;

  /// No description provided for @supportKind.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get supportKind;

  /// No description provided for @supportKindSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggestion'**
  String get supportKindSuggestion;

  /// No description provided for @supportKindBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get supportKindBug;

  /// No description provided for @supportKindQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get supportKindQuestion;

  /// No description provided for @supportSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get supportSubject;

  /// No description provided for @supportSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'In short: what is it about?'**
  String get supportSubjectHint;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get supportMessage;

  /// No description provided for @supportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Details: which screen, what you did and what you expected'**
  String get supportMessageHint;

  /// No description provided for @supportAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach a screenshot (optional)'**
  String get supportAttach;

  /// No description provided for @supportAttachRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get supportAttachRemove;

  /// No description provided for @supportAttachTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The image is larger than 5 MB. Choose a smaller one.'**
  String get supportAttachTooLarge;

  /// No description provided for @supportAttachType.
  ///
  /// In en, this message translates to:
  /// **'PNG or JPEG only.'**
  String get supportAttachType;

  /// No description provided for @supportPhiNotice.
  ///
  /// In en, this message translates to:
  /// **'Make sure the screenshot shows no patient name, date of birth, record number or other personal data.'**
  String get supportPhiNotice;

  /// No description provided for @supportSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get supportSend;

  /// No description provided for @supportSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get supportSent;

  /// No description provided for @supportReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply…'**
  String get supportReplyHint;

  /// No description provided for @supportTeam.
  ///
  /// In en, this message translates to:
  /// **'LabGuide team'**
  String get supportTeam;

  /// No description provided for @supportYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get supportYou;

  /// No description provided for @supportUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get supportUser;

  /// No description provided for @supportHumanReplies.
  ///
  /// In en, this message translates to:
  /// **'Replies are written by the LabGuide team; nothing is sent automatically.'**
  String get supportHumanReplies;

  /// No description provided for @supportStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get supportStatusNew;

  /// No description provided for @supportStatusInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get supportStatusInReview;

  /// No description provided for @supportStatusAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get supportStatusAnswered;

  /// No description provided for @supportStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get supportStatusClosed;

  /// No description provided for @supportUnread.
  ///
  /// In en, this message translates to:
  /// **'New reply'**
  String get supportUnread;

  /// No description provided for @supportUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} new {count, plural, =1{reply} other{replies}}'**
  String supportUnreadCount(int count);

  /// No description provided for @supportSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to send a request'**
  String get supportSignInTitle;

  /// No description provided for @supportSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Signing in with email lets us deliver the reply to you. Data on this device stays as it is.'**
  String get supportSignInBody;

  /// No description provided for @supportUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Server not connected yet'**
  String get supportUnavailableTitle;

  /// No description provided for @supportUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This build has no account, feedback or groups server yet. Once connected, it works right here.'**
  String get supportUnavailableBody;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t connect. Check the internet and try again.'**
  String get errNetwork;

  /// No description provided for @errRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again a bit later.'**
  String get errRateLimited;

  /// No description provided for @errInvalidSupport.
  ///
  /// In en, this message translates to:
  /// **'The subject needs at least 3 characters and the message can’t be empty.'**
  String get errInvalidSupport;

  /// No description provided for @errForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don’t have access to this.'**
  String get errForbidden;

  /// No description provided for @errSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get errSessionExpired;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'That didn’t work. Please try again.'**
  String get errGeneric;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// No description provided for @accountDeleteSub.
  ///
  /// In en, this message translates to:
  /// **'Removes your server account, requests and group memberships'**
  String get accountDeleteSub;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your account, sign-in methods (Google/Apple links), group memberships and results, “Feedback & help” requests and your community questions and answers are permanently removed from the server. If you are a teacher, the groups you created are deleted too. This can’t be undone. The text of complaints you sent in the app stays, no longer linked to the account. Data on this device is cleared as well.'**
  String get accountDeleteBody;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @adminTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get adminTitle;

  /// No description provided for @adminSub.
  ///
  /// In en, this message translates to:
  /// **'Moderation, support, content, admins'**
  String get adminSub;

  /// No description provided for @adminMfaTitle.
  ///
  /// In en, this message translates to:
  /// **'Two-step protection'**
  String get adminMfaTitle;

  /// No description provided for @adminMfaEnrollBody.
  ///
  /// In en, this message translates to:
  /// **'The admin panel needs an authenticator app (Google Authenticator, Microsoft Authenticator, 1Password…). Add the key to the app and enter the 6-digit code it shows.'**
  String get adminMfaEnrollBody;

  /// No description provided for @adminMfaVerifyBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your authenticator app.'**
  String get adminMfaVerifyBody;

  /// No description provided for @adminMfaSecret.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get adminMfaSecret;

  /// No description provided for @adminMfaCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy key'**
  String get adminMfaCopy;

  /// No description provided for @adminMfaOpen.
  ///
  /// In en, this message translates to:
  /// **'Open in authenticator'**
  String get adminMfaOpen;

  /// No description provided for @adminMfaCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get adminMfaCode;

  /// No description provided for @adminMfaVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get adminMfaVerify;

  /// No description provided for @adminMfaWrong.
  ///
  /// In en, this message translates to:
  /// **'The code is wrong or expired. Enter the current code from the app.'**
  String get adminMfaWrong;

  /// No description provided for @adminCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get adminCopied;

  /// No description provided for @adminForbiddenTitle.
  ///
  /// In en, this message translates to:
  /// **'Admins only'**
  String get adminForbiddenTitle;

  /// No description provided for @adminForbiddenBody.
  ///
  /// In en, this message translates to:
  /// **'Admin access is granted by the server — the role or email in the app can’t change that.'**
  String get adminForbiddenBody;

  /// No description provided for @adminStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get adminStats;

  /// No description provided for @adminRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get adminRegistered;

  /// No description provided for @adminNewToday.
  ///
  /// In en, this message translates to:
  /// **'New today'**
  String get adminNewToday;

  /// No description provided for @adminNew7.
  ///
  /// In en, this message translates to:
  /// **'New, 7 days'**
  String get adminNew7;

  /// No description provided for @adminNew30.
  ///
  /// In en, this message translates to:
  /// **'New, 30 days'**
  String get adminNew30;

  /// No description provided for @adminActiveToday.
  ///
  /// In en, this message translates to:
  /// **'Active today'**
  String get adminActiveToday;

  /// No description provided for @adminActive7.
  ///
  /// In en, this message translates to:
  /// **'Active, 7 days'**
  String get adminActive7;

  /// No description provided for @adminActive30.
  ///
  /// In en, this message translates to:
  /// **'Active, 30 days'**
  String get adminActive30;

  /// No description provided for @adminDefinitions.
  ///
  /// In en, this message translates to:
  /// **'Registered — an account whose email was confirmed with a code; guests and unconfirmed sign-ups aren’t counted. New — the day the email was first confirmed. Active — opened the app while signed in at least once in the period. Days use Tashkent time; “7 days” includes today.'**
  String get adminDefinitions;

  /// No description provided for @adminByRole.
  ///
  /// In en, this message translates to:
  /// **'By role'**
  String get adminByRole;

  /// No description provided for @adminByLanguage.
  ///
  /// In en, this message translates to:
  /// **'By language'**
  String get adminByLanguage;

  /// No description provided for @adminNoProfile.
  ///
  /// In en, this message translates to:
  /// **'No profile yet: {count}'**
  String adminNoProfile(int count);

  /// No description provided for @adminInbox.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get adminInbox;

  /// No description provided for @adminAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting reply: {count}'**
  String adminAwaiting(int count);

  /// No description provided for @adminAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminAllStatuses;

  /// No description provided for @adminUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminUsers;

  /// No description provided for @adminAudit.
  ///
  /// In en, this message translates to:
  /// **'Action log'**
  String get adminAudit;

  /// No description provided for @adminAuditEmpty.
  ///
  /// In en, this message translates to:
  /// **'No actions yet'**
  String get adminAuditEmpty;

  /// No description provided for @adminSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by email'**
  String get adminSearchHint;

  /// No description provided for @adminAllRoles.
  ///
  /// In en, this message translates to:
  /// **'All roles'**
  String get adminAllRoles;

  /// No description provided for @adminAllLanguages.
  ///
  /// In en, this message translates to:
  /// **'All languages'**
  String get adminAllLanguages;

  /// No description provided for @adminShowEmail.
  ///
  /// In en, this message translates to:
  /// **'Show email (logged)'**
  String get adminShowEmail;

  /// No description provided for @adminReviewer.
  ///
  /// In en, this message translates to:
  /// **'Content reviewer'**
  String get adminReviewer;

  /// No description provided for @adminPage.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to} of {total}'**
  String adminPage(int from, int to, int total);

  /// No description provided for @adminPrev.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get adminPrev;

  /// No description provided for @adminNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get adminNext;

  /// No description provided for @adminRegisteredOn.
  ///
  /// In en, this message translates to:
  /// **'Registered: {date}'**
  String adminRegisteredOn(String date);

  /// No description provided for @adminLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last active: {date}'**
  String adminLastSeen(String date);

  /// No description provided for @adminNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get adminNoUsers;

  /// No description provided for @adminReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your reply'**
  String get adminReplyHint;

  /// No description provided for @adminSendReply.
  ///
  /// In en, this message translates to:
  /// **'Send reply'**
  String get adminSendReply;

  /// No description provided for @adminStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminStatus;

  /// No description provided for @adminRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get adminRefresh;

  /// No description provided for @adminActionSupportReply.
  ///
  /// In en, this message translates to:
  /// **'Replied to request'**
  String get adminActionSupportReply;

  /// No description provided for @adminActionSupportStatus.
  ///
  /// In en, this message translates to:
  /// **'Request status changed'**
  String get adminActionSupportStatus;

  /// No description provided for @adminActionRevealEmail.
  ///
  /// In en, this message translates to:
  /// **'Email viewed'**
  String get adminActionRevealEmail;

  /// No description provided for @adminActionReviewerGranted.
  ///
  /// In en, this message translates to:
  /// **'Reviewer access granted'**
  String get adminActionReviewerGranted;

  /// No description provided for @adminActionReviewerRevoked.
  ///
  /// In en, this message translates to:
  /// **'Reviewer access revoked'**
  String get adminActionReviewerRevoked;

  /// No description provided for @adminActionAdminGranted.
  ///
  /// In en, this message translates to:
  /// **'Admin access granted'**
  String get adminActionAdminGranted;

  /// No description provided for @adminActionAdminRevoked.
  ///
  /// In en, this message translates to:
  /// **'Admin access revoked'**
  String get adminActionAdminRevoked;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get profileSignIn;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileRestartSetup.
  ///
  /// In en, this message translates to:
  /// **'Restart setup'**
  String get profileRestartSetup;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks, QC records, notes and practice progress stay on this device. If someone else will use it, delete them too.'**
  String get profileSignOutBody;

  /// No description provided for @profileSignOutDelete.
  ///
  /// In en, this message translates to:
  /// **'Sign out and delete'**
  String get profileSignOutDelete;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String profileVersion(String version);

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy and data'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'The core features work without an account (guest mode): settings, bookmarks, QC records, your instruments and practice results stay on this device. An account is optional (email code, Google or Apple) and is needed for groups, the community and “Feedback & help”. Then data is stored on a Cloudflare server (Eastern Europe, outside Uzbekistan): your email only as a hash and a masked form, sign-in method, role, language, last activity time (to the minute); in a group — your nickname or sequence number, test answers and scores; the text of requests and complaints. From Google/Apple only the account identifier and email are used; the token is not stored. A teacher sees only their own group. No ads, analytics or tracking. Full text: the “Privacy policy” link.'**
  String get privacyBody;

  /// No description provided for @privacyBodyLocal.
  ///
  /// In en, this message translates to:
  /// **'This build has no server connected: the app sends nothing to a server. Settings, bookmarks, QC records, your instruments and practice results stay on this device (they may be included in the device backup). No ads or tracking.'**
  String get privacyBodyLocal;

  /// No description provided for @privacyTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get privacyTerms;

  /// No description provided for @privacyTermsSub.
  ///
  /// In en, this message translates to:
  /// **'Rules for using the app and your account'**
  String get privacyTermsSub;

  /// No description provided for @privacyDeleteLocal.
  ///
  /// In en, this message translates to:
  /// **'Delete local data'**
  String get privacyDeleteLocal;

  /// No description provided for @privacyDeleteLocalSub.
  ///
  /// In en, this message translates to:
  /// **'Settings, bookmarks, drafts, QC records and practice progress'**
  String get privacyDeleteLocalSub;

  /// No description provided for @privacyDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete local data?'**
  String get privacyDeleteConfirmTitle;

  /// No description provided for @privacyDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Settings, bookmarks, drafts, all QC records (runs and targets) and practice progress on this device will be removed. This can’t be undone — if needed, copy a QC backup first (Lab → Quality control).'**
  String get privacyDeleteConfirmBody;

  /// No description provided for @privacyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Local data deleted'**
  String get privacyDeleted;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsTitle;

  /// No description provided for @termsBody.
  ///
  /// In en, this message translates to:
  /// **'LabGuide is a free clinical laboratory reference and learning app. By using the app you agree to these terms.\n\n1. Medical limitation. LabGuide does not diagnose, prescribe treatment or medicines, and does not replace your laboratory’s approved procedures, reagent and analyzer instructions (IFU) or a physician’s judgment. Every item shows its source; when making decisions, rely on the original source and your institution’s rules.\n\n2. Account. Some features (groups, tests, community, support requests) require signing up with email. You are responsible for your account’s security and for actions taken through it. You can delete your account at any time: Profile → Delete account.\n\n3. Teacher and student groups. When a student joins a group, the teacher sees their nickname (or seat number) and test results. Teachers use groups for educational purposes only.\n\n4. User content. You are responsible for what you post in the community and in support requests. Abuse, illegal content, advertising, other people’s personal data and non-consensual intimate images are strictly prohibited. Such content is removed, and the offending account may be restricted or deleted. You can report any message with “Report”.\n\n5. Copyright. The app’s texts, slides, tests and design belong to the LabGuide authors; external sources are shown with their own licenses. They may not be copied or distributed for commercial purposes.\n\n6. Service. The app is provided “as is”; outages and errors may occur, and we fix them as quickly as we can. We will notify you in the app if these terms change.\n\n7. Privacy. How your data is used is described in the privacy policy: labguide.nfcstore.uz/privacy\n\n8. Contact: labguide@nfcstore.uz'**
  String get termsBody;

  /// No description provided for @citePage.
  ///
  /// In en, this message translates to:
  /// **'p. {page}'**
  String citePage(String page);

  /// No description provided for @rightsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Distribution rights not confirmed'**
  String get rightsUnknown;

  /// No description provided for @rightsPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal study only — not distributed'**
  String get rightsPersonal;

  /// No description provided for @rightsPermitted.
  ///
  /// In en, this message translates to:
  /// **'Distribution permission recorded'**
  String get rightsPermitted;

  /// No description provided for @rightsDenied.
  ///
  /// In en, this message translates to:
  /// **'Distribution not permitted'**
  String get rightsDenied;

  /// No description provided for @catBiochemistry.
  ///
  /// In en, this message translates to:
  /// **'Biochemistry'**
  String get catBiochemistry;

  /// No description provided for @catClinicalLab.
  ///
  /// In en, this message translates to:
  /// **'Clinical laboratory'**
  String get catClinicalLab;

  /// No description provided for @catInstruments.
  ///
  /// In en, this message translates to:
  /// **'Instruments'**
  String get catInstruments;

  /// No description provided for @catMethods.
  ///
  /// In en, this message translates to:
  /// **'Methods'**
  String get catMethods;

  /// No description provided for @catTests.
  ///
  /// In en, this message translates to:
  /// **'Laboratory tests'**
  String get catTests;

  /// No description provided for @kindBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get kindBook;

  /// No description provided for @kindManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get kindManual;

  /// No description provided for @kindMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get kindMethod;

  /// No description provided for @kindIfu.
  ///
  /// In en, this message translates to:
  /// **'IFU'**
  String get kindIfu;

  /// No description provided for @kindArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get kindArticle;

  /// No description provided for @kindQuestionSet.
  ///
  /// In en, this message translates to:
  /// **'Question set'**
  String get kindQuestionSet;

  /// No description provided for @kindWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get kindWebsite;

  /// No description provided for @libAccessOpen.
  ///
  /// In en, this message translates to:
  /// **'Open license · {licence}'**
  String libAccessOpen(String licence);

  /// No description provided for @libAccessFree.
  ///
  /// In en, this message translates to:
  /// **'Free to read · link only'**
  String get libAccessFree;

  /// No description provided for @libAccessCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog record only'**
  String get libAccessCatalog;

  /// No description provided for @libOpenSource.
  ///
  /// In en, this message translates to:
  /// **'Open the official page'**
  String get libOpenSource;

  /// No description provided for @libChecked.
  ///
  /// In en, this message translates to:
  /// **'Page and license checked: {date}'**
  String libChecked(String date);

  /// No description provided for @libItemPack.
  ///
  /// In en, this message translates to:
  /// **'Offline pack · {size}'**
  String libItemPack(String size);

  /// No description provided for @libItemNoPack.
  ///
  /// In en, this message translates to:
  /// **'Not available as a shared offline pack'**
  String get libItemNoPack;

  /// No description provided for @libItemSupersedes.
  ///
  /// In en, this message translates to:
  /// **'Newer edition of: {title}'**
  String libItemSupersedes(String title);

  /// No description provided for @libForYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get libForYou;

  /// No description provided for @libMoreSections.
  ///
  /// In en, this message translates to:
  /// **'More sections'**
  String get libMoreSections;

  /// No description provided for @libSearchEntry.
  ///
  /// In en, this message translates to:
  /// **'Search books, authors, topics'**
  String get libSearchEntry;

  /// No description provided for @libBooksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sources · search and filters'**
  String libBooksCount(int count);

  /// No description provided for @libIntake.
  ///
  /// In en, this message translates to:
  /// **'Adding materials'**
  String get libIntake;

  /// No description provided for @libIntakeSub.
  ///
  /// In en, this message translates to:
  /// **'For teachers and editors: what to send, rights, review'**
  String get libIntakeSub;

  /// No description provided for @libContinueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get libContinueReading;

  /// No description provided for @libSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search the library'**
  String get libSearchLabel;

  /// No description provided for @libSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Title, author, topic…'**
  String get libSearchHint;

  /// No description provided for @libFilterLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get libFilterLanguage;

  /// No description provided for @libFilterTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get libFilterTopic;

  /// No description provided for @libFilterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get libFilterType;

  /// No description provided for @libFilterSectionField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get libFilterSectionField;

  /// No description provided for @libFilterSectionGroup.
  ///
  /// In en, this message translates to:
  /// **'Test group'**
  String get libFilterSectionGroup;

  /// No description provided for @libFilterSectionKind.
  ///
  /// In en, this message translates to:
  /// **'Material type'**
  String get libFilterSectionKind;

  /// No description provided for @libFilterSectionOpen.
  ///
  /// In en, this message translates to:
  /// **'How it opens'**
  String get libFilterSectionOpen;

  /// No description provided for @libFilterChoose.
  ///
  /// In en, this message translates to:
  /// **'{filter}: choose'**
  String libFilterChoose(String filter);

  /// No description provided for @libResultCount.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} materials'**
  String libResultCount(int shown, int total);

  /// No description provided for @libClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get libClearFilters;

  /// No description provided for @libFilteredEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No materials match these filters'**
  String get libFilteredEmptyTitle;

  /// No description provided for @libFilteredEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Remove one filter or try another word — for example an author’s surname or “urine”.'**
  String get libFilteredEmptyBody;

  /// No description provided for @libOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Link · external website'**
  String get libOpenLink;

  /// No description provided for @libOpenLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Opens in your browser: {host}'**
  String libOpenLinkHint(String host);

  /// No description provided for @libOpenInApp.
  ///
  /// In en, this message translates to:
  /// **'In-app file'**
  String get libOpenInApp;

  /// No description provided for @libOpenInAppHint.
  ///
  /// In en, this message translates to:
  /// **'Read inside the app — no internet needed'**
  String get libOpenInAppHint;

  /// No description provided for @libOpenDownload.
  ///
  /// In en, this message translates to:
  /// **'Downloadable book'**
  String get libOpenDownload;

  /// No description provided for @libOpenDownloadHint.
  ///
  /// In en, this message translates to:
  /// **'Read in the app after download · {size}'**
  String libOpenDownloadHint(String size);

  /// No description provided for @libOpenPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get libOpenPending;

  /// No description provided for @libOpenPendingHint.
  ///
  /// In en, this message translates to:
  /// **'Not received yet — cannot be opened'**
  String get libOpenPendingHint;

  /// No description provided for @libOpenReceivedHint.
  ///
  /// In en, this message translates to:
  /// **'File received and being checked — not available yet'**
  String get libOpenReceivedHint;

  /// No description provided for @libOpenRecordHint.
  ///
  /// In en, this message translates to:
  /// **'No distribution rights recorded — not opened in the app'**
  String get libOpenRecordHint;

  /// No description provided for @libOpenLinkShort.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get libOpenLinkShort;

  /// No description provided for @libOpenInAppShort.
  ///
  /// In en, this message translates to:
  /// **'In the app'**
  String get libOpenInAppShort;

  /// No description provided for @libOpenDownloadShort.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get libOpenDownloadShort;

  /// No description provided for @libOpenRecordShort.
  ///
  /// In en, this message translates to:
  /// **'Record only'**
  String get libOpenRecordShort;

  /// No description provided for @libItemRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get libItemRead;

  /// No description provided for @libItemContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue from page {page}'**
  String libItemContinue(int page);

  /// No description provided for @libItemCannotOpen.
  ///
  /// In en, this message translates to:
  /// **'Cannot be opened'**
  String get libItemCannotOpen;

  /// No description provided for @libDownloadUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The download server is not connected yet — the book can’t be downloaded for now.'**
  String get libDownloadUnavailable;

  /// No description provided for @libDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get libDetailsTitle;

  /// No description provided for @libFieldAuthors.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get libFieldAuthors;

  /// No description provided for @libFieldYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get libFieldYear;

  /// No description provided for @libFieldEdition.
  ///
  /// In en, this message translates to:
  /// **'Edition'**
  String get libFieldEdition;

  /// No description provided for @libFieldPublisher.
  ///
  /// In en, this message translates to:
  /// **'Publisher'**
  String get libFieldPublisher;

  /// No description provided for @libFieldAccess.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get libFieldAccess;

  /// No description provided for @libFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get libFieldStatus;

  /// No description provided for @libFieldRights.
  ///
  /// In en, this message translates to:
  /// **'Distribution rights'**
  String get libFieldRights;

  /// No description provided for @libFieldRightsRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded: {date} · {by}'**
  String libFieldRightsRecorded(String date, String by);

  /// No description provided for @libFieldTopics.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get libFieldTopics;

  /// No description provided for @libFieldPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get libFieldPages;

  /// No description provided for @libStateNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Not received yet'**
  String get libStateNotReceived;

  /// No description provided for @libStateReceived.
  ///
  /// In en, this message translates to:
  /// **'Received, being checked'**
  String get libStateReceived;

  /// No description provided for @libStateCataloged.
  ///
  /// In en, this message translates to:
  /// **'Cataloged'**
  String get libStateCataloged;

  /// No description provided for @libStateLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked to cards'**
  String get libStateLinked;

  /// No description provided for @libStateReviewed.
  ///
  /// In en, this message translates to:
  /// **'Approved by a teacher'**
  String get libStateReviewed;

  /// No description provided for @libProvidedByTeacher.
  ///
  /// In en, this message translates to:
  /// **'Provided by a teacher'**
  String get libProvidedByTeacher;

  /// No description provided for @libItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Material not found'**
  String get libItemNotFound;

  /// No description provided for @libItemNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The content pack may have been updated. Go back to the catalog.'**
  String get libItemNotFoundBody;

  /// No description provided for @libItemUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This material is not available in your language'**
  String get libItemUnavailable;

  /// No description provided for @libItemUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This material is currently available only in another language. Change the interface language or go back to the catalog.'**
  String get libItemUnavailableBody;

  /// No description provided for @libBackToCatalog.
  ///
  /// In en, this message translates to:
  /// **'Back to catalog'**
  String get libBackToCatalog;

  /// No description provided for @readerTitle.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get readerTitle;

  /// No description provided for @readerPageOf.
  ///
  /// In en, this message translates to:
  /// **'{page} of {total}'**
  String readerPageOf(int page, int total);

  /// No description provided for @readerToc.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get readerToc;

  /// No description provided for @readerTocEmpty.
  ///
  /// In en, this message translates to:
  /// **'This file has no table of contents'**
  String get readerTocEmpty;

  /// No description provided for @readerTocEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Go to a page or bookmark the place you need.'**
  String get readerTocEmptyBody;

  /// No description provided for @readerBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get readerBookmarks;

  /// No description provided for @readerAddBookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this page'**
  String get readerAddBookmark;

  /// No description provided for @readerBookmarkName.
  ///
  /// In en, this message translates to:
  /// **'Bookmark name'**
  String get readerBookmarkName;

  /// No description provided for @readerBookmarkNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example: key table'**
  String get readerBookmarkNameHint;

  /// No description provided for @readerBookmarkSaved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark saved: page {page}'**
  String readerBookmarkSaved(int page);

  /// No description provided for @readerBookmarkRemoved.
  ///
  /// In en, this message translates to:
  /// **'Bookmark removed'**
  String get readerBookmarkRemoved;

  /// No description provided for @readerBookmarkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get readerBookmarkRemove;

  /// No description provided for @readerBookmarksEmpty.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet'**
  String get readerBookmarksEmpty;

  /// No description provided for @readerBookmarksEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'On the page you need, tap “Bookmark this page” — then return with one tap.'**
  String get readerBookmarksEmptyBody;

  /// No description provided for @readerPageLabel.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String readerPageLabel(int page);

  /// No description provided for @readerGoTo.
  ///
  /// In en, this message translates to:
  /// **'Go to page'**
  String get readerGoTo;

  /// No description provided for @readerGoToShort.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get readerGoToShort;

  /// No description provided for @readerGoToHint.
  ///
  /// In en, this message translates to:
  /// **'1 to {total}'**
  String readerGoToHint(int total);

  /// No description provided for @readerGoToError.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 1 to {total}'**
  String readerGoToError(int total);

  /// No description provided for @readerGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get readerGo;

  /// No description provided for @readerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get readerSave;

  /// No description provided for @readerRenameBookmark.
  ///
  /// In en, this message translates to:
  /// **'Rename bookmark'**
  String get readerRenameBookmark;

  /// No description provided for @libFieldProvidedBy.
  ///
  /// In en, this message translates to:
  /// **'Provided by'**
  String get libFieldProvidedBy;

  /// No description provided for @libQueryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another word — for example an author’s surname, “urine” or “biochemistry”.'**
  String get libQueryEmptyBody;

  /// No description provided for @readerZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get readerZoomIn;

  /// No description provided for @readerZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get readerZoomOut;

  /// No description provided for @readerResumed.
  ///
  /// In en, this message translates to:
  /// **'Resumed at page {page}'**
  String readerResumed(int page);

  /// No description provided for @readerFromStart.
  ///
  /// In en, this message translates to:
  /// **'From start'**
  String get readerFromStart;

  /// No description provided for @readerLoading.
  ///
  /// In en, this message translates to:
  /// **'Opening the file…'**
  String get readerLoading;

  /// No description provided for @readerFileMissing.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get readerFileMissing;

  /// No description provided for @readerFileMissingBody.
  ///
  /// In en, this message translates to:
  /// **'This file isn’t in the app. Try updating the app.'**
  String get readerFileMissingBody;

  /// No description provided for @readerFileCorrupted.
  ///
  /// In en, this message translates to:
  /// **'The file failed verification'**
  String get readerFileCorrupted;

  /// No description provided for @readerFileCorruptedBody.
  ///
  /// In en, this message translates to:
  /// **'The file size or checksum doesn’t match the catalog — it may be damaged or replaced, so it wasn’t opened.'**
  String get readerFileCorruptedBody;

  /// No description provided for @readerOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the PDF'**
  String get readerOpenFailed;

  /// No description provided for @readerBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not available in the app'**
  String get readerBlockedTitle;

  /// No description provided for @readerBlockedRights.
  ///
  /// In en, this message translates to:
  /// **'Only files with fully recorded distribution rights open in the app. This material has no such file.'**
  String get readerBlockedRights;

  /// No description provided for @readerBookmarkedPage.
  ///
  /// In en, this message translates to:
  /// **'This page is bookmarked'**
  String get readerBookmarkedPage;

  /// No description provided for @intakeTitle.
  ///
  /// In en, this message translates to:
  /// **'Adding materials'**
  String get intakeTitle;

  /// No description provided for @intakeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A short guide for teachers and editors'**
  String get intakeSubtitle;

  /// No description provided for @intakeStatus.
  ///
  /// In en, this message translates to:
  /// **'Materials from teachers: {count}. The list grows as materials arrive.'**
  String intakeStatus(int count);

  /// No description provided for @intakeWhatTitle.
  ///
  /// In en, this message translates to:
  /// **'1. What to send'**
  String get intakeWhatTitle;

  /// No description provided for @intakeWhat1.
  ///
  /// In en, this message translates to:
  /// **'The book, manual, method or IFU file (PDF) and its details: title, author, year and edition, publisher, ISBN, language.'**
  String get intakeWhat1;

  /// No description provided for @intakeWhat2.
  ///
  /// In en, this message translates to:
  /// **'Test questions: the question, options, the correct answer, an explanation for each option and the source page.'**
  String get intakeWhat2;

  /// No description provided for @intakeWhat3.
  ///
  /// In en, this message translates to:
  /// **'If there is an old and a new edition — both: differences are reviewed separately.'**
  String get intakeWhat3;

  /// No description provided for @intakeRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'2. Distribution rights'**
  String get intakeRightsTitle;

  /// No description provided for @intakeRights1.
  ///
  /// In en, this message translates to:
  /// **'A shared PDF does not by itself mean it may be distributed to everyone.'**
  String get intakeRights1;

  /// No description provided for @intakeRights2.
  ///
  /// In en, this message translates to:
  /// **'For a file to open in the app for everyone, the rights are fully recorded: who granted them (author or publisher), when, who recorded it, and the evidence — a permission letter or a license link.'**
  String get intakeRights2;

  /// No description provided for @intakeRights3.
  ///
  /// In en, this message translates to:
  /// **'Without that record, the material stays a catalog entry only or for personal use.'**
  String get intakeRights3;

  /// No description provided for @intakeReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'3. How it is checked'**
  String get intakeReviewTitle;

  /// No description provided for @intakeStep1.
  ///
  /// In en, this message translates to:
  /// **'Pending — the material hasn’t arrived yet.'**
  String get intakeStep1;

  /// No description provided for @intakeStep2.
  ///
  /// In en, this message translates to:
  /// **'Received — the file arrived and was logged.'**
  String get intakeStep2;

  /// No description provided for @intakeStep3.
  ///
  /// In en, this message translates to:
  /// **'Cataloged — title, author and edition were checked. Only then can it be cited.'**
  String get intakeStep3;

  /// No description provided for @intakeStep4.
  ///
  /// In en, this message translates to:
  /// **'Linked — tied to test cards and lessons with page numbers.'**
  String get intakeStep4;

  /// No description provided for @intakeStep5.
  ///
  /// In en, this message translates to:
  /// **'Approved — a teacher reviewed it.'**
  String get intakeStep5;

  /// No description provided for @intakeConflict.
  ///
  /// In en, this message translates to:
  /// **'If an old and a new source disagree, neither is written as fact — both positions go to a reviewer.'**
  String get intakeConflict;

  /// No description provided for @intakeNeverTitle.
  ///
  /// In en, this message translates to:
  /// **'What we never do'**
  String get intakeNeverTitle;

  /// No description provided for @intakeNever1.
  ///
  /// In en, this message translates to:
  /// **'Show a material that hasn’t arrived as “available”.'**
  String get intakeNever1;

  /// No description provided for @intakeNever2.
  ///
  /// In en, this message translates to:
  /// **'Guess a page number or write anything the source doesn’t say.'**
  String get intakeNever2;

  /// No description provided for @intakeNever3.
  ///
  /// In en, this message translates to:
  /// **'Distribute a book to everyone without recorded rights.'**
  String get intakeNever3;

  /// No description provided for @intakeContactTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Contact'**
  String get intakeContactTitle;

  /// No description provided for @intakeContactBody.
  ///
  /// In en, this message translates to:
  /// **'Write to the LabGuide team about the material: title, author, edition and rights holder. How to hand over the file is agreed with the team — PDFs can’t be uploaded through the app.'**
  String get intakeContactBody;

  /// No description provided for @intakeContactAction.
  ///
  /// In en, this message translates to:
  /// **'Write to the LabGuide team'**
  String get intakeContactAction;

  /// No description provided for @libReview.
  ///
  /// In en, this message translates to:
  /// **'Review queue'**
  String get libReview;

  /// No description provided for @libReviewSub.
  ///
  /// In en, this message translates to:
  /// **'Source discrepancies and drafts'**
  String get libReviewSub;

  /// No description provided for @reviewDiscrepancies.
  ///
  /// In en, this message translates to:
  /// **'Source discrepancies'**
  String get reviewDiscrepancies;

  /// No description provided for @rvGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviewers only'**
  String get rvGateTitle;

  /// No description provided for @rvGateBody.
  ///
  /// In en, this message translates to:
  /// **'Reviewer rights are granted by an admin. An in-app role (for example, “Teacher”) does not grant them.'**
  String get rvGateBody;

  /// No description provided for @rvSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to review'**
  String get rvSignInTitle;

  /// No description provided for @rvAdminReadOnly.
  ///
  /// In en, this message translates to:
  /// **'As an admin you can see decisions. To review, grant your account reviewer rights (Admin → Users).'**
  String get rvAdminReadOnly;

  /// No description provided for @rvTabCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get rvTabCards;

  /// No description provided for @rvTabQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get rvTabQuestions;

  /// No description provided for @rvTabDiscrepancies.
  ///
  /// In en, this message translates to:
  /// **'Discrepancies'**
  String get rvTabDiscrepancies;

  /// No description provided for @rvMine.
  ///
  /// In en, this message translates to:
  /// **'Your decision: {decision}'**
  String rvMine(String decision);

  /// No description provided for @rvNotSeen.
  ///
  /// In en, this message translates to:
  /// **'Not reviewed by you yet'**
  String get rvNotSeen;

  /// No description provided for @rvCount.
  ///
  /// In en, this message translates to:
  /// **'Decisions: {count}'**
  String rvCount(int count);

  /// No description provided for @rvApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get rvApprove;

  /// No description provided for @rvChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes needed'**
  String get rvChanges;

  /// No description provided for @rvDecisionApprove.
  ///
  /// In en, this message translates to:
  /// **'approved'**
  String get rvDecisionApprove;

  /// No description provided for @rvDecisionChanges.
  ///
  /// In en, this message translates to:
  /// **'changes requested'**
  String get rvDecisionChanges;

  /// No description provided for @rvComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get rvComment;

  /// No description provided for @rvCommentHint.
  ///
  /// In en, this message translates to:
  /// **'What is wrong or what to check (source, page)'**
  String get rvCommentHint;

  /// No description provided for @rvCommentRequired.
  ///
  /// In en, this message translates to:
  /// **'Write a comment for “Changes needed”.'**
  String get rvCommentRequired;

  /// No description provided for @rvSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit decision'**
  String get rvSubmit;

  /// No description provided for @rvSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Decision recorded'**
  String get rvSubmitted;

  /// No description provided for @rvNotAuto.
  ///
  /// In en, this message translates to:
  /// **'A decision does not change the card status by itself: after editorial review it becomes “Reviewed” in the next content pack.'**
  String get rvNotAuto;

  /// No description provided for @rvHistory.
  ///
  /// In en, this message translates to:
  /// **'Decision history'**
  String get rvHistory;

  /// No description provided for @rvYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get rvYou;

  /// No description provided for @rvReviewer.
  ///
  /// In en, this message translates to:
  /// **'Reviewer'**
  String get rvReviewer;

  /// No description provided for @rvNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No decisions yet'**
  String get rvNoHistory;

  /// No description provided for @rvOpenCard.
  ///
  /// In en, this message translates to:
  /// **'Open card'**
  String get rvOpenCard;

  /// No description provided for @rvCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get rvCorrect;

  /// No description provided for @rvBasis.
  ///
  /// In en, this message translates to:
  /// **'Basis'**
  String get rvBasis;

  /// No description provided for @rvYourDecision.
  ///
  /// In en, this message translates to:
  /// **'Your decision'**
  String get rvYourDecision;

  /// No description provided for @rvAllDone.
  ///
  /// In en, this message translates to:
  /// **'All reviewed'**
  String get rvAllDone;

  /// No description provided for @analytePreparedBy.
  ///
  /// In en, this message translates to:
  /// **'Prepared by'**
  String get analytePreparedBy;

  /// No description provided for @analyteEditorial.
  ///
  /// In en, this message translates to:
  /// **'LabGuide editorial team'**
  String get analyteEditorial;

  /// No description provided for @analyteSourcesChecked.
  ///
  /// In en, this message translates to:
  /// **'Sources accessed'**
  String get analyteSourcesChecked;

  /// No description provided for @reviewDiscrepanciesBody.
  ///
  /// In en, this message translates to:
  /// **'When older and newer sources disagree, both positions are listed here for expert review. Neither is published as fact until resolved.'**
  String get reviewDiscrepanciesBody;

  /// No description provided for @reviewNoDiscrepancies.
  ///
  /// In en, this message translates to:
  /// **'No open discrepancies.'**
  String get reviewNoDiscrepancies;

  /// No description provided for @reviewDraftQuestions.
  ///
  /// In en, this message translates to:
  /// **'Draft questions: {count}'**
  String reviewDraftQuestions(int count);

  /// No description provided for @reviewDraftCards.
  ///
  /// In en, this message translates to:
  /// **'Cards awaiting expert review: {count}'**
  String reviewDraftCards(int count);

  /// No description provided for @reviewCatalog.
  ///
  /// In en, this message translates to:
  /// **'Cataloged materials: {count}'**
  String reviewCatalog(int count);

  /// No description provided for @reviewField.
  ///
  /// In en, this message translates to:
  /// **'Field: {field}'**
  String reviewField(String field);

  /// No description provided for @lessonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson topics'**
  String get lessonsTitle;

  /// No description provided for @analyteTreatmentGoals.
  ///
  /// In en, this message translates to:
  /// **'Treatment goals'**
  String get analyteTreatmentGoals;

  /// No description provided for @analyteTreatmentGoalsNotice.
  ///
  /// In en, this message translates to:
  /// **'A treatment goal is set by a physician on the basis of the patient’s full risk assessment; the app does not determine a risk category.'**
  String get analyteTreatmentGoalsNotice;

  /// No description provided for @analyteTreatmentGoalsNotRef.
  ///
  /// In en, this message translates to:
  /// **'Treatment goals are neither reference intervals nor diagnostic limits. Guidelines define risk groups differently — compare values only within one table.'**
  String get analyteTreatmentGoalsNotRef;

  /// Shown under a guideline that has been replaced by newer ones.
  ///
  /// In en, this message translates to:
  /// **'Historical guideline, superseded by {current}. Shown for context only — not for current treatment decisions.'**
  String analyteGoalHistorical(String current);

  /// No description provided for @analyteGoalGuideline.
  ///
  /// In en, this message translates to:
  /// **'{name} · {year}'**
  String analyteGoalGuideline(String name, String year);

  /// No description provided for @analyteAgentCheck.
  ///
  /// In en, this message translates to:
  /// **'Compared with sources'**
  String get analyteAgentCheck;

  /// No description provided for @analyteExpertApproval.
  ///
  /// In en, this message translates to:
  /// **'Expert approval'**
  String get analyteExpertApproval;

  /// No description provided for @classesSeat.
  ///
  /// In en, this message translates to:
  /// **'Student {n}'**
  String classesSeat(String n);

  /// No description provided for @classesQrLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code QR: {code}'**
  String classesQrLabel(String code);

  /// No description provided for @classesTeacherRegisterEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get classesTeacherRegisterEyebrow;

  /// No description provided for @classesTeacherRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Register as a teacher'**
  String get classesTeacherRegisterTitle;

  /// No description provided for @classesTeacherRegisterBody.
  ///
  /// In en, this message translates to:
  /// **'A teacher opens their own class and sees only their students’ results. This isn’t admin access and doesn’t affect other classes.'**
  String get classesTeacherRegisterBody;

  /// No description provided for @classesTeacherRegister.
  ///
  /// In en, this message translates to:
  /// **'Register as a teacher'**
  String get classesTeacherRegister;

  /// No description provided for @classesLocalNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Label (this device only)'**
  String get classesLocalNameTitle;

  /// No description provided for @classesLocalNameBody.
  ///
  /// In en, this message translates to:
  /// **'For example, the student’s name. It isn’t sent to the server and the student can’t see it.'**
  String get classesLocalNameBody;

  /// No description provided for @classesLocalNameHint.
  ///
  /// In en, this message translates to:
  /// **'Empty — remove the label'**
  String get classesLocalNameHint;

  /// No description provided for @classesLocalNameSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get classesLocalNameSave;

  /// No description provided for @classroomPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Course plan'**
  String get classroomPlanTitle;

  /// No description provided for @classroomPlanSub.
  ///
  /// In en, this message translates to:
  /// **'Topics by day: lecture, oral questions, test'**
  String get classroomPlanSub;

  /// No description provided for @classroomTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Topics'**
  String get classroomTopicsTitle;

  /// No description provided for @classroomTopicsSub.
  ///
  /// In en, this message translates to:
  /// **'Topics and tests your teacher has opened'**
  String get classroomTopicsSub;

  /// No description provided for @classroomProgramEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Curriculum'**
  String get classroomProgramEyebrow;

  /// No description provided for @classroomPlanProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} topic tests finished'**
  String classroomPlanProgress(int done, int total);

  /// No description provided for @classroomStartNone.
  ///
  /// In en, this message translates to:
  /// **'No start date — the plan is shown by day number'**
  String get classroomStartNone;

  /// No description provided for @classroomStartAt.
  ///
  /// In en, this message translates to:
  /// **'Day 1: {date}'**
  String classroomStartAt(String date);

  /// No description provided for @classroomStartNote.
  ///
  /// In en, this message translates to:
  /// **'Dates are approximate (Sundays skipped, holidays not counted) and stored only on this device.'**
  String get classroomStartNote;

  /// No description provided for @classroomStartPick.
  ///
  /// In en, this message translates to:
  /// **'Set the start date'**
  String get classroomStartPick;

  /// No description provided for @classroomDayN.
  ///
  /// In en, this message translates to:
  /// **'Day {n}'**
  String classroomDayN(int n);

  /// No description provided for @classroomWeekN.
  ///
  /// In en, this message translates to:
  /// **'Week {n}'**
  String classroomWeekN(int n);

  /// No description provided for @classroomHours.
  ///
  /// In en, this message translates to:
  /// **'{n} h'**
  String classroomHours(int n);

  /// No description provided for @classroomTypeLecture.
  ///
  /// In en, this message translates to:
  /// **'Lecture'**
  String get classroomTypeLecture;

  /// No description provided for @classroomTypePractical.
  ///
  /// In en, this message translates to:
  /// **'Practical'**
  String get classroomTypePractical;

  /// No description provided for @classroomTypeSeminar.
  ///
  /// In en, this message translates to:
  /// **'Seminar'**
  String get classroomTypeSeminar;

  /// No description provided for @classroomTypeAttestation.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get classroomTypeAttestation;

  /// No description provided for @classroomTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get classroomTypeOther;

  /// No description provided for @classroomStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Not opened'**
  String get classroomStatusClosed;

  /// No description provided for @classroomStatusOpened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get classroomStatusOpened;

  /// No description provided for @classroomStatusLectured.
  ///
  /// In en, this message translates to:
  /// **'Taught'**
  String get classroomStatusLectured;

  /// No description provided for @classroomStatusOral.
  ///
  /// In en, this message translates to:
  /// **'Oral round done'**
  String get classroomStatusOral;

  /// No description provided for @classroomStatusTestRunning.
  ///
  /// In en, this message translates to:
  /// **'Test in progress'**
  String get classroomStatusTestRunning;

  /// No description provided for @classroomStatusTestDone.
  ///
  /// In en, this message translates to:
  /// **'Test finished'**
  String get classroomStatusTestDone;

  /// No description provided for @classroomNoCurriculumTitle.
  ///
  /// In en, this message translates to:
  /// **'The curriculum hasn’t been added yet'**
  String get classroomNoCurriculumTitle;

  /// No description provided for @classroomNoCurriculumBody.
  ///
  /// In en, this message translates to:
  /// **'The course plan (module → topic → materials) will come in a later app version. For now, use class assignments.'**
  String get classroomNoCurriculumBody;

  /// No description provided for @classroomCurriculumError.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t read the curriculum'**
  String get classroomCurriculumError;

  /// No description provided for @classroomNoTopicsStudent.
  ///
  /// In en, this message translates to:
  /// **'Your teacher hasn’t opened any topics yet'**
  String get classroomNoTopicsStudent;

  /// No description provided for @classroomNoTopicsStudentBody.
  ///
  /// In en, this message translates to:
  /// **'When a topic opens, its materials and test will appear here.'**
  String get classroomNoTopicsStudentBody;

  /// No description provided for @classroomTopicTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get classroomTopicTitle;

  /// No description provided for @classroomTopicMissing.
  ///
  /// In en, this message translates to:
  /// **'Topic not found in the curriculum'**
  String get classroomTopicMissing;

  /// No description provided for @classroomTopicNotOpened.
  ///
  /// In en, this message translates to:
  /// **'This topic isn’t open yet'**
  String get classroomTopicNotOpened;

  /// No description provided for @classroomOpenNote.
  ///
  /// In en, this message translates to:
  /// **'Once opened, students see the topic materials.'**
  String get classroomOpenNote;

  /// No description provided for @classroomOpenTopic.
  ///
  /// In en, this message translates to:
  /// **'Open to students'**
  String get classroomOpenTopic;

  /// No description provided for @classroomStep.
  ///
  /// In en, this message translates to:
  /// **'Step {n}'**
  String classroomStep(int n);

  /// No description provided for @classroomStageLecture.
  ///
  /// In en, this message translates to:
  /// **'Lecture'**
  String get classroomStageLecture;

  /// No description provided for @classroomStageLectureBody.
  ///
  /// In en, this message translates to:
  /// **'Present the topic as slides on a big screen (works offline too).'**
  String get classroomStageLectureBody;

  /// No description provided for @classroomStageOral.
  ///
  /// In en, this message translates to:
  /// **'Oral questions'**
  String get classroomStageOral;

  /// No description provided for @classroomStageOralBody.
  ///
  /// In en, this message translates to:
  /// **'Question list with answer outlines. Asked: {count}.'**
  String classroomStageOralBody(int count);

  /// No description provided for @classroomStageTest.
  ///
  /// In en, this message translates to:
  /// **'Class test'**
  String get classroomStageTest;

  /// No description provided for @classroomStageTestBody.
  ///
  /// In en, this message translates to:
  /// **'Pick questions and start the test — it opens for students right away.'**
  String get classroomStageTestBody;

  /// No description provided for @classroomStageDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get classroomStageDone;

  /// No description provided for @classroomMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get classroomMarkDone;

  /// No description provided for @classroomOralOpen.
  ///
  /// In en, this message translates to:
  /// **'Question list'**
  String get classroomOralOpen;

  /// No description provided for @classroomTestPrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare the test'**
  String get classroomTestPrepare;

  /// No description provided for @classroomTestResults.
  ///
  /// In en, this message translates to:
  /// **'Results panel'**
  String get classroomTestResults;

  /// No description provided for @classroomTestFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish the test'**
  String get classroomTestFinish;

  /// No description provided for @classroomTestFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish the test?'**
  String get classroomTestFinishTitle;

  /// No description provided for @classroomTestFinishBody.
  ///
  /// In en, this message translates to:
  /// **'No new attempts are accepted. Those who already started get 2 minutes to send their answers.'**
  String get classroomTestFinishBody;

  /// No description provided for @classroomTestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} students submitted'**
  String classroomTestSubmitted(int done, int total);

  /// No description provided for @classroomTestNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Your teacher hasn’t started the test yet.'**
  String get classroomTestNotStarted;

  /// No description provided for @classroomTestOpenStudent.
  ///
  /// In en, this message translates to:
  /// **'Test open — take it'**
  String get classroomTestOpenStudent;

  /// No description provided for @classroomMaterials.
  ///
  /// In en, this message translates to:
  /// **'Topic materials'**
  String get classroomMaterials;

  /// No description provided for @classroomNoMaterials.
  ///
  /// In en, this message translates to:
  /// **'The app has no linked materials for this topic yet.'**
  String get classroomNoMaterials;

  /// No description provided for @classroomGapNote.
  ///
  /// In en, this message translates to:
  /// **'The app has little material on this topic — the teacher adds their own sources.'**
  String get classroomGapNote;

  /// No description provided for @classroomKindAnalyte.
  ///
  /// In en, this message translates to:
  /// **'Test card'**
  String get classroomKindAnalyte;

  /// No description provided for @classroomKindCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get classroomKindCondition;

  /// No description provided for @classroomKindReference.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get classroomKindReference;

  /// No description provided for @classroomKindAtlas.
  ///
  /// In en, this message translates to:
  /// **'Microscopy atlas'**
  String get classroomKindAtlas;

  /// No description provided for @classroomKindTool.
  ///
  /// In en, this message translates to:
  /// **'Calculator and tool'**
  String get classroomKindTool;

  /// No description provided for @classroomToolQc.
  ///
  /// In en, this message translates to:
  /// **'Quality control'**
  String get classroomToolQc;

  /// No description provided for @classroomToolPreanalytics.
  ///
  /// In en, this message translates to:
  /// **'Preanalytics'**
  String get classroomToolPreanalytics;

  /// No description provided for @classroomToolInstruments.
  ///
  /// In en, this message translates to:
  /// **'Instruments'**
  String get classroomToolInstruments;

  /// No description provided for @classroomToolCalibration.
  ///
  /// In en, this message translates to:
  /// **'Calibration log'**
  String get classroomToolCalibration;

  /// No description provided for @classroomToolDifferential.
  ///
  /// In en, this message translates to:
  /// **'Differential count'**
  String get classroomToolDifferential;

  /// Shown next to M9 practical-day topics whose title is a LabGuide recommendation (the timetable gives only a generic title); the teacher may change it.
  ///
  /// In en, this message translates to:
  /// **'LabGuide recommended practical plan'**
  String get classroomPlanRecommended;

  /// No description provided for @classroomOralNotice.
  ///
  /// In en, this message translates to:
  /// **'Questions are auto-picked candidates; answer outlines are a study aid. “Asked” marks and grades stay on this device only.'**
  String get classroomOralNotice;

  /// No description provided for @classroomOralEmpty.
  ///
  /// In en, this message translates to:
  /// **'No oral questions for this topic'**
  String get classroomOralEmpty;

  /// No description provided for @classroomCandidate.
  ///
  /// In en, this message translates to:
  /// **'Candidate question {n}'**
  String classroomCandidate(int n);

  /// No description provided for @classroomOralPlan.
  ///
  /// In en, this message translates to:
  /// **'Short answer outline'**
  String get classroomOralPlan;

  /// No description provided for @classroomOralNoPlan.
  ///
  /// In en, this message translates to:
  /// **'No answer outline yet.'**
  String get classroomOralNoPlan;

  /// No description provided for @classroomOralAsked.
  ///
  /// In en, this message translates to:
  /// **'Asked'**
  String get classroomOralAsked;

  /// No description provided for @classroomOralGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade students ({count})'**
  String classroomOralGrade(int count);

  /// No description provided for @classroomOralGradeTitle.
  ///
  /// In en, this message translates to:
  /// **'How each student answered'**
  String get classroomOralGradeTitle;

  /// No description provided for @classroomOralGradeNote.
  ///
  /// In en, this message translates to:
  /// **'This device only; not sent to the server.'**
  String get classroomOralGradeNote;

  /// No description provided for @classroomGradeKnew.
  ///
  /// In en, this message translates to:
  /// **'Knew'**
  String get classroomGradeKnew;

  /// No description provided for @classroomGradePartial.
  ///
  /// In en, this message translates to:
  /// **'Partly'**
  String get classroomGradePartial;

  /// No description provided for @classroomGradeDidNot.
  ///
  /// In en, this message translates to:
  /// **'Didn’t know'**
  String get classroomGradeDidNot;

  /// No description provided for @classroomCandidatesNotice.
  ///
  /// In en, this message translates to:
  /// **'Candidate questions were auto-picked. Look through each one and its key: the score is computed on the server using the key shown.'**
  String get classroomCandidatesNotice;

  /// No description provided for @classroomCandidatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Candidates · picked {picked}/{total}'**
  String classroomCandidatesTitle(int picked, int total);

  /// No description provided for @classroomPickAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get classroomPickAll;

  /// No description provided for @classroomPickNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get classroomPickNone;

  /// No description provided for @classroomKeyShown.
  ///
  /// In en, this message translates to:
  /// **'Key: {answer}'**
  String classroomKeyShown(String answer);

  /// No description provided for @classroomKeyFlagged.
  ///
  /// In en, this message translates to:
  /// **'Disputed key'**
  String get classroomKeyFlagged;

  /// No description provided for @classroomPickAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one question'**
  String get classroomPickAtLeastOne;

  /// No description provided for @classroomPickMax.
  ///
  /// In en, this message translates to:
  /// **'At most 50 questions'**
  String get classroomPickMax;

  /// No description provided for @classroomTestStart.
  ///
  /// In en, this message translates to:
  /// **'Start the test · {count} questions'**
  String classroomTestStart(int count);

  /// No description provided for @classroomTestStarted.
  ///
  /// In en, this message translates to:
  /// **'Test started — open for students'**
  String get classroomTestStarted;

  /// No description provided for @classroomTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Test: {topic}'**
  String classroomTestTitle(String topic);

  /// No description provided for @classroomTestAlready.
  ///
  /// In en, this message translates to:
  /// **'This topic’s test has already started'**
  String get classroomTestAlready;

  /// No description provided for @classroomTestNoCandidates.
  ///
  /// In en, this message translates to:
  /// **'No test questions for this topic'**
  String get classroomTestNoCandidates;

  /// No description provided for @classroomTestNoCandidatesBody.
  ///
  /// In en, this message translates to:
  /// **'You can build an assignment by hand (New assignment).'**
  String get classroomTestNoCandidatesBody;

  /// No description provided for @lectureTitle.
  ///
  /// In en, this message translates to:
  /// **'Lecture'**
  String get lectureTitle;

  /// No description provided for @lectureListTitle.
  ///
  /// In en, this message translates to:
  /// **'Lecture mode'**
  String get lectureListTitle;

  /// No description provided for @lectureListSub.
  ///
  /// In en, this message translates to:
  /// **'Pick a topic — slides on a big screen, offline'**
  String get lectureListSub;

  /// No description provided for @lectureStart.
  ///
  /// In en, this message translates to:
  /// **'Start the lecture'**
  String get lectureStart;

  /// No description provided for @lectureClose.
  ///
  /// In en, this message translates to:
  /// **'Close the lecture'**
  String get lectureClose;

  /// No description provided for @lectureCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {total}'**
  String lectureCounter(int current, int total);

  /// No description provided for @lecturePrev.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get lecturePrev;

  /// No description provided for @lectureNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get lectureNext;

  /// No description provided for @lectureGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get lectureGoals;

  /// No description provided for @lectureKeyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key concepts'**
  String get lectureKeyPoints;

  /// No description provided for @lectureConcepts.
  ///
  /// In en, this message translates to:
  /// **'Key tests'**
  String get lectureConcepts;

  /// No description provided for @lectureConditions.
  ///
  /// In en, this message translates to:
  /// **'Clinical conditions'**
  String get lectureConditions;

  /// No description provided for @lectureTables.
  ///
  /// In en, this message translates to:
  /// **'Tables and algorithms'**
  String get lectureTables;

  /// No description provided for @lectureAtlas.
  ///
  /// In en, this message translates to:
  /// **'Microscopy'**
  String get lectureAtlas;

  /// No description provided for @lectureTools.
  ///
  /// In en, this message translates to:
  /// **'Calculations and tools'**
  String get lectureTools;

  /// No description provided for @lectureQuestionN.
  ///
  /// In en, this message translates to:
  /// **'Question {n}'**
  String lectureQuestionN(int n);

  /// No description provided for @lectureEndEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get lectureEndEyebrow;

  /// No description provided for @lectureEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions and test'**
  String get lectureEndTitle;

  /// No description provided for @lectureEndOral.
  ///
  /// In en, this message translates to:
  /// **'Oral questions — asked by the teacher'**
  String get lectureEndOral;

  /// No description provided for @lectureEndTest.
  ///
  /// In en, this message translates to:
  /// **'Class test — in the app, timed'**
  String get lectureEndTest;

  /// No description provided for @lectureDraftNotice.
  ///
  /// In en, this message translates to:
  /// **'The deck is based on sources — look through the content before class'**
  String get lectureDraftNotice;

  /// No description provided for @lectureUzOnly.
  ///
  /// In en, this message translates to:
  /// **'This presentation is in Uzbek only for now'**
  String get lectureUzOnly;

  /// No description provided for @lectureNotesShow.
  ///
  /// In en, this message translates to:
  /// **'Show teacher notes'**
  String get lectureNotesShow;

  /// No description provided for @lectureNotesHide.
  ///
  /// In en, this message translates to:
  /// **'Hide teacher notes'**
  String get lectureNotesHide;

  /// No description provided for @lectureTeacherNote.
  ///
  /// In en, this message translates to:
  /// **'Teacher note'**
  String get lectureTeacherNote;

  /// No description provided for @cmTitle.
  ///
  /// In en, this message translates to:
  /// **'Community · Q&A'**
  String get cmTitle;

  /// No description provided for @cmHomeSub.
  ///
  /// In en, this message translates to:
  /// **'Questions answered by verified lab specialists'**
  String get cmHomeSub;

  /// No description provided for @cmAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask a question'**
  String get cmAsk;

  /// No description provided for @cmAllQuestions.
  ///
  /// In en, this message translates to:
  /// **'All questions'**
  String get cmAllQuestions;

  /// No description provided for @cmEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No questions yet'**
  String get cmEmptyTitle;

  /// No description provided for @cmEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to ask.'**
  String get cmEmptyBody;

  /// No description provided for @cmTopicLinkAnalyte.
  ///
  /// In en, this message translates to:
  /// **'Questions about this test ({count})'**
  String cmTopicLinkAnalyte(int count);

  /// No description provided for @cmTopicLinkCondition.
  ///
  /// In en, this message translates to:
  /// **'Questions about this condition ({count})'**
  String cmTopicLinkCondition(int count);

  /// No description provided for @cmTopicLinkSub.
  ///
  /// In en, this message translates to:
  /// **'Community · answers from specialists'**
  String get cmTopicLinkSub;

  /// No description provided for @cmTopicLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic: {name}'**
  String cmTopicLabel(String name);

  /// No description provided for @cmMyQuestions.
  ///
  /// In en, this message translates to:
  /// **'My questions'**
  String get cmMyQuestions;

  /// No description provided for @cmMyQuestionsSub.
  ///
  /// In en, this message translates to:
  /// **'Your questions and their answers'**
  String get cmMyQuestionsSub;

  /// No description provided for @cmVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Specialist verification'**
  String get cmVerifyTitle;

  /// No description provided for @cmVerifySub.
  ///
  /// In en, this message translates to:
  /// **'Upload a document to answer questions'**
  String get cmVerifySub;

  /// No description provided for @cmBadgeAi.
  ///
  /// In en, this message translates to:
  /// **'✓ Specialist (document checked automatically)'**
  String get cmBadgeAi;

  /// No description provided for @cmBadgeManual.
  ///
  /// In en, this message translates to:
  /// **'✓ Verified specialist'**
  String get cmBadgeManual;

  /// No description provided for @cmBadgeInfo.
  ///
  /// In en, this message translates to:
  /// **'“Document checked automatically” means an AI model, not a person, checked the document. Users can report a wrong badge.'**
  String get cmBadgeInfo;

  /// No description provided for @cmMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get cmMember;

  /// No description provided for @cmYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get cmYou;

  /// No description provided for @cmVerifyInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic check — the file is not stored'**
  String get cmVerifyInfoTitle;

  /// No description provided for @cmVerifyInfo.
  ///
  /// In en, this message translates to:
  /// **'The document is checked automatically by an AI model (Cloudflare Workers AI); no person looks at it. The file is not saved anywhere and is discarded right after the check. Only the result is kept on the server: role, country, status and date. An automatic check can make mistakes; if other users report a wrong badge, it is suspended until an administrator reviews it.'**
  String get cmVerifyInfo;

  /// No description provided for @cmVerifyRole.
  ///
  /// In en, this message translates to:
  /// **'Your profession'**
  String get cmVerifyRole;

  /// No description provided for @cmRoleLaborant.
  ///
  /// In en, this message translates to:
  /// **'Lab technician'**
  String get cmRoleLaborant;

  /// No description provided for @cmRoleBiochemist.
  ///
  /// In en, this message translates to:
  /// **'Biochemist'**
  String get cmRoleBiochemist;

  /// No description provided for @cmRoleKdlDoctor.
  ///
  /// In en, this message translates to:
  /// **'Clinical lab physician'**
  String get cmRoleKdlDoctor;

  /// No description provided for @cmRoleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get cmRoleTeacher;

  /// No description provided for @cmRoleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cmRoleOther;

  /// No description provided for @cmRoleClinicalLab.
  ///
  /// In en, this message translates to:
  /// **'Clinical laboratory diagnostics'**
  String get cmRoleClinicalLab;

  /// No description provided for @cmVerifyCountry.
  ///
  /// In en, this message translates to:
  /// **'Country (2-letter code, e.g. UZ)'**
  String get cmVerifyCountry;

  /// No description provided for @cmVerifyCountryError.
  ///
  /// In en, this message translates to:
  /// **'Enter a 2-letter country code'**
  String get cmVerifyCountryError;

  /// No description provided for @cmVerifyDocHint.
  ///
  /// In en, this message translates to:
  /// **'Diploma, certificate or a document from your workplace. JPEG or PNG photo, up to 5 MB. For a PDF, take a photo of its first page. Cover any patient data.'**
  String get cmVerifyDocHint;

  /// No description provided for @cmVerifyCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get cmVerifyCamera;

  /// No description provided for @cmVerifyGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get cmVerifyGallery;

  /// No description provided for @cmVerifyRemove.
  ///
  /// In en, this message translates to:
  /// **'Choose another'**
  String get cmVerifyRemove;

  /// No description provided for @cmVerifySubmit.
  ///
  /// In en, this message translates to:
  /// **'Send for automatic check'**
  String get cmVerifySubmit;

  /// No description provided for @cmVerifyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 attempts per day.'**
  String get cmVerifyAttempts;

  /// No description provided for @cmStatusNone.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet'**
  String get cmStatusNone;

  /// No description provided for @cmStatusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get cmStatusVerified;

  /// No description provided for @cmStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'The document was not accepted. Try again with a clearer photo where the institution and the field are visible.'**
  String get cmStatusRejected;

  /// No description provided for @cmStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Your community account is suspended after reports from users. An administrator will review it.'**
  String get cmStatusSuspended;

  /// No description provided for @cmVerifiedAt.
  ///
  /// In en, this message translates to:
  /// **'Verified: {date}'**
  String cmVerifiedAt(String date);

  /// No description provided for @cmMethodAi.
  ///
  /// In en, this message translates to:
  /// **'Method: automatic (AI)'**
  String get cmMethodAi;

  /// No description provided for @cmMethodManual.
  ///
  /// In en, this message translates to:
  /// **'Method: document reviewed manually'**
  String get cmMethodManual;

  /// No description provided for @cmErrTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is larger than 5 MB.'**
  String get cmErrTooLarge;

  /// No description provided for @cmErrType.
  ///
  /// In en, this message translates to:
  /// **'Only a JPEG or PNG photo.'**
  String get cmErrType;

  /// No description provided for @cmErrAi.
  ///
  /// In en, this message translates to:
  /// **'The automatic check is not available right now. Try again later.'**
  String get cmErrAi;

  /// No description provided for @cmErrNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Only verified specialists can answer and vote.'**
  String get cmErrNotVerified;

  /// No description provided for @cmErrContact.
  ///
  /// In en, this message translates to:
  /// **'Remove email addresses and phone numbers (and any patient data) from the text.'**
  String get cmErrContact;

  /// No description provided for @cmErrLength.
  ///
  /// In en, this message translates to:
  /// **'Title: 10–200 characters, text: 10–4000.'**
  String get cmErrLength;

  /// No description provided for @cmErrAlreadyVerified.
  ///
  /// In en, this message translates to:
  /// **'You are already verified.'**
  String get cmErrAlreadyVerified;

  /// No description provided for @cmErrRevoked.
  ///
  /// In en, this message translates to:
  /// **'Your specialist status was revoked by an administrator. Automatic re-verification is not available.'**
  String get cmErrRevoked;

  /// No description provided for @cmAskTitleField.
  ///
  /// In en, this message translates to:
  /// **'Question title'**
  String get cmAskTitleField;

  /// No description provided for @cmAskBodyField.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get cmAskBodyField;

  /// No description provided for @cmAskNoPatient.
  ///
  /// In en, this message translates to:
  /// **'Do not write a patient’s name, phone or other personal data. Answers are colleagues’ experience, not personal medical advice.'**
  String get cmAskNoPatient;

  /// No description provided for @cmAskSend.
  ///
  /// In en, this message translates to:
  /// **'Post question'**
  String get cmAskSend;

  /// No description provided for @cmAskSent.
  ///
  /// In en, this message translates to:
  /// **'Question posted'**
  String get cmAskSent;

  /// No description provided for @cmSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to take part'**
  String get cmSignInTitle;

  /// No description provided for @cmSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Anyone signed in can ask. Verified specialists answer.'**
  String get cmSignInBody;

  /// No description provided for @cmAnswers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No answers} =1{1 answer} other{{count} answers}}'**
  String cmAnswers(int count);

  /// No description provided for @cmAnswerField.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get cmAnswerField;

  /// No description provided for @cmAnswerSend.
  ///
  /// In en, this message translates to:
  /// **'Post answer'**
  String get cmAnswerSend;

  /// No description provided for @cmAnswerOnlySpecialists.
  ///
  /// In en, this message translates to:
  /// **'Answers are written only by verified specialists.'**
  String get cmAnswerOnlySpecialists;

  /// No description provided for @cmBest.
  ///
  /// In en, this message translates to:
  /// **'Best answer'**
  String get cmBest;

  /// No description provided for @cmMarkBest.
  ///
  /// In en, this message translates to:
  /// **'Mark as best'**
  String get cmMarkBest;

  /// No description provided for @cmUnmarkBest.
  ///
  /// In en, this message translates to:
  /// **'Remove mark'**
  String get cmUnmarkBest;

  /// No description provided for @cmUpvote.
  ///
  /// In en, this message translates to:
  /// **'Helpful ({count})'**
  String cmUpvote(int count);

  /// No description provided for @cmReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get cmReport;

  /// No description provided for @cmReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Reason for the report'**
  String get cmReportTitle;

  /// No description provided for @cmReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or advertising'**
  String get cmReasonSpam;

  /// No description provided for @cmReasonWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong or dangerous information'**
  String get cmReasonWrong;

  /// No description provided for @cmReasonAbuse.
  ///
  /// In en, this message translates to:
  /// **'Abusive'**
  String get cmReasonAbuse;

  /// No description provided for @cmReasonFake.
  ///
  /// In en, this message translates to:
  /// **'Fake specialist'**
  String get cmReasonFake;

  /// No description provided for @cmReasonPatient.
  ///
  /// In en, this message translates to:
  /// **'Contains patient data'**
  String get cmReasonPatient;

  /// No description provided for @cmReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get cmReasonOther;

  /// No description provided for @cmReportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent. Thank you.'**
  String get cmReportSent;

  /// No description provided for @cmTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get cmTranslate;

  /// No description provided for @cmMachineTranslation.
  ///
  /// In en, this message translates to:
  /// **'Machine translation'**
  String get cmMachineTranslation;

  /// No description provided for @cmShowOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original text'**
  String get cmShowOriginal;

  /// No description provided for @cmShowTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get cmShowTranslation;

  /// No description provided for @cmPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get cmPin;

  /// No description provided for @cmUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get cmUnpin;

  /// No description provided for @cmPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get cmPinned;

  /// No description provided for @cmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cmDelete;

  /// No description provided for @cmDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get cmDeleteConfirm;

  /// No description provided for @cmDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get cmDeleted;

  /// No description provided for @cmLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get cmLoadMore;

  /// No description provided for @cmNotAdvice.
  ///
  /// In en, this message translates to:
  /// **'Answers are colleagues’ experience, not personal medical advice.'**
  String get cmNotAdvice;

  /// No description provided for @cmRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Community rules'**
  String get cmRulesTitle;

  /// No description provided for @cmRulesIntro.
  ///
  /// In en, this message translates to:
  /// **'The LabGuide community is a place to share experience in clinical laboratory diagnostics.'**
  String get cmRulesIntro;

  /// No description provided for @cmRulesExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand rules'**
  String get cmRulesExpand;

  /// No description provided for @cmRulesCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse rules'**
  String get cmRulesCollapse;

  /// No description provided for @cmRulesH1.
  ///
  /// In en, this message translates to:
  /// **'What is discussed'**
  String get cmRulesH1;

  /// No description provided for @cmRulesA1.
  ///
  /// In en, this message translates to:
  /// **'interpreting test results (inconsistent results, spurious increases/decreases)'**
  String get cmRulesA1;

  /// No description provided for @cmRulesA2.
  ///
  /// In en, this message translates to:
  /// **'pre-analytics: blood collection, tubes, storage, hemolysis'**
  String get cmRulesA2;

  /// No description provided for @cmRulesA3.
  ///
  /// In en, this message translates to:
  /// **'quality control (QC, Westgard rules), calibration'**
  String get cmRulesA3;

  /// No description provided for @cmRulesA4.
  ///
  /// In en, this message translates to:
  /// **'experience working with analyzers and reagents'**
  String get cmRulesA4;

  /// No description provided for @cmRulesA5.
  ///
  /// In en, this message translates to:
  /// **'hematology, microscopy, biochemistry, immunology, urinalysis'**
  String get cmRulesA5;

  /// No description provided for @cmRulesA6.
  ///
  /// In en, this message translates to:
  /// **'questions about knowledge and skills assessment and study'**
  String get cmRulesA6;

  /// No description provided for @cmRulesH2.
  ///
  /// In en, this message translates to:
  /// **'How to write'**
  String get cmRulesH2;

  /// No description provided for @cmRulesB1.
  ///
  /// In en, this message translates to:
  /// **'put the essence of the question in the title (for example: “Potassium high, no hemolysis — what is the cause?”)'**
  String get cmRulesB1;

  /// No description provided for @cmRulesB2.
  ///
  /// In en, this message translates to:
  /// **'in the details: which test, the result and its unit, the method or analyzer, what you have already tried'**
  String get cmRulesB2;

  /// No description provided for @cmRulesB3.
  ///
  /// In en, this message translates to:
  /// **'state units precisely: SI first, conventional in parentheses (for example 7.0 mmol/L (126 mg/dL))'**
  String get cmRulesB3;

  /// No description provided for @cmRulesB4.
  ///
  /// In en, this message translates to:
  /// **'one post — one question'**
  String get cmRulesB4;

  /// No description provided for @cmRulesH3.
  ///
  /// In en, this message translates to:
  /// **'What is not allowed'**
  String get cmRulesH3;

  /// No description provided for @cmRulesC1.
  ///
  /// In en, this message translates to:
  /// **'a patient’s name, phone, address, card number or any data that identifies a person'**
  String get cmRulesC1;

  /// No description provided for @cmRulesC2.
  ///
  /// In en, this message translates to:
  /// **'advertising, off-topic posts, abusive language; posting intimate or private images or material without the person’s consent is strictly prohibited'**
  String get cmRulesC2;

  /// No description provided for @cmRulesC3.
  ///
  /// In en, this message translates to:
  /// **'personal treatment advice for a patient — this is colleagues’ experience, not a doctor’s advice'**
  String get cmRulesC3;

  /// No description provided for @cmRulesH4.
  ///
  /// In en, this message translates to:
  /// **'Who can write'**
  String get cmRulesH4;

  /// No description provided for @cmRulesD1.
  ///
  /// In en, this message translates to:
  /// **'questions — any registered user'**
  String get cmRulesD1;

  /// No description provided for @cmRulesD2Pre.
  ///
  /// In en, this message translates to:
  /// **'answers — only verified specialists with the “✓ Specialist” badge ('**
  String get cmRulesD2Pre;

  /// No description provided for @cmRulesD2Link.
  ///
  /// In en, this message translates to:
  /// **'Profile → Specialist verification'**
  String get cmRulesD2Link;

  /// No description provided for @cmRulesD2Post.
  ///
  /// In en, this message translates to:
  /// **'; upload a photo of your diploma or certificate; the document is not stored)'**
  String get cmRulesD2Post;

  /// No description provided for @cmRulesD3.
  ///
  /// In en, this message translates to:
  /// **'if you see a post that breaks the rules, tap “Report”'**
  String get cmRulesD3;

  /// No description provided for @cmRulesOutro.
  ///
  /// In en, this message translates to:
  /// **'To read posts in another language, use the “Translate” button. Respect and accuracy are our main rule.'**
  String get cmRulesOutro;

  /// No description provided for @cmAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Community moderation'**
  String get cmAdminTitle;

  /// No description provided for @cmAdminSub.
  ///
  /// In en, this message translates to:
  /// **'Reported users: restore or revoke'**
  String get cmAdminSub;

  /// No description provided for @cmAdminEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody here'**
  String get cmAdminEmpty;

  /// No description provided for @cmAdminReporters.
  ///
  /// In en, this message translates to:
  /// **'{count} reporters'**
  String cmAdminReporters(int count);

  /// No description provided for @cmAdminRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get cmAdminRestore;

  /// No description provided for @cmAdminRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke verification'**
  String get cmAdminRevoke;

  /// No description provided for @cmAdminSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get cmAdminSuspended;

  /// No description provided for @cmAdminVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get cmAdminVerified;

  /// No description provided for @cmAdminRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get cmAdminRejected;

  /// No description provided for @cmAdminDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get cmAdminDone;

  /// No description provided for @cmOwnerTag.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get cmOwnerTag;

  /// No description provided for @cmLaunchTitle.
  ///
  /// In en, this message translates to:
  /// **'Launch the community'**
  String get cmLaunchTitle;

  /// No description provided for @cmLaunchBody.
  ///
  /// In en, this message translates to:
  /// **'Tap once: your account is confirmed as the founder and the starter questions and answers are added. Tapping again adds nothing twice.'**
  String get cmLaunchBody;

  /// No description provided for @cmLaunchButton.
  ///
  /// In en, this message translates to:
  /// **'Launch'**
  String get cmLaunchButton;

  /// No description provided for @cmLaunchDone.
  ///
  /// In en, this message translates to:
  /// **'Done: founder confirmed. Added {questions} questions and {answers} answers.'**
  String cmLaunchDone(int questions, int answers);

  /// No description provided for @cmLaunchAlready.
  ///
  /// In en, this message translates to:
  /// **'The community is already launched: founder confirmed, nothing new was added.'**
  String get cmLaunchAlready;

  /// No description provided for @cmLaunchNotOwner.
  ///
  /// In en, this message translates to:
  /// **'This account is not allowed as founder. Sign in with the founder’s email.'**
  String get cmLaunchNotOwner;

  /// No description provided for @cmLaunchMfaHint.
  ///
  /// In en, this message translates to:
  /// **'To launch the community, first confirm two-step protection: enter the 6-digit code from your authenticator app. The “Launch the community” button appears after that.'**
  String get cmLaunchMfaHint;

  /// No description provided for @diffFbSound.
  ///
  /// In en, this message translates to:
  /// **'Sound on tap'**
  String get diffFbSound;

  /// No description provided for @diffFbHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration on tap'**
  String get diffFbHaptics;

  /// No description provided for @diffFbOn.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get diffFbOn;

  /// No description provided for @diffFbOff.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get diffFbOff;

  /// No description provided for @admYouSuper.
  ///
  /// In en, this message translates to:
  /// **'You are the owner (super admin)'**
  String get admYouSuper;

  /// No description provided for @admYouAdmin.
  ///
  /// In en, this message translates to:
  /// **'You are an admin'**
  String get admYouAdmin;

  /// No description provided for @adm2faOn.
  ///
  /// In en, this message translates to:
  /// **'Two-step protection (2FA) is confirmed. It is required for every admin action.'**
  String get adm2faOn;

  /// No description provided for @admReportsQueue.
  ///
  /// In en, this message translates to:
  /// **'Reports and members'**
  String get admReportsQueue;

  /// No description provided for @admReportsSub.
  ///
  /// In en, this message translates to:
  /// **'Suspended queue, verified and rejected members'**
  String get admReportsSub;

  /// No description provided for @admLaunchRow.
  ///
  /// In en, this message translates to:
  /// **'Launch the community'**
  String get admLaunchRow;

  /// No description provided for @admLaunchRowSub.
  ///
  /// In en, this message translates to:
  /// **'Founder confirmation and starter Q&A (once)'**
  String get admLaunchRowSub;

  /// No description provided for @admPending.
  ///
  /// In en, this message translates to:
  /// **'Pending: {count}'**
  String admPending(int count);

  /// No description provided for @admQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get admQueueEmpty;

  /// No description provided for @admNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected on this server yet'**
  String get admNotConnected;

  /// No description provided for @admReview.
  ///
  /// In en, this message translates to:
  /// **'Content review'**
  String get admReview;

  /// No description provided for @admReviewSub.
  ///
  /// In en, this message translates to:
  /// **'Not yet reviewed: {cards} cards, {questions} questions'**
  String admReviewSub(int cards, int questions);

  /// No description provided for @admTeam.
  ///
  /// In en, this message translates to:
  /// **'Admin management'**
  String get admTeam;

  /// No description provided for @admTeamCount.
  ///
  /// In en, this message translates to:
  /// **'Admins: {count}'**
  String admTeamCount(int count);

  /// No description provided for @admTeamSubManage.
  ///
  /// In en, this message translates to:
  /// **'Add by email and remove'**
  String get admTeamSubManage;

  /// No description provided for @admTeamSubView.
  ///
  /// In en, this message translates to:
  /// **'List (only the owner can change it)'**
  String get admTeamSubView;

  /// No description provided for @admLegacyNote.
  ///
  /// In en, this message translates to:
  /// **'Statistics, users, action history and partners are not on this server yet — they will appear here when ready.'**
  String get admLegacyNote;

  /// No description provided for @admOther.
  ///
  /// In en, this message translates to:
  /// **'Other sections'**
  String get admOther;

  /// No description provided for @admTeamIntro.
  ///
  /// In en, this message translates to:
  /// **'An admin gets full access to every admin section: community moderation, support threads, content review. Only the server grants this, and every action needs a 2FA code.'**
  String get admTeamIntro;

  /// No description provided for @admTeamOwnerOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the owner (super admin) can add and remove admins.'**
  String get admTeamOwnerOnly;

  /// No description provided for @admAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an admin'**
  String get admAddTitle;

  /// No description provided for @admAddEmail.
  ///
  /// In en, this message translates to:
  /// **'Email (e.g. Gmail)'**
  String get admAddEmail;

  /// No description provided for @admAddHint.
  ///
  /// In en, this message translates to:
  /// **'Access takes effect once they sign in with this email and set up 2FA; if the account exists — right away.'**
  String get admAddHint;

  /// No description provided for @admAddButton.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get admAddButton;

  /// No description provided for @admAddConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Make this person an admin?'**
  String get admAddConfirmTitle;

  /// No description provided for @admAddConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{email} will get full access to every admin section. You can remove them at any time.'**
  String admAddConfirmBody(String email);

  /// No description provided for @admAdded.
  ///
  /// In en, this message translates to:
  /// **'Added: {email}'**
  String admAdded(String email);

  /// No description provided for @admInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email. For example: name@gmail.com'**
  String get admInvalidEmail;

  /// No description provided for @admErrAlready.
  ///
  /// In en, this message translates to:
  /// **'This email is already an admin.'**
  String get admErrAlready;

  /// No description provided for @admErrSuper.
  ///
  /// In en, this message translates to:
  /// **'This is the owner’s email (super admin) — already an admin.'**
  String get admErrSuper;

  /// No description provided for @admErrTooMany.
  ///
  /// In en, this message translates to:
  /// **'Admin limit: {max}. Remove someone first.'**
  String admErrTooMany(int max);

  /// No description provided for @admListTitle.
  ///
  /// In en, this message translates to:
  /// **'Admins ({count})'**
  String admListTitle(int count);

  /// No description provided for @admKindSuper.
  ///
  /// In en, this message translates to:
  /// **'Owner · super admin'**
  String get admKindSuper;

  /// No description provided for @admKindGranted.
  ///
  /// In en, this message translates to:
  /// **'Admin · added {date}'**
  String admKindGranted(String date);

  /// No description provided for @admNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in yet — access starts at first sign-in'**
  String get admNotSignedIn;

  /// No description provided for @admYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get admYou;

  /// No description provided for @admRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get admRemove;

  /// No description provided for @admRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this admin?'**
  String get admRemoveTitle;

  /// No description provided for @admRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'{email} loses admin access immediately — on every device. Their account and data are not deleted.'**
  String admRemoveBody(String email);

  /// No description provided for @admRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed: {email}'**
  String admRemoved(String email);

  /// No description provided for @admSuperNote.
  ///
  /// In en, this message translates to:
  /// **'The owner is set in a secret server setting (LG_ADMIN_EMAILS) and cannot be removed from the app.'**
  String get admSuperNote;

  /// No description provided for @admNoGranted.
  ///
  /// In en, this message translates to:
  /// **'No admins added yet.'**
  String get admNoGranted;

  /// No description provided for @cmAdminRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke verification?'**
  String get cmAdminRevokeTitle;

  /// No description provided for @cmAdminRevokeBody.
  ///
  /// In en, this message translates to:
  /// **'The member loses the specialist badge and cannot be re-verified by AI. They can still ask questions.'**
  String get cmAdminRevokeBody;

  /// No description provided for @cmAdminRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this member?'**
  String get cmAdminRestoreTitle;

  /// No description provided for @cmAdminRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'The status before suspension returns and their posts become visible again. Old reports are not counted again.'**
  String get cmAdminRestoreBody;

  /// No description provided for @adminActionGrantAdded.
  ///
  /// In en, this message translates to:
  /// **'Admin added'**
  String get adminActionGrantAdded;

  /// No description provided for @adminActionGrantRemoved.
  ///
  /// In en, this message translates to:
  /// **'Admin removed'**
  String get adminActionGrantRemoved;

  /// No description provided for @cytoTitle.
  ///
  /// In en, this message translates to:
  /// **'Cytology'**
  String get cytoTitle;

  /// No description provided for @cytoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Gynecological smear: cells and reports'**
  String get cytoSubtitle;

  /// No description provided for @cytoHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Read a smear with confidence'**
  String get cytoHeroTitle;

  /// No description provided for @cytoHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Cell drawings, cleanliness grade, the Bethesda system and practice — in one place.'**
  String get cytoHeroBody;

  /// No description provided for @cytoHeroCta.
  ///
  /// In en, this message translates to:
  /// **'View cells'**
  String get cytoHeroCta;

  /// No description provided for @cytoSchematicCaption.
  ///
  /// In en, this message translates to:
  /// **'Annotated diagram (LabGuide) — not a micrograph; scale and colors are approximate.'**
  String get cytoSchematicCaption;

  /// No description provided for @cytoCellsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cells and organisms'**
  String get cytoCellsTitle;

  /// No description provided for @cytoCellsSub.
  ///
  /// In en, this message translates to:
  /// **'{n} items: drawing and key feature'**
  String cytoCellsSub(int n);

  /// No description provided for @cytoDegreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Vaginal smear cleanliness grade'**
  String get cytoDegreeTitle;

  /// No description provided for @cytoDegreeSub.
  ///
  /// In en, this message translates to:
  /// **'Grades I–IV: mark what you see'**
  String get cytoDegreeSub;

  /// No description provided for @cytoBethesdaTitle.
  ///
  /// In en, this message translates to:
  /// **'The Bethesda system'**
  String get cytoBethesdaTitle;

  /// No description provided for @cytoBethesdaSub.
  ///
  /// In en, this message translates to:
  /// **'What a Pap report means'**
  String get cytoBethesdaSub;

  /// No description provided for @cytoTechniqueTitle.
  ///
  /// In en, this message translates to:
  /// **'Sampling and staining'**
  String get cytoTechniqueTitle;

  /// No description provided for @cytoTechniqueSub.
  ///
  /// In en, this message translates to:
  /// **'Preparation, fixation, staining, errors'**
  String get cytoTechniqueSub;

  /// No description provided for @cytoQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Which cell is this?'**
  String get cytoQuizTitle;

  /// No description provided for @cytoQuizSub.
  ///
  /// In en, this message translates to:
  /// **'{n} picture questions'**
  String cytoQuizSub(int n);

  /// No description provided for @cytoQuizIntro.
  ///
  /// In en, this message translates to:
  /// **'Look at the drawing and pick the name: 4 options. The key feature is shown after you answer.'**
  String get cytoQuizIntro;

  /// No description provided for @cytoQuizPrompt.
  ///
  /// In en, this message translates to:
  /// **'What is this?'**
  String get cytoQuizPrompt;

  /// No description provided for @cytoQuizStart.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get cytoQuizStart;

  /// No description provided for @cytoLook.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get cytoLook;

  /// No description provided for @cytoKey.
  ///
  /// In en, this message translates to:
  /// **'Key feature'**
  String get cytoKey;

  /// No description provided for @cytoMeaning.
  ///
  /// In en, this message translates to:
  /// **'What it means'**
  String get cytoMeaning;

  /// No description provided for @cytoConfuse.
  ///
  /// In en, this message translates to:
  /// **'Often confused with'**
  String get cytoConfuse;

  /// No description provided for @cytoRefer.
  ///
  /// In en, this message translates to:
  /// **'Show to a cytologist or clinician'**
  String get cytoRefer;

  /// No description provided for @cytoDegreeIntro.
  ///
  /// In en, this message translates to:
  /// **'Mark what you see under the microscope — the app shows the grade by the traditional scheme. The worst feature decides.'**
  String get cytoDegreeIntro;

  /// No description provided for @cytoLacto.
  ///
  /// In en, this message translates to:
  /// **'Lactobacilli'**
  String get cytoLacto;

  /// No description provided for @cytoLeuko.
  ///
  /// In en, this message translates to:
  /// **'Leukocytes'**
  String get cytoLeuko;

  /// No description provided for @cytoFlora.
  ///
  /// In en, this message translates to:
  /// **'Other flora'**
  String get cytoFlora;

  /// No description provided for @cytoMany.
  ///
  /// In en, this message translates to:
  /// **'Many'**
  String get cytoMany;

  /// No description provided for @cytoFew.
  ///
  /// In en, this message translates to:
  /// **'Few'**
  String get cytoFew;

  /// No description provided for @cytoNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get cytoNone;

  /// No description provided for @cytoSingle.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get cytoSingle;

  /// No description provided for @cytoVeryMany.
  ///
  /// In en, this message translates to:
  /// **'Very many'**
  String get cytoVeryMany;

  /// No description provided for @cytoMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed (cocci)'**
  String get cytoMixed;

  /// No description provided for @cytoPathogenic.
  ///
  /// In en, this message translates to:
  /// **'Pathogenic (trichomonads etc.)'**
  String get cytoPathogenic;

  /// No description provided for @cytoDegreeResult.
  ///
  /// In en, this message translates to:
  /// **'Grade {n}'**
  String cytoDegreeResult(int n);

  /// No description provided for @cytoDegreeTable.
  ///
  /// In en, this message translates to:
  /// **'Grades at a glance'**
  String get cytoDegreeTable;

  /// No description provided for @cytoDegreeNote.
  ///
  /// In en, this message translates to:
  /// **'A traditional scheme (A. Heurlein, 1910; used in CIS countries). Russian guidelines (ROAG 2019) regard it as of historical interest only; the international criteria for bacterial vaginosis are Amsel and Nugent.'**
  String get cytoDegreeNote;

  /// No description provided for @cytoDegreeSourceNote.
  ///
  /// In en, this message translates to:
  /// **'Sources for the classification and for the bacterial vaginosis criteria are listed below; where they disagree, both are shown.'**
  String get cytoDegreeSourceNote;

  /// No description provided for @cytoBethesdaIntro.
  ///
  /// In en, this message translates to:
  /// **'This is how a cervical smear is reported in the Bethesda system. The clinician decides next steps.'**
  String get cytoBethesdaIntro;

  /// No description provided for @cytoMethod.
  ///
  /// In en, this message translates to:
  /// **'Stain / preparation'**
  String get cytoMethod;

  /// No description provided for @cytoMarksTitle.
  ///
  /// In en, this message translates to:
  /// **'What the numbers show'**
  String get cytoMarksTitle;

  /// No description provided for @cytoNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'No real micrograph yet — only images with verified permission will be added.'**
  String get cytoNoPhoto;

  /// No description provided for @cytoLabCardBody.
  ///
  /// In en, this message translates to:
  /// **'Cell diagrams, cleanliness grade, Bethesda and practice'**
  String get cytoLabCardBody;

  /// No description provided for @spermTitle.
  ///
  /// In en, this message translates to:
  /// **'Semen analysis'**
  String get spermTitle;

  /// No description provided for @spermLabCardBody.
  ///
  /// In en, this message translates to:
  /// **'WHO 2021 limits, counter, result assessment and terms'**
  String get spermLabCardBody;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tests, instruments or topics'**
  String get homeSearchHint;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a name, abbreviation or synonym — in Uzbek (Latin or Cyrillic), Russian or English.'**
  String get searchPrompt;

  /// No description provided for @searchSectionLibrary.
  ///
  /// In en, this message translates to:
  /// **'Learning materials'**
  String get searchSectionLibrary;

  /// No description provided for @searchSectionSections.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get searchSectionSections;

  /// No description provided for @diffAssessTitle.
  ///
  /// In en, this message translates to:
  /// **'Compared with reference'**
  String get diffAssessTitle;

  /// No description provided for @diffAssessNote.
  ///
  /// In en, this message translates to:
  /// **'This is not a diagnosis: the result is compared with the report’s reference range and shows what it may point to. The clinician draws the conclusion.'**
  String get diffAssessNote;

  /// No description provided for @diffAssessNeedWbc.
  ///
  /// In en, this message translates to:
  /// **'Enter the white cell count (WBC) to assess absolute counts — only the band percentage was assessed.'**
  String get diffAssessNeedWbc;

  /// No description provided for @diffAssessAllNormal.
  ///
  /// In en, this message translates to:
  /// **'All values are within the reference range.'**
  String get diffAssessAllNormal;

  /// No description provided for @diffAssessIncomplete.
  ///
  /// In en, this message translates to:
  /// **'The comparison appears when the count is complete: {counted} of {target} cells counted. Percentages from an incomplete count are not reliable.'**
  String diffAssessIncomplete(int counted, int target);

  /// No description provided for @diffFlagHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get diffFlagHigh;

  /// No description provided for @diffFlagLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get diffFlagLow;

  /// No description provided for @diffFlagNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get diffFlagNormal;

  /// No description provided for @diffMeasureNeutrophils.
  ///
  /// In en, this message translates to:
  /// **'Neutrophils (total)'**
  String get diffMeasureNeutrophils;

  /// No description provided for @diffMeasureLymphocytes.
  ///
  /// In en, this message translates to:
  /// **'Lymphocytes'**
  String get diffMeasureLymphocytes;

  /// No description provided for @diffMeasureMonocytes.
  ///
  /// In en, this message translates to:
  /// **'Monocytes'**
  String get diffMeasureMonocytes;

  /// No description provided for @diffMeasureEosinophils.
  ///
  /// In en, this message translates to:
  /// **'Eosinophils'**
  String get diffMeasureEosinophils;

  /// No description provided for @diffMeasureBasophils.
  ///
  /// In en, this message translates to:
  /// **'Basophils'**
  String get diffMeasureBasophils;

  /// No description provided for @diffMeasureBands.
  ///
  /// In en, this message translates to:
  /// **'Band neutrophils'**
  String get diffMeasureBands;

  /// No description provided for @diffAssessRange.
  ///
  /// In en, this message translates to:
  /// **'reference {range}'**
  String diffAssessRange(String range);

  /// No description provided for @diffAssessMaySuggest.
  ///
  /// In en, this message translates to:
  /// **'May point to: {finding}'**
  String diffAssessMaySuggest(String finding);

  /// No description provided for @diffAssessAboutFinding.
  ///
  /// In en, this message translates to:
  /// **'More about this finding'**
  String get diffAssessAboutFinding;

  /// No description provided for @diffAssessReferBody.
  ///
  /// In en, this message translates to:
  /// **'Blasts or unidentified cells, severe neutropenia (< 0.5 ×10⁹/L) or marked eosinophilia (> 1.5 ×10⁹/L): show the result and the smear to a clinician or haematologist urgently.'**
  String get diffAssessReferBody;

  /// No description provided for @diffLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Report reference ranges'**
  String get diffLimitsTitle;

  /// No description provided for @diffLimitsSub.
  ///
  /// In en, this message translates to:
  /// **'Enter the ranges printed on your laboratory’s report — assessment uses them. An empty lower limit is not checked.'**
  String get diffLimitsSub;

  /// No description provided for @diffLimitsLow.
  ///
  /// In en, this message translates to:
  /// **'Lower limit'**
  String get diffLimitsLow;

  /// No description provided for @diffLimitsHigh.
  ///
  /// In en, this message translates to:
  /// **'Upper limit'**
  String get diffLimitsHigh;

  /// No description provided for @diffLimitsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid range: the lower limit must be below the upper.'**
  String get diffLimitsInvalid;

  /// No description provided for @diffLimitsReset.
  ///
  /// In en, this message translates to:
  /// **'Restore source values'**
  String get diffLimitsReset;

  /// No description provided for @diffLimitsSourceNote.
  ///
  /// In en, this message translates to:
  /// **'Defaults are adult 95% intervals (Harrison’s Manual of Medicine, 20th ed., Table 64-1); bands — Lyubina 1984, Table 6. MSD Manual definitions differ: eosinophilia > 0.5 ×10⁹/L (default upper limit here 0.7) and lymphocytopenia < 1.0 ×10⁹/L (default lower limit here 1.5). Ranges differ in children and in some ethnic groups (e.g. Duffy-negative).'**
  String get diffLimitsSourceNote;

  /// No description provided for @cytoAdequacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Specimen adequacy'**
  String get cytoAdequacyTitle;

  /// No description provided for @cytoAdequacySub.
  ///
  /// In en, this message translates to:
  /// **'Bethesda 2014: satisfactory or not, common artifacts'**
  String get cytoAdequacySub;

  /// No description provided for @cytoArtefactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Common artifacts'**
  String get cytoArtefactsTitle;

  /// No description provided for @cytoReactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactive changes vs atypia'**
  String get cytoReactiveTitle;

  /// No description provided for @cytoReactiveSub.
  ///
  /// In en, this message translates to:
  /// **'Inflammation, repair, radiation, IUD vs ASC-US and LSIL'**
  String get cytoReactiveSub;

  /// No description provided for @cytoReactiveIntro.
  ///
  /// In en, this message translates to:
  /// **'In the Bethesda system reactive cellular changes (inflammation including repair, lymphocytic cervicitis, radiation, IUD) are non-neoplastic findings within NILM.'**
  String get cytoReactiveIntro;

  /// No description provided for @cytoCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Side by side'**
  String get cytoCompareTitle;

  /// No description provided for @cytoCompareNone.
  ///
  /// In en, this message translates to:
  /// **'no separate criterion in the cited sources'**
  String get cytoCompareNone;

  /// No description provided for @cytoReactiveTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Types of reactive change'**
  String get cytoReactiveTypesTitle;

  /// No description provided for @cytoMaturationTitle.
  ///
  /// In en, this message translates to:
  /// **'Maturation index'**
  String get cytoMaturationTitle;

  /// No description provided for @cytoMaturationSub.
  ///
  /// In en, this message translates to:
  /// **'Parabasal : intermediate : superficial — calculator'**
  String get cytoMaturationSub;

  /// No description provided for @cytoMiCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get cytoMiCalcTitle;

  /// No description provided for @cytoMiParabasal.
  ///
  /// In en, this message translates to:
  /// **'Parabasal cells'**
  String get cytoMiParabasal;

  /// No description provided for @cytoMiIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate cells'**
  String get cytoMiIntermediate;

  /// No description provided for @cytoMiSuperficial.
  ///
  /// In en, this message translates to:
  /// **'Superficial cells'**
  String get cytoMiSuperficial;

  /// No description provided for @cytoMiEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter the counts of single cells (whole numbers); at least one must be above 0.'**
  String get cytoMiEmpty;

  /// No description provided for @cytoMiResult.
  ///
  /// In en, this message translates to:
  /// **'Maturation index (parabasal : intermediate : superficial)'**
  String get cytoMiResult;

  /// No description provided for @cytoMiTotal.
  ///
  /// In en, this message translates to:
  /// **'Cells counted: {n}'**
  String cytoMiTotal(int n);

  /// No description provided for @cytoMiCaveat.
  ///
  /// In en, this message translates to:
  /// **'This is arithmetic only. Interpretation depends on age, cycle day, pregnancy, hormones and inflammation — the cytologist or clinician interprets.'**
  String get cytoMiCaveat;

  /// No description provided for @cytoOtherTitle.
  ///
  /// In en, this message translates to:
  /// **'Other specimens'**
  String get cytoOtherTitle;

  /// No description provided for @cytoOtherSub.
  ///
  /// In en, this message translates to:
  /// **'Urine, serous fluids, sputum: reporting categories'**
  String get cytoOtherSub;

  /// No description provided for @cytoOtherIntro.
  ///
  /// In en, this message translates to:
  /// **'A brief overview: only the names of the international reporting categories. Criteria and risk figures are in the sources.'**
  String get cytoOtherIntro;

  /// No description provided for @cytoCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get cytoCategoriesTitle;

  /// No description provided for @contactPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get contactPrivacyPolicy;

  /// Lab tab: blood group determination methods section title
  ///
  /// In en, this message translates to:
  /// **'Blood grouping'**
  String get bloodGroupTitle;

  /// No description provided for @bloodGroupLabCardBody.
  ///
  /// In en, this message translates to:
  /// **'ABO and RhD: methods, compatibility, discrepancies, practice'**
  String get bloodGroupLabCardBody;

  /// No description provided for @autoPresTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic presentation'**
  String get autoPresTitle;

  /// No description provided for @autoPresEntrySub.
  ///
  /// In en, this message translates to:
  /// **'Slides built from the app’s sourced content'**
  String get autoPresEntrySub;

  /// No description provided for @autoPresPickerSub.
  ///
  /// In en, this message translates to:
  /// **'Pick a topic or tests. Slides are assembled only from sourced content already in the app — nothing is made up.'**
  String get autoPresPickerSub;

  /// No description provided for @autoPresLanguageNote.
  ///
  /// In en, this message translates to:
  /// **'Slides use the app language. Content missing in this language is skipped — languages are never mixed.'**
  String get autoPresLanguageNote;

  /// No description provided for @autoPresModeTopic.
  ///
  /// In en, this message translates to:
  /// **'By topic'**
  String get autoPresModeTopic;

  /// No description provided for @autoPresModeTests.
  ///
  /// In en, this message translates to:
  /// **'By tests'**
  String get autoPresModeTests;

  /// No description provided for @autoPresSearch.
  ///
  /// In en, this message translates to:
  /// **'Search tests'**
  String get autoPresSearch;

  /// No description provided for @autoPresSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, abbreviation or synonym'**
  String get autoPresSearchHint;

  /// No description provided for @autoPresSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Selected: {count} of {max}'**
  String autoPresSelectedCount(int count, int max);

  /// No description provided for @autoPresLimitReached.
  ///
  /// In en, this message translates to:
  /// **'No more than {max} tests per presentation.'**
  String autoPresLimitReached(int max);

  /// No description provided for @autoPresNoResults.
  ///
  /// In en, this message translates to:
  /// **'No tests found.'**
  String get autoPresNoResults;

  /// No description provided for @autoPresOptQuiz.
  ///
  /// In en, this message translates to:
  /// **'Question slides'**
  String get autoPresOptQuiz;

  /// No description provided for @autoPresOptQuizSub.
  ///
  /// In en, this message translates to:
  /// **'Practice questions of the selected content; the answer opens on tap.'**
  String get autoPresOptQuizSub;

  /// No description provided for @autoPresOptGeneral.
  ///
  /// In en, this message translates to:
  /// **'General preanalytics'**
  String get autoPresOptGeneral;

  /// No description provided for @autoPresOptGeneralSub.
  ///
  /// In en, this message translates to:
  /// **'Order of draw, hemolysis, tourniquet (WHO, 2010).'**
  String get autoPresOptGeneralSub;

  /// No description provided for @autoPresPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview slides'**
  String get autoPresPreview;

  /// No description provided for @autoPresPickFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a topic or at least one test first.'**
  String get autoPresPickFirst;

  /// No description provided for @autoPresPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Slide preview'**
  String get autoPresPreviewTitle;

  /// No description provided for @autoPresPreviewSub.
  ///
  /// In en, this message translates to:
  /// **'Reorder or remove slides, then start.'**
  String get autoPresPreviewSub;

  /// No description provided for @autoPresSlideCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 slide} other{{count} slides}}'**
  String autoPresSlideCount(int count);

  /// No description provided for @autoPresStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get autoPresStart;

  /// No description provided for @autoPresMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get autoPresMoveUp;

  /// No description provided for @autoPresMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get autoPresMoveDown;

  /// No description provided for @autoPresRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove slide'**
  String get autoPresRemove;

  /// No description provided for @autoPresRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore removed slides'**
  String get autoPresRestore;

  /// No description provided for @autoPresSourcesPinned.
  ///
  /// In en, this message translates to:
  /// **'Sources slide — built automatically from the slides you keep'**
  String get autoPresSourcesPinned;

  /// No description provided for @autoPresEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough sourced content'**
  String get autoPresEmptyTitle;

  /// No description provided for @autoPresEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'The app has no sourced content for this selection in the current language, so no slides were made. Nothing is filled in with made-up text.'**
  String get autoPresEmptyBody;

  /// No description provided for @autoPresNoticeStructureOnly.
  ///
  /// In en, this message translates to:
  /// **'{name}: the card has no written content yet — skipped.'**
  String autoPresNoticeStructureOnly(String name);

  /// No description provided for @autoPresNoticeNoContent.
  ///
  /// In en, this message translates to:
  /// **'{name}: no sourced text to build slides from — skipped.'**
  String autoPresNoticeNoContent(String name);

  /// No description provided for @autoPresNoticeLang.
  ///
  /// In en, this message translates to:
  /// **'Not available in this language, so skipped: {count}. Languages are never mixed.'**
  String autoPresNoticeLang(int count);

  /// No description provided for @autoPresDeckTitleTests.
  ///
  /// In en, this message translates to:
  /// **'Laboratory tests'**
  String get autoPresDeckTitleTests;

  /// No description provided for @autoPresMoreItems.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String autoPresMoreItems(int count);

  /// No description provided for @autoPresPackSource.
  ///
  /// In en, this message translates to:
  /// **'LabGuide, content pack {version} — slides are assembled automatically from the cited cards'**
  String autoPresPackSource(String version);

  /// No description provided for @autoPresSourceLine.
  ///
  /// In en, this message translates to:
  /// **'Source: {text}'**
  String autoPresSourceLine(String text);

  /// No description provided for @autoPresColIndicator.
  ///
  /// In en, this message translates to:
  /// **'Indicator'**
  String get autoPresColIndicator;

  /// No description provided for @autoPresColValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get autoPresColValue;

  /// No description provided for @autoPresColTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get autoPresColTarget;

  /// No description provided for @autoPresColTube.
  ///
  /// In en, this message translates to:
  /// **'Tube'**
  String get autoPresColTube;

  /// No description provided for @autoPresColCap.
  ///
  /// In en, this message translates to:
  /// **'Cap color'**
  String get autoPresColCap;

  /// No description provided for @autoPresShowAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show answer'**
  String get autoPresShowAnswer;

  /// No description provided for @autoPresHideAnswer.
  ///
  /// In en, this message translates to:
  /// **'Hide answer'**
  String get autoPresHideAnswer;

  /// No description provided for @autoPresAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get autoPresAnswerLabel;

  /// No description provided for @autoPresTplTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get autoPresTplTitle;

  /// No description provided for @autoPresTplBullets.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get autoPresTplBullets;

  /// No description provided for @autoPresTplTable.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get autoPresTplTable;

  /// No description provided for @autoPresTplFigure.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get autoPresTplFigure;

  /// No description provided for @autoPresTplQa.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get autoPresTplQa;

  /// No description provided for @instSchematicCaption.
  ///
  /// In en, this message translates to:
  /// **'Schematic illustration — not a photo of this exact model'**
  String get instSchematicCaption;

  /// No description provided for @instSchematicTapToZoom.
  ///
  /// In en, this message translates to:
  /// **'Tap the illustration to enlarge'**
  String get instSchematicTapToZoom;

  /// No description provided for @instSchematicNotPhoto.
  ///
  /// In en, this message translates to:
  /// **'An original generic class schematic drawn by LabGuide. It is not a real photograph of the manufacturer’s instrument; parts are shown at principle level and do not represent model-specific features.'**
  String get instSchematicNotPhoto;

  /// No description provided for @instSchematicSemantics.
  ///
  /// In en, this message translates to:
  /// **'Schematic illustration: {kind}'**
  String instSchematicSemantics(String kind);

  /// Lab tab: histology section title (tissues and organs)
  ///
  /// In en, this message translates to:
  /// **'Histology'**
  String get histoTitle;

  /// Lab tab: histology picture card subtitle
  ///
  /// In en, this message translates to:
  /// **'Tissues and organs: real micrographs, key features, practice'**
  String get histoLabCardBody;

  /// No description provided for @contactRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact & reports'**
  String get contactRowTitle;

  /// No description provided for @contactRowSub.
  ///
  /// In en, this message translates to:
  /// **'Questions, complaints, report a problem'**
  String get contactRowSub;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactTitle;

  /// No description provided for @contactIntro.
  ///
  /// In en, this message translates to:
  /// **'Works without internet or an account: the message is sent from your mail app.'**
  String get contactIntro;

  /// No description provided for @contactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactEmailLabel;

  /// No description provided for @contactCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get contactCopy;

  /// No description provided for @contactCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get contactCopied;

  /// No description provided for @contactNoMailApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open a mail app. The address was copied: send your message from any mail service.'**
  String get contactNoMailApp;

  /// No description provided for @contactQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions and suggestions'**
  String get contactQuestionTitle;

  /// No description provided for @contactQuestionBody.
  ///
  /// In en, this message translates to:
  /// **'Ask about the app, suggest a topic or an improvement.'**
  String get contactQuestionBody;

  /// No description provided for @contactQuestionAction.
  ///
  /// In en, this message translates to:
  /// **'Write an email'**
  String get contactQuestionAction;

  /// No description provided for @contactAdTitle.
  ///
  /// In en, this message translates to:
  /// **'Advertising and partnership'**
  String get contactAdTitle;

  /// No description provided for @contactAdBody.
  ///
  /// In en, this message translates to:
  /// **'Laboratory equipment makers, distributors and service companies can advertise in LabGuide.\nWrite to us, or use the partner form if it is available in your version.'**
  String get contactAdBody;

  /// No description provided for @contactAdAction.
  ///
  /// In en, this message translates to:
  /// **'Write about advertising'**
  String get contactAdAction;

  /// No description provided for @contactReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a problem'**
  String get contactReportTitle;

  /// No description provided for @contactReportBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us about wrong medical content or inappropriate user content.'**
  String get contactReportBody;

  /// No description provided for @contactReportHint.
  ///
  /// In en, this message translates to:
  /// **'Please name the section or card so we can find it quickly.'**
  String get contactReportHint;

  /// No description provided for @contactReportAction.
  ///
  /// In en, this message translates to:
  /// **'Send a report'**
  String get contactReportAction;

  /// No description provided for @contactResponseNote.
  ///
  /// In en, this message translates to:
  /// **'We read every report and fix confirmed errors, but we cannot promise a reply time. This address is not for medical emergencies.'**
  String get contactResponseNote;

  /// No description provided for @contactPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'If you write to us, we see your email address and what you write.'**
  String get contactPrivacyNote;

  /// Prefilled email body (no personal data)
  ///
  /// In en, this message translates to:
  /// **'Your question or suggestion:\n\n\n---\nApp: LabGuide {version}\nPlatform: {platform}'**
  String contactMailBodyQuestion(String version, String platform);

  /// Prefilled email body (no personal data)
  ///
  /// In en, this message translates to:
  /// **'Company and what you would like to advertise:\n\n\n---\nApp: LabGuide {version}\nPlatform: {platform}'**
  String contactMailBodyAd(String version, String platform);

  /// Prefilled email body (no personal data)
  ///
  /// In en, this message translates to:
  /// **'Section / card name:\nWhat is wrong:\n(Please do not include patient data.)\n\n\n---\nApp: LabGuide {version}\nPlatform: {platform}'**
  String contactMailBodyReport(String version, String platform);

  /// Partner type: a laboratory that provides testing services (home ad slot 1)
  ///
  /// In en, this message translates to:
  /// **'Laboratory service'**
  String get partnerKindLaboratory;

  /// Admin statistics: ad placement on the Home tab for laboratory services
  ///
  /// In en, this message translates to:
  /// **'Home: laboratory service'**
  String get partnerPlacementHomeLab;

  /// Admin statistics: ad placement on the Home tab for equipment firms
  ///
  /// In en, this message translates to:
  /// **'Home: equipment firm'**
  String get partnerPlacementHomeEquipment;

  /// Home tab: title of the demo ad placeholder
  ///
  /// In en, this message translates to:
  /// **'Sample / Demo — ad slot'**
  String get homeAdDemoTitle;

  /// Home tab: demo placeholder text for the laboratory service ad slot
  ///
  /// In en, this message translates to:
  /// **'A partner laboratory service ad will appear here'**
  String get homeAdDemoLabBody;

  /// Home tab: demo placeholder text for the equipment firm ad slot
  ///
  /// In en, this message translates to:
  /// **'An equipment firm ad will appear here'**
  String get homeAdDemoEquipmentBody;

  /// Home tab: button on the demo ad placeholder, opens the become-a-partner page
  ///
  /// In en, this message translates to:
  /// **'Place an ad'**
  String get homeAdDemoCta;

  /// Community moderation (App Store 1.2): cmBlock
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get cmBlock;

  /// Community moderation (App Store 1.2): cmBlockConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Block this user?'**
  String get cmBlockConfirmTitle;

  /// Community moderation (App Store 1.2): cmBlockConfirmBody
  ///
  /// In en, this message translates to:
  /// **'You will no longer see their questions or answers on this device. You can undo this in the community list.'**
  String get cmBlockConfirmBody;

  /// Community moderation (App Store 1.2): cmBlockedDone
  ///
  /// In en, this message translates to:
  /// **'User blocked. Their posts are hidden.'**
  String get cmBlockedDone;

  /// Community moderation (App Store 1.2): cmBlockedHidden
  ///
  /// In en, this message translates to:
  /// **'This post is hidden because you blocked its author.'**
  String get cmBlockedHidden;

  /// No description provided for @cmBlockedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You have blocked 1 user.} other{You have blocked {count} users.}}'**
  String cmBlockedCount(int count);

  /// Community moderation (App Store 1.2): cmUnblockAll
  ///
  /// In en, this message translates to:
  /// **'Unblock everyone'**
  String get cmUnblockAll;

  /// Community moderation (App Store 1.2): cmContactLink
  ///
  /// In en, this message translates to:
  /// **'Contact LabGuide (report a problem)'**
  String get cmContactLink;

  /// Divider text between the email form and the Google/Apple sign-in buttons
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// Apple button label (Apple HIG wording)
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get authSignInApple;

  /// Google button label (Google branding wording)
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInGoogle;

  /// Shown when Google/Apple sign-in fails (not when the user cancels)
  ///
  /// In en, this message translates to:
  /// **'Couldn’t sign in. Check the connection and try again, or use the email code.'**
  String get authSocialFailed;

  /// Shown when the provider reports the email as unverified
  ///
  /// In en, this message translates to:
  /// **'This account’s email isn’t verified, so it can’t be used to sign in. Use the email code instead.'**
  String get authSocialEmailUnverified;

  /// Shown when the provider gave no email on first sign-in
  ///
  /// In en, this message translates to:
  /// **'This account didn’t share an email address. Use the email code instead.'**
  String get authSocialEmailRequired;

  /// Added to the delete-account dialog for accounts linked to Apple
  ///
  /// In en, this message translates to:
  /// **'You signed in with Apple, so Apple will ask you to confirm before the account is deleted. This also disconnects LabGuide from your Apple ID.'**
  String get accountDeleteAppleNote;

  /// Snackbar when the user cancels the Apple confirmation during account deletion
  ///
  /// In en, this message translates to:
  /// **'Nothing was deleted: Apple confirmation was canceled.'**
  String get accountDeleteAppleCancelled;

  /// Lab tab: title of the urinalysis section and its picture card
  ///
  /// In en, this message translates to:
  /// **'Urinalysis'**
  String get urinTitle;

  /// Lab tab: one-line description on the urinalysis picture card
  ///
  /// In en, this message translates to:
  /// **'Collection, strip test, sediment pictures, result reader, practice'**
  String get urinLabCardBody;

  /// Lab tab: title of the coagulogram (hemostasis tests) section and its picture card
  ///
  /// In en, this message translates to:
  /// **'Coagulogram'**
  String get coagTitle;

  /// Lab tab: one-line description on the coagulogram picture card
  ///
  /// In en, this message translates to:
  /// **'PT/INR, APTT, fibrinogen, D-dimer, sample rules, DIC score'**
  String get coagLabCardBody;

  /// Lab tab: title of the stool analysis (coprology) and intestinal parasites section
  ///
  /// In en, this message translates to:
  /// **'Stool analysis and parasites'**
  String get coproTitle;

  /// Lab tab: one-line description on the coprology picture card
  ///
  /// In en, this message translates to:
  /// **'Coprogram, occult blood, egg and cyst key (schematic)'**
  String get coproLabCardBody;

  /// No description provided for @admPanelAccess.
  ///
  /// In en, this message translates to:
  /// **'Access: the owner email (ADMIN_EMAILS) and an email code. The server re-checks every request.'**
  String get admPanelAccess;

  /// No description provided for @admOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get admOverview;

  /// No description provided for @admOverviewSub.
  ///
  /// In en, this message translates to:
  /// **'Registered: {total} · online: {online} · new in 7 days: {week}'**
  String admOverviewSub(int total, int online, int week);

  /// No description provided for @admComplaintsRow.
  ///
  /// In en, this message translates to:
  /// **'In-app complaints'**
  String get admComplaintsRow;

  /// No description provided for @admComplaintsRowSub.
  ///
  /// In en, this message translates to:
  /// **'Open: {count}'**
  String admComplaintsRowSub(int count);

  /// No description provided for @admReportsRow.
  ///
  /// In en, this message translates to:
  /// **'Community reports'**
  String get admReportsRow;

  /// No description provided for @admReportsRowSub.
  ///
  /// In en, this message translates to:
  /// **'Unreviewed posts: {count}'**
  String admReportsRowSub(int count);

  /// No description provided for @admEmailNote.
  ///
  /// In en, this message translates to:
  /// **'Complaints and questions sent by email arrive at {email} — check them in the mailbox (they do not reach the app).'**
  String admEmailNote(String email);

  /// No description provided for @admUsersSub.
  ///
  /// In en, this message translates to:
  /// **'Search by email or nickname, role, suspension'**
  String get admUsersSub;

  /// No description provided for @admAuditSub.
  ///
  /// In en, this message translates to:
  /// **'Every admin action is recorded'**
  String get admAuditSub;

  /// No description provided for @admStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads and sales'**
  String get admStoreTitle;

  /// No description provided for @admStoreBody.
  ///
  /// In en, this message translates to:
  /// **'The server cannot see store downloads — App Store Connect and Google Play Console show them. The app has no analytics SDK (privacy policy). Numbers in this panel are accounts that confirmed their email.'**
  String get admStoreBody;

  /// No description provided for @admSales.
  ///
  /// In en, this message translates to:
  /// **'Sales: 0 (no payments yet)'**
  String get admSales;

  /// No description provided for @admAppStoreConnect.
  ///
  /// In en, this message translates to:
  /// **'App Store Connect'**
  String get admAppStoreConnect;

  /// No description provided for @admPlayConsole.
  ///
  /// In en, this message translates to:
  /// **'Google Play Console'**
  String get admPlayConsole;

  /// No description provided for @admStatsAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get admStatsAccounts;

  /// No description provided for @admOnlineNow.
  ///
  /// In en, this message translates to:
  /// **'Online now (5 minutes)'**
  String get admOnlineNow;

  /// No description provided for @admSuspendedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Suspended accounts'**
  String get admSuspendedAccounts;

  /// No description provided for @admStatsActiveNote.
  ///
  /// In en, this message translates to:
  /// **'Online and active — accounts that made a request to the server. Only the minute and day are stored; no IP or device.'**
  String get admStatsActiveNote;

  /// No description provided for @admChartTitle.
  ///
  /// In en, this message translates to:
  /// **'New accounts — last 14 days'**
  String get admChartTitle;

  /// No description provided for @admChartBar.
  ///
  /// In en, this message translates to:
  /// **'{date}: {count} new accounts'**
  String admChartBar(String date, int count);

  /// No description provided for @admChartTotal.
  ///
  /// In en, this message translates to:
  /// **'Total in 14 days: {count}'**
  String admChartTotal(int count);

  /// No description provided for @admStatsObjects.
  ///
  /// In en, this message translates to:
  /// **'Main objects'**
  String get admStatsObjects;

  /// No description provided for @admStatsGroupsCount.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get admStatsGroupsCount;

  /// No description provided for @admStatsTeachers.
  ///
  /// In en, this message translates to:
  /// **'Registered teachers'**
  String get admStatsTeachers;

  /// No description provided for @admStatsStudents.
  ///
  /// In en, this message translates to:
  /// **'Students in groups'**
  String get admStatsStudents;

  /// No description provided for @admStatsAssignments.
  ///
  /// In en, this message translates to:
  /// **'Test sessions'**
  String get admStatsAssignments;

  /// No description provided for @admStatsResults.
  ///
  /// In en, this message translates to:
  /// **'Test results'**
  String get admStatsResults;

  /// No description provided for @admStatsQuestions.
  ///
  /// In en, this message translates to:
  /// **'Community questions'**
  String get admStatsQuestions;

  /// No description provided for @admStatsAnswers.
  ///
  /// In en, this message translates to:
  /// **'Community answers'**
  String get admStatsAnswers;

  /// No description provided for @admStatsComplaintsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open complaints'**
  String get admStatsComplaintsOpen;

  /// No description provided for @admStatsComplaintsResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved complaints'**
  String get admStatsComplaintsResolved;

  /// No description provided for @admStatsReportsOpen.
  ///
  /// In en, this message translates to:
  /// **'Community: unreviewed reports'**
  String get admStatsReportsOpen;

  /// No description provided for @admStatsAwaiting.
  ///
  /// In en, this message translates to:
  /// **'Messages: awaiting reply'**
  String get admStatsAwaiting;

  /// No description provided for @admStatsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {time}'**
  String admStatsUpdated(String time);

  /// No description provided for @admComplaintsTitle.
  ///
  /// In en, this message translates to:
  /// **'In-app complaints'**
  String get admComplaintsTitle;

  /// No description provided for @admApple12Note.
  ///
  /// In en, this message translates to:
  /// **'Handle reports of objectionable content promptly (Apple 1.2 requires timely action; target — 24 hours).'**
  String get admApple12Note;

  /// No description provided for @admFilterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get admFilterOpen;

  /// No description provided for @admFilterResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get admFilterResolved;

  /// No description provided for @admAllKinds.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get admAllKinds;

  /// No description provided for @complaintKindComplaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaintKindComplaint;

  /// No description provided for @complaintKindInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get complaintKindInappropriate;

  /// No description provided for @complaintKindBug.
  ///
  /// In en, this message translates to:
  /// **'Bug'**
  String get complaintKindBug;

  /// No description provided for @complaintKindAd.
  ///
  /// In en, this message translates to:
  /// **'Advertising'**
  String get complaintKindAd;

  /// No description provided for @complaintKindOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get complaintKindOther;

  /// No description provided for @admComplaintsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No complaints in this list'**
  String get admComplaintsEmpty;

  /// No description provided for @admComplaintAnon.
  ///
  /// In en, this message translates to:
  /// **'Guest (no account)'**
  String get admComplaintAnon;

  /// No description provided for @admComplaintFrom.
  ///
  /// In en, this message translates to:
  /// **'From: {email}'**
  String admComplaintFrom(String email);

  /// No description provided for @admComplaintTarget.
  ///
  /// In en, this message translates to:
  /// **'Reference: {ref}'**
  String admComplaintTarget(String ref);

  /// No description provided for @admComplaintNote.
  ///
  /// In en, this message translates to:
  /// **'Admin note'**
  String get admComplaintNote;

  /// No description provided for @admComplaintNoteHint.
  ///
  /// In en, this message translates to:
  /// **'What was done? (admins only)'**
  String get admComplaintNoteHint;

  /// No description provided for @admComplaintSaveNote.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get admComplaintSaveNote;

  /// No description provided for @admComplaintResolve.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved'**
  String get admComplaintResolve;

  /// No description provided for @admComplaintReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get admComplaintReopen;

  /// No description provided for @admComplaintResolvedOn.
  ///
  /// In en, this message translates to:
  /// **'Resolved: {date}'**
  String admComplaintResolvedOn(String date);

  /// No description provided for @admSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get admSaved;

  /// No description provided for @admReportsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reports in this list'**
  String get admReportsEmpty;

  /// No description provided for @admReportOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get admReportOpen;

  /// No description provided for @admReportDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get admReportDismissed;

  /// No description provided for @admReportResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get admReportResolved;

  /// No description provided for @admReportKindQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get admReportKindQuestion;

  /// No description provided for @admReportKindAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get admReportKindAnswer;

  /// No description provided for @admReportCount.
  ///
  /// In en, this message translates to:
  /// **'{reports} reports · {reporters} people'**
  String admReportCount(int reports, int reporters);

  /// No description provided for @admReportReasons.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reasons}'**
  String admReportReasons(String reasons);

  /// No description provided for @admReportDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted'**
  String get admReportDeleted;

  /// No description provided for @admReportAuthorSuspended.
  ///
  /// In en, this message translates to:
  /// **'Author suspended'**
  String get admReportAuthorSuspended;

  /// No description provided for @admReportOpenPost.
  ///
  /// In en, this message translates to:
  /// **'Open post'**
  String get admReportOpenPost;

  /// No description provided for @admReportDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get admReportDismiss;

  /// No description provided for @admReportResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get admReportResolve;

  /// No description provided for @admReportSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend author'**
  String get admReportSuspend;

  /// No description provided for @admReportDismissTitle.
  ///
  /// In en, this message translates to:
  /// **'Dismiss the report?'**
  String get admReportDismissTitle;

  /// No description provided for @admReportDismissBody.
  ///
  /// In en, this message translates to:
  /// **'The reports are closed and no longer count towards automatic suspension. The action is logged.'**
  String get admReportDismissBody;

  /// No description provided for @admReportResolveTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as resolved?'**
  String get admReportResolveTitle;

  /// No description provided for @admReportResolveBody.
  ///
  /// In en, this message translates to:
  /// **'Action has been taken (for example, the post was deleted). The action is logged.'**
  String get admReportResolveBody;

  /// No description provided for @admReportSuspendTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspend the author?'**
  String get admReportSuspendTitle;

  /// No description provided for @admReportSuspendBody.
  ///
  /// In en, this message translates to:
  /// **'The author can no longer post in the community and their posts are hidden. The action is logged.'**
  String get admReportSuspendBody;

  /// No description provided for @admSearchModeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get admSearchModeEmail;

  /// No description provided for @admSearchModeName.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get admSearchModeName;

  /// No description provided for @admSearchEmail.
  ///
  /// In en, this message translates to:
  /// **'Full email (exact match)'**
  String get admSearchEmail;

  /// No description provided for @admSearchName.
  ///
  /// In en, this message translates to:
  /// **'Group nickname (at least 2 characters)'**
  String get admSearchName;

  /// No description provided for @admUsersSearchNote.
  ///
  /// In en, this message translates to:
  /// **'Emails are not stored in plain text: an account is found only by its full email and is shown masked.'**
  String get admUsersSearchNote;

  /// No description provided for @admSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get admSearch;

  /// No description provided for @admStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get admStatusActive;

  /// No description provided for @admStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get admStatusSuspended;

  /// No description provided for @admUserAdminTag.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admUserAdminTag;

  /// No description provided for @admUserTitle.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get admUserTitle;

  /// No description provided for @admUserRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get admUserRole;

  /// No description provided for @admRoleChanged.
  ///
  /// In en, this message translates to:
  /// **'Role changed'**
  String get admRoleChanged;

  /// No description provided for @admRoleSelfNote.
  ///
  /// In en, this message translates to:
  /// **'You cannot change your own role or status here.'**
  String get admRoleSelfNote;

  /// No description provided for @admUserFacts.
  ///
  /// In en, this message translates to:
  /// **'Groups: {owned} (teacher) · {joined} (student) · messages: {threads} · complaints: {complaints}'**
  String admUserFacts(int owned, int joined, int threads, int complaints);

  /// No description provided for @admAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account status'**
  String get admAccountTitle;

  /// No description provided for @admAccountSuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend account'**
  String get admAccountSuspend;

  /// No description provided for @admAccountSuspendTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspend the account?'**
  String get admAccountSuspendTitle;

  /// No description provided for @admAccountSuspendBody.
  ///
  /// In en, this message translates to:
  /// **'The user is signed out on all devices and cannot sign in again (email code, Google, Apple). The app shows them the contact address. The action is logged.'**
  String get admAccountSuspendBody;

  /// No description provided for @admAccountReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get admAccountReactivate;

  /// No description provided for @admAccountReactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivate the account?'**
  String get admAccountReactivateTitle;

  /// No description provided for @admAccountReactivateBody.
  ///
  /// In en, this message translates to:
  /// **'The user can sign in again. The action is logged.'**
  String get admAccountReactivateBody;

  /// No description provided for @admAccountAdminNote.
  ///
  /// In en, this message translates to:
  /// **'An admin account cannot be suspended.'**
  String get admAccountAdminNote;

  /// No description provided for @admUserCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community status'**
  String get admUserCommunity;

  /// No description provided for @admCommunityNone.
  ///
  /// In en, this message translates to:
  /// **'Regular member'**
  String get admCommunityNone;

  /// No description provided for @admUserCommunityFacts.
  ///
  /// In en, this message translates to:
  /// **'Questions: {questions} · answers: {answers} · reporters: {reporters}'**
  String admUserCommunityFacts(int questions, int answers, int reporters);

  /// No description provided for @admCommunitySuspend.
  ///
  /// In en, this message translates to:
  /// **'Suspend in community'**
  String get admCommunitySuspend;

  /// No description provided for @admCommunitySuspendTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspend in the community?'**
  String get admCommunitySuspendTitle;

  /// No description provided for @admCommunitySuspendBody.
  ///
  /// In en, this message translates to:
  /// **'The account can no longer post questions or answers and its posts are hidden. The rest of the app keeps working. The action is logged.'**
  String get admCommunitySuspendBody;

  /// No description provided for @admErrOwner.
  ///
  /// In en, this message translates to:
  /// **'The owner account cannot be suspended.'**
  String get admErrOwner;

  /// No description provided for @admErrSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot apply this action to yourself.'**
  String get admErrSelf;

  /// No description provided for @admErrName.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be 2–40 characters.'**
  String get admErrName;

  /// No description provided for @admAuditBy.
  ///
  /// In en, this message translates to:
  /// **'By: {actor}'**
  String admAuditBy(String actor);

  /// No description provided for @admAuditSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get admAuditSystem;

  /// No description provided for @adminActionReportDismissed.
  ///
  /// In en, this message translates to:
  /// **'Community report dismissed'**
  String get adminActionReportDismissed;

  /// No description provided for @adminActionReportResolved.
  ///
  /// In en, this message translates to:
  /// **'Community report resolved'**
  String get adminActionReportResolved;

  /// No description provided for @adminActionCommunitySuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended in community'**
  String get adminActionCommunitySuspended;

  /// No description provided for @adminActionCommunityRestored.
  ///
  /// In en, this message translates to:
  /// **'Restored in community'**
  String get adminActionCommunityRestored;

  /// No description provided for @adminActionCommunityRevoked.
  ///
  /// In en, this message translates to:
  /// **'Specialist verification revoked'**
  String get adminActionCommunityRevoked;

  /// No description provided for @adminActionAutoSuspended.
  ///
  /// In en, this message translates to:
  /// **'Automatically suspended after reports'**
  String get adminActionAutoSuspended;

  /// No description provided for @adminActionPostDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted'**
  String get adminActionPostDeleted;

  /// No description provided for @adminActionPinned.
  ///
  /// In en, this message translates to:
  /// **'Question pin changed'**
  String get adminActionPinned;

  /// No description provided for @adminActionAccountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get adminActionAccountDeleted;

  /// No description provided for @adminActionMfa.
  ///
  /// In en, this message translates to:
  /// **'2FA enabled'**
  String get adminActionMfa;

  /// No description provided for @adminActionTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher registered'**
  String get adminActionTeacher;

  /// No description provided for @adminActionRoleChanged.
  ///
  /// In en, this message translates to:
  /// **'Role changed'**
  String get adminActionRoleChanged;

  /// No description provided for @adminActionAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Account suspended'**
  String get adminActionAccountSuspended;

  /// No description provided for @adminActionAccountReactivated.
  ///
  /// In en, this message translates to:
  /// **'Account reactivated'**
  String get adminActionAccountReactivated;

  /// No description provided for @adminActionComplaintNote.
  ///
  /// In en, this message translates to:
  /// **'Complaint note added'**
  String get adminActionComplaintNote;

  /// No description provided for @adminActionComplaintResolved.
  ///
  /// In en, this message translates to:
  /// **'Complaint resolved'**
  String get adminActionComplaintResolved;

  /// No description provided for @adminActionComplaintReopened.
  ///
  /// In en, this message translates to:
  /// **'Complaint reopened'**
  String get adminActionComplaintReopened;

  /// No description provided for @adminActionIdentityLinked.
  ///
  /// In en, this message translates to:
  /// **'Sign-in method linked'**
  String get adminActionIdentityLinked;

  /// No description provided for @complaintFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a complaint in the app'**
  String get complaintFormTitle;

  /// No description provided for @complaintFormBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us about objectionable content, a bug or another problem — the LabGuide team will review it (usually within 24 hours).'**
  String get complaintFormBody;

  /// No description provided for @complaintKindLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get complaintKindLabel;

  /// No description provided for @complaintText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get complaintText;

  /// No description provided for @complaintTextHint.
  ///
  /// In en, this message translates to:
  /// **'What happened? Which screen or post?'**
  String get complaintTextHint;

  /// No description provided for @complaintTarget.
  ///
  /// In en, this message translates to:
  /// **'Reference: {ref}'**
  String complaintTarget(String ref);

  /// No description provided for @complaintSend.
  ///
  /// In en, this message translates to:
  /// **'Send complaint'**
  String get complaintSend;

  /// No description provided for @complaintSent.
  ///
  /// In en, this message translates to:
  /// **'Sent. Thank you — we will review it.'**
  String get complaintSent;

  /// No description provided for @complaintTooShort.
  ///
  /// In en, this message translates to:
  /// **'Write at least 5 characters.'**
  String get complaintTooShort;

  /// No description provided for @complaintRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many complaints: up to 5 per hour. Try again in {minutes} min.'**
  String complaintRateLimited(int minutes);

  /// No description provided for @complaintAnonNote.
  ///
  /// In en, this message translates to:
  /// **'Without an account we cannot reply to you. If you need a reply, sign in or send an email.'**
  String get complaintAnonNote;

  /// No description provided for @complaintPhiNote.
  ///
  /// In en, this message translates to:
  /// **'Do not include patient names or other personal data.'**
  String get complaintPhiNote;

  /// No description provided for @complaintFailed.
  ///
  /// In en, this message translates to:
  /// **'Not sent. Check your connection and try again.'**
  String get complaintFailed;

  /// No description provided for @authAccountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended. If you have questions, write to: {email}'**
  String authAccountSuspended(String email);

  /// No description provided for @admSectionComplaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get admSectionComplaints;

  /// Lab tab: blood morphology section title (peripheral blood film: red cells, platelets, anemias)
  ///
  /// In en, this message translates to:
  /// **'Blood morphology'**
  String get bloodMorphTitle;

  /// Lab tab: blood morphology picture card subtitle
  ///
  /// In en, this message translates to:
  /// **'Red cells, platelets, anemias: real micrographs, helper, practice'**
  String get bloodMorphLabCardBody;

  /// No description provided for @lectureSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search presentations'**
  String get lectureSearchLabel;

  /// No description provided for @lectureSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Topic, test or slide title (e.g. glucose)'**
  String get lectureSearchHint;

  /// No description provided for @lectureFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get lectureFilterAll;

  /// No description provided for @lectureFilterProtocols.
  ///
  /// In en, this message translates to:
  /// **'Practical protocols'**
  String get lectureFilterProtocols;

  /// No description provided for @lectureFilterModule.
  ///
  /// In en, this message translates to:
  /// **'Module {n}'**
  String lectureFilterModule(int n);

  /// No description provided for @lectureLangAll.
  ///
  /// In en, this message translates to:
  /// **'All languages'**
  String get lectureLangAll;

  /// No description provided for @lectureDecksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} presentation} other{{count} presentations}}'**
  String lectureDecksCount(int count);

  /// No description provided for @lectureSlidesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} slide} other{{count} slides}}'**
  String lectureSlidesCount(int count);

  /// No description provided for @lectureSlidesMatch.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} slide matches} other{{count} slides match}}'**
  String lectureSlidesMatch(int count);

  /// No description provided for @lectureMoreSlides.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String lectureMoreSlides(int count);

  /// No description provided for @lectureResultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} presentation found} other{{count} presentations found}}'**
  String lectureResultsFound(int count);

  /// No description provided for @lectureNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get lectureNoResultsTitle;

  /// No description provided for @lectureNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try another word or filter. Search works in Uzbek (Latin or Cyrillic), Russian and English.'**
  String get lectureNoResultsBody;

  /// No description provided for @lectureClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear search and filters'**
  String get lectureClearFilters;

  /// No description provided for @lectureLangFallback.
  ///
  /// In en, this message translates to:
  /// **'This presentation is not available in {wanted}; shown in {shown}'**
  String lectureLangFallback(String wanted, String shown);

  /// No description provided for @lectureDeckLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the presentation'**
  String get lectureDeckLoadFailed;

  /// No description provided for @lectureFullscreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get lectureFullscreen;

  /// No description provided for @lectureFullscreenExit.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get lectureFullscreenExit;

  /// No description provided for @lectureSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Slide sources'**
  String get lectureSourcesTitle;

  /// No description provided for @lectureSourcesOpen.
  ///
  /// In en, this message translates to:
  /// **'Show full sources'**
  String get lectureSourcesOpen;

  /// No description provided for @lectureSourcesCount.
  ///
  /// In en, this message translates to:
  /// **'Sources: {count}'**
  String lectureSourcesCount(int count);

  /// No description provided for @lectureSourceLocator.
  ///
  /// In en, this message translates to:
  /// **'Section/page: {loc}'**
  String lectureSourceLocator(String loc);

  /// No description provided for @lectureSourcesHint.
  ///
  /// In en, this message translates to:
  /// **'The full list is on the last “References” slide.'**
  String get lectureSourcesHint;

  /// No description provided for @lectureRotateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rotate the screen to landscape?'**
  String get lectureRotateTitle;

  /// No description provided for @lectureRotateBody.
  ///
  /// In en, this message translates to:
  /// **'In landscape the slide fills the whole screen. “No” keeps the current orientation.'**
  String get lectureRotateBody;

  /// No description provided for @lectureRotateCastBody.
  ///
  /// In en, this message translates to:
  /// **'TVs and monitors are landscape, so landscape is recommended when casting.'**
  String get lectureRotateCastBody;

  /// No description provided for @lectureRotateYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get lectureRotateYes;

  /// No description provided for @lectureRotateNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get lectureRotateNo;

  /// No description provided for @lectureRotateRemember.
  ///
  /// In en, this message translates to:
  /// **'Don’t ask again'**
  String get lectureRotateRemember;

  /// No description provided for @lectureOrientationMenu.
  ///
  /// In en, this message translates to:
  /// **'Screen orientation when presenting'**
  String get lectureOrientationMenu;

  /// No description provided for @lectureOrientationAsk.
  ///
  /// In en, this message translates to:
  /// **'Always ask'**
  String get lectureOrientationAsk;

  /// No description provided for @lectureOrientationLandscape.
  ///
  /// In en, this message translates to:
  /// **'Always landscape'**
  String get lectureOrientationLandscape;

  /// No description provided for @lectureOrientationKeep.
  ///
  /// In en, this message translates to:
  /// **'Don’t rotate'**
  String get lectureOrientationKeep;

  /// No description provided for @lectureMore.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get lectureMore;

  /// No description provided for @lectureCast.
  ///
  /// In en, this message translates to:
  /// **'Show on TV'**
  String get lectureCast;

  /// No description provided for @lectureCastTitle.
  ///
  /// In en, this message translates to:
  /// **'Show on a TV or monitor'**
  String get lectureCastTitle;

  /// No description provided for @lectureCastHow.
  ///
  /// In en, this message translates to:
  /// **'Casting uses your phone’s built-in screen mirroring: the TV shows the phone screen. In presentation mode the screen shows only the slide (no buttons) and stays on.'**
  String get lectureCastHow;

  /// No description provided for @lectureCastStepsAndroid.
  ///
  /// In en, this message translates to:
  /// **'1. Connect the phone and the TV to the same Wi‑Fi network.\n2. Open “Cast screen” (Cast, Smart View, Miracast — the name depends on the phone) and pick the TV.\n3. Come back to the app and tap “Start presentation”.'**
  String get lectureCastStepsAndroid;

  /// No description provided for @lectureCastStepsIos.
  ///
  /// In en, this message translates to:
  /// **'1. Connect the iPhone/iPad and the TV (Apple TV or AirPlay-compatible) to the same Wi‑Fi network.\n2. Open Control Center (swipe down from the top-right corner) → Screen Mirroring → pick the TV.\n3. Come back to the app and tap “Start presentation”.'**
  String get lectureCastStepsIos;

  /// No description provided for @lectureCastOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open cast settings'**
  String get lectureCastOpenSettings;

  /// No description provided for @lectureCastSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the settings — find “Cast screen” in Settings or in the quick settings panel.'**
  String get lectureCastSettingsFailed;

  /// No description provided for @lectureCastStart.
  ///
  /// In en, this message translates to:
  /// **'Start presentation'**
  String get lectureCastStart;

  /// No description provided for @lecturePresenter.
  ///
  /// In en, this message translates to:
  /// **'Presenter view'**
  String get lecturePresenter;

  /// No description provided for @lecturePresenterNext.
  ///
  /// In en, this message translates to:
  /// **'Next slide'**
  String get lecturePresenterNext;

  /// No description provided for @lecturePresenterLast.
  ///
  /// In en, this message translates to:
  /// **'This is the last slide'**
  String get lecturePresenterLast;

  /// No description provided for @lecturePresenterTimer.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get lecturePresenterTimer;

  /// No description provided for @lecturePresenterReset.
  ///
  /// In en, this message translates to:
  /// **'Reset timer'**
  String get lecturePresenterReset;

  /// No description provided for @lecturePresenterNote.
  ///
  /// In en, this message translates to:
  /// **'Presenter view is on this device only. When mirroring, the TV shows the same view — use “Full screen” for the audience.'**
  String get lecturePresenterNote;

  /// No description provided for @topicTestAction.
  ///
  /// In en, this message translates to:
  /// **'Topic test'**
  String get topicTestAction;

  /// No description provided for @topicTestPreparing.
  ///
  /// In en, this message translates to:
  /// **'Questions for this topic are being prepared'**
  String get topicTestPreparing;

  /// No description provided for @topicTestPreparingShort.
  ///
  /// In en, this message translates to:
  /// **'Questions in preparation'**
  String get topicTestPreparingShort;

  /// No description provided for @topicTestPreparingBody.
  ///
  /// In en, this message translates to:
  /// **'Only verified questions go into the test. This topic has {count} so far — at least 3 are needed.'**
  String topicTestPreparingBody(int count);

  /// No description provided for @topicTestIntro.
  ///
  /// In en, this message translates to:
  /// **'{count} questions · the correct answer and explanation after each one'**
  String topicTestIntro(int count);

  /// No description provided for @topicTestSavedNote.
  ///
  /// In en, this message translates to:
  /// **'If you leave, your answers are kept — you will continue from the same place.'**
  String get topicTestSavedNote;

  /// No description provided for @topicTestSourcesNote.
  ///
  /// In en, this message translates to:
  /// **'Questions come only from verified sources: official questions with a confirmed key and practice questions with a cited source.'**
  String get topicTestSourcesNote;

  /// No description provided for @topicTestStart.
  ///
  /// In en, this message translates to:
  /// **'Start the test'**
  String get topicTestStart;

  /// No description provided for @topicTestResume.
  ///
  /// In en, this message translates to:
  /// **'Continue · {answered}/{total}'**
  String topicTestResume(int answered, int total);

  /// No description provided for @topicTestBest.
  ///
  /// In en, this message translates to:
  /// **'Best score: {score}/{total}'**
  String topicTestBest(int score, int total);

  /// No description provided for @topicTestBadgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Topic test, best score {score} of {total}'**
  String topicTestBadgeLabel(int score, int total);

  /// No description provided for @topicTestRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get topicTestRetake;

  /// No description provided for @topicTestNextTopic.
  ///
  /// In en, this message translates to:
  /// **'Next topic'**
  String get topicTestNextTopic;

  /// No description provided for @topicTestOpenSlide.
  ///
  /// In en, this message translates to:
  /// **'View slide'**
  String get topicTestOpenSlide;

  /// No description provided for @topicTestOpenDeckStart.
  ///
  /// In en, this message translates to:
  /// **'Open the presentation from the start'**
  String get topicTestOpenDeckStart;

  /// No description provided for @topicTestHistory.
  ///
  /// In en, this message translates to:
  /// **'Result history'**
  String get topicTestHistory;

  /// No description provided for @topicTestAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign to a group'**
  String get topicTestAssign;

  /// No description provided for @topicTestLimitBody.
  ///
  /// In en, this message translates to:
  /// **'Each student gets {minutes} min from the moment they start. When time runs out, answers are submitted automatically.'**
  String topicTestLimitBody(int minutes);

  /// No description provided for @topicTestLimitNoneBody.
  ///
  /// In en, this message translates to:
  /// **'No time limit — students can take the test any time before the deadline.'**
  String get topicTestLimitNoneBody;

  /// No description provided for @topicTestOpenFor.
  ///
  /// In en, this message translates to:
  /// **'How long the test stays open'**
  String get topicTestOpenFor;

  /// No description provided for @topicTestAssignSub.
  ///
  /// In en, this message translates to:
  /// **'Students join by QR or code; you see the results'**
  String get topicTestAssignSub;

  /// No description provided for @topicTestSelf.
  ///
  /// In en, this message translates to:
  /// **'Try it myself'**
  String get topicTestSelf;

  /// No description provided for @topicTestSelfSub.
  ///
  /// In en, this message translates to:
  /// **'Saved only on your device; not sent to students'**
  String get topicTestSelfSub;

  /// No description provided for @topicTestAssignIntro.
  ///
  /// In en, this message translates to:
  /// **'Students take the test on their own phones before the deadline; the score is calculated on the server.'**
  String get topicTestAssignIntro;

  /// No description provided for @topicTestGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get topicTestGroups;

  /// No description provided for @topicTestNoGroups.
  ///
  /// In en, this message translates to:
  /// **'You have no groups yet'**
  String get topicTestNoGroups;

  /// No description provided for @topicTestNoGroupsBody.
  ///
  /// In en, this message translates to:
  /// **'Create a group and invite students first — then assign the test from here.'**
  String get topicTestNoGroupsBody;

  /// No description provided for @topicTestPickGroup.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one group'**
  String get topicTestPickGroup;

  /// No description provided for @topicTestReveal.
  ///
  /// In en, this message translates to:
  /// **'Correct answers shown to students'**
  String get topicTestReveal;

  /// No description provided for @topicTestRevealNow.
  ///
  /// In en, this message translates to:
  /// **'Right after submitting'**
  String get topicTestRevealNow;

  /// No description provided for @topicTestRevealAfterDue.
  ///
  /// In en, this message translates to:
  /// **'After the deadline'**
  String get topicTestRevealAfterDue;

  /// No description provided for @topicTestRevealNeedsDue.
  ///
  /// In en, this message translates to:
  /// **'Choose a deadline to use “After the deadline”'**
  String get topicTestRevealNeedsDue;

  /// No description provided for @topicTestSent.
  ///
  /// In en, this message translates to:
  /// **'Test sent to groups: {count}'**
  String topicTestSent(int count);

  /// No description provided for @topicTestTitle.
  ///
  /// In en, this message translates to:
  /// **'Topic test: {title}'**
  String topicTestTitle(String title);

  /// No description provided for @topicTestSentList.
  ///
  /// In en, this message translates to:
  /// **'Sent tests'**
  String get topicTestSentList;

  /// No description provided for @topicTestAnswersLater.
  ///
  /// In en, this message translates to:
  /// **'Correct answers open after the deadline ({date}) or when the teacher closes the test'**
  String topicTestAnswersLater(String date);

  /// No description provided for @topicTestDistribution.
  ///
  /// In en, this message translates to:
  /// **'Score distribution'**
  String get topicTestDistribution;

  /// No description provided for @topicTestHardest.
  ///
  /// In en, this message translates to:
  /// **'Hardest questions'**
  String get topicTestHardest;

  /// No description provided for @topicTestAssignedTitle.
  ///
  /// In en, this message translates to:
  /// **'Assigned tests'**
  String get topicTestAssignedTitle;

  /// No description provided for @topicTestMenu.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get topicTestMenu;

  /// No description provided for @topicTestOpenLecture.
  ///
  /// In en, this message translates to:
  /// **'Open the presentation'**
  String get topicTestOpenLecture;

  /// No description provided for @topicTestCreateGroup.
  ///
  /// In en, this message translates to:
  /// **'Create a group'**
  String get topicTestCreateGroup;

  /// No description provided for @topicTestStudents.
  ///
  /// In en, this message translates to:
  /// **'Students: {count}'**
  String topicTestStudents(int count);

  /// No description provided for @topicTestReworkMistakes.
  ///
  /// In en, this message translates to:
  /// **'Review mistakes · {count}'**
  String topicTestReworkMistakes(int count);

  /// No description provided for @cmErrAbusive.
  ///
  /// In en, this message translates to:
  /// **'The text contains offensive or abusive language. Please rephrase it respectfully — the community rules require this.'**
  String get cmErrAbusive;

  /// No description provided for @admDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get admDeleteTitle;

  /// No description provided for @admDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'For deletion requests received by email (completed within 30 days). To confirm, enter the user’s full email — the server checks that it belongs to exactly this account. The account, group memberships, community posts, support threads and sign-in methods are deleted permanently; for Sign in with Apple users the server attempts to revoke the Apple token. This cannot be undone; the action is logged.'**
  String get admDeleteNote;

  /// No description provided for @admDeleteEmail.
  ///
  /// In en, this message translates to:
  /// **'User’s full email'**
  String get admDeleteEmail;

  /// No description provided for @admDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete account permanently'**
  String get admDeleteButton;

  /// No description provided for @admDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this account permanently?'**
  String get admDeleteConfirmTitle;

  /// No description provided for @admDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The account {email} and all data linked to it will be deleted. This cannot be undone.'**
  String admDeleteConfirmBody(String email);

  /// No description provided for @admDeleteDone.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get admDeleteDone;

  /// No description provided for @admDeleteMismatch.
  ///
  /// In en, this message translates to:
  /// **'This email does not belong to this account — check it and try again.'**
  String get admDeleteMismatch;

  /// Analyte card: one line listing the card sources (D-65).
  ///
  /// In en, this message translates to:
  /// **'Based on sources: {sources}'**
  String analyteSourcesBased(String sources);

  /// Title of the calm literature panel on lab sections (D-65).
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesPanelTitle;

  /// One neutral medical-safety line under the sources panel (D-65).
  ///
  /// In en, this message translates to:
  /// **'Educational reference, not a diagnosis: a physician interprets results with clinical data; reference intervals depend on the laboratory and method.'**
  String get sourcesDisclaimer;

  /// Reference tables: books are cited only (no copied text).
  ///
  /// In en, this message translates to:
  /// **'Books are cited as sources only — no text or figures were copied. The conclusion is the doctor’s.'**
  String get refBooksNote;

  /// One literature line: Author, year, «title», chapter/page (D-65).
  ///
  /// In en, this message translates to:
  /// **'Source: {cite}'**
  String sourceLine(String cite);

  /// Core pack: content is source-based.
  ///
  /// In en, this message translates to:
  /// **'Source-based learning reference — every card lists its literature'**
  String get packsCoreSources;

  /// Exam: the result is internal practice, not an official grade.
  ///
  /// In en, this message translates to:
  /// **'The result is for internal practice, not an official grade.'**
  String get examPracticeNotice;

  /// Sources panel: how many more sources are in the full list below.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more — in the list below'**
  String sourcesPanelMore(int count);

  /// No description provided for @classesPasteLink.
  ///
  /// In en, this message translates to:
  /// **'Paste link'**
  String get classesPasteLink;

  /// No description provided for @classesPasteNoCode.
  ///
  /// In en, this message translates to:
  /// **'No invite code in the copied text. Copy the link or code your teacher sent.'**
  String get classesPasteNoCode;

  /// No description provided for @classesScanTip.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code with your phone camera and tap “Open in app” on the page that opens — the code fills in by itself.'**
  String get classesScanTip;

  /// No description provided for @qrScanAction.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get qrScanAction;

  /// No description provided for @qrScanHint.
  ///
  /// In en, this message translates to:
  /// **'Fit the group or test QR code from your teacher inside the frame'**
  String get qrScanHint;

  /// No description provided for @qrScanTorchOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on flashlight'**
  String get qrScanTorchOn;

  /// No description provided for @qrScanTorchOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off flashlight'**
  String get qrScanTorchOff;

  /// No description provided for @qrScanTypeCode.
  ///
  /// In en, this message translates to:
  /// **'Type or paste the code'**
  String get qrScanTypeCode;

  /// No description provided for @qrScanNotInvite.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a LabGuide group invite'**
  String get qrScanNotInvite;

  /// No description provided for @qrScanDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get qrScanDeniedTitle;

  /// No description provided for @qrScanDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'To read the QR code, allow LabGuide to use the camera in Settings. The camera image is read on the phone only — it is not saved or sent. Or type the code yourself or paste the link.'**
  String get qrScanDeniedBody;

  /// No description provided for @qrScanOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get qrScanOpenSettings;

  /// No description provided for @qrScanFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open the camera'**
  String get qrScanFailedTitle;

  /// No description provided for @qrScanFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Type the code yourself or paste the link from your teacher.'**
  String get qrScanFailedBody;

  /// No description provided for @qrScanStarting.
  ///
  /// In en, this message translates to:
  /// **'Opening camera…'**
  String get qrScanStarting;

  /// No description provided for @classesJoinOpensTest.
  ///
  /// In en, this message translates to:
  /// **'After joining, your teacher’s test opens right away.'**
  String get classesJoinOpensTest;

  /// No description provided for @classesJoinSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to join the group'**
  String get classesJoinSignInTitle;

  /// No description provided for @classesJoinSignInBody.
  ///
  /// In en, this message translates to:
  /// **'With Google, Apple or an email code — it takes a minute. Your result reaches the teacher through this account; the invite code is kept.'**
  String get classesJoinSignInBody;

  /// No description provided for @classesNicknameTaken.
  ///
  /// In en, this message translates to:
  /// **'This nickname is taken in the group — choose another.'**
  String get classesNicknameTaken;

  /// No description provided for @classesNicknameAbusive.
  ///
  /// In en, this message translates to:
  /// **'The nickname contains an inappropriate word — choose another.'**
  String get classesNicknameAbusive;

  /// No description provided for @classesTestQr.
  ///
  /// In en, this message translates to:
  /// **'Test QR'**
  String get classesTestQr;

  /// No description provided for @classesTestQrBody.
  ///
  /// In en, this message translates to:
  /// **'Students scan → sign in → nickname → this test opens. Results on this page update by themselves.'**
  String get classesTestQrBody;

  /// No description provided for @classesInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get classesInviteLink;

  /// No description provided for @classesLiveNote.
  ///
  /// In en, this message translates to:
  /// **'Results refresh every 10 seconds. Pull down to refresh now.'**
  String get classesLiveNote;

  /// No description provided for @boardOpen.
  ///
  /// In en, this message translates to:
  /// **'Big screen'**
  String get boardOpen;

  /// No description provided for @boardJoined.
  ///
  /// In en, this message translates to:
  /// **'In group'**
  String get boardJoined;

  /// No description provided for @boardStarted.
  ///
  /// In en, this message translates to:
  /// **'Solving'**
  String get boardStarted;

  /// No description provided for @boardSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get boardSubmitted;

  /// No description provided for @boardStatusWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get boardStatusWaiting;

  /// No description provided for @boardStatusSolving.
  ///
  /// In en, this message translates to:
  /// **'Solving…'**
  String get boardStatusSolving;

  /// No description provided for @boardScan.
  ///
  /// In en, this message translates to:
  /// **'Scan to join'**
  String get boardScan;

  /// No description provided for @boardAnswersAfterClose.
  ///
  /// In en, this message translates to:
  /// **'Correct answers appear after the test is closed.'**
  String get boardAnswersAfterClose;

  /// No description provided for @boardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody yet — scan the QR.'**
  String get boardEmpty;

  /// No description provided for @boardClose.
  ///
  /// In en, this message translates to:
  /// **'Exit big screen'**
  String get boardClose;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @variantToggle.
  ///
  /// In en, this message translates to:
  /// **'Different questions for each student'**
  String get variantToggle;

  /// No description provided for @variantOnBody.
  ///
  /// In en, this message translates to:
  /// **'Each student gets {n} of the topic’s {pool} questions, balanced across sub-topics.'**
  String variantOnBody(int pool, int n);

  /// No description provided for @variantOffBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone gets the same questions (in shuffled order).'**
  String get variantOffBody;

  /// No description provided for @variantDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'This topic has {pool} questions — different sets need at least {need} (twice the question count). Lower the question count.'**
  String variantDisabledBody(int pool, int need);

  /// No description provided for @variantUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Variant tests are not supported by this server.'**
  String get variantUnsupported;

  /// No description provided for @variantPoolTitle.
  ///
  /// In en, this message translates to:
  /// **'Question pool ({pool})'**
  String variantPoolTitle(int pool);

  /// No description provided for @variantLabel.
  ///
  /// In en, this message translates to:
  /// **'Variant test'**
  String get variantLabel;

  /// No description provided for @variantPerStudent.
  ///
  /// In en, this message translates to:
  /// **'{n} questions per student from a pool of {pool}'**
  String variantPerStudent(int n, int pool);

  /// No description provided for @variantReceived.
  ///
  /// In en, this message translates to:
  /// **'Given to {n} students'**
  String variantReceived(int n);

  /// No description provided for @homeResumeCta.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeResumeCta;

  /// No description provided for @homeResumeBody.
  ///
  /// In en, this message translates to:
  /// **'Last opened: {title}'**
  String homeResumeBody(String title);

  /// No description provided for @homeHeroLabToifaCta.
  ///
  /// In en, this message translates to:
  /// **'Today’s assessment practice'**
  String get homeHeroLabToifaCta;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & contact'**
  String get helpTitle;

  /// No description provided for @helpSub.
  ///
  /// In en, this message translates to:
  /// **'In the app or by email — question, suggestion, complaint'**
  String get helpSub;

  /// No description provided for @helpIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose what suits you: an in-app message thread (the reply arrives here) or email (complaint, privacy request).'**
  String get helpIntro;

  /// No description provided for @learnSectionQuizzesTitle.
  ///
  /// In en, this message translates to:
  /// **'Section practice'**
  String get learnSectionQuizzesTitle;

  /// No description provided for @learnSectionQuizRow.
  ///
  /// In en, this message translates to:
  /// **'{section} — practice'**
  String learnSectionQuizRow(String section);

  /// No description provided for @classesNicknameInvalid.
  ///
  /// In en, this message translates to:
  /// **'A nickname may contain only letters, digits, spaces and . _ \' -, and must start and end with a letter or digit (no emoji or symbols like !?@).'**
  String get classesNicknameInvalid;

  /// No description provided for @classesGroupFull.
  ///
  /// In en, this message translates to:
  /// **'The group is full (200 people) — tell your teacher.'**
  String get classesGroupFull;

  /// No description provided for @classesCodeAmbiguous.
  ///
  /// In en, this message translates to:
  /// **'Codes never contain 0, O, 1 or I. Check the code with your teacher or scan the QR.'**
  String get classesCodeAmbiguous;

  /// No description provided for @classesOwnGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'You are this group’s teacher'**
  String get classesOwnGroupTitle;

  /// No description provided for @classesOwnGroupBody.
  ///
  /// In en, this message translates to:
  /// **'This account created the group, so it can’t join it as a student (switching the role in Profile doesn’t change that). To try it as a student, sign in with another account or take the test in student view.'**
  String get classesOwnGroupBody;

  /// No description provided for @classesOwnGroupOpen.
  ///
  /// In en, this message translates to:
  /// **'Open as teacher'**
  String get classesOwnGroupOpen;

  /// No description provided for @classesSwitchAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in with another account'**
  String get classesSwitchAccount;

  /// No description provided for @classesPreviewAsStudent.
  ///
  /// In en, this message translates to:
  /// **'Try as a student'**
  String get classesPreviewAsStudent;

  /// No description provided for @classesPreviewNote.
  ///
  /// In en, this message translates to:
  /// **'Trial mode: answers are not sent to the server and don’t appear in the results.'**
  String get classesPreviewNote;

  /// No description provided for @classesPreviewResult.
  ///
  /// In en, this message translates to:
  /// **'Trial finished: {correct} / {total} correct. Nothing was submitted.'**
  String classesPreviewResult(int correct, int total);

  /// No description provided for @classesGiveTopicTest.
  ///
  /// In en, this message translates to:
  /// **'Give a topic test'**
  String get classesGiveTopicTest;

  /// No description provided for @classesGiveTopicTestSub.
  ///
  /// In en, this message translates to:
  /// **'Pick a topic — the next page sets the number of questions, variants, due date and when answers open.'**
  String get classesGiveTopicTestSub;

  /// No description provided for @classesTopicSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search topics (e.g. anemia)'**
  String get classesTopicSearchHint;

  /// No description provided for @classesTopicNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No topic with a ready test found'**
  String get classesTopicNoMatch;

  /// No description provided for @classesTopicQuestions.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String classesTopicQuestions(int count);

  /// No description provided for @examDeadlineAt.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String examDeadlineAt(String date);

  /// No description provided for @classesScanAskNick.
  ///
  /// In en, this message translates to:
  /// **'Before joining, enter a nickname — your teacher sees your result under it (optional: leave empty to show your seat number). Then tap “Join”.'**
  String get classesScanAskNick;

  /// No description provided for @classesMyNickname.
  ///
  /// In en, this message translates to:
  /// **'My nickname'**
  String get classesMyNickname;

  /// No description provided for @classesNoNickname.
  ///
  /// In en, this message translates to:
  /// **'None — your teacher sees your seat number'**
  String get classesNoNickname;

  /// No description provided for @classesNicknameSaved.
  ///
  /// In en, this message translates to:
  /// **'Nickname saved'**
  String get classesNicknameSaved;

  /// No description provided for @classesNicknameNote.
  ///
  /// In en, this message translates to:
  /// **'Don’t use your real name. Leave empty to show your seat number.'**
  String get classesNicknameNote;

  /// No description provided for @rolesTeacherRegisterNote.
  ///
  /// In en, this message translates to:
  /// **'“Continue” registers your account as a teacher: you manage only the groups you create and see their results (not admin rights).'**
  String get rolesTeacherRegisterNote;

  /// No description provided for @rolesTeacherSignInNote.
  ///
  /// In en, this message translates to:
  /// **'Sign in to create groups — the signed-in account registers as a teacher with one tap when creating a group.'**
  String get rolesTeacherSignInNote;

  /// No description provided for @classesGiveGeneralTest.
  ///
  /// In en, this message translates to:
  /// **'Give a general test'**
  String get classesGiveGeneralTest;

  /// No description provided for @generalTestSub.
  ///
  /// In en, this message translates to:
  /// **'From several topics — up to 50 questions'**
  String get generalTestSub;

  /// No description provided for @generalTestIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick topics — questions are spread evenly across them. Students take the test on their phones; the server scores it.'**
  String get generalTestIntro;

  /// No description provided for @generalTestSources.
  ///
  /// In en, this message translates to:
  /// **'Where questions come from'**
  String get generalTestSources;

  /// No description provided for @generalTestSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search topics (e.g. anemia)'**
  String get generalTestSearchHint;

  /// No description provided for @generalSourceToifa.
  ///
  /// In en, this message translates to:
  /// **'Knowledge & Skills Assessment questions'**
  String get generalSourceToifa;

  /// No description provided for @generalSourceToifaSub.
  ///
  /// In en, this message translates to:
  /// **'Official CLD list, keys checked'**
  String get generalSourceToifaSub;

  /// No description provided for @generalSourceLecture.
  ///
  /// In en, this message translates to:
  /// **'Lecture topics'**
  String get generalSourceLecture;

  /// No description provided for @generalSourceLectureSub.
  ///
  /// In en, this message translates to:
  /// **'A whole module or single days'**
  String get generalSourceLectureSub;

  /// No description provided for @generalSourcePack.
  ///
  /// In en, this message translates to:
  /// **'By lab tests'**
  String get generalSourcePack;

  /// No description provided for @generalSourcePackSub.
  ///
  /// In en, this message translates to:
  /// **'Questions from test cards'**
  String get generalSourcePackSub;

  /// No description provided for @generalSourceToifaShort.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get generalSourceToifaShort;

  /// No description provided for @generalSourceLectureShort.
  ///
  /// In en, this message translates to:
  /// **'Lectures'**
  String get generalSourceLectureShort;

  /// No description provided for @generalSourcePackShort.
  ///
  /// In en, this message translates to:
  /// **'Lab tests'**
  String get generalSourcePackShort;

  /// No description provided for @generalSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get generalSelectAll;

  /// No description provided for @generalAllShort.
  ///
  /// In en, this message translates to:
  /// **'all'**
  String get generalAllShort;

  /// No description provided for @generalDays.
  ///
  /// In en, this message translates to:
  /// **'Days · {count}'**
  String generalDays(int count);

  /// No description provided for @generalSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {topics} topics · {questions} questions'**
  String generalSelected(int topics, int questions);

  /// No description provided for @generalPickTopic.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one topic'**
  String get generalPickTopic;

  /// No description provided for @generalTestTitle.
  ///
  /// In en, this message translates to:
  /// **'General test: {topics}'**
  String generalTestTitle(String topics);

  /// No description provided for @generalTestNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Midterm 1'**
  String get generalTestNameHint;

  /// No description provided for @calSafeKind.
  ///
  /// In en, this message translates to:
  /// **'Record type'**
  String get calSafeKind;

  /// No description provided for @calSafeKindTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get calSafeKindTraining;

  /// No description provided for @calSafeKindLab.
  ///
  /// In en, this message translates to:
  /// **'Laboratory'**
  String get calSafeKindLab;

  /// No description provided for @calSafeTrainingTag.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get calSafeTrainingTag;

  /// No description provided for @calSafeTrainingNote.
  ///
  /// In en, this message translates to:
  /// **'Training record: this is not laboratory evidence.'**
  String get calSafeTrainingNote;

  /// No description provided for @calSafeApprovedBy.
  ///
  /// In en, this message translates to:
  /// **'Approved by (name / role)'**
  String get calSafeApprovedBy;

  /// No description provided for @calSafeApprovedAt.
  ///
  /// In en, this message translates to:
  /// **'Approved on'**
  String get calSafeApprovedAt;

  /// No description provided for @calSafeApproverRequired.
  ///
  /// In en, this message translates to:
  /// **'“Accepted” needs the name or role of the authorized person.'**
  String get calSafeApproverRequired;

  /// No description provided for @calSafeQcAfter.
  ///
  /// In en, this message translates to:
  /// **'QC after calibration'**
  String get calSafeQcAfter;

  /// No description provided for @calSafeQcPass.
  ///
  /// In en, this message translates to:
  /// **'QC passed'**
  String get calSafeQcPass;

  /// No description provided for @calSafeQcFail.
  ///
  /// In en, this message translates to:
  /// **'QC failed'**
  String get calSafeQcFail;

  /// No description provided for @calSafeQcNotRun.
  ///
  /// In en, this message translates to:
  /// **'QC not run'**
  String get calSafeQcNotRun;

  /// No description provided for @calSafeQcNotRunWarn.
  ///
  /// In en, this message translates to:
  /// **'QC not run after calibration'**
  String get calSafeQcNotRunWarn;

  /// No description provided for @calSafeQcPassRequired.
  ///
  /// In en, this message translates to:
  /// **'“Accepted” is possible only when QC after calibration passed.'**
  String get calSafeQcPassRequired;

  /// No description provided for @calSafeSopRef.
  ///
  /// In en, this message translates to:
  /// **'SOP reference (optional)'**
  String get calSafeSopRef;

  /// No description provided for @calSafeLegacyTag.
  ///
  /// In en, this message translates to:
  /// **'Legacy, unverified'**
  String get calSafeLegacyTag;

  /// No description provided for @calSafeHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get calSafeHistory;

  /// No description provided for @calSafeHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No history entries.'**
  String get calSafeHistoryEmpty;

  /// No description provided for @calSafeAuditCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get calSafeAuditCreated;

  /// No description provided for @calSafeAuditEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get calSafeAuditEdited;

  /// No description provided for @calSafeAuditDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get calSafeAuditDeleted;

  /// No description provided for @calSafeHistoryNote.
  ///
  /// In en, this message translates to:
  /// **'History stays even after a record is deleted. It is removed only by “delete local data”.'**
  String get calSafeHistoryNote;

  /// No description provided for @labDirSection.
  ///
  /// In en, this message translates to:
  /// **'Laboratory directions (reference)'**
  String get labDirSection;

  /// No description provided for @labDirSectionSub.
  ///
  /// In en, this message translates to:
  /// **'Platform and test on separate cards'**
  String get labDirSectionSub;

  /// No description provided for @labDirRowTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} — reference cards'**
  String labDirRowTitle(String name);

  /// No description provided for @labDirTb.
  ///
  /// In en, this message translates to:
  /// **'Tuberculosis (TB) diagnostics'**
  String get labDirTb;

  /// No description provided for @labDirHiv.
  ///
  /// In en, this message translates to:
  /// **'HIV laboratory diagnostics'**
  String get labDirHiv;

  /// No description provided for @labDirTag.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get labDirTag;

  /// No description provided for @labDirNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not added yet'**
  String get labDirNotVerified;

  /// No description provided for @labDirKindPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform (instrument)'**
  String get labDirKindPlatform;

  /// No description provided for @labDirKindTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get labDirKindTest;

  /// No description provided for @labDirKindMethod.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get labDirKindMethod;

  /// No description provided for @labDirVsTest.
  ///
  /// In en, this message translates to:
  /// **'Platform vs test'**
  String get labDirVsTest;

  /// No description provided for @labDirTechnology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get labDirTechnology;

  /// No description provided for @labDirSpecimens.
  ///
  /// In en, this message translates to:
  /// **'Specimens'**
  String get labDirSpecimens;

  /// No description provided for @labDirTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get labDirTasks;

  /// No description provided for @labDirPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Principle'**
  String get labDirPrinciple;

  /// No description provided for @labDirLimitations.
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get labDirLimitations;

  /// No description provided for @labDirQc.
  ///
  /// In en, this message translates to:
  /// **'QC and calibration'**
  String get labDirQc;

  /// No description provided for @labDirErrors.
  ///
  /// In en, this message translates to:
  /// **'Preanalytic and analytic errors'**
  String get labDirErrors;

  /// No description provided for @labDirBiosafety.
  ///
  /// In en, this message translates to:
  /// **'Biosafety'**
  String get labDirBiosafety;

  /// No description provided for @labDirModels.
  ///
  /// In en, this message translates to:
  /// **'Models confirmed by an official source'**
  String get labDirModels;

  /// No description provided for @labDirLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked cards'**
  String get labDirLinked;

  /// No description provided for @labDirStatusNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Check status: sources are listed below; specialist sign-off not yet recorded'**
  String get labDirStatusNeedsReview;

  /// No description provided for @labDirManufacturerNote.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer page (marketing material), not an instruction'**
  String get labDirManufacturerNote;

  /// No description provided for @labDirVirology.
  ///
  /// In en, this message translates to:
  /// **'Virology'**
  String get labDirVirology;

  /// No description provided for @labDirBacteriology.
  ///
  /// In en, this message translates to:
  /// **'Bacteriology'**
  String get labDirBacteriology;

  /// No description provided for @labDirMycology.
  ///
  /// In en, this message translates to:
  /// **'Mycology'**
  String get labDirMycology;

  /// No description provided for @labDirParasitology.
  ///
  /// In en, this message translates to:
  /// **'Parasitology'**
  String get labDirParasitology;

  /// No description provided for @labDirHematology.
  ///
  /// In en, this message translates to:
  /// **'Haematology'**
  String get labDirHematology;

  /// No description provided for @labDirCoagulation.
  ///
  /// In en, this message translates to:
  /// **'Coagulation (haemostasis)'**
  String get labDirCoagulation;

  /// No description provided for @labDirTransfusion.
  ///
  /// In en, this message translates to:
  /// **'Transfusion medicine'**
  String get labDirTransfusion;

  /// No description provided for @labDirBiochemistry.
  ///
  /// In en, this message translates to:
  /// **'Clinical biochemistry'**
  String get labDirBiochemistry;

  /// No description provided for @labDirImmunology.
  ///
  /// In en, this message translates to:
  /// **'Immunology'**
  String get labDirImmunology;

  /// No description provided for @labDirUrinalysis.
  ///
  /// In en, this message translates to:
  /// **'Urinalysis'**
  String get labDirUrinalysis;

  /// No description provided for @labDirCytology.
  ///
  /// In en, this message translates to:
  /// **'Cytology'**
  String get labDirCytology;

  /// No description provided for @labDirHistology.
  ///
  /// In en, this message translates to:
  /// **'Histology'**
  String get labDirHistology;

  /// No description provided for @labDirOncology.
  ///
  /// In en, this message translates to:
  /// **'Oncology'**
  String get labDirOncology;

  /// No description provided for @labDirGenetics.
  ///
  /// In en, this message translates to:
  /// **'Genetics'**
  String get labDirGenetics;

  /// No description provided for @labDirMolecular.
  ///
  /// In en, this message translates to:
  /// **'Molecular diagnostics'**
  String get labDirMolecular;

  /// No description provided for @labDirToxicology.
  ///
  /// In en, this message translates to:
  /// **'Toxicology'**
  String get labDirToxicology;

  /// No description provided for @labDirReproductive.
  ///
  /// In en, this message translates to:
  /// **'Reproductive medicine'**
  String get labDirReproductive;

  /// No description provided for @labDirNeonatal.
  ///
  /// In en, this message translates to:
  /// **'Neonatal laboratory diagnostics'**
  String get labDirNeonatal;

  /// No description provided for @labDirTransplant.
  ///
  /// In en, this message translates to:
  /// **'Transplantation'**
  String get labDirTransplant;

  /// No description provided for @labDirGeneral.
  ///
  /// In en, this message translates to:
  /// **'General laboratory'**
  String get labDirGeneral;

  /// No description provided for @labDirDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Educational reference only. The app does not diagnose and is not an operating protocol; decisions rest with an authorised laboratory and clinician.'**
  String get labDirDisclaimer;

  /// No description provided for @labDirEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cards in this direction.'**
  String get labDirEmpty;

  /// No description provided for @labDirPlatformClassNote.
  ///
  /// In en, this message translates to:
  /// **'Class/technology reference — not verified for a specific model'**
  String get labDirPlatformClassNote;

  /// No description provided for @labSchemGcMs.
  ///
  /// In en, this message translates to:
  /// **'GC-MS instrument class — carrier gas cylinder, gas chromatograph with autosampler and a capillary column in the oven, ion source, quadrupole mass analyser, detector, vacuum pumps and data system'**
  String get labSchemGcMs;

  /// No description provided for @labSchemLcMs.
  ///
  /// In en, this message translates to:
  /// **'LC-MS instrument class — solvent bottles, pump, autosampler, column compartment, electrospray ion source, quadrupole mass analyser, detector, vacuum pumps and data system'**
  String get labSchemLcMs;

  /// No description provided for @labSchemMaldiTof.
  ///
  /// In en, this message translates to:
  /// **'MALDI-TOF mass spectrometer class — target plate with sample spots, laser, acceleration grids, flight tube, detector, vacuum pump and spectrum display'**
  String get labSchemMaldiTof;

  /// No description provided for @labSchemMicrobialIdAst.
  ///
  /// In en, this message translates to:
  /// **'Automated microbial identification and susceptibility system class — cassette with suspension tubes and test cards, incubator-reader with optical scanner, loading chamber and monitor'**
  String get labSchemMicrobialIdAst;

  /// No description provided for @labSchemBloodCulture.
  ///
  /// In en, this message translates to:
  /// **'Automated blood culture system class — incubator cabinet with rows of culture bottles (each with a sensor at the bottom and a status light) and a monitor; aerobic and anaerobic bottles beside it'**
  String get labSchemBloodCulture;

  /// No description provided for @labSchemMycobacterialCulture.
  ///
  /// In en, this message translates to:
  /// **'Automated mycobacterial liquid-culture system class — incubator-reader with drawers of culture tubes and status lights, and a monitor; tubes with a fluorescent oxygen sensor at the bottom beside it'**
  String get labSchemMycobacterialCulture;

  /// No description provided for @labSchemFlowCytometer.
  ///
  /// In en, this message translates to:
  /// **'Flow cytometer class — sheath fluid and waste containers, hydrodynamic focusing, laser, flow cell, forward-scatter detector, side-scatter and fluorescence detectors behind dichroic mirrors, sample tube and dot-plot display'**
  String get labSchemFlowCytometer;

  /// No description provided for @labSchemRealTimePcr.
  ///
  /// In en, this message translates to:
  /// **'Real-time PCR instrument class — thermal block with wells, heated lid, optical module with light source, filter wheel and detector, tube strip and amplification-curve display'**
  String get labSchemRealTimePcr;

  /// No description provided for @labSchemCartridgeMolecular.
  ///
  /// In en, this message translates to:
  /// **'Cartridge-based closed molecular platform class — instrument with separate modules (one open with a cartridge inside), disposable multi-chamber cartridge, specimen container and monitor'**
  String get labSchemCartridgeMolecular;

  /// No description provided for @labSchemCoagAnalyzer.
  ///
  /// In en, this message translates to:
  /// **'Automated coagulation analyzer class — cooled reagent positions, measuring cuvettes, pipetting arm, citrate sample tubes, optical clot detection (light source, cuvette, photodetector) and clotting-curve display'**
  String get labSchemCoagAnalyzer;

  /// No description provided for @labSchemElisaReader.
  ///
  /// In en, this message translates to:
  /// **'Microplate (ELISA) reader and washer class — reader with plate carrier and a coloured 96-well plate, light path through a well to the detector, washer with a needle manifold, wash buffer and waste containers'**
  String get labSchemElisaReader;

  /// No description provided for @labSchemBscClass2.
  ///
  /// In en, this message translates to:
  /// **'Class II biological safety cabinet, side section — room air enters the front opening into the front grille, HEPA-filtered air flows down over the work surface, returns through the rear plenum to the blower, and part is exhausted through a second HEPA filter'**
  String get labSchemBscClass2;

  /// No description provided for @labSchemAutoclave.
  ///
  /// In en, this message translates to:
  /// **'Benchtop steam autoclave class — chamber with a loading tray and wrapped items, open door with seal, pressure and temperature gauges, safety valve and water reservoir'**
  String get labSchemAutoclave;

  /// No description provided for @labSchemBloodGasIse.
  ///
  /// In en, this message translates to:
  /// **'Blood gas and electrolyte (ISE) analyzer class — display, printer, sample inlet probe with a blood-gas syringe, sensor cassette with electrodes along the measuring channel, and reagent pack'**
  String get labSchemBloodGasIse;

  /// No description provided for @labSchemHba1cAnalyzer.
  ///
  /// In en, this message translates to:
  /// **'Compact HbA1c analyzer class — display, keypad, printer, rack of EDTA whole-blood tubes with a sampling arm, reagent bottles and waste container'**
  String get labSchemHba1cAnalyzer;

  /// No description provided for @labSchemLabFridge.
  ///
  /// In en, this message translates to:
  /// **'Laboratory refrigerator-freezer class with temperature monitoring — glass-door refrigerator with racks and reagents, freezer compartment, probe in a buffered bottle and a digital data logger outside the unit'**
  String get labSchemLabFridge;

  /// No description provided for @labSchemFluorescenceMicroscope.
  ///
  /// In en, this message translates to:
  /// **'LED fluorescence microscope class — upright microscope with an LED epi-illumination module and filter slider, objectives, stage with slide; inset: bright yellow-green rods on a dark background (how auramine-stained bacilli appear)'**
  String get labSchemFluorescenceMicroscope;

  /// No description provided for @labSchemCasa.
  ///
  /// In en, this message translates to:
  /// **'Computer-aided sperm analysis (CASA) class — microscope with camera and heated stage, chamber slide, cable to a computer display showing tracks of motile spermatozoa'**
  String get labSchemCasa;

  /// No description provided for @labSchemGelCardSystem.
  ///
  /// In en, this message translates to:
  /// **'Gel (microcolumn) card system class — card centrifuge, incubator and an enlarged gel card with six microtubes: in positive tubes red cells stay at the top of or within the gel, in negative tubes they form a button at the bottom'**
  String get labSchemGelCardSystem;

  /// No description provided for @labSchemEsrAnalyzer.
  ///
  /// In en, this message translates to:
  /// **'ESR class — Westergren stand with upright tubes (clear plasma above settled red cells) and an automated reader with closed tubes and an optical reading bar'**
  String get labSchemEsrAnalyzer;

  /// No description provided for @labSchemAggregometer.
  ///
  /// In en, this message translates to:
  /// **'Platelet aggregometer and viscoelastic analyzer class — light-transmission aggregometer with stirred cuvettes, light source and photodetector, aggregation curves; viscoelastic analyzer with cup-and-pin channels and a clot trace'**
  String get labSchemAggregometer;

  /// No description provided for @labSchemElectrophoresis.
  ///
  /// In en, this message translates to:
  /// **'Electrophoresis apparatus class — power supply with leads, chamber with buffer compartments, electrodes, wicks and a support medium with stained protein bands, lifted cover, and a densitometer showing the scan'**
  String get labSchemElectrophoresis;

  /// No description provided for @labSchemOsmometer.
  ///
  /// In en, this message translates to:
  /// **'Freezing-point osmometer class — cooling block with the sample tube, thermistor probe in the sample, stirring wire, display with the freezing curve, keypad and small sample tubes'**
  String get labSchemOsmometer;

  /// No description provided for @labSchemTlc.
  ///
  /// In en, this message translates to:
  /// **'Thin-layer chromatography setup — glass developing tank with lid, solvent and a plate (origin line, separated spots, solvent front); UV lamp over a developed plate: spots appear dark on a fluorescent background'**
  String get labSchemTlc;

  /// No description provided for @labSchemAnalyticalBalance.
  ///
  /// In en, this message translates to:
  /// **'Gravimetric calibration setup — analytical balance with a glass weighing chamber and weighing vessel, pipette dispensing water, water beaker with thermometer'**
  String get labSchemAnalyticalBalance;

  /// No description provided for @imgDiagramCalibrationOverviewAlt.
  ///
  /// In en, this message translates to:
  /// **'Diagram, calibration workflow: 1 model, reagent and instruction revision; 2 calibrator lot, with values from this lot’s value sheet; 3 method-specific preparation; 4 calibration according to the instructions. Decision: post-calibration QC passed? Yes — accepted by an authorized person; no — not accepted, troubleshoot per the IFU and SOP. Parameters come only from the matching IFU.'**
  String get imgDiagramCalibrationOverviewAlt;

  /// No description provided for @imgDiagramDifferentialCountAlt.
  ///
  /// In en, this message translates to:
  /// **'Diagram, manual leukocyte differential: 1 check the film (even, no lines or holes; if poor, make a new one); 2 count in the monolayer with the ×100 oil objective, moving one way without repeating fields; 3 count to the SOP target, usually 100 cells; 4 percentage of each cell type, absolute count = fraction × WBC. Decision: blasts or unidentified cells? Yes — do not interpret yourself, a hematologist or physician reviews the smear; no — compare with the reference interval on your laboratory’s report form.'**
  String get imgDiagramDifferentialCountAlt;

  /// No description provided for @imgDiagramQcDecisionAlt.
  ///
  /// In en, this message translates to:
  /// **'Diagram, QC run decision: 1 measure the control materials; 2 plot them on the Levey–Jennings chart against the target mean ± SD. Decision: is a rejection rule violated (1-3s, 2-2s, R-4s, 4-1s, 10x)? No — accept the run (1-2s alone is a warning only). Yes — reject: stop and do not report patient results; find the cause instead of just repeating QC; fix it and recheck QC and patient samples; report once QC is in control and record the actions.'**
  String get imgDiagramQcDecisionAlt;

  /// No description provided for @imgDiagramPreanalyticsAlt.
  ///
  /// In en, this message translates to:
  /// **'Diagram, preanalytical phase in five steps: 1 prepare for testing (patient preparation); 2 select specimen and additive (tube for the test, order of draw); 3 collect and identify (full name matches the request form); 4 separate and store within sample stability; 5 transport and receive, rechecking labels and forms. Decision: specimen acceptable? Yes — analysis; no — follow the laboratory SOP.'**
  String get imgDiagramPreanalyticsAlt;

  /// No description provided for @imgDiagramPhotometryAlt.
  ///
  /// In en, this message translates to:
  /// **'Diagram, absorbance photometry: light source, filter (wavelength λ), cuvette with light path ℓ, detector and result. Incident light I0, transmitted light I; absorbance A = log10(I0/I); Beer–Lambert law A = ε·ℓ·c. Measure blank, standard and sample; C = (A sample ÷ A standard) × C standard. Above the linearity limit: dilute, repeat and multiply by the dilution factor. Wavelength, blank and limits follow the reagent IFU.'**
  String get imgDiagramPhotometryAlt;

  /// No description provided for @imgDiagramEducationalFeedbackAlt.
  ///
  /// In en, this message translates to:
  /// **'Diagram, learning from a practice quiz: 1 answer the questions; 2 see your score. Decision: any mistakes? No — try again or choose another topic. Yes — 3 review your mistakes with the correct answer and explanation; 4 practice only the questions you missed, then answer again. An app workflow, not a laboratory procedure.'**
  String get imgDiagramEducationalFeedbackAlt;

  /// No description provided for @imgDiagramCaption.
  ///
  /// In en, this message translates to:
  /// **'General diagram drawn for LabGuide. Your instrument’s IFU and your laboratory SOP take precedence.'**
  String get imgDiagramCaption;

  /// No description provided for @imgDiagramTapToZoom.
  ///
  /// In en, this message translates to:
  /// **'Tap the diagram to enlarge'**
  String get imgDiagramTapToZoom;

  /// No description provided for @stepUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you'**
  String get stepUpTitle;

  /// No description provided for @stepUpBodyEmail.
  ///
  /// In en, this message translates to:
  /// **'This action needs a fresh confirmation. Enter the 6-digit code sent to {email}.'**
  String stepUpBodyEmail(String email);

  /// No description provided for @stepUpBodyEmailNoAddress.
  ///
  /// In en, this message translates to:
  /// **'This action needs a fresh confirmation. Enter the 6-digit code sent to your email.'**
  String get stepUpBodyEmailNoAddress;

  /// No description provided for @stepUpBodyTotp.
  ///
  /// In en, this message translates to:
  /// **'This action needs a fresh confirmation. Enter the 6-digit code from your authenticator app.'**
  String get stepUpBodyTotp;

  /// No description provided for @stepUpConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get stepUpConfirm;

  /// No description provided for @stepUpCancelled.
  ///
  /// In en, this message translates to:
  /// **'Not done: this action needs a fresh confirmation code.'**
  String get stepUpCancelled;

  /// No description provided for @admRevokeSessions.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all devices'**
  String get admRevokeSessions;

  /// No description provided for @admRevokeSessionsBody.
  ///
  /// In en, this message translates to:
  /// **'The user is signed out on every device. The account stays active and they can sign in again.'**
  String get admRevokeSessionsBody;

  /// No description provided for @admRevokeSessionsDone.
  ///
  /// In en, this message translates to:
  /// **'Sessions ended: {count}.'**
  String admRevokeSessionsDone(int count);

  /// No description provided for @profileSignOutAll.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all devices'**
  String get profileSignOutAll;

  /// No description provided for @profileSignOutAllBody.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out on this phone and on every other device where you signed in. Data on this device is kept.'**
  String get profileSignOutAllBody;

  /// No description provided for @profileSignOutAllDone.
  ///
  /// In en, this message translates to:
  /// **'Signed out on all devices.'**
  String get profileSignOutAllDone;

  /// No description provided for @schemPartsPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Parts and how it works'**
  String get schemPartsPanelTitle;

  /// No description provided for @schemPartsPanelHint.
  ///
  /// In en, this message translates to:
  /// **'Numbered parts, working principle and result'**
  String get schemPartsPanelHint;

  /// No description provided for @schemPartsPartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Main parts'**
  String get schemPartsPartsTitle;

  /// No description provided for @schemPartsPrincipleTitle.
  ///
  /// In en, this message translates to:
  /// **'Working principle'**
  String get schemPartsPrincipleTitle;

  /// No description provided for @schemPartsResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get schemPartsResultTitle;

  /// No description provided for @schemPartsClassNote.
  ///
  /// In en, this message translates to:
  /// **'Parts are shown for the instrument class at principle level; their layout and design in a specific model may differ.'**
  String get schemPartsClassNote;

  /// No description provided for @schemPartsChemistrySamplesName.
  ///
  /// In en, this message translates to:
  /// **'Sample area'**
  String get schemPartsChemistrySamplesName;

  /// No description provided for @schemPartsChemistrySamplesFn.
  ///
  /// In en, this message translates to:
  /// **'Tubes sit in a rack; the probe draws the sample from here.'**
  String get schemPartsChemistrySamplesFn;

  /// No description provided for @schemPartsChemistryReagentsName.
  ///
  /// In en, this message translates to:
  /// **'Cooled reagent carousel'**
  String get schemPartsChemistryReagentsName;

  /// No description provided for @schemPartsChemistryReagentsFn.
  ///
  /// In en, this message translates to:
  /// **'Reagent bottles are kept cool; the required one is turned under the probe.'**
  String get schemPartsChemistryReagentsFn;

  /// No description provided for @schemPartsChemistryProbesName.
  ///
  /// In en, this message translates to:
  /// **'Sample and reagent probes'**
  String get schemPartsChemistryProbesName;

  /// No description provided for @schemPartsChemistryProbesFn.
  ///
  /// In en, this message translates to:
  /// **'Aspirate exact volumes of sample and reagent and dispense them into the reaction cuvette.'**
  String get schemPartsChemistryProbesFn;

  /// No description provided for @schemPartsChemistryReactionName.
  ///
  /// In en, this message translates to:
  /// **'Reaction carousel (cuvettes)'**
  String get schemPartsChemistryReactionName;

  /// No description provided for @schemPartsChemistryReactionFn.
  ///
  /// In en, this message translates to:
  /// **'The mixture in the cuvettes is held at 37 °C; the carousel moves them past the photometer.'**
  String get schemPartsChemistryReactionFn;

  /// No description provided for @schemPartsChemistryPhotometerName.
  ///
  /// In en, this message translates to:
  /// **'Photometer'**
  String get schemPartsChemistryPhotometerName;

  /// No description provided for @schemPartsChemistryPhotometerFn.
  ///
  /// In en, this message translates to:
  /// **'Lamp light passes through the cuvette; grating or filter optics measure absorbance at the selected wavelength.'**
  String get schemPartsChemistryPhotometerFn;

  /// No description provided for @schemPartsChemistryWaterName.
  ///
  /// In en, this message translates to:
  /// **'Purified water container'**
  String get schemPartsChemistryWaterName;

  /// No description provided for @schemPartsChemistryWaterFn.
  ///
  /// In en, this message translates to:
  /// **'Supplies water for washing probes and cuvettes and for dilution.'**
  String get schemPartsChemistryWaterFn;

  /// No description provided for @schemPartsChemistryWasteName.
  ///
  /// In en, this message translates to:
  /// **'Liquid waste container'**
  String get schemPartsChemistryWasteName;

  /// No description provided for @schemPartsChemistryWasteFn.
  ///
  /// In en, this message translates to:
  /// **'Collects wash water and used reaction mixtures.'**
  String get schemPartsChemistryWasteFn;

  /// No description provided for @schemPartsChemistryComputerName.
  ///
  /// In en, this message translates to:
  /// **'Computer and software'**
  String get schemPartsChemistryComputerName;

  /// No description provided for @schemPartsChemistryComputerFn.
  ///
  /// In en, this message translates to:
  /// **'Orders tests, manages calibration, calculates results and issues the report.'**
  String get schemPartsChemistryComputerFn;

  /// No description provided for @schemPartsChemistryPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Probes dispense sample and reagent into a reaction cuvette and the mixture is incubated at 37 °C. The photometer measures absorbance of the light passing through the cuvette at a selected wavelength. Concentration is calculated from calibration; many models also measure Na, K and Cl with an ion-selective electrode (ISE).'**
  String get schemPartsChemistryPrinciple;

  /// No description provided for @schemPartsChemistryResult.
  ///
  /// In en, this message translates to:
  /// **'Analyte concentration for each test (e.g. glucose, enzyme activity, electrolytes): a value calculated from the absorbance change and calibration, plus a report.'**
  String get schemPartsChemistryResult;

  /// No description provided for @schemPartsPhotometerDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display and keypad'**
  String get schemPartsPhotometerDisplayName;

  /// No description provided for @schemPartsPhotometerDisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Select the method, wavelength and standard; the result and curve appear here.'**
  String get schemPartsPhotometerDisplayFn;

  /// No description provided for @schemPartsPhotometerNeedleName.
  ///
  /// In en, this message translates to:
  /// **'Aspiration needle'**
  String get schemPartsPhotometerNeedleName;

  /// No description provided for @schemPartsPhotometerNeedleFn.
  ///
  /// In en, this message translates to:
  /// **'Draws the prepared mixture from the tube into the measuring cell.'**
  String get schemPartsPhotometerNeedleFn;

  /// No description provided for @schemPartsPhotometerCellName.
  ///
  /// In en, this message translates to:
  /// **'Measuring cell (flow cell)'**
  String get schemPartsPhotometerCellName;

  /// No description provided for @schemPartsPhotometerCellFn.
  ///
  /// In en, this message translates to:
  /// **'Lamp → interference filter → cuvette → photodetector: absorbance is measured here.'**
  String get schemPartsPhotometerCellFn;

  /// No description provided for @schemPartsPhotometerPrinterName.
  ///
  /// In en, this message translates to:
  /// **'Thermal printer'**
  String get schemPartsPhotometerPrinterName;

  /// No description provided for @schemPartsPhotometerPrinterFn.
  ///
  /// In en, this message translates to:
  /// **'Prints the results on paper.'**
  String get schemPartsPhotometerPrinterFn;

  /// No description provided for @schemPartsPhotometerWasteName.
  ///
  /// In en, this message translates to:
  /// **'Waste container'**
  String get schemPartsPhotometerWasteName;

  /// No description provided for @schemPartsPhotometerWasteFn.
  ///
  /// In en, this message translates to:
  /// **'Measured mixture and wash liquid drain here.'**
  String get schemPartsPhotometerWasteFn;

  /// No description provided for @schemPartsPhotometerReagentsName.
  ///
  /// In en, this message translates to:
  /// **'Reagent bottles'**
  String get schemPartsPhotometerReagentsName;

  /// No description provided for @schemPartsPhotometerReagentsFn.
  ///
  /// In en, this message translates to:
  /// **'Reagents stand outside the instrument; the operator adds them to the sample by hand.'**
  String get schemPartsPhotometerReagentsFn;

  /// No description provided for @schemPartsPhotometerPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The operator pipettes sample and reagent by hand and incubates the mixture. The instrument aspirates it into a flow cell (or a square cuvette is inserted); lamp light passes the selected interference filter and a photodetector measures absorbance. Concentration is calculated from a standard or a factor.'**
  String get schemPartsPhotometerPrinciple;

  /// No description provided for @schemPartsPhotometerResult.
  ///
  /// In en, this message translates to:
  /// **'The absorbance value and the concentration calculated from it, shown on the display and printed.'**
  String get schemPartsPhotometerResult;

  /// No description provided for @schemPartsHematology5AutoloaderName.
  ///
  /// In en, this message translates to:
  /// **'Autoloader with rack'**
  String get schemPartsHematology5AutoloaderName;

  /// No description provided for @schemPartsHematology5AutoloaderFn.
  ///
  /// In en, this message translates to:
  /// **'Mixes closed tubes and feeds them one by one to the sampler.'**
  String get schemPartsHematology5AutoloaderFn;

  /// No description provided for @schemPartsHematology5ProbeName.
  ///
  /// In en, this message translates to:
  /// **'Sample probe (open mode)'**
  String get schemPartsHematology5ProbeName;

  /// No description provided for @schemPartsHematology5ProbeFn.
  ///
  /// In en, this message translates to:
  /// **'Aspirates a set volume of blood from an open tube held up by hand.'**
  String get schemPartsHematology5ProbeFn;

  /// No description provided for @schemPartsHematology5ImpedanceName.
  ///
  /// In en, this message translates to:
  /// **'Impedance chamber'**
  String get schemPartsHematology5ImpedanceName;

  /// No description provided for @schemPartsHematology5ImpedanceFn.
  ///
  /// In en, this message translates to:
  /// **'Each red cell or platelet passing the aperture gives an electrical pulse: counting and sizing.'**
  String get schemPartsHematology5ImpedanceFn;

  /// No description provided for @schemPartsHematology5LaserName.
  ///
  /// In en, this message translates to:
  /// **'Laser flow cell'**
  String get schemPartsHematology5LaserName;

  /// No description provided for @schemPartsHematology5LaserFn.
  ///
  /// In en, this message translates to:
  /// **'White cells pass the laser beam one at a time and are classified by scatter (and fluorescence).'**
  String get schemPartsHematology5LaserFn;

  /// No description provided for @schemPartsHematology5DisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display (scattergram)'**
  String get schemPartsHematology5DisplayName;

  /// No description provided for @schemPartsHematology5DisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Shows results, scattergrams and histograms.'**
  String get schemPartsHematology5DisplayFn;

  /// No description provided for @schemPartsHematology5ReagentsName.
  ///
  /// In en, this message translates to:
  /// **'Reagents'**
  String get schemPartsHematology5ReagentsName;

  /// No description provided for @schemPartsHematology5ReagentsFn.
  ///
  /// In en, this message translates to:
  /// **'Diluent, lysing and staining solutions are fed through tubing.'**
  String get schemPartsHematology5ReagentsFn;

  /// No description provided for @schemPartsHematology5WasteName.
  ///
  /// In en, this message translates to:
  /// **'Waste container'**
  String get schemPartsHematology5WasteName;

  /// No description provided for @schemPartsHematology5WasteFn.
  ///
  /// In en, this message translates to:
  /// **'Collects used dilutions and wash solutions.'**
  String get schemPartsHematology5WasteFn;

  /// No description provided for @schemPartsHematology5Principle.
  ///
  /// In en, this message translates to:
  /// **'Blood is aspirated, diluted and split into several channels. Red cells and platelets are counted by impedance: a cell passing a small aperture produces a resistance pulse whose size reflects cell volume. The WBC differential is made by flow cytometry from laser light scatter (in some models with dye fluorescence); haemoglobin is measured photometrically after the red cells are lysed.'**
  String get schemPartsHematology5Principle;

  /// No description provided for @schemPartsHematology5Result.
  ///
  /// In en, this message translates to:
  /// **'Complete blood count (CBC) parameters: cell counts and red-cell indices, a 5-part WBC differential, scattergrams and histograms.'**
  String get schemPartsHematology5Result;

  /// No description provided for @schemPartsHematology3PrinterName.
  ///
  /// In en, this message translates to:
  /// **'Thermal printer'**
  String get schemPartsHematology3PrinterName;

  /// No description provided for @schemPartsHematology3PrinterFn.
  ///
  /// In en, this message translates to:
  /// **'Prints results and histograms.'**
  String get schemPartsHematology3PrinterFn;

  /// No description provided for @schemPartsHematology3DisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display (3 histograms)'**
  String get schemPartsHematology3DisplayName;

  /// No description provided for @schemPartsHematology3DisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Shows results and WBC, RBC and PLT histograms (shapes in the picture are schematic).'**
  String get schemPartsHematology3DisplayFn;

  /// No description provided for @schemPartsHematology3ProbeName.
  ///
  /// In en, this message translates to:
  /// **'Sample probe'**
  String get schemPartsHematology3ProbeName;

  /// No description provided for @schemPartsHematology3ProbeFn.
  ///
  /// In en, this message translates to:
  /// **'Aspirates a small volume of blood from an open tube.'**
  String get schemPartsHematology3ProbeFn;

  /// No description provided for @schemPartsHematology3ImpedanceName.
  ///
  /// In en, this message translates to:
  /// **'Impedance chamber'**
  String get schemPartsHematology3ImpedanceName;

  /// No description provided for @schemPartsHematology3ImpedanceFn.
  ///
  /// In en, this message translates to:
  /// **'A cell passing the aperture gives a pulse: the pulse count is the cell count, the pulse size the cell volume.'**
  String get schemPartsHematology3ImpedanceFn;

  /// No description provided for @schemPartsHematology3ReagentsName.
  ///
  /// In en, this message translates to:
  /// **'Diluent and lysing solution'**
  String get schemPartsHematology3ReagentsName;

  /// No description provided for @schemPartsHematology3ReagentsFn.
  ///
  /// In en, this message translates to:
  /// **'For diluting blood and lysing red cells.'**
  String get schemPartsHematology3ReagentsFn;

  /// No description provided for @schemPartsHematology3WasteName.
  ///
  /// In en, this message translates to:
  /// **'Waste container'**
  String get schemPartsHematology3WasteName;

  /// No description provided for @schemPartsHematology3WasteFn.
  ///
  /// In en, this message translates to:
  /// **'Collects used liquids.'**
  String get schemPartsHematology3WasteFn;

  /// No description provided for @schemPartsHematology3Principle.
  ///
  /// In en, this message translates to:
  /// **'Blood is diluted; red cells and platelets are counted by impedance (the Coulter principle) and a volume histogram is built. After lysis, white cells are split by volume into three groups; haemoglobin is measured photometrically.'**
  String get schemPartsHematology3Principle;

  /// No description provided for @schemPartsHematology3Result.
  ///
  /// In en, this message translates to:
  /// **'CBC with a 3-part WBC differential (lymphocytes, mid-size cells, granulocytes) and three histograms (WBC, RBC, PLT).'**
  String get schemPartsHematology3Result;

  /// No description provided for @schemPartsImmunoassaySamplesName.
  ///
  /// In en, this message translates to:
  /// **'Sample rack'**
  String get schemPartsImmunoassaySamplesName;

  /// No description provided for @schemPartsImmunoassaySamplesFn.
  ///
  /// In en, this message translates to:
  /// **'Tubes are placed here; the probe draws the sample.'**
  String get schemPartsImmunoassaySamplesFn;

  /// No description provided for @schemPartsImmunoassayReagentsName.
  ///
  /// In en, this message translates to:
  /// **'Cooled reagent packs'**
  String get schemPartsImmunoassayReagentsName;

  /// No description provided for @schemPartsImmunoassayReagentsFn.
  ///
  /// In en, this message translates to:
  /// **'Microparticles, labelled conjugate and other reagents are kept cool.'**
  String get schemPartsImmunoassayReagentsFn;

  /// No description provided for @schemPartsImmunoassayProbesName.
  ///
  /// In en, this message translates to:
  /// **'Pipetting probes'**
  String get schemPartsImmunoassayProbesName;

  /// No description provided for @schemPartsImmunoassayProbesFn.
  ///
  /// In en, this message translates to:
  /// **'Dispense sample and reagents into the reaction cuvette.'**
  String get schemPartsImmunoassayProbesFn;

  /// No description provided for @schemPartsImmunoassayCuvettesName.
  ///
  /// In en, this message translates to:
  /// **'Cuvette feeder'**
  String get schemPartsImmunoassayCuvettesName;

  /// No description provided for @schemPartsImmunoassayCuvettesFn.
  ///
  /// In en, this message translates to:
  /// **'Supplies single-use reaction cuvettes to the incubator.'**
  String get schemPartsImmunoassayCuvettesFn;

  /// No description provided for @schemPartsImmunoassayIncubatorName.
  ///
  /// In en, this message translates to:
  /// **'Incubator ring'**
  String get schemPartsImmunoassayIncubatorName;

  /// No description provided for @schemPartsImmunoassayIncubatorFn.
  ///
  /// In en, this message translates to:
  /// **'Cuvettes are held at a constant temperature while the antigen–antibody reaction proceeds.'**
  String get schemPartsImmunoassayIncubatorFn;

  /// No description provided for @schemPartsImmunoassayWashName.
  ///
  /// In en, this message translates to:
  /// **'Wash station (magnetic separation)'**
  String get schemPartsImmunoassayWashName;

  /// No description provided for @schemPartsImmunoassayWashFn.
  ///
  /// In en, this message translates to:
  /// **'A magnet holds the microparticles while unbound material is washed away.'**
  String get schemPartsImmunoassayWashFn;

  /// No description provided for @schemPartsImmunoassayLuminometerName.
  ///
  /// In en, this message translates to:
  /// **'Luminometer (detector)'**
  String get schemPartsImmunoassayLuminometerName;

  /// No description provided for @schemPartsImmunoassayLuminometerFn.
  ///
  /// In en, this message translates to:
  /// **'Measures the light emitted by the label by photon counting.'**
  String get schemPartsImmunoassayLuminometerFn;

  /// No description provided for @schemPartsImmunoassaySolidwasteName.
  ///
  /// In en, this message translates to:
  /// **'Solid waste drawer'**
  String get schemPartsImmunoassaySolidwasteName;

  /// No description provided for @schemPartsImmunoassaySolidwasteFn.
  ///
  /// In en, this message translates to:
  /// **'Collects used cuvettes and tips.'**
  String get schemPartsImmunoassaySolidwasteFn;

  /// No description provided for @schemPartsImmunoassayLiquidsName.
  ///
  /// In en, this message translates to:
  /// **'System solutions'**
  String get schemPartsImmunoassayLiquidsName;

  /// No description provided for @schemPartsImmunoassayLiquidsFn.
  ///
  /// In en, this message translates to:
  /// **'Containers of wash and system solutions.'**
  String get schemPartsImmunoassayLiquidsFn;

  /// No description provided for @schemPartsImmunoassayPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The sample is incubated with reagent in a cuvette: the analyte binds an antibody or antigen on magnetic microparticles. While a magnet holds the particles, unbound material is washed away; then the label (enzyme, acridinium ester or ECL label) emits light. The luminometer counts photons and the signal is converted to concentration with a calibration curve.'**
  String get schemPartsImmunoassayPrinciple;

  /// No description provided for @schemPartsImmunoassayResult.
  ///
  /// In en, this message translates to:
  /// **'Concentration of analytes such as hormones, tumour and cardiac markers, or a qualitative positive/negative result, calculated from the light signal by calibration.'**
  String get schemPartsImmunoassayResult;

  /// No description provided for @schemPartsUrineStripSampleName.
  ///
  /// In en, this message translates to:
  /// **'Urine sample and test strip'**
  String get schemPartsUrineStripSampleName;

  /// No description provided for @schemPartsUrineStripSampleFn.
  ///
  /// In en, this message translates to:
  /// **'The strip is briefly dipped in urine and the pads react.'**
  String get schemPartsUrineStripSampleFn;

  /// No description provided for @schemPartsUrineStripTrayName.
  ///
  /// In en, this message translates to:
  /// **'Strip tray (transport)'**
  String get schemPartsUrineStripTrayName;

  /// No description provided for @schemPartsUrineStripTrayFn.
  ///
  /// In en, this message translates to:
  /// **'The strip is placed here and moved under the reading head.'**
  String get schemPartsUrineStripTrayFn;

  /// No description provided for @schemPartsUrineStripHeadName.
  ///
  /// In en, this message translates to:
  /// **'Reading head (LEDs and photosensor)'**
  String get schemPartsUrineStripHeadName;

  /// No description provided for @schemPartsUrineStripHeadFn.
  ///
  /// In en, this message translates to:
  /// **'Lights the pads at several wavelengths and measures the reflected light.'**
  String get schemPartsUrineStripHeadFn;

  /// No description provided for @schemPartsUrineStripDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get schemPartsUrineStripDisplayName;

  /// No description provided for @schemPartsUrineStripDisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Shows results and instrument status.'**
  String get schemPartsUrineStripDisplayFn;

  /// No description provided for @schemPartsUrineStripPrinterName.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get schemPartsUrineStripPrinterName;

  /// No description provided for @schemPartsUrineStripPrinterFn.
  ///
  /// In en, this message translates to:
  /// **'Prints the results.'**
  String get schemPartsUrineStripPrinterFn;

  /// No description provided for @schemPartsUrineStripBinName.
  ///
  /// In en, this message translates to:
  /// **'Used strip bin'**
  String get schemPartsUrineStripBinName;

  /// No description provided for @schemPartsUrineStripBinFn.
  ///
  /// In en, this message translates to:
  /// **'Read strips drop in here.'**
  String get schemPartsUrineStripBinFn;

  /// No description provided for @schemPartsUrineStripPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The test strip is dipped in urine; the reagent in each pad changes colour with its analyte. The instrument moves the strip under the reading head: LEDs of different wavelengths light the pads and a photosensor measures the reflected light (reflectance photometry). Colour intensity is converted to a semi-quantitative grade.'**
  String get schemPartsUrineStripPrinciple;

  /// No description provided for @schemPartsUrineStripResult.
  ///
  /// In en, this message translates to:
  /// **'A qualitative or semi-quantitative result for each pad (e.g. glucose, protein, blood, leukocytes, nitrite, pH, specific gravity) and a printed report.'**
  String get schemPartsUrineStripResult;

  /// No description provided for @schemPartsUrineSystemTransportName.
  ///
  /// In en, this message translates to:
  /// **'Sample transport line'**
  String get schemPartsUrineSystemTransportName;

  /// No description provided for @schemPartsUrineSystemTransportFn.
  ///
  /// In en, this message translates to:
  /// **'Moves tube racks past the modules in turn.'**
  String get schemPartsUrineSystemTransportFn;

  /// No description provided for @schemPartsUrineSystemStripName.
  ///
  /// In en, this message translates to:
  /// **'Chemistry module (test strip)'**
  String get schemPartsUrineSystemStripName;

  /// No description provided for @schemPartsUrineSystemStripFn.
  ///
  /// In en, this message translates to:
  /// **'Reads the strip pads by reflectance and imaging.'**
  String get schemPartsUrineSystemStripFn;

  /// No description provided for @schemPartsUrineSystemNeedlesName.
  ///
  /// In en, this message translates to:
  /// **'Sampling needles'**
  String get schemPartsUrineSystemNeedlesName;

  /// No description provided for @schemPartsUrineSystemNeedlesFn.
  ///
  /// In en, this message translates to:
  /// **'Each module draws sample from the tube with its own needle.'**
  String get schemPartsUrineSystemNeedlesFn;

  /// No description provided for @schemPartsUrineSystemCameraName.
  ///
  /// In en, this message translates to:
  /// **'Sediment module (microscope and camera)'**
  String get schemPartsUrineSystemCameraName;

  /// No description provided for @schemPartsUrineSystemCameraFn.
  ///
  /// In en, this message translates to:
  /// **'Captures digital microscope images of urine particles.'**
  String get schemPartsUrineSystemCameraFn;

  /// No description provided for @schemPartsUrineSystemDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display (particle images)'**
  String get schemPartsUrineSystemDisplayName;

  /// No description provided for @schemPartsUrineSystemDisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Review of classified particle images and results.'**
  String get schemPartsUrineSystemDisplayFn;

  /// No description provided for @schemPartsUrineSystemReagentsName.
  ///
  /// In en, this message translates to:
  /// **'Reagent and wash solution'**
  String get schemPartsUrineSystemReagentsName;

  /// No description provided for @schemPartsUrineSystemReagentsFn.
  ///
  /// In en, this message translates to:
  /// **'Solutions for washing the modules and for measurement.'**
  String get schemPartsUrineSystemReagentsFn;

  /// No description provided for @schemPartsUrineSystemWasteName.
  ///
  /// In en, this message translates to:
  /// **'Waste container'**
  String get schemPartsUrineSystemWasteName;

  /// No description provided for @schemPartsUrineSystemWasteFn.
  ///
  /// In en, this message translates to:
  /// **'Collects used liquids.'**
  String get schemPartsUrineSystemWasteFn;

  /// No description provided for @schemPartsUrineSystemPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Sample racks travel along the transport line to two modules. The chemistry module reads the strip pads by reflectance. The sediment module takes digital microscope images of the urine; software classifies particles (red cells, white cells, casts, crystals, etc.) and the images can be reviewed on screen.'**
  String get schemPartsUrineSystemPrinciple;

  /// No description provided for @schemPartsUrineSystemResult.
  ///
  /// In en, this message translates to:
  /// **'Strip chemistry results plus counts or categories of sediment elements (red cells, white cells, casts, crystals, bacteria, etc.) with images for review.'**
  String get schemPartsUrineSystemResult;

  /// No description provided for @schemPartsMassSpecGcGasName.
  ///
  /// In en, this message translates to:
  /// **'Carrier gas cylinder'**
  String get schemPartsMassSpecGcGasName;

  /// No description provided for @schemPartsMassSpecGcGasFn.
  ///
  /// In en, this message translates to:
  /// **'An inert gas (usually helium) carries the sample through the column.'**
  String get schemPartsMassSpecGcGasFn;

  /// No description provided for @schemPartsMassSpecGcAutosamplerName.
  ///
  /// In en, this message translates to:
  /// **'Autosampler'**
  String get schemPartsMassSpecGcAutosamplerName;

  /// No description provided for @schemPartsMassSpecGcAutosamplerFn.
  ///
  /// In en, this message translates to:
  /// **'Takes the sample from a vial with a syringe and injects it.'**
  String get schemPartsMassSpecGcAutosamplerFn;

  /// No description provided for @schemPartsMassSpecGcInjectorName.
  ///
  /// In en, this message translates to:
  /// **'Injector (inlet)'**
  String get schemPartsMassSpecGcInjectorName;

  /// No description provided for @schemPartsMassSpecGcInjectorFn.
  ///
  /// In en, this message translates to:
  /// **'Heated inlet: the liquid sample vaporises into the gas stream.'**
  String get schemPartsMassSpecGcInjectorFn;

  /// No description provided for @schemPartsMassSpecGcColumnName.
  ///
  /// In en, this message translates to:
  /// **'Oven and capillary column'**
  String get schemPartsMassSpecGcColumnName;

  /// No description provided for @schemPartsMassSpecGcColumnFn.
  ///
  /// In en, this message translates to:
  /// **'Heated by a temperature programme; compounds separate in the column.'**
  String get schemPartsMassSpecGcColumnFn;

  /// No description provided for @schemPartsMassSpecGcTransferName.
  ///
  /// In en, this message translates to:
  /// **'Heated transfer line'**
  String get schemPartsMassSpecGcTransferName;

  /// No description provided for @schemPartsMassSpecGcTransferFn.
  ///
  /// In en, this message translates to:
  /// **'Carries separated compounds into the mass spectrometer without condensation.'**
  String get schemPartsMassSpecGcTransferFn;

  /// No description provided for @schemPartsMassSpecGcSourceName.
  ///
  /// In en, this message translates to:
  /// **'Ion source'**
  String get schemPartsMassSpecGcSourceName;

  /// No description provided for @schemPartsMassSpecGcSourceFn.
  ///
  /// In en, this message translates to:
  /// **'Ionises molecules (in GC-MS usually by electron ionisation), producing fragments.'**
  String get schemPartsMassSpecGcSourceFn;

  /// No description provided for @schemPartsMassSpecGcAnalyserName.
  ///
  /// In en, this message translates to:
  /// **'Mass analyser (quadrupole)'**
  String get schemPartsMassSpecGcAnalyserName;

  /// No description provided for @schemPartsMassSpecGcAnalyserFn.
  ///
  /// In en, this message translates to:
  /// **'Electric fields sort ions by m/z and pass them through in turn.'**
  String get schemPartsMassSpecGcAnalyserFn;

  /// No description provided for @schemPartsMassSpecGcDetectorName.
  ///
  /// In en, this message translates to:
  /// **'Detector (electron multiplier)'**
  String get schemPartsMassSpecGcDetectorName;

  /// No description provided for @schemPartsMassSpecGcDetectorFn.
  ///
  /// In en, this message translates to:
  /// **'Turns arriving ions into an amplified electrical signal.'**
  String get schemPartsMassSpecGcDetectorFn;

  /// No description provided for @schemPartsMassSpecGcVacuumName.
  ///
  /// In en, this message translates to:
  /// **'Vacuum pumps'**
  String get schemPartsMassSpecGcVacuumName;

  /// No description provided for @schemPartsMassSpecGcVacuumFn.
  ///
  /// In en, this message translates to:
  /// **'Turbomolecular and roughing pumps keep a high vacuum so ions do not collide with air molecules.'**
  String get schemPartsMassSpecGcVacuumFn;

  /// No description provided for @schemPartsMassSpecGcDataName.
  ///
  /// In en, this message translates to:
  /// **'Data system'**
  String get schemPartsMassSpecGcDataName;

  /// No description provided for @schemPartsMassSpecGcDataFn.
  ///
  /// In en, this message translates to:
  /// **'Records chromatograms and spectra and compares them with a library.'**
  String get schemPartsMassSpecGcDataFn;

  /// No description provided for @schemPartsMassSpecGcPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The sample is vaporised in the injector and a carrier gas (usually helium) carries it into a capillary column in the oven. Compounds leave the column at different times according to volatility and interaction with the column (retention time). In the mass spectrometer they are ionised, the ions are sorted by mass-to-charge ratio (m/z) and recorded by the detector.'**
  String get schemPartsMassSpecGcPrinciple;

  /// No description provided for @schemPartsMassSpecGcResult.
  ///
  /// In en, this message translates to:
  /// **'A chromatogram (signal against retention time) and a mass spectrum for each peak (m/z against relative intensity); compounds are identified against a spectral library or standards.'**
  String get schemPartsMassSpecGcResult;

  /// No description provided for @schemPartsMassSpecLcSolventsName.
  ///
  /// In en, this message translates to:
  /// **'Mobile phase bottles'**
  String get schemPartsMassSpecLcSolventsName;

  /// No description provided for @schemPartsMassSpecLcSolventsFn.
  ///
  /// In en, this message translates to:
  /// **'Solvents (e.g. water and an organic solvent) feed the pump.'**
  String get schemPartsMassSpecLcSolventsFn;

  /// No description provided for @schemPartsMassSpecLcPumpName.
  ///
  /// In en, this message translates to:
  /// **'High-pressure pump'**
  String get schemPartsMassSpecLcPumpName;

  /// No description provided for @schemPartsMassSpecLcPumpFn.
  ///
  /// In en, this message translates to:
  /// **'Drives the solvents through the column at a steady flow.'**
  String get schemPartsMassSpecLcPumpFn;

  /// No description provided for @schemPartsMassSpecLcAutosamplerName.
  ///
  /// In en, this message translates to:
  /// **'Autosampler'**
  String get schemPartsMassSpecLcAutosamplerName;

  /// No description provided for @schemPartsMassSpecLcAutosamplerFn.
  ///
  /// In en, this message translates to:
  /// **'Takes the sample from a vial and injects it into the flow.'**
  String get schemPartsMassSpecLcAutosamplerFn;

  /// No description provided for @schemPartsMassSpecLcColumnName.
  ///
  /// In en, this message translates to:
  /// **'Column (in a thermostat)'**
  String get schemPartsMassSpecLcColumnName;

  /// No description provided for @schemPartsMassSpecLcColumnFn.
  ///
  /// In en, this message translates to:
  /// **'Compounds separate by their interaction with the column phase.'**
  String get schemPartsMassSpecLcColumnFn;

  /// No description provided for @schemPartsMassSpecLcEsiName.
  ///
  /// In en, this message translates to:
  /// **'Electrospray ion source (ESI)'**
  String get schemPartsMassSpecLcEsiName;

  /// No description provided for @schemPartsMassSpecLcEsiFn.
  ///
  /// In en, this message translates to:
  /// **'Sprays the column eluate into charged droplets, producing ions.'**
  String get schemPartsMassSpecLcEsiFn;

  /// No description provided for @schemPartsMassSpecLcAnalyserName.
  ///
  /// In en, this message translates to:
  /// **'Mass analyser (quadrupole)'**
  String get schemPartsMassSpecLcAnalyserName;

  /// No description provided for @schemPartsMassSpecLcAnalyserFn.
  ///
  /// In en, this message translates to:
  /// **'Electric fields sort ions by m/z and pass them through in turn.'**
  String get schemPartsMassSpecLcAnalyserFn;

  /// No description provided for @schemPartsMassSpecLcDetectorName.
  ///
  /// In en, this message translates to:
  /// **'Detector (electron multiplier)'**
  String get schemPartsMassSpecLcDetectorName;

  /// No description provided for @schemPartsMassSpecLcDetectorFn.
  ///
  /// In en, this message translates to:
  /// **'Turns arriving ions into an amplified electrical signal.'**
  String get schemPartsMassSpecLcDetectorFn;

  /// No description provided for @schemPartsMassSpecLcVacuumName.
  ///
  /// In en, this message translates to:
  /// **'Vacuum pumps'**
  String get schemPartsMassSpecLcVacuumName;

  /// No description provided for @schemPartsMassSpecLcVacuumFn.
  ///
  /// In en, this message translates to:
  /// **'Keep a high vacuum inside the mass analyser.'**
  String get schemPartsMassSpecLcVacuumFn;

  /// No description provided for @schemPartsMassSpecLcDataName.
  ///
  /// In en, this message translates to:
  /// **'Data system'**
  String get schemPartsMassSpecLcDataName;

  /// No description provided for @schemPartsMassSpecLcDataFn.
  ///
  /// In en, this message translates to:
  /// **'Records chromatograms and spectra and calculates amounts.'**
  String get schemPartsMassSpecLcDataFn;

  /// No description provided for @schemPartsMassSpecLcPrinciple.
  ///
  /// In en, this message translates to:
  /// **'A pump drives the liquid mobile phase through the column at high pressure and the autosampler injects the sample into the flow. Compounds separate in the column and leave it at different times. In the electrospray (ESI) source the liquid is sprayed into charged droplets and the compounds become gas-phase ions; the ions are sorted by m/z and recorded by the detector.'**
  String get schemPartsMassSpecLcPrinciple;

  /// No description provided for @schemPartsMassSpecLcResult.
  ///
  /// In en, this message translates to:
  /// **'A chromatogram and mass spectra; target compounds (drugs, metabolites, biomarkers) are identified and their concentration is calculated against calibrators.'**
  String get schemPartsMassSpecLcResult;

  /// No description provided for @schemPartsMaldiTofTargetName.
  ///
  /// In en, this message translates to:
  /// **'Target plate'**
  String get schemPartsMaldiTofTargetName;

  /// No description provided for @schemPartsMaldiTofTargetFn.
  ///
  /// In en, this message translates to:
  /// **'Holds the sample spots with matrix; the plate is loaded into the vacuum chamber.'**
  String get schemPartsMaldiTofTargetFn;

  /// No description provided for @schemPartsMaldiTofLaserName.
  ///
  /// In en, this message translates to:
  /// **'Laser'**
  String get schemPartsMaldiTofLaserName;

  /// No description provided for @schemPartsMaldiTofLaserFn.
  ///
  /// In en, this message translates to:
  /// **'A short pulse desorbs and ionises proteins together with the matrix.'**
  String get schemPartsMaldiTofLaserFn;

  /// No description provided for @schemPartsMaldiTofGridsName.
  ///
  /// In en, this message translates to:
  /// **'Accelerating electrodes'**
  String get schemPartsMaldiTofGridsName;

  /// No description provided for @schemPartsMaldiTofGridsFn.
  ///
  /// In en, this message translates to:
  /// **'High voltage accelerates the ions into the flight tube.'**
  String get schemPartsMaldiTofGridsFn;

  /// No description provided for @schemPartsMaldiTofTubeName.
  ///
  /// In en, this message translates to:
  /// **'Flight tube (TOF)'**
  String get schemPartsMaldiTofTubeName;

  /// No description provided for @schemPartsMaldiTofTubeFn.
  ///
  /// In en, this message translates to:
  /// **'A vacuum tube where ions fly at different speeds according to m/z.'**
  String get schemPartsMaldiTofTubeFn;

  /// No description provided for @schemPartsMaldiTofDetectorName.
  ///
  /// In en, this message translates to:
  /// **'Detector'**
  String get schemPartsMaldiTofDetectorName;

  /// No description provided for @schemPartsMaldiTofDetectorFn.
  ///
  /// In en, this message translates to:
  /// **'Records the arrival time of each ion.'**
  String get schemPartsMaldiTofDetectorFn;

  /// No description provided for @schemPartsMaldiTofVacuumName.
  ///
  /// In en, this message translates to:
  /// **'Vacuum pump'**
  String get schemPartsMaldiTofVacuumName;

  /// No description provided for @schemPartsMaldiTofVacuumFn.
  ///
  /// In en, this message translates to:
  /// **'Creates the vacuum in the source and tube.'**
  String get schemPartsMaldiTofVacuumFn;

  /// No description provided for @schemPartsMaldiTofDatabaseName.
  ///
  /// In en, this message translates to:
  /// **'Computer and spectral database'**
  String get schemPartsMaldiTofDatabaseName;

  /// No description provided for @schemPartsMaldiTofDatabaseFn.
  ///
  /// In en, this message translates to:
  /// **'Compares the spectrum with reference spectra and gives a probability score.'**
  String get schemPartsMaldiTofDatabaseFn;

  /// No description provided for @schemPartsMaldiTofPrinciple.
  ///
  /// In en, this message translates to:
  /// **'A colony is smeared on the target and overlaid with matrix, which crystallises. A laser pulse desorbs and ionises proteins (mainly ribosomal). An electric field accelerates the ions; in the flight tube lighter ions reach the detector before heavier ones, so flight time reflects m/z. The spectrum is compared with reference spectra in the database.'**
  String get schemPartsMaldiTofPrinciple;

  /// No description provided for @schemPartsMaldiTofResult.
  ///
  /// In en, this message translates to:
  /// **'A mass spectrum (protein fingerprint) and the organism name with a probability score (log score); the result is read together with other clinical and laboratory findings.'**
  String get schemPartsMaldiTofResult;

  /// No description provided for @schemPartsMicrobialIdAstCardName.
  ///
  /// In en, this message translates to:
  /// **'Test card (64 wells)'**
  String get schemPartsMicrobialIdAstCardName;

  /// No description provided for @schemPartsMicrobialIdAstCardFn.
  ///
  /// In en, this message translates to:
  /// **'Wells hold antimicrobial dilutions (AST) or biochemical substrates (ID).'**
  String get schemPartsMicrobialIdAstCardFn;

  /// No description provided for @schemPartsMicrobialIdAstSuspensionName.
  ///
  /// In en, this message translates to:
  /// **'Suspension tube'**
  String get schemPartsMicrobialIdAstSuspensionName;

  /// No description provided for @schemPartsMicrobialIdAstSuspensionFn.
  ///
  /// In en, this message translates to:
  /// **'Bacterial suspension of standard density; the straw of the card dips into it.'**
  String get schemPartsMicrobialIdAstSuspensionFn;

  /// No description provided for @schemPartsMicrobialIdAstFillingName.
  ///
  /// In en, this message translates to:
  /// **'Filling chamber'**
  String get schemPartsMicrobialIdAstFillingName;

  /// No description provided for @schemPartsMicrobialIdAstFillingFn.
  ///
  /// In en, this message translates to:
  /// **'Vacuum draws the suspension through the straw into the card wells.'**
  String get schemPartsMicrobialIdAstFillingFn;

  /// No description provided for @schemPartsMicrobialIdAstIncubatorName.
  ///
  /// In en, this message translates to:
  /// **'Incubator'**
  String get schemPartsMicrobialIdAstIncubatorName;

  /// No description provided for @schemPartsMicrobialIdAstIncubatorFn.
  ///
  /// In en, this message translates to:
  /// **'Cards are held at a constant temperature between readings.'**
  String get schemPartsMicrobialIdAstIncubatorFn;

  /// No description provided for @schemPartsMicrobialIdAstScannerName.
  ///
  /// In en, this message translates to:
  /// **'Optical scanner'**
  String get schemPartsMicrobialIdAstScannerName;

  /// No description provided for @schemPartsMicrobialIdAstScannerFn.
  ///
  /// In en, this message translates to:
  /// **'Measures the light through every well every 15 minutes.'**
  String get schemPartsMicrobialIdAstScannerFn;

  /// No description provided for @schemPartsMicrobialIdAstSoftwareName.
  ///
  /// In en, this message translates to:
  /// **'Computer and software'**
  String get schemPartsMicrobialIdAstSoftwareName;

  /// No description provided for @schemPartsMicrobialIdAstSoftwareFn.
  ///
  /// In en, this message translates to:
  /// **'Calculates the MIC and interpretive category from growth curves and issues a report.'**
  String get schemPartsMicrobialIdAstSoftwareFn;

  /// No description provided for @schemPartsMicrobialIdAstPrinciple.
  ///
  /// In en, this message translates to:
  /// **'A suspension of standard density is made from a pure culture and drawn into the card through its straw under vacuum. AST card wells contain antimicrobials at different dilutions (a miniaturised automated MIC method). An optical scanner measures light through the wells every 15 minutes: growth attenuates the light, and software calculates the MIC from the growth kinetics.'**
  String get schemPartsMicrobialIdAstPrinciple;

  /// No description provided for @schemPartsMicrobialIdAstResult.
  ///
  /// In en, this message translates to:
  /// **'An MIC value and interpretive category for each antimicrobial (e.g. susceptible or resistant); with an identification card, the organism species.'**
  String get schemPartsMicrobialIdAstResult;

  /// No description provided for @schemPartsBloodCultureVialsName.
  ///
  /// In en, this message translates to:
  /// **'Blood culture vials'**
  String get schemPartsBloodCultureVialsName;

  /// No description provided for @schemPartsBloodCultureVialsFn.
  ///
  /// In en, this message translates to:
  /// **'Aerobic and anaerobic vials with culture medium; the patient’s blood is added.'**
  String get schemPartsBloodCultureVialsFn;

  /// No description provided for @schemPartsBloodCultureSensorName.
  ///
  /// In en, this message translates to:
  /// **'CO₂ sensor (vial bottom)'**
  String get schemPartsBloodCultureSensorName;

  /// No description provided for @schemPartsBloodCultureSensorFn.
  ///
  /// In en, this message translates to:
  /// **'A dye reacts with CO₂ and changes its fluorescence.'**
  String get schemPartsBloodCultureSensorFn;

  /// No description provided for @schemPartsBloodCultureIncubatorName.
  ///
  /// In en, this message translates to:
  /// **'Incubator cabinet'**
  String get schemPartsBloodCultureIncubatorName;

  /// No description provided for @schemPartsBloodCultureIncubatorFn.
  ///
  /// In en, this message translates to:
  /// **'Vials sit in cells at a constant temperature.'**
  String get schemPartsBloodCultureIncubatorFn;

  /// No description provided for @schemPartsBloodCultureReaderName.
  ///
  /// In en, this message translates to:
  /// **'Reading system'**
  String get schemPartsBloodCultureReaderName;

  /// No description provided for @schemPartsBloodCultureReaderFn.
  ///
  /// In en, this message translates to:
  /// **'A light source and detector under each cell measure the sensor every ten minutes.'**
  String get schemPartsBloodCultureReaderFn;

  /// No description provided for @schemPartsBloodCulturePositiveName.
  ///
  /// In en, this message translates to:
  /// **'Positive vial indicator'**
  String get schemPartsBloodCulturePositiveName;

  /// No description provided for @schemPartsBloodCulturePositiveFn.
  ///
  /// In en, this message translates to:
  /// **'Shows which vial has detected growth.'**
  String get schemPartsBloodCulturePositiveFn;

  /// No description provided for @schemPartsBloodCultureSoftwareName.
  ///
  /// In en, this message translates to:
  /// **'Computer and software'**
  String get schemPartsBloodCultureSoftwareName;

  /// No description provided for @schemPartsBloodCultureSoftwareFn.
  ///
  /// In en, this message translates to:
  /// **'Shows the growth curve and status of each vial.'**
  String get schemPartsBloodCultureSoftwareFn;

  /// No description provided for @schemPartsBloodCulturePrinciple.
  ///
  /// In en, this message translates to:
  /// **'Blood-filled vials are placed in the incubator. Growing microorganisms release CO₂; the dye in the sensor at the vial bottom reacts with CO₂ and its fluorescence rises. The instrument reads the sensor every ten minutes; an algorithm flags the vial positive from the rate of CO₂ production and its absolute increase.'**
  String get schemPartsBloodCulturePrinciple;

  /// No description provided for @schemPartsBloodCultureResult.
  ///
  /// In en, this message translates to:
  /// **'Status of each vial: positive (growth detected) or negative at the end of the protocol, time to positivity and the growth curve. A positive vial goes on to further microbiological work-up.'**
  String get schemPartsBloodCultureResult;

  /// No description provided for @schemPartsMycobacterialCultureTubeName.
  ///
  /// In en, this message translates to:
  /// **'MGIT tube'**
  String get schemPartsMycobacterialCultureTubeName;

  /// No description provided for @schemPartsMycobacterialCultureTubeFn.
  ///
  /// In en, this message translates to:
  /// **'With liquid 7H9 medium and growth supplement (OADC); the specimen is inoculated here.'**
  String get schemPartsMycobacterialCultureTubeFn;

  /// No description provided for @schemPartsMycobacterialCultureSensorName.
  ///
  /// In en, this message translates to:
  /// **'Fluorescent oxygen sensor'**
  String get schemPartsMycobacterialCultureSensorName;

  /// No description provided for @schemPartsMycobacterialCultureSensorFn.
  ///
  /// In en, this message translates to:
  /// **'Fluoresces brightly under UV light as oxygen falls.'**
  String get schemPartsMycobacterialCultureSensorFn;

  /// No description provided for @schemPartsMycobacterialCultureDrawerName.
  ///
  /// In en, this message translates to:
  /// **'Tube drawer (incubation and reading)'**
  String get schemPartsMycobacterialCultureDrawerName;

  /// No description provided for @schemPartsMycobacterialCultureDrawerFn.
  ///
  /// In en, this message translates to:
  /// **'Each station incubates a tube and its fluorescence is measured regularly.'**
  String get schemPartsMycobacterialCultureDrawerFn;

  /// No description provided for @schemPartsMycobacterialCultureLightsName.
  ///
  /// In en, this message translates to:
  /// **'Status lights'**
  String get schemPartsMycobacterialCultureLightsName;

  /// No description provided for @schemPartsMycobacterialCultureLightsFn.
  ///
  /// In en, this message translates to:
  /// **'Indicate positive or completed tubes.'**
  String get schemPartsMycobacterialCultureLightsFn;

  /// No description provided for @schemPartsMycobacterialCulturePanelName.
  ///
  /// In en, this message translates to:
  /// **'Instrument display'**
  String get schemPartsMycobacterialCulturePanelName;

  /// No description provided for @schemPartsMycobacterialCulturePanelFn.
  ///
  /// In en, this message translates to:
  /// **'Shows drawer status and alerts.'**
  String get schemPartsMycobacterialCulturePanelFn;

  /// No description provided for @schemPartsMycobacterialCultureSoftwareName.
  ///
  /// In en, this message translates to:
  /// **'Computer (GU curves)'**
  String get schemPartsMycobacterialCultureSoftwareName;

  /// No description provided for @schemPartsMycobacterialCultureSoftwareFn.
  ///
  /// In en, this message translates to:
  /// **'Records growth and DST results; curves of control and drug tubes are compared.'**
  String get schemPartsMycobacterialCultureSoftwareFn;

  /// No description provided for @schemPartsMycobacterialCulturePrinciple.
  ///
  /// In en, this message translates to:
  /// **'The MGIT tube holds modified Middlebrook 7H9 liquid medium and an oxygen-quenched fluorescent sensor at the bottom. As mycobacteria grow, dissolved oxygen is used up and the sensor fluoresces more brightly under UV light. The instrument reads each tube automatically and records the intensity as growth units (GU). In drug-susceptibility testing (DST) the GU of a drug tube are compared with those of a control tube.'**
  String get schemPartsMycobacterialCulturePrinciple;

  /// No description provided for @schemPartsMycobacterialCultureResult.
  ///
  /// In en, this message translates to:
  /// **'A positive or negative culture and a GU curve; in DST the instrument interprets first-line drugs as susceptible or resistant, while for second-line drugs the user interprets the GU values.'**
  String get schemPartsMycobacterialCultureResult;

  /// No description provided for @schemPartsFlowCytometerSheathName.
  ///
  /// In en, this message translates to:
  /// **'Sheath fluid container'**
  String get schemPartsFlowCytometerSheathName;

  /// No description provided for @schemPartsFlowCytometerSheathFn.
  ///
  /// In en, this message translates to:
  /// **'Surrounds the sample stream and squeezes it into a thin central core.'**
  String get schemPartsFlowCytometerSheathFn;

  /// No description provided for @schemPartsFlowCytometerSampleName.
  ///
  /// In en, this message translates to:
  /// **'Sample tube and probe'**
  String get schemPartsFlowCytometerSampleName;

  /// No description provided for @schemPartsFlowCytometerSampleFn.
  ///
  /// In en, this message translates to:
  /// **'The stained cell suspension is drawn up from here.'**
  String get schemPartsFlowCytometerSampleFn;

  /// No description provided for @schemPartsFlowCytometerFlowcellName.
  ///
  /// In en, this message translates to:
  /// **'Flow cell (hydrodynamic focusing)'**
  String get schemPartsFlowCytometerFlowcellName;

  /// No description provided for @schemPartsFlowCytometerFlowcellFn.
  ///
  /// In en, this message translates to:
  /// **'Cells pass one by one through the point where the laser crosses.'**
  String get schemPartsFlowCytometerFlowcellFn;

  /// No description provided for @schemPartsFlowCytometerLaserName.
  ///
  /// In en, this message translates to:
  /// **'Laser'**
  String get schemPartsFlowCytometerLaserName;

  /// No description provided for @schemPartsFlowCytometerLaserFn.
  ///
  /// In en, this message translates to:
  /// **'Illuminates the cells and excites the fluorochromes.'**
  String get schemPartsFlowCytometerLaserFn;

  /// No description provided for @schemPartsFlowCytometerFscName.
  ///
  /// In en, this message translates to:
  /// **'Forward-scatter (FSC) detector'**
  String get schemPartsFlowCytometerFscName;

  /// No description provided for @schemPartsFlowCytometerFscFn.
  ///
  /// In en, this message translates to:
  /// **'Measures light scattered along the beam, which relates to cell size.'**
  String get schemPartsFlowCytometerFscFn;

  /// No description provided for @schemPartsFlowCytometerSscName.
  ///
  /// In en, this message translates to:
  /// **'Side-scatter and fluorescence detectors'**
  String get schemPartsFlowCytometerSscName;

  /// No description provided for @schemPartsFlowCytometerSscFn.
  ///
  /// In en, this message translates to:
  /// **'Light collected to the side of the beam is split by colour with dichroic mirrors and filters onto separate detectors.'**
  String get schemPartsFlowCytometerSscFn;

  /// No description provided for @schemPartsFlowCytometerWasteName.
  ///
  /// In en, this message translates to:
  /// **'Waste container'**
  String get schemPartsFlowCytometerWasteName;

  /// No description provided for @schemPartsFlowCytometerWasteFn.
  ///
  /// In en, this message translates to:
  /// **'Collects the measured sample and sheath fluid.'**
  String get schemPartsFlowCytometerWasteFn;

  /// No description provided for @schemPartsFlowCytometerComputerName.
  ///
  /// In en, this message translates to:
  /// **'Computer (dot plots)'**
  String get schemPartsFlowCytometerComputerName;

  /// No description provided for @schemPartsFlowCytometerComputerFn.
  ///
  /// In en, this message translates to:
  /// **'Builds dot plots; populations are separated by gating.'**
  String get schemPartsFlowCytometerComputerFn;

  /// No description provided for @schemPartsFlowCytometerPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Cells are usually stained with fluorochrome-labelled antibodies. Sheath fluid hydrodynamically focuses the sample stream so the cells pass in single file through the laser beam. Forward scatter (FSC) reflects cell size, side scatter (SSC) internal complexity and fluorescence the markers; electronics digitise the signals.'**
  String get schemPartsFlowCytometerPrinciple;

  /// No description provided for @schemPartsFlowCytometerResult.
  ///
  /// In en, this message translates to:
  /// **'Dot plots and histograms; the proportion and number of cell populations (e.g. the absolute CD4+ T-cell count using calibrator beads).'**
  String get schemPartsFlowCytometerResult;

  /// No description provided for @schemPartsRealTimePcrTubesName.
  ///
  /// In en, this message translates to:
  /// **'PCR tubes (strip)'**
  String get schemPartsRealTimePcrTubesName;

  /// No description provided for @schemPartsRealTimePcrTubesFn.
  ///
  /// In en, this message translates to:
  /// **'Reaction mix and sample; read through the clear caps.'**
  String get schemPartsRealTimePcrTubesFn;

  /// No description provided for @schemPartsRealTimePcrLidName.
  ///
  /// In en, this message translates to:
  /// **'Heated lid'**
  String get schemPartsRealTimePcrLidName;

  /// No description provided for @schemPartsRealTimePcrLidFn.
  ///
  /// In en, this message translates to:
  /// **'Prevents condensation on the tube caps.'**
  String get schemPartsRealTimePcrLidFn;

  /// No description provided for @schemPartsRealTimePcrBlockName.
  ///
  /// In en, this message translates to:
  /// **'Thermal block (Peltier)'**
  String get schemPartsRealTimePcrBlockName;

  /// No description provided for @schemPartsRealTimePcrBlockFn.
  ///
  /// In en, this message translates to:
  /// **'Rapidly switches between denaturation, annealing and extension temperatures.'**
  String get schemPartsRealTimePcrBlockFn;

  /// No description provided for @schemPartsRealTimePcrSourceName.
  ///
  /// In en, this message translates to:
  /// **'Excitation light source'**
  String get schemPartsRealTimePcrSourceName;

  /// No description provided for @schemPartsRealTimePcrSourceFn.
  ///
  /// In en, this message translates to:
  /// **'Provides light that excites the dye or probe.'**
  String get schemPartsRealTimePcrSourceFn;

  /// No description provided for @schemPartsRealTimePcrFiltersName.
  ///
  /// In en, this message translates to:
  /// **'Filter wheel'**
  String get schemPartsRealTimePcrFiltersName;

  /// No description provided for @schemPartsRealTimePcrFiltersFn.
  ///
  /// In en, this message translates to:
  /// **'Selects excitation and emission filters for each dye (channel).'**
  String get schemPartsRealTimePcrFiltersFn;

  /// No description provided for @schemPartsRealTimePcrDetectorName.
  ///
  /// In en, this message translates to:
  /// **'Detector'**
  String get schemPartsRealTimePcrDetectorName;

  /// No description provided for @schemPartsRealTimePcrDetectorFn.
  ///
  /// In en, this message translates to:
  /// **'Measures fluorescence in every cycle.'**
  String get schemPartsRealTimePcrDetectorFn;

  /// No description provided for @schemPartsRealTimePcrSoftwareName.
  ///
  /// In en, this message translates to:
  /// **'Software (amplification curves)'**
  String get schemPartsRealTimePcrSoftwareName;

  /// No description provided for @schemPartsRealTimePcrSoftwareFn.
  ///
  /// In en, this message translates to:
  /// **'Plots the curves, sets the threshold and calculates Cq values.'**
  String get schemPartsRealTimePcrSoftwareFn;

  /// No description provided for @schemPartsRealTimePcrPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The thermal block changes temperature every cycle: heating separates the DNA strands, primers anneal on cooling and a heat-stable polymerase builds new strands, so the target roughly doubles each cycle (RNA is first converted to cDNA by reverse transcriptase). The optical module reads the fluorescence of an intercalating dye or probe every cycle; the signal is proportional to amplicon accumulation.'**
  String get schemPartsRealTimePcrPrinciple;

  /// No description provided for @schemPartsRealTimePcrResult.
  ///
  /// In en, this message translates to:
  /// **'Amplification curves and, for each sample, the Cq (Ct): the cycle at which fluorescence crosses the threshold; a lower Cq means more starting target. In quantitative tests the concentration is calculated against standards (e.g. HIV-1 viral load in copies/mL).'**
  String get schemPartsRealTimePcrResult;

  /// No description provided for @schemPartsCartridgeMolecularCartridgeName.
  ///
  /// In en, this message translates to:
  /// **'Single-use cartridge'**
  String get schemPartsCartridgeMolecularCartridgeName;

  /// No description provided for @schemPartsCartridgeMolecularCartridgeFn.
  ///
  /// In en, this message translates to:
  /// **'A closed cartridge with sample and reagent chambers; all steps run inside it.'**
  String get schemPartsCartridgeMolecularCartridgeFn;

  /// No description provided for @schemPartsCartridgeMolecularTubeName.
  ///
  /// In en, this message translates to:
  /// **'Reaction tube'**
  String get schemPartsCartridgeMolecularTubeName;

  /// No description provided for @schemPartsCartridgeMolecularTubeFn.
  ///
  /// In en, this message translates to:
  /// **'Amplification and fluorescence detection take place in this part of the cartridge.'**
  String get schemPartsCartridgeMolecularTubeFn;

  /// No description provided for @schemPartsCartridgeMolecularSpecimenName.
  ///
  /// In en, this message translates to:
  /// **'Specimen container'**
  String get schemPartsCartridgeMolecularSpecimenName;

  /// No description provided for @schemPartsCartridgeMolecularSpecimenFn.
  ///
  /// In en, this message translates to:
  /// **'Holds the specimen, such as sputum, which is mixed with reagent.'**
  String get schemPartsCartridgeMolecularSpecimenFn;

  /// No description provided for @schemPartsCartridgeMolecularModuleName.
  ///
  /// In en, this message translates to:
  /// **'Instrument module'**
  String get schemPartsCartridgeMolecularModuleName;

  /// No description provided for @schemPartsCartridgeMolecularModuleFn.
  ///
  /// In en, this message translates to:
  /// **'The cartridge goes in here and is processed automatically; modules run independently.'**
  String get schemPartsCartridgeMolecularModuleFn;

  /// No description provided for @schemPartsCartridgeMolecularSoftwareName.
  ///
  /// In en, this message translates to:
  /// **'Computer and software'**
  String get schemPartsCartridgeMolecularSoftwareName;

  /// No description provided for @schemPartsCartridgeMolecularSoftwareFn.
  ///
  /// In en, this message translates to:
  /// **'Controls the run and reports the interpreted result.'**
  String get schemPartsCartridgeMolecularSoftwareFn;

  /// No description provided for @schemPartsCartridgeMolecularPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The sample is mixed with reagent and added to the cartridge, which is placed in a module. The next steps run automatically inside the closed cartridge: sample processing, nucleic acid extraction, amplification (real-time PCR) and detection. The operator never opens the cartridge, which lowers the risk of amplicon contamination.'**
  String get schemPartsCartridgeMolecularPrinciple;

  /// No description provided for @schemPartsCartridgeMolecularResult.
  ///
  /// In en, this message translates to:
  /// **'For Xpert MTB/RIF: M. tuberculosis complex detected or not detected, and rifampicin resistance detected or not detected, in under 2 hours.'**
  String get schemPartsCartridgeMolecularResult;

  /// No description provided for @schemPartsCoagAnalyzerSamplesName.
  ///
  /// In en, this message translates to:
  /// **'Citrate tube rack'**
  String get schemPartsCoagAnalyzerSamplesName;

  /// No description provided for @schemPartsCoagAnalyzerSamplesFn.
  ///
  /// In en, this message translates to:
  /// **'Sodium citrate tubes (light-blue caps); plasma is drawn from here.'**
  String get schemPartsCoagAnalyzerSamplesFn;

  /// No description provided for @schemPartsCoagAnalyzerReagentsName.
  ///
  /// In en, this message translates to:
  /// **'Cooled reagent block'**
  String get schemPartsCoagAnalyzerReagentsName;

  /// No description provided for @schemPartsCoagAnalyzerReagentsFn.
  ///
  /// In en, this message translates to:
  /// **'Thromboplastin and other reagents are kept cool.'**
  String get schemPartsCoagAnalyzerReagentsFn;

  /// No description provided for @schemPartsCoagAnalyzerArmName.
  ///
  /// In en, this message translates to:
  /// **'Pipetting arm'**
  String get schemPartsCoagAnalyzerArmName;

  /// No description provided for @schemPartsCoagAnalyzerArmFn.
  ///
  /// In en, this message translates to:
  /// **'Dispenses plasma and reagent into the cuvette in exact volumes.'**
  String get schemPartsCoagAnalyzerArmFn;

  /// No description provided for @schemPartsCoagAnalyzerCuvettesName.
  ///
  /// In en, this message translates to:
  /// **'Measuring cuvettes'**
  String get schemPartsCoagAnalyzerCuvettesName;

  /// No description provided for @schemPartsCoagAnalyzerCuvettesFn.
  ///
  /// In en, this message translates to:
  /// **'Plasma is warmed; after reagent is added clot formation is followed.'**
  String get schemPartsCoagAnalyzerCuvettesFn;

  /// No description provided for @schemPartsCoagAnalyzerLightName.
  ///
  /// In en, this message translates to:
  /// **'Light source'**
  String get schemPartsCoagAnalyzerLightName;

  /// No description provided for @schemPartsCoagAnalyzerLightFn.
  ///
  /// In en, this message translates to:
  /// **'Provides the light that passes through the cuvette.'**
  String get schemPartsCoagAnalyzerLightFn;

  /// No description provided for @schemPartsCoagAnalyzerDetectorName.
  ///
  /// In en, this message translates to:
  /// **'Photodetector'**
  String get schemPartsCoagAnalyzerDetectorName;

  /// No description provided for @schemPartsCoagAnalyzerDetectorFn.
  ///
  /// In en, this message translates to:
  /// **'Records the change in transmitted light as the clot forms.'**
  String get schemPartsCoagAnalyzerDetectorFn;

  /// No description provided for @schemPartsCoagAnalyzerDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display (clotting curve)'**
  String get schemPartsCoagAnalyzerDisplayName;

  /// No description provided for @schemPartsCoagAnalyzerDisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Clotting curve, time and calculated INR.'**
  String get schemPartsCoagAnalyzerDisplayFn;

  /// No description provided for @schemPartsCoagAnalyzerPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The probe dispenses citrated plasma into a cuvette and warms it, then reagent is added (for PT, thromboplastin: tissue factor, calcium and phospholipids). As a fibrin clot forms the mixture becomes turbid: optical detection records the change in transmitted light, mechanical detection the stopping of movement. The time to this point is the clotting time.'**
  String get schemPartsCoagAnalyzerPrinciple;

  /// No description provided for @schemPartsCoagAnalyzerResult.
  ///
  /// In en, this message translates to:
  /// **'Clotting time in seconds and a clotting curve; for PT the INR is calculated from the patient PT, the mean normal PT and the reagent ISI.'**
  String get schemPartsCoagAnalyzerResult;

  /// No description provided for @schemPartsElisaReaderPlateName.
  ///
  /// In en, this message translates to:
  /// **'96-well microplate'**
  String get schemPartsElisaReaderPlateName;

  /// No description provided for @schemPartsElisaReaderPlateFn.
  ///
  /// In en, this message translates to:
  /// **'The reaction and colour develop in the wells; the carrier moves the plate into the reader.'**
  String get schemPartsElisaReaderPlateFn;

  /// No description provided for @schemPartsElisaReaderLampName.
  ///
  /// In en, this message translates to:
  /// **'Light source (lamp)'**
  String get schemPartsElisaReaderLampName;

  /// No description provided for @schemPartsElisaReaderLampFn.
  ///
  /// In en, this message translates to:
  /// **'Provides the light that passes through the well.'**
  String get schemPartsElisaReaderLampFn;

  /// No description provided for @schemPartsElisaReaderFilterName.
  ///
  /// In en, this message translates to:
  /// **'Optical filter'**
  String get schemPartsElisaReaderFilterName;

  /// No description provided for @schemPartsElisaReaderFilterFn.
  ///
  /// In en, this message translates to:
  /// **'Passes only the required wavelength.'**
  String get schemPartsElisaReaderFilterFn;

  /// No description provided for @schemPartsElisaReaderWellName.
  ///
  /// In en, this message translates to:
  /// **'Well being read'**
  String get schemPartsElisaReaderWellName;

  /// No description provided for @schemPartsElisaReaderWellFn.
  ///
  /// In en, this message translates to:
  /// **'The coloured solution absorbs part of the light.'**
  String get schemPartsElisaReaderWellFn;

  /// No description provided for @schemPartsElisaReaderDetectorName.
  ///
  /// In en, this message translates to:
  /// **'Photodetector'**
  String get schemPartsElisaReaderDetectorName;

  /// No description provided for @schemPartsElisaReaderDetectorFn.
  ///
  /// In en, this message translates to:
  /// **'Measures the transmitted light, from which absorbance is calculated.'**
  String get schemPartsElisaReaderDetectorFn;

  /// No description provided for @schemPartsElisaReaderWasherName.
  ///
  /// In en, this message translates to:
  /// **'Washer needle manifold'**
  String get schemPartsElisaReaderWasherName;

  /// No description provided for @schemPartsElisaReaderWasherFn.
  ///
  /// In en, this message translates to:
  /// **'Dispenses wash buffer into the wells and aspirates it.'**
  String get schemPartsElisaReaderWasherFn;

  /// No description provided for @schemPartsElisaReaderBufferName.
  ///
  /// In en, this message translates to:
  /// **'Wash buffer container'**
  String get schemPartsElisaReaderBufferName;

  /// No description provided for @schemPartsElisaReaderBufferFn.
  ///
  /// In en, this message translates to:
  /// **'Supplies buffer to the washer.'**
  String get schemPartsElisaReaderBufferFn;

  /// No description provided for @schemPartsElisaReaderWasteName.
  ///
  /// In en, this message translates to:
  /// **'Waste container'**
  String get schemPartsElisaReaderWasteName;

  /// No description provided for @schemPartsElisaReaderWasteFn.
  ///
  /// In en, this message translates to:
  /// **'Collects the aspirated liquid.'**
  String get schemPartsElisaReaderWasteFn;

  /// No description provided for @schemPartsElisaReaderPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The antigen–antibody reaction proceeds in steps in the plate wells; between steps the washer removes unbound material. Finally substrate is added and the enzyme produces colour. The reader passes light of a selected wavelength through each well and measures absorbance (optical density); unknowns are read from a standard curve.'**
  String get schemPartsElisaReaderPrinciple;

  /// No description provided for @schemPartsElisaReaderResult.
  ///
  /// In en, this message translates to:
  /// **'Optical density (OD) values for each well; a concentration from the standard curve, or a qualitative positive/negative result against a cut-off.'**
  String get schemPartsElisaReaderResult;

  /// No description provided for @schemPartsBscClass2OpeningName.
  ///
  /// In en, this message translates to:
  /// **'Front opening (inflow)'**
  String get schemPartsBscClass2OpeningName;

  /// No description provided for @schemPartsBscClass2OpeningFn.
  ///
  /// In en, this message translates to:
  /// **'Room air is drawn in here, protecting the operator.'**
  String get schemPartsBscClass2OpeningFn;

  /// No description provided for @schemPartsBscClass2GrilleName.
  ///
  /// In en, this message translates to:
  /// **'Front grille'**
  String get schemPartsBscClass2GrilleName;

  /// No description provided for @schemPartsBscClass2GrilleFn.
  ///
  /// In en, this message translates to:
  /// **'Inflow air and air from the front of the work zone go in here; keep it clear.'**
  String get schemPartsBscClass2GrilleFn;

  /// No description provided for @schemPartsBscClass2WorkzoneName.
  ///
  /// In en, this message translates to:
  /// **'Work zone and surface'**
  String get schemPartsBscClass2WorkzoneName;

  /// No description provided for @schemPartsBscClass2WorkzoneFn.
  ///
  /// In en, this message translates to:
  /// **'Samples are handled here under a downward flow of clean air.'**
  String get schemPartsBscClass2WorkzoneFn;

  /// No description provided for @schemPartsBscClass2DownflowName.
  ///
  /// In en, this message translates to:
  /// **'Downflow HEPA filter'**
  String get schemPartsBscClass2DownflowName;

  /// No description provided for @schemPartsBscClass2DownflowFn.
  ///
  /// In en, this message translates to:
  /// **'Cleans particles from the air entering the work zone.'**
  String get schemPartsBscClass2DownflowFn;

  /// No description provided for @schemPartsBscClass2FanName.
  ///
  /// In en, this message translates to:
  /// **'Fan (blower)'**
  String get schemPartsBscClass2FanName;

  /// No description provided for @schemPartsBscClass2FanFn.
  ///
  /// In en, this message translates to:
  /// **'Moves the air through the plenums.'**
  String get schemPartsBscClass2FanFn;

  /// No description provided for @schemPartsBscClass2ExhaustName.
  ///
  /// In en, this message translates to:
  /// **'Exhaust HEPA filter'**
  String get schemPartsBscClass2ExhaustName;

  /// No description provided for @schemPartsBscClass2ExhaustFn.
  ///
  /// In en, this message translates to:
  /// **'Cleans the exhausted air, protecting the environment.'**
  String get schemPartsBscClass2ExhaustFn;

  /// No description provided for @schemPartsBscClass2PlenumName.
  ///
  /// In en, this message translates to:
  /// **'Rear plenum'**
  String get schemPartsBscClass2PlenumName;

  /// No description provided for @schemPartsBscClass2PlenumFn.
  ///
  /// In en, this message translates to:
  /// **'Returns air from the grille to the fan.'**
  String get schemPartsBscClass2PlenumFn;

  /// No description provided for @schemPartsBscClass2SashName.
  ///
  /// In en, this message translates to:
  /// **'Sash (front window)'**
  String get schemPartsBscClass2SashName;

  /// No description provided for @schemPartsBscClass2SashFn.
  ///
  /// In en, this message translates to:
  /// **'Shields the operator’s face and sets the height of the front opening.'**
  String get schemPartsBscClass2SashFn;

  /// No description provided for @schemPartsBscClass2Principle.
  ///
  /// In en, this message translates to:
  /// **'A fan circulates the air. Room air is drawn through the front opening into the front grille, protecting the operator. HEPA-filtered air flows down over the work surface, protecting the work material. Surplus air leaves through the exhaust HEPA filter, protecting the environment.'**
  String get schemPartsBscClass2Principle;

  /// No description provided for @schemPartsBscClass2Result.
  ///
  /// In en, this message translates to:
  /// **'Not a measuring instrument: the outcome is a safe working environment (protection of the operator, the material and the environment). Performance is confirmed by regular airflow and filter testing and certification.'**
  String get schemPartsBscClass2Result;

  /// No description provided for @schemPartsAutoclaveChamberName.
  ///
  /// In en, this message translates to:
  /// **'Pressure chamber'**
  String get schemPartsAutoclaveChamberName;

  /// No description provided for @schemPartsAutoclaveChamberFn.
  ///
  /// In en, this message translates to:
  /// **'The load is held in saturated steam under pressure here.'**
  String get schemPartsAutoclaveChamberFn;

  /// No description provided for @schemPartsAutoclaveDoorName.
  ///
  /// In en, this message translates to:
  /// **'Door with seal and lock'**
  String get schemPartsAutoclaveDoorName;

  /// No description provided for @schemPartsAutoclaveDoorFn.
  ///
  /// In en, this message translates to:
  /// **'Seals the chamber and cannot be opened while under pressure.'**
  String get schemPartsAutoclaveDoorFn;

  /// No description provided for @schemPartsAutoclaveTrayName.
  ///
  /// In en, this message translates to:
  /// **'Loading tray'**
  String get schemPartsAutoclaveTrayName;

  /// No description provided for @schemPartsAutoclaveTrayFn.
  ///
  /// In en, this message translates to:
  /// **'Items are arranged so that steam can circulate freely.'**
  String get schemPartsAutoclaveTrayFn;

  /// No description provided for @schemPartsAutoclavePressureName.
  ///
  /// In en, this message translates to:
  /// **'Pressure gauge'**
  String get schemPartsAutoclavePressureName;

  /// No description provided for @schemPartsAutoclavePressureFn.
  ///
  /// In en, this message translates to:
  /// **'Shows the chamber pressure.'**
  String get schemPartsAutoclavePressureFn;

  /// No description provided for @schemPartsAutoclaveThermometerName.
  ///
  /// In en, this message translates to:
  /// **'Thermometer'**
  String get schemPartsAutoclaveThermometerName;

  /// No description provided for @schemPartsAutoclaveThermometerFn.
  ///
  /// In en, this message translates to:
  /// **'Shows the chamber temperature.'**
  String get schemPartsAutoclaveThermometerFn;

  /// No description provided for @schemPartsAutoclaveValveName.
  ///
  /// In en, this message translates to:
  /// **'Safety valve'**
  String get schemPartsAutoclaveValveName;

  /// No description provided for @schemPartsAutoclaveValveFn.
  ///
  /// In en, this message translates to:
  /// **'Releases steam if the pressure gets too high.'**
  String get schemPartsAutoclaveValveFn;

  /// No description provided for @schemPartsAutoclaveWaterName.
  ///
  /// In en, this message translates to:
  /// **'Water reservoir'**
  String get schemPartsAutoclaveWaterName;

  /// No description provided for @schemPartsAutoclaveWaterFn.
  ///
  /// In en, this message translates to:
  /// **'Holds the water used to make steam.'**
  String get schemPartsAutoclaveWaterFn;

  /// No description provided for @schemPartsAutoclavePrinciple.
  ///
  /// In en, this message translates to:
  /// **'Air is removed from the chamber and replaced by saturated steam. Pressure raises the boiling point of water, so the steam reaches high temperatures such as 121 °C or 132 °C. Steam contacts the items and kills microorganisms with heat; the process is controlled by steam quality, pressure, temperature and time. Trapped air prevents steam from reaching the load.'**
  String get schemPartsAutoclavePrinciple;

  /// No description provided for @schemPartsAutoclaveResult.
  ///
  /// In en, this message translates to:
  /// **'A sterilised load and a record of the cycle parameters (time, temperature, pressure); effectiveness is checked with chemical and biological indicators.'**
  String get schemPartsAutoclaveResult;

  /// No description provided for @schemPartsBloodGasIseSyringeName.
  ///
  /// In en, this message translates to:
  /// **'Sample in a heparinised syringe'**
  String get schemPartsBloodGasIseSyringeName;

  /// No description provided for @schemPartsBloodGasIseSyringeFn.
  ///
  /// In en, this message translates to:
  /// **'Arterial or other whole blood is brought without air bubbles.'**
  String get schemPartsBloodGasIseSyringeFn;

  /// No description provided for @schemPartsBloodGasIseProbeName.
  ///
  /// In en, this message translates to:
  /// **'Sample inlet probe'**
  String get schemPartsBloodGasIseProbeName;

  /// No description provided for @schemPartsBloodGasIseProbeFn.
  ///
  /// In en, this message translates to:
  /// **'Draws blood from the syringe into the measuring channel.'**
  String get schemPartsBloodGasIseProbeFn;

  /// No description provided for @schemPartsBloodGasIseSensorsName.
  ///
  /// In en, this message translates to:
  /// **'Sensors (electrodes)'**
  String get schemPartsBloodGasIseSensorsName;

  /// No description provided for @schemPartsBloodGasIseSensorsFn.
  ///
  /// In en, this message translates to:
  /// **'Separate electrodes for pH, pCO₂, pO₂ and electrolytes.'**
  String get schemPartsBloodGasIseSensorsFn;

  /// No description provided for @schemPartsBloodGasIseChannelName.
  ///
  /// In en, this message translates to:
  /// **'Measuring channel'**
  String get schemPartsBloodGasIseChannelName;

  /// No description provided for @schemPartsBloodGasIseChannelFn.
  ///
  /// In en, this message translates to:
  /// **'The sample flows over all sensors; the channel is temperature-controlled.'**
  String get schemPartsBloodGasIseChannelFn;

  /// No description provided for @schemPartsBloodGasIsePackName.
  ///
  /// In en, this message translates to:
  /// **'Reagent pack'**
  String get schemPartsBloodGasIsePackName;

  /// No description provided for @schemPartsBloodGasIsePackFn.
  ///
  /// In en, this message translates to:
  /// **'Calibration and wash solutions.'**
  String get schemPartsBloodGasIsePackFn;

  /// No description provided for @schemPartsBloodGasIseDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get schemPartsBloodGasIseDisplayName;

  /// No description provided for @schemPartsBloodGasIseDisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Shows measured and calculated values.'**
  String get schemPartsBloodGasIseDisplayFn;

  /// No description provided for @schemPartsBloodGasIsePrinterName.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get schemPartsBloodGasIsePrinterName;

  /// No description provided for @schemPartsBloodGasIsePrinterFn.
  ///
  /// In en, this message translates to:
  /// **'Prints the results.'**
  String get schemPartsBloodGasIsePrinterFn;

  /// No description provided for @schemPartsBloodGasIsePrinciple.
  ///
  /// In en, this message translates to:
  /// **'Whole blood from a heparinised syringe is drawn through the probe into the measuring channel and over the sensors. pH and pCO₂ are measured by potentiometry and pO₂ by amperometry; Na, K, Cl and ionised Ca by ion-selective electrodes. sO₂ is measured by co-oximetry or calculated; total CO₂, bicarbonate and base excess (BE) are calculated from the measured values.'**
  String get schemPartsBloodGasIsePrinciple;

  /// No description provided for @schemPartsBloodGasIseResult.
  ///
  /// In en, this message translates to:
  /// **'pH, pCO₂, pO₂, sO₂, electrolytes and metabolites (glucose, lactate, etc.) plus calculated bicarbonate and BE: measures of acid–base status and oxygenation.'**
  String get schemPartsBloodGasIseResult;

  /// No description provided for @schemPartsHba1cAnalyzerRackName.
  ///
  /// In en, this message translates to:
  /// **'EDTA tube rack'**
  String get schemPartsHba1cAnalyzerRackName;

  /// No description provided for @schemPartsHba1cAnalyzerRackFn.
  ///
  /// In en, this message translates to:
  /// **'Whole-blood tubes with purple caps.'**
  String get schemPartsHba1cAnalyzerRackFn;

  /// No description provided for @schemPartsHba1cAnalyzerArmName.
  ///
  /// In en, this message translates to:
  /// **'Sampling arm'**
  String get schemPartsHba1cAnalyzerArmName;

  /// No description provided for @schemPartsHba1cAnalyzerArmFn.
  ///
  /// In en, this message translates to:
  /// **'Automatically takes blood from the tube and passes it to the measuring system.'**
  String get schemPartsHba1cAnalyzerArmFn;

  /// No description provided for @schemPartsHba1cAnalyzerReagentsName.
  ///
  /// In en, this message translates to:
  /// **'Reagent bottles'**
  String get schemPartsHba1cAnalyzerReagentsName;

  /// No description provided for @schemPartsHba1cAnalyzerReagentsFn.
  ///
  /// In en, this message translates to:
  /// **'Reagent or buffer solutions for the analyzer’s method.'**
  String get schemPartsHba1cAnalyzerReagentsFn;

  /// No description provided for @schemPartsHba1cAnalyzerDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get schemPartsHba1cAnalyzerDisplayName;

  /// No description provided for @schemPartsHba1cAnalyzerDisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Shows the HbA1c result and run status.'**
  String get schemPartsHba1cAnalyzerDisplayFn;

  /// No description provided for @schemPartsHba1cAnalyzerPrinterName.
  ///
  /// In en, this message translates to:
  /// **'Printer'**
  String get schemPartsHba1cAnalyzerPrinterName;

  /// No description provided for @schemPartsHba1cAnalyzerPrinterFn.
  ///
  /// In en, this message translates to:
  /// **'Prints the results.'**
  String get schemPartsHba1cAnalyzerPrinterFn;

  /// No description provided for @schemPartsHba1cAnalyzerWasteName.
  ///
  /// In en, this message translates to:
  /// **'Waste container'**
  String get schemPartsHba1cAnalyzerWasteName;

  /// No description provided for @schemPartsHba1cAnalyzerWasteFn.
  ///
  /// In en, this message translates to:
  /// **'Collects used solutions and sample.'**
  String get schemPartsHba1cAnalyzerWasteFn;

  /// No description provided for @schemPartsHba1cAnalyzerPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The analyzer samples EDTA whole blood automatically and measures the HbA1c fraction. The measuring method depends on the analyzer: ion-exchange chromatography, boronate affinity chromatography, immunoassay, an enzymatic method or capillary electrophoresis; the drawing does not show the method. HbA1c forms by non-enzymatic binding of glucose to the N-terminal valine of the haemoglobin beta chain.'**
  String get schemPartsHba1cAnalyzerPrinciple;

  /// No description provided for @schemPartsHba1cAnalyzerResult.
  ///
  /// In en, this message translates to:
  /// **'The HbA1c result in NGSP (%) and IFCC (mmol/mol) units; it reflects glycaemic control over roughly 2–3 months.'**
  String get schemPartsHba1cAnalyzerResult;

  /// No description provided for @schemPartsLabFridgeControllerName.
  ///
  /// In en, this message translates to:
  /// **'Control panel (thermostat)'**
  String get schemPartsLabFridgeControllerName;

  /// No description provided for @schemPartsLabFridgeControllerFn.
  ///
  /// In en, this message translates to:
  /// **'Holds the set temperature and shows the current one.'**
  String get schemPartsLabFridgeControllerFn;

  /// No description provided for @schemPartsLabFridgeFridgeName.
  ///
  /// In en, this message translates to:
  /// **'Refrigerator compartment'**
  String get schemPartsLabFridgeFridgeName;

  /// No description provided for @schemPartsLabFridgeFridgeFn.
  ///
  /// In en, this message translates to:
  /// **'Samples, reagents and control materials are stored on the shelves.'**
  String get schemPartsLabFridgeFridgeFn;

  /// No description provided for @schemPartsLabFridgeProbeName.
  ///
  /// In en, this message translates to:
  /// **'Probe in a buffered bottle'**
  String get schemPartsLabFridgeProbeName;

  /// No description provided for @schemPartsLabFridgeProbeFn.
  ///
  /// In en, this message translates to:
  /// **'Measures product temperature and smooths brief swings when the door opens.'**
  String get schemPartsLabFridgeProbeFn;

  /// No description provided for @schemPartsLabFridgeLoggerName.
  ///
  /// In en, this message translates to:
  /// **'Digital data logger (DDL)'**
  String get schemPartsLabFridgeLoggerName;

  /// No description provided for @schemPartsLabFridgeLoggerFn.
  ///
  /// In en, this message translates to:
  /// **'Records the temperature regularly and alarms on excursions.'**
  String get schemPartsLabFridgeLoggerFn;

  /// No description provided for @schemPartsLabFridgeFreezerName.
  ///
  /// In en, this message translates to:
  /// **'Freezer compartment'**
  String get schemPartsLabFridgeFreezerName;

  /// No description provided for @schemPartsLabFridgeFreezerFn.
  ///
  /// In en, this message translates to:
  /// **'Holds frozen aliquots (e.g. of control material).'**
  String get schemPartsLabFridgeFreezerFn;

  /// No description provided for @schemPartsLabFridgePrinciple.
  ///
  /// In en, this message translates to:
  /// **'The refrigeration unit keeps the compartment within a set range under thermostat control. A probe in a buffered bottle reflects product temperature (brief air-temperature swings are smoothed). A digital data logger (DDL) records the temperature at regular intervals and alarms on out-of-range readings; a backup temperature monitoring device is also recommended.'**
  String get schemPartsLabFridgePrinciple;

  /// No description provided for @schemPartsLabFridgeResult.
  ///
  /// In en, this message translates to:
  /// **'A continuous temperature record (min/max, excursions and alarms) documenting that samples and reagents were stored correctly.'**
  String get schemPartsLabFridgeResult;

  /// No description provided for @schemPartsFluorescenceMicroscopeEyepiecesName.
  ///
  /// In en, this message translates to:
  /// **'Eyepieces'**
  String get schemPartsFluorescenceMicroscopeEyepiecesName;

  /// No description provided for @schemPartsFluorescenceMicroscopeEyepiecesFn.
  ///
  /// In en, this message translates to:
  /// **'For viewing the image.'**
  String get schemPartsFluorescenceMicroscopeEyepiecesFn;

  /// No description provided for @schemPartsFluorescenceMicroscopeLedName.
  ///
  /// In en, this message translates to:
  /// **'LED illuminator'**
  String get schemPartsFluorescenceMicroscopeLedName;

  /// No description provided for @schemPartsFluorescenceMicroscopeLedFn.
  ///
  /// In en, this message translates to:
  /// **'Supplies excitation light instead of a mercury lamp.'**
  String get schemPartsFluorescenceMicroscopeLedFn;

  /// No description provided for @schemPartsFluorescenceMicroscopeCubeName.
  ///
  /// In en, this message translates to:
  /// **'Filter cube'**
  String get schemPartsFluorescenceMicroscopeCubeName;

  /// No description provided for @schemPartsFluorescenceMicroscopeCubeFn.
  ///
  /// In en, this message translates to:
  /// **'The excitation filter, dichroic mirror and emission filter separate the light.'**
  String get schemPartsFluorescenceMicroscopeCubeFn;

  /// No description provided for @schemPartsFluorescenceMicroscopeObjectiveName.
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get schemPartsFluorescenceMicroscopeObjectiveName;

  /// No description provided for @schemPartsFluorescenceMicroscopeObjectiveFn.
  ///
  /// In en, this message translates to:
  /// **'Directs light onto the slide and magnifies the image.'**
  String get schemPartsFluorescenceMicroscopeObjectiveFn;

  /// No description provided for @schemPartsFluorescenceMicroscopeStageName.
  ///
  /// In en, this message translates to:
  /// **'Stage with smear'**
  String get schemPartsFluorescenceMicroscopeStageName;

  /// No description provided for @schemPartsFluorescenceMicroscopeStageFn.
  ///
  /// In en, this message translates to:
  /// **'The auramine-stained sputum smear sits here.'**
  String get schemPartsFluorescenceMicroscopeStageFn;

  /// No description provided for @schemPartsFluorescenceMicroscopeFocusName.
  ///
  /// In en, this message translates to:
  /// **'Focus knobs'**
  String get schemPartsFluorescenceMicroscopeFocusName;

  /// No description provided for @schemPartsFluorescenceMicroscopeFocusFn.
  ///
  /// In en, this message translates to:
  /// **'Adjust the sharpness.'**
  String get schemPartsFluorescenceMicroscopeFocusFn;

  /// No description provided for @schemPartsFluorescenceMicroscopeFieldName.
  ///
  /// In en, this message translates to:
  /// **'Field of view'**
  String get schemPartsFluorescenceMicroscopeFieldName;

  /// No description provided for @schemPartsFluorescenceMicroscopeFieldFn.
  ///
  /// In en, this message translates to:
  /// **'Bright yellow-green rods on a dark background: stained bacilli.'**
  String get schemPartsFluorescenceMicroscopeFieldFn;

  /// No description provided for @schemPartsFluorescenceMicroscopePrinciple.
  ///
  /// In en, this message translates to:
  /// **'The smear is stained with auramine (a fluorochrome), which the mycobacterial cell wall retains. The LED illuminator sends blue excitation light through the filter cube and objective onto the slide. Stained bacilli emit longer-wavelength (yellow-green) light; the emission filter blocks the excitation light, so the bacilli shine on a dark background.'**
  String get schemPartsFluorescenceMicroscopePrinciple;

  /// No description provided for @schemPartsFluorescenceMicroscopeResult.
  ///
  /// In en, this message translates to:
  /// **'A microscopy report: acid-fast bacilli (bright rods) seen or not seen, with a semi-quantitative grade when present.'**
  String get schemPartsFluorescenceMicroscopeResult;

  /// No description provided for @schemPartsCasaCameraName.
  ///
  /// In en, this message translates to:
  /// **'Digital camera'**
  String get schemPartsCasaCameraName;

  /// No description provided for @schemPartsCasaCameraFn.
  ///
  /// In en, this message translates to:
  /// **'Records the microscope image as a sequence of frames.'**
  String get schemPartsCasaCameraFn;

  /// No description provided for @schemPartsCasaMicroscopeName.
  ///
  /// In en, this message translates to:
  /// **'Microscope (objective)'**
  String get schemPartsCasaMicroscopeName;

  /// No description provided for @schemPartsCasaMicroscopeFn.
  ///
  /// In en, this message translates to:
  /// **'Magnifies the spermatozoa, usually with phase contrast.'**
  String get schemPartsCasaMicroscopeFn;

  /// No description provided for @schemPartsCasaStageName.
  ///
  /// In en, this message translates to:
  /// **'Heated stage'**
  String get schemPartsCasaStageName;

  /// No description provided for @schemPartsCasaStageFn.
  ///
  /// In en, this message translates to:
  /// **'Keeps the sample temperature stable, as motility depends on temperature.'**
  String get schemPartsCasaStageFn;

  /// No description provided for @schemPartsCasaChamberName.
  ///
  /// In en, this message translates to:
  /// **'Counting chamber'**
  String get schemPartsCasaChamberName;

  /// No description provided for @schemPartsCasaChamberFn.
  ///
  /// In en, this message translates to:
  /// **'A chamber of fixed depth gives a sample layer of even thickness.'**
  String get schemPartsCasaChamberFn;

  /// No description provided for @schemPartsCasaSoftwareName.
  ///
  /// In en, this message translates to:
  /// **'Computer and software'**
  String get schemPartsCasaSoftwareName;

  /// No description provided for @schemPartsCasaSoftwareFn.
  ///
  /// In en, this message translates to:
  /// **'Reconstructs the tracks and calculates kinematic parameters.'**
  String get schemPartsCasaSoftwareFn;

  /// No description provided for @schemPartsCasaPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Semen is loaded into a counting chamber on the heated stage. The camera records successive frames through the microscope; software finds the sperm heads, reconstructs the track of each motile cell and calculates movement kinematics. Tracks of at least 200 motile cells are analysed.'**
  String get schemPartsCasaPrinciple;

  /// No description provided for @schemPartsCasaResult.
  ///
  /// In en, this message translates to:
  /// **'Kinematic parameters (e.g. curvilinear, straight-line and average path velocity) and motion types; according to the WHO manual, percentage motility may be unreliable because debris can be mistaken for immotile cells.'**
  String get schemPartsCasaResult;

  /// No description provided for @schemPartsGelCardSystemCentrifugeName.
  ///
  /// In en, this message translates to:
  /// **'Card centrifuge'**
  String get schemPartsGelCardSystemCentrifugeName;

  /// No description provided for @schemPartsGelCardSystemCentrifugeFn.
  ///
  /// In en, this message translates to:
  /// **'Spins the cards at a set speed and time.'**
  String get schemPartsGelCardSystemCentrifugeFn;

  /// No description provided for @schemPartsGelCardSystemIncubatorName.
  ///
  /// In en, this message translates to:
  /// **'Incubator'**
  String get schemPartsGelCardSystemIncubatorName;

  /// No description provided for @schemPartsGelCardSystemIncubatorFn.
  ///
  /// In en, this message translates to:
  /// **'Incubates the cards for the antiglobulin test.'**
  String get schemPartsGelCardSystemIncubatorFn;

  /// No description provided for @schemPartsGelCardSystemCardName.
  ///
  /// In en, this message translates to:
  /// **'Gel card'**
  String get schemPartsGelCardSystemCardName;

  /// No description provided for @schemPartsGelCardSystemCardFn.
  ///
  /// In en, this message translates to:
  /// **'A plastic card; each microtube holds a gel or glass-bead matrix.'**
  String get schemPartsGelCardSystemCardFn;

  /// No description provided for @schemPartsGelCardSystemChamberName.
  ///
  /// In en, this message translates to:
  /// **'Reaction chamber'**
  String get schemPartsGelCardSystemChamberName;

  /// No description provided for @schemPartsGelCardSystemChamberFn.
  ///
  /// In en, this message translates to:
  /// **'Red cells and serum (or reagent) mix here.'**
  String get schemPartsGelCardSystemChamberFn;

  /// No description provided for @schemPartsGelCardSystemGelName.
  ///
  /// In en, this message translates to:
  /// **'Gel column (matrix)'**
  String get schemPartsGelCardSystemGelName;

  /// No description provided for @schemPartsGelCardSystemGelFn.
  ///
  /// In en, this message translates to:
  /// **'Traps agglutinates and lets single red cells through; may contain antiglobulin or anti-A, anti-B.'**
  String get schemPartsGelCardSystemGelFn;

  /// No description provided for @schemPartsGelCardSystemPositiveName.
  ///
  /// In en, this message translates to:
  /// **'Positive reaction'**
  String get schemPartsGelCardSystemPositiveName;

  /// No description provided for @schemPartsGelCardSystemPositiveFn.
  ///
  /// In en, this message translates to:
  /// **'Red cells stay on top of or within the gel.'**
  String get schemPartsGelCardSystemPositiveFn;

  /// No description provided for @schemPartsGelCardSystemNegativeName.
  ///
  /// In en, this message translates to:
  /// **'Negative reaction'**
  String get schemPartsGelCardSystemNegativeName;

  /// No description provided for @schemPartsGelCardSystemNegativeFn.
  ///
  /// In en, this message translates to:
  /// **'Red cells form a button at the bottom.'**
  String get schemPartsGelCardSystemNegativeFn;

  /// No description provided for @schemPartsGelCardSystemPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Red cell suspension and serum (or reagent) are added to the upper reaction chamber of the microtube and incubated. On centrifugation the red cells are driven into the gel or glass-bead matrix while the serum stays above. Agglutinates (e.g. antibody-coated cells linked by antiglobulin) are trapped in the gel (positive); unagglutinated cells pass to the bottom as a button (negative). The antiglobulin test needs no washing step.'**
  String get schemPartsGelCardSystemPrinciple;

  /// No description provided for @schemPartsGelCardSystemResult.
  ///
  /// In en, this message translates to:
  /// **'A reaction in each microtube: positive (agglutinates on top of or within the gel, graded by strength) or negative (button at the bottom); these give the blood group or the direct antiglobulin test result.'**
  String get schemPartsGelCardSystemResult;

  /// No description provided for @schemPartsEsrAnalyzerStandName.
  ///
  /// In en, this message translates to:
  /// **'Westergren stand'**
  String get schemPartsEsrAnalyzerStandName;

  /// No description provided for @schemPartsEsrAnalyzerStandFn.
  ///
  /// In en, this message translates to:
  /// **'Holds the tubes strictly upright.'**
  String get schemPartsEsrAnalyzerStandFn;

  /// No description provided for @schemPartsEsrAnalyzerTubeName.
  ///
  /// In en, this message translates to:
  /// **'Westergren tube'**
  String get schemPartsEsrAnalyzerTubeName;

  /// No description provided for @schemPartsEsrAnalyzerTubeFn.
  ///
  /// In en, this message translates to:
  /// **'A graduated standard tube with a 2.5 mm bore.'**
  String get schemPartsEsrAnalyzerTubeFn;

  /// No description provided for @schemPartsEsrAnalyzerBoundaryName.
  ///
  /// In en, this message translates to:
  /// **'Plasma–red cell boundary'**
  String get schemPartsEsrAnalyzerBoundaryName;

  /// No description provided for @schemPartsEsrAnalyzerBoundaryFn.
  ///
  /// In en, this message translates to:
  /// **'After one hour the distance to this boundary is read in millimetres.'**
  String get schemPartsEsrAnalyzerBoundaryFn;

  /// No description provided for @schemPartsEsrAnalyzerReaderName.
  ///
  /// In en, this message translates to:
  /// **'Automated reader'**
  String get schemPartsEsrAnalyzerReaderName;

  /// No description provided for @schemPartsEsrAnalyzerReaderFn.
  ///
  /// In en, this message translates to:
  /// **'Measures sedimentation automatically in closed tubes.'**
  String get schemPartsEsrAnalyzerReaderFn;

  /// No description provided for @schemPartsEsrAnalyzerTubesName.
  ///
  /// In en, this message translates to:
  /// **'Closed tubes'**
  String get schemPartsEsrAnalyzerTubesName;

  /// No description provided for @schemPartsEsrAnalyzerTubesFn.
  ///
  /// In en, this message translates to:
  /// **'The sample tube stays closed.'**
  String get schemPartsEsrAnalyzerTubesFn;

  /// No description provided for @schemPartsEsrAnalyzerSensorsName.
  ///
  /// In en, this message translates to:
  /// **'Optical sensors'**
  String get schemPartsEsrAnalyzerSensorsName;

  /// No description provided for @schemPartsEsrAnalyzerSensorsFn.
  ///
  /// In en, this message translates to:
  /// **'Detect the boundary between plasma and the red cell column.'**
  String get schemPartsEsrAnalyzerSensorsFn;

  /// No description provided for @schemPartsEsrAnalyzerDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get schemPartsEsrAnalyzerDisplayName;

  /// No description provided for @schemPartsEsrAnalyzerDisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Shows the results.'**
  String get schemPartsEsrAnalyzerDisplayFn;

  /// No description provided for @schemPartsEsrAnalyzerPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Anticoagulated blood settles by gravity in a standard upright tube (Westergren, 2.5 mm internal diameter) for one hour; the height of the clear plasma column is read in millimetres. In inflammation raised proteins promote rouleaux formation, so the cells settle faster. Automated readers follow the plasma–red cell boundary in closed tubes with optical sensors.'**
  String get schemPartsEsrAnalyzerPrinciple;

  /// No description provided for @schemPartsEsrAnalyzerResult.
  ///
  /// In en, this message translates to:
  /// **'The ESR value in mm/h; a non-specific measure read together with other tests.'**
  String get schemPartsEsrAnalyzerResult;

  /// No description provided for @schemPartsAggregometerChannelsName.
  ///
  /// In en, this message translates to:
  /// **'LTA measuring channels'**
  String get schemPartsAggregometerChannelsName;

  /// No description provided for @schemPartsAggregometerChannelsFn.
  ///
  /// In en, this message translates to:
  /// **'Cuvettes are warmed to 37 °C and stirred.'**
  String get schemPartsAggregometerChannelsFn;

  /// No description provided for @schemPartsAggregometerLightName.
  ///
  /// In en, this message translates to:
  /// **'Light source'**
  String get schemPartsAggregometerLightName;

  /// No description provided for @schemPartsAggregometerLightFn.
  ///
  /// In en, this message translates to:
  /// **'Provides the light that passes through the cuvette.'**
  String get schemPartsAggregometerLightFn;

  /// No description provided for @schemPartsAggregometerCuvetteName.
  ///
  /// In en, this message translates to:
  /// **'Cuvette (plasma and stir bar)'**
  String get schemPartsAggregometerCuvetteName;

  /// No description provided for @schemPartsAggregometerCuvetteFn.
  ///
  /// In en, this message translates to:
  /// **'Platelet-rich plasma; the agonist is added here.'**
  String get schemPartsAggregometerCuvetteFn;

  /// No description provided for @schemPartsAggregometerPhotodetectorName.
  ///
  /// In en, this message translates to:
  /// **'Photodetector'**
  String get schemPartsAggregometerPhotodetectorName;

  /// No description provided for @schemPartsAggregometerPhotodetectorFn.
  ///
  /// In en, this message translates to:
  /// **'Measures the rise in light transmission during aggregation.'**
  String get schemPartsAggregometerPhotodetectorFn;

  /// No description provided for @schemPartsAggregometerCurvesName.
  ///
  /// In en, this message translates to:
  /// **'Aggregation curves'**
  String get schemPartsAggregometerCurvesName;

  /// No description provided for @schemPartsAggregometerCurvesFn.
  ///
  /// In en, this message translates to:
  /// **'Light transmission over time for each channel.'**
  String get schemPartsAggregometerCurvesFn;

  /// No description provided for @schemPartsAggregometerCupName.
  ///
  /// In en, this message translates to:
  /// **'Cup with blood'**
  String get schemPartsAggregometerCupName;

  /// No description provided for @schemPartsAggregometerCupFn.
  ///
  /// In en, this message translates to:
  /// **'Citrated blood is clotted here with calcium and an activator.'**
  String get schemPartsAggregometerCupFn;

  /// No description provided for @schemPartsAggregometerPinName.
  ///
  /// In en, this message translates to:
  /// **'Pin and torsion sensor'**
  String get schemPartsAggregometerPinName;

  /// No description provided for @schemPartsAggregometerPinFn.
  ///
  /// In en, this message translates to:
  /// **'Fibrin couples the pin to the cup; the transmitted torque is recorded.'**
  String get schemPartsAggregometerPinFn;

  /// No description provided for @schemPartsAggregometerTraceName.
  ///
  /// In en, this message translates to:
  /// **'Viscoelastic trace'**
  String get schemPartsAggregometerTraceName;

  /// No description provided for @schemPartsAggregometerTraceFn.
  ///
  /// In en, this message translates to:
  /// **'A plot of clot formation, strength and lysis.'**
  String get schemPartsAggregometerTraceFn;

  /// No description provided for @schemPartsAggregometerPrinciple.
  ///
  /// In en, this message translates to:
  /// **'LTA: platelet-rich plasma is stirred in a cuvette at 37 °C. After an agonist is added, platelets aggregate, the plasma clears and light transmission rises; the photodetector records this as a curve. TEG/ROTEM: citrated blood in a rotating cup is clotted with calcium and an activator; fibrin couples the pin to the cup and the transmitted torque is plotted as a trace.'**
  String get schemPartsAggregometerPrinciple;

  /// No description provided for @schemPartsAggregometerResult.
  ///
  /// In en, this message translates to:
  /// **'LTA: an aggregation curve for each agonist (light transmission over time). TEG/ROTEM: a viscoelastic trace showing clot formation, clot strength and fibrinolysis.'**
  String get schemPartsAggregometerResult;

  /// No description provided for @schemPartsElectrophoresisPowerName.
  ///
  /// In en, this message translates to:
  /// **'Power supply'**
  String get schemPartsElectrophoresisPowerName;

  /// No description provided for @schemPartsElectrophoresisPowerFn.
  ///
  /// In en, this message translates to:
  /// **'Applies a constant voltage to the electrodes.'**
  String get schemPartsElectrophoresisPowerFn;

  /// No description provided for @schemPartsElectrophoresisElectrodesName.
  ///
  /// In en, this message translates to:
  /// **'Buffer compartments and electrodes'**
  String get schemPartsElectrophoresisElectrodesName;

  /// No description provided for @schemPartsElectrophoresisElectrodesFn.
  ///
  /// In en, this message translates to:
  /// **'The buffer carries the current; the cathode (−) and anode (+) set up the field.'**
  String get schemPartsElectrophoresisElectrodesFn;

  /// No description provided for @schemPartsElectrophoresisWicksName.
  ///
  /// In en, this message translates to:
  /// **'Wicks'**
  String get schemPartsElectrophoresisWicksName;

  /// No description provided for @schemPartsElectrophoresisWicksFn.
  ///
  /// In en, this message translates to:
  /// **'Carry buffer to the support medium and complete the circuit.'**
  String get schemPartsElectrophoresisWicksFn;

  /// No description provided for @schemPartsElectrophoresisMediumName.
  ///
  /// In en, this message translates to:
  /// **'Support medium and fractions'**
  String get schemPartsElectrophoresisMediumName;

  /// No description provided for @schemPartsElectrophoresisMediumFn.
  ///
  /// In en, this message translates to:
  /// **'Molecules separate into zones on agarose or cellulose acetate.'**
  String get schemPartsElectrophoresisMediumFn;

  /// No description provided for @schemPartsElectrophoresisCoverName.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get schemPartsElectrophoresisCoverName;

  /// No description provided for @schemPartsElectrophoresisCoverFn.
  ///
  /// In en, this message translates to:
  /// **'Reduces evaporation and protects against electric shock.'**
  String get schemPartsElectrophoresisCoverFn;

  /// No description provided for @schemPartsElectrophoresisDensitometerName.
  ///
  /// In en, this message translates to:
  /// **'Densitometer'**
  String get schemPartsElectrophoresisDensitometerName;

  /// No description provided for @schemPartsElectrophoresisDensitometerFn.
  ///
  /// In en, this message translates to:
  /// **'Scans the optical density of the stained zones and draws a densitogram.'**
  String get schemPartsElectrophoresisDensitometerFn;

  /// No description provided for @schemPartsElectrophoresisPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The sample is applied to a buffer-soaked support medium (agarose, cellulose acetate or polyacrylamide). The power supply creates an electric field through the electrodes; charged molecules migrate at different speeds according to charge, size and shape and separate into zones. The zones are then stained and measured by optical density on a densitometer.'**
  String get schemPartsElectrophoresisPrinciple;

  /// No description provided for @schemPartsElectrophoresisResult.
  ///
  /// In en, this message translates to:
  /// **'Stained fractions (e.g. for serum proteins: albumin, alpha-1, alpha-2, beta, gamma) and a densitogram giving the relative share of each fraction; runs are compared with control samples.'**
  String get schemPartsElectrophoresisResult;

  /// No description provided for @schemPartsOsmometerTubesName.
  ///
  /// In en, this message translates to:
  /// **'Sample tubes'**
  String get schemPartsOsmometerTubesName;

  /// No description provided for @schemPartsOsmometerTubesFn.
  ///
  /// In en, this message translates to:
  /// **'A small volume of urine or serum.'**
  String get schemPartsOsmometerTubesFn;

  /// No description provided for @schemPartsOsmometerThermistorName.
  ///
  /// In en, this message translates to:
  /// **'Thermistor probe'**
  String get schemPartsOsmometerThermistorName;

  /// No description provided for @schemPartsOsmometerThermistorFn.
  ///
  /// In en, this message translates to:
  /// **'Dips into the sample and measures temperature precisely.'**
  String get schemPartsOsmometerThermistorFn;

  /// No description provided for @schemPartsOsmometerBathName.
  ///
  /// In en, this message translates to:
  /// **'Cooling block (bath)'**
  String get schemPartsOsmometerBathName;

  /// No description provided for @schemPartsOsmometerBathFn.
  ///
  /// In en, this message translates to:
  /// **'Cools the sample below its freezing point.'**
  String get schemPartsOsmometerBathFn;

  /// No description provided for @schemPartsOsmometerWireName.
  ///
  /// In en, this message translates to:
  /// **'Stirring wire'**
  String get schemPartsOsmometerWireName;

  /// No description provided for @schemPartsOsmometerWireFn.
  ///
  /// In en, this message translates to:
  /// **'Vibrates to start freezing in the supercooled sample.'**
  String get schemPartsOsmometerWireFn;

  /// No description provided for @schemPartsOsmometerDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display (freezing curve)'**
  String get schemPartsOsmometerDisplayName;

  /// No description provided for @schemPartsOsmometerDisplayFn.
  ///
  /// In en, this message translates to:
  /// **'The temperature curve and the osmolality result.'**
  String get schemPartsOsmometerDisplayFn;

  /// No description provided for @schemPartsOsmometerPrinciple.
  ///
  /// In en, this message translates to:
  /// **'The sample is supercooled below its freezing point in the cooling block, then vibration of the stirring wire starts freezing. Released latent heat raises the temperature to the freezing point, giving a plateau that the thermistor in a Wheatstone bridge circuit measures. Dissolved particles lower the freezing point: one mole of solute lowers that of water by about 1.86 °C, and osmolality is calculated from this.'**
  String get schemPartsOsmometerPrinciple;

  /// No description provided for @schemPartsOsmometerResult.
  ///
  /// In en, this message translates to:
  /// **'Urine or serum osmolality in mOsm/kg (mmol/kg).'**
  String get schemPartsOsmometerResult;

  /// No description provided for @schemPartsTlcTankName.
  ///
  /// In en, this message translates to:
  /// **'Developing tank (with lid)'**
  String get schemPartsTlcTankName;

  /// No description provided for @schemPartsTlcTankFn.
  ///
  /// In en, this message translates to:
  /// **'A closed glass tank saturated with solvent vapour.'**
  String get schemPartsTlcTankFn;

  /// No description provided for @schemPartsTlcSolventName.
  ///
  /// In en, this message translates to:
  /// **'Mobile phase (solvent)'**
  String get schemPartsTlcSolventName;

  /// No description provided for @schemPartsTlcSolventFn.
  ///
  /// In en, this message translates to:
  /// **'Rises up the plate by capillary action.'**
  String get schemPartsTlcSolventFn;

  /// No description provided for @schemPartsTlcPlateName.
  ///
  /// In en, this message translates to:
  /// **'TLC plate (silica gel GF254)'**
  String get schemPartsTlcPlateName;

  /// No description provided for @schemPartsTlcPlateFn.
  ///
  /// In en, this message translates to:
  /// **'A thin silica gel layer with a fluorescent indicator that glows under UV.'**
  String get schemPartsTlcPlateFn;

  /// No description provided for @schemPartsTlcOriginName.
  ///
  /// In en, this message translates to:
  /// **'Origin line'**
  String get schemPartsTlcOriginName;

  /// No description provided for @schemPartsTlcOriginFn.
  ///
  /// In en, this message translates to:
  /// **'Sample and standard spots are applied here.'**
  String get schemPartsTlcOriginFn;

  /// No description provided for @schemPartsTlcFrontName.
  ///
  /// In en, this message translates to:
  /// **'Solvent front'**
  String get schemPartsTlcFrontName;

  /// No description provided for @schemPartsTlcFrontFn.
  ///
  /// In en, this message translates to:
  /// **'The line the solvent reached, marked to calculate Rf.'**
  String get schemPartsTlcFrontFn;

  /// No description provided for @schemPartsTlcCapillariesName.
  ///
  /// In en, this message translates to:
  /// **'Capillaries'**
  String get schemPartsTlcCapillariesName;

  /// No description provided for @schemPartsTlcCapillariesFn.
  ///
  /// In en, this message translates to:
  /// **'For applying the sample as a small spot.'**
  String get schemPartsTlcCapillariesFn;

  /// No description provided for @schemPartsTlcLampName.
  ///
  /// In en, this message translates to:
  /// **'UV lamp (254 nm)'**
  String get schemPartsTlcLampName;

  /// No description provided for @schemPartsTlcLampFn.
  ///
  /// In en, this message translates to:
  /// **'Lights the plate and makes the spots visible.'**
  String get schemPartsTlcLampFn;

  /// No description provided for @schemPartsTlcSpotsName.
  ///
  /// In en, this message translates to:
  /// **'Spots under UV'**
  String get schemPartsTlcSpotsName;

  /// No description provided for @schemPartsTlcSpotsFn.
  ///
  /// In en, this message translates to:
  /// **'Compounds quench the fluorescence and appear as dark spots on a green background.'**
  String get schemPartsTlcSpotsFn;

  /// No description provided for @schemPartsTlcPrinciple.
  ///
  /// In en, this message translates to:
  /// **'Sample and standard spots are applied on the origin line and the plate is placed in the saturated tank with its lower edge in the solvent. As the solvent rises, compounds partition between the silica gel (stationary phase) and the solvent (mobile phase) and travel different distances. The developed plate is viewed under 254 nm UV light or sprayed with visualising reagents.'**
  String get schemPartsTlcPrinciple;

  /// No description provided for @schemPartsTlcResult.
  ///
  /// In en, this message translates to:
  /// **'Spot positions and Rf values (spot distance / solvent-front distance), compared with a standard to identify the compound.'**
  String get schemPartsTlcResult;

  /// No description provided for @schemPartsAnalyticalBalancePipetteName.
  ///
  /// In en, this message translates to:
  /// **'Pipette (air displacement)'**
  String get schemPartsAnalyticalBalancePipetteName;

  /// No description provided for @schemPartsAnalyticalBalancePipetteFn.
  ///
  /// In en, this message translates to:
  /// **'The device being calibrated: it delivers the set volume.'**
  String get schemPartsAnalyticalBalancePipetteFn;

  /// No description provided for @schemPartsAnalyticalBalanceVesselName.
  ///
  /// In en, this message translates to:
  /// **'Weighing vessel'**
  String get schemPartsAnalyticalBalanceVesselName;

  /// No description provided for @schemPartsAnalyticalBalanceVesselFn.
  ///
  /// In en, this message translates to:
  /// **'Receives the dispensed water for weighing.'**
  String get schemPartsAnalyticalBalanceVesselFn;

  /// No description provided for @schemPartsAnalyticalBalancePanName.
  ///
  /// In en, this message translates to:
  /// **'Weighing pan'**
  String get schemPartsAnalyticalBalancePanName;

  /// No description provided for @schemPartsAnalyticalBalancePanFn.
  ///
  /// In en, this message translates to:
  /// **'Mass is measured here.'**
  String get schemPartsAnalyticalBalancePanFn;

  /// No description provided for @schemPartsAnalyticalBalanceEnclosureName.
  ///
  /// In en, this message translates to:
  /// **'Glass enclosure'**
  String get schemPartsAnalyticalBalanceEnclosureName;

  /// No description provided for @schemPartsAnalyticalBalanceEnclosureFn.
  ///
  /// In en, this message translates to:
  /// **'Shields the weighing from air currents and dust.'**
  String get schemPartsAnalyticalBalanceEnclosureFn;

  /// No description provided for @schemPartsAnalyticalBalanceDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display and keys'**
  String get schemPartsAnalyticalBalanceDisplayName;

  /// No description provided for @schemPartsAnalyticalBalanceDisplayFn.
  ///
  /// In en, this message translates to:
  /// **'Shows the mass; the tare key zeroes the vessel mass.'**
  String get schemPartsAnalyticalBalanceDisplayFn;

  /// No description provided for @schemPartsAnalyticalBalanceWaterName.
  ///
  /// In en, this message translates to:
  /// **'Water container'**
  String get schemPartsAnalyticalBalanceWaterName;

  /// No description provided for @schemPartsAnalyticalBalanceWaterFn.
  ///
  /// In en, this message translates to:
  /// **'Pure (distilled) water equilibrated to room temperature.'**
  String get schemPartsAnalyticalBalanceWaterFn;

  /// No description provided for @schemPartsAnalyticalBalanceThermometerName.
  ///
  /// In en, this message translates to:
  /// **'Thermometer'**
  String get schemPartsAnalyticalBalanceThermometerName;

  /// No description provided for @schemPartsAnalyticalBalanceThermometerFn.
  ///
  /// In en, this message translates to:
  /// **'Measures the water temperature for the density correction.'**
  String get schemPartsAnalyticalBalanceThermometerFn;

  /// No description provided for @schemPartsAnalyticalBalancePrinciple.
  ///
  /// In en, this message translates to:
  /// **'The pipette dispenses its set volume of water into the vessel on the balance and the water mass is weighed. Mass is converted to volume with corrections for water density (temperature) and air buoyancy, so water and air temperatures are recorded. The pipette is calibrated on a ‘to deliver’ basis.'**
  String get schemPartsAnalyticalBalancePrinciple;

  /// No description provided for @schemPartsAnalyticalBalanceResult.
  ///
  /// In en, this message translates to:
  /// **'The calculated volume of each delivery; comparison with the nominal volume gives the accuracy (systematic error) and repeatability.'**
  String get schemPartsAnalyticalBalanceResult;

  /// No description provided for @howToButton.
  ///
  /// In en, this message translates to:
  /// **'How to use?'**
  String get howToButton;

  /// No description provided for @howToStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get howToStepsTitle;

  /// No description provided for @howToResultTitle.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get howToResultTitle;

  /// No description provided for @howToWatchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch the video'**
  String get howToWatchVideo;

  /// No description provided for @howToVideoMb.
  ///
  /// In en, this message translates to:
  /// **'{mb} MB'**
  String howToVideoMb(String mb);

  /// No description provided for @howToVideoNote.
  ///
  /// In en, this message translates to:
  /// **'Silent screen recording with subtitles · {duration} · opens in your browser or video player'**
  String howToVideoNote(String duration);

  /// No description provided for @howToVideoStartsAt.
  ///
  /// In en, this message translates to:
  /// **'In the video, this section starts at {time}.'**
  String howToVideoStartsAt(String time);

  /// No description provided for @howToVideoOffline.
  ///
  /// In en, this message translates to:
  /// **'The video needs an internet connection. The text guide is right here and works offline.'**
  String get howToVideoOffline;

  /// No description provided for @howToVideoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The video can’t be opened right now. Try again later — the text guide is right here.'**
  String get howToVideoUnavailable;

  /// No description provided for @howToCalibrationStep1.
  ///
  /// In en, this message translates to:
  /// **'“1. Instrument”: choose the model from the catalog or add an instrument that isn’t listed.'**
  String get howToCalibrationStep1;

  /// No description provided for @howToCalibrationStep2.
  ///
  /// In en, this message translates to:
  /// **'“2. Analyte”: type the test name (e.g. glucose) and pick it from the list.'**
  String get howToCalibrationStep2;

  /// No description provided for @howToCalibrationStep3.
  ///
  /// In en, this message translates to:
  /// **'“3. Reagent”: enter the manufacturer, REF number and IFU revision.'**
  String get howToCalibrationStep3;

  /// No description provided for @howToCalibrationStep4.
  ///
  /// In en, this message translates to:
  /// **'Tap “Show guide” — the app checks the match and shows the matching guidance.'**
  String get howToCalibrationStep4;

  /// No description provided for @howToCalibrationStep5.
  ///
  /// In en, this message translates to:
  /// **'“Create a calibration record”: enter the lot, values and outcome, then save the record.'**
  String get howToCalibrationStep5;

  /// No description provided for @howToCalibrationStep6.
  ///
  /// In en, this message translates to:
  /// **'All records are in the “Calibration log” and stay on this device only.'**
  String get howToCalibrationStep6;

  /// No description provided for @howToCalibrationResult.
  ///
  /// In en, this message translates to:
  /// **'Calibration guidance matched to your instrument, analyte and reagent, plus an on-device calibration log.'**
  String get howToCalibrationResult;

  /// No description provided for @howToQcStep1.
  ///
  /// In en, this message translates to:
  /// **'“Add test”: enter the test name, unit and control levels.'**
  String get howToQcStep1;

  /// No description provided for @howToQcStep2.
  ///
  /// In en, this message translates to:
  /// **'Enter the target mean and SD for each level — the app never makes them up.'**
  String get howToQcStep2;

  /// No description provided for @howToQcStep3.
  ///
  /// In en, this message translates to:
  /// **'After each run, enter the control results and tap “Save run”.'**
  String get howToQcStep3;

  /// No description provided for @howToQcStep4.
  ///
  /// In en, this message translates to:
  /// **'Check the Levey–Jennings chart and the Westgard verdict: in control, warning or rejected.'**
  String get howToQcStep4;

  /// No description provided for @howToQcStep5.
  ///
  /// In en, this message translates to:
  /// **'“Guides”: what to do when QC is rejected, external quality assessment (EQA) and critical values.'**
  String get howToQcStep5;

  /// No description provided for @howToQcStep6.
  ///
  /// In en, this message translates to:
  /// **'Backup: copy your data as text and restore it later.'**
  String get howToQcStep6;

  /// No description provided for @howToQcResult.
  ///
  /// In en, this message translates to:
  /// **'A Levey–Jennings chart per level and a Westgard verdict for every run — on this device.'**
  String get howToQcResult;

  /// No description provided for @howToPreanalyticsStep1.
  ///
  /// In en, this message translates to:
  /// **'At the top — 5 stages: from preparing for the test to transport and receipt.'**
  String get howToPreanalyticsStep1;

  /// No description provided for @howToPreanalyticsStep2.
  ///
  /// In en, this message translates to:
  /// **'Patient preparation: fasting, medicines, exercise — every point with its source.'**
  String get howToPreanalyticsStep2;

  /// No description provided for @howToPreanalyticsStep3.
  ///
  /// In en, this message translates to:
  /// **'Order of draw: which tube is filled when during venipuncture (with cap colours).'**
  String get howToPreanalyticsStep3;

  /// No description provided for @howToPreanalyticsStep4.
  ///
  /// In en, this message translates to:
  /// **'Further down: separation, storage, transport and receipt conditions.'**
  String get howToPreanalyticsStep4;

  /// No description provided for @howToPreanalyticsStep5.
  ///
  /// In en, this message translates to:
  /// **'Check each point against your laboratory’s SOP.'**
  String get howToPreanalyticsStep5;

  /// No description provided for @howToPreanalyticsResult.
  ///
  /// In en, this message translates to:
  /// **'Rules to check before and after sample collection — with sources, on one page.'**
  String get howToPreanalyticsResult;

  /// No description provided for @howToCalculatorsStep1.
  ///
  /// In en, this message translates to:
  /// **'Pick a calculator: clinical formulas, manual methods or laboratory.'**
  String get howToCalculatorsStep1;

  /// No description provided for @howToCalculatorsStep2.
  ///
  /// In en, this message translates to:
  /// **'Enter the values and check the units.'**
  String get howToCalculatorsStep2;

  /// No description provided for @howToCalculatorsStep3.
  ///
  /// In en, this message translates to:
  /// **'If needed, choose a parameter (e.g. sex) and tap “Calculate”.'**
  String get howToCalculatorsStep3;

  /// No description provided for @howToCalculatorsStep4.
  ///
  /// In en, this message translates to:
  /// **'Read the note and sources under the result: the formula’s limits are there.'**
  String get howToCalculatorsStep4;

  /// No description provided for @howToCalculatorsResult.
  ///
  /// In en, this message translates to:
  /// **'A result computed only from the values you enter — with its formula and source.'**
  String get howToCalculatorsResult;

  /// No description provided for @howToInstrumentsStep1.
  ///
  /// In en, this message translates to:
  /// **'Choose a direction: chemistry, hematology, immunochemistry or urine.'**
  String get howToInstrumentsStep1;

  /// No description provided for @howToInstrumentsStep2.
  ///
  /// In en, this message translates to:
  /// **'Pick the manufacturer and model, or type the model name into search.'**
  String get howToInstrumentsStep2;

  /// No description provided for @howToInstrumentsStep3.
  ///
  /// In en, this message translates to:
  /// **'Model card: “Save as ‘My instrument’”, then go to calibration or QC.'**
  String get howToInstrumentsStep3;

  /// No description provided for @howToInstrumentsStep4.
  ///
  /// In en, this message translates to:
  /// **'“Laboratory directions (reference)”: cards for TB, HIV, bacteriology and other directions.'**
  String get howToInstrumentsStep4;

  /// No description provided for @howToInstrumentsStep5.
  ///
  /// In en, this message translates to:
  /// **'The schematic on a card shows the instrument class in general, not an exact model.'**
  String get howToInstrumentsStep5;

  /// No description provided for @howToInstrumentsResult.
  ///
  /// In en, this message translates to:
  /// **'Reference cards by instrument and direction, schematics and quick access to calibration/QC.'**
  String get howToInstrumentsResult;

  /// No description provided for @howToMicroscopyStep1.
  ///
  /// In en, this message translates to:
  /// **'Choose a section: urine sediment, peripheral blood film or blood parasites (malaria).'**
  String get howToMicroscopyStep1;

  /// No description provided for @howToMicroscopyStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap an image: the card shows key features, author and license.'**
  String get howToMicroscopyStep2;

  /// No description provided for @howToMicroscopyStep3.
  ///
  /// In en, this message translates to:
  /// **'Type a name into search (e.g. oxalate or neutrophil).'**
  String get howToMicroscopyStep3;

  /// No description provided for @howToMicroscopyStep4.
  ///
  /// In en, this message translates to:
  /// **'“Start practice”: pick the right name out of 4 options — the answer shows at once.'**
  String get howToMicroscopyStep4;

  /// No description provided for @howToMicroscopyStep5.
  ///
  /// In en, this message translates to:
  /// **'At the end of a round you see your score and can retry mistakes.'**
  String get howToMicroscopyStep5;

  /// No description provided for @howToMicroscopyResult.
  ///
  /// In en, this message translates to:
  /// **'An atlas of licensed micrographs and a picture practice to check yourself.'**
  String get howToMicroscopyResult;

  /// No description provided for @howToCoprologyStep1.
  ///
  /// In en, this message translates to:
  /// **'“Specimen collection”: container, timing, multiple samples, preservative.'**
  String get howToCoprologyStep1;

  /// No description provided for @howToCoprologyStep2.
  ///
  /// In en, this message translates to:
  /// **'“Macroscopic examination”: form, colour, reaction, admixtures.'**
  String get howToCoprologyStep2;

  /// No description provided for @howToCoprologyStep3.
  ///
  /// In en, this message translates to:
  /// **'“Coprogram microscopy”: a card for each element (muscle fibres, fat, starch and more).'**
  String get howToCoprologyStep3;

  /// No description provided for @howToCoprologyStep4.
  ///
  /// In en, this message translates to:
  /// **'“Occult blood”: FIT and guaiac test, preparation, result.'**
  String get howToCoprologyStep4;

  /// No description provided for @howToCoprologyStep5.
  ///
  /// In en, this message translates to:
  /// **'“Intestinal parasites”: concentration methods, a key to eggs and cysts (schematic).'**
  String get howToCoprologyStep5;

  /// No description provided for @howToCoprologyStep6.
  ///
  /// In en, this message translates to:
  /// **'Below — practical protocols (slides) and test cards.'**
  String get howToCoprologyStep6;

  /// No description provided for @howToCoprologyResult.
  ///
  /// In en, this message translates to:
  /// **'A coprology reference from collection to result — with sources; it is not a diagnosis.'**
  String get howToCoprologyResult;

  /// No description provided for @howToAssessmentStep1.
  ///
  /// In en, this message translates to:
  /// **'Choose your category (3–2, first or highest) and set a daily goal.'**
  String get howToAssessmentStep1;

  /// No description provided for @howToAssessmentStep2.
  ///
  /// In en, this message translates to:
  /// **'“Knowledge test”: a test of random questions from the official list.'**
  String get howToAssessmentStep2;

  /// No description provided for @howToAssessmentStep3.
  ///
  /// In en, this message translates to:
  /// **'“Topic practice”: the key and an explanation right after each answer.'**
  String get howToAssessmentStep3;

  /// No description provided for @howToAssessmentStep4.
  ///
  /// In en, this message translates to:
  /// **'“Oral ticket”: draw a ticket, prepare, view the answer plan and rate yourself.'**
  String get howToAssessmentStep4;

  /// No description provided for @howToAssessmentStep5.
  ///
  /// In en, this message translates to:
  /// **'“Mistake review” and “Progress”: rework mistakes and follow your results by topic.'**
  String get howToAssessmentStep5;

  /// No description provided for @howToAssessmentStep6.
  ///
  /// In en, this message translates to:
  /// **'The section is for Uzbekistan: in Uzbek, or Profile → “Knowledge & Skills Assessment” → “Uzbekistan”.'**
  String get howToAssessmentStep6;

  /// No description provided for @howToAssessmentResult.
  ///
  /// In en, this message translates to:
  /// **'Practice on the official question list, your results and a review of mistakes — to check your own knowledge.'**
  String get howToAssessmentResult;

  /// No description provided for @howToDifferentialStep1.
  ///
  /// In en, this message translates to:
  /// **'“Cell identification”: size, nucleus, cytoplasm and granules of each cell.'**
  String get howToDifferentialStep1;

  /// No description provided for @howToDifferentialStep2.
  ///
  /// In en, this message translates to:
  /// **'“Start counting”: tap +1, long-press −1; 100 or 200 cells.'**
  String get howToDifferentialStep2;

  /// No description provided for @howToDifferentialStep3.
  ///
  /// In en, this message translates to:
  /// **'When done, save the result to history — “Saved results”, on this device only.'**
  String get howToDifferentialStep3;

  /// No description provided for @howToDifferentialStep4.
  ///
  /// In en, this message translates to:
  /// **'“Differential: absolute counts”: absolute numbers from WBC and percentages.'**
  String get howToDifferentialStep4;

  /// No description provided for @howToDifferentialStep5.
  ///
  /// In en, this message translates to:
  /// **'Build your skills with “Interpretation” and the “Which cell is this?” practice.'**
  String get howToDifferentialStep5;

  /// No description provided for @howToDifferentialResult.
  ///
  /// In en, this message translates to:
  /// **'A percentage differential, results saved on the device, interpretation notes and practice.'**
  String get howToDifferentialResult;

  /// No description provided for @howToCytologyStep1.
  ///
  /// In en, this message translates to:
  /// **'“Cells and organisms”: a drawing and the key feature of each item.'**
  String get howToCytologyStep1;

  /// No description provided for @howToCytologyStep2.
  ///
  /// In en, this message translates to:
  /// **'“Vaginal smear cleanliness grade”: mark what you see — the app shows the grade.'**
  String get howToCytologyStep2;

  /// No description provided for @howToCytologyStep3.
  ///
  /// In en, this message translates to:
  /// **'“The Bethesda system”: what a Pap report means.'**
  String get howToCytologyStep3;

  /// No description provided for @howToCytologyStep4.
  ///
  /// In en, this message translates to:
  /// **'Sample adequacy, reactive changes and the maturation index — on separate pages.'**
  String get howToCytologyStep4;

  /// No description provided for @howToCytologyStep5.
  ///
  /// In en, this message translates to:
  /// **'“Which cell is this?”: a picture practice.'**
  String get howToCytologyStep5;

  /// No description provided for @howToCytologyResult.
  ///
  /// In en, this message translates to:
  /// **'A learning reference for the gynaecological smear, the cleanliness grade and practice; not a diagnosis.'**
  String get howToCytologyResult;

  /// No description provided for @howToSpermogramStep1.
  ///
  /// In en, this message translates to:
  /// **'“Key parameters”: the WHO 2021 lower reference limits.'**
  String get howToSpermogramStep1;

  /// No description provided for @howToSpermogramStep2.
  ///
  /// In en, this message translates to:
  /// **'“Counter”: count motility and morphology.'**
  String get howToSpermogramStep2;

  /// No description provided for @howToSpermogramStep3.
  ///
  /// In en, this message translates to:
  /// **'“Assess a result”: enter the values — they are compared with the WHO limits.'**
  String get howToSpermogramStep3;

  /// No description provided for @howToSpermogramStep4.
  ///
  /// In en, this message translates to:
  /// **'“Terms” and “Pre-analytics”: oligo-, astheno-, terato-; abstinence, collection, delivery.'**
  String get howToSpermogramStep4;

  /// No description provided for @howToSpermogramStep5.
  ///
  /// In en, this message translates to:
  /// **'“Practice”: check your knowledge with questions.'**
  String get howToSpermogramStep5;

  /// No description provided for @howToSpermogramResult.
  ///
  /// In en, this message translates to:
  /// **'A result compared with the WHO 2021 limits, terms and practice — a learning reference.'**
  String get howToSpermogramResult;

  /// No description provided for @howToBloodGroupStep1.
  ///
  /// In en, this message translates to:
  /// **'“ABO and RhD basics”: antigens, antibodies, forward and reverse grouping.'**
  String get howToBloodGroupStep1;

  /// No description provided for @howToBloodGroupStep2.
  ///
  /// In en, this message translates to:
  /// **'“Methods” and “Compatibility”: slide, tube, gel card; compatibility testing.'**
  String get howToBloodGroupStep2;

  /// No description provided for @howToBloodGroupStep3.
  ///
  /// In en, this message translates to:
  /// **'“Discrepancies and errors”: forward/reverse mismatch, weak D.'**
  String get howToBloodGroupStep3;

  /// No description provided for @howToBloodGroupStep4.
  ///
  /// In en, this message translates to:
  /// **'“Reaction pattern reader”: mark the results — the app shows a learning interpretation.'**
  String get howToBloodGroupStep4;

  /// No description provided for @howToBloodGroupStep5.
  ///
  /// In en, this message translates to:
  /// **'“Practice”; transfusion decisions follow your local protocol only.'**
  String get howToBloodGroupStep5;

  /// No description provided for @howToBloodGroupResult.
  ///
  /// In en, this message translates to:
  /// **'A learning reference on ABO and RhD and a learning interpretation of reaction patterns.'**
  String get howToBloodGroupResult;

  /// No description provided for @howToHistologyStep1.
  ///
  /// In en, this message translates to:
  /// **'“Tissues and organs”: epithelium, connective, muscle, nerve; liver, kidney.'**
  String get howToHistologyStep1;

  /// No description provided for @howToHistologyStep2.
  ///
  /// In en, this message translates to:
  /// **'Open an image: a real micrograph, the key feature and what to look at.'**
  String get howToHistologyStep2;

  /// No description provided for @howToHistologyStep3.
  ///
  /// In en, this message translates to:
  /// **'“Staining methods”: H&E, Masson, elastic, silver, PAS, LFB.'**
  String get howToHistologyStep3;

  /// No description provided for @howToHistologyStep4.
  ///
  /// In en, this message translates to:
  /// **'“Which tissue is this?”: a picture practice.'**
  String get howToHistologyStep4;

  /// No description provided for @howToHistologyStep5.
  ///
  /// In en, this message translates to:
  /// **'“Picture credits”: the author and license of every image.'**
  String get howToHistologyStep5;

  /// No description provided for @howToHistologyResult.
  ///
  /// In en, this message translates to:
  /// **'A tissue atlas with licensed micrographs, staining methods and practice.'**
  String get howToHistologyResult;

  /// No description provided for @howToUrinalysisStep1.
  ///
  /// In en, this message translates to:
  /// **'“Collection and preservation”: morning sample, midstream, timing, refrigeration.'**
  String get howToUrinalysisStep1;

  /// No description provided for @howToUrinalysisStep2.
  ///
  /// In en, this message translates to:
  /// **'“Physical properties”: colour, clarity, odour, specific gravity.'**
  String get howToUrinalysisStep2;

  /// No description provided for @howToUrinalysisStep3.
  ///
  /// In en, this message translates to:
  /// **'“Strip test (chemical examination)”: 10 pads — meaning, interferences, confirmation.'**
  String get howToUrinalysisStep3;

  /// No description provided for @howToUrinalysisStep4.
  ///
  /// In en, this message translates to:
  /// **'“Sediment microscopy”: cells, casts, crystals, organisms.'**
  String get howToUrinalysisStep4;

  /// No description provided for @howToUrinalysisStep5.
  ///
  /// In en, this message translates to:
  /// **'“Result reader” and “Practice: what is this?” — check yourself.'**
  String get howToUrinalysisStep5;

  /// No description provided for @howToUrinalysisResult.
  ///
  /// In en, this message translates to:
  /// **'A step-by-step urinalysis reference, a result reader and practice.'**
  String get howToUrinalysisResult;

  /// No description provided for @howToBloodMorphStep1.
  ///
  /// In en, this message translates to:
  /// **'“The normal red cell and what to look at”: size, colour, shape, inclusions.'**
  String get howToBloodMorphStep1;

  /// No description provided for @howToBloodMorphStep2.
  ///
  /// In en, this message translates to:
  /// **'“Red cell changes”: picture cards — what you see and what it may point to.'**
  String get howToBloodMorphStep2;

  /// No description provided for @howToBloodMorphStep3.
  ///
  /// In en, this message translates to:
  /// **'“Platelets” and “Reticulocytes”: counting principles and artefacts.'**
  String get howToBloodMorphStep3;

  /// No description provided for @howToBloodMorphStep4.
  ///
  /// In en, this message translates to:
  /// **'“Anaemia classification helper”: Hb, MCV, RDW → morphological group.'**
  String get howToBloodMorphStep4;

  /// No description provided for @howToBloodMorphStep5.
  ///
  /// In en, this message translates to:
  /// **'“Practice: which change is this?” — picture and knowledge questions.'**
  String get howToBloodMorphStep5;

  /// No description provided for @howToBloodMorphResult.
  ///
  /// In en, this message translates to:
  /// **'A picture reference for the peripheral blood film, an anaemia helper and practice.'**
  String get howToBloodMorphResult;

  /// No description provided for @howToCoagulogramStep1.
  ///
  /// In en, this message translates to:
  /// **'“What each test measures”: PT/INR, APTT, thrombin time, fibrinogen, D-dimer.'**
  String get howToCoagulogramStep1;

  /// No description provided for @howToCoagulogramStep2.
  ///
  /// In en, this message translates to:
  /// **'“Sample requirements”: 3.2% citrate, 9:1 ratio, timing, pre-analytical errors.'**
  String get howToCoagulogramStep2;

  /// No description provided for @howToCoagulogramStep3.
  ///
  /// In en, this message translates to:
  /// **'“Result reading helper”: PT, APTT and platelets → possible causes from the source.'**
  String get howToCoagulogramStep3;

  /// No description provided for @howToCoagulogramStep4.
  ///
  /// In en, this message translates to:
  /// **'“ISTH overt DIC score”: enter the values — the score is calculated.'**
  String get howToCoagulogramStep4;

  /// No description provided for @howToCoagulogramStep5.
  ///
  /// In en, this message translates to:
  /// **'“Anticoagulant monitoring”: warfarin — INR, heparin — APTT/anti-Xa.'**
  String get howToCoagulogramStep5;

  /// No description provided for @howToCoagulogramResult.
  ///
  /// In en, this message translates to:
  /// **'A hemostasis test reference, a result reading helper and the DIC score — with sources.'**
  String get howToCoagulogramResult;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
