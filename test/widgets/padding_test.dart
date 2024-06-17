import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';
import 'package:dt/widgets.dart';

import '../prelude.dart';

void main() {
  test('Padding(Spacing.none)', () {
    final buffer = Buffer(8, 5);

    Padding(
      child: Text('Hello'),
      spacing: Spacing.none,
    ).draw(buffer);

    check(buffer).equalsSymbolBox([
      'Hello   ',
      '        ',
      '        ',
      '        ',
      '        ',
    ]);
  });

  test('Padding(Spacing.horizontal)', () {
    final buffer = Buffer(8, 5);

    Padding(
      child: Text('Hello'),
      spacing: Spacing.symmetric(horizontal: 1),
    ).draw(buffer);

    check(buffer).equalsSymbolBox([
      ' Hello  ',
      '        ',
      '        ',
      '        ',
      '        ',
    ]);
  });

  test('Padding(Spacing.vertical)', () {
    final buffer = Buffer(8, 5);

    Padding(
      child: Text('Hello'),
      spacing: Spacing.symmetric(vertical: 1),
    ).draw(buffer);

    check(buffer).equalsSymbolBox([
      '        ',
      'Hello   ',
      '        ',
      '        ',
      '        ',
    ]);
  });

  test('Padding(Spacing.fromLTRB)', () {
    final buffer = Buffer(8, 5);

    Padding(
      child: Text('Hello'),
      spacing: Spacing.fromLTRB(2, 2, 0, 0),
    ).draw(buffer);

    check(buffer).equalsSymbolBox([
      '        ',
      '        ',
      '  Hello ',
      '        ',
      '        ',
    ]);
  });
}
