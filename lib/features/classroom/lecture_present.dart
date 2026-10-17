import 'dart:async';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/storage/kv_store.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import 'lecture_canvas.dart';
import 'lecture_slide.dart';

// Ma'ruza pleyerining taqdimot qismlari (D-59): ekran holati tanlovi
// (gorizontal/aylantirmaslik, qurilmada eslab qolinadi), to'liq ekran
// (immersive) kirish/chiqish, "Ekranga uzatish" (tizimning ekranni
// takrorlash funksiyasi), slayd manbalari oynasi va taqdimotchi ko'rinishi.

/// Taqdimot boshlanganda ekran holati.
enum LectureOrientation {
  /// Har safar so'raladi (standart).
  ask,

  /// Doim gorizontal (albom).
  landscape,

  /// Aylantirilmaydi — joriy holatda.
  keep,
}

abstract final class LecturePresentation {
  static LectureOrientation read(KeyValueStore store) =>
      switch (store.getString(StoreKeys.lectureOrientation)) {
        'landscape' => LectureOrientation.landscape,
        'keep' => LectureOrientation.keep,
        _ => LectureOrientation.ask,
      };

  static Future<void> write(KeyValueStore store, LectureOrientation o) =>
      o == LectureOrientation.ask
      ? store.remove(StoreKeys.lectureOrientation)
      : store.setString(StoreKeys.lectureOrientation, o.name);

  /// To'liq ekran: tizim panellari yashiriladi; [landscape] — gorizontal
  /// holatga majburlash.
  static Future<void> enter({required bool landscape}) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (landscape) {
      await SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  /// Chiqish: ekran holati ilova standartiga (cheklovsiz — qurilma o'zi
  /// tikka qaytadi) va tizim panellari qaytariladi.
  static Future<void> exit() async {
    await SystemChrome.setPreferredOrientations(const []);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// Android: tizimning "Ekranni uzatish" (Cast/Miracast) sozlamasini ochadi.
  /// Ochilmasa (yoki iOS) — false. Testda almashtiriladi.
  static Future<bool> Function() openCastSettings = _openCastSettings;
}

Future<bool> _openCastSettings() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    await const AndroidIntent(
      action: 'android.settings.CAST_SETTINGS',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    ).launch();
    return true;
  } on Object {
    return false;
  }
}

/// "Gorizontal holatga aylantiraymizmi?" — null: bekor qilindi.
Future<({bool landscape, bool remember})?> askLandscape(
  BuildContext context, {
  bool cast = false,
}) {
  final l = AppLocalizations.of(context);
  var remember = false;
  return showDialog<({bool landscape, bool remember})>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        key: const ValueKey('lecture-rotate-dialog'),
        icon: const Icon(Icons.screen_rotation_rounded),
        title: Text(l.lectureRotateTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(cast ? l.lectureRotateCastBody : l.lectureRotateBody),
              const SizedBox(height: 8),
              CheckboxListTile(
                key: const ValueKey('lecture-rotate-remember'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: remember,
                title: Text(l.lectureRotateRemember),
                onChanged: (v) => setState(() => remember = v ?? false),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const ValueKey('lecture-rotate-no'),
            onPressed: () =>
                Navigator.pop(context, (landscape: false, remember: remember)),
            child: Text(l.lectureRotateNo),
          ),
          FilledButton(
            key: const ValueKey('lecture-rotate-yes'),
            autofocus: true,
            onPressed: () =>
                Navigator.pop(context, (landscape: true, remember: remember)),
            child: Text(l.lectureRotateYes),
          ),
        ],
      ),
    ),
  );
}

/// "Ekranga uzatish": tizimning ekranni takrorlash funksiyasi bo'yicha qisqa
/// yo'riqnoma; Android'da sozlamani ochish tugmasi. [onStart] — taqdimotni
/// boshlash (oyna yopilgach).
Future<void> showCastSheet(BuildContext context, VoidCallback onStart) {
  final l = AppLocalizations.of(context);
  final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  var failed = false;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final text = Theme.of(context).textTheme;
        return SafeArea(
          child: SingleChildScrollView(
            key: const ValueKey('lecture-cast-sheet'),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.lectureCastTitle, style: text.titleLarge),
                const SizedBox(height: 10),
                Text(l.lectureCastHow, style: text.bodyMedium),
                const SizedBox(height: 14),
                LgPanel(
                  soft: true,
                  child: Text(
                    android ? l.lectureCastStepsAndroid : l.lectureCastStepsIos,
                    key: const ValueKey('lecture-cast-steps'),
                    style: text.bodyMedium!.copyWith(height: 1.45),
                  ),
                ),
                if (failed) ...[
                  const SizedBox(height: 10),
                  LgNotice(l.lectureCastSettingsFailed, kind: NoticeKind.info),
                ],
                const SizedBox(height: 16),
                if (android) ...[
                  LgButton.secondary(
                    key: const ValueKey('lecture-cast-settings'),
                    label: l.lectureCastOpenSettings,
                    icon: Icons.cast_rounded,
                    onPressed: () async {
                      final ok = await LecturePresentation.openCastSettings();
                      if (!ok && context.mounted) {
                        setState(() => failed = true);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                LgButton(
                  key: const ValueKey('lecture-cast-start'),
                  label: l.lectureCastStart,
                  icon: Icons.slideshow_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                    onStart();
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Slayd manbalari: to'liq yozuvlar (muallif, nom, nashr, bo'lim/sahifa) —
/// hech narsa kesilmaydi.
Future<void> showSlideSources(BuildContext context, LectureSlide slide) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scroll) {
        final p = LgPalette.of(context);
        final text = Theme.of(context).textTheme;
        return SelectionArea(
          child: ListView(
            key: const ValueKey('lecture-source-sheet'),
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Semantics(
                header: true,
                child: Text(l.lectureSourcesTitle, style: text.titleLarge),
              ),
              const SizedBox(height: 4),
              Text(slide.title, style: text.bodyMedium!.copyWith(color: p.sub)),
              const SizedBox(height: 14),
              if (slide.refs.isEmpty && slide.source != null)
                Text(
                  slide.source!,
                  key: const ValueKey('lecture-source-ref-0'),
                  style: text.bodyLarge,
                ),
              for (final (k, r) in slide.refs.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(minWidth: 32),
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: p.soft,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${r.number}',
                          style: text.labelLarge!.copyWith(color: p.brand),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.text,
                              key: ValueKey('lecture-source-ref-$k'),
                              style: text.bodyLarge!.copyWith(height: 1.4),
                            ),
                            for (final loc in r.locators)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  l.lectureSourceLocator(loc),
                                  style: text.bodyMedium!.copyWith(
                                    color: p.brand,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (slide.refs.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  l.lectureSourcesHint,
                  style: text.bodySmall!.copyWith(color: p.sub),
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
}

/// Slayd ostidagi ixcham manba qatori: bosilsa — to'liq ro'yxat.
class SlideSourceTile extends StatelessWidget {
  const SlideSourceTile({super.key, required this.slide});

  final LectureSlide slide;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final count = slide.refs.length;
    final line = slide.source ?? (count > 0 ? slide.refs.first.text : '');
    return Semantics(
      button: true,
      label: l.lectureSourcesOpen,
      child: LgPressable(
        key: const ValueKey('lecture-source'),
        onTap: () => unawaited(showSlideSources(context, slide)),
        borderRadius: BorderRadius.circular(LgRadius.chip),
        color: p.paper,
        border: Border.all(color: p.line),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            children: [
              Icon(Icons.menu_book_outlined, size: 20, color: p.brand),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (count > 0)
                      Text(
                        l.lectureSourcesCount(count),
                        style: text.labelMedium!.copyWith(color: p.brand),
                      ),
                    ExcludeSemantics(
                      child: Text(
                        line,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall!.copyWith(color: p.sub),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.sub),
            ],
          ),
        ),
      ),
    );
  }
}

/// Taqdimotchi ko'rinishi (shu qurilmada): joriy slayd, keyingi slayd,
/// hisoblagich, vaqt, ustoz izohi va katta oldinga/orqaga tugmalari.
class PresenterView extends StatefulWidget {
  const PresenterView({
    super.key,
    required this.slides,
    required this.index,
    required this.deckTitle,
    required this.answerShown,
    required this.onGo,
    required this.onExit,
    required this.onToggleAnswer,
  });

  final List<LectureSlide> slides;
  final int index;
  final String? deckTitle;
  final bool answerShown;
  final void Function(int delta) onGo;
  final VoidCallback onExit;
  final VoidCallback onToggleAnswer;

  @override
  State<PresenterView> createState() => _PresenterViewState();
}

class _PresenterViewState extends State<PresenterView> {
  final _watch = Stopwatch()..start();
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _clock() {
    final s = _watch.elapsed.inSeconds;
    final h = s ~/ 3600;
    final m = (s ~/ 60) % 60;
    final ss = (s % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$ss' : '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final n = widget.slides.length;
    final i = widget.index;
    final slide = widget.slides[i];
    final next = i + 1 < n ? widget.slides[i + 1] : null;
    final current = SlideCanvas(
      key: ValueKey('lecture-canvas-$i'),
      slide: slide,
      number: i + 1,
      total: n,
      deckTitle: widget.deckTitle,
      answerShown: widget.answerShown,
    );
    Widget card(Widget child) => DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: p.shadow.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(14), child: child),
    );
    final side = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  l.lectureCounter(i + 1, n),
                  style: text.headlineSmall,
                ),
              ),
            ),
            Icon(Icons.timer_outlined, color: p.sub, size: 20),
            const SizedBox(width: 4),
            Text(
              _clock(),
              key: const ValueKey('lecture-presenter-timer'),
              semanticsLabel: '${l.lecturePresenterTimer}: ${_clock()}',
              style: text.titleMedium!.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            IconButton(
              tooltip: l.lecturePresenterReset,
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: () => setState(() {
                _watch
                  ..reset()
                  ..start();
              }),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(l.lecturePresenterNext, style: text.labelLarge),
        const SizedBox(height: 6),
        if (next != null)
          card(
            SlideCanvas(
              key: const ValueKey('lecture-presenter-next'),
              slide: next,
              number: i + 2,
              total: n,
              deckTitle: widget.deckTitle,
            ),
          )
        else
          LgPanel(soft: true, child: Text(l.lecturePresenterLast)),
        if (slide.template == SlideTemplate.qa) ...[
          const SizedBox(height: 10),
          LgButton.secondary(
            key: const ValueKey('lecture-answer'),
            label: widget.answerShown
                ? l.autoPresHideAnswer
                : l.autoPresShowAnswer,
            icon: widget.answerShown
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            onPressed: widget.onToggleAnswer,
          ),
        ],
        if (slide.teacherNote != null) ...[
          const SizedBox(height: 10),
          LgPanel(
            soft: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.lectureTeacherNote,
                  style: text.labelLarge!.copyWith(color: p.brand),
                ),
                const SizedBox(height: 4),
                Text(
                  slide.teacherNote!,
                  key: const ValueKey('lecture-teacher-note'),
                  style: text.bodyMedium,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Text(
          l.lecturePresenterNote,
          style: text.bodySmall!.copyWith(color: p.sub),
        ),
      ],
    );
    final buttons = Row(
      children: [
        Expanded(
          child: LgButton.secondary(
            label: l.lecturePrev,
            icon: Icons.chevron_left_rounded,
            onPressed: i == 0 ? null : () => widget.onGo(-1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LgButton(
            label: l.lectureNext,
            icon: Icons.chevron_right_rounded,
            onPressed: next == null ? null : () => widget.onGo(1),
          ),
        ),
      ],
    );
    return Scaffold(
      key: const ValueKey('lecture-presenter'),
      backgroundColor: p.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth > box.maxHeight && box.maxWidth >= 600;
            final close = Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                key: const ValueKey('lecture-presenter-exit'),
                tooltip: l.lectureFullscreenExit,
                icon: const Icon(Icons.close_rounded),
                onPressed: widget.onExit,
              ),
            );
            if (wide) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          close,
                          Expanded(child: Center(child: card(current))),
                          const SizedBox(height: 10),
                          buttons,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 8),
                        child: side,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: close,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        card(current),
                        const SizedBox(height: 12),
                        side,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: buttons,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
