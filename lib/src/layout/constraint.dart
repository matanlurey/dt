import 'dart:math' as math;

import 'package:meta/meta.dart';

/// Defines the size of a layout element.
///
/// Constraints can be used to specify a [Fixed] size, a [Relative] ratio of the
/// available space, a [Minimum] or [Maximum] size, or a [Flexible] proportional
/// value for a layout element.
///
/// [Relative] constraints calculated relative to the entire space being
/// divided, rather than the space available after applying more fixed
/// constraints such as [Fixed], [Minimum], or [Maximum].
///
/// ## Ordering
///
/// Constraints are ordered by their precedence:
///
/// 1. [Minimum]
/// 2. [Maximum]
/// 3. [Fixed]
/// 4. [Relative]
/// 5. [Flexible]
///
/// The values of the constraints themselves are not conisdered when comparing.
@immutable
sealed class Constraint implements Comparable<Constraint> {
  const Constraint();

  /// A constraint that specifies a minimum size.
  ///
  /// A negative value is clamped to zero.
  @literal
  const factory Constraint.minimum(int value) = Minimum;

  /// A constraint that specifies a maximum size.
  ///
  /// A negative value is clamped to zero.
  @literal
  const factory Constraint.maximum(int value) = Maximum;

  /// A constraint that specifies a fixed size.
  ///
  /// A negative value is clamped to zero.
  @literal
  const factory Constraint.fixed(int value) = Fixed;

  /// A constraint that specifies a percentage of the parent's size.
  ///
  /// The value is clamped to `[0, 1]`.
  @literal
  const factory Constraint.relative(double value) = Relative;

  /// A constraint that specifies a ratio of the parent's size.
  @literal
  const factory Constraint.ratio(
    int numerator,
    int denominator,
  ) = Relative.fraction;

  /// A constraint that fills the available space proportionally.
  ///
  /// A negative value is clamped to zero.
  @literal
  const factory Constraint.flexible(int value) = Flexible;

  /// Applies the constraint to the given [length] to return the final size.
  int apply(int length);

  /// The precedence of this constraint.
  int get _order;

  @nonVirtual
  @override
  int compareTo(Constraint other) => _order.compareTo(other._order);

  @override
  @mustBeOverridden
  bool operator ==(Object other);

  @override
  @mustBeOverridden
  int get hashCode;
}

/// A constraint that specifies a minimum size.
final class Minimum extends Constraint {
  /// Creates a new minimum constraint.
  ///
  /// If [value] is negative, it is clamped to zero.
  @literal
  const Minimum(int value) : value = value < 0 ? 0 : value;

  /// The element's size must be _at least_ this value.
  final int value;

  @override
  int get _order => 1;

  @override
  int apply(int length) => math.max(length, value);

  @override
  bool operator ==(Object other) {
    return other is Minimum && other.value == value;
  }

  @override
  int get hashCode => Object.hash(Minimum, value);

  @override
  String toString() => 'Constraint.min($value)';
}

/// A constraint that specifies a maximum size.
final class Maximum extends Constraint {
  /// Creates a new maximum constraint.
  ///
  /// If [value] is negative, it is clamped to zero.
  @literal
  const Maximum(int value) : value = value < 0 ? 0 : value;

  /// The element's size must be _at most_ this value.
  final int value;

  @override
  int get _order => 2;

  @override
  int apply(int length) => math.min(length, value);

  @override
  bool operator ==(Object other) {
    return other is Maximum && other.value == value;
  }

  @override
  int get hashCode => Object.hash(Maximum, value);

  @override
  String toString() => 'Constraint.max($value)';
}

/// A constraint that specifies a fixed size.
final class Fixed extends Constraint {
  /// Creates a new fixed constraint.
  ///
  /// If [value] is negative, it is clamped to zero.
  @literal
  const Fixed(int value) : value = value < 0 ? 0 : value;

  /// The element's size must be exactly this value.
  final int value;

  @override
  int get _order => 3;

  @override
  bool operator ==(Object other) {
    return other is Fixed && other.value == value;
  }

  @override
  int apply(int length) => math.min(length, value);

  @override
  int get hashCode => Object.hash(Fixed, value);

  @override
  String toString() => 'Constraint.fixed($value)';
}

/// A constraint that specifies a percentage of the parent's size.
///
/// The resulting value of [apply] is rounded back to an integer.
final class Relative extends Constraint {
  /// Creates a new ratio constraint from a floating-point between `0` and `1`.
  ///
  /// If the [value] is outside this range, it is clamped to `[0, 1]`.
  @literal
  const Relative(
    double value,
  ) : this._(
          value < 0
              ? 0
              : value > 1
                  ? 1
                  : value,
        );

  /// Creates a new ratio constraint from a percentage between `0` and `100`.
  ///
  /// If the [outOf100] is outside this range, it is clamped to `[0, 100]`.
  @literal
  const Relative.percent(
    int outOf100,
  ) : this(outOf100 / 100);

  /// Creates a new ratio constraint from a fraction.
  ///
  /// - If the [numerator] is < 0, the value is clamped to `0`.
  /// - If the [denominator] is < 1, the value is clamped to `1`.
  @literal
  const Relative.fraction(
    int numerator,
    int denominator,
  ) : this(numerator / (denominator < 1 ? 1 : denominator));

  const Relative._(
    this.value,
  ) : assert(value >= 0 && value <= 1, 'Invalid ratio');

  /// The size as a ratio of the parent's size.
  final double value;

  @override
  int get _order => 4;

  @override
  int apply(int length) => (length * value).floor();

  @override
  @override
  bool operator ==(Object other) {
    return other is Relative && other.value == value;
  }

  @override
  int get hashCode => Object.hash(Relative, value);

  @override
  String toString() => 'Constraint.relative($value)';
}

/// A constraint that fills the available space proportionally.
final class Flexible extends Constraint {
  /// Creates a new flexible constraint.
  ///
  /// If [value] is negative, it is clamped to zero.
  @literal
  const Flexible(int value) : value = value < 0 ? 0 : value;

  /// The scaling factor of the element's size proportional to others.
  final int value;

  @override
  int get _order => 5;

  @override
  int apply(int length) => math.max(length, value);

  @override
  bool operator ==(Object other) {
    return other is Flexible && other.value == value;
  }

  @override
  int get hashCode => Object.hash(Flexible, value);

  @override
  String toString() => 'Constraint.flexible($value)';
}
