import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import 'line.dart';
import 'style.dart';

/// Represents part of a line that is continguous and styled the same way.
///
/// A [Span] is the smallest unit of text that can be styled, and usually
/// combined in the [Line] type to represent a line of text where each [Span]
/// may have a different style.
@immutable
final class Span {
  /// An empty span with no content and no style.
  static const empty = Span();

  /// Creates a new span with the given [content] and optional [style].
  const Span([this.content = '', this.style = Style.inherit]);

  /// Content of the span.
  ///
  /// It is assumed that the content will be displayed as-is, and no further
  /// processing will be done on it. That is, escape sequences and other
  /// special characters will be displayed as-is in the final output.
  final String content;

  /// Style of the span.
  final Style style;

  /// Returns a copy of this span with the given [content] and [style].
  ///
  /// If no arguments are provided, the current span is returned.
  Span copyWith({String? content, Style? style}) {
    return Span(content ?? this.content, style ?? this.style);
  }

  /// Unicode width of the content held by this span.
  ///
  /// This is calculated by summing the width of each rune in the content.
  int get width {
    return content.characters.length;
  }

  @override
  bool operator ==(Object other) {
    return other is Span && other.content == content && other.style == style;
  }

  @override
  int get hashCode => Object.hash(content, style);

  @override
  String toString() {
    if (this == empty) {
      return 'Span.empty';
    }
    return 'Span("$content", $style)';
  }
}
