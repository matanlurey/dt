/// A simple & specialized Cassowary implementation that is not public API.
///
/// This algorithm is designed primarily for constraining elements in user
/// interfaces, where constraints are linear combinations of the problem
/// variables.
library;

import 'package:meta/meta.dart';

import 'expr.dart';
import 'strength.dart';

/// A constaint; an equation governed by an [expr], [op], and [strength].
@immutable
final class Constraint {
  /// Constructs a new constraint.
  ///
  /// This cooresponds to the equation `expr op 0`, e.g. `x + y >= 0.0`.
  ///
  /// For equations with a non-zero right-hand side, subtract it from the
  /// equation to give a zero right-hand side, e.g. `x + y >= 10.0` becomes
  /// `x + y - 10.0 >= 0.0`.
  @literal
  const Constraint(this.expr, this.op, this.strength);

  /// The expression on the left-hand side of the equation.
  final Expr expr;

  /// The relational operator in the equation.
  final Op op;

  /// The strength of the constraint.
  final Strength strength;

  @override
  bool operator ==(Object other) {
    return other is Constraint &&
        other.expr == expr &&
        other.op == op &&
        other.strength == strength;
  }

  @override
  int get hashCode => Object.hash(expr, op, strength);

  @override
  String toString() => '$expr $op 0 | $strength';
}

/// Intermediate type used to specify a constraint.
typedef PartialConstraint = (Expr, WeightedRelation);
