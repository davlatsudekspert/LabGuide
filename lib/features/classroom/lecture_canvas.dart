import 'package:material_ui/material_ui.dart';

import '../../design/tokens.dart';
import 'lecture_slide.dart';

// 16:9 taqdimot kanvasi (D-59). Slayd 1280×720 dizayn o'lchamida chiziladi va
// ekranga TENG masshtablanadi (FittedBox): telefonda kichik karta, proyektorda
// butun ekran — matn nisbati bir xil, hech qachon kesilmaydi. Ko'rinish PPTX
// generatoridagi (tool/slides/make_topic_decks.py) bilan bir xil: eyebrow,
// katta sarlavha, belgili bandlar, manba qatori, "LabGuide · <deck>" footer
// va slayd raqami; ranglar — lib/design/tokens.dart (kunduzgi/tungi).
//
// O'lchamlar tool/slides/export_app_decks.py dagi byudjet bilan bir xil:
// eksport slaydni asosiy matn ≥ 26 px bo'ladigan qilib bo'ladi; ilova bu
// yerda haqiqiy o'lchab eng katta mos shriftni tanlaydi, baribir sig'masa
// (masalan, avtomatik taqdimot) — tana butunligicha kichraytiriladi.

/// Kanvas o'lchamlari (eksport byudjeti bilan bir xil).
abstract final class SlideCanvasMetrics {
  static const double width = 1280;
  static const double height = 720;
  static const double padX = 72;
  static const double contentW = width - 2 * padX;
  static const double topPad = 40;
  static const double eyebrowH = 40;
  static const double titleTop = 96;
  static const double titleGap = 24;
  static const double footerTop = 664;
  static const double footerH = 24;
  static const double sourceSize = 17;
  static const double bulletIndent = 30;
  static const double planIndent = 64;
  static const double figureImageW = 520;
  static const double figureGap = 40;
  static const double bodyLh = 1.35;
  static const double titleLh = 1.15;

  /// Asosiy matn: eng kattasidan boshlab tanlanadi (eksport 28 px da
  /// hisoblaydi, minimal o'qiladigan — 26 px).
  static const bodySizes = [34.0, 32.0, 30.0, 28.0, 26.0, 24.0, 22.0];
  static const titleSizes = [44.0, 40.0, 36.0, 32.0];
  static const questionSizes = [40.0, 36.0, 32.0, 28.0];
}

/// Kanvas ranglari: mavzuga (kunduzgi/tungi) qarab LgPalette'dan; sarlavha
/// slaydi — PPTX'dagi kabi chuqur yashil fon va lime aksent.
@immutable
class SlideColors {
  const SlideColors._(this.p, this.dark);

  factory SlideColors.of(BuildContext context) => SlideColors._(
    LgPalette.of(context),
    Theme.of(context).brightness == Brightness.dark,
  );

  final LgPalette p;
  final bool dark;

  Color get bg => p.bg;
  Color get paper => p.paper;
  Color get ink => p.ink;
  Color get sub => p.sub;
  Color get line => p.line;
  Color get brand => p.brand;
  Color get onBrand => p.onBrand;
  Color get soft => p.soft;

  /// Sarlavha slaydi foni (PPTX `DEEP`).
  Color get deep => dark ? const Color(0xFF081412) : const Color(0xFF122D2A);
  static const lime = Color(0xFFC8E27A);
  static const pale = Color(0xFFC9D8C2);
}

/// Bitta slayd — 16:9, ekranga teng masshtablangan.
class SlideCanvas extends StatelessWidget {
  const SlideCanvas({
    super.key,
    required this.slide,
    required this.number,
    required this.total,
    this.deckTitle,
    this.answerShown = false,
  });

  final LectureSlide slide;

  /// Slayd raqami (1 dan) va jami.
  final int number;
  final int total;

  /// Footer: `LabGuide · <deck>`.
  final String? deckTitle;

  /// Savol-javob: javob ochiqmi.
  final bool answerShown;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: FittedBox(
        child: SizedBox(
          width: SlideCanvasMetrics.width,
          height: SlideCanvasMetrics.height,
          // Kanvas — "rasm": tizim shrift masshtabi kanvasni emas, butun
          // slaydni kattalashtiradi (to'liq ekran rejimi). Panel matni esa
          // tizim masshtabiga bo'ysunadi.
          child: MediaQuery.withNoTextScaling(
            child: ClipRect(child: _frame(context)),
          ),
        ),
      ),
    );
  }

  Widget _frame(BuildContext context) {
    if (slide.image != null) return _PictureSlide(slide: slide);
    final c = SlideColors.of(context);
    if (slide.template == SlideTemplate.title || slide.section) {
      return _TitleSlide(slide: slide, number: number, total: total, colors: c);
    }
    return _ContentSlide(
      slide: slide,
      number: number,
      total: total,
      deckTitle: deckTitle,
      answerShown: answerShown,
      colors: c,
    );
  }
}

// ------------------------------------------------------------- o'lchash ---

TextStyle _base(BuildContext context) =>
    (Theme.of(context).textTheme.bodyLarge ?? const TextStyle()).copyWith(
      letterSpacing: 0,
      decoration: TextDecoration.none,
    );

double _spanHeight(InlineSpan span, double width) {
  final tp = TextPainter(
    text: span,
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout(maxWidth: width);
  final h = tp.height;
  tp.dispose();
  return h;
}

int _spanLines(InlineSpan span, double width) {
  final tp = TextPainter(
    text: span,
    textDirection: TextDirection.ltr,
    textScaler: TextScaler.noScaling,
  )..layout(maxWidth: width);
  final n = tp.computeLineMetrics().length;
  tp.dispose();
  return n;
}

/// Birinchi mos o'lcham (bo'lmasa — eng kichigi).
double _pick(List<double> sizes, bool Function(double) fits) {
  for (final s in sizes) {
    if (fits(s)) return s;
  }
  return sizes.last;
}

/// Sig'masa — butunligicha kichraytiradi (hech qachon kesmaydi, overflow yo'q).
class _Shrink extends StatelessWidget {
  const _Shrink({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.topLeft,
    child: SizedBox(width: width, child: child),
  );
}

/// "Yorliq: matn" bandi — yorliq qalin aksent rangida (kalit atama).
final _label = RegExp(r'^([^:.;!?\n]{2,48}): (.+)$', dotAll: true);

/// "3. Matn" — raqamli qadam.
final _numbered = RegExp(r'^(\d{1,2})\.\s+(.+)$', dotAll: true);

TextSpan _richItem(String text, TextStyle style, Color accent) {
  final m = _label.firstMatch(text);
  if (m == null) return TextSpan(text: text, style: style);
  return TextSpan(
    style: style,
    children: [
      TextSpan(
        text: '${m.group(1)}: ',
        style: style.copyWith(fontWeight: FontWeight.w700, color: accent),
      ),
      TextSpan(text: m.group(2)),
    ],
  );
}

// ------------------------------------------------------------ rasm slayd ---

class _PictureSlide extends StatelessWidget {
  const _PictureSlide({required this.slide});

  final LectureSlide slide;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: LgPalette.of(context).bg,
    child: Semantics(
      image: true,
      label: [slide.title, ...slide.bullets].join('. '),
      child: Image.asset(
        slide.image!,
        key: ValueKey(slide.image),
        width: SlideCanvasMetrics.width,
        height: SlideCanvasMetrics.height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
        gaplessPlayback: true,
      ),
    ),
  );
}

// -------------------------------------------------------- sarlavha slayd ---

class _TitleSlide extends StatelessWidget {
  const _TitleSlide({
    required this.slide,
    required this.number,
    required this.total,
    required this.colors,
  });

  final LectureSlide slide;
  final int number;
  final int total;
  final SlideColors colors;

  @override
  Widget build(BuildContext context) {
    final base = _base(context);
    const w = SlideCanvasMetrics.contentW - 120;
    final titleStyle = base.copyWith(
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: SlideCanvasMetrics.titleLh,
    );
    final size = _pick(
      [60, 54, 48, 44, 40, 36],
      (s) =>
          _spanLines(
            TextSpan(
              text: slide.title,
              style: titleStyle.copyWith(fontSize: s),
            ),
            w,
          ) <=
          3,
    );
    return ColoredBox(
      color: colors.deep,
      child: Stack(
        children: [
          // Aksent shakllar (bezak; mazmun emas).
          Positioned(
            right: -160,
            top: -200,
            child: _circle(560, SlideColors.lime.withValues(alpha: 0.10)),
          ),
          Positioned(
            right: 120,
            bottom: -120,
            child: _circle(260, SlideColors.lime.withValues(alpha: 0.06)),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 14, color: SlideColors.lime),
          ),
          Positioned(
            left: SlideCanvasMetrics.padX,
            top: 120,
            right: SlideCanvasMetrics.padX + 120,
            bottom: 110,
            child: LayoutBuilder(
              builder: (context, box) => _Shrink(
                width: box.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 96, height: 8, color: SlideColors.lime),
                    const SizedBox(height: 22),
                    if (slide.eyebrow case final e? when e != slide.title) ...[
                      Text(
                        e,
                        style: base.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: SlideColors.lime,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    Semantics(
                      header: true,
                      child: Text(
                        slide.title,
                        style: titleStyle.copyWith(fontSize: size),
                      ),
                    ),
                    const SizedBox(height: 30),
                    for (final (i, b) in slide.bullets.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          b,
                          style: base.copyWith(
                            fontSize: i == 0 ? 28 : 24,
                            height: 1.3,
                            color: SlideColors.pale,
                            fontWeight: i == 0 ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                    if (slide.note != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        slide.note!,
                        style: base.copyWith(
                          fontSize: 20,
                          color: SlideColors.pale,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: SlideCanvasMetrics.padX,
            right: SlideCanvasMetrics.padX,
            top: SlideCanvasMetrics.footerTop - 8,
            child: _Footer(
              label: 'LabGuide',
              number: number,
              total: total,
              color: SlideColors.pale,
              strong: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circle(double d, Color c) => Container(
    width: d,
    height: d,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}

// ------------------------------------------------------------- footer ---

class _Footer extends StatelessWidget {
  const _Footer({
    required this.label,
    required this.number,
    required this.total,
    required this.color,
    required this.strong,
  });

  final String label;
  final int number;
  final int total;
  final Color color;
  final Color strong;

  @override
  Widget build(BuildContext context) {
    final base = _base(context)
        .copyWith(fontSize: 16, color: color, height: 1.2);
    // RichText: slayd raqami pleyerdagi hisoblagich bilan aralashmasin
    // (ekran o'quvchi uchun hisoblagich — panelda).
    return ExcludeSemantics(
      child: SizedBox(
        height: SlideCanvasMetrics.footerH + 8,
        child: Row(
          children: [
            Image.asset(
              'assets/images/logo_mark.png',
              width: 26,
              height: 26,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: TextScaler.noScaling,
                text: TextSpan(
                  style: base,
                  children: [
                    TextSpan(
                      text: 'LabGuide',
                      style: base.copyWith(
                        fontWeight: FontWeight.w700,
                        color: strong,
                      ),
                    ),
                    if (label != 'LabGuide') TextSpan(text: '  ·  $label'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            RichText(
              textScaler: TextScaler.noScaling,
              text: TextSpan(
                style: base.copyWith(fontWeight: FontWeight.w600),
                text: '$number / $total',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------- kontent slayd ---

class _ContentSlide extends StatelessWidget {
  const _ContentSlide({
    required this.slide,
    required this.number,
    required this.total,
    required this.deckTitle,
    required this.answerShown,
    required this.colors,
  });

  final LectureSlide slide;
  final int number;
  final int total;
  final String? deckTitle;
  final bool answerShown;
  final SlideColors colors;

  bool get _qa => slide.template == SlideTemplate.qa;

  /// Og'zaki savol (avtomatik taqdimot): faqat savol matni.
  bool get _bareQuestion =>
      slide.question && !_qa && slide.bullets.isEmpty && slide.note == null;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final base = _base(context);
    const cw = SlideCanvasMetrics.contentW;
    final titleStyle = base.copyWith(
      fontWeight: FontWeight.w700,
      color: c.ink,
      height: SlideCanvasMetrics.titleLh,
      letterSpacing: -0.3,
    );
    final sizes = _bareQuestion
        ? const [56.0, 50.0, 44.0, 40.0, 36.0]
        : _qa
        ? SlideCanvasMetrics.questionSizes
        : SlideCanvasMetrics.titleSizes;
    final maxLines = _bareQuestion ? 5 : (_qa ? 3 : 2);
    final titleSize = _pick(
      sizes,
      (s) =>
          _spanLines(
            TextSpan(
              text: slide.title,
              style: titleStyle.copyWith(fontSize: s),
            ),
            cw,
          ) <=
          maxLines,
    );
    final eyebrow = slide.eyebrow != null && slide.eyebrow != slide.title
        ? slide.eyebrow
        : null;
    return ColoredBox(
      color: c.bg,
      child: Stack(
        children: [
          // Chap aksent chizig'i va yuqori burchakdagi yumshoq shakl (bezak).
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 10, color: c.brand),
          ),
          Positioned(
            right: -90,
            top: -90,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: c.soft.withValues(alpha: c.dark ? 0.5 : 0.8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SlideCanvasMetrics.padX,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: SlideCanvasMetrics.topPad),
                SizedBox(
                  height: SlideCanvasMetrics.eyebrowH,
                  child: eyebrow == null
                      ? null
                      : Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: _Chip(text: eyebrow, colors: c),
                          ),
                        ),
                ),
                const SizedBox(
                  height:
                      SlideCanvasMetrics.titleTop -
                      SlideCanvasMetrics.topPad -
                      SlideCanvasMetrics.eyebrowH,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        titleSize *
                            SlideCanvasMetrics.titleLh *
                            (maxLines + 1) +
                        4,
                  ),
                  child: _Shrink(
                    width: cw,
                    child: Semantics(
                      header: true,
                      child: Text(
                        slide.title,
                        style: titleStyle.copyWith(fontSize: titleSize),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SlideCanvasMetrics.titleGap),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => _body(context, box, base),
                  ),
                ),
                if (slide.source != null) ...[
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 70),
                    child: _Shrink(
                      width: cw,
                      child: Text(
                        slide.source!,
                        style: base.copyWith(
                          fontSize: SlideCanvasMetrics.sourceSize,
                          height: 1.3,
                          color: c.sub,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else
                  const SizedBox(height: 24),
                _Footer(
                  label: deckTitle ?? 'LabGuide',
                  number: number,
                  total: total,
                  color: c.sub,
                  strong: c.brand,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, BoxConstraints box, TextStyle base) {
    final w = box.maxWidth;
    final h = box.maxHeight;
    final note = slide.note;
    final noteH = note == null ? 0.0 : _noteHeight(note, base, w) + 16;
    Widget withNote(Widget body) => note == null
        ? body
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              body,
              const SizedBox(height: 16),
              _Note(text: note, colors: colors, base: base),
            ],
          );
    if (_bareQuestion) {
      return Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: colors.soft, shape: BoxShape.circle),
          child: Text(
            '?',
            style: base.copyWith(
              fontSize: 60,
              fontWeight: FontWeight.w700,
              color: colors.brand,
            ),
          ),
        ),
      );
    }
    switch (slide.template) {
      case SlideTemplate.table:
        return _Shrink(
          width: w,
          child: withNote(
            _CanvasTable(
              slide: slide,
              colors: colors,
              base: base,
              width: w,
              maxHeight: h - noteH,
            ),
          ),
        );
      case SlideTemplate.figure:
        return _Figure(slide: slide, colors: colors, base: base, w: w, h: h);
      case SlideTemplate.qa:
        return _Shrink(
          width: w,
          child: _CanvasQa(
            slide: slide,
            colors: colors,
            base: base,
            width: w,
            maxHeight: h,
            answerShown: answerShown,
          ),
        );
      case SlideTemplate.title:
      case SlideTemplate.bullets:
        return _Shrink(
          width: w,
          child: withNote(
            _Bullets(
              slide: slide,
              colors: colors,
              base: base,
              width: w,
              maxHeight: h - noteH,
            ),
          ),
        );
    }
  }

  double _noteHeight(String note, TextStyle base, double w) =>
      _spanHeight(
        TextSpan(text: note, style: base.copyWith(fontSize: 20, height: 1.3)),
        w - 40,
      ) +
      28;
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.colors});

  final String text;
  final SlideColors colors;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    decoration: BoxDecoration(
      color: colors.soft,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      maxLines: 1,
      style: _base(context).copyWith(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: colors.brand,
        letterSpacing: 0.3,
      ),
    ),
  );
}

class _Note extends StatelessWidget {
  const _Note({required this.text, required this.colors, required this.base});

  final String text;
  final SlideColors colors;
  final TextStyle base;

  @override
  Widget build(BuildContext context) {
    final p = colors.p;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: p.amberBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: base.copyWith(fontSize: 20, height: 1.3, color: p.amber),
      ),
    );
  }
}

// ---------------------------------------------------------------- bandlar ---

class _Bullets extends StatelessWidget {
  const _Bullets({
    required this.slide,
    required this.colors,
    required this.base,
    required this.width,
    required this.maxHeight,
  });

  final LectureSlide slide;
  final SlideColors colors;
  final TextStyle base;
  final double width;
  final double maxHeight;

  bool get _compact => slide.compact;

  /// Rejaning raqamlari faqat bitta sahifali rejada (davom sahifasida
  /// raqam noto'g'ri bo'lardi) — aks holda belgi.
  bool get _numberPlan => slide.plan && !(slide.eyebrow ?? '').contains('/');

  double _indent(String b) {
    if (_compact) return 0;
    if (slide.plan) return SlideCanvasMetrics.planIndent;
    if (_numbered.hasMatch(b)) return 52;
    return SlideCanvasMetrics.bulletIndent;
  }

  String _text(String b) {
    if (_compact || slide.plan) return b;
    return _numbered.firstMatch(b)?.group(2) ?? b;
  }

  TextStyle _style(double s) => base.copyWith(
    fontSize: s,
    height: _compact ? 1.3 : SlideCanvasMetrics.bodyLh,
    color: colors.ink,
  );

  double _gap(double s) => _compact ? 8 : s * (slide.plan ? 0.6 : 0.5);

  double _measure(double s) {
    var h = 0.0;
    for (final (i, b) in slide.bullets.indexed) {
      final t = _spanHeight(_span(b, s), width - _indent(b));
      h += slide.plan ? (t < 44 ? 44 : t) : t;
      if (i > 0) h += _gap(s);
    }
    return h;
  }

  InlineSpan _span(String b, double s) {
    if (_compact) {
      final m = _numbered.firstMatch(b);
      final st = _style(s).copyWith(color: colors.ink);
      if (m == null) return TextSpan(text: b, style: st);
      return TextSpan(
        style: st,
        children: [
          TextSpan(
            text: '${m.group(1)}.  ',
            style: st.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.brand,
            ),
          ),
          TextSpan(text: m.group(2)),
        ],
      );
    }
    return _richItem(_text(b), _style(s), colors.brand);
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _compact
        ? const [22.0, 20.0, 18.0, 16.0]
        : slide.plan
        ? const [32.0, 30.0, 28.0, 26.0, 24.0, 22.0]
        : SlideCanvasMetrics.bodySizes;
    final s = _pick(sizes, (s) => _measure(s) <= maxHeight);
    final lineH = s * (_compact ? 1.3 : SlideCanvasMetrics.bodyLh);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, b) in slide.bullets.indexed)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : _gap(s)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_compact) _marker(i, b, s, lineH),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: slide.plan && lineH < 44 ? (44 - lineH) / 2 : 0,
                    ),
                    child: Text.rich(_span(b, s)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _marker(int i, String b, double s, double lineH) {
    final c = colors;
    if (slide.plan) {
      return Padding(
        padding: EdgeInsets.only(
          right: 20,
          top: lineH > 44 ? (lineH - 44) / 2 : 0,
        ),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.brand,
            borderRadius: BorderRadius.circular(14),
          ),
          child: _numberPlan
              ? Text(
                  '${i + 1}',
                  style: base.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: c.onBrand,
                  ),
                )
              : Icon(Icons.east_rounded, size: 24, color: c.onBrand),
        ),
      );
    }
    final m = _numbered.firstMatch(b);
    if (m != null) {
      return Padding(
        padding: EdgeInsets.only(
          right: 16,
          top: lineH > 36 ? (lineH - 36) / 2 : 0,
        ),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.brand, shape: BoxShape.circle),
          child: Text(
            m.group(1)!,
            style: base.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.onBrand,
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(right: 18, top: (lineH - 12) / 2),
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: c.brand,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- jadval ---

class _CanvasTable extends StatelessWidget {
  const _CanvasTable({
    required this.slide,
    required this.colors,
    required this.base,
    required this.width,
    required this.maxHeight,
  });

  final LectureSlide slide;
  final SlideColors colors;
  final TextStyle base;
  final double width;
  final double maxHeight;

  static const _padX = 14.0;
  static const _padY = 10.0;

  int get _cols => slide.tableRows.fold<int>(
    slide.tableHeader.length,
    (m, r) => r.length > m ? r.length : m,
  );

  List<double> get _flex => [
    for (var c = 0; c < _cols; c++) c == _cols - 1 && _cols > 2 ? 1.4 : 1.0,
  ];

  bool get _hasHeader => slide.tableHeader.any((h) => h.isNotEmpty);

  double _swatchW(int r) {
    final n = r < slide.rowSwatches.length ? slide.rowSwatches[r].length : 0;
    return n == 0 ? 0 : n * 24.0 + 6;
  }

  double _measure(double s) {
    final flex = _flex;
    final tot = flex.fold<double>(0, (a, b) => a + b);
    final widths = [for (final f in flex) width * f / tot - 2 * _padX];
    double row(List<String> r, TextStyle st, {bool head = false, int ri = -1}) {
      var m = 0.0;
      for (var c = 0; c < _cols; c++) {
        final t = c < r.length ? r[c] : '';
        final cw = widths[c] - (c == 0 && ri >= 0 ? _swatchW(ri) : 0);
        final h = _spanHeight(
          TextSpan(
            text: t,
            style: c == 0 || head
                ? st.copyWith(fontWeight: FontWeight.w700)
                : st,
          ),
          cw < 20 ? 20 : cw,
        );
        if (h > m) m = h;
      }
      return m + 2 * _padY;
    }

    var h = _hasHeader ? row(slide.tableHeader, _head(s), head: true) : 0.0;
    for (final (i, r) in slide.tableRows.indexed) {
      h += row(r, _cell(s), ri: i);
    }
    return h;
  }

  TextStyle _cell(double s) =>
      base.copyWith(fontSize: s, height: 1.3, color: colors.ink);

  TextStyle _head(double s) => base.copyWith(
    fontSize: s * 0.85,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: colors.onBrand,
  );

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final s = _pick(const [
      30.0,
      28.0,
      26.0,
      24.0,
      22.0,
      20.0,
      18.0,
    ], (s) => _measure(s) <= maxHeight);
    final flex = _flex;
    Widget cell(String t, TextStyle st) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: _padX, vertical: _padY),
      child: Text(t, style: st),
    );
    Widget swatch(int r) {
      final colorsRow = r < slide.rowSwatches.length
          ? slide.rowSwatches[r]
          : const <Color>[];
      if (colorsRow.isEmpty) return const SizedBox.shrink();
      return ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final col in colorsRow)
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: col,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.line),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Table(
        columnWidths: {
          for (var i = 0; i < _cols; i++) i: FlexColumnWidth(flex[i]),
        },
        border: TableBorder(horizontalInside: BorderSide(color: c.line)),
        children: [
          if (_hasHeader)
            TableRow(
              decoration: BoxDecoration(color: c.brand),
              children: [
                for (var i = 0; i < _cols; i++)
                  cell(
                    i < slide.tableHeader.length ? slide.tableHeader[i] : '',
                    _head(s),
                  ),
              ],
            ),
          for (final (r, row) in slide.tableRows.indexed)
            TableRow(
              decoration: BoxDecoration(color: r.isEven ? c.paper : c.soft),
              children: [
                for (var i = 0; i < _cols; i++)
                  i == 0
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _padX,
                            vertical: _padY,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: (s * 1.3 - 20) / 2,
                                ),
                                child: swatch(r),
                              ),
                              Expanded(
                                child: Text(
                                  row.isEmpty ? '' : row[0],
                                  style: _cell(s)
                                      .copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        )
                      : cell(i < row.length ? row[i] : '', _cell(s)),
              ],
            ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ rasm ---

class _Figure extends StatelessWidget {
  const _Figure({
    required this.slide,
    required this.colors,
    required this.base,
    required this.w,
    required this.h,
  });

  final LectureSlide slide;
  final SlideColors colors;
  final TextStyle base;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final lines = [
      for (final l in (slide.figureCaption ?? '').split('\n'))
        if (l.trim().isNotEmpty) l,
    ];
    final credit = slide.figureCredit;
    final noteH = slide.note == null ? 0.0 : 90.0;
    final hasText = lines.isNotEmpty || credit != null;
    // Izoh qisqa bo'lsa — rasm kattaroq.
    final imgW = !hasText
        ? w
        : (lines.join(' ').length < 160
              ? 640.0
              : SlideCanvasMetrics.figureImageW);
    final capW = w - imgW - SlideCanvasMetrics.figureGap;
    TextStyle cap(double s) =>
        base.copyWith(fontSize: s, height: 1.35, color: c.ink);
    TextStyle cred(double s) =>
        base.copyWith(fontSize: 18, height: 1.3, color: c.sub);
    double measure(double s) {
      var t = 0.0;
      for (final (i, l) in lines.indexed) {
        t += _spanHeight(
          i == 0 && lines.length > 1
              ? TextSpan(
                  text: l,
                  style: cap(s).copyWith(fontWeight: FontWeight.w700),
                )
              : _richItem(l, cap(s), c.brand),
          capW,
        );
        if (i > 0) t += s * 0.4;
      }
      if (credit != null) {
        t += 16 + _spanHeight(TextSpan(text: credit, style: cred(s)), capW);
      }
      return t;
    }

    final s = _pick(
      SlideCanvasMetrics.bodySizes,
      (s) => measure(s) <= h - noteH,
    );
    final image = Semantics(
      image: true,
      label: [slide.title, ...lines].join('. '),
      child: Container(
        width: imgW,
        height: h - noteH,
        decoration: BoxDecoration(
          color: c.paper,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.line, width: 1.5),
        ),
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            slide.figure!,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
            errorBuilder: (context, _, _) => Center(
              child: Icon(Icons.image_not_supported_outlined, color: c.sub),
            ),
          ),
        ),
      ),
    );
    final text = !hasText
        ? null
        : SizedBox(
            width: capW,
            height: h - noteH,
            child: _Shrink(
              width: capW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (i, l) in lines.indexed)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 0 : s * 0.4),
                      child: i == 0 && lines.length > 1
                          ? Text(
                              l,
                              style: cap(s)
                                  .copyWith(fontWeight: FontWeight.w700),
                            )
                          : Text.rich(_richItem(l, cap(s), c.brand)),
                    ),
                  if (credit != null) ...[
                    const SizedBox(height: 16),
                    Container(width: 48, height: 4, color: c.brand),
                    const SizedBox(height: 10),
                    Text(credit, style: cred(s)),
                  ],
                ],
              ),
            ),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            image,
            if (text != null) ...[
              const SizedBox(width: SlideCanvasMetrics.figureGap),
              text,
            ],
          ],
        ),
        if (slide.note != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: noteH - 12,
            child: _Shrink(
              width: w,
              child: _Note(text: slide.note!, colors: c, base: base),
            ),
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------ savol-javob ---

class _CanvasQa extends StatelessWidget {
  const _CanvasQa({
    required this.slide,
    required this.colors,
    required this.base,
    required this.width,
    required this.maxHeight,
    required this.answerShown,
  });

  final LectureSlide slide;
  final SlideColors colors;
  final TextStyle base;
  final double width;
  final double maxHeight;
  final bool answerShown;

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  static const _letterD = 44.0;

  String _letter(int i) => _letters[i % _letters.length];

  TextStyle _opt(double s) =>
      base.copyWith(fontSize: s, height: 1.3, color: colors.ink);

  double _optHeight(String o, double s, {bool bold = false}) {
    final t = _spanHeight(
      TextSpan(
        text: o,
        style: bold ? _opt(s).copyWith(fontWeight: FontWeight.w700) : _opt(s),
      ),
      width - _letterD - 20 - 40,
    );
    return (t < _letterD ? _letterD : t) + 28;
  }

  List<String> get _explanation => [
    for (final p in (slide.answerExplanation ?? '').split('\n\n'))
      if (p.trim().isNotEmpty) p,
  ];

  double _measure(double s) {
    if (!answerShown) {
      var h = 0.0;
      for (final o in slide.options) {
        h += _optHeight(o, s) + 12;
      }
      return h;
    }
    final ci = slide.correctIndex ?? 0;
    var h = slide.options.isEmpty
        ? 0.0
        : _optHeight(slide.options[ci], s, bold: true) + 24;
    for (final (i, p) in _explanation.indexed) {
      h += _spanHeight(_richItem(p, _opt(s), colors.brand), width);
      if (i > 0) h += s * 0.5;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final s = _pick(const [
      30.0,
      28.0,
      26.0,
      24.0,
      22.0,
      20.0,
    ], (s) => _measure(s) <= maxHeight);
    Widget option(int i, {required bool correct}) {
      final o = slide.options[i];
      return Semantics(
        container: true,
        label: '${_letter(i)}. $o',
        child: ExcludeSemantics(
          child: Container(
            key: ValueKey('qa-option-$i'),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: correct ? c.brand : c.paper,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: correct ? c.brand : c.line, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: _letterD,
                  height: _letterD,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: correct ? SlideColors.lime : c.soft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _letter(i),
                    style: base.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: correct ? const Color(0xFF122D2A) : c.brand,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: s * 1.3 < _letterD ? (_letterD - s * 1.3) / 2 : 0,
                    ),
                    child: Text(
                      o,
                      style: correct
                          ? _opt(s).copyWith(
                              fontWeight: FontWeight.w700,
                              color: c.onBrand,
                            )
                          : _opt(s),
                    ),
                  ),
                ),
                if (correct) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.check_circle_rounded, color: c.onBrand, size: 34),
                ],
              ],
            ),
          ),
        ),
      );
    }

    if (!answerShown) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < slide.options.length; i++)
            option(i, correct: false),
        ],
      );
    }
    final ci = slide.correctIndex ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ci < slide.options.length) option(ci, correct: true),
        const SizedBox(height: 12),
        if (_explanation.isNotEmpty)
          Column(
            key: const ValueKey('lecture-answer-text'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, p) in _explanation.indexed)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : s * 0.5),
                  child: Text.rich(_richItem(p, _opt(s), c.brand)),
                ),
            ],
          ),
      ],
    );
  }
}
