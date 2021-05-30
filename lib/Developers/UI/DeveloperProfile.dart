import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helphub/core/enums/ViewState.dart';
import 'package:helphub/imports.dart';

class DeveloperProfile extends StatefulWidget {
  static const id = 'DeveloperProfilePage';
  DeveloperProfile({Key key}) : super(key: key);

  _DeveloperProfileState createState() => _DeveloperProfileState();
}

class _DeveloperProfileState extends State<DeveloperProfile> {
  DateTime year;
  String path = 'default';
  int a = 0;
  // String tempPath = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SharedPreferencesHelper _sharedPreferencesHelper =
      locator<SharedPreferencesHelper>();

  Future<Developer> getDeveloperData(Developer developer) async {
    String value = await _sharedPreferencesHelper.getDeveloper();
    final jsonData = json.decode(value);
    developer = Developer.fromJson(jsonData);
    print(value);
    return developer;
  }

  String _name = '';
  String _qualification = '';
  String _experience = '';
  String _city = '';
  String _country = '';
  String language = '';

  floatingButoonPressed(
      var model, Developer developer, User firebaseUser) async {
    bool res = false;
    if (_name.isEmpty ||
        _qualification.isEmpty ||
        _experience.isEmpty ||
        _city.isEmpty ||
        _country.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(
        ksnackBar(
            context, 'You Need to fill all the details and a profile Photo'),
      );
    } else {
      if (model.state == ViewState.Idle) {
        developer = Developer(
            displayName: _name,
            email: developer.email,
            firebaseUid: developer.firebaseUid,
            id: await _sharedPreferencesHelper.getDevelopersId(),
            photoUrl: path,
            country: _country,
            city: _city,
            language: language,
            experience: _experience,
            qualification: _qualification);
        res = await model.setDeveloperProfileData(
          developer,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc('Profile')
            .collection('Developers')
            .doc(developer.id)
            .update(developer.updateProfile(developer));
      }
    }

    if (res == true) {
      Navigator.pushNamedAndRemoveUntil(
          context, DeveloperHome.id, (r) => false);
    }
  }

  String buildTitle(Developer developer) {
    if (developer != null) {
      if (developer.displayName != null) {
        return developer.displayName != ""
            ? developer.displayName
            : ConstString.profile;
      }
      return ConstString.profile;
    } else {
      return ConstString.profile;
    }
  }

  @override
  Widget build(BuildContext context) {
    var firebaseUser = Provider.of<User>(context);
    var developer = Provider.of<Developer>(context);
    double width = MediaQuery.of(context).size.width;

    return BaseView<DeveloperProfilePageModel>(
        onModelReady: (model) => model.getDeveloperProfileData(),
        builder: (context, model, child) {
          if (model.state == ViewState.Idle) {
            if (a == 0) {
              _name = developer.displayName;
              path = developer.photoUrl;
              _qualification = developer.qualification;
              _experience = developer.experience;
              _city = developer.city;
              _country = developer.country;
              language = developer.language;
              a++;
            }
          }
          return Scaffold(
            key: _scaffoldKey,
            appBar: TopBar(
              titleTag: "title",
              title: //Text(
                  buildTitle(developer),
              //),
              child: kBackBtn,
              onPressed: () {
                if (model.state ==
                    ViewState.Idle) if (Navigator.canPop(context))
                  Navigator.pop(context);
              },
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: 'Save',
              elevation: 20,
              onPressed: () async {
                await floatingButoonPressed(model, developer, firebaseUser);
              },
              child: model.state == ViewState.Busy
                  ? SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 20,
                    )
                  : Icon(Icons.check),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    // fit: StackFit.loose,
                    children: <Widget>[
                      model.state2 == ViewState.Busy
                          ? kBuzyPage(color: Theme.of(context).primaryColor)
                          : buildProfilePhotoWidget(context, model),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ProfileFields(
                              width: width,
                              hintText: ConstString.name_hint,
                              labelText: ConstString.name,
                              onChanged: (name) {
                                print(name);
                                _name = name;
                              },
                              controller: TextEditingController(text: _name),
                            ),
                            ProfileFields(
                              width: width,
                              labelText: "email",
                              isEditable: false,
                              controller: TextEditingController(
                                  text: developer.email ?? ''),
                            ),
                            ProfileFields(
                              width: width,
                              labelText: ConstString.qualification,
                              onChanged: (qualification) {
                                _qualification = qualification;
                              },
                              hintText: '',
                              controller:
                                  TextEditingController(text: _qualification),
                            ),
                            ProfileFields(
                              width: width,
                              labelText: ConstString.developer_expirience,
                              textInputType: TextInputType.number,
                              controller:
                                  TextEditingController(text: _experience),
                              onChanged: (value) {
                                _experience = value;
                              },
                            ),
                            ProfileFields(
                              width: width,
                              labelText: "Preferred Language",
                              textInputType: TextInputType.text,
                              controller: TextEditingController(text: language),
                              onChanged: (value) {
                                language = value;
                              },
                            ),
                            ProfileFields(
                              width: width,
                              labelText: ConstString.develop_city,
                              textInputType: TextInputType.text,
                              controller: TextEditingController(text: _city),
                              onChanged: (city) {
                                _city = city;
                              },
                            ),
                            ProfileFields(
                              width: width,
                              labelText: ConstString.develop_country,
                              textInputType: TextInputType.text,
                              controller: TextEditingController(text: _country),
                              onChanged: (country) {
                                _country = country;
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget buildProfilePhotoWidget(
      BuildContext context, DeveloperProfilePageModel model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
          child: Stack(
            children: <Widget>[
              Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Hero(
                  tag: 'profileeee',
                  transitionOnUserGestures: true,
                  child: Image(
                      height: MediaQuery.of(context).size.width / 2.5,
                      width: MediaQuery.of(context).size.width / 2.5,
                      image: setImage()),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 45,
                  width: 45,
                  child: Card(
                    elevation: 5,
                    color: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: IconButton(
                      color: Colors.white,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.black38,
                        size: 25,
                      ),
                      onPressed: () async {
                        String _path = await getImage(mounted);
                        setState(() {
                          path = _path;
                          // tempPath = _path;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ImageProvider<dynamic> setImage() {
    if (path.contains('https')) {
      return NetworkImage(path);
    } else if (path == 'default' || path == null) {
      return AssetImage(ConstassetsString.developer);
    } else {
      return AssetImage(path);
    }
  }
}
