import 'package:characters/characters.dart';
import 'package:dt/rendering.dart';

/// A widget is a type that can be drawn on a [Buffer].
abstract class Widget {
  // ignore: public_member_api_docs
  const Widget();

  /// Draws the widget on the [buffer].
  void draw(Buffer buffer);
}

/// A text widget that draws a string at the given position.
final class Text extends Widget {
  /// Creates a new text widget.
  const Text(
    this.text, {
    this.style = Style.inherit,
    this.align = TextAlign.left,
  });

  /// The text to draw.
  final String text;

  /// The style to apply to the text.
  final Style style;

  /// The alignment of the text.
  final TextAlign align;

  @override
  void draw(Buffer buffer) {
    final width = text.characters.length;

    final int x;
    switch (align) {
      case TextAlign.left:
        x = 0;
      case TextAlign.center:
        x = (buffer.width - width) ~/ 2;
      case TextAlign.right:
        x = buffer.width - width;
    }

    buffer.print(x, 0, text, style: style);
  }
}

/// A text-alignments for a [Text] widget.
enum TextAlign {
  /// Aligns the text to the left.
  left,

  /// Aligns the text to the center.
  center,

  /// Aligns the text to the right.
  right;
}
