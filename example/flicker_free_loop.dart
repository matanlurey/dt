import 'dart:async';
import 'dart:io' as io;

import 'package:dt/backend.dart';
import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';

void main() async {
  final closed = Completer<void>();
  final sigint = io.ProcessSignal.sigint.watch().listen((_) {
    if (!closed.isCompleted) {
      closed.complete();
    }
  });
  final writer = StringWriter(
    Writer.fromSink(io.stdout, onFlush: io.stdout.flush),
  );
  try {
    io.stdin
      ..echoMode = false
      ..lineMode = false;
    writer.write(AlternateScreenBuffer.enter.toSequence().toEscapedString());
    await run(
      writer,
      onDone: closed.future,
      width: io.stdout.terminalColumns,
      height: io.stdout.terminalLines,
    );
  } finally {
    writer.write(AlternateScreenBuffer.leave.toSequence().toEscapedString());
    io.stdin
      ..echoMode = true
      ..lineMode = true;
    await sigint.cancel();
  }
}

Future<void> run(
  StringWriter writer, {
  required int width,
  required int height,
  required Future<void> onDone,
  Future<void> Function() wait = _wait16ms,
}) async {
  var running = true;
  unawaited(onDone.whenComplete(() => running = false));
  while (running) {
    await wait();
    final out = StringBuffer();
    out.write(SynchronizedUpdate.start.toSequence().toEscapedString());
    out.write(ClearScreen.all.toSequence().toEscapedString());
    out.write(MoveCursorTo().toSequence().toEscapedString());

    // Create a grid of cells.
    final buffer = Buffer(
      width,
      height,
      Cell('#', Style(background: Color16.red)),
    );

    // Render the buffer to the terminal.
    for (var y = 0; y < buffer.height; y++) {
      for (var x = 0; x < buffer.width; x++) {
        final cell = buffer.get(x, y);
        out.write(
          cell.style.toSequences().map((s) => s.toEscapedString()).join(),
        );
        out.write(cell.symbol);
      }
      out.write(resetStyle.toSequence().toEscapedString());
      out.write('\n');
    }

    out.write(MoveCursorTo().toSequence().toEscapedString());
    out.write(SynchronizedUpdate.end.toSequence().toEscapedString());
    writer.write(out.toString());
  }
}

const _fps60 = Duration(milliseconds: 1000 ~/ 60);
Future<void> _wait16ms() => Future.delayed(_fps60);
