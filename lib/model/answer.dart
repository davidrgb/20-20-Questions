enum DocKeyAnswer {
  username,
  answer,
}

class Answer {
  static const USERNAME = 'username';
  static const ANSWER = 'answer';

  late String username;
  late String answer;

  Answer({
    required this.username,
    required this.answer,
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyAnswer.username.name: username,
      DocKeyAnswer.answer.name: answer,
    };
  }

  static Answer? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return Answer(
      username: doc[DocKeyAnswer.username.name] ?? 'N/A',
      answer: doc[DocKeyAnswer.answer.name] ?? 'N/A',
    );
  }
}
