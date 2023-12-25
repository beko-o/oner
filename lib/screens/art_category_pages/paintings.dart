import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oner/screens/art_category_pages/blog/create_blog_paintings.dart';
import 'package:oner/screens/art_category_pages/blog/crud_paintings.dart';
import 'package:oner/screens/bottom_navigation/chatting/chat_screen.dart';

class PaintingsPage extends StatefulWidget {
  const PaintingsPage({super.key});

  @override
  State<PaintingsPage> createState() => _PaintingsPageState();
}

class _PaintingsPageState extends State<PaintingsPage> {
  CrudMethodsPaintings crudMethodsPaintings = CrudMethodsPaintings();

  late Future<QuerySnapshot> blogsFuturePaintings;

  @override
  void initState() {
    super.initState();

    blogsFuturePaintings = crudMethodsPaintings.getData();
  }

  Widget blogListPaintings() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('blogs_paintings').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No available blogs.');
        } else {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: snapshot.data!.docs.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return BlogsTile(
                docIdPaintings: snapshot.data!.docs[index].id,
                authorID: snapshot.data!.docs[index]['authorID'],
                titlePaintings: snapshot.data!.docs[index]['titlePaintings'],
                descriptionPaintings: snapshot.data!.docs[index]
                    ['descriptionPaintings'],
                imgUrlPaintings: snapshot.data!.docs[index]['imgUrlPaintings'],
                date: snapshot.data!.docs[index]['date'],
                time: snapshot.data!.docs[index]['time'],
              );
            },
          );
        }
      },
    );
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
            ),
          ],
        ),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
            onPressed: () {
              // Действие при нажатии на иконку
            },
            icon: const Icon(Icons
                .fiber_smart_record_outlined), // Иконка (можете выбрать другую)
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: blogListPaintings(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateBlogPaintings()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class BlogsTile extends StatelessWidget {
  final String imgUrlPaintings,
      titlePaintings,
      descriptionPaintings,
      docIdPaintings,
      date,
      time,
      authorID;
  BlogsTile({
    super.key,
    required this.imgUrlPaintings,
    required this.titlePaintings,
    required this.descriptionPaintings,
    required this.authorID,
    required this.docIdPaintings,
    required this.date,
    required this.time,
  });

  final currentUser = FirebaseAuth.instance.currentUser!;

  void _editPostFields(BuildContext context) async {
    String newPaintingsTitle = titlePaintings;
    String newPaintingsDescription = descriptionPaintings;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Изменить данные поста',
          style: TextStyle(color: Colors.black),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Нзавание',
                ),
                onChanged: (value) {
                  newPaintingsTitle = value;
                },
              ),
              TextField(
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                ),
                onChanged: (value) {
                  newPaintingsDescription = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Отмена',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              // Save the edited values to Firestore
              _saveEditedValues(newPaintingsTitle, newPaintingsDescription);
              Navigator.pop(context);
            },
            child: const Text(
              'Сохранить',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _saveEditedValues(
      String newPaintingsTitle, String newPaintingsDescription) async {
    // Update Firestore document with new values
    await FirebaseFirestore.instance
        .collection('blogs_paintings')
        .doc(docIdPaintings)
        .update({
      'titlePaintings': newPaintingsTitle,
      'descriptionPaintings': newPaintingsDescription,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('user_info')
          .doc(authorID)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Ошибка при получении данных: ${snapshot.error}');
        } else {
          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;
          String authorNamePaintings =
              '${userData['firstName']} ${userData['lastName']}';

          bool isCurrentUserAuthor = currentUser.uid == authorID;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imgUrlPaintings,
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // IconButton for navigating to chat page
                      if (!isCurrentUserAuthor)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.message),
                            onPressed: () {
                              // Navigate to chat page with the author
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    recieverUserEmail: userData['email'],
                                    recieverUserID: authorID,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      // editing icon

                      if (isCurrentUserAuthor)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Call function to edit post fields
                            _editPostFields(context);
                          },
                        ),

                      //
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titlePaintings,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        descriptionPaintings,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Автор: ${authorNamePaintings}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Дата создания: $date',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Время создания: $time',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
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
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    "Номер телефона: ${userData['phoneNumber']}",
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.grey[600]),
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
                                    "Email: ${currentUser.email ?? 'Не указан'}",
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      // Добавляем кнопку удаления
                      FutureBuilder(
                        future: CrudMethodsPaintings()
                            .isAuthor(docIdPaintings, currentUser.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text(
                                'Ошибка при проверке авторства: ${snapshot.error}');
                          } else {
                            bool isAuthor = snapshot.data as bool;

                            if (isAuthor) {
                              return ElevatedButton(
                                onPressed: () async {
                                  // Диалоговое окно подтверждения удаления
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Удаление поста'),
                                        content: const Text(
                                            'Вы точно хотите удалить пост?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text('Отмена'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text('Удалить'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  // Если подтвердили удаление, удаляем пост
                                  if (confirmDelete == true) {
                                    await CrudMethodsPaintings()
                                        .deleteData(docIdPaintings);
                                    // Обновляем UI (например, перезагружаем страницу)
                                    // setState(() {});
                                  }
                                },
                                child: const Text('Удалить пост'),
                              );
                            } else {
                              return Container();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
