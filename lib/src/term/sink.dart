/// An append-only terminal of lines [T].
///
/// The sink includes the ability to append to the terminal, but does not
/// assume TTY capabilities; in other words, it is not a full terminal.
abstract mixin class TerminalSink<T> {
  /// Writes a span to the current line.
  void write(T span);

  /// Writes a line to the terminal, optionally appending a [span].
  void writeLine([T? span]);

  /// Writes multiple spans to the current line.
  ///
  /// If [separator] is provided, it is written between each span.
  void writeAll(Iterable<T> spans, {T? separator}) {
    if (spans.isEmpty) {
      return;
    }
    final iterator = spans.iterator;
    while (true) {
      write(iterator.current);
      if (!iterator.moveNext()) {
        break;
      }
      if (separator != null) {
        write(separator);
      }
    }
  }

  /// Writes multiple lines to the terminal.
  ///
  /// If [separator] is provided, it is written between each line.
  void writeLines(Iterable<T> lines, {T? separator}) {
    if (lines.isEmpty) {
      return;
    }
    final iterator = lines.iterator;
    while (true) {
      write(iterator.current);
      if (!iterator.moveNext()) {
        break;
      }
      writeLine(separator);
    }
  }
}
