import 'dart:convert';

import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';
import 'package:dt/src/terminal/ansi_escaped_style.dart';
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
    writer.write(utf8.encode('$ansi$content'));
  }

  @override
  @nonVirtual
  void draw(int x, int y, Cell cell) {
    // Move the cursor to the cell position.
    moveCursorTo(x + 1, y + 1);

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
