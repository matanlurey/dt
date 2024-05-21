import 'package:dt/src/line/view.dart';
import 'package:test/test.dart';

// We use a List<int> to avoid the degenerate case of a span with a '\n'.
typedef _Span = List<int>;

void main() {
  test('LineFeeedView.of delegates to an underlying view', () {
    final delegate = _TestView();
    final wrapper = LineFeedView.of(delegate);

    expect(wrapper.isEmpty, delegate.isEmpty);
    expect(wrapper.isNotEmpty, delegate.isNotEmpty);
    expect(wrapper.length, delegate.length);
    expect(wrapper.line(0), delegate.line(0));
    expect(wrapper.lines, delegate.lines);
  });
}

// A test view with hardcoded return values.
final class _TestView implements LineFeedView<_Span> {
  const _TestView();

  @override
  bool get isEmpty => false;

  @override
  bool get isNotEmpty => true;

  @override
  int get length => 1;

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
final class _CanBeImplemented implements LineFeedView<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
final class _CanBeExtended extends LineFeedView<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: unused_element
final class _CanBeMixedIn with LineFeedView<void> {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
