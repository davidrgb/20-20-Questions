enum DocKeyQuestion {
  questionID,
  question,
}

class Question {
  static const QUESTION_ID = 'questionID';
  static const QUESTION = 'question';

  late String questionID;
  late String question;

  Question({
    required this.questionID,
    required this.question,
  });

  Map<String, dynamic> toFirestoreDoc() {
    return {
      DocKeyQuestion.questionID.name: questionID,
      DocKeyQuestion.question.name: question,
    };
  }

  static Question? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    return Question(
      questionID: doc[DocKeyQuestion.questionID.name] ?? 'N/A',
      question: doc[DocKeyQuestion.question.name] ?? 'N/A',
    );
  }
}
