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
  late List<dynamic> players;
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

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyLobby.name.name: name,
      DocKeyLobby.hostID.name: hostID,
      DocKeyLobby.players.name: players,
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
    return Lobby(
      docID: docID,
      name: doc[DocKeyLobby.name.name] ?? 'N/A',
      hostID: doc[DocKeyLobby.hostID.name] ?? 'N/A',
      players: doc[DocKeyLobby.players.name] ?? [],
      open: doc[DocKeyLobby.open.name] ?? true,
      round: doc[DocKeyLobby.round.name] ?? -1,
      turn: doc[DocKeyLobby.turn.name] ?? -1,
      questions: doc[DocKeyLobby.questions.name] ?? [],
      answers: doc[DocKeyLobby.answers.name] ?? [],
    );
  }
}
