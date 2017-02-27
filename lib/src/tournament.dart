import 'dart:math';
import 'dart:async';

import 'player/player.dart';
import 'player/magician.dart';
import 'player/warrior.dart';
import 'player/peasant.dart';
import 'name.dart';

/// Status of tournament.
enum TournamentStatus {
  EMPTY,
  INPROGRESS,
  ENDED
}

class Tournament {

  /// List of players of the current tournament.
  List<Player> _playerList;

  /// Current round of the current tournament.
  int _round;

  /// Status of the current tournament.
  TournamentStatus status;

  static int tournamentCounter = 0;

  /// Attempt to start a tournament.
  void start ([int playerCount = 7]) {
    if (playerCount <= 0) {
      status = TournamentStatus.EMPTY;
    }

    switch (status) {
      case TournamentStatus.EMPTY:
        print("Tournament is empty.");
        break;

      case TournamentStatus.INPROGRESS:
        print("Tournament is running.");
        break;

      default:
        _init(playerCount);
        _loop();
    }
  }

  /// Initialize a tournament.
  void _init (int playerCount) {
    status = TournamentStatus.INPROGRESS;
    _round = 1;
    _playerList = <Player>[];
    tournamentCounter++;

    Name name = new Name();

    // Create an instance for each player in tournament.
    for (int i = 0; i < playerCount; i++) {
      Player player;

      switch (new Random().nextInt(6)) {
        case 0:
          player = new Magician(name.generate());
          break;

        case 1:
          player = new Warriror(name.generate());
          break;

        case 2:
          player = new Peasant(name.generate());
          break;

        default:
          player = new Player(name.generate());
      }

      _playerList.add(player);
    }

    print(generateScoreBoard(heading: "Tournament is starting with $playerCount players"));
  }

  /// Tournament's main game loop.
  void _loop () {
    // Keeps track of people who was alive at the start of the round.
    List<Player> playerList = <Player>[]
      ..addAll(_playerList.where((Player player) => (player.hp > 0)));

    if (playerList.length <= 1) {
      status = TournamentStatus.ENDED;

      print("""

==============
""");

      if (playerList.length == 1) {
        print("The winner of the tournament is ${_playerList.firstWhere((Player player) => (player.hp > 0))}\n");
      } else {
        print("No one survived, no one won.\n");
      }

      print(generateScoreBoard(compare: (Player a, Player b) => b.hp.compareTo(a.hp)));

      // Clear the player list.
      _playerList = <Player>[];

      return;
    }

    print("""

  --- Round $_round
  --- with ${playerList.length} players
""");

    _round++;

    for (Player player in playerList) {
      Player target;

      do {
        target = playerList.elementAt(new Random().nextInt(playerList.length));
      } while (player == target);

      player.attack(target);
    }

    new Future<dynamic>.delayed(const Duration(seconds: 1), _loop);
  }

  String toString () {
    return generateScoreBoard(compare: (Player a, Player b) => b.hp.compareTo(a.hp));
  }

  String generateScoreBoard ({int compare (Player a, Player b), String heading: "Score board"}) {
    String stat = "$heading:\n";

    if (compare != null) {
      _playerList.sort(compare);
    }

    for (Player player in _playerList) {
      stat += player.generateStats() + (_playerList.last != player ? "\n" : "");
    }

    return stat;
  }
}
