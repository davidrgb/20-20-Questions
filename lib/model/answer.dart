enum DocKeyAnswer {
  questionID,
  playerID,
  answer,
}

class Answer {
  static const QUESTION_ID = 'questionID';
  static const PLAYER_ID = 'playerID';
  static const ANSWER = 'answer';

  late String questionID;
  late String playerID;
  late String answer;

  Answer({
    required this.questionID,
    required this.playerID,
    required this.answer,
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyAnswer.questionID.name: questionID,
      DocKeyAnswer.playerID.name: playerID,
      DocKeyAnswer.answer.name: answer,
    };
  }

  static Answer? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return Answer(
      questionID: doc[DocKeyAnswer.questionID.name] ?? 'N/A',
      playerID: doc[DocKeyAnswer.playerID.name] ?? 'N/A',
      answer: doc[DocKeyAnswer.answer.name] ?? 'N/A',
    );
  }
}
