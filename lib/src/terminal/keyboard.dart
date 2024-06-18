import 'dart:io' as io;
import 'package:dt/backend.dart';
import 'package:meta/meta.dart';

/// A keyboard that can be used to input text or detect key presses.
abstract interface class Keyboard {
  const Keyboard();

  /// Creates a new keyboard instance that reads from the standard input stream.
  factory Keyboard.fromStdin([io.Stdin? stdin]) {
    return Keyboard.fromBuffer(BufferedKeys.fromStream(stdin ?? io.stdin));
  }

  /// Creates a new keyboard instance using the provided [buffer].
  factory Keyboard.fromBuffer(BufferedKeys buffer) = _Keyboard;

  /// Clears the current state of the keyboard.
  void clear();

  /// Closes the keyboard and releases any resources associated with it.
  ///
  /// After calling this method, any further calls to [isPressed] will return
  /// `false`.
  ///
  /// This method should be called when the program is done reading keys, but
  /// before disabling raw mode.
  Future<void> close();

  /// All currently pressed key combinations in the order they were pressed.
  Iterable<List<Key>> get pressed;

  /// Returns `true` if [a] was pressed since the last call to [clear].
  ///
  /// May optionally provide up to 5 additional keys to check for a combination.
  bool isPressed(Key a, [Key b, Key c, Key d, Key e, Key f]);

  /// Whether _any_ key is currently pressed.
  bool get isAnyPressed;
}

final class _Keyboard extends Keyboard {
  const _Keyboard(this._buffer);
  final BufferedKeys _buffer;

  @override
  void clear() {
    _buffer.clear();
  }

  @override
  Future<void> close() async {
    await _buffer.close();
  }

  @override
  bool isPressed(Key a, [Key? b, Key? c, Key? d, Key? e, Key? f]) {
    return _buffer.isPressed(
      _toCode(a),
      _toCode(b),
      _toCode(c),
      _toCode(d),
      _toCode(e),
      _toCode(f),
    );
  }

  @override
  Iterable<List<Key>> get pressed {
    return _buffer.pressed.map((keys) {
      return keys.map((code) {
        return _toKey(code)!;
      }).toList();
    });
  }

  @override
  bool get isAnyPressed => _buffer.isAnyPressed;

  static int _toCode(Key? key) {
    return switch (key) {
      AsciiPrintableKey _ => key.charCode,
      AsciiControlKey _ => key.charCode,
      _ => 0,
    };
  }

  static Key? _toKey(int code) {
    return switch (code) {
      0x08 => AsciiControlKey.backspace,
      0x09 => AsciiControlKey.tab,
      0xA => AsciiControlKey.enter,
      0x1B => AsciiControlKey.escape,
      0x7F => AsciiControlKey.delete,
      _ when code >= 0x20 && code <= 0x7E =>
        AsciiPrintableKey.values[code - 0x20],
      _ => null,
    };
  }
}

/// A type representing a key on the keyboard.
@immutable
sealed class Key {
  const Key();
}

/// A control key on the keyboard.
///
/// Includes keys such as [backspace], [tab], [enter], [escape], and [delete].
enum AsciiControlKey implements Key {
  /// Backspace (`'\b'`).
  backspace(0x08),

  /// Tab (`'\t'`).
  tab(0x09),

  /// Enter (`'\n'`).
  enter(0xA),

  /// Escape (`'\x1B'`).
  escape(0x1B),

  /// Delete (`'\x7F'`).
  delete(0x7F);

  const AsciiControlKey(this.charCode);

  /// The ASCII character code of this key.
  final int charCode;
}

/// A printable ASCII key on the keyboard.
///
/// Icludes all printable characters, such as letters, numbers, and punctuation.
enum AsciiPrintableKey implements Key {
  /// Space (`' '`).
  space,

  /// Exclamation mark (`'!'`).
  exclamationMark,

  /// Double quote (`'"'`).
  doubleQuote,

  /// Number sign (`'#'`).
  hash,

  /// Dollar sign (`'$'`).
  dollar,

  /// Percent sign (`'%'`).
  percent,

  /// Ampersand (`'&'`).
  ampersand,

  /// Single quote (`"'"`).
  singleQuote,

  /// Left parenthesis (`'('`).
  openParenthesis,

  /// Right parenthesis (`')'`).
  closeParenthesis,

  /// Asterisk (`'*'`).
  asterisk,

  /// Plus sign (`'+'`).
  plus,

  /// Comma (`','`).
  comma,

  /// Minus sign (`'-'`).
  minus,

  /// Period (`'.'`).
  period,

  /// Forward slash (`'/'`).
  slash,

  /// Zero (`'0'`).
  $0,

  /// One (`'1'`).
  $1,

  /// Two (`'2'`).
  $2,

  /// Three (`'3'`).
  $3,

  /// Four (`'4'`).
  $4,

  /// Five (`'5'`).
  $5,

  /// Six (`'6'`).
  $6,

  /// Seven (`'7'`).
  $7,

  /// Eight (`'8'`).
  $8,

  /// Nine (`'9'`).
  $9,

  /// Colon (`':'`).
  colon,

  /// Semicolon (`';'`).
  semicolon,

  /// Less than sign (`'<'`).
  lessThan,

  /// Equals sign (`'='`).
  equals,

  /// Greater than sign (`'>'`).
  greaterThan,

  /// Question mark (`'?'`).
  questionMark,

  /// At sign (`'@'`).
  at,

  /// Lowercase letter a (`'a'`).
  a,

  /// Lowercase letter b (`'b'`).
  b,

  /// Lowercase letter c (`'c'`).
  c,

  /// Lowercase letter d (`'d'`).
  d,

  /// Lowercase letter e (`'e'`).
  e,

  /// Lowercase letter f (`'f'`).
  f,

  /// Lowercase letter g (`'g'`).
  g,

  /// Lowercase letter h (`'h'`).
  h,

  /// Lowercase letter i (`'i'`).
  i,

  /// Lowercase letter j (`'j'`).
  j,

  /// Lowercase letter k (`'k'`).
  k,

  /// Lowercase letter l (`'l'`).
  l,

  /// Lowercase letter m (`'m'`).
  m,

  /// Lowercase letter n (`'n'`).
  n,

  /// Lowercase letter o (`'o'`).
  o,

  /// Lowercase letter p (`'p'`).
  p,

  /// Lowercase letter q (`'q'`).
  q,

  /// Lowercase letter r (`'r'`).
  r,

  /// Lowercase letter s (`'s'`).
  s,

  /// Lowercase letter t (`'t'`).
  t,

  /// Lowercase letter u (`'u'`).
  u,

  /// Lowercase letter v (`'v'`).
  v,

  /// Lowercase letter w (`'w'`).
  w,

  /// Lowercase letter x (`'x'`).
  x,

  /// Lowercase letter y (`'y'`).
  y,

  /// Lowercase letter z (`'z'`).
  z,

  /// Left square bracket (`'['`).
  openBracket,

  /// Backslash (`'\\'`).
  backslash,

  /// Right square bracket (`']'`).
  closeBracket,

  /// Caret (`'^'`).
  caret,

  /// Underscore (`'_'`).
  underscore,

  /// Grave accent (backtick) (`'`'`).
  backtick,

  /// Uppercase letter A (`'A'`).
  A,

  /// Uppercase letter B (`'B'`).
  B,

  /// Uppercase letter C (`'C'`).
  C,

  /// Uppercase letter D (`'D'`).
  D,

  /// Uppercase letter E (`'E'`).
  E,

  /// Uppercase letter F (`'F'`).
  F,

  /// Uppercase letter G (`'G'`).
  G,

  /// Uppercase letter H (`'H'`).
  H,

  /// Uppercase letter I (`'I'`).
  I,

  /// Uppercase letter J (`'J'`).
  J,

  /// Uppercase letter K (`'K'`).
  K,

  /// Uppercase letter L (`'L'`).
  L,

  /// Uppercase letter M (`'M'`).
  M,

  /// Uppercase letter N (`'N'`).
  N,

  /// Uppercase letter O (`'O'`).
  O,

  /// Uppercase letter P (`'P'`).
  P,

  /// Uppercase letter Q (`'Q'`).
  Q,

  /// Uppercase letter R (`'R'`).
  R,

  /// Uppercase letter S (`'S'`).
  S,

  /// Uppercase letter T (`'T'`).
  T,

  /// Uppercase letter U (`'U'`).
  U,

  /// Uppercase letter V (`'V'`).
  V,

  /// Uppercase letter W (`'W'`).
  W,

  /// Uppercase letter X (`'X'`).
  X,

  /// Uppercase letter Y (`'Y'`).
  Y,

  /// Uppercase letter Z (`'Z'`).
  Z,

  /// Left curly brace (`'{'`).
  openBrace,

  /// Vertical bar (`'|'`).
  pipe,

  /// Right curly brace (`'}'`).
  closeBrace,

  /// Tilde (`'~'`).
  tilde;

  /// The ASCII character code of this key.
  int get charCode => index + 32;
}
