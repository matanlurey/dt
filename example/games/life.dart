import 'package:dt/ansi.dart';
import 'package:dt/app.dart';
import 'package:dt/core.dart';
import 'package:test/test.dart';

/// Runs the game of life by emitting to [sink] and manipulating with [driver].
Future<void> start(
  TerminalSink<String> sink,
  TerminalDriver driver,
) async {
  var count = 1;
  await runLoop(() {
    driver.cursor.moveTo(column: 0);
    driver.clearLine();

    // Placeholder.
    sink.write('$count');
    count += 1;
    if (count > 100) {
      count = 1;
    }
  });
}

void main() async {
  final terminal = AnsiTerminal<String>.stdout();
  await start(terminal, terminal);
}
