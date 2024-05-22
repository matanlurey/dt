import 'package:dt/dt.dart';
import 'package:test/test.dart';

void main() {
  group('StringSpan', () {
    _stringTests(const StringSpan());
  });

  group('TerminalSpan<String>', () {
    _stringTests(const _NaiveStringSpan());
  });

  group('ListSpan (Immutable)', () {
    _listTests(const ListSpan());
  });

  group('ListSpan (Mutable)', () {
    _listTests(const ListSpan.mutable());
  });
}

/// A simpler implementation of [TerminalSpan] without specializations.
final class _NaiveStringSpan extends TerminalSpan<String> {
  const _NaiveStringSpan();

  @override
  String empty() => '';

  @override
  int width(String span) => span.length;

  @override
  String merge(String first, String second) => first + second;

  @override
  String extract(String source, {int start = 0, int? end}) {
    return source.substring(start, end);
  }
}

void _stringTests(TerminalSpan<String> span) {
  test('emtpy returns an empty string', () {
    expect(span.empty(), '');
  });

  test("width returns a string's length", () {
    expect(span.width(''), 0);
    expect(span.width('a'), 1);
    expect(span.width('ab'), 2);
  });

  test('merge concatenates two strings', () {
    expect(span.merge('', ''), '');
    expect(span.merge('a', 'b'), 'ab');
    expect(span.merge('ab', 'c'), 'abc');
  });

  test('extract returns a substring', () {
    expect(span.extract('abc'), 'abc');
    expect(span.extract('abc', start: 0), 'abc');
    expect(span.extract('abc', start: 1), 'bc');
    expect(span.extract('abc', start: 1, end: 2), 'b');
  });

  test('insert inserts a string into another string', () {
    expect(span.insert('abc', 'd', 0), 'dabc');
    expect(span.insert('abc', 'd', 1), 'adbc');
    expect(span.insert('abc', 'd', 2), 'abdc');
    expect(span.insert('abc', 'd', 3), 'abcd');
  });

  test('replace replaces a range in a string until the end of the string', () {
    expect(
      span.replace('abc', 'd', 0),
      'd',
      reason: 'replacing at start without an end replaces the entire string',
    );
    expect(
      span.replace('abc', 'd', 1),
      'ad',
      reason: 'replacing in the middle without an end replaces the end',
    );
    expect(
      span.replace('abc', 'd', 2),
      'abd',
      reason: 'replacing at the end replaces a single character',
    );
  });

  test('replace replaces a range in a string with an end index', () {
    expect(
      span.replace('abc', 'd', 0, 1),
      'dbc',
      reason: 'replacing at start replaces the first character',
    );
    expect(
      span.replace('abc', 'd', 1, 2),
      'adc',
      reason: 'replacing in the middle replaces a single character',
    );
    expect(
      span.replace('abc', 'd', 2, 3),
      'abd',
      reason: 'replacing at the end replaces a single character',
    );
  });
}

void _listTests(TerminalSpan<List<int>> span) {
  test('emtpy returns an empty list', () {
    expect(span.empty(), <int>[]);
  });

  test("width returns a list's length", () {
    expect(span.width([]), 0);
    expect(span.width([1]), 1);
    expect(span.width([1, 2]), 2);
  });

  test('merge concatenates two lists', () {
    expect(span.merge([], []), <int>[]);
    expect(span.merge([1], [2]), [1, 2]);
    expect(span.merge([1, 2], [3]), [1, 2, 3]);
  });

  test('extract returns a sublist', () {
    expect(span.extract([1, 2, 3]), [1, 2, 3]);
    expect(span.extract([1, 2, 3], start: 0), [1, 2, 3]);
    expect(span.extract([1, 2, 3], start: 1), [2, 3]);
    expect(span.extract([1, 2, 3], start: 1, end: 2), [2]);
  });

  test('insert inserts a list into another list', () {
    expect(span.insert([1, 2, 3], [4], 0), [4, 1, 2, 3]);
    expect(span.insert([1, 2, 3], [4], 1), [1, 4, 2, 3]);
    expect(span.insert([1, 2, 3], [4], 2), [1, 2, 4, 3]);
    expect(span.insert([1, 2, 3], [4], 3), [1, 2, 3, 4]);
  });

  test('replace replaces a range in a list until the end of the list', () {
    expect(
      span.replace([1, 2, 3], [4], 0),
      [4],
      reason: 'replacing at start without an end replaces the entire list',
    );
    expect(
      span.replace([1, 2, 3], [4], 1),
      [1, 4],
      reason: 'replacing in the middle without an end replaces the end',
    );
    expect(
      span.replace([1, 2, 3], [4], 2),
      [1, 2, 4],
      reason: 'replacing at the end replaces a single element',
    );
  });

  test('replace replaces a range in a list with an end index', () {
    expect(
      span.replace([1, 2, 3], [4], 0, 1),
      [4, 2, 3],
      reason: 'replacing at start replaces the first element',
    );
    expect(
      span.replace([1, 2, 3], [4], 1, 2),
      [1, 4, 3],
      reason: 'replacing in the middle replaces a single element',
    );
    expect(
      span.replace([1, 2, 3], [4], 2, 3),
      [1, 2, 4],
      reason: 'replacing at the end replaces a single element',
    );
  });
}
