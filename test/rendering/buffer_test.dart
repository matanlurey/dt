// ignore_for_file: avoid_redundant_argument_values, non_const_call_to_literal_constructor

import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
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
}
