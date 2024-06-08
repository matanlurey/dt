import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:dt/foundation.dart';

/// Simulates Conway's Game of Life in the terminal.
void main() async {
  final random = math.Random();
  final world = Grid.generate(
    io.stdout.terminalColumns,
    io.stdout.terminalLines,
    (x, y) => random.nextBool(),
  );
  try {
    // Switch to the alternate screen buffer.
    io.stdout.write(AlternateScreenBuffer.enter.toSequence().toEscapedString());

    // Hide the cursor.
    io.stdout.write(SetCursorVisibility.hidden.toSequence().toEscapedString());

    // Enable raw mode.
    io.stdin
      ..echoMode = false
      ..lineMode = false;

    await run(
      StringWriter(Writer.fromSink(io.stdout, onFlush: io.stdout.flush)),
      world,
      done: io.ProcessSignal.sigint.watch().first,
    );
  } finally {
    // Disable raw mode.
    io.stdin
      ..echoMode = true
      ..lineMode = true;

    // Show the cursor.
    io.stdout.write(SetCursorVisibility.visible.toSequence().toEscapedString());

    // Switch back to the main screen buffer.
    io.stdout.write(AlternateScreenBuffer.leave.toSequence().toEscapedString());
  }
}

Future<void> run(
  StringWriter out,
  Grid<bool> world, {
  required Future<void> done,
  Future<void> Function() wait = _wait250ms,
}) async {
  var running = true;
  unawaited(done.whenComplete(() => running = false));
  while (running) {
    final buffer = StringBuffer();

    // Move to the top-left corner and clear the screen.
    io.stdout.write(MoveCursorTo().toSequence().toEscapedString());
    io.stdout.write(ClearScreen.all.toSequence().toEscapedString());

    // Write the world to the buffer.
    for (final row in world.rows) {
      for (final cell in row) {
        buffer.write(cell ? '█' : ' ');
      }
      buffer.writeln();
    }

    // Write the buffer to the output.
    out.write(buffer.toString());
    await wait();

    // Evolution.
    final next = Grid.filled(world.width, world.height, false);
    for (var y = 0; y < world.height; y++) {
      for (var x = 0; x < world.width; x++) {
        var alive = 0;
        for (final [dx, dy] in _neighbors) {
          final nx = x + dx;
          final ny = y + dy;
          if (nx >= 0 && nx < world.width && ny >= 0 && ny < world.height) {
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
