import 'package:helphub/imports.dart';

class StudentHomeServices extends Services {
  StreamController<Student> studentStream =
      StreamController.broadcast(sync: true);
  StudentHomeServices() {
    getUser();
  }
  DocumentReference ref =
      FirebaseFirestore.instance.collection('users').doc('Profile');

  Future<Student> getStudentProfile() async {
    Student student;
    String email = await sharedPreferencesHelper.getStudentsEmail();
    DocumentSnapshot documentSnapshot =
        await ref.collection('Students').doc(email).get();
    student = Student.dataFromSnapshot(documentSnapshot.data());
    studentStream.add(student);
    await sharedPreferencesHelper
        .setEnrolledDeveloperId(student.enrolledWithDeveloper);
    return student;
  }

  Future<bool> requestForEnrollment(
    Student student,
    Developer developer,
  ) async {
    Timestamp time = Timestamp.now();
    Student studentreq;
    studentreq = Student(
        city: student.city,
        country: student.country,
        displayName: student.displayName,
        email: student.email,
        requested: true,
        requestDateTime: time,
        qualification: student.qualification,
        yearofcompletion: student.yearofcompletion,
        photoUrl: student.photoUrl);
    DocumentReference reference =
        getProfileReference(developer.id, UserType.DEVELOPERS)
            .collection('EnrollmentRequest')
            .doc(student.displayName);

    reference.set(student.sendRequest(studentreq, developer.id));
    DocumentSnapshot snapshot = await reference.get();
    if (snapshot.exists)
      return true;
    else
      return false;
  }

  Future<bool> cancelRequest(Student student, Developer developer) async {
    DocumentReference reference =
        getProfileReference(developer.id, UserType.DEVELOPERS)
            .collection('EnrollmentRequest')
            .doc(student.displayName);
    await reference.delete();
    DocumentSnapshot snapshot = await reference.get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getStatus(String id) async {
    String displayName = await sharedPreferencesHelper.getStudentsName();
    DocumentSnapshot snapshot =
        await getProfileReference(id, UserType.DEVELOPERS)
            .collection('EnrollmentRequest')
            .doc(displayName)
            .get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

/*   Future<bool> checkEnrolled() async {
    String email = await sharedPreferencesHelper.getStudentsEmail();
    DocumentSnapshot documentSnapshot =
        await ref.collection('Students').doc(email).get();
    if (documentSnapshot.exists &&
        documentSnapshot.data.containsKey('enrolled')) {
      enrolled = documentSnapshot.data()['enrolled'];
    } else {
      enrolled = false;
    }
    return enrolled;
  } */

  Future<Developer> getEnrolledDeveloperProfie() async {
    Developer developer;
    String devId = await sharedPreferencesHelper.getEnrolledDeveloperId();
    DocumentReference documentReference;
    if (devId == 'N.A' || devId == 'none' || devId == null) {
      developer = Developer(displayName: 'N.A');
      return developer;
    } else {
      documentReference = firestore
          .collection('users')
          .doc('Profile')
          .collection('Developers')
          .doc(devId);

      DocumentSnapshot documentSnapshot = await documentReference.get();
      developer = Developer.fromMap(documentSnapshot.data());
      await sharedPreferencesHelper.setCurrentProject(developer.currentProject);
      return developer;
    }
  }

  Future<Project> getProject() async {
    Project project;
    String email = await sharedPreferencesHelper.getStudentsEmail();
    DocumentSnapshot snap =
        await getProfileReference(email, UserType.STUDENT).get();
    String projectName = snap.data()['currentProject'];
    if (projectName != 'none' && projectName != null) {
      DocumentSnapshot snapshot =
          await getProfileReference(email, UserType.STUDENT)
              .collection('Projects')
              .doc(projectName)
              .get();
      project = Project.fromMap(snapshot.data());
      return project;
    } else {
      project = Project(name: 'none');
      return project;
    }
  }

  Future<List<Developer>> getDevelopers() async {
    CollectionReference reference =
        firestore.collection('users').doc('Profile').collection('Developers');
    QuerySnapshot snap = await reference.orderBy('displayName').get();
    List<Developer> developers = [];
    for (var i = 0; i < snap.docs.length; i++) {
      Developer developer = Developer.fromSnapshot(snap.docs[i]);
      developers.add(developer);
      print(developers[i].displayName);
    }
    return developers;
  }

  Future<List<Project>> getAllProjects() async {
    String email = await sharedPreferencesHelper.getStudentsEmail();
    CollectionReference reference =
        getProfileReference(email, UserType.STUDENT).collection('Projects');
    QuerySnapshot snap = await reference.get();
    List<Project> projects = [];
    if (snap.docs.length > 0) {
      for (int i = 0; i < snap.docs.length; i++) {
        projects.add(Project.fromMap(snap.docs[i].data()));
        print(projects[i].name);
      }
      return projects;
    } else {
      return projects;
    }
  }
}
