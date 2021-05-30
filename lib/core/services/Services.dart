import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:helphub/core/enums/UserType.dart';
import 'package:helphub/core/helpers/shared_preferences_helper.dart';

import '../../locator.dart';

class Services {
  SharedPreferencesHelper _sharedPreferencesHelper =
      locator<SharedPreferencesHelper>();
  static String country =
      'India'; //Get this from firstScreen(UI Not developed yet)
  static FirebaseAuth _auth = FirebaseAuth.instance;

  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User firebaseUser;

  String schoolCode;

  final Reference _storageReference = FirebaseStorage.instance.ref();

  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;

  DocumentReference getProfileReference(docId, UserType userType) {
    DocumentReference profileReference;
    DocumentReference ref = firestore.collection('users').doc('Profile');
    switch (userType) {
      case UserType.DEVELOPERS:
        return profileReference = ref.collection('Developers').doc(docId);
        break;
      case UserType.STUDENT:
        return profileReference = ref.collection('Students').doc(docId);
        break;
      default:
        profileReference = ref.collection('Students').doc(docId);
    }
    return profileReference;
  }

  Reference get storageReference => _storageReference;

  SharedPreferencesHelper get sharedPreferencesHelper =>
      _sharedPreferencesHelper;

  getUser() {
    firebaseUser =  _auth.currentUser;
  }
}
