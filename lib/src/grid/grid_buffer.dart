import 'grid_editor.dart';
import 'grid_view.dart';

/// A buffer representing a 2-dimensional collection of cells of type [T].
interface class GridBuffer<T> with GridEditor<T>, GridView<T> {
  /// Creates a new buffer of size `width x height` and a initial cell value.
  factory GridBuffer.filled(
    int width,
    int height,
    T initialValue,
  ) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');
    final buffer = List.filled(
      width * height,
      initialValue,
      growable: true,
    );
    return GridBuffer._(buffer, width);
  }

  /// Creates a new buffer of size `width x height`.
  ///
  /// Each cell is created by invoking [fill] with the according `(x, y)`.
  factory GridBuffer.generate(
    int width,
    int height,
    T Function(int row, int column) fill,
  ) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');
    final buffer = List<T>.generate(
      width * height,
      (index) {
        final x = index % width;
        final y = index ~/ width;
        return fill(y, x);
      },
    );
    return GridBuffer._(buffer, width);
  }

  /// Creates a new buffer by copying [cells] stored in row-major order.
  ///
  /// The resulting buffer must be clearly divisible by [width].
  factory GridBuffer.fromBuffer(Iterable<T> cells, {required int width}) {
    RangeError.checkNotNegative(width, 'width');
    final buffer = List.of(cells);
    if (buffer.length % width != 0) {
      throw ArgumentError.value(
        'Cells length is not divisible by width ($width)',
        'cells.length',
        cells.length,
      );
    }
    return GridBuffer._(buffer, width);
  }

  /// Creates a new buffer by copying [rows].
  ///
  /// Each element must have the same length.
  factory GridBuffer.fromRows(Iterable<Iterable<T>> rows) {
    int? width;
    final buffer = <T>[];
    for (final row in rows) {
      if (width == null) {
        width = row.length;
      } else if (width != row.length) {
        throw ArgumentError('Each row must have the same number of cells');
      }
      buffer.addAll(row);
    }
    return GridBuffer._(buffer, width ?? 0);
  }

  const GridBuffer._(
    this._buffer,
    this._width,
  );

  @override
  Iterable<T> get cells => _buffer;
  final List<T> _buffer;

  @override
  int get length => _buffer.length;

  @override
  int get width => _width;
  final int _width;

  @override
  T operator [](int position) => _buffer[position];

  @override
  void operator []=(int position, T value) => _buffer[position] = value;

  @override
  T getCell(int row, int column) {
    final index = row * width + column;
    return _buffer[index];
  }

  @override
  void setCell(int row, int column, T value) {
    final index = row * width + column;
    _buffer[index] = value;
  }
}
