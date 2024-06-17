import 'package:dt/backend.dart';
import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';

import '../prelude.dart';

void main() {
  test('drawBatch writes a minimal number of escape sequences', () {
    final buffer = StringBuffer();
    final writer = Writer.fromStringSink(buffer);
    final backend = _TestBackend(writer, (5, 2));

    backend.drawBatch([
      Cell('H', Style(foreground: Color16.red, background: Color16.blue)),
      Cell('e'),
      Cell('l'),
      Cell('l'),
      Cell('o'),
      Cell('W'),
      Cell('o'),
      Cell('r'),
      Cell('l'),
      Cell('d'),
    ]);

    final commands = Sequence.parseAll(buffer.toString()).map(Command.tryParse);
    check(commands).deepEquals([
      MoveCursorTo(),
      resetStyle,
      SetColor16(Color16.red.foregroundIndex),
      SetColor16(Color16.blue.backgroundIndex),
      Print('H'),
      SetColor16.resetForeground,
      SetColor16.resetBackground,
      Print('ello\nWorld'),
    ]);
  });
}

final class _TestBackend with AnsiSurfaceBackend {
  const _TestBackend(
    this.writer, [
    this.size = const (80, 24),
  ]);

  @override
  final Writer writer;

  @override
  final (int, int) size;
}
