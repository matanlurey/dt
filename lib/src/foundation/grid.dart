/// Stores elements of type [T] in a continuous growable 2-dimensional grid.
///
/// The default implementation, [ListGrid], is backed by a growable [List].
abstract interface class Grid<T> {
  /// Creates an empty [ListGrid].
  factory Grid.empty() = ListGrid<T>.empty;

  /// Creates a [ListGrid] of the given [width] and [height] filled with [fill].
  ///
  /// - If either [width] or [height] is 0, an [empty] grid is created.
  ///
  /// Throws if [width] or [height] is negative.
  factory Grid.filled(
    int width,
    int height,
    T fill,
  ) = ListGrid<T>.filled;

  /// Generates a grid of the given [width] and [height] using a [generator].
  ///
  /// Creates a grid filled with the result of calling [generator] for each
  /// cell in the range `[0, width) x [0, height)`.
  ///
  /// - If either [width] or [height] is 0, an [empty] grid is created.
  ///
  /// Throws if [width] or [height] is negative.
  factory Grid.generate(
    int width,
    int height,
    T Function(int x, int y) generator,
  ) = ListGrid<T>.generate;

  /// Creates a grid from [cells] stored in a row-major order.
  ///
  /// Throws if [width] is:
  /// - negative;
  /// - not a divisor of the number of elements;
  /// - given as `0` and the number of elements is not `0`.
  factory Grid.fromCells(
    Iterable<T> cells, {
    required int width,
  }) = ListGrid<T>.fromCells;

  /// Creates a grid from a 2-dimensional [matrix] stored in a row-major order.
  ///
  /// Throws if [matrix] is not rectangular.
  factory Grid.fromMatrix(List<List<T>> matrix) = ListGrid<T>.fromMatrix;

  /// Width of the grid (in columns).
  int get width;

  /// Height of the grid (in rows).
  int get height;

  /// Total number of cells in the grid.
  int get length;

  /// Whether or not the grid is empty.
  bool get isEmpty;

  /// Whether or not the grid is not empty.
  bool get isNotEmpty;

  /// Iterable of all cells in the grid.
  Iterable<T> get cells;

  /// Cell at the given index [i].
  ///
  /// Throws if [i] is out of bounds (i.e. `i < 0` or `i >= length`).
  ///
  /// The order of the cells is determined by the internal memory layout.
  T operator [](int i);

  /// Sets the cell at the given index [i] to [value].
  ///
  /// Throws if [i] is out of bounds (i.e. `i < 0` or `i >= length`).
  ///
  /// The order of the cells is determined by the internal memory layout.
  void operator []=(int i, T value);

  /// Cell at the given [x] and [y] coordinates.
  ///
  /// Throws if [x] or [y] is out of bounds (i.e. `x < 0` or `x >= width` or
  /// `y < 0` or `y >= height`).
  T get(int x, int y);

  /// Sets the cell at the given [x] and [y] coordinates to [value].
  ///
  /// Throws if [x] or [y] is out of bounds (i.e. `x < 0` or `x >= width` or
  /// `y < 0` or `y >= height`).
  void set(int x, int y, T value);

  /// Iterable of all rows in the grid.
  Iterable<Iterable<T>> get rows;

  /// Iterable of all columns in the grid.
  ///
  /// **NOTE**: This operation is significantly slower than [rows].
  Iterable<Iterable<T>> get columns;
}

/// A 2-dimensional grid backed by a growable [List].
final class ListGrid<T> implements Grid<T> {
  /// Creates a empty grid that grows as needed.
  factory ListGrid.empty() {
    return ListGrid._(
      [],
      0,
    );
  }

  /// Creates a grid of the given [width] and [height] filled with [fill].
  ///
  /// - If either [width] or [height] is 0, an [empty] grid is created.
  /// - The [order] parameter specifies the internal memory layout of the grid.
  ///
  /// Throws if [width] or [height] is negative.
  factory ListGrid.filled(
    int width,
    int height,
    T fill,
  ) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');
    if (width == 0 || height == 0) {
      return ListGrid.empty();
    }
    return ListGrid._(
      List<T>.filled(width * height, fill),
      width,
    );
  }

  /// Generates a grid of the given [width] and [height] using a [generator].
  ///
  /// Creates a grid filled with the result of calling [generator] for each
  /// cell in the range `[0, width) x [0, height)`.
  ///
  /// - If either [width] or [height] is 0, an [empty] grid is created.
  ///
  /// Throws if [width] or [height] is negative.
  factory ListGrid.generate(
    int width,
    int height,
    T Function(int x, int y) generator,
  ) {
    RangeError.checkNotNegative(width, 'width');
    RangeError.checkNotNegative(height, 'height');
    if (width == 0 || height == 0) {
      return ListGrid.empty();
    }
    final cells = List<T>.generate(width * height, (index) {
      final x = index % width;
      final y = index ~/ width;
      return generator(x, y);
    });
    return ListGrid._(
      cells,
      width,
    );
  }

  /// Creates a grid from [cells].
  ///
  /// The [order] parameter specifies the internal memory layout of the grid.
  ///
  /// Throws if [width] is:
  /// - negative;
  /// - not a divisor of the number of elements;
  /// - given as `0` and the number of elements is not `0`.
  factory ListGrid.fromCells(
    Iterable<T> cells, {
    required int width,
  }) {
    RangeError.checkNotNegative(width, 'width');
    if (width == 0) {
      if (cells.isNotEmpty) {
        throw ArgumentError.value(
          width,
          'width',
          'must be greater than 0 if elements is not empty',
        );
      }
      return ListGrid.empty();
    }
    final copy = List.of(cells);
    if (copy.length % width != 0) {
      throw ArgumentError.value(
        width,
        'width',
        'must be a divisor of the number of elements',
      );
    }
    return ListGrid._(
      copy,
      width,
    );
  }

  /// Creates a grid from a 2-dimensional [matrix].
  ///
  /// Throws if [matrix] is not rectangular.
  factory ListGrid.fromMatrix(
    List<List<T>> matrix,
  ) {
    if (matrix.isEmpty) {
      return ListGrid.empty();
    }
    final width = matrix.first.length;
    for (final row in matrix) {
      if (row.length != width) {
        throw ArgumentError.value(
          matrix,
          'matrix',
          'must be rectangular',
        );
      }
    }
    final cells = matrix.expand((row) => row);
    return ListGrid._(
      List.of(cells),
      width,
    );
  }

  ListGrid._(
    this._cells,
    this._width,
  );

  @override
  Iterable<T> get cells => _cells;
  final List<T> _cells;

  @override
  int get length => _cells.length;

  @override
  bool get isEmpty => _cells.isEmpty;

  @override
  bool get isNotEmpty => _cells.isNotEmpty;

  @override
  int get width => _width;
  int _width;

  @override
  int get height {
    if (_width == 0) {
      return 0;
    }
    return length ~/ _width;
  }

  @override
  T operator [](int i) => _cells[i];

  @override
  void operator []=(int i, T value) => _cells[i] = value;

  int _index(int x, int y) {
    RangeError.checkValueInInterval(x, 0, width - 1, 'x');
    RangeError.checkValueInInterval(y, 0, height - 1, 'y');
    return y * _width + x;
  }

  @override
  T get(int x, int y) => _cells[_index(x, y)];

  @override
  void set(int x, int y, T value) => _cells[_index(x, y)] = value;

  @override
  Iterable<Iterable<T>> get rows sync* {
    for (var y = 0; y < height; y++) {
      yield _cells.skip(y * _width).take(width);
    }
  }

  @override
  Iterable<Iterable<T>> get columns sync* {
    for (var x = 0; x < width; x++) {
      // Yield each y-th element of each column.
      yield [
        for (var y = 0; y < height; y++) _cells[_index(x, y)],
      ];
    }
  }

  @override
  String toString({String separator = ' '}) {
    return rows.map((row) => row.join(separator)).join('\n');
  }
}
