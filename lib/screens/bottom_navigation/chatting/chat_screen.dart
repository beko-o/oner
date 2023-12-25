import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:oner/additional/textfield.dart';
import 'package:oner/screens/bottom_navigation/chatting/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String recieverUserID;
  final String recieverUserEmail;

  const ChatPage({
    Key? key,
    required this.recieverUserID,
    required this.recieverUserEmail,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _replyController = TextEditingController();
  // ignore: unused_field
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('user_info')
          .doc(widget.recieverUserID)
          .get();

      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      String firstName = userData['firstName'];
      String lastName = userData['lastName'];

      setState(() {
        _userName = '$firstName $lastName';
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void replyToMessage(
      String messageId, String senderEmail, String originalMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ответ к $senderEmail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Сообщение: $originalMessage'),
              TextField(
                controller: _replyController,
                decoration: const InputDecoration(labelText: 'Ваш ответ'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отменить'),
            ),
            TextButton(
              onPressed: () async {
                String replyMessage = _replyController.text;

                await _chatService.sendMessage(
                  widget.recieverUserID,
                  replyMessage,
                  replyToMessageId: messageId,
                );

                Navigator.of(context).pop();
              },
              child: const Text('Ответить'),
            ),
          ],
        );
      },
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.recieverUserID, _messageController.text);
      _messageController.clear();
    }
  }

  Future<String> _getAvatarURL(String userID) async {
    try {
      final storageReference =
          FirebaseStorage.instance.ref().child('avatars/avatar_$userID.jpg');
      final downloadUrl = await storageReference.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error loading avatar from Firebase Storage: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recieverUserEmail),
        backgroundColor: Color.fromARGB(255, 178, 128, 174),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
              ),
              child: _buildMessageList(),
            ),
          ),
          _builMessageInput(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.recieverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderID'] == _firebaseAuth.currentUser!.uid)
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.green,
        child: const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(
            Icons.reply,
            color: Colors.white,
          ),
        ),
      ),
      onDismissed: (direction) {
        replyToMessage(
          document.id,
          data['senderEmail'],
          data['message'],
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: alignment,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alignment == MainAxisAlignment.start)
              FutureBuilder<String>(
                future: _getAvatarURL(data['senderID']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircleAvatar();
                  } else {
                    final avatarUrl = snapshot.data ?? '';
                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const AssetImage('assets/default-avatar.png')
                              as ImageProvider<Object>,
                    );
                  }
                },
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: (alignment == MainAxisAlignment.start)
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                      color: (alignment == MainAxisAlignment.start)
                          ? Colors.white
                          : Color.fromARGB(255, 213, 145, 207),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['message'],
                          style: TextStyle(
                            color: (alignment == MainAxisAlignment.start)
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        Padding(
                          padding: (data['message'].length < 20)
                              ? const EdgeInsets.only(top: 5, right: 5)
                              : const EdgeInsets.only(
                                  top: 5, right: 5, bottom: 5),
                          child: Text(
                            _formatTimestamp(data['timestamp']),
                            style: TextStyle(
                              color: (alignment == MainAxisAlignment.start)
                                  ? Colors.grey
                                  : Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime =
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  Widget _builMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: 'Введите сообщение',
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              size: 30,
              color: Color.fromARGB(255, 178, 128, 174),
            ),
          ),
        ],
      ),
    );
  }
}
