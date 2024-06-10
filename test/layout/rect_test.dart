import 'package:dt/layout.dart';

import '../prelude.dart';

void main() {
  test('Rect.zero is (0, 0, 0, 0)', () {
    // ignore: use_named_constants
    check(Rect.zero).equals(const Rect.fromXYWH(0, 0, 0, 0));
  });

  test('Rect width of <0 clamps to 0', () {
    check(const Rect.fromXYWH(0, 0, -1, 1))
        .equals(const Rect.fromXYWH(0, 0, 0, 1));
  });

  test('Rect height of <0 clamps to 0', () {
    check(const Rect.fromXYWH(0, 0, 1, -1))
        .equals(const Rect.fromXYWH(0, 0, 1, 0));
  });

  test('Rect.fromXYWH(1, 2, 3, 4) is (1, 2, 3, 4)', () {
    check(const Rect.fromXYWH(1, 2, 3, 4))
        .equals(const Rect.fromXYWH(1, 2, 3, 4));
    check(const Rect.fromXYWH(1, 2, 3, 4))
        .has((r) => r.hashCode, 'hashCode')
        .equals(const Rect.fromXYWH(1, 2, 3, 4).hashCode);
  });

  test('left is x', () {
    check(const Rect.fromXYWH(1, 2, 3, 4)).has((r) => r.left, 'left').equals(1);
  });

  test('top is y', () {
    check(const Rect.fromXYWH(1, 2, 3, 4)).has((r) => r.top, 'top').equals(2);
  });

  test('right is x + width', () {
    check(const Rect.fromXYWH(1, 2, 3, 4))
        .has((r) => r.right, 'right')
        .equals(4);
  });

  test('bottom is y + height', () {
    check(const Rect.fromXYWH(1, 2, 3, 4))
        .has((r) => r.bottom, 'bottom')
        .equals(6);
  });

  test('topLeft is (x, y)', () {
    check(const Rect.fromXYWH(1, 2, 3, 4).topLeft).equals(const Offset(1, 2));
  });

  test('topRight is (right, y)', () {
    check(const Rect.fromXYWH(1, 2, 3, 4).topRight).equals(const Offset(4, 2));
  });

  test('bottomLeft is (x, bottom)', () {
    check(const Rect.fromXYWH(1, 2, 3, 4).bottomLeft)
        .equals(const Offset(1, 6));
  });

  test('bottomRight is (right, bottom)', () {
    check(const Rect.fromXYWH(1, 2, 3, 4).bottomRight)
        .equals(const Offset(4, 6));
  });

  test('toString returns "Rect.fromXYWH(1, 2, 3, 4)"', () {
    check(const Rect.fromXYWH(1, 2, 3, 4).toString())
        .equals('Rect.fromXYWH(1, 2, 3, 4)');
  });

  test('offsets returns all offsets in the rectangle', () {
    check(const Rect.fromXYWH(1, 1, 2, 2).offsets).deepEquals([
      const Offset(1, 1),
      const Offset(2, 1),
      const Offset(1, 2),
      const Offset(2, 2),
    ]);
  });

  test('columns returns all columns in the rectangle', () {
    check(const Rect.fromXYWH(1, 1, 2, 2).columns).deepEquals([
      const Rect.fromXYWH(1, 1, 1, 2),
      const Rect.fromXYWH(2, 1, 1, 2),
    ]);
  });

  test('rows returns all rows in the rectangle', () {
    check(const Rect.fromXYWH(1, 1, 2, 2).rows).deepEquals([
      const Rect.fromXYWH(1, 1, 2, 1),
      const Rect.fromXYWH(1, 2, 2, 1),
    ]);
  });

  test('area is width * height', () {
    check(const Rect.fromXYWH(1, 2, 3, 4))
        .has((r) => r.area, 'area')
        .equals(12);
  });

  test('isEmpty is true if area is 0', () {
    check(const Rect.fromXYWH(1, 2, 0, 0))
        .has((r) => r.isEmpty, 'isEmpty')
        .isTrue();
  });

  test('isNotEmpty is true if area is not 0', () {
    check(const Rect.fromXYWH(1, 2, 1, 1))
        .has((r) => r.isNotEmpty, 'isNotEmpty')
        .isTrue();
  });

  test('copyWith returns a new rectangle with the given arguments', () {
    check(
      const Rect.fromXYWH(1, 2, 3, 4).copyWith(x: 5, y: 6, width: 7, height: 8),
    ).equals(const Rect.fromXYWH(5, 6, 7, 8));
  });

  test('copyWith returns the original rectangle if no arguments are given', () {
    check(const Rect.fromXYWH(1, 2, 3, 4).copyWith())
        .equals(const Rect.fromXYWH(1, 2, 3, 4));
  });

  test('withOffset returns a new rectangle with the given offset', () {
    check(const Rect.fromXYWH(1, 2, 3, 4).withOffset(const Offset(5, 6)))
        .equals(
      const Rect.fromXYWH(5, 6, 3, 4),
    );
  });

  test('union returns a rectangle that contains both rectangles', () {
    check(
      const Rect.fromXYWH(1, 2, 3, 4).union(const Rect.fromXYWH(5, 6, 7, 8)),
    ).equals(
      const Rect.fromXYWH(1, 2, 11, 12),
    );
  });

  test('& is an alias for union', () {
    check(const Rect.fromXYWH(1, 2, 3, 4) & const Rect.fromXYWH(5, 6, 7, 8))
        .equals(
      const Rect.fromXYWH(1, 2, 11, 12),
    );
  });

  test('intersection returns a rect that contains the intersection', () {
    check(
      const Rect.fromXYWH(1, 2, 3, 4)
          .intersection(const Rect.fromXYWH(3, 4, 5, 6)),
    ).equals(
      const Rect.fromXYWH(3, 4, 1, 2),
    );
  });

  test('intersection returns an empty rect if there is no intersection', () {
    final result = const Rect.fromXYWH(1, 2, 3, 4)
        .intersection(const Rect.fromXYWH(5, 6, 7, 8));
    check(result).has((r) => r.isEmpty, 'isEmpty').isTrue();
  });

  test('operator | is an alias for intersection', () {
    check(const Rect.fromXYWH(1, 2, 3, 4) | const Rect.fromXYWH(3, 4, 5, 6))
        .equals(
      const Rect.fromXYWH(3, 4, 1, 2),
    );
  });

  test('intersects returns true if the rectangles intersect', () {
    check(
      const Rect.fromXYWH(1, 2, 3, 4)
          .intersects(const Rect.fromXYWH(3, 4, 5, 6)),
    ).isTrue();
    check(
      const Rect.fromXYWH(1, 2, 3, 4)
          .intersects(const Rect.fromXYWH(5, 6, 7, 8)),
    ).isFalse();
  });

  test('contains returns true if the given offset is inside the rectangle', () {
    check(const Rect.fromXYWH(1, 2, 3, 4).contains(const Offset(2, 3)))
        .isTrue();
    check(const Rect.fromXYWH(1, 2, 3, 4).contains(const Offset(4, 6)))
        .isFalse();
  });

  test('clamp returns a new rectangle that is inside the given rectangle', () {
    check(
      const Rect.fromXYWH(1, 2, 3, 4).clamp(const Rect.fromXYWH(2, 3, 4, 5)),
    ).equals(
      const Rect.fromXYWH(2, 3, 2, 3),
    );
  });
}
