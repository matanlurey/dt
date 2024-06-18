@TestOn('vm')
library;

import 'dart:async';
import 'dart:io' as io;

import 'package:dt/backend.dart';
import 'package:dt/terminal.dart';

import '../prelude.dart';

void main() {
  late Set<(int, int, int, int, int, int)> buffer;
  late Keyboard keyboard;

  setUp(() {
    buffer = {};
    keyboard = Keyboard.fromBuffer(BufferedKeys.fromBuffer(buffer));
  });

  test('AsciiPrintableKey', () {
    buffer.add((AsciiPrintableKey.x.charCode, 0, 0, 0, 0, 0));

    check(keyboard.isPressed(AsciiPrintableKey.x)).isTrue();
  });

  test('AsciiControlKey', () {
    buffer.add((AsciiControlKey.backspace.charCode, 0, 0, 0, 0, 0));

    check(keyboard.isPressed(AsciiControlKey.backspace)).isTrue();
  });

  test('.isAnyPressed', () {
    check(keyboard.isAnyPressed).isFalse();

    buffer.add((AsciiPrintableKey.x.charCode, 0, 0, 0, 0, 0));
    check(keyboard.isAnyPressed).isTrue();
  });

  test('.pressed', () {
    // Add a printable key.
    buffer.add((AsciiPrintableKey.x.charCode, 0, 0, 0, 0, 0));

    // Add every control key.
    for (final key in AsciiControlKey.values) {
      buffer.add((key.charCode, 0, 0, 0, 0, 0));
    }

    check(keyboard.pressed).deepEquals([
      [AsciiPrintableKey.x],
      ...AsciiControlKey.values.map((key) => [key]),
    ]);
  });

  test('clear', () {
    buffer.add((AsciiPrintableKey.x.charCode, 0, 0, 0, 0, 0));
    keyboard.clear();
    check(keyboard.isAnyPressed).isFalse();
  });

  test('fromStdin', () async {
    final stdin = _FakeStdin();
    final keyboard = Keyboard.fromStdin(stdin);

    stdin.controller.add([AsciiPrintableKey.x.charCode]);
    check(keyboard.isPressed(AsciiPrintableKey.x)).isTrue();

    await keyboard.close();
    check(stdin.controller.hasListener).isFalse();
  });
}

final class _FakeStdin extends Stream<List<int>> implements io.Stdin {
  final controller = StreamController<List<int>>(sync: true);

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  noSuchMethod(_) => super.noSuchMethod(_);
}
