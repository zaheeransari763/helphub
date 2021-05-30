import 'package:helphub/Students/Services/StudentHomeServices.dart';
import 'package:helphub/core/viewmodel/BaseModel.dart';
import 'package:helphub/imports.dart';

class StudentHomeModel extends BaseModel {
  StudentHomeServices studentHomeServices = locator<StudentHomeServices>();
  Student student;
  Developer enrolleddeveloper;
  Project project;
  List<Developer> developers;
  List<Project> projects;
  StudentHomeModel() {
    getStudentProfile();
    //checkEnrolled();
  }

  getAll() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    getStudentProfile();
    getEnrolledDeveloperProfile();
    getStudentProject();
    getProjects();
    // await checkEnrolled();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
  }

  /*  Future<bool> checkEnrolled() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    await studentHomeServices.checkEnrolled();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return await studentHomeServices.checkEnrolled();
  } */

  Future<bool> sendReq(Student student, Developer developer) async {
    setState3(ViewState.Busy);
    requested =
        await studentHomeServices.requestForEnrollment(student, developer);
    setState3(ViewState.Idle);
    return requested;
  }

  Future<bool> cancelReq(Student student, Developer developer) async {
    setState3(ViewState.Busy);
    requested = await studentHomeServices.cancelRequest(student, developer);
    setState3(ViewState.Idle);
    return requested;
  }

  Future<List<Developer>> getDevelopers() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    developers = await studentHomeServices.getDevelopers();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return developers;
  }

  Future<List<Project>> getProjects() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    projects = await studentHomeServices.getAllProjects();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return projects;
  }

  bool requested;

  Future<bool> getEnrollmentAndRequestStatus(String id) async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    setState3(ViewState.Busy);
    requested = await studentHomeServices.getStatus(id);
    setState3(ViewState.Idle);
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return requested;
  }

  Future<Student> getStudentProfile() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    student = await studentHomeServices.getStudentProfile();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return student;
  }

  Future<Developer> getEnrolledDeveloperProfile() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    enrolleddeveloper = await studentHomeServices.getEnrolledDeveloperProfie();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return enrolleddeveloper;
  }

  Future<Project> getStudentProject() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    project = await studentHomeServices.getProject();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return project;
  }
}
