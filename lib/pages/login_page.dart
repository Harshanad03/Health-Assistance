import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/routes.dart';
import '../services/local_storage_service.dart';
import '../widgets/modern_wavy_app_bar.dart';
import '../services/google_auth_service.dart';
import '../services/firebase_auth_service.dart';
import '../models/user_profile.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isButtonEnabled = false;
  bool _isEmailValid = true;
  String _emailError = '';
  bool _isLoading = false;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  void _validateFields() {
    setState(() {
      _isButtonEnabled =
          _emailController.text.isNotEmpty &&
          _passwordController.text.length >= 8 &&
          _isEmailValid;
    });
  }

  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _isEmailValid = true;
        _emailError = '';
      } else {
        final trimmedEmail = email.trim();
        if (_isValidEmailFormat(trimmedEmail)) {
          _isEmailValid = true;
          _emailError = '';
        } else {
          _isEmailValid = false;
          _emailError = 'Please enter a valid email address';
        }
      }
      _validateFields();
    });
  }

  Future<void> _handleLogin() async {
    if (!_isButtonEnabled || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _firebaseAuthService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (result.isSuccess && result.user != null) {
        UserProfile.instance.clear();

        final localStorage = LocalStorageService();
        await localStorage.saveUserInfo(result.user!.email ?? '');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome back ${result.user!.displayName ?? result.user!.email}!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.main,
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidEmailFormat(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      _validateEmail(_emailController.text);
    });
    _passwordController.addListener(_validateFields);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: Stack(
        children: [
          ModernWavyAppBar(
            height: 140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const SizedBox(height: 48)],
            ),
          ),

          Positioned(
            top: 170,
            left: 0,
            right: 0,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Welcome back! Please sign in to continue.',
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
                  top: 70,
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

                    const Text(
                      'Your email address',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              _isEmailValid || _emailController.text.isEmpty
                                  ? [
                                    const Color(0xFFE8EAFE),
                                    const Color(0xFFD6E0FF),
                                  ]
                                  : [
                                    const Color(0xFFFFE8E8),
                                    const Color(0xFFFFD6D6),
                                  ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border:
                            _isEmailValid || _emailController.text.isEmpty
                                ? null
                                : Border.all(
                                  color: Colors.red.withOpacity(0.6),
                                  width: 2,
                                ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: const Offset(-4, -4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color:
                                _isEmailValid || _emailController.text.isEmpty
                                    ? Color.fromARGB(
                                      255,
                                      5,
                                      5,
                                      167,
                                    ).withOpacity(0.4)
                                    : Colors.red.withOpacity(0.3),
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
                        child: Focus(
                          onFocusChange: (hasFocus) {},
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  _isEmailValid || _emailController.text.isEmpty
                                      ? Colors.black87
                                      : Colors.red.shade700,
                            ),
                            decoration: InputDecoration(
                              hintText: 'test@gmail.com',
                              hintStyle: TextStyle(
                                color:
                                    _isEmailValid ||
                                            _emailController.text.isEmpty
                                        ? Colors.grey.shade500
                                        : Colors.red.shade300,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 18,
                              ),
                              fillColor: Colors.transparent,
                              filled: true,
                              suffixIcon:
                                  _emailController.text.isNotEmpty
                                      ? Icon(
                                        _isEmailValid
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color:
                                            _isEmailValid
                                                ? Colors.green
                                                : Colors.red,
                                        size: 20,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (_emailError.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 18),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _emailError,
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),

                    const Text(
                      'Password',
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
                            color: Color.fromARGB(
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
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 18,
                            ),
                            fillColor: Colors.transparent,
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap:
                            _isButtonEnabled && !_isLoading
                                ? _handleLogin
                                : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  _isButtonEnabled && !_isLoading
                                      ? [
                                        const Color.fromARGB(255, 1, 25, 59),
                                        const Color.fromARGB(255, 1, 29, 48),
                                      ]
                                      : [
                                        Colors.grey.shade400,
                                        Colors.grey.shade500,
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
                              if (_isLoading)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              else ...[
                                Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.forgetPassword,
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Color.fromARGB(255, 1, 25, 59),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap:
                            _isLoading
                                ? null
                                : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final googleAuthService =
                                        GoogleAuthService();
                                    final result =
                                        await googleAuthService
                                            .signInWithGoogle();

                                    if (result != null && result.user != null) {
                                      UserProfile.instance.clear();

                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Welcome back ${result.user!.displayName ?? result.user!.email}!',
                                            ),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );

                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          AppRoutes.main,
                                          (route) => false,
                                        );
                                      }
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Google Sign-In failed. Please try again.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Google Sign-In not available. Please configure Firebase first.',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isLoading)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey.shade600,
                                    ),
                                  ),
                                )
                              else ...[
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Image.asset(
                                    'assets/google_logo.png',
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.signup);
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
