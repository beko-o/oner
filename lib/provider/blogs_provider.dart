import 'package:flutter/material.dart';

class BlogData extends ChangeNotifier {
  List<Map<String, dynamic>> _blogs = [];

  List<Map<String, dynamic>> get blogs => _blogs;

  set blogs(List<Map<String, dynamic>> value) {
    _blogs = value;
    notifyListeners();
  }
}