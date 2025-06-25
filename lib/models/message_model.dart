class MessageModel {
  String? msgId;
  String? message;
  String? fromId;
  String? toId;
  String? sentAt;
  String? readAt;
  int? msgType; //0-txt, 1-image
  String? imgUrl;

  MessageModel({
    required this.msgId,
    required this.message,
    required this.fromId,
    required this.toId,
    required this.sentAt,
    this.readAt = "",
    this.msgType = 0,
    this.imgUrl = "",
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      msgId: map["msgId"],
      message: map["message"],
      fromId: map["fromId"],
      toId: map["toId"],
      sentAt: map["sentAt"],
      readAt: map["readAt"],
      msgType: map["msgType"],
      imgUrl: map["imgUrl"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "msgId": msgId,
      "message": message,
      "fromId": fromId,
      "toId": toId,
      "sentAt": sentAt,
      "readAt": readAt,
      "msgType": msgType,
      "imgUrl": imgUrl,
    };
  }
}
