import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/classroom/invite_link.dart';

const _a = '0f8b2c4e-1d2a-4b3c-9d8e-7f6a5b4c3d2e';

void main() {
  group('inviteUrl', () {
    test('kod va test id', () {
      expect(
        inviteUrl('ABCD2345'),
        'https://labguide.nfcstore.uz/j/?c=ABCD2345',
      );
      expect(
        inviteUrl('ABCD2345', assignmentId: _a),
        'https://labguide.nfcstore.uz/j/?c=ABCD2345&a=$_a',
      );
    });

    test('havola qayta o‘qiladi', () {
      expect(
        parseInvite(inviteUrl('ABCD2345', assignmentId: _a)),
        const InviteTarget('ABCD2345', assignmentId: _a),
      );
    });
  });

  group('parseInvite', () {
    test('xom kod: kichik harf, bo‘shliq, chiziqcha', () {
      expect(parseInvite('abcd2345'), const InviteTarget('ABCD2345'));
      expect(parseInvite(' ABCD 2345 '), const InviteTarget('ABCD2345'));
      expect(parseInvite('abcd-2345'), const InviteTarget('ABCD2345'));
    });

    test('sayt, ilova va eski havolalar', () {
      expect(
        parseInvite('https://labguide.nfcstore.uz/j/?c=abcd2345&a=$_a'),
        const InviteTarget('ABCD2345', assignmentId: _a),
      );
      expect(
        parseInvite('labguide://app/j?c=ABCD2345'),
        const InviteTarget('ABCD2345'),
      );
      expect(
        parseInvite('/learn/classes/join?code=ABCD2345'),
        const InviteTarget('ABCD2345'),
      );
      // Test id buzuq bo'lsa — faqat kod.
      expect(
        parseInvite('https://labguide.nfcstore.uz/j/?c=ABCD2345&a=1;DROP'),
        const InviteTarget('ABCD2345'),
      );
    });

    test('taklif matni (uz/ru/en) va havolali matn', () {
      expect(
        parseInvite(
          'LabGuide ilovasidagi “KLD-1” guruhiga qo‘shiling: O‘rganish → '
          'Guruh va topshiriqlar → Kod bilan qo‘shilish. Kod: ABCD2345',
        ),
        const InviteTarget('ABCD2345'),
      );
      expect(
        parseInvite('Вступайте в группу. Код: abcd-2345.'),
        const InviteTarget('ABCD2345'),
      );
      expect(
        parseInvite(
          'Join my group! Code: ABCD2345\n'
          'https://labguide.nfcstore.uz/j/?c=ABCD2345&a=$_a',
        ),
        const InviteTarget('ABCD2345', assignmentId: _a),
      );
    });

    test('axlat — null (taxmin qilinmaydi)', () {
      for (final junk in [
        null,
        '',
        '   ',
        'salom',
        'ABCD234', // 7 belgi
        'ABCD23456', // 9 belgi
        'ABCD0O1I', // taqiqlangan belgilar
        'https://example.com/?q=1',
        'https://labguide.nfcstore.uz/j/?c=ZZZ',
        // Ikki xil kod — qaysi biri ekanini bilmaymiz.
        'ABCD2345 va WXYZ6789',
        'x' * 3000,
      ]) {
        expect(parseInvite(junk), isNull, reason: '$junk');
      }
    });
  });
}
