import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CourseDetailPage.dart';
import 'add_material.dart';

// ------------------- Course Model -------------------
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

  Map<String, dynamic> toJson() => {
    "title": title,
    "progress": progress,
    "description": description,
    "icon": icon.codePoint,
    "group": group,
  };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    title: json["title"],
    progress: (json["progress"] as num).toDouble(),
    description: json["description"],
    icon: IconData(json["icon"], fontFamily: 'MaterialIcons'),
    group: json["group"],
  );
}

// ------------------- Storage Helper -------------------
class StorageHelper {
  static Future<SharedPreferences> _prefs() async => SharedPreferences.getInstance();

  // Groups
  static Future<List<String>> loadGroups() async {
    final prefs = await _prefs();
    final saved = prefs.getStringList("courseGroups");
    return saved != null && saved.isNotEmpty ? ["All", ...saved.where((g) => g != "All")] : ["All"];
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
    final jsonStr = jsonEncode(courses.map((c) => c.toJson()).toList());
    await prefs.setString("courses", jsonStr);
  }
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

// ------------------- Courses Page -------------------
class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<String> courseGroups = ["All"];
  String selectedGroup = "All";
  List<Course> allCourses = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final loadedGroups = await StorageHelper.loadGroups();
    final loadedCourses = await StorageHelper.loadCourses();
    final savedGroup = await StorageHelper.loadSelectedGroup();

    setState(() {
      courseGroups = loadedGroups;
      allCourses = loadedCourses;
      if (savedGroup != null && courseGroups.contains(savedGroup)) {
        selectedGroup = savedGroup;
      }
    });
  }

  Future<void> _saveGroupsAndCourses() async {
    await StorageHelper.saveGroups(courseGroups);
    await StorageHelper.saveCourses(allCourses);
  }

  void _showAddGroupDialog() {
    final controller = TextEditingController();
    showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Add New Group',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(
            labelText: 'Group name',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.group_add, color: Colors.black54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black87),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 3,
              shadowColor: Colors.cyanAccent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final newGroup = controller.text.trim();
              if (newGroup.isEmpty || courseGroups.contains(newGroup)) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Group already exists or is empty!",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                return;
              }
              setState(() {
                courseGroups.add(newGroup);
                selectedGroup = newGroup;
              });
              await _saveGroupsAndCourses();
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.check),
            label: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(String oldGroup) {
    final controller = TextEditingController(text: oldGroup);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Edit Group",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(
            labelText: 'New group name',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.edit, color: Colors.black54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 3,
              shadowColor: Colors.cyanAccent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final newGroup = controller.text.trim();
              if (courseGroups.contains(newGroup)) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Group already exists!",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                return;
              }
              if (newGroup.isNotEmpty && newGroup != oldGroup) {
                setState(() {
                  final index = courseGroups.indexOf(oldGroup);
                  if (index != -1) {
                    courseGroups[index] = newGroup;
                  }
                  for (final course in allCourses) {
                    if (course.group == oldGroup) {
                      course.group = newGroup;
                    }
                  }
                  if (selectedGroup == oldGroup) {
                    selectedGroup = newGroup;
                  }
                });
                await _saveGroupsAndCourses();
              }
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.check),
            label: const Text("Save"),
          ),
        ],
      ),
    );
  }

  _confirmDeleteGroup(String group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          "Delete Group",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          "Are you sure you want to delete '$group'?",
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        actions: [
          ElevatedButton.icon(
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
            icon: const Icon(Icons.cancel, color: Colors.black),
            label: const Text("Cancel"),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor: Colors.redAccent.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              setState(() {
                courseGroups.remove(group);
                allCourses.removeWhere((c) => c.group == group);
                if (selectedGroup == group) {
                  selectedGroup = "All";
                }
              });
              await _saveGroupsAndCourses();
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text(
              "Delete",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
                                  colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
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
  void _showAddCourseDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedGroupForCourse = selectedGroup == "All"
        ? courseGroups.firstWhere((g) => g != "All", orElse: () => "All")
        : selectedGroup;
    IconData? selectedIcon = Icons.book;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateSB) => Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Container(
            width: 360,
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A7DE1),Color(0xFF2BD46E)],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 8),
                      Text(
                        'Add New Course 📚',
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
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(
                              labelText: 'Course title',
                              labelStyle: TextStyle(color: Colors.black54),
                              prefixIcon:
                              Icon(Icons.title, color: Colors.black54),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: descController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: const InputDecoration(
                              labelText: 'Description (optional)',
                              labelStyle: TextStyle(color: Colors.black54),
                              prefixIcon:
                              Icon(Icons.description, color: Colors.black54),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Select group",
                              labelStyle: const TextStyle(color: Colors.black54),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                value: selectedGroupForCourse,
                                selectedItemBuilder: (context) => courseGroups
                                    .where((g) => g != "All")
                                    .map((g) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    g,
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
                                items: [
                                  for (final g in courseGroups.where((g) => g != "All"))
                                    DropdownMenuItem(
                                      value: g,
                                      child: Text(
                                        g,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  const DropdownMenuItem(
                                    value: "__add_new__",
                                    child: Row(
                                      children: [
                                        Icon(Icons.add, color: Color(0xFF00838F)),
                                        SizedBox(width: 8),
                                        Text(
                                          "Add new group",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF00838F),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (g) async {
                                  if (g == "__add_new__") {
                                    // Navigator.pop(context); // close the Add Course dialog first
                                    _showAddGroupDialog();
                                  } else {
                                    setStateSB(() => selectedGroupForCourse = g!);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

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
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  final picked = await pickIconDialog(ctx);
                                  if (picked != null) {
                                    setStateSB(() => selectedIcon = picked);
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
                            shadowColor: Colors.redAccent.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                          label: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 3,
                            shadowColor: Colors.cyanAccent.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final desc = descController.text.trim();

                            if (title.isEmpty || selectedGroupForCourse == "All") {
                              ScaffoldMessenger.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text("Invalid course details!"),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.all(16),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              return;
                            }

                            setState(() {
                              allCourses.add(Course(
                                title: title,
                                progress: 0,
                                description: desc.isEmpty ? null : desc,
                                icon: selectedIcon!,
                                group: selectedGroupForCourse,
                              ));
                            });

                            await _saveGroupsAndCourses();
                            Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.check),
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



  void _openFabActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 2, 16, 40),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFabActionItem(Icons.note_add, "Add Material", [Color(0xFF2A7DE1), Color(0xFF2BD46E)],() {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => AddMaterialPage()),
                );
              },),
              _buildFabActionItem(Icons.add_circle, "Add a new course", [Color(0xFF2BD46E), Color(0xFF2A7DE1)],(_showAddCourseDialog ),),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFabActionItem(
      IconData icon,
      String title,
      List<Color> gradientColors,
      VoidCallback onTap,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(1.8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: () {
            Navigator.of(context).pop();
            onTap();
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final filteredCourses = selectedGroup == "All"
        ? allCourses
        : allCourses.where((c) => c.group == selectedGroup).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Courses 📚"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0.0, right: 5.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2BD46E), Color(0xFF2A7DE1)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _openFabActions,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown for course groups
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Container(
                  color: Colors.white,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      value: selectedGroup,
                      selectedItemBuilder: (context) => courseGroups
                          .map((g) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          g,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
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
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                        ),
                      ),
                      items: [
                        for (final g in courseGroups)
                          DropdownMenuItem(
                            value: g,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(g, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                                if (g != "All")
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color:Color(0xFF00838F)),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _showEditGroupDialog(g);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _confirmDeleteGroup(g);
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        const DropdownMenuItem(
                          value: "__add_new__",
                          child: Row(
                            children: [
                              Icon(Icons.add, color: Color(0xFF00838F)),
                              SizedBox(width: 8),
                              Text("Add new group", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF00838F))),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (g) async {
                        if (g == "__add_new__") {
                          _showAddGroupDialog();
                        } else {
                          setState(() => selectedGroup = g!);
                          await StorageHelper.saveSelectedGroup(selectedGroup);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Course list
            Expanded(
              child: filteredCourses.isEmpty
                  ? const Center(
                child: Text("No courses found in this group", style: TextStyle(color: Colors.black54, fontSize: 16)),
              )
                  : ListView.builder(
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  final course = filteredCourses[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CourseListTile(
                      title: course.title,
                      description: course.description,
                      progress: course.progress,
                      icon: course.icon,
                    ),
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

extension on Course {
  void operator [](String other) {}
}

// ------------------- CourseListTile -------------------
class CourseListTile extends StatelessWidget {
  final String title;
  final String? description;
  final double progress;
  final IconData icon;

  const CourseListTile({
    super.key,
    required this.title,
    this.description,
    required this.progress,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailsPage(
              title: title,
              progress: progress,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(description!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black.withOpacity(0.6), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        Container(color: Colors.grey.shade300),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text("${(progress * 100).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
