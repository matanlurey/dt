import 'dart:math' as math;

import 'package:characters/characters.dart';
import 'package:dt/foundation.dart';
import 'package:meta/meta.dart';

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
extension type const Buffer._(Grid<Cell> _grid) implements Grid<Cell> {
  /// Creates a new buffer with the given [width] and [height].
  ///
  /// The buffer is initialized with [fill] cells.
  ///
  /// The [width] and [height] must be non-negative.
  factory Buffer(int width, int height, [Cell fill = Cell.empty]) {
    return Buffer._(Grid(width, height, fill));
  }

  /// Creates an empty buffer with no cells.
  factory Buffer.empty() => Buffer._(Grid.empty());

  /// Creates a new buffer from the given [cells] and [width].
  ///
  /// The [cells] must have a length that is a multiple of the [width].
  factory Buffer.fromCells(Iterable<Cell> cells, {required int width}) {
    return Buffer._(Grid.fromCells(cells, width: width));
  }

  /// Creates a new buffer from the given [lines].
  ///
  /// The [width] and [height] must be non-negative.
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

  /// Creates a new grid from the given [rows].
  ///
  /// Each row must have the same length.
  factory Buffer.fromRows(Iterable<Iterable<Cell>> rows) {
    return Buffer._(Grid.fromRows(rows));
  }

  /// Creates a sub-buffer view into this grid within the given [bounds].
  ///
  /// The bounds must be within the grid's area.
  factory Buffer.view(Buffer buffer, Rect bounds) {
    return Buffer._(Grid.view(buffer, bounds));
  }

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
    area ??= this.area();
    for (var y = area.top; y < area.bottom; y++) {
      for (var x = area.left; x < area.right; x++) {
        set(x, y, fill);
      }
    }
  }

  /// Sets the style of all cells in the buffer to [style].
  void fillStyle(Style style, [Rect? area]) {
    area ??= this.area();
    for (var y = area.top; y < area.bottom; y++) {
      for (var x = area.left; x < area.right; x++) {
        set(x, y, get(x, y).copyWith(style: style));
      }
    }
  }

  /// Returns a sub-buffer view into this grid within the given [bounds].
  ///
  /// The bounds must be within the grid's area.
  @redeclare
  Buffer subGrid(Rect bounds) => Buffer._(_grid.subGrid(bounds));
}
