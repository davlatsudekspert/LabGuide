import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/differential/diff_eyes_free.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/differential/differential_controller.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/diff_device_fakes.dart';
import '../helpers/harness.dart';

final en = AppLocalizationsEn();

Finder _button(DiffCell c) => find.byKey(ValueKey('diff-count-${c.name}'));
final _haptic = find.byKey(const ValueKey('diff-fb-haptics'));
final _sound = find.byKey(const ValueKey('diff-fb-sound'));

Future<void> _open(
  WidgetTester tester,
  MemoryKeyValueStore store,
  RecordingCuePlayer Function() cues,
) async {
  final s = await makeServices(tester, language: AppLanguage.en, store: store);
  await pumpApp(tester, s, size: const Size(390, 3000));
  await goTo(tester, '/lab/differential/count');
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('sukut: tebranish yoqiq, tovush o\'chiq; faqat tebranish', (
    tester,
  ) async {
    final fakes = installDiffFakes();
    final haptics = recordHaptics(tester);
    final store = MemoryKeyValueStore();
    await _open(tester, store, () => fakes.cues);

    await tester.tap(_button(DiffCell.segmented));
    await tester.pump();
    expect(haptics, ['selection']);
    expect(fakes.cues.cues, isEmpty);

    await tester.longPress(_button(DiffCell.segmented));
    await tester.pump();
    expect(haptics, ['selection', 'medium']);
    expect(fakes.cues.cues, isEmpty);
  });

  testWidgets('tovush yoqilsa: hujayra toni, −1 da undo; sozlama saqlanadi', (
    tester,
  ) async {
    final fakes = installDiffFakes();
    final haptics = recordHaptics(tester);
    final store = MemoryKeyValueStore();
    await _open(tester, store, () => fakes.cues);

    await tester.tap(_sound);
    await tester.pump();
    await tester.tap(_button(DiffCell.lymphocyte));
    await tester.pump();
    await tester.tap(_button(DiffCell.basophil));
    await tester.pump();
    await tester.longPress(_button(DiffCell.basophil));
    await tester.pump();
    expect(fakes.cues.cues, [Cue.cellLymphocyte, Cue.cellBasophil, Cue.undo]);
    expect(haptics, ['selection', 'selection', 'medium']);

    // Qayta ochilganda sozlama saqlangan.
    expect(DifferentialController(store).counterSound, isTrue);
    expect(DifferentialController(store).counterHaptics, isTrue);
  });

  testWidgets('tebranish o\'chirilsa jim; saqlanadi', (tester) async {
    final fakes = installDiffFakes();
    final haptics = recordHaptics(tester);
    final store = MemoryKeyValueStore();
    await _open(tester, store, () => fakes.cues);

    await tester.tap(_haptic);
    await tester.pump();
    await tester.tap(_button(DiffCell.monocyte));
    await tester.pump();
    await tester.longPress(_button(DiffCell.monocyte));
    await tester.pump();
    expect(haptics, isEmpty);
    expect(fakes.cues.cues, isEmpty);
    final reopened = DifferentialController(store);
    expect(reopened.counterHaptics, isFalse);
    expect(reopened.counterSound, isFalse);
  });

  testWidgets('maqsadga yetilganda og\'ir tebranish + done; keyin blocked', (
    tester,
  ) async {
    final fakes = installDiffFakes();
    final haptics = recordHaptics(tester);
    final store = MemoryKeyValueStore();
    final s = await makeServices(
      tester,
      language: AppLanguage.en,
      store: store,
    );
    await s.differential.setCounterFeedback(sound: true);
    for (var i = 0; i < 99; i++) {
      s.differential.tap(DiffCell.segmented);
    }
    await pumpApp(tester, s, size: const Size(390, 3000));
    await goTo(tester, '/lab/differential/count');

    await tester.tap(_button(DiffCell.lymphocyte));
    await tester.pump();
    expect(s.differential.isComplete, isTrue);
    expect(haptics, ['heavy', 'heavy']);
    expect(fakes.cues.cues, [Cue.done]);

    haptics.clear();
    fakes.cues.cues.clear();
    await tester.tap(_button(DiffCell.lymphocyte));
    await tester.pump();
    expect(haptics, ['long']);
    expect(fakes.cues.cues, [Cue.blocked]);
  });

  testWidgets('tugmalarda tooltip va semantika', (tester) async {
    installDiffFakes();
    final handle = tester.ensureSemantics();
    final store = MemoryKeyValueStore();
    await _open(tester, store, () => RecordingCuePlayer());
    expect(
      find.byTooltip('${en.diffFbSound}: ${en.diffFbOff}'),
      findsOneWidget,
    );
    expect(
      find.byTooltip('${en.diffFbHaptics}: ${en.diffFbOn}'),
      findsOneWidget,
    );
    expect(
      tester.getSemantics(_sound),
      isSemantics(
        label: en.diffFbSound,
        value: en.diffFbOff,
        hasToggledState: true,
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
