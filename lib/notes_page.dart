import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'note.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Note> _notes = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    List<Note> notes = await _databaseHelper.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _addOrUpdateNote([Note? note]) async {
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
    } else {
      _titleController.clear();
      _contentController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note == null ? 'Add Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _contentController,
                decoration: InputDecoration(labelText: 'Content'),
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (note == null) {

                  final newNote = Note(
                    title: _titleController.text,
                    content: _contentController.text,
                    date: DateTime.now(),
                  );
                  _databaseHelper.insertNote(newNote);
                } else {

                  final updatedNote = Note(
                    id: note.id,
                    title: _titleController.text,
                    content: _contentController.text,
                    date: note.date,
                  );
                  _databaseHelper.updateNote(updatedNote);
                }
                _loadNotes();
                Navigator.of(context).pop();
              },
              child: Text(note == null ? 'Add' : 'Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteNote(int id) async {
    await _databaseHelper.deleteNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addOrUpdateNote(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () => _addOrUpdateNote(note),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteNote(note.id!),
            ),
          );
        },
      ),
    );
  }
}
