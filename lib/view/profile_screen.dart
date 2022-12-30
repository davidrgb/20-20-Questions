import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twenty_twenty_questions/controller/firebase_controller.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/profile.dart';
import 'package:twenty_twenty_questions/view/lobby_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profileScreen';
  final Profile profile;
  final Image? photo;

  const ProfileScreen({
    Key? key,
    required this.profile,
    this.photo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late _Controller controller;
  GlobalKey<FormState> usernameKey = GlobalKey();

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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  width: 200,
                  child: Text(
                    "Your profile.",
                    style: TextStyle(
                      fontSize: 36,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (widget.photo != null)
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 75,
                        backgroundImage: widget.photo!.image,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
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
                Form(
                  key: usernameKey,
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
                          initialValue: widget.profile.username,
                          style: const TextStyle(fontSize: 18),
                          validator: controller.validateUsername,
                          onSaved: controller.saveUsername,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: controller.updateProfile,
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 350,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Creation Date',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              DateFormat.yMd()
                                  .add_jm()
                                  .format(widget.profile.creationDate!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Lifetime Score',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              widget.profile.lifetimeScore.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Answers Guessed ',
                                      style: TextStyle(
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              for (int i = 0;
                                  i < widget.profile.answersGuessed.length;
                                  i++)
                                Row(
                                  children: [
                                    if (i > 1)
                                      RichText(
                                        text: const TextSpan(
                                          text: ', ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    RichText(
                                      text: TextSpan(
                                        text: widget.profile.answersGuessed[i],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Wins',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              widget.profile.wins.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Games Played',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              widget.profile.gamesPlayed.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
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
  late _ProfileScreenState state;
  FirebaseAuth auth = FirebaseAuth.instance;
  String? username;
  String? password;
  _Controller(this.state);

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username required';
    } else if (value.length > 20) {
      return 'Username must be 20 characters or less.';
    } else if (value.contains(' ')) {
      return 'Username cannot contain spaces.';
    } else if (value.contains('.')) {
      return 'Username cannot contain dots.';
    } else if (value.contains('@')) {
      return 'Username cannot contain @.';
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

  void updateProfile() async {
    FormState? currentState = state.usernameKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();

    String email = '$username@2020questions.com';
    FirebaseAuth.instance.currentUser!.updateEmail(email);
    await FirestoreController.updateProfile(
        docID: state.widget.profile.playerID,
        updateInfo: {
          Profile.USERNAME: username,
        });
  }
}
