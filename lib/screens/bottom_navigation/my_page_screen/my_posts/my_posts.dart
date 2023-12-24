import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oner/screens/bottom_navigation/my_page_screen/profile_menu.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({Key? key}) : super(key: key);

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои посты'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const SizedBox(height: 70),

            ProfileMenu(
              icon: "assets/loved-post.svg",
              text: "Мои посты в разделе Фильмов",
              press: () {
                Navigator.pushNamed(context, '/myPostsFilms');
              },
            ),
            ProfileMenu(
              icon: "assets/loved-post.svg",
              text: "Мои посты в разделе Музыки",
              press: () {
                Navigator.pushNamed(context, '/myPostsMusic');
              },
            ),
            ProfileMenu(
              icon: "assets/loved-post.svg",
              text: "Мои посты в разделе Картин",
              press: () {
                Navigator.pushNamed(context, '/myPostsPaintings');
              },
            ),
            ProfileMenu(
              icon: "assets/loved-post.svg",
              text: "Мои посты в разделе Праздников",
              press: () {
                Navigator.pushNamed(context, '/myPostsParties');
              },
            ),
          ],
        ),
      ),
    );
  }
}