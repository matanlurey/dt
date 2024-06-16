import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  test('defaults to an empty line', () {
    check(Line.empty).equals(Line([]));
  });

  test('content is set', () {
    check(Line([Span('Hello')]))
      ..equals(Line([Span('Hello')]))
      ..has((l) => l.hashCode, 'content').equals(
        Line([Span('Hello')]).hashCode,
      );
  });

  test('toString returns all properties', () {
    check(Line([Span('Hello')]))
        .has(
          (l) => l.toString(),
          'toString()',
        )
        .equals(
          'Line([Span("Hello", Style.inherit)], style: Style.inherit, alignment: Alignment.inherit)',
        );
  });

  test('width is the sum of the width of each span in the content', () {
    check(Line([Span('Hello')])).has((l) => l.width, 'width').equals(5);

    check(Line([Span('Hello'), Span('World')]))
        .has((l) => l.width, 'width')
        .equals(10);
  });

  test('copyWith returns a new line with the given content and style', () {
    final line = Line([Span('Hello')]);
    final newLine = line.copyWith(spans: [Span('World')]);
    check(newLine).equals(Line([Span('World')]));
  });

  test('copyWith does nothing if no properties are provided', () {
    final line = Line([Span('Hello')]);
    final newLine = line.copyWith();
    check(newLine).equals(line);
  });

  test('append returns a new line with the given span appended', () {
    final line = Line([Span('Hello')]);
    final newLine = line.append(Span('World'));
    check(newLine).equals(Line([Span('Hello'), Span('World')]));
  });

  test('operator+ is an alias for append', () {
    final line = Line([Span('Hello')]);
    final newLine = line + Span('World');
    check(newLine).equals(Line([Span('Hello'), Span('World')]));
  });
}
