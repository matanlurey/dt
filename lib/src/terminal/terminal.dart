import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';

import 'backend.dart';

/// An interface to interact and draw [Frame]s on a terminal.
final class Terminal {
  /// Creates a new terminal with the given backend with a full screen viewport.
  factory Terminal(Backend backend) {
    final (width, height) = backend.size;
    return Terminal._(backend, Buffer(width, height));
  }

  Terminal._(this._backend, this._buffer);
  final Backend _backend;
  final Buffer _buffer;
  late var _frame = Frame(_buffer);

  /// Synchronizes terminal size, calls [render], and flushes the frame.
  ///
  /// This is the main entry point for drawing to the terminal.
  void draw(void Function(Frame) render) {
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
