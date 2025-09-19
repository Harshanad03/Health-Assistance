import 'package:flutter/material.dart';
import 'dart:io';
import 'edit_profile_page.dart';
import '../utils/routes.dart';
import '../widgets/modern_wavy_app_bar.dart';
import '../models/user_profile.dart';
import '../services/firestore_profile_service.dart';
import '../services/health_data_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();

    FirestoreProfileService().getUserProfile().then((profile) {
      setState(() {}); // Refresh UI after loading profile
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = UserProfile.instance;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: Column(
        children: [
          ModernWavyAppBar(
            height: 140,
            child: Center(
              child: Padding(padding: const EdgeInsets.only(top: 40.0)),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 215, 223, 247),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          offset: const Offset(-4, -4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            5,
                            5,
                            167,
                          ).withOpacity(0.12),
                          offset: const Offset(4, 4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD6E0FF),
                            image:
                                user.profilePicture != null
                                    ? DecorationImage(
                                      image: FileImage(
                                        File(user.profilePicture!),
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                    : (user.sex?.toLowerCase() == 'male')
                                    ? const DecorationImage(
                                      image: AssetImage(
                                        'assets/profile_male.jpg',
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                    : const DecorationImage(
                                      image: AssetImage(
                                        'assets/profile_female.jpg',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          user.name ?? 'Your Name',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 44, 66, 113),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Profile Details',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8A8FA6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'My Info',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color.fromARGB(255, 44, 66, 113),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _profileDetailRow(Icons.person, 'Name', user.name),
                        _profileDetailRow(Icons.cake, 'Age', user.age),
                        _profileDetailRow(
                          Icons.calendar_today,
                          'Date of Birth',
                          user.dob,
                        ),
                        _profileDetailRow(Icons.wc, 'Sex', user.sex),
                        _profileDetailRow(Icons.phone, 'Phone', user.phone),
                        _profileDetailRow(Icons.pin, 'Pincode', user.pincode),
                        const SizedBox(height: 24),

                        if (user.name.isEmpty ||
                            user.dob.isEmpty ||
                            user.age.isEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 243, 205),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color.fromARGB(
                                  255,
                                  255,
                                  193,
                                  7,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color.fromARGB(255, 255, 193, 7),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Please complete your profile to access health monitoring features. Your age is required for accurate health calculations.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Health Information',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Color.fromARGB(255, 44, 66, 113),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildHealthInfoCard(user),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfilePage(),
                                ),
                              );
                              setState(() {}); // Rebuild to show updated data
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                1,
                                25,
                                59,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                              shadowColor: const Color.fromARGB(
                                255,
                                1,
                                25,
                                59,
                              ).withOpacity(0.3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showLogoutDialog(context);
                            },
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                220,
                                53,
                                69,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                              shadowColor: const Color.fromARGB(
                                255,
                                220,
                                53,
                                69,
                              ).withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(220, 245, 247, 255),
          border: const Border(
            top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 13,
          unselectedFontSize: 13,
          iconSize: 22,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          selectedItemColor: const Color.fromARGB(255, 44, 66, 113),
          unselectedItemColor: Colors.black38,
          currentIndex: 1, // Profile tab selected
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            } else if (index == 1) {
            } else if (index == 2) {}
          },
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _buildCircleIcon(Icons.home_rounded, false),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _buildCircleIcon(Icons.person_rounded, true),
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _buildCircleIcon(Icons.description_rounded, false),
              ),
              label: 'Document',
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 44, 66, 113),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 108, 117, 125)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 220, 53, 69),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Widget _profileDetailRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8EAFE),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  offset: const Offset(-2, -2),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: const Color.fromARGB(255, 5, 5, 167).withOpacity(0.10),
                  offset: const Offset(2, 2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Color.fromARGB(255, 44, 66, 113),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 44, 66, 113),
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, bool selected) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFFE8EAFE) : const Color(0xFFD6E0FF),
        border:
            selected
                ? Border.all(
                  color: const Color.fromARGB(255, 44, 66, 113),
                  width: 2,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Icon(
        icon,
        color:
            selected ? const Color.fromARGB(255, 44, 66, 113) : Colors.black38,
        size: 20,
      ),
    );
  }

  Widget _buildHealthInfoCard(UserProfile user) {
    final healthService = HealthDataService.instance;
    final age = healthService.calculateAge(user.dob);
    final bpRange = healthService.getFormattedBloodPressureRange(age);
    final hrRange = healthService.getFormattedHeartRateRange(age);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8EAFE), Color(0xFFD6E0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-2, -2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color.fromARGB(255, 5, 5, 167).withOpacity(0.10),
            offset: const Offset(2, 2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(
                    255,
                    44,
                    66,
                    113,
                  ).withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(-1, -1),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        5,
                        5,
                        167,
                      ).withOpacity(0.08),
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Color.fromARGB(255, 44, 66, 113),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expected Blood Pressure',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 44, 66, 113),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bpRange,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 44, 66, 113),
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'mmHg (Systolic/Diastolic)',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(
                    255,
                    44,
                    66,
                    113,
                  ).withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(-1, -1),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        5,
                        5,
                        167,
                      ).withOpacity(0.08),
                      offset: const Offset(1, 1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.monitor_heart,
                  color: Color.fromARGB(255, 44, 66, 113),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expected Heart Rate',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 44, 66, 113),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hrRange,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 44, 66, 113),
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Resting heart rate',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 44, 66, 113).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 44, 66, 113).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color.fromARGB(255, 44, 66, 113),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Based on your age: $age years',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 44, 66, 113),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
