import 'package:dt/src/core.dart';

import 'cursor.dart';

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
abstract interface class TerminalController<T> {
  /// An interactive cursor that can be moved and manipulated in the terminal.
  InteractiveCursor get cursor;

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
abstract mixin class InteractiveCursor implements Cursor {
  /// Moves the cursor _to_ the given [column] and [line].
  ///
  /// If being moved outside the bounds of the terminal, the implementation
  /// may either ignore the move, clamp the cursor to the nearest valid
  /// position or insert empty lines and spans to accommodate the cursor.
  ///
  /// The default implementation is equivalent to:
  /// ```dart
  /// cursor
  ///   ..column = column
  ///   ..line = line;
  /// ```
  void moveTo({
    required int column,
    required int line,
  }) {
    this
      ..column = column
      ..line = line;
  }

  @override
  Offset get offset => Offset(column, line);

  /// Moves the cursor to the given [offset].
  ///
  /// See [moveTo] for more information on cursor movement.
  set offset(Offset offset) {
    moveTo(column: offset.x, line: offset.y);
  }

  @override
  int get column;

  /// Sets the cursor to the given [column].
  ///
  /// If the column would be moved outside the bounds of the terminal, the
  /// implementation may either ignore the move, clamp the cursor to the nearest
  /// valid position, or insert empty spans to accommodate the cursor.
  set column(int column);

  @override
  int get line;

  /// Sets the cursor to the given [line].
  ///
  /// If the line would be moved outside the bounds of the terminal, the
  /// implementation may either ignore the move, clamp the cursor to the nearest
  /// valid position, or insert empty lines and spans to accommodate the cursor.
  set line(int line);

  @override
  String toString() => 'Cursor <$line:$column>';
}
