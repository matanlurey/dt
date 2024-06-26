import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'offset.dart';

/// A rectangular area defined by its top-left corner `(x, y)` and dimensions.
///
/// ## Equality
///
/// Two rectangles are equal if their [x], [y], [width], and [height] are equal.
@immutable
final class Rect {
  /// A zero-sized rectangle at the origin.
  static const zero = Rect.fromLTWH(0, 0, 0, 0);

  /// Creates a new rectangle.
  ///
  /// If either [width] or [height] is negative, they are clamped to zero.
  @literal
  const Rect.fromLTWH(
    this.x,
    this.y,
    int width,
    int height,
  )   : // coverage:ignore-start
        width = width < 0 ? 0 : width,
        height = height < 0 ? 0 : height;
  // coverage:ignore-end

  /// Creates a new rectangle of [width] and [height] with a default origin.
  ///
  /// If either [width] or [height] is negative, they are clamped to zero.
  @literal
  const Rect.fromSize(
    int width,
    int height,
  ) : this.fromLTWH(0, 0, width, height);

  /// X-coordinate of the top-left corner of this rectangle.
  final int x;

  /// Y-coordinate of the top-left corner of this rectangle.
  final int y;

  /// Width of this rectangle.
  final int width;

  /// Height of this rectangle.
  final int height;

  @override
  bool operator ==(Object other) {
    return other is Rect &&
        other.x == x &&
        other.y == y &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(x, y, width, height);

  /// The left edge of this rectangle on the x-axis.
  int get left => x;

  /// The top edge of this rectangle on the y-axis.
  int get top => y;

  /// The right edge of this rectangle on the x-axis.
  int get right => x + width;

  /// The bottom edge of this rectangle on the y-axis.
  int get bottom => y + height;

  /// The top-left corner of this rectangle.
  Offset get topLeft => Offset(x, y);

  /// The top-right corner of this rectangle.
  Offset get topRight => Offset(right, y);

  /// The bottom-left corner of this rectangle.
  Offset get bottomLeft => Offset(x, bottom);

  /// The bottom-right corner of this rectangle.
  Offset get bottomRight => Offset(right, bottom);

  /// The area of the rectangle.
  int get area => width * height;

  /// Whether the rectangle is empty (has no area).
  bool get isEmpty => area == 0;

  /// Whether the rectangle is not empty (has area).
  bool get isNotEmpty => !isEmpty;

  /// Returns a copy of this rectangle with the given arguments replaced.
  ///
  /// If no arguments are given, the original rectangle is returned.
  Rect copyWith({
    int? x,
    int? y,
    int? width,
    int? height,
  }) {
    return Rect.fromLTWH(
      x ?? this.x,
      y ?? this.y,
      width ?? this.width,
      height ?? this.height,
    );
  }

  /// Returns a rectangle with a new [offset] without modifying its size.
  Rect withOffset(Offset offset) {
    return Rect.fromLTWH(offset.x, offset.y, width, height);
  }

  /// Returns a rectangle that contains both this rectangle and [other].
  Rect union(Rect other) {
    final x1 = math.min(x, other.x);
    final y1 = math.min(y, other.y);
    final x2 = math.max(right, other.right);
    final y2 = math.max(bottom, other.bottom);
    return Rect.fromLTWH(x1, y1, x2 - x1, y2 - y1);
  }

  /// Returns a union of this rectangle and [other].
  ///
  /// An alias for [union].
  Rect operator &(Rect other) => union(other);

  /// Returns an intersection of this rectangle and [other].
  ///
  /// If the rectangles do not intersect, an empty rectangle is returned.
  Rect intersect(Rect other) {
    final x1 = math.max(x, other.x);
    final y1 = math.max(y, other.y);
    final x2 = math.min(right, other.right);
    final y2 = math.min(bottom, other.bottom);
    return Rect.fromLTWH(x1, y1, math.max(0, x2 - x1), math.max(0, y2 - y1));
  }

  /// Returns an intersection of this rectangle and [other].
  ///
  /// An alias for [intersect].
  Rect operator |(Rect other) => intersect(other);

  /// Returns whether this rectangle intersects with [other].
  bool intersects(Rect other) {
    return x < other.right &&
        right > other.x &&
        y < other.bottom &&
        bottom > other.y;
  }

  /// Returns whether this rectangle contains the given [offset].
  bool contains(Offset offset) {
    return offset.x >= x &&
        offset.x < right &&
        offset.y >= y &&
        offset.y < bottom;
  }

  /// Returns whether this rectangle contains the given [rect].
  bool containsRect(Rect rect) {
    return x <= rect.x &&
        y <= rect.y &&
        right >= rect.right &&
        bottom >= rect.bottom;
  }

  /// Clamps this rectangle to fit within the given [bounds].
  ///
  /// This is different from [intersect] in that the size of the rectangle
  /// is not changed, only its position.
  Rect clamp(Rect bounds) {
    final x = math.max(this.x, bounds.x);
    final y = math.max(this.y, bounds.y);
    final right = math.min(this.right, bounds.right);
    final bottom = math.min(this.bottom, bounds.bottom);
    return Rect.fromLTWH(x, y, right - x, bottom - y);
  }

  /// Iterable of all offsets within this rectangle.
  ///
  /// The offsets are ordered from left to right, top to bottom.
  ///
  /// ```dart
  /// final rect = Rect(1, 1, 2, 2);
  ///
  /// for (final offset in rect.offsets) {
  ///   print(offset);
  /// }
  ///
  /// // Output:
  /// // Offset(1, 1)
  /// // Offset(2, 1)
  /// // Offset(1, 2)
  /// // Offset(2, 2)
  /// ```
  Iterable<Offset> get offsets => _RectOffsets(this);

  @override
  String toString() {
    if (x == 0 && y == 0) {
      return 'Rect.fromSize($width, $height)';
    }
    return 'Rect.fromLTWH($x, $y, $width, $height)';
  }
}

final class _RectOffsets extends Iterable<Offset> {
  final Rect rect;

  _RectOffsets(this.rect);

  @override
  Iterator<Offset> get iterator => _RectOffsetsIterator(rect);
}

final class _RectOffsetsIterator implements Iterator<Offset> {
  final Rect _rect;
  final int _length;

  Offset? _current;
  var _index = 0;

  _RectOffsetsIterator(this._rect) : _length = _rect.width * _rect.height;

  @override
  Offset get current {
    return _current ?? (throw StateError('No offset'));
  }

  @override
  bool moveNext() {
    if (_index >= _length) {
      _current = null;
      return false;
    }

    final x = _rect.x + _index % _rect.width;
    final y = _rect.y + _index ~/ _rect.width;
    _current = Offset(x, y);
    _index++;
    return true;
  }
}
