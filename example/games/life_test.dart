import 'package:dt/core.dart';
import 'package:test/test.dart';

import 'life.dart' as life;

/// Tests for the game of life.
void main() {
  test('game of life', () {
    final terminal = TerminalBuffer(const StringSpan());

    // Create a grid with a glider.
    final grid = GridBuffer.fromRows([
      [false, true, false, false, true],
      [false, false, true, true, true],
      [false, true, true, false, false],
      [false, false, false, false, false],
    ]);

    // Run the game of life.
    final loop = life.run(
      grid,
      terminal: terminal,
      output: terminal,
    );

    // Write out the grid.
    loop.update();
    expect(terminal.lines, [
      '  # #',
      '    #',
      ' ##  ',
      '     ',
      '',
    ]);

    // Update the grid.
    loop.update();

    // Check the grid.
    expect(terminal.lines, [
      '   # ',
      ' ##  ',
      '     ',
      '     ',
      '',
    ]);

    // Update the grid.
    loop.update();

    // Check the grid.
    expect(terminal.lines, [
      '  #  ',
      '  #  ',
      '     ',
      '     ',
      '',
    ]);

    // Update the grid.
    loop.update();

    // Check the grid.
    expect(terminal.lines, [
      '     ',
      '     ',
      '     ',
      '     ',
      '',
    ]);
  });
}
