import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:helphub/imports.dart';

import 'package:url_launcher/url_launcher.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key key}) : super(key: key);

  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // AuthenticationServices _authService = locator<AuthenticationServices>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: TopBar(
        child: kBackBtn,
        onPressed: () {
          kbackBtn(context);
        },
        title: // Text(
            ConstString.help, //),
      ),
      body: ExpandableTheme(
        data: ExpandableThemeData(iconColor: Colors.black, useInkWell: true),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[DeveloperCard(), StudentCard()],
        ),
      ),
    );
  }
}

class DeveloperCard extends StatefulWidget {
  @override
  _DeveloperCardState createState() => _DeveloperCardState();
}

class _DeveloperCardState extends State<DeveloperCard> {
  final AuthenticationServices _authService = locator<AuthenticationServices>();

  final TextEditingController _idController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _uidController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool loading = false;

    buildImg(double height) {
      return SizedBox(
          height: height,
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(ConstassetsString.developer))),
          ));
    }

    buildCollapsed1() {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Developer",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 25),
                  ),
                ],
              ),
            ),
          ]);
    }

    buildExpanded1() {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Developer",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 30),
                  )
                ],
              ),
            ),
          ]);
    }

    buildExpanded3() {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExpansionTile(
              title: Text("Forgot Password",
                  style: TextStyle(color: Colors.black, fontFamily: 'Nunito')),
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: kTextFieldDecoration.copyWith(
                      labelText: "Your 6 digit Id"),
                ),
                TextButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      AuthErrors authError = await _authService
                          .passwordReset(_idController.text.trim().toString(),
                              UserType.DEVELOPERS)
                          .then((onValue) {
                        setState(() {
                          loading = false;
                        });
                        return AuthErrors.SUCCESS;
                      });
                      Scaffold.of(context).showSnackBar(
                        ksnackBar(
                          context,
                          AuthErrorsHelper.getValue(authError),
                        ),
                      );
                      ksnackBar(
                        context,
                        AuthErrorsHelper.getValue(authError),
                      );
                    },
                    child: Text("Submit")),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            Divider(
              height: 1,
            ),
            ExpansionTile(
              title: Text("Forgot Id",
                  style: TextStyle(color: Colors.black, fontFamily: 'Nunito')),
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: kTextFieldDecoration.copyWith(
                      labelText: "Your email address"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration:
                      kTextFieldDecoration.copyWith(labelText: "Your name"),
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _uidController,
                  keyboardType: TextInputType.text,
                  decoration:
                      kTextFieldDecoration.copyWith(labelText: "Database Uid"),
                ),
                TextButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      String result = await _authService.forgotId(
                          _emailController.text.trim(),
                          _nameController.text.trim(),
                          _uidController.text.trim());
                      List<String> values = result.split(" ");
                      String value = values[0];
                      String id = values[1];
                      if (value == 'success') {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("ID"),
                                content: Text("Your Id is $id"),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Okay"))
                                ],
                              );
                            });
                      } else {
                        Scaffold.of(context)
                            .showSnackBar(ksnackBar(context, result));
                      }
                    },
                    child: Text("Submit")),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            Divider(
              height: 1,
            ),
            ExpansionTile(
              title: Text("Create new account",
                  style: TextStyle(color: Colors.black, fontFamily: 'Nunito')),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "To create a new developer account you must fulfill the following requirements",
                        style: TextStyle(fontSize: 20),
                      )),
                ),
                SizedBox(
                  height: 10,
                ),
                ExpansionTile(
                    title: Text("Requirements.",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontFamily: 'Nunito')),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              '1) You must be excel in atleast 1 programming language.',
                              style: TextStyle(fontSize: 17)),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              '2) You must be at least 2 years experience on Industry level.',
                              style: TextStyle(fontSize: 17)),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              '3) You should have basic knowledge of management and teaching.',
                              style: TextStyle(fontSize: 17)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ]),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Once you have fulfilled the above requirements, the procedure is right below",
                        style: TextStyle(fontSize: 20),
                      )),
                ),
                SizedBox(
                  height: 5,
                ),
                ExpansionTile(
                    title: Text("Procedure",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontFamily: 'Nunito')),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              'Note: All the docs mentioned below and the obligations for creating a developer account as it is we need to confirm the identity as a real developer (Only for confirming your ID, will not be stored in database).',
                              style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text("The required Documents are:",
                              style: TextStyle(fontSize: 17)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                              "Any government ID proof.\nMarksheet of your latest qualification.\nProof of experience (minimun 2 years of experience",
                              style: TextStyle(fontSize: 17, color: black)),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: "Now, send all the document to our",
                              style: TextStyle(color: black)),
                          TextSpan(
                              text: " e-mail ",
                              style: TextStyle(color: mainColor),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launch("mailto:cth001100@gmail.com");
                                }),
                          TextSpan(text: "and wait for the call")
                        ]),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ]),
              ],
            ),
          ],
        ),
      );
    }

    buildCollapsed2() {
      return buildImg(150);
    }

    buildExpanded2() {
      return buildImg(300);
    }

    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: ScrollOnExpand(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: !loading
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expandable(
                      collapsed: buildCollapsed1(),
                      expanded: buildExpanded1(),
                    ),
                    Expandable(
                      collapsed: buildCollapsed2(),
                      expanded: buildExpanded2(),
                    ),
                    Expandable(
                      collapsed: Container(),
                      expanded: buildExpanded3(),
                    ),
                    Divider(
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Builder(
                          builder: (context) {
                            var controller = ExpandableController.of(context);
                            return TextButton(
                              child: Text(
                                controller.expanded ? "COLLAPSE" : "EXPAND",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: Colors.deepPurple),
                              ),
                              onPressed: () {
                                controller.toggle();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                )
              : kBuzyPage(),
        ),
      ),
    ));
  }
}

class StudentCard extends StatefulWidget {
  @override
  _StudentCardState createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  final AuthenticationServices _authService = locator<AuthenticationServices>();

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool loading = false;

    buildImg(double height) {
      return SizedBox(
          height: height,
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(ConstassetsString.student))),
          ));
    }

    buildCollapsed1() {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Student",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 25),
                  ),
                ],
              ),
            ),
          ]);
    }

    buildExpanded1() {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Student",
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: 30),
                  )
                ],
              ),
            ),
          ]);
    }

    buildExpanded3() {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExpansionTile(
              title: Text("Forgot Password",
                  style: TextStyle(color: Colors.black, fontFamily: 'Nunito')),
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration:
                      kTextFieldDecoration.copyWith(labelText: "Your E-mail"),
                ),
                TextButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      if (_emailController.text.trim().contains('@') &&
                          _emailController.text.trim().contains('.')) {
                        AuthErrors authError = await _authService
                            .passwordReset(
                                _emailController.text.trim().toString(),
                                UserType.STUDENT)
                            .then((val) {
                          setState(() {
                            loading = false;
                          });
                          return val;
                        });
                        Scaffold.of(context).showSnackBar(
                          ksnackBar(
                            context,
                            AuthErrorsHelper.getValue(authError),
                          ),
                        );
                        ksnackBar(
                          context,
                          AuthErrorsHelper.getValue(authError),
                        );
                      } else {
                        ksnackBar(context, 'Email is Not Valid');
                      }
                    },
                    child: Text("Submit")),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ],
        ),
      );
    }

    buildCollapsed2() {
      return buildImg(150);
    }

    buildExpanded2() {
      return buildImg(300);
    }

    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: ScrollOnExpand(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: !loading
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expandable(
                      collapsed: buildCollapsed1(),
                      expanded: buildExpanded1(),
                    ),
                    Expandable(
                      collapsed: buildCollapsed2(),
                      expanded: buildExpanded2(),
                    ),
                    Expandable(
                      collapsed: Container(),
                      expanded: buildExpanded3(),
                    ),
                    Divider(
                      height: 1,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Builder(
                          builder: (context) {
                            var controller = ExpandableController.of(context);
                            return TextButton(
                              child: Text(
                                controller.expanded ? "COLLAPSE" : "EXPAND",
                                style: Theme.of(context)
                                    .textTheme
                                    .button
                                    .copyWith(color: Colors.deepPurple),
                              ),
                              onPressed: () {
                                controller.toggle();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                )
              : kBuzyPage(),
        ),
      ),
    ));
  }
}
