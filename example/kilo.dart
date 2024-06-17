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

const _qKey = 0x51;
const _fKey = 0x66;
const _sKey = 0x73;
const _ctrlKey = 0x1D;

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
    this.cursor = Offset.zero,
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
    // Process keys.
    if (input.isPressed(_ctrlKey, _qKey)) {}
    if (input.isPressed(_ctrlKey, _sKey)) {}
    if (input.isPressed(_ctrlKey, _fKey)) {}

    // Draw the frame.
    await terminal.draw((frame) {
      frame.draw((buffer) {
        // Determine how many lines to render.
        final renderLines = buffer.height - 2;

        // Render the cursor.
        frame.cursor = state.cursor;

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

        // Render the status bar.
        final status = Text.fromLine(
          Line(
            [
              Span(state.fileName ?? '[No name]'),
              Span(' - ${state.lines.length} lines'),
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

        // Render the command bar.
        final command = Text(
          'HELP: Ctrl-S = save | Ctrl-Q = quit | Ctrl-F = find',
        );
        command.draw(
          buffer.subGrid(Rect.fromLTWH(0, buffer.height - 1, buffer.width, 1)),
        );
      });
    });

    input.clear();
    await nextFrame();
  }
}

const _fps60 = Duration(milliseconds: 1000 ~/ 60);
Future<void> _wait16ms() => Future.delayed(_fps60);
