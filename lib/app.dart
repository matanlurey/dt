/// Runs a main loop for an application.
///
/// Every frame, the [onFrame] function is called.
Future<void> runLoop(void Function() onFrame) async {
  while (true) {
    onFrame();
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }
}
