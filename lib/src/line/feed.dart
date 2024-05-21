import 'package:meta/meta.dart';

import 'sink.dart';
import 'view.dart';

/// A buffered feed of lines [T].
///
/// This type provides a way to construct and manipulate the contents of a feed
/// of lines, similar to the capabilities of a canonical ("cooked") terminal
/// _without_ input capabilities.
///
/// See [LineSink] for definitions of _line_ and _span_.
abstract class LineFeed<T> with LineFeedView<T>, LineSink<T> {
  /// Creates a new line feed, optionally by copying [lines] if provided.
  LineFeed.from([
    Iterable<T> lines = const [],
  ]) : _lines = List.of(lines);

  /// Creates a new line feed with the provided [defaultSpan] and [mergeSpan].
  ///
  /// This constructor provides a simple way to create a line feed with custom
  /// span handling without needing to extend the class. The [defaultSpan] is
  /// used to create a new span when a line is written, and [mergeSpan] is used
  /// to combine spans when writing to the same line.
  ///
  /// ## Example
  ///
  /// A sample implementation of a [LineFeed] that uses a string for spans:
  ///
  /// ```dart
  /// final feed = LineFeed.of<String>(
  ///   defaultSpan: () => '',
  ///   mergeSpan: (a, b) => '$a$b',
  /// );
  /// ```
  ///
  /// See also [StringLineFeed].
  factory LineFeed.using({
    required T Function() defaultSpan,
    required T Function(T, T) mergeSpan,
    Iterable<T> lines,
  }) = _LineFeed;

  @override
  @nonVirtual
  int get length => _lines.length;
  final List<T> _lines;

  @override
  @nonVirtual
  T line(int index) => _lines[index];
}

final class _LineFeed<T> extends LineFeed<T> {
  _LineFeed({
    required T Function() defaultSpan,
    required T Function(T, T) mergeSpan,
    Iterable<T> lines = const [],
  })  : _defaultSpan = defaultSpan,
        _mergeSpan = mergeSpan,
        super.from(lines);

  final T Function() _defaultSpan;
  final T Function(T, T) _mergeSpan;

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
/// This type serves as a sample implementation of a [LineFeed] that maintains
/// a list of strings. It is used to demonstrate the capabilities of the type,
/// as well as to provide the basis for an append-only terminal buffer without
/// input capabilities.
///
/// **NOTE**: `\n` characters are _not_ split into separate lines, and the
/// concept of a _span_ and _line_ is based on the definitions in [LineSink],
/// namely that a span contents are not parsed for new lines. It is recommended
/// to pre-process spans that contain new lines and call [writeLine] for each.
final class StringLineFeed extends LineFeed<String> {
  /// Creates a new string-based line feed by copying provided [lines] if any.
  StringLineFeed.from([
    super.lines = const [],
  ]) : super.from();

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
