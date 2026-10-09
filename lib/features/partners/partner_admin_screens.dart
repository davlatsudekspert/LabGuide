import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_scope.dart';
import '../../app/widgets/lg_page.dart';
import '../../core/backend/backend_models.dart';
import '../../core/backend/partner_models.dart';
import '../../design/tokens.dart';
import '../../design/widgets/lg_widgets.dart';
import '../../l10n/gen/app_localizations.dart';
import '../admin/admin_screens.dart' show AdminGate;
import '../content/ui/tests_screen.dart' show SearchBox;
import '../instruments/instrument_catalog.dart';
import '../instruments/instrument_screens.dart' show CatalogGate, categoryIcon;
import '../support/support_screens.dart'
    show SignedInGate, backendErrorText, formatWhen;
import 'become_partner_screen.dart';
import 'partner_widgets.dart';

// Admin: hamkorlarni yaratish/tahrirlash/e'lon qilish/to'xtatish, katalogga
// bog'lash, davr, statistika va hamkorlik arizalari. Har ekran
// SignedInGate + AdminGate (aal2) ichida; har amal serverda qayta
// tekshiriladi va admin_audit ga yoziladi.

String _day(DateTime d, BuildContext context) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(d);

/// Ro'yxatdagi holat: e'lon qilingan bo'lsa ham muddati tugagan yoki hali
/// boshlanmagan bo'lishi mumkin.
(String, LgTone) partnerAdminStatus(
  Partner p,
  DateTime today,
  AppLocalizations l,
) => switch (p.status) {
  PartnerStatus.draft => (l.adminPartnerStatusDraft, LgTone.neutral),
  PartnerStatus.paused => (l.adminPartnerStatusPaused, LgTone.warning),
  PartnerStatus.published when today.isAfter(p.endsOn) => (
    l.adminPartnerExpired,
    LgTone.neutral,
  ),
  PartnerStatus.published when today.isBefore(p.startsOn) => (
    l.adminPartnerUpcoming,
    LgTone.warning,
  ),
  PartnerStatus.published => (l.adminPartnerStatusLive, LgTone.brand),
};

String partnerPlacementLabel(PartnerPlacement p, AppLocalizations l) =>
    switch (p) {
      PartnerPlacement.card => l.partnerPlacementCard,
      PartnerPlacement.category => l.partnerPlacementCategory,
      PartnerPlacement.labHome => l.partnerPlacementLabHome,
      PartnerPlacement.partnerPage => l.partnerPlacementPage,
    };

/// Admin ekranlari qobig'i: kirish, admin vakolati, so'ng bir marta yuklash.
class _AdminScaffold extends StatelessWidget {
  const _AdminScaffold({
    required this.title,
    required this.onLoad,
    required this.child,
  });

  final String title;
  final Future<void> Function() onLoad;
  final Widget child;

  @override
  Widget build(BuildContext context) => LgPage(
    title: title,
    showProfile: false,
    children: [
      SignedInGate(
        child: AdminGate(
          child: _LoadOnce(onLoad: onLoad, child: child),
        ),
      ),
    ],
  );
}

class _LoadOnce extends StatefulWidget {
  const _LoadOnce({required this.onLoad, required this.child});

  final Future<void> Function() onLoad;
  final Widget child;

  @override
  State<_LoadOnce> createState() => _LoadOnceState();
}

class _LoadOnceState extends State<_LoadOnce> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onLoad());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ------------------------------------------------------------- ro'yxat
class AdminPartnersScreen extends StatefulWidget {
  const AdminPartnersScreen({super.key});

  @override
  State<AdminPartnersScreen> createState() => _AdminPartnersScreenState();
}

class _AdminPartnersScreenState extends State<AdminPartnersScreen> {
  List<Partner>? _partners;
  Object? _error;

  Future<void> _load() async {
    try {
      final list = await context.services.backend.adminPartners();
      if (mounted) {
        setState(() {
          _partners = list;
          _error = null;
        });
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _open(String location) async {
    await context.push(location);
    await _load();
    // Reklama joylari ham yangilansin (admin o'zgarishni darhol ko'radi).
    if (mounted) await context.services.partners.refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final today = context.services.partners.today;
    final list = _partners;
    return _AdminScaffold(
      title: l.adminPartners,
      onLoad: _load,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LgButton(
            label: l.adminPartnerNew,
            icon: Icons.add_rounded,
            onPressed: () => _open('/profile/admin/partners/new'),
          ),
          const SizedBox(height: 8),
          Text(l.adminPartnerPublishRules, style: text.bodySmall),
          const SizedBox(height: 8),
          if (_error != null)
            LgNotice(backendErrorText(_error!, l), kind: NoticeKind.error)
          else if (list == null)
            const LgStateView(kind: StateKind.loading, title: '')
          else if (list.isEmpty)
            LgStateView(kind: StateKind.empty, title: l.adminPartnersEmpty)
          else
            for (final (i, p) in list.indexed)
              LgRow(
                title: p.name,
                subtitle: [
                  partnerKindLabel(p.kind, l),
                  '${_day(p.startsOn, context)} — ${_day(p.endsOn, context)}',
                ].join('\n'),
                icon: Icons.storefront_outlined,
                trailing: () {
                  final (label, tone) = partnerAdminStatus(p, today, l);
                  return LgTag(label, tone: tone);
                }(),
                divider: i < list.length - 1,
                onTap: () => _open('/profile/admin/partners/${p.id}'),
              ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- tahrirlash
class _ModelLink {
  _ModelLink(this.modelId, String? regNo)
    : regNo = TextEditingController(text: regNo ?? '');

  final String modelId;
  final TextEditingController regNo;
}

class AdminPartnerEditScreen extends StatefulWidget {
  const AdminPartnerEditScreen({super.key, this.partnerId});

  /// `null` — yangi hamkor.
  final String? partnerId;

  @override
  State<AdminPartnerEditScreen> createState() => _AdminPartnerEditScreenState();
}

class _AdminPartnerEditScreenState extends State<AdminPartnerEditScreen> {
  String? _id;
  Partner? _saved;
  bool _loaded = false;
  Object? _loadError;

  final _name = TextEditingController();
  final _logo = TextEditingController();
  final _summary = {
    for (final lang in const ['uz', 'ru', 'en']) lang: TextEditingController(),
  };
  final _phone = TextEditingController();
  final _telegram = TextEditingController();
  final _website = TextEditingController();
  final _email = TextEditingController();
  final _brochure = TextEditingController();
  PartnerKind _kind = PartnerKind.distributor;
  final Set<String> _regions = {};
  final Set<String> _makers = {};
  final List<_ModelLink> _models = [];
  late DateTime _starts;
  late DateTime _ends;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _id = widget.partnerId;
    final today = context.services.partners.today;
    _starts = today;
    _ends = today.add(const Duration(days: 30));
    if (_id == null) _loaded = true;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _logo,
      ..._summary.values,
      _phone,
      _telegram,
      _website,
      _email,
      _brochure,
      for (final m in _models) m.regNo,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final id = _id;
    if (id == null) return;
    try {
      final all = await context.services.backend.adminPartners();
      final p =
          all.where((x) => x.id == id).firstOrNull ??
          (throw const BackendException(BackendFailure.notFound));
      if (!mounted) return;
      setState(() {
        _fill(p);
        _loaded = true;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _loadError = e);
    }
  }

  void _fill(Partner p) {
    _saved = p;
    _name.text = p.name;
    _kind = p.kind;
    _logo.text = p.logoUrl ?? '';
    for (final e in _summary.entries) {
      e.value.text = p.summary[e.key] ?? '';
    }
    _phone.text = p.phone ?? '';
    _telegram.text = p.telegram ?? '';
    _website.text = p.website ?? '';
    _email.text = p.email ?? '';
    _brochure.text = p.brochureUrl ?? '';
    _regions
      ..clear()
      ..addAll(p.regions);
    _makers
      ..clear()
      ..addAll([
        for (final l in p.links)
          if (l.target == PartnerLinkTarget.maker) l.catalogId,
      ]);
    for (final m in _models) {
      m.regNo.dispose();
    }
    _models
      ..clear()
      ..addAll([
        for (final l in p.links)
          if (l.target == PartnerLinkTarget.model)
            _ModelLink(l.catalogId, l.registrationNo),
      ]);
    _starts = p.startsOn;
    _ends = p.endsOn;
  }

  /// Formadan qoralama; noto'g'ri bo'lsa — `null` (server bilan bir xil
  /// qoidalar).
  PartnerDraft? _draft() {
    String? opt(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    final telegram = _telegram.text.trim().isEmpty
        ? null
        : normalizeTelegram(_telegram.text);
    final d = PartnerDraft(
      name: _name.text.trim(),
      kind: _kind,
      logoUrl: opt(_logo),
      summary: {for (final e in _summary.entries) e.key: e.value.text.trim()},
      regions: [
        for (final r in uzRegionCodes)
          if (_regions.contains(r)) r,
      ],
      phone: opt(_phone),
      telegram: telegram,
      website: opt(_website),
      email: opt(_email),
      brochureUrl: opt(_brochure),
      startsOn: _starts,
      endsOn: _ends,
      links: [
        for (final m in _makers)
          PartnerLink(target: PartnerLinkTarget.maker, catalogId: m),
        for (final m in _models)
          PartnerLink(
            target: PartnerLinkTarget.model,
            catalogId: m.modelId,
            registrationNo: opt(m.regNo),
          ),
      ],
    );
    bool bad(String? v, bool Function(String) ok) => v != null && !ok(v);
    final ok =
        d.name.length >= 2 &&
        d.name.length <= 120 &&
        !d.endsOn.isBefore(d.startsOn) &&
        !bad(d.phone, isValidPartnerPhone) &&
        !bad(d.telegram, isValidTelegram) &&
        !bad(d.website, isValidHttpsUrl) &&
        !bad(d.email, isValidPartnerEmail) &&
        !bad(d.brochureUrl, isValidHttpsUrl) &&
        !bad(d.logoUrl, isValidHttpsUrl) &&
        d.summary.values.every((v) => v.length <= 300) &&
        d.links.every(
          (l) =>
              l.registrationNo == null ||
              (l.registrationNo!.length >= 3 && l.registrationNo!.length <= 60),
        );
    return ok ? d : null;
  }

  Future<bool> _save({bool quiet = false}) async {
    final l = AppLocalizations.of(context);
    final backend = context.services.backend;
    FocusScope.of(context).unfocus();
    final d = _draft();
    if (d == null) {
      setState(() => _error = l.adminPartnerInvalid);
      return false;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await backend.adminSavePartner(d, id: _id);
      _id = id;
      final all = await backend.adminPartners();
      if (!mounted) return false;
      setState(() {
        _saved = all.where((x) => x.id == id).firstOrNull;
      });
      if (!quiet) _snack(l.adminPartnerSaved);
      return true;
    } on BackendException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.failure == BackendFailure.invalid
              ? l.adminPartnerInvalid
              : backendErrorText(e, l),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setStatus(PartnerStatus status) async {
    final l = AppLocalizations.of(context);
    final backend = context.services.backend;
    if (status == PartnerStatus.published && !await _save(quiet: true)) return;
    final id = _id;
    if (id == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await backend.adminSetPartnerStatus(id, status);
      final all = await backend.adminPartners();
      if (!mounted) return;
      setState(() => _saved = all.where((x) => x.id == id).firstOrNull);
      _snack(
        status == PartnerStatus.published
            ? l.adminPartnerPublished
            : l.adminPartnerPausedMsg,
      );
      await context.services.partners.refresh(force: true);
    } on BackendException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.failure == BackendFailure.invalid
              ? l.adminPartnerInvalid
              : backendErrorText(e, l),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _uploadLogo() async {
    final l = AppLocalizations.of(context);
    final backend = context.services.backend;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final mime =
        file.mimeType ??
        (file.name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');
    if (bytes.length > 1024 * 1024 ||
        !SupportAttachment.allowedTypes.contains(mime)) {
      if (mounted) setState(() => _error = l.adminPartnerLogoTooLarge);
      return;
    }
    try {
      final url = await backend.adminUploadPartnerLogo(bytes, mime);
      if (mounted) setState(() => _logo.text = url);
    } on Object catch (e) {
      if (mounted) setState(() => _error = backendErrorText(e, l));
    }
  }

  Future<void> _pickDate({required bool start}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _starts : _ends,
      firstDate: DateTime.utc(2025),
      lastDate: DateTime.utc(2035),
    );
    if (picked == null || !mounted) return;
    final day = DateTime.utc(picked.year, picked.month, picked.day);
    setState(() {
      if (start) {
        _starts = day;
        if (_ends.isBefore(day)) _ends = day;
      } else {
        _ends = day;
      }
    });
  }

  Future<void> _addModel(InstrumentCatalog catalog) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ModelPicker(
        catalog: catalog,
        exclude: {for (final m in _models) m.modelId},
      ),
    );
    if (picked != null && mounted) {
      setState(() => _models.add(_ModelLink(picked, null)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _AdminScaffold(
      title: widget.partnerId == null && _saved == null
          ? l.adminPartnerNew
          : (_saved?.name ?? l.adminPartners),
      onLoad: _load,
      child: CatalogGate(
        builder: (context, catalog) {
          if (_loadError != null) {
            return LgStateView(
              kind: StateKind.error,
              title: backendErrorText(_loadError!, l),
            );
          }
          if (!_loaded) {
            return const LgStateView(kind: StateKind.loading, title: '');
          }
          return _form(context, catalog);
        },
      ),
    );
  }

  Widget _form(BuildContext context, InstrumentCatalog catalog) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = Theme.of(context).textTheme;
    final today = context.services.partners.today;
    final saved = _saved;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (saved != null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: () {
              final (label, tone) = partnerAdminStatus(saved, today, l);
              return LgTag(label, tone: tone);
            }(),
          ),
        LgField(
          label: l.adminPartnerName,
          controller: _name,
          maxLength: 120,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        Text(l.adminPartnerKind, style: text.titleSmall),
        const SizedBox(height: 7),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final k in PartnerKind.values)
              LgChoiceChip(
                label: partnerKindLabel(k, l),
                selected: _kind == k,
                onTap: () => setState(() => _kind = k),
              ),
          ],
        ),
        LgField(
          label: l.adminPartnerLogo,
          controller: _logo,
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 8),
        LgButton.secondary(
          label: l.adminPartnerLogoUpload,
          icon: Icons.image_outlined,
          onPressed: _busy ? null : _uploadLogo,
        ),
        for (final e in _summary.entries)
          LgField(
            label: l.adminPartnerSummary(e.key.toUpperCase()),
            controller: e.value,
            maxLines: 3,
            maxLength: 300,
            keyboardType: TextInputType.multiline,
          ),
        LgSectionTitle(l.adminPartnerRegions),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final r in uzRegionCodes)
              LgChoiceChip(
                label: uzRegionName(r, lang),
                selected: _regions.contains(r),
                onTap: () => setState(
                  () => _regions.contains(r)
                      ? _regions.remove(r)
                      : _regions.add(r),
                ),
              ),
          ],
        ),
        LgSectionTitle(l.partnerContacts),
        LgField(
          label: l.partnerFormPhone,
          controller: _phone,
          hint: '+998 __ ___ __ __',
          keyboardType: TextInputType.phone,
        ),
        LgField(label: l.adminPartnerTelegram, controller: _telegram),
        LgField(
          label: l.adminPartnerWebsite,
          controller: _website,
          keyboardType: TextInputType.url,
        ),
        LgField(
          label: l.partnerFormEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
        ),
        LgField(
          label: l.adminPartnerBrochure,
          controller: _brochure,
          keyboardType: TextInputType.url,
        ),
        LgSectionTitle(l.adminPartnerLinks),
        Text(l.adminPartnerMakers, style: text.titleSmall),
        const SizedBox(height: 7),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final mk in catalog.makers)
              LgChoiceChip(
                label: mk.name,
                selected: _makers.contains(mk.id),
                onTap: () => setState(
                  () => _makers.contains(mk.id)
                      ? _makers.remove(mk.id)
                      : _makers.add(mk.id),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(l.adminPartnerModels, style: text.titleSmall),
        for (final m in _models)
          if (catalog.model(m.modelId) case final model?)
            LgPanel(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${catalog.maker(model.makerId).name} ${model.model}',
                          style: text.titleSmall,
                        ),
                      ),
                      IconButton(
                        tooltip: l.adminPartnerUnlink,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() {
                          _models.remove(m);
                          m.regNo.dispose();
                        }),
                      ),
                    ],
                  ),
                  LgField(
                    label: l.adminPartnerRegNo,
                    controller: m.regNo,
                    maxLength: 60,
                  ),
                ],
              ),
            ),
        const SizedBox(height: 6),
        LgButton.secondary(
          label: l.adminPartnerAddModel,
          icon: Icons.add_link_rounded,
          onPressed: () => _addModel(catalog),
        ),
        LgSectionTitle(l.adminPartnerPeriodTitle),
        LgRow(
          title: l.adminPartnerStarts,
          subtitle: _day(_starts, context),
          icon: Icons.event_outlined,
          onTap: () => _pickDate(start: true),
        ),
        LgRow(
          title: l.adminPartnerEnds,
          subtitle: _day(_ends, context),
          icon: Icons.event_available_outlined,
          divider: false,
          onTap: () => _pickDate(start: false),
        ),
        LgNotice(l.adminPartnerPublishRules, kind: NoticeKind.info),
        if (_error != null) LgNotice(_error!, kind: NoticeKind.error),
        const SizedBox(height: 8),
        LgButton(
          label: l.adminPartnerSave,
          icon: Icons.save_outlined,
          busy: _busy,
          onPressed: _busy ? null : () => _save(),
        ),
        const SizedBox(height: 8),
        if (saved?.status == PartnerStatus.published)
          LgButton.secondary(
            label: l.adminPartnerPause,
            icon: Icons.pause_circle_outline_rounded,
            onPressed: _busy ? null : () => _setStatus(PartnerStatus.paused),
          )
        else
          LgButton.secondary(
            label: l.adminPartnerPublish,
            icon: Icons.campaign_outlined,
            onPressed: _busy ? null : () => _setStatus(PartnerStatus.published),
          ),
        if (_id case final id?) ...[
          const SizedBox(height: 8),
          LgRow(
            title: l.adminPartnerStats,
            icon: Icons.bar_chart_rounded,
            divider: false,
            onTap: () => context.push('/profile/admin/partners/$id/stats'),
          ),
        ],
      ],
    );
  }
}

class _ModelPicker extends StatefulWidget {
  const _ModelPicker({required this.catalog, required this.exclude});

  final InstrumentCatalog catalog;
  final Set<String> exclude;

  @override
  State<_ModelPicker> createState() => _ModelPickerState();
}

class _ModelPickerState extends State<_ModelPicker> {
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
    final c = widget.catalog;
    final models = (_q.trim().isEmpty ? c.models : c.search(_q))
        .where((m) => !widget.exclude.contains(m.id))
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchBox(
                  controller: _query,
                  label: l.instSearchLabel,
                  hint: l.instSearchHint,
                  onChanged: (v) => setState(() => _q = v),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final (i, m) in models.indexed)
                      LgRow(
                        title: '${c.maker(m.makerId).name} ${m.model}',
                        subtitle: m.kind.of(lang),
                        icon: categoryIcon(m.category),
                        divider: i < models.length - 1,
                        onTap: () => Navigator.of(context).pop(m.id),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------- statistika
class AdminPartnerStatsScreen extends StatefulWidget {
  const AdminPartnerStatsScreen({super.key, required this.partnerId});

  final String partnerId;

  @override
  State<AdminPartnerStatsScreen> createState() =>
      _AdminPartnerStatsScreenState();
}

typedef _Totals = ({int impressions, int contacts});

_Totals _sum(Iterable<PartnerDayStat> rows) => (
  impressions: rows.fold(0, (a, r) => a + r.impressions),
  contacts: rows.fold(0, (a, r) => a + r.contacts),
);

class _AdminPartnerStatsScreenState extends State<AdminPartnerStatsScreen> {
  Partner? _partner;
  List<PartnerDayStat>? _rows;
  Object? _error;

  Future<void> _load() async {
    final backend = context.services.backend;
    try {
      final all = await backend.adminPartners();
      final rows = await backend.adminPartnerStats(widget.partnerId);
      if (!mounted) return;
      setState(() {
        _partner = all.where((p) => p.id == widget.partnerId).firstOrNull;
        _rows = rows;
        _error = null;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  String _ctr(_Totals t) => t.impressions == 0
      ? '—'
      : '${(t.contacts * 100 / t.impressions).toStringAsFixed(1)}%';

  String _report(BuildContext context, List<PartnerDayStat> rows) {
    final l = AppLocalizations.of(context);
    final p = _partner;
    final today = context.services.partners.today;
    String line(String label, _Totals t) =>
        '$label: ${l.adminStatsImpressions} ${t.impressions}, '
        '${l.adminStatsContacts} ${t.contacts}, ${l.adminStatsCtr} ${_ctr(t)}';
    return [
      if (p != null)
        '${p.name} (${_day(p.startsOn, context)} — ${_day(p.endsOn, context)})',
      line(
        l.adminStats7,
        _sum(rows.where((r) => today.difference(r.day).inDays < 7)),
      ),
      line(
        l.adminStats30,
        _sum(rows.where((r) => today.difference(r.day).inDays < 30)),
      ),
      line(l.adminStatsAll, _sum(rows)),
      for (final pl in PartnerPlacement.values)
        line(
          partnerPlacementLabel(pl, l),
          _sum(rows.where((r) => r.placement == pl)),
        ),
      l.adminStatsNote,
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final today = context.services.partners.today;
    final rows = _rows;
    return _AdminScaffold(
      title: _partner?.name ?? l.adminPartnerStats,
      onLoad: _load,
      child: Builder(
        builder: (context) {
          if (_error != null) {
            return LgNotice(
              backendErrorText(_error!, l),
              kind: NoticeKind.error,
            );
          }
          if (rows == null) {
            return const LgStateView(kind: StateKind.loading, title: '');
          }
          final last30 = rows
              .where((r) => today.difference(r.day).inDays < 30)
              .toList();
          final days = <DateTime, List<PartnerDayStat>>{};
          for (final r in last30) {
            (days[r.day] ??= []).add(r);
          }
          final partner = _partner;
          final total30 = _sum(last30);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (partner != null) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: () {
                    final (label, tone) = partnerAdminStatus(partner, today, l);
                    return LgTag(label, tone: tone);
                  }(),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l.adminPartnerPeriodTitle}: '
                  '${_day(partner.startsOn, context)} — '
                  '${_day(partner.endsOn, context)}',
                  style: text.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              LgTwoColumnGrid(
                children: [
                  _BigNumber(
                    value: total30.impressions,
                    label: l.adminStatsImpressions,
                    caption: l.adminStats30,
                  ),
                  _BigNumber(
                    value: total30.contacts,
                    label: l.adminStatsContacts,
                    caption: '${l.adminStatsCtr}: ${_ctr(total30)}',
                  ),
                ],
              ),
              LgSectionTitle(l.adminStatsPeriods),
              LgPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (label, t) in [
                      (
                        l.adminStats7,
                        _sum(
                          rows.where((r) => today.difference(r.day).inDays < 7),
                        ),
                      ),
                      (l.adminStats30, total30),
                      (l.adminStatsAll, _sum(rows)),
                    ])
                      _StatLine(title: label, totals: t, ctr: _ctr(t)),
                  ],
                ),
              ),
              LgSectionTitle(l.adminStatsByPlacement),
              LgPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final pl in PartnerPlacement.values)
                      _StatLine(
                        title: partnerPlacementLabel(pl, l),
                        totals: _sum(last30.where((r) => r.placement == pl)),
                      ),
                  ],
                ),
              ),
              LgSectionTitle(l.adminStatsDaily),
              if (days.isEmpty)
                LgStateView(kind: StateKind.empty, title: l.adminStatsEmpty)
              else
                LgPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final e in days.entries)
                        _StatLine(
                          title: _day(e.key, context),
                          totals: _sum(e.value),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Text(l.adminStatsNote, style: text.bodySmall),
              const SizedBox(height: 12),
              LgButton.secondary(
                label: l.adminStatsCopy,
                icon: Icons.copy_rounded,
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _report(context, rows)),
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(l.adminCopied)));
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Katta raqam (30 kunlik asosiy ko'rsatkich).
class _BigNumber extends StatelessWidget {
  const _BigNumber({
    required this.value,
    required this.label,
    required this.caption,
  });

  final int value;
  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = LgPalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.paper,
        borderRadius: BorderRadius.circular(LgRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: text.headlineMedium!.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: text.titleSmall),
            Text(caption, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.title, required this.totals, this.ctr});

  final String title;
  final _Totals totals;
  final String? ctr;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgMetric(
      label: title,
      value: [
        '${l.adminStatsImpressions}: ${totals.impressions}',
        '${l.adminStatsContacts}: ${totals.contacts}',
        if (ctr != null) '${l.adminStatsCtr}: $ctr',
      ].join(' · '),
    );
  }
}

/// Admin bosh sahifasidagi “Hamkorlik arizalari” qatori (yangi arizalar
/// soni bilan; yuklanmasa — sonsiz).
class AdminPartnerRequestsRow extends StatefulWidget {
  const AdminPartnerRequestsRow({super.key});

  @override
  State<AdminPartnerRequestsRow> createState() =>
      _AdminPartnerRequestsRowState();
}

class _AdminPartnerRequestsRowState extends State<AdminPartnerRequestsRow> {
  int? _new;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final list = await context.services.backend.adminPartnerRequests(
        status: PartnerRequestStatus.newRequest,
      );
      if (mounted) setState(() => _new = list.length);
    } on Object catch (e) {
      debugPrint('partner requests count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LgRow(
      title: l.adminPartnerRequests,
      subtitle: _new == null ? null : l.adminPartnerRequestsNew(_new!),
      icon: Icons.handshake_outlined,
      onTap: () async {
        await context.push('/profile/admin/partner-requests');
        await _load();
      },
    );
  }
}

// ------------------------------------------------------------ arizalar
class AdminPartnerRequestsScreen extends StatefulWidget {
  const AdminPartnerRequestsScreen({super.key});

  @override
  State<AdminPartnerRequestsScreen> createState() =>
      _AdminPartnerRequestsScreenState();
}

class _AdminPartnerRequestsScreenState
    extends State<AdminPartnerRequestsScreen> {
  PartnerRequestStatus? _filter;
  List<PartnerRequest>? _list;
  Object? _error;

  Future<void> _load() async {
    try {
      final list = await context.services.backend.adminPartnerRequests(
        status: _filter,
      );
      if (mounted) {
        setState(() {
          _list = list;
          _error = null;
        });
      }
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final list = _list;
    return _AdminScaffold(
      title: l.adminPartnerRequests,
      onLoad: _load,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in [null, ...PartnerRequestStatus.values])
                LgChoiceChip(
                  label: s == null
                      ? l.adminAllStatuses
                      : partnerRequestStatusLabel(s, l),
                  selected: _filter == s,
                  onTap: () {
                    setState(() {
                      _filter = s;
                      _list = null;
                    });
                    _load();
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_error != null)
            LgNotice(backendErrorText(_error!, l), kind: NoticeKind.error)
          else if (list == null)
            const LgStateView(kind: StateKind.loading, title: '')
          else if (list.isEmpty)
            LgStateView(kind: StateKind.empty, title: l.adminRequestsEmpty)
          else
            for (final (i, r) in list.indexed)
              LgRow(
                title: r.company,
                subtitle:
                    '${r.contactName} · '
                    '${partnerRequestStatusLabel(r.status, l)} · '
                    '${formatWhen(r.createdAt, context)}',
                icon: Icons.handshake_outlined,
                divider: i < list.length - 1,
                onTap: () async {
                  await context.push('/profile/admin/partner-requests/${r.id}');
                  await _load();
                },
              ),
        ],
      ),
    );
  }
}

class AdminPartnerRequestScreen extends StatefulWidget {
  const AdminPartnerRequestScreen({super.key, required this.requestId});

  final String requestId;

  @override
  State<AdminPartnerRequestScreen> createState() =>
      _AdminPartnerRequestScreenState();
}

class _AdminPartnerRequestScreenState extends State<AdminPartnerRequestScreen> {
  PartnerRequest? _request;
  PartnerRequestStatus? _status;
  final _reply = TextEditingController();
  Object? _error;
  bool _busy = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final all = await context.services.backend.adminPartnerRequests();
      final r =
          all.where((x) => x.id == widget.requestId).firstOrNull ??
          (throw const BackendException(BackendFailure.notFound));
      if (!mounted) return;
      setState(() {
        _request = r;
        _status ??= r.status;
        if (_reply.text.isEmpty) _reply.text = r.adminReply ?? '';
        _error = null;
      });
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final status = _status;
    if (status == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.services.backend.adminUpdatePartnerRequest(
        widget.requestId,
        status: status,
        reply: _reply.text,
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.adminPartnerSaved)));
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final r = _request;
    return _AdminScaffold(
      title: r?.company ?? l.adminPartnerRequests,
      onLoad: _load,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (r == null && _error == null)
            const LgStateView(kind: StateKind.loading, title: ''),
          if (r != null) ...[
            LgPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LgMetric(label: l.partnerFormCompany, value: r.company),
                  LgMetric(label: l.partnerFormContact, value: r.contactName),
                  if (r.phone case final phone?)
                    LgMetric(label: l.partnerFormPhone, value: phone),
                  if (r.email case final email?)
                    LgMetric(label: l.partnerFormEmail, value: email),
                  const SizedBox(height: 8),
                  Text(formatWhen(r.createdAt, context), style: text.bodySmall),
                ],
              ),
            ),
            if (r.products.isNotEmpty) ...[
              LgSectionTitle(l.partnerFormProducts),
              SelectableText(r.products, style: text.bodyMedium),
            ],
            if (r.message.isNotEmpty) ...[
              LgSectionTitle(l.partnerFormMessage),
              SelectableText(r.message, style: text.bodyMedium),
            ],
            LgSectionTitle(l.adminStatus),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in PartnerRequestStatus.values)
                  LgChoiceChip(
                    label: partnerRequestStatusLabel(s, l),
                    selected: _status == s,
                    onTap: () => setState(() => _status = s),
                  ),
              ],
            ),
            LgField(
              label: l.adminRequestReply,
              controller: _reply,
              hint: l.adminReplyHint,
              maxLines: 4,
              maxLength: 2000,
              keyboardType: TextInputType.multiline,
            ),
          ],
          if (_error != null)
            LgNotice(backendErrorText(_error!, l), kind: NoticeKind.error),
          if (r != null) ...[
            const SizedBox(height: 10),
            LgButton(
              label: l.adminRequestSave,
              icon: Icons.save_outlined,
              busy: _busy,
              onPressed: _save,
            ),
          ],
        ],
      ),
    );
  }
}
