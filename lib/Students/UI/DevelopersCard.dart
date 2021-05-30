import 'package:flutter/cupertino.dart';
import 'package:helphub/Students/UI/DeveloperDetail.dart';
import 'package:helphub/imports.dart';

class DevelopersCard extends StatelessWidget {
  final Developer developer;
  final Student student;
  DevelopersCard({Key key, this.developer, this.student}) : super(key: key);
  final StudentProfileServices studentProfileServices =
      locator<StudentProfileServices>();
  /* 
  DateTime dateTime = DateTime.now();
  String requestText = "Request For Enrollment"; */

  //int a = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = size.height;
    double width = size.width;
    return Stack(children: [
      Container(
        height: height / 1.6,
        width: width / 1.2,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 6,
          child: imageBuilder(
            developer.photoUrl,
            placeHolder: Container(
                decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: setImage(null, ConstassetsString.developer),
              ),
            )),
            child: Container(
                decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                fit: BoxFit.cover,
                image:
                    setImage(developer.photoUrl, ConstassetsString.developer),
              ),
            )),
          ),
        ),
      ),
      Positioned(
        left: width / 100,
        child: Container(
          height: height / 1.7,
          width: width / 1.225,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            gradient: LinearGradient(
                colors: [Colors.transparent, black.withOpacity(0.5), black],
                stops: [0.3, 0.6, 1],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
        ),
      ),
      Positioned(
        bottom: height / 6.5 - 25,
        left: 18,
        child: Hero(
          tag: developer.displayName,
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: Text(developer.displayName,
                style: TextStyle(
                  backgroundColor: Colors.transparent,
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                )),
          ),
        ),
      ),
      Positioned(
        bottom: height / 8.2 - 25,
        left: 23,
        child: Text(developer.language ?? '',
            style: TextStyle(
              backgroundColor: Colors.transparent,
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            )),
      ),
      Positioned(
        bottom: height / 12.5 - 25,
        left: 23,
        child: Text("${developer.city}, ${developer.country}",
            style: TextStyle(
              backgroundColor: Colors.transparent,
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            )),
      ),
      Positioned(
        bottom: height / 13.5 - 33,
        right: width / 12 - 8,
        child: TextButton(
          onPressed: () => kopenPage(
              context, DeveloperDetail(card: true, developer: developer)),
          child: Row(
            children: <Widget>[
              Text("View more details",
                  style: TextStyle(
                    backgroundColor: Colors.transparent,
                    fontSize: 18,
                    color: Colors.white,
                  )),
              SizedBox(
                width: 3,
              ),
              Hero(
                  tag: developer.qualification,
                  child: Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 20)),
            ],
          ),
        ),
      ),
    ]);
  }
}
