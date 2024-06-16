import 'dart:convert';
import 'dart:typed_data';

/// An interface for objects that are byte-oriented sinks.
///
/// Writers are defined by two required methods: [write] and [flush]:
/// - [write] will attempt to write the provided `bytes` to the sink, returning
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

/// Wraps a writer and provides an API for writing strings instead of bytes.
///
/// This class is useful for writing text to a byte-oriented sink, such as a
/// network socket or file. It encodes strings to bytes using the provided
/// encoding, defaulting to UTF-8.
final class StringWriter {
  /// Creates a new string writer with the provided [encoding].
  ///
  /// The [encoding] is used to convert strings to bytes before writing them to
  /// the underlying writer. The default encoding is UTF-8, but may be changed
  /// to any other supported encoding.
  StringWriter(
    this._writer, {
    Encoding encoding = utf8,
    String newLine = '\n',
  })  : _encoding = encoding,
        _newLine = newLine;

  final Writer _writer;
  final Encoding _encoding;
  final String _newLine;

  /// Flushes the buffer, ensuring all written data is actually written.
  Future<void> flush() => _writer.flush();

  /// Writes the provided [string] to the sink.
  ///
  /// This method is non-blocking and may be buffered.
  void write(String string) {
    _writer.write(_encoding.encode(string));
  }

  /// Writes the provided [string] to the sink, followed by a newline.
  ///
  /// This method is non-blocking and may be buffered.
  void writeLine([String string = '']) {
    _writer.write(_encoding.encode('$string$_newLine'));
  }

  /// Writes the provided [strings] to the sink.
  ///
  /// Optionally, a [separator] may be provided to join the strings.
  ///
  /// This method is non-blocking and may be buffered.
  void writeAll(Iterable<String> strings, [String separator = '']) {
    write(strings.join(separator));
  }

  /// Writes the provided [strings] to the sink, each followed by a newline.
  ///
  /// This method is non-blocking and may be buffered.
  void writeLines(Iterable<String> strings) {
    for (final string in strings) {
      writeLine(string);
    }
  }
}

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
