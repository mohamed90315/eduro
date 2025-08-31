//------------------------ I m p o r t s --------------------------------
import 'package:flutter/material.dart';

//------------------------ N o t e s   P a g e --------------------------------
class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

//------------------------ S t a t e --------------------------------
class _NotesPageState extends State<NotesPage> {
  int _selectedIndex = 0;

  //------------------------ N a v i g a t i o n --------------------------------
  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // TODO: Navigate to different pages depending on index
    });
  }

  //------------------------ M o c k   N o t e s --------------------------------
  final List<Map<String, String>> mockNotes = [
    {
      "subject": "Mathematics",
      "note": "Integration techniques and practice problems.",
    },
    {
      "subject": "Artificial Intelligence",
      "note": "Review reinforcement learning algorithms.",
    },
    {
      "subject": "Robotics",
      "note": "Check sensors calibration for navigation project.",
    },
    {
      "subject": "Computer Vision",
      "note": "Finish reading paper on object detection.",
    },
    {
      "subject": "Flutter",
      "note": "Experiment with animations and state management.",
    },
    {
      "subject": "Data Science",
      "note": "Clean dataset and run exploratory analysis.",
    },
    {"subject": "Cyber Security", "note": "Review basics of network security."},
    {
      "subject": "Operating Systems",
      "note": "Study process scheduling algorithms.",
    },
    {
      "subject": "Machine Learning",
      "note": "Practice decision trees and SVMs.",
    },
    {
      "subject": "Deep Learning",
      "note": "Understand CNN and RNN architectures.",
    },
    {
      "subject": "Cloud Computing",
      "note": "Check AWS basics and deployment steps.",
    },
    {
      "subject": "Software Engineering",
      "note": "Revise software development lifecycle models.",
    },
    {
      "subject": "Database Systems",
      "note": "Review normalization and indexing.",
    },
    {
      "subject": "Linear Algebra",
      "note": "Matrix operations and eigenvalues practice.",
    },
  ];

  //------------------------ F A B   M e n u --------------------------------
  void _showAddNoteOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.note_add, color: Colors.cyan),
              title: const Text("Create Text Note"),
              onTap: () {
                Navigator.pop(context);
                // TODO: Add navigation to "create note" page
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.cyan),
              title: const Text("Drawing"),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open drawing pad or text editor
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Colors.cyan),
              title: const Text("Attach Images or PDFs"),
              onTap: () {
                Navigator.pop(context);
                // TODO: Use file picker/image picker here
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.cyan),
              title: const Text("Voice Notes"),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement voice recording feature
              },
            ),
          ],
        );
      },
    );
  }

  //------------------------ B u i l d --------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //------------------------ A p p B a r --------------------------------
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "My Notes 📋",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      //------------------------ N o t e s   L i s t --------------------------------
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: mockNotes.length,
          itemBuilder: (context, index) {
            final note = mockNotes[index];
            return Card(
              elevation: 4,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                leading: CircleAvatar(
                  backgroundColor: Colors.cyan.withOpacity(0.1),
                  child: const Icon(Icons.note, color: Colors.cyan),
                ),
                title: Text(
                  note["subject"]!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  note["note"]!,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.black45,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteDetailPage(
                        subject: note["subject"]!,
                        note: note["note"]!,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),

      //------------------------ F A B --------------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteOptions,
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

//------------------------ D e t a i l   P a g e --------------------------------
class NoteDetailPage extends StatelessWidget {
  final String subject;
  final String note;

  const NoteDetailPage({Key? key, required this.subject, required this.note})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //------------------------ A p p B a r --------------------------------
      appBar: AppBar(
        title: Text(
          subject,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      //------------------------ N o t e   D e t a i l   C a r d --------------------------------
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              note,
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
