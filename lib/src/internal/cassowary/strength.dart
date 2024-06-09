import 'dart:math' as math;

/// A precedence value for deciding the relative importance of constraints.
///
/// Each constraint added to the solver has an associated strength specifying
/// the precedence the solver should impose when choosing which constraints to
/// enforce; it will try to enforce _all_ constraints, but when it can't, the
/// lower-strength constraints are the first to be violated.
///
/// Strengths are real numbers. The strongest legal strengh is [required], and
/// the weakest is [none]. For convenience constants are declared for other
/// commonly used strengths: [strong], [medium], and [weak], which can also
/// be multiplied by a scalar to create custom strengths, but are always brought
/// into a valid range.
///
/// It is undefined behavior to cast from a double; use [Strength.from] instead.
extension type const Strength._(double _) {
  /// Creates a constraint as a linear combination of the three basic strengths.
  ///
  /// The result is further multiplied by a scalar [weight].
  factory Strength({
    double strong = 0,
    double medium = 0,
    double weak = 0,
    double weight = 1,
  }) {
    return Strength._(_fromABCW(strong, medium, weak, weight));
  }

  /// Returns a strength by clamping the given value to the valid range.
  factory Strength.from(double strength) {
    return Strength._(strength.clamp(_none, _required));
  }

  static double _fromABCW(double a, double b, double c, double w) {
    var result = 0.0;
    result += math.max(0.0, math.min(1000.0, a * w)) * _strong;
    result += math.max(0.0, math.min(1000.0, b * w)) * _medium;
    result += math.max(0.0, math.min(1000.0, c * w)) * _weak;
    return result;
  }

  /// A constaint that cannot be violated under any circumstances.
  ///
  /// Use this special strength sparingly, as the solver will fail completely
  /// if it finds that not all of the [required] constraints can be satisfied,
  /// where-as the any other strength are considered [isFallible].
  ///
  /// The same result as `Strength(strong: 1000, medium: 1000, weak: 1000)`.
  static const required = Strength._(_required);
  static const _required = _strong * _medium + _strong + _medium;

  /// A strong constraint that should be satisfied whenever possible.
  ///
  /// The same result as `Strength(strong: 1);
  static const strong = Strength._(_strong);
  static const _strong = _medium * _medium;

  /// A medium constraint that should be satisfied when possible.
  ///
  /// The same result as `Strength(medium: 1);
  static const medium = Strength._(_medium);
  static const _medium = 1000.0;

  /// A weak constraint that should be satisfied when possible.
  ///
  /// The same result as `Strength(weak: 1);
  static const weak = Strength._(_weak);
  static const _weak = 1.0;

  /// The lowest bound for a strength.
  static const none = Strength._(_none);
  static const _none = 0.0;

  /// Whether this strength is [required] to be satisfied.
  bool get isRequired => this == required;

  /// Whether this strength can be violated without causing the solver to fail.
  bool get isFallible => !isRequired;

  /// Returns the product of this strength and the given scalar.
  ///
  /// The result is clamped to the valid range.
  Strength operator *(double scalar) => Strength.from(_ * scalar);
}
