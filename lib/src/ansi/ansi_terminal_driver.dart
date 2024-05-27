import 'package:dt/src/ansi/ansi_escape.dart';
import 'package:dt/src/term.dart';
import 'package:meta/meta.dart';

/// A mixin that implements [TerminalDriver] for ANSI terminals.
///
/// This mixin provides a default implementation of a terminal driver that
/// manipulates the cursor and terminal contents by writing ANSI escape codes
/// to the provided [ansi] handler.
mixin AnsiTerminalDriver implements TerminalDriver {
  /// The ANSI handler that writes ANSI escape codes.
  @protected
  void handleAnsi(AnsiEscape code);

  @override
  @nonVirtual
  late final cursor = _AnsiCursor(handleAnsi);

  @override
  @nonVirtual
  void clearScreenAfter() {
    handleAnsi(const AnsiClearScreenAfter());
  }

  @override
  @nonVirtual
  void clearScreenBefore() {
    handleAnsi(const AnsiClearScreenBefore());
  }

  @override
  @nonVirtual
  void clearScreen() {
    handleAnsi(const AnsiClearScreen());
  }

  @override
  @nonVirtual
  void clearLineAfter() {
    handleAnsi(const AnsiClearLineAfter());
  }

  @override
  @nonVirtual
  void clearLineBefore() {
    handleAnsi(const AnsiClearLineBefore());
  }

  @override
  @nonVirtual
  void clearLine() {
    handleAnsi(const AnsiClearLine());
  }
}

final class _AnsiCursor implements Cursor {
  const _AnsiCursor(this._ansi);
  final AnsiHandler<void> _ansi;

  @override
  void moveTo({required int column, int? line}) {
    if (line == null) {
      _ansi(AnsiMoveCursorToColumn(column));
      return;
    }

    _ansi(AnsiMoveCursorTo(line, column));
  }

  @override
  void moveBy({int? columns, int? lines}) {
    if (lines != null) {
      if (lines > 0) {
        _ansi(AnsiMoveCursorDown(lines));
      } else {
        _ansi(AnsiMoveCursorUp(-lines));
      }
    }
    if (columns != null) {
      if (columns > 0) {
        _ansi(AnsiMoveCursorRight(columns));
      } else {
        _ansi(AnsiMoveCursorLeft(-columns));
      }
    }
  }

  @override
  void reset() {
    _ansi(const AnsiMoveCursorHome());
  }

  @override
  void hide() {
    _ansi(const AnsiHideCursor());
  }

  @override
  void show() {
    _ansi(const AnsiShowCursor());
  }
}
