import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/lg_art.dart';

void main() {
  test('bosh sahifa plitka rasmlari mavjud va pubspec papkasida', () {
    for (final loc in [
      '/lab/qc',
      '/lab/differential',
      '/lab/calibration',
      '/lab/calculators',
      '/lab/preanalytics',
      '/lab/instruments',
    ]) {
      final art = LgArt.forHomeLocation(loc);
      expect(art, isNotNull, reason: loc);
      expect(File(art!.asset).existsSync(), isTrue, reason: art.asset);
    }
    expect(LgArt.forHomeLocation('/tests'), isNull);
  });
}
