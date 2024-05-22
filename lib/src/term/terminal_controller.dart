import 'package:dt/src/core.dart';
import 'package:meta/meta.dart';

import 'cursor.dart';
import 'terminal_span.dart';

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

/// A mixin that provides a default implementation of [TerminalController].
///
/// Implementations that provide a mutable [lines] and [span] implementation
/// can use this mixin to provide a default implementation of a controller
/// after calling [initializeCursor] with the initial cursor position.
///
/// The default implementation of the methods provided by this mixin emulate
/// the behavior of a canonical terminal, that is, if content _before_ the
/// cursor is cleared, empty content is inserted to replace it and the cursor is
/// not moved.
///
/// It is recommended to only extend or mixin this class if the resulting type
/// is implementation private, and to instead document the behavior of the
/// terminal controller in the public API:
/// ```dart
/// abstract final class MyTerminal {
///   factory MyTerminal() = _MyTerminal();
///   // ...
/// }
///
/// final class _MyTerminal with ListTerminalMixin implements MyTerminal {
///   MyTerminal() {
///     initializeCursor(Offset.zero);
///   }
///   // ...
/// }
/// ```
mixin ListTerminalMixin<T> implements TerminalController<T> {
  /// Initializes the cursor at the given [start] position.
  @protected
  void initializeCursor(Offset start) {
    cursor = _InteractiveCursor(this, start.x, start.y);
  }

  @override
  late final InteractiveCursor cursor;

  /// Details about how the contents of the terminal are stored and manipulated.
  @protected
  TerminalSpan<T> get span;

  /// The lines of the terminal.
  ///
  /// The lines are stored in an idiomatic order, that is, the first line is
  /// at index `0`, the second line is at index `1`, and so on. The last line
  /// is at index `length - 1`.
  ///
  /// The list must be mutable.
  @protected
  List<T> get lines;

  @override
  void clearScreenAfter() {
    lines.removeRange(cursor.line + 1, lines.length);
    clearLineAfter();
  }

  /// Replaces all content before the cursor with empty content.
  ///
  /// The current line is replaced with empty content from the start of the line
  /// to the cursor position, and previous lines are replaced with empty lines
  /// of no content.
  @override
  void clearScreenBefore() {
    lines.replaceRange(0, cursor.line, List.filled(cursor.line, span.empty()));
    clearLineBefore();
  }

  @override
  void clearScreen() {
    clearScreenAfter();
    clearScreenBefore();
  }

  @override
  void clearLineAfter() {
    final Cursor(:line, :column) = cursor;
    lines[line] = span.extract(lines[line], end: column);
  }

  /// Replaces the current line before the cursor with empty content.
  @override
  void clearLineBefore() {
    final Cursor(:line, :column) = cursor;
    lines[line] = span.replace(
      lines[line],
      span.empty(column),
      0,
      column,
    );
  }

  /// Replaces the current line with empty content up to the cursor position.
  @override
  void clearLine() {
    final Cursor(:line, :column) = cursor;
    lines[line] = span.empty(column);
  }
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
  /// may either ignore the move or clamp the cursor to the nearest valid
  /// position. The default implementation is equivalent to:
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

  /// Moves the cursor to the given [offset] if able.
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
  /// implementation may either ignore the move or clamp the cursor to the
  /// nearest valid position.
  set column(int column);

  @override
  int get line;

  /// Sets the cursor to the given [line].
  ///
  /// If the line would be moved outside the bounds of the terminal, the
  /// implementation may either ignore the move or clamp the cursor to the
  /// nearest valid position.
  set line(int line);

  @override
  String toString() => 'Cursor <$line:$column>';
}

final class _InteractiveCursor extends InteractiveCursor {
  _InteractiveCursor(
    this._controller,
    this._column,
    this._line,
  );

  final ListTerminalMixin<void> _controller;
  int _column;
  int _line;

  @override
  int get column => _column;

  @override
  set column(int value) {
    _column = value.clamp(
      0,
      _controller.span.width(_controller.lines[_line]),
    );
  }

  @override
  int get line => _line;

  @override
  set line(int value) {
    _line = value.clamp(0, _controller.lines.length - 1);
    _column = _column.clamp(
      0,
      _controller.span.width(_controller.lines[_line]),
    );
  }
}
