/// Test prelude for tests in this package.
library;

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
