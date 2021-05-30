
import 'package:helphub/imports.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  static String id = "AboutPage";
  const AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String appName = "app";
  String appVersion;
  String buildNumber;

  @override
  void initState() {
    PackageInfo.fromPlatform().then((packageInfo) {
      appName = packageInfo.appName;
      appVersion = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: TopBar(
        titleTag: "title",
        child: kBackBtn,
        title: "About",
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                appName,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 35,
                    fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 15),
              Card(
                shape: CircleBorder(),
                elevation: 5,
                child: Image(
                  height: MediaQuery.of(context).size.width / 1.2,
                  width: MediaQuery.of(context).size.width / 1.2,

                  image: AssetImage(ConstassetsString.icon2))),
              SizedBox(height: 15),
              Text(
                "Version $appVersion",
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Text(
                "Build Number $buildNumber",
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: "Created By: ",
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: "Hassan Ansari & Hassan Momin")
                ]),
              ),
              SizedBox(height: 10),
              GestureDetector(
                  onTap: () {
                    launch("mailto:cth001100@gmail.com");
                  },
                  child: Text("Contact Us"))
            ],
          ),
        ),
      ),
    ));
  }
}
