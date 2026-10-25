// “Qanday foydalaniladi?” oynasidagi video tugmasi — SOXTA ro‘yxat bilan
// (haqiqiy manzil yo‘q; ilova bilan keladigan videos.json bo‘sh):
// uz yorug‘ 390, ru tungi 320, en planshet 820. Har birida: tugma (hajm
// bilan) va internet yo‘q holatidagi xabar.
//
//   flock /tmp/flutter_test.lock flutter test \
//     tool/screenshots/walk_howto_video_test.dart --update-goldens
// Rasmlar: tool/screenshots/out/walk/howto_video_<til>/ (gitignore).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:labguide/features/howto/howto_videos.dart';
import 'package:labguide/features/howto/howto_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _host = 'https://videos.labguide-test.uz/howto/v1';

HowToVideoCatalog _fake() => HowToVideoCatalog.parse(
  jsonEncode({
    'schema_version': 1,
    'owner_approval': 'D-99',
    'videos': [
      for (final (l, b) in [('uz', 1280244), ('ru', 1324342), ('en', 1208864)])
        {
          'section': 'qc',
          'lang': l,
          'url': '$_host/02_sifat_nazorati_$l.aced2cdf.mp4',
          'bytes': b,
          'seconds': 46.0,
          'sha256': 'ab' * 32,
        },
      for (final (l, b) in [('uz', 1815480), ('ru', 1804643), ('en', 1780274)])
        {
          'section': 'cytology',
          'lang': l,
          'url': '$_host/10_boshqa_funksiyalar_$l.806f0f7b.mp4',
          'bytes': b,
          'seconds': 56.0,
          'sha256': 'cd' * 32,
          'start_seconds': 18.0,
        },
    ],
  }),
);

final _offline = MockClient(
  (_) async => throw const SocketException('Failed host lookup'),
);

Future<void> _scenario(
  WidgetTester tester, {
  required AppLanguage lang,
  required ThemeMode theme,
  required Size size,
}) async {
  final w = Walk(tester, 'howto_video_${lang.name}');
  final s = await start(tester, lang: lang, theme: theme, size: size);
  s.howToVideos.debugUse(catalog: _fake(), client: _offline);
  for (final (sec, route) in [('qc', '/lab/qc'), ('cytology', '/lab/cytology')]) {
    await goTo(tester, route);
    await w.tap(find.byKey(ValueKey('howto-$sec')));
    final video = find.byKey(ValueKey('howto-video-$sec'));
    await tester.ensureVisible(video);
    await w.snap('${sec}_button');
    await w.tap(video);
    await tester.ensureVisible(find.byKey(const ValueKey('howto-video-offline')));
    await w.snap('${sec}_offline');
    await w.tap(
      find.descendant(
        of: find.byType(HowToSheet),
        matching: find.text(lookupAppLocalizations(lang.locale).actionClose),
      ),
    );
  }
  expect(tester.takeException(), isNull);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('uz, yorug‘, 390', (tester) async {
    await _scenario(
      tester,
      lang: AppLanguage.uz,
      theme: ThemeMode.light,
      size: const Size(390, 844),
    );
  });

  testWidgets('ru, tungi, 320', (tester) async {
    await _scenario(
      tester,
      lang: AppLanguage.ru,
      theme: ThemeMode.dark,
      size: const Size(320, 640),
    );
  });

  testWidgets('en, planshet, 820', (tester) async {
    await _scenario(
      tester,
      lang: AppLanguage.en,
      theme: ThemeMode.light,
      size: const Size(820, 1180),
    );
  });
}
