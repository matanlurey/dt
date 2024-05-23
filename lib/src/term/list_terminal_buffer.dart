import 'package:meta/meta.dart';

import 'cursor.dart';
import 'terminal_buffer.dart';
import 'terminal_controller.dart';
import 'terminal_span.dart';

/// A mixin that provides sensible defaults for terminals backed by a `List<T>`.
///
/// Implementations that provide a [lines] and [span] can use this mixin to
/// provide a default implementation of a terminal sink and terminal controller
/// that emulate the behavior of TTY devices.
///
/// ## Write Behavior
///
/// New lines (i.e. [writeLine]) advance [Cursor.line] by 1, and place the
/// cursor at the beginning of the next line. If the current line is the last
/// line in the terminal a new empty line is added, and the cursor is placed at
/// the beginning of that empty line:
///
/// ```dart
/// // 0 Hello World!█
/// print(buffer.toDebugString());
///
/// buffer.writeLine();
///
/// // 0 Hello World!
/// // 1 █
/// print(buffer.toDebugString());
/// ```
///
/// New spans (i.e. [write]) advance [Cursor.column] by the width of the span:
///
/// ```dart
/// // 0 Hello█
/// print(buffer.toDebugString());
///
/// buffer.write(' World!);
///
/// // 0 Hello World!█
/// print(buffer.toDebugString());
/// ```
///
/// If the cursor is _not_ at [lastPosition] existing content is gradually
/// replaced the new spans, with the colum and line position of the cursor
/// advancing accordingly:
///
/// ```dart
/// // 0 Hello World!█
/// print(buffer.toDebugString());
///
/// buffer.cursor.column -= 6;
///
/// // 0 Hello █orld!
/// print(buffer.toDebugString());
///
/// buffer.write('Earth!');
///
/// // 0 Hello Earth!█
/// print(buffer.toDebugString());
/// ```
///
/// ## Cursor Behavior
///
/// Append-only terminals can safely ignore cursor positioning, as the cursor
/// is always at [lastPosition]. However, if the terminal is used interactively
/// the cursor can be moved to any position within the terminal with the
/// following rules:
///
/// - If the cursor is moved beyond the left or top edge of the terminal, it is
///   clamped to position 0 on the line or column accordingly.
/// - If the cursor is moved beyond the right edge of the terminal, empty spans
///   are added to the line until the cursor is within the bounds of the
///   terminal.
/// - If the cursor is moved beyond the bottom edge of the terminal, it is
///   clamped to the last line in the terminal.
mixin ListTerminalBuffer<T> implements TerminalBuffer<T> {
  @override
  @nonVirtual
  InteractiveCursor get cursor {
    var cursor = _cursor;
    if (cursor == null) {
      final position = lastPosition;
      _cursor = cursor = _InteractiveCursor(this, position.x, position.y);
    }
    return cursor;
  }

  InteractiveCursor? _cursor;

  /// Details about how the contents of the terminal are stored and manipulated.
  @protected
  TerminalSpan<T> get span;

  /// The list of lines in the terminal represented as a list.
  ///
  /// The lines are stored in an idiomatic order, that is, the first line is
  /// at index `0`, the second line is at index `1`, and so on. The last line
  /// is at index `length - 1`.
  ///
  /// The list must be mutable.
  @override
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

  /// Writes a [span] to the [currentLine].
  ///
  /// If no line exists, a new line is created and the span is written to it.
  ///
  /// If the [cursor] is at [lastPosition], the [span] is appended to the
  /// [currentLine]. Otherwise, the [span] replaces content to the right of the
  /// cursor.
  ///
  /// **Note**: The span is assumed to _not_ contain new lines. If the span
  /// contains new lines, it is recommended to pre-process the span and call
  /// [writeLine] for each line.
  @override
  void write(T span) {
    // If the terminal is empty, create a new line.
    if (lines.isEmpty) {
      lines.add(this.span.empty());
    }

    // Replace the remainder of the line with the span.
    final Cursor(:line, :column) = cursor;
    lines[line] = this.span.replace(lines[line], span, column);
    cursor.column += this.span.width(span);
  }

  /// Writes a [span] to the [currentLine], if given, and terminates the line.
  ///
  /// If the [span] is provided, it is written to the [currentLine] before the
  /// line is terminated. If the [span] contains new lines, it is _not_ split.
  ///
  /// If the [cursor] is at [lastPosition], a new empty line is added to the
  /// terminal. Otherwise, the [span] is appended to the [currentLine].
  @override
  void writeLine([T? span]) {
    if (span != null) {
      write(span);
    }
    lines.add(this.span.empty());
    cursor.line++;
    cursor.column = 0;
  }
}

final class _InteractiveCursor<T> extends InteractiveCursor {
  _InteractiveCursor(
    this._terminal,
    this._column,
    this._line,
  );

  final ListTerminalBuffer<T> _terminal;
  int _column;
  int _line;

  @override
  int get column => _column;

  @override
  set column(int value) {
    // No-op if the value is the same.
    if (value == _column) {
      return;
    }

    // If < 0, clamp to 0.
    if (value < 0) {
      value = 0;
    }

    // Otherwise, add empty spans to the line until the column is reached.
    final line = _terminal.lines[_line];
    final width = _terminal.span.width(line);
    if (value > width) {
      _terminal.lines[_line] = _terminal.span.merge(
        line,
        _terminal.span.empty(value - width),
      );
    }

    _column = value;
  }

  @override
  int get line => _line;

  @override
  set line(int value) {
    if (value == _line) {
      return;
    }

    _line = value.clamp(0, _terminal.lines.length - 1);
  }
}
