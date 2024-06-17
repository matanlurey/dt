import 'package:dt/rendering.dart';
import 'package:dt/widgets.dart';

import '../prelude.dart';

void main() {
  test('Footer', () {
    // Create a buffer of 2 rows and 10 columns.
    final buffer = Buffer(10, 2);

    // Create a footer widget that draws a string at the bottom of the buffer.
    final footer = Footer(
      main: Text('Hello, World!'),
      footer: Text('Footer'),
      height: 1,
    );

    // Draw the footer on the buffer.
    footer.draw(buffer);

    // Check that the buffer has the expected rows.
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
        Cell('F'),
        Cell('o'),
        Cell('o'),
        Cell('t'),
        Cell('e'),
        Cell('r'),
        Cell(' '),
        Cell(' '),
        Cell(' '),
        Cell(' '),
      ],
    ]);
  });
}
