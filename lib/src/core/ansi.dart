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

  /// Move the cursor to home positionn `(0, 0)`.
  void moveCursorHome() {}

  /// Move the cursor the given [line] and [column] position.
  void moveCursorTo(int line, int column) {}

  /// Move the cursor up [count] lines.
  void moveCursorUp(int count) {}

  /// Move the cursor down [count] lines.
  void moveCursorDown(int count) {}

  /// Move the cursor right [count] columns.
  void moveCursorRight(int count) {}

  /// Move the cursor left [count] columns.
  void moveCursorLeft(int count) {}

  /// Move the cursor to the beginning of [count] lines down.
  void moveCursorDownAndReturn(int count) {}

  /// Move the cursor to the beginning of [count] lines up.
  void moveCursorUpAndReturn(int count) {}

  /// Move the cursor to the given [column] position.
  void moveCursorToColumn(int column) {}

  /// Writes the given text to the screen at the cursor's position.
  void write(String text) {}
}

/// Writes ANSI control sequences.
final class AnsiWriter implements AnsiHandler {
  /// Creates a new ANSI writer that writes to the given function.
  const AnsiWriter.to(this._write);
  final void Function(String) _write;

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
  void moveCursorHome() => _escape('H', '');

  @override
  void moveCursorTo(int line, int column) => _escape('$line;${column}H', '');

  @override
  void moveCursorUp(int count) => _escape('$count', 'A');

  @override
  void moveCursorDown(int count) => _escape('$count', 'B');

  @override
  void moveCursorRight(int count) => _escape('$count', 'C');

  @override
  void moveCursorLeft(int count) => _escape('$count', 'D');

  @override
  void moveCursorDownAndReturn(int count) => _escape('$count', 'E');

  @override
  void moveCursorUpAndReturn(int count) => _escape('$count', 'F');

  @override
  void moveCursorToColumn(int column) => _escape('$column', 'G');

  @override
  void write(String text) => _write(text);
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
    void Function() moveCursorHome,
    void Function(int, int) moveCursorTo,
    void Function(int) moveCursorUp,
    void Function(int) moveCursorDown,
    void Function(int) moveCursorRight,
    void Function(int) moveCursorLeft,
    void Function(int) moveCursorDownAndReturn,
    void Function(int) moveCursorUpAndReturn,
    void Function(int) moveCursorToColumn,
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
    void Function() moveCursorHome,
    void Function(int, int) moveCursorTo,
    void Function(int) moveCursorUp,
    void Function(int) moveCursorDown,
    void Function(int) moveCursorRight,
    void Function(int) moveCursorLeft,
    void Function(int) moveCursorDownAndReturn,
    void Function(int) moveCursorUpAndReturn,
    void Function(int) moveCursorToColumn,
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
    void Function() moveCursorHome = _noop0,
    void Function(int, int) moveCursorTo = _noop2,
    void Function(int) moveCursorUp = _noop1,
    void Function(int) moveCursorDown = _noop1,
    void Function(int) moveCursorRight = _noop1,
    void Function(int) moveCursorLeft = _noop1,
    void Function(int) moveCursorDownAndReturn = _noop1,
    void Function(int) moveCursorUpAndReturn = _noop1,
    void Function(int) moveCursorToColumn = _noop1,
    void Function(String) write = _noop1,
    void Function(String, int) unknown = _noop2,
  })  : _clearLine = clearLine,
        _clearLineAfter = clearLineAfter,
        _clearLineBefore = clearLineBefore,
        _clearScreen = clearScreen,
        _clearScreenAfter = clearScreenAfter,
        _clearScreenBefore = clearScreenBefore,
        _moveCursorHome = moveCursorHome,
        _moveCursorTo = moveCursorTo,
        _moveCursorUp = moveCursorUp,
        _moveCursorDown = moveCursorDown,
        _moveCursorRight = moveCursorRight,
        _moveCursorLeft = moveCursorLeft,
        _moveCursorDownAndReturn = moveCursorDownAndReturn,
        _moveCursorUpAndReturn = moveCursorUpAndReturn,
        _moveCursorToColumn = moveCursorToColumn,
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
    void Function() moveCursorHome = _throw0,
    void Function(int, int) moveCursorTo = _throw2,
    void Function(int) moveCursorUp = _throw1,
    void Function(int) moveCursorDown = _throw1,
    void Function(int) moveCursorRight = _throw1,
    void Function(int) moveCursorLeft = _throw1,
    void Function(int) moveCursorDownAndReturn = _throw1,
    void Function(int) moveCursorUpAndReturn = _throw1,
    void Function(int) moveCursorToColumn = _throw1,
    void Function(String) write = _throw1,
    void Function(String, int) unknown = _throw2,
  })  : _clearLine = clearLine,
        _clearLineAfter = clearLineAfter,
        _clearLineBefore = clearLineBefore,
        _clearScreen = clearScreen,
        _clearScreenAfter = clearScreenAfter,
        _clearScreenBefore = clearScreenBefore,
        _moveCursorHome = moveCursorHome,
        _moveCursorTo = moveCursorTo,
        _moveCursorUp = moveCursorUp,
        _moveCursorDown = moveCursorDown,
        _moveCursorRight = moveCursorRight,
        _moveCursorLeft = moveCursorLeft,
        _moveCursorDownAndReturn = moveCursorDownAndReturn,
        _moveCursorUpAndReturn = moveCursorUpAndReturn,
        _moveCursorToColumn = moveCursorToColumn,
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
  void moveCursorHome() => _moveCursorHome();
  final void Function() _moveCursorHome;

  @override
  void moveCursorTo(int line, int column) => _moveCursorTo(line, column);
  final void Function(int, int) _moveCursorTo;

  @override
  void moveCursorUp(int count) => _moveCursorUp(count);
  final void Function(int) _moveCursorUp;

  @override
  void moveCursorDown(int count) => _moveCursorDown(count);
  final void Function(int) _moveCursorDown;

  @override
  void moveCursorRight(int count) => _moveCursorRight(count);
  final void Function(int) _moveCursorRight;

  @override
  void moveCursorLeft(int count) => _moveCursorLeft(count);
  final void Function(int) _moveCursorLeft;

  @override
  void moveCursorDownAndReturn(int count) => _moveCursorDownAndReturn(count);
  final void Function(int) _moveCursorDownAndReturn;

  @override
  void moveCursorUpAndReturn(int count) => _moveCursorUpAndReturn(count);
  final void Function(int) _moveCursorUpAndReturn;

  @override
  void moveCursorToColumn(int column) => _moveCursorToColumn(column);
  final void Function(int) _moveCursorToColumn;

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
      case _$A:
        return _listener.moveCursorUp(int.parse(value));
      case _$B:
        return _listener.moveCursorDown(int.parse(value));
      case _$C:
        return _listener.moveCursorRight(int.parse(value));
      case _$D:
        return _listener.moveCursorLeft(int.parse(value));
      case _$E:
        return _listener.moveCursorDownAndReturn(int.parse(value));
      case _$F:
        return _listener.moveCursorUpAndReturn(int.parse(value));
      case _$G:
        return _listener.moveCursorToColumn(int.parse(value));
      case _$H:
        final parts = value.split(';');
        if (parts.length == 2) {
          return _listener.moveCursorTo(
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }
        return _listener.moveCursorHome();
      case _$f:
        final parts = value.split(';');
        return _listener.moveCursorTo(
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
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

  static const _$A = 0x41;
  static const _$B = 0x42;
  static const _$C = 0x43;
  static const _$D = 0x44;
  static const _$E = 0x45;
  static const _$F = 0x46;
  static const _$G = 0x47;
  static const _$H = 0x48;
  static const _$J = 0x4A;
  static const _$K = 0x4B;
  static const _$f = 0x66;

  // Copied from https://github.com/chalk/ansi-regex/blob/main/index.js.
  static final _isAnsiEscape = RegExp(
    r'[\u001B\u009B][[\]()#;?]*(?:(?:(?:(?:;[-a-zA-Z\d\/#&.:=?%@~_]+)*|'
    r'[a-zA-Z\d]+(?:;[-a-zA-Z\d\/#&.:=?%@~_]*)*)?\u0007)|'
    r'(?:(?:\d{1,4}(?:;\d{0,4})*)?[\dA-PR-TZcf-nq-uy=><~]))',
  );
  static final _ansiMatchParts = RegExp(r'([\u001B]\[)(.*)(\w$)');
}
