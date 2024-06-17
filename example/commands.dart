import 'dart:io' as io;

import 'package:dt/backend.dart';
import 'package:dt/foundation.dart';

/// Uses various commands to manipulate the terminal.
void main() async {
  await run(StringWriter(Writer.fromSink(io.stdout, onFlush: io.stdout.flush)));
}

Future<void> run(
  StringWriter out, {
  Future<void> Function() wait = _wait1s,
}) async {
  try {
    // Enter the alternate screen buffer.
    out.write(AlternateScreenBuffer.enter.toSequence().toEscapedString());
    await wait();

    // Hide the cursor.
    out.write(SetCursorVisibility.hidden.toSequence().toEscapedString());
    await wait();

    // Move the cursor to the top-left corner.
    out.write(MoveCursorTo().toSequence().toEscapedString());
    await wait();

    // Clear the screen.
    out.write(ClearScreen.all.toSequence().toEscapedString());
    await wait();

    // Write out 10 lines of text.
    for (var i = 9; i >= 0; i--) {
      out.write(MoveCursorToColumn().toSequence().toEscapedString());
      out.write('Counting: $i');
      await wait();
    }
  } finally {
    // Show the cursor.
    out.write(SetCursorVisibility.visible.toSequence().toEscapedString());

    // Exit the alternate screen buffer.
    out.write(AlternateScreenBuffer.leave.toSequence().toEscapedString());
  }
}

Future<void> _wait1s() async {
  await Future<void>.delayed(const Duration(seconds: 1));
}
