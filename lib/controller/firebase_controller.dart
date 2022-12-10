import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/player.dart';

class FirestoreController {
  static Future<void> createLobby({
    required String docID,
    required Lobby lobby,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(docID)
        .set(lobby.toFirestoreDoc());
  }

  static Future<List<Lobby>> readLobbies() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .where(Lobby.OPEN, isEqualTo: true)
        .get();
    var result = <Lobby>[];

    querySnapshot.docs.forEach((doc) {
      if (doc.data() != null) {
        var document = doc.data() as Map<String, dynamic>;
        var l = Lobby.fromFirestoreDoc(doc: document, docID: doc.id);
        if (l != null) {
          result.add(l);
        }
      }
    });

    return result;
  }

  static Future<void> updateLobby(
      {required String docID, required Map<String, dynamic> updateInfo}) async {
    await FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(docID)
        .update(updateInfo);
  }

  static Future<void> deleteLobby({required String docID}) async {
    await FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(docID)
        .delete();
  }

  static Future<void> createPlayer({
    required String docID,
    required Player player,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constants.playerCollection)
        .doc(docID)
        .set(player.toFirestoreDoc());
  }

  static Future<Player?> readPlayer({
    required String docID,
  }) async {
    var reference = await FirebaseFirestore.instance
        .collection(Constants.playerCollection)
        .doc(docID)
        .get();
    if (reference.data() != null) {
      return Player.fromFirestoreDoc(doc: reference.data()!, docID: docID);
    } else {
      return null;
    }
  }

  static Future<void> updatePlayer(
      {required String docID, required Map<String, dynamic> updateInfo}) async {
    await FirebaseFirestore.instance
        .collection(Constants.playerCollection)
        .doc(docID)
        .update(updateInfo);
  }

  static Future<void> deletePlayer({required String docID}) async {
    var lobbyReference = await FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(docID)
        .get();
    if (lobbyReference.exists) {
      await deleteLobby(docID: docID);
    }
    await FirebaseFirestore.instance
        .collection(Constants.playerCollection)
        .doc(docID)
        .delete();
  }
}
