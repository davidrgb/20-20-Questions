import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/controller/firebase_controller.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/player.dart';
import 'package:twenty_twenty_questions/view/lobby_list_screen.dart';

class PlayerLoginScreen extends StatefulWidget {
  static const routeName = '/playerLoginScreen';

  const PlayerLoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PlayerLoginScreenState();
}

class _PlayerLoginScreenState extends State<PlayerLoginScreen> {
  late _Controller controller;
  GlobalKey<FormState> loginKey = GlobalKey();

  void render(fn) => setState(fn);

  @override
  void initState() {
    super.initState();
    controller = _Controller(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                  "Login or create a new profile.",
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
                height: 100,
              ),
              Form(
                key: loginKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          hintText: "Username",
                        ),
                        style: const TextStyle(fontSize: 18),
                        validator: controller.validateUsername,
                        onSaved: controller.saveUsername,
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          hintText: "Password",
                        ),
                        obscureText: true,
                        style: const TextStyle(fontSize: 18),
                        validator: controller.validatePassword,
                        onSaved: controller.savePassword,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.login,
                      child: const Text('Login/Create'),
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
  late _PlayerLoginScreenState state;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? username;
  String? password;
  _Controller(this.state);

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username required';
    } else if (value.length > 20) {
      return 'Username must be 20 characters or less.';
    } else {
      return null;
    }
  }

  void saveUsername(String? value) {
    if (value != null) username = value;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password required.';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    } else {
      return null;
    }
  }

  void savePassword(String? value) {
    if (value != null) password = value;
  }

  void login() async {
    FormState? currentState = state.loginKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();

    String email = '$username@2020questions.com';
    Player? player;
    final methods = await auth.fetchSignInMethodsForEmail(email);
    if (methods.isEmpty) {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password!);
      player = Player(
        docID: auth.currentUser!.uid,
        playerID: username!,
        creationDate: DateTime.now(),
        answersGuessed: [],
        friends: [],
      );
      await FirestoreController.createPlayer(
          docID: auth.currentUser!.uid, player: player);
    } else {
      await auth.signInWithEmailAndPassword(email: email, password: password!);
      player =
          await FirestoreController.readPlayer(docID: auth.currentUser!.uid);
    }

    await Navigator.pushNamed(
      state.context,
      LobbyListScreen.routeName,
      arguments: {
        ARGS.PLAYER: player,
      },
    );
  }

  void showLoginError(String e) {}
}
