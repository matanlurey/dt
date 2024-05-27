import 'package:dt/core.dart';

void main() {
  final terminal = TerminalBuffer(
    const StringSpan(),
    lines: ['Hello, World!'],
  );

  // World isn't that impressive, let's replace it with Dart!
  terminal.cursor.moveLeft(6);
  terminal.write('Dart!');

  print(
    terminal.toDebugString(
      drawBorder: true,
      drawCursor: true,
      includeLineNumbers: true,
    ),
  );
}
