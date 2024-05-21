import 'package:dt/src/term.dart';
import 'package:test/test.dart';

// We use a List<int> to avoid the degenerate case of a span with a '\n'.
typedef _Span = List<int>;

void main() {
  (List<_Span> lines, TerminalSink<_Span> sink) fixture() {
    final lines = <_Span>[];
    final sink = _TestSink(lines);
    return (lines, sink);
  }

  test('writes a span', () {
    final (lines, sink) = fixture();

    sink.write([1, 2, 3]);

    expect(lines, <_Span>[
      [1, 2, 3],
    ]);
  });

  test('writes a line', () {
    final (lines, sink) = fixture();

    sink.writeLine([1, 2, 3]);

    expect(lines, <_Span>[
      [1, 2, 3],
      [],
    ]);
  });

  test('writes multiple spans', () {
    final (lines, sink) = fixture();

    sink.writeAll([
      [1, 2],
      [3, 4],
    ]);

    expect(lines, <_Span>[
      [1, 2, 3, 4],
    ]);
  });

  test('writes multiple spans with a separator', () {
    final (lines, sink) = fixture();

    sink.writeAll(
      [
        [1, 2],
        [3, 4],
      ],
      separator: [5],
    );

    expect(lines, <_Span>[
      [1, 2, 5, 3, 4],
    ]);
  });

  test('writes multiple lines', () {
    final (lines, sink) = fixture();

    sink.writeLines([
      [1, 2],
      [3, 4],
    ]);

    expect(lines, <_Span>[
      [1, 2],
      [3, 4],
      [],
    ]);
  });

  test('writes multiple lines with a separator', () {
    final (lines, sink) = fixture();

    sink.writeLines(
      [
        [1, 2],
        [3, 4],
      ],
      separator: [5],
    );

    expect(lines, <_Span>[
      [1, 2, 5],
      [3, 4],
      [],
    ]);
  });
}

/// An example of a class that implements [TerminalSink].
final class _TestSink extends TerminalSink<_Span> {
  _TestSink(this.lines);

  final List<List<int>> lines;

  @override
  void write(_Span span) {
    if (lines.isEmpty) {
      lines.add(span);
    } else {
      lines.last.addAll(span);
    }
  }

  @override
  void writeLine([_Span? span]) {
    if (span != null) {
      write(span);
    }
    lines.add([]);
  }
}

// These types exist to ensure that the class has the intended modifiers.
// -----------------------------------------------------------------------------

// ignore: unused_element
final class _CanBeImplemented implements TerminalSink<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
final class _CanBeExtended extends TerminalSink<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
final class _CanBeMixedIn with TerminalSink<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
