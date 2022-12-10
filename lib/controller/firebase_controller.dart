import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:twenty_twenty_questions/model/lobby.dart';
import 'package:twenty_twenty_questions/model/profile.dart';

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

  static Future<void> createProfile({
    required String docID,
    required Profile profile,
  }) async {
    await FirebaseFirestore.instance
        .collection(Constants.profileCollection)
        .doc(docID)
        .set(profile.toFirestoreDoc());
  }

  static Future<Profile?> readProfile({
    required String docID,
  }) async {
    var reference = await FirebaseFirestore.instance
        .collection(Constants.profileCollection)
        .doc(docID)
        .get();
    if (reference.data() != null) {
      return Profile.fromFirestoreDoc(doc: reference.data()!, docID: docID);
    } else {
      return null;
    }
  }

  static Future<void> updateProfile(
      {required String docID, required Map<String, dynamic> updateInfo}) async {
    await FirebaseFirestore.instance
        .collection(Constants.profileCollection)
        .doc(docID)
        .update(updateInfo);
  }

  static Future<void> deleteProfile({required String docID}) async {
    var lobbyReference = await FirebaseFirestore.instance
        .collection(Constants.lobbyCollection)
        .doc(docID)
        .get();
    if (lobbyReference.exists) {
      await deleteLobby(docID: docID);
    }
    await FirebaseFirestore.instance
        .collection(Constants.profileCollection)
        .doc(docID)
        .delete();
  }
}
