@TestOn('vm')
library;

import 'dart:io' as io;

import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';
import 'package:dt/terminal.dart';

import '../prelude.dart';

void main() {
  test('draws to a buffer', () {
    final backend = TestSurfaceBackend(5, 5);
    final terminal = Surface.fromBackend(backend);

    terminal.draw((frame) {
      frame.draw((buffer) {
        buffer.print(0, 0, 'Hello');
        buffer.print(0, 1, 'World');
        buffer.print(0, 2, '!!!!!');
        buffer.print(0, 3, '?????');
        buffer.print(0, 4, '#####');
      });
    });

    check(backend).has((b) => b.buffer.rows, 'buffer.rows').deepEquals([
      [Cell('H'), Cell('e'), Cell('l'), Cell('l'), Cell('o')],
      [Cell('W'), Cell('o'), Cell('r'), Cell('l'), Cell('d')],
      [Cell('!'), Cell('!'), Cell('!'), Cell('!'), Cell('!')],
      [Cell('?'), Cell('?'), Cell('?'), Cell('?'), Cell('?')],
      [Cell('#'), Cell('#'), Cell('#'), Cell('#'), Cell('#')],
    ]);
  });

  test('shows the cursor', () {
    final backend = TestSurfaceBackend(5, 5);
    final terminal = Surface.fromBackend(backend);

    terminal.draw((frame) {
      frame.cursor = const Offset(2, 2);
    });

    check(backend)
      ..has(
        (b) => b.isCursorVisible,
        'isCursorVisible',
      ).equals(true)
      ..has(
        (b) => b.cursorPosition,
        'cursorPosition',
      ).equals(const Offset(2, 2));
  });

  test('throws after being disposed', () {
    final backend = TestSurfaceBackend(5, 5);
    final terminal = Surface.fromBackend(backend);

    terminal.dispose();

    check(terminal.dispose).throws<StateError>();
    check(() => terminal.draw((frame) {})).throws<StateError>();
  });

  test('enables/disables raw mode', () {
    final stdin = _FakeStdin();
    final stdout = _FakeStdout();

    final terminal = Surface.fromStdio(stdout, stdin);
    check(stdin)
      ..has((s) => s.echoMode, 'echoMode').equals(false)
      ..has((s) => s.lineMode, 'lineMode').equals(false);

    terminal.dispose();
    check(stdin)
      ..has((s) => s.echoMode, 'echoMode').equals(true)
      ..has((s) => s.lineMode, 'lineMode').equals(true);
  });

  test('enters/exits alt-buffer and hides/shows cursor', () {
    final stdout = _FakeStdout();
    final terminal = Surface.fromStdio(stdout, _FakeStdin());

    var logs = Sequence.parseAll(stdout.logs.join()).map(Command.tryParse);
    check(logs).deepEquals([
      AlternateScreenBuffer.enter,
      SetCursorVisibility.hidden,
    ]);

    stdout.logs.clear();
    terminal.dispose();

    logs = Sequence.parseAll(stdout.logs.join()).map(Command.tryParse);
    check(logs).deepEquals([
      SetCursorVisibility.visible,
      AlternateScreenBuffer.leave,
    ]);
  });

  test('e2e rendering test of "Hello World"', () {
    final backend = TestSurfaceBackend(80, 24);
    final surface = Surface.fromBackend(backend);

    surface.draw((frame) {
      frame.draw((buffer) {
        buffer.print(0, 0, 'Hello');
      });
    });

    check(backend)
        .has((b) => b.buffer.rows.first.take(5), 'buffer.rows.first.take(5)')
        .deepEquals([Cell('H'), Cell('e'), Cell('l'), Cell('l'), Cell('o')]);
  });
}

final class _FakeStdin implements io.Stdin {
  @override
  var echoMode = true;

  @override
  var lineMode = true;

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}

final class _FakeStdout implements io.Stdout {
  var logs = <String>[];

  @override
  void write(Object? obj) {
    logs.add(obj.toString());
  }

  @override
  var terminalColumns = 80;

  @override
  var terminalLines = 24;

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
