// ignore_for_file: cascade_invocations

import 'package:dt/dt.dart';
import 'package:test/test.dart';

void main() {
  group('$Terminal', () {
    test('starts at the beginning', () {
      final terminal = Terminal();

      expect(terminal.cursorX, 0);
      expect(terminal.cursorY, 0);
      expect(terminal.lines, ['']);
    });

    test('writes some text', () {
      final terminal = Terminal()..write('Hello, World!');

      expect(terminal.cursorX, 13);
      expect(terminal.cursorY, 0);
      expect(terminal.lines, ['Hello, World!']);
    });

    test('writes some text and then some more', () {
      final terminal = Terminal('Hello');
      expect(terminal.cursorX, 5);
      expect(terminal.cursorY, 0);
      expect(terminal.lines, ['Hello']);

      terminal.write(' World!');
      expect(terminal.cursorX, 12);
      expect(terminal.cursorY, 0);
      expect(terminal.lines, ['Hello World!']);
    });

    test('writes some multi-line text', () {
      final terminal = Terminal('Hello\nWorld!');
      expect(terminal.cursorX, 6);
      expect(terminal.cursorY, 1);
      expect(terminal.lines, ['Hello', 'World!']);

      terminal.write('\nGoodbye!');
      expect(terminal.cursorX, 8);
      expect(terminal.cursorY, 2);
      expect(terminal.lines, ['Hello', 'World!', 'Goodbye!']);
    });

    test('clears the line', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal.clearLine();
      expect(terminal.lines, ['Hello', '']);
      expect(terminal.cursorX, 0);
      expect(terminal.cursorY, 1);
    });

    test('clears the line after', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal
        ..cursorX = 3
        ..clearLineAfter();
      expect(terminal.lines, ['Hello', 'Wor']);
      expect(terminal.cursorX, 3);
      expect(terminal.cursorY, 1);
    });

    test('clears the line before', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal
        ..cursorX = 3
        ..clearLineBefore();
      expect(terminal.lines, ['Hello', 'ld!']);
      expect(terminal.cursorX, 0);
      expect(terminal.cursorY, 1);
    });

    test('clears the screen', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal.clearScreen();
      expect(terminal.lines, ['']);
      expect(terminal.cursorX, 0);
      expect(terminal.cursorY, 0);
    });

    test('clears the screen after, single line', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal
        ..cursorX = 3
        ..clearScreenAfter();
      expect(terminal.lines, ['Hello', 'Wor']);
      expect(terminal.cursorX, 3);
      expect(terminal.cursorY, 1);
    });

    test('clears the screen after, multiple lines', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal
        ..cursorX = 3
        ..cursorY = 0
        ..clearScreenAfter();
      expect(terminal.lines, ['Hel']);
      expect(terminal.cursorX, 3);
      expect(terminal.cursorY, 0);
    });

    test('clears the screen before, single line', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal
        ..cursorX = 3
        ..cursorY = 0
        ..clearScreenBefore();
      expect(terminal.lines, ['lo', 'World!']);
      expect(terminal.cursorX, 0);
      expect(terminal.cursorY, 0);
    });

    test('clears the screen before, multiple lines', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal
        ..cursorX = 3
        ..cursorY = 1
        ..clearScreenBefore();
      expect(terminal.lines, ['ld!']);
      expect(terminal.cursorX, 0);
      expect(terminal.cursorY, 0);
    });

    test('clears the screen after', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal
        ..cursorX = 3
        ..cursorY = 0
        ..clearScreenAfter();
      expect(terminal.lines, ['Hel']);
      expect(terminal.cursorX, 3);
      expect(terminal.cursorY, 0);
    });

    test('clears the scren after, multiple lines', () {
      final terminal = Terminal('Hello\nWorld!');

      terminal
        ..cursorX = 3
        ..cursorY = 0
        ..clearScreenAfter();
      expect(terminal.lines, ['Hel']);
      expect(terminal.cursorX, 3);
      expect(terminal.cursorY, 0);
    });
  });
}
