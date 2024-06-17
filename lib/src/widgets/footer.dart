import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';

import 'widget.dart';

/// Splits a buffer into two parts: main content and a fixed-height footer.
///
/// The footer is drawn at the bottom of the buffer.
final class Footer extends Widget {
  /// Creates a new footer widget.
  const Footer({
    required this.main,
    required this.footer,
    required this.height,
  });

  /// The main content of the buffer.
  final Widget main;

  /// The footer content of the buffer.
  final Widget footer;

  /// The height of the footer.
  final int height;

  @override
  void draw(Buffer buffer) {
    // Split into two parts.
    final footer = buffer.subGrid(
      Rect.fromLTWH(
        0,
        buffer.height - height,
        buffer.width,
        height,
      ),
    );

    final rect = buffer.area().copyWith(height: buffer.height - height);
    final main = buffer.subGrid(rect);

    // Draw the main content.
    this.main.draw(main);

    // Draw the footer content.
    this.footer.draw(footer);
  }
}
