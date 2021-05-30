import 'package:helphub/imports.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sortedmap/sortedmap.dart';
import 'dart:math' as math;

class MyProject extends StatefulWidget {
  final bool val;
  final Project project;
  final UserType userType;
  final bool allProject;
  MyProject(
      {Key key,
      @required this.val,
      this.project,
      @required this.userType,
      @required this.allProject});

  @override
  _MyProjectState createState() => _MyProjectState();
}

class _MyProjectState extends State<MyProject> {
  DocumentReference projectreference;
  UserType get userType => widget.userType;
  Project project;
  Student student;

  acceptProject() async {
    await projectreference.update({'current': true, 'rejected': false});
  }

  rejectProject() async {
    await projectreference.delete();
  }

  @override
  void initState() {
    super.initState();
  }

  SliverPersistentHeader makePinnedheader(String headerText, String price) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: MediaQuery.of(context).size.height / 9,
        maxHeight: MediaQuery.of(context).size.height / 6,
        child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            child: Column(
              children: <Widget>[
                Spacer(),
                Text(
                  headerText,
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                Spacer(
                  flex: 3,
                ),
                Row(children: [
                  Spacer(),
                  Text("Price",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Spacer(
                    flex: 3,
                  ),
                  Text(price,
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                          fontWeight: FontWeight.bold)),
                  Spacer(),
                ]),
                Spacer(),
              ],
            )),
      ),
    );
  }

  TextStyle titleStyle() {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width / 24,
        fontWeight: FontWeight.w700);
  }

  TextStyle valueStyle() {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width / 24,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300);
  }

  int selected = 0;
  changeRadioValue(index) {
    setState(() {
      selected = index;
    });
  }

  Widget studentList(
      {BuildContext context, Student student, int index, Developer developer}) {
    return ListTile(
      title: Text(student.displayName),
      subtitle: Text(student.email),
      leading: imageBuilder(student.photoUrl,
          child: Image(
              image: setImage(student.photoUrl, ConstassetsString.student)),
          placeHolder: Image(image: setImage(null, ConstassetsString.student))),
      onTap: () {
        Navigator.of(context).pop();
        showStudentDetailSheet(context, student, developer, true);
      },
    );
  }

  showStudentDetailSheet(
      BuildContext context, Student student, Developer developer, bool value) {
    return showModalBottomSheet(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        context: context,
        builder: (context) => StudentDetail(
            isARequest: false,
            student: student,
            isASelection: value,
            project: project));
  }

  showAddStudentSheet(BuildContext context, Developer developer) {
    return showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      context: context,
      builder: (context) => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ListView.builder(
          itemCount: enrolledstudents.length,
          itemBuilder: (context, index) {
            return studentList(
                context: context,
                student: enrolledstudents[index],
                developer: developer);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Developer developer = Provider.of<Developer>(context);
    if (userType == UserType.STUDENT) {
      return buildPage(developer, context, project: widget.project);
    } else {
      return BaseView<DeveloperHomeModel>(
        onModelReady: (model) => model.getCurrentProject(),
        builder: (context, model, child) {
          if (model.state == ViewState.Idle && model.state2 == ViewState.Idle) {
            if (project == null || enrolledstudents == null) {
              model.getCurrentProject();
              model.getenrolledStudents();
            }
            if (student.displayName == "" || student == null) {
              model.getWorkingStudent();
            }
          }
          project = model.project;
          enrolledstudents = model.enrolledstudents;
          student = model.student;
          return widget.allProject
              ? buildPage(developer, context,
                  model: model, student: student, project: widget.project)
              : buildPage(developer, context,
                  model: model, student: student, project: project);
        },
      );
    }
  }

  Widget listTile(String key, dynamic value) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: TextDirection.ltr,
      children: <Widget>[
        Text(
          key.toString(),
          style: titleStyle(),
        ),
        // Spacer(),
        Text(
          value.toString(),
          style: valueStyle(),
        )
      ],
    );
  }

  List<Student> enrolledstudents;
  TextEditingController controller = TextEditingController();

  Widget buildPage(Developer developer, BuildContext context,
      {var model, Project project, Student student}) {
    if (project != null) {
      if (project.name != 'none') {
        return Scaffold(
            appBar: widget.val
                ? TopBar(
                    title: "Project",
                    child: kBackBtn,
                    onPressed: () => Navigator.pop(context))
                : null,
            body: SafeArea(
              child:
                  CustomScrollView(physics: BouncingScrollPhysics(), slivers: <
                      Widget>[
                SliverFixedExtentList(
                  itemExtent: MediaQuery.of(context).size.height / 3,
                  delegate: SliverChildListDelegate(
                    [
                      imageBuilder(
                        project.photo,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: setImage(project.photo,
                                      ConstassetsString.welcome1))),
                        ),
                        placeHolder: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: setImage(
                                      null, ConstassetsString.welcome1))),
                        ),
                      )
                    ],
                  ),
                ),
                makePinnedheader(project.name, project.price),
                SliverFixedExtentList(
                  itemExtent: MediaQuery.of(context).size.height / 3.9,
                  delegate: SliverChildListDelegate([
                    Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Text(
                              "Project Information",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Positioned(
                            left: 45,
                            top: 65,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 100,
                              height: MediaQuery.of(context).size.height / 4,
                              child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: project.projectInfo.length,
                                  itemBuilder: (BuildContext context, int i) =>
                                      listTile(
                                          project.projectInfo.keys.elementAt(i),
                                          project.projectInfo.values
                                              .elementAt(i))),
                            )),
                      ],
                    ),
                  ]),
                ),
                SliverFixedExtentList(
                    itemExtent: project.current
                        ? project.progress.length != 6
                            ? MediaQuery.of(context).size.height / 2.2
                            : MediaQuery.of(context).size.height / 3.5
                        : MediaQuery.of(context).size.height / 25,
                    delegate: SliverChildListDelegate([
                      Visibility(
                        visible: project.current,
                        replacement: Padding(
                          padding: const EdgeInsets.only(left: 28.0, right: 28),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    style: BorderStyle.solid,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.green[400]
                                        : Colors.green[900]),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10)),
                            height: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.done, color: Colors.green),
                                Text(
                                  "Project Completed",
                                  style: TextStyle(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.green
                                          : Colors.green[900]),
                                ),
                              ],
                            ),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 35),
                                child: Text(
                                  "Progress",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 45,
                              child: LinearPercentIndicator(
                                width: MediaQuery.of(context).size.width - 100,
                                animation: true,
                                animationDuration: 100,
                                lineHeight: 20.0,
                                percent: project.progress.length == 6
                                    ? 1
                                    : (project.progress.length * 16.66666) /
                                        100,
                                center: Text(
                                    project.progress.length == 6
                                        ? 100.toString() + "%"
                                        : (project.progress.length * 16.6)
                                                .toString() +
                                            "%",
                                    style: TextStyle(
                                      color:
                                          (project.progress.length * 16.66666) <
                                                  50
                                              ? black
                                              : Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.black
                                                  : Colors.white,
                                    )),
                                linearStrokeCap: LinearStrokeCap.roundAll,
                                progressColor: mainColor,
                              ),
                            ),
                            project.progress.length > 0
                                ? Positioned(
                                    left: 45,
                                    top: 100,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          100,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3.8,
                                      child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: project.progress.length,
                                          itemBuilder: (context, i) {
                                            var map = SortedMap.from(
                                                project.progress,
                                                Ordering.byValue());
                                            return listTile(
                                                map.keys.elementAt(i),
                                                map.values
                                                    .elementAt(i)
                                                    .toDate());
                                          }),
                                    ))
                                : Container(),
                            userType == UserType.DEVELOPERS
                                ? project.progress.length < 6
                                    ? Positioned(
                                        bottom: project.progress.length > 0
                                            ? 0
                                            : 30,
                                        left: 45,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              80,
                                          height: 180,
                                          child: Column(
                                            children: <Widget>[
                                              Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text("Add Progress",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Flexible(
                                                    child: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: TextField(
                                                        decoration:
                                                            kTextFieldDecoration
                                                                .copyWith(
                                                          labelText: "Phase",
                                                        ),
                                                        controller: controller,
                                                        onChanged: (val) {
                                                          print(val);
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 12.0),
                                                    child: IconButton(
                                                        icon: model.state3 ==
                                                                ViewState.Idle
                                                            ? Icon(Icons.done)
                                                            : CircularProgressIndicator(),
                                                        onPressed: () async {
                                                          if (controller.text !=
                                                                  null ||
                                                              controller.text
                                                                  .isNotEmpty ||
                                                              controller !=
                                                                  null) {
                                                            await model
                                                                .updateProgress(
                                                                    project
                                                                        .projectReference,
                                                                    controller
                                                                        .text);
                                                          } else {
                                                            Scaffold.of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text("Please name the phase")));
                                                          }
                                                        }),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        style:
                                                            BorderStyle.solid,
                                                        color:
                                                            Colors.yellow[700]),
                                                    color: Colors.yellow
                                                        .withOpacity(0.3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                height: 60,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Align(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 6),
                                                        child: Icon(Icons.info,
                                                            size: 18,
                                                            color: Colors
                                                                .yellow[700]),
                                                      ),
                                                    ),
                                                    Text(
                                                      '''Note: The project development, that is the SDLC (Software Development 
           Life Cycle) is divided into 6 phases, the completion of 6th phase
           will be completeion of project''',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .yellow[700]),
                                                      softWrap: true,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                    : Container()
                                : Container(),
                          ],
                        ),
                      ),
                    ]))
              ]),
            ),
            bottomNavigationBar: userType == UserType.DEVELOPERS
                ? buildBottomWidget(context, developer,
                    project: project, student: student, model: model)
                : Container(
                    height: 0,
                  ));
      } else {
        return Scaffold(
          appBar: Navigator.canPop(context)
              ? TopBar(
                  title: "Project", //Text("Project"),
                  child: kBackBtn,
                  onPressed: () => Navigator.pop(context))
              : null,
          body: Center(
            child: Text("No Current Projects"),
          ),
        );
      }
    } else {
      return kBuzyPage();
    }
  }

  Widget buildBottomWidget(BuildContext context, Developer developer,
      {Project project, Student student, DeveloperHomeModel model}) {
    if (project != null) {
      if (project.current) {
        if (student == null) {
          //model.getWorkingStudent();
          Future.delayed((Duration(milliseconds: 600)));
          return Center(child: CircularProgressIndicator());
        } else if (student.displayName == "") {
          return TextButton(
              onPressed: () {
                showAddStudentSheet(context, developer);
              },
              child: Text("Select a Student"));
        } else {
          return TextButton(
              onPressed: () {
                showStudentDetailSheet(context, student, developer, false);
              },
              child: Text(student.displayName));
        }
      } else if (project.completed) {
        return BottomAppBar(
            child: FlatButton(
                disabledTextColor: black,
                onPressed: null,
                child: Text("Completed")));
      } else if (project.requested) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                  color: Colors.red,
                  colorBrightness: Brightness.dark,
                  onPressed: () {
                    rejectProject();
                  },
                  child: Text("Reject")),
            ),
            Expanded(
              child: FlatButton(
                  color: Colors.green,
                  colorBrightness: Brightness.dark,
                  onPressed: () {
                    acceptProject();
                  },
                  child: Text("Accept")),
            ),
          ],
        );
      } else {
        return Container();
      }
    } else {
      kBuzyPage();
      Future.delayed((Duration(milliseconds: 500)), () {
        setState(() {});
      });
      return buildBottomWidget(context, developer);
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
