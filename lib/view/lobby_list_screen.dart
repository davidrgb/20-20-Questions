import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/controller/firebase_controller.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/profile.dart';
import 'package:twenty_twenty_questions/view/lobby_screen.dart';

class LobbyListScreen extends StatefulWidget {
  static const routeName = '/lobbyListScreen';
  final Profile player;

  const LobbyListScreen({
    Key? key,
    required this.player,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LobbyListScreenState();
}

class _LobbyListScreenState extends State<LobbyListScreen> {
  GlobalKey<FormState> lobbyNameKey = GlobalKey();
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
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 50,
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const SizedBox(
                  width: 250,
                  child: Text(
                    "Join \nor create \na lobby.",
                    style: TextStyle(
                      fontSize: 36,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
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
                SizedBox(
                  width: 200,
                  child: Form(
                    key: lobbyNameKey,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.amber),
                              ),
                              hintText: "Create a lobby",
                            ),
                            style: const TextStyle(fontSize: 18),
                            validator: controller.validateLobbyName,
                            onSaved: controller.saveLobbyName,
                          ),
                        ),
                        IconButton(
                          onPressed: controller.createLobby,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  width: 300,
                  child: Divider(
                    color: Colors.amber,
                    thickness: 1,
                  ),
                ),
                controller.lobbies.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: SizedBox(
                          width: 300,
                          child: ListView.separated(
                            itemCount: controller.lobbies.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5),
                                    bottomLeft: Radius.circular(5),
                                    bottomRight: Radius.circular(5),
                                  ),
                                  color: Colors.amber,
                                ),
                                child: ListTile(
                                  title: Text(
                                    controller.lobbies[index].name,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Created by ${controller.lobbies[index].hostID}',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                  onTap: () => controller.joinLobby(index),
                                ),
                              );
                            },
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            separatorBuilder: (context, index) => const Divider(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: SizedBox(
                          width: 300,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            shrinkWrap: true,
                            children: const [
                              Center(
                                child: Text(
                                  'No lobbies to join.',
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
  late _LobbyListScreenState state;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Lobby> lobbies = [];
  bool isLoading = false;
  String? lobbyName;

  _Controller(this.state) {
    refresh();
  }

  Future<void> refresh() async {
    state.render(() {
      isLoading = true;
    });
    try {
      lobbies = await FirestoreController.readLobbies();
      state.render(() {
        isLoading = false;
      });
    } catch (e) {
      state.render(() {
        isLoading = false;
      });
      print(e);
    }
  }

  String? validateLobbyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lobby name required.';
    } else {
      return null;
    }
  }

  void saveLobbyName(String? value) {
    if (value != null) lobbyName = value;
  }

  void createLobby() async {
    FormState? currentState = state.lobbyNameKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();

    Lobby lobby = Lobby(
      docID: auth.currentUser!.uid,
      name: lobbyName!,
      hostID: state.widget.player.playerID,
      players: [state.widget.player.playerID],
      questions: [],
      answers: [],
    );
    await FirestoreController.createLobby(
        docID: auth.currentUser!.uid, lobby: lobby);
    currentState.reset();

    await Navigator.pushNamed(
      state.context,
      LobbyScreen.routeName,
      arguments: {
        ARGS.PLAYER: state.widget.player,
        ARGS.LOBBY: lobby,
      },
    );
  }

  void joinLobby(int index) async {
    Lobby lobby = lobbies[index];
    for (int i = 0, counterAppend = 1; i < lobby.players.length; i++) {
      if (lobby.players[i] == state.widget.player.playerID) {
        counterAppend++;
        if (counterAppend == 2) {
          state.widget.player.playerID =
              '${state.widget.player.playerID}$counterAppend';
        } else {
          state.widget.player.playerID =
              '${state.widget.player.playerID.substring(0, state.widget.player.playerID.length - 1)}_$counterAppend';
        }
        i = 0;
      }
    }

    lobby.players.add(state.widget.player.playerID);
    Map<String, dynamic> updateInfo = {};
    updateInfo[Lobby.PLAYERS] = lobby.players;
    await FirestoreController.updateLobby(
        docID: lobby.docID!, updateInfo: updateInfo);
    await Navigator.pushNamed(
      state.context,
      LobbyScreen.routeName,
      arguments: {
        ARGS.PLAYER: state.widget.player,
        ARGS.LOBBY: lobby,
      },
    );
  }
}
