import 'dart:io' as io;

import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';

import 'backend.dart';

/// An interface to interact and draw [Frame]s on a terminal.
abstract final class Terminal {
  /// Creates a new terminal that uses [stdout] and [stdin] for I/O.
  ///
  /// If [stdout] or [stdin] are not provided, they default to [io.stdout] and
  /// [io.stdin] respectively. Upon creation, the terminal will switch to the
  /// alternate screen buffer, hide the cursor, and enable raw mode.
  ///
  /// When [dispose] is called, the terminal will switch back.
  factory Terminal.fromStdio([io.Stdout? stdout, io.Stdin? stdin]) {
    return _StdioTerminal(stdout ?? io.stdout, stdin ?? io.stdin);
  }

  /// Creates a new terminal from a [backend].
  ///
  /// This is useful for testing or when a custom backend is needed.
  factory Terminal.fromBackend(Backend backend) {
    final (width, height) = backend.size;
    return _Terminal(backend, Buffer(width, height));
  }

  /// Disposes of the terminal.
  ///
  /// This should be called when the terminal is no longer needed.
  void dispose();

  /// Synchronizes terminal size, calls [render], and flushes the frame.
  ///
  /// This is the main entry point for drawing to the terminal.
  void draw(void Function(Frame) render);
}

final class _Terminal implements Terminal {
  _Terminal(this._backend, this._buffer);
  final Backend _backend;
  final Buffer _buffer;

  late var _frame = Frame(_buffer);
  var _disposed = false;

  void _checkNotDisposed() {
    if (_disposed) {
      throw StateError('Terminal has been disposed.');
    }
  }

  @override
  void dispose() {
    _checkNotDisposed();
    _disposed = true;
  }

  @override
  void draw(void Function(Frame) render) {
    _checkNotDisposed();

    // Get a frame.
    final frame = _frame;

    // Render the frame.
    render(frame);

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

final class _StdioTerminal extends _Terminal {
  factory _StdioTerminal(io.Stdout stdout, io.Stdin stdin) {
    // Switch to the alternate screen buffer.
    stdout.write(AlternateScreenBuffer.enter.toSequence().toEscapedString());

    // Hide the cursor.
    stdout.write(SetCursorVisibility.hidden.toSequence().toEscapedString());

    // Enable raw mode.
    stdin
      ..echoMode = false
      ..lineMode = false;

    return _StdioTerminal._(
      Backend.fromStdout(stdout),
      Buffer(stdout.terminalColumns, stdout.terminalLines),
      stdin,
      stdout,
    );
  }

  _StdioTerminal._(
    super._backend,
    super._buffer,
    this._stdin,
    this._stdout,
  );

  final io.Stdin _stdin;
  final io.Stdout _stdout;

  @override
  void dispose() {
    super.dispose();

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
