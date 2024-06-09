import 'package:meta/meta.dart';

/// Contains useful constants and functions for producing strength values.
///
/// Each constraint added to the solver has an associated [Strength] specifying
/// the precedence the solver should impose when choosing which constraints to
/// enforce; it will try to enforce all constraints, but if that is impossible
/// the lower-strength constraints will be violated first.
///
/// The streongest legal strength is [required], and the weakest is [none].
///
/// For convenience constants are declared for commonly used strengths:
/// - [required]; a constraint that cannot be violated under any circumstances.
/// - [strong]; a constraint that should be satisfied if possible.
/// - [medium]; a somewhat important constraint.
/// - [weak]; a constraint that is not very important.
/// - [none]; a constraint that is not important at all.
///
/// These strengths can be multiplied by other values to get intermediate
/// strengths, or added together to get a strength that is the combination of
/// multiple constraints. Note that the solver will clip given strengths to the
/// legal range of values.
extension type const Strength._(double _) {
  /// Signifies a constraint that cannot be violated under any circumstances.
  ///
  /// Use this special strength sparignly, as the solver will fail completely
  /// if it finds that it cannot satisty _all_ required constraints.
  static const required = Strength._(_required);
  static const _required = _strong * _medium + _strong + _medium;

  /// Signifies a constraint that should be satisfied if possible.
  static const strong = Strength._(_strong);
  static const _strong = _medium * _medium;

  /// Signifies a somewhat important constraint.
  static const medium = Strength._(_medium);
  static const _medium = 1000.0;

  /// Signifies a constraint that is not very important.
  static const weak = Strength._(1);

  /// Signifies a constraint that is not important at all.
  static const none = Strength._(0);

  @literal
  const Strength._clamp(double value)
      : this._(
          value < 0
              ? 0
              : value > _required
                  ? _required
                  : value,
        );

  /// Creates a constraint as a linear combination of strong, medium, and weak.
  ///
  /// The result is further multiplied by [weight] to get the final strength.
  factory Strength.fromSWMW(
    double strong,
    double medium,
    double weak, [
    double weight = 1,
  ]) {
    final ds = (strong * weight).clamp(0, _medium) * _strong;
    final dm = (medium * weight).clamp(0, _medium) * _medium;
    final dw = (weak * weight).clamp(0, _medium);
    return Strength._clamp(ds + dm + dw);
  }

  /// Multiplies this strength by the given [value].
  ///
  /// The result is clipped to the legal range of values.
  Strength operator *(double value) => Strength._clamp(_ * value);
}
