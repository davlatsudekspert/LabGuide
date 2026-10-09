import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/differential/diff_eyes_free.dart';
import 'package:labguide/features/differential/diff_eyes_free_settings.dart';
import 'package:labguide/features/differential/diff_voice.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/differential/differential_controller.dart';

import '../helpers/diff_device_fakes.dart';

List<String> _cmds(String text) => [
  for (final c in parseVoiceCommands(text)) c.toString(),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Sozlamalar', () {
    test('JSON orqali saqlanadi; buzilgan tartib tiklanadi', () async {
      final store = MemoryKeyValueStore();
      final c = DifferentialController(store);
      expect(c.eyesFree.zones, hasLength(7));
      await c.setEyesFree(
        c.eyesFree.copyWith(
          leftHanded: true,
          includeOther: false,
          keepAwake: true,
          voiceLanguage: VoiceLanguage.ru,
          order: [DiffCell.lymphocyte, DiffCell.lymphocyte, DiffCell.band],
        ),
      );
      final again = DifferentialController(store).eyesFree;
      expect(again.leftHanded, isTrue);
      expect(again.keepAwake, isTrue);
      expect(again.voiceLanguage, VoiceLanguage.ru);
      expect(again.zones, hasLength(6));
      expect(again.zones.take(2), [DiffCell.lymphocyte, DiffCell.band]);
      expect(again.order.toSet(), DiffCell.values.toSet());
      expect(decodeEyesFree('{buzuq').zones, hasLength(7));
    });

    test('lokal ma\'lumot o\'chirilganda standart holatga qaytadi', () async {
      final c = DifferentialController(MemoryKeyValueStore());
      await c.setEyesFree(c.eyesFree.copyWith(sound: false));
      c.resetInMemory();
      expect(c.eyesFree.sound, isTrue);
    });
  });

  group('Zonalar joylashuvi', () {
    test('o\'ng qo\'l: 1-zona pastda o\'ngda; toq zona tepada to\'liq', () {
      final zones = const EyesFreeSettings().zones;
      final slots = layoutZones(zones, leftHanded: false);
      expect(zoneRows(7), 4);
      expect(slots.first.row, 3);
      expect(slots.first.col, 1);
      expect(slots[1].col, 0);
      expect(slots.last.row, 0);
      expect(slots.last.span, 2);
      // Har katak bitta zonaga tegishli.
      final cells = <String>{};
      for (final s in slots) {
        for (var col = s.col; col < s.col + s.span; col++) {
          expect(cells.add('${s.row}:$col'), isTrue);
        }
      }
      expect(cells, hasLength(8));
    });

    test('landshaft: 4 ustun, 2 qator, bo\'sh katak yo\'q', () {
      final zones = const EyesFreeSettings().zones;
      final slots = layoutZones(zones, leftHanded: false, columns: 4);
      expect(zoneRows(7, 4), 2);
      expect(slots.first.row, 1);
      expect(slots.first.col, 3);
      expect(slots.last.row, 0);
      expect(slots.last.span, 2);
      expect(slots.last.col, 0);
      final used = slots.fold(0, (a, s) => a + s.span);
      expect(used, 8);
    });

    test('chap qo\'l — ko\'zgudagidek; 6 zona — 3 qator', () {
      final zones = const EyesFreeSettings(includeOther: false).zones;
      final slots = layoutZones(zones, leftHanded: true);
      expect(slots, hasLength(6));
      expect(slots.first.col, 0);
      expect(slots.map((s) => s.row).toSet(), {0, 1, 2});
      expect(slots.every((s) => s.span == 1), isTrue);
    });
  });

  group('Ovozli buyruqlar parseri', () {
    test('o\'zbekcha (lotin va kirill)', () {
      expect(_cmds('neytrofil'), ['segmented']);
      expect(_cmds('Limfotsit, limfotsit'), ['lymphocyte', 'lymphocyte']);
      expect(_cmds('monotsit eozinofil bazofil'), [
        'monocyte',
        'eosinophil',
        'basophil',
      ]);
      expect(_cmds('tayoqcha'), ['band']);
      expect(_cmds('tayoqcha yadroli neytrofil'), ['band']);
      expect(_cmds('segment yadroli neytrofil'), ['segmented']);
      expect(_cmds('bekor'), ['undo']);
      expect(_cmds('Bekor qilish'), ['undo']);
      expect(_cmds('limfosit'), ['lymphocyte']);
      expect(_cmds('boshqa'), ['other']);
      expect(_cmds('нейтрофил таёқча бекор'), ['segmented', 'band', 'undo']);
    });

    test('ruscha (kelishiklar bilan)', () {
      expect(_cmds('Нейтрофил'), ['segmented']);
      expect(_cmds('лимфоцит лимфоцита'), ['lymphocyte', 'lymphocyte']);
      expect(_cmds('моноцит, эозинофил. Базофил'), [
        'monocyte',
        'eosinophil',
        'basophil',
      ]);
      expect(_cmds('палочка'), ['band']);
      expect(_cmds('палочкоядерный нейтрофил'), ['band']);
      expect(_cmds('сегментоядерный нейтрофил'), ['segmented']);
      expect(_cmds('отмена'), ['undo']);
      expect(_cmds('отменить'), ['undo']);
      expect(_cmds('бласт'), ['other']);
    });

    test('inglizcha', () {
      expect(_cmds('Neutrophil'), ['segmented']);
      expect(_cmds('lymphocyte lymph'), ['lymphocyte', 'lymphocyte']);
      expect(_cmds('monocyte eosinophil basophil'), [
        'monocyte',
        'eosinophil',
        'basophil',
      ]);
      expect(_cmds('band neutrophil'), ['band']);
      expect(_cmds('band'), ['band']);
      expect(_cmds('undo'), ['undo']);
      expect(_cmds('mono eos baso seg'), [
        'monocyte',
        'eosinophil',
        'basophil',
        'segmented',
      ]);
    });

    test('ortiqcha so\'zlar e\'tiborsiz; bo\'sh matn — buyruq yo\'q', () {
      expect(_cmds(''), isEmpty);
      expect(_cmds('salom dunyo'), isEmpty);
      expect(_cmds('monogram'), isEmpty);
      expect(_cmds('ну лимфоцит наверное'), ['lymphocyte']);
      // Ikki alohida neytrofil.
      expect(_cmds('neytrofil neytrofil'), ['segmented', 'segmented']);
      // Orada boshqa buyruq bo'lsa — neytrofil alohida sanaladi.
      expect(_cmds('tayoqcha limfotsit neytrofil'), [
        'band',
        'lymphocyte',
        'segmented',
      ]);
    });
  });

  group('Tanish tili', () {
    test('avtomatik: ilova tili, yo\'q bo\'lsa rus, keyin ingliz', () {
      expect(
        pickVoiceLocale(['en-US', 'uz-UZ', 'ru-RU'], VoiceLanguage.auto, 'uz'),
        (localeId: 'uz-UZ', lang: 'uz'),
      );
      expect(
        pickVoiceLocale(['en-US', 'ru-RU'], VoiceLanguage.auto, 'uz'),
        (localeId: 'ru-RU', lang: 'ru'),
      );
      expect(
        pickVoiceLocale(['en_GB', 'en_US'], VoiceLanguage.auto, 'uz'),
        (localeId: 'en_US', lang: 'en'),
      );
      expect(pickVoiceLocale(['de-DE'], VoiceLanguage.auto, 'uz'), isNull);
      expect(pickVoiceLocale(['ru-RU'], VoiceLanguage.uz, 'ru'), isNull);
      expect(
        pickVoiceLocale(['ru-KZ'], VoiceLanguage.ru, 'en'),
        (localeId: 'ru-KZ', lang: 'ru'),
      );
    });
  });

  group('Ovozli seans', () {
    Future<VoiceCounter> started(
      FakeSpeechEngine engine,
      List<VoiceCommand> got, {
      String appLang = 'uz',
    }) async {
      final v = VoiceCounter(engine: engine, restartDelay: Duration.zero);
      await v.start(
        pref: VoiceLanguage.auto,
        appLang: appLang,
        onCommand: got.add,
      );
      return v;
    }

    test('buyruqlar uzatiladi; o\'zbek tili yo\'q — rus tili', () async {
      final engine = FakeSpeechEngine();
      final got = <VoiceCommand>[];
      final v = await started(engine, got);
      expect(v.state, VoiceState.listening);
      expect(v.lang, 'ru');
      expect(engine.listenedLocale, 'ru-RU');
      engine.say('лимфоцит лимфоцит отмена');
      expect(got, [
        const VoiceCommand.count(DiffCell.lymphocyte),
        const VoiceCommand.count(DiffCell.lymphocyte),
        const VoiceCommand.undo(),
      ]);
      expect(v.lastMatched, 3);
      engine.say('что-то другое');
      expect(v.lastMatched, 0);
      await v.stop();
      expect(v.state, VoiceState.off);
    });

    test('ruxsat rad etildi', () async {
      final engine = FakeSpeechEngine(initResult: VoiceInit.permissionDenied);
      final v = await started(engine, []);
      expect(v.state, VoiceState.permissionDenied);
      expect(v.active, isFalse);
      expect(engine.listens, 0);
    });

    test('mos til yo\'q', () async {
      final engine = FakeSpeechEngine(locales: ['de-DE']);
      final v = await started(engine, []);
      expect(v.state, VoiceState.languageUnavailable);
    });

    test('qurilmada tanish yo\'q (iOS) — serverga o\'tilmaydi', () async {
      final engine = FakeSpeechEngine(
        listenError: PlatformException(code: 'onDeviceError'),
      );
      final v = await started(engine, []);
      expect(v.state, VoiceState.onDeviceUnavailable);
      expect(engine.listens, 1);
    });

    test('jimlik — qayta tinglanadi; ruxsat xatosi — to\'xtaydi', () async {
      final engine = FakeSpeechEngine();
      final v = await started(engine, []);
      engine.onError!('error_speech_timeout', false);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(engine.listens, 2);
      expect(v.state, VoiceState.listening);
      engine.onError!('error_permission', true);
      expect(v.state, VoiceState.permissionDenied);
    });
  });

  group('Tebranish va tovush', () {
    late List<String> haptics;
    late RecordingCuePlayer cues;

    setUp(() {
      haptics = recordHaptics(null);
      cues = RecordingCuePlayer();
      DiffDevice.wait = (_) async {};
    });

    tearDown(() => DiffDevice.wait = Future<void>.delayed);

    test('har tur o\'z naqshi bilan; har 10 da qo\'shimcha signal', () async {
      final f = EyesFreeFeedback(player: cues);
      await f.counted(DiffCell.band, TapOutcome.added, 3);
      expect(haptics, ['medium', 'medium']);
      expect(cues.cues, [Cue.tap]);
      haptics.clear();
      await f.counted(DiffCell.segmented, TapOutcome.added, 10);
      expect(haptics, ['light', 'long']);
      expect(cues.cues.last, Cue.ten);
      haptics.clear();
      await f.counted(DiffCell.monocyte, TapOutcome.completed, 100);
      expect(haptics, ['heavy', 'heavy', 'heavy', 'long']);
      expect(cues.cues.last, Cue.done);
      haptics.clear();
      await f.undone();
      expect(haptics, ['heavy', 'selection']);
      expect(cues.cues.last, Cue.undo);
    });

    test('naqshlar bir-biridan farq qiladi', () {
      final patterns = cellPatterns.values
          .map((p) => p.map((e) => e.name).join('-'))
          .toSet();
      expect(patterns, hasLength(DiffCell.values.length));
    });

    test('tovush va tebranish o\'chirilsa — hech narsa', () async {
      final f = EyesFreeFeedback(player: cues)
        ..sound = false
        ..haptics = false;
      await f.counted(DiffCell.band, TapOutcome.added, 1);
      await f.blocked();
      expect(haptics, isEmpty);
      expect(cues.cues, isEmpty);
    });
  });
}
