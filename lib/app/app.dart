import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/backend/step_up.dart';
import '../design/theme.dart';
import '../features/admin/step_up_dialog.dart';
import '../features/daily/daily_screens.dart';
import '../features/home/resume_history.dart';
import '../features/settings/settings_controller.dart';
import '../features/toifa/toifa_screens.dart' show toifaBase;
import '../l10n/gen/app_localizations.dart';
import 'app_scope.dart';
import 'router.dart';

class LabGuideApp extends StatefulWidget {
  const LabGuideApp({super.key, required this.services});

  final AppServices services;

  @override
  State<LabGuideApp> createState() => _LabGuideAppState();
}

class _LabGuideAppState extends State<LabGuideApp> {
  late GoRouter _router;
  late bool _wasOnboarded;

  /// Sahifa almashganda oldingi sahifaning xabari (SnackBar) yangi sahifani
  /// yopib turmasin.
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  String? _location;
  late final OnboardingChanges _routerRefresh = OnboardingChanges(_settings);

  SettingsController get _settings => widget.services.settings;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(_settings, refresh: _routerRefresh);
    _router.routeInformationProvider.addListener(_onRoute);
    _wasOnboarded = _settings.onboarded;
    _settings.addListener(_onSettings);
    widget.services.reminders.addListener(_onReminder);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onReminder());
    if (widget.services.backend case final StepUpBackend b) {
      b.stepUpPrompt = _stepUpPrompt;
    }
  }

  /// Admin step-up (server `403 step_up_required`): kod oynasi ildiz
  /// navigatorda; tasdiqlansa backend so'rovni bir marta qaytaradi.
  Future<bool> _stepUpPrompt(String? action) async {
    final ctx = _router.routerDelegate.navigatorKey.currentContext;
    if (widget.services.backend case final StepUpBackend b
        when ctx != null && ctx.mounted) {
      return showStepUpDialog(ctx, b);
    }
    return false;
  }

  /// Eslatma bildirishnomasi bosilgan — kunlik savol ochiladi.
  void _onReminder() {
    if (!mounted || !_settings.onboarded) return;
    if (widget.services.reminders.takeOpenRequest()) {
      openDailyFromReminder(_router);
    }
    // Toifa eslatmasi — toifa bo'limi (bo'lim yopiq bo'lsa, router o'zi
    // O'rganishga qaytaradi).
    if (widget.services.reminders.takeToifaOpenRequest()) {
      _router.go(toifaBase);
    }
  }

  /// Chiqish yoki lokal ma'lumotlar o'chirilganda tab stacklari ham
  /// tozalanadi: router qaytadan quriladi.
  void _onSettings() {
    final onboarded = _settings.onboarded;
    if (_wasOnboarded && !onboarded) {
      final old = _router..routeInformationProvider.removeListener(_onRoute);
      setState(() => _router = buildRouter(_settings, refresh: _routerRefresh));
      _router.routeInformationProvider.addListener(_onRoute);
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    _wasOnboarded = onboarded;
  }

  void _onRoute() {
    final uri = _router.routeInformationProvider.value.uri;
    final location = uri.path;
    // Bosh sahifadagi “Davom ettirish” uchun oxirgi taqdimot/test/bo'lim.
    if (_settings.onboarded) {
      ResumeHistory.of(widget.services.store).note(uri);
    }
    if (_location != null && location != _location) {
      _messenger.currentState?.hideCurrentSnackBar();
    }
    _location = location;
  }

  @override
  void dispose() {
    if (widget.services.backend case final StepUpBackend b
        when b.stepUpPrompt == _stepUpPrompt) {
      b.stepUpPrompt = null;
    }
    _router.routeInformationProvider.removeListener(_onRoute);
    _settings.removeListener(_onSettings);
    widget.services.reminders.removeListener(_onReminder);
    _router.dispose();
    _routerRefresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: widget.services,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => MaterialApp.router(
          restorationScopeId: 'app',
          onGenerateTitle: (_) => 'LabGuide',
          debugShowCheckedModeBanner: false,
          routerConfig: _router,
          scaffoldMessengerKey: _messenger,
          theme: buildLgTheme(
            Brightness.light,
            theme: _settings.appTheme,
            cyrillic: _settings.language == AppLanguage.ru,
          ),
          darkTheme: buildLgTheme(
            Brightness.dark,
            theme: _settings.appTheme,
            cyrillic: _settings.language == AppLanguage.ru,
          ),
          themeMode: _settings.themeMode,
          // Mavzu almashganda ranglar silliq o'tadi (D-64).
          // Reduced motion — darhol.
          themeAnimationDuration:
              WidgetsBinding
                  .instance
                  .platformDispatcher
                  .accessibilityFeatures
                  .disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 360),
          themeAnimationCurve: Curves.easeOutCubic,
          locale: _settings.language.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
        ),
      ),
    );
  }
}
