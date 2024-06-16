import 'package:dt/layout.dart';

import 'buffer.dart';

/// A consistent view into a terminal state for rendering a single frame.
///
/// Frames are typically acquired during a synchronous draw operation, and
/// represent the state of the terminal at a single point in time for rendering
/// widgets and controlling the cursor position.
final class Frame {
  /// Creates a new frame from the given buffer and [count].
  Frame(this._buffer, [this.count = 0]);
  final Buffer _buffer;

  /// Current frame count.
  ///
  /// This method provides access to the frame count, which is a sequence number
  /// indicating how many frames have been rendered up to (but not including)
  /// the current frame, starting at 0.
  ///
  /// Can be used for:
  /// - Animations
  /// - Performance tracking
  /// - Debugging
  ///
  /// The frame count is guaranteed to be monotonically increasing _except_ it
  /// will wrap around to 0 after reaching the maximum value of an integer on
  /// the executing platform.
  final int count;

  /// Total size of the current frame.
  ///
  /// This is guaranteed not to change during rendering.
  ///
  /// If your app listens for a resize event, it should ignore the event for any
  /// calculations that are used to render the current frame and use this value
  /// instead.
  Rect get size => _buffer.area();

  /// Calls the given [render] function with a buffer for drawing.
  ///
  /// If [bounds] is not provided it defaults to the entire frame.
  void draw(void Function(Buffer) render, [Rect? bounds]) {
    var buffer = _buffer;
    if (bounds != null) {
      buffer = buffer.subGrid(bounds);
    }
    render(buffer);
  }

  /// Cursor position within the frame.
  ///
  /// If the cursor is not visible, this will be `null`.
  Offset? cursor;

  static const _isJsPlatform = identical(1, 1.0);
  static const _maxInt = _isJsPlatform ? _maxJsInt : _maxVmInt;
  static const _maxJsInt = 0x1FFFFFFFFFFFFF;
  static const _maxVmInt = 0x7FFFFFFFFFFFFFFF;

  /// Returns the next frame in the sequence.
  int get _nextCount => count == _maxInt ? 0 : count + 1;

  /// Returns the next frame in the sequence.
  Frame next() => Frame(_buffer, _nextCount);
}
