import 'dart:io' as io;

import 'package:dt/rendering.dart';
import 'package:dt/widgets.dart';

void main() async {
  final buffer = Buffer(io.stdout.terminalColumns, io.stdout.terminalLines - 1);
  await run(buffer);

  // Draw the buffer to the terminal manually.
  io.stdout.write(
    buffer.rows.map((row) => row.map((cell) => cell.symbol).join()).join('\n'),
  );
}

Future<void> run(Buffer buffer) async {
  Footer(
    main: Text('Hello, World!'),
    footer: Text('-' * buffer.width),
    height: 1,
  ).draw(buffer);
}
