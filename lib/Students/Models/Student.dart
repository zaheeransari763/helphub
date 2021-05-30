import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helphub/imports.dart';

class Student {
  String photoUrl;
  String email;
  String firebaseUid;
  String displayName;
  String qualification;
  String yearofcompletion;
  Timestamp requestDateTime;
  Timestamp acceptDate;
  String city;
  String country;
  String enrolledWithDeveloper;
  String doc;
  bool enrolled;
  bool requested;
  bool rejected;
  DocumentReference reference;

  Student(
      {this.photoUrl = 'default',
      this.requestDateTime,
      this.email = '',
      this.firebaseUid = '',
      this.displayName = '',
      this.qualification = '',
      this.yearofcompletion = '',
      this.city = '',
      this.country = '',
      this.enrolled = false,
      this.rejected = false,
      this.requested = false,
      this.doc,
      this.enrolledWithDeveloper,
      this.reference});

  bool isEmpty() {
    if (this.displayName == '' ||
        this.displayName == null ||
        this.email == null ||
        this.email == '' ||
        this.city == null ||
        this.city == '' ||
        this.country == null ||
        this.country == '') {
      return true;
    } else {
      return false;
    }
  }

  Student.dataFromSnapshot(Map<String, dynamic> data)
      : this(
            photoUrl: data['photoUrl'] ?? 'default',
            email: data['email'] ?? '',
            firebaseUid: data['firebaseUuid'] ?? '',
            displayName: data['displayName'] ?? '',
            qualification: data['qualification'] ?? '',
            yearofcompletion: data['yearofcompletion'] ?? '',
            city: data['city'] ?? '',
            country: data['country'] ?? '',
            enrolled: data['enrolled'] ?? false,
            reference: data['reference'],
            requested: data['requested'],
            rejected: data['rejected'],
            enrolledWithDeveloper: data['enrolledWith']);

  Student.fromSnapshot(DocumentSnapshot documentSnapshot) {
    fromJson(documentSnapshot.data());
  }

  Student.fromJson(Map<String, dynamic> json) {
    fromJson(json);
  }

  Student.requestFromMap(Map<dynamic, dynamic> data)
      : this(
          photoUrl: data['Student Photo'],
          email: data['Student Email'],
          displayName: data['Student Name'],
          qualification: data['Student Qualification'],
          yearofcompletion: data['Student Year of Completion'],
          requestDateTime: data['Request Date & Time'],
          city: data['city'],
          country: data['country'],
        );

  Map<String, dynamic> sendRequest(Student student, String id) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Student Photo'] = student.photoUrl;
    data['Student Email'] = student.email;
    data['Student Name'] = student.displayName;
    data['Student Qualification'] = student.qualification;
    data['Student Year of Completion'] = student.yearofcompletion;
    data['Request Date & Time'] = student.requestDateTime;
    data['city'] = student.city;
    data['requested'] = student.requested;
    data['country'] = student.country;
    data['requestedTo'] = id;
    return data;
  }

  Map<String, dynamic> acceptRequest(Student student) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['photoUrl'] = student.photoUrl;
    data['email'] = student.email;
    data['displayName'] = student.displayName;
    data['qualification'] = student.qualification;
    data['year of completion'] = student.yearofcompletion;
    data['acceptance date'] = student.acceptDate;
    data['city'] = student.city;
    data['country'] = student.country;
    return data;
  }

  Map<String, dynamic> toJson(Student student) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['photoUrl'] = student.photoUrl;
    data['email'] = student.email;
    data['firebaseUuid'] = student.firebaseUid;
    data['displayName'] = student.displayName;
    data['qualification'] = student.qualification;
    data['yearofcompletion'] = student.yearofcompletion;
    data['city'] = student.city;
    data['country'] = student.country;
    return data;
  }

  fromJson(Map<dynamic, dynamic> json) {
    photoUrl = json['photoUrl'] ?? 'default';
    email = json['email'] ?? '';
    firebaseUid = json['firebaseUuid'] ?? '';
    displayName = json['displayName'] ?? '';
    qualification = json['qualification'] ?? '';
    yearofcompletion = json['yearofcompletion'] ?? '';
    city = json['city'] ?? '';
    country = json['country'] ?? '';
  }
}
