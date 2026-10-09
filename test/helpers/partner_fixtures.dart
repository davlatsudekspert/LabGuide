import 'package:labguide/core/backend/partner_models.dart';

/// Testlar uchun hamkor (to'qima kompaniya — faqat test/rasm uchun, ilova
/// kontentiga kirmaydi). Sana bugungi Toshkent kuniga nisbatan.
Partner testPartner({
  String id = 'partner-test-1',
  String name = 'Sinov Hamkor MChJ',
  PartnerKind kind = PartnerKind.distributor,
  PartnerStatus status = PartnerStatus.published,
  int fromDays = -1,
  int toDays = 30,
  List<PartnerLink>? links,
  String? phone = '+998 71 200-00-00',
  String? telegram = 'sinov_hamkor',
  String? website = 'https://example.com',
  List<String> regions = const ['tashkent_city', 'samarkand', 'fergana'],
}) {
  final today = tashkentToday(DateTime.now());
  return Partner(
    id: id,
    name: name,
    kind: kind,
    summary: const {
      'uz':
          'Mindray biokimyo analizatorlari: yetkazib berish, o‘rnatish, '
          'xodimlarni o‘qitish va kafolat servisi.',
      'ru':
          'Биохимические анализаторы Mindray: поставка, установка, '
          'обучение персонала и гарантийный сервис.',
      'en':
          'Mindray chemistry analysers: supply, installation, staff '
          'training and warranty service.',
    },
    regions: regions,
    phone: phone,
    telegram: telegram,
    website: website,
    email: 'sales@example.com',
    brochureUrl: 'https://example.com/brochure.pdf',
    startsOn: today.add(Duration(days: fromDays)),
    endsOn: today.add(Duration(days: toDays)),
    status: status,
    links:
        links ??
        const [
          PartnerLink(target: PartnerLinkTarget.maker, catalogId: 'mindray'),
          PartnerLink(
            target: PartnerLinkTarget.model,
            catalogId: 'mindray-bs-240',
            registrationNo: 'TEST-0001',
          ),
        ],
  );
}
