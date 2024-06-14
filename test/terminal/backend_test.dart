// ignore_for_file: avoid_redundant_argument_values

import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';
import 'package:dt/terminal.dart';

import '../prelude.dart';

void main() {
  group('TestBackend', () {
    test('starts with an empty buffer', () {
      final backend = TestBackend(3, 3);

      check(backend)
        ..has((b) => b.buffer.rows, 'buffer.rows').deepEquals([
          [Cell(' '), Cell(' '), Cell(' ')],
          [Cell(' '), Cell(' '), Cell(' ')],
          [Cell(' '), Cell(' '), Cell(' ')],
        ])
        ..has((b) => b.isCursorVisible, 'isCursorVisible').equals(true)
        ..has((b) => b.cursorPosition, 'cursorPosition').equals(Offset.zero)
        ..has((b) => b.size, 'size').equals((3, 3));
    });

    test('draws to and then resizes an existing buffer', () {
      final backend = TestBackend(2, 2);

      backend
        ..draw(0, 0, Cell('#'))
        ..draw(1, 0, Cell('#'))
        ..draw(0, 1, Cell('#'))
        ..draw(1, 1, Cell('#'));

      check(backend).has((b) => b.buffer.rows, 'buffer.rows').deepEquals([
        [Cell('#'), Cell('#')],
        [Cell('#'), Cell('#')],
      ]);

      backend.resize(3, 3);

      check(backend).has((b) => b.buffer.rows, 'buffer.rows').deepEquals([
        [Cell('#'), Cell('#'), Cell(' ')],
        [Cell('#'), Cell('#'), Cell(' ')],
        [Cell(' '), Cell(' '), Cell(' ')],
      ]);
    });

    test('draws a red/green cell', () {
      final backend = TestBackend(2, 1);

      backend.draw(
        0,
        0,
        Cell(
          ' ',
          Style(foreground: AnsiColor.red, background: AnsiColor.green),
        ),
      );

      check(backend).has((b) => b.buffer.rows, 'buffer.rows').deepEquals([
        [
          Cell(
            ' ',
            Style(foreground: AnsiColor.red, background: AnsiColor.green),
          ),
          Cell(' '),
        ],
      ]);
    });

    test('sets, moves, checks, and hides the cursor', () {
      final backend = TestBackend(3, 3);

      backend.moveCursorTo(1, 1);
      check(backend)
          .has((b) => b.cursorPosition, 'cursorPosition')
          .equals(const Offset(1, 1));

      backend.hideCursor();
      check(backend)
          .has((b) => b.isCursorVisible, 'isCursorVisible')
          .equals(false);

      backend.showCursor();
      check(backend)
          .has((b) => b.isCursorVisible, 'isCursorVisible')
          .equals(true);
    });

    test('clears the screen', () {
      final backend = TestBackend(3, 3);

      backend
        ..draw(0, 0, Cell('#'))
        ..draw(1, 1, Cell('#'))
        ..draw(2, 2, Cell('#'));

      backend.clear();

      check(backend).has((b) => b.buffer.rows, 'buffer.rows').deepEquals([
        [Cell(' '), Cell(' '), Cell(' ')],
        [Cell(' '), Cell(' '), Cell(' ')],
        [Cell(' '), Cell(' '), Cell(' ')],
      ]);
    });
  });
}
