import 'package:dt/src/core.dart';
import 'package:meta/meta.dart';

import 'cursor.dart';
import 'view.dart';

/// A display of lines of content [T].
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
/// - or use [Terminal.of] for a generic terminal with a custom [T].
abstract class Terminal<T> extends TerminalView<T> {
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

  /// Creates a new terminal from [lines] and an optional [cursor].
  ///
  /// The [width] and [emptyLine] functions are used to determine the width
  /// of a line and create an empty line, respectively.
  ///
  /// If [cursor] is not provided, the cursor is placed at the end of the last
  /// line in the terminal, otherwise it is clamped to the terminal's bounds.
  ///
  /// **TIP**: Prefer using [StringTerminal] for a terminal of strings.
  factory Terminal.of(
    Iterable<T> lines, {
    required int Function(T) width,
    required T Function() emptyLine,
    Cursor? cursor,
  }) {
    return _Terminal(
      lines,
      width: width,
      emptyLine: emptyLine,
      cursor: cursor,
    );
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

final class _Terminal<T> extends Terminal<T> {
  _Terminal(
    super.lines, {
    required int Function(T) width,
    required T Function() emptyLine,
    super.cursor,
  })  : _width = width,
        _emptyLine = emptyLine;

  final int Function(T) _width;
  final T Function() _emptyLine;

  @override
  Cursor get lastPosition {
    return isEmpty ? Offset.zero : Offset(_width(currentLine), lineCount - 1);
  }

  @override
  set lineCount(int length) {
    RangeError.checkNotNegative(length, 'length');
    if (length == _lines.length) {
      return;
    }
    if (length < lineCount) {
      // If the y-position is beyond the new length, move the cursor.
      if (cursor.y >= length) {
        cursor = Offset(cursor.x, length - 1);
      }
      _lines.removeRange(length, lineCount);
      // Clamp if necessary.
      if (cursor >= lastPosition) {
        cursor = lastPosition;
      }
    } else {
      _lines.addAll([
        for (var i = lineCount; i < length; i++) _emptyLine(),
      ]);
    }
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
  ]) : this.fromLines(text?.split('\n') ?? const []);

  /// Creates a new terminal from [lines] of text.
  ///
  /// The cursor is placed at the end of last line, or at `(0, 0)` if empty.
  StringTerminal.fromLines(
    super.lines, {
    super.cursor,
  });

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
}
