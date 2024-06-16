/// Building blocks and framework primitives for the rest of the library.
///
/// The features defined in this library are the lowest-level utility classes
/// and functions used by all other parts of the framework and do not import
/// any other libraries in the package.
///
/// Most applications and packages will not use this library directly.
library;

export 'src/foundation/grid.dart' show Grid, ListGrid;
export 'src/foundation/offset.dart' show Offset;
export 'src/foundation/rect.dart' show Rect;
export 'src/foundation/sequence.dart' show EscapeSequence, Literal, Sequence;
export 'src/foundation/writer.dart' show BufferedWriter, StringWriter, Writer;
