# Dart Terminal

A _fun_ and _minimalist_ experiment in crafting terminal UIs with Dart.

[![Linux Build](https://github.com/matanlurey/dt/actions/workflows/linux.yaml/badge.svg)](https://github.com/matanlurey/dt/actions/workflows/linux.yaml)
[![Mac Build](https://github.com/matanlurey/dt/actions/workflows/macos.yaml/badge.svg)](https://github.com/matanlurey/dt/actions/workflows/macos.yaml)
[![Coverage Status](https://coveralls.io/repos/github/matanlurey/dt/badge.svg?branch=main)](https://coveralls.io/github/matanlurey/dt?branch=main)

Inspiration:

- <https://github.com/crossterm-rs/crossterm>
- <https://github.com/muesli/termenv>
- <https://github.com/wez/wezterm/tree/main/termwiz>
- <https://sr.ht/~rockorager/vaxis/>
- <https://github.com/timsneath/dart_console>

Work-in-progress:

- [x] Support a non-interactive ("cooked") string-based terminal with input
  support (`StringTerminal`).
- [ ] Support an interactive ("raw") string-based terminal with input and output
  support (`RawStringTerminal`).
- [ ] Add a new span-type for terminal formatting and styling (`TextSpan`), and
  support it (i.e. `*SpanTerminal*`).

## Overview

> [!NOTE]
> This project is a work-in-progress and everything is subject to change.
> Feedback and contributions are welcome!

This project aims to provide an intuitive and ergonomic API for building,
emulating, and interacting with terminal applications in Dart. It's designed to
be a low-level building block for more complex terminal applications, such as
text editors, games, and interactive command-line interfaces.

### Terminal

A `Terminal` represents a sequence of lines of text that can be written to and
read from, and a cursor that can be moved around. Intended to represent parts of
a standard ("cooked" or _canonical_) terminal interface, writing to a terminal
replaces all spans after the cursor and moves the cursor to the last possible
position

```dart
import 'package:dt/dt.dart';

void main() {
  final terminal = StringTerminal.from(lines: ['Hello, World!']);

  // World isn't that impressive, let's replace it with Dart!
  terminal.cursor.column -= 6;
  terminal.write('Dart!');

  print(terminal.toDebugString(drawBorder: true, includeCursor: true));
}
```

```shell
% dart example/terminal.dart
┌─────────────┐
│Hello, Dart!█│
└─────────────┘
```

The major API surface of a `Terminal` includes:

```mermaid
classDiagram
  class TerminalSink~T~
  <<abstract>> TerminalSink
    TerminalSink~T~ : +void write(T span)
    TerminalSink~T~ : +void writeLine(T span)

  class TerminalView~T~
  <<abstract>> TerminalView
    TerminalView~T~ : +Iterable~T~ get lines
    TerminalView~T~ : +Cursor get cursor

  class Terminal~T~
  <<abstract>> Terminal
    Terminal~T~ : +InteractiveCursor get cursor
  
  TerminalSink~T~ <|-- Terminal~T~ : Mixes-in
  TerminalView~T~ <|-- Terminal~T~ : Mixes-in
  Terminal~T~ <|-- StringTerminal : Extends, T=String
```

## Benchmarks

While not the primary goal of this project, it's interesting to see how the
`libc`-based implementation compares to the `dart:io`-based one. The following
benchmarks were run on an M2 Max MacBook Pro (2021) with 10 CPU cores on Dart
version 3.4.0:

```shell
# Redirect stderr to /dev/null to avoid printing junk to the terminal.
dart run benchmark/stdout_write.dart 2> /dev/null
```

| Implementation | Time (ms)       |
| -------------- | --------------- |
| `dart:io`      |  1203.0025 us   |
| `libc`         |  752.19175 us   |

📈 The `libc`-based implementation is about **37% faster** than `dart:io`.

> [!TIP]
> In my tests, an AOT-compiled binary had no noticeable performance impact.

## Contributing

### CI

This package is:

- Formatted with `dart format`.
- Checked with `dart analyze`.
- Tested with `dart test`, including with code coverage.

See [`github/workflows/check.yaml`](./.github/workflows/check.yaml) for details.

### Coverage

To view the coverage report locally (MacOS):

```shell
brew install lcov
dart run coverage:test_with_coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```
