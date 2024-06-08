import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:dt/foundation.dart';

/// Simulates Conway's Game of Life in the terminal.
void main() async {
  final random = math.Random();
  final width = io.stdout.terminalColumns;
  final world = List.generate(
    io.stdout.terminalLines * width,
    (_) => random.nextBool(),
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
      width: width,
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
  List<bool> world, {
  required int width,
  required Future<void> done,
  Future<void> Function() wait = _wait250ms,
}) async {
  final height = world.length ~/ width;

  bool get(List<bool> world, int x, int y) => world[y * width + x];

  // ignore: avoid_positional_boolean_parameters
  void set(List<bool> world, int x, int y, bool value) {
    world[y * width + x] = value;
  }

  var running = true;
  unawaited(done.whenComplete(() => running = false));

  while (running) {
    final buffer = StringBuffer();

    // Move to the top-left corner and clear the screen.
    io.stdout.write(MoveCursorTo().toSequence().toEscapedString());
    io.stdout.write(ClearScreen.all.toSequence().toEscapedString());

    // Write the world to the buffer.
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        buffer.write(get(world, x, y) ? '█' : ' ');
      }
      buffer.writeln();
    }

    // Write the buffer to the output.
    out.write(buffer.toString());
    await wait();

    // Evolution.
    final next = List.filled(world.length, false);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        var alive = 0;
        for (final [dx, dy] in _neighbors) {
          final nx = x + dx;
          final ny = y + dy;
          if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
            alive += get(world, nx, ny) ? 1 : 0;
          }
        }
        set(next, x, y, alive == 3 || (alive == 2 && get(world, x, y)));
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
