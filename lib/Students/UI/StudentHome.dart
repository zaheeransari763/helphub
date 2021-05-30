import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:helphub/Shared/Widgets_and_Utility/MyTheme.dart';
import 'package:helphub/Students/UI/DeveloperDetail.dart';
import 'package:helphub/imports.dart';
import 'package:hidden_drawer_menu/simple_hidden_drawer/simple_hidden_drawer.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import 'DevelopersCard.dart';

class StudentPage extends StatefulWidget {
  static String id = 'student';
  StudentPage({Key key}) : super(key: key);

  @override
  _StudentPageState createState() => _StudentPageState();
}

Future<String> downloadAndSaveFile(String url, String name) async {
  var directory = await getApplicationDocumentsDirectory();
  var path = '${directory.path}/$name';
  var res = await get(Uri.parse(url));
  var file = File(path);
  await file.writeAsBytes(res.bodyBytes);
  return path;
}

List<Message> messages = [];
BigPictureStyleInformation photo;
Person person;
MessagingStyleInformation messageStyle;

Future<dynamic> configureNotificationToShow(Map message) async {
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
    showNotification(
        notification, notification['titile'], "Text", messageStyle);
  }
  return Future<void>.value();
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

class _StudentPageState extends State<StudentPage>
    with SingleTickerProviderStateMixin {
  SwiperController _swiperController;
  PageController pageController;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  SharedPreferencesHelper sharedPreferencesHelper =
      locator<SharedPreferencesHelper>();

  AnimationController _animationController;
  bool open = false;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    super.initState();

    registerNotification();
    configLocalNotification();
    _swiperController = SwiperController();
    pageController = PageController();
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

  void registerNotification() async {
    String currentUser = await sharedPreferencesHelper.getStudentsEmail();
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

    firebaseMessaging.getToken().then((token) async {
      print('token: $token');
      FirebaseFirestore.instance
          .collection('users')
          .doc('Profile')
          .collection('Students')
          .doc(currentUser)
          .update({'pushToken': token});
      await sharedPreferencesHelper.setSenderToken(token);
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
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  ThemeClass themeClass = locator<ThemeClass>();
  void showSnackbar(Map message) {
    Map notification = message['notification'];
    Map data = message['data'];
    if (student != null && student.enrolled && _selectedIndex != 2) {
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
              _onItemTapped(2);
            },
            child: Text("Open", style: TextStyle(color: white))),
        duration: Duration(milliseconds: 2200),
      )..show(context);
    }
  }

  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageController.animateToPage(_selectedIndex,
          duration: Duration(microseconds: 150), curve: Curves.ease);
    });
  }

  int a = 0;

  Future<Null> refresh(StudentHomeModel model) async {
    await Future.delayed((Duration(milliseconds: 1200)));
    setState(() {
      model.getAll();
      //model.checkEnrolled();
      a = 0;
    });
    return null;
  }

  String buildenrolledtitle() {
    switch (_selectedIndex) {
      case 0:
        return "Developer";
        break;
      case 1:
        return "My Current Project";
        break;
      case 2:
        return "Chat";
        break;
      case 3:
        return "All Projects";
        break;
      default:
        return "Home";
    }
  }

  String buildtitle() {
    switch (_selectedIndex) {
      case 0:
        return "Explore";
        break;
      case 1:
        return "All Projects";
        break;
      default:
        return "Home";
    }
  }

  List<Developer> developers;
  List<Project> projects;
  Developer developer;
  Student student;
  Project project;

  @override
  Widget build(BuildContext context) {
    MyTheme myTheme = Provider.of<MyTheme>(context);
    return BaseView<StudentHomeModel>(
      onModelReady: (model) => model.getAll(),
      builder: (context, model, child) {
        if (student == null) {
          if (model.student != null) {
            student = model.student;
            a++;
          } else {
            model.getStudentProfile();
            student = model.student;
            a++;
          }
        } else {
          if (student.enrolled) {
            if (developer == null || projects == null || project == null) {
              if (model.project == null ||
                  model.enrolleddeveloper == null ||
                  model.projects == null) {
                model.getEnrolledDeveloperProfile();
                model.getStudentProject();
                model.getProjects();
                if (model.state == ViewState.Idle) {
                  developer = model.enrolleddeveloper;
                  project = model.project;
                  projects = model.projects;
                  a++;
                }
              } else {
                developer = model.enrolleddeveloper;
                project = model.project;
                projects = model.projects;
                a++;
              }
            }
          } else {
            if (model.developers == null || model.projects == null) {
              model.getDevelopers();
              model.getProjects();
              if (model.state == ViewState.Idle) {
                developers = model.developers;
                projects = model.projects;
                a++;
              }
            } else {
              developers = model.developers;
              projects = model.projects;
              a++;
            }
          }
        }
        /*  if (model.state == ViewState.Idle) {
          if (a == 0) {
            //  model.getStudentProfile();
            student = model.student;
            //  model.getEnrolledDeveloperProfile();
            developer = model.enrolleddeveloper;
            //   model.getProjects();
            projects = model.projects;
            //  model.getDevelopers();
            developers = model.developers;
            //   model.getStudentProject();
            project = model.project;
            a++;
          }
        } */
        return Scaffold(
            backgroundColor: Colors.white,
            body: futurePageBuilder<Student>(
                student, student == null ? model.getStudentProfile() : null,
                child: (studentSnap) {
              if (studentSnap != null)
                return SimpleHiddenDrawer(
                    slidePercent: 65,
                    isDraggable: true,
                    verticalScalePercent: 99,
                    
                    menu: buildMenu(
                        changeTheme: (v) {
                          myTheme = v;
                          themeClass.changeTheme(myTheme);
                        },
                        elevation: 5,
                        radius: 15,
                        user: 'Student', 
                        name: student.displayName ?? studentSnap.displayName,
                        imageUrl: studentSnap.photoUrl ?? student.photoUrl,
                        profileRoute: StudentProfile.id,
                        animateIcon: handleOnPressed,
                        infoChildren: [
                          SizedBox(height: 7),
                          Text(student.email ?? '', style: infoStyle()),
                          SizedBox(height: 7),
                          Text(student.qualification ?? '', style: infoStyle()),
                          SizedBox(height: 7),
                          Text(student.yearofcompletion ?? '',
                              style: infoStyle()),
                          SizedBox(height: 7),
                          Text(student.city ?? '', style: infoStyle()),
                          SizedBox(height: 7),
                          Text(student.country ?? '', style: infoStyle()),
                          SizedBox(height: 7),
                        ]),
                    screenSelectedBuilder: (position, bloc) {
                      return Scaffold(
                        key: _scaffoldKey,
                        appBar: TopBar(
                            title: student.enrolled == true
                                ? buildenrolledtitle()
                                : buildtitle(),
                            child: AnimatedIcon(
                                icon: AnimatedIcons.menu_close,
                                progress: _animationController),
                            onPressed: () {
                              handleOnPressed();
                              bloc.toggle();
                            }),
                        body: student.enrolled == true
                            ? futurePageBuilder<Developer>(
                                developer, model.getEnrolledDeveloperProfile(),
                                child: (snap) {
                                return PageView(
                                    physics: BouncingScrollPhysics(),
                                    controller: pageController,
                                    onPageChanged: (index) {
                                      _onItemTapped(index);
                                    },
                                    children: enrolledbody(
                                        studentSnap ?? student,
                                        snap ?? developer,
                                        model,
                                        project,
                                        projects));
                              })
                            : futurePageBuilder<List<Developer>>(
                                developers, model.getDevelopers(),
                                child: (snap) {
                                return PageView(
                                  physics: BouncingScrollPhysics(),
                                  controller: pageController,
                                  onPageChanged: (index) {
                                    _onItemTapped(index);
                                  },
                                  children: notEnrolledbody(
                                      student ?? studentSnap,
                                      model,
                                      snap ?? developers,
                                      projects),
                                );
                              }),
                      );
                    });
              else
                return kBuzyPage();
            }),
            bottomNavigationBar: student != null
                ? BottomNavyBar(
                    itemCornerRadius: 15,
                    showElevation: false,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    animationDuration: Duration(milliseconds: 150),
                    curve: Curves.bounceInOut,
                    selectedIndex: _selectedIndex,
                    items: student.enrolled == false
                        ? notEnrolled(context)
                        : enrolled(context),
                    onItemSelected: (index) => _onItemTapped(index))
                : null);
      },
    );
  }

  Widget buildMyProjects(Project project) {
    return MyProject(
      userType: UserType.STUDENT,
      val: false,
      allProject: false,
      project: project,
    );
  }

  Widget buildAllProjects(bool isEnrolled, List<Project> projects) {
    return projects != null
        ? projects.length == 0
            ? Center(
                child: Text("No Projects"),
              )
            : ListView.builder(
                itemCount: projects.length,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return AllProjects(
                      userType: UserType.STUDENT,
                      project: projects[index],
                      enrolled: isEnrolled);
                })
        : kBuzyPage();
  }

  Widget buildChat(Developer developer) {
    return Chat(
      recieverId: developer.id,
      recieverImage: developer.photoUrl,
      userType: UserType.STUDENT,
      developer: developer,
    );
  }

  Widget buildDeveloperProfile(Developer developer) {
    if (developer.displayName != 'N.A') {
      return DeveloperDetail(
        card: false,
        developer: developer,
      );
    } else {
      return Center(
        child: Text("Something went wrong"),
      );
    }
  }

  List<Widget> notEnrolledbody(Student student, StudentHomeModel model,
      List<Developer> developers, List<Project> projects) {
    Size size = MediaQuery.of(context).size;
    return [
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(
              height: size.height / 13,
            ),
            Padding(
              padding: EdgeInsets.only(left: size.width / 10),
              child: Text(
                "Hello, ${student.displayName}",
                style: TextStyle(fontSize: 28),
              ),
            ),
            SizedBox(
              height: size.height / 70,
            ),
            Padding(
              padding: EdgeInsets.only(
                left: size.width / 10,
              ),
              child: Text(
                  '''Looks like you're not enrolled yet, choose any developer
from below and get to work''',
                  style: TextStyle(fontSize: 17)),
            ),
            Spacer(),
            developers != null
                ? Container(
                    height: MediaQuery.of(context).size.height / 1.65,
                    child: Swiper(
                      viewportFraction: 1,
                      controller: _swiperController,
                      loop: false,
                      itemCount: developers.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.only(
                              left: size.width / 10 /* , right: 30 */),
                          child: DevelopersCard(
                            student: student,
                            developer: developers[index],
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text("Something went wrong"),
                  )
          ],
        ),
      ),
      buildAllProjects(false, projects),
    ];
  }

  List<Widget> enrolledbody(Student student, Developer developer,
      StudentHomeModel model, Project project, List<Project> projects) {
    return [
      buildDeveloperProfile(developer),
      buildMyProjects(project),
      buildChat(developer),
      buildAllProjects(true, projects),
    ];
  }

  List<BottomNavyBarItem> notEnrolled(BuildContext context) => [
        bottomNavyBarItem(context,
            icon: Icon(Icons.person_outline), text: 'Explore Developers'),
        bottomNavyBarItem(context,
            icon: Icon(Icons.personal_video), text: 'Projects'),
      ];

  List<BottomNavyBarItem> enrolled(BuildContext context) => [
        bottomNavyBarItem(context,
            icon: Icon(Icons.person_outline), text: 'Developer'),
        bottomNavyBarItem(context,
            icon: Icon(Icons.personal_video), text: 'My Project'),
        bottomNavyBarItem(context, icon: Icon(Icons.chat), text: 'Chat'),
        bottomNavyBarItem(context,
            icon: Icon(Icons.pie_chart_outlined), text: 'All Projects')
      ];
}
