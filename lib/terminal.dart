import 'dart:io' as io;

/// An _append-only_ sink that writes to a terminal or _terminal-like_ buffer.
///
/// This class is a minimal abstraction over a buffer that has terminal-like
/// capabilities (and limitations), such as a terminal emulator, pipe, file, or
/// in-memory buffer, and is useful for apps that have a traditional terminal
/// interface.
///
/// For example, the following use-cases may benefit from this class:
/// - Log output of a command-line app, but wanting a testable interface.
/// - Command-line "prompt"-like interfaces in conjunction with [TerminalInput].
/// - Terminal-like interfaces embedded in other UIs.
///
/// ## Lifecycle
///
/// Terminal sinks have varied lifecycles, as they may be backed by different
/// types of buffers. For example, a terminal emulator may be backed by a
/// network connection, while a file may be backed by a file system.
///
/// See [flush] and [close] for more information.
abstract interface class TerminalSink {
  /// Creates a terminal sink that writes to an [io.IOSink].
  ///
  /// This is useful for adapting an [io.IOSink] to a [TerminalSink].
  ///
  /// ## Example
  ///
  /// Writing to stdout:
  ///
  /// ```dart
  /// final output = TerminalSink.fromIOSink(io.stdout);
  /// output.write('Hello, World!');
  /// ```
  ///
  /// Writing to a file:
  ///
  /// ```dart
  /// final file = io.File('output.txt');
  /// final output = TerminalSink.fromIOSink(file.openWrite());
  /// output.write('Hello, World!');
  /// ```
  factory TerminalSink.fromIOSink(io.IOSink output) = _IOTerminalSink;

  /// Appends a span of [text] to the current line in the buffer.
  ///
  /// This operation is non-blocking and may be buffered. See [flush].
  void append(String text);

  /// Writes a newline to the buffer, optionally preceded by [text].
  ///
  /// The newline character may be platform-specific.
  ///
  /// This operation is non-blocking and may be buffered. See [flush].
  void write([String text = '']);

  /// Flushes the buffer, ensuring all written data is actually written.
  ///
  /// This method is idempotent and may be called multiple times.
  ///
  /// Waiting for this operation may be slow, depending on the underlying
  /// buffer. For example, a network connection may take longer to flush than an
  /// in-memory buffer, in which case the operation may even be a no-op if no
  /// buffering is used.
  ///
  /// Returns a future that completes when the buffer is flushed.
  Future<void> flush();

  /// Closes the buffer, releasing any resources.
  ///
  /// This method is idempotent and may be called multiple times.
  ///
  /// After this method is called, no further writes or flushes are allowed.
  ///
  /// Returns a future that completes when the buffer is closed.
  Future<void> close();
}

/// Additional methods for [TerminalSink] that are not implementation specific.
extension TerminalSinkExtension on TerminalSink {
  /// Appends multiple spans of [text] optionally separated by a [delimiter].
  ///
  /// This operation is non-blocking and may be buffered. See [flush].
  void appendAll(Iterable<String> text, [String delimiter = '']) {
    // The delimiter is only added between spans.
    var first = true;
    for (final span in text) {
      if (!first) {
        append(delimiter);
      }
      append(span);
      first = false;
    }
  }

  /// Writes multiple lines of [text] to the buffer.
  ///
  /// Optionally, provide a [prefix] or [suffix] to be added to each line.
  ///
  /// This operation is non-blocking and may be buffered. See [flush].
  void writeAll(
    Iterable<String> text, {
    String prefix = '',
    String suffix = '',
  }) {
    for (final line in text) {
      write('$prefix$line$suffix');
    }
  }
}

/// An in-memory readable buffer that implements [TerminalSink].
///
/// This class is useful for capturing terminal output in tests or for internal
/// buffering. It is not intended to be a complete terminal emulator, but rather
/// a simple buffer that can be used to capture terminal output.
///
/// ## Example
///
/// ```dart
/// final buffer = TerminalSinkBuffer();
/// buffer.write('Hello, World!');
///
/// print(buffer.lines); // ['Hello, World!']
/// ```
final class TerminalSinkBuffer implements TerminalSink {
  /// Creates a buffer, optionally with initial [content].
  ///
  /// May provide a custom [newLine] character, which defaults to `'\n'`.
  TerminalSinkBuffer({
    String content = '',
    String newLine = '\n',
  }) : _newLine = newLine {
    _lines.addAll(content.split(_newLine));
  }

  final _lines = <String>[];
  final String _newLine;
  var _closed = false;

  @override
  void append(String text) {
    _checkNotClosed();
    final lines = text.split(_newLine);

    // The first line is appended to the last line in the buffer.
    _lines.last += lines.first;

    // The rest of the lines are added to the buffer.
    _lines.addAll(lines.skip(1));
  }

  @override
  void write([String text = '']) {
    append('$text$_newLine');
  }

  void _checkNotClosed() {
    if (_closed) {
      throw StateError('TerminalSink is closed.');
    }
  }

  /// Has no effect in this implementation.
  @override
  Future<void> flush() async {
    _checkNotClosed();
  }

  @override
  Future<void> close() async {
    _closed = true;
  }

  /// Returns the content of the buffer as an iterable of lines.
  ///
  /// If the last line is empty, it is omitted.
  ///
  /// Can be safely accessed after the buffer is closed.
  Iterable<String> get lines {
    return _lines.last.isEmpty ? _lines.take(_lines.length - 1) : _lines;
  }

  /// Returns the content of the buffer as a single string.
  ///
  /// Can be safely accessed after the buffer is closed.
  @override
  String toString() => _lines.join(_newLine);
}

final class _IOTerminalSink implements TerminalSink {
  const _IOTerminalSink(this._output);

  final io.IOSink _output;

  @override
  void append(String text) {
    _output.write(text);
  }

  @override
  void write([String text = '']) {
    _output.writeln(text);
  }

  @override
  Future<void> flush() async {
    await _output.flush();
  }

  @override
  Future<void> close() async {
    await _output.close();
  }
}

/// ...
final class TerminalInput {}

/// ...
final class Terminal {}
