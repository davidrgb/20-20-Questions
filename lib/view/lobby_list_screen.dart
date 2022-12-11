import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twenty_twenty_questions/controller/firebase_controller.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/player.dart';
import 'package:twenty_twenty_questions/model/profile.dart';
import 'package:twenty_twenty_questions/view/home_screen.dart';
import 'package:twenty_twenty_questions/view/lobby_screen.dart';

class LobbyListScreen extends StatefulWidget {
  static const routeName = '/lobbyListScreen';
  final Profile profile;

  const LobbyListScreen({
    Key? key,
    required this.profile,
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 10,
          ),
          child: FloatingActionButton(
            onPressed: controller.logOut,
            backgroundColor: Colors.amber,
            child: const Icon(Icons.close),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 50,
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                SizedBox(
                  width: 250,
                  child: RichText(
                    text: TextSpan(
                      text: 'Join \nor create \na lobby,\n',
                      style: const TextStyle(
                        fontSize: 36,
                      ),
                      children: [
                        TextSpan(
                          text: widget.profile.username,
                          style: const TextStyle(color: Colors.amber),
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
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 250,
                  child: Form(
                    key: lobbyNameKey,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 200,
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
                const SizedBox(
                  height: 20,
                ),
                controller.lobbies.isNotEmpty
                    ? SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            for (int i = 0; i < controller.lobbies.length; i++)
                              Column(
                                children: [
                                  Container(
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
                                        controller.lobbies[i].name,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Created by ${controller.lobbies[i].hostID}',
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                      onTap: () => controller.joinLobby(i),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      )
                    : SizedBox(
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
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> listener;

  _Controller(this.state) {
    createListener();
  }

  void createListener() {
    final reference =
        FirebaseFirestore.instance.collection(Constants.lobbyCollection);
    listener = reference.snapshots().listen((event) {
      lobbies.clear();
      for (var doc in event.docs) {
        var document = doc.data() as Map<String, dynamic>;
        var l = Lobby.fromFirestoreDoc(doc: document, docID: doc.id);
        if (l != null && l.open == true) lobbies.add(l);
      }
      state.render(() {});
    });
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
    listener.cancel();
    FormState? currentState = state.lobbyNameKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    currentState.save();

    Player player = Player(username: state.widget.profile.username);

    Lobby lobby = Lobby(
      docID: auth.currentUser!.uid,
      name: lobbyName!,
      hostID: state.widget.profile.username,
      playerIDs: [state.widget.profile.playerID],
      players: [player],
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
        ARGS.PROFILE: state.widget.profile,
        ARGS.LOBBY: lobby,
      },
    ).then((data) {
      createListener();
    });
  }

  void joinLobby(int index) async {
    listener.cancel();
    Profile joinProfile = Profile.clone(state.widget.profile);
    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(lobbies[index].docID);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      List<dynamic> playerIDs = snapshot.get(Lobby.PLAYER_IDS);
      playerIDs.add(joinProfile.playerID);
      List<dynamic> playerDocuments = snapshot.get(Lobby.PLAYERS);
      for (int i = 0, counterAppend = 1; i < playerDocuments.length; i++) {
        if (playerDocuments[i][Player.USERNAME] == joinProfile.username) {
          counterAppend++;
          if (counterAppend == 2) {
            joinProfile.username = '${joinProfile.username}_$counterAppend';
          } else {
            joinProfile.username =
                '${joinProfile.username.substring(0, joinProfile.username.length - 1)}_$counterAppend';
          }
          i = 0;
        }
      }
      Player player = Player(username: state.widget.profile.username);
      playerDocuments.add(player.toFirestoreDoc());
      transaction.update(lobbyReference, {
        Lobby.PLAYER_IDS: playerIDs,
        Lobby.PLAYERS: playerDocuments,
      });
    });
    await Navigator.pushNamed(
      state.context,
      LobbyScreen.routeName,
      arguments: {
        ARGS.PROFILE: joinProfile,
        ARGS.LOBBY: lobbies[index],
      },
    ).then((data) {
      createListener();
    });
  }

  void logOut() async {
    auth.signOut();
    await Navigator.pushNamed(
      state.context,
      HomeScreen.routeName,
    );
  }
}
