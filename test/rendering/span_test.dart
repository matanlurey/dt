import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  test('defaults to an empty span', () {
    check(Span.empty).equals(Span());
  });

  test('content and style are set', () {
    final style = Style();
    check(Span('Hello', style))
      ..equals(Span('Hello', style))
      ..has((s) => s.hashCode, 'content').equals(Span('Hello', style).hashCode);
  });

  test('toString returns "Span(content, style)"', () {
    check(Span('Hello').toString()).equals('Span("Hello", Style.inherit)');
  });

  test('copyWith returns a new span with the given content and style', () {
    final span = Span('Hello');
    final newSpan = span.copyWith(content: 'World');
    check(newSpan).equals(Span('World'));
  });

  test('width is the sum of the width of each rune in the content', () {
    check(Span('Café'))
      ..has((s) => s.width, 'width').equals(4)
      ..has((s) => s.content.length, 'content.length').equals(4);

    check(Span('ह्न'))
      ..has((s) => s.width, 'width').equals(2)
      ..has((s) => s.content.length, 'content.length').equals(3);

    check(Span('🇬🇧🇬🇧'))
      ..has((s) => s.width, 'width').equals(2)
      ..has((s) => s.content.length, 'content.length').equals(8);
  });
}
