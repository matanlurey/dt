import 'package:dt/foundation.dart';
import 'package:test/test.dart';

void main() {
  late StringBuffer output;
  late StringWriter writer;
  late void Function() onFlush;

  setUp(() {
    onFlush = () {
      fail('Unexpected flush');
    };
    output = StringBuffer();
    writer = StringWriter(
      _StringWriter(
        output,
        onFlush: () {
          onFlush();
        },
      ),
    );
  });

  test('should write to the underlying writer', () {
    writer.write('Hello');
    expect(output.toString(), 'Hello');
  });

  test('should write the entire buffer', () {
    writer.write('Hello');
    writer.write('World');
    expect(output.toString(), 'HelloWorld');
  });

  test('should delegate flush', () async {
    var flushed = false;
    onFlush = () {
      if (flushed) {
        fail('Unexpected flush');
      }
      flushed = true;
    };
    await writer.flush();
    expect(flushed, isTrue);
  });
}

/// A simple writer that writes to a string buffer.
final class _StringWriter implements Writer {
  _StringWriter(
    this._buffer, {
    void Function()? onFlush,
  }) : _onFlush = onFlush ?? (() {});

  @override
  Future<void> flush() async {
    _onFlush();
  }

  final void Function() _onFlush;

  @override
  int write(List<int> bytes, [int offset = 0, int? length]) {
    length ??= bytes.length - offset;
    _buffer.write(String.fromCharCodes(bytes, offset, length));
    return length;
  }

  final StringSink _buffer;
}
