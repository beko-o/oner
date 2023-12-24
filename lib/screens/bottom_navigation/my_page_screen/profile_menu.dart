import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    required this.press,
  });

  final String text, icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          backgroundColor: const Color.fromARGB(193, 245, 246, 249),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 26,
              colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
