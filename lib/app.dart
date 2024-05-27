/// An interface for running a main loop.
///
/// In a standard application, the main loop is responsible for updating the
/// application state and rendering the application to the screen, typically
/// every frame:
///
/// ```dart
/// final app = Loop(() {
///   // Update the application state.
///   // Render the application to the screen.
///   // Handle user input.
/// });
///
/// await app.start();
/// ```
///
/// In a test environment, [update] should be called directly:
///
/// ```dart
/// final app = Loop(() {
///   // Update the application state.
///   // Render the application to the screen.
///   // Handle user input.
/// });
///
/// app.update();
/// ```
interface class Loop {
  /// Creates an application with the given [update] function.
  Loop(this._update);

  /// Update the application.
  ///
  /// This method should be called once per frame.
  void update() {
    _update();
  }

  final void Function() _update;

  /// Starts the main loop.
  ///
  /// Invokes the [update] method once per frame until [stop] is called.
  ///
  /// In a test environment, this method can be ignored.
  Future<void> start() async {
    _running = true;
    while (_running) {
      update();
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }

  var _running = false;

  /// Stops the main loop.
  ///
  /// In a test environment, this method can be ignored.
  Future<void> stop() async {
    _running = false;
  }

  /// Whether the application is running.
  bool get isRunning => _running;
}
