import 'package:flutter/material.dart';

class UserInfoProvider extends ChangeNotifier {
  Map<String, dynamic> _userInfo = {};

  Map<String, dynamic> get userInfo => _userInfo;

  void setUserInfo(Map<String, dynamic> info) {
    _userInfo = info;
    notifyListeners();
  }
}
