// ignore_for_file: always_use_package_imports

import '_libc/_null.dart' if (dart.library.io) '_libc/_posix.dart' as impl;

/// Represents a file descriptor.
extension type const FileDescriptor(int _value) implements int {}

/// Represents a subset of the C standard library, for use with FFI.
///
/// This class is intended to be subclassed for each platform that has a
/// different C standard library implementation, or swapped for a fake
/// implementation during testing.
abstract interface class LibC {
  /// Whether the current platform supports the C standard library.
  static bool get isSupported => impl.isSupported;

  /// Returns the platform-specific implementation of the C standard library.
  ///
  /// On an unsupported platform, this method throws an [UnsupportedError].
  factory LibC() => impl.libc();

  /// Standard output file descriptor.
  FileDescriptor get stdoutFd;

  /// Standard error file descriptor.
  FileDescriptor get stderrFd;

  /// Flushes the given [fd].
  ///
  /// Returns `0` on success, or `-1` if an error occurred.
  int flush(FileDescriptor fd);

  /// Writes the specified [bytes] to the given [fd].
  ///
  /// Returns the number of bytes written, or `-1` if an error occurred.
  int write(FileDescriptor fd, List<int> bytes);
}
