import 'package:flutter/foundation.dart';

/// Hamkor turi.
enum PartnerKind {
  manufacturer,
  distributor,
  service;

  static PartnerKind parse(String raw) => values.firstWhere(
    (k) => k.name == raw,
    orElse: () => throw FormatException('unknown partner kind: $raw'),
  );
}

/// E'lon holati (faollik davri alohida: [Partner.startsOn]..[Partner.endsOn]).
enum PartnerStatus {
  draft,
  published,
  paused;

  static PartnerStatus parse(String raw) => values.firstWhere(
    (s) => s.name == raw,
    orElse: () => throw FormatException('unknown partner status: $raw'),
  );
}

/// Reklama ko'rinadigan joy (hisobotda alohida sanaladi).
enum PartnerPlacement {
  card('card'),
  category('category'),
  labHome('lab_home'),
  partnerPage('partner_page');

  const PartnerPlacement(this.wire);
  final String wire;

  static PartnerPlacement parse(String raw) => values.firstWhere(
    (p) => p.wire == raw,
    orElse: () => throw FormatException('unknown placement: $raw'),
  );
}

enum PartnerEventKind { impression, contact }

enum PartnerLinkTarget { maker, model }

/// O'zbekiston hududlari (server `_uz_regions()` bilan bir xil). `all` —
/// butun respublika.
const uzRegionCodes = [
  'all',
  'tashkent_city',
  'tashkent',
  'andijan',
  'bukhara',
  'fergana',
  'jizzakh',
  'kashkadarya',
  'khorezm',
  'namangan',
  'navoi',
  'samarkand',
  'sirdarya',
  'surkhandarya',
  'karakalpakstan',
];

const _regionNames = <String, (String, String, String)>{
  'all': ('Butun respublika', 'Вся республика', 'Nationwide'),
  'tashkent_city': ('Toshkent shahri', 'г. Ташкент', 'Tashkent city'),
  'tashkent': ('Toshkent viloyati', 'Ташкентская обл.', 'Tashkent region'),
  'andijan': ('Andijon', 'Андижан', 'Andijan'),
  'bukhara': ('Buxoro', 'Бухара', 'Bukhara'),
  'fergana': ('Farg‘ona', 'Фергана', 'Fergana'),
  'jizzakh': ('Jizzax', 'Джизак', 'Jizzakh'),
  'kashkadarya': ('Qashqadaryo', 'Кашкадарья', 'Kashkadarya'),
  'khorezm': ('Xorazm', 'Хорезм', 'Khorezm'),
  'namangan': ('Namangan', 'Наманган', 'Namangan'),
  'navoi': ('Navoiy', 'Навои', 'Navoi'),
  'samarkand': ('Samarqand', 'Самарканд', 'Samarkand'),
  'sirdarya': ('Sirdaryo', 'Сырдарья', 'Syrdarya'),
  'surkhandarya': ('Surxondaryo', 'Сурхандарья', 'Surkhandarya'),
  'karakalpakstan': ('Qoraqalpog‘iston', 'Каракалпакстан', 'Karakalpakstan'),
};

String uzRegionName(String code, String lang) {
  final n = _regionNames[code];
  if (n == null) return code;
  return switch (lang) {
    'ru' => n.$2,
    'en' => n.$3,
    _ => n.$1,
  };
}

// --- kiritish qoidalari (server CHECK lari bilan bir xil)
final _phone = RegExp(r'^\+?[0-9 ()-]{7,20}$');
final _telegram = RegExp(r'^[A-Za-z0-9_]{5,32}$');
final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _catalogId = RegExp(r'^[a-z0-9][a-z0-9-]{1,79}$');

bool isValidPartnerPhone(String s) => _phone.hasMatch(s.trim());
bool isValidPartnerEmail(String s) =>
    s.trim().length <= 120 && _email.hasMatch(s.trim());
bool isValidHttpsUrl(String s) =>
    s.trim().startsWith('https://') &&
    s.trim().length <= 500 &&
    Uri.tryParse(s.trim())?.host.isNotEmpty == true;
bool isValidTelegram(String s) => _telegram.hasMatch(s);
bool isValidCatalogId(String s) => _catalogId.hasMatch(s);

/// “@name”, “t.me/name”, “https://t.me/name” → “name”.
String normalizeTelegram(String raw) => raw
    .trim()
    .replaceFirst(RegExp(r'^https?://'), '')
    .replaceFirst(RegExp(r'^(t\.me|telegram\.me)/'), '')
    .replaceFirst('@', '');

/// Telefon raqamini havola uchun (tel:+998...).
String telUri(String phone) =>
    'tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}';

DateTime _day(String raw) {
  final d = DateTime.parse(raw);
  return DateTime.utc(d.year, d.month, d.day);
}

String _dayWire(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Toshkent vaqti bo'yicha bugungi sana (UTC+5, yozgi vaqt yo'q) — server
/// faollikni shu kun bo'yicha tekshiradi.
DateTime tashkentToday(DateTime now) {
  final t = now.toUtc().add(const Duration(hours: 5));
  return DateTime.utc(t.year, t.month, t.day);
}

@immutable
class PartnerLink {
  const PartnerLink({
    required this.target,
    required this.catalogId,
    this.registrationNo,
  });

  factory PartnerLink.fromJson(Map<String, Object?> j) => PartnerLink(
    target: PartnerLinkTarget.values.byName(j['target']! as String),
    catalogId: j['catalog_id']! as String,
    registrationNo: j['registration_no'] as String?,
  );

  final PartnerLinkTarget target;
  final String catalogId;

  /// Apparatning O'zbekistonda ro'yxatdan o'tganlik guvohnomasi raqami
  /// (hamkor bergan; faqat model uchun).
  final String? registrationNo;

  Map<String, Object?> toJson() => {
    'target': target.name,
    'catalog_id': catalogId,
    'registration_no': registrationNo,
  };
}

/// Hamkor kompaniya (reklama beruvchi). Barcha matn kompaniyaning o'zi
/// bergan ma'lumot — ilova uni katalog fakti deb ko'rsatmaydi.
@immutable
class Partner {
  const Partner({
    required this.id,
    required this.name,
    required this.kind,
    required this.summary,
    required this.regions,
    required this.startsOn,
    required this.endsOn,
    required this.status,
    required this.links,
    this.logoUrl,
    this.phone,
    this.telegram,
    this.website,
    this.email,
    this.brochureUrl,
  });

  factory Partner.fromJson(Map<String, Object?> j) => Partner(
    id: j['id']! as String,
    name: j['name']! as String,
    kind: PartnerKind.parse(j['kind']! as String),
    logoUrl: j['logo_url'] as String?,
    summary: {
      for (final e in ((j['summary'] as Map?) ?? const {}).entries)
        e.key as String: e.value as String,
    },
    regions: ((j['regions'] as List?) ?? const []).cast<String>(),
    phone: j['phone'] as String?,
    telegram: j['telegram'] as String?,
    website: j['website'] as String?,
    email: j['email'] as String?,
    brochureUrl: j['brochure_url'] as String?,
    startsOn: _day(j['starts_on']! as String),
    endsOn: _day(j['ends_on']! as String),
    status: PartnerStatus.parse(j['status']! as String),
    links: [
      for (final l in ((j['links'] ?? j['partner_links']) as List?) ?? const [])
        PartnerLink.fromJson((l as Map).cast<String, Object?>()),
    ],
  );

  final String id;
  final String name;
  final PartnerKind kind;
  final String? logoUrl;

  /// Qisqa tavsif: til kodi → matn.
  final Map<String, String> summary;
  final List<String> regions;
  final String? phone;
  final String? telegram;
  final String? website;
  final String? email;
  final String? brochureUrl;
  final DateTime startsOn;
  final DateTime endsOn;
  final PartnerStatus status;
  final List<PartnerLink> links;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'logo_url': logoUrl,
    'summary': summary,
    'regions': regions,
    'phone': phone,
    'telegram': telegram,
    'website': website,
    'email': email,
    'brochure_url': brochureUrl,
    'starts_on': _dayWire(startsOn),
    'ends_on': _dayWire(endsOn),
    'status': status.name,
    'links': [for (final l in links) l.toJson()],
  };

  /// Tanlangan til, bo'lmasa uz → ru → en.
  String summaryOf(String lang) =>
      summary[lang] ?? summary['uz'] ?? summary['ru'] ?? summary['en'] ?? '';

  bool get hasContact =>
      phone != null || telegram != null || website != null || email != null;

  /// E'lon qilingan va [day] (Toshkent sanasi) faollik davrida.
  bool isLiveOn(DateTime day) =>
      status == PartnerStatus.published &&
      !day.isBefore(startsOn) &&
      !day.isAfter(endsOn);

  bool linksModel(String modelId) => links.any(
    (l) => l.target == PartnerLinkTarget.model && l.catalogId == modelId,
  );

  bool linksMaker(String makerId) => links.any(
    (l) => l.target == PartnerLinkTarget.maker && l.catalogId == makerId,
  );

  String? registrationFor(String modelId) => links
      .where(
        (l) => l.target == PartnerLinkTarget.model && l.catalogId == modelId,
      )
      .firstOrNull
      ?.registrationNo;

  PartnerDraft toDraft() => PartnerDraft(
    name: name,
    kind: kind,
    logoUrl: logoUrl,
    summary: summary,
    regions: regions,
    phone: phone,
    telegram: telegram,
    website: website,
    email: email,
    brochureUrl: brochureUrl,
    startsOn: startsOn,
    endsOn: endsOn,
    links: links,
  );
}

/// Admin kiritgan hamkor ma'lumoti (saqlashdan oldin).
@immutable
class PartnerDraft {
  const PartnerDraft({
    required this.name,
    required this.kind,
    required this.summary,
    required this.regions,
    required this.startsOn,
    required this.endsOn,
    required this.links,
    this.logoUrl,
    this.phone,
    this.telegram,
    this.website,
    this.email,
    this.brochureUrl,
  });

  final String name;
  final PartnerKind kind;
  final String? logoUrl;
  final Map<String, String> summary;
  final List<String> regions;
  final String? phone;
  final String? telegram;
  final String? website;
  final String? email;
  final String? brochureUrl;
  final DateTime startsOn;
  final DateTime endsOn;
  final List<PartnerLink> links;

  Map<String, Object?> toJson() => {
    'name': name.trim(),
    'kind': kind.name,
    'logo_url': logoUrl,
    'summary': {
      for (final e in summary.entries)
        if (e.value.trim().isNotEmpty) e.key: e.value.trim(),
    },
    'regions': regions,
    'phone': phone,
    'telegram': telegram,
    'website': website,
    'email': email,
    'brochure_url': brochureUrl,
    'starts_on': _dayWire(startsOn),
    'ends_on': _dayWire(endsOn),
    'links': [for (final l in links) l.toJson()],
  };
}

@immutable
class PartnerEvent {
  const PartnerEvent(this.partnerId, this.placement, this.kind);

  final String partnerId;
  final PartnerPlacement placement;
  final PartnerEventKind kind;

  Map<String, Object?> toJson() => {
    'partner': partnerId,
    'placement': placement.wire,
    'kind': kind.name,
  };

  @override
  bool operator ==(Object other) =>
      other is PartnerEvent &&
      other.partnerId == partnerId &&
      other.placement == placement &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(partnerId, placement, kind);
}

/// Hisobot qatori: hamkor × kun × joy (shaxsiy ma'lumotsiz hisoblagich).
@immutable
class PartnerDayStat {
  const PartnerDayStat({
    required this.day,
    required this.placement,
    required this.impressions,
    required this.contacts,
  });

  factory PartnerDayStat.fromJson(Map<String, Object?> j) => PartnerDayStat(
    day: _day(j['day']! as String),
    placement: PartnerPlacement.parse(j['placement']! as String),
    impressions: (j['impressions']! as num).toInt(),
    contacts: (j['contacts']! as num).toInt(),
  );

  final DateTime day;
  final PartnerPlacement placement;
  final int impressions;
  final int contacts;
}

enum PartnerRequestStatus {
  newRequest('new'),
  inReview('in_review'),
  accepted('accepted'),
  declined('declined');

  const PartnerRequestStatus(this.wire);
  final String wire;

  static PartnerRequestStatus parse(String raw) => values.firstWhere(
    (s) => s.wire == raw,
    orElse: () => throw FormatException('unknown request status: $raw'),
  );
}

/// “Hamkor bo'lish” arizasi (firma vakili yuboradi).
@immutable
class PartnerRequestDraft {
  const PartnerRequestDraft({
    required this.company,
    required this.contactName,
    this.phone,
    this.email,
    this.products = '',
    this.message = '',
  });

  final String company;
  final String contactName;
  final String? phone;
  final String? email;
  final String products;
  final String message;

  /// Server CHECK lari bilan bir xil tekshiruv (xato bo'lsa — `false`).
  bool get isValid {
    final c = company.trim().length;
    final n = contactName.trim().length;
    final p = phone?.trim() ?? '';
    final e = email?.trim() ?? '';
    return c >= 2 &&
        c <= 120 &&
        n >= 2 &&
        n <= 80 &&
        (p.isNotEmpty || e.isNotEmpty) &&
        (p.isEmpty || isValidPartnerPhone(p)) &&
        (e.isEmpty || isValidPartnerEmail(e)) &&
        products.trim().length <= 1000 &&
        message.trim().length <= 2000;
  }
}

@immutable
class PartnerRequest {
  const PartnerRequest({
    required this.id,
    required this.userId,
    required this.company,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.products,
    required this.message,
    required this.status,
    required this.adminReply,
    required this.createdAt,
    required this.repliedAt,
  });

  factory PartnerRequest.fromJson(Map<String, Object?> j) => PartnerRequest(
    id: j['id']! as String,
    userId: j['user_id']! as String,
    company: j['company']! as String,
    contactName: j['contact_name']! as String,
    phone: j['phone'] as String?,
    email: j['email'] as String?,
    products: (j['products'] as String?) ?? '',
    message: (j['message'] as String?) ?? '',
    status: PartnerRequestStatus.parse(j['status']! as String),
    adminReply: j['admin_reply'] as String?,
    createdAt: DateTime.parse(j['created_at']! as String),
    repliedAt: j['replied_at'] == null
        ? null
        : DateTime.parse(j['replied_at']! as String),
  );

  final String id;
  final String userId;
  final String company;
  final String contactName;
  final String? phone;
  final String? email;
  final String products;
  final String message;
  final PartnerRequestStatus status;
  final String? adminReply;
  final DateTime createdAt;
  final DateTime? repliedAt;
}
