/// Mutaxassis Pro (D-78): kalibrlash jurnalini CSV va PDF ga eksport.
///
/// Faqat SAQLANGAN maydonlar: apparat, analit, reagent (ishlab chiqaruvchi,
/// REF, IFU), kalibrator nomi / loti / yaroqlilik, darajalar (qiymat va
/// birlik — foydalanuvchi kiritgan), natija, kalibrlashdan keyingi QC, yozuv
/// turi, tasdiqlagan va sana, SOP, qo'llanma versiyasi, izoh va o'zgarishlar
/// tarixi. Jurnalda alohida "bajaruvchi (analitik)" maydoni yo'q — eksportda
/// ham to'qilmaydi. Hech narsa klinik qaror emas.
library;

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../core/entitlements/feature.dart';

import '../../core/export/csv.dart';
import '../../core/export/pdf_report.dart';
import '../../l10n/gen/app_localizations.dart';
import '../instruments/calibration_screens.dart'
    show auditActionLabel, kindLabel, localizedAuditSummary, outcomeLabel, qcLabel;
import '../instruments/instruments_controller.dart';
import '../share/file_export.dart';
import 'pro_widgets.dart';

/// Ustunlar (barqaror, mashina o'qiydigan nomlar — `qc_export.dart` kabi).
const calibrationCsvHeader = [
  'record_id',
  'performed_on',
  'kind',
  'instrument',
  'instrument_id',
  'analyte',
  'analyte_id',
  'reagent_maker',
  'reagent_ref',
  'reagent_ifu',
  'calibrator',
  'calibrator_lot',
  'lot_expiry',
  'level',
  'level_value',
  'level_unit',
  'outcome',
  'qc_after',
  'approved_by',
  'approved_at',
  'sop_ref',
  'manual_version',
  'legacy_unverified',
  'note',
  'created_at',
];

const calibrationAuditCsvHeader = ['at', 'record_id', 'action', 'summary'];

/// Jurnal qatorlari: har kalibrator darajasi — bitta qator (darajasiz
/// yozuv — bitta qator, daraja ustunlari bo'sh).
List<List<String>> calibrationCsvRows(
  List<CalibrationRecord> records, {
  required String Function(String analyteId) analyteName,
}) {
  final rows = <List<String>>[calibrationCsvHeader];
  for (final r in records) {
    final levels = r.levels.isEmpty ? <CalibratorLevel?>[null] : r.levels;
    for (final lv in levels) {
      rows.add([
        r.id,
        csvDate(r.performedOn),
        r.kind.name,
        csvText(r.instrumentName),
        r.instrumentId,
        csvText(analyteName(r.analyteId)),
        r.analyteId,
        csvText(r.reagent.maker),
        csvText(r.reagent.ref),
        csvText(r.reagent.ifuVersion),
        csvText(r.calibratorName ?? ''),
        csvText(r.calibratorLot),
        r.lotExpiry == null ? '' : csvDate(r.lotExpiry!),
        csvText(lv?.name ?? ''),
        lv == null ? '' : '${lv.value}',
        csvText(lv?.unit ?? ''),
        r.outcome.name,
        r.qcAfter.name,
        csvText(r.approvedBy ?? ''),
        r.approvedAt == null ? '' : csvDate(r.approvedAt!),
        csvText(r.sopRef ?? ''),
        csvText(r.manualVersion ?? ''),
        r.legacy ? 'yes' : 'no',
        csvText(r.note ?? ''),
        csvDateTime(r.createdAt),
      ]);
    }
  }
  return rows;
}

List<List<String>> calibrationAuditCsvRows(List<CalibrationAuditEntry> audit) => [
  calibrationAuditCsvHeader,
  for (final e in audit)
    [csvDateTime(e.at), e.recordId, e.action.name, csvText(e.summary)],
];

/// CSV fayllari: jurnal va o'zgarishlar tarixi.
List<ExportFile> calibrationCsvFiles(
  List<CalibrationRecord> records,
  List<CalibrationAuditEntry> audit, {
  required String Function(String analyteId) analyteName,
  required DateTime now,
}) {
  final stamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
  return [
    ExportFile(
      name: 'labguide-calibration-log-$stamp.csv',
      mimeType: ExportFile.csv,
      bytes: csvBytes(calibrationCsvRows(records, analyteName: analyteName)),
    ),
    ExportFile(
      name: 'labguide-calibration-audit-$stamp.csv',
      mimeType: ExportFile.csv,
      bytes: csvBytes(calibrationAuditCsvRows(audit)),
    ),
  ];
}

/// PDF: har yozuv — kalit/qiymat bloki va darajalar jadvali; oxirida tarix.
Future<ExportFile> calibrationPdf(
  List<CalibrationRecord> records,
  List<CalibrationAuditEntry> audit, {
  required AppLocalizations l,
  required String locale,
  required AssetBundle bundle,
  required String Function(String analyteId) analyteName,
  required DateTime now,
}) async {
  final (regular, bold) = await PdfFonts.load(bundle);
  final date = DateFormat.yMd(locale);
  final stamp = DateFormat.yMd(locale).add_Hm();
  final b = PdfReportBuilder(
    regular: regular,
    bold: bold,
    title: l.calLog,
    footerNote: 'LabGuide · ${l.proExportNotClinical}',
    pageLabel: (p, t) => l.proExportPage(p, t),
  )
    ..heading1(l.calLog)
    ..text(l.proExportCreated(stamp.format(now)), color: PdfColor.grey)
    ..text(l.proCalExportCount(records.length), color: PdfColor.grey)
    ..gap(4)
    ..text(l.proExportNotClinical, size: 8.5, color: PdfColor.grey);
  for (final r in records) {
    b
      ..heading2('${analyteName(r.analyteId)} · ${date.format(r.performedOn)}')
      ..keyValues([
        (l.calDetailInstrument, r.instrumentName),
        (l.calReagentMaker, r.reagent.maker),
        (l.calReagentRef, r.reagent.ref),
        (l.calIfuRevision, r.reagent.ifuVersion),
        if (r.calibratorName case final n?) (l.calDetailCalibrator, n),
        (l.calCalibratorLot, r.calibratorLot),
        if (r.lotExpiry case final e?) (l.calDetailLotExpiry, date.format(e)),
        (l.calSafeKind, kindLabel(r.kind, l)),
        (l.calOutcome, outcomeLabel(r.outcome, l)),
        (l.calSafeQcAfter, qcLabel(r.qcAfter, l)),
        if (r.approvedBy case final a?) (l.calSafeApprovedBy, a),
        if (r.approvedAt case final a?) (l.calSafeApprovedAt, date.format(a)),
        if (r.sopRef case final s?) (l.calSafeSopRef, s),
        if (r.manualVersion case final m?) (l.calDetailManual, m),
        if (r.note case final n? when n.trim().isNotEmpty) (l.calNote, n),
        if (r.legacy) (l.proColStatus, l.calSafeLegacyTag),
      ]);
    if (r.levels.isNotEmpty) {
      b.table(
        [l.calLevelName, l.calLevelValue, l.calLevelUnit],
        [
          for (final lv in r.levels) [lv.name, '${lv.value}', lv.unit],
        ],
        widths: const [2, 1.4, 1],
      );
    }
  }
  if (audit.isNotEmpty) {
    b
      ..heading2(l.calSafeHistory)
      ..table(
        [l.proColDate, l.proColAction, l.proColDetail],
        [
          for (final e in audit)
            [
              stamp.format(e.at),
              auditActionLabel(e.action, l),
              localizedAuditSummary(e.summary, l, analyteName: analyteName),
            ],
        ],
        widths: const [1.3, 1, 3],
      );
  }
  return ExportFile(
    name: 'labguide-calibration-log-${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.pdf',
    mimeType: ExportFile.pdf,
    bytes: b.build(created: now),
  );
}

/// Jurnal eksporti oqimi (kalibrlash jurnali ekranidagi Pro qatoridan).
Future<void> exportCalibrationLog(
  BuildContext context, {
  required String Function(String analyteId) analyteName,
}) {
  final l = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  final bundle = DefaultAssetBundle.of(context);
  final instruments = context.services.instruments;
  return runExport(
    context,
    feature: Feature.calibrationExport,
    pdf: () async => [
      await calibrationPdf(
        instruments.records,
        instruments.audit,
        l: l,
        locale: locale,
        bundle: bundle,
        analyteName: analyteName,
        now: DateTime.now(),
      ),
    ],
    csv: () async => calibrationCsvFiles(
      instruments.records,
      instruments.audit,
      analyteName: analyteName,
      now: DateTime.now(),
    ),
  );
}
