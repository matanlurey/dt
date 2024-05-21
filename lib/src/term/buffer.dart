import 'package:meta/meta.dart';

import 'cursor.dart';
import 'sink.dart';
import 'view.dart';

/// A buffer representing the output of a canonical ("cooked") terminal.
///
/// This class provides a way to construct and manipulate the contents of a
/// terminal without direct interaction with a TTY device or input capabilities.
///
/// The buffer maintains a sequence of lines of type [T], along with a cursor
/// position. Spans can be appended to the buffer, which automatically updates
/// the cursor position and line count to simulate the output of a cooked mode
/// terminal.
///
/// The [cursor] is always placed at the [lastPosition] in the buffer.
abstract class TerminalBuffer<T> extends TerminalView<T> with TerminalSink<T> {
  /// Creates a new terminal buffer, optionally with [lines].
  TerminalBuffer([
    Iterable<T> lines = const [],
  ]) : _lines = List.of(lines);

  @override
  @nonVirtual
  Cursor get cursor => lastPosition;

  @override
  @nonVirtual
  Iterable<T> get lines => _lines;
  final List<T> _lines;

  @override
  @nonVirtual
  int get lineCount => _lines.length;

  @override
  T line(int index) => _lines[index];

  @override
  String toString() {
    return ''
        'TerminalBuffer '
        '<cursor: (${cursor.x}, ${cursor.y}), lines: $lineCount>';
  }
}

/// A buffer representing the output of a [String]-based canonical terminal.
///
/// This class provides a way to construct and manipulate the contents of a
/// terminal without direct interaction with a TTY device or input capabilities.
///
/// The buffer maintains a sequence of [String]-based lines, along with a cursor
/// position. Spans can be appended to the buffer, which automatically updates
/// the cursor position and line count to simulate the output of a cooked mode
/// terminal.
///
/// Strings can contain new lines, the buffer will split the span automatically:
/// ```dart
/// final buffer = StringTerminalBuffer();
/// buffer.write('Hello\nGoodbye');
/// print(buffer.lines); // ['Hello', 'Goodbye']
/// ```
///
/// The [cursor] is always placed at the [lastPosition] in the buffer.
base class StringTerminalBuffer extends TerminalBuffer<String> {
  /// Creates a new string terminal buffer, optionally by parsing a [string].
  ///
  /// If provided, the string is split into lines using the `\n` character.
  StringTerminalBuffer([
    String? string,
  ]) : super(string == null ? const [] : string.split('\n'));

  /// Creates a new string terminal buffer by copying the given [lines].
  ///
  /// Each line typically will contain a single span of text, but the presence
  /// of a newline character will split the span into multiple lines. In other
  /// words, this constructor is semantically similar to [writeLines]:
  /// ```dart
  /// final a = StringTerminalBuffer.fromLines(['Hello\nGoodbye']);
  /// final b = StringTerminalBuffer()..writeLines(['Hello', 'Goodbye']);
  /// ```
  StringTerminalBuffer.fromLines(Iterable<String> lines) {
    writeLines(lines);
  }

  @override
  Cursor get lastPosition {
    if (isEmpty) {
      return Cursor.zero;
    }
    return Cursor(_lines.last.length, lineCount - 1);
  }

  /// Writes a span to the current line.
  ///
  /// If the span contains newlines (`\n`), it is split into multiple lines.
  @override
  void write(String span) {
    // Edge case: if the buffer is empty, start a new line.
    if (isEmpty) {
      _lines.add('');
    }

    // Walk the span, and if a newline is found, add a line instead.
    var start = 0;
    for (var i = 0; i < span.length; i++) {
      if (span[i] == '\n') {
        _lines
          ..last += span.substring(start, i)
          ..add('');
        start = i + 1;
      }
    }
    if (start < span.length) {
      _lines.last += span.substring(start);
    }
  }

  /// Writes a line to the terminal, optionally prepending with a [span].
  ///
  /// If the span is provided, it is written to the current line before the line
  /// is terminated. If the span contains newlines (`\n`), it is split into
  /// multiple lines.
  @override
  void writeLine([String? span]) {
    if (span != null) {
      write(span);
    }
    _lines.add('');
  }
}
