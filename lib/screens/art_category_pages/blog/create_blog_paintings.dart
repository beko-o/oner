import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oner/screens/art_category_pages/blog/crud_paintings.dart';
import 'dart:io';

import 'package:random_string/random_string.dart';

class CreateBlogPaintings extends StatefulWidget {
  const CreateBlogPaintings({super.key});

  @override
  State<CreateBlogPaintings> createState() => CreateBlogPaintingsState();
}

class CreateBlogPaintingsState extends State<CreateBlogPaintings> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  String authorNamePaintings = '';
  String titlePaintings = '';
  String descriptionPaintings = '';
    String date = ''; // Add this line
  String time = ''; // Add this line

  XFile? selectedImagePaintings;
  bool isLoadingPaintings = false;

  CrudMethodsPaintings crudMethodsPaintings = CrudMethodsPaintings();

  Future getImage() async {
    final pickerPaintings = ImagePicker();
    XFile? imagePaintings =
        await pickerPaintings.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImagePaintings = imagePaintings;
    });
  }

  uploadBlog() async {
    if (selectedImagePaintings != null) {
      setState(() {
        isLoadingPaintings = true;
      });

      // Get current date and time
      DateTime now = DateTime.now();
      date = "${now.year}-${now.month}-${now.day}";
      time = "${now.hour}:${now.minute}:${now.second}";
      //uploading image to firebase storage
      Reference firebasStorageRef = FirebaseStorage.instance
          .ref()
          .child('blogImagesPaintings')
          .child('${randomAlphaNumeric(9)}.jpg');

      final UploadTask taskPaintings =
          firebasStorageRef.putFile(File(selectedImagePaintings!.path));

      String downloadUrlPaintings =
          await taskPaintings.then((TaskSnapshot snapshot) {
        return snapshot.ref.getDownloadURL();
      });
      print('this is url $downloadUrlPaintings');

      Map<String, String> blogMap = {
        'imgUrlPaintings': downloadUrlPaintings,
        'authorNamePaintings': authorNamePaintings,
        'titlePaintings': titlePaintings,
        'descriptionPaintings': descriptionPaintings,
        'authorID': FirebaseAuth.instance.currentUser!.uid,
        'date': date, // Add this line
        'time': time, // Add this line
      };

      crudMethodsPaintings.addData(blogMap).then((resultPaintings) {
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
              "Картин",
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
      body: isLoadingPaintings
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
                      child: selectedImagePaintings != null
                          ? Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              height: 400,
                              width: MediaQuery.of(context).size.width,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    File(selectedImagePaintings!.path),
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
                            decoration: const InputDecoration(
                                hintText: "Название картины"),
                            onChanged: (val) {
                              titlePaintings = val;
                            },
                          ),
                          TextField(
                            maxLines: null,
                            decoration: const InputDecoration(
                                hintText: "Описание картины"),
                            onChanged: (val) {
                              descriptionPaintings = val;
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
