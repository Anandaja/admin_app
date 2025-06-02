import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference adminCollection = FirebaseFirestore.instance
      .collection('admin_data');

  Future<void> addData(
    String imageUrl,
    String title,
    String description,
  ) async {
    await adminCollection.add({
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateData(
    String docId,
    String imageUrl,
    String title,
    String description,
  ) async {
    await adminCollection.doc(docId).update({
      'imageUrl': imageUrl,
      'title': title,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteData(String docId) async {
    await adminCollection.doc(docId).delete();
  }

  Stream<QuerySnapshot> getDataStream() {
    return adminCollection.orderBy('createdAt', descending: true).snapshots();
  }

  Future<DocumentSnapshot> getSingleData(String docId) async {
    return await adminCollection.doc(docId).get();
  }
}
