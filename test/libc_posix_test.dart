// ignore_for_file: avoid_private_typedef_functions

@TestOn('posix')
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:io' as io;

import 'package:dt/src/ffi/libc.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  // Setup libc.
  late final LibC libc;

  setUpAll(() {
    libc = LibC();
  });

  // Create temporary directory to use for testing per test and clean up after.
  late io.Directory tempDir;

  setUp(() {
    tempDir = io.Directory.systemTemp.createTempSync('libc_posix_test');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('write writes to a file descriptor', () {
    final path = p.join(tempDir.path, 'test.txt');
    final fd = path.toUtf8Bytes((pathPointer) {
      return _libc$open(pathPointer, 0x201, 0x1B6);
    });
    expect(fd, isNonNegative, reason: 'Failed to open file');

    final message = 'Hello World';
    libc.write(FileDescriptor(fd), utf8.encode(message));

    // Set permissions.
    var done = _libc$fchmod(fd, 0x1B6);
    expect(done, isZero, reason: 'Failed to set permissions');

    // Close the file.
    done = _libc$close(fd);
    expect(done, isZero, reason: 'Failed to close file');

    // Now read the file to verify the content.
    final file = io.File(path).readAsStringSync();
    expect(file, message);
  });
}

extension on String {
  T toUtf8Bytes<T>(T Function(Pointer<Int8>) f) {
    // Get as bytes.
    final bytes = utf8.encode(this);

    // Allocate memory for the bytes.
    final pointer = _libc$malloc<Int8>(bytes.length);

    // Copy the bytes to the memory.
    pointer.asTypedList(bytes.length).setAll(0, bytes);

    // Call the function with the pointer.
    try {
      return f(pointer);
    } finally {
      // Free the memory.
      _libc$malloc.free(pointer);
    }
  }
}

final _stdLib = DynamicLibrary.process();

typedef _COpen = Int32 Function(
  Pointer<Int8> path,
  Int32 flags,
  Int32 mode,
);
typedef _DOpen = int Function(
  Pointer<Int8> path,
  int flags,
  int mode,
);
typedef _CFchmod = Int32 Function(
  Int32 fd,
  Int32 mode,
);
typedef _DFchmod = int Function(
  int fd,
  int mode,
);
typedef _CClose = Int32 Function(Int32 fd);
typedef _DClose = int Function(int fd);

final _libc$open = _stdLib.lookupFunction<_COpen, _DOpen>('open');
final _libc$fchmod = _stdLib.lookupFunction<_CFchmod, _DFchmod>('fchmod');
final _libc$close = _stdLib.lookupFunction<_CClose, _DClose>('close');

// A copy of the _Malloc from lib/src/ffi/_libc/_posix.dart.
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

const _libc$malloc = _Malloc._();
