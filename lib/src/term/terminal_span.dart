import 'dart:collection';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'terminal.dart';
import 'terminal_sink.dart';
import 'terminal_view.dart';

/// A set of functions that allow a span of type [T] within a [Terminal].
///
/// The core types, such as [Terminal], [TerminalSink], and [TerminalView], are
/// agnostic to the type of span that they operate on, but the actual terminal
/// itself needs to perform operations on the span.
///
/// If extended or mixed-in, default implementations of [insert] and [replace]
/// are provided that use [merge] and [extract] to perform the operations; some
/// types may want to override these methods for performance reasons.
///
/// See [StringSpan] and [ListSpan] for example implementations.
@immutable
abstract mixin class TerminalSpan<T> {
  // ignore: public_member_api_docs
  const TerminalSpan();

  /// Returns an empty span of type [T] with a default [width] of `0`.
  T empty([int width = 0]);

  /// Returns the width of the [span] measured in columns.
  int width(T span);

  /// Returns a span that is the result of merging [first] and [second].
  T merge(T first, T second);

  /// Returns a span that is the result of extracting a range from [source].
  ///
  /// The [start] index is inclusive, and the [end] index is exclusive. If the
  /// [end] index is `null`, the range is assumed to extend to the end of the
  /// [source].
  T extract(T source, {int start = 0, int? end});

  /// Returns a span that is the result of inserting [insertion] into [source].
  T insert(T source, T insertion, int index) {
    return merge(
      merge(
        extract(source, end: index),
        insertion,
      ),
      extract(
        source,
        start: index,
      ),
    );
  }

  /// Returns a span that is the result of replacing a range in [source].
  ///
  /// The [start] index is inclusive, and the [end] index is exclusive. If the
  /// [end] index is `null`, the range is assumed to extend to the end of the
  /// [source].
  T replace(T source, T replacement, int start, [int? end]) {
    // Get the first part of the span that is not being replaced.
    final prefix = extract(source, end: start);

    // Get the last part of the span that is not being replaced, if any.
    final suffix = extract(source, start: end ?? width(source));

    // Merge the prefix, replacement, and suffix to create the new span.
    return merge(merge(prefix, replacement), suffix);
  }
}

/// A span implementation for a [String].
final class StringSpan extends TerminalSpan<String> {
  /// Creates a string span.
  @literal
  const StringSpan();

  @override
  String empty([int width = 0]) {
    if (width == 0) {
      return '';
    }
    return ' ' * width;
  }

  @override
  int width(String span) => span.length;

  @override
  String merge(String first, String second) => first + second;

  @override
  String extract(String source, {int start = 0, int? end}) {
    return source.substring(start, end);
  }

  @override
  String replace(String source, String replacement, int start, [int? end]) {
    return source.replaceRange(
      start,
      end,
      replacement,
    );
  }
}

/// A span implementation for a [List].
///
/// While not particularly practical, a list is a reasonable example of a span
/// that can be used to store a sequence of elements. This implementation is
/// agnostic to the type of list, but it can be more efficient with growable
/// lists; see [ListSpan.new] and [ListSpan.mutable] for more information.
abstract final class ListSpan<T> extends TerminalSpan<List<T>> {
  /// Creates a list span that creates a new list for each operation.
  ///
  /// This is the default implementation of a [ListSpan], which is safe to use
  /// for all list subtypes, including those that are non-growable (such as
  /// [Uint8List]), are shared between multiple instances, or are unmodifiable
  /// (such as [UnmodifiableListView]).
  const factory ListSpan({
    required T Function() defaultElement,
  }) = _ImmutableListSpan<T>;

  /// Creates a list span that mutates an existing list for each operation.
  ///
  /// This implementation is more efficient for growable lists, such as
  /// [List], [ListQueue], and [SplayTreeList], but should not be used with
  /// non-growable lists, shared lists, or unmodifiable lists.
  const factory ListSpan.mutable({
    required T Function() defaultElement,
  }) = _MutableListSpan<T>;

  const ListSpan._(this._defaultElement);
  final T Function() _defaultElement;

  @override
  List<T> empty([int width = 0]) {
    return List<T>.generate(width, (_) => _defaultElement());
  }

  @override
  @nonVirtual
  int width(List<T> span) => span.length;

  @override
  @nonVirtual
  List<T> extract(List<T> source, {int start = 0, int? end}) {
    return source.sublist(start, end);
  }
}

final class _ImmutableListSpan<T> extends ListSpan<T> {
  const _ImmutableListSpan({
    required T Function() defaultElement,
  }) : super._(defaultElement);

  @override
  List<T> empty([int width = 0]) {
    return width == 0 ? const [] : super.empty(width);
  }

  @override
  List<T> merge(List<T> first, List<T> second) => first + second;

  @override
  List<T> insert(List<T> source, List<T> insertion, int index) {
    return [
      ...source.sublist(0, index),
      ...insertion,
      ...source.sublist(index),
    ];
  }

  @override
  List<T> replace(List<T> source, List<T> replacement, int start, [int? end]) {
    return [
      ...source.sublist(0, start),
      ...replacement,
      ...source.sublist(end ?? source.length),
    ];
  }
}

final class _MutableListSpan<T> extends ListSpan<T> {
  const _MutableListSpan({
    required T Function() defaultElement,
  }) : super._(defaultElement);

  @override
  List<T> merge(List<T> first, List<T> second) {
    first.addAll(second);
    return first;
  }

  @override
  List<T> insert(List<T> source, List<T> insertion, int index) {
    source.insertAll(index, insertion);
    return source;
  }

  @override
  List<T> replace(List<T> source, List<T> replacement, int start, [int? end]) {
    source.replaceRange(start, end ?? source.length, replacement);
    return source;
  }
}
