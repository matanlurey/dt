import 'package:dt/src/core.dart';
import 'package:test/test.dart';

void main() {
  group('$Offset', _offsetTests);
}

void _offsetTests() {
  test('zero is (0, 0)', () {
    expect(Offset.zero, Offset(0, 0));
  });

  test('compareTo the same offset returns 0', () {
    expect(Offset(1, 2).compareTo(Offset(1, 2)), 0);
  });

  test('compareTo an offset with a greater y returns -1', () {
    expect(Offset(1, 2).compareTo(Offset(1, 3)), -1);
  });

  test('compareTo an offset with a greater x returns -1', () {
    expect(Offset(1, 2).compareTo(Offset(2, 2)), -1);
  });

  test('compareTo an offset with a lesser y returns 1', () {
    expect(Offset(1, 2).compareTo(Offset(1, 1)), 1);
  });

  test('compareTo an offset with a lesser x returns 1', () {
    expect(Offset(1, 2).compareTo(Offset(0, 2)), 1);
  });

  test('compareTo with a lesser y and greater x returns 1', () {
    expect(Offset(1, 2).compareTo(Offset(2, 1)), 1);
  });

  test('compareTo with a greater y and lesser x returns -1', () {
    expect(Offset(1, 2).compareTo(Offset(0, 3)), -1);
  });

  test('isBefore the same offset returns false', () {
    expect(Offset(1, 2).isBefore(Offset(1, 2)), isFalse);
  });

  test('isBefore an offset ordered previously returns true', () {
    expect(Offset(1, 2).isBefore(Offset(1, 3)), isTrue);
  });

  test('isBefore an offset ordered later returns false', () {
    expect(Offset(1, 2).isBefore(Offset(1, 1)), isFalse);
  });

  test('operator< is an alias for isBefore', () {
    // Same tests as above but using operator<.
    expect(Offset(1, 2) < Offset(1, 2), isFalse);
    expect(Offset(1, 2) < Offset(1, 3), isTrue);
    expect(Offset(1, 2) < Offset(1, 1), isFalse);
  });

  test('isAfter the same offset returns false', () {
    expect(Offset(1, 2).isAfter(Offset(1, 2)), isFalse);
  });

  test('isAfter an offset ordered previously returns false', () {
    expect(Offset(1, 2).isAfter(Offset(1, 3)), isFalse);
  });

  test('isAfter an offset ordered later returns true', () {
    expect(Offset(1, 2).isAfter(Offset(1, 1)), isTrue);
  });

  test('operator> is an alias for isAfter', () {
    // Same tests as above but using operator>.
    expect(Offset(1, 2) > Offset(1, 2), isFalse);
    expect(Offset(1, 2) > Offset(1, 3), isFalse);
    expect(Offset(1, 2) > Offset(1, 1), isTrue);
  });

  test('operator<= returns <= the same offset', () {
    // Same tests as above but using operator<=.
    expect(Offset(1, 2) <= Offset(1, 2), isTrue);
    expect(Offset(1, 2) <= Offset(1, 3), isTrue);
    expect(Offset(1, 2) <= Offset(1, 1), isFalse);
  });

  test('operator>= returns >= the same offset', () {
    // Same tests as above but using operator>=.
    expect(Offset(1, 2) >= Offset(1, 2), isTrue);
    expect(Offset(1, 2) >= Offset(1, 3), isFalse);
    expect(Offset(1, 2) >= Offset(1, 1), isTrue);
  });

  test('hashCode', () {
    expect(Offset(1, 2).hashCode, Offset(1, 2).hashCode);
  });

  test('abs', () {
    expect(Offset(1, 2).abs(), Offset(1, 2));
    expect(Offset(-1, -2).abs(), Offset(1, 2));
  });

  test('clamp', () {
    expect(Offset(1, 2).clamp(Offset(0, 0), Offset(2, 3)), Offset(1, 2));
    expect(Offset(1, 2).clamp(Offset(2, 3), Offset(3, 4)), Offset(2, 3));
    expect(Offset(1, 2).clamp(Offset(0, 0), Offset(0, 0)), Offset(0, 0));
  });

  test('distanceTo', () {
    expect(Offset(1, 2).distanceTo(Offset(1, 2)), 0.0);
    expect(Offset(1, 2).distanceTo(Offset(1, 3)), 1.0);
    expect(Offset(1, 2).distanceTo(Offset(2, 2)), 1.0);
    expect(Offset(1, 2).distanceTo(Offset(2, 3)), closeTo(1.41, 0.01));
  });

  test('translate', () {
    expect(Offset(1, 2).translate(1, 2), Offset(2, 4));
  });

  test('operator+', () {
    expect(Offset(1, 2) + Offset(3, 4), Offset(4, 6));
  });

  test('operator- other', () {
    expect(Offset(1, 2) - Offset(3, 4), Offset(-2, -2));
  });

  test('operator- unary', () {
    expect(-Offset(1, 2), Offset(-1, -2));
  });

  test('operator*', () {
    expect(Offset(1, 2) * 3, Offset(3, 6));
  });

  test('operator~/', () {
    expect(Offset(3, 6) ~/ 3, Offset(1, 2));
  });

  test('operator%', () {
    expect(Offset(3, 5) % 3, Offset(0, 2));
  });

  test('toString', () {
    expect(Offset(1, 2).toString(), 'Offset (1, 2)');
  });
}
