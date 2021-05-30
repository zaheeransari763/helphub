import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:helphub/Shared/Pages/About.dart';
import 'package:helphub/Shared/Widgets_and_Utility/MyTheme.dart';
import 'package:helphub/imports.dart';
import 'package:hidden_drawer_menu/hidden_drawer_menu.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'ImageCompress.dart';

var kTextFieldDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  hintStyle: TextStyle(height: 1.5, fontWeight: FontWeight.w300),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
);

ShapeBorder kRoundedButtonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(50)),
);

ShapeBorder kBackButtonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topRight: Radius.circular(30),
  ),
);

ShapeBorder kCardCircularShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(50)),
);

Widget kBackBtn = Icon(
  Icons.arrow_back_ios,
  // color: black54,
);

kopenPage(BuildContext context, Widget page) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (BuildContext context) => page,
    ),
  );
}

kBuzyPage({Color color = Colors.white}) {
  return Align(
    alignment: Alignment.center,
    child: SpinKitThreeBounce(
      color: color ?? Colors.white,
      size: 20.0,
    ),
  );
}

kbackBtn(BuildContext context) {
  Navigator.pop(context);
}

Future<String> getImage(
  bool mounted,
) async {
  String _path;
  File file = await takeCompressedPicture();
  if (file != null) _path = file.path;
  String croppedImage = await cropImage(_path);
  if (!mounted) return '';
  return croppedImage;
}

Future<String> cropImage(String path) async {
  String imagepath;
  File croppedImage = await ImageCropper.cropImage(
      sourcePath: path,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.square,
      ],
      androidUiSettings: AndroidUiSettings(
          cropFrameColor: mainColor,
          cropGridColor: mainColor,
          lockAspectRatio: false,
          toolbarTitle: "Crop Image",
          toolbarColor: mainColor,
          activeControlsWidgetColor: mainColor,
          initAspectRatio: CropAspectRatioPreset.original,
          toolbarWidgetColor: white));
  if (croppedImage != null) imagepath = croppedImage.path;
  return imagepath;
}

ShapeBorder bordershape(double radius) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(right: Radius.circular(radius ?? 15)),
  );
}

SnackBar ksnackBar(BuildContext context, String message, {Function onPressed}) {
  return SnackBar(
    duration: Duration(seconds: 2),
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    backgroundColor: Theme.of(context).primaryColor,
  );
}

TextStyle infoStyle() {
  return TextStyle(fontSize: 17, fontWeight: FontWeight.w300);
}

Widget profileMaterialButton(Size size,
    {@required Function onPressed,
    @required String text,
    double elevation,
    double radius}) {
  return Container(
      width: size.height / 4,
      child: MaterialButton(
          color: Colors.white,
          shape: bordershape(radius ?? 10),
          elevation: elevation ?? 3,
          child: Container(
            margin: EdgeInsets.only(left: 10),
            child: Align(alignment: Alignment.centerLeft, child: Text(text)),
          ),
          onPressed: () {
            return onPressed();
          }));
}

Widget profileFlatButton(Size size,
    {@required Function onPressed,
    @required text,
    BorderRadiusGeometry radius}) {
  return InkWell(
    borderRadius: radius ?? BorderRadius.circular(0),
    onTap: () {
      onPressed();
    },
    child: Container(
      width: size.height / 4,
      height: size.height / 20 - 7,
      margin: EdgeInsets.only(left: 10),
      decoration:
          BoxDecoration(borderRadius: radius ?? BorderRadius.circular(0)),
      child: Align(alignment: Alignment.centerLeft, child: Text(text)),
    ),
  );
}

Card drawerProfileImageCard(Size size, BuildContext context,
    {ImageProvider image, double elevation, double radius}) {
  return Card(
    shadowColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black,
    elevation: elevation ?? 3,
    shape: bordershape(radius ?? 22),
    margin: EdgeInsets.all(0),
    child: Container(
      height: size.height / 3.5,
      width: size.height / 3.8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(22)),
          image: DecorationImage(fit: BoxFit.cover, image: image)),
    ),
  );
}

TextStyle detailtitleStyle(context) {
  return TextStyle(
      fontSize: MediaQuery.of(context).size.width / 24,
      fontWeight: FontWeight.w700);
}

TextStyle detailvalueStyle(context) {
  return TextStyle(
      fontSize: MediaQuery.of(context).size.width / 24,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w300);
}

Widget drawerProfileInfo(Size size, BuildContext context,
    {List<Widget> children, double elevation, double radius}) {
  return Card(
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white,
    shadowColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.white38
        : Colors.black,
    margin: EdgeInsets.only(left: 0),
    shape: bordershape(radius ?? 15),
    elevation: elevation ?? 3,
    child: Container(
      width: size.height / 4,
      margin: EdgeInsets.only(left: 10, right: 0, top: 12, bottom: 10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: children),
    ),
  );
}

Card drawerNameCard(Size size, BuildContext context,
    {String user, String name, double elevation, double radius}) {
  return Card(
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white,
    shadowColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.white38
        : Colors.black,
    margin: EdgeInsets.only(left: 0),
    shape: bordershape(radius ?? 15),
    elevation: elevation ?? 3,
    child: Container(
      width: size.height / 4,
      margin: EdgeInsets.only(left: 10, right: 0, top: 12, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(user,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w400,
              )),
          SizedBox(
            height: 10,
          ),
          Text(name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              )),
        ],
      ),
    ),
  );
}

LayoutBuilder buildMenu({
  @required String user,
  @required String name,
  @required String imageUrl,
  @required String profileRoute,
  @required Function animateIcon,
  @required double elevation,
  @required double radius,
  @required Function(MyTheme) changeTheme,
  @required List<Widget> infoChildren,
}) {
  LoginPageModel model = locator<LoginPageModel>();
  return LayoutBuilder(builder: (context, snapshot) {
    //MyTheme myTheme = Provider.of(context);
    Size size = MediaQuery.of(context).size;
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    IconData myIcon = darkMode ? Icons.wb_sunny : Icons.nightlight_round;
    return SafeArea(
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx < 0) {
            animateIcon();
            SimpleHiddenDrawerController.of(context).toggle();
            
          }
        },
        onTap: () {
          animateIcon();
          SimpleHiddenDrawerController.of(context).toggle();
          
        },
        child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            child: Align(
              alignment: Alignment.topLeft,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Spacer(),
                    AnimatedSwitcher(
                      key: ValueKey(myIcon),
                      duration: Duration(milliseconds: 500),
                      child: IconButton(
                        icon: Icon(myIcon),
                        onPressed: () {
                          darkMode
                              ? changeTheme(MyTheme.Light)
                              : changeTheme(MyTheme.Dark);
                        },
                      ),
                    ),
                    Spacer(),
                    drawerNameCard(
                      size,
                      context,
                      elevation: elevation,
                      user: user,
                      name: name,
                    ),
                    Spacer(),
                    imageBuilder(
                      imageUrl,
                      child: drawerProfileImageCard(size, context,
                          image: setImage(
                              imageUrl,
                              user == 'Student'
                                  ? ConstassetsString.student
                                  : ConstassetsString.developer),
                          elevation: elevation),
                      placeHolder: drawerProfileImageCard(size, context,
                          image: setImage(
                              null,
                              user == 'Student'
                                  ? ConstassetsString.student
                                  : ConstassetsString.developer),
                          elevation: elevation),
                    ),
                    Spacer(),
                    drawerProfileInfo(size, context,
                        children: infoChildren, elevation: elevation),
                    Spacer(),
                    Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      shadowColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38
                              : Colors.black,
                      elevation: elevation,
                      margin: EdgeInsets.all(0),
                      child: profileFlatButton(size,
                          radius: BorderRadius.horizontal(
                              right: Radius.circular(radius ?? 15)),
                          onPressed: () {
                        animateIcon();
                        SimpleHiddenDrawerController.of(context).toggle();
                        Navigator.of(context).pushNamed(profileRoute);
                      }, text: 'Edit Profile'),
                    ),
                    Spacer(),
                    Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      shadowColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38
                              : Colors.black,
                      shape: bordershape(15),
                      elevation: elevation ?? 5,
                      margin: EdgeInsets.all(0),
                      child: Container(
                        width: size.height / 3.86,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            profileFlatButton(size,
                                radius: BorderRadius.only(
                                    topRight: Radius.circular(radius ?? 15)),
                                onPressed: () {
                              animateIcon();
                              SimpleHiddenDrawerController.of(context).toggle();
                              Navigator.of(context)
                                  .pushReplacementNamed(WelcomeScreen.id);
                              model.logoutUser();
                            }, text: "Logout"),
                            Divider(color: black, height: 3),
                            profileFlatButton(size, onPressed: () {
                              animateIcon();
                              SimpleHiddenDrawerController.of(context).toggle();
                              // Navigator.of(context).pushNamed(//TODO: Feedback route);
                            }, text: "Complaints & Feedback"),
                            Divider(color: black, height: 3),
                            profileFlatButton(size,
                                radius: BorderRadius.only(
                                    bottomRight: Radius.circular(radius ?? 15)),
                                onPressed: () {
                              animateIcon();
                              SimpleHiddenDrawerController.of(context).toggle();
                              Navigator.of(context).pushNamed(AboutPage.id);
                            }, text: "About")
                          ],
                        ),
                      ),
                    ),
                    /* Spacer(),
                    Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      shadowColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38
                              : Colors.black,
                      elevation: elevation,
                      margin: EdgeInsets.all(0),
                      child: profileFlatButton(size,
                          radius: BorderRadius.horizontal(
                              right: Radius.circular(radius ?? 15)),
                          onPressed: () {
                        changeTheme(MyTheme.Light);
                      }, text: 'Light Mode'),
                    ),
                    Card(
                      elevation: elevation,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      shadowColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white38
                              : Colors.black,
                      margin: EdgeInsets.all(0),
                      child: profileFlatButton(size,
                          radius: BorderRadius.horizontal(
                              right: Radius.circular(radius ?? 15)),
                          onPressed: () {
                        changeTheme(MyTheme.Dark);
                      }, text: 'Dark Mode'),
                    ), */
                    Spacer(),
                  ]),
            )),
      ),
    );
  });
}

FutureBuilder<http.Response> imageBuilder(String url,
    {Widget child, Widget placeHolder}) {
  return FutureBuilder<http.Response>(
      future: http.get(Uri.parse(url)),
      builder: (context, snapshot) {
        if (snapshot != null && snapshot.data != null) {
          if (snapshot.data.statusCode == 200) {
            return child;
          } else {
            return placeHolder;
          }
        } else {
          return placeHolder;
        }
      });
}

FutureBuilder<Object> futurePageBuilder<Object>(
    Object object, Future<Object> future,
    {@required Widget Function(Object snapshotData) child}) {
  return FutureBuilder(
      future:
          object == null ? future : Future.delayed(Duration(milliseconds: 10)),
      builder: (context, snapshot) {
        if ((snapshot != null && snapshot.data != null) || object != null) {
          return child(snapshot.data ?? object);
        } else {
          return kBuzyPage();
        }
      });
}

BottomNavyBarItem bottomNavyBarItem(
  BuildContext context, {
  Icon icon,
  String text,
}) {
  return BottomNavyBarItem(
      activeColor: mainColor,
      textAlign: TextAlign.center,
      inactiveColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black,
      icon: icon,
      title: Text(text));
}

ImageProvider<dynamic> setImage(String url, String defaultImage) {
  if (url != "default" && url != null && url != "") {
    return NetworkImage(
      url,
    );
  } else {
    return AssetImage(defaultImage);
  }
}

Widget toast(String message) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    child: Text(message),
  );
}

/* ImageProvider<dynamic> setImage(String url, String defaultImage) {
  return url != "default"
      ? FadeInImage.assetNetwork(placeholder: defaultImage, image: url)
      : AssetImage(defaultImage);
} */
