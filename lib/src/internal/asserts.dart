import 'package:meta/meta.dart';

/// Whether the application has assertions enabled.
@visibleForTesting
final assertionsEnabled = () {
  var enabled = false;
  assert(enabled = true, 'If executed, assertions are enabled.');
  return enabled;
}();
