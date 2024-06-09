import 'package:meta/meta.dart';

/// Possible kinds of symbols in the solver.
enum SymbolKind {
  /// An invalid symbol.
  invalid,

  /// An external symbol.
  external,

  /// A slack symbol.
  slack,

  /// An error symbol.
  error,

  /// A dummy symbol.
  dummy;
}

/// A symbol in the solver.
@immutable
final class Symbol {
  /// Creates a new symbol with a unique [id] and [kind].
  const Symbol(this.id, this.kind);

  /// Creates an invalid symbol.
  @literal
  const Symbol.invalid() : this(0, SymbolKind.invalid);

  /// The unique identifier for this symbol.
  final int id;

  /// The kind of this symbol.
  final SymbolKind kind;

  @override
  bool operator ==(Object other) {
    return other is Symbol && other.id == id && other.kind == kind;
  }

  @override
  int get hashCode => Object.hash(id, kind);

  @override
  String toString() => 'Symbol($id, $kind)';
}
