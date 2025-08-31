import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import 'package:audioplayers/audioplayers.dart';
import 'add_material.dart';


class CourseDetailsPage extends StatefulWidget {
  final String courseTitle;
  final IconData courseIcon;
  final double progress;

  const CourseDetailsPage({
    super.key,
    required this.courseTitle,
    required this.courseIcon,
    required this.progress,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class NamedIcon {
  final String name;
  final IconData icon;
  const NamedIcon(this.name, this.icon);
}

final List<NamedIcon> allCourseIcons = [
  NamedIcon("edit", Icons.edit),
  NamedIcon("book", Icons.book),
  NamedIcon("computer", Icons.computer),
  NamedIcon("science", Icons.science),
  NamedIcon("calculate", Icons.calculate),
  NamedIcon("school", Icons.school),
  NamedIcon("code", Icons.code),
  NamedIcon("star", Icons.star),
  NamedIcon("check", Icons.check),
  NamedIcon("close", Icons.close),
  NamedIcon("delete", Icons.delete),
  NamedIcon("save", Icons.save),
  NamedIcon("search", Icons.search),
  NamedIcon("settings", Icons.settings),
  NamedIcon("share", Icons.share),
  NamedIcon("camera_alt", Icons.camera_alt),
  NamedIcon("photo", Icons.photo),
  NamedIcon("image", Icons.image),
  NamedIcon("music_note", Icons.music_note),
  NamedIcon("mic", Icons.mic),
  NamedIcon("volume_up", Icons.volume_up),
  NamedIcon("map", Icons.map),
  NamedIcon("location_on", Icons.location_on),
  NamedIcon("directions", Icons.directions),
  NamedIcon("phone", Icons.phone),
  NamedIcon("email", Icons.email),
  NamedIcon("message", Icons.message),
  NamedIcon("chat", Icons.chat),
  NamedIcon("group", Icons.group),
  NamedIcon("person", Icons.person),
  NamedIcon("people", Icons.people),
  NamedIcon("work", Icons.work),
  NamedIcon("business", Icons.business),
  NamedIcon("shopping_cart", Icons.shopping_cart),
  NamedIcon("payment", Icons.payment),
  NamedIcon("card_giftcard", Icons.card_giftcard),
  NamedIcon("home", Icons.home),
  NamedIcon("house", Icons.house),
  NamedIcon("apartment", Icons.apartment),
  NamedIcon("hotel", Icons.hotel),
  NamedIcon("flight", Icons.flight),
  NamedIcon("directions_car", Icons.directions_car),
  NamedIcon("train", Icons.train),
  NamedIcon("directions_boat", Icons.directions_boat),
  NamedIcon("pedal_bike", Icons.pedal_bike),
  NamedIcon("sports_soccer", Icons.sports_soccer),
  NamedIcon("sports_basketball", Icons.sports_basketball),
  NamedIcon("sports_baseball", Icons.sports_baseball),
  NamedIcon("sports_tennis", Icons.sports_tennis),
  NamedIcon("fitness_center", Icons.fitness_center),
  NamedIcon("local_cafe", Icons.local_cafe),
  NamedIcon("restaurant", Icons.restaurant),
  NamedIcon("fastfood", Icons.fastfood),
  NamedIcon("local_bar", Icons.local_bar),
  NamedIcon("local_grocery_store", Icons.local_grocery_store),
  NamedIcon("local_hospital", Icons.local_hospital),
  NamedIcon("healing", Icons.healing),
  NamedIcon("local_pharmacy", Icons.local_pharmacy),
  NamedIcon("local_library", Icons.local_library),
  NamedIcon("menu_book", Icons.menu_book),
  NamedIcon("school_outlined", Icons.school_outlined),
  NamedIcon("science_outlined", Icons.science_outlined),
  NamedIcon("calculate_outlined", Icons.calculate_outlined),
  NamedIcon("computer_outlined", Icons.computer_outlined),
  NamedIcon("code_outlined", Icons.code_outlined),
  NamedIcon("lightbulb", Icons.lightbulb),
  NamedIcon("bolt", Icons.bolt),
  NamedIcon("eco", Icons.eco),
  NamedIcon("nature", Icons.nature),
  NamedIcon("water", Icons.water),
  NamedIcon("wb_sunny", Icons.wb_sunny),
  NamedIcon("cloud", Icons.cloud),
  NamedIcon("ac_unit", Icons.ac_unit),
  NamedIcon("waves", Icons.waves),
  NamedIcon("language", Icons.language),
  NamedIcon("public", Icons.public),
  NamedIcon("explore", Icons.explore),
  NamedIcon("travel_explore", Icons.travel_explore),
  NamedIcon("emoji_events", Icons.emoji_events),
  NamedIcon("military_tech", Icons.military_tech),
  NamedIcon("workspace_premium", Icons.workspace_premium),
  NamedIcon("sports_esports", Icons.sports_esports),
  NamedIcon("videogame_asset", Icons.videogame_asset),
  NamedIcon("movie", Icons.movie),
  NamedIcon("tv", Icons.tv),
  NamedIcon("radio", Icons.radio),
  NamedIcon("headphones", Icons.headphones),
  NamedIcon("brush", Icons.brush),
  NamedIcon("palette", Icons.palette),
  NamedIcon("design_services", Icons.design_services),
  NamedIcon("build", Icons.build),
  NamedIcon("engineering", Icons.engineering),
  NamedIcon("architecture", Icons.architecture),
  NamedIcon("calculate_rounded", Icons.calculate_rounded),
  NamedIcon("analytics", Icons.analytics),
  NamedIcon("bar_chart", Icons.bar_chart),
  NamedIcon("timeline", Icons.timeline),
  NamedIcon("account_balance", Icons.account_balance),
  NamedIcon("attach_money", Icons.attach_money),
  NamedIcon("currency_exchange", Icons.currency_exchange),
  NamedIcon("euro", Icons.euro),
  NamedIcon("trending_up", Icons.trending_up),
  NamedIcon("local_shipping", Icons.local_shipping),
  NamedIcon("inventory", Icons.inventory),
  NamedIcon("fact_check", Icons.fact_check),
  NamedIcon("security", Icons.security),
  NamedIcon("verified_user", Icons.verified_user),
  NamedIcon("fingerprint", Icons.fingerprint),
  NamedIcon("lock", Icons.lock),
  NamedIcon("vpn_key", Icons.vpn_key),
  NamedIcon("assignment", Icons.assignment),
  NamedIcon("task", Icons.task),
  NamedIcon("notes", Icons.notes),
  NamedIcon("description", Icons.description),
  NamedIcon("bookmark", Icons.bookmark),
  NamedIcon("push_pin", Icons.push_pin),
  NamedIcon("schedule", Icons.schedule),
  NamedIcon("calendar_today", Icons.calendar_today),
  NamedIcon("event", Icons.event),
  NamedIcon("alarm", Icons.alarm),
  NamedIcon("access_time", Icons.access_time),
  NamedIcon("timer", Icons.timer),
  NamedIcon("hourglass_bottom", Icons.hourglass_bottom),
  NamedIcon("bug_report", Icons.bug_report),
  NamedIcon("memory", Icons.memory),
  NamedIcon("data_object", Icons.data_object),
  NamedIcon("storage", Icons.storage),
  NamedIcon("developer_mode", Icons.developer_mode),
  NamedIcon("terminal", Icons.terminal),
  NamedIcon("battery_full", Icons.battery_full),
  NamedIcon("charging_station", Icons.charging_station),
  NamedIcon("electrical_services", Icons.electrical_services),
  NamedIcon("power", Icons.power),
  NamedIcon("wifi", Icons.wifi),
  NamedIcon("network_check", Icons.network_check),
  NamedIcon("brightness_5", Icons.brightness_5),
  NamedIcon("brightness_6", Icons.brightness_6),
  NamedIcon("construction", Icons.construction),
  NamedIcon("local_doctor ",Icons.health_and_safety),
  NamedIcon("palette",Icons.palette ),
  NamedIcon("format_paint ",Icons.format_paint),
  NamedIcon("theaters",Icons.theaters),
];

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  // runtime mutable title (widget.courseTitle is final)
  late String _currentTitle;
  // Track completed states for all items
  final Map<String, bool> _completedMap = {};

  // Helper: get completion state
  bool _isCompleted(String id) => _completedMap[id] ?? false;

  // Helper: toggle completion state
  void _toggleCompletion(String id, bool done) {
    setState(() {
      _completedMap[id] = done;
    });
  }
  List<Map<String, dynamic>> materials = [];
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.courseTitle;
    _loadMaterials();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    final prefs = await SharedPreferences.getInstance();
    final String? materialsJson = prefs.getString('materials');

    if (materialsJson == null) {
      setState(() => materials = []);
      return;
    }

    final List<dynamic> materialsList = jsonDecode(materialsJson);

    // keep as list of Map<String, dynamic>
    final List<Map<String, dynamic>> all =
    List<Map<String, dynamic>>.from(materialsList
        .map((e) =>
    e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{
    }));

    // filter by the current title
    setState(() {
      materials = all.where((m) => m['course'] == _currentTitle).toList();
    });
  }



  Future<IconData?> pickIconDialog(BuildContext context) async {
    return await showDialog<IconData>(
      context: context,
      builder: (ctx) {
        TextEditingController searchController = TextEditingController();
        ValueNotifier<String> searchQuery = ValueNotifier("");

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: const [
              Icon(Icons.widgets, color: Colors.black, size: 18),
              SizedBox(width: 8),
              Text(
                "Pick an Icon",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 220, // 🔥 makes it scrollable
            child: Column(
              children: [
                // 🔍 Search Bar
                TextField(
                  controller: searchController,
                  onChanged: (val) => searchQuery.value = val.toLowerCase(),
                  decoration: InputDecoration(
                    hintText: "Search icons...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // 🔄 Filtered Icons
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: searchQuery,
                    builder: (context, query, _) {
                      final filtered = allCourseIcons.where((ic) {
                        return ic.name.toLowerCase().contains(query);
                      }).toList();

                      return GridView.builder(
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5, // 🔥 more compact grid
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final ic = filtered[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () => Navigator.pop(ctx, ic.icon),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2A7DE1),
                                    Color(0xFF2BD46E)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child:
                              Icon(ic.icon, color: Colors.white, size: 28),
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
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 3,
                shadowColor: Colors.cyanAccent.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        );
      },
    );
  }


// ------------------- Add Course Dialog -------------------
  void _editCourseDetails() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    IconData? selectedIcon = Icons.book;

    showDialog(
      context: context,
      builder: (ctx) =>
          StatefulBuilder(
            builder: (ctx, setStateSB) =>
                Dialog(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Container(
                    width: 360,
                    constraints: const BoxConstraints(maxHeight: 500),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔹 Title Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(width: 8),
                              Text(
                                'Edit Course 📚',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  // color: Color(0xFF00838F),
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // 🔹 Fields & Inputs
                          Flexible(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: titleController,
                                    style: const TextStyle(
                                        color: Colors.black87),
                                    decoration: const InputDecoration(
                                      labelText: 'Course title',
                                      labelStyle: TextStyle(
                                          color: Colors.black54),
                                      prefixIcon:
                                      Icon(Icons.title, color: Colors.black54),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  TextField(
                                    controller: descController,
                                    style: const TextStyle(
                                        color: Colors.black87),
                                    decoration: const InputDecoration(
                                      labelText: 'Description (optional)',
                                      labelStyle: TextStyle(
                                          color: Colors.black54),
                                      prefixIcon:
                                      Icon(Icons.description,
                                          color: Colors.black54),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // InputDecorator(
                                  //   decoration: InputDecoration(
                                  //     labelText: "Select group",
                                  //     labelStyle: const TextStyle(color: Colors.black54),
                                  //     border: const OutlineInputBorder(
                                  //       borderSide: BorderSide(color: Colors.grey),
                                  //     ),
                                  //     enabledBorder: const OutlineInputBorder(
                                  //       borderSide: BorderSide(color: Colors.grey),
                                  //     ),
                                  //     focusedBorder: const OutlineInputBorder(
                                  //       borderSide: BorderSide(color: Colors.blue, width: 2),
                                  //     ),
                                  //     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  //   ),
                                  //   child: DropdownButtonHideUnderline(
                                  //     child: DropdownButton2<String>(
                                  //       isExpanded: true,
                                  //       value: selectedGroupForCourse,
                                  //       selectedItemBuilder: (context) => courseGroups
                                  //           .where((g) => g != "All")
                                  //           .where((g) => g != "All")
                                  //           .map((g) => Align(
                                  //         alignment: Alignment.centerLeft,
                                  //         child: Text(
                                  //           g,
                                  //           style: const TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.w600,
                                  //             color: Colors.black87,
                                  //           ),
                                  //           overflow: TextOverflow.ellipsis,
                                  //         ),
                                  //       ))
                                  //           .toList(),
                                  //       dropdownStyleData: DropdownStyleData(
                                  //         maxHeight: 200,
                                  //         padding: EdgeInsets.zero,
                                  //         elevation: 0,
                                  //         decoration: BoxDecoration(
                                  //           color: Colors.white,
                                  //           borderRadius: BorderRadius.circular(12),
                                  //           boxShadow: const [
                                  //             BoxShadow(
                                  //               color: Colors.black26,
                                  //               blurRadius: 8,
                                  //               offset: Offset(0, 4),
                                  //             )
                                  //           ],
                                  //         ),
                                  //       ),
                                  //       items: [
                                  //         for (final g in courseGroups.where((g) => g != "All"))
                                  //           DropdownMenuItem(
                                  //             value: g,
                                  //             child: Text(
                                  //               g,
                                  //               style: const TextStyle(
                                  //                 fontSize: 16,
                                  //                 fontWeight: FontWeight.w600,
                                  //                 color: Colors.black87,
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         const DropdownMenuItem(
                                  //           value: "__add_new__",
                                  //           child: Row(
                                  //             children: [
                                  //               Icon(Icons.add, color: Color(0xFF00838F)),
                                  //               SizedBox(width: 8),
                                  //               Text(
                                  //                 "Add new group",
                                  //                 style: TextStyle(
                                  //                   fontSize: 16,
                                  //                   fontWeight: FontWeight.w600,
                                  //                   color: Color(0xFF00838F),
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         ),
                                  //       ],
                                  //       onChanged: (g) async {
                                  //         if (g == "__add_new__") {
                                  //           // Navigator.pop(context); // close the Add Course dialog first
                                  //           _showAddGroupDialog();
                                  //         } else {
                                  //           setStateSB(() => selectedGroupForCourse = g!);
                                  //         }
                                  //       },
                                  //     ),
                                  //   ),
                                  // ),
                                  // const SizedBox(height: 12),

                                  // 🔹 Icon Picker
                                  Row(
                                    children: [
                                      const Text(
                                        "Course Icon:",
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(selectedIcon,
                                          size: 28, color: Colors.black87),
                                      const Spacer(),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          elevation: 3,
                                          shadowColor:
                                          Colors.cyanAccent.withOpacity(0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final picked = await pickIconDialog(
                                              ctx);
                                          if (picked != null) {
                                            setStateSB(() =>
                                            selectedIcon = picked);
                                          }
                                        },
                                        child: const Text("Pick"),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 🔹 Actions (Centered)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 3,
                                    shadowColor: Colors.redAccent.withOpacity(
                                        0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(ctx),
                                  // icon: const Icon(Icons.close),
                                  label: const Text("Delete"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 3,
                                    shadowColor: Colors.grey.withOpacity(0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                  },
                                  // icon: const Icon(Icons.check),
                                  label: const Text("Cancel"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    elevation: 3,
                                    shadowColor: Colors.cyanAccent.withOpacity(
                                        0.6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                  },
                                  // icon: const Icon(Icons.cancel),
                                  label: const Text("Add"),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  // Helper: show snackbar
  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)));
  }

  // Helper: attempt to open file and show friendly error if it fails
  Future<void> _tryOpenFile(String path) async {
    try {
      final result = await OpenFilex.open(path);
      // OpenFilex returns details; if it failed you may inform user (some platforms return -1)
      if (result.type == ResultType.error) {
        _showSnack("Could not open file: ${path
            .split('/')
            .last}");
      }
    } catch (e) {
      _showSnack("Could not open file: ${path
          .split('/')
          .last}");
    }
  }

  // Helper: play audio file (path should be device path)
  Future<void> _playAudio(String path) async {
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
    } catch (e) {
      _showSnack("Could not play audio: ${path
          .split('/')
          .last}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Normalize legacy note keys:
    // Some older entries may have noteTitle/noteText instead of title/description.
    final normalized = materials.map((m) {
      final copy = Map<String, dynamic>.from(m);
      if ((copy['title'] == null || (copy['title'] as String).isEmpty) &&
          copy['noteTitle'] != null) {
        copy['title'] = copy['noteTitle'];
      }
      if ((copy['description'] == null ||
          (copy['description'] as String).isEmpty) &&
          copy['noteText'] != null) {
        copy['description'] = copy['noteText'];
      }
      return copy;
    }).toList();

    // Notes: only materials of type 'note' or legacy noteText
    final notes = normalized.where((m) =>
    m['type'] == 'note' || m.containsKey('noteText')).toList();

    // Files: collect all files across materials and flatten into entries
    final List<Map<String, String>> fileEntries = [];
    for (var m in normalized) {
      final List<dynamic> files = (m['files'] is List)
          ? (m['files'] as List)
          : [];
      for (var f in files) {
        if (f == null) continue;
        fileEntries.add({
          'path': f.toString(),
          'parentTitle': (m['title'] ?? 'Untitled').toString(),
          'parentType': (m['type'] ?? '').toString(),
        });
      }
    }

    // Audio entries: collect audio file paths
    final List<Map<String, String>> audioEntries = [];
    for (var m in normalized) {
      final List<dynamic> audios = (m['audios'] is List)
          ? (m['audios'] as List)
          : [];
      for (var a in audios) {
        if (a == null) continue;
        audioEntries.add({
          'path': a.toString(),
          'parentTitle': (m['title'] ?? 'Untitled').toString(),
        });
      }
    }

    // Videos entries
    final List<Map<String, String>> videoEntries = [];
    for (var m in normalized) {
      final List<dynamic> vids = (m['files'] is List) ? (m['files'] as List) : [
      ];
      // If m.type == 'video' treat those files as videos
      if (m['type'] == 'video') {
        for (var v in vids) {
          if (v == null) continue;
          videoEntries.add({
            'path': v.toString(),
            'parentTitle': (m['title'] ?? 'Untitled').toString()
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Text(
              _currentTitle,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(width: 6),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Icon(widget.courseIcon, color: Colors.white, size: 28),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: _editCourseDetails),
          //   IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: _deleteCourse),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Progress Header
            const Text("Progress", style: TextStyle(fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
            const SizedBox(height: 8),

            // Progress bar styled
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color: Colors.blueGrey.withOpacity(0.6), width: 1.2),
                boxShadow: [
                  BoxShadow(color: Colors.cyanAccent.withOpacity(0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 12,
                  child: Stack(children: [
                    Container(color: Colors.white70),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: widget.progress),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      builder: (context, value, _) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFF2A7DE1),
                                Color(0xFF2BD46E)
                              ]),
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sections
            _buildNotesSection(notes),
            _buildFilesSection(fileEntries),
            _buildAudioSection(audioEntries),
            _buildVideosSection(videoEntries),

            const SizedBox(height: 20),

            // CTA Example (Add Material) — you can connect this to your add flow
            GestureDetector(
              onTap: () {
                // debugStorage();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddMaterialPage()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.cyanAccent.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: const Center(
                  child: Text("➕  Add Material", style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // NOTES section
  Widget _buildNotesSection(List<Map<String, dynamic>> notes) {
    return _sectionWrapper(
      title: "Notes",
      children: notes.isEmpty
          ? [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No content here yet",
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        )
      ]
          : notes.map((m) {
        final title = (m['title'] ?? 'Untitled').toString();
        final desc = (m['description'] ?? '').toString();
        final id = 'note-$title'; // Unique key for state tracking
        return _materialTile(
          leadingIcon: Icons.note,
          title: title,
          subtitle: desc,
          isDone: _isCompleted(id),
          onCheck: (done) => _toggleCompletion(id, done),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text("To be connected to agamy's notes"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Close"),
                  )
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // FILES section
  Widget _buildFilesSection(List<Map<String, String>> fileEntries) {
    return _sectionWrapper(
      title: "Files",
      children: fileEntries.isEmpty
          ? [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No files yet",
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        )
      ]
          : fileEntries.map((entry) {
        final path = entry['path'] ?? '';
        final fileName = path.split('/').last;
        final parent = entry['parentTitle'] ?? '';
        final id = 'file-$fileName';
        return _materialTile(
          leadingIcon: Icons.picture_as_pdf,
          title: fileName,
          subtitle: parent,
          isDone: _isCompleted(id),
          onCheck: (done) => _toggleCompletion(id, done),
          onTap: () async {
            if (path.isEmpty) {
              _showSnack("Missing file path");
              return;
            }
            await _tryOpenFile(path);
          },
        );
      }).toList(),
    );
  }

  // AUDIO section
  Widget _buildAudioSection(List<Map<String, String>> audioEntries) {
    return _sectionWrapper(
      title: "Audio",
      children: audioEntries.isEmpty
          ? [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No audio here yet",
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        )
      ]
          : audioEntries.map((entry) {
        final path = entry['path'] ?? '';
        final fileName = path.split('/').last;
        final parent = entry['parentTitle'] ?? '';
        final id = 'audio-$fileName';
        return _materialTile(
          leadingIcon: Icons.audiotrack,
          title: fileName,
          subtitle: parent,
          isDone: _isCompleted(id),
          onCheck: (done) => _toggleCompletion(id, done),
          onTap: () async {
            if (path.isEmpty) {
              _showSnack("Missing audio path");
              return;
            }
            await _playAudio(path);
          },
        );
      }).toList(),
    );
  }

  // VIDEOS section
  Widget _buildVideosSection(List<Map<String, String>> videoEntries) {
    return _sectionWrapper(
      title: "Videos",
      children: videoEntries.isEmpty
          ? [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No videos here yet",
            style: TextStyle(color: Colors.black54, fontSize: 15),
          ),
        )
      ]
          : videoEntries.map((entry) {
        final path = entry['path'] ?? '';
        final fileName = path.split('/').last;
        final parent = entry['parentTitle'] ?? '';
        final id = 'video-$fileName';
        return _materialTile(
          leadingIcon: Icons.play_circle,
          title: fileName,
          subtitle: parent,
          isDone: _isCompleted(id),
          onCheck: (done) => _toggleCompletion(id, done),
          onTap: () async {
            if (path.isEmpty) {
              _showSnack("Missing video path");
              return;
            }
            await _tryOpenFile(path);
          },
        );
      }).toList(),
    );
  }

  // Tile Widget
  Widget _materialTile({
    required IconData leadingIcon,
    required String title,
    String? subtitle,
    required bool isDone,
    required VoidCallback onTap,
    required Function(bool) onCheck,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              // Gradient accent bar
              Container(
                width: 5,
                height: 50,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.green],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Icon
              Icon(
                leadingIcon,
                size: 22,
                color: isDone ? Colors.grey : Colors.black,
              ),
              const SizedBox(width: 10),

              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDone ? Colors.grey : Colors.black,
                        decoration: isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDone ? Colors.grey : Colors.black54,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                  ],
                ),
              ),

              // Circle checkbox
              Checkbox(
                shape: const CircleBorder(),
                value: isDone,
                onChanged: (val) {
                  if (val != null) onCheck(val);
                },
                activeColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wrapper
  Widget _sectionWrapper({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedIconColor: Colors.black,
          iconColor: Colors.black,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.symmetric(vertical: 4),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          children: children.isNotEmpty
              ? children
              : [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "No items yet",
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}