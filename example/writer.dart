#!/usr/bin/env dart

import 'package:dt/dt.dart';

void main() {
  // Use an in-memory string buffer.
  final memory = StringBuffer();

  // Create a buffer.
  final buffer = Writer.fromStringSink(memory);

  // Write 'Hello, World!' to the buffer.
  buffer.write('Hello, World!');
  assert(memory.toString() == 'Hello, World!');

  // Now show an example of using a file descriptor.
  final stdout = Writer.stdout;

  // Write 'Hello, World!' to standard output.
  stdout.write('Hello, World!\n');

  // Write 'Goodbye, World!' to standard error.
  final stderr = Writer.stderr;
  stderr.write('Goodbye, World!\n');
}
