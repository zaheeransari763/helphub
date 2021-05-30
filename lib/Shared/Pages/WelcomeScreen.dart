import 'package:helphub/imports.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatelessWidget {
  static const id = 'WelcomeScreen';
  List<PageViewModel> page(BuildContext context) {
    return [
      PageViewModel(
        pageColor: Color(0xff80DEEA),
        bubbleBackgroundColor: Color(0xff80DEEA),
        bubble: Center(
          child: Text('1',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ),
        title: Container(),
        body: Column(
          children: <Widget>[
            Text(
              ConstString.welcome1_heading,
              style: TextStyle(
                  color: black, fontSize: 35, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Text(
                ConstString.welcome1,
                style: TextStyle(
                    color: black, fontSize: 18.0, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        mainImage: Image.asset(
          ConstassetsString.welcome1,
          // fit: BoxFit.none,
          width: MediaQuery.of(context).size.width - 60,
          alignment: Alignment.center,
        ),
        textStyle: TextStyle(color: Colors.white),
      ),
      PageViewModel(
        bubble: Center(
          child: Text('2',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ),
        pageColor: Color(0xff2ab1e0), //Color(0xff80DEEA),
        bubbleBackgroundColor: Color(0xff2ab1e0),

        title: Container(),
        body: Column(
          children: <Widget>[
            Text(
              ConstString.welcome2_heading,
              style: TextStyle(
                  color: black, fontSize: 35, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Text(
                ConstString.welcome2,
                style: TextStyle(
                    color: black, fontSize: 18.0, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        mainImage: Image.asset(
          ConstassetsString.welcome2,
          // fit: BoxFit.none,
          width: MediaQuery.of(context).size.width - 100,
          alignment: Alignment.center,
        ),
        textStyle: TextStyle(color: Colors.white),
      ),
      PageViewModel(
        bubbleBackgroundColor: Color(0xff008b88),
        bubble: Center(
          child: Text('3',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        ),
        pageColor: Color(0xff008b88),
        title: Container(),
        body: Column(
          children: <Widget>[
            Text(
              ConstString.welcome3_heading,
              style: TextStyle(
                  color: black, fontSize: 35, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
              child: Text(
                ConstString.welcome3,
                style: TextStyle(
                    color: black, fontSize: 18.0, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        mainImage: Image.asset(
          ConstassetsString.welcome3,
          // fit: BoxFit.none,
          width: MediaQuery.of(context).size.width - 60,
          alignment: Alignment.center,
        ),
        textStyle: TextStyle(color: Colors.white),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          IntroViewsFlutter(
            page(context),
            onTapDoneButton: () => kopenPage(context, Login()),
            fullTransition: 450,
            showNextButton: true,
            showBackButton: true,
            skipText: Text(
              '↠',
              style: TextStyle(
                // color: Colors.white,
                fontSize: 30,
              ),
            ),
            backText: Text(
              '←',
              style: TextStyle(
                //color: Colors.white,
                fontSize: 30,
              ),
            ),
            nextText: Text(
              '→',
              style: TextStyle(
                // color: mainColor,
                fontSize: 30,
              ),
            ),
            showSkipButton: true,
            doneText: Text("Done"),
            pageButtonsColor: Color.fromARGB(100, 254, 198, 27),
            pageButtonTextStyles: new TextStyle(
              color: black,
              fontSize: 16.0,
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).size.width / 12,
              left: MediaQuery.of(context).size.width / 20 - 10,
              child: Hero(
                placeholderBuilder: (context, heroSize, child) {
                  return Icon(Icons.send);
                },
                flightShuttleBuilder: (flightContext, animation,
                    flightDirection, fromHeroContext, toHeroContext) {
                  final Hero toHero = toHeroContext.widget;

                  return ScaleTransition(
                    scale: animation.drive(
                      Tween<double>(begin: 0.0, end: 6.0).chain(
                        CurveTween(
                          curve:
                              Interval(0.0, 1.0, curve: PeakQuadraticCurve()),
                        ),
                      ),
                    ),
                    child: toHero.child,
                  );
                },
                tag: "hello",
                child: Card(
                  shape: CircleBorder(),
                  elevation: 5,
                  child: Image(
                      height: 80,
                      width: 80,
                      image: AssetImage(ConstassetsString.icon2)),
                ),
              )),
          Positioned(
            bottom: 60.0,
            left: 50,
            width: MediaQuery.of(context).size.width / 1.2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Hero(
                tag: 'title',
                transitionOnUserGestures: true,
                child: MaterialButton(
                  shape: StadiumBorder(),
                  height: 50,
                  minWidth: MediaQuery.of(context).size.width - 100,
                  onPressed: () => kopenPage(context, Login()),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Color(0xff424242)
                      : Colors.white,
                  splashColor: Theme.of(context).accentColor,
                  child: Text(
                    ConstString.get_started,
                    style: TextStyle(
                      //color: black,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PeakQuadraticCurve extends Curve {
  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    return -15 * math.pow(t, 2) + 15 * t + 1;
  }
}
