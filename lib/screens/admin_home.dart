import 'package:demo_app/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController imgCtrl = TextEditingController();

  String? editingDocId;

  void addOrUpdateData() {
    if (editingDocId == null) {
      // Add new document
      FirebaseFirestore.instance.collection('admin_data').add({
        'title': titleCtrl.text,
        'description': descCtrl.text,
        'imageUrl': imgCtrl.text,
      });
    } else {
      // Update existing document
      FirebaseFirestore.instance
          .collection('admin_data')
          .doc(editingDocId)
          .update({
            'title': titleCtrl.text,
            'description': descCtrl.text,
            'imageUrl': imgCtrl.text,
          });
    }

    // Clear input fields & reset editing id
    titleCtrl.clear();
    descCtrl.clear();
    imgCtrl.clear();
    setState(() {
      editingDocId = null;
    });
  }

  void deleteData(String id) {
    FirebaseFirestore.instance.collection('admin_data').doc(id).delete();
    // If deleting the currently edited document, reset the form
    if (editingDocId == id) {
      titleCtrl.clear();
      descCtrl.clear();
      imgCtrl.clear();
      setState(() {
        editingDocId = null;
      });
    }
  }

  void startEditing(DocumentSnapshot doc) {
    titleCtrl.text = doc['title'];
    descCtrl.text = doc['description'];
    imgCtrl.text = doc['imageUrl'];
    setState(() {
      editingDocId = doc.id;
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            TextField(
              controller: imgCtrl,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addOrUpdateData,
              child: Text(editingDocId == null ? 'Add Data' : 'Update Data'),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('admin_data')
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var doc = docs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: Image.network(
                            doc['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                          ),
                          title: Text(doc['title']),
                          subtitle: Text(doc['description']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => startEditing(doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteData(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
