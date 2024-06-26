import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  test('defaults to a reset style', () {
    check(Style.reset).equals(
      Style(foreground: Color.reset, background: Color.reset),
    );
  });

  test('copyWith returns a new style with the given properties', () {
    final style = Style();
    final newStyle = style.copyWith(
      foreground: Color16.black,
      background: Color16.white,
    );
    check(newStyle).equals(
      Style(foreground: Color16.black, background: Color16.white),
    );
  });

  test('copyWith does nothing if no properties are provided', () {
    final style = Style();
    final newStyle = style.copyWith();
    check(newStyle).equals(style);
  });

  test('toString returns "Style.reset"', () {
    check(Style.reset)
        .has((s) => s.toString(), 'toString()')
        .equals('Style.reset');
  });

  test('toString returns "Style(foreground: ..., background: ...)"', () {
    check(Style(foreground: Color16.black, background: Color16.white))
        .has((s) => s.toString(), 'toString()')
        .equals(
          'Style(foreground: Color16.black, background: Color16.white)',
        );
  });

  test('toString returns "Style(foreground: ...)"', () {
    check(Style(foreground: Color16.black))
        .has((s) => s.toString(), 'toString()')
        .equals('Style(foreground: Color16.black)');
  });

  test('toString returns "Style(background: ...)"', () {
    check(Style(background: Color16.white))
        .has((s) => s.toString(), 'toString()')
        .equals('Style(background: Color16.white)');
  });
}
