import 'package:dt/rendering.dart';

import 'command.dart';

/// Provides conversion from a [Color] to ANSI escape sequences.
extension AnsiEscapedColor on Color {
  /// Returns a command that represents setting the foreground color to `this`.
  Command setForeground() {
    switch (this) {
      case Color.inherit:
        return Command.none;
      case Color.reset:
        return SetColor16.resetForeground;
      case final Color16 c:
        return SetColor16(c.foregroundIndex);
      default:
        return Command.none;
    }
  }

  /// Returns a command that represents setting the background color to `this`.
  Command setBackground() {
    switch (this) {
      case Color.inherit:
        return Command.none;
      case Color.reset:
        return SetColor16.resetBackground;
      case final Color16 c:
        return SetColor16(c.backgroundIndex);
      default:
        return Command.none;
    }
  }
}

/// Provides utilities for working with 16-color ANSI escape sequences.
extension AnsiEscapedColor16 on Color16 {
  /// Returns the ANSI index for the foreground color.
  int get foregroundIndex => isBright ? index - 8 + 90 : index + 30;

  /// Returns the ANSI index for the background color.
  int get backgroundIndex => isBright ? index - 8 + 100 : index + 40;
}
