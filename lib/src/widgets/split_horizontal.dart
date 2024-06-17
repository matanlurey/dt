import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';

import 'widget.dart';

/// Splits a buffer into two parts: left and right.
///
/// The left widget is drawn on the left side of the buffer.
final class SplitHorizontal extends Widget {
  /// Creates a new horizontal split widget.
  const SplitHorizontal({
    required this.left,
    required this.right,
  });

  /// The left widget.
  final Widget left;

  /// The right widget.
  final Widget right;

  @override
  void draw(Buffer buffer) {
    final left = buffer.subGrid(
      Rect.fromLTWH(0, 0, buffer.width ~/ 2, buffer.height),
    );

    final right = buffer.subGrid(
      Rect.fromLTWH(buffer.width ~/ 2, 0, buffer.width ~/ 2, buffer.height),
    );

    this.left.draw(left);
    this.right.draw(right);
  }
}
