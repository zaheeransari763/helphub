import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helphub/imports.dart';

class Developer {
  String photoUrl;
  String email;
  String id;
  String firebaseUid;
  String language;
  String currentProject;
  String currentlyworkingWith;
  String displayName;
  String city;
  String country;
  String qualification;
  String experience;
  DocumentReference documentReference;
  Color color;
  LinearGradient gradient;

  Developer(
      {this.photoUrl = 'default',
      this.email = '',
      this.id = '',
      this.firebaseUid = '',
      this.displayName = '',
      this.language = '',
      this.currentlyworkingWith = 'none',
      this.city = '',
      this.country = '',
      this.qualification = '',
      this.currentProject = '',
      this.experience = ''});

  bool isEmpty() {
    if (this.displayName == '' || this.displayName == null) return true;
    if (this.firebaseUid == '' || this.firebaseUid == null) return true;
    if (this.id == '' || this.id == null) return true;
    return false;
  }

  Developer.fromSnapshot(DocumentSnapshot documentSnapshot) {
    fromJson(documentSnapshot.data());
  }

  fromJson(Map<String, dynamic> json) {
    photoUrl = json['photoUrl'] ?? 'default';
    email = json['email'] ?? '';
    id = json['id'] ?? '';
    firebaseUid = json['firebaseUid'] ?? '';
    displayName = json['displayName'] ?? '';
    country = json['country'] ?? '';
    city = json['city'] ?? '';
    experience = json['experience'] ?? '';
    qualification = json['qualification'] ?? '';
    currentProject = json['current project'] ?? '';
    language = json['language'] ?? '';
    currentlyworkingWith = json['currentlyworkingWith'] ?? '';
  }

  Developer.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  Developer.fromMap(Map<String, dynamic> data)
      : this(
            photoUrl: data['photoUrl'] ?? 'default',
            email: data['email'],
            id: data['id'],
            displayName: data['displayName'],
            city: data['city'],
            country: data['country'],
            experience: data['experience'],
            qualification: data['qualification'],
            currentProject: data['current project'],
            language: data['language'],
            currentlyworkingWith: data['currentlyworkingWith'],
            firebaseUid: data['firebaseUid']);

  Map<String, dynamic> updateProfile(Developer developer) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['photoUrl'] = developer.photoUrl;
    data['email'] = developer.email;
    data['id'] = developer.id;
    data['firebaseUid'] = developer.firebaseUid;
    data['displayName'] = developer.displayName;
    data['city'] = developer.city;
    data['language'] = developer.language;
    data['country'] = developer.country;
    data['experience'] = developer.experience;
    data['qualification'] = developer.qualification;
    return data;
  }

  Map<String, dynamic> toJson(Developer developer) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['photoUrl'] = developer.photoUrl;
    data['email'] = developer.email;
    data['id'] = developer.id;
    data['firebaseUid'] = developer.firebaseUid;
    data['displayName'] = developer.displayName;
    data['city'] = developer.city;
    data['language'] = developer.language;
    data['country'] = developer.country;
    data['experience'] = developer.experience;
    data['qualification'] = developer.qualification;
    data['current project'] = developer.currentProject;
    data['currentlyworkingWith'] = developer.currentlyworkingWith;
    return data;
  }
}
