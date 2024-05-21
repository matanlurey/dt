import 'package:dt/src/core/writer.dart';

/// Typed methods for known ANSI control sequences.
///
/// There are two ways to use this interface:
/// - `implements AnsiHandler` to respond to _all_ ANSI control sequences.
/// - `extends AnsiHandler` to respond to _some_ ANSI control sequences.
abstract class AnsiHandler {
  // ignore: public_member_api_docs
  const AnsiHandler();

  /// Clears the current line that the cursor is located on.
  void clearLine() {}

  /// Clears the current line _after_ the cursor's position.
  void clearLineAfter() {}

  /// Clears the current line _before_ the cursor's position.
  void clearLineBefore() {}

  /// Clears the screen.
  void clearScreen() {}

  /// Clears the screen _after_ the cursor's position.
  void clearScreenAfter() {}

  /// Clears the screen _before_ the cursor's position.
  void clearScreenBefore() {}

  /// Writes the given text to the screen at the cursor's position.
  void write(String text) {}
}

/// Writes ANSI control sequences to and is a [Writer].
final class AnsiWriter implements AnsiHandler, Writer {
  /// Creates a new ANSI writer that writes to the given [writer].
  const AnsiWriter.from(this._writer);
  final Writer _writer;

  void _escape(String value, String suffix) {
    write('\x1B[$value$suffix');
  }

  @override
  void clearLineAfter() => _escape('0', 'K');

  @override
  void clearLineBefore() => _escape('1', 'K');

  @override
  void clearLine() => _escape('2', 'K');

  @override
  void clearScreenAfter() => _escape('0', 'J');

  @override
  void clearScreenBefore() => _escape('1', 'J');

  @override
  void clearScreen() => _escape('2', 'J');

  @override
  Future<void> close() => _writer.close();

  @override
  Future<void> flush() => _writer.flush();

  @override
  void write(String text) => _writer.write(text);
}

/// Typed methods for known and [unknown] ANSI control sequences.
///
/// There are two ways to use this interface:
/// - `implements AnsiListener` to respond to _all_ ANSI control sequences.
/// - `extends AnsiListener` to respond to _some_ ANSI control sequences.
abstract class AnsiListener extends AnsiHandler {
  /// Creates a new ANSI handler with the given methods.
  ///
  /// Each method is optional and will be a no-op if not provided.
  ///
  /// This constructor is intended for convenience and testing; prefer extending
  /// this class to implement only the methods you need over using this
  /// constructor.
  const factory AnsiListener.from({
    void Function() clearLine,
    void Function() clearLineAfter,
    void Function() clearLineBefore,
    void Function() clearScreen,
    void Function() clearScreenAfter,
    void Function() clearScreenBefore,
    void Function(String) write,
    void Function(String, int) unknown,
  }) = _AnsiListener;

  /// Creates a new ANSI handler with the given methods.
  ///
  /// Each method is optional and will throw an [UnimplementedError] by default.
  ///
  /// This constructor is intended for convenience and testing; prefer
  /// implementing this class to receive static analysis errors for unhandled
  /// methods over using this constructor.
  const factory AnsiListener.fromOrThrow({
    void Function() clearLine,
    void Function() clearLineAfter,
    void Function() clearLineBefore,
    void Function() clearScreen,
    void Function() clearScreenAfter,
    void Function() clearScreenBefore,
    void Function(String) write,
    void Function(String, int) unknown,
  }) = _AnsiListener.throwsIfMissing;

  /// An unknown ANSI control sequence was received.
  ///
  /// This method is called when an unknown ANSI control sequence is received;
  /// the [value] is the control sequence's value, and [suffix] is the final
  /// character of the control sequence.
  ///
  /// Could be used to log unknown control sequences or to throw an error.
  void unknown(String value, int suffix) {}
}

final class _AnsiListener implements AnsiListener {
  const _AnsiListener({
    void Function() clearLine = _noop0,
    void Function() clearLineAfter = _noop0,
    void Function() clearLineBefore = _noop0,
    void Function() clearScreen = _noop0,
    void Function() clearScreenAfter = _noop0,
    void Function() clearScreenBefore = _noop0,
    void Function(String) write = _noop1,
    void Function(String, int) unknown = _noop2,
  })  : _clearLine = clearLine,
        _clearLineAfter = clearLineAfter,
        _clearLineBefore = clearLineBefore,
        _clearScreen = clearScreen,
        _clearScreenAfter = clearScreenAfter,
        _clearScreenBefore = clearScreenBefore,
        _write = write,
        _unknown = unknown;

  static void _noop0() {}
  static void _noop1(void _) {}
  static void _noop2(void _, void __) {}

  const _AnsiListener.throwsIfMissing({
    void Function() clearLine = _throw0,
    void Function() clearLineAfter = _throw0,
    void Function() clearLineBefore = _throw0,
    void Function() clearScreen = _throw0,
    void Function() clearScreenAfter = _throw0,
    void Function() clearScreenBefore = _throw0,
    void Function(String) write = _throw1,
    void Function(String, int) unknown = _throw2,
  })  : _clearLine = clearLine,
        _clearLineAfter = clearLineAfter,
        _clearLineBefore = clearLineBefore,
        _clearScreen = clearScreen,
        _clearScreenAfter = clearScreenAfter,
        _clearScreenBefore = clearScreenBefore,
        _write = write,
        _unknown = unknown;

  static void _throw0() => throw UnimplementedError();
  static void _throw1(void _) => throw UnimplementedError();
  static void _throw2(void _, void __) => throw UnimplementedError();

  @override
  void clearLine() => _clearLine();
  final void Function() _clearLine;

  @override
  void clearLineAfter() => _clearLineAfter();
  final void Function() _clearLineAfter;

  @override
  void clearLineBefore() => _clearLineBefore();
  final void Function() _clearLineBefore;

  @override
  void clearScreen() => _clearScreen();
  final void Function() _clearScreen;

  @override
  void clearScreenAfter() => _clearScreenAfter();
  final void Function() _clearScreenAfter;

  @override
  void clearScreenBefore() => _clearScreenBefore();
  final void Function() _clearScreenBefore;

  @override
  void write(String text) => _write(text);
  final void Function(String) _write;

  @override
  void unknown(String value, int suffix) => _unknown(value, suffix);
  final void Function(String, int) _unknown;
}

/// Parses ANSI control sequences from a stream of text.
///
/// This class could be used to implement a terminal emulator or a debugger.
final class AnsiParser {
  /// Creates a new ANSI parser which invokes the given listener.
  const AnsiParser(this._listener);

  final AnsiListener _listener;

  /// Parses the given [text] for ANSI control sequences.
  ///
  /// This method should be called for each chunk of text received from the
  /// terminal. The text may contain ANSI control sequences, which are parsed
  /// and handled by the listener.
  void parse(String text) {
    text.splitMapJoin(
      _isAnsiEscape,
      onMatch: (match) {
        match = _ansiMatchParts.matchAsPrefix(match.group(0)!)!;
        _onParse(match.group(2)!, match.group(3)!.codeUnitAt(0));
        return '';
      },
      onNonMatch: (string) {
        if (string.isNotEmpty) {
          _listener.write(string);
        }
        return '';
      },
    );
  }

  void _onParse(String value, int suffix) {
    switch (suffix) {
      case _$J:
        switch (value) {
          case '0':
            return _listener.clearScreenBefore();
          case '1':
            return _listener.clearScreenAfter();
          case '2':
            return _listener.clearScreen();
        }
      case _$K:
        switch (value) {
          case '0':
            return _listener.clearLineBefore();
          case '1':
            return _listener.clearLineAfter();
          case '2':
            return _listener.clearLine();
        }
    }
    return _listener.unknown(value, suffix);
  }

  static const _$J = 0x4A;
  static const _$K = 0x4B;

  // Copied from https://github.com/chalk/ansi-regex/blob/main/index.js.
  static final _isAnsiEscape = RegExp(
    r'[\u001B\u009B][[\]()#;?]*(?:(?:(?:(?:;[-a-zA-Z\d\/#&.:=?%@~_]+)*|'
    r'[a-zA-Z\d]+(?:;[-a-zA-Z\d\/#&.:=?%@~_]*)*)?\u0007)|'
    r'(?:(?:\d{1,4}(?:;\d{0,4})*)?[\dA-PR-TZcf-nq-uy=><~]))',
  );
  static final _ansiMatchParts = RegExp(r'([\u001B]\[)(.*)(\w$)');
}
