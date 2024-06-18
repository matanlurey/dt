/// Provides the main interface of this package, [Surface], and related types.
///
/// ```dart
/// import 'package:dt/terminal.dart';
///
/// void main() {
///   final terminal = Surface.fromStdio();
///   terminal.draw((frame) {
///     frame.draw((buffer) {
///       buffer.print(0, 0, 'Hello, World!');
///     });
///   });
///   terminal.dispose();
/// }
/// ```
library;

import 'terminal.dart';

export 'src/terminal/frame.dart' show Frame;
export 'src/terminal/keyboard.dart'
    show AsciiControlKey, AsciiPrintableKey, Keyboard;
export 'src/terminal/surface.dart' show Surface;
