import 'dart:typed_data';

/// An interface for objects that are byte-oriented sinks.
///
/// Writers are defined by two required methods: [write] and [flush]:
/// - [write] will attempt to write the provided [bytes] to the sink, returning
///   how many bytes were actually written.
/// - [flush] will ensure that all written data is actually written, useful for
///   adapters and explicit buffers that may not write data immediately.
///
/// It is possible for operations to fail, such as writing to a closed socket or
/// a full buffer. In these cases, the writer should document how it handles
/// these errors, such as throwing an exception or returning a specific value.
abstract interface class Writer {
  /// Creates a new writer that writes to the provided [sink].
  ///
  /// The [onFlush] callback is invoked when the writer is flushed, which may
  /// be useful for a sink that needs to know when data is requested to be
  /// written to the underlying sink.
  ///
  /// This API exists as an adapter for Dart's core [Sink] interface. Prefer
  /// using a [Writer] directly if possible.
  factory Writer.fromSink(
    Sink<List<int>> sink, {
    Future<void> Function()? onFlush,
  }) = _SinkWriter;

  /// Writes the provided [bytes] to the sink, optionally with offsets.
  ///
  /// Returns the number of bytes actually written.
  ///
  /// This method is non-blocking and may be buffered.
  int write(List<int> bytes, [int offset = 0, int? length]);

  /// Flushes the buffer, ensuring all written data is actually written.
  Future<void> flush();
}

final class _SinkWriter implements Writer {
  const _SinkWriter(
    this._sink, {
    Future<void> Function()? onFlush,
  }) : _onFlush = onFlush;

  final Sink<List<int>> _sink;
  final Future<void> Function()? _onFlush;

  @override
  Future<void> flush() async {
    await _onFlush?.call();
  }

  @override
  int write(List<int> bytes, [int offset = 0, int? length]) {
    // If the length is not provided, write the entire buffer.
    if (offset == 0 && length == null) {
      _sink.add(bytes);
      return bytes.length;
    }

    // Otherwise, write the specified range.
    final List<int> sublist;
    if (bytes is Uint8List) {
      sublist = Uint8List.view(
        bytes.buffer,
        offset,
        length,
      );
    } else {
      sublist = bytes.sublist(offset, length == null ? null : offset + length);
    }

    _sink.add(sublist);
    return sublist.length;
  }
}
