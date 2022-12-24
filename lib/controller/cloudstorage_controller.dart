import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageController {
  static Future<void> uploadProfilePicture(
      {required Uint8List photo,
      String? filename,
      required String playerID,
      }) async {
    filename ??= '${Constants.profilePicturesFolder}/$playerID';
    UploadTask task = FirebaseStorage.instance.ref(filename).putData(photo);
    await task;
  }

  static Future<bool> profilePictureExists({required String playerID}) async {
    try {
      String url = await FirebaseStorage.instance
          .ref('${Constants.profilePicturesFolder}/$playerID')
          .getDownloadURL();
      return true;
    } catch (error) {
      return false;
    }
  }

  static Future<String> getPhotoURL({required String playerID}) async {
    return await FirebaseStorage.instance
        .ref('${Constants.profilePicturesFolder}/$playerID')
        .getDownloadURL();
  }

  static Future<File> getPhotoFile({required String filename}) async {
    var random = Random();
    String directory = (await getTemporaryDirectory()).path;
    File file = File('$directory${(random.nextInt(10)).toString()}.png');
    await FirebaseStorage.instance.ref(filename).writeToFile(file);
    return file;
  }
}
