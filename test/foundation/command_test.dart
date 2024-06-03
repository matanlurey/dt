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
        ..has((a) => a.finalByte, 'finalByte').equals('H')
        ..has((a) => a.parameters, 'parameters').deepEquals([1, 2]);
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
        ..has((a) => a.finalByte, 'finalByte').equals('G')
        ..has((a) => a.parameters, 'parameters').deepEquals([1]);
    });
  });

  group('ClearScreen', () {
    test('all', () {
      final command = ClearScreen.all;

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalByte, 'finalByte').equals('J')
        ..has((a) => a.parameters, 'parameters').deepEquals([0]);
    });

    test('allAndScrollback', () {
      final command = ClearScreen.allAndScrollback;

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalByte, 'finalByte').equals('J')
        ..has((a) => a.parameters, 'parameters').deepEquals([3]);
    });

    test('fromCursorDown', () {
      final command = ClearScreen.fromCursorDown;

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalByte, 'finalByte').equals('J')
        ..has((a) => a.parameters, 'parameters').deepEquals([1]);
    });

    test('fromCursorUp', () {
      final command = ClearScreen.fromCursorUp;

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalByte, 'finalByte').equals('J')
        ..has((a) => a.parameters, 'parameters').deepEquals([2]);
    });

    test('currentLine', () {
      final command = ClearScreen.currentLine;

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalByte, 'finalByte').equals('K')
        ..has((a) => a.parameters, 'parameters').deepEquals([0]);
    });

    test('toEndOfLine', () {
      final command = ClearScreen.toEndOfLine;

      check(command.toSequence()).isA<EscapeSequence>()
        ..has((a) => a.finalByte, 'finalByte').equals('K')
        ..has((a) => a.parameters, 'parameters').deepEquals([0]);
    });
  });
}
