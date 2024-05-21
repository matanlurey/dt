import 'package:dt/src/line/feed.dart';
import 'package:test/test.dart';

void main() {
  group('StringLineFeed', () {
    _tests(
      constructor: StringLineFeed.from,
    );
  });
  group('LineFeed<String>.using', () {
    _tests(
      constructor: ([lines = const []]) => LineFeed.using(
        defaultSpan: () => '',
        mergeSpan: (a, b) => '$a$b',
        lines: lines,
      ),
    );
  });
}

void _tests({
  required LineFeed<String> Function([Iterable<String>]) constructor,
}) {
  test('starts empty', () {
    final feed = constructor();

    // Contents.
    expect(feed.isEmpty, isTrue);
    expect(feed.isNotEmpty, isFalse);
    expect(feed.length, 0);

    // Accessors.
    expect(() => feed.line(0), throwsRangeError);
  });

  test('starts with an empty line', () {
    final feed = constructor(['']);

    // Contents.
    expect(feed.isEmpty, isFalse);
    expect(feed.isNotEmpty, isTrue);
    expect(feed.length, 1);

    // Accessors.
    expect(feed.line(0), '');
  });

  test('starts with a single line', () {
    final feed = constructor(['Hello World!']);

    expect(feed.lines, ['Hello World!']);
  });

  test('starts with multiple lines', () {
    final feed = constructor([
      'Hello World!',
      'Goodbye World!',
    ]);

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
}

// These types exist to ensure that the class has the intended modifiers.
// -----------------------------------------------------------------------------

// ignore: unused_element
final class _CanBeImplemented implements LineFeed<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
final class _CanBeExtended extends LineFeed<void> {
  _CanBeExtended() : super.from([]);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
