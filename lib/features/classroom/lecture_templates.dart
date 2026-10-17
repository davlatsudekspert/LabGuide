import 'package:material_ui/material_ui.dart';

import '../../design/tokens.dart';
import '../../l10n/gen/app_localizations.dart';
import 'lecture_slide.dart';

// Slayd shablonlari (jadval, rasm, savol-javob, sarlavha): hammasi ilova
// ichida chiziladi. [base] — asosiy shrift o'lchami (ekranga qarab:
// telefondan 1920×1080 televizorgacha); matn o'ramaydigan qattiq kenglik yo'q,
// shuning uchun 320 px va 1.3× shriftda ham kesilmaydi.

/// Asosiy shrift: kenglik/balandlikka moslanadi. Televizorda (1920×1080)
/// telefondagidan ancha katta.
double slideBaseFont(double width, double height) {
  final byWidth = width / 22;
  final byHeight = height.isFinite ? height / 19 : byWidth;
  return (byWidth < byHeight ? byWidth : byHeight).clamp(16.0, 44.0);
}

/// Sarlavha shabloni: katta nom, ostida qisqa qatorlar.
class SlideTitleBody extends StatelessWidget {
  const SlideTitleBody({super.key, required this.slide, required this.base});

  final LectureSlide slide;
  final double base;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in slide.bullets)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              b,
              style: text.bodyLarge!.copyWith(
                fontSize: base * 0.95,
                height: 1.3,
                color: p.sub,
              ),
            ),
          ),
      ],
    );
  }
}

/// Jadval shabloni. Keng ekranda haqiqiy jadval; tor ekranda (< 520 px)
/// har qator alohida kartochka: birinchi ustun sarlavha, qolganlari ostida.
class SlideTableBody extends StatelessWidget {
  const SlideTableBody({
    super.key,
    required this.slide,
    required this.base,
    required this.width,
  });

  final LectureSlide slide;
  final double base;
  final double width;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final rows = slide.tableRows;
    final header = slide.tableHeader;
    final cols = rows.fold<int>(
      header.length,
      (m, r) => r.length > m ? r.length : m,
    );
    Widget swatch(int r) {
      final colors = r < slide.rowSwatches.length
          ? slide.rowSwatches[r]
          : const <Color>[];
      if (colors.isEmpty) return const SizedBox.shrink();
      return ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final c in colors)
                Container(
                  width: base * 0.8,
                  height: base * 0.8,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.line),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Tor ekranda (kartochkalar) matn kattaroq: tik joy yetarli; keng
    // ekranda (televizor) jadval bir ekranga sig'ishi uchun ixchamroq.
    final narrow = width < 520 || cols == 0;
    final cell = text.bodyLarge!.copyWith(
      fontSize: base * (narrow ? 0.9 : (cols >= 3 ? 0.62 : 0.75)),
      height: 1.3,
      color: p.ink,
    );
    final head = text.labelLarge!.copyWith(
      fontSize: base * (narrow ? 0.7 : 0.55),
      color: p.brand,
    );
    if (narrow) {
      // Tor ekran: kartochkalar.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (r, row) in rows.indexed)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.soft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Semantics(
                container: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (c, v) in row.indexed)
                      if (v.trim().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: c == 0 ? 0 : 6),
                          child: c == 0
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    swatch(r),
                                    Expanded(
                                      child: Text(
                                        v,
                                        style: cell.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (c < header.length &&
                                        header[c].isNotEmpty)
                                      Text(header[c], style: head),
                                    Text(v, style: cell),
                                  ],
                                ),
                        ),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    return Table(
      columnWidths: {
        for (var c = 0; c < cols; c++)
          c: FlexColumnWidth(c == cols - 1 && cols > 2 ? 1.4 : 1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      border: TableBorder(
        horizontalInside: BorderSide(color: p.line.withValues(alpha: 0.8)),
        bottom: BorderSide(color: p.line.withValues(alpha: 0.8)),
      ),
      children: [
        if (header.any((h) => h.isNotEmpty))
          TableRow(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: p.brand, width: 2)),
            ),
            children: [
              for (var c = 0; c < cols; c++)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 12, 8),
                  child: Text(c < header.length ? header[c] : '', style: head),
                ),
            ],
          ),
        for (final (r, row) in rows.indexed)
          TableRow(
            children: [
              for (var c = 0; c < cols; c++)
                Padding(
                  padding: EdgeInsets.fromLTRB(0, base * 0.3, 12, base * 0.3),
                  child: c == 0
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            swatch(r),
                            Expanded(
                              child: Text(
                                c < row.length ? row[c] : '',
                                style: cell.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(c < row.length ? row[c] : '', style: cell),
                ),
            ],
          ),
      ],
    );
  }
}

/// Rasm shabloni: atlas rasmi va izoh. Yotiq keng ekranda rasm chapda,
/// izoh o'ngda; aks holda rasm tepada.
class SlideFigureBody extends StatelessWidget {
  const SlideFigureBody({
    super.key,
    required this.slide,
    required this.base,
    required this.width,
    required this.height,
  });

  final LectureSlide slide;
  final double base;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final wide = width > height * 1.2 && width >= 720;
    final inner = width - (width * 0.06).clamp(16.0, 64.0) * 2;
    // Rasm kengligi: yotiqda ~55%, tikda butun kenglik (tor ekranda ham
    // sig'adi). Balandlik televizorda ekrandan oshmasin.
    final imgW = wide ? inner * 0.55 : inner;
    final maxH = height.isFinite ? height * (wide ? 0.58 : 0.4) : 360.0;
    final image = Semantics(
      image: true,
      label: [slide.title, ?slide.figureCaption].join('. '),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          slide.figure!,
          width: imgW,
          height: maxH,
          fit: BoxFit.contain,
          alignment: wide ? Alignment.centerLeft : Alignment.center,
          excludeFromSemantics: true,
        ),
      ),
    );
    final caption = slide.figureCaption == null
        ? null
        : Text(
            slide.figureCaption!,
            style: text.bodyLarge!.copyWith(
              fontSize: base * 0.85,
              height: 1.35,
              color: p.ink,
            ),
          );
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image,
          SizedBox(width: base),
          if (caption != null) Expanded(child: caption),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: image),
        if (caption != null) ...[const SizedBox(height: 12), caption],
      ],
    );
  }
}

/// Savol-javob shabloni: variantlar; javob tugma (yoki Enter) bilan ochiladi.
class SlideQaBody extends StatelessWidget {
  const SlideQaBody({
    super.key,
    required this.slide,
    required this.base,
    required this.answerShown,
    required this.onToggleAnswer,
  });

  final LectureSlide slide;
  final double base;
  final bool answerShown;
  final VoidCallback onToggleAnswer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, o) in slide.options.indexed)
          Builder(
            builder: (context) {
              final correct = answerShown && i == slide.correctIndex;
              return Semantics(
                container: true,
                label: [
                  '${letters[i % letters.length]}. $o',
                  if (correct) l.autoPresAnswerLabel,
                ].join(', '),
                child: ExcludeSemantics(
                  child: Container(
                    key: ValueKey('qa-option-$i'),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(
                      horizontal: base * 0.6,
                      vertical: base * 0.3,
                    ),
                    decoration: BoxDecoration(
                      color: correct ? p.soft : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: correct ? p.brand : p.line,
                        width: correct ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${letters[i % letters.length]}.  ',
                          style: text.titleSmall!.copyWith(
                            fontSize: base * 0.8,
                            color: p.brand,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            o,
                            style: text.bodyLarge!.copyWith(
                              fontSize: base * 0.8,
                              height: 1.3,
                              color: p.ink,
                            ),
                          ),
                        ),
                        if (correct) ...[
                          SizedBox(width: base * 0.4),
                          Icon(
                            Icons.check_circle_rounded,
                            color: p.brand,
                            size: base,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const ValueKey('lecture-answer'),
            onPressed: onToggleAnswer,
            icon: Icon(
              answerShown
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            label: Text(
              answerShown ? l.autoPresHideAnswer : l.autoPresShowAnswer,
            ),
          ),
        ),
        if (answerShown && slide.answerExplanation != null) ...[
          const SizedBox(height: 12),
          Text(
            slide.answerExplanation!,
            key: const ValueKey('lecture-answer-text'),
            style: text.bodyLarge!.copyWith(
              fontSize: base * 0.78,
              height: 1.35,
              color: p.ink,
            ),
          ),
        ],
      ],
    );
  }
}
