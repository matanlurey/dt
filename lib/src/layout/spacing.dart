import 'package:meta/meta.dart';

/// Defines spacing insets for edges of a box.
@immutable
final class Spacing {
  /// Creates spacing with no offsets.
  static const none = Spacing.all(0);

  /// Creates spacing from offsets from the left, top, right, and bottom edges.
  const Spacing.fromLTRB(
    this.left,
    this.top,
    this.right,
    this.bottom,
  );

  /// Creates spacing where all the offsets are the same.
  const Spacing.all(
    int value,
  ) : this.fromLTRB(value, value, value, value);

  /// Creates spacing with symmetrical vertical and horizontal offsets.
  const Spacing.symmetric({
    int vertical = 0,
    int horizontal = 0,
  }) : this.fromLTRB(horizontal, vertical, horizontal, vertical);

  /// Creates spacing with symmetrical horizontal offsets.
  const Spacing.horizontal({
    int value = 0,
  }) : this.fromLTRB(value, 0, value, 0);

  /// Creates spacing with symmetrical vertical offsets.
  const Spacing.vertical({
    int value = 0,
  }) : this.fromLTRB(0, value, 0, value);

  /// Creates spacing where only the given values are non-zero.
  const Spacing.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  /// Offset from the left edge.
  final int left;

  /// Offset from the top edge.
  final int top;

  /// Offset from the right edge.
  final int right;

  /// Offset from the bottom edge.
  final int bottom;

  /// Returns the sum of the horizontal offsets.
  int get horizontal => left + right;

  /// Returns the sum of the vertical offsets.
  int get vertical => top + bottom;

  @override
  bool operator ==(Object other) {
    if (other is! Spacing) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return left == other.left &&
        top == other.top &&
        right == other.right &&
        bottom == other.bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() {
    if (left == 0 && top == 0 && right == 0 && bottom == 0) {
      return 'Spacing.none';
    }
    if (left == right && top == bottom) {
      if (left == top) {
        return 'Spacing.all($left)';
      }
      if (left == 0 && top == 0) {
        return 'Spacing.none';
      }
      if (left == 0) {
        return 'Spacing.vertical($top)';
      }
      if (top == 0) {
        return 'Spacing.horizontal($left)';
      }
      return 'Spacing.symmetric(vertical: $top, horizontal: $left)';
    }
    return 'Spacing.fromLTRB($left, $top, $right, $bottom)';
  }
}
