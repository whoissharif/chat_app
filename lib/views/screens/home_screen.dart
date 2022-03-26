import 'dart:developer';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/views/screens/sign_in_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/home_provider.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeProvider homeProvider;
  late AuthProvider authProvider;
  String? currentUserId;
  final storage = const FlutterSecureStorage();
  String? userName;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      currentUserId = (await storage.read(key: "id"))!;
      userName = await storage.read(key: "name");
      if (mounted) {
        setState(() {});
      }
    });

    homeProvider = context.read<HomeProvider>();
    authProvider = context.read<AuthProvider>();
  }

  @override
  Widget build(BuildContext context) {
    log(currentUserId.toString());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat Time'),
            Text(
              'Signed in as $userName',
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                authProvider.handleSignOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text(
                'Sign out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: homeProvider.getStreamFireStore(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            if ((snapshot.data?.docs.length ?? 0) > 0) {
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, index) {
                  return buildUserTile(context, snapshot.data?.docs[index]);
                },
                itemCount: snapshot.data?.docs.length,
              );
            } else {
              return const Center(
                child: Text("No users"),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget buildUserTile(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserModel user = UserModel.fromDocument(document);
      if (user.id == currentUserId.toString()) {
        return const SizedBox.shrink();
      } else {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  id: currentUserId.toString(),
                  peerId: user.id,
                  peerName: user.name,
                  peerImgUrl: user.photoUrl,
                ),
              ),
            );
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Material(
                  child: user.photoUrl.isNotEmpty
                      ? Image.network(
                          user.photoUrl,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              size: 50,
                            );
                          },
                        )
                      : const Icon(
                          Icons.account_circle,
                          size: 50,
                        ),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  clipBehavior: Clip.hardEdge,
                ),
                title: Text(
                  user.name,
                  maxLines: 1,
                ),
                trailing: const Icon(Icons.chat),
              ),
            ),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
