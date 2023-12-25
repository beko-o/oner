import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oner/screens/bottom_navigation/main_page.dart';
import 'package:oner/screens/bottom_navigation/my_page_screen/account_screen.dart';
import 'package:oner/screens/bottom_navigation/chatting/message_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;

  int selectedIndex = 0;

  void _navigateBottomBar(int index) {
    if ((index == 2 || index == 1) && user == null) {
      _showRegistrationDialog(context).then((_) {
        // Perform any additional actions after the dialog is closed
        setState(() {
          selectedIndex =
              0; // You can set it to the default tab or handle it as needed
        });
      });
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  final List _pages = [
    const MainPage(),
    const MessageScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _navigateBottomBar,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
            backgroundColor: Color.fromARGB(255, 178, 128, 174),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Сообщения',
            backgroundColor: Color.fromARGB(255, 178, 128, 174),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Моя страница',
            backgroundColor: Color.fromARGB(255, 178, 128, 174),
          ),
        ],
      ),
    );
  }

  Future<void> _showRegistrationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Вам надо авторизоваться',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Войти'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text('Зарегистрироваться'),
              ),
            ],
          ),
        );
      },
    );
  }
}
