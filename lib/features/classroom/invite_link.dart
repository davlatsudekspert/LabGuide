// Guruh taklifi havolasi: QR va “Havolani qo'yish” uchun yagona format.
//
//   https://labguide.nfcstore.uz/j/?c=ABCD2345            — guruhga qo'shilish
//   https://labguide.nfcstore.uz/j/?c=ABCD2345&a=<uuid>   — + shu testni ochish
//
// Telefon kamerasi havolani saytda ochadi (site/j/: kod va “Ilovada ochish”
// tugmasi — `labguide://app/j?c=...`); ilova ichida havola yoki taklif
// matni qo'yilsa — kod va test id shu yerda ajratib olinadi.

/// Taklif kodi alifbosi (server `CODE_RE` bilan bir xil: 0/O/1/I yo'q).
const inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

const inviteHost = 'labguide.nfcstore.uz';

final _codeRe = RegExp(r'^[A-HJ-NP-Z2-9]{8}$');

/// Topshiriq id si (serverda UUID): faqat harf/raqam/chiziqcha, ≤ 64.
final _assignmentRe = RegExp(r'^[a-z0-9][a-z0-9-]{0,63}$');

/// Havola yoki matndan topilgan taklif.
class InviteTarget {
  const InviteTarget(this.code, {this.assignmentId});

  final String code;

  /// Ustoz “Test QR” bergan bo'lsa — qo'shilgach darhol ochiladigan test.
  final String? assignmentId;

  @override
  bool operator ==(Object other) =>
      other is InviteTarget &&
      other.code == code &&
      other.assignmentId == assignmentId;

  @override
  int get hashCode => Object.hash(code, assignmentId);

  @override
  String toString() => 'InviteTarget($code, $assignmentId)';
}

/// QR / ulashish uchun havola.
String inviteUrl(String code, {String? assignmentId}) =>
    Uri.https(inviteHost, '/j/', {'c': code, 'a': ?assignmentId}).toString();

/// Kodni normallashtiradi (bo'shliq/chiziqcha olib tashlanadi, katta harf);
/// yaroqsiz bo'lsa — null.
String? normalizeInviteCode(String? raw) {
  if (raw == null) return null;
  final c = raw.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
  return _codeRe.hasMatch(c) ? c : null;
}

String? _assignment(String? raw) {
  final a = raw?.trim().toLowerCase();
  return a != null && _assignmentRe.hasMatch(a) ? a : null;
}

/// Matndan taklifni ajratadi: xom kod (`abcd-2345`), sayt havolasi
/// (`.../j/?c=..&a=..`), ilova havolasi (`labguide://app/j?...`,
/// `/learn/classes/join?code=..`) yoki “… Kod: ABCD2345” taklif matni.
/// Ishonchli kod topilmasa — null (taxmin qilinmaydi).
InviteTarget? parseInvite(String? text) {
  if (text == null) return null;
  final t = text.trim();
  if (t.isEmpty || t.length > 2000) return null;
  final raw = normalizeInviteCode(t);
  if (raw != null) return InviteTarget(raw);
  // Matn ichidagi havola(lar).
  for (final m in RegExp(
    r'[a-zA-Z][a-zA-Z0-9+.-]*://\S+|/learn/classes/join\?\S+',
  ).allMatches(t)) {
    final uri = Uri.tryParse(
      m.group(0)!.replaceAll(RegExp(r'[).,;!?»"]+$'), ''),
    );
    if (uri == null) continue;
    final q = uri.queryParameters;
    final code = normalizeInviteCode(q['c'] ?? q['code']);
    if (code != null) {
      return InviteTarget(code, assignmentId: _assignment(q['a']));
    }
  }
  // “Kod: ABCD2345” / “Код: …” / “Code: …”.
  final labelled = RegExp(
    r'(?:kod|код|code)\s*[:：]?\s*([A-Za-z2-9]{4}[\s-]?[A-Za-z2-9]{4})\b',
    caseSensitive: false,
    unicode: true,
  ).firstMatch(t);
  final fromLabel = normalizeInviteCode(labelled?.group(1));
  if (fromLabel != null) return InviteTarget(fromLabel);
  // Oxirgi imkon: matnda yagona 8 belgili KATTA harfli kod.
  final found = {
    for (final m in RegExp(
      r'(?<![A-Za-z0-9])([A-HJ-NP-Z2-9]{4}-?[A-HJ-NP-Z2-9]{4})(?![A-Za-z0-9])',
    ).allMatches(t))
      normalizeInviteCode(m.group(1))!,
  };
  return found.length == 1 ? InviteTarget(found.single) : null;
}
