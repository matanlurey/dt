import 'package:meta/meta.dart';

/// A sealed type representing multiple types of colors.
@immutable
sealed class Color {
  /// A command that resets the color to the default.
  static const Color reset = _ResetColor();

  /// A convenience constant for inheriting the color from the parent.
  static const Color inherit = _InheritedColor();

  const Color();
}

final class _InheritedColor extends Color {
  @literal
  const _InheritedColor();

  @override
  String toString() => 'Color.inherit';
}

final class _ResetColor extends Color {
  @literal
  const _ResetColor();

  @override
  String toString() => 'Color.reset';
}

/// 4-bit ANSI color palette that includes 8 basic colors and 8 bright colors.
enum Color16 implements Color {
  /// ANSI color `black`.
  ///
  /// Represented by `#000000` in xterm.
  black,

  /// ANSI color `red`.
  ///
  /// Represented by `#800000` in xterm.
  red,

  /// ANSI color `green`.
  ///
  /// Represented by `#008000` in xterm.
  green,

  /// ANSI color `yellow`.
  ///
  /// Represented by `#808000` in xterm.
  yellow,

  /// ANSI color `blue`.
  ///
  /// Represented by `#000080` in xterm.
  blue,

  /// ANSI color `magenta`.
  ///
  /// Represented by `#800080` in xterm.
  magenta,

  /// ANSI color `cyan`.
  ///
  /// Represented by `#008080` in xterm.
  cyan,

  /// ANSI color `white`.
  ///
  /// Represented by `#c0c0c0` in xterm.
  white,

  /// ANSI color `brightBlack`.
  ///
  /// Represented by `#808080` in xterm.
  brightBlack,

  /// ANSI color `brightRed`.
  ///
  /// Represented by `#ff0000` in xterm.
  brightRed,

  /// ANSI color `brightGreen`.
  ///
  /// Represented by `#00ff00` in xterm.
  brightGreen,

  /// ANSI color `brightYellow`.
  ///
  /// Represented by `#ffff00` in xterm.
  brightYellow,

  /// ANSI color `brightBlue`.
  ///
  /// Represented by `#0000ff` in xterm.
  brightBlue,

  /// ANSI color `brightMagenta`.
  ///
  /// Represented by `#ff00ff` in xterm.
  brightMagenta,

  /// ANSI color `brightCyan`.
  ///
  /// Represented by `#00ffff` in xterm.
  brightCyan,

  /// ANSI color `brightWhite`.
  ///
  /// Represented by `#ffffff` in xterm.
  brightWhite;

  /// Convenience constant for resetting the color to the default.
  static const Color reset = Color.reset;

  /// Convenience constant for inheriting the color from the parent.
  static const Color inherit = Color.inherit;

  /// Whether this color is a dim color.
  bool get isDim => index < 8;

  /// Whether this color is a bright color.
  bool get isBright => index >= 8;

  /// Returns the dim version of this color.
  ///
  /// If this color is already dim, it is returned as-is.
  Color16 toDim() => isDim ? this : Color16.values[index - 8];

  /// Returns the bright version of this color.
  ///
  /// If this color is already bright, it is returned as-is.
  Color16 toBright() => isBright ? this : Color16.values[index + 8];
}
