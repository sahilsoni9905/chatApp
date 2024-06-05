import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:whatsapp_clone/common/repositories/common_firebase_repository.dart';
import 'package:whatsapp_clone/models/status_models.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/utils/snackbar.dart';

final StatusRepositoryProvider = Provider((ref) => StatusRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref));

class StatusRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  StatusRepository(
      {required this.firestore, required this.auth, required this.ref});

  void uploadStatus({
    required String username,
    required String profilePic,
    required String phoneNumber,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      print('part 1 .............');
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;

      // Uploading image to Firebase Storage
      String imageUrl = await ref
          .read(CommonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase('/status/$statusId$uid', statusImage);
      print('Image uploaded to Firebase Storage: $imageUrl');

      // Fetching contacts
      List<Contact> contacts = [];
      print('part 2 .............');
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
        print('Contacts fetched: ${contacts.length}');
      }

      // Determining who can see the status
      List<String> uidWhoCanSee = [];
      for (int i = 0; i < contacts.length; i++) {
        try {
          if (contacts[i].phones.length == 0) {
            continue;
          }
          var userDataFirebase = await firestore
              .collection('users')
              .where('phoneNumber',
                  isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''))
              .get();

          print('part 3 ............. ');
          if (userDataFirebase.docs.isNotEmpty) {
            var userData = userModel.fromMap(userDataFirebase.docs[0].data());
            uidWhoCanSee.add(userData.uid);
            print('User who can see added: ${userData.uid}');
          }
        } catch (e) {
          print(
              'Error fetching user data: ${contacts[i].phones[0].number}, Error: $e');
        }
      }

      // Updating or creating status
      List<String> statusImageUrls = [];
      try {
        var statusesSnapshot = await firestore
            .collection('status')
            .where('uid', isEqualTo: auth.currentUser!.uid)
            .get();
        print('part 4 .............');
        if (statusesSnapshot.docs.isNotEmpty) {
          Status status = Status.fromMap(statusesSnapshot.docs[0].data());
          statusImageUrls = status.photoUrl;
          statusImageUrls.add(imageUrl);
          await firestore
              .collection('status')
              .doc(statusesSnapshot.docs[0].id)
              .update({'photoUrl': statusImageUrls});
          print('Status updated');
        } else {
          statusImageUrls = [imageUrl];
          Status status = Status(
              uid: uid,
              username: username,
              phoneNumber: phoneNumber,
              photoUrl: statusImageUrls,
              createdAt: DateTime.now(),
              profilePic: profilePic,
              statusId: statusId,
              whoCanSee: uidWhoCanSee);
          await firestore
              .collection('status')
              .doc(statusId)
              .set(status.toMap());
          print('Status created');
        }
      } catch (e) {
        print('Error updating/creating status: $e');
        rethrow;
      }

      print('all task done ');
    } catch (e) {
      // Check if the context is still valid before showing the snackbar
      if (context.mounted) {
        showSnackBar(
            context: context,
            content:
                '${e.toString()} Error in repository while uploading status');
      }
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    print('1.....');
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];
      print('2.....');
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
        print('3.....');
      }
      for (int i = 0; i < contacts.length; i++) {
        if (contacts[i].phones.length == 0) {
          continue;
        }

        print('4..... ${contacts[i].name}');
        var statusesSnaphot = await firestore
            .collection('status')
            .where('phoneNumber',
                isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''))
            .get();
        print('sahil sahil , ${statusesSnaphot.docs}');

        for (var tempData in statusesSnaphot.docs) {
          print('sahil soni is great');
          Status tempStatus = Status.fromMap(tempData.data());
          print('$tempStatus');
          if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
          }
        }
      }
      print('7.....');
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
    return statusData;
  }
}
