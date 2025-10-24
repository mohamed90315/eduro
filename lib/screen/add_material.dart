import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';

Future<void> _saveMaterialsToPrefs(List<Map<String, dynamic>> materials) async {
  final prefs = await SharedPreferences.getInstance();
  final materialsJson = jsonEncode(materials);
  await prefs.setString('materials', materialsJson);
}

Future<List<Map<String, dynamic>>> _loadMaterialsFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final materialsJson = prefs.getString('materials');
  if (materialsJson == null) return [];
  final List<dynamic> decoded = jsonDecode(materialsJson);
  return decoded.cast<Map<String, dynamic>>();
}

class Course {
  String title;
  double progress;
  String? description;
  IconData icon;
  String group;

  Course({
    required this.title,
    required this.progress,
    this.description,
    required this.icon,
    required this.group,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    title: json["title"],
    progress: (json["progress"] as num).toDouble(),
    description: json["description"],
    icon: IconData(json["icon"], fontFamily: "MaterialIcons"),
    group: json["group"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "progress": progress,
    "description": description,
    "icon": icon.codePoint,
    "group": group,
  };
}

/// StorageHelper (from your snippet)
class StorageHelper {
  static Future<SharedPreferences> _prefs() async =>
      SharedPreferences.getInstance();

  // Groups
  static Future<List<String>> loadGroups() async {
    final prefs = await _prefs();
    final saved = prefs.getStringList("courseGroups");
    return saved != null && saved.isNotEmpty
        ? ["All", ...saved.where((g) => g != "All")]
        : ["All"];
  }

  static Future<void> saveGroups(List<String> groups) async {
    final prefs = await _prefs();
    final groupsToSave = groups.where((g) => g != "All").toList();
    await prefs.setStringList("courseGroups", groupsToSave);
  }

  static Future<String?> loadSelectedGroup() async {
    final prefs = await _prefs();
    return prefs.getString("selectedGroup");
  }

  static Future<void> saveSelectedGroup(String group) async {
    final prefs = await _prefs();
    await prefs.setString("selectedGroup", group);
  }

  // Courses
  static Future<List<Course>> loadCourses() async {
    final prefs = await _prefs();
    final saved = prefs.getString("courses");
    if (saved == null) return [];
    final List decoded = jsonDecode(saved);
    return decoded.map((c) => Course.fromJson(c)).toList();
  }

  static Future<void> saveCourses(List<Course> courses) async {
    final prefs = await _prefs();
    final jsonStr =
    jsonEncode(courses.map((c) => c.toJson()).toList());
    await prefs.setString("courses", jsonStr);
  }
}

class AddMaterialPage extends StatefulWidget {
  const AddMaterialPage({super.key});

  @override
  State<AddMaterialPage> createState() => _AddMaterialPageState();
}

class _AddMaterialPageState extends State<AddMaterialPage>
    with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final List<PlatformFile> _pickedVideos = [];

  late AnimationController _card1Controller;
  late AnimationController _card2Controller;
  late Animation<double> _fade1;
  late Animation<double> _fade2;
  late Animation<Offset> _slide1;
  late Animation<Offset> _slide2;

  final List<PlatformFile> _pickedFiles = [];
  final List<PlatformFile> _pickedAudios = [];

  final bool _hasFile = false;
  final bool _hasAudio = false;

  /// Course dropdown state
  List<Course> _courses = [];
  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();

    _card1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _card2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade1 = CurvedAnimation(parent: _card1Controller, curve: Curves.easeOut);
    _fade2 = CurvedAnimation(parent: _card2Controller, curve: Curves.easeOut);

    _slide1 =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _card1Controller,
            curve: Curves.easeOut,
          ),
        );
    _slide2 =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _card2Controller,
            curve: Curves.easeOut,
          ),
        );

    _card1Controller.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _card2Controller.forward();
    });

    _loadCourses();
  }
  bool _isSnackBarActive = false;

  void _showSnackBar(BuildContext context, String message) {
    if (_isSnackBarActive) return; // Prevent stacking
    _isSnackBarActive = true;

    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50, // Distance from bottom
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    overlay.insert(entry);

    // Auto-remove after delay
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
      _isSnackBarActive = false;
    });
  }



  Future<void> _loadCourses() async {
    final courses = await StorageHelper.loadCourses();
    setState(() {
      _courses = courses;
      _selectedCourse = null;
    });
  }

  @override
  void dispose() {
    _card1Controller.dispose();
    _card2Controller.dispose();
    super.dispose();
  }

  Widget _buildCard({
    required Widget child,
    required Animation<double> fade,
    required Animation<Offset> slide,
  }) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextAlign labelAlign = TextAlign.start,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Focus(
        child: Builder(builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              boxShadow: hasFocus
                  ? [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.2),
                  blurRadius: 7,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ]
                  : [],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: label,
                alignLabelWithHint: true,
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
                hintText: hint,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2A7DE1),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2BD46E),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.3),
              blurRadius: 7,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF2A7DE1),
            width: 1.2,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.2),
              blurRadius: 3,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF2A7DE1)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedVideos.addAll(result.files));
      _showSnackBar(context, "Picked ${result.files.length} video(s)");
    } else {
      _showSnackBar(context, "No video selected");
    }
  }


  Future<void> _saveMaterial({
    required String type,
    required String title,
    String description = "",
    List<String> files = const [],
    List<String> audios = const [],
    List<String> videos = const [],
  }) async {

    final courseTitle = _selectedCourse?.title ?? "Unassigned";

    if (title.isEmpty && description.isEmpty && files.isEmpty && audios.isEmpty) {
      _showSnackBar(context, "Please add content before saving");
      return;
    }

    List<Map<String, dynamic>> existingMaterials = await _loadMaterialsFromPrefs();

    final newMaterial = {
      "course": courseTitle,
      "type": type,
      "title": title,
      "description": description,
      "files": files,
      "audios": audios,
      "videos": videos,  // 👈 ADD THIS
      "createdAt": DateTime.now().toIso8601String(),
    };

    existingMaterials.add(newMaterial);
    await _saveMaterialsToPrefs(existingMaterials);

    debugPrint("✅ Saved material: $newMaterial");

    _showSnackBar(context, "${type[0].toUpperCase()}${type.substring(1)} saved ✅");
  }


  Widget _buildFabActionItem(Function(void Function()) setModalState) {
    return (_pickedFiles.isNotEmpty || _pickedAudios.isNotEmpty || _pickedVideos.isNotEmpty)
        ? _buildCard(
      fade: _fade1,
      slide: _slide1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_pickedFiles.isNotEmpty) ...[
            const Text(
              "📂 Selected Files",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._pickedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF2A7DE1).withOpacity(0.3),
                  ),
                  color: Colors.grey.shade50,
                ),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.insert_drive_file, color: Color(0xFF2A7DE1)),
                  title: Text(
                    file.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setModalState(() => _pickedFiles.removeAt(index)); // 👈 Updates instantly
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
          // 🔥 Do the same for Audios & Videos
        ],
      ),
    )
        : _buildCard(
      fade: _fade1,
      slide: _slide1,
      child: const Center(
        child: Text(
          "No files uploaded yet",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  void _openFabActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      isScrollControlled: true, // 👈 Optional if you want scrolling
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 2, 16, 40),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFabActionItem(setModalState), // 👈 Pass modal state updater
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() => _pickedFiles.addAll(result.files));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Picked ${result.files.length} file(s)")),
      );
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result != null) {
      setState(() => _pickedAudios.addAll(result.files));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Picked ${result.files.length} audio file(s)")),
      );
    }
  }



  void _recordVoiceNote() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Record voice note to be implemented ... 🎤")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text("Add New Content 📄",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0, right: 0.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2BD46E), Color(0xFF2A7DE1)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: FloatingActionButton(
            onPressed: _openFabActions,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.more_horiz, color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  /// Course Dropdown
                  Container(
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.1),
                          blurRadius: 3,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),

                    ),
                    margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Container(
                        color: _courses.isEmpty
                            ? Colors.grey.shade200
                            : Colors.white,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<Course>(
                            isExpanded: true,
                            value: _selectedCourse,
                            hint: Text(
                              _courses.isEmpty
                                  ? "No courses available"
                                  : "Select Course",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                _courses.isEmpty ? Colors.grey : Colors.black,
                              ),
                            ),
                            selectedItemBuilder: (context) => _courses
                                .map((c) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                c.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                                .toList(),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  )
                                ],
                              ),
                            ),
                            items: _courses.isEmpty
                                ? []
                                : [
                              for (final c in _courses)
                                DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                            ],
                            onChanged: _courses.isEmpty
                                ? null
                                : (c) {
                              setState(() => _selectedCourse = c);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// --- Card 1
                  _buildCard(
                    fade: _fade1,
                    slide: _slide1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add New Content",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Upload files, add notes, or record audio",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          label: "Title",
                          hint: "Topic or lesson title",
                          controller: _titleController,
                        ),
                        _buildInputField(
                          label: "Notes",
                          hint:
                          "Type your notes here or upload content below...",
                          controller: _notesController,
                          maxLines: 4,
                          labelAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  /// --- Card 2
                _buildCard(
                  fade: _fade2,
                  slide: _slide2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Upload Content",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildOutlineButton(
                        text: "Upload File (PDF, DOC, etc.)",
                        icon: Icons.upload_file,
                        onTap: _pickFile,
                      ),
                      _buildOutlineButton(
                        text: "Upload Audio to Transcribe",
                        icon: Icons.audiotrack,
                        onTap: _pickAudio,
                      ),
                      _buildOutlineButton(
                        text: "Upload Video",
                        icon: Icons.video_file, // or Icons.movie
                        onTap: _pickVideo,
                      ),
                    ],
                  ),
                ),
                  const SizedBox(height: 80), // spacing before button
                ],
              ),
            ),
          ),

          /// Sticky Save Button (same width as other cards)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final noteTitle = _titleController.text.trim();
                    final noteText = _notesController.text.trim();

                    final hasNote = noteTitle.isNotEmpty || noteText.isNotEmpty;
                    final hasFiles = _pickedFiles.isNotEmpty;
                    final hasAudios = _pickedAudios.isNotEmpty;

                    if (!hasNote && !hasFiles && !hasAudios) {
                      _showSnackBar(context, "Please add notes or materials before saving");
                      return;
                    }

                    // Decide type
                    String type;
                    if (hasNote && (hasFiles || hasAudios)) {
                      type = "note"; // treat as note with attachments
                    } else if (hasNote) {
                      type = "note";
                    } else if (hasFiles) {
                      type = "pdf"; // or "file", depending on how you want to tag
                    } else if (hasAudios) {
                      type = "audio";
                    } else {
                      type = "unknown";
                    }

                    await _saveMaterial(
                      type: type,
                      title: noteTitle.isNotEmpty ? noteTitle : "Untitled",
                      description: noteText,
                      files: _pickedFiles.map((f) => f.name).toList(),
                      audios: _pickedAudios.map((a) => a.name).toList(),
                      videos: _pickedVideos.map((v) => v.name).toList(), // 👈 ADD THIS
                    );

                    // Clear after save
                    setState(() {
                      _titleController.clear();
                      _notesController.clear();
                      _pickedFiles.clear();
                      _pickedAudios.clear();
                      _pickedVideos.clear();
                    });
                  },

                  icon: const Icon(Icons.save, color: Colors.white),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      (() {
                        final hasFile = _pickedFiles.isNotEmpty;
                        final hasAudio = _pickedAudios.isNotEmpty;
                        final hasNote = _titleController.text.trim().isNotEmpty ||
                            _notesController.text.trim().isNotEmpty;

                        if (hasNote && (hasFile || hasAudio)) {
                          return "Save Note + Material";
                        } else if (hasNote) {
                          return "Save Note";
                        } else if (hasFile || hasAudio) {
                          return "Save Material";
                        } else {
                          return "Save";
                        }
                      })(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
