import 'package:meta/meta.dart';

/// An interface for a command that performs an action on a terminal.
///
/// Typically the commands are converted to ANSI escape sequences before being
/// written to the terminal:
///
/// ```dart
/// final command = MoveCursorTo(1, 1);
/// terminal.write(command.toEscapeSequence());
/// ```
@immutable
sealed class Command {
  const Command();

  @override
  @mustBeOverridden
  bool operator ==(Object other);

  @override
  @mustBeOverridden
  int get hashCode;

  @override
  @mustBeOverridden
  String toString();

  /// Returns the ANSI escape sequence for this command.
  ///
  /// If [short] is `true`, the shortest possible escape sequence is returned.
  /// Otherwise, the most human-readable escape sequence is returned.
  ///
  /// For example, `MoveCursorTo(1, 1)` is `ESC[H` when [short] is `true`, and
  /// `ESC[1;1H` otherwise.
  String toEscapeSequence({bool short = true});
}

/// A command that sets the [visibility] of the cursor.
final class SetCursorVisibility implements Command {
  /// Creates a command that sets the visibility of the cursor.
  @literal
  // ignore: avoid_positional_boolean_parameters
  const SetCursorVisibility(this.visibility);

  /// Whether the cursor should be visible.
  final bool visibility;

  @override
  bool operator ==(Object other) {
    return other is SetCursorVisibility && other.visibility == visibility;
  }

  @override
  int get hashCode => Object.hash(SetCursorVisibility, visibility);

  @override
  String toString() {
    return 'SetCursorVisibility($visibility)';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return visibility ? '\x1B[?25h' : '\x1B[?25l';
  }
}

/// A command that moves the cursor up by a specified number of [rows].
final class MoveCursorUp implements Command {
  /// Creates a command that moves the cursor up by [rows].
  ///
  /// This command is 1-based, meaning `MoveCursorUp(1)` moves the cursor up by
  /// one line.
  ///
  /// It is undefined behavior to provide a negative number.
  @literal
  const MoveCursorUp([this.rows = 1]);

  /// The number of lines to move the cursor up.
  final int rows;

  @override
  bool operator ==(Object other) {
    return other is MoveCursorUp && other.rows == rows;
  }

  @override
  int get hashCode => Object.hash(MoveCursorUp, rows);

  @override
  String toString() {
    return 'MoveCursorUp($rows)';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return short && rows == 1 ? '\x1B[A' : '\x1B[${rows}A';
  }
}

/// A command that moves the cursor down by a specified number of [rows].
final class MoveCursorDown implements Command {
  /// Creates a new command that moves the cursor down by [rows].
  ///
  /// This command is 1-based, meaning `MoveCursorDown(1)` moves the cursor down
  /// by one line.
  ///
  /// It is undefined behavior to provide a negative number.
  @literal
  const MoveCursorDown([this.rows = 1]);

  /// The number of rows to move the cursor down.
  final int rows;

  @override
  bool operator ==(Object other) {
    return other is MoveCursorDown && other.rows == rows;
  }

  @override
  int get hashCode => Object.hash(MoveCursorDown, rows);

  @override
  String toString() {
    return 'MoveCursorDown($rows)';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return short && rows == 1 ? '\x1B[B' : '\x1B[${rows}B';
  }
}

/// A command that moves the cursor right by a specified number of [columns].
final class MoveCursorRight implements Command {
  /// Creates a command that moves the cursor right by [columns].
  ///
  /// This command is 1-based, meaning `MoveCursorRight(1)` moves the cursor
  /// right by one column.
  ///
  /// It is undefined behavior to provide a negative number of columns.
  @literal
  const MoveCursorRight([this.columns = 1]);

  /// The number of columns to move the cursor right.
  final int columns;

  @override
  bool operator ==(Object other) {
    return other is MoveCursorRight && other.columns == columns;
  }

  @override
  int get hashCode => Object.hash(MoveCursorRight, columns);

  @override
  String toString() {
    return 'MoveCursorRight($columns)';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return short && columns == 1 ? '\x1B[C' : '\x1B[${columns}C';
  }
}

/// A command that moves the cursor left by a specified number of [columns].
final class MoveCursorLeft implements Command {
  /// Creates a command that moves the cursor left by [columns].
  ///
  /// This command is 1-based, meaning `MoveCursorLeft(1)` moves the cursor left
  /// by one column.
  ///
  /// It is undefined behavior to provide a negative number of columns.
  @literal
  const MoveCursorLeft([this.columns = 1]);

  /// The number of columns to move the cursor left.
  final int columns;

  @override
  bool operator ==(Object other) {
    return other is MoveCursorLeft && other.columns == columns;
  }

  @override
  int get hashCode => Object.hash(MoveCursorLeft, columns);

  @override
  String toString() {
    return 'MoveCursorLeft($columns)';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return short && columns == 1 ? '\x1B[D' : '\x1B[${columns}D';
  }
}

/// A command that moves the cursor to the specified [row] and [column].
final class MoveCursorTo implements Command {
  /// Creates a command that moves the cursor to a specified [row] and [column].
  ///
  /// This command is 1-based, meaning `MoveCursorTo(1, 1)` moves the cursor to
  /// the first row and column.
  ///
  /// It is undefined behavior to provide a negative row or column.
  @literal
  const MoveCursorTo([this.row = 1, this.column = 1]);

  /// The 1-based column to move the cursor to.
  final int column;

  /// The 1-based row to move the cursor to.
  final int row;

  @override
  bool operator ==(Object other) {
    return other is MoveCursorTo && other.column == column && other.row == row;
  }

  @override
  int get hashCode => Object.hash(MoveCursorTo, column, row);

  @override
  String toString() {
    return 'MoveCursorTo($column, $row)';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    if (short && column == 1) {
      return row == 1 ? '\x1B[H' : '\x1B[${row}H';
    }
    return '\x1B[$row;${column}H';
  }
}

/// A command that moves the cursor to the specified [column].
final class MoveCursorToColumn implements Command {
  /// Creates a command that moves the cursor to a specified [column].
  ///
  /// This command is 1-based, meaning `MoveCursorToColumn(1)` moves the cursor
  /// to the first column.
  ///
  /// It is undefined behavior to provide a negative column.
  const MoveCursorToColumn([this.column = 1]);

  /// The 1-based column to move the cursor to.
  final int column;

  @override
  bool operator ==(Object other) {
    return other is MoveCursorToColumn && other.column == column;
  }

  @override
  int get hashCode => Object.hash(MoveCursorToColumn, column);

  @override
  String toString() {
    return 'MoveCursorToColumn($column)';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return short && column == 1 ? '\x1B[G' : '\x1B[${column}G';
  }
}

/// A command that moves the cursor down [lines] and to the first column.
final class MoveCursorNextLine implements Command {
  /// Creates a command that moves the cursor down [lines] and to the first
  /// column.
  ///
  /// This command is 1-based, meaning `MoveCursorNextLine(1)` moves the cursor
  /// down by one line.
  ///
  /// It is undefined behavior to provide a negative number of lines.
  @literal
  const MoveCursorNextLine([this.lines = 1]);

  /// The number of lines to move the cursor down.
  final int lines;

  @override
  bool operator ==(Object other) {
    return other is MoveCursorNextLine && other.lines == lines;
  }

  @override
  int get hashCode => Object.hash(MoveCursorNextLine, lines);

  @override
  String toString() {
    return 'MoveCursorNextLine($lines)';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return short && lines == 1 ? '\x1B[E' : '\x1B[${lines}E';
  }
}

/// A command that moves the cursor up [lines] and to the first column.
final class MoveCursorPreviousLine implements Command {
  /// Creates a command that moves the cursor up [lines] and to the first column.
  ///
  /// This command is 1-based, meaning `MoveCursorPreviousLine(1)` moves the
  /// cursor up by one line.
  ///
  /// It is undefined behavior to provide a negative number of lines.
  @literal
  const MoveCursorPreviousLine([this.lines = 1]);

  /// The number of lines to move the cursor up.
  final int lines;

  @override
  bool operator ==(Object other) {
    return other is MoveCursorPreviousLine && other.lines == lines;
  }

  @override
  int get hashCode => Object.hash(MoveCursorPreviousLine, lines);

  @override
  String toString() {
    return 'MoveCursorPreviousLine($lines)';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return short && lines == 1 ? '\x1B[F' : '\x1B[${lines}F';
  }
}

/// A command that restores the saved (global) terminal cursor position.
///
/// This command is typically used in conjunction with [SaveCursor].
final class RestoreCursor implements Command {
  /// Creates a command that restores the saved terminal cursor position.
  @literal
  const RestoreCursor();

  @override
  bool operator ==(Object other) {
    return other is RestoreCursor;
  }

  @override
  int get hashCode => (RestoreCursor).hashCode;

  @override
  String toString() {
    return 'RestoreCursor';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return '\x1B[u';
  }
}

/// A command that saves the current (global) terminal cursor position.
///
/// This command is typically used in conjunction with [RestoreCursor].
final class SaveCursor implements Command {
  /// Creates a command that saves the current terminal cursor position.
  @literal
  const SaveCursor();

  @override
  bool operator ==(Object other) {
    return other is SaveCursor;
  }

  @override
  int get hashCode => (SaveCursor).hashCode;

  @override
  String toString() {
    return 'SaveCursor';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return '\x1B[s';
  }
}

/// A command that clears the terminal screen or line.
// ignore: missing_override_of_must_be_overridden
enum Clear implements Command {
  /// Clears the entire terminal screen.
  all,

  /// Clears the entire terminal screen and scrollback buffer.
  purge,

  /// Clears from the cursor position downwards.
  fromCursorDown,

  /// Clears from the cursor position upwards.
  fromCursorUp,

  /// Clears the current line.
  currentLine,

  /// Clears the line from the cursor position to the end of the line.
  untilNewLine;

  @override
  String toEscapeSequence({bool short = true}) {
    switch (this) {
      case Clear.all:
        return '\x1B[2J';
      case Clear.purge:
        return '\x1B[3J';
      case Clear.fromCursorDown:
        return '\x1B[J';
      case Clear.fromCursorUp:
        return '\x1B[1J';
      case Clear.currentLine:
        return '\x1B[2K';
      case Clear.untilNewLine:
        return '\x1B[K';
    }
  }
}

/// A command that enters the alternate screen buffer.
final class EnterAlternateScreen implements Command {
  /// Creates a command that enters the alternate screen buffer.
  @literal
  const EnterAlternateScreen();

  @override
  bool operator ==(Object other) {
    return other is EnterAlternateScreen;
  }

  @override
  int get hashCode => (EnterAlternateScreen).hashCode;

  @override
  String toString() {
    return 'EnterAlternateScreen';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return '\x1B[?1049h';
  }
}

/// A command that leaves the alternate screen buffer.
final class LeaveAlternateScreen implements Command {
  /// Creates a command that exits the alternate screen buffer.
  @literal
  const LeaveAlternateScreen();

  @override
  bool operator ==(Object other) {
    return other is LeaveAlternateScreen;
  }

  @override
  int get hashCode => (LeaveAlternateScreen).hashCode;

  @override
  String toString() {
    return 'LeaveAlternateScreen';
  }

  @override
  String toEscapeSequence({bool short = true}) {
    return '\x1B[?1049l';
  }
}
