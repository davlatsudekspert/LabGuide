import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/core/backend/backend_models.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/fake_backend.dart';
import '../helpers/harness.dart';

final uz = lookupAppLocalizations(const Locale('uz'));
const _topic = 'd003-L';

class _Backend extends FakeLabBackend {
  bool offline = false;

  @override
  Future<List<StudyGroup>> myGroups() async {
    if (offline) throw const BackendException(BackendFailure.network);
    return super.myGroups();
  }
}

Future<void> _signIn(WidgetTester tester, AppServices s, String email) async {
  await s.auth.signOut();
  await s.auth.requestCode(email);
  await s.auth.verifyCode(FakeLabBackend.otpCode);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('mavzu sahifasi: hisob almashsa oldingi hisob ma’lumoti '
      'ko‘rinib qolmaydi; internet yo‘q — qayta urinish', (tester) async {
    final b = _Backend();
    final s = await makeServices(tester, backend: b, role: AppRole.teacher);
    await pumpApp(tester, s, size: const Size(390, 1600));
    await _signIn(tester, s, 'teacher@example.com');
    await b.registerTeacher();
    final g = await b.createGroup('KLD-1');
    final path = '/learn/classes/g/${g.id}/t/$_topic';

    // Ustoz: mavzu boshqaruvi (guruh kodi bilan bog‘liq ma’lumot).
    await goTo(tester, path);
    expect(find.text(uz.classroomOpenTopic), findsOneWidget);

    // Shu sahifa ochiq turib boshqa (a’zo bo‘lmagan) hisob kiradi:
    // ustoz tugmasi qolmaydi, “guruh topilmadi” chiqadi.
    await _signIn(tester, s, 'stranger@example.com');
    expect(find.text(uz.classroomOpenTopic), findsNothing);
    expect(find.text(uz.classesGroupMissing), findsOneWidget);

    // Ustoz qaytib kirsa — yana o‘z ma’lumoti.
    await _signIn(tester, s, 'teacher@example.com');
    expect(find.text(uz.classesGroupMissing), findsNothing);
    expect(find.text(uz.classroomOpenTopic), findsOneWidget);

    // Internet yo‘q: xato holat va “Qayta urinish”.
    b.offline = true;
    await goTo(tester, '/learn/classes');
    await goTo(tester, path);
    expect(find.text(uz.actionRetry), findsOneWidget);
    expect(find.text(uz.classroomOpenTopic), findsNothing);
    b.offline = false;
    await tester.tap(find.text(uz.actionRetry));
    await tester.pumpAndSettle();
    expect(find.text(uz.classroomOpenTopic), findsOneWidget);
  });

  testWidgets('qo‘shilish ekrani ochiq turganda yangi QR/havola kodi maydonni '
      'to‘ldiradi', (tester) async {
    final b = _Backend();
    final s = await makeServices(tester, backend: b);
    await pumpApp(tester, s);
    await _signIn(tester, s, 'student@example.com');
    String field() => tester
        .widget<EditableText>(find.byType(EditableText).first)
        .controller
        .text;
    await goTo(tester, '/learn/classes/join?code=ABCD2345');
    expect(field(), 'ABCD2345');
    await goTo(tester, '/learn/classes/join?code=PVK4D2RW');
    expect(field(), 'PVK4D2RW');
  });
}
