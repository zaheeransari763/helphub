import 'dart:io';
import 'package:helphub/core/enums/UserType.dart';
import 'package:path/path.dart' as p;
import 'package:firebase_storage/firebase_storage.dart';

import 'Services.dart';

class StorageServices extends Services {
  StorageServices() {
    getUser();
  }
  UploadTask uploadTask;
  Future<String> setProfilePhoto(String filePath) async {
    if (firebaseUser == null) await getUser();
    // String schoolCode = await sharedPreferencesHelper.getSchoolCode();

    String _extension = p.extension(filePath);
    String fileName = firebaseUser.uid + _extension;
    UserType userType = await sharedPreferencesHelper.getUserType();

    if (userType == UserType.STUDENT) {
      uploadTask = storageReference
          .child("Profile" + '/' + "Students" + '/' + fileName)
          .putFile(
            File(filePath),
            SettableMetadata(
              contentType: "image",
              customMetadata: {
                "uploadedBy": firebaseUser.uid,
                "uploaderEmail": firebaseUser.email,
              },
            ),
          );
    } else {
      String devId = await sharedPreferencesHelper.getDevelopersId();
      uploadTask = storageReference
          .child("Profile" + '/' + "Developers" + '/' + fileName)
          .putFile(
            File(filePath),
            SettableMetadata(
              contentType: "image",
              customMetadata: {
                "uploadedBy": firebaseUser.uid,
                "uploaderId": devId,
              },
            ),
          );
    }

    final TaskSnapshot downloadUrl = await uploadTask;
    final String profileUrl = await downloadUrl.ref.getDownloadURL();

    await sharedPreferencesHelper.setLoggedInUserPhotoUrl(profileUrl);

    return profileUrl;
  }

  Future<String> sendImage(
      {String path, String name, String sender, String reciever}) async {
    String _extension = p.extension(path);
    String filename = name + _extension;
    uploadTask = storageReference
        .child("Messages" + "/" + sender + " - " + reciever + "/" + filename)
        .putFile(
            File(path),
            SettableMetadata(contentType: "image", customMetadata: {
              "sender": sender,
              "reciever": reciever,
            }));
    final TaskSnapshot url = await uploadTask;
    final String imageUrl = await url.ref.getDownloadURL();

    return imageUrl;
  }
}
