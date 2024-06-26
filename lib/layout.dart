/// Layout definitions, computations, and utilities.
///
/// The coordinate system runs left-to-right on the x-axis and top-to-bottom on
/// the y-axis, with the origin [Offset.zero] at the top-left corner. The `x`
/// and `y` coordinates are represented by [int] values and are generally listed
/// in the order `(x, y)`.
///
/// ```txt
/// (0, 0) -------------------------> x (columns)
///        |
///        |
///        |
///        |
///        |
///        |
///        |
///        v
///        y (rows)
/// ```
library layout;

import 'foundation.dart';

export 'foundation.dart' show Offset, Rect;

export 'src/layout/axis.dart' show Axis;
export 'src/layout/constraint.dart'
    show Constrained, Constraint, Fixed, Flexible;
export 'src/layout/layout.dart'
    show FixedHeightRows, FixedWidthColumns, LayoutRect, LayoutSpec;
export 'src/layout/spacing.dart' show Spacing;
