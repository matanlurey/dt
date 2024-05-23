import 'dart:io' as io show stdout;

void main() async {
  // Print "Hello, World!" to the terminal.
  io.stdout.writeln('Hello, World!');

  // Print "Goodbye, World!" to the terminal.
  io.stdout.writeln('Goodbye, World!');

  await Future<void>.delayed(const Duration(seconds: 1));

  // Move the cursor up two lines and to the right 20 columns.
  io.stdout.write('\x1b[2A\x1b[20C');

  // Hold for 1s.
  await Future<void>.delayed(const Duration(seconds: 1));

  // Move down 8 lines.
  io.stdout.write('\x1b[8B');

  // Hold for 1s.
  await Future<void>.delayed(const Duration(seconds: 1));
}
