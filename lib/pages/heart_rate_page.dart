import 'package:flutter/material.dart';
import 'dart:async';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_light/torch_light.dart';
import '../widgets/modern_wavy_app_bar.dart';
import '../utils/routes.dart';
import '../models/user_profile.dart';

class HeartRatePage extends StatefulWidget {
  const HeartRatePage({super.key});

  @override
  State<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {
  List<SensorValue> data = [];
  int? bpmValue;
  int? finalBpm;
  bool isMeasuring = false;
  Timer? timer;
  int secondsLeft = 30;
  List<int> bpmValues = [];
  String statusMessage = 'Ready to measure your heart rate';

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

  Future<bool> _ensureCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied || status.isRestricted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  void startMeasurement() async {
    bool granted = await _ensureCameraPermission();
    if (!granted) {
      setState(() {
        statusMessage =
            'Camera permission required. Please enable in settings.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Turn on flash
    try {
      await TorchLight.enableTorch();
    } catch (e) {
      print('Error turning on flash: $e');
    }

    setState(() {
      isMeasuring = true;
      secondsLeft = 30;
      bpmValues.clear();
      finalBpm = null;
      statusMessage = 'Place your finger over camera and flash. Keep still!';
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        secondsLeft--;
        if (secondsLeft <= 0) {
          stopMeasurement();
        }
      });
    });
  }

  void stopMeasurement() async {
    timer?.cancel();

    // Turn off flash
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      print('Error turning off flash: $e');
    }

    setState(() {
      isMeasuring = false;
      if (bpmValues.isNotEmpty) {
        finalBpm = (bpmValues.reduce((a, b) => a + b) / bpmValues.length)
            .round();
        statusMessage =
            'Measurement complete! Your average heart rate: $finalBpm BPM';
      } else {
        statusMessage = 'No valid readings. Please try again.';
      }
    });
  }

  void resetMeasurement() async {
    // Turn off flash if it's on
    try {
      await TorchLight.disableTorch();
    } catch (e) {
      print('Error turning off flash: $e');
    }

    setState(() {
      isMeasuring = false;
      finalBpm = null;
      bpmValue = null;
      bpmValues.clear();
      data.clear();
      statusMessage = 'Ready to measure your heart rate';
    });
    timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: Column(
        children: [
          // Modern Wavy App Bar
          ModernWavyAppBar(
            height: 140,
            onBack: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.home),
            child: Center(
              child: Text(
                'Heart Rate Monitor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Status Message Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
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
                    child: Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 44, 66, 113),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Heart Icon and BPM Display Card
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8EAFE), Color(0xFFD6E0FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          offset: const Offset(-6, -6),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: const Color.fromARGB(
                            255,
                            5,
                            5,
                            167,
                          ).withOpacity(0.15),
                          offset: const Offset(6, 6),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 80, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          isMeasuring
                              ? '${bpmValue ?? '--'}'
                              : '${finalBpm ?? '--'}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isMeasuring
                                ? const Color.fromARGB(255, 220, 53, 69)
                                : const Color.fromARGB(255, 44, 66, 113),
                          ),
                        ),
                        const Text(
                          'BPM',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 44, 66, 113),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Timer Display
                  if (isMeasuring)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE8EAFE), Color(0xFFD6E0FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            offset: const Offset(-2, -2),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: const Color.fromARGB(
                              255,
                              5,
                              5,
                              167,
                            ).withOpacity(0.10),
                            offset: const Offset(2, 2),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 20,
                            color: const Color.fromARGB(255, 44, 66, 113),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${secondsLeft}s remaining',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 44, 66, 113),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Heart Rate Dialog (only when measuring)
                  if (isMeasuring)
                    HeartBPMDialog(
                      context: context,
                      showTextValues: true,
                      onRawData: (value) {
                        setState(() {
                          if (data.length >= 100) data.removeAt(0);
                          data.add(value);
                        });
                      },
                      onBPM: (value) {
                        setState(() {
                          bpmValue = value;
                          if (value > 0) {
                            bpmValues.add(value);
                          }
                        });
                      },
                    ),

                  const SizedBox(height: 40),

                  // Control Buttons
                  Column(
                    children: [
                      // Main Action Button (Start/Stop)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isMeasuring
                              ? stopMeasurement
                              : startMeasurement,
                          icon: Icon(
                            isMeasuring ? Icons.stop : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                          label: Text(
                            isMeasuring
                                ? 'Stop Measurement'
                                : 'Start Measurement',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isMeasuring
                                ? const Color.fromARGB(255, 220, 53, 69)
                                : const Color.fromARGB(255, 1, 25, 59),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                            shadowColor:
                                (isMeasuring
                                        ? const Color.fromARGB(255, 220, 53, 69)
                                        : const Color.fromARGB(255, 1, 25, 59))
                                    .withOpacity(0.3),
                          ),
                        ),
                      ),

                      // Reset Button (only when not measuring and has result)
                      if (!isMeasuring && finalBpm != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: resetMeasurement,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Reset',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                108,
                                117,
                                125,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 4,
                              shadowColor: const Color.fromARGB(
                                255,
                                108,
                                117,
                                125,
                              ).withOpacity(0.3),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Instructions Card
                  Container(
                    padding: const EdgeInsets.all(24),
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
                                  44,
                                  66,
                                  113,
                                ).withOpacity(0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.8),
                                    offset: const Offset(-2, -2),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: const Color.fromARGB(
                                      255,
                                      5,
                                      5,
                                      167,
                                    ).withOpacity(0.10),
                                    offset: const Offset(2, 2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.info_outline,
                                color: Color.fromARGB(255, 44, 66, 113),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Instructions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 44, 66, 113),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '1. Cover the camera lens and flash with your fingertip\n'
                          '2. Keep your finger steady and still\n'
                          '3. Ensure good lighting\n'
                          '4. Wait for 30 seconds for accurate reading',
                          style: TextStyle(
                            color: Color.fromARGB(255, 44, 66, 113),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Disclaimer
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
                          Icons.warning_amber_rounded,
                          color: Color.fromARGB(255, 255, 193, 7),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This is not a medical device. For medical purposes, consult a healthcare professional.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
