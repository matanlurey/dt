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
}
