import 'package:dt/src/foundation/command.dart';
import 'package:dt/src/internal.dart';
import 'package:test/test.dart';

void main() {
  group('escapeSequence', () {
    test('returns with no parameters', () {
      expect(escapeSequence('a'), '\x1B[a');
    });

    test('returns with one parameter', () {
      expect(escapeSequence('a', [1]), '\x1B[1a');
    });

    test('returns with two parameters', () {
      expect(escapeSequence('a', [1, 2]), '\x1B[1;2a');
    });

    test('returns with one parameter as a default', () {
      expect(escapeSequence('a', [1], [1]), '\x1B[a');
    });

    test('returns with the last of 2 parameters as a default', () {
      expect(escapeSequence('a', [2, 1], [1, 1]), '\x1B[2a');
    });

    test('returns with both parameters as a default', () {
      expect(escapeSequence('a', [1, 1], [1, 1]), '\x1B[a');
    });

    test('returns with no defaults matching', () {
      expect(escapeSequence('a', [2, 2], [1, 1]), '\x1B[2;2a');
    });

    test('returns with both parameters since a trailing is not a default', () {
      expect(escapeSequence('a', [1, 2], [1, 1]), '\x1B[1;2a');
    });

    group(
      'when assertions enabled',
      () {
        test('throws when not a single character', () {
          expect(
            () => escapeSequence('ab'),
            throwsA(isA<AssertionError>()),
          );
        });

        test('throws when parameters are empty but defaults are not', () {
          expect(
            () => escapeSequence('a', [], [1]),
            throwsA(isA<AssertionError>()),
          );
        });

        test('throws when default parameters length not the same', () {
          expect(
            () => escapeSequence('a', [1], [1, 2]),
            throwsA(isA<AssertionError>()),
          );
        });
      },
      skip: !assertionsEnabled,
    );
  });
}
