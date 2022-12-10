import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/controller/firebase_controller.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/player.dart';

class LobbyListScreen extends StatefulWidget {
  static const routeName = '/lobbyListScreen';
  final Player player;

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
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                const SizedBox(
                  width: 200,
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
                  width: 200,
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
                  width: 200,
                  child: Divider(
                    color: Colors.amber,
                    thickness: 1,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                controller.lobbies.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: controller.refresh,
                        child: ListView.separated(
                          itemCount: controller.lobbies.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.amber,
                              child: ListTile(
                                title: Text(controller.lobbies[index].name),
                                subtitle: Text(
                                    'Created by ${controller.lobbies[index].hostID}'),
                                onTap: () => controller.joinLobby(index),
                              ),
                            );
                          },
                          physics: const AlwaysScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.amber,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          const Text(
                            'No lobbies to join.',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: controller.refresh,
                            child: const Text("Refresh"),
                          ),
                        ],
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
  List<Lobby> lobbies = [];
  bool isLoading = false;
  String? lobbyName;

  _Controller(this.state) {
    print(FirebaseAuth.instance.currentUser!.uid);
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

  void createLobby() {}

  void joinLobby(int index) {}

  void showLoginError(String e) {}
}
