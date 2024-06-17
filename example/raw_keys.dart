import 'dart:io' as io;

import 'package:dt/backend.dart';
import 'package:dt/foundation.dart';

void main() async {
  final writer = StringWriter(
    Writer.fromSink(
      io.stdout,
      onFlush: io.stdout.flush,
    ),
  );
  final keys = BufferedKeys.fromStream(io.stdin);
  try {
    io.stdin
      ..echoMode = false
      ..lineMode = false;
    await run(writer, keys);
  } finally {
    io.stdin
      ..echoMode = true
      ..lineMode = true;
    await keys.close();
  }
}

Future<void> run(
  StringWriter writer,
  BufferedKeys keys, {
  Future<void> Function() onFrame = _wait16ms,
}) async {
  writer.writeLine('Press key(s) to see their codes.');
  while (true) {
    await onFrame();
    if (keys.isAnyPressed) {
      final combinations = keys.pressed.toList();
      for (final combo in combinations) {
        writer.writeAll(
          combo.map((key) => '0x${key.toRadixString(16)}'),
          ', ',
        );
        writer.writeLine();
      }
    }
    keys.clear();
  }
}

const _fps60 = Duration(milliseconds: 1000 ~/ 60);
Future<void> _wait16ms() => Future.delayed(_fps60);
