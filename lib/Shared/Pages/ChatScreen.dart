import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:helphub/Shared/Model/MessageModel.dart';
import 'package:helphub/Shared/Widgets_and_Utility/FullImage.dart';
import 'package:helphub/Shared/Widgets_and_Utility/chatback.dart';
import 'package:helphub/Shared/Widgets_and_Utility/easylist.dart';
import 'package:helphub/imports.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';

class Chat extends StatelessWidget {
  final String recieverId;
  final String recieverImage;
  final Developer developer;
  final UserType userType;
  final Student student;
  //GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  Chat(
      {Key key,
      this.recieverId,
      this.recieverImage,
      this.developer,
      this.student,
      this.userType})
      : super(key: key);

  ImageProvider<dynamic> setImage(String url) {
    return url != 'default'
        ? NetworkImage(
            url,
          )
        : AssetImage(ConstassetsString.student);
  }

/*   void showSnackbar(){
    key.currentState.showSnackBar(
      SnackBar(content: Text("This is a snackbar"))
    );
  } */

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // key: key,
      appBar: userType == UserType.DEVELOPERS
          ? TopBar(
              titleTag: student.email,
              title: student.displayName,
              child1: ChatProfilePic(
                imageHero: '${student.displayName}+1',
                arrowHero: student.displayName,
                image: student.photoUrl,
              ),
              onPressed: () {
                Navigator.pop(context);
              })
          : null,
      body: ChatScreen(
        recieverId: recieverId,
        recieverImage: recieverImage,
        userType: userType,
        developer: developer,
        student: student,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String recieverId;
  final String recieverImage;
  final UserType userType;
  final Developer developer;
  final Student student;
  ChatScreen({
    Key key,
    @required this.recieverId,
    @required this.recieverImage,
    this.userType,
    this.developer,
    this.student,
  }) : super(key: key);

  @override
  State createState() => new ChatScreenState(
        recieverId: recieverId,
        recieverImage: recieverImage,
        userType: userType,
        developer: developer,
        student: student,
      );
}

class ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  ChatScreenState(
      {this.userType,
      this.developer,
      this.student,
      Key key,
      @required this.recieverId,
      @required this.recieverImage});
  final UserType userType;
  final Developer developer;
  final Student student;
  String recieverId;
  String recieverImage;
  String fromId;

  var listMessage;
  String groupChatId;
  StorageServices storageServices = locator<StorageServices>();

  SharedPreferencesHelper sharedPreferencesHelper =
      locator<SharedPreferencesHelper>();
  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  ImagePicker imagePicker = ImagePicker();

  final TextEditingController textEditingController =
      new TextEditingController();
  ScrollController listScrollController;
  final FocusNode focusNode = new FocusNode();
  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController = ScrollController();
    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    fromId = userType == UserType.DEVELOPERS
        ? await sharedPreferencesHelper.getDevelopersId()
        : await sharedPreferencesHelper.getStudentsEmail();
    if (fromId.hashCode <= recieverId.hashCode) {
      groupChatId = '$fromId-$recieverId';
    } else {
      groupChatId = '$recieverId-$fromId';
    }
    userType == UserType.DEVELOPERS
        ? FirebaseFirestore.instance
            .collection('users')
            .doc('Profile')
            .collection('Developers')
            .doc(fromId)
            .update({'chattingWith': recieverId})
        : FirebaseFirestore.instance
            .collection('users')
            .doc('Profile')
            .collection('Students')
            .doc(fromId)
            .update({'chattingWith': recieverId});

    setState(() {});
  }

  void onSendMessage(String content, int type) async {
    String rouename = ModalRoute.of(context).settings.name;
    print(rouename);
    String token = await sharedPreferencesHelper.getSenderToken();
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());
      MessageModel message = MessageModel(
          to: recieverId,
          from: fromId,
          senderToken: token,
          type: type,
          userType: userType,
          content: content,
          timeStamp: DateTime.now().millisecondsSinceEpoch);
      await documentReference.set(message.toMap(message));
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(
        msg: "Nothing sent",
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  showDialogText(MessageModel message, bool isRight) {
    bool loading = false;
    bool image = message.type == 1;
    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: StatefulBuilder(builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Visibility(
                      visible: !image,
                      child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                              text: message.content,
                            )).then((onValue) {
                              Fluttertoast.showToast(
                                  msg: "Copied", gravity: ToastGravity.BOTTOM);
                              Navigator.pop(context);
                            });
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: 20),
                              alignment: Alignment.centerLeft,
                              height:
                                  MediaQuery.of(context).size.height / 17 - 7,
                              width: double.maxFinite,
                              child: Text("Copy Text"))),
                    ),
                    Visibility(
                        visible: isRight,
                        child: InkWell(
                            onTap: () async {
                              setState(() {
                                loading = true;
                              });
                              CollectionReference ref = FirebaseFirestore
                                  .instance
                                  .collection('messages')
                                  .doc(groupChatId)
                                  .collection(groupChatId);
                              QuerySnapshot data = await ref
                                  .where('timestamp',
                                      isEqualTo: message.timeStamp)
                                  .get();
                              Future.delayed(Duration(milliseconds: 500),
                                  () async {
                                await ref.doc(data.docs.first.id).delete().then(
                                    (value) {
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                    msg: "Message unsent",
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                }, onError: (error) {
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                    msg: "There was an error",
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                });
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              alignment: Alignment.centerLeft,
                              height:
                                  MediaQuery.of(context).size.height / 17 - 7,
                              width: double.maxFinite,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Unsend Message"),
                                  !loading
                                      ? Container(
                                          width: 20,
                                        )
                                      : Container(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.black),
                                            strokeWidth: 1,
                                          ),
                                        ),
                                ],
                              ),
                            ))),
                    Visibility(
                        visible: image,
                        child: InkWell(
                            onTap: () async {
                              setState(() {
                                loading = true;
                              });
                              Future.delayed(Duration(milliseconds: 500),
                                  () async {
                                /* var response = await Dio().get(message.content,
                                options:
                                    Options(responseType: ResponseType.bytes));
 */
                                await ImageDownloader.downloadImage(
                                        message.content,
                                        destination: AndroidDestinationType
                                            .directoryPictures)
                                    .then((value) {
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                    msg: "Image Saved in Gallery",
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                }, onError: (error) {
                                  Navigator.pop(context);
                                  print(error);
                                  Fluttertoast.showToast(
                                    msg: "There was an error",
                                    gravity: ToastGravity.BOTTOM,
                                  );
                                });
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              alignment: Alignment.centerLeft,
                              height:
                                  MediaQuery.of(context).size.height / 17 - 7,
                              width: double.maxFinite,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text("Save"),
                                  !loading
                                      ? Container(
                                          width: 20,
                                        )
                                      : Container(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.black),
                                            strokeWidth: 1,
                                          ),
                                        ),
                                ],
                              ),
                            ))),
                  ],
                );
              }),
            ));
  }

  Widget buildItem(int index, MessageModel message) {
    if (message.from == fromId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          message.type == 0
              // Text
              ? Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(17),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(17)),
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                  child: InkWell(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(17),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(17)),
                    onLongPress: () => showDialogText(message, true),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(17.0, 12.0, 10.0, 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            message.content + "     ",
                          ),
                          Text(getDateTime(message.timeStamp),
                              style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(17),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(17)),
                    ),
                    margin: EdgeInsets.only(right: 10.0),
                    color: white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onLongPress: () => showDialogText(message, true),
                          child: Hero(
                            tag: message.content,
                            child: Material(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(17),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(17)),
                              ),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        themeColor),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    color: greyColor2,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: message.content,
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                          ),
                          onPressed: () => kopenPage(
                              context,
                              FullImage(
                                image: NetworkImage(message.content),
                                heroTag: message.content,
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5, right: 5),
                          child: Text(getDateTime(message.timeStamp),
                              style: TextStyle(fontSize: 10, color: black)),
                        )
                      ],
                    ),
                  ),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                ),
          // Sticker
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Row(
          children: <Widget>[
            isLastMessageLeft(index)
                ? Material(
                    child: CachedNetworkImage(
                      placeholder: (context, url) => Container(
                        child: SpinKitPulse(color: mainColor, size: 30),
                        /* CircularProgressIndicator(
                          strokeWidth: 1.0,
                        ), */
                        width: 35.0,
                        height: 35.0,
                        padding: EdgeInsets.all(10.0),
                      ),
                      imageUrl: recieverImage,
                      width: 35.0,
                      height: 35.0,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                  )
                : Container(width: 35.0),
            message.type == 0
                ? Card(
                    color: mainColor,
                    child: InkWell(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(17),
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(17)),
                      onTap: () => showDialogText(message, false),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              message.content + "     ",
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(getDateTime(message.timeStamp),
                                style: TextStyle(color: white, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(17),
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(17)),
                    ),
                    margin: EdgeInsets.only(left: 10.0),
                  )
                : Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(17),
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(17)),
                    ),
                    margin: EdgeInsets.only(left: 10.0),
                    color: mainColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextButton(
                          child: Hero(
                            tag: message.content,
                            child: Material(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(17),
                                    topLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(17)),
                              ),
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        themeColor),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                  padding: EdgeInsets.all(70.0),
                                  decoration: BoxDecoration(
                                    color: greyColor2,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                imageUrl: message.content,
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                          ),
                          onLongPress: () {
                            showDialogText(message, false);
                          },
                          onPressed: () => kopenPage(
                              context,
                              FullImage(
                                image: NetworkImage(message.content),
                                heroTag: message.content,
                              )),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5, left: 5),
                          child: Text(getDateTime(message.timeStamp),
                              style: TextStyle(fontSize: 10, color: white)),
                        )
                      ],
                    ),
                  ),
          ],
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  String getDateTime(int timestamp) {
    DateTime now = DateTime.now();
    DateFormat date = DateFormat('d');
    DateFormat year = DateFormat('y');
    DateFormat month = DateFormat('M');

    if (year.format(DateTime.fromMillisecondsSinceEpoch(timestamp)) ==
        year.format(now)) {
      if (month.format(DateTime.fromMillisecondsSinceEpoch(timestamp)) ==
          month.format(now)) {
        if (date.format(DateTime.fromMillisecondsSinceEpoch(timestamp)) ==
            date.format(now)) {
          return DateFormat('jm')
              .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
        } else {
          return DateFormat('d')
                  .format(DateTime.fromMillisecondsSinceEpoch(timestamp)) +
              ", " +
              DateFormat('jm')
                  .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
        }
      } else {
        return DateFormat('MMMM')
                .format(DateTime.fromMillisecondsSinceEpoch(timestamp)) +
            ", " +
            DateFormat('d')
                .format(DateTime.fromMillisecondsSinceEpoch(timestamp)) +
            " " +
            DateFormat('jm')
                .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
      }
    } else {
      return DateFormat('d')
              .format(DateTime.fromMillisecondsSinceEpoch(timestamp)) +
          "-" +
          DateFormat('MMM')
              .format(DateTime.fromMillisecondsSinceEpoch(timestamp)) +
          "-" +
          DateFormat('y')
              .format(DateTime.fromMillisecondsSinceEpoch(timestamp)) +
          ", " +
          DateFormat('jm')
              .format(DateTime.fromMillisecondsSinceEpoch(timestamp));
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == fromId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != fromId) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            // List of messages
            buildListMessage(),
            // Input content
            buildInput(),
          ],
        ),

        // Loading
        buildLoading()
      ],
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: kBuzyPage(color: mainColor),
              ),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
        child: Row(
          children: <Widget>[
            // Button send image
            InkWell(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: EdgeInsets.all(10),
                child: Icon(Icons.camera),
              ),
              onTap: () {
                imagePicker
                    .getImage(source: ImageSource.camera)
                    .then((file) async {
                  if (file != null) {
                    setState(() {
                      isLoading = true;
                    });
                    File image = File(file.path);
                    String path = await cropImage(image.path);
                    storageServices
                        .sendImage(
                      path: path,
                      sender: fromId,
                      reciever: recieverId,
                      name: DateTime.now().toString(),
                    )
                        .then((imageUrl) {
                      setState(() {
                        isLoading = false;
                        onSendMessage(imageUrl, 1);
                      });
                    }, onError: (err) {
                      setState(() {
                        isLoading = false;
                      });
                      Fluttertoast.showToast(
                        msg: err.message.toString(),
                        gravity: ToastGravity.BOTTOM,
                      );
                    });
                  }
                });
              },
            ),

            // Edit text
            Flexible(
              child: Container(
                child: TextField(
                  style: TextStyle(color: primaryColor, fontSize: 20.0),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: greyColor),
                  ),
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: EdgeInsets.all(10),
                child: Icon(
                  Icons.image,
                ),
              ),
              onTap: () {
                imagePicker
                    .getImage(source: ImageSource.gallery)
                    .then((file) async {
                  if (file != null) {
                    setState(() {
                      isLoading = true;
                    });
                    File image = File(file.path);
                    String path = await cropImage(image.path);
                    storageServices
                        .sendImage(
                      path: path,
                      sender: fromId,
                      reciever: recieverId,
                      name: DateTime.now().toString(),
                    )
                        .then((imageUrl) {
                      setState(() {
                        isLoading = false;
                        onSendMessage(imageUrl, 1);
                      });
                    }, onError: (err) {
                      setState(() {
                        isLoading = false;
                      });
                      Fluttertoast.showToast(
                        msg: err.message.toString(),
                        gravity: ToastGravity.BOTTOM,
                      );
                    });
                  }
                });
              },
            ),
            // Button send message
            Material(
              child: new Container(
                margin: new EdgeInsets.symmetric(horizontal: 8.0),
                child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => onSendMessage(textEditingController.text, 0),
                  color: Theme.of(context).accentColor,
                ),
              ),
              color: Colors.transparent,
            ),
          ],
        ),
        width: double.infinity,
        height: 50.0,
        decoration: new BoxDecoration(
            border:
                new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white));
  }

  int limit = 20;
  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  listMessage = snapshot.data.docs;
                  bool load =
                      limit <= 1000 && limit <= snapshot.data.docs.length;
                  return EasyListView(
                      reverse: true,
                      scrollbarEnable: true,
                      onLoadMore: () {
                        if (load)
                          setState(() {
                            limit = limit + 10;
                          });
                      },
                      loadMore: load,
                      itemCount: snapshot.data.docs.length,
                      controller: listScrollController,
                      padding: EdgeInsets.all(10),
                      itemBuilder: (context, index) => buildItem(
                          index,
                          MessageModel.fromMap(
                              snapshot.data.docs[index].data())));
                  /* return SingleChildScrollView(
                    reverse: true,
                    child: EasyListView(
                        scrollbarEnable: true,
                        onLoadMore: () {
                          setState(() {
                            limit = limit + 10;
                          });
                        },
                        itemCount: snapshot.data.docs.length,
                        controller: listScrollController,
                        padding: EdgeInsets.all(10),
                        itemBuilder: (context, index) => buildItem(
                            index,
                            MessageModel.fromMap(
                                snapshot.data.docs[index].data()))),
                  ); */
                  /* ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) =>
                          buildItem(index, MessageModel.fromMap(snapshot.data.docs[index].data())),
                      itemCount: snapshot.data.docs.length,
                      reverse: true,
                      controller: listScrollController,
                      physics: BouncingScrollPhysics()); */
                }
              },
            ),
    );
  }
}
/* Align(
                                  alignment: Alignment.bottomCenter,
                                  child: IconButton(
                                      icon: AnimatedIcon(
                                          icon: AnimatedIcons.play_pause,
                                          color: white.withOpacity(0.7),
                                          progress: iconAnimation),
                                      onPressed: () {
                                        if (videoController.value.isPlaying) {
                                          controller.pause();
                                          setState(() {
                                            iconAnimation.forward();
                                          });
                                        } else {
                                          videoController.play();
                                          setState(() {
                                            iconAnimation.reverse();
                                          });
                                        }
                                      }),
                                ) */
