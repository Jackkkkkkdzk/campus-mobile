// To parse this JSON data, do
//
//     final messages = messagesFromJson(jsonString);

import 'dart:convert';

Messages messagesFromJson(String str) => Messages.fromJson(json.decode(str));

String messagesToJson(Messages data) => json.encode(data.toJson());

class Messages {
  List<MessageElement> messages;
  int? next; // confirmed optional

  Messages({required this.messages, this.next});

  Messages.fromJson(Map<String, dynamic> json)
      : messages = List<MessageElement>.from(
                      json["messages"].map((x) => MessageElement.fromJson(x))),
        next = json["next"];

  Map<String, dynamic> toJson() => {
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
        "next": next
      };
}

class MessageElement {
  MessageElement({
    required this.sender,
    required this.message,
    required this.messageId,
    required this.audience,
    required this.timestamp,
  });

  String sender;
  Message message;
  String messageId;
  Audience audience;
  int timestamp;

  MessageElement.fromJson(Map<String, dynamic> json)
      : sender = json["sender"],
        message = Message.fromJson(json["message"]),
        messageId = json["messageId"],
        audience = Audience.fromJson(json["audience"]),
        timestamp = json["timestamp"];

  Map<String, dynamic> toJson() => {
        "sender": sender,
        "message": message.toJson(),
        "messageId": messageId ,
        "audience": audience.toJson(),
        "timestamp": timestamp,
      };
}

class Audience {
  Audience({
    this.topics,
  });

  List<String>? topics; // this is a direct message if it's null

  Audience.fromJson(Map<String, dynamic> json)
    : topics = json["topics"] != null ? List<String>.from(json["topics"].map((x) => x)) : null;

  Map<String, dynamic> toJson() => {
        "topics": topics != null ? List<dynamic>.from(topics!.map((x) => x)) : null
      };
}

class Message {

  String message;
  String title;
  Data data;

  Message({
    required this.message,
    required this.title,
    required this.data,
  });

  Message.fromJson(Map<String, dynamic> json)
      // Defaulting to empty strings until we figure out what should or should not be null on the backend
      : message = json["message"] ?? "",
        title = json["title"] ?? "",
        data = Data.fromJson(json["data"]);

  Map<String, dynamic> toJson() => {
        "message": message,
        "title": title,
        "data": data.toJson(),
      };
}

class Data {
  Data();

  factory Data.fromJson(Map<String, dynamic>? json) => Data();

  Map<String, dynamic> toJson() => {};
}
