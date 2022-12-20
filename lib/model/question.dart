import 'package:twenty_twenty_questions/model/response.dart';

enum DocKeyQuestion {
  questionID,
  question,
  askerUsername,
  guess,
  guessPlayerUsername,
  responses
}

class Question {
  static const QUESTION_ID = 'questionID';
  static const QUESTION = 'question';
  static const ASKER_USERNAME = 'askerUsername';
  static const GUESS = 'guess';
  static const GUESS_PLAYER_USERNAME = 'guessPlayerUsername';
  static const RESPONSES = 'responses';

  late int questionID;
  late String? question;
  late String askerUsername;
  late bool guess;
  late String? guessPlayerUsername;
  late List<Response> responses;

  Question({
    required this.questionID,
    this.question,
    required this.askerUsername,
    required this.guess,
    this.guessPlayerUsername,
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
      DocKeyQuestion.askerUsername.name: askerUsername,
      DocKeyQuestion.guess.name: guess,
      DocKeyQuestion.guessPlayerUsername.name: guessPlayerUsername,
      DocKeyQuestion.responses.name: responseDocuments,
    };
  }

  static Question? fromFirestoreDoc({
    required Map<String, dynamic> doc,
  }) {
    Question q = Question(
      questionID: doc[DocKeyQuestion.questionID.name] ?? 'N/A',
      question: doc[DocKeyQuestion.question.name] ?? 'N/A',
      askerUsername: doc[DocKeyQuestion.askerUsername.name] ?? 'N/A',
      guess: doc[DocKeyQuestion.guess.name] ?? false,
      guessPlayerUsername: doc[DocKeyQuestion.guessPlayerUsername.name] ?? 'N/A',
    );
    List<dynamic> responseDocuments = doc[DocKeyQuestion.responses.name];
    q.responses = q.getResponses(responseDocuments);
    return q;
  }
}
