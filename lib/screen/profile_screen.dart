import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'achievement_screen.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  String? photoUrl;
  bool _uploading = false;

  // User data from Firestore
  String? displayName;
  String? email;
  String? createdAt;
  bool _loadingUserData = true;

  // Editing state
  bool _isEditingName = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  // Notification and theme state (local UI state)
  bool _studyReminders = true;
  bool _quizAlerts = true;
  bool _featureUpdates = false;
  bool _isDarkMode = false; // false = day mode, true = night mode

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    photoUrl = user?.photoURL ?? '';
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user?.uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          if (mounted) {
            setState(() {
              displayName =
                  data?['displayName']?.toString() ??
                  user?.displayName ??
                  'No name';
              email = data?['email']?.toString() ?? user?.email ?? '';

              // Format createdAt timestamp
              if (data?['createdAt'] != null) {
                final timestamp = data!['createdAt'] as Timestamp;
                final date = timestamp.toDate();
                createdAt = '${date.month}/${date.day}/${date.year}';
              } else {
                createdAt = 'Unknown';
              }

              _loadingUserData = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              displayName = user?.displayName ?? 'No name';
              email = user?.email ?? '';
              createdAt = 'Unknown';
              _loadingUserData = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            displayName = user?.displayName ?? 'No name';
            email = user?.email ?? '';
            createdAt = 'Unknown';
            _loadingUserData = false;
          });
        }
      }
    } else {
      setState(() {
        displayName = 'No name';
        email = '';
        createdAt = 'Unknown';
        _loadingUserData = false;
      });
    }
  }

  Future<void> _startEditingName() async {
    setState(() {
      _isEditingName = true;
      _nameController.text = displayName ?? '';
    });
    // Wait for the widget to rebuild, then focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  Future<void> _finishEditingName() async {
    if (!_isEditingName) return;

    final newName = _nameController.text.trim();

    // Validate: name cannot be empty
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      // Restore original name
      _nameController.text = displayName ?? '';
      return;
    }

    // If name hasn't changed, just exit edit mode
    if (newName == displayName) {
      setState(() {
        _isEditingName = false;
      });
      return;
    }

    setState(() {
      _isEditingName = false;
      displayName = newName;
    });

    // Update Firestore
    try {
      final uid = user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'displayName': newName,
        });

        // Also update Firebase Auth profile
        await user?.updateDisplayName(newName);
        await user?.reload();
        user = FirebaseAuth.instance.currentUser;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Name updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update name: $e'),
            backgroundColor: Colors.red,
          ),
        );
        // Revert to original name on error
        setState(() {
          displayName = user?.displayName ?? 'No name';
        });
      }
    }
  }

  Future<void> _showImageOptions() async {
    // TODO: Implement photo upload/delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo upload feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildGradientCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // More rounded like design
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(
              0.15,
            ), // Subtle cyan shadow like design
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24), // More padding like design
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // More rounded like design
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(
              0.15,
            ), // Subtle cyan shadow like design
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAvatar() {
    final Widget avatarImage = (photoUrl != null && photoUrl!.isNotEmpty)
        ? ClipOval(
            child: Image.network(
              photoUrl!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          );

    return Center(
      child: Stack(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(
                    0.15,
                  ), // Subtle cyan shadow like design
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(child: avatarImage),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _showImageOptions,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blueAccent,
                      Colors.greenAccent,
                    ], // CTA button gradient from palette
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(
                        0.25,
                      ), // Stronger shadow for edit button
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Not signed in')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background like the design
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Text(
              "Profile",
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
              child: Icon(Icons.person, color: Colors.black, size: 28),
            ),
          ],
        ),
        backgroundColor: Colors.grey[50], // Match screen background
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24), // More padding like design
        child: Column(
          children: [
            // Profile Header Card
            _buildGradientCard(
              child: Padding(
                padding: const EdgeInsets.all(32), // More generous padding
                child: Column(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 20),
                    _loadingUserData
                        ? const CircularProgressIndicator()
                        : Column(
                            children: [
                              Text(
                                displayName ?? 'No name',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                email ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),

            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.access_time,
                    value: '124h',
                    label: 'Study Time',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    value: '7',
                    label: 'Day Streak',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.menu_book,
                    value: '3',
                    label: 'Courses',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.emoji_events,
                    value: '12',
                    label: 'Badges',
                  ),
                ),
              ],
            ),

            // Account Details Card
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Account Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: _startEditingName,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.black54,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildAccountDetailItem(
                    icon: Icons.email_outlined,
                    label: 'EMAIL',
                    value: email ?? 'No email',
                  ),
                  const SizedBox(height: 16),
                  _buildAccountDetailItem(
                    icon: Icons.person_outline,
                    label: 'USERNAME',
                    value: displayName ?? 'No name',
                    isEditing: _isEditingName,
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    onEditComplete: _finishEditingName,
                  ),
                  const SizedBox(height: 16),
                  _buildAccountDetailItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'MEMBER SINCE',
                    value: createdAt ?? 'Unknown',
                  ),
                ],
              ),
            ),

            // Theme Settings
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Primary text from palette
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildThemeModeSwitch(),
                ],
              ),
            ),

            // Recent Achievements Card
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AchievementScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00838F),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAchievementItem(
                    icon: Icons.emoji_events,
                    title: 'Study Streak Champion',
                    subtitle: 'Completed 7 days in a row',
                    badge: 'New',
                    isNew: true,
                  ),
                  const SizedBox(height: 12),
                  _buildAchievementItem(
                    icon: Icons.menu_book,
                    title: 'Course Completion',
                    subtitle: 'Finished Mathematics Basics',
                    badge: '3 days ago',
                    isNew: false,
                  ),
                ],
              ),
            ),

            // Notifications
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Primary text from palette
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildNotificationOption(
                    'Study Reminders',
                    _studyReminders,
                    (v) => setState(() => _studyReminders = v),
                  ),
                  _buildNotificationOption(
                    'Quiz Completion Alerts',
                    _quizAlerts,
                    (v) => setState(() => _quizAlerts = v),
                  ),
                  _buildNotificationOption(
                    'New Feature Updates',
                    _featureUpdates,
                    (v) => setState(() => _featureUpdates = v),
                  ),
                ],
              ),
            ),

            // Account Options
            _buildWhiteCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Primary text from palette
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildAccountOption(
                    'Account Information',
                    Icons.person_outline,
                  ),
                  _buildAccountOption(
                    'Privacy Settings',
                    Icons.privacy_tip_outlined,
                  ),
                  _buildAccountOption('Security', Icons.security_outlined),
                ],
              ),
            ),

            // Logout Button
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  24,
                ), // More rounded like design
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.25),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      24,
                    ), // More rounded like design
                  ),
                  elevation:
                      0, // Remove default elevation since we have custom shadow
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false, // remove all previous routes
                  );

                },
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            if (_uploading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2), // Border width
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            18,
          ), // Slightly smaller radius for inner container
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black54, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isEditing = false,
    TextEditingController? controller,
    FocusNode? focusNode,
    VoidCallback? onEditComplete,
  }) {
    return GestureDetector(
      onTap: () {
        // If editing and user taps outside, finish editing
        if (isEditing && onEditComplete != null) {
          onEditComplete();
        }
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.black54, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                if (isEditing && controller != null && focusNode != null)
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan, width: 2),
                      ),
                    ),
                    onSubmitted: (_) {
                      if (onEditComplete != null) {
                        onEditComplete();
                      }
                    },
                    onTapOutside: (_) {
                      if (onEditComplete != null) {
                        onEditComplete();
                      }
                    },
                  )
                else
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: 48,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.black87 : Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: _isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.cyan.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background text
            Positioned.fill(
              child: Row(
                children: [
                  // Day Mode Text
                  Expanded(
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: !_isDarkMode ? 0.0 : 1.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_sunny_outlined,
                              color: Colors.grey[400],
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'DAY MODE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Night Mode Text
                  Expanded(
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isDarkMode ? 0.0 : 1.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.nightlight_round,
                              color: Colors.grey[600],
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'NIGHT MODE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Animated circle
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: _isDarkMode
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isDarkMode
                        ? Icon(
                            Icons.nightlight_round,
                            key: const ValueKey('night'),
                            color: Colors.black87,
                            size: 18,
                          )
                        : Icon(
                            Icons.wb_sunny_outlined,
                            key: const ValueKey('day'),
                            color: Colors.orange,
                            size: 18,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87, // Secondary text from palette
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00838F),
            inactiveThumbColor: Colors.grey.shade600,
            inactiveTrackColor: Colors.grey.shade200,
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountOption(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle navigation
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50], // Very subtle background like design
          borderRadius: BorderRadius.circular(16), // More rounded like design
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black54,
              size: 24,
            ), // Muted/tertiary text from palette
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87, // Secondary text from palette
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.black54,
            ), // Muted/tertiary text from palette
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required bool isNew,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew
              ? Colors.cyan.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
              ),
              borderRadius: BorderRadius.circular(12),
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
                    fontWeight: FontWeight.w600,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isNew
                  ? Color(0xFF00838F).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isNew ? Color(0xFF00838F) : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
