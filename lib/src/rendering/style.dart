import 'package:meta/meta.dart';

import 'color.dart';

/// Control over the visual appearance of displayed elements.
@immutable
final class Style {
  /// Inherit the style from the parent element.
  static const inherit = Style();

  /// Reset the style to the default.
  static const reset = Style(foreground: Color.reset, background: Color.reset);

  /// Creates a new default style.
  const Style({
    this.foreground = Color.inherit,
    this.background = Color.inherit,
  });

  /// Which color to use the foreground.
  ///
  /// If `null`, the color will be inherited from the parent element.
  final Color foreground;

  /// Which color to use the background.
  ///
  /// If `null`, the color will be inherited from the parent element.
  final Color background;

  /// Returns a copy of this style with the given properties.
  ///
  /// If no arguments are provided, the current style is returned.
  Style copyWith({
    Color? foreground,
    Color? background,
  }) {
    return Style(
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
    );
  }

  /// Returns a new style with the properties of [other] overriding this style.
  ///
  /// `other.*.inherit` is ignored and the current value is used instead.
  Style overrideWith(Style other) {
    return copyWith(
      foreground: other.foreground == Color.inherit ? null : other.foreground,
      background: other.background == Color.inherit ? null : other.background,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Style) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return foreground == other.foreground && background == other.background;
  }

  @override
  int get hashCode => Object.hash(foreground, background);

  @override
  String toString() {
    if (this == inherit) {
      return 'Style.inherit';
    }
    return 'Style(foreground: $foreground, background: $background)';
  }
}
