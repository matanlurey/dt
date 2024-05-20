import 'dart:convert' show utf8;

import 'package:dt/dt.dart';
import 'package:dt/src/core/writer.dart';
import 'package:dt/src/ffi/libc.dart';

/// Returns a writer that writes to the given file descriptor using `libc`.
Writer writer(FileDescriptor fd, {required LibC libc}) {
  return _CWriter(fd, libc: libc);
}

final class _CWriter implements Writer {
  _CWriter(
    this._fd, {
    required LibC libc,
  }) : _libc = libc;

  final FileDescriptor _fd;
  final LibC _libc;
  var _closed = false;

  @override
  void write(String text) {
    if (_closed) {
      throw StateError('Writer is closed');
    }
    _libc.write(_fd, utf8.encode(text));
  }

  @override
  Future<void> close() {
    // Intentionnally not async so we immediately enter the function body.
    if (_closed) {
      throw StateError('Writer is closed');
    }
    _closed = true;
    return Future.value();
  }

  @override
  Future<void> flush() {
    // Intentionnally not async so we immediately enter the function body.
    if (_closed) {
      throw StateError('Writer is closed');
    }
    _libc.flush(_fd);
    return Future.value();
  }
}
