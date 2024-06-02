import 'dart:convert';

import 'writer.dart';

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
