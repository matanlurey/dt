import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;

import 'package:dt/backend.dart';
import 'package:dt/layout.dart';
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
          if (x == 0 && y == 0) {
            break;
          }
          if (x == 0) {
            final line = lines.removeAt(y);
            lines[y - 1] += line;
            state.cursor = Offset(lines[y - 1].length, y - 1);
          } else {
            lines[y] = lines[y].replaceRange(x - 1, x, '');
            state.cursor = Offset(x - 1, y);
          }
        // Enter.
        case [0xa]:
          lines.insert(state.cursor.y + 1, '');
          state.cursor = Offset(0, state.cursor.y + 1);
        // Arrow-up
        case [0x1b, 0x5b, 0x41]:
          state.cursor = Offset(x, math.max(0, y - 1));
        // Arrow-down
        case [0x1b, 0x5b, 0x42]:
          state.cursor = Offset(x, math.min(lines.length - 1, y + 1));
        // Arrow-left
        case [0x1b, 0x5b, 0x44]:
          state.cursor = Offset(math.max(0, x - 1), y);
        // Arrow-right
        case [0x1b, 0x5b, 0x43]:
          state.cursor = Offset(math.min(lines[y].length, x + 1), y);
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
        Layout(
          Constrained.horizontal([
            Constraint.flex(1),
            Constraint.fixed(1),
            Constraint.fixed(1),
          ]),
          [
            _Content(state),
            _commandBar,
            _StatusBar(state),
          ],
        ).draw(buffer);
        frame.cursor = state.cursor;
      });
    });

    input.clear();
    await nextFrame();
  }
}

final class _Content extends Widget {
  const _Content(this.state);

  final EditorState state;

  @override
  void draw(Buffer buffer) {
    // Determine how many lines to render.
    final renderLines = buffer.height;

    // Render the lines.
    final renderOffset = math.max(0, state.cursor.y - renderLines ~/ 2);

    // Render the lines, and the remaining lines as `~`.
    for (var y = 0; y < renderLines; y++) {
      final Widget widget;
      if (y + renderOffset < state.lines.length) {
        widget = Text.fromLine(Line([state.lines[y + renderOffset]]));
      } else {
        widget = Text.fromLine(Line(['~']));
      }
      widget.draw(buffer.subGrid(Rect.fromLTWH(0, y, buffer.width, 1)));
    }
  }
}

final class _StatusBar extends Widget {
  const _StatusBar(this.state);

  final EditorState state;

  @override
  void draw(Buffer buffer) {
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
    status.draw(buffer);
  }
}

final _commandBar = Text.fromLine(
  Line([
    'HELP: Option-Q: Quit | Option-S: Save | Option-F: Find',
  ]),
);

const _fps60 = Duration(milliseconds: 1000 ~/ 60);
Future<void> _wait16ms() => Future.delayed(_fps60);
