import 'package:helphub/imports.dart';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

class DeveloperDetail extends StatefulWidget {
  final Developer developer;
  final bool card;
  final Student student;
  DeveloperDetail({
    Key key,
    this.student,
    @required this.card,
    @required this.developer,
  }) : super(key: key);

  @override
  _DeveloperDetailState createState() => _DeveloperDetailState();
}

class _DeveloperDetailState extends State<DeveloperDetail> {
  Developer get developer => widget.developer;
  @override
  void initState() {
    super.initState();
    if (!widget.card && widget.student != null) {
      updateStudent();
    }
  }

  updateStudent() async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc('Enrolled')
        .collection(developer.id)
        .doc(widget.student.displayName)
        .update(widget.student.acceptRequest(widget.student));
  }

  SliverPersistentHeader makePinnedheader(String headerText, String email) {
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
                Hero(
                  tag: widget.developer.displayName,
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
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Spacer(),
              ],
            )),
      ),
    );
  }

  int a = 0;
  @override
  Widget build(BuildContext context) {
    return widget.card
        ? BaseView<StudentHomeModel>(
            onModelReady: (model) =>
                model.getEnrollmentAndRequestStatus(widget.developer.id),
            builder: (context, model, child) {
              if (a == 0) {
                model.getEnrollmentAndRequestStatus(widget.developer.id);
                a++;
              }
              return buildPage(model: model);
            },
          )
        : buildPage();
  }

  Widget buildPage({StudentHomeModel model}) {
    Student student = Provider.of<Student>(context);
    return Scaffold(
      appBar: Navigator.canPop(context) == true
          ? TopBar(
              buttonHeroTag: developer.qualification,
              title: "Developer",
              child: kBackBtn,
              onPressed: () => Navigator.pop(context))
          : null,
      body: SafeArea(
        child: CustomScrollView(physics: BouncingScrollPhysics(), slivers: <
            Widget>[
          SliverFixedExtentList(
            itemExtent: MediaQuery.of(context).size.height / 3,
            delegate: SliverChildListDelegate(
              [
                Hero(
                  tag: widget.developer.photoUrl,
                  child: FutureBuilder<http.Response>(
                      future: http.get(Uri.parse(developer.photoUrl)),
                      builder: (context, snapshot) {
                        if (snapshot != null && snapshot.data != null) {
                          if (snapshot.data.statusCode == 200) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: setImage(developer.photoUrl,
                                          ConstassetsString.developer))),
                            );
                          } else {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: setImage(
                                          null, ConstassetsString.developer))),
                            );
                          }
                        } else {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: setImage(
                                        null, ConstassetsString.developer))),
                          );
                        }
                      }),

                  /* imageBuilder(
                        developer.photoUrl,
                        placeHolder: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: setImage(null,
                                      ConstassetsString.developer))),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: setImage(developer.photoUrl,
                                      ConstassetsString.developer))),
                        ),
                      ), */
                )
              ],
            ),
          ),
          makePinnedheader(developer.displayName, developer.email),
          SliverFixedExtentList(
              itemExtent: MediaQuery.of(context).size.height / 2,
              delegate: SliverChildListDelegate([
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width / 16,
                      right: MediaQuery.of(context).size.width / 10),
                  child: Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Developer Information",
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width / 22,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Current Project:",
                                        style: detailtitleStyle(context),
                                      ),
                                      SizedBox(height: 5),
                                      Text("Language:",
                                          style: detailtitleStyle(context)),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("Experience:",
                                          style: detailtitleStyle(context)),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("Qualification:",
                                          style: detailtitleStyle(context)),
                                      SizedBox(height: 5),
                                      Text("Location:",
                                          style: detailtitleStyle(context))
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        developer.currentProject ?? "",
                                        style: detailvalueStyle(context),
                                      ),
                                      SizedBox(height: 5),
                                      Text(developer.language ?? "",
                                          style: detailvalueStyle(context)),
                                      SizedBox(height: 5),
                                      Text(developer.experience,
                                          style: detailvalueStyle(context)),
                                      SizedBox(height: 5),
                                      Text(developer.qualification,
                                          style: detailvalueStyle(context)),
                                      SizedBox(height: 5),
                                      Text(
                                          '${developer.city}, ${developer.country}',
                                          style: detailvalueStyle(context)),
                                    ],
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]))
        ]),
      ),
      bottomNavigationBar: widget.card
          ? TextButton(
              onPressed: () {
                model.requested
                    ? model.cancelReq(student, developer)
                    : model.sendReq(student, developer);
                setState(() {
                  a = 0;
                });
              },
              child: model.state3 == ViewState.Idle
                  ? model.requested
                      //? model.state3 == ViewState.Idle
                      ? Text("Requested")
                      //  : circularProgressIndicator()
                      : // model.state3 == ViewState.Idle
                      Text("Request for enrollment")
                  //  : circularProgressIndicator()
                  : circularProgressIndicator())
          : null,
    );
  }

  SizedBox circularProgressIndicator() {
    return SizedBox(height: 25, width: 25, child: CircularProgressIndicator());
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
