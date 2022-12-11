import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/model/answer.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/player.dart';
import 'package:twenty_twenty_questions/model/profile.dart';

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
  late _Controller controller;

  void render(fn) => setState(fn);

  @override
  void initState() {
    super.initState();
    controller = _Controller(this);
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
                child: controller.hasSubmittedAnswer()
                    ? Column(
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 36,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Tap',
                                  style: TextStyle(color: Colors.amber),
                                ),
                                TextSpan(text: ' to view player.'),
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
                                  onPressed: () {},
                                  child: Text(
                                    widget.lobby.players[i].username,
                                  ),
                                ),
                                const SizedBox(
                                  width: 200,
                                  child: Divider(
                                    color: Colors.amber,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      )
                    : Column(
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'Enter something for the other players to ',
                              style: TextStyle(
                                fontSize: 36,
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
                                        borderSide:
                                            BorderSide(color: Colors.amber),
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

  _Controller(this.state) {
    createListener();
  }

  void createListener() {
    final reference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    listener = reference.snapshots().listen((event) {
      var document = event.data() as Map<String, dynamic>;
      var l = Lobby.fromFirestoreDoc(doc: document, docID: event.id);
      if (l != null) state.widget.lobby.assign(l);
      state.render(() {});
    });
  }

  bool hasSubmittedAnswer() {
    bool submitted = false;
    for (int i = 0; i < state.widget.lobby.players.length; i++) {
      if (state.widget.lobby.players[i].answer.isNotEmpty) submitted = true;
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
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      List<dynamic> playerDocuments = snapshot.get(Lobby.PLAYERS);
      for (int i = 0, counterAppend = 1; i < playerDocuments.length; i++) {
        if (playerDocuments[i][Player.USERNAME] ==
            state.widget.profile.username) {
          playerDocuments[i][Player.ANSWER] = answer;
        }
      }
      Player player = Player(username: state.widget.profile.username);
      transaction.update(lobbyReference, {
        Lobby.PLAYERS: playerDocuments,
      });
    });
  }

  bool isPlayerTurn() {
    if (state.widget.lobby.questions.length <
        state.widget.lobby.players.length) {
      return false;
    }
    for (int i = 0; i < state.widget.lobby.players.length; i++) {
      if (state.widget.lobby.players[i].username ==
          state.widget.profile.username) {
        if (state.widget.lobby.turn % state.widget.lobby.players[i].turnOrder ==
            0) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  Future<bool> leave() async {
    /*listener.cancel();
    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      List<dynamic> playerDocuments = snapshot.get("players");
      for (int i = 0; i < playerDocuments.length; i++) {
        if (playerDocuments[i]['playerID'] == state.widget.profile.playerID) {
          playerDocuments.removeAt(i);
        }
      }
      transaction.update(lobbyReference, {"players": playerDocuments});
    });
    return true;*/
    return false;
  }
}
