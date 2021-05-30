import 'package:community_material_icon/community_material_icon.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:helphub/Shared/Widgets_and_Utility/MyTheme.dart';
import 'package:helphub/imports.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/simple_hidden_drawer.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class DeveloperHome extends StatefulWidget {
  static const id = 'DeveloperHome';

  @override
  _DeveloperHomeState createState() => _DeveloperHomeState();
}

List<Message> messages = [];
BigPictureStyleInformation photo;
Person person;
MessagingStyleInformation messageStyle;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();
Future<dynamic> configureNotificationToShow(Map message) async {
  print(message);
  Map notification = message['notification'];
  Map data = message["data"];
  var senderImage = await downloadAndSaveFile(data['sender_image'], "Icon");
  if (data['messageType'] == "photo") {
    var picturePath = await downloadAndSaveFile(notification['body'], "Photo");
    photo = BigPictureStyleInformation(FilePathAndroidBitmap(picturePath),
        largeIcon: FilePathAndroidBitmap(senderImage));
    showNotification(notification, notification['titile'], "Photo", photo);
  } else {
    person = Person(
      icon: BitmapFilePathAndroidIcon(senderImage),
      name: notification['title'],
    );
    Message message = Message(notification['body'], DateTime.now(), person);
    for (int i = 0; i <= messages.length; i++) {
      if (messages.length != 0) {
        if (messages[i].text != message.text) {
          if (messages.length != 5) {
            messages.add(message);
            print(message.text);
          } else {
            messages.removeAt(0);
            messages.add(message);
          }
        }
      } else {
        messages.add(message);
      }
    }
    messageStyle = MessagingStyleInformation(person, messages: messages);
    showNotification(notification, notification['titile'], notification['body'],
        messageStyle);
  }
  return Future<void>.value();
}

Future<String> downloadAndSaveFile(String url, String name) async {
  var directory = await getApplicationDocumentsDirectory();
  var path = '${directory.path}/$name';
  var res = await get(Uri.parse(url));
  var file = File(path);
  await file.writeAsBytes(res.bodyBytes);
  return path;
}

void showNotification(Map notification, String title, String body,
    StyleInformation styleInformation) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    Platform.isAndroid ? 'com.h2.helphub' : 'com.h2.helphub',
    'Help Hub',
    'your channel description',
    playSound: true,
    enableVibration: true,
    importance: Importance.max,
    groupKey: title,
    autoCancel: true,
    channelShowBadge: true,
    styleInformation: styleInformation,
    priority: Priority.high,
  );
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
      0, title, body, platformChannelSpecifics,
      payload: json.encode(notification));
}

class _DeveloperHomeState extends State<DeveloperHome>
    with SingleTickerProviderStateMixin {
  SharedPreferencesHelper sharedPreferencesHelper =
      locator<SharedPreferencesHelper>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  PageController pageController;
  int selectedIndex = 0;
  DocumentReference currentProjectReference;
  DocumentSnapshot snapShot;
  ThemeClass themeClass = locator<ThemeClass>();
  AnimationController _animationController;
  bool open = false;

  void showSnackbar(Map message) {
    Map notification = message['notification'];
    Map data = message['data'];
    Student student;
    if (enrolledstudents != null) {
      enrolledstudents.forEach((f) {
        if (f.email == data['senderId']) student = f;
      });
    }
    Flushbar(
      title: notification['title'],
      messageText: data['messageType'] == 'photo'
          ? Text("New Message: Photo", style: TextStyle(color: white))
          : Text("New message: ${notification['body']}",
              style: TextStyle(color: white)),
      backgroundColor: mainColor.withOpacity(0.6),
      barBlur: 50,
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      icon: Icon(Icons.chat, color: white),
      borderRadius: 15,
      //  padding: EdgeInsets.all(10),
      margin: EdgeInsets.fromLTRB(10, 7, 10, 7),
      animationDuration: Duration(milliseconds: 700),
      mainButton: TextButton(
          onPressed: () {
            kopenPage(
                context,
                Chat(
                    recieverId: data['senderId'],
                    userType: UserType.DEVELOPERS,
                    recieverImage: data['sender_image'],
                    student: student));
          },
          child: Text("Open", style: TextStyle(color: white))),
      duration: Duration(milliseconds: 2200),
    )..show(context);
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    pageController = PageController();
    registerNotification();
    configLocalNotification();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void handleOnPressed() {
    setState(() {
      open = !open;
      open ? _animationController.forward() : _animationController.reverse();
    });
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(microseconds: 150), curve: Curves.ease);
    });
    print(index);
  }

  void registerNotification() async {
    String currentUser = await sharedPreferencesHelper.getDevelopersId();

    FirebaseMessaging.onMessage.listen((event) {
      Map message = event.data;
      print('onMessage: $message');
      showSnackbar(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      Map message = event.data;
      showSnackbar(message);
    });

    FirebaseMessaging.onBackgroundMessage(
        (message) => configureNotificationToShow(message.data));

    firebaseMessaging.requestPermission();

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      FirebaseFirestore.instance
          .collection('users')
          .doc('Profile')
          .collection('Developers')
          .doc(currentUser)
          .update({'pushToken': token});
      sharedPreferencesHelper.setSenderToken(token);
    }).catchError((err) {
      Fluttertoast.showToast(
        msg: err.message.toString(),
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelect);
  }

  Future onSelect(message) {
    if (message['tag'] == 'chat') {
      enrolledstudents != null
          ? student = enrolledstudents
              .singleWhere((student) => student.displayName == message['title'])
          : student = null;
      student != null
          ? kopenPage(
              context,
              ChatScreen(
                recieverId: student.email,
                recieverImage: student.photoUrl,
                userType: UserType.DEVELOPERS,
                student: student,
              ))
          : setState(() {
              selectedIndex = 3;
            });
    } else {
      setState(() {
        selectedIndex = 1;
      });
    }
    return Future.delayed(Duration(seconds: 2));
  }

  Project project;
  Student student;
  List<Student> enrolledstudents;
  List<Student> requests;
  List<Project> allProject;

  int a = 0;
  @override
  Widget build(BuildContext context) {
    Developer developer = Provider.of<Developer>(context);
    MyTheme myTheme = Provider.of<MyTheme>(context);
    var login = locator<LoginPageModel>();
    return BaseView<DeveloperHomeModel>(
        onModelReady: (model) => model.getAll(),
        builder: (context, model, child) {
          if (model.state == ViewState.Idle) {
            if (a == 0) {
              allProject = model.allProject;
              project = model.project;
              requests = model.requests;
              student = model.student;
              enrolledstudents = model.enrolledstudents;
              a++;
            }
          }
          if (allProject == null ||
              project == null ||
              requests == null ||
              student == null ||
              enrolledstudents == null) {
            allProject = model.allProject;
            project = model.project;
            requests = model.requests;
            student = model.student;
            enrolledstudents = model.enrolledstudents;
            a++;
          }
          return Scaffold(
            body: SimpleHiddenDrawer(
              slidePercent: 65,
              isDraggable: true,
              enableCornerAnimation: true,
              verticalScalePercent: 99,
              enableScaleAnimation: true,
              menu: buildMenu(
                  changeTheme: (v) {
                    themeClass.changeTheme(v);
                  },
                  user: 'Developer',
                  name: developer.displayName,
                  imageUrl: developer.photoUrl,
                  profileRoute: DeveloperProfile.id,
                  animateIcon: handleOnPressed,
                  elevation: 5,
                  radius: 15,
                  infoChildren: [
                    SizedBox(height: 7),
                    Text(developer.email ?? '', style: infoStyle()),
                    SizedBox(height: 7),
                    Text(developer.language ?? '', style: infoStyle()),
                    SizedBox(height: 7),
                    Text(developer.qualification ?? '', style: infoStyle()),
                    SizedBox(height: 7),
                    Text(developer.experience ?? '', style: infoStyle()),
                    SizedBox(height: 7),
                    Text(developer.city ?? '', style: infoStyle()),
                    SizedBox(height: 7),
                    Text(developer.country ?? '', style: infoStyle()),
                    SizedBox(height: 7),
                  ]),
              screenSelectedBuilder: (position, cont) {
                return Scaffold(
                  key: scaffoldKey,
                  appBar: TopBar(
                    onTitleTapped: () {
                      login.logoutUser();
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => WelcomeScreen()));
                    },
                    title: title(),
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_close,
                      progress: _animationController,
                    ),
                    onPressed: () {
                      handleOnPressed();
                      cont.toggle();
                    },
                  ),
                  body: PageView(
                    pageSnapping: true,
                    physics: BouncingScrollPhysics(),
                    controller: pageController,
                    onPageChanged: (index) => onItemTapped(index),
                    children: <Widget>[
                      futurePageBuilder(
                          enrolledstudents, model.getenrolledStudents(),
                          child: (snap) => RefreshIndicator(
                                onRefresh: () {
                                  return refresh(model);
                                },
                                child: buildEnrolled(
                                    developer, snap ?? enrolledstudents),
                              )),
                      futurePageBuilder(requests, model.getrequestList(),
                          child: (snap) => RefreshIndicator(
                                onRefresh: () {
                                  return refresh(model);
                                },
                                child: buildRequest(model, snap ?? requests),
                              )),
                      RefreshIndicator(
                          onRefresh: () {
                            return refresh(model);
                          },
                          child: buildMyProject()),
                      futurePageBuilder(
                          enrolledstudents, model.getenrolledStudents(),
                          child: (snap) => RefreshIndicator(
                                onRefresh: () {
                                  return refresh(model);
                                },
                                child: buildChat(snap ?? enrolledstudents),
                              )),
                      futurePageBuilder(allProject, model.getAllProjects(),
                          child: (snap) => RefreshIndicator(
                              onRefresh: () {
                                return refresh(model);
                              },
                              child: buildAllProject(snap ?? allProject))),
                    ],
                  ),
                );
              },
            ),
            bottomNavigationBar: BottomNavyBar(
                iconSize: 30,
                selectedIndex: selectedIndex,
                onItemSelected: (index) => onItemTapped(index),
                itemCornerRadius: 15,
                showElevation: false,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                animationDuration: Duration(milliseconds: 150),
                curve: Curves.bounceInOut,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                items: [
                  bottomNavyBarItem(context,
                      icon: Icon(Icons.supervisor_account), text: "Enrolled"),
                  bottomNavyBarItem(context,
                      icon: Icon(Icons.recent_actors), text: "Requests"),
                  bottomNavyBarItem(context,
                      icon: Icon(Icons.personal_video),
                      text: "Current Project"),
                  bottomNavyBarItem(context,
                      icon: Icon(CommunityMaterialIcons.chat_processing),
                      text: "Chats"),
                  bottomNavyBarItem(context,
                      icon: Icon(Icons.pie_chart_outlined),
                      text: "All Projects"),
                ]),
          );
        });
  }

  Future<Null> refresh(DeveloperHomeModel model) async {
    await Future.delayed((Duration(milliseconds: 1200)));
    setState(() {
      model.getAll();
      a = 0;
    });
    return null;
  }

  String title() {
    switch (selectedIndex) {
      case 0:
        return "Home";
        break;
      case 1:
        return "Requests";
        break;
      case 2:
        return "Current Project";
        break;
      case 3:
        return "Chat";
        break;
      case 4:
        return 'All Projects';
        break;
      default:
        return "Home";
    }
  }

  Widget buildChat(List<Student> enrolledStudents) {
    if (enrolledStudents != null)
      return ListView.separated(
          separatorBuilder: (context, i) => Divider(color: black),
          itemCount: enrolledstudents.length,
          itemBuilder: (context, index) {
            return chatList(enrolledstudents[index]);
          });
    else
      return Center(
        child: Text("No chats"),
      );
  }

  Widget chatList(Student student) {
    return ListTile(
      isThreeLine: true,
      onLongPress: () => kopenPage(
          context,
          StudentDetail(
            isARequest: false,
            student: student,
          )),
      onTap: () => kopenPage(
          context,
          Chat(
              recieverId: student.email,
              recieverImage: student.photoUrl,
              student: student,
              userType: UserType.DEVELOPERS)),
      leading: Hero(
        tag: '${student.displayName}+1',
        child: imageBuilder(
          student.photoUrl,
          placeHolder: CircleAvatar(
            backgroundImage: setImage(null, ConstassetsString.student),
          ),
          child: CircleAvatar(
            backgroundImage:
                setImage(student.photoUrl, ConstassetsString.student),
          ),
        ),
      ),
      title: Hero(
          transitionOnUserGestures: true,
          tag: student.email,
          child: Card(
            color: Colors.transparent,
            child: Text(student.displayName),
            elevation: 0,
          )),
      subtitle: Text(student.email),
      trailing: Hero(
        transitionOnUserGestures: true,
        tag: student.displayName,
        child: Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget buildAllProject(List<Project> projects) {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            child: child,
            scale: animation,
          );
        },
        child: projects.length != 0
            ? ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return AllProjects(
                    userType: UserType.DEVELOPERS,
                    project: projects[index],
                  );
                })
            : Text("No Projects"));
  }

  Widget buildMyProject() {
    return MyProject(
      userType: UserType.DEVELOPERS,
      val: false,
      allProject: false,
    );
  }

  Widget buildRequest(DeveloperHomeModel model, List<Student> request) {
    if (request != null)
      return AnimatedSwitcher(
          duration: Duration(milliseconds: 600),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              child: child,
              scale: animation,
            );
          },
          child: request.length == 0
              ? Center(
                  child: Text("No requests"),
                )
              : ListView.builder(
                  itemCount: request.length,
                  itemBuilder: (context, index) {
                    return requestList(student: request[index], model: model);
                  },
                ));
    else
      return kBuzyPage();
  }

  failed(String state) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Failed"),
            content: Text("Something went wrong, failed to $state the request"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Ok'))
            ],
          );
        });
  }

  Widget requestList({Student student, DeveloperHomeModel model}) {
    return GestureDetector(
      onTap: () => kopenPage(
          context,
          StudentDetail(
            isARequest: true,
            student: student,
          )),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Card(
          child: Row(
            children: <Widget>[
              imageBuilder(
                student.photoUrl,
                placeHolder: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: setImage(null, ConstassetsString.student))),
                ),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: setImage(
                              student.photoUrl, ConstassetsString.student))),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(student.displayName),
                  Text(student.email),
                ],
              ),
              Spacer(),
              IconButton(
                  icon: model.state2 == ViewState.Busy
                      ? SpinKitPulse(
                          color: mainColor,
                        )
                      : Icon(Icons.cancel),
                  onPressed: () async {
                    await rejectRequest(model, student).then((val) {
                      if (val) {
                        requests.remove(student);
                      } else {
                        failed('reject');
                      }
                    });
                  }),
              IconButton(
                  icon: model.state == ViewState.Busy
                      ? SpinKitPulse(
                          color: mainColor,
                        )
                      : Icon(Icons.done),
                  onPressed: () async {
                    await acceptRequest(model, student).then((val) {
                      if (val) {
                        requests.remove(student);
                      } else {
                        failed('accept');
                      }
                    });
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> acceptRequest(DeveloperHomeModel model, Student student) async {
    bool val = false;
    if (model.state == ViewState.Idle) {
      val = await model.acceptRequest(student);
    }
    return val;
  }

  Future<bool> rejectRequest(DeveloperHomeModel model, Student student) async {
    bool val = false;
    if (model.state == ViewState.Idle) {
      val = await model.rejectRequest(student);
    }
    return val;
  }

  Widget buildEnrolled(Developer developer, List<Student> student) {
    if (student == null) {
      return kBuzyPage();
    } else {
      return student.length != 0
          ? ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: student.length,
              itemBuilder: (context, index) {
                return enrolledList(student: student[index]);
              },
            )
          : Center(
              child: Text("No Students Enrolled"),
            );
    }
  }

  Widget enrolledList({Student student}) {
    var media = MediaQuery.of(context);
    Orientation orientation = media.orientation;
    Size size = media.size;
    double height = size.height;
    double width = size.width;
    var name = student.displayName.split(' ');
    String firstName = name[0];

    String lastName = (name.length > 1) ? name[1] : " "; //Ali
    return GestureDetector(
      onTap: () => kopenPage(
          context,
          StudentDetail(
            student: student,
            isARequest: false,
          )),
      child: Padding(
        padding: EdgeInsets.only(top: 18.0),
        child: Container(
          alignment: Alignment.center,
          child: Hero(
            tag: '${student.displayName}+1',
            child: Material(
              elevation: 0.7,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                  height: (orientation == Orientation.portrait)
                      ? height / 5.31
                      : 150,
                  width:
                      (orientation == Orientation.portrait) ? width - 50 : 350,
                  margin: EdgeInsets.only(top: 10),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [mainColor, Colors.blue[900]])),
                        margin: EdgeInsets.only(top: 90),
                        height: (orientation == Orientation.portrait)
                            ? height / 10
                            : 70,
                        width: (orientation == Orientation.portrait)
                            ? width - 50
                            : 350,
                      ),
                      Container(
                        margin: EdgeInsets.all(5),
                        child: CircleAvatar(
                          backgroundColor: Colors.blue[900],
                          radius: 70,
                          child: student.photoUrl == null
                              ? imageBuilder(student.photoUrl,
                                  child: CircleAvatar(
                                    backgroundImage: setImage(student.photoUrl,
                                        ConstassetsString.student),
                                    backgroundColor: mainColor,
                                    radius: 68,
                                  ),
                                  placeHolder: CircleAvatar(
                                    backgroundImage: setImage(student.photoUrl,
                                        ConstassetsString.student),
                                    backgroundColor: mainColor,
                                    radius: 68,
                                  ))
                              : CircleAvatar(
                                  backgroundImage: setImage(student.photoUrl,
                                      ConstassetsString.student),
                                  backgroundColor: mainColor,
                                  radius: 68,
                                ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 15, left: 150),
                        child: Text(
                          '$firstName'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 37,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue[900]),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 43, left: 150),
                        child: Text(
                          '$lastName'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue[900]),
                        ),
                      ),
                      Container(
                        color: mainColor,
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(top: 67, left: 150),
                        child: Text(
                          '${student.qualification}'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue[50]),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 95, left: 150),
                        child: Text(
                          '${student.email}',
                          style:
                              TextStyle(fontSize: 16, color: Colors.blue[50]),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 110, left: 200),
                        child: Text(
                          '${student.city}'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.blue[50]),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ),

        // TODO: Old UI
        //child: Container(
        //   height: height / 4,
        //   child: Card(
        //     elevation: 3,
        //     shape:
        //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        //     child: Column(
        //       mainAxisSize: MainAxisSize.max,
        //       children: <Widget>[
        //         Expanded(
        //             child: Hero(
        //           tag: '${student.displayName}+1',
        //           child: Container(
        //             decoration: BoxDecoration(
        //               image: DecorationImage(
        //                 image: setImage(
        //                     student.photoUrl, ConstassetsString.student),
        //                 fit: BoxFit.cover,
        //               ),
        //             ),
        //           ),
        //         )),
        //         Padding(
        //           padding: EdgeInsets.all(8.0),
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: <Widget>[
        //               Text(student.displayName),
        //               Text(student.qualification)
        //             ],
        //           ),
        //         )
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
