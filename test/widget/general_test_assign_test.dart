// “Umumiy test berish”: ustoz guruh sahifasidan toifa mavzusi + ma'ruza
// moduli tanlaydi, 50 ta savol, 20 daqiqa, variantli rejim — yuboradi. Server
// (soxta) to'g'ri id, kalit, vaqt va per_student oladi; talaba ilovada
// yechadi; ustoz natijani ko'radi. Ikki ekran: 390×844 (iOS fizikasi) va
// 360×640 ×1.3.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/variant_draw.dart';
import 'package:labguide/design/widgets/lg_widgets.dart';
import 'package:labguide/features/classroom/general_test.dart';
import 'package:labguide/features/classroom/topic_questions.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = lookupAppLocalizations(const Locale('uz'));

const _toifaTopic = 'toifa:anemias';
const _module = 'M3';

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.scrollUntilVisible(
    f,
    200,
    scrollable: find.byType(Scrollable).hitTestable().first,
    maxScrolls: 80,
  );
  await tester.pumpAndSettle();
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _flow(
  WidgetTester tester, {
  required Size size,
  double textScale = 1,
}) async {
  final b = FakeLabBackend();
  final s = await makeServices(tester, backend: b, role: AppRole.teacher);
  await pumpApp(tester, s, size: size, textScale: textScale);
  await _signIn(tester, s, 'teacher@example.com');
  await b.registerTeacher();
  final g = await b.createGroup('Gematologiya 3-kurs');
  // Ikkinchi guruh — tanlanmagan bo'lsa, unga yuborilmaydi.
  final other = await b.createGroup('Biokimyo 2-kurs');

  // Kutilgan hovuz — haqiqiy asset'lardan.
  final pack = s.content.pack!;
  final bank = s.toifa.bank!;
  final catalog = GeneralCatalog.of(s.curriculum.curriculum, pack, bank);
  final m3 = catalog.modules.firstWhere((m) => m.id == _module);
  final selected = {_toifaTopic, for (final d in m3.days) d.key};
  final strata = catalog.strata(selected);
  expect(strata.map((x) => x.key), [_toifaTopic, 'mod:$_module']);
  final pool = generalPool(strata);
  expect(
    pool.length,
    greaterThanOrEqualTo(100),
    reason: '50 ta variantli test uchun hovuz ≥ 100',
  );
  final index = classQuestionIndex(pack, bank);

  // 1. Guruh sahifasi: “Mavzu testi berish” yonida “Umumiy test berish”.
  await goTo(tester, '/learn/classes/g/${g.id}');
  expect(find.text(uz.classesGiveTopicTest), findsOneWidget);
  await tapScroll(tester, uz.classesGiveGeneralTest);
  expect(find.text(uz.generalSourceToifa), findsOneWidget);
  expect(tester.takeException(), isNull);

  // 2. Qidiruv: “anemiya” — toifa mavzusi topiladi; tanlanadi.
  await tester.enterText(
    find.byKey(const ValueKey('general-search')),
    'anemiya',
  );
  await tester.pumpAndSettle();
  await _tapKey(tester, 'general-topic-$_toifaTopic');
  await tester.enterText(find.byKey(const ValueKey('general-search')), '');
  await tester.pumpAndSettle();
  // Ma'ruza moduli M3 — butunligicha.
  await _tapKey(tester, 'general-module-$_module');
  expect(
    find.text(uz.generalSelected(2, pool.length), skipOffstage: false),
    findsOneWidget,
  );
  // Standart sarlavha tanlovdan.
  final title = tester
      .widget<TextField>(
        find.descendant(
          of: find.byKey(const ValueKey('general-title')),
          matching: find.byType(TextField),
        ),
      )
      .controller!
      .text;
  expect(title, startsWith(uz.generalTestTitle('')));
  expect(title, contains('${uz.generalSourceToifaShort} · '));
  expect(title, contains('${uz.generalSourceLectureShort} · $_module'));

  // 3. 50 ta (standart ham 50), 20 daqiqa, variant yoqiq.
  Future<void> preset(String label) async {
    final chip = find.descendant(
      of: find.byKey(const ValueKey('general-count')),
      matching: find.byWidgetPredicate(
        (w) => w is LgChoiceChip && w.label == label,
      ),
    );
    await tester.ensureVisible(chip);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pumpAndSettle();
  }

  await preset('20');
  expect(find.text(uz.variantOnBody(100, 20)), findsOneWidget);
  await preset('50');
  await _tapKey(tester, 'assign-limit-20');
  final toggle = tester.widget<SwitchListTile>(
    find.byKey(const ValueKey('assign-variant')),
  );
  expect(toggle.value, isTrue);
  expect(find.text(uz.variantOnBody(100, 50)), findsOneWidget);
  // Faqat shu guruh tanlangan (guruh sahifasidan kelindi).
  expect(
    tester
        .widget<LgChoiceChip>(find.byKey(ValueKey('assign-group-${g.id}')))
        .selected,
    isTrue,
  );
  expect(tester.takeException(), isNull);
  await _tapKey(tester, 'assign-send');
  expect(tester.takeException(), isNull);

  // 4. Server: hovuz 100 (takrorsiz, ikkala mavzudan teng), kalitlar,
  // vaqt, per_student.
  expect(await b.assignments(other.id), isEmpty);
  final a = (await b.assignments(g.id)).single;
  expect(a.title, title);
  expect(a.timeLimitMinutes, 20);
  expect(a.perStudent, 50);
  expect(a.isVariant, isTrue);
  expect(a.questionCount, 50);
  expect(a.questionIds, hasLength(kVariantPoolServerMax));
  expect(a.questionIds.toSet(), hasLength(a.questionIds.length));
  final poolIds = {for (final q in pool) q.id};
  expect(poolIds.containsAll(a.questionIds), isTrue);
  final key = await b.assignmentKey(a.id);
  for (final (i, id) in a.questionIds.indexed) {
    final q = index[id];
    expect(q, isNotNull, reason: id);
    expect(key[i], q!.correct.single, reason: id);
  }
  expect(a.poolTopics, hasLength(a.questionIds.length));
  final perTopic = <String?, int>{};
  for (final t in a.poolTopics!) {
    perTopic[t] = (perTopic[t] ?? 0) + 1;
  }
  final first = strata.first.questions.length;
  expect(perTopic.keys.toSet(), {_toifaTopic, 'mod:$_module'});
  expect(perTopic[_toifaTopic], first < 50 ? first : 50);

  // Guruh sahifasiga qaytildi: topshiriq ro'yxatda.
  expect(find.text(title), findsWidgets);

  // 5. Talaba qo'shilib, ilovada yechadi (hammasi to'g'ri).
  await _signIn(tester, s, 'student@example.com');
  await b.joinGroup(g.joinCode!);
  await s.settings.setRole(AppRole.student);
  await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
  await tapScroll(tester, uz.classesStart);
  expect(tester.takeException(), isNull);
  final run = s.exams.assignmentSession(a.id, b.userId)!;
  final mine = a.questionIdsFor(b.userId);
  expect(run.length, 50);
  expect({for (final i in run.items) i.questionId}, mine.toSet());
  for (final item in run.items) {
    // Rasmiy (toifa) savolda variantlar tartibi o'zgarmaydi.
    if (index[item.questionId] is OfficialKeyQuestion) {
      expect(item.order, [for (var k = 0; k < item.order.length; k++) k]);
    }
  }
  final source = ClassQuestionSource.of(pack, bank);
  for (var i = 0; i < run.length; i++) {
    final item = run.current;
    final q = source.question(item.questionId)!;
    await tapScroll(tester, q.option(item.correct.single, 'uz'));
    if (i < run.length - 1) await tapScroll(tester, uz.examNext);
  }
  await tapScroll(tester, uz.examFinish);
  await tester.tap(find.text(uz.examFinish).hitTestable().last);
  await tester.pumpAndSettle();
  final sub = (await b.submissions(a.id)).single;
  expect((sub.score, sub.total), (50, 50));
  expect(sub.questionIds, mine);
  expect(tester.takeException(), isNull);

  // 6. Ustoz natijani ko'radi.
  await _signIn(tester, s, 'teacher@example.com');
  await s.settings.setRole(AppRole.teacher);
  await goTo(tester, '/learn/classes/g/${g.id}');
  expect(find.text(uz.classesSubmittedOf(1, 1)), findsOneWidget);
  await goTo(tester, '/learn/classes/g/${g.id}/a/${a.id}');
  expect(find.text('100%'), findsWidgets);
  expect(find.byKey(const ValueKey('assignment-variant')), findsOneWidget);
  expect(tester.takeException(), isNull);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets(
    'umumiy test: toifa + modul, 50 ta, 20 daqiqa, variant — 390×844 iOS',
    (tester) => _flow(tester, size: const Size(390, 844)),
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'umumiy test: toifa + modul, 50 ta, 20 daqiqa, variant — 360×640 ×1.3',
    (tester) => _flow(tester, size: const Size(360, 640), textScale: 1.3),
  );

  testWidgets('O‘rganish → ustozga “Umumiy test berish”; guruh tanlanadi', (
    tester,
  ) async {
    final b = FakeLabBackend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: const Size(390, 844));
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g1 = await b.createGroup('Guruh A');
    final g2 = await b.createGroup('Guruh B');
    await goTo(tester, '/learn');
    await tapScroll(tester, uz.classesGiveGeneralTest);
    // Ikki guruh — hech biri oldindan tanlanmagan; tanlanmasa yuborilmaydi.
    for (final g in [g1, g2]) {
      expect(
        tester
            .widget<LgChoiceChip>(find.byKey(ValueKey('assign-group-${g.id}')))
            .selected,
        isFalse,
      );
    }
    // “Hammasini tanlash” — analizlar bo'yicha; kam son, variantsiz.
    await _tapKey(tester, 'general-all-pack');
    await enterField(tester, uz.examCount, '12');
    await _tapKey(tester, 'assign-variant');
    await _tapKey(tester, 'assign-send');
    expect(find.text(uz.topicTestPickGroup), findsOneWidget);
    expect(await b.assignments(g1.id), isEmpty);
    await _tapKey(tester, 'assign-group-${g2.id}');
    await _tapKey(tester, 'assign-send');
    expect(await b.assignments(g1.id), isEmpty);
    final a = (await b.assignments(g2.id)).single;
    expect(a.isVariant, isFalse);
    expect(a.questionIds, hasLength(12));
    expect(a.timeLimitMinutes, 15, reason: '12 savol — ≈ 1 daqiqadan');
    expect(a.title, startsWith(uz.generalTestTitle(uz.generalSourcePackShort)));

    // Guruhlar ro'yxatida ham kirish bor.
    await goTo(tester, '/learn/classes');
    expect(
      find.byKey(const ValueKey('classes-general-test'), skipOffstage: false),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('talabaga O‘rganishda “Umumiy test berish” yo‘q', (tester) async {
    final s = await makeServices(tester, role: AppRole.student);
    await pumpApp(tester, s);
    await goTo(tester, '/learn');
    expect(find.byKey(const ValueKey('learn-general-test')), findsNothing);
  });
}
