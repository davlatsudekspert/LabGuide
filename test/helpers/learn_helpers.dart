import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/learn/exam_session.dart';
import 'package:material_ui/material_ui.dart';

/// Matnni topguncha pastga suradi (ro'yxat elementlari dangasa quriladi),
/// so'ng bosadi.
Future<void> tapScroll(WidgetTester tester, String text) async {
  final f = find.text(text);
  final scrollable = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .first;
  if (f.hitTestable().evaluate().isEmpty) {
    // Qurilgan va yuqorida qolgan bo'lsa — tepaga, aks holda avval pastga,
    // topilmasa tepaga suriladi.
    final above =
        f.evaluate().isNotEmpty && tester.getTopLeft(f.first).dy < 120;
    try {
      await tester.scrollUntilVisible(
        f.hitTestable(),
        above ? -250 : 250,
        scrollable: scrollable,
        maxScrolls: 40,
      );
    } on StateError {
      await tester.scrollUntilVisible(
        f.hitTestable(),
        above ? 250 : -250,
        scrollable: scrollable,
        maxScrolls: 40,
      );
    }
  }
  await tester.tap(f.hitTestable().last);
  await tester.pumpAndSettle();
}

/// Yorliq ostidagi matn maydoniga yozadi (LgField).
Future<void> enterField(WidgetTester tester, String label, String value) async {
  final field = find.descendant(
    of: find
        .ancestor(of: find.text(label).last, matching: find.byType(Column))
        .first,
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field.first);
  await tester.enterText(field.first, value);
  await tester.pumpAndSettle();
}

/// Joriy savolga to'g'ri yoki noto'g'ri javob (ekrandagi matn bo'yicha).
Future<void> answerCurrent(
  WidgetTester tester,
  AppServices s,
  ExamSession session, {
  required bool correct,
  String lang = 'uz',
}) async {
  final item = session.current;
  final q = PackQuestionSource.of(s.content.pack!).question(item.questionId)!;
  final idx = correct
      ? item.correct.single
      : item.order.firstWhere((o) => !item.correct.contains(o));
  await tapScroll(tester, q.option(idx, lang));
}
