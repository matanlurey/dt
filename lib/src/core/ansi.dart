import 'package:meta/meta.dart';

/// An ANSI escape code.
@immutable
sealed class AnsiEscape {
  const AnsiEscape();

  static const _$A = 0x41;
  static const _$B = 0x42;
  static const _$C = 0x43;
  static const _$D = 0x44;
  static const _$E = 0x45;
  static const _$F = 0x46;
  static const _$G = 0x47;
  static const _$H = 0x48;
  static const _$J = 0x4A;
  static const _$K = 0x4B;
  static const _$f = 0x66;

  // Copied from https://github.com/chalk/ansi-regex/blob/main/index.js.
  static final _isAnsiEscape = RegExp(
    r'[\u001B\u009B][[\]()#;?]*(?:(?:(?:(?:;[-a-zA-Z\d\/#&.:=?%@~_]+)*|'
    r'[a-zA-Z\d]+(?:;[-a-zA-Z\d\/#&.:=?%@~_]*)*)?\u0007)|'
    r'(?:(?:\d{1,4}(?:;\d{0,4})*)?[\dA-PR-TZcf-nq-uy=><~]))',
  );
  static final _ansiMatchParts = RegExp(r'([\u001B]\[)(.*)(\w$)');

  /// Parses all ANSI escape codes from the given [text].
  ///
  /// This method is a default implementation of [AnsiParser].
  static Iterable<AnsiEscape> parseAll(String text) sync* {
    // Text could be any number of escapes and text interleaved.
    var start = 0;
    for (final match in _isAnsiEscape.allMatches(text)) {
      if (start < match.start) {
        yield AnsiText(text.substring(start, match.start));
      }
      yield parse(match.group(0)!);
      start = match.end;
    }

    // If there is any remaining text, then yield it as text.
    if (start < text.length) {
      yield AnsiText(text.substring(start));
    }
  }

  /// Parses a single ANSI escape code from the given [text].
  static AnsiEscape parse(String text) {
    // Does this text contain exactly one ANSI escape code?
    final match = _isAnsiEscape.firstMatch(text);

    // If not, then this text is not an ANSI escape code.
    if (match == null) {
      return AnsiText(text);
    }

    // Parse the ANSI escape code.
    final parts = _ansiMatchParts.matchAsPrefix(match.group(0)!)!;

    // Parse the value and suffix of the ANSI escape code.
    return _parse(parts.group(2)!, parts.group(3)!.codeUnitAt(0));
  }

  static AnsiEscape _parse(String value, int suffix) {
    switch (suffix) {
      case _$A:
        return AnsiMoveCursorUp(int.parse(value));
      case _$B:
        return AnsiMoveCursorDown(int.parse(value));
      case _$C:
        return AnsiMoveCursorRight(int.parse(value));
      case _$D:
        return AnsiMoveCursorLeft(int.parse(value));
      case _$E:
        return AnsiMoveCursorDownAndReturn(int.parse(value));
      case _$F:
        return AnsiMoveCursorUpAndReturn(int.parse(value));
      case _$G:
        return AnsiMoveCursorToColumn(int.parse(value));
      case _$H:
        final parts = value.split(';');
        if (parts.length == 2) {
          return AnsiMoveCursorTo(
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }
        return const AnsiMoveCursorHome();
      case _$f:
        final parts = value.split(';');
        return AnsiMoveCursorTo(
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      case _$J:
        switch (value) {
          case '0':
            return const AnsiClearScreenBefore();
          case '1':
            return const AnsiClearScreenAfter();
          case '2':
            return const AnsiClearScreen();
        }
      case _$K:
        switch (value) {
          case '0':
            return const AnsiClearLineBefore();
          case '1':
            return const AnsiClearLineAfter();
          case '2':
            return const AnsiClearLine();
        }
    }
    return AnsiUnknown(value, suffix);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnsiEscape &&
          runtimeType == other.runtimeType &&
          toEscapedString() == other.toEscapedString();

  @override
  int get hashCode => toEscapedString().hashCode;

  /// Returns as an encoded ANSI escape code.
  String toEscapedString();

  @mustBeOverridden
  @override
  String toString();
}

/// Clears the current line that the cursor is located on.
final class AnsiClearLine extends AnsiEscape {
  // ignore: public_member_api_docs
  const AnsiClearLine();

  @override
  String toEscapedString() => '\u001B[2K';

  @override
  String toString() => 'AnsiClearLine';
}

/// Clears the current line _after_ the cursor's position.
final class AnsiClearLineAfter extends AnsiEscape {
  // ignore: public_member_api_docs
  const AnsiClearLineAfter();

  @override
  String toEscapedString() => '\u001B[K';

  @override
  String toString() => 'AnsiClearLineAfter';
}

/// Clears the current line _before_ the cursor's position.
final class AnsiClearLineBefore extends AnsiEscape {
  // ignore: public_member_api_docs
  const AnsiClearLineBefore();

  @override
  String toEscapedString() => '\u001B[1K';

  @override
  String toString() => 'AnsiClearLineBefore';
}

/// Clears the screen.
final class AnsiClearScreen extends AnsiEscape {
  // ignore: public_member_api_docs
  const AnsiClearScreen();

  @override
  String toEscapedString() => '\u001B[2J';

  @override
  String toString() => 'AnsiClearScreen';
}

/// Clears the screen _after_ the cursor's position.
final class AnsiClearScreenAfter extends AnsiEscape {
  @literal
  // ignore: public_member_api_docs
  const AnsiClearScreenAfter();

  @override
  String toEscapedString() => '\u001B[0J';

  @override
  String toString() => 'AnsiClearScreenAfter';
}

/// Clears the screen _before_ the cursor's position.
final class AnsiClearScreenBefore extends AnsiEscape {
  @literal
  // ignore: public_member_api_docs
  const AnsiClearScreenBefore();

  @override
  String toEscapedString() => '\u001B[1J';

  @override
  String toString() => 'AnsiClearScreenBefore';
}

/// Move the cursor to home position `(0, 0)`.
final class AnsiMoveCursorHome extends AnsiEscape {
  @literal
  // ignore: public_member_api_docs
  const AnsiMoveCursorHome();

  @override
  String toEscapedString() => '\u001B[H';

  @override
  String toString() => 'AnsiMoveCursorHome';
}

/// Move the cursor the given [line] and [column] position.
final class AnsiMoveCursorTo extends AnsiEscape {
  /// Creates a new ANSI escape code to move the
  @literal
  const AnsiMoveCursorTo(this.line, this.column);

  /// The line to move the cursor to.
  final int line;

  /// The column to move the cursor to.
  final int column;

  @override
  String toEscapedString() => '\u001B[$line;${column}H';

  @override
  String toString() => 'AnsiMoveCursorTo($line, $column)';
}

/// Move the cursor up [count] lines.
final class AnsiMoveCursorUp extends AnsiEscape {
  /// Creates a new ANSI escape code to move the cursor up by [count] lines.
  @literal
  const AnsiMoveCursorUp(this.count);

  /// The number of lines to move the cursor up.
  final int count;

  @override
  String toEscapedString() => '\u001B[${count}A';

  @override
  String toString() => 'AnsiMoveCursorUp($count)';
}

/// Move the cursor down [count] lines.
final class AnsiMoveCursorDown extends AnsiEscape {
  /// Creates a new ANSI escape code to move the cursor down by [count] lines.
  @literal
  const AnsiMoveCursorDown(this.count);

  /// The number of lines to move the cursor down.
  final int count;

  @override
  String toEscapedString() => '\u001B[${count}B';

  @override
  String toString() => 'AnsiMoveCursorDown($count)';
}

/// Move the cursor right [count] columns.
final class AnsiMoveCursorRight extends AnsiEscape {
  @literal

  /// Creates a new ANSI escape code to move the cursor right by [count] columns.
  const AnsiMoveCursorRight(this.count);

  /// The number of columns to move the cursor right.
  final int count;

  @override
  String toEscapedString() => '\u001B[${count}C';

  @override
  String toString() => 'AnsiMoveCursorRight($count)';
}

/// Move the cursor left [count] columns.
final class AnsiMoveCursorLeft extends AnsiEscape {
  /// Creates a new ANSI escape code to move the cursor left by [count] columns.
  @literal
  const AnsiMoveCursorLeft(this.count);

  /// The number of columns to move the cursor left.
  final int count;

  @override
  String toEscapedString() => '\u001B[${count}D';

  @override
  String toString() => 'AnsiMoveCursorLeft($count)';
}

/// Move the cursor to the beginning of [count] lines down.
final class AnsiMoveCursorDownAndReturn extends AnsiEscape {
  /// Creates a new ANSI escape code to move the cursor down and return.
  @literal
  const AnsiMoveCursorDownAndReturn(this.count);

  /// The number of lines to move the cursor down.
  final int count;

  @override
  String toEscapedString() => '\u001B[${count}E';

  @override
  String toString() => 'AnsiMoveCursorDownAndReturn($count)';
}

/// Move the cursor to the beginning of [count] lines up.
final class AnsiMoveCursorUpAndReturn extends AnsiEscape {
  /// Creates a new ANSI escape code to move the cursor up and return.
  @literal
  const AnsiMoveCursorUpAndReturn(this.count);

  /// The number of lines to move the cursor up.
  final int count;

  @override
  String toEscapedString() => '\u001B[${count}F';

  @override
  String toString() => 'AnsiMoveCursorUpAndReturn($count)';
}

/// Move the cursor to the given [column] position.
final class AnsiMoveCursorToColumn extends AnsiEscape {
  /// Creates a new ANSI escape code to move the cursor to the given column.
  @literal
  const AnsiMoveCursorToColumn(this.column);

  /// The column to move the cursor to.
  final int column;

  @override
  String toEscapedString() => '\u001B[${column}G';

  @override
  String toString() => 'AnsiMoveCursorToColumn($column)';
}

/// An unknown ANSI escape code.
final class AnsiUnknown extends AnsiEscape {
  /// Creates a new ANSI escape code with the given value and suffix.
  @literal
  const AnsiUnknown(this.value, this.suffix);

  /// The value of the unknown escape code.
  final String value;

  /// The suffix of the unknown escape code.
  final int suffix;

  @override
  String toEscapedString() => '\u001B[$value$suffix';

  @override
  String toString() => 'AnsiUnknown($value, $suffix)';
}

/// Text that does not contain any ANSI control sequences.
final class AnsiText extends AnsiEscape {
  /// Creates a new ANSI text escape code with the given text
  @literal
  const AnsiText(this.text);

  /// The text that does not contain any ANSI control sequences.
  final String text;

  @override
  String toEscapedString() => text;

  @override
  String toString() => 'AnsiText($text)';
}

/// A method that handles ANSI control sequences.
typedef AnsiHandler<T> = T Function(AnsiEscape escape);

/// A method that parses ANSI control sequences.
///
/// A default implementation is provided by [AnsiEscape.parseAll].
typedef AnsiParser = Iterable<AnsiEscape> Function(String text);
