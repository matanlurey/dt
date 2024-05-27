/// Operations on a terminal-like object not related to writing or styling text.
///
/// This type provides additional operations on a terminal-like object such as
/// manipulating the [cursor] position, clearing all or part of the current line
/// or screen, and more.
///
/// The [cursor] is always clamped to the bounds of the terminal. If the cursor
/// would be placed outside the terminal, the implementation may either ignore
/// the move, clamp the cursor to the nearest valid position, or insert empty
/// lines and spans to accommodate the cursor.
abstract interface class TerminalDriver {
  /// A cursor that can be moved and manipulated in the terminal.
  Cursor get cursor;

  /// Clears the terminal from the cursor position to the end of the screen.
  void clearScreenAfter();

  /// Clears the terminal from the cursor position to the start of the screen.
  void clearScreenBefore();

  /// Clears the entire terminal.
  void clearScreen();

  /// Clears the current line from the cursor position to the end of the line.
  void clearLineAfter();

  /// Clears the current line from the cursor position to the start of the line.
  void clearLineBefore();

  /// Clears the entire current line.
  void clearLine();
}

/// A position in a terminal represented by a [column] and [line].
///
/// Interactive cursors are _mutable_, and [column] and [line] may be changed
/// by calling their respective setters, or by calling methods such as [moveTo].
///
/// Operations on a cursor that would move it outside the bounds of the terminal
/// are implementation-defined, and may result in being ignored or clamped to
/// the nearest valid position.
abstract mixin class Cursor {
  /// Moves the cursor _to_ the given [column] and optionally [line].
  ///
  /// If being moved outside the bounds of the terminal, the implementation
  /// may either ignore the move, clamp the cursor to the nearest valid
  /// position or insert empty lines and spans to accommodate the cursor.
  void moveTo({
    required int column,
    int? line,
  });

  /// Moves the cursor _by_ the given [columns] and/or [lines].
  ///
  /// If being moved outside the bounds of the terminal, the implementation
  /// may either ignore the move, clamp the cursor to the nearest valid
  /// position or insert empty lines and spans to accommodate the cursor.
  void moveBy({
    int? columns,
    int? lines,
  });
}

/// Extension methods for [Cursor].
extension CursorExtension on Cursor {
  /// Moves the cursor up by [lines] lines.
  ///
  /// If [lines] is not provided, the cursor is moved up by one line.
  ///
  /// Must be a non-negative integer.
  void moveUp([int lines = 1]) {
    moveBy(lines: -RangeError.checkNotNegative(lines));
  }

  /// Moves the cursor down by [lines] lines.
  ///
  /// If [lines] is not provided, the cursor is moved down by one line.
  ///
  /// Must be a non-negative integer.
  void moveDown([int lines = 1]) {
    moveBy(lines: RangeError.checkNotNegative(lines));
  }

  /// Moves the cursor left by [columns] columns.
  ///
  /// If [columns] is not provided, the cursor is moved left by one column.
  ///
  /// Must be a non-negative integer.
  void moveLeft([int columns = 1]) {
    moveBy(columns: -RangeError.checkNotNegative(columns));
  }

  /// Moves the cursor right by [columns] columns.
  ///
  /// If [columns] is not provided, the cursor is moved right by one column.
  ///
  /// Must be a non-negative integer.
  void moveRight([int columns = 1]) {
    moveBy(columns: RangeError.checkNotNegative(columns));
  }
}
