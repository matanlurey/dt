import 'package:dt/dt.dart';
import 'package:test/test.dart';

void main() {
  group('$Writer.fromStringSink', () {
    late StringBuffer capture;
    late Writer buffer;

    setUp(() {
      capture = StringBuffer();
      buffer = Writer.fromStringSink(capture);
    });

    test('write does not write to sink until flushed', () async {
      buffer.write('Hello');
      expect(capture.toString(), isEmpty);

      await buffer.flush();
      expect(capture.toString(), 'Hello');
    });

    test('multiple writes are concatenated on flush', () async {
      buffer
        ..write('Hello')
        ..write('World');
      expect(capture.toString(), isEmpty);

      await buffer.flush();
      expect(capture.toString(), 'HelloWorld');
    });

    test('flushing twice does not duplicate text', () async {
      buffer.write('Hello');
      await buffer.flush();
      await buffer.flush();
      expect(capture.toString(), 'Hello');
    });

    test('close does not write to sink', () async {
      buffer.write('Hello');
      await buffer.close();
      expect(capture.toString(), isEmpty);
    });

    test('flush after close throws StateError', () async {
      buffer.write('Hello');
      await buffer.close();
      expect(() => buffer.flush(), throwsStateError);
    });

    test('close after close throws StateError', () async {
      await buffer.close();
      expect(() => buffer.close(), throwsStateError);
    });

    test('write after close throws StateError', () async {
      await buffer.close();
      expect(() => buffer.write('Hello'), throwsStateError);
    });
  });
}
