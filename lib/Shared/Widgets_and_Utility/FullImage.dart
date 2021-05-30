import 'package:helphub/imports.dart';

class FullImage extends StatelessWidget {
  final ImageProvider image;
  final String heroTag;
  const FullImage({Key key, this.image, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Hero(
          tag: heroTag,
          child: Center(
              child: Container(
            decoration: BoxDecoration(image: DecorationImage(image: image)),
          )),
        ));
  }
}
