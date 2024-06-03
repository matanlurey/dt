import 'package:dt/foundation.dart';

import '../prelude.dart';

void main() {
  group('MoveCursorTo', () {
    test('== and hashCode', () {
      final a = MoveCursorTo(1, 2);
      final b = MoveCursorTo(1, 2);
      final c = MoveCursorTo(2, 1);

      check(a)
        ..has((a) => a == b, '== b').isTrue()
        ..has((a) => a == c, '== c').isFalse()
        ..has((a) => a.hashCode, 'hashCode').equals(b.hashCode);
    });

    test('defaults to (0, 0)', () {
      final command = MoveCursorTo();

      check(command)
        ..has((a) => a.row, 'row').equals(0)
        ..has((a) => a.column, 'column').equals(0);
    });

    test('clamps negative row and column', () {
      final command = MoveCursorTo(-1, -1);

      check(command)
        ..has((a) => a.row, 'row').equals(0)
        ..has((a) => a.column, 'column').equals(0);
    });

    test('includes row and column in toString', () {
      final command = MoveCursorTo(1, 2);

      check(command.toString())
        ..contains('MoveCursorTo')
        ..contains('1:2');
    });

    test('converts to sequence', () {
      final command = MoveCursorTo(1, 2);

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('H')
        ..has((a) => a.parameters, 'parameters').deepEquals([1, 2]);
    });

    test('converts back to Command', () {
      final Command noParams = MoveCursorTo();
      final Command oneParam = MoveCursorTo(1);
      final Command twoParams = MoveCursorTo(1, 2);

      check(noParams).equals(
        Command.tryParse(
          noParams.toSequence().toTerse(),
        )!,
      );

      check(oneParam).equals(
        Command.tryParse(
          oneParam.toSequence().toTerse(),
        )!,
      );

      check(twoParams).equals(
        Command.tryParse(
          twoParams.toSequence().toTerse(),
        )!,
      );
    });
  });

  group('MoveCursorToColumn', () {
    test('defaults to 0', () {
      final command = MoveCursorToColumn();

      check(command).has((a) => a.column, 'column').equals(0);
    });

    test('clamps negative column', () {
      final command = MoveCursorToColumn(-1);

      check(command).has((a) => a.column, 'column').equals(0);
    });

    test('includes column in toString', () {
      final command = MoveCursorToColumn(1);

      check(command.toString())
        ..contains('MoveCursorToColumn')
        ..contains('1');
    });

    test('converts to sequence', () {
      final command = MoveCursorToColumn(1);

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('G')
        ..has((a) => a.parameters, 'parameters').deepEquals([1]);
    });

    test('converts back to Command', () {
      final Command noParams = MoveCursorToColumn();
      final Command oneParam = MoveCursorToColumn(1);

      check(noParams).equals(
        Command.tryParse(noParams.toSequence().toTerse())!,
      );
      check(oneParam).equals(
        Command.tryParse(oneParam.toSequence().toTerse())!,
      );
    });
  });

  group('SetCursorVisibility', () {
    test('visible', () {
      final Command command = SetCursorVisibility.visible;
      final sequence = command.toSequence();

      check(sequence).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('?25h')
        ..has((a) => a.parameters, 'parameters').isEmpty();

      check(command).equals(Command.tryParse(sequence)!);
    });

    test('hidden', () {
      final Command command = SetCursorVisibility.hidden;
      final sequence = command.toSequence();

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('?25l')
        ..has((a) => a.parameters, 'parameters').isEmpty();

      check(command).equals(Command.tryParse(sequence)!);
    });
  });

  group('AlternateScreenBuffer', () {
    test('enter', () {
      final Command command = AlternateScreenBuffer.enter;
      final sequence = command.toSequence();

      check(sequence).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('?1049h')
        ..has((a) => a.parameters, 'parameters').isEmpty();

      check(command).equals(Command.tryParse(sequence)!);
    });

    test('leave', () {
      final Command command = AlternateScreenBuffer.leave;
      final sequence = command.toSequence();

      check(sequence).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('?1049l')
        ..has((a) => a.parameters, 'parameters').isEmpty();

      check(command).equals(Command.tryParse(sequence)!);
    });
  });

  group('ClearScreen', () {
    test('all', () {
      final Command command = ClearScreen.all;
      final sequence = command.toSequence();

      check(sequence).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('J')
        ..has((a) => a.parameters, 'parameters').deepEquals([0]);

      check(command).equals(Command.tryParse(sequence)!);
    });

    test('allAndScrollback', () {
      final Command command = ClearScreen.allAndScrollback;
      final sequence = command.toSequence();

      check(sequence).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('J')
        ..has((a) => a.parameters, 'parameters').deepEquals([3]);

      check(command).equals(Command.tryParse(sequence)!);
    });

    test('fromCursorDown', () {
      final Command command = ClearScreen.fromCursorDown;
      final sequence = command.toSequence();

      check(sequence).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('J')
        ..has((a) => a.parameters, 'parameters').deepEquals([1]);

      check(command).equals(Command.tryParse(sequence)!);
    });

    test('fromCursorUp', () {
      final Command command = ClearScreen.fromCursorUp;
      final sequence = command.toSequence();

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('J')
        ..has((a) => a.parameters, 'parameters').deepEquals([2]);

      check(command).equals(Command.tryParse(sequence)!);
    });

    test('currentLine', () {
      final Command command = ClearScreen.currentLine;
      final sequence = command.toSequence();

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('K')
        ..has((a) => a.parameters, 'parameters').deepEquals([2]);

      check(command).equals(Command.tryParse(sequence)!);
    });

    test('toEndOfLine', () {
      final Command command = ClearScreen.toEndOfLine;
      final sequence = command.toSequence();

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalChars, 'finalByte').equals('K')
        ..has((a) => a.parameters, 'parameters').deepEquals([0]);

      check(command).equals(Command.tryParse(sequence)!);
    });
  });
}
