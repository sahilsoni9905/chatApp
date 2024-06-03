import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/enums/message_enum.dart';
import 'package:whatsapp_clone/common/providers/message_reply_provider.dart';
import 'package:whatsapp_clone/common/repositories/common_firebase_repository.dart';
import 'package:whatsapp_clone/models/chat_contact_model.dart';
import 'package:whatsapp_clone/models/message_models.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/utils/info.dart';
import 'package:whatsapp_clone/utils/snackbar.dart';

final ChatRepositoryProvider = Provider((ref) => ChatRepository(
    auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance));

class ChatRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  ChatRepository({required this.auth, required this.firestore});

  Stream<List<ChatContact>> getChatContacts() {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap(
      (event) async {
        List<ChatContact> contacts = [];
        for (var document in event.docs) {
          var chatContact = ChatContact.fromMap(document.data());
          var userData = await firestore
              .collection('users')
              .doc(chatContact.contactId)
              .get();
          var user = userModel.fromMap(userData.data()!);
          contacts.add(ChatContact(
              name: user.name,
              profilePic: user.profilePic,
              contactId: user.uid,
              timeSent: chatContact.timeSent,
              lastMessage: chatContact.lastMessage));
        }
        return contacts;
      },
    );
  }

  Stream<List<Message>> getChatStream(String recieverUserId) {
    return firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .orderBy('timeSent')
        .snapshots()
        .map((event) {
      List<Message> messages = [];
      for (var document in event.docs) {
        messages.add(Message.fromMap(document.data()));
      }
      return messages;
    });
  }

  void _saveMessageToMessageSubcollection({
    required String recieverUserId,
    required String text,
    required DateTime timeSent,
    required String messageId,
    required String username,
    required String recieverUsername,
    required MessageEnum messageType,
    required MessageReply? messageReply,
    required String senderUsername,
  }) async {
    final message = Message(
      senderId: auth.currentUser!.uid,
      receiverId: recieverUserId,
      text: text,
      type: messageType,
      timeSent: timeSent,
      messageId: messageId,
      isSeen: false,
      repliedMessage: messageReply == null ? '' : messageReply.message,
      repliedTo: messageReply == null
          ? ''
          : messageReply.isMe
              ? senderUsername
              : recieverUsername,
      repliedMessageType:
          messageReply == null ? MessageEnum.text : messageReply.messageEnum,
    );
    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());

    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .set(message.toMap());
  }

  void _saveDataToContactsSubcollection(
      {required userModel senderUserData,
      required userModel recieverUserData,
      required String text,
      required DateTime timeSent,
      required String reciverUserid}) async {
    // users ->  reciever id -> chats -> current user id -> store message
    var recieverChatContact = ChatContact(
        name: senderUserData.name,
        profilePic: senderUserData.profilePic,
        contactId: senderUserData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await firestore
        .collection('users')
        .doc(reciverUserid)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .set(recieverChatContact.toMap());

    // users ->  current id -> chats -> receiver user id -> store message

    var senderChatContact = ChatContact(
        name: recieverUserData.name,
        profilePic: recieverUserData.profilePic,
        contactId: recieverUserData.uid,
        timeSent: timeSent,
        lastMessage: text);

    await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(reciverUserid)
        .set(senderChatContact.toMap());
  }

  void sendTextMessage({
    required BuildContext context,
    required String text,
    required String recieverUserId,
    required userModel senderUser,
    required MessageReply? messageReply,
  }) async {
    // users -> sender id -> reciever id -> messages -> message id -> store message
    try {
      var timeSent = DateTime.now();
      userModel recieverUserData;
      var userDataMap =
          await firestore.collection('users').doc(recieverUserId).get();
      // got the snapshot now we have to convert it into model
      recieverUserData = userModel.fromMap(userDataMap.data()!);
      // installed a dependancy to create unique id uuid
      var messageId = const Uuid().v1();
      _saveDataToContactsSubcollection(
        senderUserData: senderUser,
        recieverUserData: recieverUserData,
        text: text,
        timeSent: timeSent,
        reciverUserid: recieverUserId,
      );

      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: text,
        timeSent: timeSent,
        messageType: MessageEnum.text,
        messageId: messageId,
        recieverUsername: recieverUserData.name,
        username: senderUser.name,
        messageReply: messageReply,
        senderUsername: senderUser.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  // now to send file instead of text
  void sendFileMessage({
    required BuildContext context,
    required File file,
    required String recieverUserId,
    required userModel senderUserData,
    required ProviderRef ref,
    required MessageEnum messageEnum,
    required MessageReply? messageReply,
  }) async {
    try {
      var timeSent = DateTime.now();
      var messageId = const Uuid().v1();
      String imageUrl = await ref
          .read(CommonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase(
              'chat/${messageEnum.type}/${senderUserData.uid}/${recieverUserId}/$messageId',
              file);

      userModel recieveruserData;
      var userDataMap =
          await firestore.collection('users').doc(recieverUserId).get();
      recieveruserData = userModel.fromMap(userDataMap.data()!);
      String contactMsg;
      if (messageEnum == MessageEnum.image) {
        contactMsg = '📷 photo';
      } else if (messageEnum == MessageEnum.video) {
        contactMsg = '🎥 video';
      } else if (messageEnum == MessageEnum.audio) {
        contactMsg = '🎙️ audio';
      } else {
        contactMsg = 'noi pata';
      }

      _saveDataToContactsSubcollection(
          senderUserData: senderUserData,
          recieverUserData: recieveruserData,
          text: contactMsg,
          timeSent: timeSent,
          reciverUserid: recieverUserId);
      _saveMessageToMessageSubcollection(
        recieverUserId: recieverUserId,
        text: imageUrl,
        timeSent: timeSent,
        messageId: messageId,
        username: senderUserData.name,
        recieverUsername: recieveruserData.name,
        messageType: messageEnum,
        messageReply: messageReply,
        senderUsername: senderUserData.name,
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  void setChatMessageSeen(
      BuildContext context, String recieverUserId, String messageId) async {
    try {
       await firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUserId)
        .collection('messages')
        .doc(messageId)
        .update({'isSeen' : true});

    await firestore
        .collection('users')
        .doc(recieverUserId)
        .collection('chats')
        .doc(auth.currentUser!.uid)
        .collection('messages')
        .doc(messageId)
        .update({'isSeen' : true});
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
  
}
