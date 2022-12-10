enum DocKeyPlayer {
  playerID,
  score,
  turnOrder,
  answer,
}

class Player {
  static const PLAYER_ID = 'playerID';
  static const SCORE = 'score';
  static const TURN_ORDER = 'turnOrder';
  static const ANSWER = 'answer';

  late String playerID;
  late int score;
  late int turnOrder;
  late String answer;

  Player({
    required this.playerID,
    this.score = 0,
    this.turnOrder = -1,
    this.answer = '',
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyPlayer.playerID.name: playerID,
      DocKeyPlayer.score.name: score,
      DocKeyPlayer.turnOrder.name: turnOrder,
      DocKeyPlayer.answer.name: answer,
    };
  }

  static Player? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return Player(
      playerID: doc[DocKeyPlayer.playerID.name] ?? 'N/A',
      score: doc[DocKeyPlayer.score.name] ?? 0,
      turnOrder: doc[DocKeyPlayer.turnOrder.name] ?? -1,
      answer: doc[DocKeyPlayer.answer.name] ?? 'N/A',
    );
  }
}
