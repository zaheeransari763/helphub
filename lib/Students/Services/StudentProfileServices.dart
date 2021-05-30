import 'package:helphub/core/services/Services.dart';
import 'package:helphub/core/services/StorageServices.dart';
import 'package:helphub/imports.dart';

class StudentProfileServices extends Services {
  StorageServices storageServices = locator<StorageServices>();
  StreamController<Student> loggedInStudentStream =
      StreamController.broadcast(sync: true);
  StudentProfileServices() {
    getUser();
  }

  setProfileData({Student student}) async {
    if (student.photoUrl.contains('https')) {
      /*  student.photoUrl =
          await storageServices.setProfilePhoto(student.photoUrl); */
    } else if (student.photoUrl == 'default') {
      student.photoUrl = student.photoUrl;
    } else {
      student.photoUrl =
          await storageServices.setProfilePhoto(student.photoUrl);
    }
    Map profileData = student.toJson(student);
    var body = json.encode(profileData);
    print("success");
    final jsonData = await json.decode(body);
    student = Student.fromJson(jsonData);
    sharedPreferencesHelper.setStudent(body);
    sharedPreferencesHelper.setStudentsEmail(student.email);
    sharedPreferencesHelper.setStudentsName(student.displayName);
    loggedInStudentStream.add(student);
  }

  Future<Student> getStudentLocal() async {
    Student student;
    String body = await sharedPreferencesHelper.getStudent();
    if (body != 'N.A') {
      final data = json.decode(body);
      if (data()['displayName'] != null && data()['displayName'] != "") {
        student = Student.fromJson(data());
        loggedInStudentStream.add(student);
      } else {
        student = Student();
        loggedInStudentStream.add(student);
      }
    } else {
      student = Student();
      loggedInStudentStream.add(student);
    }
    return student;
  }

  Future<Student> getStudent() async {
    Student student;
    String email = await sharedPreferencesHelper.getStudentsEmail();
    Map studentData;
    DocumentReference ref = getProfileReference(email, UserType.STUDENT);
    String stu = await sharedPreferencesHelper.getStudent();
    if (stu == 'N.A') {
      try {
        DocumentSnapshot documentSnapshot = await ref.get();
        if (documentSnapshot.exists) {
          student = Student.fromSnapshot(documentSnapshot);
          studentData = student.toJson(student);
          var body = json.encode(studentData);
          loggedInStudentStream.add(student);
          await sharedPreferencesHelper.setStudent(body);
          return student;
        } else {
          student = null;
          return student;
        }
      } catch (e) {
        student = Student();
        return student;
      }
    } else {
      String stu = await sharedPreferencesHelper.getStudent();
      Map data = json.decode(stu);
      student = Student.fromJson(data);
      return student;
    }
  }

  Future<Student> isStudentLoggedin() async {
    Student student = await getStudentLocal();
    return student;
  }
}
