import 'package:dt/src/core.dart';
import 'package:meta/meta.dart';

import 'cursor.dart';
import 'sink.dart';
import 'view.dart';

/// A buffer representing the output of a canonical ("cooked") terminal.
///
/// This class provides a way to construct and manipulate the contents of a
/// terminal without direct interaction with a TTY device. It supports line
/// buffering and editing, but does not provide input capabilities or control
/// over the terminal's display.
///
/// The buffer maintains a sequence of lines of type [T], along with a cursor
/// position. Spans can be appended to the buffer, which automatically updates
/// the cursor position and line count to simulate the output of a cooked mode
/// terminal.
abstract class TerminalBuffer<T> extends TerminalView<T> with TerminalSink<T> {
  /// Creates a new terminal buffer, optionally with [lines].
  ///
  /// Implementations must place the cursor at the end of the last line.
  TerminalBuffer([
    Iterable<T> lines = const [],
  ]) : _lines = List.of(lines) {
    if (cursor != lastPosition) {
      throw StateError('Cursor must be at the end of the last line');
    }
  }

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

/// A buffer representing the output of a string-based canonical terminal.
///
/// This class provides a way to construct and manipulate the contents of a
/// terminal without direct interaction with a TTY device. It supports line
/// buffering and editing, but does not provide input capabilities or control
/// over the terminal's display.
base class StringTerminalBuffer extends TerminalBuffer<String> {
  /// Creates a new string terminal buffer, optionally with [lines].
  ///
  /// The cursor is placed at the end of the last line.
  StringTerminalBuffer([super.lines]) {
    _cursor = lastPosition;
  }

  @override
  @nonVirtual
  Cursor get cursor => _cursor;
  late Cursor _cursor;

  @override
  Cursor get lastPosition {
    if (isEmpty) {
      return Cursor.zero;
    }
    return Cursor(_lines.last.length, lineCount - 1);
  }

  @override
  void write(String span) {
    _lines[cursor.y] += span;
    _moveCursorToEnd();
  }

  @override
  void writeLine([String? span]) {
    if (span != null) {
      _lines[cursor.y] += span;
    }
    _lines.add('');
    _moveCursorToEnd();
  }

  void _moveCursorToEnd() {
    if (_cursor < lastPosition) {
      _cursor = lastPosition;
    }
  }
}
