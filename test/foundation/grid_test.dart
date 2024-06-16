import 'package:dt/foundation.dart';

import '../prelude.dart';

void main() {
  test('columns', () {
    final grid = Grid.generate(3, 3, (x, y) => (x, y));

    check(grid.columns).deepEquals([
      [(0, 0), (0, 1), (0, 2)],
      [(1, 0), (1, 1), (1, 2)],
      [(2, 0), (2, 1), (2, 2)],
    ]);
  });

  test('indexed', () {
    final grid = Grid.generate(3, 3, (x, y) => (x, y));

    check(grid.indexed).unorderedEquals([
      (0, 0, (0, 0)),
      (0, 1, (0, 1)),
      (0, 2, (0, 2)),
      (1, 0, (1, 0)),
      (1, 1, (1, 1)),
      (1, 2, (1, 2)),
      (2, 0, (2, 0)),
      (2, 1, (2, 1)),
      (2, 2, (2, 2)),
    ]);
  });

  test('fromCells throws if the cells do not fit the grid', () {
    check(
      () => Grid.fromCells(
        [
          [1, 2, 3],
          [4, 5, 6],
        ],
        width: 4,
      ),
    ).throws<ArgumentError>();
  });

  test('fromRows returns an empty grid if empty', () {
    final grid = Grid.fromRows([]);

    check(grid).has((g) => g.cells, 'cells').isEmpty();
  });

  test('fromRows throws if the rows do not fit the grid', () {
    check(
      () => Grid.fromRows([
        [1, 2, 3],
        [4, 5, 6, 7],
      ]),
    ).throws<ArgumentError>();
  });
}
