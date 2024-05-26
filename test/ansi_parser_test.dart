import 'package:dt/src/core/ansi.dart';
import 'package:test/test.dart';

void main() {
  group('$AnsiEscape.parse', () {
    test('parses clearScreenBefore', () {
      final escape = const AnsiClearScreenBefore();
      expect(escape.toEscapedString(), escape);
    });

    test('parses clearScreenAfter', () {
      final escape = const AnsiClearScreenAfter();
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses clearScreen', () {
      final escape = const AnsiClearScreen();
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses clearLineBefore', () {
      final escape = const AnsiClearLineBefore();
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses clearLineAfter', () {
      final escape = const AnsiClearLineAfter();
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses clearLine', () {
      final escape = const AnsiClearLine();
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses moveCursorHome', () {
      final escape = const AnsiMoveCursorHome();
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses moveCursorTo', () {
      final escape = const AnsiMoveCursorTo(1, 2);
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses moveCursorUp', () {
      final escape = const AnsiMoveCursorUp(3);
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses moveCursorDown', () {
      final escape = const AnsiMoveCursorDown(4);
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses moveCursorRight', () {
      final escape = const AnsiMoveCursorRight(5);
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses moveCursorLeft', () {
      final escape = const AnsiMoveCursorLeft(6);
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses moveCursorDownAndReturn', () {
      final escape = const AnsiMoveCursorDownAndReturn(7);
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses moveCursorUpAndReturn', () {
      final escape = const AnsiMoveCursorUpAndReturn(8);
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses moveCursorToColumn', () {
      final escape = const AnsiMoveCursorToColumn(9);
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses non-escaped text', () {
      final escape = const AnsiText('Hello World');
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses unknown', () {
      final escape = AnsiUnknown('3', 'J'.codeUnitAt(0));
      expect(AnsiEscape.parse(escape.toEscapedString()), escape);
    });

    test('parses interleaved', () {
      final calls = AnsiEscape.parseAll(
        '\x1B[2J\x1B[0J\x1B[1J\x1B[2J\x1B[0J\x1B[1JHello World\x1B[3J',
      );
      expect(
        calls,
        [
          const AnsiClearScreen(),
          const AnsiClearScreenBefore(),
          const AnsiClearScreenAfter(),
          const AnsiClearScreen(),
          const AnsiClearScreenBefore(),
          const AnsiClearScreenAfter(),
          const AnsiText('Hello World'),
          AnsiUnknown('3', 'J'.codeUnitAt(0)),
        ],
      );
    });
  });
}
