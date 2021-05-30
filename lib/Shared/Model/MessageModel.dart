import 'package:helphub/core/enums/UserType.dart';

class MessageModel {
  final String from;
  final String to;
  final String content;
  final UserType userType;
  final String senderToken;
  final int timeStamp;
  final int type;
  MessageModel({
    this.from,
    this.to,
    this.content,
    this.userType,
    this.senderToken,
    this.timeStamp,
    this.type,
  });
  MessageModel.fromMap(Map<String, dynamic> data)
      : this(
            to: data['idTo'],
            from: data['idFrom'],
            content: data['content'],
            timeStamp: data['timestamp'],
            userType: UserTypeHelper.getEnum(data['userType']),
            type: data['type'],
            senderToken: data['token']);

  Map<String, dynamic> toMap(MessageModel message) {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['idTo'] = message.to;
    data['idFrom'] = message.from;
    data['content'] = message.content;
    data['timestamp'] = message.timeStamp;
    data['type'] = message.type;
    data['userType'] = UserTypeHelper.getValue(message.userType);
    data['token'] = message.senderToken;
    return data;
  }
}
