enum DocKeyPlayer {
  username,
  score,
  turnOrder,
  answer,
  correctGuesses,
}

class Player {
  static const USERNAME = 'username';
  static const SCORE = 'score';
  static const TURN_ORDER = 'turnOrder';
  static const ANSWER = 'answer';
  static const CORRECT_GUESSES = 'correctGuesses';

  late String username;
  late int score;
  late int turnOrder;
  late String answer;
  late List<String> correctGuesses;

  Player({
    required this.username,
    this.score = 0,
    this.turnOrder = -1,
    this.answer = '',
    List<String>? correctGuesses,
  }) {
    this.correctGuesses = correctGuesses == null ? [] : [...correctGuesses];
  }

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyPlayer.username.name: username,
      DocKeyPlayer.score.name: score,
      DocKeyPlayer.turnOrder.name: turnOrder,
      DocKeyPlayer.answer.name: answer,
      DocKeyPlayer.correctGuesses.name: correctGuesses,
    };
  }

  static Player? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    Player p = Player(
      username: doc[DocKeyPlayer.username.name] ?? 'N/A',
      score: doc[DocKeyPlayer.score.name] ?? 0,
      turnOrder: doc[DocKeyPlayer.turnOrder.name] ?? -1,
      answer: doc[DocKeyPlayer.answer.name] ?? 'N/A',
      correctGuesses: [],
    );
    List<dynamic> correctGuessesDocuments = doc[DocKeyPlayer.correctGuesses.name];
    for (int i = 0; i < correctGuessesDocuments.length; i++) {
      p.correctGuesses.add(correctGuessesDocuments[i]);
    }
    return p;
  }
}
