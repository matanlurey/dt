import 'package:dt/rendering.dart';

import 'widget.dart';

/// A widget that displays text.
abstract final class Text extends Widget {
  const Text._();

  /// Creates a new text widget from a string.
  ///
  /// Optionally, a [style] can be provided to apply to the text.
  ///
  /// For more complex text, consider using [Text.fromSpan] or [Text.fromLine].
  factory Text(
    String text, {
    Style style = Style.inherit,
  }) {
    return Text.fromSpan(Span(text, style));
  }

  /// Creates a new text widget from a [Span].
  factory Text.fromSpan(Span span) = _SpanText;

  /// Creates a new text widget from a [Line].
  factory Text.fromLine(Line line) = _LineText;
}

final class _SpanText extends Text {
  const _SpanText(this._span) : super._();
  final Span _span;

  @override
  void draw(Buffer buffer) {
    buffer.printSpan(0, 0, _span);
  }
}

final class _LineText extends Text {
  const _LineText(this._line) : super._();
  final Line _line;

  @override
  void draw(Buffer buffer) {
    var x = switch (_line.alignment) {
      Alignment.left => 0,
      Alignment.center => (buffer.width - _line.width) ~/ 2,
      Alignment.right => buffer.width - _line.width,
    };

    // Add spaces to the left of the text.
    final leftSpacing = ' ' * x;
    buffer.print(
      0,
      0,
      leftSpacing,
      style: _line.style,
    );

    // Draw the spans.
    for (final span in _line.spans) {
      buffer.print(
        x,
        0,
        span.content,
        style: _line.style.overrideWith(span.style),
      );
      x += span.width;
    }

    // Add spaces to the right of the text.
    final rightSpacing = ' ' * (buffer.width - x);
    buffer.print(
      x,
      0,
      rightSpacing,
      style: _line.style,
    );
  }
}
