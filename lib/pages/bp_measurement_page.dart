import 'package:flutter/material.dart';
import 'dart:async';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_light/torch_light.dart';
import '../widgets/modern_wavy_app_bar.dart';
import '../utils/routes.dart';
import '../services/health_data_service.dart';
import '../models/user_profile.dart';

class BPMeasurementPage extends StatefulWidget {
  const BPMeasurementPage({super.key});

  @override
  State<BPMeasurementPage> createState() => _BPMeasurementPageState();
}

class _BPMeasurementPageState extends State<BPMeasurementPage> {
  List<SensorValue> data = [];
  int? bpmValue;
  int? finalBpm;
  bool isMeasuring = false;
  Timer? timer;
  int secondsLeft = 30;
  List<int> bpmValues = [];
  String statusMessage = 'Ready to measure your blood pressure';
  int? calculatedSystolic;
  int? calculatedDiastolic;

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

        // Calculate BP values based on age and heart rate
        _calculateBloodPressure();

        statusMessage =
            'Measurement complete! Your average heart rate: $finalBpm BPM';
      } else {
        statusMessage = 'No valid readings. Please try again.';
      }
    });
  }

  void _calculateBloodPressure() {
    final user = UserProfile.instance;
    final healthService = HealthDataService.instance;
    final age = healthService.calculateAge(user.dob);

    if (finalBpm != null && age > 0) {
      // Calculate systolic and diastolic based on age and heart rate
      // Using the data from your table, we'll estimate BP values
      calculatedSystolic = _estimateSystolic(age, finalBpm!);
      calculatedDiastolic = _estimateDiastolic(age, finalBpm!);
    } else {
      // If age is 0 (invalid DOB), use default values
      calculatedSystolic = 120;
      calculatedDiastolic = 80;
    }
  }

  int _estimateSystolic(int age, int heartRate) {
    // Base systolic calculation based on age and heart rate
    // Using patterns from your data table
    double baseSystolic = 120.0;

    // Age factor (systolic tends to increase with age)
    double ageFactor = (age - 30) * 0.8;

    // Heart rate factor (higher HR often correlates with higher systolic)
    double hrFactor = (heartRate - 70) * 0.3;

    int systolic = (baseSystolic + ageFactor + hrFactor).round();

    // Keep within reasonable bounds based on your data
    return systolic.clamp(100, 170);
  }

  int _estimateDiastolic(int age, int heartRate) {
    // Base diastolic calculation
    double baseDiastolic = 80.0;

    // Age factor (diastolic also increases with age but less than systolic)
    double ageFactor = (age - 30) * 0.4;

    // Heart rate factor (moderate correlation)
    double hrFactor = (heartRate - 70) * 0.2;

    int diastolic = (baseDiastolic + ageFactor + hrFactor).round();

    // Keep within reasonable bounds based on your data
    return diastolic.clamp(60, 100);
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
      calculatedSystolic = null;
      calculatedDiastolic = null;
      statusMessage = 'Ready to measure your blood pressure';
    });
    timer?.cancel();
  }

  Widget _buildHealthStatusComparison() {
    final user = UserProfile.instance;
    final healthService = HealthDataService.instance;
    final age = healthService.calculateAge(user.dob);

    // Use default age if calculation failed
    final validAge = age > 0 ? age : 30;

    final status = healthService.checkHealthStatus(
      validAge,
      finalBpm,
      calculatedSystolic,
      calculatedDiastolic,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8EAFE), Color(0xFFD6E0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-3, -3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color.fromARGB(255, 5, 5, 167).withOpacity(0.10),
            offset: const Offset(3, 3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
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
                  Icons.analytics,
                  color: Color.fromARGB(255, 44, 66, 113),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Health Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 44, 66, 113),
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Heart Rate Status
          Row(
            children: [
              Icon(
                status['heartRateNormal']! ? Icons.check_circle : Icons.warning,
                color: status['heartRateNormal']!
                    ? Colors.green
                    : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Heart Rate: ${status['heartRateNormal']! ? 'Normal' : 'Outside normal range'}',
                style: TextStyle(
                  color: status['heartRateNormal']!
                      ? Colors.green
                      : Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Blood Pressure Status
          Row(
            children: [
              Icon(
                status['systolicNormal']! && status['diastolicNormal']!
                    ? Icons.check_circle
                    : Icons.warning,
                color: status['systolicNormal']! && status['diastolicNormal']!
                    ? Colors.green
                    : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Blood Pressure: ${status['systolicNormal']! && status['diastolicNormal']! ? 'Normal' : 'Outside normal range'}',
                style: TextStyle(
                  color: status['systolicNormal']! && status['diastolicNormal']!
                      ? Colors.green
                      : Colors.orange,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Expected Ranges
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 44, 66, 113).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Expected for age $validAge:',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 44, 66, 113),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'HR: ${healthService.getFormattedHeartRateRange(validAge)} | BP: ${healthService.getFormattedBloodPressureRange(validAge)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color.fromARGB(255, 44, 66, 113),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 44, 66, 113),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                offset: const Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: const Color.fromARGB(255, 44, 66, 113).withOpacity(0.3),
                offset: const Offset(2, 2),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color.fromARGB(255, 44, 66, 113),
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.visible,
            softWrap: true,
          ),
        ),
      ],
    );
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
                'Blood Pressure Monitor',
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

                  // Status Message Card with Animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isMeasuring
                            ? [const Color(0xFFFFE8E8), const Color(0xFFFFD6D6)]
                            : [
                                const Color(0xFFE8EAFE),
                                const Color(0xFFD6E0FF),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          offset: const Offset(-6, -6),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: isMeasuring
                              ? const Color.fromARGB(
                                  255,
                                  220,
                                  53,
                                  69,
                                ).withOpacity(0.15)
                              : const Color.fromARGB(
                                  255,
                                  5,
                                  5,
                                  167,
                                ).withOpacity(0.12),
                          offset: const Offset(6, 6),
                          blurRadius: 20,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isMeasuring) ...[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 220, 53, 69),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                  255,
                                  220,
                                  53,
                                  69,
                                ).withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            statusMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: isMeasuring
                                  ? const Color.fromARGB(255, 220, 53, 69)
                                  : const Color.fromARGB(255, 44, 66, 113),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Heart Icon and BPM Display Card with Enhanced Animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isMeasuring
                            ? [const Color(0xFFFFE8E8), const Color(0xFFFFD6D6)]
                            : [
                                const Color(0xFFE8EAFE),
                                const Color(0xFFD6E0FF),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          offset: const Offset(-8, -8),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: isMeasuring
                              ? const Color.fromARGB(
                                  255,
                                  220,
                                  53,
                                  69,
                                ).withOpacity(0.2)
                              : const Color.fromARGB(
                                  255,
                                  5,
                                  5,
                                  167,
                                ).withOpacity(0.15),
                          offset: const Offset(8, 8),
                          blurRadius: 25,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Heart Icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.favorite,
                            size: isMeasuring ? 70 : 60,
                            color: isMeasuring
                                ? const Color.fromARGB(255, 220, 53, 69)
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // BPM Display with Animation
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: isMeasuring ? 32 : 28,
                            fontWeight: FontWeight.bold,
                            color: isMeasuring
                                ? const Color.fromARGB(255, 220, 53, 69)
                                : const Color.fromARGB(255, 44, 66, 113),
                          ),
                          child: Text(
                            isMeasuring
                                ? '${bpmValue ?? '--'}'
                                : '${finalBpm ?? '--'}',
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'BPM',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 44, 66, 113),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        // Blood Pressure Display with Enhanced Styling
                        if (calculatedSystolic != null &&
                            calculatedDiastolic != null) ...[
                          const SizedBox(height: 20),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(
                                    255,
                                    44,
                                    66,
                                    113,
                                  ).withOpacity(0.1),
                                  const Color.fromARGB(
                                    255,
                                    44,
                                    66,
                                    113,
                                  ).withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: const Color.fromARGB(
                                  255,
                                  44,
                                  66,
                                  113,
                                ).withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: const Offset(-2, -2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: const Color.fromARGB(
                                    255,
                                    44,
                                    66,
                                    113,
                                  ).withOpacity(0.1),
                                  offset: const Offset(2, 2),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.monitor_heart,
                                      size: 16,
                                      color: const Color.fromARGB(
                                        255,
                                        44,
                                        66,
                                        113,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Blood Pressure',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color.fromARGB(255, 44, 66, 113),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          '$calculatedSystolic',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                              255,
                                              44,
                                              66,
                                              113,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          'SYSTOLIC',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color.fromARGB(
                                              255,
                                              44,
                                              66,
                                              113,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        '/',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                            255,
                                            44,
                                            66,
                                            113,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          '$calculatedDiastolic',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                              255,
                                              44,
                                              66,
                                              113,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          'DIASTOLIC',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color.fromARGB(
                                              255,
                                              44,
                                              66,
                                              113,
                                            ),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Health Status Comparison
                  if (calculatedSystolic != null &&
                      calculatedDiastolic != null) ...[
                    const SizedBox(height: 20),
                    _buildHealthStatusComparison(),
                  ],

                  const SizedBox(height: 40),

                  // Enhanced Timer Display with Animation
                  if (isMeasuring)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: secondsLeft <= 10
                              ? [
                                  const Color(0xFFFFE8E8),
                                  const Color(0xFFFFD6D6),
                                ]
                              : [
                                  const Color(0xFFE8EAFE),
                                  const Color(0xFFD6E0FF),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.9),
                            offset: const Offset(-3, -3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: secondsLeft <= 10
                                ? const Color.fromARGB(
                                    255,
                                    220,
                                    53,
                                    69,
                                  ).withOpacity(0.15)
                                : const Color.fromARGB(
                                    255,
                                    5,
                                    5,
                                    167,
                                  ).withOpacity(0.10),
                            offset: const Offset(3, 3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.timer,
                              size: 22,
                              color: secondsLeft <= 10
                                  ? const Color.fromARGB(255, 220, 53, 69)
                                  : const Color.fromARGB(255, 44, 66, 113),
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: secondsLeft <= 10
                                  ? const Color.fromARGB(255, 220, 53, 69)
                                  : const Color.fromARGB(255, 44, 66, 113),
                            ),
                            child: Text('${secondsLeft}s remaining'),
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

                  // Enhanced Control Buttons with Animations
                  Column(
                    children: [
                      // Main Action Button (Start/Stop) with Enhanced Styling
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isMeasuring
                              ? stopMeasurement
                              : startMeasurement,
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isMeasuring
                                  ? Icons.stop_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                              key: ValueKey(isMeasuring),
                            ),
                          ),
                          label: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              isMeasuring
                                  ? 'Stop Measurement'
                                  : 'Start Measurement',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              key: ValueKey(isMeasuring),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isMeasuring
                                ? const Color.fromARGB(255, 220, 53, 69)
                                : const Color.fromARGB(255, 1, 25, 59),
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                            elevation: 6,
                            shadowColor:
                                (isMeasuring
                                        ? const Color.fromARGB(255, 220, 53, 69)
                                        : const Color.fromARGB(255, 1, 25, 59))
                                    .withOpacity(0.4),
                          ),
                        ),
                      ),

                      // Reset Button (only when not measuring and has result)
                      if (!isMeasuring && finalBpm != null) ...[
                        const SizedBox(height: 20),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: resetMeasurement,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            label: const Text(
                              'Reset Measurement',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
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

                  // Enhanced Instructions Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8EAFE), Color(0xFFD6E0FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
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
                          ).withOpacity(0.12),
                          offset: const Offset(6, 6),
                          blurRadius: 20,
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
                                gradient: LinearGradient(
                                  colors: [
                                    const Color.fromARGB(
                                      255,
                                      44,
                                      66,
                                      113,
                                    ).withOpacity(0.1),
                                    const Color.fromARGB(
                                      255,
                                      44,
                                      66,
                                      113,
                                    ).withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.8),
                                    offset: const Offset(-3, -3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                  BoxShadow(
                                    color: const Color.fromARGB(
                                      255,
                                      5,
                                      5,
                                      167,
                                    ).withOpacity(0.10),
                                    offset: const Offset(3, 3),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: Color.fromARGB(255, 44, 66, 113),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Measurement Instructions',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 44, 66, 113),
                                fontSize: 20,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            _buildInstructionStep(
                              '1',
                              'Cover the camera lens and flash with your fingertip',
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionStep(
                              '2',
                              'Keep your finger steady and still',
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionStep('3', 'Ensure good lighting'),
                            const SizedBox(height: 12),
                            _buildInstructionStep(
                              '4',
                              'Wait for 30 seconds for accurate reading',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Enhanced Disclaimer
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 255, 243, 205),
                          const Color.fromARGB(255, 255, 248, 220),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color.fromARGB(
                          255,
                          255,
                          193,
                          7,
                        ).withOpacity(0.4),
                        width: 1.5,
                      ),
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
                            255,
                            193,
                            7,
                          ).withOpacity(0.2),
                          offset: const Offset(2, 2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(
                              255,
                              255,
                              193,
                              7,
                            ).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Color.fromARGB(255, 255, 193, 7),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Medical Disclaimer',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 184, 134, 11),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This is not a medical device. For medical purposes, consult a healthcare professional.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ],
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
