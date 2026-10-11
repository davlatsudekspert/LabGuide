import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../core/storage/kv_store.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'community_screens.dart' show CommunityRoutes;

/// Hamjamiyat qoidalari kartasi (D-43): ro'yxat tepasida doimiy, post emas.
/// Standart yopiq (sarlavha + qisqa xulosa); ochiq/yopiq holati qurilma
/// bo'yicha eslab qolinadi (kv, ixtiyoriy).
class CommunityRulesCard extends StatefulWidget {
  const CommunityRulesCard({super.key});

  @override
  State<CommunityRulesCard> createState() => _CommunityRulesCardState();
}

class _CommunityRulesCardState extends State<CommunityRulesCard> {
  bool? _open;

  Future<void> _toggle(KeyValueStore store, bool current) async {
    setState(() => _open = !current);
    try {
      await store.setBool(StoreKeys.communityRulesOpen, !current);
    } on Object {
      // Eslab qolish ixtiyoriy — xato kartani buzmasligi kerak.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final store = context.services.store;
    var stored = false;
    try {
      stored = store.getBool(StoreKeys.communityRulesOpen) ?? false;
    } on Object {
      stored = false;
    }
    final open = _open ?? stored;
    return Padding(
      key: const ValueKey('cm-rules-card'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.soft,
          borderRadius: BorderRadius.circular(LgRadius.button),
          border: Border.all(color: p.line),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LgPressable(
                key: const ValueKey('cm-rules-toggle'),
                onTap: () => _toggle(store, open),
                semanticLabel:
                    '${l.cmRulesTitle}. ${open ? l.cmRulesCollapse : l.cmRulesExpand}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.rule_rounded, color: p.brand, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.cmRulesTitle,
                              style: text.titleSmall?.copyWith(color: p.ink),
                            ),
                            if (!open)
                              Text(
                                l.cmRulesIntro,
                                style: text.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        open
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: p.sub,
                      ),
                    ],
                  ),
                ),
              ),
              if (open) ...[const SizedBox(height: 6), const _RulesBody()],
            ],
          ),
        ),
      ),
    );
  }
}

/// Qoidalar matni; karta ichida ham, “Savol berish” ekranidagi varaqda ham.
class _RulesBody extends StatefulWidget {
  const _RulesBody({this.beforeNavigate});

  final VoidCallback? beforeNavigate;

  @override
  State<_RulesBody> createState() => _RulesBodyState();
}

class _RulesBodyState extends State<_RulesBody> {
  late final TapGestureRecognizer _verifyTap = TapGestureRecognizer()
    ..onTap = () {
      final router = GoRouter.of(context);
      widget.beforeNavigate?.call();
      router.push(CommunityRoutes.verify);
    };

  @override
  void dispose() {
    _verifyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;

    Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(t, style: text.titleSmall?.copyWith(color: p.ink)),
    );
    Widget bullet(Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: text.bodyMedium),
          Expanded(child: child),
        ],
      ),
    );
    Widget item(String s) => bullet(Text(s, style: text.bodyMedium));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.cmRulesIntro, style: text.bodyMedium),
        heading(l.cmRulesH1),
        for (final s in [
          l.cmRulesA1,
          l.cmRulesA2,
          l.cmRulesA3,
          l.cmRulesA4,
          l.cmRulesA5,
          l.cmRulesA6,
        ])
          item(s),
        heading(l.cmRulesH2),
        for (final s in [l.cmRulesB1, l.cmRulesB2, l.cmRulesB3, l.cmRulesB4])
          item(s),
        heading(l.cmRulesH3),
        for (final s in [l.cmRulesC1, l.cmRulesC2, l.cmRulesC3]) item(s),
        heading(l.cmRulesH4),
        item(l.cmRulesD1),
        bullet(
          Text.rich(
            TextSpan(
              style: text.bodyMedium,
              children: [
                TextSpan(text: l.cmRulesD2Pre),
                TextSpan(
                  text: l.cmRulesD2Link,
                  recognizer: _verifyTap,
                  mouseCursor: SystemMouseCursors.click,
                  style: text.bodyMedium?.copyWith(
                    color: p.brand,
                    decoration: TextDecoration.underline,
                    decorationColor: p.brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: l.cmRulesD2Post),
              ],
            ),
          ),
        ),
        item(l.cmRulesD3),
        const SizedBox(height: 8),
        Text(l.cmRulesOutro, style: text.bodyMedium),
      ],
    );
  }
}

/// “Savol berish” ekranida: qoidalarga ixcham havola (varaq ochadi).
class CommunityRulesLink extends StatelessWidget {
  const CommunityRulesLink({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgButton.link(
      key: const ValueKey('cm-rules-link'),
      label: l.cmRulesTitle,
      icon: Icons.rule_rounded,
      expand: false,
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: SingleChildScrollView(
            key: const ValueKey('cm-rules-sheet'),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.cmRulesTitle,
                  style: Theme.of(sheet).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _RulesBody(beforeNavigate: () => Navigator.of(sheet).pop()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
