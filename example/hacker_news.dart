// ignore_for_file: cast_nullable_to_non_nullable

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';
import 'package:dt/terminal.dart';
import 'package:dt/widgets.dart';

void main() async {
  final terminal = Surface.fromStdio();
  final keyboard = Keyboard.fromStdin();
  final apiClient = HackerNews();

  final completer = Completer<void>();
  final sigint = io.ProcessSignal.sigint.watch().listen((_) {
    if (!completer.isCompleted) {
      completer.complete();
    }
  });
  try {
    await run(
      terminal,
      keyboard,
      apiClient,
      count: io.stdout.terminalLines - 2,
      onExit: completer.future,
    );
  } finally {
    terminal.close();
    await (keyboard.close(), apiClient.close(), sigint.cancel()).wait;
  }
}

/// An API client for Hacker News.
final class HackerNews {
  static final _defaultBaseUrl = Uri.https(
    'hacker-news.firebaseio.com',
    'v0',
  );

  static final _utf8JsonDecoder = const Utf8Decoder().fuse(const JsonDecoder());

  /// Creates a new client for the Hacker News API.
  ///
  /// The [baseUrl] defaults to `https://hacker-news.firebaseio.com/v0`.
  HackerNews({
    io.HttpClient? client,
    Uri? baseUrl,
    Converter<List<int>, Object?>? decoder,
  })  : _client = client ?? io.HttpClient(),
        _baseUrl = baseUrl ?? _defaultBaseUrl,
        _decoder = decoder ?? _utf8JsonDecoder;

  final io.HttpClient _client;
  final Uri _baseUrl;
  final Converter<List<int>, Object?> _decoder;

  /// Closes the client.
  Future<void> close() async {
    _client.close();
  }

  Future<T> _getJson<T>(String path) async {
    final url = _baseUrl.replace(
      pathSegments: [
        ..._baseUrl.pathSegments,
        path,
      ],
    );
    final request = await _client.getUrl(url);
    final response = await request.close();
    if (response.statusCode != 200) {
      throw io.HttpException(
        'Failed to fetch $path: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
    final bytes = await response.expand((chunk) => chunk).toList();
    return _decoder.convert(bytes) as T;
  }

  /// Gets the top stories.
  ///
  /// The stream will emit a list of stories until all stories have been loaded.
  Stream<List<Story>> topStories({int count = 15}) async* {
    // Get a list of IDs for the top stories.
    final ids = (await _getJson<List<Object?>>('topstories.json')).cast<int>();

    // Load the stories.
    final stories = ids.take(count).map<Story>(LoadingStory.new).toList();

    // Yield the initial list of stories.
    yield stories;

    // Load the details for each story in parallel.
    final futures = stories.map((story) async {
      final id = story.id;
      final details = await _getJson<Map<String, Object?>>('item/$id.json');
      return LoadedStory(
        id,
        details['title'] as String,
        Uri.parse(details['url'] as String),
      );
    });

    // Yield the loaded stories as they become available.
    for (final future in futures) {
      final story = await future;
      final index = stories.indexWhere((s) => s.id == story.id);
      stories[index] = story;
      yield stories;
    }

    // Yield the final list of stories.
    yield stories;
  }
}

/// A story on Hacker News.
sealed class Story {
  const Story(this.id);

  /// Unique ID of the story.
  final int id;
}

/// A story that is still loading.
final class LoadingStory extends Story {
  /// Creates a new loading story with the given [id].
  const LoadingStory(super.id);
}

/// A story that has loaded.
final class LoadedStory extends Story {
  /// Creates a new loaded story with the given [id], [title], and [url].
  const LoadedStory(super.id, this.title, this.url);

  /// Title of the story.
  final String title;

  /// URL of the story.
  final Uri url;
}

Future<void> run(
  Surface terminal,
  Keyboard keyboard,
  HackerNews apiClient, {
  required int count,
  Future<void>? onExit,
  Future<void> Function() wait = _wait16ms,
}) async {
  var stories = <Story>[];

  // Get the top stories.
  final sub = apiClient.topStories(count: count).listen((newStories) {
    stories = newStories;
  });

  var running = true;
  var selected = 0;
  unawaited(
    onExit?.whenComplete(() {
      running = false;
    }),
  );

  while (running) {
    // Handle input.
    if (keyboard.isPressed(AsciiPrintableKey.q) ||
        keyboard.isPressed(AsciiControlKey.escape)) {
      break;
    } else if (keyboard.isPressed(AsciiPrintableKey.s)) {
      selected = (selected + 1) % stories.length;
    } else if (keyboard.isPressed(AsciiPrintableKey.w)) {
      selected = (selected - 1) % stories.length;
    } else if (keyboard.isPressed(AsciiControlKey.enter)) {
      final story = stories[selected];
      if (story is LoadedStory) {
        io.Process.runSync('open', [story.url.toString()]);
      }
    }

    // Clear input.
    keyboard.clear();

    // Render.
    await terminal.draw((frame) {
      frame.draw((buffer) {
        _Window(stories, selected: selected).draw(buffer);
      });
    });

    // Delay.
    await wait();
  }

  await sub.cancel();
}

const _fps60 = Duration(milliseconds: 1000 ~/ 60);
Future<void> _wait16ms() => Future.delayed(_fps60);

final class _Window extends Widget {
  const _Window(this.stories, {this.selected = -1});
  final List<Story> stories;
  final int selected;

  @override
  void draw(Buffer buffer) {
    Layout(
      Constrained.horizontal([
        Constraint.fixed(1),
        Constraint.flex(1),
        Constraint.fixed(1),
      ]),
      [
        Text.fromLine(
          Line(
            ['Hacker News'],
            style: Style(
              background: Color16.white,
              foreground: Color16.black,
            ),
          ),
        ),
        _StoryList(stories, selected: selected),
        Text.fromLine(
          Line(
            ['HELP - Q: Quit | S: Down | W: Up | Enter: Open'],
            style: Style(
              background: Color16.white,
              foreground: Color16.black,
            ),
          ),
        ),
      ],
    ).draw(buffer);
  }
}

final class _StoryList extends Widget {
  const _StoryList(this.stories, {required this.selected});
  final List<Story> stories;
  final int selected;

  @override
  void draw(Buffer buffer) {
    if (stories.isEmpty) {
      return;
    }
    Layout(
      const FixedHeightRows(),
      stories.indexed.map((entry) {
        final (i, story) = entry;
        final style = i == selected
            ? Style(
                background: Color16.blue,
                foreground: Color16.white,
              )
            : Style.reset;
        return switch (story) {
          LoadingStory _ => Text.fromLine(
              Line(
                ['Loading #${story.id}'],
                style: style,
              ),
            ),
          LoadedStory _ => Text.fromLine(
              Line(
                ['${story.id}: ${story.title}'],
                style: style,
              ),
            ),
        };
      }).toList(),
    ).draw(buffer);
  }
}
