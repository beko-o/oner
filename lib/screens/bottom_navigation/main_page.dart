import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:oner/message_screen.dart';
// import 'package:oner/screens/home_screen.dart';
// import 'package:oner/screens/profile/account_screen.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAnimatedAppBar(context),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCenteredRoundedIcons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildSearchField() {
  //   return Container(
  //     width: 300,
  //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20.0),
  //     ),
  //     child: const Row(
  //       children: [
  //         Expanded(
  //           child: TextField(
  //             decoration: InputDecoration(
  //               hintText: '      Поиск по Oner',
  //               border: InputBorder.none,
  //             ),
  //           ),
  //         ),
  //         SizedBox(width: 8),
  //         Icon(Icons.search),
  //       ],
  //     ),
  //   );
  // }

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

  PreferredSizeWidget _buildAnimatedAppBar(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 178, 128, 174),
              Color.fromARGB(255, 178, 128, 174),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const AnimatedTextWidget(
        text: 'Твори историю искусства!',
        textStyle: TextStyle(color: Colors.white),
        duration: Duration(milliseconds: 500),
      ),
      centerTitle: true, // Add this line to center the title.
    );
  }

  Widget _buildCenteredRoundedIcons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () {
                _navigateToPage(context, '/music');
              },
              child: _buildRoundedIcon(Icons.music_note, 'Музыка'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _navigateToPage(context, '/parties');
              },
              child: _buildRoundedIcon(Icons.cake, 'Праздник'),
            ),
          ],
        ),
        const SizedBox(width: 50),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                _navigateToPage(context, '/paintings');
              },
              child: _buildRoundedIcon(Icons.palette, 'Картины'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _navigateToPage(context, '/films');
              },
              child: _buildRoundedIcon(Icons.movie, 'Кино'),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToPage(BuildContext context, String route) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showRegistrationDialog(context);
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  Widget _buildRoundedIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 178, 128, 174),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10.0),
          child: Icon(
            icon,
            size: 40.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(label),
      ],
    );
  }
}

class AnimatedTextWidget extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration duration;

  const AnimatedTextWidget({
    required this.text,
    required this.textStyle,
    required this.duration,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedTextWidgetState createState() => _AnimatedTextWidgetState();
}

class _AnimatedTextWidgetState extends State<AnimatedTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation =
        StepTween(begin: 0, end: widget.text.length).animate(_controller);

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentLength = _animation.value;
        return Text(
          widget.text.substring(0, currentLength),
          style: widget.textStyle,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
