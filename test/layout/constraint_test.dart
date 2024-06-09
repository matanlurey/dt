// ignore_for_file: non_const_call_to_literal_constructor

import 'package:dt/layout.dart';

import '../prelude.dart';

void main() {
  test('orders constraints by precedence', () {
    final constraints = [
      Flexible(1),
      Relative(0.5),
      Fixed(10),
      Minimum(5),
      Maximum(15),
    ];

    final sorted = [...constraints]..sort();
    check(sorted).deepEquals([
      Minimum(5),
      Maximum(15),
      Fixed(10),
      Relative(0.5),
      Flexible(1),
    ]);
  });

  group('Constraint.maximum', () {
    test('treats a size < 0 as 0', () {
      final max = Maximum(-1);
      check(max).has((c) => c.value, 'value').equals(0);
    });

    test('when applied to a size, returns the minimum of the two', () {
      final max = Maximum(10);
      check(max.apply(5)).equals(5);
      check(max.apply(15)).equals(10);
    });

    test('two maximum constraints with the same value are equal', () {
      check(Maximum(10)).equals(Maximum(10));
      check(Maximum(10))
          .has((c) => c.hashCode, 'hashCode')
          .equals(Maximum(10).hashCode);
    });

    test('should have a toString', () {
      check(Maximum(10).toString()).equals('Constraint.max(10)');
    });
  });

  group('Constraint.minimum', () {
    test('treats a size < 0 as 0', () {
      final min = Minimum(-1);
      check(min).has((c) => c.value, 'value').equals(0);
    });

    test('when applied to a size, returns the maximum of the two', () {
      final min = Minimum(10);
      check(min.apply(5)).equals(10);
      check(min.apply(15)).equals(15);
    });

    test('two minimum constraints with the same value are equal', () {
      check(Minimum(10)).equals(Minimum(10));
      check(Minimum(10))
          .has((c) => c.hashCode, 'hashCode')
          .equals(Minimum(10).hashCode);
    });

    test('should have a toString', () {
      check(Minimum(10).toString()).equals('Constraint.min(10)');
    });
  });

  group('Constraint.fixed', () {
    test('treats a size < 0 as 0', () {
      final fixed = Fixed(-1);
      check(fixed).has((c) => c.value, 'value').equals(0);
    });

    test('when applied to a size, returns the fixed value', () {
      final fixed = Fixed(10);
      check(fixed.apply(5)).equals(5);
      check(fixed.apply(15)).equals(10);
    });

    test('two fixed constraints with the same value are equal', () {
      check(Fixed(10)).equals(Fixed(10));
      check(Fixed(10))
          .has((c) => c.hashCode, 'hashCode')
          .equals(Fixed(10).hashCode);
    });

    test('should have a toString', () {
      check(Fixed(10).toString()).equals('Constraint.fixed(10)');
    });
  });

  group('Constraint.relative', () {
    test('treats a size < 0 as 0', () {
      final relative = Relative(-1);
      check(relative).has((c) => c.value, 'value').equals(0);
    });

    test('when applied to a size, returns size multiplied by the value', () {
      final relative = Relative(0.5);
      check(relative.apply(10)).equals(5);
      check(relative.apply(20)).equals(10);
    });

    test('two relative constraints with the same value are equal', () {
      check(Relative(0.5)).equals(Relative(0.5));
      check(Relative(0.5))
          .has((c) => c.hashCode, 'hashCode')
          .equals(Relative(0.5).hashCode);
    });

    test('should have a toString', () {
      check(Relative(0.5).toString()).equals('Constraint.relative(0.5)');
    });

    test('should convert from an integer percentage', () {
      check(Relative.percent(50)).equals(Relative(0.5));
    });

    test('should convert from a fraction', () {
      check(Relative.fraction(1, 2)).equals(Relative(0.5));
    });

    test('should treat the denominator as 1 if < 1', () {
      check(Relative.fraction(1, 0)).equals(Relative(1));
    });
  });

  group('Constraint.flexible', () {
    test('treats a size < 0 as 0', () {
      final flexible = Flexible(-1);
      check(flexible).has((c) => c.value, 'value').equals(0);
    });

    test('when applied to a size, returns the maximum of the two', () {
      final flexible = Flexible(2);
      check(flexible.apply(1)).equals(2);
      check(flexible.apply(3)).equals(3);
    });

    test('two flexible constraints with the same value are equal', () {
      check(Flexible(2)).equals(Flexible(2));
      check(Flexible(2))
          .has((c) => c.hashCode, 'hashCode')
          .equals(Flexible(2).hashCode);
    });

    test('should have a toString', () {
      check(Flexible(2).toString()).equals('Constraint.flexible(2)');
    });
  });
}
