import 'dart:convert';

import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';
import 'package:dt/src/backend/ansi_escaped_color.dart';
import 'package:dt/src/backend/ansi_escaped_style.dart';
import 'package:meta/meta.dart';

import 'command.dart';
import 'sequence.dart';
import 'surface_backend.dart';

/// A partial implementation of [SurfaceBackend] that writes ANSI sequences.
mixin AnsiSurfaceBackend implements SurfaceBackend {
  /// The writer used to write UTF-8 encoded ANSI escape sequences.
  @protected
  Writer get writer;

  void _writeSequences(Iterable<Sequence> sequences, [String content = '']) {
    final ansi = sequences.map((s) => s.toEscapedString()).join();
    final total = '$ansi$content';
    if (total.isEmpty) {
      return;
    }
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
  void drawBatch(
    Iterable<Cell> cells, {
    Offset start = Offset.zero,
    int? width,
  }) {
    // Move the cursor to the start position and write a reset sequence.
    moveCursorTo(start.x, start.y);

    // TODO: Use dual-buffering instead of this one-off implementation.
    //
    // With dual-buffering we could remove the "drawBatch" method entirely, and
    // stage all changes to the buffer in a separate buffer. Then, when the
    // "flush" method is called, we would compare the two buffers and only write
    // the necessary changes to the terminal. This would allow us to avoid
    // writing the entire buffer to the terminal on every frame, and instead
    // only write the changes.
    final buffer = StringBuffer();
    void writeSeq(Sequence seq) {
      buffer.write(seq.toEscapedString());
    }

    writeSeq(resetStyle.toSequence());

    // Determine the width of the batch.
    width ??= size.$1 - 1;

    var fg = Color.reset;
    var bg = Color.reset;
    var count = 0;

    final list = List.of(cells);
    for (final cell in list) {
      // If the width has been reached, move to the next line.
      if (count > width) {
        count = 1;
        buffer.writeln();
      } else {
        count++;
      }

      // If the style has changed, write a new style sequence.
      if (cell.style.foreground case final Color color when color != fg) {
        fg = color;
        buffer.write(fg.setForeground().toSequence().toEscapedString());
      }
      if (cell.style.background case final Color color when color != bg) {
        bg = color;
        buffer.write(bg.setBackground().toSequence().toEscapedString());
      }

      // Write the content of the cell.
      buffer.write(cell.symbol);
    }

    // Write the buffer to the terminal.
    writer.write(utf8.encode(buffer.toString()));
  }

  @override
  @nonVirtual
  void clear() {
    _writeSequences([ClearScreen.all.toSequence()]);
  }

  @override
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
    _writeSequences([MoveCursorTo(y + 1, x + 1).toSequence()]);
  }

  @override
  @nonVirtual
  void startSynchronizedUpdate() {
    _writeSequences([SynchronizedUpdate.start.toSequence()]);
  }

  @override
  @nonVirtual
  void endSynchronizedUpdate() {
    _writeSequences([SynchronizedUpdate.end.toSequence()]);
  }
}
