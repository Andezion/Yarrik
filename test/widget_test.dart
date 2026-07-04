import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yarrik/utils/date_utils.dart';
import 'package:yarrik/utils/color_utils.dart';
import 'package:yarrik/widgets/splash_screen.dart';

void main() {
  test('fmtShort formats an ISO date as "d mon"', () {
    expect(fmtShort('2026-07-04'), '4 июл');
  });

  test('fmtVol switches to tonnes above 1000kg', () {
    expect(fmtVol(840), '840 кг');
    expect(fmtVol(1234), '1.2 т');
  });

  test('weekKey returns the Monday of the given date\'s week', () {
    expect(weekKey(DateTime(2026, 7, 4)), '2026-06-29');
  });

  test('colorFromHex parses 6-digit hex strings', () {
    expect(colorFromHex('#17B8A6'), const Color(0xFF17B8A6));
  });

  testWidgets('SplashScreen renders the ARMFORGE wordmark', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    final richText = tester.widget<RichText>(find.byType(RichText).first);
    expect(richText.text.toPlainText(), 'ARMFORGE');
  });
}
