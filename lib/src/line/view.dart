import 'package:meta/meta.dart';

import 'sink.dart';

/// A view of a sequence of lines [T].
///
/// This type is used to provide a read-only view of a sequence of lines, which
/// could be used to represent the output of a non-interactive terminal, a file,
/// or any other source of lines.
///
/// It is recommended to _extend_ or _mixin_ this class if able.
///
/// See [LineSink] for definitions of _line_ and _span_.
abstract mixin class LineFeedView<T> {
  // ignore: public_member_api_docs
  const LineFeedView();

  /// Returns a read-only view of an existing feed.
  ///
  /// All methods and properties are delegated to the provided feed.
  const factory LineFeedView.of(LineFeedView<T> _) = _DelegatingLineFeedView;

  /// Number of lines in the feed.
  ///
  /// Implementations are expected to provide a constant-time implementation.
  int get length;

  /// Whether the feed is empty.
  ///
  /// A feed is considered empty if it has no lines, that is `length == 0`.
  @nonVirtual
  bool get isEmpty => length == 0;

  /// Whether the feed is not empty.
  @nonVirtual
  bool get isNotEmpty => !isEmpty;

  /// Returns the line at [index] in the range of `0 <= index < length`.
  ///
  /// Reading beyond the bounds of the feed throws an error.
  T line(int index);

  /// Lines in the feed in an idiomatic order.
  ///
  /// A typical feed is vertically ordered from top to bottom.
  Iterable<T> get lines => Iterable.generate(length, line);
}

final class _DelegatingLineFeedView<T> implements LineFeedView<T> {
  const _DelegatingLineFeedView(this._delegate);
  final LineFeedView<T> _delegate;

  @override
  bool get isEmpty => _delegate.isEmpty;

  @override
  bool get isNotEmpty => _delegate.isNotEmpty;

  @override
  int get length => _delegate.length;

  @override
  T line(int index) => _delegate.line(index);

  @override
  Iterable<T> get lines => _delegate.lines;
}
