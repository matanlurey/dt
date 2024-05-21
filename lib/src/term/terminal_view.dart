import 'dart:math' as math;

import 'package:dt/src/core.dart';
import 'package:meta/meta.dart';

import 'terminal_sink.dart';

/// A position in a terminal represented by a [column] and [line].
interface class Cursor {
  /// Creates a new cursor at the given [column] and [line].
  ///
  /// If either is omitted, they default to `0`.
  Cursor({
    int column = 0,
    int line = 0,
  }) : this._(column, line);

  /// Creates a new cursor at the given [x] and [y] coordinates.
  Cursor.fromXY(
    int x,
    int y,
  ) : this._(x, y);

  Cursor._(
    int column,
    int line,
  )   : column = math.max(0, column),
        line = math.max(0, line);

  /// The column, or x-coordinate from the left, of the cursor.
  ///
  /// Columns are zero-based and are clamped to non-negative values.
  final int column;

  /// The line, or y-coordinate from the top, of the cursor.
  ///
  /// Lines are zero-based and are clamped to non-negative values.
  final int line;

  /// Returns the cursor represented as an offset.
  Offset toOffset() => Offset(column, line);

  @override
  String toString() => 'Cursor <$line:$column>';
}

/// A view of a terminal: a sequence of lines [T] and a [cursor] position.
///
/// This type is used to provide a read-only view of a sequence of lines, which
/// could be used to represent the output of a non-interactive terminal, a file,
/// or any other source of lines.
///
/// It is recommended to _extend_ or _mixin_ this class if able.
///
/// See [TerminalSink] for definitions of _line_ and _span_.
abstract mixin class TerminalView<T> {
  // ignore: public_member_api_docs
  const TerminalView();

  /// Returns a read-only view of an existing terminal.
  ///
  /// All methods and properties are delegated to the provided terminal.
  const factory TerminalView.of(TerminalView<T> _) = _DelegatingTerminalView;

  /// The cursor position in the terminal.
  Cursor get cursor;

  /// Number of lines in the terminal.
  ///
  /// Implementations are expected to provide a constant-time implementation.
  int get lineCount;

  /// Whether the terminal is empty.
  ///
  /// A terminal is considered empty if it has no lines, that is `length == 0`.
  @nonVirtual
  bool get isEmpty => lineCount == 0;

  /// Whether the terminal is not empty.
  @nonVirtual
  bool get isNotEmpty => !isEmpty;

  /// Returns the line at [index] in the range of `0 <= index < length`.
  ///
  /// Reading beyond the bounds of the terminal throws an error.
  T line(int index);

  /// Lines in the terminal in an idiomatic order.
  ///
  /// A typical terminal is vertically ordered from top to bottom.
  Iterable<T> get lines => Iterable.generate(lineCount, line);
}

final class _DelegatingTerminalView<T> implements TerminalView<T> {
  const _DelegatingTerminalView(this._delegate);
  final TerminalView<T> _delegate;

  @override
  Cursor get cursor => _delegate.cursor;

  @override
  bool get isEmpty => _delegate.isEmpty;

  @override
  bool get isNotEmpty => _delegate.isNotEmpty;

  @override
  int get lineCount => _delegate.lineCount;

  @override
  T line(int index) => _delegate.line(index);

  @override
  Iterable<T> get lines => _delegate.lines;
}
