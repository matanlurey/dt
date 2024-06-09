import 'package:dt/layout.dart';

import '../prelude.dart';

void main() {
  test('Margin.zero is (0, 0, 0, 0)', () {
    // ignore: use_named_constants
    check(Margin.zero).equals(const Margin.fromLTRB(0, 0, 0, 0));
  });

  test('Margin.all(1) is (1, 1, 1, 1)', () {
    check(const Margin.all(1)).equals(const Margin.fromLTRB(1, 1, 1, 1));
  });

  test('Margin.only(left: 1) is (1, 0, 0, 0)', () {
    check(const Margin.only(left: 1)).equals(
      const Margin.fromLTRB(1, 0, 0, 0),
    );
  });

  test('Margin.only(top: 1) is (0, 1, 0, 0)', () {
    check(const Margin.only(top: 1)).equals(
      const Margin.fromLTRB(0, 1, 0, 0),
    );
  });

  test('Margin.only(right: 1) is (0, 0, 1, 0)', () {
    check(const Margin.only(right: 1)).equals(
      const Margin.fromLTRB(0, 0, 1, 0),
    );
  });

  test('Margin.only(bottom: 1) is (0, 0, 0, 1)', () {
    check(const Margin.only(bottom: 1)).equals(
      const Margin.fromLTRB(0, 0, 0, 1),
    );
  });

  test('Margin.fromLTRB(1, 2, 3, 4) is (1, 2, 3, 4)', () {
    check(const Margin.fromLTRB(1, 2, 3, 4)).equals(
      const Margin.fromLTRB(1, 2, 3, 4),
    );
    check(const Margin.fromLTRB(1, 2, 3, 4))
        .has((m) => m.hashCode, 'hashCode')
        .equals(const Margin.fromLTRB(1, 2, 3, 4).hashCode);
  });

  test('Margin.symmetric(vertical: 1, horizontal: 2) is (2, 1, 2, 1)', () {
    check(const Margin.symmetric(vertical: 1, horizontal: 2)).equals(
      const Margin.fromLTRB(2, 1, 2, 1),
    );
  });

  test('Margin.zero has a toString', () {
    check(Margin.zero)
        .has((m) => m.toString(), 'toString')
        .equals('Margin.zero');
  });

  test('Margin.all(1) has a toString', () {
    check(const Margin.all(1))
        .has((m) => m.toString(), 'toString')
        .equals('Margin.all(1)');
  });

  test('Margin.fromLTRB(1, 2, 3, 4) has a toString', () {
    check(const Margin.fromLTRB(1, 2, 3, 4))
        .has((m) => m.toString(), 'toString')
        .equals('Margin.fromLTRB(1, 2, 3, 4)');
  });

  test('Margin.symmetric(vertical: 1, horizontal: 2) has a toString', () {
    check(const Margin.symmetric(vertical: 1, horizontal: 2))
        .has((m) => m.toString(), 'toString')
        .equals('Margin.symmetric(vertical: 1, horizontal: 2)');
  });
}
