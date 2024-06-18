import 'package:dt/layout.dart';
import 'package:dt/src/rendering/buffer.dart';

import 'widget.dart';

/// A widget that lays out other widgets according to a layout algorithm.
///
/// The layout must divide the area into the exact number of sub-areas as there
/// are [children], and the children are then drawn in those sub-areas in the
/// order they are provided.
final class Layout extends Widget {
  /// Creates a layout widget.
  const Layout(this.layout, this.children);

  /// The layout algorithm to use.
  final LayoutSpec layout;

  /// The children to lay out.
  final List<Widget> children;

  @override
  void draw(Buffer buffer) {
    final area = buffer.area();
    final split = area.split(layout);
    if (children.length > split.length) {
      throw StateError(
        'Layout defined ${split.length} sub-areas, but received '
        '${children.length} children',
      );
    }

    for (var i = 0; i < split.length; i++) {
      final child = children[i];
      child.draw(buffer.subGrid(split[i]));
    }
  }
}
