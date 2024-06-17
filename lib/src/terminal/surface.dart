import 'dart:io' as io;

import 'package:dt/backend.dart';
import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';

import 'frame.dart';

/// An interface to interact and draw [Frame]s on a terminal.
abstract final class Surface {
  /// Creates a new terminal that uses [stdout] and [stdin] for I/O.
  ///
  /// If [stdout] or [stdin] are not provided, they default to [io.stdout] and
  /// [io.stdin] respectively. Upon creation, the terminal will switch to the
  /// alternate screen buffer, hide the cursor, and enable raw mode.
  ///
  /// When [close] is called, the terminal will switch back.
  factory Surface.fromStdio([io.Stdout? stdout, io.Stdin? stdin]) {
    return _StdioSurface(stdout ?? io.stdout, stdin ?? io.stdin);
  }

  /// Creates a new terminal from a [backend].
  ///
  /// This is useful for testing or when a custom backend is needed.
  factory Surface.fromBackend(SurfaceBackend backend) {
    final (width, height) = backend.size;
    return _Surface(backend, Buffer(width, height));
  }

  /// Disposes of the terminal.
  ///
  /// This should be called when the terminal is no longer needed.
  void close();

  /// Synchronizes terminal size, calls [render], and flushes the frame.
  ///
  /// This is the main entry point for drawing to the terminal.
  void draw(void Function(Frame) render);
}

final class _Surface implements Surface {
  _Surface(this._backend, this._buffer);
  final SurfaceBackend _backend;
  final Buffer _buffer;

  late var _frame = Frame(_buffer);
  var _disposed = false;

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('Terminal has been disposed.');
    }
  }

  @override
  void close() {
    _checkNotDisposed();
    _disposed = true;
  }

  @override
  void draw(void Function(Frame) render) {
    _checkNotDisposed();

    // Get a frame.
    final frame = _frame;
    try {
      _backend.startSynchronizedUpdate();
      render(frame);
    } finally {
      _backend.endSynchronizedUpdate();
    }

    // Draw the buffer to the terminal.
    for (var y = 0; y < frame.size.height; y++) {
      for (var x = 0; x < frame.size.width; x++) {
        final cell = _buffer.get(x, y);
        _backend.draw(x, y, cell);
      }
    }

    // Check if we have a cursor to render.
    switch (frame.cursor) {
      case null:
        _backend.hideCursor();
      case Offset(:final x, :final y):
        _backend.moveCursorTo(x, y);
        _backend.showCursor();
    }

    // Increment the frame count.
    _frame = frame.next();
  }
}

final class _StdioSurface extends _Surface {
  factory _StdioSurface(io.Stdout stdout, io.Stdin stdin) {
    // Switch to the alternate screen buffer.
    stdout.write(AlternateScreenBuffer.enter.toSequence().toEscapedString());

    // Hide the cursor.
    stdout.write(SetCursorVisibility.hidden.toSequence().toEscapedString());

    // Enable raw mode.
    stdin
      ..echoMode = false
      ..lineMode = false;

    return _StdioSurface._(
      SurfaceBackend.fromStdout(stdout),
      Buffer(stdout.terminalColumns, stdout.terminalLines),
      stdin,
      stdout,
    );
  }

  _StdioSurface._(
    super._backend,
    super._buffer,
    this._stdin,
    this._stdout,
  );

  final io.Stdin _stdin;
  final io.Stdout _stdout;

  @override
  void close() {
    super.close();

    // Disable raw mode.
    _stdin
      ..echoMode = true
      ..lineMode = true;

    // Show the cursor.
    _stdout.write(SetCursorVisibility.visible.toSequence().toEscapedString());

    // Switch back to the main screen buffer.
    _stdout.write(AlternateScreenBuffer.leave.toSequence().toEscapedString());
  }
}
