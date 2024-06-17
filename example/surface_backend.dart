import 'package:dt/backend.dart';
import 'package:dt/rendering.dart';

void main() async {
  final backend = SurfaceBackend.fromStdout();
  await run(backend);
}

Future<void> run(SurfaceBackend backend) async {
  backend.draw(0, 0, Cell('H'));
  backend.draw(1, 0, Cell('e'));
  backend.draw(2, 0, Cell('l'));
  backend.draw(3, 0, Cell('l'));
  backend.draw(4, 0, Cell('o'));
}
