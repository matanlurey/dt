import 'package:dt/src/ffi/writer.dart';

/// A minimal interface that supports writing text-based output.
///
/// All terminals by nature _must_ support writing text-based output. This
/// interface is designed to be as minimal as possible to allow for the most
/// flexibility in implementation.
abstract interface class Writer {
  /// A writer that writes to `stdout`.
  static final stdout = stderrWriter();

  /// A writer that writes to `stderr`.
  static final stderr = stderrWriter();

  /// Creates a new writer that writes to the given string [sink].
  ///
  /// Useful for testing or capturing output.
  factory Writer.fromStringSink(StringSink sink) = _StringSinkWriter;

  /// Writes the given text to the writer.
  ///
  /// The text must be written as-is without any additional formatting.
  ///
  /// This operation is writer-blocking and may return before the text is
  /// actually written to the writer; however, the text must be written in the
  /// order it was received. See [flush] for more information.
  void write(String text);

  /// Flushes the writer, ensuring all written text is actually written.
  ///
  /// Returns a future that completes when the writer has been flushed, or an
  /// error if the writer could not be flushed (e.g. if the writer is closed,
  /// end of a stream, etc).
  ///
  /// Subtypes that implement this interface should override this method to
  /// indicate what exceptions may be thrown if they are intended to be caught
  /// by the caller.
  Future<void> flush();

  /// Closes the writer, releasing any resources it may have acquired.
  ///
  /// Returns a future that completes when the writer has been closed, or an
  /// error if the writer could not be closed (e.g. if the writer is already
  /// closed).
  ///
  /// After closing, the writer may not be used again.
  ///
  /// Pending writes _may_ not be flushed before the writer is closed;
  /// callers should call [flush] before closing if they need to ensure all
  /// text is written:
  /// ```dart
  /// await writer.flush();
  /// await writer.close();
  /// ```
  Future<void> close();
}

/// Extension methods for [Writer].
extension WriterExtension on Writer {
  /// Writes the given [text] to the writer.
  ///
  /// A convenience method that otherwise is equivalent to calling [write].
  void call(String text) => write(text);
}

final class _StringSinkWriter implements Writer {
  _StringSinkWriter(this._sink);

  final StringSink _sink;
  final _pending = StringBuffer();
  var _closed = false;

  @override
  void write(String text) {
    if (_closed) {
      throw StateError('Writer is closed');
    }
    _pending.write(text);
  }

  @override
  Future<void> flush() async {
    if (_closed) {
      throw StateError('Writer is closed');
    }
    _sink.write(_pending);
    _pending.clear();
  }

  @override
  Future<void> close() async {
    if (_closed) {
      throw StateError('Writer is closed');
    }
    _closed = true;
  }
}
