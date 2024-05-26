import 'package:dt/dt.dart';
import 'package:dt/src/core/ansi.dart';
import 'package:test/test.dart';

void main() {
  test('invokes clearLine', () {
    _when(
      (driver) => driver.clearLine(),
    );
  });
}

Iterable<String> _when(
  void Function(AnsiTerminalDriver) drive,
) {
  final calls = <String>[];
  final driver = _TestAnsiTerminal((code) {
    calls.add(code.toString());
    return '';
  });

  drive(driver);

  return calls;
}

final class _TestAnsiTerminal with AnsiTerminalDriver {
  _TestAnsiTerminal(this._ansi);

  @override
  String handleAnsi(AnsiEscape code) => _ansi(code);
  final AnsiHandler<String> _ansi;
}
