import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

final uz = AppLocalizationsUz();

final _vertical = find.byWidgetPredicate(
  (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
);

Future<void> _tapText(WidgetTester tester, String text) async {
  final f = find.text(text);
  if (f.hitTestable().evaluate().isEmpty) {
    if (f.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        f,
        250,
        scrollable: _vertical.hitTestable().first,
      );
    } else {
      await tester.ensureVisible(f.first);
    }
    await tester.pumpAndSettle();
  }
  await tester.tap(f.hitTestable().first);
  await tester.pumpAndSettle();
}

/// Ko'rinib turgan (eng yuqori) sahifaning yo'li.
String _path(WidgetTester tester) =>
    GoRouterState.of(tester.element(find.byType(LgPage).last)).uri.path;

String _title(WidgetTester tester) =>
    tester.widget<LgPage>(find.byType(LgPage).last).title;

void main() {
  setUpAll(loadAppFonts);

  testWidgets('doctor home → conditions → diabetes → HbA1c card → back', (
    tester,
  ) async {
    final s = await makeServices(tester, role: AppRole.doctor);
    await pumpApp(tester, s);
    // Bosh sahifadagi qo'llanma kartasi.
    expect(find.text(uz.condGuideTitle), findsOneWidget);
    expect(find.text(uz.condGuideAll), findsOneWidget);
    await _tapText(tester, uz.condGuideAll);
    expect(_title(tester), uz.condGuideTitle);
    // Tizimlar bo'yicha guruhlangan ro'yxat.
    expect(find.text(uz.condSysEndocrine), findsWidgets);
    await _tapText(tester, '2-tip qandli diabet');
    expect(_title(tester), '2-tip qandli diabet');
    expect(find.text(uz.condNotDiagnosticTitle), findsOneWidget);
    expect(find.textContaining(uz.condTierFirstLine), findsWidgets);
    // Birinchi navbatdagi tahlil → analit kartasi (o'sha tab ichida).
    await _tapText(tester, 'HbA1c (glikirlangan gemoglobin)');
    final hba1c = s.content.pack!.analyte('hba1c')!.names.of('uz');
    expect(_title(tester), hba1c);
    expect(_path(tester), '/home/conditions/type-2-diabetes/analyte/hba1c');
    // Teskari yo'nalish: karta holatlarni ko'rsatadi.
    await tester.scrollUntilVisible(
      find.text(uz.condAnalyteSection),
      300,
      scrollable: _vertical.hitTestable().first,
    );
    expect(find.text(uz.condAnalyteSection), findsOneWidget);
    // Orqaga: holat kartasi, keyin ro'yxat, keyin bosh sahifa.
    await tester.tap(find.byTooltip(uz.actionBack).hitTestable().first);
    await tester.pumpAndSettle();
    expect(_title(tester), '2-tip qandli diabet');
    await tester.tap(find.byTooltip(uz.actionBack).hitTestable().first);
    await tester.pumpAndSettle();
    expect(_title(tester), uz.condGuideTitle);
    await tester.tap(find.byTooltip(uz.actionBack).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text(uz.condGuideAll), findsOneWidget);
  });

  testWidgets('quick chip opens a condition in one tap; copy list', (
    tester,
  ) async {
    final s = await makeServices(tester, role: AppRole.doctor);
    await pumpApp(tester, s);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await _tapText(tester, 'Gipotireoz (qalqonsimon bez faoliyati pasayishi)');
    expect(_path(tester), '/home/conditions/hypothyroidism');
    await tester.scrollUntilVisible(
      find.text('TSH ↑ + erkin T4 ↓'),
      300,
      scrollable: _vertical.hitTestable().first,
    );
    expect(find.text('TSH ↑ + erkin T4 ↓'), findsOneWidget);
    await _tapText(tester, uz.condCopyList);
    expect(copied, contains('Gipotireoz'));
    expect(copied, contains(uz.condReferralFooter));
    expect(find.text(uz.condCopied), findsOneWidget);
  });

  testWidgets('tests tab: entry row and condition matches in search', (
    tester,
  ) async {
    final s = await makeServices(tester, role: AppRole.student);
    await pumpApp(tester, s);
    await goTo(tester, '/tests');
    expect(find.text(uz.condGuideTitle), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'qand');
    await tester.pumpAndSettle();
    expect(find.text(uz.condSearchSection), findsOneWidget);
    await _tapText(tester, '2-tip qandli diabet');
    expect(_path(tester), '/tests/conditions/type-2-diabetes');
  });

  testWidgets('conditions search filters by name and system', (tester) async {
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s);
    await goTo(tester, '/tests/conditions');
    await tester.enterText(find.byType(TextField).first, 'щитовид');
    await tester.pumpAndSettle();
    expect(
      find.text('Гипотиреоз (снижение функции щитовидной железы)'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField).first, 'zzzqqq');
    await tester.pumpAndSettle();
    expect(find.text('Ничего не найдено'), findsOneWidget);
  });
}
