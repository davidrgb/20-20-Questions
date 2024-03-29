import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twenty_twenty_questions/controller/cloudstorage_controller.dart';
import 'package:twenty_twenty_questions/controller/firebase_controller.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/player.dart';
import 'package:twenty_twenty_questions/model/profile.dart';
import 'package:twenty_twenty_questions/view/home_screen.dart';
import 'package:twenty_twenty_questions/view/lobby_screen.dart';
import 'package:twenty_twenty_questions/view/profile_screen.dart';

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
                  width: 275,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 175,
                        child: RichText(
                          text: TextSpan(
                            text: 'Join \nor create \na lobby,\n',
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
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
                      controller.networkPhoto == null
                          ? GestureDetector(
                              onLongPress: controller.openProfile,
                              child: IconButton(
                                padding: const EdgeInsets.all(0),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                ),
                                onPressed: controller.getPhoto,
                              ),
                            )
                          : GestureDetector(
                              onTap: controller.getPhoto,
                              onLongPress: controller.openProfile,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: controller.networkPhoto!.image,
                              ),
                            ),
                    ],
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

AlertDialog _duplicateUsernameAlert(BuildContext context, String username) {
  return AlertDialog(
    title: RichText(
      text: TextSpan(
        text: username,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.amber,
        ),
        children: const [
          TextSpan(
            text: ' has already joined the lobby.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
    content: const Text('Please change your username to join.'),
  );
}

class _Controller {
  late _LobbyListScreenState state;
  FirebaseAuth auth = FirebaseAuth.instance;
  List<Lobby> lobbies = [];
  bool isLoading = false;
  String? lobbyName;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> listener;
  File? photo;
  Image? networkPhoto;

  _Controller(this.state) {
    loadPhoto();
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

  Future<void> loadPhoto() async {
    bool profilePictureExists =
        await CloudStorageController.profilePictureExists(
            playerID: state.widget.profile.playerID);
    if (profilePictureExists) {
      String url = await CloudStorageController.getPhotoURL(
          playerID: state.widget.profile.playerID);
      networkPhoto = Image.network(url);
      state.render(() {});
    }
  }

  Future<void> getPhoto() async {
    XFile? selectedPhoto =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (selectedPhoto == null) return;
    String path = selectedPhoto.path;
    Uint8List imageData = await XFile(path).readAsBytes();
    await CloudStorageController.uploadProfilePicture(
        photo: imageData, playerID: state.widget.profile.playerID);
    await loadPhoto();
  }

  void openProfile() async {
    if (await FirestoreController.checkIfGuest(
        playerID: state.widget.profile.playerID)) {
      return;
    }
    await listener.cancel();
    await Navigator.pushNamed(
      state.context,
      ProfileScreen.routeName,
      arguments: {
        ARGS.PROFILE: state.widget.profile,
        ARGS.PHOTO: networkPhoto,
      },
    ).then((data) {
      createListener();
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

    Player player = Player(
      playerID: state.widget.profile.playerID,
      username: state.widget.profile.username,
    );

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
    final lobbyReference = FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(lobbies[index].docID);
    bool duplicateUsername = false;
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(lobbyReference);
      List<dynamic> playerIDs = snapshot.get(Lobby.PLAYER_IDS);
      playerIDs.add(state.widget.profile.playerID);
      List<dynamic> playerDocuments = snapshot.get(Lobby.PLAYERS);
      for (int i = 0; i < playerDocuments.length; i++) {
        if (playerDocuments[i][Player.USERNAME] ==
            state.widget.profile.username) {
          showDialog(
            context: state.context,
            builder: (BuildContext context) {
              return _duplicateUsernameAlert(
                  context, state.widget.profile.username);
            },
          );
          duplicateUsername = true;
          return;
        }
      }
      Player player = Player(
        playerID: state.widget.profile.playerID,
        username: state.widget.profile.username,
      );
      playerDocuments.add(player.toFirestoreDoc());
      transaction.update(lobbyReference, {
        Lobby.PLAYER_IDS: playerIDs,
        Lobby.PLAYERS: playerDocuments,
      });
    });
    if (duplicateUsername) {
      createListener();
    } else {
      await Navigator.pushNamed(
        state.context,
        LobbyScreen.routeName,
        arguments: {
          ARGS.PROFILE: state.widget.profile,
          ARGS.LOBBY: lobbies[index],
        },
      ).then((data) {
        createListener();
      });
    }
  }

  void logOut() async {
    listener.cancel();
    auth.signOut();
    await Navigator.pushNamed(
      state.context,
      HomeScreen.routeName,
    );
  }
}
