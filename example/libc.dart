#!/usr/bin/env dart

import 'package:dt/src/ffi/libc.dart';

void main() {
  // Ensure we're running on a supported platform.
  if (!LibC.isSupported) {
    throw UnsupportedError('This platform is not supported');
  }

  // Create a new instance of the C standard library.
  final libc = LibC();

  // Write 'Hello, World!' to standard output.
  libc.write(libc.stdoutFd, 'Hello, World!\n'.codeUnits);

  // Write 'Goodbye, World!' to standard error.
  libc.write(libc.stderrFd, 'Goodbye, World!\n'.codeUnits);
}
