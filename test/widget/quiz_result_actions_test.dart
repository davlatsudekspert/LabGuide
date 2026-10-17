// Viktorina natijasi: "xatolarni qayta ishlash" va qayta boshlash tugmalari
// xatolar ro'yxatidan OLDIN turadi (uzun ro'yxatni aylantirmaslik uchun) va
// faqat xato javob berilgan savollarni qayta beradi.
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/l10n/gen/app_localizations_uz.dart';

import '../helpers/harness.dart';
import '../helpers/learn_helpers.dart';

final uz = AppLocalizationsUz();

Future<void> _pick(WidgetTester tester) async {
  final f = find.byWidgetPredicate(
    (w) => w.runtimeType.toString() == 'QuizOptionButton',
  );
  await tester.ensureVisible(f.first);
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('natija: xatolarni qayta ishlash tugmasi ro‘yxatdan yuqorida', (
    tester,
  ) async {
    final s = await makeServices(tester);
    await pumpApp(tester, s);
    await goTo(tester, '/learn/quiz');
    await tapScroll(tester, uz.quizTopicMixed(10));
    for (var i = 0; i < 10; i++) {
      await _pick(tester);
      await tapScroll(tester, i == 9 ? uz.quizFinish : uz.quizNext);
    }
    expect(find.text(uz.quizDoneTitle), findsOneWidget);
    final wrong = s.quizProgress.mistakes([
      for (final q in s.content.pack!.quiz) q.id,
    ]).length;
    expect(wrong, greaterThan(0));
    final retry = find.text(uz.examReworkMistakes(wrong));
    expect(retry, findsOneWidget);
    // Tugma "Xatolar" sarlavhasidan yuqorida.
    expect(
      tester.getTopLeft(retry).dy,
      lessThan(tester.getTopLeft(find.text(uz.quizMistakes)).dy),
    );
    await tester.tap(retry);
    await tester.pumpAndSettle();
    expect(find.text(uz.quizProgress(1, wrong).toUpperCase()), findsOneWidget);
  });
}
