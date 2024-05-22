import 'dart:io' as io show stdout;

void main() async {
  // Print "Hello, World!" to the terminal.
  io.stdout.writeln('Hello, World!');

  // Print "Goodbye, World!" to the terminal.
  io.stdout.writeln('Goodbye, World!');

  // Move the cursor up two lines and to the right 2 columns.
  io.stdout.write('\x1b[2A\x1b[2C');

  // Hold for 1s.
  await Future<void>.delayed(const Duration(seconds: 1));

  // Clear the current line.
  io.stdout.write('\x1b[2K');

  // Hold for 1s.
  await Future<void>.delayed(const Duration(seconds: 1));
}
