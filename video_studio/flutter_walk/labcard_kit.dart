// Shared walk for instrument-class reference cards (Lab → Instruments and
// methods → <direction> → card): the direction list with the card row, the
// card with its original schematic, the numbered-parts panel (expanded), and
// chosen text fields. For every field the frame records a rectangle that
// covers the section title + the field text but NOT the source line below
// it (the video dims outside that rectangle: source titles name publishers,
// kept off camera like the flagships' bibliographic sources).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';

import 'file:///home/user/wt-audit/test/helpers/harness.dart';
import 'walk_kit.dart';

Future<void> labCardWalk(
  WidgetTester tester,
  Walk w,
  AppLocalizations l, {
  required String cardId,
  required String cardName,
  required String direction,
  required String schematicKey,
  required Map<String, String> fields, // frame id -> section title
  required String prefix,
}) async {
  // 1. The direction's reference cards, the card row ringed.
  await goTo(tester, '/lab/instruments/d/$direction');
  final row = find.text(cardName);
  await w.bring(row, at: 470);
  await w.snap('${prefix}_dir', tapOn: row, marks: {'card': row});

  // 2. The card with the app's original schematic (class, not a model).
  await goTo(tester, '/lab/instruments/lc/$cardId');
  final fig = find.byKey(const ValueKey('lab-card-schematic'));
  await w.bring(fig, at: 360);
  await w.snap('${prefix}_card', marks: {'schematic': fig, 'title': find.text(cardName).first});

  // 3. Numbered parts panel, expanded.
  final panel = find.byKey(ValueKey('schematic-parts-$schematicKey'));
  await w.bring(panel, at: 300);
  await tester.tap(find.text(l.schemPartsPanelTitle).first);
  await tester.pumpAndSettle();
  final p1 = find.byKey(const ValueKey('schematic-part-1'));
  await w.bring(p1, at: 230);
  await w.snap('${prefix}_parts', marks: {'parts': p1, 'panel': find.text(l.schemPartsPartsTitle)});
  // Collapse again so the fields below sit where a reader finds them.
  await w.bring(find.text(l.schemPartsPanelTitle), at: 300);
  await tester.tap(find.text(l.schemPartsPanelTitle).first);
  await tester.pumpAndSettle();

  // 4. Text fields: title + first text block (source line excluded).
  for (final e in fields.entries) {
    final title = find.text(e.value);
    await w.bring(title, at: 300);
    final tr = tester.getRect(title.first);
    // The field text is the next Text below the title.
    Rect? body;
    for (final el in find.byType(Text).evaluate()) {
      final box = el.renderObject as RenderBox?;
      if (box == null || !box.hasSize || !box.attached) continue;
      final r = box.localToGlobal(Offset.zero) & box.size;
      if (r.top >= tr.bottom - 1 && r.top < tr.bottom + 60 && r.height > 18) {
        if (body == null || r.top < body.top) body = r;
      }
    }
    await w.snap(e.key, marks: {
      'title': title,
    });
    final u = body == null ? tr : tr.expandToInclude(body);
    final last = w.frames.last;
    (last['marks']! as Map)['field'] = [u.left - 4, u.top - 6, u.width + 8, u.height + 7];
  }
}

AppRole get walkRole => AppRole.lab;
