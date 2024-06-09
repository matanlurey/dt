import 'package:meta/meta.dart';

/// A 2D offset relative to the top left corner of a coordinate space.
///
/// - The [x]-axis is horizontal increasing to the right.
/// - The [y]-axis is vertical increasing downwards.
///
/// ## Equality
///
/// Two offsets are equal if their [x] and [y] coordinates are equal.
///
/// ## Comparison
///
/// Offsets are ordered in relation to their [x] and [y] coordinates.
///
/// That is, an offset in the top-left corner is less than an offset in the
/// bottom-right corner. If two offsets have the same [y] coordinate, the one
/// with the smaller [x] coordinate is less, and vice versa.
///
/// If both coordinates are different, the offset with the smaller [y]
/// coordinate is less. If both coordinates are equal, the offsets are equal.
@immutable
final class Offset implements Comparable<Offset> {
  /// The zero offset, or origin.
  static const zero = Offset(0, 0);

  /// Creates a new offset.
  @literal
  const Offset(this.x, this.y);

  /// Creates a new offset from a coordinate pair `(x, y)`.
  factory Offset.from((int x, int y) pair) {
    final (x, y) = pair;
    return Offset(x, y);
  }

  /// X-coordinate of this offset.
  ///
  /// Relative to the left edge of the coordinate space.
  final int x;

  /// Y-coordinate of this offset.
  ///
  /// Relative to the top edge of the coordinate space.
  final int y;

  @override
  bool operator ==(Object other) {
    return other is Offset && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);

  @override
  int compareTo(Offset other) {
    if (y < other.y) return -1;
    if (y > other.y) return 1;
    if (x < other.x) return -1;
    if (x > other.x) return 1;
    return 0;
  }

  /// Returns a pair `(x, y)` of this offset.
  (int x, int y) toPair() => (x, y);

  @override
  String toString() => 'Offset($x, $y)';
}
