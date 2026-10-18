import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';

/// Profildagi yagona “Yordam va aloqa” kirishi (D-68 Q6): ichida ikki aniq
/// yo'l — ilova ichidagi yozishma (`/profile/support`, javob ilovaga keladi)
/// va email / shikoyat (`/profile/contact`, serversiz doim ochiq). Ikkala
/// manzil o'zgarmagan: boshqa joylardagi havolalar (hamjamiyatdagi shikoyat,
/// kontent so'rovi) to'g'ridan-to'g'ri ishlayveradi.
class HelpContactScreen extends StatelessWidget {
  const HelpContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = context.services;
    final access = services.access;
    return ListenableBuilder(
      listenable: access,
      builder: (context, _) {
        final l = AppLocalizations.of(context);
        return LgPage(
          title: l.helpTitle,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l.helpIntro,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            LgRow(
              key: const ValueKey('help-support'),
              title: l.supportTitle,
              subtitle: services.backend.isConfigured
                  ? l.supportSub
                  : '${l.supportSub} · ${l.notAvailableYet}',
              icon: Icons.forum_outlined,
              trailing: access.unreadReplies > 0
                  ? LgTag(
                      l.supportUnreadCount(access.unreadReplies),
                      tone: LgTone.brand,
                    )
                  : null,
              onTap: () => context.push('/profile/support'),
            ),
            LgRow(
              key: const ValueKey('help-contact'),
              title: l.contactRowTitle,
              subtitle: l.contactRowSub,
              icon: Icons.mail_outline_rounded,
              onTap: () => context.push('/profile/contact'),
              divider: false,
            ),
          ],
        );
      },
    );
  }
}
