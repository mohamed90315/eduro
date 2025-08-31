import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:convert'; // for json encode/decode
import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(const MyApp());
// }

// class LeaderboardPage extends StatefulWidget {
//   const LeaderboardPage({super.key});
//
//   @override
//   State<LeaderboardPage> createState() => _LeaderboardPageState();
// }

// ====== MODELS ======
class Team {
  final String id;
  String name;
  String inviteCode;
  final List<UserScore> members;

  Team({required this.id, required this.name, required this.inviteCode, required this.members});
}

class UserScore {
  final String username;
  int scoreAllTime;
  int scoreMonthly;

  UserScore({
    required this.username,
    required this.scoreAllTime,
    required this.scoreMonthly,
  });
}

// ====== MOCK DATA / REPOSITORY ======
class MockRepo {
  static final Map<String, Team> _inviteCodes = {};

  static List<Team> initialUserTeams() {
    final team = Team(
      id: 't-egypt',
      name: 'Egypt Tigers',
      inviteCode: 'EGY1',
      members: [
        UserScore(username: '0xgus1337', scoreAllTime: 18377, scoreMonthly: 4000),
        UserScore(username: 'rrawwann', scoreAllTime: 27233, scoreMonthly: 6800),
        UserScore(username: 'morphinee', scoreAllTime: 34741, scoreMonthly: 8200),
        UserScore(username: 'HaSsAnAlA', scoreAllTime: 26635, scoreMonthly: 6400),
        UserScore(username: 'iamfarrah', scoreAllTime: 22902, scoreMonthly: 7200),
        UserScore(username: 'aswa2', scoreAllTime: 9188, scoreMonthly: 1900),
        UserScore(username: 'yousefsakr', scoreAllTime: 20439, scoreMonthly: 5400),
      ],
    );
    _inviteCodes[team.inviteCode] = team;
    return [team];
  }

  static Future<Team?> validateInviteCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _inviteCodes[code.trim().toUpperCase()];
  }

  static Future<Team> createTeam(String name, {String? owner}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final id = 't-${DateTime.now().millisecondsSinceEpoch}';
    final code = _generateUniqueCode();
    final newTeam = Team(
      id: id,
      name: name.trim(),
      inviteCode: code,
      members: [if (owner != null) UserScore(username: owner, scoreAllTime: 0, scoreMonthly: 0)],
    );
    _inviteCodes[code] = newTeam;
    return newTeam;
  }

  static String _generateUniqueCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    String code;
    do {
      code = List.generate(4, (index) => chars[rand.nextInt(chars.length)]).join();
    } while (_inviteCodes.containsKey(code));
    return code;
  }
}
bool _snackBarVisible = false;
// ====== VIEW MODE ======
enum ViewMode { allTime, monthly }

// ====== LEADERBOARD PAGE ======
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}


class _LeaderboardPageState extends State<LeaderboardPage> {
  late List<Team> userTeams;
  Team? selectedTeam;
  ViewMode viewMode = ViewMode.monthly;

  @override
  void initState() {
    super.initState();
    _loadTeams(); // load from storage
  }

  Future<void> _loadTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('userTeams');
    if (stored != null) {
      final decoded = jsonDecode(stored) as List<dynamic>;
      userTeams = decoded
          .map((t) => _teamFromJson(Map<String, dynamic>.from(t)))
          .toList();
    } else {
      userTeams = MockRepo.initialUserTeams();
    }
    if (userTeams.isNotEmpty) {
      selectedTeam = userTeams.first;
    }
    setState(() {});
  }

  Future<void> _saveTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(userTeams.map(_teamToJson).toList());
    await prefs.setString('userTeams', encoded);
  }

  // Convert Team <-> Map for storage
  Map<String, dynamic> _teamToJson(Team t) => {
    'id': t.id,
    'name': t.name,
    'inviteCode': t.inviteCode,
    'members': t.members
        .map((m) => {
      'username': m.username,
      'scoreAllTime': m.scoreAllTime,
      'scoreMonthly': m.scoreMonthly,
    })
        .toList(),
  };

  Team _teamFromJson(Map<String, dynamic> json) => Team(
    id: json['id'],
    name: json['name'],
    inviteCode: json['inviteCode'],
    members: (json['members'] as List)
        .map((m) => UserScore(
      username: m['username'],
      scoreAllTime: m['scoreAllTime'],
      scoreMonthly: m['scoreMonthly'],
    ))
        .toList(),
  );

  List<UserScore> _sortedMembers() {
    final list = List<UserScore>.from(selectedTeam?.members ?? []);
    list.sort((a, b) {
      final aScore = viewMode == ViewMode.allTime ? a.scoreAllTime : a.scoreMonthly;
      final bScore = viewMode == ViewMode.allTime ? b.scoreAllTime : b.scoreMonthly;
      return bScore.compareTo(aScore);
    });
    return list;
  }

  int _score(UserScore u) => viewMode == ViewMode.allTime ? u.scoreAllTime : u.scoreMonthly;

  // Future<void> _handleJoinTeam() async {
  //   final code = await showDialog<String?>(
  //     context: context,
  //     builder: (ctx) {
  //       final controller = TextEditingController();
  //       return AlertDialog(
  //         title: const Text('Join a team'),
  //         content: TextField(
  //           controller: controller,
  //           decoration: const InputDecoration(
  //             labelText: 'Enter invite code',
  //             prefixIcon: Icon(Icons.key),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
  //           FilledButton(
  //             style: _ctaButtonStyle(),
  //             onPressed: () => Navigator.pop(ctx, controller.text),
  //             child: const Text('Join'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   if (code == null || code.trim().isEmpty) return;
  //   final team = await MockRepo.validateInviteCode(code);
  //   if (team == null) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid team code.')));
  //     return;
  //   }
  //   if (!userTeams.any((t) => t.id == team.id)) {
  //     setState(() {
  //       userTeams.add(team);
  //       selectedTeam = team;
  //     });
  //     await _saveTeams();
  //   } else {
  //     setState(() => selectedTeam = team);
  //   }
  //   if (!mounted) return;
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Joined team: ${team.name}')));
  // }

  Future<void> _handleJoinTeam() async {
    final controller = TextEditingController();

    final code = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Join a Team",
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
            labelText: 'Enter invite code',
            labelStyle: TextStyle(color: Colors.black54),
            prefixIcon: Icon(Icons.key, color: Colors.black54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
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
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            icon: const Icon(Icons.group_add),
            label: const Text("Join"),
          ),
        ],
      ),
    );

    if (code == null || code.isEmpty) return;

    final team = await MockRepo.validateInviteCode(code);
    if (team == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Invalid team code!",
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

    if (!userTeams.any((t) => t.id == team.id)) {
      setState(() {
        userTeams.add(team);
        selectedTeam = team;
      });
    } else {
      setState(() => selectedTeam = team);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                "Joined team: ${team.name}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
  }


  Future<void> _handleCreateTeam() async {
    final name = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Create a new team',
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
              labelText: 'Team name',
              labelStyle: TextStyle(color: Colors.black54),
              prefixIcon: Icon(Icons.group_add, color: Colors.black54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text(
                'Cancel',
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
              onPressed: () => Navigator.pop(ctx, controller.text),
              icon: const Icon(Icons.check),
              label: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (name == null || name.trim().isEmpty) return;

    final newTeam = await MockRepo.createTeam(name, owner: 'you');
    setState(() {
      userTeams.add(newTeam);
      selectedTeam = newTeam;
    });
    await _saveTeams();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Team "${newTeam.name}" created. Code: ${newTeam.inviteCode}',
        ),
      ),
    );
  }


  void _openFabActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // transparent sheet
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 2, 16, 40), // ⬅️ extra bottom margin raises the box
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Join a team
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(1.8), // border thickness
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.greenAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.group_add, color: Colors.black),
                    title: const Text(
                      'Join a team',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleJoinTeam();
                    },
                  ),
                ),
              ),

              // Create a team
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(1.8), // border thickness
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.greenAccent, Colors.blueAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.group_add, color: Colors.black),
                    title: const Text(
                      'Create a team',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleCreateTeam();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final members = _sortedMembers();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Leaderboard  🏆',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30.0, right: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.green],
            ),
            // shape: BoxShape.circle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.6),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _openFabActions,
            backgroundColor: Colors.transparent, // <-- makes gradient visible
            elevation: 0, // <-- remove default FAB shadow so gradient/shadow shows
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

// Team dropdown with styled box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(1.5), // gradient border thickness
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.greenAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.3), // cyan glow
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Container(
                            color: Colors.white,
                            child: DropdownButtonHideUnderline(
                              child: userTeams.isEmpty
                                  ? InkWell(
                                onTap: () {
                                  if (_snackBarVisible) return; // ignore taps while snackbar is visible
                                  _snackBarVisible = true;

                                  final messenger = ScaffoldMessenger.of(context);
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('No teams available. Please create or join a team first.'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  ).closed.then((_) {
                                    _snackBarVisible = false; // reset when snackbar disappears
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: const Text(
                                    'No teams available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              )
                                  : DropdownButton2<Team>(
                                isExpanded: true,
                                value: selectedTeam,
                                items: [
                                  for (final t in userTeams)
                                    DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        t.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                ],
                                onChanged: (t) => setState(() => selectedTeam = t),
                                buttonStyleData: const ButtonStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 250,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  _ViewIconLabeled(
                    label: 'All time',
                    icon: Icons.auto_graph,
                    active: viewMode == ViewMode.allTime,
                    onTap: () => setState(() => viewMode = ViewMode.allTime),
                  ),
                  const SizedBox(width: 8),
                  _ViewIconLabeled(
                    label: 'Monthly',
                    icon: Icons.calendar_today,
                    active: viewMode == ViewMode.monthly,
                    onTap: () => setState(() => viewMode = ViewMode.monthly),
                  ),
                  const SizedBox(width: 8),
                  _ViewIconLabeled(
                    label: 'Settings',
                    icon: Icons.settings,
                    active: false,
                    onTap: () => _openTeamSettings(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: members.isEmpty
                  ? const Center(child: Text('No members yet'))
                  : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _RankCard(
                      rank: 1,
                      username: members[0].username,
                      score: _score(members[0]),
                      color: Colors.cyanAccent.withOpacity(0.6),
                      medal: '🥇',
                    ),
                    const SizedBox(height: 8),
                    if (members.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _RankCard(
                                rank: 2,
                                username: members[1].username,
                                score: _score(members[1]),
                                color: Colors.black12,
                                medal: '🥈',
                                margin: const EdgeInsets.symmetric(vertical: 6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _RankCard(
                                rank: 3,
                                username: members.length > 2 ? members[2].username : '-',
                                score: members.length > 2 ? _score(members[2]) : 0,
                                color: Colors.cyan.withOpacity(0.2),
                                medal: '🥉',
                                margin: const EdgeInsets.symmetric(vertical: 6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (members.length > 3)
                      ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: members.length - 3,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final user = members[index + 3];
                          final rank = index + 4;
                          return _RankCard(
                            rank: rank,
                            username: user.username,
                            score: _score(user),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _ctaButtonStyle() {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      elevation: WidgetStateProperty.all(0),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      overlayColor: WidgetStateProperty.all(Colors.black12),
      side: WidgetStateProperty.all(BorderSide.none),
      textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.bold)),
    ).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        return null; // handled by Ink gradient
      }),
      overlayColor: WidgetStateProperty.all(Colors.black12),
    );
  }

  void _openTeamSettings() {
    if (selectedTeam == null) return;
    final team = selectedTeam!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // let rounded container float
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 1, 16, 20),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // View members
              _buildFloatingActionTile(
                ctx,
                icon: Icons.group,
                text: 'View Team Members',
                onTap: () {
                  Navigator.pop(ctx);
                  _showTeamMembers(team);
                },
              ),

              // Exit team
              _buildFloatingActionTile(
                ctx,
                icon: Icons.logout,
                text: 'Exit team',
                onTap: () async {
                  Navigator.pop(ctx);
                  setState(() {
                    userTeams.removeWhere((t) => t.id == team.id);
                    selectedTeam = userTeams.isNotEmpty ? userTeams.first : null;
                  });
                  await _saveTeams();
                },
              ),


              // Delete team
              _buildFloatingActionTile(
                ctx,
                icon: Icons.delete,
                text: 'Delete team',
                onTap: () async  {
                  Navigator.pop(ctx);
                  setState(() {
                    userTeams.remove(team);
                    selectedTeam =
                    userTeams.isNotEmpty ? userTeams.first : null;
                  });
                  await _saveTeams();
                },
              ),

              // Edit name
              _buildFloatingActionTile(
                ctx,
                icon: Icons.edit,
                text: 'Edit team name',
                onTap: () async {
                  final controller = TextEditingController(text: team.name);
                  final newName = await showDialog<String?>(
                    context: context,
                    builder: (dctx) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: const Text(
                        'Edit Team Name',
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
                          hintText: "Enter new name",
                          hintStyle: TextStyle(color: Colors.black54),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dctx, null),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 3,
                            shadowColor: Colors.cyanAccent.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () =>
                              Navigator.pop(dctx, controller.text),
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );

                  if (newName != null && newName.trim().isNotEmpty) {
                    setState(() => team.name = newName.trim());
                    await _saveTeams();
                  }
                  Navigator.pop(ctx);
                },
              ),

              // Team code (read-only)
              _buildFloatingActionTile(
                ctx,
                icon: Icons.code,
                text: 'Team code: ${team.inviteCode}',
                onTap: () {}, // no action
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable floating action tile with gradient outline + shadow
  Widget _buildFloatingActionTile(
      BuildContext ctx, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(1.8), // gradient border thickness
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.greenAccent],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showTeamMembers(Team team) {
    final sortedMembers = [...team.members]
      ..sort((a, b) => a.username.toLowerCase().compareTo(b.username.toLowerCase()));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // let us style container
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.3), // subtle glow
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Text(
                  'Team Members (A–Z)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const Divider(height: 12),

              // Member list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortedMembers.length,
                  itemBuilder: (context, index) {
                    final m = sortedMembers[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(1.8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.greenAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.black),
                          title: Text(
                            m.username,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _ViewIconLabeled extends StatelessWidget {
  const _ViewIconLabeled({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(colors: [Colors.blue, Colors.green])
                  : null,
              color: active ? null : Colors.black12,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (active)
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
              ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: active ? Colors.white : Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? Colors.black : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}


class _RankCard extends StatefulWidget {
  const _RankCard({
    required this.rank,
    required this.username,
    required this.score,
    this.color,
    this.medal,
    this.margin,
  });

  final int rank;
  final String username;
  final int score;
  final Color? color;
  final String? medal;
  final EdgeInsetsGeometry? margin;

  @override
  State<_RankCard> createState() => _RankCardState();
}

class _RankCardState extends State<_RankCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Gradient? _buildGradient() {
    switch (widget.rank) {
      case 1: // Gold
        return const LinearGradient(
          colors: [
            Color(0xFFF9E79F), // soft highlight gold
            Color(0xFFF1C40F), // rich gold mid
            Color(0xFFD4AF37), // classic metallic gold
            Color(0xFFF9E79F), // deep antique gold
          ],
          stops: [0.0, 0.3, 0.65, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

      case 2: // Silver
        return const LinearGradient(
          colors: [
            Color(0xFFECEFF1), // bright silver
            Color(0xFFB0BEC5), // mid steel
            Color(0xFF455A64), // deep steel
            Color(0xFFECEFF1), // reflective edge
          ],
          stops: [0.0, 0.35, 0.7, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3: // Bronze
        return const LinearGradient(
          colors: [
            Color(0xFFF5E1C8), // soft reflective highlight (champagne bronze)
            Color(0xFFE6A267), // warm polished bronze mid
            Color(0xFFCD7F32), // classic bronze (standard hex)
            Color(0xFFF5E1C8), // deeper elegant bronze shadow
          ],
          stops: [0.0, 0.3, 0.65, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return null;
    }
  }

  BoxShadow _buildShadow() {
    switch (widget.rank) {
      case 1:
        return BoxShadow(
          color: const Color(0xFFFBC02D).withValues(alpha: 0.5),
          blurRadius: 14,
          spreadRadius: 2,
        );
      case 2:
        return BoxShadow(
          color: const Color(0xFF546E7A).withValues(alpha: 0.45),
          blurRadius: 12,
          spreadRadius: 2,
        );
      case 3:
        return BoxShadow(
          color: const Color(0xFFCD7F32).withValues(alpha: 0.5),
          blurRadius: 12,
          spreadRadius: 2,
        );
      default:
        return BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 2,
          spreadRadius: 1,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _buildGradient();

    return Container(
      margin:
      widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: gradient == null ? (widget.color ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.12),
          width: 1.3,
        ),
        boxShadow: [_buildShadow()],
      ),
      child: Stack(
        children: [
          // Static vertical highlight overlay (brushed metal texture)
          // if (widget.rank <= 3)
          //   Positioned.fill(
          //     child: Container(
          //       decoration: BoxDecoration(
          //         gradient: LinearGradient(
          //           colors: [
          //             Colors.white.withValues(alpha: 0.18),
          //             Colors.transparent,
          //             Colors.white.withValues(alpha: 0.12),
          //           ],
          //           begin: Alignment.topCenter,
          //           end: Alignment.bottomCenter,
          //           stops: const [0.2, 0.5, 0.8],
          //         ),
          //       ),
          //     ),
          //   ),

          // Shimmer sweep (animated metallic reflection)
          if (widget.rank <= 3)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: 0.25,
                  alignment: Alignment(-1.0 + 2.0 * _controller.value, 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                );
              },
            ),

          Row(
            children: [
              Text(
                '${widget.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: widget.rank <= 3 ? 20 : 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.username,
                  style: TextStyle(
                    fontWeight:
                    widget.rank <= 3 ? FontWeight.bold : FontWeight.w600,
                    fontSize: widget.rank <= 3 ? 16 : 14,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.medal != null)
                Text(
                  widget.medal!,
                  style: TextStyle(
                    fontSize: widget.rank <= 3 ? 22 : 18,
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                '${widget.score}',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight:
                  widget.rank <= 3 ? FontWeight.bold : FontWeight.normal,
                  fontSize: widget.rank <= 3 ? 16 : 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
