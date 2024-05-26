import 'package:dt/dt.dart';
import 'package:test/test.dart';

void main() {
  group('$AnsiParser', () {
    test('parses clearScreenBefore', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        clearScreenBefore: () {
          calls++;
        },
      );

      AnsiParser(listener).parse('\x1B[0J');
      expect(calls, 1);
    });

    test('parses clearScreenAfter', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        clearScreenAfter: () {
          calls++;
        },
      );

      AnsiParser(listener).parse('\x1B[1J');
      expect(calls, 1);
    });

    test('parses clearScreen', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        clearScreen: () {
          calls++;
        },
      );

      AnsiParser(listener).parse('\x1B[2J');
      expect(calls, 1);
    });

    test('parses clearLineBefore', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        clearLineBefore: () {
          calls++;
        },
      );

      AnsiParser(listener).parse('\x1B[0K');
      expect(calls, 1);
    });

    test('parses clearLineAfter', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        clearLineAfter: () {
          calls++;
        },
      );

      AnsiParser(listener).parse('\x1B[1K');
      expect(calls, 1);
    });

    test('parses clearLine', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        clearLine: () {
          calls++;
        },
      );

      AnsiParser(listener).parse('\x1B[2K');
      expect(calls, 1);
    });

    test('parses moveCursorHome', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        moveCursorHome: () {
          calls++;
        },
      );

      AnsiParser(listener).parse('\x1B[H');
      expect(calls, 1);
    });

    test('parses moveCursorTo', () {
      final calls = <Offset>[];
      final listener = AnsiListener.fromOrThrow(
        moveCursorTo: (x, y) {
          calls.add(Offset(x, y));
        },
      );

      AnsiParser(listener).parse('\x1B[3;4H');
      expect(calls, [Offset(3, 4)]);
    });

    test('parses moveCursorUp', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        moveCursorUp: (count) {
          calls += count;
        },
      );

      AnsiParser(listener).parse('\x1B[5A');
      expect(calls, 5);
    });

    test('parses moveCursorDown', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        moveCursorDown: (count) {
          calls += count;
        },
      );

      AnsiParser(listener).parse('\x1B[6B');
      expect(calls, 6);
    });

    test('parses moveCursorRight', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        moveCursorRight: (count) {
          calls += count;
        },
      );

      AnsiParser(listener).parse('\x1B[7C');
      expect(calls, 7);
    });

    test('parses moveCursorLeft', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        moveCursorLeft: (count) {
          calls += count;
        },
      );

      AnsiParser(listener).parse('\x1B[8D');
      expect(calls, 8);
    });

    test('parses moveCursorDownAndReturn', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        moveCursorDownAndReturn: (count) {
          calls += count;
        },
      );

      AnsiParser(listener).parse('\x1B[9E');
      expect(calls, 9);
    });

    test('parses moveCursorUpAndReturn', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        moveCursorUpAndReturn: (count) {
          calls += count;
        },
      );

      AnsiParser(listener).parse('\x1B[10F');
      expect(calls, 10);
    });

    test('parses moveCursorToColumn', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        moveCursorToColumn: (column) {
          calls = column;
        },
      );

      AnsiParser(listener).parse('\x1B[11G');
      expect(calls, 11);
    });

    test('parses write', () {
      final calls = <String>[];
      final listener = AnsiListener.fromOrThrow(
        write: calls.add,
      );

      AnsiParser(listener).parse('Hello World');
      expect(calls, ['Hello World']);
    });

    test('parses unknown', () {
      var calls = 0;

      final listener = AnsiListener.fromOrThrow(
        unknown: (code, count) {
          calls++;
        },
      );

      AnsiParser(listener).parse('\x1B[3J');
      expect(calls, 1);
    });

    test('parses interleaved', () {
      final calls = <String>[];
      final listener = AnsiListener.fromOrThrow(
        clearScreenBefore: () {
          calls.add('clearScreenBefore');
        },
        clearScreenAfter: () {
          calls.add('clearScreenAfter');
        },
        clearScreen: () {
          calls.add('clearScreen');
        },
        clearLineBefore: () {
          calls.add('clearLineBefore');
        },
        clearLineAfter: () {
          calls.add('clearLineAfter');
        },
        clearLine: () {
          calls.add('clearLine');
        },
        write: (text) {
          calls.add('write:$text');
        },
        unknown: (value, suffix) {
          calls.add('unknown:$value:${String.fromCharCode(suffix)}');
        },
      );

      AnsiParser(listener).parse(
        '\x1B[0J\x1B[1J\x1B[2J\x1B[0K\x1B[1K\x1B[2KHello World\x1B[3J',
      );
      expect(
        calls,
        [
          'clearScreenBefore',
          'clearScreenAfter',
          'clearScreen',
          'clearLineBefore',
          'clearLineAfter',
          'clearLine',
          'write:Hello World',
          'unknown:3:J',
        ],
      );
    });
  });
}
