import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/model/answer.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/player.dart';
import 'package:twenty_twenty_questions/model/profile.dart';
import 'package:twenty_twenty_questions/model/question.dart';
import 'package:twenty_twenty_questions/model/response.dart';

class GameScreen extends StatefulWidget {
  static const routeName = '/gameScreen';
  final Profile profile;
  final Lobby lobby;

  const GameScreen({
    Key? key,
    required this.profile,
    required this.lobby,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GlobalKey<FormState> answerKey = GlobalKey();
  GlobalKey<FormState> questionKey = GlobalKey();
  late _Controller controller;

  void render(fn) => setState(fn);

  @override
  void initState() {
    super.initState();
    controller = _Controller(this);
  }

  Container showAnswerPhase() {
    if (!controller.hasSubmittedAnswer()) {
      return Container(child: showSubmitAnswer());
    } else {
      return Container(child: showWaitingForOtherPlayers());
    }
  }

  Column showSubmitAnswer() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            text: 'Enter something for the other players to ',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'guess',
                style: TextStyle(color: Colors.amber),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 300,
          child: Divider(
            color: Colors.amber,
            thickness: 1,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Form(
          key: controller.state.answerKey,
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: TextFormField(
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                    hintText: "Type here",
                  ),
                  style: const TextStyle(fontSize: 18),
                  validator: controller.validateAnswer,
                  onSaved: controller.saveAnswer,
                ),
              ),
              IconButton(
                onPressed: controller.submitAnswer,
                icon: const Icon(Icons.check),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container showQuestionPhase() {
    if (!controller.hasAskedQuestion()) {
      if (controller.isPlayerTurn()) {
        return Container(
          child: showSubmitQuestion(),
        );
      } else {
        return Container(
          child: showWaitingForOtherPlayers(),
        );
      }
    } else {
      if (controller.isPlayerTurn()) {
        return Container(child: showWaitingForOtherPlayers());
      } else {
        if (!controller.hasResponded()) {
          if (controller.isGuess()) {
            if (controller.isBeingGuessed()) {
              return Container(child: showSubmitResponse());
            } else {
              return Container(child: showWaitingForOtherPlayers());
            }
          } else {
            return Container(child: showSubmitResponse());
          }
        } else {
          return Container(child: showWaitingForOtherPlayers());
        }
      }
    }
  }

  Column showSubmitQuestion() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            text: 'Enter a ',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'question',
                style: TextStyle(color: Colors.amber),
              ),
              TextSpan(text: ' for the other players to answer.'),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Form(
          key: controller.state.questionKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 50,
                child: Center(
                  child: Text(
                    '${controller.questionsAsked(widget.profile.username) + 1}',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextFormField(
                  decoration: const InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                    hintText: "Type here",
                  ),
                  style: const TextStyle(fontSize: 18),
                  validator: controller.validateQuestion,
                  onSaved: controller.saveQuestion,
                ),
              ),
              IconButton(
                onPressed: controller.askQuestion,
                icon: const Icon(Icons.check),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        controller.guessPlayerUsername == null
            ? ElevatedButton(
                onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _pickPlayerToGuessAlert(context);
                    },
                  ),
                },
                child: const Text('Make A Guess'),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Guessing ',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: controller.guessPlayerUsername,
                          style: const TextStyle(
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: controller.cancelGuess,
                    icon: const Icon(Icons.cancel),
                  ),
                ],
              ),
        const SizedBox(
          height: 20,
        ),
        showPlayerButtonColumn(),
      ],
    );
  }

  AlertDialog _pickPlayerToGuessAlert(BuildContext context) {
    return AlertDialog(
      title: RichText(
        text: const TextSpan(
          text: 'Pick a ',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: 'player',
              style: TextStyle(color: Colors.amber),
            ),
            TextSpan(
              text: ' to guess.',
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < widget.lobby.players.length; i++)
              if (widget.lobby.players[i].username == widget.profile.username)
                for (int j = 0; j < widget.lobby.players.length; j++)
                  if (!widget.lobby.players[i].correctGuesses
                          .contains(widget.lobby.players[j].username) &&
                      i != j)
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.selectPlayerForGuess(j),
                          child: Text(widget.lobby.players[j].username),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
          ],
        ),
      ),
    );
  }

  Column showSubmitResponse() {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
            children: [
              const TextSpan(
                text: 'Question',
                style: TextStyle(color: Colors.amber),
              ),
              TextSpan(
                  text:
                      ' - ${widget.lobby.questions[widget.lobby.questions.length - 1].question}'),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        RichText(
          text: TextSpan(
            text: 'Your ',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
            children: [
              const TextSpan(
                text: 'Answer',
                style: TextStyle(color: Colors.amber),
              ),
              TextSpan(
                  text:
                      ' - ${controller.getPlayerAnswer()}'),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => controller.submitResponse('no'),
              icon: const Icon(
                Icons.cancel,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () => controller.submitResponse('unsure'),
              icon: const Icon(
                Icons.question_mark,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () => controller.submitResponse('yes'),
              icon: const Icon(
                Icons.check,
                color: Colors.green,
                size: 40,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  AlertDialog _anotherPlayerIsGuessing(BuildContext context) {
    return AlertDialog(
      title: RichText(
        text: TextSpan(
          text:
              '${widget.lobby.questions[widget.lobby.questions.length - 1].askerUsername} is ',
          style: const TextStyle(
            fontSize: 24,
          ),
          children: const [
            TextSpan(
              text: 'guessing',
              style: TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ),
    );
  }

  Column showWaitingForOtherPlayers() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'Waiting',
                style: TextStyle(color: Colors.amber),
              ),
              TextSpan(text: ' for other players...'),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        showPlayerButtonColumn(),
      ],
    );
  }

  Column showPlayerButtonColumn() {
    return Column(
      children: [
        widget.lobby.questions.isEmpty
            ? RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(
                      text: 'Tap',
                      style: TextStyle(color: Colors.amber),
                    ),
                    TextSpan(text: ' to view player.'),
                  ],
                ),
              )
            : RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Question',
                      style: TextStyle(color: Colors.amber),
                    ),
                    widget.lobby.questions[widget.lobby.questions.length - 1]
                                .guess &&
                            widget
                                    .lobby
                                    .questions[
                                        widget.lobby.questions.length - 1]
                                    .askerUsername !=
                                widget.profile.username &&
                            widget
                                    .lobby
                                    .questions[
                                        widget.lobby.questions.length - 1]
                                    .guessPlayerUsername !=
                                widget.profile.username
                        ? const TextSpan(text: ' - ???')
                        : TextSpan(
                            text:
                                ' - ${widget.lobby.questions[widget.lobby.questions.length - 1].question}'),
                  ],
                ),
              ),
        const SizedBox(
          width: 300,
          child: Divider(
            color: Colors.amber,
            thickness: 2,
          ),
        ),
        const SizedBox(height: 20),
        for (int i = 0; i < widget.lobby.players.length; i++)
          Column(
            children: [
              ElevatedButton(
                onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return _playerDetails(context, i);
                    },
                  )
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: controller.getPlayerButtonColor(i)),
                child: Text(
                  widget.lobby.players[i].username,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
      ],
    );
  }

  AlertDialog _playerDetails(BuildContext context, int index) {
    return AlertDialog(
      title: RichText(
        text: TextSpan(
          text: 'Answers from ',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: widget.lobby.players[index].username,
              style: const TextStyle(color: Colors.amber),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: controller.getPlayerDetails(index).isEmpty
                  ? [
                      const Text('Nothing to see right now.'),
                      const SizedBox(
                        height: 20,
                      ),
                    ]
                  : controller.getPlayerDetails(index),
            ),
            Center(
              child: Text(
                'Score - ${widget.lobby.players[index].score}',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column showScoreboard() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            text: 'Game ',
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
            ),
            children: [
              TextSpan(
                text: 'Over',
                style: TextStyle(color: Colors.amber),
              ),
            ],
          ),
        ),
        const SizedBox(
          width: 300,
          child: Divider(
            color: Colors.amber,
            thickness: 2,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        for (int i = 0; i < widget.lobby.players.length; i++)
          Column(
            children: [
              RichText(
                text: TextSpan(
                    text: widget.lobby.players[i].username,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.amber,
                    ),
                    children: [
                      TextSpan(
                        text: ' - ${widget.lobby.players[i].score}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ]),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: controller.leave,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.lobby.name),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(
              top: 25,
              bottom: 25,
            ),
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  children: [
                    if (!controller.allAnswersSubmitted())
                      showAnswerPhase()
                    else if (!controller.usedAllQuestions() &&
                        !controller.allPlayersGuessedAllCorrectly())
                      showQuestionPhase()
                    else
                      showScoreboard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Controller {
  late _GameScreenState state;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> listener;
  String? answer;
  String? question;
  String? guessPlayerUsername;

  _Controller(this.state) {}

  void createListener() {
    final reference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    listener = reference.snapshots().listen((event) {
      var document = event.data() as Map<String, dynamic>;
      var l = Lobby.fromFirestoreDoc(doc: document, docID: event.id);
      if (l != null) state.widget.lobby.assign(l);
      if (allPlayersGuessedAllCorrectly()) listener.cancel();
      state.render(() {});
    });
  }

  bool hasSubmittedAnswer() {
    bool submitted = false;
    for (int i = 0; i < state.widget.lobby.players.length; i++) {
      if (state.widget.lobby.players[i].username ==
          state.widget.profile.username) {
        if (state.widget.lobby.players[i].answer.isNotEmpty) submitted = true;
      }
    }
    return submitted;
  }

  String? validateAnswer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Answer required.';
    } else {
      return null;
    }
  }

  void saveAnswer(String? value) {
    if (value != null) answer = value;
  }

  void submitAnswer() async {
    FormState? currentState = state.answerKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();

    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      List<dynamic> playerDocuments = snapshot.get(Lobby.PLAYERS);
      for (int i = 0; i < playerDocuments.length; i++) {
        if (playerDocuments[i][Player.USERNAME] ==
            state.widget.profile.username) {
          playerDocuments[i][Player.ANSWER] = answer;
        }
      }
      transaction.update(lobbyReference, {
        Lobby.PLAYERS: playerDocuments,
      });
    });
    createListener();
  }

  bool allAnswersSubmitted() {
    for (int i = 0; i < state.widget.lobby.players.length; i++) {
      if (state.widget.lobby.players[i].answer.isEmpty) {
        return false;
      }
    }
    return true;
  }

  bool isPlayerTurn() {
    for (int i = 0; i < state.widget.lobby.players.length; i++) {
      if (state.widget.lobby.players[i].username ==
          state.widget.profile.username) {
        if ((state.widget.lobby.turn - 1) % state.widget.lobby.players.length ==
            state.widget.lobby.players[i].turnOrder - 1) {
          if (guessedAllCorrectly()) {
            skipQuestion();
            return false;
          }
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  bool guessedAllCorrectly() {
    for (int i = 0; i < state.widget.lobby.players.length; i++) {
      if (state.widget.lobby.players[i].username ==
          state.widget.profile.username) {
        Player player = state.widget.lobby.players[i];
        if (player.correctGuesses.length <
            state.widget.lobby.players.length - 1) {
          return false;
        }
        for (int j = 0; j < state.widget.lobby.players.length; j++) {
          if (j == i) {
            continue;
          }
          bool guessedCorrectly = false;
          for (int k = 0; k < player.correctGuesses.length; k++) {
            if (player.correctGuesses[k] ==
                state.widget.lobby.players[j].username) {
              guessedCorrectly = true;
            }
          }
          if (!guessedCorrectly) {
            return false;
          }
        }
      }
    }
    return true;
  }

  bool playerGuessedAllCorrectly(int index) {
    Player player = state.widget.lobby.players[index];
    if (player.correctGuesses.length < state.widget.lobby.players.length - 1) {
      return false;
    }
    for (int j = 0; j < state.widget.lobby.players.length; j++) {
      if (j == index) {
        continue;
      }
      bool guessedCorrectly = false;
      for (int k = 0; k < player.correctGuesses.length; k++) {
        if (player.correctGuesses[k] ==
            state.widget.lobby.players[j].username) {
          guessedCorrectly = true;
        }
      }
      if (!guessedCorrectly) {
        return false;
      }
    }
    return true;
  }

  bool allPlayersGuessedAllCorrectly() {
    for (int i = 0; i < state.widget.lobby.players.length; i++) {
      bool hasGuessed = playerGuessedAllCorrectly(i);
      if (!hasGuessed) {
        return false;
      }
    }
    state.widget.lobby.players.sort((b, a) => a.score.compareTo(b.score));
    return true;
  }

  Future<void> skipQuestion() async {
    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      int turn = snapshot.get(Lobby.TURN);
      turn++;
      transaction.update(lobbyReference, {
        Lobby.TURN: turn,
      });
    });
  }

  Future<void> skipToNextPlayer() async {
    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      int turn = snapshot.get(Lobby.TURN);
      List<dynamic> playerDocuments = snapshot.get(Lobby.PLAYERS);
      turn++;
      while (true) {
        if (playerGuessedAllCorrectly(turn % playerDocuments.length)) {
          turn++;
        } else {
          break;
        }
      }
      transaction.update(lobbyReference, {
        Lobby.TURN: turn,
      });
    });
  }

  bool hasAskedQuestion() {
    if (state.widget.lobby.questions.isEmpty || allPlayersResponded()) {
      return false;
    }
    return true;
  }

  String? validateQuestion(String? value) {
    if (value == null || value.isEmpty) {
      return 'Question required.';
    } else {
      return null;
    }
  }

  void saveQuestion(String? value) {
    if (value != null) question = value;
  }

  void selectPlayerForGuess(int index) {
    guessPlayerUsername = state.widget.lobby.players[index].username;
    Navigator.pop(state.context);
    state.render(() {});
  }

  void cancelGuess() {
    guessPlayerUsername = null;
    state.render(() {});
  }

  void askQuestion() async {
    FormState? currentState = state.questionKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();

    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      List<dynamic> questionDocuments = snapshot.get(Lobby.QUESTIONS);
      int turn = snapshot.get(Lobby.TURN);
      Question questionToAsk = Question(
        questionID: turn,
        question: question,
        askerUsername: state.widget.profile.username,
        guess: guessPlayerUsername != null,
        guessPlayerUsername: guessPlayerUsername,
      );
      questionDocuments.add(questionToAsk.toFirestoreDoc());
      transaction.update(lobbyReference, {
        Lobby.QUESTIONS: questionDocuments,
      });
    });
  }

  bool hasResponded() {
    for (int i = 0;
        i <
            state
                .widget
                .lobby
                .questions[state.widget.lobby.questions.length - 1]
                .responses
                .length;
        i++) {
      if (state.widget.lobby.questions[state.widget.lobby.questions.length - 1]
              .responses[i].responsePlayerUsername ==
          state.widget.profile.username) return true;
    }
    return false;
  }

  bool isGuess() {
    return state
        .widget.lobby.questions[state.widget.lobby.questions.length - 1].guess;
  }

  bool isBeingGuessed() {
    if (state.widget.lobby.questions[state.widget.lobby.questions.length - 1]
            .guessPlayerUsername ==
        state.widget.profile.username) {
      return true;
    } else {
      return false;
    }
  }

  void submitResponse(String response) async {
    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      List<dynamic> questionDocuments = snapshot.get(Lobby.QUESTIONS);
      Question? question = Question.fromFirestoreDoc(
          doc: questionDocuments[questionDocuments.length - 1]);
      if (question == null) return;
      Response r = Response(
          responsePlayerUsername: state.widget.profile.username,
          response: response);
      question.responses.add(r);
      questionDocuments[questionDocuments.length - 1] =
          question.toFirestoreDoc();
      if (isFinalResponse()) {
        int turn = snapshot.get(Lobby.TURN);
        turn++;
        List<dynamic> playerDocuments = snapshot.get(Lobby.PLAYERS);
        while (!allPlayersGuessedAllCorrectly()) {
          if (playerGuessedAllCorrectly(turn % playerDocuments.length)) {
            turn++;
          } else {
            break;
          }
        }
        transaction.update(lobbyReference, {
          Lobby.QUESTIONS: questionDocuments,
          Lobby.TURN: turn,
        });
      } else {
        transaction.update(lobbyReference, {
          Lobby.QUESTIONS: questionDocuments,
        });
      }
      if (question.guess && response == 'yes') {
        List<dynamic> playerDocuments = snapshot.get(Lobby.PLAYERS);
        for (int i = 0; i < playerDocuments.length; i++) {
          Player? p = Player.fromFirestoreDoc(doc: playerDocuments[i]);
          if (p != null && p.username == question.askerUsername) {
            p.score += 20 - questionsAsked(p.username) + 1;
            p.correctGuesses.add(state.widget.profile.username);
            playerDocuments[i] = p.toFirestoreDoc();
          }
        }
        transaction.update(lobbyReference, {
          Lobby.PLAYERS: playerDocuments,
        });
      }
    });
  }

  bool isFinalResponse() {
    if (state.widget.lobby.questions[state.widget.lobby.questions.length - 1]
                .responses.length ==
            state.widget.lobby.players.length - 2 ||
        state.widget.lobby.questions[state.widget.lobby.questions.length - 1]
            .guess) {
      return true;
    } else {
      return false;
    }
  }

  bool allPlayersResponded() {
    if (state.widget.lobby.questions[state.widget.lobby.questions.length - 1]
            .responses.length <
        state.widget.lobby.players.length - 1) {
      return false;
    } else {
      return true;
    }
  }

  bool showResponseDialog() {
    return allAnswersSubmitted() &&
        !usedAllQuestions() &&
        !allPlayersGuessedAllCorrectly() &&
        !hasAskedQuestion() &&
        state.widget.lobby.turn > 1;
  }

  int questionsAsked(String username) {
    int questionsAsked = 0;
    for (int i = 0; i < state.widget.lobby.questions.length; i++) {
      if (state.widget.lobby.questions[i].askerUsername == username) {
        questionsAsked++;
      }
    }
    return questionsAsked;
  }

  bool usedAllQuestions() {
    int questionsUsed = 0;
    for (int i = 0; i < state.widget.lobby.questions.length; i++) {
      if (state.widget.lobby.questions[i].askerUsername ==
          state.widget.lobby.players[state.widget.lobby.players.length - 1]
              .username) questionsUsed++;
    }
    if (questionsUsed < 20) {
      return false;
    }
    if (questionsUsed == 20 && !allPlayersResponded()) return false;
    state.widget.lobby.players.sort((b, a) => a.score.compareTo(b.score));
    return true;
  }

  Color getPlayerButtonColor(int index) {
    Player player = state.widget.lobby.players[index];
    if (state.widget.lobby.questions.isEmpty) return Colors.amber;
    Question question =
        state.widget.lobby.questions[state.widget.lobby.questions.length - 1];
    if (question.askerUsername == player.username) return Colors.amber;
    for (int i = 0; i < question.responses.length; i++) {
      if (question.responses[i].responsePlayerUsername == player.username) {
        if (question.responses[i].response == 'yes') {
          return Colors.green;
        } else if (question.responses[i].response == 'no') {
          return Colors.red;
        } else {
          return Colors.white;
        }
      }
    }
    return Colors.amber;
  }

  List<Column> getPlayerDetails(int index) {
    List<Column> buttons = [];
    Player player = state.widget.lobby.players[index];
    for (int i = 0; i < state.widget.lobby.questions.length; i++) {
      Question question = state.widget.lobby.questions[i];
      for (int j = 0; j < question.responses.length; j++) {
        Response response = question.responses[j];
        if (response.responsePlayerUsername == player.username) {
          buttons.add(
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: response.response == 'yes'
                        ? Colors.green
                        : response.response == 'no'
                            ? Colors.red
                            : Colors.white,
                  ),
                  child: Text(question.question!),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        }
      }
    }
    return buttons;
  }

  String getPlayerAnswer() {
    for (int i = 0; i < state.widget.lobby.players.length; i++) {
      if (state.widget.lobby.players[i].username == state.widget.profile.username) {
        return state.widget.lobby.players[i].answer;
      }
    }
    return '';
  }

  Future<bool> leave() async {
    if (!allPlayersGuessedAllCorrectly()) {
      listener.cancel();
    }
    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      List<dynamic> playerDocuments = snapshot.get(Lobby.PLAYERS);
      for (int i = playerDocuments.length - 1; i >= 0; i--) {
        Player? player = Player.fromFirestoreDoc(doc: playerDocuments[i]);
        if (player != null &&
            player.username == state.widget.profile.username) {
          playerDocuments.removeAt(i);
        }
      }
      for (int i = 0; i < playerDocuments.length; i++) {
        Player? player = Player.fromFirestoreDoc(doc: playerDocuments[i]);
        if (player != null) {
          player.turnOrder = i + 1;
          playerDocuments[i] = player.toFirestoreDoc();
        }
      }
      transaction.update(lobbyReference, {Lobby.PLAYERS: playerDocuments});
    });
    return true;
  }
}
