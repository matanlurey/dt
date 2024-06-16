# Dart Terminal

A _fun_ and _minimalist_ experiment in crafting terminal UIs with Dart.

[![Linux Build](https://github.com/matanlurey/dt/actions/workflows/linux.yaml/badge.svg)](https://github.com/matanlurey/dt/actions/workflows/linux.yaml)
[![Mac Build](https://github.com/matanlurey/dt/actions/workflows/macos.yaml/badge.svg)](https://github.com/matanlurey/dt/actions/workflows/macos.yaml)
[![Coverage Status](https://coveralls.io/repos/github/matanlurey/dt/badge.svg?branch=main)](https://coveralls.io/github/matanlurey/dt?branch=main)

## Key Concepts

> [!NOTE]
>
> This project is a work-in-progress and everything is subject to change.

This project aims to provide an intuitive and ergonomic API for building,
emulating, and interacting with terminal applications in Dart. It's designed to
be a low-level building block for more complex terminal applications, such as
text editors, games, and interactive command-line interfaces.

### Buffer

A `Buffer` is a two-dimensional grid of characters with an associated style. It
is the primary building block for rendering text-based content to the terminal,
and it can be used to build more complex UI components. For example, a `Buffer`
can be used to render text, boxes, and sprites:

```dart
import 'package:dt/rendering.dart';

void main() {
  final buffer = Buffer(10, 3, '#');
  buffer.print(0, 1, 'Hello, World!');
  
  // ##########
  // Hello, Wor
  // ##########
  buffer.rows.forEach((row) => print(row.map((cell) => cell.symbol).join()));
}
```

### Surface

A `Surface` is a high-level abstraction for writing `Buffer`s to the terminal:

```dart
import 'package:dt/terminal.dart';

void main() {
  final surface = Surface.fromStdout();

  surface.draw((frame) {
    frame.draw((buffer) {
      buffer.print(0, 1, 'Hello, World!');
    });
  });
}
```

## Contributing

### CI/CD

This package is:

- Formatted with `dart format`.
- Checked with `dart analyze`.
- Tested with `dart test`, including with code coverage (see
  [`tool/coverage.dart`](tool/coverage.dart)).

### Inspiration

This package is inspired by a number of libraries, including but not limited to:

- [crossterm](https://github.com/crossterm-rs/crossterm): A Rust library for
  cross-platform terminal manipulation.
- [dart_console](https://github.com/timsneath/dart_console): A Dart library for
  terminal manipulation.
- [fortress](https://pub.dev/packages/fortress): A Dart library for building
  retro-style games.
- [hex_toolkit](https://pub.dev/packages/hex_toolkit): A Dart library for
  hexagonal grids.
- [mini_sprite](https://pub.dev/packages/mini_sprite): A Dart library for
  sprite-based rendering.
- [pathxp](https://pub.dev/packages/pathxp) and
  [pathfinding](https://pub.dev/packages/pathfinding): Dart libraries for
  pathfinding algorithms.
- [taffy](https://crates.io/crates/taffy): UI layout library for Rust.
- [termenv](https://github.com/muesli/termenv): A Go library for terminal
  feature detection and styling.
- [termion](https://crates.io/crates/termion): A Rust library for low-level
  bindless terminal manipulation.
- [termwiz](ttps://github.com/wez/wezterm/tree/main/termwiz): Another Rust
  library for building a terminal emulator.
- [vaxis](https://sr.ht/~rockorager/vaxis/): A Rust library for building
  terminal UIs.
