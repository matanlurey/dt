import 'package:dt/src/ffi/libc.dart';

/// Stub implementation of `isSupported` for unsupported platforms.
bool get isSupported => false;

/// Stub implementation of `libc` for unsupported platforms.
LibC libc() {
  throw UnsupportedError('This platform is not supported');
}
