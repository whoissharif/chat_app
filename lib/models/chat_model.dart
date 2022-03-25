import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String idFrom;
  String idTo;
  String timestamp;
  String content;

  ChatModel({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'idFrom': this.idFrom,
      'idTo': this.idTo,
      'timestamp': this.timestamp,
      'content': this.content,
    };
  }

  factory ChatModel.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get('idFrom');
    String idTo = doc.get('idTo');
    String timestamp = doc.get('timestamp');
    String content = doc.get('content');

    return ChatModel(
      idFrom: idFrom,
      idTo: idTo,
      timestamp: timestamp,
      content: content,
    );
  }
}
