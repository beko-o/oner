import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPostsFilmsScreen extends StatefulWidget {
  const MyPostsFilmsScreen({Key? key}) : super(key: key);

  @override
  State<MyPostsFilmsScreen> createState() => _MyPostsFilmsScreenState();
}

class _MyPostsFilmsScreenState extends State<MyPostsFilmsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои посты в разделе Фильмов'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: _fetchUserPosts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return Center(child: Text('У вас пока нет постов'));
            } else {
              List<DocumentSnapshot> posts = snapshot.data as List<DocumentSnapshot>;
      
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  var post = posts[index].data() as Map<String, dynamic>;
      
                  return BlogsTile(
                    docId: posts[index].id,
                    authorID: post['authorID'],
                    titleFilms: post['titleFilms'],
                    descriptionFilms: post['descriptionFilms'],
                    imgUrlFilms: post['imgUrlFilms'],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchUserPosts() async {
    if (currentUser != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('blogs_films')
            .where('authorID', isEqualTo: currentUser!.uid)
            .get();

        return querySnapshot.docs;
      } catch (e) {
        print('Error fetching user posts: $e');
        return [];
      }
    } else {
      return [];
    }
  }
}

class BlogsTile extends StatelessWidget {
  final String imgUrlFilms, titleFilms, descriptionFilms, docId, authorID;

  BlogsTile({
    required this.docId,
    required this.imgUrlFilms,
    required this.titleFilms,
    required this.descriptionFilms,
    required this.authorID,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16.0),
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
                      imgUrlFilms,
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // You can add any other overlay elements if needed
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
                    titleFilms,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descriptionFilms,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Include the rest of the content from BlogsTile
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
