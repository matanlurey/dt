import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  test('defaults to an empty line', () {
    check(Line.empty).equals(Line([]));
  });

  test('content is set', () {
    check(Line(['Hello']))
      ..equals(Line(['Hello']))
      ..has((l) => l.hashCode, 'content').equals(
        Line(['Hello']).hashCode,
      );
  });

  test('toString returns all properties', () {
    check(Line(['Hello']))
        .has(
          (l) => l.toString(),
          'toString()',
        )
        .equals(
          'Line([Span("Hello", Style.none)], style: Style.reset, alignment: Alignment.left)',
        );
  });

  test('width is the sum of the width of each span in the content', () {
    check(Line(['Hello'])).has((l) => l.width, 'width').equals(5);

    check(Line(['Hello', 'World'])).has((l) => l.width, 'width').equals(10);
  });

  test('copyWith returns a new line with the given content and style', () {
    final line = Line(['Hello']);
    final newLine = line.copyWith(spans: [Span('World', Style.none)]);
    check(newLine).equals(Line(['World']));
  });

  test('copyWith does nothing if no properties are provided', () {
    final line = Line(['Hello']);
    final newLine = line.copyWith();
    check(newLine).equals(line);
  });

  test('append returns a new line with the given span appended', () {
    final line = Line(['Hello']);
    final newLine = line.append(Span('World', Style.none));
    check(newLine).equals(Line(['Hello', 'World']));
  });

  test('operator+ is an alias for append', () {
    final line = Line(['Hello']);
    final newLine = line + Span('World', Style.none);
    check(newLine).equals(Line(['Hello', 'World']));
  });
}
