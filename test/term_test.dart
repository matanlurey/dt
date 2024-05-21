// ignore_for_file: cascade_invocations

import 'package:dt/dt.dart';
import 'package:test/test.dart';

void main() {
  group('$StringTerminal', () {
    _terminalTests(
      empty: StringTerminal.new,
      helloWorld: () => StringTerminal('Hello\nWorld!'),
    );
  });
  group('$TerminalSnapshot', _terminalSnapshotTests);
  group('$TerminalView', _terminalViewTests);
}

void _terminalTests({
  required Terminal<String> Function() empty,
  required Terminal<String> Function() helloWorld,
}) {
  test('starts with an empty terminal', () {
    final terminal = empty();

    // Cursor.
    expect(terminal.cursor, Cursor.zero);
    expect(terminal.firstPosition, Cursor.zero);
    expect(terminal.lastPosition, Cursor.zero);

    // Lines.
    expect(terminal.isEmpty, isTrue);
    expect(terminal.isNotEmpty, isFalse);
    expect(terminal.lines, <String>[]);
    expect(() => terminal.line(0), throwsRangeError);
    expect(() => terminal[0], throwsRangeError);
    expect(terminal.lineAt(), isNull);
    expect(() => terminal.currentLine, throwsRangeError);

    // Misc.
    expect(terminal.toString(), 'Terminal <cursor: (0, 0), lines: 0>');
  });

  test('cursor is clamped', () {
    final terminal = helloWorld();

    // Try setting beyond the last position.
    terminal.cursor = terminal.cursor.translate(1, 0);
    expect(terminal.cursor, terminal.lastPosition);

    // Try setting beyond the first position.
    terminal.cursor = terminal.firstPosition.translate(-1, 0);
    expect(terminal.cursor, terminal.firstPosition);
  });

  test('length grows the terminal', () {
    final terminal = empty();

    // Add a line.
    terminal.lineCount = 1;
    expect(terminal.lines, ['']);

    // Add another line.
    terminal.lineCount = 2;
    expect(terminal.lines, ['', '']);
  });

  test('length shrinks the terminal', () {
    final terminal = helloWorld();

    // Remove a line.
    terminal.lineCount = 1;
    expect(terminal.lines, ['Hello']);

    // Remove another line.
    terminal.lineCount = 0;
    expect(terminal.lines, isEmpty);
  });

  test('lines iterates over the terminal', () {
    final terminal = helloWorld();

    expect(terminal.lines, ['Hello', 'World!']);
  });
}

void _terminalSnapshotTests() {
  test('takes a snapshot of an existing terminal', () {
    final terminal = StringTerminal('Hello\nWorld!');
    final snapshot = TerminalSnapshot.from(terminal);

    // Cursor.
    expect(snapshot.cursor, terminal.cursor);
    expect(snapshot.firstPosition, terminal.firstPosition);
    expect(snapshot.lastPosition, terminal.lastPosition);

    // Lines.
    expect(snapshot.isEmpty, terminal.isEmpty);
    expect(snapshot.isNotEmpty, terminal.isNotEmpty);
    expect(snapshot.lines, terminal.lines);
    expect(snapshot.line(0), terminal.line(0));
    expect(snapshot[0], terminal[0]);
    expect(snapshot.lineAt(0), terminal.lineAt(0));
    expect(snapshot.currentLine, terminal.currentLine);

    // Misc.
    expect(snapshot.toString(), 'TerminalSnapshot <cursor: (5, 1), lines: 2>');
  });

  test('== and hashCode', () {
    final a = TerminalSnapshot.from(StringTerminal('Hello'));
    final b = TerminalSnapshot.from(StringTerminal('Hello'));
    final c = TerminalSnapshot.from(StringTerminal('World'));

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(c));
  });
}

void _terminalViewTests() {
  test('creates a read-only view of an existing terminal', () {
    final terminal = StringTerminal('Hello\nWorld!');
    final view = TerminalView.from(terminal);

    // Cursor.
    expect(view.cursor, terminal.cursor);
    expect(view.firstPosition, terminal.firstPosition);
    expect(view.lastPosition, terminal.lastPosition);

    // Lines.
    expect(view.isEmpty, terminal.isEmpty);
    expect(view.isNotEmpty, terminal.isNotEmpty);
    expect(view.lines, terminal.lines);
    expect(view.line(0), terminal.line(0));
    expect(view[0], terminal[0]);
    expect(view.lineAt(0), terminal.lineAt(0));
    expect(view.currentLine, terminal.currentLine);

    // Misc.
    expect(view.toString(), 'TerminalView <cursor: (5, 1), lines: 2>');
  });
}
