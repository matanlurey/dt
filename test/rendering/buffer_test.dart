// ignore_for_file: avoid_redundant_argument_values, non_const_call_to_literal_constructor

import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  test('an empty buffer', () {
    check(Buffer.empty()).has((b) => b.cells, 'cells').isEmpty();
  });

  test('fromCells', () {
    final cells = [
      Cell('H'),
      Cell('e'),
      Cell('l'),
      Cell('l'),
      Cell('o'),
    ];
    final buffer = Buffer.fromCells(cells, width: 5);

    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [Cell('H'), Cell('e'), Cell('l'), Cell('l'), Cell('o')],
    ]);
  });

  test('fromRows', () {
    final rows = [
      [Cell('H'), Cell('e'), Cell('l'), Cell('l'), Cell('o')],
    ];
    final buffer = Buffer.fromRows(rows);

    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [Cell('H'), Cell('e'), Cell('l'), Cell('l'), Cell('o')],
    ]);
  });
  test('viewing a buffer', () {
    final buffer = Buffer(3, 3);
    final view = Buffer.view(buffer, Rect.fromXYWH(1, 1, 2, 2));

    check(view).has((b) => b.rows, 'rows').deepEquals([
      [Cell.empty, Cell.empty],
      [Cell.empty, Cell.empty],
    ]);

    view.set(0, 0, Cell('H'));
    check(view).has((b) => b.rows, 'rows').deepEquals([
      [Cell('H'), Cell.empty],
      [Cell.empty, Cell.empty],
    ]);

    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [Cell.empty, Cell.empty, Cell.empty],
      [Cell.empty, Cell('H'), Cell.empty],
      [Cell.empty, Cell.empty, Cell.empty],
    ]);
  });

  test('a 4x2 empty buffer', () {
    check(Buffer(4, 2)).has((b) => b.rows, 'rows').deepEquals([
      [Cell.empty, Cell.empty, Cell.empty, Cell.empty],
      [Cell.empty, Cell.empty, Cell.empty, Cell.empty],
    ]);
  });

  test('a 4x2 buffer with a fill character', () {
    check(Buffer(4, 2, Cell('H'))).has((b) => b.rows, 'rows').deepEquals([
      [Cell('H'), Cell('H'), Cell('H'), Cell('H')],
      [Cell('H'), Cell('H'), Cell('H'), Cell('H')],
    ]);
  });

  test('a 4x2 buffer made from lines', () {
    final lines = [
      Line([Span('Hello')]),
      Line([Span('World')]),
    ];
    final buffer = Buffer.fromLines(lines);

    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [Cell('H'), Cell('e'), Cell('l'), Cell('l'), Cell('o')],
      [Cell('W'), Cell('o'), Cell('r'), Cell('l'), Cell('d')],
    ]);
  });

  test('cells are in row-major order', () {
    final buffer = Buffer.fromLines([
      Line([Span('Hello')]),
      Line([Span('World')]),
    ]);

    check(buffer).has((b) => b.cells, 'cells').deepEquals([
      Cell('H'), Cell('e'), Cell('l'), Cell('l'), Cell('o'), //
      Cell('W'), Cell('o'), Cell('r'), Cell('l'), Cell('d'), //
    ]);
  });

  test('printing a string to a buffer', () {
    final buffer = Buffer(10, 2);
    buffer.print(0, 0, 'Hello, World!');

    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell('H'),
        Cell('e'),
        Cell('l'),
        Cell('l'),
        Cell('o'),
        Cell(','),
        Cell(' '),
        Cell('W'),
        Cell('o'),
        Cell('r'),
      ],
      [
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ],
    ]);
  });

  test('printing a span to a buffer', () {
    final buffer = Buffer(10, 2);
    buffer.printSpan(0, 0, Span('Hello, World!'));

    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell('H'),
        Cell('e'),
        Cell('l'),
        Cell('l'),
        Cell('o'),
        Cell(','),
        Cell(' '),
        Cell('W'),
        Cell('o'),
        Cell('r'),
      ],
      [
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ],
    ]);
  });

  test('fill a buffer with a cell', () {
    final buffer = Buffer(10, 2);
    buffer.fillCells(Cell('H'));

    check(buffer)
        .has((b) => b.cells, 'cells')
        .every((c) => c.equals(Cell('H')));
  });

  test('fill an entire buffer with a style', () {
    final buffer = Buffer(10, 2);
    final style = Style(background: AnsiColor.red);
    buffer.fillStyle(style);

    final expected = Cell(' ', style);
    check(buffer).has((b) => b.cells, 'cells').every((c) => c.equals(expected));
  });

  test('fill part of a buffer with a style', () {
    final buffer = Buffer(10, 2);
    final style = Style(background: AnsiColor.red);
    buffer.fillStyle(style, Rect.fromXYWH(1, 1, 6, 1));

    final expected = Cell(' ', style);
    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ],
      [
        Cell.empty,
        expected,
        expected,
        expected,
        expected,
        expected,
        expected,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ],
    ]);
  });

  test('Buffer.within returns a view into the buffer', () {
    final buffer = Buffer(10, 2);
    final view = buffer.subGrid(Rect.fromXYWH(1, 1, 6, 1));

    check(view).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ],
    ]);

    view.set(0, 0, Cell('H'));
    check(view).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell('H'),
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ],
    ]);

    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ],
      [
        Cell.empty,
        Cell('H'),
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
        Cell.empty,
      ],
    ]);
  });

  test('Buffer.within outside the buffer throws an error', () {
    final buffer = Buffer(10, 2);

    check(
      () => buffer.subGrid(Rect.fromXYWH(1, 1, 10, 2)),
    ).throws<ArgumentError>();
  });

  test('Buffer.within.within (nested) returns a view into the buffer', () {
    // 0 1 2
    // 3 4 5
    // 6 7 8
    final buffer = Buffer(3, 3);

    // Create a view of the last 2x2 area.
    // 4 5
    // 7 8
    final view1 = buffer.subGrid(Rect.fromXYWH(1, 1, 2, 2));

    // Create a view of the first 2x1 area.
    // 4 5
    final view2 = view1.subGrid(Rect.fromXYWH(0, 0, 2, 1));

    // Draw a character to the inner view.
    view2.set(1, 0, Cell('#'));

    // The inner view should have the character.
    check(view2).has((b) => b.rows, 'rows').deepEquals([
      [Cell(' '), Cell('#')],
    ]);

    check(view2).has((b) => b.cells, 'cells').deepEquals([
      Cell(' '),
      Cell('#'),
    ]);

    // The outer view should have the character.
    check(view1).has((b) => b.rows, 'rows').deepEquals([
      [Cell(' '), Cell('#')],
      [Cell(' '), Cell(' ')],
    ]);

    // The original buffer should have the character.
    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [Cell(' '), Cell(' '), Cell(' ')],
      [Cell(' '), Cell(' '), Cell('#')],
      [Cell(' '), Cell(' '), Cell(' ')],
    ]);
  });
}
