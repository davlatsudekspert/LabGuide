import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/lg_page.dart';
import '../../design/widgets/lg_widgets.dart';

/// Yo'nalish: «Laboratoriya ishi» — alohida test ro'yxati (mashq rejimi).
/// Savollar o'zbekcha; kalit ilova ichidagi ma'lumotdan. Natija qurilmada
/// saqlanmaydi (sodda mashq).
const labIshiAsset = 'assets/toifa/lab_ishi_tests.json';
const labIshiRoute = 'lab-ishi';
const toxLabAsset = 'assets/toifa/tox_lab_tests.json';
const toxLabRoute = 'tox-lab';
const labIshiSessionSize = 20;

class LabIshiQuestion {
  const LabIshiQuestion(this.number, this.text, this.options, this.key);

  factory LabIshiQuestion.fromJson(Map<String, Object?> j) => LabIshiQuestion(
    j['n']! as int,
    j['q']! as String,
    (j['options']! as List).cast<String>(),
    j['key']! as int,
  );

  final int number;
  final String text;
  final List<String> options;
  final int key;
}

Future<List<LabIshiQuestion>> loadLabIshi(
  AssetBundle bundle, [
  String asset = labIshiAsset,
]) async {
  final raw = jsonDecode(await bundle.loadString(asset)) as Map;
  return [
    for (final e in (raw['questions'] as List))
      LabIshiQuestion.fromJson((e as Map).cast<String, Object?>()),
  ];
}

/// Uch tilli qisqa matnlar (ARB'siz: yo'nalish ekrani mustaqil).
String _t(BuildContext context, String uz, String ru, String en) =>
    switch (Localizations.localeOf(context).languageCode) {
      'ru' => ru,
      'en' => en,
      _ => uz,
    };

String labIshiTitle(BuildContext context) => _t(
  context,
  'Laboratoriya ishi',
  'Лабораторное дело',
  'Laboratory practice',
);

String toxLabTitle(BuildContext context) => _t(
  context,
  'Toksikologik laboratoriya',
  'Токсикологическая лаборатория',
  'Toxicology laboratory',
);

/// Tavsif: sanitariya-gigiena laboratoriyasi (klinik emas, sud-tibbiy emas).
String toxLabAbout(BuildContext context) => _t(
  context,
  'Sanitariya-gigiena laboratoriyasi mutaxassisi uchun: pestitsidlar, ruxsat etilgan konsentratsiyalar, xavfni baholash, o‘lchash va metrologiya.',
  'Для специалиста санитарно-гигиенической лаборатории: пестициды, предельно допустимые концентрации, оценка риска, измерения и метрология.',
  'For sanitary-hygiene laboratory specialists: pesticides, maximum permissible concentrations, risk assessment, measurement and metrology.',
);

String labIshiRowSubtitle(BuildContext context, int count) => _t(
  context,
  '$count ta test savoli · mashq',
  '$count тестовых вопросов · тренировка',
  '$count test questions · practice',
);

class LabIshiScreen extends StatefulWidget {
  const LabIshiScreen({super.key, this.random, this.tox = false});

  final Random? random;

  /// true — «Toksikologik laboratoriya» yo‘nalishi (boshqa ro‘yxat).
  final bool tox;

  @override
  State<LabIshiScreen> createState() => _LabIshiScreenState();
}

class _LabIshiScreenState extends State<LabIshiScreen> {
  List<LabIshiQuestion>? _all;
  List<LabIshiQuestion> _session = const [];
  int _index = 0;
  int _correct = 0;
  int? _picked;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await loadLabIshi(
        rootBundle,
        widget.tox ? toxLabAsset : labIshiAsset,
      );
      if (!mounted) return;
      setState(() => _all = all);
      _start();
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _start() {
    final all = [...?_all]..shuffle(widget.random ?? Random());
    setState(() {
      _session = all.take(labIshiSessionSize).toList();
      _index = 0;
      _correct = 0;
      _picked = null;
    });
  }

  void _pick(int i) {
    if (_picked != null) return;
    setState(() {
      _picked = i;
      if (i == _session[_index].key) _correct++;
    });
  }

  void _next() => setState(() {
    _index++;
    _picked = null;
  });

  @override
  Widget build(BuildContext context) {
    final title = widget.tox ? toxLabTitle(context) : labIshiTitle(context);
    if (_failed) {
      return LgPage(
        title: title,
        showProfile: false,
        children: [
          LgNotice(
            _t(
              context,
              'Savollarni yuklab bo‘lmadi.',
              'Не удалось загрузить вопросы.',
              'Could not load the questions.',
            ),
            kind: NoticeKind.error,
          ),
        ],
      );
    }
    if (_all == null || _session.isEmpty) {
      return LgPage(
        title: title,
        showProfile: false,
        children: const [Center(child: CircularProgressIndicator())],
      );
    }
    final text = Theme.of(context).textTheme;
    if (_index >= _session.length) {
      return LgPage(
        title: title,
        showProfile: false,
        children: [
          Text(
            '$_correct / ${_session.length}',
            style: text.headlineMedium,
          ),
          const SizedBox(height: 16),
          LgButton(
            label: _t(
              context,
              'Yangi 20 savol',
              'Ещё 20 вопросов',
              'Another 20 questions',
            ),
            onPressed: _start,
          ),
        ],
      );
    }
    final q = _session[_index];
    final answered = _picked != null;
    return LgPage(
      key: ValueKey(_index),
      title: title,
      subtitle: '${_index + 1} / ${_session.length}',
      showProfile: false,
      buildAllChildren: true,
      children: [
        if (widget.tox) ...[
          Text(toxLabAbout(context), style: text.bodySmall),
          const SizedBox(height: 8),
        ],
        LgNotice(
          _t(
            context,
            'Savollar o‘zbekcha. Javoblar kaliti LabGuide tomonidan tayyorlangan — mashq uchun; shubha bo‘lsa darslik bilan solishtiring.',
            'Вопросы на узбекском. Ключ ответов подготовлен LabGuide — для тренировки; при сомнении сверяйтесь с учебником.',
            'Questions are in Uzbek. The answer key was prepared by LabGuide for practice; check the textbook if in doubt.',
          ),
          kind: NoticeKind.info,
        ),
        const SizedBox(height: 12),
        Text(q.text, style: text.titleMedium),
        const SizedBox(height: 8),
        for (var i = 0; i < q.options.length; i++)
          LgRow(
            title: '${'ABCD'[i]}) ${q.options[i]}',
            icon: !answered
                ? Icons.radio_button_unchecked
                : i == q.key
                ? Icons.check_circle_outline
                : i == _picked
                ? Icons.cancel_outlined
                : Icons.radio_button_unchecked,
            onTap: answered ? null : () => _pick(i),
            divider: i < q.options.length - 1,
          ),
        if (answered) ...[
          const SizedBox(height: 12),
          Text(
            _picked == q.key
                ? _t(context, 'To‘g‘ri', 'Верно', 'Correct')
                : '${_t(context, 'To‘g‘ri javob', 'Правильный ответ', 'Correct answer')}: ${'ABCD'[q.key]}',
            style: text.titleSmall,
          ),
          const SizedBox(height: 12),
          LgButton(
            label: _index + 1 == _session.length
                ? _t(context, 'Natija', 'Результат', 'Result')
                : _t(context, 'Keyingi', 'Далее', 'Next'),
            onPressed: _next,
          ),
        ],
      ],
    );
  }
}
