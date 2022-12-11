import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
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
            child: Column(
              children: [
                widget.lobby.questions.length < widget.lobby.players.length
                    ? Column(
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'Enter something for others to ',
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
                        ],
                      )
                    : const SizedBox(
                        height: 0,
                      ),
                controller.isPlayerTurn()
                    ? Column(
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'Ask a ',
                              style: TextStyle(
                                fontSize: 36,
                              ),
                              children: [
                                TextSpan(
                                  text: 'question',
                                  style: TextStyle(color: Colors.amber),
                                ),
                                TextSpan(
                                  text: ' for the other players',
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(
                        height: 0,
                      ),
              ],
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

  bool isPlayerTurn() {
    if (state.widget.lobby.questions.length < state.widget.lobby.players.length) return false;
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

  void start() async {}

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
