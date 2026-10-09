import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../app/widgets/links.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../content/ui/tests_screen.dart' show SearchBox;
import '../partners/partner_widgets.dart';
import 'instrument_catalog.dart';
import 'instrument_image.dart';
import 'instruments_controller.dart';

IconData categoryIcon(InstrumentCategory c) => switch (c) {
  InstrumentCategory.chemistry => Icons.science_outlined,
  InstrumentCategory.hematology => Icons.bloodtype_outlined,
  InstrumentCategory.immunoassay => Icons.biotech_outlined,
  InstrumentCategory.urinalysis => Icons.water_drop_outlined,
};

/// “Mindray BS-240 · 1-xona” kabi to'liq nom.
String myInstrumentName(MyInstrument m, InstrumentCatalog? catalog) {
  final model = m.catalogId == null ? null : catalog?.model(m.catalogId!);
  final base = model != null
      ? '${catalog!.maker(model.makerId).name} ${model.model}'
      : '${m.customMaker ?? ''} ${m.customModel ?? ''}'.trim();
  return m.label == null ? base : '$base · ${m.label}';
}

/// Katalog yuklanguncha kutadi; buzilgan bo'lsa — xato va qayta urinish.
class CatalogGate extends StatefulWidget {
  const CatalogGate({super.key, required this.builder});

  final Widget Function(BuildContext context, InstrumentCatalog catalog)
  builder;

  @override
  State<CatalogGate> createState() => _CatalogGateState();
}

class _CatalogGateState extends State<CatalogGate> {
  @override
  void initState() {
    super.initState();
    context.services.instruments.ensureCatalog();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.services.instruments;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final catalog = c.catalog;
        if (catalog != null) return widget.builder(context, catalog);
        if (c.state == CatalogLoadState.failed) {
          return LgStateView(
            kind: StateKind.error,
            title: l.instCatalogError,
            actionLabel: l.actionRetry,
            onAction: c.retry,
          );
        }
        return const LgStateView(kind: StateKind.loading, title: '');
      },
    );
  }
}

/// Yo'nalish → ishlab chiqaruvchi → model → karta. Yuqorida qidiruv va
/// saqlangan apparatlar.
class InstrumentsScreen extends StatefulWidget {
  const InstrumentsScreen({super.key});

  @override
  State<InstrumentsScreen> createState() => _InstrumentsScreenState();
}

class _InstrumentsScreenState extends State<InstrumentsScreen> {
  final _query = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final instruments = context.services.instruments;
    return LgPage(
      title: l.insTitle,
      subtitle: l.labInstrumentsSub,
      children: [
        SearchBox(
          controller: _query,
          label: l.instSearchLabel,
          hint: l.instSearchHint,
          onChanged: (v) => setState(() => _q = v),
        ),
        CatalogGate(
          builder: (context, catalog) => ListenableBuilder(
            listenable: instruments,
            builder: (context, _) {
              if (_q.trim().isNotEmpty) {
                final results = catalog.search(_q);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (results.isEmpty)
                      LgStateView(
                        kind: StateKind.empty,
                        title: l.instNoResultsTitle,
                        message: l.instNoResultsBody,
                      ),
                    for (final (i, m) in results.indexed)
                      ModelRow(
                        catalog: catalog,
                        model: m,
                        showMaker: true,
                        divider: i < results.length - 1,
                      ),
                    const SizedBox(height: 8),
                    _AddCustomRow(divider: false),
                  ],
                );
              }
              final planned = catalog.plannedMakers;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (instruments.mine.isNotEmpty) ...[
                    LgSectionTitle(l.instMine),
                    for (final (i, m) in instruments.mine.indexed)
                      _MyInstrumentRow(
                        instrument: m,
                        catalog: catalog,
                        divider: i < instruments.mine.length - 1,
                      ),
                  ],
                  LgSectionTitle(l.instDirections),
                  for (final (i, c) in catalog.categories.indexed)
                    LgRow(
                      title: c.name.of(lang),
                      subtitle:
                          '${c.subtitle.of(lang)} · '
                          '${l.instModelsCount(catalog.inCategory(c.category).length)}',
                      icon: categoryIcon(c.category),
                      divider: i < catalog.categories.length - 1,
                      onTap: () =>
                          context.push('/lab/instruments/c/${c.category.name}'),
                    ),
                  const SizedBox(height: 6),
                  _AddCustomRow(divider: true),
                  LgRow(
                    title: l.calLog,
                    subtitle: l.calLogSub,
                    icon: Icons.fact_check_outlined,
                    divider: false,
                    onTap: () => context.push('/lab/calibration/log'),
                  ),
                  if (planned.isNotEmpty)
                    LgNotice(
                      l.instPlannedBody,
                      kind: NoticeKind.info,
                      title: l.instPlanned(
                        planned.map((m) => m.name).join(', '),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    l.instCatalogNote(catalog.sources.values.first.accessed),
                    style: text.bodySmall,
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

class ModelRow extends StatelessWidget {
  const ModelRow({
    super.key,
    required this.catalog,
    required this.model,
    this.showMaker = false,
    this.divider = true,
    this.onTap,
  });

  final InstrumentCatalog catalog;
  final InstrumentModel model;
  final bool showMaker;
  final bool divider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final maker = catalog.maker(model.makerId).name;
    return LgRow(
      title: showMaker ? '$maker ${model.model}' : model.model,
      subtitle: model.kind.of(lang),
      icon: categoryIcon(model.category),
      divider: divider,
      onTap: onTap ?? () => context.push('/lab/instruments/m/${model.id}'),
    );
  }
}

class _MyInstrumentRow extends StatelessWidget {
  const _MyInstrumentRow({
    required this.instrument,
    required this.catalog,
    required this.divider,
  });

  final MyInstrument instrument;
  final InstrumentCatalog catalog;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final model = instrument.catalogId == null
        ? null
        : catalog.model(instrument.catalogId!);
    final category = model?.category ?? instrument.customCategory;
    return LgRow(
      title: myInstrumentName(instrument, catalog),
      subtitle: [
        model?.kind.of(lang) ??
            (category == null
                ? null
                : catalog.category(category).name.of(lang)),
        if (instrument.isCustom) l.instCustomTag,
        if (instrument.serial != null) 'SN ${instrument.serial}',
      ].nonNulls.join(' · '),
      icon: category == null
          ? Icons.precision_manufacturing_outlined
          : categoryIcon(category),
      divider: divider,
      onTap: () => model != null
          ? context.push('/lab/instruments/m/${model.id}')
          : showMyInstrumentActions(context, instrument),
    );
  }
}

/// Katalogda yo'q apparat uchun amallar (kalibrlash, QC, olib tashlash).
Future<void> showMyInstrumentActions(
  BuildContext context,
  MyInstrument instrument,
) async {
  final l = AppLocalizations.of(context);
  final instruments = context.services.instruments;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              myInstrumentName(instrument, instruments.catalog),
              style: Theme.of(sheet).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LgButton(
              label: l.instCalibrate,
              icon: Icons.tune_rounded,
              onPressed: () {
                Navigator.of(sheet).pop();
                context.push('/lab/calibration?mine=${instrument.id}');
              },
            ),
            const SizedBox(height: 8),
            LgButton.secondary(
              label: l.instQc,
              icon: Icons.show_chart_rounded,
              onPressed: () {
                Navigator.of(sheet).pop();
                context.push('/lab/qc');
              },
            ),
            const SizedBox(height: 8),
            LgButton.secondary(
              label: l.instRemove,
              icon: Icons.delete_outline_rounded,
              onPressed: () async {
                Navigator.of(sheet).pop();
                if (await _confirmRemove(context) == true) {
                  await instruments.remove(instrument.id);
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool?> _confirmRemove(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(l.instRemove),
      content: Text(l.instRemoveConfirm),
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
}

class _AddCustomRow extends StatelessWidget {
  const _AddCustomRow({required this.divider});

  final bool divider;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgRow(
      title: l.instAddCustom,
      subtitle: l.instAddCustomSub,
      icon: Icons.add_circle_outline_rounded,
      divider: divider,
      onTap: () => showAddCustomSheet(context),
    );
  }
}

/// Katalogda yo'q apparatni qo'shish. Saqlangan apparatni qaytaradi.
Future<MyInstrument?> showAddCustomSheet(BuildContext context) =>
    showModalBottomSheet<MyInstrument>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _InstrumentForm(),
    );

/// Katalog modelini “Mening apparatim” sifatida saqlash.
Future<MyInstrument?> showSaveInstrumentSheet(
  BuildContext context,
  InstrumentModel model,
) => showModalBottomSheet<MyInstrument>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _InstrumentForm(model: model),
);

class _InstrumentForm extends StatefulWidget {
  const _InstrumentForm({this.model});

  /// `null` — katalogda yo'q apparat (ishlab chiqaruvchi va model kiritiladi).
  final InstrumentModel? model;

  @override
  State<_InstrumentForm> createState() => _InstrumentFormState();
}

class _InstrumentFormState extends State<_InstrumentForm> {
  final _maker = TextEditingController();
  final _model = TextEditingController();
  final _label = TextEditingController();
  final _serial = TextEditingController();
  final _manual = TextEditingController();
  InstrumentCategory _category = InstrumentCategory.chemistry;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_maker, _model, _label, _serial, _manual]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final instruments = context.services.instruments;
    final model = widget.model;
    if (model == null &&
        (_maker.text.trim().isEmpty || _model.text.trim().isEmpty)) {
      setState(() => _error = l.instCustomRequired);
      return;
    }
    setState(() => _busy = true);
    try {
      final saved = model != null
          ? await instruments.addFromCatalog(
              model.id,
              label: _label.text,
              serial: _serial.text,
              manualVersion: _manual.text,
            )
          : await instruments.addCustom(
              maker: _maker.text,
              model: _model.text,
              category: _category,
              label: _label.text,
              serial: _serial.text,
              manualVersion: _manual.text,
            );
      if (mounted) Navigator.of(context).pop(saved);
    } on Object catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final catalog = context.services.instruments.catalog;
    final model = widget.model;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                model == null ? l.instAddCustom : l.instSaveTitle,
                style: text.titleMedium,
              ),
              if (model != null && catalog != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${catalog.maker(model.makerId).name} ${model.model}',
                    style: text.bodyMedium,
                  ),
                ),
              if (model == null) ...[
                LgField(
                  label: l.instMaker,
                  controller: _maker,
                  textInputAction: TextInputAction.next,
                ),
                LgField(
                  label: l.instModel,
                  controller: _model,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Text(l.instCategory, style: text.titleSmall),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in InstrumentCategory.values)
                      LgChoiceChip(
                        label: catalog?.category(c).name.of(lang) ?? c.name,
                        selected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ),
                  ],
                ),
              ],
              LgField(
                label: l.instLabel,
                hint: l.instLabelHint,
                controller: _label,
                textInputAction: TextInputAction.next,
              ),
              LgField(
                label: l.instSerial,
                controller: _serial,
                textInputAction: TextInputAction.next,
              ),
              LgField(
                label: l.instManualVersion,
                hint: l.instManualVersionHint,
                controller: _manual,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              ),
              if (_error != null) LgNotice(_error!, kind: NoticeKind.error),
              const SizedBox(height: 14),
              LgButton(label: l.instSave, busy: _busy, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

/// Yo'nalish ichidagi ishlab chiqaruvchilar.
class InstrumentMakersScreen extends StatelessWidget {
  const InstrumentMakersScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final cat = InstrumentCategory.values
        .where((c) => c.name == category)
        .firstOrNull;
    return CatalogGate(
      builder: (context, catalog) {
        if (cat == null) {
          return LgPage(
            title: l.insTitle,
            children: [
              LgStateView(kind: StateKind.empty, title: l.instNoResultsTitle),
            ],
          );
        }
        final makers = catalog.makersIn(cat);
        return LgPage(
          title: catalog.category(cat).name.of(lang),
          subtitle: l.instChooseMaker,
          children: [
            for (final (i, (mk, n)) in makers.indexed)
              LgRow(
                title: mk.name,
                subtitle: l.instModelsCount(n),
                icon: Icons.factory_outlined,
                divider: i < makers.length - 1,
                onTap: () =>
                    context.push('/lab/instruments/c/${cat.name}/${mk.id}'),
              ),
            // Yo'nalishning bezak chizmasi — ro'yxatdan keyin, “sxematik”
            // izohi bilan (model kartasida ishlatilmaydi).
            const SizedBox(height: 16),
            CategoryIllustration(asset: catalog.category(cat).illustration),
            // Reklama: ro'yxatdan keyin, alohida va “Hamkor” yorlig'i bilan.
            CategoryPartnerCards(catalog: catalog, category: cat),
          ],
        );
      },
    );
  }
}

/// Ishlab chiqaruvchining shu yo'nalishdagi modellari.
class InstrumentModelsScreen extends StatelessWidget {
  const InstrumentModelsScreen({
    super.key,
    required this.category,
    required this.makerId,
  });

  final String category;
  final String makerId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final cat = InstrumentCategory.values
        .where((c) => c.name == category)
        .firstOrNull;
    return CatalogGate(
      builder: (context, catalog) {
        final models = cat == null
            ? const <InstrumentModel>[]
            : catalog.inCategory(cat, makerId: makerId);
        final maker = catalog.makers.where((m) => m.id == makerId).firstOrNull;
        return LgPage(
          title: maker?.name ?? l.insTitle,
          subtitle: cat == null
              ? null
              : '${catalog.category(cat).name.of(lang)} · ${l.instChooseModel}',
          children: [
            if (models.isEmpty)
              LgStateView(kind: StateKind.empty, title: l.instNoResultsTitle),
            for (final (i, m) in models.indexed)
              ModelRow(
                catalog: catalog,
                model: m,
                divider: i < models.length - 1,
              ),
          ],
        );
      },
    );
  }
}

/// Apparat kartasi: aniq nom, rasm (litsenziyali bo'lsa), holat, vazifa,
/// prinsip, faktlar, qo'llanma, parvarish, manbalar va amallar.
class InstrumentCardScreen extends StatelessWidget {
  const InstrumentCardScreen({super.key, required this.modelId});

  final String modelId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CatalogGate(
      builder: (context, catalog) {
        final model = catalog.model(modelId);
        if (model == null) {
          return LgPage(
            title: l.instOpenCard,
            children: [
              LgStateView(kind: StateKind.empty, title: l.instNoResultsTitle),
            ],
          );
        }
        return _InstrumentCard(catalog: catalog, model: model);
      },
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  const _InstrumentCard({required this.catalog, required this.model});

  final InstrumentCatalog catalog;
  final InstrumentModel model;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final maker = catalog.maker(model.makerId);
    final instruments = context.services.instruments;
    String sourceTitle(String id) => catalog.sources[id]?.title ?? id;
    return LgPage(
      title: model.model,
      eyebrow: maker.name,
      subtitle: model.kind.of(lang),
      children: [
        InstrumentImageBlock(
          model: model,
          officialPage: model.officialPage == null
              ? null
              : catalog.sources[model.officialPage!],
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: instruments,
          builder: (context, _) {
            final saved = instruments.savedFor(model.id);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LgButton(
                  label: l.instSaveMine,
                  icon: Icons.bookmark_add_outlined,
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final m = await showSaveInstrumentSheet(context, model);
                    if (m != null) {
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text(l.instSaved)));
                    }
                  },
                ),
                if (saved.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l.instSavedCount(saved.length),
                      style: text.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 8),
                LgButton.secondary(
                  label: l.instCalibrate,
                  icon: Icons.tune_rounded,
                  onPressed: () {
                    // Oldingi “Saqlandi” xabari keyingi sahifani yopmasin.
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    context.push(
                      saved.length == 1
                          ? '/lab/calibration?mine=${saved.single.id}'
                          : '/lab/calibration?model=${model.id}',
                    );
                  },
                ),
                const SizedBox(height: 8),
                LgButton.secondary(
                  label: l.instQc,
                  icon: Icons.show_chart_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    context.push('/lab/qc');
                  },
                ),
              ],
            );
          },
        ),
        LgSectionTitle(l.instStatusTitle),
        _StatusLadder(status: model.status),
        _Explained(
          title: l.instPurpose,
          value: model.purpose,
          catalog: catalog,
        ),
        _Explained(
          title: l.instPrinciple,
          value: model.principle,
          catalog: catalog,
        ),
        if (model.facts.isNotEmpty) ...[
          LgSectionTitle(l.instKeyFacts),
          LgPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, f) in model.facts.indexed) ...[
                  if (i > 0) const Divider(height: 18),
                  Text(f.label.of(lang), style: text.labelMedium),
                  const SizedBox(height: 2),
                  Text(f.value, style: text.bodyLarge),
                  Text(sourceTitle(f.sourceId), style: text.bodySmall),
                ],
              ],
            ),
          ),
        ],
        LgSectionTitle(l.instReagentSystem),
        Text(switch (model.reagentSystem) {
          ReagentSystemKind.open => l.instReagentOpen,
          ReagentSystemKind.partlyOpen => l.instReagentPartly,
          ReagentSystemKind.closed => l.instReagentClosed,
          ReagentSystemKind.unknown => l.instReagentUnknown,
        }, style: text.bodyLarge),
        if (model.reagentSystemQuote case final q?)
          _QuoteBox(quotes: [q], catalog: catalog),
        if (model.validatedReagents.isNotEmpty)
          _ValidatedReagents(model: model, catalog: catalog),
        LgSectionTitle(l.instMaintenance),
        if (model.maintenance.isNotEmpty) ...[
          Text(l.instMaintenanceQuotes, style: text.bodyMedium),
          _QuoteBox(quotes: model.maintenance, catalog: catalog),
        ],
        LgNotice(l.instMaintenanceNone),
        LgSectionTitle(l.instManual),
        LgTag(
          switch (model.manualAccess) {
            ManualAccess.public => l.instManualPublic,
            ManualAccess.login => l.instManualLogin,
            ManualAccess.notPublic => l.instManualNotPublic,
          },
          tone: model.manualAccess == ManualAccess.public
              ? LgTone.brand
              : LgTone.warning,
        ),
        const SizedBox(height: 8),
        Text(model.manualNote.of(lang), style: text.bodyMedium),
        if (maker.docs case final docs?)
          LgRow(
            title: docs.name,
            subtitle: [
              l.instDocsPortal,
              switch (docs.login) {
                true => l.instLoginYes,
                false => l.instLoginNo,
                null => l.instLoginUnknown,
              },
            ].join(' · '),
            icon: Icons.menu_book_outlined,
            divider: false,
            onTap: () => openExternalLink(context, docs.url),
          ),
        if (maker.docs?.note case final note?)
          Text(note.of(lang), style: text.bodySmall),
        LgSectionTitle(l.instSources),
        for (final (i, id) in model.sourceIds.indexed)
          if (catalog.sources[id] case final s?)
            LgRow(
              title: s.title,
              subtitle: [?s.docRef, l.instAccessed(s.accessed)].join(' · '),
              icon: Icons.link_rounded,
              divider: i < model.sourceIds.length - 1,
              onTap: () => openExternalLink(context, s.url),
            ),
        // Reklama: barcha katalog ma'lumotidan keyin, alohida bo'lim.
        InstrumentPartnersSection(model: model),
      ],
    );
  }
}

class _StatusLadder extends StatelessWidget {
  const _StatusLadder({required this.status});

  final InstrumentStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = LgPalette.of(context);
    final text = Theme.of(context).textTheme;
    final steps = [
      (InstrumentStatus.deviceInfo, l.instStatusDevice, l.instStatusDeviceSub),
      (InstrumentStatus.ifuAvailable, l.instStatusIfu, l.instStatusIfuSub),
      (
        InstrumentStatus.expertReviewed,
        l.instStatusExpert,
        l.instStatusExpertSub,
      ),
    ];
    return LgPanel(
      child: Column(
        children: [
          for (final (i, (s, title, sub)) in steps.indexed) ...[
            if (i > 0) const SizedBox(height: 10),
            Semantics(
              label:
                  '$title: ${status.index >= s.index ? l.instStatusDone : l.instStatusNotYet}',
              excludeSemantics: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    status.index >= s.index
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: status.index >= s.index ? p.brand : p.sub,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.index >= s.index
                              ? title
                              : '$title — ${l.instStatusNotYet}',
                          style: text.titleSmall,
                        ),
                        Text(sub, style: text.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Explained extends StatelessWidget {
  const _Explained({
    required this.title,
    required this.value,
    required this.catalog,
  });

  final String title;
  final ExplainedText? value;
  final InstrumentCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final v = value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LgSectionTitle(title),
        if (v == null)
          Text(l.instNotStated, style: text.bodyMedium)
        else ...[
          Text(v.text.of(lang), style: text.bodyLarge),
          _QuoteBox(quotes: v.quotes, catalog: catalog),
        ],
      ],
    );
  }
}

/// Rasmiy iqtiboslar (asl tilda) va manba nomi.
class _QuoteBox extends StatelessWidget {
  const _QuoteBox({required this.quotes, required this.catalog});

  final List<SourcedQuote> quotes;
  final InstrumentCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.soft,
        borderRadius: BorderRadius.circular(LgRadius.button),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.instOfficialText, style: text.labelSmall),
          for (final q in quotes) ...[
            const SizedBox(height: 6),
            Text(
              '“${q.quote}”',
              style: text.bodyMedium!.copyWith(fontStyle: FontStyle.italic),
            ),
            Text(
              catalog.sources[q.sourceId]?.title ?? q.sourceId,
              style: text.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _ValidatedReagents extends StatelessWidget {
  const _ValidatedReagents({required this.model, required this.catalog});

  final InstrumentModel model;
  final InstrumentCatalog catalog;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final list = model.validatedReagents;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          l.instValidatedReagents(list.length),
          style: text.titleSmall,
        ),
        subtitle: Text(
          catalog.sources[list.first.sourceId]?.title ?? '',
          style: text.bodySmall,
        ),
        children: [
          for (final r in list)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(r.name, style: text.bodyMedium)),
                  const SizedBox(width: 8),
                  Text(
                    'REF ${r.refs.join(', ')}',
                    style: text.bodySmall!.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
