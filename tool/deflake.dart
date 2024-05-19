#!/usr/bin/env dart

import 'dart:async';
import 'dart:io' as io;

/// A wrapper around `dart` that runs CLI tests 100 times to check flakiness.
///
/// Usage: `./tool/deflake.dart <test_file.dart>`.
///
/// The number of failures is printed to the console.
void main(List<String> args) async {
  if (args.isEmpty) {
    io.stderr.writeln('Usage: ./tool/deflake.dart <test_file.dart>');
    io.exitCode = 1;
    return;
  }

  // Create the command to run the tests.
  final testFile = args.first;
  final parallelism = io.Platform.numberOfProcessors;

  // Run the tests 100 times with parallelism.
  var failures = 0;
  var running = 0;
  var remaining = 100;
  final queue = List.generate(100, (_) => testFile);
  while (remaining > 0) {
    while (running < parallelism && queue.isNotEmpty) {
      final file = queue.removeAt(0);
      running++;
      unawaited(
        io.Process.run('dart', ['test', file]).then((result) {
          if (result.exitCode != 0) {
            failures++;
          }
        }).whenComplete(() {
          running--;
          remaining--;
          io.stderr.writeln('Remaining: $remaining');
        }),
      );
    }

    await Future(() {});
  }

  if (failures > 0) {
    io.stderr.writeln('Failures: $failures');
    io.exitCode = 1;
  } else {
    io.stderr.writeln('No failures');
  }
}
