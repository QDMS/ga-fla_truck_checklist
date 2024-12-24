import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:truckchecklist/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truckchecklist/views/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> employeeInfo;

  @override
  void initState() {
    super.initState();
    employeeInfo = _getEmployeeInfo();
  }

  Future<Map<String, dynamic>> _getEmployeeInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('employees')
            .doc(user.uid)
            .get();
        return snapshot.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      debugPrint('Error fetching employee info: $e');
      return {};
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Get.offAll(() =>
          const LoginScreen()); // Replaces Navigator logic with Get.offAll
    } catch (e) {
      debugPrint('Logout error: $e');
      CustomSnackBar('Error', 'Logout failed: ${e.toString()}', Colors.red);
    }
  }

  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () =>
                Get.back(result: false), // Closes dialog with false
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true), // Closes dialog with true
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) {
      await _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: screenHeight / 4,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        title: Center(
          child: FutureBuilder<Map<String, dynamic>>(
            future: employeeInfo,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person),
                );
              } else {
                final employeeData = snapshot.data!;
                final profileImage = employeeData['profileImage'] as String?;
                return CircleAvatar(
                  backgroundColor: primary,
                  radius: 150,
                  child: CircleAvatar(
                    radius: 140,
                    backgroundImage: profileImage != null
                        ? NetworkImage(profileImage)
                        : const AssetImage('assets/images/default_avatar.jpg')
                            as ImageProvider,
                  ),
                );
              }
            },
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>>(
              future: employeeInfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No employee data found.'));
                } else {
                  final employeeData = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Username: ${employeeData['username'] ?? 'N/A'}',
                            style: Theme.of(context).textTheme.titleLarge),
                        Text(
                            'Company ID: ${employeeData['employeeCompanyId'] ?? 'N/A'}',
                            style: Theme.of(context).textTheme.titleLarge),
                        Text('Email: ${employeeData['email'] ?? 'N/A'}'),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(250, 50),
                              backgroundColor: primary,
                            ),
                            onPressed: _confirmLogout,
                            label: const Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
