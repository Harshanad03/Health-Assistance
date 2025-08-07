import 'package:flutter/material.dart';
import 'create_account_page.dart';
import 'signup_page.dart' as signup; // Import for ModernWavyAppBar with prefix

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _pincodeController;
  String? _sex;

  @override
  void initState() {
    super.initState();
    final user = UserProfile.instance;
    _nameController = TextEditingController(text: user.name ?? '');
    _ageController = TextEditingController(text: user.age ?? '');
    _dobController = TextEditingController(text: user.dob ?? '');
    _phoneController = TextEditingController(text: user.phone ?? '');
    _pincodeController = TextEditingController(text: user.pincode ?? '');
    _sex = user.sex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(_dobController.text) ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 1, 25, 59),
              onPrimary: Colors.white,
              onSurface: Color.fromARGB(255, 44, 66, 113),
              surface: Color(0xFFE8EAFE),
              secondary: Color.fromARGB(255, 1, 29, 48),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 1, 25, 59),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {});
    }
  }

  void _saveProfile() {
    UserProfile.instance.update(
      name: _nameController.text,
      age: _ageController.text,
      dob: _dobController.text,
      sex: _sex,
      phone: _phoneController.text,
      pincode: _pincodeController.text,
    );
    Navigator.pop(context); // Go back to ProfilePage
  }

  Widget _neumorphicField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
                color: const Color.fromARGB(255, 5, 5, 167).withOpacity(0.4),
                offset: const Offset(4, 4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 18,
              ),
              fillColor: Colors.transparent,
              filled: true,
              suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: Stack(
        children: [
          signup.ModernWavyAppBar(
            height: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const SizedBox(height: 48)],
            ),
          ),
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Update your profile details',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 44, 66, 113),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(
                  top: 220,
                  left: 0,
                  right: 0,
                  bottom: 0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 32,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 215, 223, 247),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _neumorphicField(
                      label: 'Name',
                      controller: _nameController,
                      hint: 'Enter your name',
                    ),
                    const SizedBox(height: 18),
                    _neumorphicField(
                      label: 'Age',
                      controller: _ageController,
                      hint: 'Enter your age',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),
                    _neumorphicField(
                      label: 'Date of Birth',
                      controller: _dobController,
                      hint: 'YYYY-MM-DD',
                      readOnly: true,
                      onTap: _pickDate,
                      suffixIcon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Sex',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
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
                            ).withOpacity(0.4),
                            offset: const Offset(4, 4),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _sex,
                          hint: const Text('Select sex'),
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(24),
                          items: const [
                            DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male'),
                            ),
                            DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female'),
                            ),
                            DropdownMenuItem(
                              value: 'Other',
                              child: Text('Other'),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _sex = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _neumorphicField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 18),
                    _neumorphicField(
                      label: 'Pincode',
                      controller: _pincodeController,
                      hint: 'Enter your pincode',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: _saveProfile,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 1, 25, 59),
                                Color.fromARGB(255, 1, 29, 48),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.check_circle_outline,
                                size: 22,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
