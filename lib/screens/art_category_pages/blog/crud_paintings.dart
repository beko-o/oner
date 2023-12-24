import 'package:cloud_firestore/cloud_firestore.dart';

class CrudMethodsPaintings {
  Future<void> addData(blogData) async {
    FirebaseFirestore.instance.collection('blogs_paintings').add(blogData).catchError((e) {return e;});
  }

  Future<QuerySnapshot<Object?>> getData() async {
    return await FirebaseFirestore.instance.collection('blogs_paintings').get();
  }

  Future<void> deleteData(String docId) async {
    await FirebaseFirestore.instance.collection('blogs_paintings').doc(docId).delete();
  }

  Future<bool> isAuthor(String docId, String userId) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('blogs_paintings').doc(docId).get();

    Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;

    return data['authorID'] == userId;
  }
}