import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oner/provider/avatar_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class ProfilePic extends StatefulWidget {
  const ProfilePic({
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePicState createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<File> _reduceImageSize(File image) async {
    final decodedImage = img.decodeImage(await image.readAsBytes());

    // Уменьшаем размер изображения до 200x200 пикселей
    final resizedImage = img.copyResize(decodedImage!, width: 200, height: 200);

    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;

    // Создаем новый файл с уменьшенным изображением
    final reducedImageFile = File('$tempPath/reduced_avatar.jpg')
      ..writeAsBytesSync(img.encodeJpg(resizedImage));

    return reducedImageFile;
  }

  Future<void> _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      context.read<AvatarProvider>().setLoading(true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();

        if (docSnapshot.exists) {
          final imageUrl = docSnapshot.get('avatarUrl');
          if (imageUrl != null && imageUrl.isNotEmpty) {
            final imageFile = await _loadImageFromNetwork(imageUrl);
            if (imageFile != null) {
              context.read<AvatarProvider>().clearAvatar();
              context.read<AvatarProvider>().setAvatar(imageFile);
            }
          }
        }

        // Устанавливаем флаг в false только при первом запуске приложения
        prefs.setBool('isFirstTime', false);
      } catch (e) {
        _handleError('Ошибка при загрузке изображения: $e');
      } finally {
        context.read<AvatarProvider>().setLoading(false);
      }
    }
  }

  Future<File?> _loadImageFromNetwork(String imageUrl) async {
    context.read<AvatarProvider>().clearAvatar();
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final savedFile = File('${appDir.path}/profile_avatar.jpg');

      if (savedFile.existsSync()) {
        return savedFile;
      }

      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        await savedFile.writeAsBytes(response.bodyBytes);
        return savedFile;
      }
    } catch (e) {
      _handleError('Ошибка при загрузке изображения из сети: $e');
    }

    return null;
  }

  Future<void> _saveImage(File image) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('profile_image', image.path);
    context.read<AvatarProvider>().clearAvatar();
    context.read<AvatarProvider>().setAvatar(image);
  }

  Future<void> _handleImageSelection() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {});
        // Очищаем аватар после успешной загрузки нового изображения

        await _uploadImageToFirebaseStorage(File(pickedFile.path));
        await _saveImage(File(pickedFile.path));
      }
    } catch (e) {
      _handleError('Ошибка при выборе изображения: $e');
    } finally {
      setState(() {});
    }
  }

  Future<void> _uploadImageToFirebaseStorage(File image) async {
    try {
      final reducedImage = await _reduceImageSize(image);
      final user = FirebaseAuth.instance.currentUser;
      final fileName = 'avatar_${user?.uid}.jpg';
      final storageReference =
          FirebaseStorage.instance.ref().child('avatars/$fileName');
      await storageReference.putFile(reducedImage);
      final downloadUrl = await storageReference.getDownloadURL();

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);

      final userDocSnapshot = await userDoc.get();

      if (userDocSnapshot.exists) {
        await userDoc.update({'avatarUrl': downloadUrl});
      } else {
        await userDoc.set({'avatarUrl': downloadUrl});
      }

      print('Firestore обновлен с URL изображения: $downloadUrl');
      _showSnackbar('Изображение профиля успешно обновлено', Colors.green);
    } catch (e) {
      _handleError(
          'Ошибка при загрузке изображения в Firebase Storage или обновлении Firestore: $e');
    }
  }

  void _handleError(String errorMessage) {
    _showSnackbar(errorMessage, Colors.red);
  }

  void _showSnackbar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = context.watch<AvatarProvider>();
    final avatar = avatarProvider.avatar;
    final isLoading = avatarProvider.loading;

    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundImage: avatar != null
                ? FileImage(avatar)
                : const AssetImage(
                        'assets/default-profile-account-unknown-icon-black-silhouette-free-vector.jpg')
                    as ImageProvider,
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            right: -10,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F6F9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                ),
                onPressed: isLoading ? null : _handleImageSelection,
                child: SvgPicture.asset("assets/photo-camera-svgrepo-com.svg"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
