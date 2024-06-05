import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/calls/controllers/call_controller.dart';
import 'package:whatsapp_clone/common/loader.dart';
import 'package:whatsapp_clone/config/agora_config.dart';
import 'package:whatsapp_clone/models/call_models.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String channelId;
  final Call call;

  const CallScreen({
    Key? key,
    required this.channelId,
    required this.call,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            IconButton(
              onPressed: () async {
                ref.read(callControllerProvider).endCall(
                      widget.call.callerId,
                      widget.call.receiverId,
                      context,
                    );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.call_end),
            ),
          ],
        ),
      ),
    );
  }
}
