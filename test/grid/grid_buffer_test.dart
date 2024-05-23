import 'package:dt/dt.dart';
import 'package:test/test.dart';

void main() {
  test('GridBuffer.filled sets initial values', () {
    final grid = GridBuffer.filled(3, 3, ' ');

    expect(grid.rows, [
      [' ', ' ', ' '],
      [' ', ' ', ' '],
      [' ', ' ', ' '],
    ]);
  });

  test('GridBuffer.generate sets initial values', () {
    final grid = GridBuffer.generate(3, 3, (row, col) {
      return '$row:$col';
    });

    expect(grid.rows, [
      ['0:0', '0:1', '0:2'],
      ['1:0', '1:1', '1:2'],
      ['2:0', '2:1', '2:2'],
    ]);
  });

  test('GridBuffer.fromBuffer copies a buffer', () {
    final grid = GridBuffer.fromBuffer(
      ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
      width: 3,
    );

    expect(grid.rows, [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ]);
  });

  test('GridBuffer.fromRows copies rows', () {
    final grid = GridBuffer.fromRows([
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ]);

    expect(grid.rows, [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ]);
  });
}
