import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/storage/kv_store.dart';
import 'instrument_catalog.dart';

/// Laboratoriyadagi aniq apparat (“Mening apparatim”). Katalogdagi model
/// yoki katalogda yo'q (qo'lda kiritilgan) apparat bo'lishi mumkin.
@immutable
class MyInstrument {
  const MyInstrument({
    required this.id,
    required this.createdAt,
    this.catalogId,
    this.customMaker,
    this.customModel,
    this.customCategory,
    this.label,
    this.serial,
    this.manualVersion,
    this.reagents = const {},
  });

  factory MyInstrument.fromJson(Map<String, Object?> j) => MyInstrument(
    id: j['id']! as String,
    createdAt: DateTime.parse(j['created_at']! as String),
    catalogId: j['catalog_id'] as String?,
    customMaker: j['custom_maker'] as String?,
    customModel: j['custom_model'] as String?,
    customCategory: j['custom_category'] == null
        ? null
        : InstrumentCategory.parse(j['custom_category']! as String),
    label: j['label'] as String?,
    serial: j['serial'] as String?,
    manualVersion: j['manual_version'] as String?,
    reagents: {
      for (final e in ((j['reagents'] as Map?) ?? const {}).entries)
        e.key as String: ReagentChoice.fromJson(
          (e.value as Map).cast<String, Object?>(),
        ),
    },
  );

  final String id;
  final DateTime createdAt;
  final String? catalogId;
  final String? customMaker;
  final String? customModel;
  final InstrumentCategory? customCategory;

  /// Ixtiyoriy nom: “1-xona”, “zaxira”.
  final String? label;
  final String? serial;

  /// Laboratoriyadagi operator qo'llanmasining versiyasi (foydalanuvchi
  /// kiritadi) — kalibrlash yozuvlarida iz qoladi.
  final String? manualVersion;

  /// Analit bo'yicha oxirgi tanlangan reagent — qayta kiritilmaydi.
  final Map<String, ReagentChoice> reagents;

  bool get isCustom => catalogId == null;

  MyInstrument copyWith({
    String? label,
    String? serial,
    String? manualVersion,
    Map<String, ReagentChoice>? reagents,
  }) => MyInstrument(
    id: id,
    createdAt: createdAt,
    catalogId: catalogId,
    customMaker: customMaker,
    customModel: customModel,
    customCategory: customCategory,
    label: label ?? this.label,
    serial: serial ?? this.serial,
    manualVersion: manualVersion ?? this.manualVersion,
    reagents: reagents ?? this.reagents,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'catalog_id': ?catalogId,
    'custom_maker': ?customMaker,
    'custom_model': ?customModel,
    'custom_category': ?customCategory?.name,
    'label': ?label,
    'serial': ?serial,
    'manual_version': ?manualVersion,
    'reagents': {for (final e in reagents.entries) e.key: e.value.toJson()},
  };
}

/// Reagent: ishlab chiqaruvchi (apparatnikidan farq qilishi mumkin), REF va
/// IFU versiyasi.
@immutable
class ReagentChoice {
  const ReagentChoice({
    required this.maker,
    required this.ref,
    required this.ifuVersion,
  });

  factory ReagentChoice.fromJson(Map<String, Object?> j) => ReagentChoice(
    maker: j['maker']! as String,
    ref: j['ref']! as String,
    ifuVersion: j['ifu']! as String,
  );

  final String maker;
  final String ref;
  final String ifuVersion;

  Map<String, Object?> toJson() => {
    'maker': maker,
    'ref': ref,
    'ifu': ifuVersion,
  };
}

enum CalibrationOutcome { accepted, rejected, pending }

@immutable
class CalibratorLevel {
  const CalibratorLevel({
    required this.name,
    required this.value,
    required this.unit,
  });

  factory CalibratorLevel.fromJson(Map<String, Object?> j) => CalibratorLevel(
    name: j['name']! as String,
    value: (j['value']! as num).toDouble(),
    unit: j['unit']! as String,
  );

  final String name;

  /// Kalibrator qiymatlar varag'idagi (lotga xos) qiymat — foydalanuvchi
  /// kiritadi, ilova hech qachon taxmin qilmaydi.
  final double value;
  final String unit;

  Map<String, Object?> toJson() => {'name': name, 'value': value, 'unit': unit};
}

/// Bajarilgan kalibrlash qaydi (lokal jurnal).
@immutable
class CalibrationRecord {
  const CalibrationRecord({
    required this.id,
    required this.instrumentId,
    required this.instrumentName,
    required this.analyteId,
    required this.reagent,
    required this.calibratorLot,
    required this.levels,
    required this.performedOn,
    required this.outcome,
    required this.createdAt,
    this.calibratorName,
    this.lotExpiry,
    this.manualVersion,
    this.note,
  });

  factory CalibrationRecord.fromJson(Map<String, Object?> j) =>
      CalibrationRecord(
        id: j['id']! as String,
        instrumentId: j['instrument_id']! as String,
        instrumentName: j['instrument_name']! as String,
        analyteId: j['analyte_id']! as String,
        reagent: ReagentChoice.fromJson(
          (j['reagent']! as Map).cast<String, Object?>(),
        ),
        calibratorName: j['calibrator_name'] as String?,
        calibratorLot: j['calibrator_lot']! as String,
        lotExpiry: j['lot_expiry'] == null
            ? null
            : DateTime.parse(j['lot_expiry']! as String),
        levels: [
          for (final l in j['levels']! as List)
            CalibratorLevel.fromJson((l as Map).cast<String, Object?>()),
        ],
        performedOn: DateTime.parse(j['performed_on']! as String),
        outcome: CalibrationOutcome.values.byName(j['outcome']! as String),
        manualVersion: j['manual_version'] as String?,
        note: j['note'] as String?,
        createdAt: DateTime.parse(j['created_at']! as String),
      );

  final String id;
  final String instrumentId;

  /// Apparat keyin o'chirilsa ham jurnal o'qiladigan bo'lsin.
  final String instrumentName;
  final String analyteId;
  final ReagentChoice reagent;
  final String? calibratorName;
  final String calibratorLot;
  final DateTime? lotExpiry;
  final List<CalibratorLevel> levels;
  final DateTime performedOn;
  final CalibrationOutcome outcome;
  final String? manualVersion;
  final String? note;
  final DateTime createdAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'instrument_id': instrumentId,
    'instrument_name': instrumentName,
    'analyte_id': analyteId,
    'reagent': reagent.toJson(),
    'calibrator_name': ?calibratorName,
    'calibrator_lot': calibratorLot,
    'lot_expiry': ?lotExpiry?.toIso8601String(),
    'levels': [for (final l in levels) l.toJson()],
    'performed_on': performedOn.toIso8601String(),
    'outcome': outcome.name,
    'manual_version': ?manualVersion,
    'note': ?note,
    'created_at': createdAt.toIso8601String(),
  };
}

enum CatalogLoadState { loading, ready, failed }

/// Apparatlar katalogi (ilova ichidagi, manbali JSON), “Mening
/// apparatlarim” va kalibrlash jurnali. Hammasi qurilmada saqlanadi.
class InstrumentsController extends ChangeNotifier {
  InstrumentsController(
    this._store, {
    required this.bundle,
    DateTime Function()? clock,
    math.Random? random,
  }) : _clock = clock ?? DateTime.now,
       _random = random ?? math.Random() {
    _mine = _read(StoreKeys.myInstruments, MyInstrument.fromJson);
    _records = _read(StoreKeys.calibrationLog, CalibrationRecord.fromJson);
  }

  static const catalogAsset = 'assets/instruments/catalog.json';

  final KeyValueStore _store;
  final AssetBundle bundle;
  final DateTime Function() _clock;
  final math.Random _random;

  CatalogLoadState _state = CatalogLoadState.loading;
  InstrumentCatalog? _catalog;
  Future<void>? _loading;
  List<MyInstrument> _mine = const [];
  List<CalibrationRecord> _records = const [];
  Object? _storeError;

  CatalogLoadState get state => _state;
  InstrumentCatalog? get catalog => _catalog;
  List<MyInstrument> get mine => _mine;
  List<CalibrationRecord> get records => _records;

  /// Saqlangan ma'lumotni o'qib bo'lmadi — ustiga yozilmaydi.
  Object? get storeError => _storeError;

  List<T> _read<T>(String key, T Function(Map<String, Object?>) parse) {
    final raw = _store.getString(key);
    if (raw == null) return const [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          parse((e as Map).cast<String, Object?>()),
      ];
    } on Object catch (e) {
      _storeError = e;
      return const [];
    }
  }

  /// Katalog bir marta yuklanadi (ekran ochilganda).
  Future<void> ensureCatalog({Set<String> knownAnalytes = const {}}) =>
      _loading ??= _loadCatalog(knownAnalytes);

  Future<void> _loadCatalog(Set<String> knownAnalytes) async {
    try {
      final raw = await bundle.loadString(catalogAsset);
      _catalog = InstrumentCatalog.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
        knownAnalytes: knownAnalytes,
      );
      _state = CatalogLoadState.ready;
    } on Object catch (e) {
      debugPrint('instrument catalog rejected: $e');
      _state = CatalogLoadState.failed;
      _loading = null;
    }
    notifyListeners();
  }

  Future<void> retry() {
    _state = CatalogLoadState.loading;
    _loading = null;
    notifyListeners();
    return ensureCatalog();
  }

  String _newId() =>
      '${_clock().microsecondsSinceEpoch.toRadixString(36)}'
      '${_random.nextInt(1 << 30).toRadixString(36)}';

  Future<void> _saveMine(List<MyInstrument> next) async {
    if (_storeError != null) throw StateError('instrument data unreadable');
    await _store.setString(
      StoreKeys.myInstruments,
      jsonEncode([for (final m in next) m.toJson()]),
    );
    _mine = List.unmodifiable(next);
    notifyListeners();
  }

  Future<void> _saveRecords(List<CalibrationRecord> next) async {
    if (_storeError != null) throw StateError('instrument data unreadable');
    await _store.setString(
      StoreKeys.calibrationLog,
      jsonEncode([for (final r in next) r.toJson()]),
    );
    _records = List.unmodifiable(next);
    notifyListeners();
  }

  MyInstrument? myInstrument(String id) =>
      _mine.where((m) => m.id == id).firstOrNull;

  /// Katalog modelidan saqlangan apparatlar (bir model bir necha marta
  /// bo'lishi mumkin — masalan, ikki xonada).
  List<MyInstrument> savedFor(String catalogId) => [
    for (final m in _mine)
      if (m.catalogId == catalogId) m,
  ];

  Future<MyInstrument> addFromCatalog(
    String catalogId, {
    String? label,
    String? serial,
    String? manualVersion,
  }) async {
    final m = MyInstrument(
      id: _newId(),
      createdAt: _clock(),
      catalogId: catalogId,
      label: _clean(label),
      serial: _clean(serial),
      manualVersion: _clean(manualVersion),
    );
    await _saveMine([..._mine, m]);
    return m;
  }

  Future<MyInstrument> addCustom({
    required String maker,
    required String model,
    required InstrumentCategory category,
    String? label,
    String? serial,
    String? manualVersion,
  }) async {
    final m = MyInstrument(
      id: _newId(),
      createdAt: _clock(),
      customMaker: maker.trim(),
      customModel: model.trim(),
      customCategory: category,
      label: _clean(label),
      serial: _clean(serial),
      manualVersion: _clean(manualVersion),
    );
    await _saveMine([..._mine, m]);
    return m;
  }

  Future<void> update(MyInstrument next) =>
      _saveMine([for (final m in _mine) m.id == next.id ? next : m]);

  Future<void> remove(String id) => _saveMine([
    for (final m in _mine)
      if (m.id != id) m,
  ]);

  /// Analit uchun tanlangan reagentni apparatga yozib qo'yadi.
  Future<void> rememberReagent(
    String instrumentId,
    String analyteId,
    ReagentChoice choice,
  ) async {
    final m = myInstrument(instrumentId);
    if (m == null) return;
    await update(m.copyWith(reagents: {...m.reagents, analyteId: choice}));
  }

  Future<CalibrationRecord> addRecord({
    required MyInstrument instrument,
    required String instrumentName,
    required String analyteId,
    required ReagentChoice reagent,
    required String calibratorLot,
    required List<CalibratorLevel> levels,
    required DateTime performedOn,
    required CalibrationOutcome outcome,
    String? calibratorName,
    DateTime? lotExpiry,
    String? note,
  }) async {
    if (calibratorLot.trim().isEmpty || levels.isEmpty) {
      throw ArgumentError('lot and at least one level are required');
    }
    final r = CalibrationRecord(
      id: _newId(),
      instrumentId: instrument.id,
      instrumentName: instrumentName,
      analyteId: analyteId,
      reagent: reagent,
      calibratorName: _clean(calibratorName),
      calibratorLot: calibratorLot.trim(),
      lotExpiry: lotExpiry,
      levels: levels,
      performedOn: performedOn,
      outcome: outcome,
      manualVersion: instrument.manualVersion,
      note: _clean(note),
      createdAt: _clock(),
    );
    await _saveRecords([r, ..._records]);
    await rememberReagent(instrument.id, analyteId, reagent);
    return r;
  }

  Future<void> removeRecord(String id) => _saveRecords([
    for (final r in _records)
      if (r.id != id) r,
  ]);

  /// “Lokal ma'lumotlarni o'chirish” dan keyin (ombor allaqachon tozalangan).
  void resetInMemory() {
    _mine = const [];
    _records = const [];
    _storeError = null;
    notifyListeners();
  }

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }
}
