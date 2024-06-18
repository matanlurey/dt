import 'package:dt/layout.dart';

import '../prelude.dart';

void main() {
  test('Fixed ==, hashCode, toString', () {
    final layout1 = const Fixed(2);
    final layout2 = const Fixed(2);
    final layout3 = const Fixed(3);

    check(layout1)
      ..has((l) => l == layout1, '== layout1').isTrue()
      ..has((l) => l == layout2, '== layout2').isTrue()
      ..has((l) => l == layout3, '== layout3').isFalse()
      ..has((l) => l.hashCode, 'hashCode').equals(layout2.hashCode)
      ..has((l) => l.toString(), 'toString').equals('Fixed(2)');
  });

  test('Flexible ==, hashCode, toString', () {
    final layout1 = const Flexible(2);
    final layout2 = const Flexible(2);
    final layout3 = const Flexible(3);

    check(layout1)
      ..has((l) => l == layout1, '== layout1').isTrue()
      ..has((l) => l == layout2, '== layout2').isTrue()
      ..has((l) => l == layout3, '== layout3').isFalse()
      ..has((l) => l.hashCode, 'hashCode').equals(layout2.hashCode)
      ..has((l) => l.toString(), 'toString').equals('Flexible(2)');
  });

  test('Constrained ==, hashCode, toString', () {
    final layout1 = Constrained.vertical(
      const [
        Fixed(2),
        Flexible(1),
        Fixed(3),
      ],
    );
    final layout2 = Constrained.vertical(
      const [
        Fixed(2),
        Flexible(1),
        Fixed(3),
      ],
    );
    final layout3 = Constrained.vertical(
      const [
        Fixed(2),
        Flexible(1),
        Fixed(4),
      ],
    );

    check(layout1)
      ..has((l) => l == layout1, '== layout1').isTrue()
      ..has((l) => l == layout2, '== layout2').isTrue()
      ..has((l) => l == layout3, '== layout3').isFalse()
      ..has((l) => l.hashCode, 'hashCode').equals(layout2.hashCode)
      ..has(
        (l) => l.toString(),
        'toString',
      ).equals('Constrained.vertical([Fixed(2), Flexible(1), Fixed(3)])');
  });

  group('Constrained.vertical', () {
    test('fixed sizes only', () {
      final layout = Constrained.vertical(
        [
          Constraint.fixed(2),
          Constraint.fixed(3),
          Constraint.fixed(4),
        ],
      );

      final result = layout.split(const Rect.fromSize(9, 9));
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 2, 9),
        Rect.fromLTWH(2, 0, 3, 9),
        Rect.fromLTWH(5, 0, 4, 9),
      ]);
    });

    test('flexible sizes only', () {
      final layout = Constrained.vertical(
        [
          Constraint.flex(1),
          Constraint.flex(2),
          Constraint.flex(3),
        ],
      );

      final result = layout.split(const Rect.fromSize(6, 6));
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 1, 6),
        Rect.fromLTWH(1, 0, 2, 6),
        Rect.fromLTWH(3, 0, 3, 6),
      ]);
    });

    test('mixed sizes', () {
      final layout = Constrained.vertical(
        [
          Constraint.fixed(2),
          Constraint.flex(1),
          Constraint.fixed(4),
        ],
      );

      final result = layout.split(const Rect.fromSize(9, 9));
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 2, 9),
        Rect.fromLTWH(2, 0, 3, 9),
        Rect.fromLTWH(5, 0, 4, 9),
      ]);
    });
  });

  group('Constrained.horizontal', () {
    test('fixed sizes only', () {
      final layout = Constrained.horizontal(
        [
          Constraint.fixed(2),
          Constraint.fixed(3),
          Constraint.fixed(4),
        ],
      );

      final result = layout.split(const Rect.fromSize(9, 9));
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 9, 2),
        Rect.fromLTWH(0, 2, 9, 3),
        Rect.fromLTWH(0, 5, 9, 4),
      ]);
    });

    test('flexible sizes only', () {
      final layout = Constrained.horizontal(
        [
          Constraint.flex(1),
          Constraint.flex(2),
          Constraint.flex(3),
        ],
      );

      final result = layout.split(const Rect.fromSize(6, 6));
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 6, 1),
        Rect.fromLTWH(0, 1, 6, 2),
        Rect.fromLTWH(0, 3, 6, 3),
      ]);
    });

    test('mixed sizes', () {
      final layout = Constrained.horizontal(
        [
          Constraint.flex(1),
          Constraint.fixed(1),
          Constraint.fixed(1),
        ],
      );

      final result = layout.split(const Rect.fromSize(9, 9));
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 9, 7),
        Rect.fromLTWH(0, 7, 9, 1),
        Rect.fromLTWH(0, 8, 9, 1),
      ]);
    });
  });
}
