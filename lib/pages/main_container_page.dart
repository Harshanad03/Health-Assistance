import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/modern_wavy_app_bar.dart';
import '../models/user_profile.dart';
import '../utils/routes.dart';
import '../services/firestore_profile_service.dart';
import '../services/health_data_service.dart';
import 'edit_profile_page.dart';
import '../services/local_storage_service.dart';
import '../services/measurement_history_service.dart';
import '../models/measurement_history.dart';
import '../services/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class MainContainerPage extends StatefulWidget {
  final int initialTabIndex;
  const MainContainerPage({Key? key, this.initialTabIndex = 0})
    : super(key: key);

  @override
  State<MainContainerPage> createState() => _MainContainerPageState();
}

class _MainContainerPageState extends State<MainContainerPage> {
  int _currentIndex = 0;
  List<MeasurementGroup> _measurementGroups = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex; // Set initial tab
    _loadUserProfile();
    _loadMeasurementHistory();
  }

  void _loadUserProfile() {
    UserProfile.instance.clear();

    setState(() {
      _measurementGroups = [];
    });

    FirestoreProfileService().getUserProfile().then((profile) {
      setState(() {}); // Refresh UI after loading profile
    });
  }

  Future<void> _loadMeasurementHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final historyService = MeasurementHistoryService.instance;
      print('MainContainer: Loading measurement history...');

      final allMeasurements = await historyService.getAllMeasurements();
      print(
        'MainContainer: Found ${allMeasurements.length} total measurements',
      );

      final groups = await historyService.getMeasurementsGroupedByDate();
      print('MainContainer: Created ${groups.length} measurement groups');

      setState(() {
        _measurementGroups = groups;
      });

      if (groups.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${allMeasurements.length} measurements'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error loading measurement history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _testSaveMeasurement() async {
    try {
      final historyService = MeasurementHistoryService.instance;
      print('MainContainer: Testing measurement save...');

      final success = await historyService.saveHeartRateMeasurement(
        heartRate: 75,
        age: 30,
        isNormal: true,
        additionalMetadata: {'test': true},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Test measurement saved!'
                  : 'Failed to save test measurement',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (success) {
        await _loadMeasurementHistory();
      }
    } catch (e) {
      print('Error in test save: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test save error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildCircleIcon(IconData icon, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: selected ? 34 : 30, // Dynamic sizing
      height: selected ? 34 : 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient:
            selected
                ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 240, 245, 255),
                    Color.fromARGB(255, 230, 240, 255),
                  ],
                )
                : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 235, 240, 250),
                    Color.fromARGB(255, 225, 235, 248),
                  ],
                ),
        border:
            selected
                ? Border.all(
                  color: const Color.fromARGB(255, 44, 66, 113),
                  width: 2.5,
                )
                : Border.all(
                  color: const Color.fromARGB(255, 200, 210, 230),
                  width: 1,
                ),
        boxShadow:
            selected
                ? [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      44,
                      66,
                      113,
                    ).withOpacity(0.15),
                    offset: const Offset(0, 3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    offset: const Offset(0, -1),
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
      ),
      child: AnimatedScale(
        scale: selected ? 1.0 : 0.9,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Icon(
          icon,
          color:
              selected
                  ? const Color.fromARGB(255, 44, 66, 113)
                  : const Color.fromARGB(255, 120, 130, 150),
          size: selected ? 18 : 16, // Dynamic icon size
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    final user = UserProfile.instance;
    final DateTime now = DateTime.now();
    final String greeting =
        now.hour < 12
            ? 'Good Morning'
            : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 248, 250, 255),
                  Color.fromARGB(255, 240, 245, 255),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color.fromARGB(255, 220, 230, 250),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    44,
                    66,
                    113,
                  ).withOpacity(0.06),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 44, 66, 113),
                            Color.fromARGB(255, 70, 90, 140),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              44,
                              66,
                              113,
                            ).withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'assets/logo.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 24,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.name.isNotEmpty
                                ? user.name
                                : 'Welcome to AUVI',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 44, 66, 113),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      44,
                      66,
                      113,
                    ).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        44,
                        66,
                        113,
                      ).withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.health_and_safety,
                        color: const Color.fromARGB(255, 44, 66, 113),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Monitor your health with precision and care',
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color.fromARGB(255, 44, 66, 113),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              'Health Monitoring',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 44, 66, 113),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, AppRoutes.heartRate);
                _loadMeasurementHistory();
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 255, 245, 248),
                      Color.fromARGB(255, 255, 235, 245),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 200, 220),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        220,
                        53,
                        69,
                      ).withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 220, 53, 69),
                            Color.fromARGB(255, 255, 80, 100),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              220,
                              53,
                              69,
                            ).withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Heart Rate Monitor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 44, 66, 113),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Measure your heart rate using camera',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                255,
                                220,
                                53,
                                69,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Tap to start',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 220, 53, 69),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color.fromARGB(255, 44, 66, 113),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, AppRoutes.bpMeasurement);
                _loadMeasurementHistory();
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 240, 255, 248),
                      Color.fromARGB(255, 230, 255, 240),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color.fromARGB(255, 180, 255, 200),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        255,
                        25,
                        135,
                        84,
                      ).withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 25, 135, 84),
                            Color.fromARGB(255, 40, 160, 100),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              25,
                              135,
                              84,
                            ).withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bloodtype,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Blood Pressure Monitor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 44, 66, 113),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Measure blood pressure using camera',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                255,
                                25,
                                135,
                                84,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Tap to start',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 25, 135, 84),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Color.fromARGB(255, 44, 66, 113),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 250, 252, 255),
                  Color.fromARGB(255, 245, 250, 255),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color.fromARGB(255, 200, 220, 250),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    44,
                    66,
                    113,
                  ).withOpacity(0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      ),
                      child: const Icon(
                        Icons.tips_and_updates,
                        color: Color.fromARGB(255, 44, 66, 113),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Health Tip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 44, 66, 113),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Regular monitoring of your heart rate and blood pressure helps in early detection of health issues. Take measurements at the same time each day for consistent results.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    final user = UserProfile.instance;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 248, 250, 255),
                  Color.fromARGB(255, 240, 245, 255),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color.fromARGB(255, 220, 230, 250),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(
                    255,
                    44,
                    66,
                    113,
                  ).withOpacity(0.06),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  offset: const Offset(0, -2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 230, 240, 255),
                        Color.fromARGB(255, 220, 235, 255),
                      ],
                    ),
                    border: Border.all(
                      color: const Color.fromARGB(
                        255,
                        44,
                        66,
                        113,
                      ).withOpacity(0.2),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          255,
                          44,
                          66,
                          113,
                        ).withOpacity(0.1),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child:
                        user.profilePicture != null
                            ? Image.file(
                              File(user.profilePicture!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _getDefaultAvatar(user.sex);
                              },
                            )
                            : _getDefaultAvatar(user.sex),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  user.name.isNotEmpty ? user.name : 'Complete Your Profile',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 44, 66, 113),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        user.name.isNotEmpty &&
                                user.age.isNotEmpty &&
                                user.dob.isNotEmpty
                            ? const Color.fromARGB(
                              255,
                              25,
                              135,
                              84,
                            ).withOpacity(0.1)
                            : const Color.fromARGB(
                              255,
                              255,
                              193,
                              7,
                            ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          user.name.isNotEmpty &&
                                  user.age.isNotEmpty &&
                                  user.dob.isNotEmpty
                              ? const Color.fromARGB(
                                255,
                                25,
                                135,
                                84,
                              ).withOpacity(0.3)
                              : const Color.fromARGB(
                                255,
                                255,
                                193,
                                7,
                              ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.name.isNotEmpty &&
                                user.age.isNotEmpty &&
                                user.dob.isNotEmpty
                            ? Icons.check_circle
                            : Icons.info_outline,
                        size: 14,
                        color:
                            user.name.isNotEmpty &&
                                    user.age.isNotEmpty &&
                                    user.dob.isNotEmpty
                                ? const Color.fromARGB(255, 25, 135, 84)
                                : const Color.fromARGB(255, 255, 193, 7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.name.isNotEmpty &&
                                user.age.isNotEmpty &&
                                user.dob.isNotEmpty
                            ? 'Profile Complete'
                            : 'Profile Incomplete',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              user.name.isNotEmpty &&
                                      user.age.isNotEmpty &&
                                      user.dob.isNotEmpty
                                  ? const Color.fromARGB(255, 25, 135, 84)
                                  : const Color.fromARGB(255, 255, 193, 7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color.fromARGB(255, 230, 235, 250),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(
                          255,
                          44,
                          66,
                          113,
                        ).withOpacity(0.05),
                        const Color.fromARGB(
                          255,
                          44,
                          66,
                          113,
                        ).withOpacity(0.02),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(
                            255,
                            44,
                            66,
                            113,
                          ).withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 44, 66, 113),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 44, 66, 113),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildModernProfileRow(
                        Icons.badge,
                        'Full Name',
                        user.name,
                      ),
                      _buildModernProfileRow(Icons.cake, 'Age', user.age),
                      _buildModernProfileRow(
                        Icons.calendar_today,
                        'Date of Birth',
                        user.dob,
                      ),
                      _buildModernProfileRow(Icons.wc, 'Gender', user.sex),
                      _buildModernProfileRow(Icons.phone, 'Phone', user.phone),
                      _buildModernProfileRow(
                        Icons.location_on,
                        'Pincode',
                        user.pincode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color.fromARGB(255, 230, 235, 250),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(
                          255,
                          25,
                          135,
                          84,
                        ).withOpacity(0.05),
                        const Color.fromARGB(
                          255,
                          25,
                          135,
                          84,
                        ).withOpacity(0.02),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(
                            255,
                            25,
                            135,
                            84,
                          ).withOpacity(0.1),
                        ),
                        child: const Icon(
                          Icons.health_and_safety,
                          color: Color.fromARGB(255, 25, 135, 84),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Health Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 44, 66, 113),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildEnhancedHealthInfo(user),
                ),
              ],
            ),
          ),

          if (user.name.isEmpty || user.dob.isEmpty || user.age.isEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 248, 220),
                    Color.fromARGB(255, 255, 252, 235),
                  ],
                ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color.fromARGB(
                            255,
                            255,
                            193,
                            7,
                          ).withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.warning_amber,
                          color: Color.fromARGB(255, 184, 134, 11),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Complete Your Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 184, 134, 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please complete your profile to access all health monitoring features. Your age and personal information are essential for accurate health calculations and personalized recommendations.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
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
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 44, 66, 113),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 4,
                      shadowColor: const Color.fromARGB(
                        255,
                        44,
                        66,
                        113,
                      ).withOpacity(0.3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Color.fromARGB(255, 220, 53, 69),
                      size: 18,
                    ),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 220, 53, 69),
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 220, 53, 69),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDefaultAvatar(String sex) {
    if (sex.toLowerCase() == 'male') {
      return Image.asset(
        'assets/profile_male.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 44, 66, 113),
                  Color.fromARGB(255, 70, 90, 140),
                ],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          );
        },
      );
    } else if (sex.toLowerCase() == 'female') {
      return Image.asset(
        'assets/profile_female.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 220, 53, 69),
                  Color.fromARGB(255, 255, 80, 100),
                ],
              ),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 40),
          );
        },
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 44, 66, 113),
              Color.fromARGB(255, 70, 90, 140),
            ],
          ),
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 40),
      );
    }
  }

  Widget _buildModernProfileRow(IconData icon, String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 250, 255),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 230, 235, 250),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(255, 44, 66, 113).withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 44, 66, 113),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value?.isNotEmpty == true ? value! : 'Not provided',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        value?.isNotEmpty == true
                            ? const Color.fromARGB(255, 44, 66, 113)
                            : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHealthInfo(UserProfile user) {
    if (user.age.isEmpty || user.dob.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 248, 250, 255),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 230, 235, 250),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Health Information Unavailable',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your profile to view personalized health ranges',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final healthService = HealthDataService.instance;
    final age = healthService.calculateAge(user.dob);
    final bpRange = healthService.getFormattedBloodPressureRange(age);
    final hrRange = healthService.getFormattedHeartRateRange(age);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 240, 255, 248),
                Color.fromARGB(255, 250, 255, 252),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromARGB(255, 25, 135, 84).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(
                    255,
                    25,
                    135,
                    84,
                  ).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.bloodtype,
                  color: Color.fromARGB(255, 25, 135, 84),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Normal Blood Pressure',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 44, 66, 113),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bpRange,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 25, 135, 84),
                      ),
                    ),
                    const Text(
                      'mmHg (Systolic/Diastolic)',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 245, 248),
                Color.fromARGB(255, 255, 250, 252),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromARGB(255, 220, 53, 69).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(
                    255,
                    220,
                    53,
                    69,
                  ).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Color.fromARGB(255, 220, 53, 69),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Normal Heart Rate',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 44, 66, 113),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hrRange,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 220, 53, 69),
                      ),
                    ),
                    const Text(
                      'BPM (Beats per minute)',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 44, 66, 113).withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
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
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Based on your age: $age years',
                style: const TextStyle(
                  color: Color.fromARGB(255, 44, 66, 113),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryContent() {
    if (_isLoadingHistory) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromARGB(255, 44, 66, 113),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Loading measurement history...',
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 44, 66, 113),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_measurementGroups.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8EAFE), Color(0xFFD6E0FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                offset: const Offset(-4, -4),
                blurRadius: 10,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color.fromARGB(255, 5, 5, 167).withOpacity(0.12),
                offset: const Offset(4, 4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_rounded,
                size: 48,
                color: Color.fromARGB(255, 44, 66, 113),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Measurements Yet',
                style: TextStyle(
                  fontSize: 22,
                  color: Color.fromARGB(255, 44, 66, 113),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Start taking measurements to see your health history here.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0; // Switch to Home tab
                  });
                },
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Take Measurement',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 1, 25, 59),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadMeasurementHistory();
      },
      color: Color.fromARGB(255, 44, 66, 113),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8EAFE), Color(0xFFD6E0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
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
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 44, 66, 113).withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: Color.fromARGB(255, 44, 66, 113),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUVI Health History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 44, 66, 113),
                          ),
                        ),
                        Text(
                          '${_measurementGroups.fold<int>(0, (sum, group) => sum + group.measurements.length)} total measurements',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            ..._measurementGroups
                .map((group) => _buildMeasurementGroup(group))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementGroup(MeasurementGroup group) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 44, 66, 113).withOpacity(0.1),
                  Color.fromARGB(255, 44, 66, 113).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Color.fromARGB(255, 44, 66, 113),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  group.dateString,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 44, 66, 113),
                  ),
                ),
                Spacer(),
                Text(
                  '${group.measurements.length} measurement${group.measurements.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          ...group.measurements
              .map((measurement) => _buildMeasurementItem(measurement))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildMeasurementItem(MeasurementRecord measurement) {
    final isHeartRate = measurement.type == MeasurementType.heartRate;
    final icon = isHeartRate ? Icons.favorite : Icons.monitor_heart;
    final color =
        measurement.isNormal == true
            ? Colors.green
            : measurement.isNormal == false
            ? Colors.orange
            : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      measurement.typeDisplayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 44, 66, 113),
                      ),
                    ),
                    Spacer(),
                    Text(
                      measurement.displayValue,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${measurement.timestamp.hour.toString().padLeft(2, '0')}:${measurement.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        measurement.statusText,
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentPageContent() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildProfileContent();
      case 2:
        return _buildHistoryContent();
      default:
        return _buildHomeContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return WillPopScope(
      onWillPop: () async {
        _showExitConfirmation();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 215, 223, 247),
        body: Stack(
          children: [
            ModernWavyAppBar(
              height: 300,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Color.fromARGB(255, 245, 248, 255),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(17.5),
                                  child: Image.asset(
                                    'assets/logo.jpg',
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.favorite,
                                        color: Color.fromARGB(255, 44, 66, 113),
                                        size: 20,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'AUVI',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  Text(
                                    'Health Monitor',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _currentIndex == 0
                                      ? Icons.home_rounded
                                      : _currentIndex == 1
                                      ? Icons.person_rounded
                                      : Icons.history_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _currentIndex == 0
                                      ? 'Home'
                                      : _currentIndex == 1
                                      ? 'Profile'
                                      : 'History',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 120),
              child: _getCurrentPageContent(),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 85, // Slightly increased for better visual balance
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 248, 250, 255),
                Color.fromARGB(255, 240, 245, 255),
              ],
            ),
            border: const Border(
              top: BorderSide(
                color: Color.fromARGB(255, 200, 210, 230),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 44, 66, 113).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, -1),
                spreadRadius: 1,
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedFontSize: 13, // Optimized font size
            unselectedFontSize: 11,
            iconSize: 20,
            landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              height: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              height: 1.2,
            ),
            selectedItemColor: const Color.fromARGB(255, 44, 66, 113),
            unselectedItemColor: const Color.fromARGB(255, 120, 130, 150),
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCircleIcon(Icons.home_rounded, _currentIndex == 0),
                      if (_currentIndex == 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 44, 66, 113),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  44,
                                  66,
                                  113,
                                ).withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCircleIcon(
                        Icons.person_rounded,
                        _currentIndex == 1,
                      ),
                      if (_currentIndex == 1)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 44, 66, 113),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  44,
                                  66,
                                  113,
                                ).withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCircleIcon(
                        Icons.history_rounded,
                        _currentIndex == 2,
                      ),
                      if (_currentIndex == 2)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 44, 66, 113),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  44,
                                  66,
                                  113,
                                ).withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                label: 'History',
              ),
            ],
          ),
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

  void _logout() async {
    UserProfile.instance.clear();
    final localStorage = LocalStorageService();
    await localStorage.clearUserInfo();

    try {
      await FirebaseAuth.instance.signOut();
      await GoogleAuthService().signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 1, 25, 59),
                      Color.fromARGB(255, 1, 29, 48),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Exit AUVI',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 44, 66, 113),
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to exit the app?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Stay in App',
                style: TextStyle(color: Color.fromARGB(255, 108, 117, 125)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 220, 53, 69),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Exit App',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
