import 'package:flutter_test/flutter_test.dart';
import 'package:sayo_app/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formatMoney formats correctly', () {
      expect(formatMoney(1000.00), '\$1,000.00');
      expect(formatMoney(0.0), '\$0.00');
      expect(formatMoney(47520.83), '\$47,520.83');
    });

    test('formatPhone formats 10-digit numbers', () {
      expect(formatPhone('3312345678'), '331 234 5678');
    });

    test('formatPhone returns original for non-10-digit', () {
      expect(formatPhone('123'), '123');
    });

    test('formatClabe formats 18-digit CLABE', () {
      expect(formatClabe('646180204800012345'), '646 180 2048 0001 2345');
    });

    test('formatClabe returns original for non-18-digit', () {
      expect(formatClabe('123'), '123');
    });

    test('timeAgo returns Ahora for recent times', () {
      expect(timeAgo(DateTime.now()), 'Ahora');
    });
  });
}
