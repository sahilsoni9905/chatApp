import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/common/loader.dart';
import 'package:whatsapp_clone/features/chat/controllers/chat_controllers.dart';
import 'package:whatsapp_clone/features/chat/screens/mobile_chat_screen.dart';
import 'package:whatsapp_clone/models/chat_contact_model.dart';
import 'package:whatsapp_clone/utils/colors.dart';
import 'package:whatsapp_clone/utils/info.dart';
import 'package:whatsapp_clone/features/chat/widgets/chatlist.dart';

class ContactList extends ConsumerWidget {
  const ContactList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatContact>>(
                stream: ref.watch(chatControllerProvider).chatContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Loader();
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var chatContactData = snapshot.data![index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            MobileChatScreen.routeName,
                            arguments: {
                              'name': chatContactData.name,
                              'uid': chatContactData.contactId
                            },
                          );
                        },
                        child: ListTile(
                          title: Text(chatContactData.name,
                              style: TextStyle(fontSize: 18)),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              chatContactData.lastMessage,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(chatContactData.profilePic),
                          ),
                          trailing: Text(
                            DateFormat.Hm().format(chatContactData.timeSent),
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  );
                }),
          ),
          const Divider(
            color: dividerColor,
          ),
        ],
      ),
    );
  }
}
