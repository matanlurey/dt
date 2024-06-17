import 'package:dt/backend.dart';
import 'package:dt/src/rendering/cell.dart';

import '../prelude.dart';

void main() {
  test('drawBatch invokes draw(...) by default', () {
    final output = <(int, int, Cell)>[];
    final backend = _TestBackend(output, const (10, 1));

    backend.drawBatch([
      Cell('H'),
      Cell('e'),
      Cell('l'),
      Cell('l'),
      Cell('o'),
      Cell('W'),
      Cell('o'),
      Cell('r'),
      Cell('l'),
      Cell('d'),
    ]);

    check(output).deepEquals([
      (0, 0, Cell('H')),
      (1, 0, Cell('e')),
      (2, 0, Cell('l')),
      (3, 0, Cell('l')),
      (4, 0, Cell('o')),
      (5, 0, Cell('W')),
      (6, 0, Cell('o')),
      (7, 0, Cell('r')),
      (8, 0, Cell('l')),
      (9, 0, Cell('d')),
    ]);
  });
}

final class _TestBackend with SurfaceBackend {
  const _TestBackend(this.output, this.size);
  final List<(int x, int y, Cell cell)> output;

  @override
  void draw(int x, int y, Cell cell) {
    output.add((x, y, cell));
  }

  @override
  noSuchMethod(Invocation _) => super.noSuchMethod(_);

  @override
  final (int, int) size;
}
