import 'package:flutter_payments/flutter_payments.dart';
import 'package:test/test.dart';

void main() {
  test('Period', () {
    var period = Period('P1M');
    expect(period.length, equals(1));
    expect(period.type, equals('month'));
    expect(period.toString(), equals('month'));

    period = Period('P2M');
    expect(period.length, equals(2));
    expect(period.type, equals('month'));
    expect(period.toString(), equals('2 months'));
  });
}
