// ignore_for_file: avoid_private_typedef_functions

import 'dart:ffi';
import 'dart:io' as io show Platform;

import 'package:dt/src/ffi/libc.dart';

/// Whether the current platform supports the C standard library.
final isSupported = const [
  // 'fflush',
  'free',
  'malloc',
  'write',
].every(_stdLib.providesSymbol);

/// Returns a POSIX-specific implementation of the C standard library.
LibC libc() => isSupported
    ? const _PosixLibC()
    : throw UnsupportedError('This platform is not supported');

/// Symbols that are available in global scope.
final _stdLib = io.Platform.isMacOS
    ? DynamicLibrary.process()
    : DynamicLibrary.open('libc.so.6');

typedef _CMalloc = Pointer Function(IntPtr);
typedef _DMalloc = Pointer Function(int);

typedef _CFree = Void Function(Pointer);
typedef _DFree = void Function(Pointer);

final class _Malloc implements Allocator {
  const _Malloc._();

  static final _malloc = _stdLib.lookupFunction<_CMalloc, _DMalloc>(
    'malloc',
  );

  @override
  Pointer<T> allocate<T extends NativeType>(int byteCount, {int? alignment}) {
    final pointer = _malloc(byteCount);
    if (pointer.address == 0) {
      throw ArgumentError('Could not allocate $byteCount bytes');
    }
    return pointer.cast();
  }

  static final _free = _stdLib.lookupFunction<_CFree, _DFree>('free');

  @override
  void free(Pointer<NativeType> pointer) {
    _free(pointer);
  }
}

typedef _CWrite = Int32 Function(
  Int32 fd,
  Pointer<Uint8> buffer,
  Uint32 count,
);
typedef _DWrite = int Function(
  int fd,
  Pointer<Uint8> buffer,
  int count,
);

typedef _CFlush = Int32 Function(Int32 fd);
typedef _DFlush = int Function(int fd);

/// A POSIX-specific interface to the C standard library.
final class _PosixLibC implements LibC {
  const _PosixLibC();

  static final _libc = _stdLib;
  static final _allocate = const _Malloc._();

  @override
  FileDescriptor get stdoutFd => const FileDescriptor(1);

  @override
  FileDescriptor get stderrFd => const FileDescriptor(2);

  @override
  int flush(FileDescriptor fd) => _flush(fd);

  static final _flush = _libc.lookupFunction<_CFlush, _DFlush>('fflush');

  @override
  int write(FileDescriptor fd, List<int> bytes) {
    final pointer = _allocate<Uint8>(bytes.length);
    pointer.asTypedList(bytes.length).setAll(0, bytes);

    try {
      return _write(fd, pointer, bytes.length);
    } finally {
      // _allocate.free(pointer);
    }
  }

  static final _write = _libc.lookupFunction<_CWrite, _DWrite>('write');
}
