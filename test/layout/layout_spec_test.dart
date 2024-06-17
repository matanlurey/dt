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
  });
}
