import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/calls/controllers/call_controller.dart';
import 'package:whatsapp_clone/common/loader.dart';
import 'package:whatsapp_clone/features/auth/controllers/auth_controller.dart';
import 'package:whatsapp_clone/features/chat/screens/call_pickup_screen.dart';
import 'package:whatsapp_clone/features/chat/widgets/bottom_chat_field.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/utils/colors.dart';
import 'package:whatsapp_clone/utils/info.dart';
import 'package:whatsapp_clone/features/chat/widgets/chatlist.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final String profilePic;
  const MobileChatScreen(
      {super.key,
      required this.name,
      required this.uid,
      required this.profilePic});

  void makeCall(WidgetRef ref, BuildContext context) {
    ref.read(callControllerProvider).makeCall(context, name, uid, profilePic);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: StreamBuilder<userModel>(
            stream: ref.read(authControllerProvider).userDataById(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Loader();
              }
              return Column(
                children: [
                  Text(name),
                  Text(
                    snapshot.data!.isOnline ? 'online' : 'offline',
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.normal),
                  )
                ],
              );
            }),
        actions: [
          IconButton(
              onPressed: () => makeCall(ref, context),
              icon: Icon(Icons.video_call)),
          IconButton(onPressed: () {}, icon: Icon(Icons.call)),
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        //chat list
        //text input
        children: [
          Expanded(
              child: ChatList(
            recieverUserId: uid,
          )),
          bottomChatField(recieverUserId: uid),
        ],
      ),
    );
  }
}
