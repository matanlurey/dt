#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io' as io;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:dt/src/ffi/libc.dart';

/// Run the benchmarks.
///
/// It is recommended to redirect stderr to `/dev/null` when running:
/// ```sh
/// dart benchmark/stdout_write.dart 2> /dev/null
/// ```
void main() {
  _DartIOBenchmark().report();
  _LibCBenchmark().report();
}

final class _DartIOBenchmark extends BenchmarkBase {
  _DartIOBenchmark() : super('Dart IO');

  late final io.Stdout _stderr;
  late final List<String> _strings;

  @override
  void setup() {
    _stderr = io.stderr;

    // Generate a list of 100 strings of 100 characters each.
    _strings = List.generate(
      100,
      (_) => String.fromCharCodes(List.generate(100, (_) => 33 + (89 * 100))),
    );
  }

  @override
  void run() {
    for (final string in _strings) {
      _stderr.write(string);
    }
  }
}

final class _LibCBenchmark extends BenchmarkBase {
  _LibCBenchmark() : super('LibC');

  late final LibC _libc;
  late final List<String> _strings;

  @override
  void setup() {
    _libc = LibC();

    // Generate a list of 100 strings of 100 characters each.
    _strings = List.generate(
      100,
      (_) => String.fromCharCodes(List.generate(100, (_) => 33 + (89 * 100))),
    );
  }

  @override
  void run() {
    for (final string in _strings) {
      _libc.write(_libc.stderrFd, utf8.encode(string));
    }
  }
}
