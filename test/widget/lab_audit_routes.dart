// Lab tabi auditi (2026-10-18, docs/AUDIT_2026-10-18_LAB.md): Lab tabidan
// ochiladigan BARCHA manzillar ro'yxati — kontent ro'yxatlaridan dasturiy
// ravishda yig'iladi (yangi hujayra/element/model qo'shilsa, audit uni ham
// qamraydi).
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/bloodmorph/bloodmorph_content.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/coprology/copro_content.dart';
import 'package:labguide/features/cytology/cytology_content.dart';
import 'package:labguide/features/differential/differential_content.dart';
import 'package:labguide/features/histology/histology_content.dart';
import 'package:labguide/features/qc/qc_guides_info.dart';
import 'package:labguide/features/tools/calc_info.dart';
import 'package:labguide/features/tools/clinical_calc_screens.dart';
import 'package:labguide/features/tools/manual_calc_info.dart';
import 'package:labguide/features/tools/manual_calc_screens.dart';
import 'package:labguide/features/urinalysis/urinalysis_content.dart';

/// Hub va statik sahifalar (parametrsiz).
const labStaticRoutes = [
  '/lab',
  '/lab/calibration',
  '/lab/calibration/log',
  '/lab/qc',
  '/lab/qc/new',
  '/lab/preanalytics',
  '/lab/instruments',
  '/lab/calculators',
  '/lab/calculators/dilution',
  '/lab/calculators/units',
  '/lab/microscopy',
  '/lab/microscopy/quiz',
  '/lab/microscopy/credits',
  '/lab/differential',
  '/lab/differential/cells',
  '/lab/differential/confusions',
  '/lab/differential/count',
  '/lab/differential/count/eyes-free',
  '/lab/differential/history',
  '/lab/differential/interpret',
  '/lab/differential/limits',
  '/lab/differential/technique',
  '/lab/differential/quiz',
  '/lab/differential/quiz?mode=extended',
  '/lab/cytology',
  '/lab/cytology/cells',
  '/lab/cytology/degree',
  '/lab/cytology/bethesda',
  '/lab/cytology/technique',
  '/lab/cytology/quiz',
  '/lab/cytology/adequacy',
  '/lab/cytology/reactive',
  '/lab/cytology/maturation',
  '/lab/cytology/other',
  '/lab/spermogram',
  '/lab/spermogram/limits',
  '/lab/spermogram/count',
  '/lab/spermogram/assess',
  '/lab/spermogram/terms',
  '/lab/spermogram/preanalytics',
  '/lab/spermogram/quiz',
  '/lab/bloodgroup',
  '/lab/bloodgroup/basics',
  '/lab/bloodgroup/methods',
  '/lab/bloodgroup/compat',
  '/lab/bloodgroup/errors',
  '/lab/bloodgroup/quality',
  '/lab/bloodgroup/reader',
  '/lab/bloodgroup/quiz',
  '/lab/histology',
  '/lab/histology/items',
  '/lab/histology/stains',
  '/lab/histology/quiz',
  '/lab/histology/credits',
  '/lab/bloodmorph',
  '/lab/bloodmorph/normal',
  '/lab/bloodmorph/rbc',
  '/lab/bloodmorph/platelets',
  '/lab/bloodmorph/retic',
  '/lab/bloodmorph/anemia',
  '/lab/bloodmorph/quality',
  '/lab/bloodmorph/quiz',
  '/lab/bloodmorph/credits',
  '/lab/urinalysis',
  '/lab/urinalysis/collect',
  '/lab/urinalysis/physical',
  '/lab/urinalysis/strip',
  '/lab/urinalysis/sediment',
  '/lab/urinalysis/reader',
  '/lab/urinalysis/quiz',
  '/lab/coagulogram',
  '/lab/coagulogram/tests',
  '/lab/coagulogram/sample',
  '/lab/coagulogram/reader',
  '/lab/coagulogram/dic',
  '/lab/coagulogram/monitoring',
  '/lab/coprology',
  '/lab/coprology/collect',
  '/lab/coprology/macro',
  '/lab/coprology/micro',
  '/lab/coprology/occult',
  '/lab/coprology/parasites',
];

/// Parametrli sahifalar: har hujayra, element, parazit, kalkulyator,
/// QC yo'riqnomasi.
List<String> labContentRoutes() => [
  for (final g in QcGuide.values) '/lab/qc/${qcGuideRoute(g)}',
  for (final c in ClinicalCalc.values) '/lab/calculators/${calcRoute(c)}',
  for (final c in ManualCalc.values) '/lab/calculators/${manualCalcRoute(c)}',
  for (final c in cellGuides) '/lab/differential/cells/${c.id}',
  for (final f in diffFindings) '/lab/differential/interpret?finding=${f.id}',
  for (final c in cytoCells) '/lab/cytology/cells/${c.id}',
  for (final f in [...bmFindings, ...bmPlatelets])
    '/lab/bloodmorph/rbc/${f.id}',
  for (final e in urElements) '/lab/urinalysis/sediment/${e.id}',
  for (final e in cpElements) '/lab/coprology/micro/${e.id}',
  for (final p in cpParasites) '/lab/coprology/parasites/${p.id}',
  for (final i in histoItems) '/lab/histology/items/${i.id}',
];

/// Katalog va atlasdan (servislar yuklangach): apparat kategoriyalari,
/// ishlab chiqaruvchilar, modellar; atlas bo'limlari va rasmlari.
List<String> labCatalogRoutes(AppServices s) {
  final cat = s.instruments.catalog!;
  final atlas = s.microscopy.atlas!;
  final makersByCat = <String>{
    for (final m in cat.models) '${m.category.name}/${m.makerId}',
  };
  return [
    for (final c in cat.categories) '/lab/instruments/c/${c.category.name}',
    for (final mc in makersByCat) '/lab/instruments/c/$mc',
    for (final m in cat.models) '/lab/instruments/m/${m.id}',
    for (final m in cat.models.take(3)) '/lab/calibration?model=${m.id}',
    for (final sec in atlas.sections) '/lab/microscopy/s/${sec.id}',
    for (final sec in atlas.sections) '/lab/microscopy/quiz?section=${sec.id}',
    for (final img in atlas.images) '/lab/microscopy/i/${img.id}',
  ];
}

/// Amaliy protokollar (46 ta): Lab bo'limlaridan (koagulogramma,
/// koprologiya) va Ma'ruza ro'yxatidan ochiladigan taqdimotlar.
List<String> protocolDeckRoutes(DeckCatalog catalog) => [
  for (final d in catalog.protocols) '/learn/lecture/deck/${d.id}',
];

/// Mavjud bo'lmagan id — halol "topilmadi" holati (qulamasin).
const labMissingRoutes = [
  '/lab/differential/cells/missing',
  '/lab/differential/history/missing',
  '/lab/cytology/cells/missing',
  '/lab/bloodmorph/rbc/missing',
  '/lab/urinalysis/sediment/missing',
  '/lab/coprology/micro/missing',
  '/lab/coprology/parasites/missing',
  '/lab/histology/items/missing',
  '/lab/instruments/m/missing',
  '/lab/instruments/c/missing',
  '/lab/instruments/c/chemistry/missing',
  '/lab/microscopy/s/missing',
  '/lab/microscopy/i/missing',
  '/lab/qc/set/missing',
  '/lab/qc/set/missing/target/L1',
  '/lab/calibration/log/missing',
];
