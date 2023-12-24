import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oner/additional/textbox.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  //all users
  final userCollection = FirebaseFirestore.instance.collection('user_info');

  //edit field
  Future<void> editField(String field) async {
    String newValue = '';
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Изменить значение',
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Введите новое значение',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  newValue = value;
                },
              ),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //cancel button
                      TextButton(
                        child: const Text(
                          'Отменить',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),

                      //save button
                      TextButton(
                        child: const Text(
                          'Сохранить',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => Navigator.of(context).pop(newValue),
                      ),
                    ])
              ],
            ));

    //update changes on Firestore
    if (newValue.trim().length > 0) {
      await userCollection.doc(currentUser.uid).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Настройки профиля'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user_info')
              .doc(currentUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            //get user data
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                children: [
                  SizedBox(height: 50),

                  //my details
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      'Детали',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                  //firstname
                  MyTextBox(
                    text: userData['firstName'],
                    sectionName: 'Имя',
                    onPressed: () => editField("firstName"),
                  ),

                  //lastname
                  MyTextBox(
                    text: userData['lastName'],
                    sectionName: 'Фамилия',
                    onPressed: () => editField("lastName"),
                  ),

                  //phone number
                  MyTextBox(
                    text: userData['phoneNumber'],
                    sectionName: 'Номер телефона',
                    onPressed: () => editField("phoneNumber"),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.only(left: 15, bottom: 15),
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 15, top: 15),
                              child: Text(
                                'Email',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ),
                          ],
                        ),
                        //text
                        Text(
                            currentUser.email ?? 'Адрес эл. почты отсутствует'),
                      ],
                    ),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error ${snapshot.error}'),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}


