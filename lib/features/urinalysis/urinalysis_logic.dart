/// Siydik tahlili: natijani o'qish yordamchisi va mashq savollarini tuzish.
///
/// O'qish — faqat manbada aytilgan ma'nolar ([urFindingInfo]) va manbada
/// ta'riflangan birikmalar ([urComboInfo]); tashxis qo'yilmaydi.
library;

import 'dart:math';

import '../content/content_model.dart';
import 'urinalysis_content.dart';

/// Tanlangan topilmalar bo'yicha o'qish natijasi.
class UrReading {
  const UrReading(this.findings, this.combos);

  /// Tanlangan topilmalar ([UrFinding] tartibida).
  final List<UrFinding> findings;

  /// Mos kelgan birikmalar ([UrCombo] tartibida).
  final List<UrCombo> combos;

  bool get isEmpty => findings.isEmpty;
}

/// Birikma qoidasi: qachon ko'rsatiladi.
bool urComboApplies(UrCombo c, Set<UrFinding> s) {
  bool has(UrFinding f) => s.contains(f);
  final pyuria = has(UrFinding.leukocyteEsterase) || has(UrFinding.wbc);
  final glomerular = has(UrFinding.dysmorphicRbc) || has(UrFinding.rbcCast);
  return switch (c) {
    // Chiziqda qon, cho'kmada eritrotsit yo'q.
    UrCombo.bloodWithoutRbc =>
      has(UrFinding.blood) &&
          !has(UrFinding.rbc) &&
          !has(UrFinding.dysmorphicRbc),
    UrCombo.glomerularPattern => glomerular,
    // Eritrotsitlar bor, lekin oqsil va glomerulyar belgilar yo'q.
    UrCombo.urologicPattern =>
      has(UrFinding.rbc) && !has(UrFinding.protein) && !glomerular,
    UrCombo.nitriteAndLe =>
      has(UrFinding.nitrite) && has(UrFinding.leukocyteEsterase),
    UrCombo.leWithoutNitrite => pyuria && !has(UrFinding.nitrite),
    UrCombo.contamination =>
      has(UrFinding.squamous) &&
          (has(UrFinding.bacteria) ||
              pyuria ||
              has(UrFinding.rbc) ||
              has(UrFinding.blood)),
    UrCombo.ureaseAlkaline =>
      has(UrFinding.alkalinePh) &&
          (has(UrFinding.nitrite) || has(UrFinding.bacteria)),
  };
}

UrReading readUrinalysis(Set<UrFinding> selected) => UrReading(
  [
    for (final f in UrFinding.values)
      if (selected.contains(f)) f,
  ],
  [
    for (final c in UrCombo.values)
      if (urComboApplies(c, selected)) c,
  ],
);

// ───────────────────────── Mashq ─────────────────────────

/// Mashq savoli; rasmli savolda [element] va [atlasId] bor.
class UrQuizQuestion {
  const UrQuizQuestion(this.question, {this.element, this.atlasId});

  final QuizQuestion question;
  final UrElement? element;
  final String? atlasId;

  bool get isPicture => atlasId != null;
}

/// Rasmli savolga yaroqli elementlar: `quiz` belgilangan, chalg'ituvchilari
/// yozilgan va panelsiz (butun maydon) rasmi bor.
List<UrElement> urPictureQuizPool() => [
  for (final e in urElements)
    if (e.quiz &&
        urPictureDistractors.containsKey(e.id) &&
        e.pics.any((p) => p.panel == null))
      e,
];

UrQuizQuestion _picture(UrElement e, Random rnd) {
  final pics = [
    for (final p in e.pics)
      if (p.panel == null) p,
  ];
  final pic = pics[rnd.nextInt(pics.length)];
  final ids = [e.id, ...urPictureDistractors[e.id]!]..shuffle(rnd);
  return UrQuizQuestion(
    QuizQuestion(
      id: 'ur-pic-${e.id}',
      prompt: UrL.quizPicturePrompt,
      options: [
        for (final id in ids)
          QuizOption(
            text: urElement(id)!.name,
            explanation: urElement(id)!.look.first.text,
          ),
      ],
      correctIndex: ids.indexOf(e.id),
      basis: e.look.first.text,
      refs: const [],
      reviewState: ReviewState.pending,
    ),
    element: e,
    atlasId: pic.atlasId,
  );
}

UrQuizQuestion _knowledge(UrQuizItem item, Random rnd) {
  final order = List.generate(item.options.length, (i) => i)..shuffle(rnd);
  return UrQuizQuestion(
    QuizQuestion(
      id: item.id,
      prompt: item.prompt,
      options: [
        for (final o in order)
          QuizOption(text: item.options[o], explanation: item.basis),
      ],
      correctIndex: order.indexOf(0),
      basis: item.basis,
      refs: const [],
      reviewState: ReviewState.pending,
    ),
  );
}

/// [urQuizSize] ta savol: rasmli va bilim savollari aralash, takrorsiz.
List<UrQuizQuestion> buildUrQuiz(Random rnd) {
  final all = [
    for (final e in urPictureQuizPool()) _picture(e, rnd),
    for (final q in urQuizItems) _knowledge(q, rnd),
  ]..shuffle(rnd);
  return all.take(urQuizSize).toList();
}
