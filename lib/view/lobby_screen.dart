import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/controller/firebase_controller.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/profile.dart';

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
                const SizedBox(
                  width: 200,
                  child: Text(
                    "Press Start when all players have joined.",
                    style: TextStyle(
                      fontSize: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const SizedBox(
                  width: 250,
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
                          widget.lobby.players[i].playerID,
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
                ElevatedButton(
                  onPressed: controller.start,
                  child: const Text(
                    'Start',
                  ),
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
  _Controller(this.state);

  void start() async {}

  Future<bool> leave() async {
    for (int i = 0; i < state.widget.lobby.players.length; i++) {
      if (state.widget.lobby.players[i].playerID == state.widget.profile.playerID) state.widget.lobby.players.removeAt(i);
    }
    List<Map<String, dynamic>> playerDocuments = state.widget.lobby.getPlayerDocumentList();
    Map<String, dynamic> updateInfo = {};
    updateInfo[Lobby.PLAYERS] = playerDocuments;
    await FirestoreController.updateLobby(docID: state.widget.lobby.docID!, updateInfo: updateInfo);
    return true;
  }
}
