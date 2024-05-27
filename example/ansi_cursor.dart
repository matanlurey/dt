#!/usr/bin/env dart

import 'package:dt/ansi.dart';
import 'package:dt/dt.dart';

void main() async {
  // Create a terminal that writes to standard output.
  final terminal = AnsiTerminal<void>.stdout();

  // Move the cursor from 0 to 9, then next line, 10 times.
  for (var i = 0; i < 10; i++) {
    for (var j = 0; j < 10; j++) {
      terminal.cursor.moveRight();
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    terminal.writeLine();
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
