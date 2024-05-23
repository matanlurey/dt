// ignore_for_file: avoid_setters_without_getters

/// An editor for a grid of _cells_ of type [T].
///
/// This type is used to provide a write-only view of a 2-dimensional grid of
/// elements, which could be used to represent a pixel canvas or output of a
/// grid-based terminal.
///
/// It is recommended to _extend_ or _mixin_ this class if able.
abstract mixin class GridEditor<T> {
  // coverage:ignore-start
  // ignore: public_member_api_docs
  const GridEditor();
  // coverage:ignore-end

  /// Sets the element at the given [row] and [column].
  ///
  /// Writing beyond the bounds of the grid throws an error.
  void setCell(int row, int column, T value);

  /// Sets the element at the given [position] in row-major order.
  ///
  /// Writing beyond the bounds of the grid throws an error.
  /// Returns the previous value at the given [position].
  void operator []=(int position, T value);
}
