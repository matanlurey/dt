import 'package:meta/meta.dart';

import 'command.dart';

/// A sealed type representing multiple types of colors.
@immutable
sealed class Color {
  /// A command that resets the color to the default.
  static const Color reset = _ResetColor();

  /// A convenience constant for inheriting the color from the parent.
  static const Color inherit = _InheritedColor();

  const Color();

  /// Returns a command that sets the foreground color to this color.
  Command setForeground();

  /// Returns a command that sets the background color to this color.
  Command setBackground();
}

final class _InheritedColor extends Color {
  @literal
  const _InheritedColor();

  @override
  Command setForeground() => Command.none;

  @override
  Command setBackground() => Command.none;

  @override
  String toString() => 'Color.inherit';
}

/// Represents just resetting the _color_ (not all styles) to the default.
///
/// This is useful when you want to reset the color to the default without
/// affecting other styles like bold, italic, underline, etc.
///
/// See [Color.reset] for a singleton instance of this type.
final class _ResetColor extends Color {
  @literal
  const _ResetColor();

  @override
  Command setForeground() => const SetForegroundColor256(39);

  @override
  Command setBackground() => const SetBackgroundColor256(49);

  @override
  String toString() => 'Color.reset';
}

/// 4-bit ANSI color palette that includes 8 basic colors and 8 bright colors.
enum AnsiColor implements Color {
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
  AnsiColor toDim() => isDim ? this : AnsiColor.values[index - 8];

  /// Returns the bright version of this color.
  ///
  /// If this color is already bright, it is returned as-is.
  AnsiColor toBright() => isBright ? this : AnsiColor.values[index + 8];

  static const _dimForegroundOffset = 30;
  static const _brightForegroundOffset = 90;

  @override
  Command setForeground() {
    return SetForegroundColor256(
      index + (isBright ? _brightForegroundOffset : _dimForegroundOffset),
    );
  }

  static const _dimBackgroundOffset = 40;
  static const _brightBackgroundOffset = 100;

  @override
  Command setBackground() {
    return SetBackgroundColor256(
      index + (isBright ? _brightBackgroundOffset : _dimBackgroundOffset),
    );
  }
}
