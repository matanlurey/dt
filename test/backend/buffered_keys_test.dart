import 'dart:async';

import 'package:dt/backend.dart';

import '../prelude.dart';

void main() {
  const qKey = 0x51;

  group('BufferedKeys.fromBuffer', () {
    late BufferedKeys keys;
    late Set<(int, int, int, int, int, int)> buffer;

    setUp(() {
      buffer = {};
      keys = BufferedKeys.fromBuffer(buffer);
    });

    test('should not initially have any keys pressed', () {
      check(keys).has((k) => k.isAnyPressed, 'isAnyPressed').isFalse();
    });

    test('isPressed(qKey)', () {
      check(keys).has((k) => k.isPressed(qKey), 'isPressed(qKey)').isFalse();

      buffer.add((qKey, 0, 0, 0, 0, 0));

      check(keys)
        ..has((k) => k.isPressed(qKey), 'isPressed(qKey)').isTrue()
        ..has((k) => k.isAnyPressed, 'isAnyPressed').isTrue();
    });

    test('clear', () {
      buffer.add((qKey, 0, 0, 0, 0, 0));

      check(keys).has((k) => k.isAnyPressed, 'isAnyPressed').isTrue();

      keys.clear();

      check(keys).has((k) => k.isAnyPressed, 'isAnyPressed').isFalse();
    });

    test('close', () async {
      await keys.close();

      buffer.add((qKey, 0, 0, 0, 0, 0));
      check(keys).has((k) => k.isAnyPressed, 'isAnyPressed').isFalse();
    });

    test('2-code character', () {
      buffer.add((1, 2, 0, 0, 0, 0));

      check(keys).has((k) => k.isPressed(1, 2), 'isPressed(1, 2)').isTrue();
    });

    test('3-code character', () {
      buffer.add((1, 2, 3, 0, 0, 0));

      check(keys)
          .has((k) => k.isPressed(1, 2, 3), 'isPressed(1, 2, 3)')
          .isTrue();
    });

    test('4-code character', () {
      buffer.add((1, 2, 3, 4, 0, 0));

      check(keys)
          .has((k) => k.isPressed(1, 2, 3, 4), 'isPressed(1, 2, 3, 4)')
          .isTrue();
    });

    test('5-code character', () {
      buffer.add((1, 2, 3, 4, 5, 0));

      check(keys)
          .has((k) => k.isPressed(1, 2, 3, 4, 5), 'isPressed(1, 2, 3, 4, 5)')
          .isTrue();
    });

    test('6-code character', () {
      buffer.add((1, 2, 3, 4, 5, 6));

      check(keys)
          .has(
            (k) => k.isPressed(1, 2, 3, 4, 5, 6),
            'isPressed(1, 2, 3, 4, 5, 6)',
          )
          .isTrue();
    });

    test('pressed', () {
      buffer.add((1, 2, 3, 4, 5, 6));

      check(keys).has((k) => k.pressed, 'pressed').deepEquals([
        [1, 2, 3, 4, 5, 6],
      ]);
    });
  });

  group('BufferedKeys.fromStream', () {
    late BufferedKeys keys;
    late StreamController<List<int>> controller;

    setUp(() {
      controller = StreamController<List<int>>(sync: true);
      keys = BufferedKeys.fromStream(controller.stream);
    });

    test('should not initially have any keys pressed', () {
      check(keys).has((k) => k.isAnyPressed, 'isAnyPressed').isFalse();
    });

    test('isPressed(qKey)', () {
      check(keys).has((k) => k.isPressed(qKey), 'isPressed(qKey)').isFalse();

      controller.add([qKey]);

      check(keys)
        ..has((k) => k.isPressed(qKey), 'isPressed(qKey)').isTrue()
        ..has((k) => k.isAnyPressed, 'isAnyPressed').isTrue();
    });

    test('clear', () {
      controller.add([qKey]);

      check(keys).has((k) => k.isAnyPressed, 'isAnyPressed').isTrue();

      keys.clear();

      check(keys).has((k) => k.isAnyPressed, 'isAnyPressed').isFalse();
    });

    test('2-code character', () {
      controller.add([1, 2]);

      check(keys).has((k) => k.isPressed(1, 2), 'isPressed(1, 2)').isTrue();
    });

    test('3-code character', () {
      controller.add([1, 2, 3]);

      check(keys)
          .has((k) => k.isPressed(1, 2, 3), 'isPressed(1, 2, 3)')
          .isTrue();
    });

    test('4-code character', () {
      controller.add([1, 2, 3, 4]);

      check(keys)
          .has((k) => k.isPressed(1, 2, 3, 4), 'isPressed(1, 2, 3, 4)')
          .isTrue();
    });

    test('5-code character', () {
      controller.add([1, 2, 3, 4, 5]);

      check(keys)
          .has((k) => k.isPressed(1, 2, 3, 4, 5), 'isPressed(1, 2, 3, 4, 5)')
          .isTrue();
    });

    test('6-code character', () {
      controller.add([1, 2, 3, 4, 5, 6]);

      check(keys)
          .has(
            (k) => k.isPressed(1, 2, 3, 4, 5, 6),
            'isPressed(1, 2, 3, 4, 5, 6)',
          )
          .isTrue();
    });

    test('should cancel the subscription when closed', () async {
      await keys.close();

      check(controller.hasListener).isFalse();
    });
  });
}
