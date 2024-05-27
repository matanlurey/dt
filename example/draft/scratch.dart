import 'dart:io';

void main() async {
  // Move to line 30, column 10.
  stdout.write('\x1B[30;10H');
  await Future<void>.delayed(const Duration(milliseconds: 1000));
}
