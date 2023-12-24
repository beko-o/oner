import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oner/screens/art_category_pages/blog/crud_parties.dart';
import 'dart:io';
import 'package:random_string/random_string.dart';

class CreateBlogParties extends StatefulWidget {
  const CreateBlogParties({super.key});

  @override
  State<CreateBlogParties> createState() => CreateBlogPartiesState();
}

class CreateBlogPartiesState extends State<CreateBlogParties> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  String titleParties = '';
  String descriptionParties = '';
  String date = ''; // Add this line
  String time = ''; // Add this line

  XFile? selectedImageParties;
  bool isLoadingParties = false;

  CrudMethodsParties crudMethodsParties = CrudMethodsParties();

  Future getImage() async {
    final pickerParties = ImagePicker();
    XFile? imageParties =
        await pickerParties.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImageParties = imageParties;
    });
  }

  uploadBlog() async {
    if (selectedImageParties != null) {
      setState(() {
        isLoadingParties = true;
      });

      // Get current date and time
      DateTime now = DateTime.now();
      date = "${now.year}-${now.month}-${now.day}";
      time = "${now.hour}:${now.minute}:${now.second}";
      //uploading image to firebase storage
      Reference firebasStorageRef = FirebaseStorage.instance
          .ref()
          .child('blogImagesParties')
          .child('${randomAlphaNumeric(9)}.jpg');

      final UploadTask taskParties =
          firebasStorageRef.putFile(File(selectedImageParties!.path));

      String downloadUrlParties =
          await taskParties.then((TaskSnapshot snapshot) {
        return snapshot.ref.getDownloadURL();
      });
      print('this is url $downloadUrlParties');

      Map<String, String> blogMap = {
        'imgUrlParties': downloadUrlParties,
        'titleParties': titleParties,
        'descriptionParties': descriptionParties,
        'authorID': FirebaseAuth.instance.currentUser!.uid,
        'date': date, // Add this line
        'time': time, // Add this line
      };

      crudMethodsParties.addData(blogMap).then((resultParties) {
        Navigator.pop(context);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Раздел ",
              style: TextStyle(fontSize: 22),
            ),
            Text(
              "Праздников",
              style: TextStyle(fontSize: 22, color: Colors.white),
            )
          ],
        ),
        backgroundColor: Colors.grey,
        actions: [
          GestureDetector(
            onTap: () {
              uploadBlog();
            },
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(Icons.file_upload)),
          ),
        ],
      ),
      // ignore: avoid_unnecessary_containers
      body: isLoadingParties
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
            child: Container(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: selectedImageParties != null
                          ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              height: 400,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    File(selectedImageParties!.path),
                                    fit: BoxFit.cover,
                                  )),
                            )
                          : Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: const Icon(Icons.add_a_photo),
                            ),
                    ),
                    Container(
                      child: const Text(
                        'Прикрепите свое фото',
                        style: TextStyle(
                                  fontSize: 17, color: Colors.black),
                        )),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Имя автора: ${currentUser.displayName ?? ''}",
                              style: TextStyle(
                                  fontSize: 17, color: Colors.grey[600]),
                            ),
                          ),
                          TextField(
                            maxLines: null,
                            decoration:
                                const InputDecoration(hintText: "Кем являетесь"),
                            onChanged: (val) {
                              titleParties = val;
                            },
                          ),
                          TextField(
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText:
                                  "Опишите свой опыт работы (где работали и стаж работы)",
                              hintStyle: TextStyle(fontSize: 13),
                            ),
                            onChanged: (val) {
                              descriptionParties = val;
                            },
                          ),
                          const SizedBox(height: 20),
                          FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection('user_info')
                                .doc(currentUser.uid)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                    'Ошибка при получении данных: ${snapshot.error}');
                              } else {
                                Map<String, dynamic> userData =
                                    snapshot.data!.data() as Map<String, dynamic>;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: const Text(
                                        "Контактные данные:",
                                        style: TextStyle(
                                            fontSize: 17, color: Colors.grey),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        "Номер телефона: ${userData['phoneNumber']}",
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[600]),
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                    Container(
                                      margin:
                                          const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        "Емэйл: ${currentUser.email ?? 'Не указан'}",
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.grey[600]),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
