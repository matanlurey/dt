import 'dart:collection';

import 'package:dt/src/core/ansi.dart';
import 'package:meta/meta.dart';

/// WIP: A terminal that buffers output.
@experimental
final class Terminal implements AnsiHandler {
  final _lines = [''];
  var _cursorX = 0;
  var _cursorY = 0;

  /// The lines of text in the terminal.
  ///
  /// This list is unmodifiable.
  late final List<String> lines = UnmodifiableListView(_lines);

  /// The current cursor's X position.
  int get cursorX => _cursorX;

  /// The current cursor's Y position.
  int get cursorY => _cursorY;

  @override
  void clearLine() {
    _cursorX = 0;
    clearLineAfter();
  }

  @override
  void clearLineAfter() {
    // Clear the current line after the cursor's X position.
    _lines[_cursorY] = _lines[_cursorY].substring(0, _cursorX);
  }

  @override
  void clearLineBefore() {
    // Clear the current line before the cursor's X position.
    _lines[_cursorY] = _lines[_cursorY].substring(_cursorX);
    _cursorX = 0;
  }

  @override
  void clearScreen() {
    _lines
      ..clear()
      ..add('');
    _cursorX = 0;
    _cursorY = 0;
  }

  @override
  void clearScreenAfter() {
    // Clear the screen after the cursor's X/Y position.
    _lines.removeRange(_cursorY + 1, _lines.length);
    clearLineAfter();
  }

  @override
  void clearScreenBefore() {
    // Clear the screen before the cursor's X/Y position.
    _lines.removeRange(0, _cursorY);
    clearLineBefore();
    _cursorY = 0;
  }

  /// Writes text to the buffer at the current cursor position.
  ///
  /// Each new line character will increment the cursor's Y position.
  @override
  void write(String text) {
    // Empty writes are no-ops.
    if (text.isEmpty) {
      return;
    }

    // Split the text into lines.
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      // Write the text to the current line at the cursor's X/Y position.
      _write(lines[i]);

      // If this is not the last line, write a new line.
      if (i < lines.length - 1) {
        _writeLine();
      }
    }
  }

  /// Write text to the buffer at the current cursor position.
  ///
  /// It is guaranteed no new line characters are present in the text.
  void _write(String text) {
    // Write the text to the current line at the cursor's X/Y position.
    _lines[_cursorY] = _lines[_cursorY].substring(0, _cursorX) + text;
    _cursorX += text.length;
  }

  /// Write a line to the buffer.
  ///
  /// This will append the line to the buffer and increment the cursor's Y.
  void _writeLine() {
    _cursorY++;
    _cursorX = 0;
    if (_cursorY >= _lines.length) {
      _lines.add('');
    }
  }
}
