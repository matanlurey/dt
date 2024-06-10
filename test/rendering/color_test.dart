import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  group('dim colors are considered dim', () {
    for (final color in [
      AnsiColor.black,
      AnsiColor.red,
      AnsiColor.green,
      AnsiColor.yellow,
      AnsiColor.blue,
      AnsiColor.magenta,
      AnsiColor.cyan,
      AnsiColor.white,
    ]) {
      test(color.name, () {
        check(color)
          ..has((c) => c.isDim, 'isDim').isTrue()
          ..has((c) => c.isBright, 'isBright').isFalse()
          ..has((c) => c.setForeground(), 'setForeground()').equals(
            SetForegroundColor256(color.index + 30),
          )
          ..has((c) => c.setBackground(), 'setBackground()').equals(
            SetBackgroundColor256(color.index + 40),
          );

        check(color.toBright().toDim()).equals(color);
      });
    }
  });

  group('bright colors are considered bright', () {
    for (final color in [
      AnsiColor.brightBlack,
      AnsiColor.brightRed,
      AnsiColor.brightGreen,
      AnsiColor.brightYellow,
      AnsiColor.brightBlue,
      AnsiColor.brightMagenta,
      AnsiColor.brightCyan,
      AnsiColor.brightWhite,
    ]) {
      test(color.name, () {
        check(color)
          ..has((c) => c.isDim, 'isDim').isFalse()
          ..has((c) => c.isBright, 'isBright').isTrue()
          ..has((c) => c.setForeground(), 'setForeground()').equals(
            SetForegroundColor256(color.index + 90),
          )
          ..has((c) => c.setBackground(), 'setBackground()').equals(
            SetBackgroundColor256(color.index + 100),
          );

        check(color.toDim().toBright()).equals(color);
      });
    }
  });

  test('Color.reset is reset', () {
    check(Color.reset)
      ..has((c) => c.setForeground(), 'setForeground()').equals(
        SetForegroundColor256(39),
      )
      ..has((c) => c.setBackground(), 'setBackground()').equals(
        SetBackgroundColor256(49),
      )
      ..has((c) => c.toString(), 'toString()').equals('Color.reset');
  });

  test('Color.inherit is inherit', () {
    check(Color.inherit)
      ..has((c) => c.setForeground(), 'setForeground()').equals(Command.none)
      ..has((c) => c.setBackground(), 'setBackground()').equals(Command.none)
      ..has((c) => c.toString(), 'toString()').equals('Color.inherit');
  });
}
