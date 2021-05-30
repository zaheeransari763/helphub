import 'package:helphub/core/enums/UserType.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  final String _userType = 'userType';
  final String _schoolCode = 'schoolCode';
  final String _photoUrl = 'photoUrl';
  final String _studentsIds = 'studentIds';
  final String _developersIds = 'developersIds';
  final String _userModel = 'userJsonModel';
  final String _email = 'developer@dev.com';
  final String _studentName = 'StuName';
  final String _enrolledDeveloper = 'Developer';
  final String _currentProject = 'Project';
  final String fcmtoken = 'token';

  Future<bool> setUserDataModel(String jsonModel) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(_userModel, jsonModel);
    print('User Data Model saved ' + res.toString() + ' ' + jsonModel);
    return res;
  }

  Future<String> getUserDataModel() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(_userModel) ?? 'N.A';
    print('User Data Model Retrived ' + res.toString());
    return res;
  }

  Future<bool> setSenderToken(String token) async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(fcmtoken, token);
    return res;
  }

  Future<String> getSenderToken() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(fcmtoken) ?? 'N.A';
    return res;
  }

  Future<bool> setDeveloper(String jsonModel) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(_userModel, jsonModel);
    print(jsonModel);
    return res;
  }



  Future<String> getDeveloper() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(_userModel) ?? "N.A";
    print(_userModel);
    return res;
  }

  
  Future<bool> setDeveloperEmail(String email) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(_email, email);
    print(email);
    return res;
  }

  Future<String> getDeveloperEmail() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(_email) ?? "N.A";
    print(_userModel);
    return res;
  }


  Future<bool> setStudent(String jsonModel) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(_userModel, jsonModel);
    print(jsonModel);
    return res;
  }

  Future<String> getStudent() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(_userModel) ?? "N.A";
    print(_userModel);
    return res;
  }

  Future<bool> setStudentsEmail(String email) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(_studentsIds, email);
    print('Childs Id Saved ' + res.toString());
    return res;
  }

  Future<String> getStudentsEmail() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(_studentsIds) ?? 'N.A';
    print('Childs Id Retrived ' + res.toString());
    return res;
  }

    Future<bool> setStudentsName(String name) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(_studentName, name);
    print('Childs Id Saved ' + res.toString());
    return res;
  }


  Future<String> getStudentsName() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(_studentName) ?? 'N.A';
    print('Childs Id Retrived ' + res.toString());
    return res;
  }

  Future<bool> setEnrolledDeveloperId(String id) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(_enrolledDeveloper, id);
    return res;
  }

  Future<String> getEnrolledDeveloperId() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(_enrolledDeveloper) ?? 'N.A';
    print('Enrolled Developer Id' + res.toString());
    return res;
  }

  Future<bool> setCurrentProject(String name) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(_currentProject, name);
    return res;
  }

  Future<String> getCurrentProject() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(_currentProject) ?? 'N.A';
    print('Enrolled Developer Id' + res.toString());
    return res;
  }

  Future<bool> setDevelopersId(String id) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool res = await preferences.setString(_developersIds, id);
    print('Childs Id Saved ' + res.toString());
    return res;
  }

  //Method to retrive the _childIds of Parent
  Future<String> getDevelopersId() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String res = preferences.getString(_developersIds) ?? 'N.A';
    return res;
  }

  //Method that saves the _loggedInUserPhotoUrl
  Future<bool> setLoggedInUserPhotoUrl(String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool res = await prefs.setString(_photoUrl, url);
    print('User Id Saved' + res.toString());
    return res;
  }

  //Method that return the _loggedInUserPhotoUrl
  Future<String> getLoggedInUserPhotoUrl() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String res = prefs.getString(_photoUrl) ?? 'default';
    print('User photo url Retrived' + res.toString());
    return res;
  }

  //Method that saves the user logged in type
  Future<bool> setUserType(UserType userType) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool res =
        await prefs.setString(_userType, UserTypeHelper.getValue(userType));
    print('User Type Saved' +
        UserTypeHelper.getValue(userType) +
        ' ' +
        res.toString());
    return res;
  }

  //Method that return the user logged in type
  Future<UserType> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String userType =
        prefs.getString(_userType) ?? UserTypeHelper.getValue(UserType.UNKNOWN);
    print('User Type Returned' + userType);
    return UserTypeHelper.getEnum(userType);
  }

  // Method that returns the last selected country code
  Future<String> getSchoolCode() async {
    final SharedPreferences countryCodePrefs =
        await SharedPreferences.getInstance();

    String res = countryCodePrefs.getString(_schoolCode) ?? "";

    print('School Code Retrived : ' + res);

    return res.toUpperCase();
  }

  //Method to remove all the Sharedpreference details when Logging Out
  Future<bool> clearAllData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    bool res = await preferences.clear();
    print('User Data Cleared : ' + res.toString());

    return res;
  }
}
