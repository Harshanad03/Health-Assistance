import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../widgets/modern_wavy_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = UserProfile.instance;
    _nameController = TextEditingController(text: user.name ?? '');
    _ageController = TextEditingController(text: user.age ?? '');
    _dobController = TextEditingController(text: user.dob ?? '');
    _phoneController = TextEditingController(text: user.phone ?? '');
    _pincodeController = TextEditingController(text: user.pincode ?? '');
    // Ensure the sex value matches exactly one of the dropdown options
    _sex = _validateSexValue(user.sex);
  }

  String? _validateSexValue(String? sex) {
    if (sex == null) return null;
    // Convert to proper case and check if it matches dropdown options
    final validOptions = ['Male', 'Female', 'Other'];
    final normalizedSex = sex.trim();

    // Check for exact match first
    if (validOptions.contains(normalizedSex)) {
      return normalizedSex;
    }

    // Check for case-insensitive match
    for (final option in validOptions) {
      if (option.toLowerCase() == normalizedSex.toLowerCase()) {
        return option; // Return the properly cased option
      }
    }

    // If no match found, return null (will show hint text)
    return null;
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    // Check if image picker is available
    try {
      // Test if the plugin is available by checking if we can create an instance
      if (_picker != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: const Color.fromARGB(255, 215, 223, 247),
              title: const Text(
                'Choose Profile Picture',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color.fromARGB(255, 44, 66, 113),
                ),
              ),
              content: const Text(
                'Select where you want to pick your profile picture from',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                  child: const Text(
                    'Gallery',
                    style: TextStyle(
                      color: Color.fromARGB(255, 44, 66, 113),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 1, 25, 59),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    shadowColor: const Color.fromARGB(
                      255,
                      1,
                      25,
                      59,
                    ).withOpacity(0.3),
                  ),
                  child: const Text(
                    'Camera',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Image picker not initialized');
      }
    } catch (e) {
      // Show error if image picker is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Image picker not available: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _saveProfile() {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Name is required');
      return;
    }

    if (_ageController.text.trim().isEmpty) {
      _showErrorDialog('Age is required');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showErrorDialog('Phone number is required');
      return;
    }

    if (_pincodeController.text.trim().isEmpty) {
      _showErrorDialog('Pincode is required');
      return;
    }

    // Save the profile
    UserProfile.instance.update(
      name: _nameController.text.trim(),
      age: _ageController.text.trim(),
      dob: _dobController.text.trim(),
      sex: _sex,
      phone: _phoneController.text.trim(),
      pincode: _pincodeController.text.trim(),
      profilePicture: _selectedImage?.path,
    );

    // Show success message and go back
    _showSuccessDialog();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: const Color.fromARGB(255, 215, 223, 247),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 220, 53, 69),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Validation Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color.fromARGB(255, 44, 66, 113),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color.fromARGB(255, 108, 117, 125),
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 220, 53, 69),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                shadowColor: const Color.fromARGB(
                  255,
                  220,
                  53,
                  69,
                ).withOpacity(0.3),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Success!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 1, 25, 59),
            ),
          ),
          content: const Text('Profile updated successfully!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // Go back to ProfilePage
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 1, 25, 59),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 18,
                ),
                fillColor: Colors.transparent,
                filled: true,
                suffixIcon: suffixIcon != null
                    ? Icon(
                        suffixIcon,
                        color: const Color.fromARGB(255, 44, 66, 113),
                        size: 20,
                      )
                    : null,
              ),
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
      body: Column(
        children: [
          // Fixed App Bar
          ModernWavyAppBar(
            height: 140,
            onBack: () => Navigator.pop(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const SizedBox(height: 48)],
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Title
                  Padding(
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
                  const SizedBox(height: 24),
                  // Form Container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 215, 223, 247),
                      borderRadius: BorderRadius.circular(36),
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
                        // Profile Picture Section
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _showImagePickerDialog,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFD6E0FF),
                                        image: _selectedImage != null
                                            ? DecorationImage(
                                                image: FileImage(
                                                  _selectedImage!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : (UserProfile.instance.sex
                                                      ?.toLowerCase() ==
                                                  'male')
                                            ? const DecorationImage(
                                                image: AssetImage(
                                                  'assert/profile_male.jpg',
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : const DecorationImage(
                                                image: AssetImage(
                                                  'assert/profile_female.jpg',
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            1,
                                            25,
                                            59,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to change profile picture',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(
                                    255,
                                    44,
                                    66,
                                    113,
                                  ).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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
                                    Icons.arrow_forward_rounded,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
