import 'package:helphub/imports.dart';

class AuthenticationServices extends Services {
  bool isUserLoggedIn = false;
  bool isUserAvailable = false;
  UserType userType;

  StreamController<User> fireBaseUserStream = StreamController<User>();
  StreamController<bool> isUserLoggedInStream = StreamController<bool>();
  StreamController<UserType> userTypeStream = StreamController<UserType>();

  StudentProfileServices _studentprofileServices =
      locator<StudentProfileServices>();
  DeveloperProfileServices _developerprofileServices =
      locator<DeveloperProfileServices>();

  Developer developer;
  Student student;

  AuthenticationServices() {
    _userType().then((onValue) => userType = onValue);
    isLoggedIn().then((onValue) => isUserLoggedIn = onValue);
  }

  CollectionReference getCollection = FirebaseFirestore.instance
      .collection("users")
      .doc('Login')
      .collection('Developers');

  Future<bool> isLoggedIn() async {
    await getUser();
    fireBaseUserStream.add(firebaseUser);
    String name = firebaseUser != null ? firebaseUser.email.toString() : 'Null';
    print('User Email :' + name);
    isUserLoggedIn = firebaseUser == null ? false : true;
    isUserLoggedInStream.add(isUserLoggedIn);
    if (userType == null) {
      await _userType();
    }
    if (isUserLoggedIn) {
      if (userType == UserType.STUDENT) {
        _studentprofileServices.isStudentLoggedin();
      } else {
        _developerprofileServices.isDeveloperLoggedin();
      }
    }
    print(isUserLoggedIn.toString() + 'here');
    return isUserLoggedIn;
  }

  Future<UserType> _userType() async {
    userType = await sharedPreferencesHelper.getUserType();
    userTypeStream.add(userType);
    return userType;
  }

  Future checkDetails({
    @required String email,
    @required String password,
    @required UserType userType,
  }) async {
    await sharedPreferencesHelper.clearAllData();
    // String loginType = userType == UserType.STUDENT?"Student":"Developer";
    if (userType == UserType.DEVELOPERS) {
      DocumentSnapshot document = await getCollection.doc(email).get();
      if (document.exists) {
        sharedPreferencesHelper.setDevelopersId(email);
        isUserAvailable = true;
      } else {
        isUserAvailable = false;
      }
    } else {
      isUserAvailable = true;
    }
    if (isUserAvailable) {
      print("user Found");
    }

    if (userType == UserType.STUDENT) {
      this.userType = UserType.STUDENT;
      userTypeStream.add(userType);
      sharedPreferencesHelper.setUserType(UserType.STUDENT);
    } else {
      this.userType = UserType.DEVELOPERS;
      userTypeStream.add(this.userType);
      sharedPreferencesHelper.setUserType(this.userType);
    }
    return ReturnType.SUCCESS;
  }

  Future emailPasswordRegister(String email, String password) async {
    try {
      AuthErrors authErrors = AuthErrors.UNKNOWN;
      firebaseUser = (await auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      authErrors = AuthErrors.SUCCESS;
      this.userType = UserType.STUDENT;
      userTypeStream.add(userType);
      await sharedPreferencesHelper.setUserType(this.userType);
      await sharedPreferencesHelper.setStudentsEmail(email);
      print("User Regestered using Email and Password");
      isUserLoggedIn = true;
      isUserLoggedInStream.add(isUserLoggedIn);
      fireBaseUserStream.add(firebaseUser);
      return authErrors;
    } catch (e) {
      return catchException(e);
    }
  }

  Future<AuthErrors> emailPasswordSignIn(
      String email, String password, UserType userType) async {
    try {
      AuthErrors authErrors = AuthErrors.UNKNOWN;

      if (userType == UserType.DEVELOPERS) {
        DocumentSnapshot document = await getCollection.doc(email).get();
        if (document.exists) {
          firebaseUser = (await auth.signInWithEmailAndPassword(
                  email: document.data()['email'], password: password))
              .user;
          await sharedPreferencesHelper
              .setDeveloperEmail(document.data()['email']);
          bool res = await sharedPreferencesHelper.setDevelopersId(email);

          if (res) {
            authErrors = AuthErrors.SUCCESS;
            isUserLoggedIn = true;
            fireBaseUserStream.add(firebaseUser);
            isUserLoggedInStream.add(isUserLoggedIn);
            return authErrors;
          } else {
            authErrors = AuthErrors.UNKNOWN;
            fireBaseUserStream.add(firebaseUser);
            return authErrors;
          }
        } else {
          authErrors = AuthErrors.UserNotFound;
          return authErrors;
        }
      } else {
        firebaseUser = (await auth.signInWithEmailAndPassword(
                email: email, password: password))
            .user;
        await sharedPreferencesHelper.setUserType(UserType.STUDENT);
        bool res = await sharedPreferencesHelper.setStudentsEmail(email);

        if (res) {
          authErrors = AuthErrors.SUCCESS;
          isUserLoggedIn = true;
          fireBaseUserStream.add(firebaseUser);
          isUserLoggedInStream.add(isUserLoggedIn);
          return authErrors;
        } else {
          authErrors = AuthErrors.UNKNOWN;
          return authErrors;
        }
      }
    } on PlatformException catch (e) {
      return catchException(e);
    }
  }

  logoutMethod() async {
    await auth.signOut();
    isUserLoggedIn = false;
    isUserLoggedInStream.add(false);
    fireBaseUserStream.add(null);
    _studentprofileServices.loggedInStudentStream.add(null);
    _developerprofileServices.loggedInDeveloperStream.add(null);
    userTypeStream.add(UserType.UNKNOWN);
    await sharedPreferencesHelper.clearAllData();
    print("User Loged out");
  }

  Future<AuthErrors> passwordReset(String email, UserType userType) async {
    if (userType == UserType.STUDENT) {
      try {
        AuthErrors authErrors = AuthErrors.UNKNOWN;
        await auth.sendPasswordResetEmail(email: email);
        authErrors = AuthErrors.SUCCESS;
        print("Password Reset Link Send");
        return authErrors;
      } on PlatformException catch (e) {
        return catchException(e);
      }
    } else {
      try {
        AuthErrors authErrors = AuthErrors.UNKNOWN;
        DocumentSnapshot snap =
            await getProfileReference(email, UserType.DEVELOPERS).get();
        await auth.sendPasswordResetEmail(email: snap.data()['email']);
        authErrors = AuthErrors.SUCCESS;
        return authErrors;
      } on PlatformException catch (e) {
        return catchException(e);
      }
    }
  }

  Future<String> forgotId(String email, String displayName, String uid) async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('users')
          .doc('Profile')
          .collection('Developers')
          .where('email', isEqualTo: email)
          .get();
      if (snapshot.docs.length != 0) {
        DocumentSnapshot snap = snapshot.docs.first;
        if (snap.data()['displayName'] == displayName) {
          if (snap.data()['firebaseUid'] == uid) {
            /* final Email emailBody = Email(
                isHTML: false,
                subject: "Developer ID",
                body:
                    "Hello $displayName, your developer Id is ${snap.documentID}",
                recipients: [email],
                cc: ["cth001100@gmail.com"]);
            await FlutterEmailSender.send(emailBody); */
            return 'success ${snap.id}';
          } else {
            return 'Incorrect UID';
          }
        } else {
          return 'Display Name incorrect';
        }
      } else {
        return 'Please check your email';
      }
    } on PlatformException catch (e) {
      catchException(e);
      return e.message;
    }
  }

  AuthErrors catchException(Exception e) {
    AuthErrors errorType = AuthErrors.UNKNOWN;
    if (e is PlatformException) {
      if (Platform.isIOS) {
        switch (e.message) {
          case 'There is no user record corresponding to this identifier. The user may have been deleted.':
            errorType = AuthErrors.UserNotFound;
            break;
          case 'The password is invalid or the user does not have a password.':
            errorType = AuthErrors.PasswordNotValid;
            break;
          case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
            errorType = AuthErrors.NetworkError;
            break;
          case 'Too many unsuccessful login attempts.  Please include reCaptcha verification or try again later':
            errorType = AuthErrors.TOOMANYATTEMPTS;
            break;
          // ...
          default:
            print('Case iOS ${e.message} is not yet implemented');
        }
      } else if (Platform.isAndroid) {
        switch (e.code) {
          case 'Error 17011':
            errorType = AuthErrors.UserNotFound;
            break;
          case 'Error 17009':
          case 'ERROR_WRONG_PASSWORD':
            errorType = AuthErrors.PasswordNotValid;
            break;
          case 'Error 17020':
            errorType = AuthErrors.NetworkError;
            break;
          // ...
          default:
            print('Case Android ${e.message} ${e.code} is not yet implemented');
        }
      }
    }

    print('The error is $errorType');
    return errorType;
  }
}
