import 'package:dt/src/core.dart';
import 'package:meta/meta.dart';

import 'terminal_sink.dart';
import 'terminal_view.dart';

/// A buffered terminal of lines [T] and a [cursor] position.
///
/// This type provides a way to construct and manipulate the contents of a
/// terminal of lines, similar to the capabilities of a canonical ("cooked")
/// terminal.
///
/// See [TerminalSink] for definitions of _line_ and _span_.
abstract class Terminal<T> with TerminalView<T>, TerminalSink<T> {
  /// Creates a new line feed, optionally by copying [lines] if provided.
  Terminal.from({
    Iterable<T> lines = const [],
    Offset? cursor,
  }) : _lines = List.of(lines) {
    if (cursor == null || cursor < lastPosition) {
      cursor = lastPosition;
    }
    _cursor = Cursor.fromXY(cursor.x, cursor.y);
  }

  /// Creates a new line feed with the provided [defaultSpan] and [mergeSpan].
  ///
  /// This constructor provides a simple way to create a terminal with custom
  /// span handling without needing to extend the class. The [defaultSpan] is
  /// used to create a new span when a line is written, and [mergeSpan] is used
  /// to combine spans when writing to the same line.
  ///
  /// A [cursor] may be provided, which defaults to the last line and column,
  /// and is clamped to the bounds of the terminal.
  ///
  /// ## Example
  ///
  /// A sample implementation of a [Terminal] that uses a string for spans:
  ///
  /// ```dart
  /// final terminal = Terminal.using<String>(
  ///   defaultSpan: () => '',
  ///   mergeSpan: (a, b) => '$a$b',
  /// );
  /// ```
  ///
  /// See also [StringTerminal].
  factory Terminal.using({
    required T Function() defaultSpan,
    required T Function(T, T) mergeSpan,
    required int Function(T) widthSpan,
    Offset? cursor,
    Iterable<T> lines,
  }) = _Terminal;

  /// The last possible position in the terminal.
  Offset get lastPosition;

  @override
  Cursor get cursor => _cursor;
  late Cursor _cursor;

  @override
  @nonVirtual
  int get lineCount => _lines.length;
  final List<T> _lines;

  @override
  @nonVirtual
  T line(int index) => _lines[index];
}

final class _Terminal<T> extends Terminal<T> {
  _Terminal({
    required T Function() defaultSpan,
    required T Function(T, T) mergeSpan,
    required int Function(T) widthSpan,
    super.lines,
    super.cursor,
  })  : _defaultSpan = defaultSpan,
        _mergeSpan = mergeSpan,
        _widthSpan = widthSpan,
        super.from();

  final T Function() _defaultSpan;
  final T Function(T, T) _mergeSpan;
  final int Function(T) _widthSpan;

  @override
  Offset get lastPosition {
    return Offset(
      _lines.isEmpty ? 0 : _widthSpan(_lines.last),
      _lines.length,
    );
  }

  @override
  void write(T span) {
    if (_lines.isEmpty) {
      _lines.add(span);
    } else {
      _lines.last = _mergeSpan(_lines.last, span);
    }
  }

  @override
  void writeLine([T? span]) {
    if (span != null) {
      write(span);
    }
    _lines.add(_defaultSpan());
  }
}

/// A [String]-based line feed.
///
/// This type serves as a sample implementation of a [Terminal] that maintains
/// a list of strings. It is used to demonstrate the capabilities of the type,
/// as well as to provide the basis for an append-only terminal buffer without
/// input capabilities.
///
/// **NOTE**: `\n` characters are _not_ split into separate lines, and the
/// concept of a _span_ and _line_ is based on the definitions in
/// [TerminalSink] namely that a span contents are not parsed for new lines. It
/// is recommended to pre-process spans that contain new lines and call
/// [writeLine] for each.
final class StringTerminal extends Terminal<String> {
  /// Creates a new string-based line feed by copying provided [lines] if any.
  StringTerminal.from({
    super.lines = const [],
    super.cursor,
  }) : super.from();

  @override
  Offset get lastPosition {
    return Offset(
      _lines.isEmpty ? 0 : _lines.last.length,
      _lines.length,
    );
  }

  @override
  void write(String span) {
    if (_lines.isEmpty) {
      _lines.add(span);
    } else {
      _lines.last += span;
    }
  }

  @override
  void writeLine([String? span]) {
    if (span != null) {
      write(span);
    }
    _lines.add('');
  }
}
