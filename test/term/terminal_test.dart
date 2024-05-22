import 'package:dt/src/core.dart';
import 'package:dt/src/term.dart';
import 'package:test/test.dart';

void main() {
  Terminal<String> terminal({
    List<String> lines = const [],
    Offset? cursor,
  }) {
    return Terminal(
      const StringSpan(),
      lines: lines,
      cursor: cursor,
    );
  }

  test('starts empty', () {
    final fixture = terminal();

    // Contents.
    expect(fixture.isEmpty, isTrue);
    expect(fixture.isNotEmpty, isFalse);
    expect(fixture.lineCount, 0);

    // Accessors.
    expect(() => fixture.line(0), throwsRangeError);
  });

  test('starts with an empty line', () {
    final fixture = terminal(lines: ['']);

    // Contents.
    expect(fixture.isEmpty, isFalse);
    expect(fixture.isNotEmpty, isTrue);
    expect(fixture.lineCount, 1);

    // Accessors.
    expect(fixture.line(0), '');
  });

  test('starts with a single line', () {
    final fixture = terminal(lines: ['Hello World!']);

    expect(fixture.lines, ['Hello World!']);
  });

  test('starts with multiple lines', () {
    final fixture = terminal(
      lines: [
        'Hello World!',
        'Goodbye World!',
      ],
    );

    expect(fixture.lines, [
      'Hello World!',
      'Goodbye World!',
    ]);
  });

  test('writing a span', () {
    final fixture = terminal();

    // Write a span.
    fixture.write('Hello World!');

    expect(fixture.lines, ['Hello World!']);
  });

  test('writing a line', () {
    final fixture = terminal();

    // Write a line.
    fixture.writeLine('Hello World!');

    expect(fixture.lines, ['Hello World!', '']);
  });

  test('writing multiple spans', () {
    final fixture = terminal();

    // Write multiple spans.
    fixture.writeAll([
      'Hello',
      'World!',
    ]);

    expect(fixture.lines, ['HelloWorld!']);
  });

  test('writing multiple spans with a separator', () {
    final fixture = terminal();

    // Write multiple spans with a separator.
    fixture.writeAll(
      [
        'Hello',
        'World!',
      ],
      separator: ' ',
    );

    expect(fixture.lines, ['Hello World!']);
  });

  test('writing multiple lines', () {
    final fixture = terminal();

    // Write multiple lines.
    fixture.writeLines([
      'Hello',
      'World!',
    ]);

    expect(fixture.lines, ['Hello', 'World!', '']);
  });

  test('writing multiple lines with a separator', () {
    final fixture = terminal();

    // Write multiple lines with a separator.
    fixture.writeLines(
      [
        'Hello',
        'World!',
      ],
      separator: ' ',
    );

    expect(fixture.lines, ['Hello ', 'World!', '']);
  });

  test('cursor starts at 0:0 in an empty fixture', () {
    final fixture = terminal();

    expect(fixture.cursor.offset, Offset(0, 0));
  });

  test('cursor starts at lastPosition in a non-empty fixture', () {
    final fixture = terminal(
      lines: [
        'Hello World!',
        'Goodbye World!',
      ],
    );

    expect(fixture.cursor.offset, fixture.lastPosition);
    expect(fixture.cursor.toString(), 'Cursor <1:14>');
  });

  test('cursor moves to the left', () {
    final fixture = terminal(
      lines: ['Hello'],
    );

    expect(fixture.cursor.offset, Offset(5, 0));

    fixture.cursor.column -= 1;

    expect(fixture.cursor.offset, Offset(4, 0));
  });

  test('cursor is clamped to 0 when moved too far left', () {
    final fixture = terminal(
      lines: ['Hello'],
    );

    expect(fixture.cursor.offset, Offset(5, 0));

    fixture.cursor.column -= 10;

    expect(fixture.cursor.offset, Offset(0, 0));
  });

  test('cursor moves to the right', () {
    final fixture = terminal(
      lines: ['Hello'],
      cursor: Offset(4, 0),
    );

    expect(fixture.cursor.offset, Offset(4, 0));

    fixture.cursor.column += 1;

    expect(fixture.cursor.offset, Offset(5, 0));
  });

  test('cursor is clamped to width when oved too far right', () {
    final fixture = terminal(
      lines: ['Hello'],
      cursor: Offset(4, 0),
    );

    expect(fixture.cursor.offset, Offset(4, 0));

    fixture.cursor.column += 10;

    expect(fixture.cursor.offset, Offset(5, 0));
  });

  test('cursor moves up', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(0, 1),
    );

    expect(fixture.cursor.offset, Offset(0, 1));

    fixture.cursor.line -= 1;

    expect(fixture.cursor.offset, Offset(0, 0));
  });

  test('cursor is clamped to 0 when moved too far up', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(0, 1),
    );

    expect(fixture.cursor.offset, Offset(0, 1));

    fixture.cursor.line -= 10;

    expect(fixture.cursor.offset, Offset(0, 0));
  });

  test('cursor moves down', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset.zero,
    );

    expect(fixture.cursor.offset, Offset(0, 0));

    fixture.cursor.line += 1;

    expect(fixture.cursor.offset, Offset(0, 1));
  });

  test('cursor is clamped to height when moved too far down', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset.zero,
    );

    expect(fixture.cursor.offset, Offset(0, 0));

    fixture.cursor.line += 10;

    expect(fixture.cursor.offset, Offset(0, 1));
  });

  test('currentLine reflects the cursor position', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(0, 0),
    );

    expect(fixture.currentLine, 'Hello');
  });

  test('lastPosition changes as lines are added', () {
    final fixture = terminal();

    expect(fixture.lastPosition, Offset.zero);

    fixture.writeLine('Hello World!');

    expect(fixture.lastPosition, Offset(0, 1));
  });

  test('writing to a non-terminal cursor replaces the current line', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(0, 1),
    );

    fixture.write('Goodbye!');

    expect(fixture.lines, [
      'Hello',
      'Goodbye!',
    ]);
  });

  test('clears the current line', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(0, 1),
    );

    fixture.clearLine();

    expect(fixture.lines, [
      'Hello',
      '',
    ]);
  });

  test('clears the current line before the cursor', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(3, 1),
    );

    fixture.clearLineBefore();

    expect(fixture.lines, [
      'Hello',
      '   ld!',
    ]);
  });

  test('clears the current line after the cursor', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(3, 1),
    );

    fixture.clearLineAfter();

    expect(fixture.lines, [
      'Hello',
      'Wor',
    ]);
  });

  test('clears the curent screen with the cursor at 0x0', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset.zero,
    );

    fixture.clearScreen();

    expect(fixture.lines, [
      '',
    ]);
  });

  test('clears the current screen with the cursor at 0x1', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(0, 1),
    );

    fixture.clearScreen();

    expect(fixture.lines, [
      '',
      '',
    ]);
  });

  test('clears the screen before the cursor', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(3, 1),
    );

    fixture.clearScreenBefore();

    expect(fixture.lines, [
      '',
      '   ld!',
    ]);
  });

  test('clears the screen after the cursor', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(3, 1),
    );

    fixture.clearScreenAfter();

    expect(fixture.lines, [
      'Hello',
      'Wor',
    ]);
  });

  test('clears the screen after the cursor erasing lines', () {
    final fixture = terminal(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(5, 0),
    );

    fixture.clearScreenAfter();

    expect(fixture.lines, [
      'Hello',
    ]);
  });
}

// These types exist to ensure that the class has the intended modifiers.
// -----------------------------------------------------------------------------

// ignore: unused_element
final class _CanBeImplemented implements Terminal<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
