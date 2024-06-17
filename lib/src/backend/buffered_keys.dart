import 'dart:async';

/// A minimal buffer interface for _synchronously_ reading the state of keys.
///
/// When reading directly from the terminal using `dart:io`, you can either:
/// 1. Block the program until a key is pressed (`stdin.readByteSync()`).
/// 2. Capture event codes as they are received (`stdin.listen()`).
///
/// [BufferedKeys] provides a synchronous API for the _state_ of key codes:
/// ```dart
/// import 'dart:io' as io;
///
/// void main() async {
///   const frames = Duration(milliseconds: 1000 ~/ 60);
///   const qKey = 0x51;
///   final bufferedKeys = BufferedKeys.fromStream(io.stdin);
///
///   io.stdout.writeln('Press Q to exit.');
///   await for (final _ in Stream.periodic(frames)) {
///     if (bufferedKeys.isPressed(qKey)) {
///       break;
///     }
///     bufferedKeys.clear();
///   }
///
///   await bufferedKeys.close();
/// }
/// ```
abstract class BufferedKeys {
  // ignore: public_member_api_docs
  const BufferedKeys();

  /// Creates a new buffered keys instance using the provided [buffer].
  ///
  /// The class expects that the buffer will be updated by the caller.
  ///
  /// Each combination of key codes is represented as a tuple of up to six
  /// integers, set from left to right, with every unset key code set to `0`.
  ///
  /// For example, the key code for the 'A' key is `0x41`:
  /// ```dart
  /// const aKey = 0x41;
  /// const bufferedKeys = BufferedKeys.fromBuffer({(aKey, 0, 0, 0, 0, 0)});
  /// ```
  ///
  /// To represent a combination of key codes, such as 'Ctrl+C':
  /// ```dart
  /// const ctrlKey = 0x1D;
  /// const cKey = 0x43;
  /// const bufferedKeys = BufferedKeys.fromBuffer({(ctrlKey, cKey, 0, 0, 0, 0)});
  /// ```
  factory BufferedKeys.fromBuffer(
    Set<(int, int, int, int, int, int)> buffer,
  ) = _SyncBufferedKeys;

  /// Creates a new buffered keys instance from the provided [input] stream.
  ///
  /// The class will listen to the stream and update the buffer as events are
  /// received.
  factory BufferedKeys.fromStream(Stream<List<int>> input) = _AsyncBufferedKeys;

  /// Returns whether the provided key code combination is currently pressed.
  ///
  /// A simple key code can be provided:
  /// ```dart
  /// const enterKey = 0x0A;
  /// if (bufferedKeys.isPressed(enterKey)) {
  ///   print('Enter key is pressed!');
  /// }
  /// ```
  ///
  /// Or a combination of key codes can be provided:
  /// ```dart
  /// const ctrlKey = 0x1D;
  /// const cKey = 0x43;
  /// if (bufferedKeys.isPressed(ctrlKey, cKey)) {
  ///   print('Ctrl+C is pressed!');
  /// }
  /// ```
  bool isPressed(
    int code1, [
    int code2,
    int code3,
    int code4,
    int code5,
    int code6,
  ]);

  /// Returns whether _any_ key code is currently pressed.
  bool get isAnyPressed;

  /// All currently pressed key code combinations.
  Iterable<List<int>> get pressed;

  /// Closes the buffered keys and releases any resources.
  ///
  /// After calling this method, any further calls to [isPressed] will return
  /// `false`.
  ///
  /// This method should be called when the program is done reading keys, but
  /// before disabling raw mode.
  Future<void> close();

  /// Clears the buffer of any key codes.
  ///
  /// This method should be called at the end of each frame to ensure that the
  /// buffer is up-to-date:
  /// ```dart
  /// while (true) {
  ///   // Process keys.
  ///   const qKey = 0x51;
  ///   if (bufferedKeys.isPressed(qKey)) {
  ///     break;
  ///   }
  ///   // Clear the buffer.
  ///   await bufferedKeys.clear();
  ///
  ///   // Render the frame.
  ///   // ...
  /// }
  /// ```
  void clear();
}

final class _SyncBufferedKeys extends BufferedKeys {
  _SyncBufferedKeys(this._buffer);

  Set<(int, int, int, int, int, int)> _buffer;

  @override
  bool isPressed(
    int code1, [
    int code2 = 0,
    int code3 = 0,
    int code4 = 0,
    int code5 = 0,
    int code6 = 0,
  ]) {
    return _buffer.contains((code1, code2, code3, code4, code5, code6));
  }

  @override
  Iterable<List<int>> get pressed {
    return _buffer.map(
      (keys) => [
        keys.$1,
        if (keys.$2 != 0) keys.$2,
        if (keys.$3 != 0) keys.$3,
        if (keys.$4 != 0) keys.$4,
        if (keys.$5 != 0) keys.$5,
        if (keys.$6 != 0) keys.$6,
      ],
    );
  }

  @override
  bool get isAnyPressed => _buffer.isNotEmpty;

  @override
  Future<void> close() async {
    _buffer = const {};
  }

  @override
  void clear() {
    _buffer.clear();
  }
}

final class _AsyncBufferedKeys extends _SyncBufferedKeys {
  _AsyncBufferedKeys(Stream<List<int>> input) : super({}) {
    _subscription = input.listen((event) {
      final keys = (
        event[0],
        event.length > 1 ? event[1] : 0,
        event.length > 2 ? event[2] : 0,
        event.length > 3 ? event[3] : 0,
        event.length > 4 ? event[4] : 0,
        event.length > 5 ? event[5] : 0,
      );
      _buffer.add(keys);
    });
  }

  late final StreamSubscription<void> _subscription;

  @override
  Future<void> close() async {
    _buffer = const {};
    await _subscription.cancel();
  }
}
