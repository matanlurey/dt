import 'package:characters/characters.dart';
import 'package:meta/meta.dart';

import 'style.dart';

/// A buffer cell which can be styled and contain a single character.
@immutable
final class Cell {
  /// A cell with an `' '` symbol and an inherited style.
  static const empty = Cell._();

  /// Creates a new cell with the given [symbol] and optional [style].
  ///
  /// The [symbol] must be exactly 1 character long.
  ///
  /// If no [style] is provided, the cell will inherit the style of its parent.
  factory Cell([String symbol = ' ', Style style = Style.reset]) {
    if (symbol.length != 1 && symbol.characters.length != 1) {
      throw ArgumentError.value(
        symbol,
        'symbol',
        'must be exactly 1 character',
      );
    }
    return Cell._(symbol, style);
  }

  const Cell._([
    this.symbol = ' ',
    this.style = Style.reset,
  ]);

  /// A 1-width string representing the cell's content.
  final String symbol;

  /// Style of the cell.
  final Style style;

  /// Returns a copy of this cell with the given [symbol] and [style].
  ///
  /// If no arguments are provided, the current cell is returned.
  Cell copyWith({String? symbol, Style? style}) {
    return Cell(
      symbol ?? this.symbol,
      style ?? this.style,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Cell && other.symbol == symbol && other.style == style;
  }

  @override
  int get hashCode => Object.hash(symbol, style);

  @override
  String toString() {
    if (this == empty) {
      return 'Cell.empty';
    }
    if (style == Style.reset) {
      return 'Cell("$symbol")';
    }
    return 'Cell("$symbol", $style)';
  }
}
