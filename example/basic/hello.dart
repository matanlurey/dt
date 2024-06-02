import 'dart:io' as io;

import 'package:dt/terminal.dart';

/// Prints a 'Hello' message in the terminal.
void main() async {
  await run(TerminalSink.fromIOSink(io.stdout));
}

Future<void> run(
  TerminalSink out,
) async {
  out.writeAll([
    r' __    __   _______  __       __        ______   ',
    r'|  |  |  | |   ____||  |     |  |      /  __  \  ',
    r'|  |__|  | |  |__   |  |     |  |     |  |  |  | ',
    r'|   __   | |   __|  |  |     |  |     |  |  |  | ',
    r'|  |  |  | |  |____ |  `----.|  `----.|  `--`  | ',
    r'|__|  |__| |_______||_______||_______| \______/  ',
  ]);
}
