import 'dart:ui';
import 'package:helphub/Shared/Pages/ForgotPassword.dart';
import 'package:helphub/imports.dart';
import 'package:helphub/Shared/Widgets_and_Utility/MyTheme.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  UserType loginType = UserType.STUDENT;
  bool isRegistered = false;
  ButtonType buttonType = ButtonType.LOGIN;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ThemeClass themeClass = locator<ThemeClass>();
  @override
  void initState() {
    super.initState();
    controller =
        ScrollController(keepScrollOffset: true, initialScrollOffset: 20);
  }

  loginRegisterBtnTap(
      LoginPageModel model,
      BuildContext context,
      String email,
      String password,
      String confirmPassword,
      UserType userType,
      ButtonType buttonType) async {
    if (email == null || password == null) {
      _scaffoldKey.currentState
          .showSnackBar(ksnackBar(context, 'Please enter details properly'));
    } else {
      if (email.trim().isEmpty || password.trim().isEmpty) {
        _scaffoldKey.currentState
            .showSnackBar(ksnackBar(context, 'Please enter details properly'));
      } else {
        bool response = await model.checkUserDetails(
          email: email,
          password: password,
          userType: userType,
          buttonType: buttonType,
          confirmPassword: confirmPassword,
        );
        if (response) {
          if (locator<AuthenticationServices>().userType ==
              UserType.DEVELOPERS) {
            Navigator.pushNamedAndRemoveUntil(
                context, DeveloperProfile.id, (r) => false);
          } else if (locator<AuthenticationServices>().userType ==
              UserType.STUDENT) {
            Navigator.pushNamedAndRemoveUntil(
                context, StudentProfile.id, (r) => false);
          }
        } else {
          _scaffoldKey.currentState
              .showSnackBar(ksnackBar(context, 'something went wrong...'));
        }
        _scaffoldKey.currentState.showSnackBar(ksnackBar(
          context,
          model.currentLoggingStatus,
        ));
      }
    }
  }

  ScrollController controller;
  @override
  Widget build(BuildContext context) {
    MyTheme myTheme = Provider.of<MyTheme>(context);
    IconData themeIcon =
        myTheme == MyTheme.Light ? Icons.nightlight_round : Icons.wb_sunny;
    var media = MediaQuery.of(context);
    Size size = media.size;
    double bottom = media.viewInsets.bottom;
    double heigth = size.height;
    double width = size.width;
    Orientation orientation = media.orientation;
    bool portrait = orientation == Orientation.portrait ? true : false;
    return BaseView<LoginPageModel>(
      onModelReady: (model) => model,
      builder: (context, model, child) {
        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: false,
          body:
              LayoutBuilder(builder: (BuildContext context, BoxConstraints c) {
            return SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: bottom == 0 ? bottom : bottom - heigth / 4.8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: c.maxHeight, maxHeight: c.maxHeight),
                  child: Stack(
                    children: <Widget>[
                      GradientBox(
                        colors: [
                          Color(0xff80DEEA),
                          Color(0xff2ab1e0),
                          Color(0xff008b88)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      portrait
                          ? Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: FlutterLoginCustom(
                                messages: LoginMessages(
                                    recoverPasswordDescription: ""),
                                theme: LoginTheme(
                                  accentColor: mainColor,
                                  buttonStyle: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(context).accentColor
                                          : Colors.white),
                                  buttonTheme: LoginButtonTheme(
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Theme.of(context).accentColor),
                                  cardTheme: CardTheme(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(22)),
                                      elevation: 10),
                                ),
                                onSignup: (data) async {
                                  await loginRegisterBtnTap(
                                      model,
                                      context,
                                      data.name,
                                      data.password,
                                      data.password,
                                      UserType.STUDENT,
                                      ButtonType.REGISTER);
                                  return "";
                                },
                                onLogin: (data) async {
                                  await loginRegisterBtnTap(
                                      model,
                                      context,
                                      data.name,
                                      data.password,
                                      data.password,
                                      UserType.STUDENT,
                                      ButtonType.LOGIN);
                                  return "";
                                },
                                onRecoverPassword: (data) async {
                                  await loginRegisterBtnTap(
                                      model,
                                      context,
                                      data.name,
                                      data.password,
                                      data.password,
                                      UserType.DEVELOPERS,
                                      ButtonType.LOGIN);
                                  return "";
                                },
                              ),
                            )
                          : Positioned(
                              left: width / 4.9,
                              bottom: heigth / 20,
                              child: FlutterLoginCustom(
                                messages: LoginMessages(
                                    recoverPasswordDescription: ""),
                                theme: LoginTheme(
                                  accentColor: mainColor,
                                  buttonStyle: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Theme.of(context).accentColor
                                          : Colors.white),
                                  buttonTheme: LoginButtonTheme(
                                    backgroundColor:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Theme.of(context).accentColor,
                                  ),
                                  cardTheme: CardTheme(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(22)),
                                      elevation: 10),
                                ),
                                onSignup: (data) async {
                                  await loginRegisterBtnTap(
                                      model,
                                      context,
                                      data.name,
                                      data.password,
                                      data.password,
                                      UserType.STUDENT,
                                      ButtonType.REGISTER);
                                  return "";
                                },
                                onLogin: (data) async {
                                  await loginRegisterBtnTap(
                                      model,
                                      context,
                                      data.name,
                                      data.password,
                                      data.password,
                                      UserType.STUDENT,
                                      ButtonType.LOGIN);
                                  return "";
                                },
                                onRecoverPassword: (data) async {
                                  await loginRegisterBtnTap(
                                      model,
                                      context,
                                      data.name,
                                      data.password,
                                      data.password,
                                      UserType.DEVELOPERS,
                                      ButtonType.LOGIN);
                                  return "";
                                },
                              ),
                            ),
                      Positioned(
                        top: 45,
                        left: 5,
                        child: AnimatedSwitcher(
                          key: ValueKey(themeIcon),
                          duration: Duration(milliseconds: 500),
                          child: Hero(
                            tag: 'ThemeButton',
                            child: IconButton(
                              icon: Icon(themeIcon),
                              onPressed: () {
                                myTheme == MyTheme.Dark
                                    ? themeClass.changeTheme(MyTheme.Light)
                                    : themeClass.changeTheme(MyTheme.Dark);
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          top: 80,
                          left: MediaQuery.of(context).size.width / 10,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Hero(
                                  tag: 'hello',
                                  child: Card(
                                    elevation: 15,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(22)),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          right: 12,
                                          top: 12,
                                          bottom: 10),
                                      child: Text(
                                        'Hello!',
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black,
                                            fontSize: portrait
                                                ? (heigth / 15) - 10
                                                : (heigth / 8) - 13,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ),
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 12),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FadeIn(
                                        duration: Duration(milliseconds: 800),
                                        fadeDirection:
                                            FadeDirection.topToBottom,
                                        curve: Curves.easeIn,
                                        child: Text('''Welcome to ''',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: portrait
                                                  ? (heigth / 15) - 20
                                                  : (heigth / 8) - 26.8,
                                              fontWeight: FontWeight.w300,
                                            )),
                                      ),
                                      FadeIn(
                                        duration: Duration(milliseconds: 850),
                                        fadeDirection:
                                            FadeDirection.topToBottom,
                                        curve: Curves.easeIn,
                                        child: Text(
                                          'Help Hub.',
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: portrait
                                                  ? (heigth / 15) - 15
                                                  : (heigth / 8) - 18,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      )
                                    ]),
                              )
                            ],
                          )),
                      model.state == ViewState.Busy
                          ? Container(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 10.0, sigmaY: 10.0),
                                child: kBuzyPage(
                                    color: Theme.of(context).primaryColor),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            );
          }),
          floatingActionButton: model.state == ViewState.Idle
              ? FloatingActionButton.extended(
                  heroTag: "title",
                  onPressed: () {
                    kopenPage(context, ForgotPasswordPage());
                  },
                  label: Text("Need Help?"))
              : null,
        );
      },
    );
  }
}
