import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_scope.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets/lg_widgets.dart';
import '../../settings/settings_controller.dart';
import 'welcome_screen.dart';

/// Birinchi ishga tushirishdagi til tanlash ekrani (welcome'dan oldin).
///
/// Har bir karta o'z tilida yozilgan, shuning uchun bu yerda ARB kalitlari
/// ishlatilmaydi: ilova hali foydalanuvchi tilida emas. Tanlangach til
/// o'rnatiladi, `languageChosen` saqlanadi va /welcome ochiladi.
class LanguagePickerScreen extends StatefulWidget {
  const LanguagePickerScreen({super.key});

  /// Ko'rsatish tartibi: English, Русский, O'zbekcha.
  static const options = <LanguageOption>[
    LanguageOption(
      language: AppLanguage.en,
      code: 'EN',
      name: 'English',
      greeting: 'Welcome',
      subtitle: 'Continue in English',
    ),
    LanguageOption(
      language: AppLanguage.ru,
      code: 'RU',
      name: 'Русский',
      greeting: 'Добро пожаловать',
      subtitle: 'Продолжить на русском',
    ),
    LanguageOption(
      language: AppLanguage.uz,
      code: 'UZ',
      name: 'O‘zbekcha',
      greeting: 'Xush kelibsiz',
      subtitle: 'O‘zbek tilida davom etish',
    ),
  ];

  /// Qurilma tili: ru → Русский, uz → O'zbekcha, qolgan hammasi → English.
  static AppLanguage suggest(Iterable<Locale> deviceLocales) {
    final code = deviceLocales.isEmpty
        ? null
        : deviceLocales.first.languageCode;
    return switch (code) {
      'ru' => AppLanguage.ru,
      'uz' => AppLanguage.uz,
      _ => AppLanguage.en,
    };
  }

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class LanguageOption {
  const LanguageOption({
    required this.language,
    required this.code,
    required this.name,
    required this.greeting,
    required this.subtitle,
  });

  final AppLanguage language;
  final String code;
  final String name;
  final String greeting;
  final String subtitle;
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen>
    with SingleTickerProviderStateMixin {
  // Bitta tugaydigan controller: logo, sarlavha va kartalar Interval bilan
  // ketma-ket paydo bo'ladi (cheksiz animatsiya yo'q).
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  bool _started = false;
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Reduced motion: hammasi darhol ko'rinadi.
    if (LgMotion.reduced(context)) {
      _c.value = 1;
    } else {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Animation<double> _step(double begin, double end) => CurvedAnimation(
    parent: _c,
    curve: Interval(begin, end, curve: Curves.easeOutCubic),
  );

  Future<void> _choose(AppLanguage language) async {
    if (_busy) return;
    _busy = true;
    final router = GoRouter.of(context);
    await context.services.settings.chooseLanguage(language);
    router.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final suggested = LanguagePickerScreen.suggest(
      View.of(context).platformDispatcher.locales,
    );
    final logoAnim = _step(0, 0.4);
    final headAnim = _step(0.25, 0.55);
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: LgSpace.gutter(MediaQuery.sizeOf(context).width),
              vertical: LgSpace.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FadeTransition(
                    opacity: logoAnim,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.8,
                        end: 1,
                      ).animate(logoAnim),
                      child: const LgLogoHero(size: 104),
                    ),
                  ),
                  const SizedBox(height: LgSpace.lg),
                  FadeTransition(
                    opacity: headAnim,
                    child: Column(
                      children: [
                        Icon(Icons.language_rounded, size: 28, color: p.brand),
                        const SizedBox(height: LgSpace.sm),
                        Text(
                          'Choose language · Выберите язык · Tilni tanlang',
                          textAlign: TextAlign.center,
                          style: text.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: LgSpace.lg),
                  for (var i = 0; i < LanguagePickerScreen.options.length; i++)
                    _StaggeredIn(
                      animation: _step(0.4 + i * 0.12, 0.7 + i * 0.12),
                      child: _LanguageCard(
                        option: LanguagePickerScreen.options[i],
                        highlighted:
                            LanguagePickerScreen.options[i].language ==
                            suggested,
                        onTap: () =>
                            _choose(LanguagePickerScreen.options[i].language),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fade + pastdan biroz siljib kirish.
class _StaggeredIn extends StatelessWidget {
  const _StaggeredIn({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  );
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.option,
    required this.highlighted,
    required this.onTap,
  });

  final LanguageOption option;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    const radius = BorderRadius.all(Radius.circular(LgRadius.card));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LgPressable(
        onTap: onTap,
        borderRadius: radius,
        color: highlighted ? p.soft : p.paper,
        border: Border.all(
          color: highlighted ? p.brand : p.line,
          width: highlighted ? 2 : 1,
        ),
        selected: highlighted,
        semanticLabel: '${option.name}. ${option.greeting}. ${option.subtitle}',
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: highlighted ? p.brand : p.soft,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      option.code,
                      style: text.labelLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        color: highlighted ? p.onBrand : p.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.name,
                          style: text.titleLarge!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          option.greeting,
                          style: text.bodyLarge!.copyWith(color: p.brand),
                        ),
                        Text(option.subtitle, style: text.bodySmall),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: p.sub),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
