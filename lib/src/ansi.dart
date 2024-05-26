import 'package:dt/src/core.dart';
import 'package:dt/src/term.dart';

/// A mixin that implements [TerminalDriver] for ANSI terminals.
///
/// This mixin provides a default implementation of a terminal driver that
/// manipulates the cursor and terminal contents by writing ANSI escape codes
/// to the string-based terminal sink.
mixin AnsiTerminalDriver on TerminalSink<String> implements TerminalDriver {
  late final _ansi = AnsiWriter.to(write);

  @override
  void clearScreenAfter() {
    _ansi.clearScreenAfter();
  }

  @override
  void clearScreenBefore() {
    _ansi.clearScreenBefore();
  }

  @override
  void clearScreen() {
    _ansi.clearScreen();
  }

  @override
  void clearLineAfter() {
    _ansi.clearLineAfter();
  }

  @override
  void clearLineBefore() {
    _ansi.clearLineBefore();
  }

  @override
  void clearLine() {
    _ansi.clearLine();
  }
}
