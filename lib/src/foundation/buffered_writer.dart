import 'dart:typed_data';

import 'writer.dart';

/// Wraps a writer and buffers its output.
///
/// It can be excessively inefficient to work directly with something that
/// implements [Writer]. For example, every call to [write] on a network socket
/// results in a sytem call. A [BufferedWriter] keeps an in-memory buffer of
/// data and writes to to an underlying writer in larger batches.
///
/// [BufferedWriter] can improve the speed of programs that make _small_ and
/// _repeated_ write calls to the same file or network socket, but will have
/// no effect on programs that write large chunks of data at once or just
/// writing a few times, or to writing to an in-memory buffer.
final class BufferedWriter implements Writer {
  /// Creates a new buffered writer with the provided [capacity].
  ///
  /// The [capacity] is the size of the buffer in bytes. If the buffer is full,
  /// it will be flushed to the underlying writer. The default capacity is 8kb
  /// (8192 bytes) but may be adjusted to suit the expected workload.
  BufferedWriter(
    this._writer, {
    int capacity = 8 * 1024,
  }) : _buffer = Uint8List(capacity);

  final Writer _writer;
  Uint8List _buffer;
  var _length = 0;

  /// Flushes the buffer, ensuring all written data is actually written.
  ///
  /// This method always invokes [Writer.flush] on the underlying writer.
  @override
  Future<void> flush() {
    if (_length > 0) {
      _softFlush();
    }
    return _writer.flush();
  }

  /// Writes to the underlying writer and resets the buffer.
  void _softFlush() {
    _writer.write(_buffer, 0, _length);
    _length = 0;
    _buffer = Uint8List(_buffer.length);
  }

  /// Writes the provided [bytes] to the sink, optionally with offsets.
  ///
  /// Returns the number of bytes written, which is always [length].
  ///
  /// This method is non-blocking and may be buffered.
  ///
  /// If the buffer is full, this method will flush the buffer and then write
  /// the provided bytes, otherwise it will append the bytes to the buffer
  /// until it is full and write to the underlying buffer.
  @override
  int write(List<int> bytes, [int offset = 0, int? length]) {
    length ??= bytes.length - offset;

    var remaining = length;
    while (remaining > 0) {
      // Try writing to the buffer.
      final wrote = _write(bytes, offset, remaining);
      offset += wrote;
      remaining -= wrote;

      // If the buffer is full, flush it.
      if (_length == _buffer.length) {
        _softFlush();
      }
    }

    return length;
  }

  /// Writes as many bytes as possible to the buffer.
  ///
  /// Returns the number of bytes written.
  int _write(List<int> bytes, int offset, int length) {
    // Write as much fits in the buffer.
    final remaining = _buffer.length - _length;
    final writeLength = length < remaining ? length : remaining;
    _buffer.setRange(_length, _length + writeLength, bytes, offset);

    // Update the buffer length.
    _length += writeLength;
    return writeLength;
  }
}
