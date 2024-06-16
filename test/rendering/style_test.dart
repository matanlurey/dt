import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  test('defaults to an inherited style', () {
    check(Style.inherit).equals(Style());
  });

  test('copyWith returns a new style with the given properties', () {
    final style = Style();
    final newStyle = style.copyWith(
      foreground: AnsiColor.black,
      background: AnsiColor.white,
    );
    check(newStyle).equals(
      Style(foreground: AnsiColor.black, background: AnsiColor.white),
    );
  });

  test('copyWith does nothing if no properties are provided', () {
    final style = Style();
    final newStyle = style.copyWith();
    check(newStyle).equals(style);
  });

  test('toString returns "Style.inherit"', () {
    check(Style.inherit)
        .has((s) => s.toString(), 'toString()')
        .equals('Style.inherit');
  });

  test('toString returns "Style(...)"', () {
    check(Style(foreground: AnsiColor.black, background: AnsiColor.white))
        .has((s) => s.toString(), 'toString()')
        .equals(
          'Style(foreground: AnsiColor.black, background: AnsiColor.white)',
        );
  });
}
