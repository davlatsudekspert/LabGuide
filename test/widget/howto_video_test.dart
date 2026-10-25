// “Qanday foydalaniladi?” oynasidagi video tugmasi (soxta ro‘yxat bilan):
// ilova bilan keladigan bo‘sh ro‘yxatda tugma yo‘q; uz/ru/en da o‘z tilidagi
// video hajmi bilan; boshqa tilga jim o‘tilmaydi; internet yo‘q / fayl yo‘q —
// halol xabar, matnli qadamlar joyida; 320 px va shrift ×2.0 (yorug‘/tungi)
// da toshmaydi.
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/howto/howto_registry.dart';
import 'package:labguide/features/howto/howto_videos.dart';
import 'package:labguide/features/howto/howto_widgets.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

const _host = 'https://videos.labguide-test.uz/howto/v1';
const _urlChannel = MethodChannel('plugins.flutter.io/url_launcher');

/// Bo‘lim → uning asosiy sahifasi.
const _hub = {
  HowToSection.qc: '/lab/qc',
  HowToSection.cytology: '/lab/cytology',
};

/// Soxta ro‘yxat: qc — uch til (hajmlar turlicha), cytology — umumiy
/// video ichida 18-soniyadan (faqat [cytologyLangs]).
HowToVideoCatalog _catalog({
  List<String> qcLangs = const ['uz', 'ru', 'en'],
  List<String> cytologyLangs = const ['uz', 'ru', 'en'],
}) {
  const bytes = {'uz': 1256116, 'ru': 1301088, 'en': 1188242};
  return HowToVideoCatalog.parse(
    jsonEncode({
      'schema_version': 1,
      'owner_approval': 'D-99',
      'videos': [
        for (final l in qcLangs)
          {
            'section': 'qc',
            'lang': l,
            'url': '$_host/02_sifat_nazorati_$l.0e953a65.mp4',
            'bytes': bytes[l],
            'seconds': 46.0,
            'sha256': 'ab' * 32,
          },
        for (final l in cytologyLangs)
          {
            'section': 'cytology',
            'lang': l,
            'url': '$_host/10_boshqa_funksiyalar_$l.40df0dc7.mp4',
            'bytes': 1810045,
            'seconds': 56.0,
            'sha256': 'cd' * 32,
            'start_seconds': 18.5,
          },
      ],
    }),
  );
}

/// Video hosting: HEAD so‘rovlariga javob (hajmi ro‘yxatdagidek).
http.Client _online(HowToVideoCatalog c, {List<String>? log}) =>
    MockClient((req) async {
      log?.add('${req.method} ${req.url}');
      for (final s in HowToSection.values) {
        for (final v in c.forSection(s).values) {
          if (v.url == req.url) {
            return http.Response('', 200, headers: {
              'content-length': '${v.bytes}',
            });
          }
        }
      }
      return http.Response('', 404);
    });

final _offline = MockClient(
  (_) async => throw const SocketException('Failed host lookup'),
);

/// Tashqi ilovada ochilgan havolalar (url_launcher kanali).
List<String> _fakeLauncher(WidgetTester tester) {
  final launched = <String>[];
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(_urlChannel, (call) async {
    if (call.method == 'launch') {
      launched.add((call.arguments as Map)['url'] as String);
      return true;
    }
    return false;
  });
  addTearDown(() => messenger.setMockMethodCallHandler(_urlChannel, null));
  return launched;
}

Future<AppServices> _start(
  WidgetTester tester, {
  AppLanguage lang = AppLanguage.uz,
  ThemeMode theme = ThemeMode.light,
  Size size = const Size(390, 844),
  double textScale = 1,
  HowToVideoCatalog? catalog,
  http.Client? client,
}) async {
  final s = await makeServices(tester, language: lang, themeMode: theme);
  s.howToVideos.debugUse(catalog: catalog, client: client);
  await pumpApp(tester, s, size: size, textScale: textScale);
  return s;
}

Future<void> _openHowTo(WidgetTester tester, HowToSection s) async {
  await goTo(tester, _hub[s]!);
  final key = find.byKey(ValueKey('howto-${s.id}'));
  await tester.ensureVisible(key);
  await tester.pumpAndSettle();
  await tester.tap(key);
  await tester.pumpAndSettle();
  expect(find.byType(HowToSheet), findsOneWidget);
}

Future<void> _tapVideo(WidgetTester tester, HowToSection s) async {
  final b = find.byKey(ValueKey('howto-video-${s.id}'));
  await tester.ensureVisible(b);
  await tester.pumpAndSettle();
  await tester.tap(b);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('ilova bilan keladigan ro‘yxat bo‘sh — 16 bo‘limda video '
      'tugmasi yo‘q', (tester) async {
    final s = await _start(tester);
    expect(s.howToVideos.catalog.isEmpty, isTrue);
    for (final sec in HowToSection.values) {
      final c = s.howToVideos.contentFor(sec);
      expect(c.videos, isEmpty, reason: sec.id);
    }
    final l = lookupAppLocalizations(const Locale('uz'));
    await _openHowTo(tester, HowToSection.qc);
    expect(find.byKey(const ValueKey('howto-video-qc')), findsNothing);
    expect(find.textContaining(l.howToWatchVideo), findsNothing);
    expect(find.text(l.howToVideoOffline), findsNothing);
  });

  const labels = {
    AppLanguage.uz: 'Videoni ko‘rish (1,3 MB)',
    AppLanguage.ru: 'Смотреть видео (1,3 МБ)',
    AppLanguage.en: 'Watch the video (1.2 MB)',
  };
  for (final lang in AppLanguage.values) {
    testWidgets('soxta ro‘yxat: o‘z tilidagi video, hajm bilan (${lang.name})',
        (tester) async {
      final launched = _fakeLauncher(tester);
      final c = _catalog();
      final requests = <String>[];
      await _start(
        tester,
        lang: lang,
        catalog: c,
        client: _online(c, log: requests),
      );
      final l = lookupAppLocalizations(lang.locale);
      await _openHowTo(tester, HowToSection.qc);
      expect(find.text(labels[lang]!), findsOneWidget);
      expect(find.text(l.howToVideoNote('0:46')), findsOneWidget);
      expect(find.byKey(const ValueKey('howto-video-start')), findsNothing);
      // Hech narsa bosilmaguncha tarmoqqa murojaat yo‘q.
      expect(requests, isEmpty);
      await _tapVideo(tester, HowToSection.qc);
      final url = '$_host/02_sifat_nazorati_${lang.name}.0e953a65.mp4';
      expect(requests, ['HEAD $url']);
      expect(launched, [url]);
      expect(find.text(l.howToVideoOffline), findsNothing);
      expect(find.text(l.howToVideoUnavailable), findsNothing);
    });
  }

  testWidgets('umumiy video: bo‘lim qayerdan boshlanishi ko‘rsatiladi', (
    tester,
  ) async {
    final c = _catalog();
    await _start(tester, lang: AppLanguage.ru, catalog: c, client: _online(c));
    final l = lookupAppLocalizations(const Locale('ru'));
    await _openHowTo(tester, HowToSection.cytology);
    expect(find.text('Смотреть видео (1,8 МБ)'), findsOneWidget);
    expect(find.text(l.howToVideoNote('0:56')), findsOneWidget);
    expect(find.text(l.howToVideoStartsAt('0:18')), findsOneWidget);
  });

  testWidgets('ilova tilida video yo‘q — boshqa tildagisi ko‘rsatilmaydi', (
    tester,
  ) async {
    final c = _catalog(qcLangs: ['uz'], cytologyLangs: ['en']);
    await _start(tester, lang: AppLanguage.ru, catalog: c, client: _online(c));
    final l = lookupAppLocalizations(const Locale('ru'));
    for (final sec in [HowToSection.qc, HowToSection.cytology]) {
      await _openHowTo(tester, sec);
      expect(find.byKey(ValueKey('howto-video-${sec.id}')), findsNothing);
      expect(find.textContaining(l.howToWatchVideo), findsNothing);
      await tester.tap(
        find.descendant(
          of: find.byType(HowToSheet),
          matching: find.text(l.actionClose),
        ),
      );
      await tester.pumpAndSettle();
    }
  });

  testWidgets('internet yo‘q — halol xabar, qadamlar joyida, hech narsa '
      'ochilmaydi', (tester) async {
    final launched = _fakeLauncher(tester);
    await _start(tester, catalog: _catalog(), client: _offline);
    final l = lookupAppLocalizations(const Locale('uz'));
    await _openHowTo(tester, HowToSection.qc);
    await _tapVideo(tester, HowToSection.qc);
    expect(find.text(l.howToVideoOffline), findsOneWidget);
    expect(launched, isEmpty);
    final c = HowToRegistry.of(HowToSection.qc);
    expect(find.text(c.steps.first(l)), findsOneWidget);
    expect(find.text(c.result(l)), findsOneWidget);
    // Tugma qayta bosiladigan holatda (internet qaytsa).
    final button = find.byKey(const ValueKey('howto-video-qc'));
    expect(button.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fayl joyida emas (404) — “hozir ochilmadi”, ochilmaydi', (
    tester,
  ) async {
    final launched = _fakeLauncher(tester);
    await _start(
      tester,
      lang: AppLanguage.en,
      catalog: _catalog(),
      client: MockClient((_) async => http.Response('', 404)),
    );
    final l = lookupAppLocalizations(const Locale('en'));
    await _openHowTo(tester, HowToSection.qc);
    await _tapVideo(tester, HowToSection.qc);
    expect(find.text(l.howToVideoUnavailable), findsOneWidget);
    expect(find.text(l.howToVideoOffline), findsNothing);
    expect(launched, isEmpty);
  });

  for (final theme in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('320 px, shrift ×2.0, ${theme.name}: video bloki toshmaydi', (
      tester,
    ) async {
      for (final lang in [AppLanguage.uz, AppLanguage.ru, AppLanguage.en]) {
        await _start(
          tester,
          lang: lang,
          theme: theme,
          size: const Size(320, 640),
          textScale: 2.0,
          catalog: _catalog(),
          client: _offline,
        );
        final l = lookupAppLocalizations(lang.locale);
        for (final sec in [HowToSection.qc, HowToSection.cytology]) {
          await _openHowTo(tester, sec);
          await _tapVideo(tester, sec);
          final notice = find.text(l.howToVideoOffline);
          await tester.ensureVisible(notice);
          await tester.pumpAndSettle();
          expect(notice.hitTestable(), findsOneWidget, reason: '$lang $sec');
          final note = find.text(l.howToVideoNote(sec == HowToSection.qc
              ? '0:46'
              : '0:56'));
          await tester.ensureVisible(note);
          await tester.pumpAndSettle();
          expect(note.hitTestable(), findsOneWidget, reason: '$lang $sec');
          final close = find.descendant(
            of: find.byType(HowToSheet),
            matching: find.text(l.actionClose),
          );
          await tester.ensureVisible(close);
          await tester.pumpAndSettle();
          await tester.tap(close);
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull, reason: lang.name);
      }
    });
  }

  test('hajm va vaqt formati', () {
    final uz = lookupAppLocalizations(const Locale('uz'));
    final ru = lookupAppLocalizations(const Locale('ru'));
    final en = lookupAppLocalizations(const Locale('en'));
    expect(formatVideoSize(uz, 1256116), '1,3 MB');
    expect(formatVideoSize(ru, 1801862), '1,8 МБ');
    expect(formatVideoSize(en, 926284), '0.9 MB');
    expect(formatVideoSize(en, 12), '0.1 MB');
    expect(formatVideoTime(45.5), '0:46');
    expect(formatVideoTime(64), '1:04');
    expect(formatVideoTime(18), '0:18');
  });
}
