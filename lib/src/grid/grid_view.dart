import 'dart:math' as math;

/// A view of a grid of _cells_ of type [T].
///
/// This type is used to provide a read-only view of a 2-dimensional grid of
/// elements, which could be used to represent a pixel canvas or output of a
/// grid-based terminal.
///
/// It is recommended to _extend_ or _mixin_ this class if able.
abstract mixin class GridView<T> {
  // coverage:ignore-start
  // ignore: public_member_api_docs
  const GridView();
  // coverage:ignore-end

  /// The cells in the buffer in row-major order.
  Iterable<T> get cells {
    return Iterable.generate(length, (i) => this[i]);
  }

  /// The number of cells in the buffer.
  ///
  /// Must be a non-negative integer.
  ///
  /// Implementations are expected to provide a constant-time implementation.
  int get length;

  /// The number of rows in the grid.
  ///
  /// Must be a non-negative integer.
  ///
  /// Implementations are expected to provide a constant-time implementation.
  int get height => length ~/ width;

  /// The number of columns in the grid.
  ///
  /// Must be a non-negative integer.
  ///
  /// Implementations are expected to provide a constant-time implementation.
  int get width;

  /// Returns the element at the given [row] and [column].
  ///
  /// Reading beyond the bounds of the grid throws an error.
  T getCell(int row, int column) {
    RangeError.checkValueInInterval(row, 0, height - 1, 'row');
    RangeError.checkValueInInterval(column, 0, width - 1, 'column');
    final index = row * width + column;
    return this[index];
  }

  /// Returns the element at the given [position] in row-major order.
  ///
  /// Reading beyond the bounds of the grid throws an error.
  T operator [](int position);

  /// Rows in the grid in row-major order.
  ///
  /// Each yielded row is an iterable of elements (cells) in the row.
  Iterable<Iterable<T>> get rows {
    return Iterable.generate(
      height,
      (row) => Iterable.generate(width, (column) => getCell(row, column)),
    );
  }

  /// Returns a string representation of the grid suitable for debugging.
  ///
  /// ```txt
  /// 1 2 3
  /// 4 5 6
  /// 7 8 9
  /// ```
  ///
  /// If [drawGrid] is `true`, the bounds of the grid are drawn:
  ///
  /// ```txt
  /// ┌───┬───┬───┐
  /// │ 1 │ 2 │ 3 │
  /// ├───┼───┼───┤
  /// │ 4 │ 5 │ 6 │
  /// ├───┼───┼───┤
  /// │ 7 │ 8 │ 9 │
  /// └───┴───┴───┘
  /// ```
  ///
  /// If `T.toString` is not suitable, provide a [format] function to convert.
  static String visualize<T>(
    GridView<T> grid, {
    bool drawGrid = false,
    int padding = 1,
    String Function(T span)? format,
  }) {
    // Default to the identity function.
    format ??= (span) => span.toString();

    // Render the grid.
    final buffer = StringBuffer();

    // Convert the grid to a string.
    final cells = grid.cells.map(format).toList();
    late final int maxCellWidth;
    if (drawGrid) {
      maxCellWidth = cells.fold<int>(
        0,
        (max, cell) => math.max(max, cell.length),
      );
    }

    // Header.
    if (drawGrid) {
      buffer.write('┌');
      for (var i = 0; i < grid.width; i++) {
        if (i > 0) {
          buffer.write('┬');
        }
        buffer.write('─' * padding);
        buffer.write('─' * maxCellWidth);
        buffer.write('─' * padding);
      }
      buffer.write('┐');
      buffer.writeln();
    }

    // Rows.
    for (var row = 0; row < grid.height; row++) {
      if (drawGrid) {
        if (row > 0) {
          buffer.write('├');
          for (var i = 0; i < grid.width; i++) {
            if (i > 0) {
              buffer.write('┼');
            }
            buffer.write('─' * padding);
            buffer.write('─' * maxCellWidth);
            buffer.write('─' * padding);
          }
          buffer.write('┤');
          buffer.writeln();
        }
      }

      buffer.write('│');
      for (var column = 0; column < grid.width; column++) {
        if (column > 0) {
          buffer.write('│');
        }
        final cell = cells[row * grid.width + column];
        buffer.write(' ' * padding);
        buffer.write(cell);
        buffer.write(' ' * (maxCellWidth - cell.length));
        buffer.write(' ' * padding);
      }
      buffer.write('│');
      buffer.writeln();
    }

    // Footer.
    if (drawGrid) {
      buffer.write('└');
      for (var i = 0; i < grid.width; i++) {
        if (i > 0) {
          buffer.write('┴');
        }
        buffer.write('─' * padding);
        buffer.write('─' * maxCellWidth);
        buffer.write('─' * padding);
      }
      buffer.write('┘');
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Returns a string representation of the grid suitable for debugging.
  ///
  /// This method is equivalent to calling [visualize].
  String toDebugString({
    bool drawGrid = false,
    int padding = 1,
    String Function(T span)? format,
  }) {
    return visualize(
      this,
      drawGrid: drawGrid,
      padding: padding,
      format: format,
    );
  }
}
