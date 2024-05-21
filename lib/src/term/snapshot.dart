import 'package:dt/src/term/cursor.dart';
import 'package:dt/src/term/view.dart';
import 'package:meta/meta.dart';

/// An _immutable_ snapshot of a terminal's state at a specific point in time.
///
/// Unlike [TerminalView], a type signature of [TerminalSnapshot] guarantees
/// that all members are fixed and will not change over time, making it ideal
/// to store and pass around.
///
/// ## Equality
///
/// Two snapshots are considered equal if their [cursor] and [lines] are equal.
@immutable
final class TerminalSnapshot<T> extends TerminalView<T> {
  /// Creates a snapshot of a terminal's state.
  factory TerminalSnapshot.from(TerminalView<T> view) {
    return TerminalSnapshot._(
      cursor: view.cursor,
      lines: List.unmodifiable(view.lines),
      lastPosition: view.lastPosition,
    );
  }

  const TerminalSnapshot._({
    required this.cursor,
    required this.lines,
    required this.lastPosition,
  });

  @override
  final Cursor cursor;

  @override
  final Cursor lastPosition;

  /// Lines in the terminal from top to bottom.
  ///
  /// This list is unmodifiable.
  @override
  final List<T> lines;

  @override
  int get lineCount => lines.length;

  @override
  T line(int index) => lines[index];

  @override
  bool operator ==(Object other) {
    if (other is! TerminalSnapshot<T>) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    if (cursor.x != other.cursor.x || cursor.y != other.cursor.y) {
      return false;
    }
    for (var i = 0; i < lineCount; i++) {
      if (line(i) != other.line(i)) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(cursor.x, cursor.y, Object.hashAll(lines));

  @override
  String toString() {
    return ''
        'TerminalSnapshot '
        '<cursor: (${cursor.x}, ${cursor.y}), lines: $lineCount>';
  }
}
