import 'package:meta/meta.dart';

import 'cassowary/constraint.dart';
import 'cassowary/expr.dart';
import 'cassowary/row.dart';
import 'cassowary/strength.dart';
import 'cassowary/symbol.dart';

export 'cassowary/constraint.dart' show Constraint;
export 'cassowary/expr.dart' show Expr, Op;
export 'cassowary/strength.dart' show Strength;

/// A constraint solver using the Cassowary algorithm.
final class Solver {
  /// Constructs a new solver.
  Solver()
      : _constraints = {},
        _variables = {},
        _symbols = {},
        _changes = [],
        _changed = {},
        _shouldClearChanges = false,
        _rows = {},
        _edits = {},
        _infeasibleRows = [],
        _objective = Row(),
        _idTick = 1;

  final Map<Constraint, _Tag> _constraints;
  final Map<Var, (double, Symbol, int)> _variables;
  final Map<Symbol, Var> _symbols;

  final List<(Var, double)> _changes;
  final Set<Var> _changed;
  bool _shouldClearChanges;

  final Map<Symbol, Row> _rows;
  final Map<Var, _Edit> _edits;
  final List<Symbol> _infeasibleRows;
  Row _objective;
  Row? _artificial;

  int _idTick;

  /// Adds a constraint to the solver.
  ///
  /// Returns an error if the operation failed.
  @useResult
  AddConstraintError? addConstraint(Constraint constraint) {
    if (_constraints.containsKey(constraint)) {
      return AddConstraintError.duplicate;
    }

    final (row, tag) = _createRow(constraint);

    var subject = _chooseSubject(row, tag);
    if (subject.kind == SymbolKind.invalid &&
        row.cells.keys.every((s) => s.kind == SymbolKind.dummy)) {
      if (row.constant.isNearZero) {
        return AddConstraintError.unsatisfiable;
      }
      subject = tag.marker;
    }

    if (subject.kind == SymbolKind.invalid) {}
  }

  (Row, _Tag) _createRow(Constraint constraint) {
    throw UnimplementedError();
  }

  static Symbol _chooseSubject(Row row, _Tag tag) {
    for (final s in row.cells.keys) {
      if (s.kind == SymbolKind.external) {
        return s;
      }
    }

    return switch (tag.marker.kind) {
      SymbolKind.slack ||
      SymbolKind.error when row.coefficientFor(tag.marker) < 0.0 =>
        tag.marker,
      SymbolKind.slack ||
      SymbolKind.error when row.coefficientFor(tag.marker) < 0.0 =>
        tag.marker,
      _ => const Symbol.invalid(),
    };
  }
}

/// An error that occurs when adding a constraint to the solver.
enum AddConstraintError {
  /// The constraint is a duplicate of an existing constraint.
  duplicate,

  /// The constraint is required but is it not satisfiable.
  unsatisfiable,
}

final class _Tag {
  const _Tag({
    required this.marker,
    required this.other,
  });

  final Symbol marker;
  final Symbol other;
}

final class _Edit {
  const _Edit({
    required this.tag,
    required this.constraint,
    required this.constant,
  });

  final _Tag tag;
  final Constraint constraint;
  final double constant;
}
