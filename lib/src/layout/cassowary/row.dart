import 'symbol.dart';

/// An extension on [double] to check if it is near zero.
extension IsNearZero on double {
  /// Returns whether the number is near zero.
  bool get isNearZero => (this - 0).abs() < 1.0e-8;
}

/// A row in the solver.
final class Row {
  /// Creates a new row with a constant value.
  Row([this.constant = 0]) : cells = const {};

  /// The cells in the row.
  ///
  /// It is undefined to modify this map directly.
  final Map<Symbol, double> cells;

  /// The constant value in the row.
  ///
  /// It is undefined to modify this value directly.
  double constant;

  /// Adds and returns the constant value.
  double add(double constant) => this.constant += constant;

  /// Inserts a symbol with a coefficient.
  ///
  /// If the symbol already exists in the row, add the coefficient to it.
  ///
  /// If at any point the coefficient becomes near-zero, remove the symbol.
  void insertSymbol(Symbol symbol, double coefficient) {
    final current = cells[symbol];
    if (current == null) {
      if (!coefficient.isNearZero) {
        cells[symbol] = coefficient;
      }
      return;
    }

    coefficient += current;
    if (coefficient.isNearZero) {
      cells.remove(symbol);
    } else {
      cells[symbol] = coefficient;
    }
  }

  /// Inserts a row into this row with a coefficient.
  ///
  /// Returns whether the constant value changed.
  bool insertRow(Row other, double coefficient) {
    final constantDiff = other.constant * coefficient;
    constant += constantDiff;
    for (final MapEntry(:key, :value) in other.cells.entries) {
      insertSymbol(key, value * coefficient);
    }
    return constantDiff != 0.0;
  }

  /// Removes a symbol from this row.
  void removeSymbol(Symbol symbol) {
    cells.remove(symbol);
  }

  /// Reverses the sign of the constant and every coefficient in every cell.
  void reverseSign() {
    constant = -constant;
    cells.updateAll((_, value) => -value);
  }

  /// Solves the row for the given symbol.
  ///
  /// The symbol should be a basic symbol in the row.
  void solveForSymbol(Symbol symbol) {
    final coefficient = -1.0 / cells.remove(symbol)!;
    constant *= coefficient;
    cells.updateAll((_, value) => value * coefficient);
  }

  /// Solves the row for the given symbols.
  void solveForSymbols(Symbol lhs, Symbol rhs) {
    insertSymbol(lhs, -1);
    solveForSymbol(rhs);
  }

  /// Returns the coefficient for the given symbol or `0` if it does not exist.
  double coefficientFor(Symbol symbol) => cells[symbol] ?? 0;

  /// Substitutes the given symbol with the given row.
  bool substitute(Symbol symbol, Row row) {
    final coefficient = cells.remove(symbol);
    if (coefficient == null) {
      return false;
    }

    insertRow(row, coefficient);
    return true;
  }
}
