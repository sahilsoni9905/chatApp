import 'package:flutter/material.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/features/chat/widgets/display_image_text_gif.dart';
import 'package:whatsapp_clone/utils/colors.dart';

class SenderMessageCart extends StatelessWidget {
  final String message;
  final String date;
  final MessageEnum type;
  final String repliedText;
  final String username;
  final MessageEnum repliedMessageType;
  final VoidCallback onRightSwipe;
  final bool isSeen; // Added isSeen to match MyMessageCart
  const SenderMessageCart(
      {super.key,
      required this.message,
      required this.date,
      required this.type,
      required this.onRightSwipe,
      required this.repliedMessageType,
      required this.repliedText,
      required this.username,
      required this.isSeen}); // Added isSeen to the constructor

  @override
  Widget build(BuildContext context) {
    final isReplying = repliedText.isNotEmpty;
    return SwipeTo(
      onRightSwipe: (details) => onRightSwipe(),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 45),
          child: Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            color: messageColor, // Changed to messageColor to be consistent
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 5, bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isReplying) ...[
                        Text(
                          username,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: backgroundColor.withOpacity(0.5),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: DisplayTextImageGif(
                              message: repliedText, type: repliedMessageType),
                        ),
                        const SizedBox(
                          height: 5,
                        )
                      ],
                      DisplayTextImageGif(message: message, type: type),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 4, // Changed to 4 to be consistent
                  right: 10,
                  child: Row(children: [
                    Text(
                      date,
                      style: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Icon(
                      isSeen ? Icons.done_all : Icons.done, // Updated to use isSeen
                      size: 20,
                      color: isSeen ? Colors.blue : Colors.white60,
                    )
                  ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
