import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';
import 'package:dt/terminal.dart';
import 'package:dt/widgets.dart';

/// Simulates Conway's Game of Life in the terminal.
void main() async {
  final random = math.Random();
  final world = Grid.generate(
    io.stdout.terminalColumns,
    io.stdout.terminalLines - 1,
    (x, y) => random.nextBool(),
  );

  final terminal = Surface.fromStdio();
  try {
    await run(
      terminal,
      world,
      done: io.ProcessSignal.sigint.watch().first,
    );
  } finally {
    terminal.dispose();
  }
}

Future<void> run(
  Surface terminal,
  Grid<bool> world, {
  required Future<void> done,
  Future<void> Function() wait = _wait250ms,
}) async {
  final Grid(:width, :height) = world;

  var running = true;
  unawaited(done.whenComplete(() => running = false));

  while (running) {
    // Render.
    terminal.draw((frame) {
      frame.draw((buffer) {
        Footer(
          main: _WorldWidget(world),
          footer: Text('Press Ctrl+C to exit.'),
          height: 1,
        ).draw(buffer);
      });
    });

    // Delay.
    await wait();

    // Evolve.
    final next = Grid(width, height, false);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        var alive = 0;
        for (final [dx, dy] in _neighbors) {
          final nx = x + dx;
          final ny = y + dy;
          if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
            alive += world.get(nx, ny) ? 1 : 0;
          }
        }
        next.set(x, y, alive == 3 || (alive == 2 && world.get(x, y)));
      }
    }

    world = next;
  }
}

final _neighbors = [
  for (var x = -1; x <= 1; x++)
    for (var y = -1; y <= 1; y++)
      if (x != 0 || y != 0) [x, y],
];

Future<void> _wait250ms() async {
  await Future<void>.delayed(const Duration(milliseconds: 250));
}

final class _WorldWidget extends Widget {
  const _WorldWidget(this._world);
  final Grid<bool> _world;

  @override
  void draw(Buffer output) {
    for (var y = 0; y < _world.height; y++) {
      for (var x = 0; x < _world.width; x++) {
        final cell = _world.get(x, y) ? Cell('█') : Cell.empty;
        output.set(x, y, cell);
      }
    }
  }
}
