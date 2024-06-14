import 'package:dt/rendering.dart';
import 'package:dt/terminal.dart';

import '../prelude.dart';

void main() {
  group('Terminal', () {
    test('draws to a buffer', () {
      final backend = TestBackend(5, 5);
      final terminal = Terminal.fromBackend(backend);

      terminal.draw((frame) {
        frame.draw((buffer) {
          buffer.print(0, 0, 'Hello');
          buffer.print(0, 1, 'World');
          buffer.print(0, 2, '!!!!!');
          buffer.print(0, 3, '?????');
          buffer.print(0, 4, '#####');
        });
      });

      check(backend).has((b) => b.buffer.rows, 'buffer.rows').deepEquals([
        [Cell('H'), Cell('e'), Cell('l'), Cell('l'), Cell('o')],
        [Cell('W'), Cell('o'), Cell('r'), Cell('l'), Cell('d')],
        [Cell('!'), Cell('!'), Cell('!'), Cell('!'), Cell('!')],
        [Cell('?'), Cell('?'), Cell('?'), Cell('?'), Cell('?')],
        [Cell('#'), Cell('#'), Cell('#'), Cell('#'), Cell('#')],
      ]);
    });
  });
}
