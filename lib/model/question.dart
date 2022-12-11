enum DocKeyQuestion {
  questionID,
  question,
  guess,
}

class Question {
  static const QUESTION_ID = 'questionID';
  static const QUESTION = 'question';
  static const GUESS = 'guess';

  late String questionID;
  late String question;
  late bool guess;

  Question({
    required this.questionID,
    required this.question,
    required this.guess,
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyQuestion.questionID.name: questionID,
      DocKeyQuestion.question.name: question,
      DocKeyQuestion.guess.name: guess,
    };
  }

  static Question? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return Question(
      questionID: doc[DocKeyQuestion.questionID.name] ?? 'N/A',
      question: doc[DocKeyQuestion.question.name] ?? 'N/A',
      guess: doc[DocKeyQuestion.guess.name] ?? false,
    );
  }
}
