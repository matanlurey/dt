// Now that web is moving away from dart:html, it's unlikely that the Sink type
// type will be used outside of the VM, so don't bother testing it elsewhere.
@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dt/foundation.dart';

import '../prelude.dart';

void main() {
  late Future<void> Function() close;

  late Writer writer;
  late Stream<String> output;

  setUp(() async {
    final pipe = await io.Pipe.create();
    close = pipe.write.close;
    writer = Writer.fromSink(pipe.write, onFlush: pipe.write.flush);
    output = pipe.read.transform(const Utf8Decoder());
  });

  test('should write to the underlying sink', () async {
    writer.write('Hello'.codeUnits);
    await writer.flush();
    await close();

    await check(output).withQueue.inOrder([
      (s) => s.emits((v) => v.equals('Hello')),
      (s) => s.isDone(),
    ]);
  });

  test('should write the entire buffer', () async {
    writer.write('Hello'.codeUnits);
    writer.write('World'.codeUnits);
    await writer.flush();
    await close();

    await check(output).withQueue.inOrder([
      (s) => s.emits((v) => v.equals('HelloWorld')),
      (s) => s.isDone(),
    ]);
  });

  test('should write the specified range', () async {
    writer.write('Hello'.codeUnits, 1, 3);
    await writer.flush();
    await close();

    await check(output).withQueue.inOrder([
      (s) => s.emits((v) => v.equals('ell')),
      (s) => s.isDone(),
    ]);
  });

  test('should write the specified range of a Uint8List', () async {
    writer.write(utf8.encode('Hello'), 1, 3);
    await writer.flush();
    await close();

    await check(output).withQueue.inOrder([
      (s) => s.emits((v) => v.equals('ell')),
      (s) => s.isDone(),
    ]);
  });
}