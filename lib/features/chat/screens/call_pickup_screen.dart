import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp_clone/calls/controllers/call_controller.dart';
import 'package:whatsapp_clone/features/chat/screens/call_screen.dart';
import 'package:whatsapp_clone/models/call_models.dart';

class CallPickupScreen extends ConsumerWidget {
  final Widget scaffold;
  const CallPickupScreen({super.key, required this.scaffold});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerProvider).callStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call call =
              Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);
          if (!call.hadDialled) {
            return Scaffold(
              body: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Incoming Call',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage(call.callerPic),
                      radius: 60,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Text(
                      call.callerName,
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.call_end,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(
                          width: 25,
                        ),
                        IconButton(
                          onPressed: () {
                             Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CallScreen(
                  channelId: call.callId, call: call)));
                          },
                          icon: Icon(
                            Icons.call,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        }
        return scaffold;
      },
    );
  }
}
