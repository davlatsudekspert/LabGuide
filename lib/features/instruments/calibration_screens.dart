import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/analyte_search.dart';
import '../content/content_model.dart';
import '../content/ui/content_widgets.dart';
import '../content/ui/tests_screen.dart' show SearchBox;
import '../lab/ifu_matching.dart';
import '../tools/tool_screens.dart' show formatResult, parseFieldNumber;
import 'instrument_catalog.dart';
import 'instrument_screens.dart';
import 'instruments_controller.dart';

const _decimalKeyboard = TextInputType.numberWithOptions(decimal: true);

/// Tanlangan apparat: saqlangan (“Mening apparatim”) yoki hali saqlanmagan
/// katalog modeli. Kalibrlash yozuvi yaratilganda katalog modeli avtomatik
/// saqlanadi — keyingi safar qayta kiritilmaydi.
class _Pick {
  const _Pick({this.mine, this.model});

  final MyInstrument? mine;
  final InstrumentModel? model;
}

/// Kalibrlash: apparat → analit → reagent (ishlab chiqaruvchi, REF, IFU) →
/// yo'riqnoma → (ixtiyoriy) kalibrlash yozuvi. Lot va belgilangan qiymatlar
/// faqat yozuv yaratishda so'raladi.
class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({
    super.key,
    this.modelId,
    this.mineId,
    this.analyteId,
  });

  final String? modelId;
  final String? mineId;
  final String? analyteId;

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  _Pick? _pick;
  String? _analyteId;
  final _analyteQuery = TextEditingController();
  String _aq = '';
  AnalyteSearch? _search;

  /// `null` — apparat ishlab chiqaruvchisi; aks holda boshqa nom.
  bool _otherMaker = false;
  final _makerName = TextEditingController();
  final _ref = TextEditingController();
  final _ifu = TextEditingController();
  String? _guideError;
  IfuMatch? _guide;
  bool _recordOpen = false;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _analyteId = widget.analyteId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final instruments = context.services.instruments;
    // Katalog odatda allaqachon yuklangan — tanlov darhol qo'llanadi.
    if (instruments.catalog case final catalog?) {
      _applyInitial(catalog);
    } else {
      instruments.ensureCatalog().then((_) {
        final catalog = instruments.catalog;
        if (mounted && catalog != null) setState(() => _applyInitial(catalog));
      });
    }
  }

  /// `?mine=` yoki `?model=` bo'yicha boshlang'ich apparat.
  void _applyInitial(InstrumentCatalog catalog) {
    final instruments = context.services.instruments;
    if (widget.mineId case final id?) {
      final m = instruments.myInstrument(id);
      if (m != null) {
        _pick = _Pick(
          mine: m,
          model: m.catalogId == null ? null : catalog.model(m.catalogId!),
        );
      }
    } else if (widget.modelId case final id?) {
      final model = catalog.model(id);
      if (model != null) _pick = _Pick(model: model);
    }
    _prefill();
  }

  @override
  void dispose() {
    for (final c in [_analyteQuery, _makerName, _ref, _ifu]) {
      c.dispose();
    }
    super.dispose();
  }

  InstrumentCatalog? get _catalog => context.services.instruments.catalog;

  /// Apparat ishlab chiqaruvchisining nomi (katalog yoki qo'lda kiritilgan).
  String? get _instrumentMaker {
    final p = _pick;
    if (p == null) return null;
    if (p.model != null) return _catalog?.maker(p.model!.makerId).name;
    return p.mine?.customMaker;
  }

  String get _instrumentName {
    final p = _pick!;
    if (p.mine != null) return myInstrumentName(p.mine!, _catalog);
    return '${_instrumentMaker ?? ''} ${p.model!.model}'.trim();
  }

  String get _reagentMaker =>
      _otherMaker ? _makerName.text.trim() : (_instrumentMaker ?? '');

  /// Saqlangan apparatda shu analit uchun avval tanlangan reagent bo'lsa —
  /// maydonlar to'ldiriladi (qayta kiritish shart emas).
  void _prefill() {
    final mine = _pick?.mine;
    final a = _analyteId;
    if (mine == null || a == null) return;
    final r = mine.reagents[a];
    if (r == null) return;
    _otherMaker = r.maker != _instrumentMaker;
    _makerName.text = _otherMaker ? r.maker : '';
    _ref.text = r.ref;
    _ifu.text = r.ifuVersion;
  }

  void _invalidate() {
    if (_guide != null || _guideError != null) {
      setState(() {
        _guide = null;
        _guideError = null;
      });
    }
  }

  void _setPick(_Pick? p) => setState(() {
    _pick = p;
    _guide = null;
    _recordOpen = false;
    _otherMaker = false;
    _makerName.clear();
    _ref.clear();
    _ifu.clear();
    _prefill();
  });

  void _setAnalyte(String? id) => setState(() {
    _analyteId = id;
    _guide = null;
    _recordOpen = false;
    _analyteQuery.clear();
    _aq = '';
    _prefill();
  });

  bool get _guideReady =>
      _pick != null &&
      _analyteId != null &&
      _reagentMaker.isNotEmpty &&
      _ref.text.trim().isNotEmpty &&
      _ifu.text.trim().isNotEmpty;

  void _showGuide(ContentPack pack) {
    final l = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    if (!_guideReady) {
      setState(() {
        _guideError = l.calGuideNeeds;
        _guide = null;
      });
      return;
    }
    final model = _pick!.model?.model ?? _pick!.mine?.customModel ?? '';
    setState(() {
      _guideError = null;
      _guide = matchIfu(
        pack.ifuRecords,
        IfuQuery(
          manufacturer: _instrumentMaker,
          model: model,
          reagentRef: _ref.text,
          ifuRevision: _ifu.text,
        ),
      );
    });
    // Tanlov apparatga yozib qo'yiladi (faqat saqlangan apparat uchun).
    if (_pick!.mine case final mine?) {
      context.services.instruments.rememberReagent(
        mine.id,
        _analyteId!,
        ReagentChoice(
          maker: _reagentMaker,
          ref: _ref.text.trim(),
          ifuVersion: _ifu.text.trim(),
        ),
      );
    }
  }

  Future<void> _chooseFromCatalog() async {
    final id = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _CatalogPicker(),
    );
    final model = id == null ? null : _catalog?.model(id);
    if (model != null && mounted) _setPick(_Pick(model: model));
  }

  Future<void> _addCustom() async {
    final m = await showAddCustomSheet(context);
    if (m != null && mounted) _setPick(_Pick(mine: m));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final instruments = context.services.instruments;
    return LgPage(
      title: l.calTitle,
      subtitle: l.calSubtitle,
      children: [
        CatalogGate(
          builder: (context, catalog) => ContentGate(
            builder: (context, pack) => ListenableBuilder(
              listenable: instruments,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------------------------------------------- 1. Apparat
                  LgSectionTitle(l.calStepInstrument),
                  if (_pick == null) ...[
                    Text(l.calChooseInstrument, style: text.bodyMedium),
                    if (instruments.mine.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final m in instruments.mine)
                            LgChoiceChip(
                              label: myInstrumentName(m, catalog),
                              selected: false,
                              onTap: () => _setPick(
                                _Pick(
                                  mine: m,
                                  model: m.catalogId == null
                                      ? null
                                      : catalog.model(m.catalogId!),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    LgButton.secondary(
                      label: l.calFromCatalog,
                      icon: Icons.search_rounded,
                      onPressed: _chooseFromCatalog,
                    ),
                    const SizedBox(height: 8),
                    LgButton.secondary(
                      label: l.instAddCustom,
                      icon: Icons.add_rounded,
                      onPressed: _addCustom,
                    ),
                  ] else
                    _Chosen(
                      title: _instrumentName,
                      subtitle: [
                        _pick!.model?.kind.of(lang),
                        if (_pick!.mine == null) null else l.instMine,
                        if (_pick!.mine?.isCustom ?? false) l.instCustomTag,
                      ].nonNulls.join(' · '),
                      onChange: () => _setPick(null),
                      onOpen: _pick!.model == null
                          ? null
                          : () => context.push(
                              '/lab/instruments/m/${_pick!.model!.id}',
                            ),
                    ),
                  // ----------------------------------------------- 2. Analit
                  LgSectionTitle(l.calStepAnalyte),
                  if (_analyteId case final id? when pack.analyte(id) != null)
                    _Chosen(
                      title: pack.analyte(id)!.names.of(lang),
                      onChange: () => _setAnalyte(null),
                    )
                  else ...[
                    SearchBox(
                      controller: _analyteQuery,
                      label: l.calStepAnalyte,
                      hint: l.calAnalyteHint,
                      onChanged: (v) => setState(() => _aq = v),
                    ),
                    if (_aq.trim().isNotEmpty)
                      for (final a
                          in (_search?.pack == pack
                                  ? _search!
                                  : _search = AnalyteSearch(pack))
                              .search(_aq, lang: lang)
                              .take(6))
                        LgRow(
                          title: a.names.of(lang),
                          subtitle: pack.group(a.group)?.names.of(lang),
                          icon: Icons.biotech_outlined,
                          onTap: () => _setAnalyte(a.id),
                        ),
                  ],
                  // ---------------------------------------------- 3. Reagent
                  LgSectionTitle(l.calStepReagent),
                  Text(l.calReagentMaker, style: text.titleSmall),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (_instrumentMaker case final mk?)
                        LgChoiceChip(
                          label: mk,
                          selected: !_otherMaker,
                          onTap: () {
                            setState(() => _otherMaker = false);
                            _invalidate();
                          },
                        ),
                      LgChoiceChip(
                        label: l.calManufacturerOther,
                        selected: _otherMaker || _instrumentMaker == null,
                        onTap: () {
                          setState(() => _otherMaker = true);
                          _invalidate();
                        },
                      ),
                    ],
                  ),
                  if (_otherMaker || _instrumentMaker == null)
                    LgField(
                      label: l.calReagentMakerName,
                      controller: _makerName,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _invalidate(),
                    ),
                  if (_otherMaker && _instrumentMaker != null)
                    LgNotice(l.calDifferentMaker),
                  LgField(
                    label: l.calReagentRef,
                    controller: _ref,
                    hint: 'REF',
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(_invalidate),
                  ),
                  LgField(
                    label: l.calIfuRevision,
                    controller: _ifu,
                    hint: 'IFU rev.',
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => _invalidate(),
                    onSubmitted: (_) => _showGuide(pack),
                  ),
                  if (!_otherMaker &&
                      _pick?.model != null &&
                      _analyteId != null)
                    _ValidatedHint(
                      catalog: catalog,
                      model: _pick!.model!,
                      analyteId: _analyteId!,
                      ref: _ref.text,
                    ),
                  if (_guideError != null)
                    LgNotice(_guideError!, kind: NoticeKind.error),
                  const SizedBox(height: 14),
                  LgButton(
                    label: l.calShowGuide,
                    icon: Icons.menu_book_outlined,
                    onPressed: () => _showGuide(pack),
                  ),
                  if (_guide case final g?)
                    _GuideResult(
                      match: g,
                      pack: pack,
                      catalog: catalog,
                      instrumentMakerName: _instrumentMaker,
                      reagentMakerName: _reagentMaker,
                    ),
                  if (_guide != null) ...[
                    const SizedBox(height: 12),
                    if (!_recordOpen)
                      LgButton.secondary(
                        label: l.calRecordCreate,
                        icon: Icons.edit_note_rounded,
                        onPressed: () => setState(() => _recordOpen = true),
                      )
                    else
                      _RecordForm(
                        onSave: (draft) async {
                          final messenger = ScaffoldMessenger.of(context);
                          final router = GoRouter.of(context);
                          var mine = _pick!.mine;
                          mine ??= await instruments.addFromCatalog(
                            _pick!.model!.id,
                          );
                          await instruments.addRecord(
                            instrument: mine,
                            instrumentName: myInstrumentName(mine, catalog),
                            analyteId: _analyteId!,
                            reagent: ReagentChoice(
                              maker: _reagentMaker,
                              ref: _ref.text.trim(),
                              ifuVersion: _ifu.text.trim(),
                            ),
                            calibratorName: draft.calibratorName,
                            calibratorLot: draft.lot,
                            lotExpiry: draft.lotExpiry,
                            levels: draft.levels,
                            performedOn: draft.performedOn,
                            outcome: draft.outcome,
                            note: draft.note,
                          );
                          if (!mounted) return;
                          setState(() {
                            _pick = _Pick(
                              mine: instruments.myInstrument(mine!.id),
                              model: _pick!.model,
                            );
                            _recordOpen = false;
                          });
                          // Forma yopilgach foydalanuvchi sahifa pastida
                          // qoladi — jurnalga to'g'ridan-to'g'ri o'tish.
                          messenger
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(l.calRecordSaved),
                                action: SnackBarAction(
                                  label: l.calLog,
                                  onPressed: () =>
                                      router.push('/lab/calibration/log'),
                                ),
                              ),
                            );
                        },
                      ),
                  ],
                  const SizedBox(height: 10),
                  LgRow(
                    title: l.calLog,
                    subtitle: l.calLogSub,
                    icon: Icons.fact_check_outlined,
                    divider: false,
                    onTap: () => context.push('/lab/calibration/log'),
                  ),
                ],
              ),
            ),
          ),
        ),
        LgNotice(l.calBrandWarning, kind: NoticeKind.info),
        LgSectionTitle(l.calWorkflow),
        LgSteps([
          l.calStep1,
          l.calStep2,
          l.calStep3,
          l.calStep4,
          l.calStep5,
          l.calStep6,
        ]),
        const SizedBox(height: 8),
        Text(l.calNoServiceCodes, style: text.bodySmall),
      ],
    );
  }
}

class _Chosen extends StatelessWidget {
  const _Chosen({
    required this.title,
    required this.onChange,
    this.subtitle,
    this.onOpen,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onChange;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    return LgPanel(
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleMedium),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(subtitle!, style: text.bodySmall),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: l.calChange,
            onPressed: onChange,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

class _CatalogPicker extends StatefulWidget {
  const _CatalogPicker();

  @override
  State<_CatalogPicker> createState() => _CatalogPickerState();
}

class _CatalogPickerState extends State<_CatalogPicker> {
  final _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final catalog = context.services.instruments.catalog!;
    final results = _query.trim().isEmpty
        ? catalog.models
        : catalog.search(_query);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchBox(
                controller: _q,
                label: l.instSearchLabel,
                hint: l.instSearchHint,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? LgStateView(
                      kind: StateKind.empty,
                      title: l.instNoResultsTitle,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final m = results[i];
                        return LgRow(
                          title: '${catalog.maker(m.makerId).name} ${m.model}',
                          subtitle: m.kind.of(lang),
                          icon: categoryIcon(m.category),
                          divider: i < results.length - 1,
                          onTap: () => Navigator.of(context).pop(m.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rasmiy manbada apparatda sozlamasi bor reagentlar va kiritilgan REF
/// shu ro'yxatda bormi-yo'qmi.
class _ValidatedHint extends StatelessWidget {
  const _ValidatedHint({
    required this.catalog,
    required this.model,
    required this.analyteId,
    required this.ref,
  });

  final InstrumentCatalog catalog;
  final InstrumentModel model;
  final String analyteId;
  final String ref;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final list = model.reagentsFor(analyteId);
    if (list.isEmpty) return const SizedBox.shrink();
    final src = catalog.sources[list.first.sourceId];
    final doc = src?.docRef ?? src?.title ?? '';
    final entered = ref.trim().toUpperCase();
    final listed = list.any(
      (r) => r.refs.any((x) => x.toUpperCase() == entered),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgNotice(
          [for (final r in list) '${r.name} — REF ${r.refs.join(', ')}']
              .join('\n'),
          kind: NoticeKind.info,
          title: l.calValidated(doc),
        ),
        if (entered.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              listed ? l.calRefListed : l.calRefNotListed,
              style: text.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _GuideResult extends StatelessWidget {
  const _GuideResult({
    required this.match,
    required this.pack,
    required this.catalog,
    required this.instrumentMakerName,
    required this.reagentMakerName,
  });

  final IfuMatch match;
  final ContentPack pack;
  final InstrumentCatalog catalog;
  final String? instrumentMakerName;
  final String reagentMakerName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    if (match.record case final r?) {
      return LgNotice(
        pack.analyte(r.analyteId)?.names.of(lang) ?? r.analyteId,
        kind: NoticeKind.info,
        title: l.calGuideFound,
      );
    }
    // Reagent va apparat ishlab chiqaruvchilarining hujjat portallari.
    InstrumentMaker? find(String? name) {
      final n = normalizeInstrumentQuery(name ?? '');
      if (n.isEmpty) return null;
      return catalog.makers
          .where(
            (m) =>
                normalizeInstrumentQuery(m.name) == n ||
                normalizeInstrumentQuery(m.id) == n ||
                normalizeInstrumentQuery(m.name).startsWith(n),
          )
          .firstOrNull;
    }

    final portals = <InstrumentMaker>{
      ?find(reagentMakerName),
      ?find(instrumentMakerName),
    }.where((m) => m.docs != null).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgNotice(l.calGuideNoneBody, title: l.calGuideNoneTitle),
        LgSteps([
          l.calGuide1,
          l.calGuide2,
          l.calGuide3,
          l.calGuide4,
          l.calGuide5,
        ]),
        if (portals.isNotEmpty) ...[
          LgSectionTitle(l.calDocsWhere),
          for (final (i, m) in portals.indexed)
            LgRow(
              title: m.docs!.name,
              subtitle: [
                m.name,
                switch (m.docs!.login) {
                  true => l.instLoginYes,
                  false => l.instLoginNo,
                  null => l.instLoginUnknown,
                },
              ].join(' · '),
              icon: Icons.menu_book_outlined,
              divider: i < portals.length - 1,
              onTap: () => openExternalLink(context, m.docs!.url),
            ),
        ],
      ],
    );
  }
}

class _RecordDraft {
  const _RecordDraft({
    required this.lot,
    required this.levels,
    required this.performedOn,
    required this.outcome,
    this.calibratorName,
    this.lotExpiry,
    this.note,
  });

  final String lot;
  final List<CalibratorLevel> levels;
  final DateTime performedOn;
  final CalibrationOutcome outcome;
  final String? calibratorName;
  final DateTime? lotExpiry;
  final String? note;
}

class _LevelFields {
  _LevelFields(String name) : name = TextEditingController(text: name);

  final TextEditingController name;
  final value = TextEditingController();
  final unit = TextEditingController();

  void dispose() {
    name.dispose();
    value.dispose();
    unit.dispose();
  }
}

class _RecordForm extends StatefulWidget {
  const _RecordForm({required this.onSave});

  final Future<void> Function(_RecordDraft draft) onSave;

  @override
  State<_RecordForm> createState() => _RecordFormState();
}

class _RecordFormState extends State<_RecordForm> {
  final _calibrator = TextEditingController();
  final _lot = TextEditingController();
  final _note = TextEditingController();
  final List<_LevelFields> _levels = [_LevelFields('1')];
  DateTime _performedOn = DateTime.now();
  DateTime? _lotExpiry;
  CalibrationOutcome _outcome = CalibrationOutcome.accepted;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_calibrator, _lot, _note]) {
      c.dispose();
    }
    for (final f in _levels) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({required bool expiry}) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: expiry ? (_lotExpiry ?? now) : _performedOn,
      firstDate: DateTime(now.year - 2),
      lastDate: expiry ? DateTime(now.year + 5) : now,
    );
    if (d == null || !mounted) return;
    setState(() => expiry ? _lotExpiry = d : _performedOn = d);
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    if (_lot.text.trim().isEmpty) {
      setState(() => _error = l.calLotRequired);
      return;
    }
    final levels = <CalibratorLevel>[];
    for (final f in _levels) {
      final v = parseFieldNumber(context, f.value.text);
      if (f.name.text.trim().isEmpty ||
          v == null ||
          f.unit.text.trim().isEmpty) {
        setState(() => _error = l.calLevelInvalid);
        return;
      }
      levels.add(
        CalibratorLevel(
          name: f.name.text.trim(),
          value: v,
          unit: f.unit.text.trim(),
        ),
      );
    }
    setState(() {
      _error = null;
      _busy = true;
    });
    try {
      await widget.onSave(
        _RecordDraft(
          lot: _lot.text,
          levels: levels,
          performedOn: _performedOn,
          outcome: _outcome,
          calibratorName: _calibrator.text,
          lotExpiry: _lotExpiry,
          note: _note.text,
        ),
      );
    } on Object catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateFormat.yMd(locale);
    return LgPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.calRecordTitle, style: text.titleMedium),
          LgField(
            label: l.calCalibratorName,
            controller: _calibrator,
            textInputAction: TextInputAction.next,
          ),
          LgField(
            label: l.calCalibratorLot,
            controller: _lot,
            hint: 'LOT',
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _pickDate(expiry: true),
            icon: const Icon(Icons.event_outlined),
            label: Text(
              _lotExpiry == null
                  ? l.calLotExpiry
                  : '${l.calLotExpiry}: ${date.format(_lotExpiry!)}',
            ),
          ),
          LgSectionTitle(l.calLevels),
          Text(l.calValuesFromSheet, style: text.bodySmall),
          for (final (i, f) in _levels.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 56,
                    child: LgField(label: l.calLevelName, controller: f.name),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: LgField(
                      label: l.calLevelValue,
                      controller: f.value,
                      keyboardType: _decimalKeyboard,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: LgField(
                      label: l.calLevelUnit,
                      controller: f.unit,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  if (_levels.length > 1)
                    IconButton(
                      tooltip: l.calRemoveLevel,
                      onPressed: () => setState(() {
                        _levels.removeAt(i).dispose();
                      }),
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _levels.length >= 8
                  ? null
                  : () => setState(
                      () => _levels.add(_LevelFields('${_levels.length + 1}')),
                    ),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.calAddLevel),
            ),
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => _pickDate(expiry: false),
            icon: const Icon(Icons.today_outlined),
            label: Text('${l.calPerformedOn}: ${date.format(_performedOn)}'),
          ),
          const SizedBox(height: 10),
          Text(l.calOutcome, style: text.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final o in CalibrationOutcome.values)
                LgChoiceChip(
                  label: outcomeLabel(o, l),
                  selected: _outcome == o,
                  onTap: () => setState(() => _outcome = o),
                ),
            ],
          ),
          LgField(
            label: l.calNote,
            controller: _note,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
          ),
          if (_error != null) LgNotice(_error!, kind: NoticeKind.error),
          const SizedBox(height: 12),
          LgButton(
            label: l.calRecordSave,
            icon: Icons.save_outlined,
            busy: _busy,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

String outcomeLabel(CalibrationOutcome o, AppLocalizations l) => switch (o) {
  CalibrationOutcome.accepted => l.calOutcomeAccepted,
  CalibrationOutcome.rejected => l.calOutcomeRejected,
  CalibrationOutcome.pending => l.calOutcomePending,
};

LgTone _outcomeTone(CalibrationOutcome o) => switch (o) {
  CalibrationOutcome.accepted => LgTone.brand,
  CalibrationOutcome.rejected => LgTone.warning,
  CalibrationOutcome.pending => LgTone.neutral,
};

class CalibrationLogScreen extends StatelessWidget {
  const CalibrationLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final instruments = context.services.instruments;
    final date = DateFormat.yMd(locale);
    return LgPage(
      title: l.calLog,
      subtitle: l.calLogSub,
      children: [
        ContentGate(
          builder: (context, pack) => ListenableBuilder(
            listenable: instruments,
            builder: (context, _) {
              final records = instruments.records;
              if (records.isEmpty) {
                return LgStateView(
                  kind: StateKind.empty,
                  title: l.calLogEmpty,
                  message: l.calLogEmptyBody,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, r) in records.indexed)
                    LgRow(
                      title:
                          '${pack.analyte(r.analyteId)?.names.of(lang) ?? r.analyteId} · '
                          '${date.format(r.performedOn)}',
                      subtitle:
                          '${r.instrumentName} · ${l.calLot} ${r.calibratorLot} · '
                          '${outcomeLabel(r.outcome, l)}',
                      icon: Icons.fact_check_outlined,
                      divider: i < records.length - 1,
                      onTap: () => context.push('/lab/calibration/log/${r.id}'),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class CalibrationRecordScreen extends StatelessWidget {
  const CalibrationRecordScreen({super.key, required this.recordId});

  final String recordId;

  Future<void> _delete(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final instruments = context.services.instruments;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.calDeleteRecord),
        content: Text(l.calDeleteRecordConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(d).pop(false),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(d).pop(true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await instruments.removeRecord(recordId);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final text = Theme.of(context).textTheme;
    final date = DateFormat.yMd(locale);
    final r = context.services.instruments.records
        .where((x) => x.id == recordId)
        .firstOrNull;
    if (r == null) {
      return LgPage(
        title: l.calRecordTitle,
        children: [LgStateView(kind: StateKind.empty, title: l.calLogEmpty)],
      );
    }
    final analyte = context.services.content.pack?.analyte(r.analyteId);
    return LgPage(
      title: analyte?.names.of(lang) ?? r.analyteId,
      subtitle: date.format(r.performedOn),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: LgTag(
            outcomeLabel(r.outcome, l),
            tone: _outcomeTone(r.outcome),
          ),
        ),
        const SizedBox(height: 8),
        LgPanel(
          child: Column(
            children: [
              LgMetric(label: l.calDetailInstrument, value: r.instrumentName),
              if (r.manualVersion != null)
                LgMetric(label: l.calDetailManual, value: r.manualVersion!),
              LgMetric(label: l.calReagentMaker, value: r.reagent.maker),
              LgMetric(label: l.calReagentRef, value: r.reagent.ref),
              LgMetric(label: l.calIfuRevision, value: r.reagent.ifuVersion),
              if (r.calibratorName != null)
                LgMetric(
                  label: l.calDetailCalibrator,
                  value: r.calibratorName!,
                ),
              LgMetric(label: l.calCalibratorLot, value: r.calibratorLot),
              if (r.lotExpiry != null)
                LgMetric(
                  label: l.calDetailLotExpiry,
                  value: date.format(r.lotExpiry!),
                ),
            ],
          ),
        ),
        LgSectionTitle(l.calLevels),
        LgPanel(
          child: Column(
            children: [
              for (final lv in r.levels)
                LgMetric(
                  label: '${l.calLevelName} ${lv.name}',
                  value: '${formatResult(lv.value, locale)} ${lv.unit}',
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(l.calUserEntered, style: text.bodySmall),
        ),
        if (r.note != null) ...[
          LgSectionTitle(l.calNote),
          Text(r.note!, style: text.bodyLarge),
        ],
        const SizedBox(height: 18),
        LgButton.secondary(
          label: l.calDeleteRecord,
          icon: Icons.delete_outline_rounded,
          onPressed: () => _delete(context),
        ),
        SizedBox(height: LgSpace.md),
      ],
    );
  }
}
