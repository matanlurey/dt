import 'package:meta/meta.dart';

import 'alignment.dart';
import 'span.dart';
import 'style.dart';

/// A line of text, consisting of one or more [Span]s.
@immutable
final class Line {
  /// An empty line with no spans, inheriting style and alignment.
  static const empty = Line._([], Style.reset, Alignment.left);

  /// Creates a new line of text with the given text content.
  ///
  /// Optionally, a [style] and [alignment] can be provided to set, otherwise
  /// a default style and alignment will be used by inheriting from the parent
  /// element.
  Line(
    Iterable<String> spans, {
    Style style = Style.reset,
    Alignment alignment = Alignment.left,
  }) : this.fromSpans(
          spans.map((span) => Span(span, Style.none)),
          style: style,
          alignment: alignment,
        );

  /// Creates a new line of text with the given [spans].
  ///
  /// Optionally, a [style] and [alignment] can be provided to set, otherwise
  /// a default style and alignment will be used by inheriting from the parent
  /// element.
  Line.fromSpans(
    Iterable<Span> spans, {
    Style style = Style.reset,
    Alignment alignment = Alignment.left,
  }) : this._(
          List.unmodifiable(spans),
          style,
          alignment,
        );

  const Line._(this.spans, this.style, this.alignment);

  /// Spans that make up this line of text.
  ///
  /// Each span represents a contiguous part of the line with the same style.
  ///
  /// This list is unmodifiable and cannot be changed.
  final List<Span> spans;

  /// Style of this line of text.
  ///
  /// This style makes up the default style for all spans in this line, which
  /// can be further overridden by individual spans. If a span does not specify
  /// a style, this style will be used.
  final Style style;

  /// Alignment of this line of text.
  final Alignment alignment;

  /// Returns a copy of this line with the given properties.
  ///
  /// If no arguments are provided, the current line is returned.
  Line copyWith({
    Iterable<Span>? spans,
    Style? style,
    Alignment? alignment,
  }) {
    return Line.fromSpans(
      spans ?? this.spans,
      style: style ?? this.style,
      alignment: alignment ?? this.alignment,
    );
  }

  /// Combined width of the spans in this line.
  int get width => spans.fold(0, (width, span) => width + span.width);

  /// Returns a new line with [span] appended to the end.
  @useResult
  Line append(Span span) {
    return Line.fromSpans(
      [...spans, span],
      style: style,
      alignment: alignment,
    );
  }

  /// An alias for [append].
  @useResult
  Line operator +(Span span) => append(span);

  @override
  bool operator ==(Object other) {
    if (other is! Line || other.spans.length != spans.length) {
      return false;
    }
    if (other.style != style || other.alignment != alignment) {
      return false;
    }
    for (var i = 0; i < spans.length; i++) {
      if (other.spans[i] != spans[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(spans), style, alignment);

  @override
  String toString() {
    return 'Line($spans, style: $style, alignment: $alignment)';
  }
}
