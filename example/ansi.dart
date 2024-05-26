#!/usr/bin/env dart

import 'package:dt/dt.dart';
import 'package:dt/src/core/ansi.dart';

void main() async {
  final stdout = Writer.stdout;

  // Simulate a progress bar.
  for (var i = 0; i < 100; i++) {
    stdout.write('\rProgress: $i%');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    stdout.write(const AnsiClearLine().toEscapedString());
  }

  stdout.write('\rProgress: Done!\n');
}
