import 'package:dt/layout.dart';

import '../prelude.dart';

void main() {
  test('Spacing.none', () {
    check(Spacing.none)
      ..has((s) => s.left, 'left').equals(0)
      ..has((s) => s.top, 'top').equals(0)
      ..has((s) => s.right, 'right').equals(0)
      ..has((s) => s.bottom, 'bottom').equals(0)
      ..has((s) => s.toString(), 'toString()').equals('Spacing.none');
  });

  test('Spacing.all', () {
    check(Spacing.all(1))
      ..has((s) => s.left, 'left').equals(1)
      ..has((s) => s.top, 'top').equals(1)
      ..has((s) => s.right, 'right').equals(1)
      ..has((s) => s.bottom, 'bottom').equals(1)
      ..has((s) => s.toString(), 'toString()').equals('Spacing.all(1)');
  });

  test('Spacing.symmetric', () {
    check(Spacing.symmetric(horizontal: 1, vertical: 2))
      ..has((s) => s.left, 'left').equals(1)
      ..has((s) => s.top, 'top').equals(2)
      ..has((s) => s.right, 'right').equals(1)
      ..has((s) => s.bottom, 'bottom').equals(2)
      ..has((s) => s.toString(), 'toString()')
          .equals('Spacing.symmetric(vertical: 2, horizontal: 1)');
  });

  test('Spacing.horizontal', () {
    check(Spacing.horizontal(value: 1))
      ..has((s) => s.left, 'left').equals(1)
      ..has((s) => s.top, 'top').equals(0)
      ..has((s) => s.right, 'right').equals(1)
      ..has((s) => s.bottom, 'bottom').equals(0)
      ..has((s) => s.toString(), 'toString()').equals('Spacing.horizontal(1)');
  });

  test('Spacing.vertical', () {
    check(Spacing.vertical(value: 1))
      ..has((s) => s.left, 'left').equals(0)
      ..has((s) => s.top, 'top').equals(1)
      ..has((s) => s.right, 'right').equals(0)
      ..has((s) => s.bottom, 'bottom').equals(1)
      ..has((s) => s.toString(), 'toString()').equals('Spacing.vertical(1)');
  });

  test('Spacing.fromLTRB', () {
    check(Spacing.fromLTRB(1, 2, 3, 4))
      ..has((s) => s.left, 'left').equals(1)
      ..has((s) => s.top, 'top').equals(2)
      ..has((s) => s.right, 'right').equals(3)
      ..has((s) => s.bottom, 'bottom').equals(4)
      ..has((s) => s.toString(), 'toString()')
          .equals('Spacing.fromLTRB(1, 2, 3, 4)');
  });

  test('Spacing.only', () {
    check(Spacing.only(left: 1, top: 2, right: 3, bottom: 4))
      ..has((s) => s.left, 'left').equals(1)
      ..has((s) => s.top, 'top').equals(2)
      ..has((s) => s.right, 'right').equals(3)
      ..has((s) => s.bottom, 'bottom').equals(4)
      ..has((s) => s.toString(), 'toString()')
          .equals('Spacing.fromLTRB(1, 2, 3, 4)');
  });

  test('horizontal', () {
    check(Spacing.fromLTRB(1, 2, 3, 4))
        .has((s) => s.horizontal, 'horizontal')
        .equals(4);
  });

  test('vertical', () {
    check(Spacing.fromLTRB(1, 2, 3, 4))
        .has((s) => s.vertical, 'vertical')
        .equals(6);
  });

  test('== and hashCode', () {
    check(Spacing.fromLTRB(1, 2, 3, 4))
      ..has((s) => s.hashCode, 'hashCode')
          .equals(Spacing.fromLTRB(1, 2, 3, 4).hashCode)
      ..equals(Spacing.fromLTRB(1, 2, 3, 4));
  });
}
