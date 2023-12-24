import 'dart:io';

import 'package:flutter/material.dart';

class AvatarProvider with ChangeNotifier {
  File? _avatar;
  bool _loading = false;

  File? get avatar => _avatar;
  bool get loading => _loading;

  void setAvatar(File? avatar) {
    _avatar = avatar;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void clearAvatar() {
    _avatar = null;
    notifyListeners();
  }
}
