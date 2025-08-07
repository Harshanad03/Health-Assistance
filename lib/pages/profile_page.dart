import 'package:flutter/material.dart';
import 'create_account_page.dart';
import 'edit_profile_page.dart';
import 'signup_page.dart' as signup; // For ModernWavyAppBar

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = UserProfile.instance;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: Stack(
        children: [
          signup.ModernWavyAppBar(
            height: 140,
            child: Center(
              child: Padding(padding: const EdgeInsets.only(top: 40.0)),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
              child: Container(
                width: 370,
                margin: const EdgeInsets.only(
                  top: 120,
                  bottom: 32,
                  left: 16,
                  right: 16,
                ),
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
                    // Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD6E0FF),
                        image: (user.sex?.toLowerCase() == 'male')
                            ? const DecorationImage(
                                image: AssetImage('assert/profile_male.jpg'),
                                fit: BoxFit.cover,
                              )
                            : const DecorationImage(
                                image: AssetImage('assert/profile_female.jpg'),
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
                    // Edit Button inside container
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
                          backgroundColor: const Color.fromARGB(255, 1, 25, 59),
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
                  ],
                ),
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
              Navigator.pushReplacementNamed(context, '/home');
            } else if (index == 1) {
              // Already on profile
            } else if (index == 2) {
              // If you have a Document page, navigate to it
              // Navigator.pushReplacementNamed(context, '/document');
            }
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
}
