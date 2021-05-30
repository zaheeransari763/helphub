import 'package:flutter/material.dart';
import 'package:helphub/Shared/Widgets_and_Utility/constants.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget child;
  final Function onPressed;
  final Function onTitleTapped;
  final String buttonHeroTag;
  final String titleTag;
  final Widget child1;

  @override
  final Size preferredSize;

  TopBar(
      {@required this.title,
      this.child,
      @required this.onPressed,
      this.child1,
      this.titleTag = 'title',
      this.buttonHeroTag = 'topBarBtn',
      this.onTitleTapped})
      : preferredSize = Size.fromHeight(60.0);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          widget.child == null
              ? Container(
                  width: 100,
                  child: MaterialButton(
                    height: 50,
                    elevation: 10,
                    shape: kBackButtonShape,
                    onPressed: widget.onPressed,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: widget.child1,
                    ),
                  ),
                )
              : Hero(
                  transitionOnUserGestures: true,
                  tag: widget.buttonHeroTag,
                  child: Container(
                    child: MaterialButton(
                      height: 50,
                      minWidth: 50,
                      elevation: 10,
                      shape: kBackButtonShape,
                      onPressed: widget.onPressed,
                      child: widget.child,
                    ),
                  ),
                ),
          widget.child1==null ? Spacer() : Container(),
          Hero(
            tag: widget.titleTag,
            transitionOnUserGestures: true,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              child: InkWell(
                onTap: widget.onTitleTapped,
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: 50,
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(widget.title),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Spacer(flex: 3),
        ],
      ),
    );
  }
}
