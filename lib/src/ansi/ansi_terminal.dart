import 'package:dt/dt.dart';

import 'ansi_escape.dart';
import 'ansi_terminal_driver.dart';

/// A terminal that writes ANSI escape codes to a [Writer].
abstract interface class AnsiTerminal<T>
    with TerminalSink<T>
    implements TerminalDriver {
  AnsiTerminal._();

  /// Creates a new ANSI terminal that writes to the given [writer].
  factory AnsiTerminal(Writer writer) = _AnsiTerminal;

  /// Creates a new ANSI terminal that writes to standard output.
  factory AnsiTerminal.stdout() => AnsiTerminal(Writer.stdout);
}

final class _AnsiTerminal<T> extends AnsiTerminal<T> with AnsiTerminalDriver {
  _AnsiTerminal(this._writer) : super._();

  @override
  void handleAnsi(AnsiEscape code) => _writer.write(code.toEscapedString());
  final Writer _writer;

  @override
  void write(T span) {
    _writer.write('$span');
  }

  @override
  void writeLine([T? span]) {
    _writer.write('${span ?? ''}\n');
  }
}
