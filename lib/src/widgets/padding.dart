import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';

import 'widget.dart';

/// A widget that adds padding to its child.
final class Padding extends Widget {
  /// Creates a padding widget.
  const Padding({
    required this.child,
    required this.spacing,
  });

  /// The widget to pad.
  final Widget child;

  /// The padding to apply.
  final Spacing spacing;

  @override
  void draw(Buffer buffer) {
    final rect = Rect.fromLTWH(
      spacing.left,
      spacing.top,
      buffer.width - spacing.horizontal,
      buffer.height - spacing.vertical,
    );
    child.draw(buffer.subGrid(rect));
  }
}
