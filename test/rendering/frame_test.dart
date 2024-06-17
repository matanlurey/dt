import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';
import 'package:dt/terminal.dart';

import '../prelude.dart';

void main() {
  test('Frame.size returns the size of the buffer', () {
    final buffer = Buffer(4, 2);
    final frame = Frame(buffer);

    check(frame.size).equals(const Rect.fromLTWH(0, 0, 4, 2));
  });

  test('Frame.draw defaults to the entire buffer', () {
    final buffer = Buffer(4, 2);
    final frame = Frame(buffer);

    frame.draw((b) {
      b.set(0, 0, Cell('#'));
    });

    check(buffer.rows.map((r) => r.map((c) => c.symbol))).deepEquals([
      ['#', ' ', ' ', ' '],
      [' ', ' ', ' ', ' '],
    ]);
  });

  test('Frame.draw can draw within bounds', () {
    final buffer = Buffer(4, 2);
    final frame = Frame(buffer);

    frame.draw(
      (b) {
        b.set(0, 0, Cell('#'));
      },
      const Rect.fromLTWH(1, 0, 2, 1),
    );

    check(buffer.rows.map((r) => r.map((c) => c.symbol))).deepEquals([
      [' ', '#', ' ', ' '],
      [' ', ' ', ' ', ' '],
    ]);
  });
}
