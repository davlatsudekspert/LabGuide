/// Talaba Pro (D-78): natijalar tarixini CSV va PDF ga eksport. Faqat
/// qurilmadagi tarixdan; shaxsiy ma'lumot (ism, email) qo'shilmaydi.
library;

import 'package:flutter/services.dart' show AssetBundle;
import 'package:intl/intl.dart';

import '../../core/export/csv.dart';
import '../../core/export/pdf_report.dart';
import '../../l10n/gen/app_localizations.dart';
import '../learn/exam_session.dart';
import '../learn/exam_widgets.dart' show formatClock;
import '../share/file_export.dart';
import 'learner_analytics.dart';

/// Mavzu nomi (manba + mavzu id) — UI qatlami beradi.
typedef TopicName = String Function(String sourceId, String topicId);

/// Sessiya nomi — UI qatlami beradi (`examSessionTitle`).
typedef SessionTitle = String Function(ExamSession s);

String _mode(ExamSession s) => s.simulation ? 'simulation' : s.mode.name;

List<List<String>> resultsCsvRows(
  List<ExamSession> sessions, {
  required SessionTitle title,
}) => [
  [
    'finished_at',
    'source',
    'title',
    'mode',
    'questions',
    'correct',
    'wrong',
    'unanswered',
    'percent',
    'pass_percent',
    'passed',
    'time_limit_min',
    'time_spent_s',
    'timed_out',
  ],
  for (final s in sessions)
    [
      csvDateTime(s.finishedAt ?? s.startedAt),
      s.sourceId,
      csvText(title(s)),
      _mode(s),
      '${s.length}',
      '${s.correctCount}',
      '${s.wrongCount}',
      '${s.unansweredCount}',
      '${s.percent}',
      s.passPercent?.toString() ?? '',
      switch (s.passed) {
        null => '',
        true => 'yes',
        false => 'no',
      },
      s.limit == null ? '' : '${s.limit!.inMinutes}',
      '${s.spent(s.finishedAt ?? s.startedAt).inSeconds}',
      s.timedOut ? 'yes' : 'no',
    ],
];

List<List<String>> topicsCsvRows(
  List<TopicTrend> topics, {
  required TopicName topicName,
}) => [
  [
    'source',
    'topic_id',
    'topic',
    'questions',
    'correct',
    'percent',
    'sessions',
    'early_percent',
    'recent_percent',
    'weak',
  ],
  for (final t in topics)
    [
      t.sourceId,
      t.topicId,
      csvText(topicName(t.sourceId, t.topicId)),
      '${t.total}',
      '${t.correct}',
      '${t.percent}',
      '${t.sessions}',
      t.earlyPercent?.toString() ?? '',
      t.recentPercent?.toString() ?? '',
      t.weak() ? 'yes' : 'no',
    ],
];

String _stamp(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

List<ExportFile> resultsCsvFiles(
  ResultsAnalytics a, {
  required SessionTitle title,
  required TopicName topicName,
  required DateTime now,
}) => [
  ExportFile(
    name: 'labguide-results-${_stamp(now)}.csv',
    mimeType: ExportFile.csv,
    bytes: csvBytes(resultsCsvRows(a.sessions, title: title)),
  ),
  ExportFile(
    name: 'labguide-results-topics-${_stamp(now)}.csv',
    mimeType: ExportFile.csv,
    bytes: csvBytes(topicsCsvRows(a.topics(), topicName: topicName)),
  ),
];

Future<ExportFile> resultsPdf(
  ResultsAnalytics a, {
  required AppLocalizations l,
  required String locale,
  required AssetBundle bundle,
  required SessionTitle title,
  required TopicName topicName,
  required DateTime now,
}) async {
  final (regular, bold) = await PdfFonts.load(bundle);
  final stamp = DateFormat.yMd(locale).add_Hm();
  final trend = a.trend();
  final weak = a.weakTopics();
  final b = PdfReportBuilder(
    regular: regular,
    bold: bold,
    title: l.proResultsTitle,
    footerNote: 'LabGuide · ${l.examPracticeNotice}',
    pageLabel: (p, t) => l.proExportPage(p, t),
  )
    ..heading1(l.proResultsTitle)
    ..text(l.proExportCreated(stamp.format(now)), color: PdfColor.grey)
    ..gap(4)
    ..keyValues([
      (l.proResultsSessions, '${a.sessions.length}'),
      (l.proResultsAverage, '${a.average}%'),
      (l.proResultsBest, '${a.best}%'),
      (l.proResultsLast, '${a.last}%'),
      if (trend != null) (l.proResultsTrend, l.proPoints(signedInt(trend))),
      (l.proResultsAnswered, '${a.totalCorrect} / ${a.totalQuestions}'),
    ])
    ..heading2(l.proResultsWeak);
  if (weak.isEmpty) {
    b.text(l.proResultsNoWeak);
  } else {
    b.table(
      [l.examTopics, '%', l.proResultsQuestions],
      [
        for (final t in weak)
          [topicName(t.sourceId, t.topicId), '${t.percent}%', '${t.correct}/${t.total}'],
      ],
      widths: const [3, 0.7, 1],
    );
  }
  b
    ..heading2(l.proResultsTopics)
    ..table(
      [l.examTopics, '%', l.proResultsQuestions, l.proResultsTrend],
      [
        for (final t in a.topics())
          [
            topicName(t.sourceId, t.topicId),
            '${t.percent}%',
            '${t.correct}/${t.total}',
            t.delta == null ? '—' : l.proPoints(signedInt(t.delta!)),
          ],
      ],
      widths: const [3, 0.7, 1, 1],
    )
    ..heading2(l.proResultsHistory)
    ..table(
      [l.proColDate, l.proResultsSession, '%', l.proResultsQuestions, l.examSpent],
      [
        for (final s in a.sessions)
          [
            stamp.format(s.finishedAt ?? s.startedAt),
            '${title(s)}${s.simulation ? ' · ${l.proSimTag}' : ''}'
                '${s.passed == null ? '' : s.passed! ? ' · ${l.examPassMet(s.passPercent!)}' : ' · ${l.examPassMissed(s.passPercent!)}'}',
            '${s.percent}%',
            '${s.correctCount}/${s.length}',
            formatClock(s.spent(s.finishedAt ?? s.startedAt)),
          ],
      ],
      widths: const [1.3, 3, 0.6, 0.9, 0.9],
    );
  return ExportFile(
    name: 'labguide-results-${_stamp(now)}.pdf',
    mimeType: ExportFile.pdf,
    bytes: b.build(created: now),
  );
}

/// `+5`, `−3`, `0`.
String signedInt(int v) => v > 0 ? '+$v' : (v < 0 ? '−${-v}' : '0');
