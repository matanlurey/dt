import 'package:dt/src/core.dart';
import 'package:dt/src/term/list_terminal_buffer.dart';
import 'package:meta/meta.dart';

import 'terminal_controller.dart';
import 'terminal_sink.dart';
import 'terminal_span.dart';
import 'terminal_view.dart';

/// A _canonical_ buffered terminal of lines [T] and a [cursor] position.
///
/// This type provides a way to construct and manipulate the contents of a
/// terminal of lines, similar to the capabilities of a canonical ("cooked")
/// terminal. In practice, it is the combination of the types:
/// - [TerminalSink] for writing to the terminal.
/// - [TerminalView] for reading from the terminal.
/// - [TerminalController] for manipulating the cursor and terminal contents.
///
/// ## Cursor behavior
///
/// Append-only terminals can safely ignore cursor positioning, as the cursor
/// is always at the end of the terminal (i.e. [lastPosition]). However, if
/// the terminal is used interactively the following rules are recommended
/// and are implemented by the default ([Terminal.new]) type:
///
/// - The cursor is always clamped to the bounds of the terminal. If the cursor
///   would be placed outside the terminal, it is moved to the nearest valid
///   position.
/// - The cursor is always at the end of the last line, unless explicitly moved.
/// - If a [write] operation is performed when the cursor is _not_ at the end of
///   the buffer, the contents to the right of the cursor are _replaced_ with
///   the new contents.
/// - Clearing content _before_ the cursor will insert empty lines and spans to
///   replace the cleared content, but will not move the cursor. See
///   [CanonicalMixin] for details.
///
/// See [RawTerminalBuffer].
abstract interface class TerminalBuffer<T>
    with TerminalView<T>, TerminalSink<T>
    implements TerminalController<T> {
  /// Creates a new line feed with the provided `___Span` implementations.
  ///
  /// This constructor provides a simple way to create a terminal with custom
  /// span handling without needing to extend the class by providing the
  /// necessary functions to manipulate the spans, [TerminalSpan].
  ///
  /// A [cursor] may be provided, which defaults to the last line and column,
  /// and is clamped to the bounds of the terminal.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final terminal = Terminal(
  ///   span: const StringSpan(),
  /// );
  /// ```
  factory TerminalBuffer(
    TerminalSpan<T> span, {
    Offset? cursor,
    Iterable<T> lines,
  }) = _Terminal;

  /// Creates a new line feed, optionally by copying [lines] if provided.
  TerminalBuffer._from({
    Iterable<T> lines = const [],
  }) : _lines = List.of(lines);

  @override
  InteractiveCursor get cursor;

  @override
  Offset get lastPosition;

  @override
  @nonVirtual
  int get lineCount => _lines.length;
  final List<T> _lines;

  @override
  @nonVirtual
  T line(int index) => _lines[index];

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
}

final class _Terminal<T> extends TerminalBuffer<T> with ListTerminalBuffer<T> {
  _Terminal(
    this.span, {
    super.lines,
    Offset? cursor,
  }) : super._from() {
    if (cursor == null) {
      cursor = lastPosition;
    } else {
      cursor = cursor.clamp(Offset.zero, lastPosition);
    }
    this.cursor.offset = cursor;
  }

  @override
  final TerminalSpan<T> span;

  @override
  List<T> get lines => _lines;

  @override
  Offset get lastPosition {
    if (isEmpty) {
      return Offset.zero;
    }
    return Offset(
      _lines.isEmpty ? 0 : span.width(_lines.last),
      _lines.length - 1,
    );
  }
}
