import 'package:dt/src/core.dart';
import 'package:meta/meta.dart';

import 'terminal_sink.dart';
import 'terminal_view.dart';

final class _InteractiveCursor extends InteractiveCursor {
  _InteractiveCursor(this._terminal, this._column, this._line);

  final Terminal<void> _terminal;
  int _column;
  int _line;

  @override
  int get column => _column;

  @override
  set column(int value) {
    _column = value.clamp(0, _terminal._width(_line));
  }

  @override
  int get line => _line;

  @override
  set line(int value) {
    _line = value.clamp(0, _terminal.lineCount - 1);
    _column = _column.clamp(0, _terminal._width(_line));
  }
}

/// A buffered terminal of lines [T] and a [cursor] position.
///
/// This type provides a way to construct and manipulate the contents of a
/// terminal of lines, similar to the capabilities of a canonical ("cooked")
/// terminal.
///
/// See [TerminalSink] for definitions of _line_ and _span_.
///
/// ## Cursor behavior
///
/// Append-only terminals can safely ignore cursor positioning, as the cursor
/// is always at the end of the terminal (i.e. [lastPosition]). However, if
/// the terminal is used interactively the following rules are recommended
/// and are implemented by the default terminal types:
///
/// - The cursor is always clamped to the bounds of the terminal. If the cursor
///   would be placed outside the terminal, it is moved to the nearest valid
///   position.
/// - The cursor is always at the end of the last line, unless explicitly moved.
/// - If a [write] operation is performed when the cursor is _not_ at the end of
///   the buffer, the contents to the right of the cursor are _replaced_ with
///   the new contents.
///
/// For customized behavior, consider using [RawTerminal] instead, which is
/// intended to be used for fully interactive terminals with cursor movement
/// and input capabilities.
abstract interface class Terminal<T> with TerminalView<T>, TerminalSink<T> {
  /// Creates a new line feed, optionally by copying [lines] if provided.
  Terminal.from({
    Iterable<T> lines = const [],
    Offset? cursor,
  }) : _lines = List.of(lines) {
    if (cursor != null) {
      cursor = cursor.clamp(Offset.zero, lastPosition);
    } else {
      cursor = lastPosition;
    }
    _cursor = _InteractiveCursor(this, cursor.x, cursor.y);
  }

  /// Creates a new line feed with the provided `___Span` implementations.
  ///
  /// This constructor provides a simple way to create a terminal with custom
  /// span handling without needing to extend the class:
  /// - [defaultSpan] creates a new span when a line is written.
  /// - [widthSpan] returns the width of a span.
  /// - [truncateSpan] inserts a span into another span at a given index and
  ///   truncates the remainder.
  ///
  /// A [cursor] may be provided, which defaults to the last line and column,
  /// and is clamped to the bounds of the terminal.
  ///
  /// ## Example
  ///
  /// A sample implementation of a [Terminal] that uses a string for spans:
  ///
  /// ```dart
  /// final terminal = Terminal.using<String>(
  ///   defaultSpan: () => '',
  ///   mergeSpan: (a, b) => '$a$b',
  ///   widthSpan: (span) => span.length,
  ///   truncateSpan: (original, index, insert) {
  ///     return original..replaceRange(index, null, insert);
  ///   },
  /// );
  /// ```
  ///
  /// See also [StringTerminal].
  factory Terminal.using({
    required T Function() defaultSpan,
    required int Function(T) widthSpan,
    required T Function(T original, int index, T insert) truncateSpan,
    Offset? cursor,
    Iterable<T> lines,
  }) = _Terminal;

  @override
  Offset get lastPosition;

  @override
  @nonVirtual
  InteractiveCursor get cursor => _cursor;
  late InteractiveCursor _cursor;

  @override
  @nonVirtual
  int get lineCount => _lines.length;
  final List<T> _lines;

  @override
  @nonVirtual
  T line(int index) => _lines[index];

  /// Move the cursor to the last position in the terminal.
  void _resetCursor() {
    _cursor.offset = lastPosition;
  }

  /// Removes all lines after the cursor.
  void _truncateLines() {
    _lines.removeRange(cursor.line + 1, _lines.length);
  }

  /// Writes a [span] to the _current_ line.
  ///
  /// If the [cursor] is at the end of a line, the [span] is appended to the
  /// current line. Otherwise all contents to the right of the cursor are
  /// replaced with the [span].
  @override
  void write(T span);

  /// Writes a [span] to the _current_ line, if given, and terminates the line.
  ///
  /// If the [span] is provided, it is written to the current line before the
  /// line is terminated. If the [span] contains new lines, it is _not_ split.
  ///
  /// If the [cursor] is at the end of a line, a new line is created and the
  /// [span] is written to it. Otherwise all contents to the right of the cursor
  /// are replaced with the [span].
  @override
  void writeLine([T? span]);

  /// Writes multiple [spans] to the _current_ line.
  ///
  /// If a [separator] is provided, it is written _between_ each span.
  ///
  /// Like [write] and [writeLine], the spans are assumed to be single lines.
  ///
  /// If the [cursor] is at the end of a line, the [spans] are appended to the
  /// current line. Otherwise all contents to the right of the cursor are
  /// replaced with the [spans].
  @override
  void writeAll(Iterable<T> spans, {T? separator});

  /// Writes multiple [spans] to the _current_ line, and terminates the line.
  ///
  /// If a [separator] is provided, it is written _between_ each span.
  ///
  /// Like [write] and [writeLine], the spans are assumed to be single lines.
  ///
  /// If the [cursor] is at the end of a line, a new line is created and the
  /// [spans] are written to it. Otherwise all contents to the right of the
  /// cursor are replaced with the [spans].
  @override
  void writeLines(Iterable<T> lines, {T? separator});

  /// Returns the width of the terminal at the given [line].
  int _width(int line);
}

final class _Terminal<T> extends Terminal<T> {
  _Terminal({
    required T Function() defaultSpan,
    required int Function(T) widthSpan,
    required T Function(T original, int index, T insert) truncateSpan,
    super.lines,
    super.cursor,
  })  : _defaultSpan = defaultSpan,
        _widthSpan = widthSpan,
        _truncateSpan = truncateSpan,
        super.from();

  final T Function() _defaultSpan;
  final int Function(T) _widthSpan;
  final T Function(T, int, T) _truncateSpan;

  @override
  int _width(int line) => _widthSpan(_lines[line]);

  @override
  Offset get lastPosition {
    if (isEmpty) {
      return Offset.zero;
    }
    return Offset(
      _lines.isEmpty ? 0 : _widthSpan(_lines.last),
      _lines.length - 1,
    );
  }

  @override
  void write(T span) {
    // If the terminal is empty, create a new line and write the span.
    if (_lines.isEmpty) {
      _lines.add(span);
      _resetCursor();
      return;
    }

    // Insert it into the current line at the cursor position.
    final Cursor(:line, :column) = cursor;
    _lines[line] = _truncateSpan(_lines[line], column, span);

    // Remove any lines after the cursor and reset the cursor.
    _truncateLines();
    _resetCursor();
  }

  @override
  void writeLine([T? span]) {
    if (span != null) {
      write(span);
    }

    // Add a new line at the cursor position.
    _lines.insert(cursor.line + 1, _defaultSpan());

    // Move the cursor to the new line.
    _cursor.moveTo(column: 0, line: cursor.line + 1);

    // Remove any lines after the cursor.
    _truncateLines();
  }
}

/// A [String]-based line feed.
///
/// This type serves as a sample implementation of a [Terminal] that maintains
/// a list of strings. It is used to demonstrate the capabilities of the type,
/// as well as to provide the basis for an append-only terminal buffer without
/// input capabilities.
///
/// **NOTE**: `\n` characters are _not_ split into separate lines, and the
/// concept of a _span_ and _line_ is based on the definitions in
/// [TerminalSink] namely that a span contents are not parsed for new lines. It
/// is recommended to pre-process spans that contain new lines and call
/// [writeLine] for each.
final class StringTerminal extends Terminal<String> {
  /// Creates a new string-based line feed by copying provided [lines] if any.
  StringTerminal.from({
    super.lines = const [],
    super.cursor,
  }) : super.from();

  @override
  int _width(int line) => _lines[line].length;

  @override
  Offset get lastPosition {
    if (isEmpty) {
      return Offset.zero;
    }
    return Offset(
      _lines.isEmpty ? 0 : _lines.last.length,
      _lines.length - 1,
    );
  }

  @override
  void write(String span) {
    // If the terminal is empty, create a new line and write the span.
    if (_lines.isEmpty) {
      _lines.add(span);
      _resetCursor();
      return;
    }

    // Insert it into the current line at the cursor position.
    final Cursor(:line, :column) = cursor;
    _lines[line] = _lines[line].replaceRange(column, null, span);

    // Remove any lines after the cursor and reset the cursor.
    _truncateLines();
    _resetCursor();
  }

  @override
  void writeLine([String? span]) {
    if (span != null) {
      write(span);
    }

    // Add a new line at the cursor position.
    _lines.insert(cursor.line + 1, '');

    // Move the cursor to the new line.
    _cursor.moveTo(column: 0, line: cursor.line + 1);

    // Remove any lines after the cursor.
    _truncateLines();
  }
}
