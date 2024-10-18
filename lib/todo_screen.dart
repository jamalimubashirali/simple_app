import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_todo.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final CollectionReference _todoRef = FirebaseFirestore.instance.collection("user").doc(uid).collection("myTodos");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo App"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: _todoRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error}"),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No data found"),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var todo = snapshot.data!.docs[index];
                      return ListTile(
                        title: Text(todo['title']),
                        subtitle: Text("${todo['description']} - ${todo['date']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showUpdateDialog(context, _todoRef, todo);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _todoRef.doc(todo.id).delete();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddTodo()),
                  );
                },
                child: const Text("Add Task"),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Delete All"),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Show update dialog for editing
  void _showUpdateDialog(BuildContext context, CollectionReference _todoRef, DocumentSnapshot todo) {
    TextEditingController titleController = TextEditingController(text: todo['title']);
    TextEditingController descriptionController = TextEditingController(text: todo['description']);
    TextEditingController dateController = TextEditingController(text: todo['date']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Date"),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _todoRef.doc(todo.id).update({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'date': dateController.text,
                }).then((_) {
                  Navigator.of(context).pop(); // Close the dialog
                });
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without updating
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
