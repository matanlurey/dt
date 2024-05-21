import 'package:dt/src/core.dart';
import 'package:meta/meta.dart';

import 'cursor.dart';

/// A read-only view of a terminal of lines [T].
///
/// The view itself does not allow modification of the underlying terminal, but
/// the state might be changed by other parts of the system, causing the values
/// exposed by this view to change over time.
///
/// This class is very flexible, and can be used and reused a number of ways:
/// - `implements TerminalView` to completely define a custom terminal view.
/// - `extends TerminalView` or `with TerminalView` to use some default members.
/// - [TerminalView.from] to create a read-only view of an _existing_ terminal.
abstract mixin class TerminalView<T> {
  // ignore: public_member_api_docs
  const TerminalView();

  /// Returns a read-only view of an existing terminal.
  const factory TerminalView.from(TerminalView<T> _) = _DelegatingTerminalView;

  /// Number of lines in the terminal, irrespective of viewport.
  ///
  /// Prefer using over [lines.length]; this property is `O(1)` if possible.
  int get lineCount;

  /// Whether the terminal is empty.
  ///
  /// A terminal is considered empty if it has no lines.
  bool get isEmpty => lineCount == 0;

  /// Whether the terminal is not empty.
  bool get isNotEmpty => !isEmpty;

  /// Current cursor's position.
  Cursor get cursor;

  /// The first possible cursor position in the terminal.
  @nonVirtual
  Cursor get firstPosition => Offset.zero;

  /// The last possible cursor position in the terminal.
  Cursor get lastPosition;

  /// Returns the line at [index] in the range of `0 <= index < length`.
  ///
  /// Reading beyond the bounds of the terminal throws an error.
  T line(int index);

  /// The [line] at the [cursor.y] position.
  ///
  /// Reading an empty terminal throws an error; see [lineAt] to receive `null`.
  T get currentLine => line(cursor.y);

  /// Lines in the terminal from top to bottom.
  ///
  /// This iterable is lazily evaluated.
  Iterable<T> get lines => Iterable.generate(lineCount, line);

  /// Returns the line at the [curosr.y] position + [offset].
  ///
  /// If the offset is negative, the line is resolved above the cursor.
  ///
  /// Returns `null` if the line is out of bounds.
  T? lineAt([int offset = 0]) {
    final index = cursor.y + offset;
    return index >= 0 && index < lineCount ? line(index) : null;
  }

  /// Returns a concise string representation of the terminal.
  ///
  /// It is customary to include the cursor's position and number of lines:
  /// ```dart
  /// print(view); // TerminalView <cursor: (0, 0), lines: 1>
  /// ```
  @override
  String toString() {
    return 'TerminalView <cursor: (${cursor.x}m ${cursor.y}), lines: $lineCount>';
  }
}

/// Extension methods for [TerminalView].
extension TerminalViewExtensions<T> on TerminalView<T> {
  /// Returns the line at the given [index].
  ///
  /// This is a shorthand for `line(index)`.
  T operator [](int index) => line(index);
}

final class _DelegatingTerminalView<T> implements TerminalView<T> {
  const _DelegatingTerminalView(this._delegate);

  // Technically, this is a reference to the terminal being viewed, but since
  // every terminal is a terminal view, and we want to limit ourselves to just
  // the read-only view, we use the `TerminalView` type here.
  final TerminalView<T> _delegate;

  @override
  T get currentLine => _delegate.currentLine;

  @override
  Cursor get cursor => _delegate.cursor;

  @override
  Cursor get firstPosition => _delegate.firstPosition;

  @override
  Cursor get lastPosition => _delegate.lastPosition;

  @override
  bool get isEmpty => _delegate.isEmpty;

  @override
  bool get isNotEmpty => _delegate.isNotEmpty;

  @override
  int get lineCount => _delegate.lineCount;

  @override
  T line(int index) => _delegate.line(index);

  @override
  T? lineAt([int offset = 0]) => _delegate.lineAt(offset);

  @override
  Iterable<T> get lines => _delegate.lines;

  @override
  String toString() {
    return ''
        'TerminalView '
        '<cursor: (${cursor.x}, ${cursor.y}), lines: $lineCount>';
  }
}
