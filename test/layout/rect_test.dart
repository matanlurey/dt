// ignore_for_file: non_const_call_to_literal_constructor

import 'package:dt/layout.dart';

import '../prelude.dart';

void main() {
  test('Rect.zero is (0, 0, 0, 0)', () {
    // ignore: use_named_constants
    check(Rect.zero).equals(Rect.fromXYWH(0, 0, 0, 0));
  });

  test('Rect width of <0 clamps to 0', () {
    check(Rect.fromXYWH(0, 0, -1, 1)).equals(Rect.fromXYWH(0, 0, 0, 1));
  });

  test('Rect height of <0 clamps to 0', () {
    check(Rect.fromXYWH(0, 0, 1, -1)).equals(Rect.fromXYWH(0, 0, 1, 0));
  });

  test('Rect.fromXYWH(1, 2, 3, 4) is (1, 2, 3, 4)', () {
    check(Rect.fromXYWH(1, 2, 3, 4)).equals(Rect.fromXYWH(1, 2, 3, 4));
    check(Rect.fromXYWH(1, 2, 3, 4))
        .has((r) => r.hashCode, 'hashCode')
        .equals(Rect.fromXYWH(1, 2, 3, 4).hashCode);
  });

  test('left is x', () {
    check(Rect.fromXYWH(1, 2, 3, 4)).has((r) => r.left, 'left').equals(1);
  });

  test('top is y', () {
    check(Rect.fromXYWH(1, 2, 3, 4)).has((r) => r.top, 'top').equals(2);
  });

  test('right is x + width', () {
    check(Rect.fromXYWH(1, 2, 3, 4)).has((r) => r.right, 'right').equals(4);
  });

  test('bottom is y + height', () {
    check(Rect.fromXYWH(1, 2, 3, 4)).has((r) => r.bottom, 'bottom').equals(6);
  });

  test('topLeft is (x, y)', () {
    check(Rect.fromXYWH(1, 2, 3, 4).topLeft).equals(Offset(1, 2));
  });

  test('topRight is (right, y)', () {
    check(Rect.fromXYWH(1, 2, 3, 4).topRight).equals(Offset(4, 2));
  });

  test('bottomLeft is (x, bottom)', () {
    check(Rect.fromXYWH(1, 2, 3, 4).bottomLeft).equals(Offset(1, 6));
  });

  test('bottomRight is (right, bottom)', () {
    check(Rect.fromXYWH(1, 2, 3, 4).bottomRight).equals(Offset(4, 6));
  });

  test('toString returns "Rect.fromXYWH(1, 2, 3, 4)"', () {
    check(Rect.fromXYWH(1, 2, 3, 4).toString())
        .equals('Rect.fromXYWH(1, 2, 3, 4)');
  });

  test('offsets returns all offsets in the rectangle', () {
    check(Rect.fromXYWH(1, 1, 2, 2).offsets).deepEquals([
      Offset(1, 1),
      Offset(2, 1),
      Offset(1, 2),
      Offset(2, 2),
    ]);
  });

  test('columns returns all columns in the rectangle', () {
    check(Rect.fromXYWH(1, 1, 2, 2).columns).deepEquals([
      Rect.fromXYWH(1, 1, 1, 2),
      Rect.fromXYWH(2, 1, 1, 2),
    ]);
  });

  test('rows returns all rows in the rectangle', () {
    check(Rect.fromXYWH(1, 1, 2, 2).rows).deepEquals([
      Rect.fromXYWH(1, 1, 2, 1),
      Rect.fromXYWH(1, 2, 2, 1),
    ]);
  });

  test('area is width * height', () {
    check(Rect.fromXYWH(1, 2, 3, 4)).has((r) => r.area, 'area').equals(12);
  });

  test('isEmpty is true if area is 0', () {
    check(Rect.fromXYWH(1, 2, 0, 0)).has((r) => r.isEmpty, 'isEmpty').isTrue();
  });

  test('isNotEmpty is true if area is not 0', () {
    check(Rect.fromXYWH(1, 2, 1, 1))
        .has((r) => r.isNotEmpty, 'isNotEmpty')
        .isTrue();
  });

  test('copyWith returns a new rectangle with the given arguments', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4).copyWith(x: 5, y: 6, width: 7, height: 8),
    ).equals(Rect.fromXYWH(5, 6, 7, 8));
  });

  test('copyWith returns the original rectangle if no arguments are given', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4).copyWith(),
    ).equals(Rect.fromXYWH(1, 2, 3, 4));
  });

  test('withOffset returns a new rectangle with the given offset', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4).withOffset(Offset(5, 6)),
    ).equals(
      Rect.fromXYWH(5, 6, 3, 4),
    );
  });

  test('union returns a rectangle that contains both rectangles', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4).union(Rect.fromXYWH(5, 6, 7, 8)),
    ).equals(
      Rect.fromXYWH(1, 2, 11, 12),
    );
  });

  test('& is an alias for union', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4) & Rect.fromXYWH(5, 6, 7, 8),
    ).equals(
      Rect.fromXYWH(1, 2, 11, 12),
    );
  });

  test('intersection returns a rect that contains the intersection', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4).intersection(
        Rect.fromXYWH(3, 4, 5, 6),
      ),
    ).equals(
      Rect.fromXYWH(3, 4, 1, 2),
    );
  });

  test('intersection returns an empty rect if there is no intersection', () {
    final result = Rect.fromXYWH(1, 2, 3, 4).intersection(
      Rect.fromXYWH(5, 6, 7, 8),
    );
    check(result).has((r) => r.isEmpty, 'isEmpty').isTrue();
  });

  test('operator | is an alias for intersection', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4) | Rect.fromXYWH(3, 4, 5, 6),
    ).equals(
      Rect.fromXYWH(3, 4, 1, 2),
    );
  });

  test('intersects returns true if the rectangles intersect', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4).intersects(
        Rect.fromXYWH(3, 4, 5, 6),
      ),
    ).isTrue();
    check(
      Rect.fromXYWH(1, 2, 3, 4).intersects(
        Rect.fromXYWH(5, 6, 7, 8),
      ),
    ).isFalse();
  });

  test('contains returns true if the given offset is inside the rectangle', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4).contains(Offset(2, 3)),
    ).isTrue();
    check(
      Rect.fromXYWH(1, 2, 3, 4).contains(Offset(4, 6)),
    ).isFalse();
  });

  test('clamp returns a new rectangle that is inside the given rectangle', () {
    check(
      Rect.fromXYWH(1, 2, 3, 4).clamp(Rect.fromXYWH(2, 3, 4, 5)),
    ).equals(
      Rect.fromXYWH(2, 3, 2, 3),
    );
  });
}
