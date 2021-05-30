import 'package:helphub/imports.dart';

import 'StudentHome.dart';

class StudentProfile extends StatefulWidget {
  static const id = 'StudentProfilePage';
  StudentProfile({Key key}) : super(key: key);

  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  SharedPreferencesHelper _sharedPreferencesHelper =
      locator<SharedPreferencesHelper>();
  UserType userType = UserType.STUDENT;
  DateTime year;
  int a = 0;
  String path = 'default';
  Student student;
  User firebaseUser;
  _StudentProfileState() {
    getStudentData();
  }

  getStudentData() async {
    firebaseUser = Provider.of<User>(context, listen: false);
    student = Provider.of<Student>(context);
    String value = await _sharedPreferencesHelper.getStudent();
    if (value == 'N.A') {
      student = json.decode(value);
    }
    student = Student(
        displayName: student.displayName,
        email: firebaseUser.email,
        city: student.city,
        country: student.country,
        firebaseUid: firebaseUser.uid,
        photoUrl: student.photoUrl,
        qualification: student.qualification,
        yearofcompletion: student.yearofcompletion);
    print(value);
  }

  // String tempPath = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        initialDatePickerMode: DatePickerMode.day,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2010),
        lastDate: DateTime(2022));
    if (picked != null) {
      setState(() {
        year = picked;
        return _yearofcompletion = picked.toLocal().toString().substring(0, 10);
      });
    }
  }

  String _name = '';
  String _qualification = '';
  String _yearofcompletion = '';
  String id = '';
  String city = '';
  String country = '';

  floatingButoonPressed(StudentProfilePageModel model, UserType userType,
      Student student, User firebaseUser) async {
    bool res = false;
    if (_name.isEmpty || _qualification.isEmpty || _yearofcompletion.isEmpty) {
      _scaffoldKey.currentState.showSnackBar(ksnackBar(
        context,
        'You Need to fill all the details and a profile Photo',
      ));
    } else {
      if (model.state == ViewState.Idle) {
        if (model.studentProfile == null) {
          student = Student(
              displayName: _name,
              email: firebaseUser.email,
              firebaseUid: firebaseUser.uid,
              photoUrl: path,
              qualification: _qualification,
              yearofcompletion: _yearofcompletion,
              city: city,
              country: country);
          res = await model.setStudentProfileData(
            student: student,
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc('Profile')
              .collection('Students')
              .doc(student.email)
              .set(student.toJson(student));
        } else {
          student = Student(
              displayName: _name,
              email: firebaseUser.email,
              firebaseUid: firebaseUser.uid,
              photoUrl: path,
              qualification: _qualification,
              yearofcompletion: _yearofcompletion,
              city: city,
              country: country);
          res = await model.setStudentProfileData(
            student: student,
          );
          await FirebaseFirestore.instance
              .collection('users')
              .doc('Profile')
              .collection('Students')
              .doc(student.email)
              .update(student.toJson(student));
        }
      }
    }

    if (res == true) {
      Navigator.pushNamedAndRemoveUntil(context, StudentPage.id, (r) => false);
    }
  }

  Future<Map<String, dynamic>> getConnection() async {
    this.id = await _sharedPreferencesHelper.getStudentsEmail();
    if (id == 'N.A') {
      return null;
    }

    return jsonDecode(id);
  }

  @override
  Widget build(BuildContext context) {
    var firebaseUser = Provider.of<User>(context, listen: false);
    Student student = Provider.of<Student>(context);
    return BaseView<StudentProfilePageModel>(
        onModelReady: (model) => model.getStudentProfileData(),
        builder: (context, model, child) {
          if (model.state == ViewState.Idle) {
            if (a == 0) {
              student = model.studentProfile;
              if (student != null) {
                _name = student.displayName;
                path = student.photoUrl;
                _qualification = student.qualification;
                _yearofcompletion = student.yearofcompletion;
                city = student.city;
                country = student.country;
                a++;
              }
            }
          }
          return Scaffold(
            key: _scaffoldKey,
            appBar: TopBar(
              title: //Text(
                  student != null
                      ? student.displayName == ''
                          ? 'Profile'
                          : student.displayName
                      : 'Profile', //),
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
                await floatingButoonPressed(
                    model, userType, student, firebaseUser);
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
                              width: MediaQuery.of(context).size.width,
                              hintText: ConstString.student_name_hint,
                              labelText: ConstString.student_name,
                              onChanged: (name) {
                                print(name);
                                _name = name;
                              },
                              controller: TextEditingController(text: _name),
                            ),
                            Row(
                              // mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: ProfileFields(
                                    labelText: ConstString.qualification,
                                    onChanged: (qualification) {
                                      _qualification = qualification;
                                    },
                                    hintText: '',
                                    controller: TextEditingController(
                                        text: _qualification),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      await _selectDate(context);
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: IgnorePointer(
                                      child: ProfileFields(
                                          labelText: ConstString
                                              .student_yearofcompletion,
                                          textInputType: TextInputType.number,
                                          onChanged: (dob) {
                                            _yearofcompletion = dob;
                                          },
                                          hintText: '',
                                          controller: TextEditingController(
                                              text: _yearofcompletion)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                            ProfileFields(
                                isEditable: false,
                                labelText: ConstString.email,
                                textInputType: TextInputType.text,
                                hintText: '',
                                controller: TextEditingController(
                                    text: firebaseUser.email)),
                            ProfileFields(
                                isEditable: false,
                                labelText: "Firebase UID",
                                hintText: '',
                                controller: TextEditingController(
                                    text: firebaseUser.uid)),
                            ProfileFields(
                              labelText: ConstString.develop_city,
                              onChanged: (val) {
                                city = val;
                              },
                              hintText: '',
                              controller: TextEditingController(text: city),
                            ),
                            ProfileFields(
                              labelText: ConstString.develop_country,
                              onChanged: (val) {
                                country = val;
                              },
                              hintText: '',
                              controller: TextEditingController(text: country),
                            ),
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
      BuildContext context, StudentProfilePageModel model) {
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
                          //tempPath = _path;
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
      return AssetImage(ConstassetsString.student);
    } else {
      return AssetImage(path);
    }
  }
}
