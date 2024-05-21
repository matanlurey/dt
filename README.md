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

- [x] Support a non-interactive ("cooked"), output-only string-based terminal
  (`StringLineFeed`).
- [ ] Support a non-interactive ("cooked") string-based terminal with input
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

See the diagram below for a high-level overview of the API design:

```mermaid
classDiagram
  class LineSink~T~
  <<abstract>> LineSink
    LineSink~T~ : +void write(T span)
    LineSink~T~ : +void writeLine(T span)

  class LineFeedView~T~
  <<abstract>> LineFeedView
    LineFeedView~T~ : +Iterable~T~ get lines

  class LineFeed~T~
  <<abstract>> LineFeed
  
  LineSink~T~ <|-- LineFeed~T~ : Mixes-in
  LineFeedView~T~ <|-- LineFeed~T~ : Mixes-in
  LineFeed~T~ <|-- StringLineFeed : Extends, T=String
```

<!--
```mermaid
classDiagram
  class TerminalView~T~
  <<abstract>> TerminalView
    TerminalView~T~ : +Cursor get cursor
    TerminalView~T~ : +Iterable~T~ get lines
  
  class TerminalSink~T~
  <<abstract>> TerminalSink
    TerminalSink~T~ : +void write(T span)
    TerminalSink~T~ : +void writeLine(T span)

  class TerminalBuffer~T~
  <<abstract>> TerminalBuffer

  TerminalView~T~ <|-- TerminalBuffer~T~ : Extends
  TerminalSink~T~ <|-- TerminalBuffer~T~ : Mixes-in
  TerminalBuffer~T~ <|-- StringTerminalBuffer : Extends, T=String

  class LineEditor~T~
  <<abstract>> LineEditor
    LineEditor~T~ : +LineCursor get cursor
    LineEditor~T~ : +void backspace()
    LineEditor~T~ : +void delete()

  class Terminal~T~
  <<abstract>> Terminal

  LineEditor~T~ <|-- Terminal~T~ : Mixes-in
  TerminalSink~T~ <|-- Terminal~T~ : Mixes-in
  TerminalView~T~ <|-- Terminal~T~ : Extends
  Terminal~T~ <|-- StringTerminal : Extends, T=String

  class TerminalController~T~
  <<abstract>> TerminalController
    TerminalController~T~ : +void clear()
    TerminalController~T~ : +ScreenCursor get cursor

  class RawTerminal~T~
  <<abstract>> RawTerminal

  Terminal~T~ <|-- RawTerminal~T~ : Extends
  TerminalController~T~ <|-- RawTerminal~T~ : Mixes-in
  RawTerminal~T~ <|-- RawStringTerminal : Extends, T=String
```
-->

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
