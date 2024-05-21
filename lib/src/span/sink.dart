/// A mixin class for a sink that consumes text-like spans of type [T].
///
/// This type provides a way to append spans to a sink, but does not provide
/// input capabilities or the ability to interact with a TTY device; in other
/// words, a [SpanSink] is an append-only terminal.
///
/// It is recommended to _extend_ or _mixin_ this class if able.
///
/// ## Span
///
/// The type [T] is referred to as a _span_ and represents a _unit_ of text that
/// can be added to an existing span or seperated across multiple lines. For
/// example, a span could be a [String] but could also be a custom type that
/// represents a line of text (i.e. with formatting or other metadata).
///
/// A span:
/// - **Must** be appendable to another span of the same type.
/// - **Must** be able to be represented across multiple lines.
/// - **Should** be deeply immutable.
///
/// In order to limit complexity, a span is assumed to always be a single line
/// of text, even if it contains new lines. This means that a span that contains
/// new lines will _not_ be split into multiple lines and will be written as-is.
///
/// ## Example
///
/// A sample implementation of a [SpanSink] that writes spans to a list:
///
/// ```dart
/// // Uses a string for brevity, but could be any type that conforms.
/// class ExampleSink extends SpanSink<String> {
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
abstract mixin class SpanSink<T> {
  // ignore: public_member_api_docs
  const SpanSink();

  /// Writes a span to the current line.
  ///
  /// It is assumed that the [span] does not indicate additional lines, that is,
  /// a [String]-based span, if it included new lines, would _not_ be split into
  /// multiple lines and would be written as-is.
  ///
  /// **tl;dr**: Pre-process the span if it contains new lines.
  void write(T span);

  /// Writes a line to the terminal, optionally appending a [span] first.
  ///
  /// If the [span] is provided, it is written to the current line before the
  /// line is terminated. If the [span] contains new lines, it is _not_ split.
  void writeLine([T? span]);

  /// Writes multiple spans to the current line.
  ///
  /// If [separator] is provided, it is written _between_ each span.
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

  /// Writes multiple lines to the terminal.
  ///
  /// If [separator] is provided, it is written _between_ each line.
  ///
  /// Like [write] and [writeLine], the lines are assumed to be single lines.
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
