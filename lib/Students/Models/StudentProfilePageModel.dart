import 'package:helphub/Students/Services/StudentProfileServices.dart';
import 'package:helphub/imports.dart';

class StudentProfilePageModel extends BaseModel{
  final studentprofileServices = locator<StudentProfileServices>();
  Student studentProfile;
  StudentProfilePageModel(){
    getStudentProfileData();
    
}

Future<bool> setStudentProfileData({
  Student student,
})async{
  setState(ViewState.Busy);
  await studentprofileServices.setProfileData(
    student: student
  );
  await Future.delayed(Duration(seconds: 3), (){});
  setState(ViewState.Idle);
  return true;
}

  Future<Student> getStudentProfileData() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    studentProfile = await studentprofileServices.getStudent();
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return studentProfile;
  }

}