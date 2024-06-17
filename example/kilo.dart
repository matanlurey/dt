import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:dt/backend.dart';
import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';
import 'package:dt/terminal.dart';
import 'package:dt/widgets.dart';

/// A simple terminal text editor.
void main(List<String> arguments) async {
  final terminal = Surface.fromStdio();
  final keyboard = BufferedKeys.fromStream(io.stdin);
  final EditorState state;
  switch (arguments.length) {
    case 0:
      state = EditorState();
    case 1:
      state = await EditorState.open(arguments[0]);
    default:
      io.stderr.writeln('Usage: kilo [filename]');
      io.exitCode = 1;
      return;
  }
  final closed = Completer<void>();
  final sigint = io.ProcessSignal.sigint.watch().listen((_) {
    if (!closed.isCompleted) {
      closed.complete();
    }
  });
  try {
    await run(
      terminal,
      keyboard,
      state,
      onExit: closed.future,
    );
  } finally {
    terminal.close();
    await (keyboard.close(), sigint.cancel()).wait;
  }
}

final class EditorState {
  /// Loads the editor state from the provided [fileName].
  static Future<EditorState> open(String fileName) async {
    final file = io.File(fileName);
    final lines = await file.readAsLines();
    return EditorState.from(lines, fileName: fileName);
  }

  /// Creates a new empty editor state.
  factory EditorState() => EditorState.from([]);

  EditorState.from(
    this.lines, {
    this.fileName,
    this.cursor = const Offset(1, 1),
  });

  /// Current cursor position.
  Offset cursor;

  /// File being edited, or `null` if a new file.
  String? fileName;

  /// Lines of text in the editor.
  List<String> lines;
}

Future<void> run(
  Surface terminal,
  BufferedKeys input,
  EditorState state, {
  Future<void>? onExit,
  Future<void> Function() nextFrame = _wait16ms,
}) async {
  var running = true;
  unawaited(
    onExit?.whenComplete(() {
      running = false;
    }),
  );
  while (running) {
    for (final keys in input.pressed) {
      final Offset(:x, :y) = state.cursor;
      final lines = state.lines;
      switch (keys) {
        // Option-Q.
        case [0xc5, 0x93]:
          return;
        // Option-S.
        case [0xc3, 0x93]:
          break;
        // Option-F.
        case [0xc6, 0x92]:
          break;
        // Backspace.
        case [0x7f]:
          break;
        // Enter.
        case [0xa]:
          lines.insert(state.cursor.y, '');
          state.cursor = Offset(1, state.cursor.y + 1);
        // Key press.
        case [final code]:
          final char = String.fromCharCode(code);
          if (lines.isEmpty) {
            lines.add('');
            state.cursor = Offset(x + 1, y);
          }
          lines[y] += char;
          state.cursor = Offset(x + 1, y);
      }
    }

    // Draw the frame.
    await terminal.draw((frame) {
      frame.draw((buffer) {
        _drawContent(state, buffer);
        _drawFooter(state, buffer);
        frame.cursor = state.cursor;
      });
    });

    input.clear();
    await nextFrame();
  }
}

void _drawContent(EditorState state, Buffer buffer) {
  // Determine how many lines to render.
  final renderLines = buffer.height - 2;

  // Render the lines.
  final renderOffset = math.max(0, state.cursor.y - renderLines ~/ 2);

  // Render the lines, and the remaining lines as `~`.
  for (var y = 0; y < renderLines; y++) {
    final Widget widget;
    if (y + renderOffset < state.lines.length) {
      widget = Text(state.lines[y + renderOffset]);
    } else {
      widget = Text('~');
    }
    widget.draw(buffer.subGrid(Rect.fromLTWH(0, y, buffer.width, 1)));
  }
}

void _drawFooter(EditorState state, Buffer buffer) {
  final status = Text.fromLine(
    Line(
      [
        state.fileName ?? '[No name]',
        ' - ${state.lines.length} lines',
      ],
      style: Style(
        background: Color16.white,
        foreground: Color16.black,
      ),
    ),
  );
  status.draw(
    buffer.subGrid(Rect.fromLTWH(0, buffer.height - 2, buffer.width, 1)),
  );

  // Render command bar.
  final command = Text.fromLine(
    Line(
      [
        'HELP: ',
        'Option-Q: Quit | ',
        'Option-S: Save | ',
        'Option-F: Find',
      ],
    ),
  );
  command.draw(
    buffer.subGrid(Rect.fromLTWH(0, buffer.height - 1, buffer.width, 1)),
  );
}

const _fps60 = Duration(milliseconds: 1000 ~/ 60);
Future<void> _wait16ms() => Future.delayed(_fps60);
