import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Помощь'),
        centerTitle: true,
      ),
      body: const Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Часто задаваемые вопросы',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            FAQTile(
              question: 'Зачем нужно наше приложение?',
              answer: 'Наше приложение нужно чтобы помочь творческим людям находить спонсоров',
            ),
          
            SizedBox(height: 16),
            FAQTile(
              question: 'Как спонсор может связаться с вами?',
              answer: 'Спонсор видит вас в списке постов и у него есть возможность вам написать',
            ),
          ],
        ),
      ),
    );
  }
}

class FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const FAQTile({required this.question, required this.answer, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }
}