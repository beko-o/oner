import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oner/screens/bottom_navigation/chatting/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //SEND MESSAGES
  Future<void> sendMessage(String recieverID, String message,
      {String? replyToMessageId}) async {
    //get current user info
    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      recieverID: recieverID,
      message: message,
      timestamp: timestamp,
      replyToMessageId: replyToMessageId,
    );

    //construct chat room id from current user id and reciever id (sorted to ensure uniquness)
    List<String> ids = [currentUserID, recieverID];
    ids.sort(); //sort the ids to always have the same id for two people
    String chatRoomID = ids
        .join("_" // combine the ids into a single string to use as a chatRoomID
            );

    //add new message to database
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
  }

  //GET MESSAGES
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    //construct chat room id from user ids
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
