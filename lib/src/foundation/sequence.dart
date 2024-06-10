import 'package:meta/meta.dart';

/// A regular expression for matching CSI escape sequences.
///
/// This matches any sequence that starts with `ESC[` and ends with a letter,
/// optionally containing numbers and semicolons in between. The sequence is
/// not validated for correctness.
///
/// For example, `ESC[1;2m` is matched, but `ESC[1;2` is not.
final _csiEscape = RegExp(r'\x1B\[([0-9;]*)([A-Za-z])');

/// Represents a sequence of values; a [Literal] or [EscapeSequence].
@immutable
sealed class Sequence {
  /// Parses a sequence from the given [string].
  ///
  /// Returns either a [Literal] or [EscapeSequence] depending on the input.
  static Sequence parse(String string) {
    return EscapeSequence.tryParse(string) ?? Literal._(string);
  }

  /// Parses all sequences from the given [string].
  ///
  /// If the [string] is empty, returns an iterable with an empty [Literal].
  static Iterable<Sequence> parseAll(String string) {
    if (string.isEmpty) {
      return const [Literal._('')];
    }
    return _parseAll(string);
  }

  static Iterable<Sequence> _parseAll(String string) sync* {
    var start = 0;
    for (final match in _csiEscape.allMatches(string)) {
      if (start < match.start) {
        yield Literal._(string.substring(start, match.start));
      }
      yield EscapeSequence.tryParse(match.group(0)!)!;
      start = match.end;
    }
    if (start < string.length) {
      yield Literal._(string.substring(start));
    }
  }

  /// A sequence that represents nothing and does nothing.
  ///
  /// This is useful when you want to represent an empty sequence, for example
  /// for a style that has no effect, or for converting an unsupported sequence
  /// to a valid sequence.
  ///
  /// In practice, this should be rarely used.
  static const Sequence none = _NullSequence();

  const Sequence();

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString();

  /// Returns the terse representation of this sequence.
  ///
  /// This is the same as the sequence, but with default parameters removed.
  Sequence toTerse();

  /// Returns the string representation of this sequence.
  ///
  /// If [verbose] is `true`, parameters that are otherwise default are still
  /// included in the string, i.e. `[1;1m` instead of `[m`, for readability.
  String toEscapedString({bool verbose = false});
}

/// A string literal.
final class Literal extends Sequence {
  /// Creates a new literal.
  ///
  /// The [value] must not contain escape sequences.
  factory Literal(String value) {
    if (value.contains('\x1B')) {
      throw ArgumentError.value(
        value,
        'value',
        'must not contain escape sequences',
      );
    }
    return Literal._(value);
  }

  const Literal._(this.value);

  /// String literal.
  ///
  /// The [value] must not contain escape sequences.
  final String value;

  @override
  bool operator ==(Object other) {
    return other is Literal && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;

  @override
  Sequence toTerse() => this;

  @override
  String toEscapedString({bool verbose = false}) => value;
}

/// A null sequence.
final class _NullSequence extends Sequence {
  const _NullSequence();

  @override
  bool operator ==(Object other) => other is _NullSequence;

  @override
  int get hashCode => 0;

  @override
  String toString() => '';

  @override
  Sequence toTerse() => this;

  @override
  String toEscapedString({bool verbose = false}) => '';
}

/// A CSI escape sequence.
abstract final class EscapeSequence extends Sequence {
  /// Creates a new escape sequence.
  ///
  /// If [defaults] is provided, they are used when computing [toEscapedString]
  /// output if `verbose: false`, and are excluded from the output if they are
  /// the same as the parameters. Must be the same length as [parameters] if
  /// provided.
  factory EscapeSequence(
    String finalChars, [
    Iterable<int> parameters = const [],
    Iterable<int> defaults = const [],
  ]) {
    if (defaults.isNotEmpty && parameters.length != defaults.length) {
      throw ArgumentError.value(
        defaults,
        'defaultParameters',
        'must have the same length as parameters',
      );
    }
    return _EscapeSequence(finalChars, parameters, defaults);
  }

  /// Creates a new escape sequence without copying or validating the inputs.
  ///
  /// This constructor is unsafe and should only be used when the inputs are
  /// known to be correct and are all constant values. For example, when
  /// creating an `enum` that produces escape sequences:
  /// ```dart
  /// enum ShakeTheScreen {
  ///   once(EscapeSequence.unchecked('H', [1], [1])),
  ///   twice(EscapeSequence.unchecked('H', [2])),
  ///
  ///   const ShakeTheScreen(this.sequence);
  ///   final EscapeSequence sequence;
  /// }
  @literal
  const factory EscapeSequence.unchecked(
    String finalBytes, [
    @mustBeConst List<int> parameters,
    @mustBeConst List<int> defaults,
  ]) = _EscapeSequence.noCopy;

  const EscapeSequence._();

  /// Parses an escape sequence from the given [string].
  ///
  /// If the [string] is not a CSI escape sequence, returns `null`.
  static EscapeSequence? tryParse(String string) {
    final match = _csiEscape.firstMatch(string);
    if (match == null) {
      return null;
    }
    final params = match.group(1);
    return _EscapeSequence(
      match.group(2)!,
      params!.isEmpty ? const [] : params.split(';').map(int.parse),
    );
  }

  /// Final characters for the escape sequence.
  ///
  /// For example, `'H'` for `ESC[H`.
  String get finalChars;

  /// Parameters for the escape sequence.
  ///
  /// For example, `[1, 1]` for `ESC[1;1H`.
  ///
  /// This list should not be modified.
  List<int> get parameters;

  /// Default parameters for the escape sequence.
  @protected
  List<int> get _defaults;

  @override
  @nonVirtual
  bool operator ==(Object other) {
    if (other is! EscapeSequence || finalChars != other.finalChars) {
      return false;
    }
    if (parameters.length != other.parameters.length) {
      return false;
    }
    for (var i = 0; i < parameters.length; i++) {
      if (parameters[i] != other.parameters[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  @nonVirtual
  int get hashCode => Object.hash(finalChars, Object.hashAll(parameters));

  @override
  @nonVirtual
  String toEscapedString({bool verbose = false}) {
    var sequence = this;
    if (!verbose) {
      sequence = sequence.toTerse();
    }
    final params = sequence.parameters.join(';');
    return '\x1B[$params${sequence.finalChars}';
  }

  @override
  String toString() {
    return 'EscapeSequence <${parameters.join(';')}$finalChars>';
  }

  @override
  EscapeSequence toTerse() {
    if (_defaults.isEmpty) {
      return this;
    }

    final params = parameters.toList();
    for (var i = params.length - 1; i >= 0; i--) {
      if (params[i] == _defaults[i]) {
        params.removeAt(i);
      } else {
        break;
      }
    }

    return EscapeSequence(finalChars, params);
  }
}

final class _EscapeSequence extends EscapeSequence {
  _EscapeSequence(
    this.finalChars, [
    Iterable<int> parameters = const [],
    Iterable<int> defaultParameters = const [],
  ])  : parameters = List.unmodifiable(parameters),
        _defaults = List.of(defaultParameters),
        super._();

  const _EscapeSequence.noCopy(
    this.finalChars, [
    this.parameters = const [],
    this._defaults = const [],
  ]) : super._(); // coverage:ignore-line

  @override
  final String finalChars;

  @override
  final List<int> parameters;

  @override
  final List<int> _defaults;
}
