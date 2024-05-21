import 'dart:io' as io;

void main() async {
  // Write 3 lines to stdout.
  io.stdout.writeln('1 Hello, World!');
  io.stdout.writeln('2 Hello, World!');
  io.stdout.writeln('3 Hello, World!');

  // Wait 300ms.
  await Future<void>.delayed(const Duration(milliseconds: 300));

  // Move the cursor up 2 lines.
  io.stdout.write('\x1B[2A');

  // Wait 300ms.
  await Future<void>.delayed(const Duration(milliseconds: 300));

  // Write 'INTERCEPTED'
  io.stdout.writeln('INTERCEPTED');
}
