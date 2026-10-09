import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/differential/diff_eyes_free.dart';
import 'package:labguide/features/differential/diff_voice.dart';

/// Ijro etilgan tovushlarni yozib boradi.
class RecordingCuePlayer implements CuePlayer {
  final cues = <Cue>[];

  @override
  Future<void> play(Cue cue) async => cues.add(cue);

  @override
  Future<void> dispose() async {}
}

class RecordingScreenAwake implements ScreenAwake {
  final calls = <bool>[];

  @override
  Future<void> set({required bool on}) async => calls.add(on);
}

/// Tebranish chaqiruvlari: 'light', 'medium', 'heavy', 'selection', 'long'.
List<String> recordHaptics(WidgetTester? tester) {
  final out = <String>[];
  final messenger = tester?.binding.defaultBinaryMessenger ??
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
    if (call.method == 'HapticFeedback.vibrate') {
      out.add(switch (call.arguments) {
        'HapticFeedbackType.lightImpact' => 'light',
        'HapticFeedbackType.mediumImpact' => 'medium',
        'HapticFeedbackType.heavyImpact' => 'heavy',
        'HapticFeedbackType.selectionClick' => 'selection',
        _ => 'long',
      });
    }
    return null;
  });
  return out;
}

/// Qurilma qismlarini soxtasi bilan almashtiradi (test oxirida tiklanadi).
({RecordingCuePlayer cues, RecordingScreenAwake awake}) installDiffFakes({
  SpeechEngine? engine,
}) {
  final cues = RecordingCuePlayer();
  final awake = RecordingScreenAwake();
  final oldPlayer = DiffDevice.cuePlayer;
  final oldAwake = DiffDevice.screenAwake;
  final oldWait = DiffDevice.wait;
  final oldEngine = DiffVoiceDevice.engine;
  DiffDevice.cuePlayer = () => cues;
  DiffDevice.screenAwake = awake;
  DiffDevice.wait = (_) async {};
  if (engine != null) DiffVoiceDevice.engine = () => engine;
  addTearDown(() {
    DiffDevice.cuePlayer = oldPlayer;
    DiffDevice.screenAwake = oldAwake;
    DiffDevice.wait = oldWait;
    DiffVoiceDevice.engine = oldEngine;
  });
  return (cues: cues, awake: awake);
}

/// Boshqariladigan soxta nutq dvigateli.
class FakeSpeechEngine implements SpeechEngine {
  FakeSpeechEngine({
    this.initResult = VoiceInit.ready,
    this.locales = const ['ru-RU', 'en-US'],
    this.listenError,
    this.onDevice = true,
  });

  VoiceInit initResult;
  List<String> locales;
  PlatformException? listenError;
  final bool onDevice;

  VoiceErrorCallback? onError;
  void Function(String)? onStatus;
  void Function(String, bool)? _onResult;
  String? listenedLocale;
  int listens = 0;
  int stops = 0;

  @override
  bool get onDeviceGuaranteed => onDevice;

  @override
  Future<VoiceInit> init({
    required VoiceErrorCallback onError,
    required void Function(String status) onStatus,
  }) async {
    this.onError = onError;
    this.onStatus = onStatus;
    return initResult;
  }

  @override
  Future<List<String>> localeIds() async => locales;

  @override
  Future<void> listen({
    required String localeId,
    required void Function(String words, bool isFinal) onResult,
  }) async {
    listens++;
    if (listenError != null) throw listenError!;
    listenedLocale = localeId;
    _onResult = onResult;
  }

  @override
  Future<void> stop() async => stops++;

  /// Foydalanuvchi gapirdi (yakuniy natija).
  void say(String words) => _onResult?.call(words, true);
}
