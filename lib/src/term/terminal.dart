import 'package:dt/src/core.dart';
import 'package:meta/meta.dart';

import 'cursor.dart';
import 'sink.dart';
import 'view.dart';

/// A display of lines of content span [T].
///
/// This class provides the foundation for a virtual terminal, handling the
/// presentation, cursor position, and other user interface elements that might
/// make up a terminal.
///
/// A concrete implementation of a terminal typically will have a concrete [T].
///
/// To implement a terminal, either:
/// - `implements Terminal` to define a custom terminal.
/// - `extends Terminal`, and define [lineCount] and [lastPosition].
abstract class Terminal<T> extends TerminalView<T> with TerminalSink<T> {
  /// Creates a new terminal from [lines] and an optional [cursor].
  ///
  /// If [cursor] is not provided, the cursor is placed at the end of the last
  /// line in the terminal, otherwise it is clamped to the terminal's bounds.
  Terminal(
    Iterable<T> lines, {
    Cursor? cursor,
  })  : _lines = List.of(lines),
        _cursor = cursor ?? Offset.zero {
    if (cursor == null) {
      _cursor = lastPosition;
      return;
    }
  }

  @override
  @nonVirtual
  Iterable<T> get lines => _lines;
  final List<T> _lines;

  @override
  @nonVirtual
  Cursor get cursor => _cursor;
  Cursor _cursor;

  /// Sets the cursor to the given [position].
  ///
  /// The cursor is clamped to the bounds of the terminal.
  set cursor(Cursor position) {
    _cursor = position.clamp(firstPosition, lastPosition);
  }

  @override
  @nonVirtual
  int get lineCount => _lines.length;

  /// Sets the number of lines in the terminal.
  ///
  /// The terminal is truncated if [length] is less than the current length,
  /// and padded with empty lines if [length] is greater than the current
  /// length.
  ///
  /// The cursor is moved to the last line if it is beyond the new length, but
  /// is _not_ moved if the cursor is within the bounds of the new length (i.e.
  /// the length has increased).
  ///
  /// It is an error to set the length to a negative value.
  set lineCount(int length);

  @override
  T line(int index) => _lines[index];

  @override
  String toString() {
    return 'Terminal <cursor: (${cursor.x}, ${cursor.y}), lines: $lineCount>';
  }
}

/// A terminal of lines of text.
///
/// This class provides a concrete implementation of a terminal of strings,
/// similar to a text editor or a console. The terminal is backed by a list of
/// lines of text, and a cursor that points to a specific position in the text.
base class StringTerminal extends Terminal<String> {
  /// Creates a new terminal with optional initial [text].
  ///
  /// The initial text is split into lines using the newline character `\n`,
  /// and used as the initial state of the terminal, otherwise the terminal
  /// starts [isEmpty].
  ///
  /// The cursor is placed at the end of the last line, or at `(0, 0)` if empty.
  StringTerminal([
    String? text,
  ]) : super(text?.split('\n') ?? const []);

  @override
  @nonVirtual
  Cursor get lastPosition {
    return isEmpty ? Offset.zero : Offset(currentLine.length, lineCount - 1);
  }

  @override
  @nonVirtual
  set lineCount(int length) {
    RangeError.checkNotNegative(length, 'length');
    if (length == _lines.length) {
      return;
    }
    if (length < _lines.length) {
      // If the y-position is beyond the new length, move the cursor.
      if (cursor.y >= length) {
        cursor = Offset(cursor.x, length - 1);
      }
      _lines.removeRange(length, _lines.length);
      // Clamp if necessary.
      if (cursor >= lastPosition) {
        cursor = lastPosition;
      }
    } else {
      _lines.addAll(List.filled(length - _lines.length, ''));
    }
  }

  @override
  @nonVirtual
  void write(String span) {
    final current = currentLine;
    final prefix = current.substring(0, cursor.x);
    final suffix = current.substring(cursor.x);
    _lines[cursor.y] = '$prefix$span$suffix';
    cursor = cursor.translate(span.length, 0);
  }

  @override
  @nonVirtual
  void writeLine([String? span]) {
    write(span ?? '');
  }
}
