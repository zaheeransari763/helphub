import 'package:helphub/imports.dart';


class AllProjects extends StatelessWidget {
  final Project project;
  final bool val;
  final bool enrolled;
  final UserType userType;
  const AllProjects(
      {Key key, this.project, this.val, this.enrolled, @required this.userType})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String completedyear = project.completion.toDate().year.toString();
    String completedmonth = project.completion.toDate().month.toString();
    String completeddate = project.completion.toDate().day.toString();
    return GestureDetector(
      onTap: () {
        kopenPage(
            context,
            MyProject(
              userType: userType,
              project: project,
              val: true,
              allProject: true,
            ));
      },
      child: Container(
        height: MediaQuery.of(context).size.height / 6,
        child: Card(
          color: enrolled == null
              ? project.current == true ? mainColor : Theme.of(context).brightness == Brightness.dark
 ? Colors.black:Colors.white
              : enrolled == true
                  ? project.current == true ? mainColor :  Theme.of(context).brightness == Brightness.dark
 ? Colors.black:Colors.white
                  :  Theme.of(context).brightness == Brightness.dark
 ? Colors.black:Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                child: imageBuilder(project.photo,
                    placeHolder: Image(
                        image: setImage(null, ConstassetsString.welcome1)),
                    child: Image(
                        image: setImage(
                            project.photo, ConstassetsString.welcome1))),
              ),
              Spacer(
                flex: 1,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(project.name),
                  Text(project.projectInfo['Language']),
                  Text(project.projectInfo['Database']),
                  enrolled == true
                      ? project.current == true
                          ? Text("In Progress")
                          : Text(
                              '$completeddate - $completedmonth - $completedyear')
                      : Text(
                          '$completeddate - $completedmonth - $completedyear')
                ],
              ),
              Spacer(
                flex: 5,
              ),
              Text(project.price)
            ],
          ),
        ),
      ),
    );
  }
}
