import 'dart:math' as math;

import 'package:dt/src/core.dart';
import 'package:meta/meta.dart';

import 'terminal_sink.dart';

/// A view of a terminal: a sequence of lines [T] and a [cursor] position.
///
/// This type is used to provide a read-only view of a sequence of lines, which
/// could be used to represent the output of a non-interactive terminal, a file,
/// or any other source of lines.
///
/// It is recommended to _extend_ or _mixin_ this class if able.
///
/// See [TerminalSink] for definitions of _line_ and _span_.
abstract mixin class TerminalView<T> {
  // coverage:ignore-start
  // ignore: public_member_api_docs
  const TerminalView();
  // coverage:ignore-end

  /// The last possible position in the terminal.
  Offset get lastPosition;

  /// Number of lines in the terminal.
  ///
  /// Implementations are expected to provide a constant-time implementation.
  int get lineCount;

  /// Whether the terminal is empty.
  ///
  /// A terminal is considered empty if it has no lines, that is `length == 0`.
  @nonVirtual
  bool get isEmpty => lineCount == 0;

  /// Whether the terminal is not empty.
  @nonVirtual
  bool get isNotEmpty => !isEmpty;

  /// Returns the line at [index] in the range of `0 <= index < length`.
  ///
  /// Reading beyond the bounds of the terminal throws an error.
  T line(int index);

  /// Lines in the terminal in an idiomatic order.
  ///
  /// A typical terminal is vertically ordered from top to bottom.
  Iterable<T> get lines => Iterable.generate(lineCount, line);

  /// Returns a string representation of the terminal suitable for debugging.
  ///
  /// ```txt
  /// Hello World!
  /// ```
  ///
  /// If [drawBorder] is `true`, the bounds of the terminal are drawn:
  ///
  /// ```txt
  /// ┌────────────┐
  /// │Hello World!│
  /// └────────────┘
  /// ```
  ///
  /// If [drawCursor] is `true`, the cursor position is replaced with a `█`:
  ///
  /// ```txt
  /// Hello World!█
  /// ```
  ///
  /// If [includeLineNumbers] is `true`, each row is prefixed with a number:
  ///
  /// ```txt
  /// 1: Hello World!
  /// ```
  ///
  /// When combined with [drawBorder] the box is split into two parts:
  ///
  /// ```txt
  /// ┌─┬──────────┐
  /// │1│Hello     │
  /// │2│World!    │
  /// └─┴──────────┘
  /// ```
  ///
  /// If `T.toString` is not suitable, provide a [format] function to convert.
  static String visualize<T>(
    TerminalView<T> view, {
    bool drawBorder = false,
    Offset? drawCursor,
    bool includeLineNumbers = false,
    String Function(T span)? format,
  }) {
    // Default to the identity function.
    format ??= (span) => span.toString();

    // Convert the spans to strings.
    var lines = view.lines.map(format).toList();

    // Calculate the width of the terminal.
    var width = lines.fold<int>(0, (max, line) => math.max(max, line.length));

    // If we are drawing a cursor
    if (drawCursor != null) {
      // Increase the width to account for the cursor.
      if (drawCursor.x == width) {
        width++;
        lines = lines.map((line) => '$line ').toList();
      }

      // Replace the cursor with a block character.
      final cursorLine = lines[drawCursor.y];
      lines[drawCursor.y] = cursorLine.replaceRange(
        drawCursor.x,
        drawCursor.y + 1,
        '█',
      );
    }

    // Now render with the given options.
    final lineNumberWidth = lines.length.toString().length;
    final buffer = StringBuffer();
    if (drawBorder) {
      // Draw the top border.
      buffer.write('┌─');
      if (includeLineNumbers) {
        // Calculate the width of the line numbers.
        buffer.write('─' * (lineNumberWidth - 1));
        buffer.write('┬');
      }
      buffer.write('─' * (width - 1));
      buffer.writeln('┐');
    }
    for (var i = 0; i < lines.length; i++) {
      if (drawBorder) {
        buffer.write('│');
        if (includeLineNumbers) {
          buffer.write('${i + 1}'.padLeft(lineNumberWidth));
          buffer.write('│');
        }
      }
      buffer.write(lines[i].padRight(width));
      buffer.writeln(drawBorder ? '│' : '');
    }
    if (drawBorder) {
      // Draw the bottom border.
      buffer.write('└─');
      if (includeLineNumbers) {
        buffer.write('─' * (lineNumberWidth - 1));
        buffer.write('┴');
      }
      buffer.write('─' * (width - 1));
      buffer.writeln('┘');
    }
    return buffer.toString();
  }
}
