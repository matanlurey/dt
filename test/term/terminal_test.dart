import 'package:dt/src/core.dart';
import 'package:dt/src/term.dart';
import 'package:test/test.dart';

void main() {
  group('$StringTerminal', () {
    _tests(
      constructor: StringTerminal.from,
    );
  });
  group('Terminal<String>.using', () {
    _tests(
      constructor: ({lines = const [], cursor}) => Terminal.using(
        defaultSpan: () => '',
        widthSpan: (span) => span.length,
        truncateSpan: (span, index, insert) {
          return span.replaceRange(index, null, insert);
        },
        lines: lines,
        cursor: cursor,
      ),
    );
  });
}

void _tests({
  required Terminal<String> Function({
    Iterable<String> lines,
    Offset? cursor,
  }) constructor,
}) {
  test('starts empty', () {
    final feed = constructor();

    // Contents.
    expect(feed.isEmpty, isTrue);
    expect(feed.isNotEmpty, isFalse);
    expect(feed.lineCount, 0);

    // Accessors.
    expect(() => feed.line(0), throwsRangeError);
  });

  test('starts with an empty line', () {
    final feed = constructor(lines: ['']);

    // Contents.
    expect(feed.isEmpty, isFalse);
    expect(feed.isNotEmpty, isTrue);
    expect(feed.lineCount, 1);

    // Accessors.
    expect(feed.line(0), '');
  });

  test('starts with a single line', () {
    final feed = constructor(lines: ['Hello World!']);

    expect(feed.lines, ['Hello World!']);
  });

  test('starts with multiple lines', () {
    final feed = constructor(
      lines: [
        'Hello World!',
        'Goodbye World!',
      ],
    );

    expect(feed.lines, [
      'Hello World!',
      'Goodbye World!',
    ]);
  });

  test('writing a span', () {
    final feed = constructor();

    // Write a span.
    feed.write('Hello World!');

    expect(feed.lines, ['Hello World!']);
  });

  test('writing a line', () {
    final feed = constructor();

    // Write a line.
    feed.writeLine('Hello World!');

    expect(feed.lines, ['Hello World!', '']);
  });

  test('writing multiple spans', () {
    final feed = constructor();

    // Write multiple spans.
    feed.writeAll([
      'Hello',
      'World!',
    ]);

    expect(feed.lines, ['HelloWorld!']);
  });

  test('writing multiple spans with a separator', () {
    final feed = constructor();

    // Write multiple spans with a separator.
    feed.writeAll(
      [
        'Hello',
        'World!',
      ],
      separator: ' ',
    );

    expect(feed.lines, ['Hello World!']);
  });

  test('writing multiple lines', () {
    final feed = constructor();

    // Write multiple lines.
    feed.writeLines([
      'Hello',
      'World!',
    ]);

    expect(feed.lines, ['Hello', 'World!', '']);
  });

  test('writing multiple lines with a separator', () {
    final feed = constructor();

    // Write multiple lines with a separator.
    feed.writeLines(
      [
        'Hello',
        'World!',
      ],
      separator: ' ',
    );

    expect(feed.lines, ['Hello ', 'World!', '']);
  });

  test('cursor starts at 0:0 in an empty feed', () {
    final feed = constructor();

    expect(feed.cursor.offset, Offset(0, 0));
  });

  test('cursor starts at lastPosition in a non-empty feed', () {
    final feed = constructor(
      lines: [
        'Hello World!',
        'Goodbye World!',
      ],
    );

    expect(feed.cursor.offset, feed.lastPosition);
  });

  test('cursor moves to the left', () {
    final feed = constructor(
      lines: ['Hello'],
    );

    expect(feed.cursor.offset, Offset(5, 0));

    feed.cursor.column -= 1;

    expect(feed.cursor.offset, Offset(4, 0));
  });

  test('cursor is clamped to 0 when moved too far left', () {
    final feed = constructor(
      lines: ['Hello'],
    );

    expect(feed.cursor.offset, Offset(5, 0));

    feed.cursor.column -= 10;

    expect(feed.cursor.offset, Offset(0, 0));
  });

  test('cursor moves to the right', () {
    final feed = constructor(
      lines: ['Hello'],
      cursor: Offset(4, 0),
    );

    expect(feed.cursor.offset, Offset(4, 0));

    feed.cursor.column += 1;

    expect(feed.cursor.offset, Offset(5, 0));
  });

  test('cursor is clamped to width when oved too far right', () {
    final feed = constructor(
      lines: ['Hello'],
      cursor: Offset(4, 0),
    );

    expect(feed.cursor.offset, Offset(4, 0));

    feed.cursor.column += 10;

    expect(feed.cursor.offset, Offset(5, 0));
  });

  test('cursor moves up', () {
    final feed = constructor(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(0, 1),
    );

    expect(feed.cursor.offset, Offset(0, 1));

    feed.cursor.line -= 1;

    expect(feed.cursor.offset, Offset(0, 0));
  });

  test('cursor is clamped to 0 when moved too far up', () {
    final feed = constructor(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset(0, 1),
    );

    expect(feed.cursor.offset, Offset(0, 1));

    feed.cursor.line -= 10;

    expect(feed.cursor.offset, Offset(0, 0));
  });

  test('cursor moves down', () {
    final feed = constructor(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset.zero,
    );

    expect(feed.cursor.offset, Offset(0, 0));

    feed.cursor.line += 1;

    expect(feed.cursor.offset, Offset(0, 1));
  });

  test('cursor is clamped to height when moved too far down', () {
    final feed = constructor(
      lines: [
        'Hello',
        'World!',
      ],
      cursor: Offset.zero,
    );

    expect(feed.cursor.offset, Offset(0, 0));

    feed.cursor.line += 10;

    expect(feed.cursor.offset, Offset(0, 1));
  });
}

// These types exist to ensure that the class has the intended modifiers.
// -----------------------------------------------------------------------------

// ignore: unused_element
final class _CanBeImplemented implements Terminal<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
