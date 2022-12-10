import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/player.dart';
import 'package:twenty_twenty_questions/view/guest_login_screen.dart';
import 'package:twenty_twenty_questions/view/player_login_screen.dart';

class LobbyScreen extends StatefulWidget {
  static const routeName = '/lobbyScreen';
  final Player player;
  final Lobby lobby;

  const LobbyScreen({
    Key? key,
    required this.player,
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
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(
            top: 100,
            bottom: 100,
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: controller.start,
                      child: const Text(
                        'Start',
                      ),
                    ),
                  ],
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
  late _LobbyScreenState state;
  _Controller(this.state);

  void start() async {}

  void leave() async {}
}
