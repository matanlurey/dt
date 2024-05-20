import 'package:dt/dt.dart';
import 'package:dt/src/ffi/libc.dart';
import 'package:dt/src/writer.dart';

/// Stub implementation of `writer` for unsupported platforms.
Writer writer(FileDescriptor fd, {LibC? libc}) {
  throw UnsupportedError('This platform is not supported');
}
