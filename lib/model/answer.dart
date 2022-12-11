enum DocKeyAnswer {
  questionID,
  username,
  answer,
}

class Answer {
  static const QUESTION_ID = 'questionID';
  static const USERNAME = 'username';
  static const ANSWER = 'answer';

  late String questionID;
  late String username;
  late String answer;

  Answer({
    required this.questionID,
    required this.username,
    required this.answer,
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyAnswer.questionID.name: questionID,
      DocKeyAnswer.username.name: username,
      DocKeyAnswer.answer.name: answer,
    };
  }

  static Answer? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return Answer(
      questionID: doc[DocKeyAnswer.questionID.name] ?? 'N/A',
      username: doc[DocKeyAnswer.username.name] ?? 'N/A',
      answer: doc[DocKeyAnswer.answer.name] ?? 'N/A',
    );
  }
}
