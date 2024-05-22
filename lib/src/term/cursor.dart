import 'dart:math' as math;

import 'package:dt/src/core.dart';

/// A position in a terminal represented by a [column] and [line].
///
/// **NOTE**: Cursors by nature are _not_ immutable, and their properties may
/// change in some implementations. As a result, they do not implement [==] or
/// [hashCode]; instead, use [offset] to compare cursor positions:
/// ```dart
/// final cursor = Cursor(column: 1, line: 2);
/// final other = Cursor(column: 1, line: 2);
/// assert(cursor.offset == other.offset);
/// ```
interface class Cursor {
  /// Creates a new cursor at the given [column] and [line].
  ///
  /// If either is omitted, they default to `0`.
  Cursor({
    int column = 0,
    int line = 0,
  }) : this._(column, line);

  /// Creates a new cursor at the given [x] and [y] coordinates.
  Cursor.fromXY(
    int x,
    int y,
  ) : this._(x, y);

  Cursor._(
    int column,
    int line,
  )   : column = math.max(0, column),
        line = math.max(0, line);

  /// The column, or x-coordinate from the left, of the cursor.
  ///
  /// Columns are zero-based and are clamped to non-negative values.
  final int column;

  /// The line, or y-coordinate from the top, of the cursor.
  ///
  /// Lines are zero-based and are clamped to non-negative values.
  final int line;

  /// The cursor represented as an offset.
  Offset get offset => Offset(column, line);

  @override
  String toString() => 'Cursor <$line:$column>';
}
