import 'package:helphub/Developers/services/DeveloperProfileServices.dart';
import 'package:helphub/imports.dart';

class DeveloperProfilePageModel extends BaseModel {
  final developerprofileServices = locator<DeveloperProfileServices>();
  Developer developerProfile;
  final AuthenticationServices authenticationServices =
      locator<AuthenticationServices>();

  List<Developer> get developers => developerprofileServices.developers;
  DeveloperProfilePageModel() {
    getDeveloperProfileData();
  }

  Future<bool> setDeveloperProfileData(
      Developer developer) async {
    setState(ViewState.Busy);
    await developerprofileServices.setProfileData(
        developer);
    await Future.delayed(Duration(seconds: 3), () {});
    setState(ViewState.Idle);
    return true;
  }

  Future<Developer> getDeveloperProfileData() async {
    setState(ViewState.Busy);
    setState2(ViewState.Busy);
    developerProfile = await developerprofileServices.getDeveloper();
    // loggedInUserStream.add(userProfile);
    setState2(ViewState.Idle);
    setState(ViewState.Idle);
    return developerProfile;
  }

/* 
  Future<Developer> getUserProfileDataById(String id) async {
    setState(ViewState.Busy);
    developerProfile =
        await developerprofileServices.getDeveloperProfileDataById(id);
    setState(ViewState.Idle);
    return developerProfile;
  } */
}
