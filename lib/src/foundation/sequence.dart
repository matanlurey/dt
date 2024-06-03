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

  const Sequence();

  @override
  bool operator ==(Object other);

  @override
  int get hashCode;

  @override
  String toString();

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
  String toEscapedString({bool verbose = false}) => value;
}

/// A CSI escape sequence.
abstract final class EscapeSequence extends Sequence {
  /// Creates a new escape sequence.
  ///
  /// The [finalByte] must be a single byte character.
  ///
  /// If [defaults] is provided, they are used when computing [toEscapedString]
  /// output if `verbose: false`, and are excluded from the output if they are
  /// the same as the parameters. Must be the same length as [parameters] if
  /// provided.
  factory EscapeSequence(
    String finalByte, [
    Iterable<int> parameters = const [],
    Iterable<int> defaults = const [],
  ]) {
    if (finalByte.length != 1) {
      throw ArgumentError.value(
        finalByte,
        'finalByte',
        'must be a single character',
      );
    }
    if (defaults.isNotEmpty && parameters.length != defaults.length) {
      throw ArgumentError.value(
        defaults,
        'defaultParameters',
        'must have the same length as parameters',
      );
    }
    return _EscapeSequence(finalByte, parameters, defaults);
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
    String finalByte, [
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

  /// A single byte character for the escape sequence.
  ///
  /// For example, `'H'` for `ESC[H`.
  String get finalByte;

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
    if (other is! EscapeSequence || finalByte != other.finalByte) {
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
  int get hashCode => Object.hash(finalByte, Object.hashAll(parameters));

  @override
  @nonVirtual
  String toEscapedString({bool verbose = false}) {
    // No parameters.
    if (parameters.isEmpty) {
      return '\x1B[$finalByte';
    }

    // If the parameter is the same as the default parameter, it is excluded.
    // Once a non-default parameter is found, remaining parameters are included.
    final buffer = StringBuffer('\x1B[');
    for (var i = parameters.length - 1; i >= 0; i--) {
      final parameter = parameters[i];
      final defaultTo = _defaults.length > i ? _defaults[i] : null;
      if (parameter != defaultTo) {
        buffer.writeAll(parameters.sublist(0, i + 1), ';');
        break;
      }
    }
    return (buffer..write(finalByte)).toString();
  }

  @override
  String toString() {
    return 'EscapeSequence <${parameters.join(';')}$finalByte>';
  }
}

final class _EscapeSequence extends EscapeSequence {
  _EscapeSequence(
    this.finalByte, [
    Iterable<int> parameters = const [],
    Iterable<int> defaultParameters = const [],
  ])  : parameters = List.unmodifiable(parameters),
        _defaults = List.of(defaultParameters),
        super._();

  const _EscapeSequence.noCopy(
    this.finalByte, [
    this.parameters = const [],
    this._defaults = const [],
  ]) : super._(); // coverage:ignore-line

  @override
  final String finalByte;

  @override
  final List<int> parameters;

  @override
  final List<int> _defaults;
}
