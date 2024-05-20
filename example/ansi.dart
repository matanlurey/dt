#!/usr/bin/env dart

import 'package:dt/dt.dart';

void main() async {
  final stdout = AnsiWriter.from(Writer.stdout);

  // Simulate a progress bar.
  for (var i = 0; i < 100; i++) {
    stdout.write('\rProgress: $i%');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    stdout.clearLine();
  }

  stdout.write('\rProgress: Done!\n');
}
