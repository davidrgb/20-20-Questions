import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:twenty_twenty_questions/model/constant.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudStorageController {
  static Future<Map<ARGS, String>> uploadProfilePicture(
      {required File photo,
      String? filename,
      required String playerID,
      Function? listener}) async {
    filename ??= '${Constants.profilePicturesFolder}/$playerID';
    UploadTask task = FirebaseStorage.instance.ref(filename).putFile(photo);
    task.snapshotEvents.listen((TaskSnapshot event) {
      int progress = (event.bytesTransferred / event.totalBytes * 100).toInt();
      if (listener != null) {
        listener(progress);
      }
    });
    await task;
    String downloadURL =
        await FirebaseStorage.instance.ref(filename).getDownloadURL();
    return {
      ARGS.DownloadURL: downloadURL,
      ARGS.Filename: filename,
    };
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
