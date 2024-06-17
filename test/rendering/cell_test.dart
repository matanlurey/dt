import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  test('defaults to an empty cell', () {
    check(Cell.empty).equals(Cell());
  });

  test('content and style are set', () {
    final style = Style();
    check(Cell('H', style))
      ..equals(Cell('H', style))
      ..has((c) => c.hashCode, 'hashCode').equals(Cell('H', style).hashCode);
  });

  test('toString returns "Cell(content, style)"', () {
    check(Cell('H'))
        .has((c) => c.toString(), 'toString')
        .equals('Cell("H", Style.reset)');
  });

  test('toString returns Cell.empty', () {
    check(Cell.empty).has((c) => c.toString(), 'toString').equals('Cell.empty');
  });

  test('copyWith returns a new cell with the given content and style', () {
    final cell = Cell('H');
    final newCell = cell.copyWith(symbol: 'W');
    check(newCell).equals(Cell('W'));
  });

  test('copyWith does nothing if no properties are provided', () {
    final cell = Cell('H');
    final newCell = cell.copyWith();
    check(newCell).equals(cell);
  });

  test('rejection of multi-character symbols', () {
    check(() => Cell('Hello')).throws<ArgumentError>();
  });
}
