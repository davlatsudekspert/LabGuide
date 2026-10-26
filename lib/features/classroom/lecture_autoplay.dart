import 'package:material_ui/material_ui.dart';

import '../../core/storage/kv_store.dart';
import '../../l10n/gen/app_localizations.dart';

// Ma'ruza pleyeri: «Avto / Qo'lda» varaqlash rejimi. Bu yerda — qurilmada
// eslab qolinadigan tanlov va yuqoridagi boshqaruv tugmalari; taymer va
// holat mantig'i pleyerning o'zida (lecture_screens.dart).

/// Avto varaqlash tanlovi (qurilmada saqlanadi).
abstract final class LectureAutoPrefs {
  /// Tanlanadigan tezliklar (soniya).
  static const speeds = [15, 30, 60];

  /// Standart tezlik (soniya).
  static const defaultSeconds = 30;

  /// Rejim: standart — qo'lda (hozirgi xatti-harakat o'zgarmaydi).
  static bool readAuto(KeyValueStore store) =>
      store.getString(StoreKeys.lectureAutoMode) == 'auto';

  static int readSeconds(KeyValueStore store) {
    final v = int.tryParse(store.getString(StoreKeys.lectureAutoSeconds) ?? '');
    return v != null && speeds.contains(v) ? v : defaultSeconds;
  }

  static Future<void> writeAuto(KeyValueStore store, {required bool on}) => on
      ? store.setString(StoreKeys.lectureAutoMode, 'auto')
      : store.remove(StoreKeys.lectureAutoMode);

  static Future<void> writeSeconds(KeyValueStore store, int seconds) =>
      seconds == defaultSeconds
      ? store.remove(StoreKeys.lectureAutoSeconds)
      : store.setString(StoreKeys.lectureAutoSeconds, '$seconds');
}

/// Yuqoridagi boshqaruv: «Avto / Qo'lda» tugmasi; Avto yoqilganda — tezlik
/// tanlovi (15 / 30 / 60 soniya) va pauza/davom etish. Hamma tugma >= 48 dp,
/// o'rama (Wrap) — tor ekranda va katta shriftda qatorga tushadi.
///
/// [compact] — tezlik faqat belgi (yotiq / to'liq ekran); [onDark] — qora
/// fon ustidagi (to'liq ekran) ranglar.
class LectureAutoBar extends StatelessWidget {
  const LectureAutoBar({
    super.key,
    required this.auto,
    required this.paused,
    required this.seconds,
    required this.onToggle,
    required this.onSeconds,
    required this.onPauseToggle,
    this.compact = false,
    this.onDark = false,
  });

  final bool auto;
  final bool paused;
  final int seconds;
  final VoidCallback onToggle;
  final ValueChanged<int> onSeconds;
  final VoidCallback onPauseToggle;
  final bool compact;
  final bool onDark;

  static const _target = Size(48, 48);

  ButtonStyle get _style => onDark
      ? ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(_target),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          backgroundColor: WidgetStatePropertyAll(
            Colors.black.withValues(alpha: 0.45),
          ),
          side: const WidgetStatePropertyAll(BorderSide.none),
        )
      : const ButtonStyle(minimumSize: WidgetStatePropertyAll(_target));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mode = auto ? l.lectureAutoModeAuto : l.lectureAutoModeManual;
    final secondsText = l.lectureAutoSeconds(seconds);
    final speedTitle = '${l.lectureAutoSpeedTitle}: $secondsText';
    final label = Text(mode);
    final icon = Icon(
      auto ? Icons.play_circle_outline_rounded : Icons.touch_app_outlined,
    );
    final toggle = Semantics(
      button: true,
      toggled: auto,
      label: '${l.lectureAutoToggleLabel}: $mode',
      onTap: onToggle,
      excludeSemantics: true,
      child: auto
          ? FilledButton.tonalIcon(
              key: const ValueKey('lecture-auto-toggle'),
              style: _style,
              onPressed: onToggle,
              icon: icon,
              label: label,
            )
          : OutlinedButton.icon(
              key: const ValueKey('lecture-auto-toggle'),
              style: _style,
              onPressed: onToggle,
              icon: icon,
              label: label,
            ),
    );
    final speed = PopupMenuButton<int>(
      key: const ValueKey('lecture-auto-speed'),
      tooltip: speedTitle,
      onSelected: onSeconds,
      constraints: const BoxConstraints(minWidth: 48),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        child: Center(
          widthFactor: 1,
          child: Semantics(
            label: speedTitle,
            button: true,
            excludeSemantics: true,
            child: compact
                ? Icon(
                    Icons.timer_outlined,
                    color: onDark ? Colors.white : null,
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          secondsText,
                          key: const ValueKey('lecture-auto-speed-text'),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
          ),
        ),
      ),
      itemBuilder: (context) => [
        for (final s in LectureAutoPrefs.speeds)
          CheckedPopupMenuItem<int>(
            key: ValueKey('lecture-auto-speed-$s'),
            value: s,
            checked: s == seconds,
            child: Text(l.lectureAutoSeconds(s)),
          ),
      ],
    );
    final pause = paused
        // Pauza belgisi: yozuv ko'rinadi, bosilsa davom etadi.
        ? Semantics(
            button: true,
            label: l.lectureAutoPause,
            hint: l.lectureAutoResume,
            onTap: onPauseToggle,
            excludeSemantics: true,
            child: Tooltip(
              message: l.lectureAutoResume,
              child: FilledButton.tonalIcon(
                key: const ValueKey('lecture-auto-resume'),
                style: _style,
                onPressed: onPauseToggle,
                icon: const Icon(Icons.pause_circle_outline_rounded),
                label: Text(l.lectureAutoPause),
              ),
            ),
          )
        : IconButton(
            key: const ValueKey('lecture-auto-pause'),
            tooltip: l.lectureAutoPause,
            style: _style,
            onPressed: onPauseToggle,
            icon: const Icon(Icons.pause_rounded),
          );
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [toggle, if (auto) speed, if (auto) pause],
    );
  }
}
