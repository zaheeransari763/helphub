import 'package:helphub/Developers/Models/DeveloperHomeModel.dart';
import 'package:helphub/imports.dart';
import 'dart:math' as math;

class StudentDetail extends StatefulWidget {
  final bool isARequest;
  final bool isASelection;
  final Project project;
  final Student student;
  StudentDetail({
    Key key,
    this.project,
    this.isASelection,
    @required this.isARequest,
    @required this.student,
  }) : super(key: key);

  @override
  _StudentDetailState createState() => _StudentDetailState();
}

class _StudentDetailState extends State<StudentDetail> {
  Student get student => widget.student;

  bool get select => widget.isASelection == null ? true : false;

  SliverPersistentHeader makePinnedheader(String headerText, String email) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        minHeight: select
            ? MediaQuery.of(context).size.height / 9
            : MediaQuery.of(context).size.height / 12,
        maxHeight: select
            ? MediaQuery.of(context).size.height / 6
            : MediaQuery.of(context).size.height / 9,
        child: Container(
            child: Column(
          children: <Widget>[
            Spacer(),
            Hero(
              tag: student.email,
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                child: Text(
                  headerText,
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            Spacer(
              flex: 3,
            ),
            Text(email,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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

  bool exist;
  List<Student> request = [];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return BaseView<DeveloperHomeModel>(
      onModelReady: (model) => model.getrequestList(),
      builder: (context, model, child) {
        model.requests.forEach((students) {
          if (students.email == student.email) {
            exist = true;
          } else {
            exist = false;
          }
        });
        return Scaffold(
            appBar: Navigator.canPop(context) == true
                ? TopBar(
                    title: // Text(
                        'Student', //),
                    child: kBackBtn,
                    onPressed: () => Navigator.pop(context))
                : null,
            body: SafeArea(
              child: CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverFixedExtentList(
                      itemExtent:
                          widget.isASelection == null ? height / 3 : height / 5,
                      delegate: SliverChildListDelegate(
                        [
                          Hero(
                              tag: '${student.displayName}+1',
                              child: imageBuilder(
                                student.photoUrl,
                                placeHolder: Container(
                                  width: width,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: setImage(
                                              student.photoUrl ?? null,
                                              ConstassetsString.student))),
                                ),
                                child: Container(
                                  width: width,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: setImage(student.photoUrl,
                                              ConstassetsString.student))),
                                ),
                              ))
                        ],
                      ),
                    ),
                    makePinnedheader(student.displayName, student.email),
                    SliverFixedExtentList(
                        itemExtent: 250,
                        delegate: SliverChildListDelegate([
                          Padding(
                            padding: EdgeInsets.only(
                                left: width / 16, right: width / 10),
                            child: Column(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Student Information",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 30),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                select
                                                    ? Text(
                                                        "Current Project:",
                                                        style: titleStyle(),
                                                      )
                                                    : Container(),
                                                SizedBox(height: 5),
                                                Text("Language:",
                                                    style: titleStyle()),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text("Qualification:",
                                                    style: titleStyle()),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text("Year of Completion:",
                                                    style: titleStyle()),
                                                SizedBox(height: 5),
                                                Text("Location:",
                                                    style: titleStyle()),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                select
                                                    ? Text(
                                                        "student.cu??",
                                                        style: valueStyle(),
                                                      )
                                                    : Container(),
                                                SizedBox(height: 5),
                                                Text("student.language",
                                                    style: valueStyle()),
                                                SizedBox(height: 5),
                                                Text(student.qualification,
                                                    style: valueStyle()),
                                                SizedBox(height: 5),
                                                Text(student.yearofcompletion,
                                                    style: valueStyle()),
                                                SizedBox(height: 5),
                                                Text(
                                                    '${student.city}, ${student.country}',
                                                    style: valueStyle()),
                                              ],
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                                // Divider(color: black),
                              ],
                            ),
                          ),
                        ]))
                  ]),
            ),
            bottomNavigationBar: select
                ? widget.isARequest
                    ? exist
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Center(
                                child: Text(
                                    "Request Date & Time: ${student.requestDateTime.toDate().toIso8601String()}"),
                              ),
                              BottomAppBar(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: TextButton(
                                          style: ButtonStyle(
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red),
                                          ),
                                          onPressed: () {
                                            model
                                                .rejectRequest(student)
                                                .then((val) {
                                              if (val) {
                                                model.getrequestList();
                                                model.requests.remove(student);
                                                Navigator.pop(context);
                                              } else {
                                                failed('reject');
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(
                                                Icons.cancel,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text("Reject"),
                                            ],
                                          )),
                                    ),
                                    Expanded(
                                      child: FlatButton(
                                          color: Colors.green,
                                          colorBrightness: Brightness.dark,
                                          onPressed: () {
                                            model
                                                .acceptRequest(student)
                                                .then((val) {
                                              if (val) {
                                                model.getrequestList();
                                                model.requests.remove(student);
                                                Navigator.pop(context);
                                              } else {
                                                failed('accept');
                                              }
                                            });
                                          },
                                          child: model.state3 == ViewState.Idle
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Icon(Icons.done),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text("Accept"),
                                                  ],
                                                )
                                              : kBuzyPage()),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : null
                    : null
                : widget.isASelection
                    ? BottomAppBar(
                        child: TextButton(
                            onPressed: () {
                              model
                                  .selectStudent(student, widget.project)
                                  .then((val) {
                                if (val) {
                                  Navigator.pop(context);
                                } else {
                                  print("error");
                                }
                              });
                            },
                            child: model.state3 == ViewState.Idle
                                ? Text("Select This Student")
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      kBuzyPage(),
                                    ],
                                  )),
                      )
                    : null);
      },
    );
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
