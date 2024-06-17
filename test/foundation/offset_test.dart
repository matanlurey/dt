import 'package:dt/foundation.dart';

import '../prelude.dart';

void main() {
  test('Offset.zero is (0, 0)', () {
    check(Offset.zero).equals(Offset.from((0, 0)));
  });

  test('Offset(1, 2) is (1, 2)', () {
    check(const Offset(1, 2)).equals(Offset.from((1, 2)));
  });

  test('Offset(1, 2) is not Offset(2, 1)', () {
    check(const Offset(1, 2)).not((o) => o.equals(const Offset(2, 1)));
  });

  test('Offset(2, 1) is less than Offset(1, 2)', () {
    check(const Offset(2, 1)).isLessThan(const Offset(1, 2));
  });

  test('Offset(0, 3) is greater than Offset(1, 2)', () {
    check(const Offset(0, 3)).isGreaterThan(const Offset(1, 2));
  });

  test('Offset(1, 2) is less than Offset(1, 3)', () {
    check(const Offset(1, 2)).isLessThan(const Offset(1, 3));
  });

  test('Offset(1, 3) is greater than Offset(1, 2)', () {
    check(const Offset(1, 3)).isGreaterThan(const Offset(1, 2));
  });

  test('Offset (2, 1) is less than Offset(3, 1)', () {
    check(const Offset(2, 1)).isLessThan(const Offset(3, 1));
  });

  test('Offset(3, 1) is greater than Offset(2, 1)', () {
    check(const Offset(3, 1)).isGreaterThan(const Offset(2, 1));
  });

  test('Offset(1, 2) is equal to Offset(1, 2)', () {
    check(const Offset(1, 2)).equals(const Offset(1, 2));
    check(const Offset(1, 2))
        .has((o) => o.hashCode, 'hashCode')
        .equals(const Offset(1, 2).hashCode);
  });

  test('Offset(1, 2) + Offset(2, 3)', () {
    check(const Offset(1, 2) + const Offset(2, 3)).equals(const Offset(3, 5));
  });

  test('Offset(2, 3) - Offset(1, 2)', () {
    check(const Offset(2, 3) - const Offset(1, 2)).equals(const Offset(1, 1));
  });

  test('toPair returns (1, 2)', () {
    check(const Offset(1, 2).toPair()).equals((1, 2));
  });

  test('toString returns "Offset(1, 2)"', () {
    check(const Offset(1, 2).toString()).equals('Offset(1, 2)');
  });
}
