import 'package:helphub/core/enums/AuthErrors.dart';
import 'package:helphub/imports.dart';

class LoginPageModel extends BaseModel {
  final _authenticationService = locator<AuthenticationServices>();
  String currentLoggingStatus = 'Please wait';

  bool isUserLoggedIn() {
    return _authenticationService.isUserLoggedIn;
  }

  Future checkUserDetails({
    String email,
    String password,
    String confirmPassword,
    UserType userType,
    ButtonType buttonType,
  }) async {
    setState(ViewState.Busy);
    ReturnType response = await _authenticationService.checkDetails(
        email: email, password: password, userType: userType);

    if (response == ReturnType.EMAILERROR) {
      currentLoggingStatus = 'No user with that email found';
      setState(ViewState.Idle);
      return false;
    } else {
      currentLoggingStatus = 'Please wait while we check your credientials..';
      if (buttonType == ButtonType.LOGIN) {
        AuthErrors res = await _loginUser(email, password, userType);
        setState(ViewState.Idle);
        if (res == AuthErrors.SUCCESS) {
          return true;
        } else {
          return false;
        }
      } else {
        if (password != confirmPassword) {
          currentLoggingStatus = 'Passwords do not match';
          setState(ViewState.Idle);
          return false;
        }
        AuthErrors res = await _registerUser(email, password);
        setState(ViewState.Idle);
        if (res == AuthErrors.SUCCESS) {
          return true;
        } else {
          return false;
        }
      }
    }
  }

  Future _loginUser(String email, String password, UserType userType) async {
    AuthErrors authError = await _authenticationService.emailPasswordSignIn(
        email, password, userType);
    currentLoggingStatus = AuthErrorsHelper.getValue(authError);
    return authError;
  }

  Future _registerUser(String email, String password) async {
    AuthErrors authError =
        await _authenticationService.emailPasswordRegister(email, password);
    currentLoggingStatus = AuthErrorsHelper.getValue(authError);
    return authError;
  }

  logoutUser() async {
    setState(ViewState.Busy);
    await _authenticationService.logoutMethod();
    isUserLoggedIn();
    setState(ViewState.Idle);
  }
}
