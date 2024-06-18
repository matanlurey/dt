import 'dart:async';
import 'dart:io' as io;

import 'package:dt/layout.dart';
import 'package:dt/rendering.dart';
import 'package:dt/terminal.dart';
import 'package:dt/widgets.dart';

void main() async {
  final terminal = Surface.fromStdio();
  final keyboard = Keyboard.fromStdin();
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
      onExit: completer.future,
    );
  } finally {
    terminal.close();
    await (keyboard.close(), sigint.cancel()).wait;
  }
}

Future<void> run(
  Surface terminal,
  Keyboard keyboard, {
  Future<void>? onExit,
  Future<void> Function() wait = _wait16ms,
}) async {
  var running = true;
  unawaited(
    onExit?.whenComplete(() {
      running = false;
    }),
  );
  while (running) {
    if (keyboard.isPressed(AsciiControlKey.escape)) {
      break;
    }
    await terminal.draw((frame) {
      frame.draw((buffer) {
        _Window().draw(buffer);
      });
    });
    await wait();
  }
}

const _fps60 = Duration(milliseconds: 1000 ~/ 60);
Future<void> _wait16ms() => Future.delayed(_fps60);

final class _Window extends Widget {
  const _Window();

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
            ['Black Jack'],
            style: Style(foreground: Color16.blue, background: Color16.red),
          ),
        ),
        _Game(
          dealer: [
            const Card(Rank.ace, Suit.clubs),
            const Card(Rank.two, Suit.clubs),
          ],
          player: [
            const Card(Rank.three, Suit.clubs),
            const Card(Rank.four, Suit.clubs),
          ],
        ),
        Text.fromLine(
          Line(
            ['Press ESC to exit.'],
            style: Style(background: Color16.white, foreground: Color16.black),
          ),
        ),
      ],
    ).draw(buffer);
  }
}

final class _Game extends Widget {
  const _Game({
    required this.dealer,
    required this.player,
  });

  final List<Card> dealer;
  final List<Card> player;

  @override
  void draw(Buffer buffer) {
    Layout(
      Constrained.horizontal([
        Constraint.fixed(1),
        Constraint.flex(1),
        Constraint.fixed(1),
        Constraint.flex(1),
      ]),
      [
        Text('Dealer:'),
        _RenderCards(dealer),
        Text('Player:'),
        _RenderCards(player),
      ],
    ).draw(buffer);
  }
}

final class _RenderCards extends Widget {
  _RenderCards(this.cards);
  final List<Card> cards;

  @override
  void draw(Buffer buffer) {
    Layout(
      Constrained.vertical(cards.map((_) => Constraint.fixed(4)).toList()),
      cards,
    ).draw(buffer);
  }
}

enum Suit {
  clubs,
  diamonds,
  hearts,
  spades,
}

enum Rank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

final class Card extends Widget {
  const Card(this.rank, this.suit);
  final Rank rank;
  final Suit suit;

  @override
  void draw(Buffer buffer) {
    final rank = _rankToString(this.rank);
    final suit = _suitToString(this.suit);
    buffer.print(0, 0, '$suit $rank');
  }

  String _rankToString(Rank rank) {
    switch (rank) {
      case Rank.ace:
        return 'A';
      case Rank.two:
        return '2';
      case Rank.three:
        return '3';
      case Rank.four:
        return '4';
      case Rank.five:
        return '5';
      case Rank.six:
        return '6';
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.ten:
        return '10';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
    }
  }

  String _suitToString(Suit suit) {
    switch (suit) {
      case Suit.clubs:
        return '♣';
      case Suit.diamonds:
        return '♦';
      case Suit.hearts:
        return '♥';
      case Suit.spades:
        return '♠';
    }
  }
}
