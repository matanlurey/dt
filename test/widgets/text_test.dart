import 'package:dt/rendering.dart';
import 'package:dt/widgets.dart';

import '../prelude.dart';

void main() {
  test('TextAlign.left', () {
    // Create a buffer of 1 row and 10 columns.
    final buffer = Buffer(10, 1);

    // Create a text widget that draws a string at the left of the buffer.
    final text = Text('Hello');

    // Draw the text on the buffer.
    text.draw(buffer);

    // Check that the buffer has the expected row.
    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell('H'),
        Cell('e'),
        Cell('l'),
        Cell('l'),
        Cell('o'),
        Cell(' '),
        Cell(' '),
        Cell(' '),
        Cell(' '),
        Cell(' '),
      ],
    ]);
  });

  test('TextAlign.center', () {
    // Create a buffer of 1 row and 10 columns.
    final buffer = Buffer(10, 1);

    // Create a text widget that draws a string at the center of the buffer.
    final text = Text.fromLine(
      Line(
        [Span('Hello')],
        alignment: Alignment.center,
      ),
    );

    // Draw the text on the buffer.
    text.draw(buffer);

    // Check that the buffer has the expected row.
    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell(' '),
        Cell(' '),
        Cell('H'),
        Cell('e'),
        Cell('l'),
        Cell('l'),
        Cell('o'),
        Cell(' '),
        Cell(' '),
        Cell(' '),
      ],
    ]);
  });

  test('TextAlign.right', () {
    // Create a buffer of 1 row and 10 columns.
    final buffer = Buffer(10, 1);

    // Create a text widget that draws a string at the right of the buffer.
    final text = Text.fromLine(
      Line(
        [Span('Hello')],
        alignment: Alignment.right,
      ),
    );

    // Draw the text on the buffer.
    text.draw(buffer);

    // Check that the buffer has the expected row.
    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell(' '),
        Cell(' '),
        Cell(' '),
        Cell(' '),
        Cell(' '),
        Cell('H'),
        Cell('e'),
        Cell('l'),
        Cell('l'),
        Cell('o'),
      ],
    ]);
  });
}
