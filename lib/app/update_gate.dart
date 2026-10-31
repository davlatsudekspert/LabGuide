import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/policy/app_policy.dart';

/// Server "yangilang" desa — tepada ixcham taklif (yopsa bo'ladi); "majburiy" desa — butun ekran
/// (yopib bo'lmaydi). Siyosat yo'q yoki so'rov muvaffaqiyatsiz bo'lsa — ilova o'zgarishsiz ishlaydi.
/// Matnlar shu faylda (uz / ru / en): NEEDS_NATIVE_REVIEW.
class UpdateGate extends StatelessWidget {
  const UpdateGate({super.key, required this.controller, required this.child});

  final AppPolicyController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final t = _UpdateText.of(Localizations.localeOf(context).languageCode);
        switch (controller.need) {
          case UpdateNeed.none:
            return child;
          case UpdateNeed.required:
            return _RequiredScreen(text: t, url: controller.updateUrl);
          case UpdateNeed.available:
            return Column(
              children: [
                _SoftBanner(
                  text: t,
                  url: controller.updateUrl,
                  onLater: controller.dismissSoft,
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: child,
                  ),
                ),
              ],
            );
        }
      },
    );
  }
}

Future<void> _openUpdate(Uri url) async {
  try {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } on Object {
    // Ochilmasa hech narsa qilmaymiz: tugma qayta bosiladi.
  }
}

class _RequiredScreen extends StatelessWidget {
  const _RequiredScreen({required this.text, required this.url});

  final _UpdateText text;
  final Uri? url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.system_update,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    text.required,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (url != null) ...[
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => _openUpdate(url!),
                      child: Text(text.update),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoftBanner extends StatelessWidget {
  const _SoftBanner({
    required this.text,
    required this.url,
    required this.onLater,
  });

  final _UpdateText text;
  final Uri? url;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text.available,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              if (url != null)
                TextButton(
                  onPressed: () => _openUpdate(url!),
                  child: Text(text.update),
                ),
              TextButton(onPressed: onLater, child: Text(text.later)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateText {
  const _UpdateText({
    required this.title,
    required this.required,
    required this.available,
    required this.update,
    required this.later,
  });

  final String title;
  final String required;
  final String available;
  final String update;
  final String later;

  static _UpdateText of(String lang) => switch (lang) {
    'uz' => const _UpdateText(
      title: 'Ilovani yangilang',
      required:
          'Bu versiya endi qo‘llab-quvvatlanmaydi. Davom etish uchun ilovani yangilang.',
      available: 'Ilovaning yangi versiyasi bor.',
      update: 'Yangilash',
      later: 'Keyinroq',
    ),
    'ru' => const _UpdateText(
      title: 'Обновите приложение',
      required:
          'Эта версия больше не поддерживается. Чтобы продолжить, обновите приложение.',
      available: 'Доступна новая версия приложения.',
      update: 'Обновить',
      later: 'Позже',
    ),
    _ => const _UpdateText(
      title: 'Update the app',
      required:
          'This version is no longer supported. Update the app to continue.',
      available: 'A new version of the app is available.',
      update: 'Update',
      later: 'Later',
    ),
  };
}
