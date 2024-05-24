import 'package:dt/dt.dart';
import 'package:test/test.dart';

// We use a List<int> to avoid the degenerate case of a span with a '\n'.
typedef _Span = List<int>;

void main() {
  test('Cursor(...) is the same as Cursor.fromXY', () {
    final cursor = Cursor(column: 1, line: 2);
    final fromXY = Cursor.fromXY(1, 2);

    expect(cursor.offset, fromXY.offset);
    expect(cursor.toString(), 'Cursor <2:1>');
  });

  test('A string representation of the view', () {
    final view = _TestView();
    final result = view.toDebugString(
      drawBorder: true,
      format: (span) => span.join(),
    );

    expect(
      result,
      [
        '┌───┐',
        '│123│',
        '└───┘',
        '',
      ].join('\n'),
    );
  });

  test('A string representation of the view w/ cursor', () {
    final view = _TestView();
    final result = view.toDebugString(
      drawBorder: true,
      drawCursor: true,
      format: (span) => span.join(),
    );

    expect(
      result,
      [
        '┌───┐',
        '│█23│',
        '└───┘',
        '',
      ].join('\n'),
    );
  });

  test('A string representation of the view w/ cursor at end', () {
    final view = _TestView(cursor: Offset(3, 0));
    final result = view.toDebugString(
      drawBorder: true,
      drawCursor: true,
      format: (span) => span.join(),
    );

    expect(
      result,
      [
        '┌────┐',
        '│123█│',
        '└────┘',
        '',
      ].join('\n'),
    );
  });
}

// A test view with hardcoded return values.
final class _TestView implements TerminalView<_Span> {
  _TestView({
    Offset cursor = Offset.zero,
  }) : cursor = Cursor.fromXY(cursor.x, cursor.y);

  @override
  final Cursor cursor;

  @override
  Offset get lastPosition => Offset(0, 0);

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => true;

  @override
  int get lineCount => 1;

  @override
  _Span line(int index) => [1, 2, 3];

  @override
  _Span get currentLine => [1, 2, 3];

  @override
  Iterable<_Span> get lines {
    return [
      [1, 2, 3],
    ];
  }

  @override
  String toDebugString({
    bool drawBorder = false,
    bool drawCursor = false,
    bool includeLineNumbers = false,
    String Function(_Span)? format,
  }) {
    return TerminalView.visualize(
      this,
      drawBorder: drawBorder,
      includeLineNumbers: includeLineNumbers,
      drawCursor: drawCursor,
      format: format,
    );
  }
}

// These types exist to ensure that the class has the intended modifiers.
// -----------------------------------------------------------------------------

// ignore: unused_element
final class _CanBeImplemented implements TerminalView<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
final class _CanBeExtended extends TerminalView<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
final class _CanBeMixedIn with TerminalView<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
