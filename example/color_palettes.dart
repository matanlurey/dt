import 'dart:io' as io;
import 'dart:math' as math;

import 'package:dt/backend.dart';
import 'package:dt/foundation.dart';
import 'package:dt/rendering.dart';

void main() {
  // Create the buffer manually.
  final writer = StringWriter(
    Writer.fromSink(io.stdout, onFlush: io.stdout.flush),
  );
  run(writer, width: io.stdout.hasTerminal ? io.stdout.terminalColumns : 80);
}

void run(
  StringWriter writer, {
  required int width,
}) {
  _renderColor16(writer, width: width);
}

void _renderColor16(
  StringWriter writer, {
  required int width,
}) {
  // Check what the longest possible title width is.
  final maxWidth = Color16.values.map((c) {
    return '██ ### ### Color16.${c.name}'.length;
  }).reduce(math.max);

  // Check how many tiles can fit in the width of the terminal.
  final tilesPerLine = width ~/ (maxWidth + 2);

  // Render each color as the following tile format:
  //   FG BG Color16.name
  // █ ## ## name
  //
  // A minimum of 1 space is added between each tile, and as many tiles as fits
  // in the width of the terminal are rendered per line, wrapping as needed.
  var tilesLeft = tilesPerLine;
  for (final color in Color16.values) {
    var tile = '${color.foregroundIndex.toString().padLeft(3, '0')} '
        '${color.backgroundIndex.toString().padLeft(3, '0')} '
        'Color16.${color.name}';
    tile += ' ' * (maxWidth - tile.length);
    tile = '${color.setForeground().toSequence().toEscapedString()}██ '
        '${Color.reset.setForeground().toSequence().toEscapedString()}'
        '$tile';

    writer.write(tile);

    if (--tilesLeft == 0) {
      writer.writeLine();
      tilesLeft = tilesPerLine;
    } else {
      writer.write(' ');
    }
  }

  writer.writeLine();
}
