import 'raw_terminal_buffer.dart';
import 'terminal_buffer.dart';

/// A sink that builds text-like lines of spans [T].
///
/// This type provides a way to _append_ spans in a unidirectional manner, but
/// does not provide input capabilities or the ability to interact with a TTY
/// device; in other words, a [TerminalSink] can be considered an append-only
/// terminal.
///
/// Each write operation appends spans and lines to the cursor position, where
/// the behavior of the cursor is determined by the implementation. For example,
/// a write operation in a standard [TerminalBuffer] replaces the remainder of the
/// output and moves the cursor to the end of the new content, while a
/// [RawTerminalBuffer] does not move the cursor at all.
///
/// It is recommended to _extend_ or _mixin_ this class if able.
///
/// ## Span
///
/// The type [T] is referred to as a _span_ and represents a _unit_ that can be
/// added to an existing line or separated across multiple lines. For example,
/// a span could be a [String] but could also be a custom type that represents
/// formatting or other metadata.
///
/// A span:
/// - **Must** be _appendable_ to another span of the same type. That is, there
///   must be a logical way to combine two spans into a single span (`a + b`).
/// - **Should** be _deeply immutable_. This is to ensure that spans can be
///   safely shared across multiple lines without causing unexpected behavior,
///   though this is not strictly required.
///
/// In order to limit complexity, a _span_ of [T] is always assumed to logically
/// never represent more than a single line of text. A string-based span which
/// contains `\m` characters will _not_ be split into multiple lines. It is
/// recommended to pre-process the span and call the [writeLine] method for each
/// line if the span contains new lines.
///
/// ## Line
///
/// A _line_ is a separation of spans across virtual space, typically
/// (but not strictly) represented vertically. A line can contain multiple
/// spans, or be considered empty if it contains no spans.
///
/// ## Example
///
/// A sample implementation of a [TerminalSink] that writes lines to a list:
///
/// ```dart
/// // Uses a string for brevity, but could be any type that conforms.
/// class ExampleSink extends TerminalSink<String> {
///   final List<String> lines = [];
///
///   @override
///   void write(String span) {
///     if (lines.isEmpty) {
///       lines.add('');
///     }
///     lines.last += span;
///   }
///
///   @override
///   void writeLine([String? span]) {
///     if (span != null) {
///       write(span);
///     }
///     lines.add('');
///   }
/// }
/// ```
abstract mixin class TerminalSink<T> {
  /// Writes a [span] to the _current_ line.
  ///
  /// If no line exists, a new line is created and the span is written to it.
  ///
  /// **Note**: The span is assumed to _not_ contain new lines. If the span
  /// contains new lines, it is recommended to pre-process the span and call
  /// [writeLine] for each line.
  void write(T span);

  /// Writes a [span] to the _current_ line, if given, and terminates the line.
  ///
  /// If the [span] is provided, it is written to the current line before the
  /// line is terminated. If the [span] contains new lines, it is _not_ split.
  void writeLine([T? span]);

  /// Writes multiple [spans] to the _current_ line.
  ///
  /// If a [separator] is provided, it is written _between_ each span.
  ///
  /// Like [write] and [writeLine], the spans are assumed to be single lines.
  void writeAll(Iterable<T> spans, {T? separator}) {
    var isFirst = true;
    for (final span in spans) {
      if (!isFirst && separator != null) {
        write(separator);
      }
      write(span);
      isFirst = false;
    }
  }

  /// Writes multiple [spans] to the _current_ line, and terminates the line.
  ///
  /// If a [separator] is provided, it is written _between_ each span.
  ///
  /// Like [write] and [writeLine], the spans are assumed to be single lines.
  void writeLines(Iterable<T> lines, {T? separator}) {
    final iterator = lines.iterator;
    if (!iterator.moveNext()) {
      return;
    }
    while (true) {
      write(iterator.current);
      final hasNext = iterator.moveNext();
      if (separator != null && hasNext) {
        write(separator);
      }
      writeLine();
      if (!hasNext) {
        break;
      }
    }
  }
}
