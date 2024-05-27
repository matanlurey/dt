import 'package:dt/core.dart';

void main() {
  final grid = GridBuffer.filled(3, 3, ' ');

  // An in-progress game of tic-tac-toe.
  grid.setCell(1, 1, 'X');
  grid.setCell(0, 0, 'O');
  grid.setCell(2, 2, 'X');

  print(grid.toDebugString(drawGrid: true));
}
