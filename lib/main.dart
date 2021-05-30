import 'package:firebase_core/firebase_core.dart';
import 'package:helphub/Shared/Pages/About.dart';
import 'Shared/Widgets_and_Utility/MyTheme.dart';
import 'Students/UI/StudentHome.dart';
import 'imports.dart';
import 'package:helphub/Shared/Widgets_and_Utility/MyTheme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  timeDilation = 2;
  Provider.debugCheckInvalidValueType = null;
  setupLocator();
  runApp(
    MyApp(),
  );
}

final darkTheme = ThemeData(
    accentColor: mainColor,
    accentColorBrightness: Brightness.dark,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    backgroundColor: Colors.black);
final lightTheme = ThemeData(
  accentColor: mainColor,
  pageTransitionsTheme: PageTransitionsTheme(
    builders: {TargetPlatform.android: CupertinoPageTransitionsBuilder()},
  ),
);

ThemeData getTheme(MyTheme theme) {
  switch (theme) {
    case MyTheme.Light:
      return lightTheme;
      break;
    case MyTheme.Dark:
      return darkTheme;
      break;
    case MyTheme.System:
      return lightTheme;
      break;
    default:
      return darkTheme;
  }
}

ThemeMode getThemeMode(MyTheme theme) {
  switch (theme) {
    case MyTheme.Light:
      return ThemeMode.light;
      break;
    case MyTheme.Dark:
      return ThemeMode.dark;
      break;
    case MyTheme.System:
      return ThemeMode.system;
      break;
    default:
      return ThemeMode.system;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<MyTheme>.value(
            initialData: MyTheme.System,
            value: locator<ThemeClass>().themeController.stream),
        StreamProvider<Developer>.value(
            initialData: Developer(),
            value: locator<DeveloperProfileServices>()
                .loggedInDeveloperStream
                .stream),
        StreamProvider<Student>.value(
            initialData: Student(),
            value:
                locator<StudentProfileServices>().loggedInStudentStream.stream),
        StreamProvider<User>.value(
          initialData: null,
          value: locator<AuthenticationServices>().fireBaseUserStream.stream,
        ),
        StreamProvider<UserType>.value(
          initialData: UserType.UNKNOWN,
          value: locator<AuthenticationServices>().userTypeStream.stream,
        ),
        StreamProvider<bool>.value(
          initialData: false,
          value: locator<AuthenticationServices>().isUserLoggedInStream.stream,
        ),
      ],
      child: HelpHub(),
    );
  }
}

class HelpHub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MyTheme myTheme = Provider.of<MyTheme>(context);
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      title: 'Help Hub',
      routes: {
        StudentPage.id: (context) => StudentPage(),
        DeveloperHome.id: (context) => DeveloperHome(),
        StudentProfile.id: (context) => StudentProfile(),
        DeveloperProfile.id: (context) => DeveloperProfile(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        AboutPage.id: (context) => AboutPage()
      },
      themeMode: getThemeMode(myTheme),
      home: getHome(context),
    );
  }

  Widget getHome(BuildContext context) {
    Developer currentDeveloper = Provider.of<Developer>(context, listen: false);
    Student currentStudent = Provider.of<Student>(context, listen: false);
    UserType userType = Provider.of<UserType>(context, listen: false);
    bool isUserLoggedIn = Provider.of<bool>(context);
    if (Provider.of<User>(context) == null) {
      return WelcomeScreen();
    }

    if (userType == UserType.UNKNOWN) {
      return WelcomeScreen();
    }

    if (isUserLoggedIn) {
      if (userType == UserType.STUDENT) {
        return currentStudent != null
            ? currentStudent.displayName == null ||
                    currentStudent.displayName == ""
                ? StudentProfile()
                : StudentPage()
            : StudentProfile();
      }
      if (userType == UserType.DEVELOPERS) {
        return currentDeveloper != null
            ? currentDeveloper.displayName == null ||
                    currentDeveloper.displayName == ""
                ? DeveloperProfile()
                : DeveloperHome()
            : DeveloperProfile();
      }
    } else {
      return WelcomeScreen();
    }
    return WelcomeScreen();
  }
}
