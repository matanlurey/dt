/// Provides backend implementations for interacting with terminal APIs.
///
/// It defines the [SurfaceBackend] interface, which is a low-level interface
/// for drawing cells to a terminal-like surface, with a default implementation,
/// [SurfaceBackend.fromStdout], that writes to a [io.Stdout] stream.
///
/// For building custom backends, or terminal emulators, [AnsiSurfaceBackend]
/// uses ANSI escape sequences to interact with the terminal, and helper types
/// such as [Sequence], [EscapeSequence], [Command] and utility extension such
/// as [AnsiEscapedStyle] are provided.
library;

import 'dart:io' as io;

import 'backend.dart';

export 'src/backend/ansi_escaped_color.dart'
    show AnsiEscapedColor, AnsiEscapedColor16;
export 'src/backend/ansi_escaped_style.dart' show AnsiEscapedStyle;
export 'src/backend/ansi_surface_backend.dart' show AnsiSurfaceBackend;
export 'src/backend/buffered_keys.dart' show BufferedKeys;
export 'src/backend/command.dart'
    show
        AlternateScreenBuffer,
        ClearScreen,
        Command,
        MoveCursorTo,
        MoveCursorToColumn,
        SetBackgroundColor256,
        SetColor16,
        SetCursorVisibility,
        SetForegroundColor256,
        SynchronizedUpdate,
        resetStyle;
export 'src/backend/sequence.dart' show EscapeSequence, Literal, Sequence;
export 'src/backend/surface_backend.dart' show SurfaceBackend;
export 'src/backend/test_surface_backend.dart' show TestSurfaceBackend;
