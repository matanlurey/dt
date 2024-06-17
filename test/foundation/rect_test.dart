// ignore_for_file: non_const_call_to_literal_constructor

import 'package:dt/foundation.dart';

import '../prelude.dart';

void main() {
  test('Rect.zero is (0, 0, 0, 0)', () {
    // ignore: use_named_constants
    check(Rect.zero).equals(Rect.fromLTWH(0, 0, 0, 0));
  });

  test('Rect width of <0 clamps to 0', () {
    check(Rect.fromLTWH(0, 0, -1, 1)).equals(Rect.fromLTWH(0, 0, 0, 1));
  });

  test('Rect height of <0 clamps to 0', () {
    check(Rect.fromLTWH(0, 0, 1, -1)).equals(Rect.fromLTWH(0, 0, 1, 0));
  });

  test('Rect.fromSize is (0, 0, width, height)', () {
    check(Rect.fromSize(1, 2)).equals(Rect.fromLTWH(0, 0, 1, 2));
  });

  test('Rect.fromLTWH(1, 2, 3, 4) is (1, 2, 3, 4)', () {
    check(Rect.fromLTWH(1, 2, 3, 4)).equals(Rect.fromLTWH(1, 2, 3, 4));
    check(Rect.fromLTWH(1, 2, 3, 4))
        .has((r) => r.hashCode, 'hashCode')
        .equals(Rect.fromLTWH(1, 2, 3, 4).hashCode);
  });

  test('left is x', () {
    check(Rect.fromLTWH(1, 2, 3, 4)).has((r) => r.left, 'left').equals(1);
  });

  test('top is y', () {
    check(Rect.fromLTWH(1, 2, 3, 4)).has((r) => r.top, 'top').equals(2);
  });

  test('right is x + width', () {
    check(Rect.fromLTWH(1, 2, 3, 4)).has((r) => r.right, 'right').equals(4);
  });

  test('bottom is y + height', () {
    check(Rect.fromLTWH(1, 2, 3, 4)).has((r) => r.bottom, 'bottom').equals(6);
  });

  test('topLeft is (x, y)', () {
    check(Rect.fromLTWH(1, 2, 3, 4).topLeft).equals(Offset(1, 2));
  });

  test('topRight is (right, y)', () {
    check(Rect.fromLTWH(1, 2, 3, 4).topRight).equals(Offset(4, 2));
  });

  test('bottomLeft is (x, bottom)', () {
    check(Rect.fromLTWH(1, 2, 3, 4).bottomLeft).equals(Offset(1, 6));
  });

  test('bottomRight is (right, bottom)', () {
    check(Rect.fromLTWH(1, 2, 3, 4).bottomRight).equals(Offset(4, 6));
  });

  test('toString returns "Rect.fromLTWH(1, 2, 3, 4)"', () {
    check(Rect.fromLTWH(1, 2, 3, 4).toString())
        .equals('Rect.fromLTWH(1, 2, 3, 4)');
  });

  test('offsets returns all offsets in the rectangle', () {
    check(Rect.fromLTWH(1, 1, 2, 2).offsets).deepEquals([
      Offset(1, 1),
      Offset(2, 1),
      Offset(1, 2),
      Offset(2, 2),
    ]);
  });

  test('area is width * height', () {
    check(Rect.fromLTWH(1, 2, 3, 4)).has((r) => r.area, 'area').equals(12);
  });

  test('isEmpty is true if area is 0', () {
    check(Rect.fromLTWH(1, 2, 0, 0)).has((r) => r.isEmpty, 'isEmpty').isTrue();
  });

  test('isNotEmpty is true if area is not 0', () {
    check(Rect.fromLTWH(1, 2, 1, 1))
        .has((r) => r.isNotEmpty, 'isNotEmpty')
        .isTrue();
  });

  test('copyWith returns a new rectangle with the given arguments', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4).copyWith(x: 5, y: 6, width: 7, height: 8),
    ).equals(Rect.fromLTWH(5, 6, 7, 8));
  });

  test('copyWith returns the original rectangle if no arguments are given', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4).copyWith(),
    ).equals(Rect.fromLTWH(1, 2, 3, 4));
  });

  test('withOffset returns a new rectangle with the given offset', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4).withOffset(Offset(5, 6)),
    ).equals(
      Rect.fromLTWH(5, 6, 3, 4),
    );
  });

  test('union returns a rectangle that contains both rectangles', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4).union(Rect.fromLTWH(5, 6, 7, 8)),
    ).equals(
      Rect.fromLTWH(1, 2, 11, 12),
    );
  });

  test('& is an alias for union', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4) & Rect.fromLTWH(5, 6, 7, 8),
    ).equals(
      Rect.fromLTWH(1, 2, 11, 12),
    );
  });

  test('intersection returns a rect that contains the intersection', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4).intersect(
        Rect.fromLTWH(3, 4, 5, 6),
      ),
    ).equals(
      Rect.fromLTWH(3, 4, 1, 2),
    );
  });

  test('intersection returns an empty rect if there is no intersection', () {
    final result = Rect.fromLTWH(1, 2, 3, 4).intersect(
      Rect.fromLTWH(5, 6, 7, 8),
    );
    check(result).has((r) => r.isEmpty, 'isEmpty').isTrue();
  });

  test('operator | is an alias for intersection', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4) | Rect.fromLTWH(3, 4, 5, 6),
    ).equals(
      Rect.fromLTWH(3, 4, 1, 2),
    );
  });

  test('intersects returns true if the rectangles intersect', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4).intersects(
        Rect.fromLTWH(3, 4, 5, 6),
      ),
    ).isTrue();
    check(
      Rect.fromLTWH(1, 2, 3, 4).intersects(
        Rect.fromLTWH(5, 6, 7, 8),
      ),
    ).isFalse();
  });

  test('contains returns true if the given offset is inside the rectangle', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4).contains(Offset(2, 3)),
    ).isTrue();
    check(
      Rect.fromLTWH(1, 2, 3, 4).contains(Offset(4, 6)),
    ).isFalse();
  });

  test('containsRect returns true if the given rectangle is inside', () {
    check(
      Rect.fromLTWH(0, 0, 8, 2).containsRect(Rect.fromLTWH(1, 1, 6, 1)),
    ).isTrue();
    check(
      Rect.fromLTWH(1, 2, 3, 4).containsRect(Rect.fromLTWH(4, 6, 1, 1)),
    ).isFalse();
  });

  test('clamp returns a new rectangle that is inside the given rectangle', () {
    check(
      Rect.fromLTWH(1, 2, 3, 4).clamp(Rect.fromLTWH(2, 3, 4, 5)),
    ).equals(
      Rect.fromLTWH(2, 3, 2, 3),
    );
  });
}
