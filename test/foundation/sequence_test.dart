import 'package:dt/foundation.dart';

import '../prelude.dart';

void main() {
  test('should parse an empty literal', () {
    final result = Sequence.parse('');

    check(result).equals(Literal(''));
  });

  test('should parse a literal', () {
    final result = Sequence.parse('Hello, World!');

    check(result).equals(Literal('Hello, World!'));
  });

  test('should compare literals', () {
    final a = Literal('Hello, World!');
    final b = Literal('Hello, World!');

    check(a)
      ..equals(b)
      ..equals(a)
      ..has((p) => p.hashCode, 'hashCode').equals(b.hashCode)
      ..has((p) => p.toString(), 'toString').equals('Hello, World!')
      ..has((p) => p.toEscapedString(), 'toEscapedString')
          .equals('Hello, World!');
  });

  test('should compare escape sequences', () {
    final a = EscapeSequence('m');
    final b = EscapeSequence('m');

    check(a)
      ..equals(b)
      ..equals(a)
      ..has((p) => p.hashCode, 'hashCode').equals(b.hashCode)
      ..has((p) => p.toString(), 'toString').contains('<m>')
      ..has((p) => p.toEscapedString(), 'toEscapedString').equals('\x1B[m');
  });

  test('should parse an escape sequence without parameters', () {
    final result = Sequence.parse('\x1B[m');

    check(result).equals(EscapeSequence('m'));
  });

  test('should parse an escape sequence with a single parameter', () {
    final result = Sequence.parse('\x1B[1m');

    check(result).equals(EscapeSequence('m', [1]));
  });

  test('should parse an escape sequence with multiple parameters', () {
    final result = Sequence.parse('\x1B[1;2m');

    check(result).equals(EscapeSequence('m', [1, 2]));
  });

  test('should parse an empty literal from parseAll', () {
    final result = Sequence.parseAll('');

    check(result).deepEquals([Literal('')]);
  });

  test('should parse a literal from parseAll', () {
    final result = Sequence.parseAll('Hello, World!');

    check(result).deepEquals([Literal('Hello, World!')]);
  });

  test('should parse interleaved sequences from parseAll', () {
    final result = Sequence.parseAll('Hello, \x1B[1;2mWorld\x1B[m!');

    check(result).deepEquals([
      Literal('Hello, '),
      EscapeSequence('m', [1, 2]),
      Literal('World'),
      EscapeSequence('m'),
      Literal('!'),
    ]);
  });

  test('should refuse a literal with an escape sequence', () {
    check(
      () => Literal('Hello, \x1B[1;2mWorld\x1B[m!'),
    ).throws<ArgumentError>();
  });

  test('should refuse an escape sequence with invalid defaults', () {
    check(
      () => EscapeSequence('m', [1], [2, 1]),
    ).throws<ArgumentError>();
  });

  test('should escape an escape sequence with no parameters', () {
    check(EscapeSequence('m'))
        .has((p) => p.toEscapedString(), 'toEscapedString')
        .equals('\x1B[m');
  });

  test('should escape an escape sequence with a single parameter', () {
    check(EscapeSequence('m', [1]))
        .has((p) => p.toEscapedString(), 'toEscapedString')
        .equals('\x1B[1m');
  });

  test('should escape an escape sequence with multiple parameters', () {
    check(EscapeSequence('m', [1, 2]))
        .has((p) => p.toEscapedString(), 'toEscapedString')
        .equals('\x1B[1;2m');
  });

  test('should escape an escape sequence with a single default parameter', () {
    check(EscapeSequence('m', [1], [1]))
        .has((p) => p.toEscapedString(), 'toEscapedString')
        .equals('\x1B[m');
  });

  test('should escape an escape sequence with multiple default parameters', () {
    check(EscapeSequence('m', [1, 2], [1, 2]))
        .has((p) => p.toEscapedString(), 'toEscapedString')
        .equals('\x1B[m');
  });

  test('should not escape if a trailing default parameter is missing', () {
    check(EscapeSequence('m', [1, 2], [1, 1]))
        .has((p) => p.toEscapedString(), 'toEscapedString')
        .equals('\x1B[1;2m');
  });

  test('should return a terse representation of a literal', () {
    check(Literal('Hello, World!'))
        .has((p) => p.toTerse(), 'toTerse')
        .equals(Literal('Hello, World!'));
  });

  test('should return a terse representation of an escape sequence', () {
    check(EscapeSequence('m', [2, 1], [1, 1]))
        .has((p) => p.toTerse(), 'toTerse')
        .equals(EscapeSequence('m', [2]));
  });
}
