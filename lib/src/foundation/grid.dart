/// Stores elements of a type [T] in a continuous growable 2D data structure.
abstract interface class Grid<T> {
  /// The number of rows in the grid.
  int get width;

  /// The number of columns in the grid.
  int get height;

  /// The total number of elements in the grid.
  int get length;

  /// Clears all elements in the grid.
  void clear();

  /// Returns the element at the given [row] and [column].
  ///
  /// An error is thrown if [row] or [column] are out of bounds.
  T get(int row, int column);

  /// Sets the element at the given [row] and [column] to [value].
  ///
  /// An error is thrown if [row] or [column] are out of bounds.
  void set(int row, int column, T value);

  /// Traverse the grid with row and column indexes.
  ///
  /// The iteration order is dependent on the internal memory layout, but the
  /// indexes will be accurate either way.
  Iterator<(int row, int column, T value)> get cells;
}
