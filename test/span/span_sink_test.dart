import 'package:dt/src/span/sink.dart';
import 'package:test/test.dart';

void main() {
  (List<String> lines, SpanSink<String> sink) fixture() {
    final lines = <String>[];
    final sink = _TestSink(lines);
    return (lines, sink);
  }

  test('writes a span', () {
    final (lines, sink) = fixture();

    sink.write('Hello, world!');

    expect(lines, ['Hello, world!']);
  });

  test(r'writes a span that contains a \n', () {
    final (lines, sink) = fixture();

    sink.write('Hello\nworld!');

    expect(lines, ['Hello\nworld!'], reason: 'The span should not be split.');
  });

  test('writes a line', () {
    final (lines, sink) = fixture();

    sink.writeLine('Hello, world!');

    expect(lines, ['Hello, world!', '']);
  });

  test('writes a line containing a span', () {
    final (lines, sink) = fixture();

    sink.writeLine('Hello, world!');

    expect(lines, ['Hello, world!', '']);
  });

  test(r'writes a line containing a span with a \n', () {
    final (lines, sink) = fixture();

    sink.writeLine('Hello\nworld!');

    expect(
      lines,
      ['Hello\nworld!', ''],
      reason: 'The span should not be split.',
    );
  });

  test('writes multiple spans', () {
    final (lines, sink) = fixture();

    sink.writeAll(['Hello', 'world!']);

    expect(lines, ['Helloworld!']);
  });

  test('writes multiple spans with a separator', () {
    final (lines, sink) = fixture();

    sink.writeAll(['Hello', 'world!'], separator: ', ');

    expect(lines, ['Hello, world!']);
  });

  test(r'writes multiple spans with a separator that contains a \n', () {
    final (lines, sink) = fixture();

    sink.writeAll(['Hello', 'world!'], separator: '\n');

    expect(
      lines,
      ['Hello\nworld!'],
      reason: 'The separator should not be split.',
    );
  });

  test(r'writes multiple spans that contain a \n with a separator', () {
    final (lines, sink) = fixture();

    sink.writeAll(['Hello\n', 'world!'], separator: ', ');

    expect(
      lines,
      ['Hello\n, world!'],
      reason: 'The spans should not be split.',
    );
  });

  test('writes multiple lines', () {
    final (lines, sink) = fixture();

    sink.writeLines(['Hello', 'world!']);

    expect(lines, ['Hello', 'world!', '']);
  });

  test('writes multiple lines with a separator', () {
    final (lines, sink) = fixture();

    sink.writeLines(['Apples', 'Oranges'], separator: ' and');

    expect(lines, ['Apples and', 'Oranges', '']);
  });

  test(r'writes multiple lines with a separator that contains a \n', () {
    final (lines, sink) = fixture();

    sink.writeLines(['Apples', 'Oranges'], separator: '\n');

    expect(
      lines,
      ['Apples\n', 'Oranges', ''],
      reason: 'The separator should not be split.',
    );
  });

  test(r'writes multiple lines that contain a \n with a separator', () {
    final (lines, sink) = fixture();

    sink.writeLines(['Apples\n', 'Oranges'], separator: ' and');

    expect(
      lines,
      ['Apples\n and', 'Oranges', ''],
      reason: 'The lines should not be split.',
    );
  });
}

/// An example implementation of a [SpanSink] that writes spans to a list.
final class _TestSink extends SpanSink<String> {
  _TestSink(this._spans);

  final List<String> _spans;

  @override
  void write(String span) {
    if (_spans.isEmpty) {
      _spans.add('');
    }
    _spans.last += span;
  }

  @override
  void writeLine([String? span]) {
    if (span != null) {
      write(span);
    }
    _spans.add('');
  }
}

// These types exist to ensure that the class has the intended modifiers.
// ----------------------------------------------------------------------------

// ignore: unused_element
final class _CanBeImplemented implements SpanSink<String> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
final class _CanBeExtended extends SpanSink<String> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
final class _CanBeMixedIn with SpanSink<String> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
