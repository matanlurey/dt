import 'package:meta/meta.dart';

import '../foundation/sequence.dart';

/// An interface for a command that performs an action on a terminal.
///
/// A set of built-in commands are provided and it is rare to need to create a
/// custom command; however, it is possible to create a custom command by
/// implementing this interface.
@immutable
abstract mixin class Command {
  /// Parses an escape sequence into a _command_.
  static Command? tryParse(Sequence sequence) {
    if (sequence is! EscapeSequence) {
      return null;
    }
    if (sequence.prefix == '?') {
      return switch (sequence.finalChars) {
        'h' => switch (sequence.parameters) {
            [25] => SetCursorVisibility.visible,
            [1049] => AlternateScreenBuffer.enter,
            [2026] => SynchronizedUpdate.start,
            _ => null,
          },
        'l' => switch (sequence.parameters) {
            [25] => SetCursorVisibility.hidden,
            [1049] => AlternateScreenBuffer.leave,
            [2026] => SynchronizedUpdate.end,
            _ => null,
          },
        _ => null,
      };
    }
    return switch (sequence.finalChars) {
      'H' => switch (sequence.parameters) {
          [final int row, final int column] => MoveCursorTo(row, column),
          [final int row] => MoveCursorTo(row),
          [] => MoveCursorTo(),
          _ => null,
        },
      'G' => switch (sequence.parameters) {
          [final int column] => MoveCursorToColumn(column),
          [] => MoveCursorToColumn(),
          _ => null,
        },
      'J' => switch (sequence.parameters) {
          [0] || [] => ClearScreen.all,
          [1] => ClearScreen.fromCursorDown,
          [2] => ClearScreen.fromCursorUp,
          [3] => ClearScreen.allAndScrollback,
          _ => null,
        },
      'K' => switch (sequence.parameters) {
          [0] || [] => ClearScreen.toEndOfLine,
          [2] => ClearScreen.currentLine,
          _ => null,
        },
      'm' => switch (sequence.parameters) {
          [38, 5, final int color] => SetForegroundColor256(color),
          [48, 5, final int color] => SetBackgroundColor256(color),
          [final int color] => SetColor16(color),
          _ => null,
        },
      _ => null,
    };
  }

  /// A command that does nothing and returns [Sequence.none] when rendered.
  ///
  /// This command is useful when you want to represent a no-op command.
  ///
  /// **NOTE**: This command is _never_ returned by [tryParse].
  static const Command none = _NullCommand();

  // ignore: public_member_api_docs
  const Command();

  @override
  bool operator ==(Object other) {
    if (other is! Command || other.runtimeType != runtimeType) {
      return false;
    }
    return toSequence() == other.toSequence();
  }

  @override
  int get hashCode => toSequence().hashCode;

  /// Returns the ANSI escape sequence for this command.
  Sequence toSequence();
}

/// A command that does nothing.
final class _NullCommand extends Command {
  const _NullCommand();

  @override
  Sequence toSequence() => Sequence.none;
}

/// Moves the terminal cursor to the given position (row, column).
///
/// The top-left cell is represented as `(1, 1)`.
final class MoveCursorTo extends Command {
  /// Creates a move cursor to command.
  ///
  /// The [row] and [column] must be positive.
  const MoveCursorTo([
    int row = 1,
    int column = 1,
  ])  : row = row < 1 ? 1 : row,
        column = column < 1 ? 1 : column;

  /// The row to move the cursor to.
  final int row;

  /// The column to move the cursor to.
  final int column;

  @override
  Sequence toSequence() {
    return EscapeSequence(
      'H',
      parameters: [row, column],
      defaults: const [1, 1],
    );
  }

  @override
  String toString() {
    return 'MoveCursorTo($row:$column)';
  }
}

/// Moves the terminal cursor to the given column.
///
/// The left-most column is represented as `0`.
final class MoveCursorToColumn extends Command {
  /// Creates a move cursor to column command.
  ///
  /// The [column] must be positive.
  const MoveCursorToColumn([
    int column = 1,
  ]) : column = column < 1 ? 1 : column;

  /// The column to move the cursor to.
  final int column;

  @override
  Sequence toSequence() {
    return EscapeSequence(
      'G',
      parameters: [column],
      defaults: const [1],
    );
  }

  @override
  String toString() {
    return 'MoveCursorToColumn($column)';
  }
}

/// Sets the cursor visibility.
enum SetCursorVisibility implements Command {
  /// Sets the cursor visibility to visible.
  visible(
    EscapeSequence.unchecked('h', prefix: '?', parameters: [25]),
  ),

  /// Sets the cursor visibility to hidden.
  hidden(
    EscapeSequence.unchecked('l', prefix: '?', parameters: [25]),
  );

  const SetCursorVisibility(this._sequence);
  final EscapeSequence _sequence;

  @override
  Sequence toSequence() => _sequence;
}

/// Clears the terminal screen buffer.
///
/// Note that the cursor is _not_ moved as a result of this command.
enum ClearScreen implements Command {
  /// Clears the entire screen.
  all(
    EscapeSequence.unchecked('J', parameters: [0], defaults: [0]),
  ),

  /// Clears the entire screen and the scrollback buffer.
  allAndScrollback(
    EscapeSequence.unchecked('J', parameters: [3], defaults: [0]),
  ),

  /// Clears the screen from the cursor down.
  fromCursorDown(
    EscapeSequence.unchecked('J', parameters: [1], defaults: [0]),
  ),

  /// Clears the screen from the cursor up.
  fromCursorUp(
    EscapeSequence.unchecked('J', parameters: [2], defaults: [0]),
  ),

  /// Clears the current line.
  currentLine(
    EscapeSequence.unchecked('K', parameters: [2], defaults: [0]),
  ),

  /// Clears the line from the cursor to the end of the line.
  toEndOfLine(
    EscapeSequence.unchecked('K', parameters: [0], defaults: [0]),
  );

  const ClearScreen(this._sequence);
  final EscapeSequence _sequence;

  @override
  Sequence toSequence() => _sequence;
}

/// Enters or leaves the alternate screen buffer.
enum AlternateScreenBuffer implements Command {
  /// Enters the alternate screen buffer.
  enter(
    EscapeSequence.unchecked('h', prefix: '?', parameters: [1049]),
  ),

  /// Leaves the alternate screen buffer.
  leave(
    EscapeSequence.unchecked('l', prefix: '?', parameters: [1049]),
  );

  const AlternateScreenBuffer(this._sequence);
  final EscapeSequence _sequence;

  @override
  Sequence toSequence() => _sequence;
}

/// Instructs the terminal to start or end a synchronized update.
///
/// A synchronized update is a way to prevent the terminal from rendering
/// intermediate states of a complex update. For example, if you are updating
/// multiple lines of text, you can start a synchronized update, update all the
/// lines, and then end the synchronized update. This will prevent the terminal
/// from rendering the intermediate states of the update.
///
/// **NOTE**: Not all terminals support synchronized updates.
enum SynchronizedUpdate implements Command {
  /// Starts a synchronized update.
  start(
    EscapeSequence.unchecked('h', prefix: '?', parameters: [2026]),
  ),

  /// Ends a synchronized update.
  end(
    EscapeSequence.unchecked('l', prefix: '?', parameters: [2026]),
  );

  const SynchronizedUpdate(this._sequence);
  final EscapeSequence _sequence;

  @override
  Sequence toSequence() => _sequence;
}

/// Sets either the foreground or background color to one of 16 colors.
final class SetColor16 extends Command {
  /// Resets the foreground color to the default color.
  static const resetForeground = SetColor16(39);

  /// Resets the background color to the default color.
  static const resetBackground = SetColor16(49);

  /// Resets both colors and all text attributes to the default.
  static const resetStyle = SetColor16(0);

  /// Creates a set color command.
  const SetColor16(this.color);

  /// The color code that signifies the layer and color to set.
  final int color;

  @override
  Sequence toSequence() {
    return EscapeSequence('m', parameters: [color]);
  }

  @override
  String toString() {
    return 'SetColor16${switch (this) {
      resetForeground => '.resetForeground',
      resetBackground => '.resetBackground',
      resetStyle => '.resetStyle',
      _ => '($color)',
    }}';
  }
}

/// Resets both colors and all text attributes to the default.
///
/// An alias for [SetColor16.resetStyle].
const Command resetStyle = SetColor16.resetStyle;

/// Sets the foreground color to one of the 256 colors.
///
/// This command is compatible with both 4-bit and 8-bit color terminals, where
/// the [color] is a value between `0` and `255`, inclusive. Any value outside
/// this range will be clamped to the nearest valid value.
final class SetForegroundColor256 extends Command {
  /// Resets the foreground color to the default color.
  ///
  /// An alias for [SetColor16.resetForeground].
  static const Command reset = SetColor16.resetForeground;

  /// Creates a set foreground color command.
  ///
  /// The [color] must be between `0` and `255`, inclusive.
  const SetForegroundColor256(int color) : color = 0xFF & color;

  /// The color to set the foreground to.
  final int color;

  @override
  Sequence toSequence() {
    return EscapeSequence('m', parameters: [38, 5, color]);
  }

  @override
  String toString() {
    return 'SetForegroundColor256(0x${color.toRadixString(16)})';
  }
}

/// Sets the background color to one of the 256 colors.
///
/// This command is compatible with both 4-bit and 8-bit color terminals, where
/// the [color] is a value between `0` and `255`, inclusive. Any value outside
/// this range will be clamped to the nearest valid value.
final class SetBackgroundColor256 extends Command {
  /// Resets the background color to the default color.
  ///
  /// An alias for [SetColor16.resetBackground].
  static const reset = SetColor16.resetBackground;

  /// Creates a set background color command.
  ///
  /// The [color] must be between `0` and `255`, inclusive.
  const SetBackgroundColor256(int color) : color = 0xFF & color;

  /// The color to set the background to.
  final int color;

  @override
  Sequence toSequence() {
    return EscapeSequence('m', parameters: [48, 5, color]);
  }

  @override
  String toString() {
    return 'SetBackgroundColor256(0x${color.toRadixString(16)})';
  }
}
