import 'package:meta/meta.dart';

/// Identifies a variable for the constraint solver.
///
/// Each new variable should be unique in the view of a solver.
extension type const Variable(int _) {}

/// A variable and a coefficient to multiply that variable by.
///
/// This is a sub-expression in a constraint equation.
@immutable
final class Term {
  /// Constructs a new term from a variable and a coefficient.
  @literal
  const Term(this.variable, [this.coefficient = 1.0]);

  /// The variable in the term.
  final Variable variable;

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
    return 'Var<$variable> * $coefficient';
  }
}

/// An expression that can be the left or right side of a constraint equation.
///
/// It is a linear combination of variables weighted by coefficients, plus an
/// optional [constant].
final class Expression {}
