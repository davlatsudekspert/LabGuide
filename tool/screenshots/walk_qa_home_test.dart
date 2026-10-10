// QA: bosh sahifa (har to'rt rol), sarlavhadagi til menyusi va profil
// tugmasi, profil/sozlamalar va kirish oqimi — foydalanuvchi sifatida har
// bosiladigan elementni bosib, ochilgan manzil va sarlavhani qayd qiladi.
// "Iflos" holat: boshqa tablarda chuqur sahifa ochiq qolgan.
//
//   flutter test tool/screenshots/walk_qa_home_test.dart --update-goldens
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/content/ui/conditions_screens.dart';
import 'package:labguide/features/content/ui/content_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

final _log = StringBuffer();
const _logPath = 'tool/screenshots/out/walk/qa_home_log.txt';

/// Ko'rinib turgan (joriy marshrut, faol tab) sahifa.
Element? _visible(WidgetTester tester) {
  for (final e in find.byType(LgPage).evaluate()) {
    final route = ModalRoute.of(e);
    if (route == null || !route.isCurrent) continue;
    if (!TickerMode.valuesOf(e).enabled) continue;
    return e;
  }
  return null;
}

String _title(WidgetTester tester) =>
    (_visible(tester)?.widget as LgPage?)?.title ?? '?';

String _loc(WidgetTester tester) {
  final e = _visible(tester);
  return e == null ? '?' : GoRouterState.of(e).uri.toString();
}

void _rec(WidgetTester tester, String sc, String what) {
  final line = '$sc | $what -> ${_loc(tester)} | "${_title(tester)}"';
  _log.writeln(line);
  // ignore: avoid_print
  print(line);
}

AppLocalizations _l(WidgetTester tester) => l10n(tester, AppLocalizations.of);

Finder _scrollable() => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

Future<void> _reveal(WidgetTester tester, Finder f) async {
  for (var i = 0; i < 30 && f.hitTestable().evaluate().isEmpty; i++) {
    await tester.drag(_scrollable(), const Offset(0, -200));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
}

/// Boshqa tablarda chuqur sahifalar ochiq qoladi.
Future<void> _dirty(WidgetTester tester) async {
  await goTo(tester, '/tests/analyte/potassium');
  await goTo(tester, '/lab/calculators/dilution');
  await goTo(tester, '/library/sources');
  await goTo(tester, '/learn/reference');
}

Future<void> _resetTabs(WidgetTester tester) async {
  for (final t in ['/tests', '/lab', '/library', '/learn', '/home']) {
    await goTo(tester, t);
  }
}

Future<void> _top(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.drag(_scrollable(), const Offset(0, 800));
    await tester.pumpAndSettle();
  }
}

typedef _Target = (String, Finder);

/// Bosh sahifadagi barcha bosiladigan elementlar (dangasa ro'yxat —
/// oxirigacha surib yig'iladi).
Future<List<_Target>> _collect(WidgetTester tester) async {
  final out = <String, Finder>{};
  await _top(tester);
  void grab() {
    for (final e in find.byType(LgButton).evaluate()) {
      final label = (e.widget as LgButton).label;
      out['btn "$label"'] = find.descendant(
        of: find.byType(LgButton),
        matching: find.text(label),
      );
    }
    for (final e in find.byType(LgTile).evaluate()) {
      final t = (e.widget as LgTile).title;
      out['tile "$t"'] = find.descendant(
        of: find.byType(LgTile),
        matching: find.text(t),
      );
    }
    for (final e in find.byType(AnalyteRow).evaluate()) {
      final id = (e.widget as AnalyteRow).analyte.id;
      out['row $id'] = find.byWidgetPredicate(
        (w) => w is AnalyteRow && w.analyte.id == id,
      );
    }
    final presses = find.descendant(
      of: find.byType(ConditionGuideCard),
      matching: find.byType(LgPressable),
    );
    for (var i = 0; i < presses.evaluate().length; i++) {
      final texts = find
          .descendant(of: presses.at(i), matching: find.byType(Text))
          .evaluate()
          .map((t) => (t.widget as Text).data)
          .whereType<String>()
          .toList();
      if (texts.isEmpty) continue;
      out['cond "${texts.first}"'] = find.descendant(
        of: find.byType(ConditionGuideCard),
        matching: find.text(texts.first),
      );
    }
  }

  for (var i = 0; i < 12; i++) {
    grab();
    await tester.drag(_scrollable(), const Offset(0, -350));
    await tester.pumpAndSettle();
  }
  grab();
  await goTo(tester, '/home');
  return [for (final e in out.entries) (e.key, e.value)];
}

Future<void> _role(
  WidgetTester tester,
  AppRole role, {
  AppLanguage lang = AppLanguage.uz,
  bool dirty = false,
}) async {
  await start(tester, role: role, lang: lang);
  final sc = '${role.name}_${lang.name}${dirty ? '_iflos' : ''}';
  final w = Walk(tester, 'qa_home_$sc');
  if (!dirty) {
    await w.snap('bosh');
    await w.scroll(600);
    await w.snap('bosh_2');
    await w.scroll(600);
    await w.snap('bosh_3');
    await w.scroll(900);
    await w.snap('bosh_4');
    await goTo(tester, '/home');
  }
  final targets = await _collect(tester);
  _log.writeln('$sc | ${targets.length} targets');
  var n = 0;
  for (final (name, f) in targets) {
    n++;
    if (dirty) await _dirty(tester);
    await goTo(tester, '/home');
    await _top(tester);
    await _reveal(tester, f);
    await tester.tap(f.hitTestable().first);
    await tester.pumpAndSettle();
    _rec(tester, sc, name);
    await w.snap('t${n}_${name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')}');
    final backBtn = find.byTooltip(_l(tester).actionBack).hitTestable();
    if (backBtn.evaluate().isNotEmpty) {
      await tester.tap(backBtn.first);
      await tester.pumpAndSettle();
      _rec(tester, sc, '   back');
    }
    await _resetTabs(tester);
  }
}

void main() {
  setUpAll(loadAppFonts);
  tearDownAll(() {
    File(_logPath).writeAsStringSync(_log.toString(), mode: FileMode.append);
  });

  for (final role in AppRole.values) {
    testWidgets('bosh: ${role.name}', (tester) async {
      await _role(tester, role);
    });
    testWidgets('bosh iflos: ${role.name}', (tester) async {
      await _role(tester, role, dirty: true);
    });
  }
  testWidgets('bosh: doctor ru', (tester) async {
    await _role(tester, AppRole.doctor, lang: AppLanguage.ru);
  });
  testWidgets('bosh: student en', (tester) async {
    await _role(tester, AppRole.student, lang: AppLanguage.en);
  });

  testWidgets('sarlavha: til menyusi, profil, pastki tab', (tester) async {
    await start(tester, role: AppRole.lab);
    final w = Walk(tester, 'qa_header');
    const sc = 'header';
    await tester.tap(
      find.bySemanticsLabel(RegExp('^Til|^Language|^Язык')).first,
    );
    await tester.pumpAndSettle();
    await w.snap('til_menyu');
    await tester.tap(find.text('Русский').last);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'til -> Русский');
    await w.snap('ru');
    await tester.tap(find.bySemanticsLabel(RegExp('Язык')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'til -> English');
    await w.snap('en');
    await tester.tap(find.bySemanticsLabel(RegExp('Language')).first);
    await tester.pumpAndSettle();
    // Menyuni tanlamasdan yopish (tashqariga bosish).
    await tester.tapAt(const Offset(200, 600));
    await tester.pumpAndSettle();
    _rec(tester, sc, 'til menyu yopildi');
    await tester.tap(find.bySemanticsLabel(RegExp('Language')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('O‘zbekcha').last);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'til -> O‘zbekcha');

    // Chuqur sahifadan profil va tilni almashtirish: sahifa joyida qoladi.
    await goTo(tester, '/home/analyte/potassium');
    await tester.tap(find.byTooltip(_l(tester).actionProfile).first);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'profil (analit kartasidan)');
    await w.snap('profil');
    await tester.tap(find.byTooltip(_l(tester).actionBack).first);
    await tester.pumpAndSettle();
    _rec(tester, sc, '   back');
    await tester.tap(find.bySemanticsLabel(RegExp('^Til')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'kartada til -> English');
    await w.snap('karta_en');
    // Pastki tabni qayta bosish — ildizga.
    await tester.tap(find.text(_l(tester).navHome).last);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'Home tab qayta bosildi');
    await w.snap('home_root');
  });

  testWidgets('profil: har bir qator', (tester) async {
    final s = await start(tester, role: AppRole.lab);
    final w = Walk(tester, 'qa_profile');
    const sc = 'profile';
    await goTo(tester, '/tests/analyte/potassium');
    await goTo(tester, '/library/sources');
    await goTo(tester, '/home');
    await tester.tap(find.byTooltip(_l(tester).actionProfile).first);
    await tester.pumpAndSettle();
    await w.snap('profil');
    await w.scroll(900);
    await w.snap('profil_past');
    await w.scroll(-2000);
    final l = _l(tester);

    Future<void> row(String title, String snap) async {
      await _reveal(tester, find.text(title));
      await tester.tap(find.text(title).hitTestable().first);
      await tester.pumpAndSettle();
      _rec(tester, sc, 'row "$title"');
      await w.snap(snap);
      final back = find.byTooltip(_l(tester).actionBack).hitTestable();
      if (back.evaluate().isNotEmpty) {
        await tester.tap(back.first);
        await tester.pumpAndSettle();
        _rec(tester, sc, '   back');
      }
      if (!_loc(tester).startsWith('/profile')) {
        await tester.tap(find.byTooltip(_l(tester).actionProfile).first);
        await tester.pumpAndSettle();
      }
    }

    await row(l.profileSignIn, 'kirish');
    await row(l.libPacks, 'paketlar');
    await row(l.profilePurchase, 'xarid');
    await row(l.supportTitle, 'yordam');
    await row(l.partnerBecome, 'hamkor');
    await row(l.profilePrivacy, 'maxfiylik');

    // Rol: talabaga almashtirish → bosh sahifa o'zgaradi.
    await _top(tester);
    await _reveal(tester, find.text(l.profileRole));
    await tester.tap(find.text(l.profileRole).first);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'row "${l.profileRole}"');
    await w.snap('rol');
    await tester.tap(find.text(l.roleStudent).first);
    await tester.pumpAndSettle();
    await _reveal(tester, find.text(l.actionContinue));
    await tester.tap(find.text(l.actionContinue).hitTestable().first);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'rol -> talaba, davom');
    _log.writeln('$sc | role now ${s.settings.effectiveRole}');
    // Til chiplari.
    await tester.tap(find.text('Русский').first);
    await tester.pumpAndSettle();
    await w.snap('til_ru');
    await tester.tap(find.text('O‘zbekcha').first);
    await tester.pumpAndSettle();
    // Mavzu.
    await tester.tap(find.text(_l(tester).themeDark).first);
    await tester.pumpAndSettle();
    await w.snap('qorongi');
    await tester.tap(find.text(_l(tester).themeLight).first);
    await tester.pumpAndSettle();
    _log.writeln('$sc | theme now ${s.settings.themeMode}');

    // Maxfiylik → shartlar, lokal o'chirish (bekor, so'ng tasdiq).
    await _reveal(tester, find.text(l.profilePrivacy));
    await tester.tap(find.text(l.profilePrivacy).hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.privacyTerms).first);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'privacy -> terms');
    await w.snap('shartlar');
    await tester.tap(find.byTooltip(l.actionBack).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.privacyDeleteLocal).first);
    await tester.pumpAndSettle();
    await w.snap('ochirish_dialog');
    await tester.tap(find.text(l.actionCancel).last);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'delete local -> cancel');
    await tester.tap(find.text(l.privacyDeleteLocal).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.actionDelete).last);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'delete local -> delete');
    _log.writeln(
      '$sc | after delete: onboarded=${s.settings.onboarded} '
      'role=${s.settings.role} lang=${s.settings.language}',
    );
    await w.snap('ochirildi');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    _rec(tester, sc, 'after delete settle');
    await w.snap('ochirildi_keyin');
  });

  testWidgets('profil: sozlashni boshidan', (tester) async {
    await start(tester, role: AppRole.doctor);
    final w = Walk(tester, 'qa_restart');
    const sc = 'restart';
    await goTo(tester, '/profile');
    final l = _l(tester);
    await _reveal(tester, find.text(l.profileRestartSetup));
    await tester.tap(find.text(l.profileRestartSetup).hitTestable().first);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'restart setup');
    await w.snap('welcome');
  });

  testWidgets('kirish: mehmon va email oqimi', (tester) async {
    final s = await makeServices(tester, onboarded: false, role: null);
    await pumpApp(tester, s);
    final w = Walk(tester, 'qa_welcome');
    const sc = 'welcome';
    _rec(tester, sc, 'start');
    await w.snap('welcome');
    await w.scroll(600);
    await w.snap('welcome_past');
    final l = _l(tester);
    await w.tapText(l.welcomeSignIn);
    _rec(tester, sc, 'tap Kirish');
    await w.snap('email');
    await tester.tap(find.byTooltip(l.actionBack).first);
    await tester.pumpAndSettle();
    _rec(tester, sc, '   back');
    await w.tapText(l.welcomeGetStarted);
    _rec(tester, sc, 'tap Boshlash');
    // Bo'sh holda kod olish — xatolar.
    await w.tapText(l.authGetCode);
    await w.snap('email_xato');
    await w.tapText(l.authViewTerms);
    _rec(tester, sc, 'tap shartlar');
    await tester.tap(find.byTooltip(l.actionBack).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'qa@example.com');
    await w.tapText(l.authConsent);
    await w.tapText(l.authGetCode);
    _rec(tester, sc, 'kod olish');
    await w.snap('otp');
    await tester.enterText(find.byType(TextField).first, '000000');
    await tester.pumpAndSettle();
    await w.snap('otp_xato');
    final code = s.auth.lastRequest?.debugCode ?? '';
    await tester.enterText(find.byType(TextField).first, code);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'otp to‘g‘ri');
    await w.snap('rol');
    await w.tapText(l.roleTeacher);
    await w.tapText(l.actionContinue);
    _rec(tester, sc, 'rol -> davom');
    await w.snap('bosh');
    await goTo(tester, '/profile');
    await w.snap('profil_hisob');
    await _reveal(tester, find.text(l.profileSignOut));
    await tester.tap(find.text(l.profileSignOut).hitTestable().first);
    await tester.pumpAndSettle();
    await w.snap('chiqish_dialog');
    await tester.tap(find.text(l.profileSignOut).last);
    await tester.pumpAndSettle();
    _rec(tester, sc, 'chiqish (saqlab)');
    await w.snap('chiqdi');
    // Mehmon.
    await w.tapText(l.welcomeGuest);
    _rec(tester, sc, 'mehmon');
    await w.tapText(l.actionContinue);
    _rec(tester, sc, 'mehmon rol -> davom');
    await w.snap('mehmon_bosh');
  });
}
