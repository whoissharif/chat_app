import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerImgUrl,
  }) : super(key: key);

  final String id;
  final String peerId;
  final String peerName;
  final String peerImgUrl;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
