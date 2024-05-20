# Dart Terminal

A _fun_ and _minimalist_ experiment in crafting terminal UIs with Dart.

Inspiration:

- <https://github.com/crossterm-rs/crossterm>
- <https://github.com/muesli/termenv>
- <https://github.com/wez/wezterm/tree/main/termwiz>
- <https://sr.ht/~rockorager/vaxis/>
- <https://github.com/timsneath/dart_console>

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
