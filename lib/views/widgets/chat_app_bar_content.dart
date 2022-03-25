import 'package:chat_app/constants/color_constants.dart';
import 'package:flutter/material.dart';

import 'app_bar_button.dart';

class ChatAppBarContent extends StatelessWidget {
  const ChatAppBarContent({
    Key? key,
    required this.imgUrl,
    required this.name,
  }) : super(key: key);

  final String imgUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            kAppBarGradPrimary,
            kAppBarGradSecondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          Material(
            child: Image.network(
              imgUrl,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
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
          ),
          const SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white),
              ),
              const Text(
                'Online',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          AppBarButton(
            icon: Icons.call_outlined,
            ontap: () {},
          ),
          const SizedBox(
            width: 10,
          ),
          AppBarButton(
            icon: Icons.video_call,
            ontap: () {},
          ),
        ],
      ),
    );
  }
}
