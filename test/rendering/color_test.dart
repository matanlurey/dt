import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  group('dim colors are considered dim', () {
    for (final color in [
      Color16.black,
      Color16.red,
      Color16.green,
      Color16.yellow,
      Color16.blue,
      Color16.magenta,
      Color16.cyan,
      Color16.white,
    ]) {
      test(color.name, () {
        check(color)
          ..has((c) => c.isDim, 'isDim').isTrue()
          ..has((c) => c.isBright, 'isBright').isFalse();

        check(color.toBright().toDim()).equals(color);
      });
    }
  });

  group('bright colors are considered bright', () {
    for (final color in [
      Color16.brightBlack,
      Color16.brightRed,
      Color16.brightGreen,
      Color16.brightYellow,
      Color16.brightBlue,
      Color16.brightMagenta,
      Color16.brightCyan,
      Color16.brightWhite,
    ]) {
      test(color.name, () {
        check(color)
          ..has((c) => c.isDim, 'isDim').isFalse()
          ..has((c) => c.isBright, 'isBright').isTrue();

        check(color.toDim().toBright()).equals(color);
      });
    }
  });

  test('Color.reset is reset', () {
    check(Color.reset)
        .has((c) => c.toString(), 'toString()')
        .equals('Color.reset');
  });

  test('Color.inherit is inherit', () {
    check(Color.inherit)
        .has((c) => c.toString(), 'toString()')
        .equals('Color.inherit');
  });
}
