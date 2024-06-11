import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:dt/layout.dart';

import 'cell.dart';
import 'line.dart';
import 'span.dart';
import 'style.dart';

/// A buffer that maps to the desired content of a terminal after rendering.
///
/// Widgets and other renderable objects do not typically interact directly with
/// a terminal and instead draw their state to an intermediate buffer, which is
/// a grid where each [Cell] contains a single symbol (grapheme) and an optional
/// [Style].
abstract final class Buffer {
  /// Creates a new buffer with the given [width] and [height].
  ///
  /// The buffer is initialized with [fill] cells.
  ///
  /// The [width] and [height] must be non-negative.
  factory Buffer(int width, int height, [Cell fill = Cell.empty]) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');
    return _Buffer(
      List<Cell>.filled(width * height, fill),
      width,
    );
  }

  /// Creates a new buffer from the given [lines].
  factory Buffer.fromLines(Iterable<Line> lines) {
    final lines_ = List.of(lines);
    final height = lines_.length;
    final width = lines_.fold(0, (width, line) => math.max(width, line.width));

    final buffer = Buffer(width, height);
    for (var y = 0; y < height; y++) {
      buffer.setLine(0, y, lines_.elementAt(y));
    }
    return buffer;
  }

  const Buffer._();

  /// Individual cells in the buffer from top-left to bottom-right.
  Iterable<Cell> get cells;

  /// Each row of cells in the buffer from top to bottom.
  Iterable<Iterable<Cell>> get rows {
    return Iterable.generate(
      height,
      (y) => Iterable.generate(width, (x) => get(x, y)),
    );
  }

  /// Width of the buffer.
  int get width;

  /// Height of the buffer.
  int get height;

  /// Returns the area of the buffer as a rectangle with an optional [offset].
  Rect toArea([Offset offset = Offset.zero]) {
    return Rect.fromXYWH(offset.x, offset.y, width, height);
  }

  /// Returns the index of the cell at the given [x] and [y] coordinates.
  ///
  /// Throws if the coordinates are out of bounds.
  int _indexOf(int x, int y) => x + y * width;

  /// Returns the cell at the given [x] and [y] coordinates.
  ///
  /// Throws if the coordinates are out of bounds.
  Cell get(int x, int y) => cells.elementAt(_indexOf(x, y));

  /// Sets the cell at the given [x] and [y] coordinates to [cell].
  ///
  /// Throws if the coordinates are out of bounds.
  void set(int x, int y, Cell cell);

  /// Prints a string, starting at the given [x] and [y] coordinates.
  ///
  /// If [maxWidth] is provided, the string will be truncated to fit within the
  /// buffer's width, which otherwise defaults to the buffer's width if omitted.
  ///
  /// Throws if the coordinates are out of bounds.
  void print(
    int x,
    int y,
    String string, {
    Style style = Style.inherit,
    int? maxWidth,
  }) {
    maxWidth ??= width - x;
    var remaining = math.min(string.characters.length, maxWidth);

    // Get all non-zero width characters up to the maximum width.
    final graphemes = string.characters.takeWhile((char) {
      final width = char.characters.length;
      if (width > remaining) {
        return false;
      }
      remaining -= width;
      return true;
    });

    // Print each grapheme to the buffer.
    var i = 0;
    for (final grapheme in graphemes) {
      set(x + i, y, Cell(grapheme, style));
      i += grapheme.characters.length;
    }
  }

  /// Prints a span of text starting at the given [x] and [y] coordinates.
  ///
  /// If [maxWidth] is provided, the span will be truncated to fit within the
  /// buffer's width, which otherwise defaults to the buffer's width if omitted.
  ///
  /// Throws if the coordinates are out of bounds.
  void printSpan(int x, int y, Span span, {int? maxWidth}) {
    print(x, y, span.content, style: span.style, maxWidth: maxWidth);
  }

  /// Sets cells starting at the given [x] and [y] coordinates to [line].
  ///
  /// If [maxWidth] is provided, the line will be truncated to fit within the
  /// buffer's width, which otherwise defaults to the buffer's width if omitted.
  ///
  /// Throws if the coordinates are out of bounds.
  void setLine(int x, int y, Line line, {int? maxWidth}) {
    final width = maxWidth ?? this.width;
    var i = 0;
    for (final span in line.spans) {
      final content = span.content;
      final style = span.style;
      print(x + i, y, content, maxWidth: width - x - i, style: style);
      i += content.characters.length;
    }
  }

  /// Fills the buffer with the given [fill] cell.
  void fillCells([Cell fill = Cell.empty, Rect? area]) {
    area ??= toArea();
    for (var y = area.top; y < area.bottom; y++) {
      for (var x = area.left; x < area.right; x++) {
        set(x, y, fill);
      }
    }
  }

  /// Sets the style of all cells in the buffer to [style].
  void fillStyle(Style style, [Rect? area]) {
    area ??= toArea();
    for (var y = area.top; y < area.bottom; y++) {
      for (var x = area.left; x < area.right; x++) {
        set(x, y, get(x, y).copyWith(style: style));
      }
    }
  }
}

final class _Buffer extends Buffer {
  _Buffer(this.cells, this.width) : super._();

  @override
  final List<Cell> cells;

  @override
  final int width;

  @override
  int get height => cells.length ~/ width;

  @override
  void set(int x, int y, Cell cell) {
    cells[_indexOf(x, y)] = cell;
  }
}
