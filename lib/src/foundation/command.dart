import 'package:meta/meta.dart';

import 'sequence.dart';

/// An interface for a command that performs an action on a terminal.
///
/// A set of built-in commands are provided and it is rare to need to create a
/// custom command; however, it is possible to create a custom command by
/// implementing this interface.
@immutable
abstract mixin class Command {
  // ignore: public_member_api_docs
  const Command();

  @override
  bool operator ==(Object other) {
    if (other is! Command || other.runtimeType != runtimeType) {
      return false;
    }
    return toSequence() == other.toSequence();
  }

  @override
  int get hashCode => toSequence().hashCode;

  /// Returns the ANSI escape sequence for this command.
  Sequence toSequence();
}

/// Moves the terminal cursor to the given position (row, column).
///
/// The top-left cell is represented as `(0, 0)`.
final class MoveCursorTo extends Command {
  /// Creates a move cursor to command.
  ///
  /// The [row] and [column] must be non-negative.
  const MoveCursorTo([
    int row = 0,
    int column = 0,
  ])  : row = row < 0 ? 0 : row,
        column = column < 0 ? 0 : column;

  /// The row to move the cursor to.
  final int row;

  /// The column to move the cursor to.
  final int column;

  @override
  Sequence toSequence() {
    return EscapeSequence('H', [row, column]);
  }

  @override
  String toString() {
    return 'MoveCursorTo($row:$column)';
  }
}

/// Moves the terminal cursor to the given column.
///
/// The left-most column is represented as `0`.
final class MoveCursorToColumn extends Command {
  /// Creates a move cursor to column command.
  ///
  /// The [column] must be non-negative.
  const MoveCursorToColumn([
    int column = 0,
  ]) : column = column < 0 ? 0 : column;

  /// The column to move the cursor to.
  final int column;

  @override
  Sequence toSequence() {
    return EscapeSequence('G', [column]);
  }

  @override
  String toString() {
    return 'MoveCursorToColumn($column)';
  }
}

/// Sets the cursor visibility.
enum SetCursorVisibility implements Command {
  /// Sets the cursor visibility to visible.
  visible(
    EscapeSequence.unchecked('?25h'),
  ),

  /// Sets the cursor visibility to hidden.
  hidden(
    EscapeSequence.unchecked('?25l'),
  );

  const SetCursorVisibility(this._sequence);
  final EscapeSequence _sequence;

  @override
  Sequence toSequence() => _sequence;
}

/// Clears the terminal screen buffer.
///
/// Note that the cursor is _not_ moved as a result of this command.
enum ClearScreen implements Command {
  /// Clears the entire screen.
  all(
    EscapeSequence.unchecked('J', [0], [0]),
  ),

  /// Clears the entire screen and the scrollback buffer.
  allAndScrollback(
    EscapeSequence.unchecked('J', [3], [0]),
  ),

  /// Clears the screen from the cursor down.
  fromCursorDown(
    EscapeSequence.unchecked('J', [1], [0]),
  ),

  /// Clears the screen from the cursor up.
  fromCursorUp(
    EscapeSequence.unchecked('J', [2], [0]),
  ),

  /// Clears the current line.
  currentLine(
    EscapeSequence.unchecked('K', [0], [0]),
  ),

  /// Clears the line from the cursor to the end of the line.
  toEndOfLine(
    EscapeSequence.unchecked('K', [0], [0]),
  );

  const ClearScreen(this._sequence);
  final EscapeSequence _sequence;

  @override
  Sequence toSequence() => _sequence;
}

/// Enters or leaves the alternate screen buffer.
enum AlternateScreenBuffer implements Command {
  /// Enters the alternate screen buffer.
  enter(
    EscapeSequence.unchecked('?1049h'),
  ),

  /// Leaves the alternate screen buffer.
  leave(
    EscapeSequence.unchecked('?1049l'),
  );

  const AlternateScreenBuffer(this._sequence);
  final EscapeSequence _sequence;

  @override
  Sequence toSequence() => _sequence;
}
