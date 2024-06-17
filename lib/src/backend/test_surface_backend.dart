import 'dart:convert' show utf8;
import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';

import 'ansi_escaped_color.dart';
import 'ansi_surface_backend.dart';
import 'command.dart';
import 'sequence.dart';
import 'surface_backend.dart';

/// A backend implementation used for integration testing.
abstract interface class TestSurfaceBackend implements SurfaceBackend {
  factory TestSurfaceBackend(int width, int height) = _TestSurfaceBackend;

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

final class _TestSurfaceBackend
    with AnsiSurfaceBackend
    implements TestSurfaceBackend, Writer {
  _TestSurfaceBackend(
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
  Future<void> flush() async {}

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
          buffer.set(
            cursorPosition.x - 1,
            cursorPosition.y - 1,
            Cell(char, style),
          );
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
            style = style.copyWith(foreground: Color16.inherit);
          } else if (color == 49) {
            style = style.copyWith(background: Color16.inherit);
          } else {
            for (final c in Color16.values) {
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
