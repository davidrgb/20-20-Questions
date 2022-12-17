import 'package:twenty_twenty_questions/model/response.dart';

enum DocKeyQuestion {
  questionID,
  question,
  guess,
  guessPlayerID,
  responses
}

class Question {
  static const QUESTION_ID = 'questionID';
  static const QUESTION = 'question';
  static const GUESS = 'guess';
  static const GUESS_PLAYER_ID = 'guessPlayerID';
  static const RESPONSES = 'responses';

  late String questionID;
  late String question;
  late bool guess;
  late String? guessPlayerID;
  late List<Response> responses;

  Question({
    required this.questionID,
    required this.question,
    required this.guess,
    this.guessPlayerID,
    List<Response>? responses,
  }) {
    this.responses = responses == null ? [] : [...responses];
  }

  List<Map<String, dynamic>> getResponseDocuments() {
    List<Map<String, dynamic>> responseDocuments = [];
    for (int i = 0; i < responses.length; i++) {
      responseDocuments.add(responses[i].toFirestoreDoc());
    }
    return responseDocuments;
  }

  List<Response> getResponses(List<dynamic> responseDocuments) {
    List<Response> responses = [];
    for (int i = 0; i < responseDocuments.length; i++) {
      Response? response = Response.fromFirestoreDoc(doc: responseDocuments[i]);
      if (response != null) responses.add(response);
    }
    return responses;
  }

  Map<String, dynamic> toFirestoreDoc() {
    List<Map<String, dynamic>> responseDocuments = getResponseDocuments();
    return {
      DocKeyQuestion.questionID.name: questionID,
      DocKeyQuestion.question.name: question,
      DocKeyQuestion.guess.name: guess,
      DocKeyQuestion.guessPlayerID.name: guessPlayerID,
    };
  }

  static Question? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    Question q =  Question(
      questionID: doc[DocKeyQuestion.questionID.name] ?? 'N/A',
      question: doc[DocKeyQuestion.question.name] ?? 'N/A',
      guess: doc[DocKeyQuestion.guess.name] ?? false,
      guessPlayerID: doc[DocKeyQuestion.guessPlayerID.name] ?? 'N/A',
    );
    List<dynamic> responseDocuments = doc[DocKeyQuestion.responses.name];
    q.responses = q.getResponses(responseDocuments);
    return q;
  }
}
