import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';
import 'package:dt/widgets.dart';

import '../prelude.dart';

void main() {
  test('Layout', () {
    // Create a buffer of 4 rows and 4 columns.
    final buffer = Buffer(4, 4);

    // Create a layout that splits the buffer into 2 rows and 2 columns.
    final layout = Layout(
      FixedHeightRows(height: 2),
      [
        Text('A'),
        Text('B'),
      ],
    );

    // Draw the layout on the buffer.
    layout.draw(buffer);

    // Check that the buffer has the expected rows.
    check(buffer).has((b) => b.rows, 'rows').deepEquals([
      [
        Cell('A'),
        Cell(' '),
        Cell(' '),
        Cell(' '),
      ],
      [
        Cell(' '),
        Cell(' '),
        Cell(' '),
        Cell(' '),
      ],
      [
        Cell('B'),
        Cell(' '),
        Cell(' '),
        Cell(' '),
      ],
      [
        Cell(' '),
        Cell(' '),
        Cell(' '),
        Cell(' '),
      ],
    ]);
  });

  test('Layout throws if children > areas', () {
    check(
      () => Layout(
        FixedHeightRows(height: 8),
        [
          Text('A'),
          Text('A'),
        ],
      ).draw(Buffer(10, 10)),
    ).throws<StateError>();
  });
}
