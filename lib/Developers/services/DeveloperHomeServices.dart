import 'package:helphub/core/services/Services.dart';
import 'package:helphub/imports.dart';

class DeveloperHomeServices extends Services {
  SharedPreferencesHelper sharedPreferencesHelper =
      locator<SharedPreferencesHelper>();
  DeveloperHomeServices() {
    currentWorkingStudent();
  }
  Future<Student> currentWorkingStudent() async {
    String id = await sharedPreferencesHelper.getDevelopersId();
    DocumentSnapshot devSnapshot =
        await getProfileReference(id, UserType.DEVELOPERS).get();
    Developer developer = Developer.fromJson(devSnapshot.data());
    String currentStudent = developer.currentlyworkingWith;
    await sharedPreferencesHelper.setStudentsEmail(currentStudent);
    await sharedPreferencesHelper.setCurrentProject(developer.currentProject);
    if (currentStudent != '' &&
        currentStudent != null &&
        currentStudent != 'none') {
      DocumentSnapshot snapshot =
          await getProfileReference(currentStudent, UserType.STUDENT).get();
      Student student;
      student = Student.dataFromSnapshot(snapshot.data());
      return student;
    } else {
      Student student;
      student = Student(displayName: '');
      return student;
    }
  }

  Future updateProgress(
      DocumentReference projectReference, String phase) async {
    Project project;
    await projectReference.update({'Progress.$phase': DateTime.now()});
    String stuemail = await sharedPreferencesHelper.getStudentsEmail();
    String devId = await sharedPreferencesHelper.getDevelopersId();
    DocumentReference developerReference =
        getProfileReference(devId, UserType.DEVELOPERS);
    DocumentReference studentreference =
        getProfileReference(stuemail, UserType.STUDENT);
    project = Project.fromSnapshot(await projectReference.get());
    if (project.progress.length == 6) {
      /*  FirebaseFirestore.instance.runTransaction((tx) async {
        await tx.update(projectReference, {'current': false, 'view': false});
       await  tx.update(studentreference, {
          'currentProject': 'none',
        });
       await tx.update(developerReference,
            {'current project': 'none', 'currentlyworkingWith': 'none'});
      }); */
      projectReference.update({'current': false, 'view': false});
      studentreference.update({
        'currentProject': 'none',
      });
      developerReference
          .update({'current project': 'none', 'currentlyworkingWith': 'none'});
    }
    project = Project.fromSnapshot(await projectReference.get());
    await studentreference
        .collection('Projects')
        .doc(project.name)
        .update(project.toMap(project));
  }

  Future<bool> acceptRequest(Student student) async {
    Timestamp time = Timestamp.now();
    student.acceptDate = time;
    String devId = await sharedPreferencesHelper.getDevelopersId();
    DocumentReference ref =
        getProfileReference(student.email, UserType.STUDENT);

    DocumentReference enrolledRef = firestore
        .collection('users')
        .doc('Enrolled')
        .collection(devId)
        .doc(student.displayName);
    await enrolledRef.set(student.acceptRequest(student));
    await ref.update({'enrolled': true, 'enrolledWith': devId});
    await getProfileReference(devId, UserType.DEVELOPERS)
        .collection('EnrollmentRequest')
        .doc(student.displayName)
        .delete();
    DocumentSnapshot snapshot = await enrolledRef.get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> rejectRequest(Student student) async {
    DocumentReference ref =
        getProfileReference(student.email, UserType.STUDENT);
    await ref.update({'enrolled': false, 'enrolledWith': 'none'});
    await ref.collection('EnrollmentRequest').doc(student.displayName).delete();
    DocumentReference sturef =
        getProfileReference(student.email, UserType.STUDENT);
    DocumentSnapshot snapshot = await sturef.get();
    if (snapshot.data()['enrolled'] == false) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> selectStudent({Student student, Project project}) async {
    if (student != null) {
      String devId = await sharedPreferencesHelper.getDevelopersId();
      await getProfileReference(devId, UserType.DEVELOPERS).update({
        'current project': project.name,
        'currentlyworkingWith': student.email
      });
      project.studentProfile =
          getProfileReference(student.email, UserType.STUDENT);
      await project.studentProfile.update({'currentProject': project.name});
      await project.studentProfile
          .collection('Projects')
          .doc(project.name)
          .set(project.toMap(project));
      await project.projectReference.update(project.setRef(project));
      DocumentSnapshot snapshot = await project.studentProfile
          .collection('Projects')
          .doc(project.name)
          .get();
      if (snapshot.exists) {
        return true;
      } else {
        return false;
      }
    } else {
      print('No Student selected');
      return false;
    }
  }

  Future<List<Student>> getEnrolled() async {
    String devId = await sharedPreferencesHelper.getDevelopersId();
    QuerySnapshot collectionReference = await firestore
        .collection('users')
        .doc('Enrolled')
        .collection(devId)
        .get();
    List<Student> student = [];
    for (var i = 0; i < collectionReference.docs.length; i++) {
      student.add(Student.dataFromSnapshot(collectionReference.docs[i].data()));
      print(student[i].displayName);
    }
    return student;
  }

  Future<List<Student>> getRequest() async {
    String devId = await sharedPreferencesHelper.getDevelopersId();
    try {
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc('Profile')
          .collection('Developers')
          .doc(devId)
          .collection('EnrollmentRequest')
          .get();
      List<Student> students = [];
      if (snapshot.docs.length > 0) {
        for (var i = 0; i < snapshot.docs.length; i++) {
          students.add(Student.requestFromMap(snapshot.docs[i].data()));
          print(students[i].displayName);
        }
      } else {
        students = [];
      }
      return students;
    } catch (e) {
      print(e.details);
      List<Student> students = [Student(displayName: "netException")];
      print(e.code);
      return students;
    }
  }

  Future<List<Project>> getProjects() async {
    String devId = await sharedPreferencesHelper.getDevelopersId();
    QuerySnapshot snapshot = await firestore
        .collection('users')
        .doc('Projects')
        .collection(devId)
        .orderBy('current', descending: true)
        .get();
    List<Project> projects = [];
    for (var i = 0; i < snapshot.docs.length; i++) {
      Project project = Project.fromMap(snapshot.docs[i].data());
      projects.add(project);
      print(project.name);
    }
    return projects;
  }

  Future<Project> getCurrentProject() async {
    Project project;
    //String name = await sharedPreferencesHelper.getCurrentProject();
    String devId = await sharedPreferencesHelper.getDevelopersId();
    QuerySnapshot snap = await firestore
        .collection('users')
        .doc('Projects')
        .collection(devId)
        .where('view', isEqualTo: true)
        .get();
    if (snap.docs.length != 0) {
      project = Project.fromMap(snap.docs.first.data());
    } else {
      project = Project(name: 'none');
    }
    return project;
  }
}
