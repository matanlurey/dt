import 'package:dt/src/core.dart';
import 'package:dt/src/term/terminal_view.dart';
import 'package:test/test.dart';

// We use a List<int> to avoid the degenerate case of a span with a '\n'.
typedef _Span = List<int>;

void main() {
  test('LineFeeedView.of delegates to an underlying view', () {
    final delegate = _TestView();
    final wrapper = TerminalView.of(delegate);

    expect(wrapper.cursor.offset, delegate.cursor.offset);
    expect(wrapper.isEmpty, delegate.isEmpty);
    expect(wrapper.isNotEmpty, delegate.isNotEmpty);
    expect(wrapper.lineCount, delegate.lineCount);
    expect(wrapper.line(0), delegate.line(0));
    expect(wrapper.lines, delegate.lines);
  });
}

// A test view with hardcoded return values.
final class _TestView implements TerminalView<_Span> {
  const _TestView();

  @override
  Cursor get cursor => Cursor.fromXY(0, 0);

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
