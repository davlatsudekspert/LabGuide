import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import '../../l10n/gen/app_localizations.dart';
import '../content/analyte_search.dart';
import '../content/content_model.dart';

/// Material qanday ochiladi. Kartada doim ikonka + yorliq + “nima bo'ladi”
/// izohi bilan ko'rsatiladi — foydalanuvchi bosishdan oldin biladi.
enum LibraryOpenKind {
  /// Hali olinmagan yoki tekshirilmoqda — ochish tugmasi yo'q.
  pending,

  /// Ilova ichidagi fayl (to'liq tarqatish huquqi qayd etilgan) —
  /// o'quvchida ochiladi.
  inApp,

  /// Alohida yuklab olinadigan kitob (oflayn paket).
  download,

  /// Tashqi sayt — brauzerda ochiladi.
  link,

  /// Faqat bibliografik yozuv: ochiladigan narsa yo'q.
  record,
}

/// Elementning ochilish turi. Kelmagan yoki tekshirilmagan material hech
/// qachon “mavjud” deb ko'rsatilmaydi; fayl faqat to'liq huquq qaydi bilan.
LibraryOpenKind openKindOf(LibraryItem item) {
  if (!item.importState.citable) return LibraryOpenKind.pending;
  if (item.file != null && item.rights.allowsSharedPack) {
    return LibraryOpenKind.inApp;
  }
  if (item.filePack != null && item.rights.allowsSharedPack) {
    return LibraryOpenKind.download;
  }
  if (item.url != null) return LibraryOpenKind.link;
  return LibraryOpenKind.record;
}

/// Ilova ichidagi o'quvchida ochish mumkinmi.
bool canReadInApp(LibraryItem item) =>
    openKindOf(item) == LibraryOpenKind.inApp;

/// Material interfeys tilida mavjudmi (“tarjima qilingan bo'lsa ko'rinsin”).
/// Modelda tarjimalar maydoni yo'q — faqat asl `language`. Material ilova
/// tilida yozilgan yoki ko'p tilli (`multi`/`mul`, yoki `ru,en` kabi ro'yxat)
/// bo'lsa ko'rinadi. O'zbek interfeysida (va til noma'lum bo'lsa) hammasi
/// ko'rinadi.
bool libraryItemAvailableIn(LibraryItem item, String? lang) {
  if (lang == null || lang == 'uz') return true;
  final code = item.language.toLowerCase().trim();
  if (code == lang || code == 'multi' || code == 'mul') return true;
  return code.split(RegExp(r'[,;/+\s]+')).contains(lang);
}

const _keep = Object();

/// Katalog filtri: qidiruv so'zi va til / mavzu / tur bo'yicha tanlovlar.
/// Har o'lchamda bitta qiymat (yoki hech biri).
@immutable
class LibraryFilter {
  const LibraryFilter({
    this.query = '',
    this.language,
    this.category,
    this.group,
    this.kind,
    this.open,
  });

  static const none = LibraryFilter();

  final String query;
  final String? language;
  final LibraryCategory? category;

  /// Tahlillar guruhi (`groups[].id`).
  final String? group;
  final LibraryItemKind? kind;
  final LibraryOpenKind? open;

  bool get hasSelections =>
      language != null ||
      category != null ||
      group != null ||
      kind != null ||
      open != null;

  bool get hasQuery => query.trim().isNotEmpty;

  bool get isActive => hasSelections || hasQuery;

  LibraryFilter copyWith({
    String? query,
    Object? language = _keep,
    Object? category = _keep,
    Object? group = _keep,
    Object? kind = _keep,
    Object? open = _keep,
  }) => LibraryFilter(
    query: query ?? this.query,
    language: identical(language, _keep) ? this.language : language as String?,
    category: identical(category, _keep)
        ? this.category
        : category as LibraryCategory?,
    group: identical(group, _keep) ? this.group : group as String?,
    kind: identical(kind, _keep) ? this.kind : kind as LibraryItemKind?,
    open: identical(open, _keep) ? this.open : open as LibraryOpenKind?,
  );

  /// Faqat qidiruv so'zini saqlab, tanlovlarni tozalaydi.
  LibraryFilter clearSelections() => LibraryFilter(query: query);

  @override
  bool operator ==(Object other) =>
      other is LibraryFilter &&
      other.query == query &&
      other.language == language &&
      other.category == category &&
      other.group == group &&
      other.kind == kind &&
      other.open == open;

  @override
  int get hashCode => Object.hash(query, language, category, group, kind, open);
}

/// Kutubxona katalogi ustida qidiruv va filtr. Paket bir marta indekslanadi.
class LibraryCatalog {
  LibraryCatalog(this.pack, {this.lang})
    : items = [
        for (final i in pack.library)
          if (libraryItemAvailableIn(i, lang)) i,
      ],
      _entries = {
        for (final (i, item) in pack.library.indexed)
          item.id: _Entry.of(item, i, pack),
      };

  final ContentPack pack;
  final Map<String, _Entry> _entries;

  /// Interfeys tili: shu tilda mavjud bo'lmagan materiallar katalogda yo'q.
  final String? lang;

  /// Interfeys tilida ko'rinadigan materiallar (paket tartibida).
  final List<LibraryItem> items;

  /// Element bog'langan tahlillar guruhlari (mavzu analit yoki dars bo'lsa
  /// — uning guruhi).
  Set<String> groupsOf(LibraryItem item) => _entries[item.id]!.groups;

  /// Katalogdagi tillar: uz, ru, en tartibida, keyin boshqalari.
  List<String> get languages {
    final present = {for (final i in items) i.language};
    return [
      for (final code in const ['uz', 'ru', 'en'])
        if (present.remove(code)) code,
      ...present.toList()..sort(),
    ];
  }

  List<LibraryCategory> get categories => [
    for (final c in LibraryCategory.values)
      if (items.any((i) => i.categories.contains(c))) c,
  ];

  List<LibraryItemKind> get kinds => [
    for (final k in LibraryItemKind.values)
      if (items.any((i) => i.kind == k)) k,
  ];

  /// Tahlillar guruhlari — paketdagi tartibda, faqat katalogda uchraganlari.
  List<AnalyteGroup> get groups => [
    for (final g in pack.groups)
      if (items.any((i) => groupsOf(i).contains(g.id))) g,
  ];

  List<LibraryOpenKind> get openKinds => [
    for (final k in LibraryOpenKind.values)
      if (items.any((i) => openKindOf(i) == k)) k,
  ];

  bool _matches(LibraryItem item, LibraryFilter f) =>
      (f.language == null || item.language == f.language) &&
      (f.category == null || item.categories.contains(f.category)) &&
      (f.group == null || groupsOf(item).contains(f.group)) &&
      (f.kind == null || item.kind == f.kind) &&
      (f.open == null || openKindOf(item) == f.open);

  /// Filtr va qidiruv natijasi. So'z bo'lmasa — interfeys tilidagi
  /// materiallar birinchi (paket tartibi saqlanadi); so'z bo'lsa — moslik
  /// darajasi bo'yicha (nomida > muallifda > boshqa maydonlarda).
  List<LibraryItem> apply(LibraryFilter f, {String? lang}) {
    lang ??= this.lang ?? '';
    final candidates = items.where((i) => _matches(i, f));
    final q = normalizeForSearch(f.query);
    int langRank(LibraryItem i) => i.language == lang ? 0 : 1;
    if (q.isEmpty) {
      final list = candidates.toList()
        ..sort((a, b) {
          final byLang = langRank(a).compareTo(langRank(b));
          if (byLang != 0) return byLang;
          return _entries[a.id]!.index.compareTo(_entries[b.id]!.index);
        });
      return list;
    }
    final queries = {
      q,
      if (_cyrillic.hasMatch(q)) normalizeForSearch(uzCyrillicToLatin(q)),
    };
    final scored = <(LibraryItem, int)>[];
    for (final item in candidates) {
      final e = _entries[item.id]!;
      var best = 0;
      for (final query in queries) {
        final s = e.score(query);
        if (s > best) best = s;
      }
      if (best > 0) scored.add((item, best));
    }
    scored.sort((x, y) {
      final byScore = y.$2.compareTo(x.$2);
      if (byScore != 0) return byScore;
      final byLang = langRank(x.$1).compareTo(langRank(y.$1));
      if (byLang != 0) return byLang;
      return _entries[x.$1.id]!.index.compareTo(_entries[y.$1.id]!.index);
    });
    return [for (final s in scored) s.$1];
  }

  int count(LibraryFilter f) => apply(f, lang: '').length;
}

final _cyrillic = RegExp('[а-яёўқғҳ]');

/// Qidiruv indeksi: nom (asl va kirill → lotin), mualliflar va boshqa
/// maydonlar (nashriyot, ISBN, yil, izoh, yo'nalish, tur va guruh nomlari —
/// uch tilda, shunda “руководство” ham, “qo'llanma” ham topadi).
class _Entry {
  _Entry({
    required this.index,
    required this.titles,
    required this.authors,
    required this.other,
    required this.groups,
  });

  factory _Entry.of(LibraryItem item, int index, ContentPack pack) {
    String n(String s) => normalizeForSearch(s);
    final groups = <String>{};
    final groupIds = {for (final g in pack.groups) g.id};
    for (final t in item.topics) {
      if (groupIds.contains(t)) {
        groups.add(t);
      } else if (pack.analyte(t) case final a?) {
        groups.add(a.group);
      } else {
        for (final lesson in pack.lessons) {
          if (lesson.id == t && lesson.groupId != null) {
            groups.add(lesson.groupId!);
          }
        }
      }
    }
    final other = <String>[
      ?item.publisher,
      ?item.isbn,
      if (item.year != null) '${item.year}',
      ?item.edition,
      if (item.note != null) ...item.note!.values.values,
      for (final l in _allLocales) ...[
        for (final c in item.categories) _categoryLabel(c, l),
        _kindLabel(item.kind, l),
      ],
      for (final g in groups) ...?pack.group(g)?.names.values.values,
    ];
    return _Entry(
      index: index,
      titles: {n(item.title), n(uzCyrillicToLatin(item.title))}.toList(),
      authors: n(
        [...item.authors, ...item.authors.map(uzCyrillicToLatin)].join(' '),
      ),
      other: n(other.join(' ')),
      groups: groups,
    );
  }

  final int index;
  final List<String> titles;
  final String authors;
  final String other;
  final Set<String> groups;

  int score(String q) {
    var best = 0;
    for (final t in titles) {
      if (t == q) {
        best = _max(best, 100);
      } else if (t.startsWith(q)) {
        best = _max(best, 90);
      } else if (t.split(' ').any((w) => w.startsWith(q))) {
        best = _max(best, 75);
      } else if (t.contains(q)) {
        best = _max(best, 60);
      }
    }
    if (best > 0) return best;
    if (authors.contains(q)) return 50;
    if (other.contains(q)) return 30;
    // Bir necha so'z: har biri biror maydonda uchrashi kerak.
    final tokens = q.split(' ');
    if (tokens.length > 1) {
      final haystack = '${titles.join(' ')} $authors $other';
      if (tokens.every(haystack.contains)) return 20;
    }
    return 0;
  }

  static int _max(int a, int b) => a > b ? a : b;
}

final _allLocales = [
  for (final code in const ['uz', 'ru', 'en'])
    lookupAppLocalizations(Locale(code)),
];

String _categoryLabel(LibraryCategory c, AppLocalizations l) => switch (c) {
  LibraryCategory.biochemistry => l.catBiochemistry,
  LibraryCategory.clinicalLab => l.catClinicalLab,
  LibraryCategory.instruments => l.catInstruments,
  LibraryCategory.methods => l.catMethods,
  LibraryCategory.tests => l.catTests,
};

String _kindLabel(LibraryItemKind k, AppLocalizations l) => switch (k) {
  LibraryItemKind.book => l.kindBook,
  LibraryItemKind.manual => l.kindManual,
  LibraryItemKind.method => l.kindMethod,
  LibraryItemKind.ifu => l.kindIfu,
  LibraryItemKind.article => l.kindArticle,
  LibraryItemKind.questionSet => l.kindQuestionSet,
  LibraryItemKind.website => l.kindWebsite,
};

String libraryCategoryLabel(LibraryCategory c, AppLocalizations l) =>
    _categoryLabel(c, l);

String libraryKindLabel(LibraryItemKind k, AppLocalizations l) =>
    _kindLabel(k, l);
