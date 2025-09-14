//------------------------ I m p o r t s --------------------------------
import 'package:flutter/material.dart';
import 'create_note_page.dart';
import 'note_detail_page.dart';
import 'create_drawing_note_page.dart';
import 'create_file_note_page.dart';
import 'create_voice_note_page.dart';

//------------------------ N o t e s   P a g e --------------------------------
class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

//------------------------ S t a t e --------------------------------
class _NotesPageState extends State<NotesPage> {
  //------------------------ N o t e s   L i s t --------------------------------
  List<Map<String, String>> notes = [
    {
      "title": "Integration Techniques",
      "subject": "Mathematics",
      "note": "Integration techniques and practice problems.",
      "color": Colors.blue.value.toString(),
      "date": DateTime.now().subtract(const Duration(days: 2)).toString(),
      "type": "text",
    },
    {
      "title": "Reinforcement Learning",
      "subject": "Artificial Intelligence",
      "note": "Review reinforcement learning algorithms.",
      "color": Colors.green.value.toString(),
      "date": DateTime.now().subtract(const Duration(days: 1)).toString(),
      "type": "text",
    },
    {
      "title": "Sensor Calibration",
      "subject": "Robotics",
      "note": "Check sensors calibration for navigation project.",
      "color": Colors.orange.value.toString(),
      "date": DateTime.now().subtract(const Duration(hours: 12)).toString(),
      "type": "text",
    },
    {
      "title": "Object Detection Paper",
      "subject": "Computer Vision",
      "note": "Finish reading paper on object detection.",
      "color": Colors.purple.value.toString(),
      "date": DateTime.now().subtract(const Duration(hours: 6)).toString(),
      "type": "text",
    },
    {
      "title": "Flutter Animations",
      "subject": "Flutter",
      "note": "Experiment with animations and state management.",
      "color": Colors.blue.value.toString(),
      "date": DateTime.now().subtract(const Duration(hours: 3)).toString(),
      "type": "text",
    },
    {
      "title": "Dataset Analysis",
      "subject": "Data Science",
      "note": "Clean dataset and run exploratory analysis.",
      "color": Colors.teal.value.toString(),
      "date": DateTime.now().subtract(const Duration(hours: 1)).toString(),
      "type": "text",
    },
  ];

  //------------------------ G e t   N o t e   I c o n --------------------------------
  IconData _getNoteIcon(String type) {
    switch (type) {
      case "drawing":
        return Icons.brush;
      case "file":
        return Icons.attach_file;
      case "voice":
        return Icons.mic;
      case "text":
      default:
        return Icons.note;
    }
  }

  //------------------------ A d d   N o t e   M e t h o d --------------------------------
  void _addNote(Map<String, String> newNote) {
    setState(() {
      notes.insert(0, newNote); // Add to beginning of list
    });
  }

  //------------------------ F o r m a t   D a t e --------------------------------
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} min ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  //------------------------ F A B   M e n u --------------------------------
  void _showAddNoteOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add New Note',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              _buildAddNoteOption(
                icon: Icons.note_add,
                title: "Create Text Note",
                subtitle: "Write your thoughts",
                gradient: [Colors.blue, Colors.cyan],
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateNotePage(onNoteCreated: _addNote),
                    ),
                  );
                },
              ),
              _buildAddNoteOption(
                icon: Icons.edit,
                title: "Drawing",
                subtitle: "Sketch and draw",
                gradient: [Colors.purple, Colors.pink],
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateDrawingNotePage(onNoteCreated: _addNote),
                    ),
                  );
                },
              ),
              _buildAddNoteOption(
                icon: Icons.attach_file,
                title: "Attach Files",
                subtitle: "Images or PDFs",
                gradient: [Colors.green, Colors.teal],
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateFileNotePage(onNoteCreated: _addNote),
                    ),
                  );
                },
              ),
              _buildAddNoteOption(
                icon: Icons.mic,
                title: "Voice Notes",
                subtitle: "Record audio",
                gradient: [Colors.orange, Colors.red],
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateVoiceNotePage(onNoteCreated: _addNote),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddNoteOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: gradient.first.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      //------------------------ A p p B a r --------------------------------
      appBar: AppBar(
        title: const Text(
          'My Notes ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.black,
      ),

      //------------------------ N o t e s   L i s t --------------------------------
      body: Column(
        children: [
          // Header with stats
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.note_alt,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${notes.length} Notes',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Keep your thoughts organized',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Text('📚', style: TextStyle(fontSize: 32)),
              ],
            ),
          ),

          // Notes list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  // Parse color from string (fallback to blue if not available)
                  Color noteColor = Colors.blue;
                  try {
                    if (note["color"] != null) {
                      noteColor = Color(int.parse(note["color"]!));
                    }
                  } catch (e) {
                    noteColor = Colors.blue;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 4,
                      shadowColor: noteColor.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [Colors.white, noteColor.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: noteColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getNoteIcon(note["type"] ?? "text"),
                              color: noteColor,
                              size: 24,
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note["title"] ?? note["subject"]!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (note["title"] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  note["subject"]!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: noteColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                note["note"]!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (note["date"] != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(note["date"]!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: noteColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: noteColor,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoteDetailPage(
                                  subject: note["subject"]!,
                                  note: note,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      //------------------------ F A B --------------------------------
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddNoteOptions,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

//------------------------ D e t a i l   P a g e --------------------------------
// Legacy inline NoteDetailPage removed. Using the dedicated NoteDetailPage in note_detail_page.dart.
