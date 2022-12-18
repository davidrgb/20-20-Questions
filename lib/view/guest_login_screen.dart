import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/controller/firebase_controller.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/profile.dart';
import 'package:twenty_twenty_questions/view/lobby_list_screen.dart';

class GuestLoginScreen extends StatefulWidget {
  static const routeName = '/guestLoginScreen';

  const GuestLoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _GuestLoginScreenState();
}

class _GuestLoginScreenState extends State<GuestLoginScreen> {
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
                  "Play as a guest.",
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
                height: 200,
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.login,
                      child: const Text('Guest Login'),
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

AlertDialog _profileWithUsernameExistsAlert(
    BuildContext context, String username) {
  return AlertDialog(
    title: RichText(
      text: TextSpan(
        text: 'The username ',
        style: const TextStyle(fontSize: 24),
        children: [
          TextSpan(
            text: username,
            style: const TextStyle(color: Colors.amber),
          ),
          const TextSpan(text: ' is used by a profile.'),
        ],
      ),
    ),
    content: const Text('Please choose a different username.'),
  );
}

class _Controller {
  late _GuestLoginScreenState state;
  FirebaseAuth auth = FirebaseAuth.instance;

  String? username;
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

  void login() async {
    FormState? currentState = state.loginKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();

    await auth.signInAnonymously();
    Profile? profile = Profile(
      playerID: auth.currentUser!.uid,
      username: username!,
      friends: [],
    );

    if (await FirestoreController.checkIfProfileExists(
        username: profile.username)) {
      showDialog(
        context: state.context,
        builder: (BuildContext context) {
          return _profileWithUsernameExistsAlert(context, profile.username);
        },
      );
      await auth.signOut();
      return;
    }

    await Navigator.pushNamed(
      state.context,
      LobbyListScreen.routeName,
      arguments: {
        ARGS.PROFILE: profile,
      },
    );
  }
}
