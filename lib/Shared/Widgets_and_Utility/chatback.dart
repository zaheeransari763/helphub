import 'package:flutter/cupertino.dart';
import 'package:helphub/imports.dart';

class ChatProfilePic extends StatelessWidget {
  final String imageHero;
  final String arrowHero;
  final Widget child;
  final String image;
  const ChatProfilePic(
      {Key key, this.imageHero, this.arrowHero, this.child, this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Hero(tag: arrowHero, child: Icon(CupertinoIcons.back)),
          Hero(
            transitionOnUserGestures: true,
            tag: imageHero,
            child: imageBuilder(
              image,
              placeHolder: CircleAvatar(
                radius: 18,
                backgroundImage: setImage(null, ConstassetsString.student),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: setImage(image, ConstassetsString.student),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
