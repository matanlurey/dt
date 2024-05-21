import 'package:dt/dt.dart';
import 'package:test/test.dart';

void main() {
  group('$StringTerminalBuffer', () {
    test('starts empty', () {
      final buffer = StringTerminalBuffer();

      // Contents.
      expect(buffer.isEmpty, isTrue);
      expect(buffer.isNotEmpty, isFalse);
      expect(buffer.lines, <String>[]);
      expect(buffer.lineCount, 0);

      // Accessors.
      expect(() => buffer.line(0), throwsRangeError);
      expect(() => buffer[0], throwsRangeError);
      expect(() => buffer.currentLine, throwsRangeError);
      expect(buffer.lineAt(), isNull);

      // Cursor.
      expect(buffer.cursor, Cursor.zero);
      expect(buffer.firstPosition, Cursor.zero);
      expect(buffer.lastPosition, Cursor.zero);

      // toString.
      expect(buffer.toString(), 'TerminalBuffer <cursor: (0, 0), lines: 0>');
    });

    test('starts with an empty line', () {
      // This is meaningfully different from the previous test.
      final buffer = StringTerminalBuffer('');

      // Contents.
      expect(buffer.isEmpty, isFalse);
      expect(buffer.isNotEmpty, isTrue);
      expect(buffer.lines, <String>['']);
      expect(buffer.lineCount, 1);

      // Accessors.
      expect(buffer.line(0), '');
      expect(buffer[0], '');
      expect(buffer.currentLine, '');
      expect(buffer.lineAt(), '');

      // Cursor.
      expect(buffer.cursor, Cursor.zero);
      expect(buffer.firstPosition, Cursor.zero);
      expect(buffer.lastPosition, Cursor.zero);
    });

    test('starts with a single line', () {
      final buffer = StringTerminalBuffer('Hello World!');

      // Contents.
      expect(buffer.lines, ['Hello World!']);
      expect(buffer.lineCount, 1);

      // Accessors.
      expect(buffer.line(0), 'Hello World!');
      expect(buffer[0], 'Hello World!');
      expect(buffer.currentLine, 'Hello World!');
      expect(buffer.lineAt(), 'Hello World!');

      // Cursor.
      expect(buffer.cursor, Cursor(12, 0));
      expect(buffer.firstPosition, Cursor.zero);
      expect(buffer.lastPosition, Cursor(12, 0));
    });

    test('starts with multiple lines', () {
      final buffer = StringTerminalBuffer('Hello\nWorld!');

      // Contents.
      expect(buffer.lines, ['Hello', 'World!']);
      expect(buffer.lineCount, 2);

      // Accessors.
      expect(buffer.line(0), 'Hello');
      expect(buffer[0], 'Hello');
      expect(buffer.line(1), 'World!');
      expect(buffer[1], 'World!');
      expect(buffer.currentLine, 'World!');
      expect(buffer.lineAt(), 'World!');

      // Cursor.
      expect(buffer.cursor, Cursor(6, 1));
      expect(buffer.firstPosition, Cursor.zero);
      expect(buffer.lastPosition, Cursor(6, 1));
    });

    test('new spans are written', () {
      final buffer = StringTerminalBuffer();

      // Write a span.
      buffer.write('Hello');

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Hello']);
      expect(buffer.currentLine, 'Hello');
      expect(buffer.cursor, Cursor(5, 0));

      // Write another span.
      buffer.write(' World!');

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Hello World!']);
      expect(buffer.currentLine, 'Hello World!');
      expect(buffer.cursor, Cursor(12, 0));
    });

    test('new lines are written', () {
      final buffer = StringTerminalBuffer();

      // Write a line.
      buffer.writeLine('Hello');

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Hello', '']);
      expect(buffer.currentLine, '');
      expect(buffer.cursor, Cursor(0, 1));

      // Write another line.
      buffer.writeLine('World!');

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Hello', 'World!', '']);
      expect(buffer.currentLine, '');
      expect(buffer.cursor, Cursor(0, 2));
    });

    test('write multiple spans', () {
      final buffer = StringTerminalBuffer();

      // Write multiple spans that do not contain newlines.
      buffer.writeAll(['Hello', ' World!']);

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Hello World!']);
      expect(buffer.currentLine, 'Hello World!');
      expect(buffer.cursor, Cursor(12, 0));
    });

    test('write multple spans with a separator', () {
      final buffer = StringTerminalBuffer();

      // Write multiple spans that do not contain newlines.
      buffer.writeAll(['Apples', 'Oranges'], separator: ', ');

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Apples, Oranges']);
      expect(buffer.currentLine, 'Apples, Oranges');
      expect(buffer.cursor, Cursor(15, 0));
    });

    test('write multiple spans that include new-line characters', () {
      final buffer = StringTerminalBuffer();

      // Write multiple spans that contain newlines.
      buffer.writeAll(['Hello\n', 'World!']);

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Hello', 'World!']);
      expect(buffer.currentLine, 'World!');
      expect(buffer.cursor, Cursor(6, 1));
    });

    test('write multiple spans with a separator that includes newlines', () {
      final buffer = StringTerminalBuffer();

      // Write multiple spans that contain newlines.
      buffer.writeAll(['Apples', 'Oranges'], separator: '\n');

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Apples', 'Oranges']);
      expect(buffer.currentLine, 'Oranges');
      expect(buffer.cursor, Cursor(7, 1));
    });

    test('write multiple lines', () {
      final buffer = StringTerminalBuffer();

      // Write multiple lines.
      buffer.writeLines(['Hello', 'World!']);

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Hello', 'World!', '']);
      expect(buffer.currentLine, '');
      expect(buffer.cursor, Cursor(0, 2));
    });

    test('write multiple lines with a separator', () {
      final buffer = StringTerminalBuffer();

      // Write multiple lines.
      buffer.writeLines(['Apples', 'Oranges'], separator: ' and');

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Apples and', 'Oranges', '']);
      expect(buffer.currentLine, '');
      expect(buffer.cursor, Cursor(0, 2));
    });

    test('write multiple lines with a separator that includes newlines', () {
      final buffer = StringTerminalBuffer();

      // Write multiple lines.
      buffer.writeLines(['Apples', 'Oranges'], separator: '\n');

      // Spot check the contents, current line, and cursor position.
      expect(buffer.lines, ['Apples', '', 'Oranges', '']);
      expect(buffer.currentLine, '');
      expect(buffer.cursor, Cursor(0, 3));
    });
  });
}
