import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:dt/ansi.dart';
import 'package:dt/app.dart';
import 'package:dt/core.dart';

void main() async {
  // Get the width and height of the terminal.
  final width = io.stdout.terminalColumns;
  final height = io.stdout.terminalLines;
  final terminal = AnsiTerminal<String>.stdout();

  try {
    // Raw mode and hide the cursor.
    io.stdin.echoMode = false;
    io.stdin.lineMode = false;
    terminal.cursor.hide();

    // Create an initial random grid.
    final random = Random();
    final grid = GridBuffer.generate(
      width,
      height - 1,
      (_, __) => random.nextBool(),
    );

    final app = run(
      grid,
      terminal: terminal,
      output: terminal,
    );

    // Wait for any key to be pressed to stop the application.
    late final StreamSubscription<void> onKeyPress;
    late final StreamSubscription<void> onSigInt;
    onKeyPress = io.stdin.listen((_) {
      onKeyPress.cancel();
      onSigInt.cancel();
      app.stop();
    });

    // SIGINT (Ctrl+C) stops the application.
    onSigInt = io.ProcessSignal.sigint.watch().listen((_) {
      onKeyPress.cancel();
      onSigInt.cancel();
      app.stop();
    });

    await app.start();
    await (onKeyPress.cancel(), onSigInt.cancel()).wait;
  } finally {
    // Clear the screen.
    terminal.clearScreen();

    // Print a message.
    terminal.write('Goodbye!\n');

    // Restore the terminal.
    terminal.cursor.show();
  }
}

/// Runs the game of life.
///
/// The game of life is a cellular automaton simulation that evolves over time:
/// - Each cell has two states: alive or dead.
/// - The state of each cell is determined by its neighbors.
Loop run(
  GridBuffer<bool> grid, {
  required TerminalDriver terminal,
  required TerminalSink<String> output,
}) {
  // Neighbors for each cell.
  final neighbors = [
    for (var y = -1; y <= 1; y++)
      for (var x = -1; x <= 1; x++)
        if (x != 0 || y != 0) [x, y],
  ];

  // Updates the grid.
  //
  // 1. Any live cell with fewer than two live neighbors dies.
  // 2. Any live cell with two or three live neighbors lives.
  // 3. Any live cell with more than three live neighbors dies.
  // 4. Any dead cell with exactly three live neighbors becomes alive.
  void update() {
    final next = GridBuffer.generate(grid.width, grid.height, (_, __) => false);

    for (var y = 0; y < grid.height; y++) {
      for (var x = 0; x < grid.width; x++) {
        var alive = 0;
        for (final neighbor in neighbors) {
          final nx = x + neighbor[0];
          final ny = y + neighbor[1];
          if (nx >= 0 && nx < grid.width && ny >= 0 && ny < grid.height) {
            if (grid.getCell(ny, nx)) {
              alive++;
            }
          }
        }

        if (grid.getCell(y, x)) {
          next.setCell(y, x, alive == 2 || alive == 3);
        } else {
          next.setCell(y, x, alive == 3);
        }
      }
    }

    grid = next;
  }

  return Loop(() {
    update();

    // Clear the screen.
    terminal.clearScreen();

    // Draw the grid, placing a # for each alive cell.
    final buffer = StringBuffer();
    for (final row in grid.rows) {
      for (final cell in row) {
        buffer.write(cell ? '#' : ' ');
      }
      buffer.writeln();
    }

    // Write the buffer to the terminal.
    buffer.toString().split('\n').take(grid.height).forEach(output.writeLine);

    // Reset the cursor.
    terminal.cursor.reset();
  });
}
