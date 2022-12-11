import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/player.dart';
import 'package:twenty_twenty_questions/model/profile.dart';
import 'package:twenty_twenty_questions/view/game_screen.dart';

class LobbyScreen extends StatefulWidget {
  static const routeName = '/lobbyScreen';
  final Profile profile;
  final Lobby lobby;

  const LobbyScreen({
    Key? key,
    required this.profile,
    required this.lobby,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
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
              bottom: 50,
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  width: 250,
                  child: RichText(
                    text: const TextSpan(
                      text: 'Press ',
                      style: TextStyle(
                        fontSize: 36,
                      ),
                      children: [
                        TextSpan(
                          text: 'Start',
                          style: TextStyle(color: Colors.amber),
                        ),
                        TextSpan(text: ' when all players have joined.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          widget.lobby.players[i].username,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(
                        width: 200,
                        child: Divider(
                          color: Colors.amber,
                          thickness: 1,
                        ),
                      )
                    ],
                  ),
                const SizedBox(
                  height: 20,
                ),
                widget.lobby.hostID == widget.profile.username
                    ? ElevatedButton(
                        onPressed: controller.start,
                        child: const Text(
                          'Start',
                        ),
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
  late _LobbyScreenState state;
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> listener;

  _Controller(this.state) {
    createListener();
  }

  void createListener() async {
    final reference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    listener = reference.snapshots().listen((event) async {
      var document = event.data() as Map<String, dynamic>;
      var l = Lobby.fromFirestoreDoc(doc: document, docID: event.id);
      if (l != null) state.widget.lobby.assign(l);
      if (state.widget.lobby.open == false) {
        await Navigator.pushNamed(
          state.context,
          GameScreen.routeName,
          arguments: {
            ARGS.PROFILE: state.widget.profile,
            ARGS.LOBBY: state.widget.lobby,
          },
        );
        listener.cancel();
      }
      state.render(() {});
    });
  }

  void start() async {
    if (state.widget.lobby.players.length < 2) {
      return;
    }
    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      transaction.update(lobbyReference, {Lobby.OPEN: false});
    });
  }

  Future<bool> leave() async {
    listener.cancel();
    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(state.widget.lobby.docID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      List<dynamic> playerIDs = snapshot.get(Lobby.PLAYER_IDS);
      for (int i = 0; i < playerIDs.length; i++) {
        if (playerIDs[i] == state.widget.profile.playerID) {
          playerIDs.removeAt(i);
        }
      }
      List<dynamic> playerDocuments = snapshot.get(Lobby.PLAYERS);
      for (int i = 0; i < playerDocuments.length; i++) {
        if (playerDocuments[i][Player.USERNAME] ==
            state.widget.profile.username) {
          playerDocuments.removeAt(i);
        }
      }
      transaction.update(lobbyReference, {
        Lobby.PLAYER_IDS: playerIDs,
        Lobby.PLAYERS: playerDocuments,
      });
    });
    return true;
  }
}
