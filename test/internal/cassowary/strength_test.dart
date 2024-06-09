import 'package:dt/src/internal/cassowary.dart';

import '../../prelude.dart';

void main() {
  group('Strength.required', () {
    test('isRequired and !isFallible', () {
      check(Strength.required)
        ..has((s) => s.isRequired, 'isRequired').isTrue()
        ..has((s) => s.isFallible, 'isFallible').isFalse();
    });

    test('is the same as Strength(strong: 1000, medium: 1000, weak: 1000)', () {
      check(Strength.required).equals(
        Strength(strong: 1000, medium: 1000, weak: 1000),
      );
    });
  });

  group('Strength.strong', () {
    test('isFallible and !isRequired', () {
      check(Strength.strong)
        ..has((s) => s.isFallible, 'isFallible').isTrue()
        ..has((s) => s.isRequired, 'isRequired').isFalse();
    });

    test('is the same as Strength(strong: 1)', () {
      check(Strength.strong).equals(Strength(strong: 1));
    });
  });

  group('Strength.medium', () {
    test('isFallible and !isRequired', () {
      check(Strength.medium)
        ..has((s) => s.isFallible, 'isFallible').isTrue()
        ..has((s) => s.isRequired, 'isRequired').isFalse();
    });

    test('is the same as Strength(medium: 1)', () {
      check(Strength.medium).equals(Strength(medium: 1));
    });
  });

  group('Strength.weak', () {
    test('isFallible and !isRequired', () {
      check(Strength.weak)
        ..has((s) => s.isFallible, 'isFallible').isTrue()
        ..has((s) => s.isRequired, 'isRequired').isFalse();
    });

    test('is the same as Strength(weak: 1)', () {
      check(Strength.weak).equals(Strength(weak: 1));
    });
  });

  group('Strength.none', () {
    test('isFallible and !isRequired', () {
      check(Strength.none)
        ..has((s) => s.isFallible, 'isFallible').isTrue()
        ..has((s) => s.isRequired, 'isRequired').isFalse();
    });

    test('is the same as Strength()', () {
      check(Strength.none).equals(Strength());
    });
  });

  group('Strength.from', () {
    test('clamps the value to the valid range', () {
      check(Strength.from(-1)).equals(Strength.from(0));
      check(Strength.from(0)).equals(Strength.from(0));
      check(Strength.from(1000)).equals(Strength.from(1000));

      final required = Strength.required as double;
      check(Strength.from(required + 1)).equals(Strength.required);
    });
  });

  test('can be scaled by a factor', () {
    final strength = Strength.from(1000) * 1000;
    check(strength).equals(Strength(medium: 1000));
  });

  test('is clamped when scaled by a factor', () {
    check(Strength.weak * -1).equals(Strength.none);
    check(Strength.required * 2).equals(Strength.required);
  });
}
