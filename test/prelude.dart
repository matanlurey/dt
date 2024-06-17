/// Test prelude for tests in this package.
library;

import 'package:checks/checks.dart';
import 'package:dt/rendering.dart';

export 'package:checks/checks.dart';
export 'package:test/test.dart'
    show
        TestOn,
        fail,
        group,
        pumpEventQueue,
        setUp,
        setUpAll,
        tearDown,
        tearDownAll,
        test;

extension BufferChecks on Subject<Buffer> {
  void equalsSymbolBox(Iterable<String> expected) {
    has(
      (b) => b.rows.map(
        (row) => row.map((cell) => cell.symbol).join(''),
      ),
      'rows',
    ).deepEquals(expected);
  }
}
