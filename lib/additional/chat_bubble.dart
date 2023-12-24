import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String time; // Add time property
  const ChatBubble({
    required this.message,
    required this.time, // Include time in the constructor
    Key? key, // Add key property
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.amber,
          ),
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
