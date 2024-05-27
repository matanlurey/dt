#!/usr/bin/env dart

import 'package:dt/ansi.dart';

void main() async {
  final terminal = AnsiTerminal<String>.stdout();

  // Simulate a progress bar.
  for (var i = 0; i < 100; i++) {
    terminal.write('\rProgress: $i%');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    terminal.clearLine();
  }

  terminal.write('\rProgress: Done!\n');
}
