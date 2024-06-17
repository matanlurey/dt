import 'offset.dart';
import 'rect.dart';

/// Stores elements of a certain type [T] in a 2-dimensional grid structure.
///
/// This class is designed to implemented or used as a mixin by other
/// implementations that provide the actual storage and retrieval of elements.
/// If extended or mixed-in, default implementations are provided for most
/// methods, but the implementor may choose to override them for performance.
abstract mixin class Grid<T> {
  /// Creates a new grid with the given [width] and [height].
  ///
  /// The grid is filled with [fill] by default.
  ///
  /// The [width] and [height] must be non-negative.
  factory Grid(int width, int height, T fill) = ListGrid<T>;

  /// Creates an empty grid with no cells.
  factory Grid.empty() = ListGrid<T>.empty;

  /// Creates a new grid from the given [cells] and [width].
  ///
  /// The [cells] must have a length that is a multiple of the [width].
  factory Grid.fromCells(
    Iterable<T> cells, {
    required int width,
  }) = ListGrid<T>.fromCells;

  /// Creates a new grid from the given [rows].
  ///
  /// Each row must have the same length.
  factory Grid.fromRows(Iterable<Iterable<T>> rows) = ListGrid<T>.fromRows;

  /// Creates a new grid with the given [width] and [height].
  ///
  /// The grid is filled with the result of calling [generator] for each cell.
  ///
  /// The [width] and [height] must be non-negative.
  factory Grid.generate(
    int width,
    int height,
    T Function(int x, int y) generator,
  ) = ListGrid<T>.generate;

  /// Creates a sub-grid view into this grid within the given [bounds].
  ///
  /// The bounds must be within the grid's area.
  factory Grid.view(Grid<T> grid, Rect bounds) {
    final area = grid.area();
    if (!area.containsRect(bounds)) {
      throw ArgumentError.value(
        bounds,
        'bounds',
        "Must be within the grid's area: $area",
      );
    }
    return _SubGrid(grid, bounds);
  }

  /// Width of the buffer.
  int get width;

  /// Height of the buffer.
  int get height;

  /// Cells in the grid.
  ///
  /// The order of the cells are based on the grid's internal memory layout.
  ///
  /// See also:
  /// - [rows]; for an iterable of rows.
  /// - [columns]; for an iterable of columns.
  /// - [indexed]; for an iterable of _indexed_ cells (with x, y coordinates).
  Iterable<T> get cells;

  /// Returns the cell at the given [x] and [y] coordinates.
  ///
  /// Throws if the coordinates are out of bounds.
  T get(int x, int y);

  /// Sets the cell at the given [x] and [y] coordinates to [cell].
  ///
  /// Throws if the coordinates are out of bounds.
  void set(int x, int y, T cell);

  /// Each row of cells in the grid from top to bottom.
  ///
  /// The performance of this getter is heavily based on the grid's internal
  /// memory layout. For example, a [ListGrid] (the default implementation) uses
  /// a row-major layout, so this getter is more efficient by design.
  ///
  /// See also:
  /// - [columns]; for an iterable of columns.
  /// - [indexed]; for an iterable of _indexed_ rows (with x, y coordinates).
  Iterable<Iterable<T>> get rows {
    return Iterable.generate(
      height,
      (y) => Iterable.generate(width, (x) => get(x, y)),
    );
  }

  /// Each column of cells in the grid from left to right.
  ///
  /// The performance of this getter is heavily based on the grid's internal
  /// memory layout. For example, a [ListGrid] (the default implementation) uses
  /// a row-major layout, so this getter is less efficient than [rows].
  ///
  /// See also:
  /// - [rows]; for an iterable of rows.
  /// - [indexed]; for an iterable of _indexed_ columns (with x, y coordinates).
  Iterable<Iterable<T>> get columns {
    return Iterable.generate(
      width,
      (x) => Iterable.generate(height, (y) => get(x, y)),
    );
  }

  /// Each cell in the grid with its x and y coordinates.
  ///
  /// The order of the cells are based on the grid's internal memory layout,
  /// but each `x` and `y` coordinate is also provided for each cell, which
  /// makes this getter more useful than [cells] in many cases.
  ///
  /// See also:
  /// - [rows]; for an iterable of rows.
  /// - [columns]; for an iterable of columns.
  Iterable<(int x, int y, T cell)> get indexed {
    return Iterable.generate(
      height,
      (y) => Iterable.generate(
        width,
        (x) => (x, y, get(x, y)),
      ),
    ).expand((row) => row);
  }

  /// Returns the area of the grid as a rectangle with an optional [offset].
  ///
  /// The [offset] is relative to the top-left corner of the grid.
  Rect area([Offset offset = Offset.zero]) {
    return Rect.fromLTWH(offset.x, offset.y, width, height);
  }

  /// Returns a sub-grid view into this grid within the given [bounds].
  ///
  /// The bounds must be within the grid's area.
  Grid<T> subGrid(Rect bounds) => Grid.view(this, bounds);
}

/// A grid whose internal memory layout is a row-major 1-dimenional [List].
final class ListGrid<T> with Grid<T> {
  /// Creates a new grid with the given [width] and [height].
  ///
  /// The grid is filled with [fill] by default.
  ///
  /// The [width] and [height] must be non-negative.
  factory ListGrid(int width, int height, T fill) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');
    return ListGrid._(List.filled(width * height, fill), width);
  }

  /// Creates an empty grid with no cells.
  factory ListGrid.empty() => ListGrid._([], 0);

  /// Creates a new grid from the given [cells] and [width].
  ///
  /// The [cells] must have a length that is a multiple of the [width].
  factory ListGrid.fromCells(
    Iterable<T> cells, {
    required int width,
  }) {
    if (cells.length % width != 0) {
      throw ArgumentError.value(
        cells,
        'cells',
        'The length must be a multiple of the width.',
      );
    }
    return ListGrid._(List.of(cells), width);
  }

  /// Creates a new grid from the given [rows].
  ///
  /// Each row must have the same length.
  factory ListGrid.fromRows(Iterable<Iterable<T>> rows) {
    if (rows.isEmpty) {
      return ListGrid.empty();
    }

    final rows_ = List.of(rows);
    final width = rows.first.length;
    for (final row in rows_) {
      if (row.length != width) {
        throw ArgumentError.value(
          rows,
          'rows',
          'All rows must have the same length.',
        );
      }
    }

    final cells = rows_.expand((row) => row).toList();
    return ListGrid._(cells, width);
  }

  /// Creates a new grid with the given [width] and [height].
  ///
  /// The grid is filled with the result of calling [generator] for each cell.
  ///
  /// The [width] and [height] must be non-negative.
  factory ListGrid.generate(
    int width,
    int height,
    T Function(int x, int y) generator,
  ) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');
    return ListGrid.fromCells(
      Iterable.generate(height, (y) {
        return Iterable.generate(width, (x) => generator(x, y));
      }).expand((row) => row),
      width: width,
    );
  }

  const ListGrid._(this.cells, this.width);

  @override
  final List<T> cells;

  @override
  final int width;

  @override
  int get height => cells.length ~/ width;

  int _indexOf(int x, int y) => x + y * width;

  @override
  T get(int x, int y) {
    return cells[_indexOf(x, y)];
  }

  @override
  void set(int x, int y, T cell) {
    cells[_indexOf(x, y)] = cell;
  }
}

final class _SubGrid<T> with Grid<T> {
  const _SubGrid(this._grid, this._bounds);

  /// Delegate grid.
  final Grid<T> _grid;

  /// Bounds of the sub-grid.
  final Rect _bounds;

  @override
  int get width => _bounds.width;

  @override
  int get height => _bounds.height;

  @override
  Iterable<T> get cells {
    return _bounds.offsets.map((offset) {
      final Offset(:x, :y) = offset;
      return _grid.get(x, y);
    });
  }

  @override
  T get(int x2, int y2) {
    final Offset(x: x1, y: y1) = _bounds.topLeft;
    return _grid.get(x1 + x2, y1 + y2);
  }

  @override
  void set(int x2, int y2, T cell) {
    final Offset(x: x1, y: y1) = _bounds.topLeft;
    _grid.set(x1 + x2, y1 + y2, cell);
  }
}
