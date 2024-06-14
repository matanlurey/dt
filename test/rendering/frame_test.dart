import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  test('Frame.pump can pump 10 frames', () async {
    final buffer = Buffer(4, 2);
    final frames = await Frame.pump(() => buffer).take(10).toList();

    check(frames.map((f) => f.count)).deepEquals(
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    );
  });

  test('Frame.size returns the size of the buffer', () {
    final buffer = Buffer(4, 2);
    final frame = Frame(buffer);

    check(frame.size).equals(const Rect.fromXYWH(0, 0, 4, 2));
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
      const Rect.fromXYWH(1, 0, 2, 1),
    );

    check(buffer.rows.map((r) => r.map((c) => c.symbol))).deepEquals([
      [' ', '#', ' ', ' '],
      [' ', ' ', ' ', ' '],
    ]);
  });
}
