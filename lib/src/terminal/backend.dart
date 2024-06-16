import 'dart:convert';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';
import 'package:meta/meta.dart';

import 'terminal.dart';

/// Abstraction over accessing lower-level terminal APIs or implementations.
///
/// Most applications will not interact with the [Backend] type directly, and
/// instead use the higher-level [Terminal] class.
abstract class Backend {
  /// Creates a new backend that writes to the given [stdout].
  ///
  /// This is the most common backend used for writing to the terminal.
  factory Backend.fromStdout([io.Stdout? stdout]) {
    return _StdoutBackend(stdout ?? io.stdout);
  }

  /// Draws a [cell] at the given [x] and [y] position.
  void draw(int x, int y, Cell cell);

  /// Clears the terminal screen.
  void clear();

  /// Flushes any buffered content to the terminal screen.
  Future<void> flush();

  /// Hides the terminal cursor.
  void hideCursor();

  /// Shows the terminal cursor.
  void showCursor();

  /// Moves the terminal cursor to the given position.
  void moveCursorTo(int x, int y);

  /// Returns the terminal size in columns and rows.
  (int columns, int rows) get size;
}

/// A partial implementation of [Backend] that writes ANSI escape sequences.
mixin AnsiBackend implements Backend {
  /// The writer used to write UTF-8 encoded ANSI escape sequences.
  @protected
  Writer get writer;

  void _writeSequences(Iterable<Sequence> sequences, [String content = '']) {
    final ansi = sequences.map((s) => s.toEscapedString()).join();
    writer.write(utf8.encode('$ansi$content'));
  }

  @override
  @nonVirtual
  void draw(int x, int y, Cell cell) {
    // Move the cursor to the cell position.
    moveCursorTo(x, y);

    // Write the cell's content and style.
    _writeSequences(cell.style.toSequences(), cell.symbol);

    // Reset the style to the default.
    _writeSequences(Style.reset.toSequences());
  }

  @override
  @nonVirtual
  void clear() {
    _writeSequences([ClearScreen.all.toSequence()]);
  }

  @override
  @nonVirtual
  Future<void> flush() => writer.flush();

  @override
  @nonVirtual
  void hideCursor() {
    _writeSequences([SetCursorVisibility.hidden.toSequence()]);
  }

  @override
  @nonVirtual
  void showCursor() {
    _writeSequences([SetCursorVisibility.visible.toSequence()]);
  }

  @override
  @nonVirtual
  void moveCursorTo(int x, int y) {
    _writeSequences([MoveCursorTo(y, x).toSequence()]);
  }
}

final class _StdoutBackend with AnsiBackend {
  _StdoutBackend(
    this.stdout,
  ) : writer = Writer.fromSink(stdout, onFlush: stdout.flush);

  final io.Stdout stdout;

  @override
  final Writer writer;

  @override
  (int columns, int rows) get size {
    return (stdout.terminalColumns, stdout.terminalLines);
  }
}

/// A backend implementation used for integration testing.
abstract interface class TestBackend implements Backend {
  factory TestBackend(int width, int height) = _TestBackend;

  /// The buffer of cells that represents the terminal screen.
  Buffer get buffer;

  /// Whether the terminal cursor is visible.
  ///
  /// This is used to determine whether the cursor should be drawn or hidden.
  ///
  /// Defaults to `true`.
  bool get isCursorVisible;

  /// Position of the terminal cursor.
  ///
  /// The cursor position is relative to the top-left corner of the terminal.
  Offset get cursorPosition;

  /// Resizes the terminal screen to the given [width] and [height].
  void resize(int width, int height);
}

final class _TestBackend with AnsiBackend implements TestBackend, Writer {
  _TestBackend(
    int width,
    int height,
  ) : buffer = Buffer(width, height);

  @override
  Buffer buffer;

  @override
  Writer get writer => this;

  @override
  var isCursorVisible = true;

  @override
  var cursorPosition = Offset.zero;

  @override
  int write(List<int> bytes, [int offset = 0, int? length]) {
    // Decode the bytes as UTF-8.
    final content = utf8.decode(bytes.sublist(offset, length));

    // Decode the content as ANSI escape sequences.
    var style = Style.inherit;
    for (final sequence in Sequence.parseAll(content)) {
      if (sequence is Literal) {
        // Writes the literal content to the buffer.
        for (final char in sequence.value.characters) {
          buffer.set(cursorPosition.x, cursorPosition.y, Cell(char, style));
        }
        continue;
      }

      switch (Command.tryParse(sequence)) {
        case MoveCursorTo(:final column, :final row):
          cursorPosition = Offset(column, row);
        case ClearScreen.all:
          buffer.fillCells();
        case SetColor16(:final color):
          if (color == 39) {
            style = style.copyWith(foreground: AnsiColor.inherit);
          } else if (color == 49) {
            style = style.copyWith(background: AnsiColor.inherit);
          } else {
            for (final c in AnsiColor.values) {
              if (c.foregroundIndex == color) {
                style = style.copyWith(foreground: c);
                break;
              }
              if (c.backgroundIndex == color) {
                style = style.copyWith(background: c);
                break;
              }
            }
          }
        case SetCursorVisibility.visible:
          isCursorVisible = true;
        case SetCursorVisibility.hidden:
          isCursorVisible = false;
      }
    }

    return length ?? bytes.length - offset;
  }

  @override
  (int columns, int rows) get size => (buffer.width, buffer.height);

  @override
  void resize(int width, int height) {
    // Creates a new buffer with the new dimensions.
    final newBuffer = Buffer(width, height);

    // Copies the extent of the old buffer to the new buffer as possible.
    for (var y = 0; y < math.min(height, buffer.height); y++) {
      for (var x = 0; x < math.min(width, buffer.width); x++) {
        newBuffer.set(x, y, buffer.get(x, y));
      }
    }

    // Updates the buffer and cursor position.
    buffer = newBuffer;
    cursorPosition = Offset.zero;
  }
}
