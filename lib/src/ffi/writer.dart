// ignore_for_file: always_use_package_imports

import 'package:dt/dt.dart';
import 'package:dt/src/ffi/libc.dart';

import '_writer/_null.dart' if (dart.library.io) '_writer/_posix.dart' as impl;

/// Returns a writer that writes to `stdout` using `libc`.
Writer stdoutWriter({LibC? libc}) {
  libc ??= LibC();
  return impl.writer(libc.stdoutFd, libc: libc);
}

/// Returns a writer that writes to `stderr` using `libc`.
Writer stderrWriter({LibC? libc}) {
  libc ??= LibC();
  return impl.writer(libc.stderrFd, libc: libc);
}
