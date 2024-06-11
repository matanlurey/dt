import 'package:dt/layout.dart';

import 'buffer.dart';

/// A consistent view into a terminal state for rendering a single frame.
///
/// Frames are typically acquired during a synchronous draw operation, and
/// represent the state of the terminal at a single point in time for rendering
/// widgets and controlling the cursor position.
abstract interface class Frame {
  /// Size of the current frame.
  ///
  /// This is guaranteed not to change during rendering.
  ///
  /// If your app listens for a resize event, it should ignore the event for any
  /// calculations that are used to render the current frame and use this value
  /// instead.
  Rect get bounds;
}

/// A renderable object that can be drawn to a terminal frame.
abstract interface class Renderable {
  /// ...
  void render(Buffer output, Rect bounds);
}
