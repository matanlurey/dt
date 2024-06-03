import 'package:checks/checks.dart';
import 'package:dt/foundation.dart';
import 'package:test/test.dart' show fail, setUp, test;

void main() {
  late StringBuffer output;
  late BufferedWriter writer;
  late void Function() onFlush;

  setUp(() {
    onFlush = () {
      fail('Unexpected flush');
    };
    output = StringBuffer();
    writer = BufferedWriter(
      _StringWriter(
        output,
        onFlush: () {
          onFlush();
        },
      ),
      capacity: 8,
    );
  });

  test('should not write to underlying writer', () {
    writer.write('Hello'.codeUnits);
    check(output.toString()).isEmpty();
  });

  test('should write to underlying writer when capacity is reached', () {
    // Write 4 bytes, which is less than the capacity.
    writer.write('1234'.codeUnits);
    check(output.toString()).isEmpty();

    // Write 4 more bytes, which should flush the buffer.
    writer.write('5678'.codeUnits);
    check(output.toString()).equals('12345678');
  });

  test('should write to underlying writer when flush is called', () async {
    writer.write('1234'.codeUnits);
    check(output.toString()).isEmpty();

    var flushed = false;
    onFlush = () {
      if (flushed) {
        fail('Unexpected flush');
      }
      flushed = true;
    };
    await writer.flush();
    check(output.toString()).equals('1234');
    check(flushed).isTrue();
  });

  test('should write the first block and store the next partial', () {
    // Writes the first 8 bytes and stores the next 4.
    writer.write('123412341234'.codeUnits);
    check(output.toString()).equals('12341234');

    // Writes the next 4 bytes and flushes the buffer.
    writer.write('1234'.codeUnits);
    check(output.toString()).equals('1234123412341234');
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
