import 'package:dt/rendering.dart';

import 'ansi_escaped_color.dart';
import 'sequence.dart';

/// Provides conversion from a [Style] to ANSI escape sequences.
extension AnsiEscapedStyle on Style {
  /// Returns a list of ANSI escape sequences that represent this style.
  List<Sequence> toSequences() {
    return [
      foreground.setForeground().toSequence(),
      background.setBackground().toSequence(),
    ];
  }
}
