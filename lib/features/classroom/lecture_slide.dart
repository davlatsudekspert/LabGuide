import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

// Ma'ruza slaydi modeli. Ma'ruza pleyeri (lecture_screens.dart) shu turni
// chizadi: o'quv dasturidan yig'ilgan slaydlar ham, avtomatik taqdimot
// (auto_deck.dart) ham. Shablon — slayd qanday chizilishini belgilaydi;
// hammasi ilova ichida chiziladi (rasm faylsiz), shuning uchun 3 tilda va
// televizorda tiniq.

/// Slayd shabloni (D-47: sarlavha, bandlar, jadval/me'yor, sxema/rasm,
/// savol-javob).
enum SlideTemplate {
  /// Sarlavha: katta nom + qisqa tavsif qatorlari.
  title,

  /// Bandlar ro'yxati (standart).
  bullets,

  /// Jadval: me'yor, chegara, maqsad qiymatlari yoki "nom — qiymat".
  table,

  /// Rasm yoki sxema: atlas rasmi + izoh.
  figure,

  /// Savol-javob: variantlar, javob tugma bilan ochiladi.
  qa,
}

@immutable
class LectureSlide {
  const LectureSlide({
    required this.title,
    this.eyebrow,
    this.bullets = const [],
    this.note,
    this.question = false,
    this.teacherNote,
    this.source,
    this.section = false,
    this.image,
    this.template = SlideTemplate.bullets,
    this.tableHeader = const [],
    this.tableRows = const [],
    this.rowSwatches = const [],
    this.figure,
    this.figureCaption,
    this.options = const [],
    this.correctIndex,
    this.answerExplanation,
    this.compact = false,
  });

  final String? eyebrow;
  final String title;
  final List<String> bullets;
  final String? note;

  /// Ustoz izohi — faqat tugma bosilganda ko'rinadi.
  final String? teacherNote;

  /// Manba (slayd pastida kichik yozuv).
  final String? source;

  /// Bo'lim boshi slaydi (sarlavha kattaroq).
  final bool section;

  /// Tayyor dizayndagi slayd rasmi (16:9) — bo'lsa, matn o'rniga ko'rsatiladi.
  final String? image;

  /// Savol slaydi (auditoriyaga beriladi).
  final bool question;

  /// Slayd shabloni; `image` bo'lsa e'tiborsiz (rasm to'liq ekranda).
  final SlideTemplate template;

  /// Jadval sarlavhasi (bo'sh bo'lishi mumkin) va qatorlari. Har qator
  /// ustunlar soni bilan bir xil.
  final List<String> tableHeader;
  final List<List<String>> tableRows;

  /// Jadval qatorining rang belgilari (masalan, probirka qopqog'i); bo'sh
  /// bo'lsa — belgi yo'q. Uzunligi `tableRows` bilan bir xil yoki bo'sh.
  final List<List<Color>> rowSwatches;

  /// Rasm shabloni: asset yo'li va izoh.
  final String? figure;
  final String? figureCaption;

  /// Savol-javob: variantlar, to'g'ri javob indeksi va tushuntirish.
  final List<String> options;
  final int? correctIndex;
  final String? answerExplanation;

  /// Ixcham bandlar (kichikroq shrift): uzun manba yozuvlari ro'yxati.
  final bool compact;
}
