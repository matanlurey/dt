import 'package:dt/foundation.dart';
import 'package:meta/meta.dart';

/// A layout is a way to split an area into multiple sub-areas.
abstract interface class LayoutSpec {
  /// Splits the given [area] into multiple sub-areas.
  List<Rect> split(Rect area);
}

/// Provides a [split] for splitting areas into multiple sub-areas.
extension LayoutRect on Rect {
  /// Splits the given [area] into multiple sub-areas.
  List<Rect> split(LayoutSpec layout) => layout.split(this);
}

/// A layout that splits an area into rows a defined [height].
///
/// The area is split into rows of equal height.
///
/// The remaining space at the bottom of the area is not included in the rows.
@immutable
final class FixedHeightRows implements LayoutSpec {
  /// Creates a layout that splits an area into rows.
  const FixedHeightRows({
    this.height = 1,
  }) : assert(height > 0, 'Height must be greater than 0');

  /// The height of each row.
  final int height;

  @override
  List<Rect> split(Rect area) {
    final length = area.height ~/ height;
    if (length == 0) {
      return const [Rect.zero];
    }
    return [
      for (var y = area.top; y < area.top + length * height; y += height)
        Rect.fromLTWH(
          area.left,
          y,
          area.width,
          height,
        ),
    ];
  }

  @override
  bool operator ==(Object other) {
    return other is FixedHeightRows && other.height == height;
  }

  @override
  int get hashCode => Object.hash(FixedHeightRows, height);

  @override
  String toString() => 'FixedHeightRows(height: $height)';
}

/// A layout that splits an area into columns of a defined [width].
///
/// The area is split into columns of equal width.
///
/// The remaining space at the right of the area is not included in the columns.
@immutable
final class FixedWidthColumns implements LayoutSpec {
  /// Creates a layout that splits an area into columns.
  const FixedWidthColumns({
    this.width = 1,
  }) : assert(width > 0, 'Width must be greater than 0');

  /// The width of each column.
  final int width;

  @override
  List<Rect> split(Rect area) {
    final length = area.width ~/ width;
    if (length == 0) {
      return const [Rect.zero];
    }
    return [
      for (var x = area.left; x < area.left + length * width; x += width)
        Rect.fromLTWH(
          x,
          area.top,
          width,
          area.height,
        ),
    ];
  }

  @override
  bool operator ==(Object other) {
    return other is FixedWidthColumns && other.width == width;
  }

  @override
  int get hashCode => Object.hash(FixedWidthColumns, width);

  @override
  String toString() => 'FixedWidthColumns(width: $width)';
}
