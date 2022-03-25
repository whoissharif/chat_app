import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String photoUrl;
  String name;

  UserModel({required this.id, required this.photoUrl, required this.name});

  Map<String, String> toJson() {
    return {
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String nickname = "";

    try {
      photoUrl = doc.get('photoUrl');
    } catch (e) {}
    try {
      nickname = doc.get('name');
    } catch (e) {}
    return UserModel(
      id: doc.id,
      photoUrl: photoUrl,
      name: nickname,
    );
  }
}
