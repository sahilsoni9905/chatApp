import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
      var statusId = const Uuid().v1();
      String uid = auth.currentUser!.uid;
      String imageUrl = await ref
          .read(CommonFirebaseStorageRepositoryProvider)
          .storeFileToFirebase('/status/$statusId$uid', statusImage);
      print('firebase storage me save ho gya');
      List<Contact> contacts = [];

      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      } //withproperties give number of the contacts .. if we keep it false we will only get the names
      print('jitne bhi contacts hai sb aa gye');
      List<String> uidWhoCanSee = [];
      for (int i = 0; i < contacts.length; i++) {
        var userDataFirebase = await firestore
            .collection('users')
            .where('phoneNumber',
                isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''))
            .get();
        if (userDataFirebase.docs.isNotEmpty) {
          var userData = userModel.fromMap(userDataFirebase.docs[0].data());
          uidWhoCanSee.add(userData.uid);
        }
        print('got list of all who can see');
      }

      List<String> statusImageUrls = [];
      var statusesSnapshot = await firestore
          .collection('status')
          .where('uid', isEqualTo: auth.currentUser!.uid)
          .get();
      if (statusesSnapshot.docs.isNotEmpty) {
        Status status = Status.fromMap(statusesSnapshot.docs[0].data());
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageUrl);
        await firestore
            .collection('status')
            .doc(statusesSnapshot.docs[0].id)
            .update({'photoUrl': statusImageUrls});
        return;
      } else {
        statusImageUrls = [imageUrl];
      }
      Status status = Status(
          uid: uid,
          username: username,
          phoneNumber: phoneNumber,
          photoUrl: statusImageUrls,
          createdAt: DateTime.now(),
          profilePic: profilePic,
          statusId: statusId,
          whoCanSee: uidWhoCanSee);
      await firestore.collection('status').doc(statusId).set(status.toMap());
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];
    try {
      List<Contact> contacts = [];

      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
      for (int i = 0; i < contacts.length; i++) {
        var statusesSnaphot = await firestore
            .collection('status')
            .where('phoneNumber',
                isEqualTo: contacts[i].phones[0].number.replaceAll(' ', ''))
            .get();
        for (var tempData in statusesSnaphot.docs) {
          Status tempStatus = Status.fromMap(tempData.data());
          if (tempStatus.whoCanSee.contains(auth.currentUser!.uid)) {
            statusData.add(tempStatus);
          }
        }
      }
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
    return statusData;
  }
}
