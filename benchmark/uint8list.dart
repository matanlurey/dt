import 'dart:math';
import 'dart:typed_data';

import 'package:benchmark_harness/benchmark_harness.dart';

void main() {
  _Uint8ListFillRange().report();
  _Uint8ListNewAlloc().report();
}

final class _Uint8ListFillRange extends BenchmarkBase {
  _Uint8ListFillRange() : super('Uint8List.fillRange');

  late Uint8List _buffer;

  @override
  void setup() {
    _buffer = Uint8List(4096);
  }

  @override
  void run() {
    _buffer.fillRange(0, _buffer.length, 0);
  }

  @override
  void teardown() {
    _disableSomeOptimizations(_buffer);
  }
}

final class _Uint8ListNewAlloc extends BenchmarkBase {
  _Uint8ListNewAlloc() : super('Uint8List.newAlloc');

  late Uint8List _buffer;

  @override
  void run() {
    _buffer = Uint8List(4096);
  }

  @override
  void teardown() {
    _disableSomeOptimizations(_buffer);
  }
}

// Tries to avoid the compiler seeing the buffer as dead code.
void _disableSomeOptimizations(Uint8List buffer) {
  final random = Random();
  for (var i = 0; i < buffer.length; i++) {
    buffer[i] = random.nextInt(256);
  }
}
