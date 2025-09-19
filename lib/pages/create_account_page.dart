import 'package:flutter/material.dart';
import '../utils/routes.dart';
import '../widgets/modern_wavy_app_bar.dart';
import '../models/user_profile.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() {
    print('=== CREATING CREATE ACCOUNT PAGE ===');
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  String? _sex;
  bool _isButtonEnabled = false;

  void _validateFields() {
    setState(() {
      _isButtonEnabled =
          _nameController.text.isNotEmpty &&
          _ageController.text.isNotEmpty &&
          _dobController.text.isNotEmpty &&
          _sex != null &&
          _phoneController.text.isNotEmpty &&
          _pincodeController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateFields);
    _ageController.addListener(_validateFields);
    _dobController.addListener(_validateFields);
    _phoneController.addListener(_validateFields);
    _pincodeController.addListener(_validateFields);
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
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromARGB(255, 1, 25, 59), // header background
              onPrimary: Colors.white, // header text color
              onSurface: Color.fromARGB(255, 44, 66, 113), // body text color
              surface: Color(0xFFE8EAFE), // dialog background
              secondary: Color.fromARGB(255, 1, 29, 48), // accent color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(
                  255,
                  1,
                  25,
                  59,
                ), // button text color
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
    }
  }

  @override
  Widget build(BuildContext context) {
    print('=== BUILDING CREATE ACCOUNT PAGE ===');
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: Stack(
        children: [
          ModernWavyAppBar(
            height: 140,
            onBack:
                () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                ),
            child: Stack(children: [const SizedBox(height: 48)]),
          ),

          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Enter Profile Details',
                style: TextStyle(
                  fontSize: 22,
                  color: Color.fromARGB(255, 44, 66, 113),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(
                  top: 200, // increased space for appbar + title
                  left: 0,
                  right: 0,
                  bottom: 0,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
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
                            _validateFields();
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
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () {
                          UserProfile.instance.update(
                            name: _nameController.text,
                            age: _ageController.text,
                            dob: _dobController.text,
                            sex: _sex,
                            phone: _phoneController.text,
                            pincode: _pincodeController.text,
                          );
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.profile,
                            (route) => false,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      _isButtonEnabled
                                          ? Colors.white
                                          : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 22,
                                color:
                                    _isButtonEnabled
                                        ? Colors.white
                                        : Colors.grey,
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
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(secondary: Colors.transparent),
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
        ),
      ],
    );
  }
}
