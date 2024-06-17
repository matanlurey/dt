import 'package:dt/layout.dart';

import '../prelude.dart';

void main() {
  group('FixedWidthColumns', () {
    test('does nothing on an empty area', () {
      final area = Rect.zero;
      final layout = FixedWidthColumns();

      final result = layout.split(area);
      check(result).deepEquals(const [Rect.zero]);
    });

    test('splits an area into columns', () {
      final area = const Rect.fromSize(4, 4);
      final layout = FixedWidthColumns(width: 2);

      final result = layout.split(area);
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 2, 4),
        Rect.fromLTWH(2, 0, 2, 4),
      ]);
    });

    test('splits an area into columns and ignores remaining space', () {
      final area = const Rect.fromSize(5, 5);
      final layout = FixedWidthColumns(width: 2);

      final result = layout.split(area);
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 2, 5),
        Rect.fromLTWH(2, 0, 2, 5),
      ]);
    });

    test('== and hashCode and toString', () {
      final layout1 = FixedWidthColumns(width: 2);
      final layout2 = FixedWidthColumns(width: 2);
      final layout3 = FixedWidthColumns(width: 3);

      check(layout1)
        ..has((l) => l == layout1, '== layout1').isTrue()
        ..has((l) => l == layout2, '== layout2').isTrue()
        ..has((l) => l == layout3, '== layout3').isFalse()
        ..has((l) => l.hashCode, 'hashCode').equals(layout2.hashCode)
        ..has(
          (l) => l.toString(),
          'toString',
        ).equals('FixedWidthColumns(width: 2)');
    });
  });

  group('FixedHeightRows', () {
    test('does nothing on an empty area', () {
      final area = Rect.zero;
      final layout = FixedHeightRows();

      final result = layout.split(area);
      check(result).deepEquals(const [Rect.zero]);
    });

    test('splits an area into rows', () {
      final area = const Rect.fromSize(4, 4);
      final layout = FixedHeightRows(height: 2);

      final result = layout.split(area);
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 4, 2),
        Rect.fromLTWH(0, 2, 4, 2),
      ]);
    });

    test('splits an area into rows and ignores remaining space', () {
      final area = const Rect.fromSize(5, 5);
      final layout = FixedHeightRows(height: 2);

      final result = layout.split(area);
      check(result).deepEquals(const [
        Rect.fromLTWH(0, 0, 5, 2),
        Rect.fromLTWH(0, 2, 5, 2),
      ]);
    });

    test('== and hashCode and toString', () {
      final layout1 = FixedHeightRows(height: 2);
      final layout2 = FixedHeightRows(height: 2);
      final layout3 = FixedHeightRows(height: 3);

      check(layout1)
        ..has((l) => l == layout1, '== layout1').isTrue()
        ..has((l) => l == layout2, '== layout2').isTrue()
        ..has((l) => l == layout3, '== layout3').isFalse()
        ..has((l) => l.hashCode, 'hashCode').equals(layout2.hashCode)
        ..has(
          (l) => l.toString(),
          'toString',
        ).equals('FixedHeightRows(height: 2)');
    });
  });
}
