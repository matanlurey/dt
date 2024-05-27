import 'package:dt/ansi.dart';
import 'package:test/test.dart';

void main() {
  test('invokes clearScreenAfter', () {
    final commands = _when((driver) => driver.clearScreenAfter());
    expect(commands, [const AnsiClearScreenAfter()]);
  });

  test('invokes clearScreenBefore', () {
    final commands = _when((driver) => driver.clearScreenBefore());
    expect(commands, [const AnsiClearScreenBefore()]);
  });

  test('invokes clearScreen', () {
    final commands = _when((driver) => driver.clearScreen());
    expect(commands, [const AnsiClearScreen()]);
  });

  test('invokes clearLineAfter', () {
    final commands = _when((driver) => driver.clearLineAfter());
    expect(commands, [const AnsiClearLineAfter()]);
  });

  test('invokes clearLineBefore', () {
    final commands = _when((driver) => driver.clearLineBefore());
    expect(commands, [const AnsiClearLineBefore()]);
  });

  test('invokes clearLine', () {
    final commands = _when((driver) => driver.clearLine());
    expect(commands, [const AnsiClearLine()]);
  });
}

Iterable<AnsiEscape> _when(
  void Function(AnsiTerminalDriver) drive,
) {
  final calls = <AnsiEscape>[];
  final driver = _TestAnsiTerminal(calls.add);
  drive(driver);
  return calls;
}

final class _TestAnsiTerminal with AnsiTerminalDriver {
  _TestAnsiTerminal(this._ansi);

  @override
  void handleAnsi(AnsiEscape code) => _ansi(code);
  final AnsiHandler<void> _ansi;
}
