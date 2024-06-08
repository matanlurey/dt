import 'package:dt/foundation.dart';

import '../prelude.dart';

void main() {
  test('Grid.empty should return an empty grid', () {
    final grid = Grid<int>.empty();
    check(grid)
      ..has((g) => g.isEmpty, 'isEmpty').isTrue()
      ..has((g) => g.isNotEmpty, 'isNotEmpty').isFalse()
      ..has((g) => g.width, 'width').equals(0)
      ..has((g) => g.height, 'height').equals(0)
      ..has((g) => g.cells, 'cells').isEmpty();
  });

  group('Grid.filled should return an empty grid if', () {
    test('width is 0', () {
      final grid = Grid.filled(0, 10, '');
      check(grid).has((g) => g.isEmpty, 'isEmpty').isTrue();
    });

    test('height is 0', () {
      final grid = Grid.filled(10, 0, '');
      check(grid).has((g) => g.isEmpty, 'isEmpty').isTrue();
    });
  });

  group('Grid.filled should throw if', () {
    test('width is negative', () {
      check(() => Grid.filled(-1, 10, '')).throws<ArgumentError>();
    });

    test('height is negative', () {
      check(() => Grid.filled(10, -1, '')).throws<ArgumentError>();
    });
  });

  test('Grid.filled should return a row-major grid', () {
    final grid = Grid.filled(2, 3, 0);
    check(grid).has((g) => g.cells, 'cells').deepEquals([0, 0, 0, 0, 0, 0]);
  });

  group('Grid.generate', () {
    group('should return an empty grid if', () {
      test('width is 0', () {
        final grid = Grid<(int, int)>.generate(0, 10, (x, y) => (x, y));
        check(grid).has((g) => g.isEmpty, 'isEmpty').isTrue();
      });

      test('height is 0', () {
        final grid = Grid<(int, int)>.generate(10, 0, (x, y) => (x, y));
        check(grid).has((g) => g.isEmpty, 'isEmpty').isTrue();
      });
    });

    group('should throw if', () {
      test('width is negative', () {
        check(
          () => Grid.generate(-1, 10, (x, y) => (x, y)),
        ).throws<ArgumentError>();
      });

      test('height is negative', () {
        check(
          () => Grid.generate(10, -1, (x, y) => (x, y)),
        ).throws<ArgumentError>();
      });
    });

    test('should return a row-major grid', () {
      final grid = Grid.generate(
        2,
        3,
        (x, y) => (x, y),
      );
      check(grid).has((g) => g.cells, 'cells').deepEquals([
        (0, 0),
        (1, 0),
        (0, 1),
        (1, 1),
        (0, 2),
        (1, 2),
      ]);
    });
  });

  group('Grid.fromCells', () {
    test('should return an empty grid if cells is empty', () {
      final grid = Grid.fromCells([], width: 0);
      check(grid)
        ..has((g) => g.isEmpty, 'isEmpty').isTrue()
        ..has((g) => g.isNotEmpty, 'isNotEmpty').isFalse()
        ..has((g) => g.width, 'width').equals(0)
        ..has((g) => g.height, 'height').equals(0)
        ..has((g) => g.cells, 'cells').isEmpty();
    });

    test('throw if width is negative', () {
      check(() => Grid.fromCells([0], width: -1)).throws<ArgumentError>();
    });

    test('throw if width is not a divisor of the number of elements', () {
      check(() => Grid.fromCells([0, 1, 2], width: 2)).throws<ArgumentError>();
    });

    test('throw if width is 0 and cells is not empty', () {
      check(() => Grid.fromCells([0], width: 0)).throws<ArgumentError>();
    });

    test('should return a row-major grid', () {
      final grid = Grid.fromCells(
        [0, 1, 2, 3, 4, 5],
        width: 2,
      );
      check(grid).has((g) => g.cells, 'cells').deepEquals(
        [0, 1, 2, 3, 4, 5],
      );
    });
  });

  group('Grid.fromMatrix', () {
    test('should return an empty grid if matrix is empty', () {
      final grid = Grid.fromMatrix([]);
      check(grid)
        ..has((g) => g.isEmpty, 'isEmpty').isTrue()
        ..has((g) => g.isNotEmpty, 'isNotEmpty').isFalse()
        ..has((g) => g.width, 'width').equals(0)
        ..has((g) => g.height, 'height').equals(0)
        ..has((g) => g.cells, 'cells').isEmpty();
    });

    test('should throw if matrix is not rectangular', () {
      check(
        () => Grid.fromMatrix([
          [0, 1],
          [0],
        ]),
      ).throws<ArgumentError>();
    });

    test('should return a row-major grid', () {
      final grid = Grid.fromMatrix([
        [0, 1],
        [2, 3],
        [4, 5],
      ]);
      check(grid).has((g) => g.cells, 'cells').deepEquals([0, 1, 2, 3, 4, 5]);
    });
  });

  test('Grid.length should return the number of cells', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(grid).has((g) => g.length, 'length').equals(6);
  });

  test('Grid.isEmpty should return true if there are no cells', () {
    final grid = Grid.fromCells([], width: 0);
    check(grid).has((g) => g.isEmpty, 'isEmpty').isTrue();
  });

  test('Grid.isNotEmpty should return true if there are cells', () {
    final grid = Grid.fromCells([0], width: 1);
    check(grid).has((g) => g.isNotEmpty, 'isNotEmpty').isTrue();
  });

  test('Grid.width should return the width of the grid', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(grid).has((g) => g.width, 'width').equals(2);
  });

  test('Grid.height should return the height of the grid', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(grid).has((g) => g.height, 'height').equals(3);
  });

  test('Grid.cells should return the cells of the grid', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(grid).has((g) => g.cells, 'cells').deepEquals([0, 1, 2, 3, 4, 5]);
  });

  test('Grid[i] should return the cell at index i', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(grid).has((g) => g[0], '[0]').equals(0);
    check(grid).has((g) => g[1], '[1]').equals(1);
    check(grid).has((g) => g[2], '[2]').equals(2);
    check(grid).has((g) => g[3], '[3]').equals(3);
    check(grid).has((g) => g[4], '[4]').equals(4);
    check(grid).has((g) => g[5], '[5]').equals(5);
  });

  test('Grid[i] = value should set the cell at index i to value', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    grid[0] = 10;
    grid[1] = 11;
    grid[2] = 12;
    grid[3] = 13;
    grid[4] = 14;
    grid[5] = 15;
    check(grid).has((g) => g.cells, 'cells').deepEquals(
      [10, 11, 12, 13, 14, 15],
    );
  });

  test('Grid.get should return the cell at position (x, y)', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(grid).has((g) => g.get(0, 0), 'get(0, 0)').equals(0);
    check(grid).has((g) => g.get(1, 0), 'get(1, 0)').equals(1);
    check(grid).has((g) => g.get(0, 1), 'get(0, 1)').equals(2);
    check(grid).has((g) => g.get(1, 1), 'get(1, 1)').equals(3);
    check(grid).has((g) => g.get(0, 2), 'get(0, 2)').equals(4);
    check(grid).has((g) => g.get(1, 2), 'get(1, 2)').equals(5);
  });

  test('Grid.get should throw if x is out of bounds', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(() => grid.get(2, 0)).throws<RangeError>();
  });

  test('Grid.get should throw if y is out of bounds', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(() => grid.get(0, 3)).throws<RangeError>();
  });

  test('Grid.set should set the cell at position (x, y) to value', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    grid.set(0, 0, 10);
    grid.set(1, 0, 11);
    grid.set(0, 1, 12);
    grid.set(1, 1, 13);
    grid.set(0, 2, 14);
    grid.set(1, 2, 15);
    check(grid).has((g) => g.cells, 'cells').deepEquals(
      [10, 11, 12, 13, 14, 15],
    );
  });

  test('Grid.set should throw if x is out of bounds', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(() => grid.set(2, 0, 10)).throws<RangeError>();
  });

  test('Grid.set should throw if y is out of bounds', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(() => grid.set(0, 3, 10)).throws<RangeError>();
  });

  test('Grid.rows (row-major) should return the rows of the grid', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(grid).has((g) => g.rows, 'rows').deepEquals([
      [0, 1],
      [2, 3],
      [4, 5],
    ]);
  });

  test('Grid.columns (row-major) should return the columns of the grid', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);
    check(grid).has((g) => g.columns, 'columns').deepEquals([
      [0, 2, 4],
      [1, 3, 5],
    ]);
  });

  test('Grid.toString should return a string representation of the grid', () {
    final grid = Grid.fromCells([0, 1, 2, 3, 4, 5], width: 2);

    final expected = [
      '0 1',
      '2 3',
      '4 5',
    ].join('\n');
    check(grid).has((g) => g.toString(), 'toString').equals(expected);
  });
}
