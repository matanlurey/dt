import 'package:dt/dt.dart';
import 'package:test/test.dart';

// We use a List<int> to avoid the degenerate case of a span with a '\n'.
typedef _Span = List<int>;

void main() {
  test('A string representation of the view', () {
    final view = _TestView();
    final result = TerminalView.visualize(
      view,
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
    final result = TerminalView.visualize(
      view,
      drawBorder: true,
      drawCursor: Offset.zero,
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
    final view = _TestView();
    final result = TerminalView.visualize(
      view,
      drawBorder: true,
      drawCursor: view.lastPosition,
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
  const _TestView();

  @override
  Offset get lastPosition => Offset(3, 0);

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => true;

  @override
  int get lineCount => 1;

  @override
  _Span line(int index) => [1, 2, 3];

  @override
  Iterable<_Span> get lines {
    return [
      [1, 2, 3],
    ];
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
