import 'package:meta/meta.dart';

/// Identifies a variable in the constraint solver.
///
/// Each new variable is unique in the view of the solver.
extension type const Var(int _) {}

/// A variable and a coefficient to multiply that variable by.
///
/// This is a sub-expression in a constraint equation.
@immutable
final class Term {
  /// Creates a new term in a constraint equation.
  Term(this.variable, this.coefficient);

  /// The variable in the term.
  final Var variable;

  /// The coefficient to multiply the variable by.
  final double coefficient;

  @override
  bool operator ==(Object other) {
    return other is Term &&
        other.variable == variable &&
        other.coefficient == coefficient;
  }

  @override
  int get hashCode => Object.hash(variable, coefficient);

  @override
  String toString() {
    final sign = coefficient < 0 ? '-' : '+';
    final coeff = coefficient.abs();
    return '$sign $coeff $variable';
  }
}

/// An expression that can be the left or right side of a constraint equation.
///
/// An expression is a linear combination of variables and constants.
final class Expr {
  /// Creates a new expression from a list of [terms] and a [constant].
  ///
  /// Each term is a variable and a coefficient to multiply that variable by.
  ///
  /// The constant is a real number that is added to the sum of the terms.
  Expr(this.terms, this.constant);

  /// Constructs an expression of the form _n_, a constant real number.
  Expr.fromConstant(
    double constant,
  ) : this(const [], constant);

  /// Constructs an expression from a single [term].
  ///
  /// Forms an expression of the form _n x_, where _n_ is the coefficient of
  /// and _x_ is the variable.
  Expr.fromTerm(
    Term term,
  ) : this([term], 0);

  /// Constructs an expression from a single [variable].
  ///
  /// Forms an expression of the form _x_, where _x_ is the variable and the
  /// coefficient is `1`.
  Expr.fromVar(Var variable) : this.fromTerm(Term(variable, 1));

  /// Terms in the expression.
  ///
  /// It is undefined behavior to modify the list after creating the expression.
  final List<Term> terms;

  /// Constant value in the expression.
  final double constant;

  /// Mutates this expression by multiplying it by `-1`.
  @useResult
  Expr operator -() {
    return Expr(
      [for (final term in terms) Term(term.variable, -term.coefficient)],
      -constant,
    );
  }
}

/// Possible relational operators for constraints.
enum Op {
  /// Less than or equal to (`<=`).
  lessOrEqual('<='),

  /// Equal to (`==`).
  equal('=='),

  /// Greater than or equal to (`>=`).
  greaterOrEqual('>=');

  const Op(this._symbol);
  final String _symbol;

  /// Returns a weighted relation with this operator.
  WeightedRelation call(double weight) => WeightedRelation(this, weight);

  @override
  String toString() => _symbol;
}

/// An operator with a weight.
@immutable
final class WeightedRelation {
  /// Constructs a new weighted relation.
  const WeightedRelation(this.op, this.weight);

  /// The operator.
  final Op op;

  /// The weight of the operator.
  final double weight;

  @override
  bool operator ==(Object other) {
    return other is WeightedRelation &&
        other.op == op &&
        other.weight == weight;
  }

  @override
  int get hashCode => Object.hash(op, weight);

  @override
  String toString() => '$op | $weight';
}
