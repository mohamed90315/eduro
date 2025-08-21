import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  String? selectedFileName;
  String? selectedFilePath;
  String? selectedSubject;

  // Store mappings of file -> subject
  final Map<String, String> fileAssignments = {};

  // Example subjects (replace with dynamic later)
  final List<String> subjects = [
    "Math",
    "Physics",
    "Chemistry",
    "Computer Science",
    "Biology",
  ];

  Future<void> importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFileName = result.files.single.name;
        selectedFilePath = result.files.single.path; // Full path
        selectedSubject = null; // reset subject selection
      });
    }
  }

  void assignFileToSubject() {
    if (selectedFileName != null && selectedSubject != null) {
      setState(() {
        fileAssignments[selectedFileName!] = selectedSubject!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B1B), // Dark background
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF3A2F2F), // Brownish box
            borderRadius: BorderRadius.circular(12),
          ),
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              const Text(
                "Import / Export",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              // Buttons row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                    onPressed: importFile,
                    child: const Text("Import"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade700,
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 14),
                    ),
                    onPressed: () {
                      // TODO: Add export functionality later
                    },
                    child: const Text("Export"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Show imported file details + subject dropdown
              if (selectedFileName != null) ...[
                Text(
                  "Selected File: $selectedFileName",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  "Path: $selectedFilePath",
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // Dropdown for subject assignment
                DropdownButtonFormField<String>(
                  dropdownColor: const Color(0xFF3A2F2F),
                  decoration: InputDecoration(
                    labelText: "Assign to Subject",
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.amber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: selectedSubject,
                  items: subjects
                      .map((subject) => DropdownMenuItem(
                    value: subject,
                    child: Text(
                      subject,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Save assignment button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                  ),
                  onPressed: assignFileToSubject,
                  child: const Text("Add File to Subject"),
                ),
              ],

              const SizedBox(height: 20),

              // Show list of file -> subject assignments
              if (fileAssignments.isNotEmpty) ...[
                const Divider(color: Colors.white24, thickness: 1),
                const SizedBox(height: 10),
                const Text(
                  "Assigned Files",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fileAssignments.entries
                      .map((entry) => Text(
                    "${entry.key} → ${entry.value}",
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
