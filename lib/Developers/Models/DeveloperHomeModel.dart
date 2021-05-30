import 'package:helphub/Developers/services/DeveloperHomeServices.dart';
import 'package:helphub/core/viewmodel/BaseModel.dart';
import 'package:helphub/imports.dart';

class DeveloperHomeModel extends BaseModel {
  DeveloperHomeServices developerHomeServices =
      locator<DeveloperHomeServices>();

  Project project;
  Student student;
  List<Student> enrolledstudents;
  List<Student> requests;
  List<Project> allProject;

  getAll() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    getWorkingStudent();
    getCurrentProject();
    getrequestList();
    getenrolledStudents();
    getAllProjects();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
  }

  Future<bool> acceptRequest(Student student) async {
    setState3(ViewState.Busy);
    bool value = await developerHomeServices.acceptRequest(student);
    setState3(ViewState.Idle);
    return value;
  }

    Future<bool> rejectRequest(Student student) async {
    setState3(ViewState.Busy);
    bool value = await developerHomeServices.rejectRequest(student);
    setState3(ViewState.Idle);
    return value;
  }

    Future<bool> selectStudent(Student student, Project project)async{
    setState3(ViewState.Busy);
    bool value = await developerHomeServices.selectStudent(student: student, project: project);
    setState3(ViewState.Idle);
    return value;
  }

  Future updateProgress(DocumentReference documentReference, String phase)async{
    setState3(ViewState.Busy);
    await developerHomeServices.updateProgress(documentReference, phase);
    setState3(ViewState.Idle);
  }

  Future<Project> getCurrentProject() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    project = await developerHomeServices.getCurrentProject();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return project;
  }

  Future<Student> getWorkingStudent() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    student = await developerHomeServices.currentWorkingStudent();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return student;
  }

  Future<List<Student>> getenrolledStudents() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    enrolledstudents = await developerHomeServices.getEnrolled();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return enrolledstudents;
  }

  Future<List<Student>> getrequestList() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    requests = await developerHomeServices.getRequest();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return requests;
  }

  Future<List<Project>> getAllProjects() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    allProject = await developerHomeServices.getProjects();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return allProject;
  }
}
