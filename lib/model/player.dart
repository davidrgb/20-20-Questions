enum DocKeyPlayer {
  username,
  score,
  turnOrder,
  answer,
}

class Player {
  static const USERNAME = 'username';
  static const SCORE = 'score';
  static const TURN_ORDER = 'turnOrder';
  static const ANSWER = 'answer';

  late String username;
  late int score;
  late int turnOrder;
  late String answer;

  Player({
    required this.username,
    this.score = 0,
    this.turnOrder = -1,
    this.answer = '',
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyPlayer.username.name: username,
      DocKeyPlayer.score.name: score,
      DocKeyPlayer.turnOrder.name: turnOrder,
      DocKeyPlayer.answer.name: answer,
    };
  }

  static Player? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return Player(
      username: doc[DocKeyPlayer.username.name] ?? 'N/A',
      score: doc[DocKeyPlayer.score.name] ?? 0,
      turnOrder: doc[DocKeyPlayer.turnOrder.name] ?? -1,
      answer: doc[DocKeyPlayer.answer.name] ?? 'N/A',
    );
  }
}
