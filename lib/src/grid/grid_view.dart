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
  Iterable<T> get cells;

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
}
