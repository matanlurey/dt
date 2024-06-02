import 'dart:io' as io;

import 'package:dt/foundation.dart';

/// Prints a 'Hello' message in the terminal.
void main() async {
  await run(StringWriter(Writer.fromSink(io.stdout, onFlush: io.stdout.flush)));
}

Future<void> run(
  StringWriter out,
) async {
  out.writeLines([
    r' __    __   _______  __       __        ______   ',
    r'|  |  |  | |   ____||  |     |  |      /  __  \  ',
    r'|  |__|  | |  |__   |  |     |  |     |  |  |  | ',
    r'|   __   | |   __|  |  |     |  |     |  |  |  | ',
    r'|  |  |  | |  |____ |  `----.|  `----.|  `--`  | ',
    r'|__|  |__| |_______||_______||_______| \______/  ',
    r'',
    r'',
  ]);
}
