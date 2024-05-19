/// A minimal interface that supports writing text-based output.
///
/// All terminals by nature _must_ support writing text-based output. This
/// interface is designed to be as minimal as possible to allow for the most
/// flexibility in implementation.
abstract interface class Buffer {
  /// Creates a new buffer that writes to the given string [sink].
  ///
  /// Useful for testing or capturing output.
  factory Buffer.fromStringSink(StringSink sink) = _StringSinkBuffer;

  /// Writes the given text to the buffer.
  ///
  /// The text must be written as-is without any additional formatting.
  ///
  /// This operation is non-blocking and may return before the text is actually
  /// written to the buffer; however, the text must be written in the order
  /// it was received. See [flush] for more information.
  void write(String text);

  /// Flushes the buffer, ensuring all written text is actually written.
  ///
  /// Returns a future that completes when the buffer has been flushed, or an
  /// error if the buffer could not be flushed (e.g. if the buffer is closed,
  /// end of a stream, etc).
  ///
  /// Subtypes that implement this interface should override this method to
  /// indicate what exceptions may be thrown if they are intended to be caught
  /// by the caller.
  Future<void> flush();

  /// Closes the buffer, releasing any resources it may have acquired.
  ///
  /// Returns a future that completes when the buffer has been closed, or an
  /// error if the buffer could not be closed (e.g. if the buffer is already
  /// closed).
  ///
  /// After closing, the buffer may not be used again.
  ///
  /// Pending writes _may_ not be flushed before the buffer is closed;
  /// callers should call [flush] before closing if they need to ensure all
  /// text is written:
  /// ```dart
  /// await buffer.flush();
  /// await buffer.close();
  /// ```
  Future<void> close();
}

final class _StringSinkBuffer implements Buffer {
  _StringSinkBuffer(this._sink);

  final StringSink _sink;
  final _buffer = StringBuffer();
  var _closed = false;

  @override
  void write(String text) {
    if (_closed) {
      throw StateError('Buffer is closed');
    }
    _buffer.write(text);
  }

  @override
  Future<void> flush() async {
    if (_closed) {
      throw StateError('Buffer is closed');
    }
    _sink.write(_buffer);
    _buffer.clear();
  }

  @override
  Future<void> close() async {
    if (_closed) {
      throw StateError('Buffer is already closed');
    }
    _closed = true;
  }
}
