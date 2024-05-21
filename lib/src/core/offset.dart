import 'dart:math' as math;

import 'package:meta/meta.dart';

/// An immutable 2D fixed-point offset.
///
/// This class is used to represent a point in a 2D plane, such as the cursor's
/// position on a terminal screen, the start or end of a text selection in a
/// text editor, or relative positioning of a widget in a 2D space.
///
/// ## Equality
///
/// Two offsets are considered equal if both [x] and [y] are equal.
///
/// ## Comparison
///
/// Offsets are ordered by their [y] coordinate first, then by their [x], or:
///
/// ```txt
/// Offset (0,0) < Offset (1,0) < Offset (0,1) < Offset (1,1)
/// ```
///
/// This property makes offsets suitable to determine the order of text.
@immutable
final class Offset implements Comparable<Offset> {
  /// An offset with zero horizontal and vertical coordinates.
  ///
  /// Can be used as a constant to represent the origin of a 2D plane.
  static const zero = Offset(0, 0);

  /// Creates an offset with the given horizontal and vertical coordinates.
  const Offset(this.x, this.y);

  /// The x-coordinate of this offset.
  final int x;

  /// The y-coordinate of this offset.
  final int y;

  @override
  int compareTo(Offset other) {
    return y == other.y ? x.compareTo(other.x) : y.compareTo(other.y);
  }

  /// Returns true if this offset is after [other].
  ///
  /// An alias for [operator<].
  bool isBefore(Offset other) => compareTo(other) < 0;

  /// Returns true if this offset is before [other].
  bool operator <(Offset other) => isBefore(other);

  /// Return true if this offset is before or equal to [other].
  bool operator <=(Offset other) => compareTo(other) <= 0;

  /// Returns true if this offset is after [other].
  ///
  /// An alias for [operator>].
  bool isAfter(Offset other) => compareTo(other) > 0;

  /// Returns true if this offset is after [other].
  bool operator >(Offset other) => isAfter(other);

  /// Returns true if this offset is after or equal to [other].
  bool operator >=(Offset other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    return other is Offset && x == other.x && y == other.y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  /// Returns the absolute value of this offset.
  Offset abs() => Offset(x.abs(), y.abs());

  /// Returns the offset clamped to the given [min] and [max] offsets.
  Offset clamp(Offset min, Offset max) {
    return Offset(
      x.clamp(min.x, max.x),
      y.clamp(min.y, max.y),
    );
  }

  /// Returns the distance between this offset and [other].
  double distanceTo(Offset other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Returns an offset that is the result of [dx]+[x] and [dy]+[y].
  ///
  /// Prefer [operator+] for adding two offsets.
  Offset translate(int dx, int dy) => Offset(x + dx, y + dy);

  /// Returns an offset that is the sum of this offset and [other].
  Offset operator +(Offset other) => Offset(x + other.x, y + other.y);

  /// Returns an offset that is the difference of this offset and [other].
  Offset operator -(Offset other) => Offset(x - other.x, y - other.y);

  /// Returns an offset that is the negation of this offset.
  Offset operator -() => Offset(-x, -y);

  /// Returns an offset that is the product of this offset and [factor].
  Offset operator *(int factor) => Offset(x * factor, y * factor);

  /// Returns an offset that is the quotient of this offset and [quotient].
  ///
  /// The result is truncated towards zero.
  Offset operator ~/(int quotient) => Offset(x ~/ quotient, y ~/ quotient);

  /// Returns an offset that is the remainder of this offset and [quotient].
  ///
  /// The result has the same sign as the divisor.
  Offset operator %(int quotient) => Offset(x % quotient, y % quotient);

  @override
  String toString() => 'Offset ($x, $y)';
}
