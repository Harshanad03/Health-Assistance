import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/routes.dart';
import '../widgets/modern_wavy_app_bar.dart';
import '../models/user_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  void _checkProfileCompletion() {
    final user = UserProfile.instance;
    // Check if essential profile fields are filled
    if (user.name.isEmpty || user.dob.isEmpty || user.age.isEmpty) {
      // Redirect to profile page if profile is incomplete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
      });
    }
  }

  Widget _buildNeumorphicCard(String title, IconData icon, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
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
          Icon(icon, size: 48, color: Color.fromARGB(255, 44, 66, 113)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              color: Color.fromARGB(255, 44, 66, 113),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper to build a neumorphic circle icon
  Widget _buildCircleIcon(IconData icon, bool selected) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFFE8EAFE) : const Color(0xFFD6E0FF),
        border: selected
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
        color: selected
            ? const Color.fromARGB(255, 44, 66, 113)
            : Colors.black38,
        size: 20,
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        // Home tab: show two image boxes stacked vertically in a column, reduced width
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.heartRate);
                  },
                  child: Container(
                    width: 380,
                    margin: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(16),
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
                        AspectRatio(
                          aspectRatio: 1.9,
                          child: Image.asset(
                            'assert/module1.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Check Heart Rate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 44, 66, 113),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to measure',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.bpMeasurement);
                  },
                  child: Container(
                    width: 380,
                    margin: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(16),
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
                        AspectRatio(
                          aspectRatio: 1.9,
                          child: Image.asset(
                            'assert/module2.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Check BP Rate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 44, 66, 113),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap to measure',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 1:
        return _buildNeumorphicCard(
          'Your Profile',
          Icons.person_rounded,
          'View and edit your profile details.',
        );
      case 2:
        return _buildNeumorphicCard(
          'Your Documents',
          Icons.description_rounded,
          'Access your important documents here.',
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to light mode for white text
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 215, 223, 247),
        body: Stack(
          children: [
            ModernWavyAppBar(
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [const SizedBox(height: 68)],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: _buildPage(0), // Always show Home tab content
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
            currentIndex: 0, // Home tab selected
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              } else if (index == 1) {
                Navigator.pushReplacementNamed(context, AppRoutes.profile);
              } else if (index == 2) {
                // If you have a Document page, navigate to it
                // Navigator.pushReplacementNamed(context, AppRoutes.documents);
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _buildCircleIcon(Icons.home_rounded, true),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _buildCircleIcon(Icons.person_rounded, false),
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
      ),
    );
  }
}
