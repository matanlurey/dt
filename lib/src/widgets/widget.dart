import 'package:dt/rendering.dart';

/// A widget is a type that can be drawn on a [Buffer].
abstract class Widget {
  // ignore: public_member_api_docs
  const Widget();

  /// Draws the widget on the [buffer].
  void draw(Buffer buffer);
}
