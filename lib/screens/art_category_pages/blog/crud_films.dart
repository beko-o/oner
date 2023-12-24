import 'package:cloud_firestore/cloud_firestore.dart';

class CrudMethodsFilms {
  Future<void> addData(blogData) async {
    // blogData['createdAt'] = FieldValue.serverTimestamp(); // Add this line
    FirebaseFirestore.instance.collection('blogs_films').add(blogData).catchError((e) {return e;});
  }

  Future<QuerySnapshot<Object?>> getData() async {
    return await FirebaseFirestore.instance.collection('blogs_films').get();
  }

  Future<void> deleteData(String docId) async {
    await FirebaseFirestore.instance.collection('blogs_films').doc(docId).delete();
  }

  Future<bool> isAuthor(String docId, String userId) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('blogs_films').doc(docId).get();

    Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;

    return data['authorID'] == userId;
  }
}