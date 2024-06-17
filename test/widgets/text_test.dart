import 'package:dt/foundation.dart';
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
        ['Hello'],
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
        ['Hello'],
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

  test('Line with style', () {
    // Create a buffer of 1 row and 10 columns.
    final buffer = Buffer(10, 1);

    // Create a text widget that draws a string with a style.
    final text = Text.fromLine(
      Line(
        ['Hello'],
        style: Style(foreground: Color16.red),
      ),
    );

    // Draw the text on the buffer.
    text.draw(buffer);

    // Check that the buffer has the expected row.
    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell('H', Style(foreground: Color16.red)),
        Cell('e', Style(foreground: Color16.red)),
        Cell('l', Style(foreground: Color16.red)),
        Cell('l', Style(foreground: Color16.red)),
        Cell('o', Style(foreground: Color16.red)),
        Cell(' ', Style(foreground: Color16.red)),
        Cell(' ', Style(foreground: Color16.red)),
        Cell(' ', Style(foreground: Color16.red)),
        Cell(' ', Style(foreground: Color16.red)),
        Cell(' ', Style(foreground: Color16.red)),
      ],
    ]);
  });

  test('Two lines means the second line is not styled from the first', () {
    // Create a buffer of 2 rows and 5 columns.
    final buffer = Buffer(5, 2);

    // Create a text widget that draws two lines with different styles.
    final line1 = Line(
      ['Hello'],
      style: Style(foreground: Color16.red),
    );
    final line2 = Line(['World']);

    // Draw the text on the buffer.
    Text.fromLine(line1).draw(buffer.subGrid(const Rect.fromLTWH(0, 0, 5, 1)));
    Text.fromLine(line2).draw(buffer.subGrid(const Rect.fromLTWH(0, 1, 5, 1)));

    // Check that the buffer has the expected rows.
    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell('H', Style(foreground: Color16.red)),
        Cell('e', Style(foreground: Color16.red)),
        Cell('l', Style(foreground: Color16.red)),
        Cell('l', Style(foreground: Color16.red)),
        Cell('o', Style(foreground: Color16.red)),
      ],
      [
        Cell('W'),
        Cell('o'),
        Cell('r'),
        Cell('l'),
        Cell('d'),
      ],
    ]);
  });
}
