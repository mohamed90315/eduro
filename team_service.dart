import 'dart:convert';
import 'package:http/http.dart' as http;
import 'leaderboard.dart'; // <-- make sure you have your Team/UserScore model here

const String teamsApiUrl = "https://mock-api.net/api/Flutter/teams";

class TeamService {
  /// Fetch all teams
  static Future<List<Team>> fetchTeams() async {
    final response = await http.get(Uri.parse(teamsApiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((t) => Team.fromJson(t)).toList();
    } else {
      throw Exception("Failed to load teams");
    }
  }

  /// Create a new team
  static Future<Team> createTeam(Team team) async {
    final response = await http.post(
      Uri.parse(teamsApiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(team.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Team.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create team");
    }
  }

  /// Edit team (name or other fields)
  static Future<Team> editTeam(String id, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse("$teamsApiUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      return Team.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to update team");
    }
  }

  /// Join a team (add member)
  static Future<Team> joinTeam(String teamId, UserScore user) async {
    final response = await http.patch(
      Uri.parse("$teamsApiUrl/$teamId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "join",
        "member": user.toJson(),
      }),
    );

    if (response.statusCode == 200) {
      return Team.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to join team");
    }
  }

  /// Leave a team (remove member)
  static Future<Team> leaveTeam(String teamId, String username) async {
    final response = await http.patch(
      Uri.parse("$teamsApiUrl/$teamId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "action": "leave",
        "username": username,
      }),
    );

    if (response.statusCode == 200) {
      return Team.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to leave team");
    }
  }

  /// Delete a team
  static Future<void> deleteTeam(String id) async {
    final response = await http.delete(Uri.parse("$teamsApiUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to delete team");
    }
  }
}
