import 'package:twenty_twenty_questions/model/player.dart';

enum DocKeyLobby {
  name,
  hostID,
  players,
  open,
  round,
  turn,
  questions,
  answers,
}

class Lobby {
  static const NAME = 'name';
  static const HOST_ID = 'hostID';
  static const PLAYERS = 'players';
  static const OPEN = 'open';
  static const ROUND = 'round';
  static const TURN = 'turn';
  static const QUESTIONS = 'questions';
  static const ANSWERS = 'answers';

  String? docID;
  late String name;
  late String hostID;
  late List<Player> players;
  late bool open;
  late int round;
  late int turn;
  late List<dynamic> questions;
  late List<dynamic> answers;

  Lobby({
    this.docID,
    this.name = '',
    this.hostID = '',
    List<dynamic>? players,
    this.open = true,
    this.round = 1,
    this.turn = 1,
    List<dynamic>? questions,
    List<dynamic>? answers,
  }) {
    this.players = players == null ? [] : [...players];
    this.questions = questions == null ? [] : [...questions];
    this.answers = answers == null ? [] : [...answers];
  }

  Lobby.clone(Lobby l) {
    docID = l.docID;
    name = l.name;
    hostID = l.hostID;
    players = [...l.players];
    open = l.open;
    round = l.round;
    turn = l.turn;
    questions = [...l.questions];
    answers = [...l.answers];
  }

  void assign(Lobby l) {
    docID = l.docID;
    name = l.name;
    hostID = l.hostID;
    players = [...l.players];
    open = l.open;
    round = l.round;
    turn = l.turn;
    questions = [...l.questions];
    answers = [...l.answers];
  }

    List<Map<String, dynamic>> getPlayerDocumentList() {
    List<Map<String, dynamic>> playerDocuments = [];
    for (int i = 0; i < players.length; i++) {
      playerDocuments.add(players[i].toFirestoreDoc());
    }
    return playerDocuments;
  }

  Map<String, dynamic> toFirestoreDoc() {
    List<Map<String, dynamic>> playerDocuments = getPlayerDocumentList();
    return {
      DocKeyLobby.name.name: name,
      DocKeyLobby.hostID.name: hostID,
      DocKeyLobby.players.name: playerDocuments,
      DocKeyLobby.open.name: open,
      DocKeyLobby.round.name: round,
      DocKeyLobby.turn.name: turn,
      DocKeyLobby.questions.name: questions,
      DocKeyLobby.answers.name: answers,
    };
  }

  static Lobby? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docID,
  }) {
    List<Player> players = [];
    Lobby l = Lobby(
      docID: docID,
      name: doc[DocKeyLobby.name.name] ?? 'N/A',
      hostID: doc[DocKeyLobby.hostID.name] ?? 'N/A',
      players: [],
      open: doc[DocKeyLobby.open.name] ?? true,
      round: doc[DocKeyLobby.round.name] ?? -1,
      turn: doc[DocKeyLobby.turn.name] ?? -1,
      questions: doc[DocKeyLobby.questions.name] ?? [],
      answers: doc[DocKeyLobby.answers.name] ?? [],
    );
    List<dynamic> playerDocuments = doc[DocKeyLobby.players.name];
    for (int i = 0; i < playerDocuments.length; i++) {
      Player? player = Player.fromFirestoreDoc(doc: playerDocuments[i]);
      if (player != null) players.add(player);
    }
    l.players = players;
    print(l);
    return l;
  }
}
