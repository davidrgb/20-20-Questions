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
        body: Container(
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
              controller.lobbies.isNotEmpty
                  ? Expanded(
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
                        separatorBuilder: (context, index) => const Divider(
                          color: Colors.amber,
                        ),
                      ),
                    )
                  : const Text(
                      'No lobbies to display.',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
            ],
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

  void joinLobby(int index) {}

  void showLoginError(String e) {}
}
