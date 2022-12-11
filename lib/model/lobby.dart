import 'package:twenty_twenty_questions/model/answer.dart';
import 'package:twenty_twenty_questions/model/player.dart';
import 'package:twenty_twenty_questions/model/question.dart';

enum DocKeyLobby {
  name,
  hostID,
  playerIDs,
  players,
  open,
  round,
  turn,
  questions,
  answers,
}

class Lobby {
  static const NAME = 'name';
  static const HOST_ID = 'hostID';
  static const PLAYER_IDS = 'playerIDs';
  static const PLAYERS = 'players';
  static const OPEN = 'open';
  static const ROUND = 'round';
  static const TURN = 'turn';
  static const QUESTIONS = 'questions';
  static const ANSWERS = 'answers';

  String? docID;
  late String name;
  late String hostID;
  late List<String> playerIDs;
  late List<Player> players;
  late bool open;
  late int round;
  late int turn;
  late List<Question> questions;
  late List<Answer> answers;

  Lobby({
    this.docID,
    this.name = '',
    this.hostID = '',
    List<String>? playerIDs,
    List<Player>? players,
    this.open = true,
    this.round = 1,
    this.turn = 1,
    List<Question>? questions,
    List<Answer>? answers,
  }) {
    this.playerIDs = playerIDs == null ? [] : [...playerIDs];
    this.players = players == null ? [] : [...players];
    this.questions = questions == null ? [] : [...questions];
    this.answers = answers == null ? [] : [...answers];
  }

  Lobby.clone(Lobby l) {
    docID = l.docID;
    name = l.name;
    hostID = l.hostID;
    playerIDs = [...l.playerIDs];
    players = [...l.players];
    open = l.open;
    round = l.round;
    turn = l.turn;
    questions = [...l.questions];
    answers = [...l.answers];
  }

  void assign(Lobby l) {
    docID = l.docID;
    name = l.name;
    hostID = l.hostID;
    playerIDs = [...l.playerIDs];
    players = [...l.players];
    open = l.open;
    round = l.round;
    turn = l.turn;
    questions = [...l.questions];
    answers = [...l.answers];
  }

  List<Map<String, dynamic>> getPlayerDocumentList() {
    List<Map<String, dynamic>> playerDocuments = [];
    for (int i = 0; i < players.length; i++) {
      playerDocuments.add(players[i].toFirestoreDoc());
    }
    return playerDocuments;
  }

  List<Player> getPlayers(List<dynamic> playerDocuments) {
    List<Player> players = [];
    for (int i = 0; i < playerDocuments.length; i++) {
      Player? player = Player.fromFirestoreDoc(doc: playerDocuments[i]);
      if (player != null) players.add(player);
    }
    return players;
  }

  List<Map<String, dynamic>> getQuestionDocumentList() {
    List<Map<String, dynamic>> questionDocuments = [];
    for (int i = 0; i < questions.length; i++) {
      questionDocuments.add(questions[i].toFirestoreDoc());
    }
    return questionDocuments;
  }

  List<Question> getQuestions(List<dynamic> questionDocuments) {
    List<Question> questions = [];
    for (int i = 0; i < questionDocuments.length; i++) {
      Question? question = Question.fromFirestoreDoc(doc: questionDocuments[i]);
      if (question != null) questions.add(question);
    }
    return questions;
  }

  List<Map<String, dynamic>> getAnswerDocumentList() {
    List<Map<String, dynamic>> answerDocuments = [];
    for (int i = 0; i < answers.length; i++) {
      answerDocuments.add(answers[i].toFirestoreDoc());
    }
    return answerDocuments;
  }

  List<Answer> getAnswers(List<dynamic> answerDocuments) {
    List<Answer> answers = [];
    for (int i = 0; i < answerDocuments.length; i++) {
      Answer? answer = Answer.fromFirestoreDoc(doc: answerDocuments[i]);
      if (answer != null) answers.add(answer);
    }
    return answers;
  }

  Map<String, dynamic> toFirestoreDoc() {
    List<Map<String, dynamic>> playerDocuments = getPlayerDocumentList();
    List<Map<String, dynamic>> questionDocuments = getQuestionDocumentList();
    List<Map<String, dynamic>> answerDocuments = getAnswerDocumentList();
    return {
      DocKeyLobby.name.name: name,
      DocKeyLobby.hostID.name: hostID,
      DocKeyLobby.playerIDs.name: playerIDs,
      DocKeyLobby.players.name: playerDocuments,
      DocKeyLobby.open.name: open,
      DocKeyLobby.round.name: round,
      DocKeyLobby.turn.name: turn,
      DocKeyLobby.questions.name: questionDocuments,
      DocKeyLobby.answers.name: answerDocuments,
    };
  }

  static Lobby? fromFirestoreDoc({
    required Map<String, dynamic> doc,
    required String docID,
  }) {
    Lobby l = Lobby(
      docID: docID,
      name: doc[DocKeyLobby.name.name] ?? 'N/A',
      hostID: doc[DocKeyLobby.hostID.name] ?? 'N/A',
      playerIDs: [],
      players: [],
      open: doc[DocKeyLobby.open.name] ?? true,
      round: doc[DocKeyLobby.round.name] ?? -1,
      turn: doc[DocKeyLobby.turn.name] ?? -1,
      questions: [],
      answers: [],
    );
    List<dynamic> playerIDDocuments = doc[DocKeyLobby.playerIDs.name];
    for (int i = 0; i < playerIDDocuments.length; i++) {
      l.playerIDs.add(playerIDDocuments[i]);
    }
    List<dynamic> playerDocuments = doc[DocKeyLobby.players.name];
    l.players = l.getPlayers(playerDocuments);
    List<dynamic> questionDocuments = doc[DocKeyLobby.questions.name];
    l.questions = l.getQuestions(questionDocuments);
    List<dynamic> answerDocuments = doc[DocKeyLobby.answers.name];
    l.answers = l.getAnswers(answerDocuments);
    return l;
  }
}
