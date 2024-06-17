/// Provides utilities for rendering text to a terminal-like UI.
///
/// This library provides a set of classes and utilities that does not depend on
/// any specific terminal implementation, but rather provide a common interface
/// and set of utilities for rendering text and styled grapheme cells.
///
/// Most users will interact with the [Buffer] class, which provides a 2D grid
/// of optionally styled cells, or with the text-oriented classes like [Line],
/// [Span], [Style], and [Color].
library;

import 'rendering.dart';

export 'src/rendering/alignment.dart' show Alignment;
export 'src/rendering/buffer.dart' show Buffer;
export 'src/rendering/cell.dart' show Cell;
export 'src/rendering/color.dart' show Color, Color16;
export 'src/rendering/line.dart' show Line;
export 'src/rendering/span.dart' show Span;
export 'src/rendering/style.dart' show Style;
