import 'package:chat_app/constants/color_constants.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../widgets/bottom_sheet_item.dart';
import '../widgets/chat_app_bar_content.dart';

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
  String groupChatId = "";
  List<QueryDocumentSnapshot> listMessage = [];
  final TextEditingController textEditingController = TextEditingController();
  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    String peerId = widget.peerId;
    if (widget.id.compareTo(peerId) > 0) {
      groupChatId = '${widget.id}-$peerId';
    } else {
      groupChatId = '$peerId-${widget.id}';
    }
  }

  void onSendMessage(String content) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      FocusScope.of(context).unfocus();
      chatProvider.sendMessage(content, groupChatId, widget.id, widget.peerId);
    } else {
      debugPrint('nothing to send');
    }
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      ChatModel chatModel = ChatModel.fromDocument(document);
      if (chatModel.idFrom == widget.id) {
        return Column(
          children: [
            Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    child: Text(
                      chatModel.content,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.centerRight,
                          colors: [
                            kAppBarGradPrimary,
                            kAppBarGradSecondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.only(
                        bottom: 5, right: 10, top: 10, left: 50),
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Text(
                    DateFormat.MMMd().add_jm().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            int.parse(chatModel.timestamp))),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      } else {
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          child: Image.network(
                            widget.peerImgUrl,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(
                                Icons.account_circle,
                                size: 35,
                              );
                            },
                            width: 35,
                            height: 35,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(18),
                          ),
                          clipBehavior: Clip.hardEdge,
                        )
                      : Container(width: 35),
                  Flexible(
                    child: Container(
                      child: Text(
                        chatModel.content,
                        style: const TextStyle(color: Colors.black),
                      ),
                      padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                      decoration: BoxDecoration(
                          color: kLeftChatBg,
                          borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.only(left: 10, right: 50),
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat.MMMd().add_jm().format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(chatModel.timestamp))),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: const EdgeInsets.only(bottom: 10),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') == widget.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') != widget.id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: ChatAppBarContent(
              imgUrl: widget.peerImgUrl, name: widget.peerName),
        ),
        body: Stack(
          children: [
            Column(children: [
              buildListMessage(),
              buildInput(),
            ]),
          ],
        ),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: chatProvider.getChatStream(groupChatId),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.length > 0) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                    );
                  } else {
                    return const Center(child: Text("No message here yet..."));
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image

          Material(
            child: SizedBox(
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  showMoreChatOptions();
                },
              ),
            ),
            color: Colors.white,
          ),

          Flexible(
            child: SizedBox(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text);
                },
                style: const TextStyle(fontSize: 15),
                controller: textEditingController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type your message...',
                ),
              ),
            ),
          ),
          Material(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text),
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }

  Future<dynamic> showMoreChatOptions() {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * .28,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                kAppBarGradPrimary,
                kAppBarGradSecondary,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: GridView.count(
              crossAxisCount: 4,
              children: const [
                BottomSheetItem(
                  icon: Icons.camera_alt,
                  text: 'camera',
                ),
                BottomSheetItem(
                  icon: Icons.money,
                  text: 'Send Money',
                ),
                BottomSheetItem(
                  icon: Icons.attachment_outlined,
                  text: 'Attachment',
                ),
                BottomSheetItem(
                  icon: Icons.games,
                  text: 'Games',
                ),
                BottomSheetItem(
                  icon: Icons.location_pin,
                  text: 'Location',
                ),
                BottomSheetItem(
                  icon: Icons.call,
                  text: 'Schedule a call',
                ),
                BottomSheetItem(
                  icon: Icons.music_note,
                  text: 'Caller tune',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
