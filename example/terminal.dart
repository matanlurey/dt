import 'package:dt/dt.dart';

void main() {
  final terminal = Terminal(
    const StringSpan(),
    lines: ['Hello, World!'],
  );

  // World isn't that impressive, let's replace it with Dart!
  terminal.cursor.column -= 6;
  terminal.write('Dart!');

  print(terminal.toDebugString(drawBorder: true, includeCursor: true));
}
