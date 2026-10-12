// Promo roliklar uchun qo'shimcha kadrlar (haqiqiy ilova ekranlari).
//   flutter test tool/video/frames_promo_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';

import '../../test/helpers/harness.dart';
import 'common.dart';
import 'rec.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('promo talaba', (tester) async {
    await startCommunity(tester, role: AppRole.student);
    final r = Rec(tester, 'promo');
    await r.shot('home');
    await goTo(tester, '/learn');
    await r.shot('learn');
    await goTo(tester, '/learn/toifa/practice/hemostasis');
    await r.shot('toifa');
    await goTo(tester, '/tests/analyte/glucose-plasma-fasting');
    await r.shot('analyte');
    await goTo(tester, '/lab/microscopy');
    await r.shot('atlas');
    r.save();
  });
}
