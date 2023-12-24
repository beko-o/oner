import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oner/screens/bottom_navigation/chatting/chat_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, int> unreadMessagesCount = {};
  Map<String, String> lastMessagesContent = {};

  Widget _buildUserList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('user_info').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Ошибка');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Загрузка...');
        }

        final List<Widget> userListItems = [];
        final List<String> usersWithChats = [];

        snapshot.data!.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          final String userEmail = data['email'];
          final String userID = data['uid'];
          final String userName = '${data['firstName']} ${data['lastName']}';

          if (_auth.currentUser!.email != userEmail) {
            usersWithChats.add(userID);

            int unreadCount = unreadMessagesCount[userID] ?? 0;

            userListItems.add(
              ListTile(
                title: Text(userName),
                subtitle: _buildLastMessageContent(userID),
                leading: FutureBuilder<String>(
                  future: _getAvatarURL(userID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar();
                    } else {
                      final avatarUrl = snapshot.data ?? '';
                      return CircleAvatar(
                        backgroundImage: avatarUrl.isNotEmpty
                            ? NetworkImage(avatarUrl)
                            : const AssetImage('assets/default-avatar.png')
                                as ImageProvider<Object>,
                      );
                    }
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        recieverUserEmail: userName,
                        recieverUserID: userID,
                      ),
                    ),
                  );
                  setState(() {
                    unreadMessagesCount[userID] = 0;
                  });
                },
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (unreadCount > 0)
                      Text(
                        'Новых сообщений: $unreadCount',
                        style: const TextStyle(color: Colors.red),
                      ),
                    _buildLastMessageTime(userID),
                  ],
                ),
              ),
            );
          }
        });

        if (usersWithChats.isNotEmpty) {
          return ListView(children: userListItems);
        } else {
          return const Center(child: Text('Пока нет чатов'));
        }
      },
    );
  }

  Widget _buildLastMessageTime(String userID) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(_getChatRoomID(userID))
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Ошибка');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Загрузка...');
        }

        final List<QueryDocumentSnapshot> messages = snapshot.data!.docs;

        if (messages.isNotEmpty) {
          final Timestamp lastMessageTimestamp = messages.first['timestamp'];
          final DateTime lastMessageDateTime = lastMessageTimestamp.toDate();
          final String formattedTime =
              '${lastMessageDateTime.hour}:${lastMessageDateTime.minute.toString().padLeft(2, '0')}';
          return Text(' $formattedTime');
        } else {
          return const SizedBox(); // Пустой виджет, если сообщений нет
        }
      },
    );
  }

  Widget _buildLastMessageContent(String userID) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(_getChatRoomID(userID))
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text('Ошибка');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Загрузка...');
        }

        final List<QueryDocumentSnapshot> messages = snapshot.data!.docs;

        if (messages.isNotEmpty) {
          final String lastMessageContent = messages.first['message'];
          return Text(' $lastMessageContent');
        } else {
          return const SizedBox(); // Пустой виджет, если сообщений нет
        }
      },
    );
  }

  String _getChatRoomID(String otherUserID) {
    List<String> ids = [_auth.currentUser!.uid, otherUserID];
    ids.sort();
    return ids.join('_');
  }

  Future<String> _getAvatarURL(String userID) async {
    try {
      final storageReference =
          FirebaseStorage.instance.ref().child('avatars/avatar_$userID.jpg');
      final downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Ошибка при загрузке изображения из Firebase Storage: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
        centerTitle: true,
      ),
      body: _buildUserList(),
    );
  }
}
