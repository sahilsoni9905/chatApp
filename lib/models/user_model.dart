// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class userModel {
  final String name;
  final String uid;
  final String profilePic;
  final bool isOnline;
  final String phoneNumber;
  final List<String> groupId;

  userModel(
      {required this.name,
      required this.uid,
      required this.profilePic,
      required this.isOnline,
      required this.phoneNumber,
      required this.groupId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'phoneNumber': phoneNumber,
      'groupId': groupId,
    };
  }

  factory userModel.fromMap(Map<String, dynamic> map) {
    return userModel(
        name: map['name'] ?? '',
        uid: map['uid'] ?? '',
        profilePic: map['profilePic'] ?? '',
        isOnline: map['isOnline'] ?? false,
        phoneNumber: map['phoneNumber'] ?? '',
        groupId: List<String>.from(
          (map['groupId']),
        ));
  }
}
