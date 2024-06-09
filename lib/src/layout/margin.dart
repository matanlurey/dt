import 'package:meta/meta.dart';

/// A set of offsets from the edges of a rectangle.
///
/// ## Equality
///
/// Two margins are equal if their offsets from the left, top, right, and bottom
/// edges are equal.
@immutable
final class Margin {
  /// A margin with zero offsets.
  static const zero = Margin.all(0);

  /// Creates a margin where each edge is [value].
  @literal
  const Margin.all(
    int value,
  )   : left = value,
        top = value,
        right = value,
        bottom = value;

  /// Creates a margin where only given values are non-zero.
  @literal
  const Margin.only({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
  });

  /// Creates a margin from offsets from the left, top, right, and bottom edges.
  @literal
  const Margin.fromLTRB(
    this.left,
    this.top,
    this.right,
    this.bottom,
  );

  /// Creates a margin with horizontal and vertical offsets.
  @literal
  const Margin.symmetric({
    int vertical = 0,
    int horizontal = 0,
  })  : left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;

  /// Margin from the left edge.
  final int left;

  /// Margin from the top edge.
  final int top;

  /// Margin from the right edge.
  final int right;

  /// Margin from the bottom edge.
  final int bottom;

  @override
  bool operator ==(Object other) {
    return other is Margin &&
        other.left == left &&
        other.top == top &&
        other.right == right &&
        other.bottom == bottom;
  }

  @override
  int get hashCode => Object.hash(left, top, right, bottom);

  @override
  String toString() {
    if (left == top && left == right && left == bottom) {
      if (left == 0) {
        return 'Margin.zero';
      }
      return 'Margin.all($left)';
    } else if (left == right && top == bottom) {
      return 'Margin.symmetric(vertical: $top, horizontal: $left)';
    } else {
      return 'Margin.fromLTRB($left, $top, $right, $bottom)';
    }
  }
}
