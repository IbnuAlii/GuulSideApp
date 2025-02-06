import 'package:flutter/material.dart';

class NoteModal extends StatefulWidget {
  final String initialNote;

  const NoteModal({Key? key, required this.initialNote}) : super(key: key);

  @override
  _NoteModalState createState() => _NoteModalState();
}

class _NoteModalState extends State<NoteModal> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your note here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _noteController.text);
                  },
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
