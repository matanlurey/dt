import 'dart:io' as io;

import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';

import 'ansi_surface_backend.dart';

/// Abstraction over accessing lower-level terminal-like output APIs.
///
/// Most applications will not interact with the [SurfaceBackend] type directly,
/// and instead use the higher-level `Surface` API.
abstract class SurfaceBackend {
  /// Creates a new backend that writes to the given [stdout].
  ///
  /// This is the most common backend used for writing to the terminal.
  factory SurfaceBackend.fromStdout([io.Stdout? stdout]) {
    return _StdoutBackend(stdout ?? io.stdout);
  }

  /// Draws a [cell] at the given [x] and [y] position.
  void draw(int x, int y, Cell cell);

  /// Clears the terminal screen.
  void clear();

  /// Flushes any buffered content to the terminal screen.
  Future<void> flush();

  /// Starts a synchronized update.
  void startSynchronizedUpdate();

  /// Ends a synchronized update.
  void endSynchronizedUpdate();

  /// Hides the terminal cursor.
  void hideCursor();

  /// Shows the terminal cursor.
  void showCursor();

  /// Moves the terminal cursor to the given position.
  void moveCursorTo(int x, int y);

  /// Returns the terminal size in columns and rows.
  (int columns, int rows) get size;
}

final class _StdoutBackend with AnsiSurfaceBackend {
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
