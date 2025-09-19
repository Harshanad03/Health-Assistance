import 'package:flutter/material.dart';
import 'dart:async';
import 'package:heart_bpm/heart_bpm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import '../widgets/modern_wavy_app_bar.dart';
import '../utils/routes.dart';
import '../models/user_profile.dart';
import '../services/measurement_history_service.dart';
import '../services/health_data_service.dart';
import '../services/health_prediction_service.dart';

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
  Timer? vibrationTimer;
  int secondsLeft = 30;
  List<int> bpmValues = [];
  String statusMessage = 'Ready to measure your heart rate';
  bool hasVibration = false;

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
    _checkVibrationCapability();
  }

  void _checkProfileCompletion() {
    final user = UserProfile.instance;

    if (user.name.isEmpty || user.dob.isEmpty || user.age.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileCompletionDialog();
      });
    }
  }

  void _showProfileCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 193, 7),
                      Color.fromARGB(255, 255, 165, 0),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 44, 66, 113),
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To use AUVI\'s heart rate monitoring, please complete your profile first.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 248, 220),
                  borderRadius: BorderRadius.circular(15),
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
                        const Icon(
                          Icons.info_outline,
                          color: Color.fromARGB(255, 255, 193, 7),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Required Information:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 184, 134, 11),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Full Name\n• Date of Birth\n• Age\n\nYour age is essential for accurate heart rate analysis.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 134, 107, 48),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, AppRoutes.main);
              },
              child: const Text(
                'Maybe Later',
                style: TextStyle(
                  color: Color.fromARGB(255, 108, 117, 125),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, AppRoutes.mainProfile);
              },
              icon: const Icon(Icons.edit, color: Colors.white, size: 18),
              label: const Text(
                'Complete Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 1, 25, 59),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkVibrationCapability() async {
    try {
      hasVibration = await Vibration.hasVibrator() ?? false;
      print('HeartRatePage: Native vibration available: $hasVibration');
    } catch (e) {
      print('HeartRatePage: Error checking vibration capability: $e');
      hasVibration = false;
    }
  }

  void _startVibrationFeedback() {
    if (!hasVibration) return;

    try {
      _startContinuousVibration();

      print('HeartRatePage: Started continuous vibration');
    } catch (e) {
      print('HeartRatePage: Error starting vibration: $e');
    }
  }

  void _startContinuousVibration() {
    if (!hasVibration || !isMeasuring) return;

    try {
      Vibration.vibrate(duration: 1000);

      vibrationTimer = Timer.periodic(const Duration(milliseconds: 900), (
        timer,
      ) {
        if (isMeasuring && hasVibration) {
          Vibration.vibrate(duration: 1000); // 100ms overlap to prevent gaps
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      print('HeartRatePage: Error in continuous vibration: $e');
    }
  }

  void _stopVibrationFeedback() {
    try {
      vibrationTimer?.cancel();
      vibrationTimer = null;

      Vibration.cancel();

      print('HeartRatePage: Stopped continuous native vibration');
    } catch (e) {
      print('HeartRatePage: Error stopping vibration: $e');
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
      statusMessage = 'Place your finger over camera and flash.';
    });

    _startVibrationFeedback();

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

    _stopVibrationFeedback();

    try {
      await TorchLight.disableTorch();
    } catch (e) {
      print('Error turning off flash: $e');
    }

    setState(() {
      isMeasuring = false;
      if (bpmValues.isNotEmpty) {
        finalBpm =
            (bpmValues.reduce((a, b) => a + b) / bpmValues.length).round();
        statusMessage =
            'Measurement complete! Your average heart rate: $finalBpm BPM';

        _saveMeasurementToHistory();
      } else {
        statusMessage = 'No valid readings. Please try again.';
      }
    });
  }

  Future<Map<String, dynamic>> _getBPPrediction() async {
    if (finalBpm == null) {
      return {'error': 'No heart rate data'};
    }

    final user = UserProfile.instance;
    final healthService = HealthDataService.instance;
    final predictionService = HealthPredictionService.instance;

    final age = healthService.calculateAge(user.dob);
    return predictionService.predictBloodPressure(
      age > 0 ? age : 30,
      finalBpm!,
    );
  }

  void _saveMeasurementToHistory() async {
    if (finalBpm == null) return;

    try {
      final user = UserProfile.instance;
      final healthService = HealthDataService.instance;
      final historyService = MeasurementHistoryService.instance;
      final predictionService = HealthPredictionService.instance;

      final age = healthService.calculateAge(user.dob);
      final healthStatus = healthService.checkHealthStatus(
        age > 0 ? age : 30, // Use default age if calculation fails
        finalBpm,
        null,
        null,
      );

      final bpPrediction = predictionService.predictBloodPressure(
        age > 0 ? age : 30,
        finalBpm!,
      );

      final success = await historyService.saveHeartRateMeasurement(
        heartRate: finalBpm!,
        age: age > 0 ? age : null,
        isNormal: healthStatus['heartRateNormal'],
        additionalMetadata: {
          'measurementDuration': 30,
          'sampleCount': bpmValues.length,
          'rawValues': bpmValues.take(10).toList(), // Store first 10 raw values
          'predictedBP': bpPrediction['prediction'],
          'predictedBPStatus': bpPrediction['status'],
          'predictionConfidence': bpPrediction['confidence'],
          'similarCases': bpPrediction['similarCases'],
        },
      );

      if (success) {
        print('Heart rate measurement saved successfully');
        print(
          'BP Prediction: ${bpPrediction['prediction']} (${bpPrediction['status']})',
        );

        setState(() {
          statusMessage =
              'Heart Rate: $finalBpm BPM\nPredicted BP: ${bpPrediction['prediction']} (${bpPrediction['status']})';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Measurement saved to history'),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Predicted BP: ${bpPrediction['prediction']} (${bpPrediction['status']})',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        print('Failed to save heart rate measurement');
      }
    } catch (e) {
      print('Error saving heart rate measurement: $e');
    }
  }

  void resetMeasurement() async {
    vibrationTimer?.cancel();
    vibrationTimer = null;
    try {
      Vibration.cancel();
    } catch (e) {
      print('Error stopping vibration: $e');
    }

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
    vibrationTimer?.cancel();
    Vibration.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 215, 223, 247),
      body: Column(
        children: [
          ModernWavyAppBar(
            height: 140,
            onBack:
                () => Navigator.pushReplacementNamed(context, AppRoutes.main),
            child: Center(
              child: Text(
                'AUVI Heart Rate Monitor',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

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
                            color:
                                isMeasuring
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
                          if (hasVibration) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.vibration,
                              size: 16,
                              color: const Color.fromARGB(255, 44, 66, 113),
                            ),
                          ],
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),

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

                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              isMeasuring ? stopMeasurement : startMeasurement,
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
                            backgroundColor:
                                isMeasuring
                                    ? const Color.fromARGB(255, 220, 53, 69)
                                    : const Color.fromARGB(255, 1, 25, 59),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                            shadowColor: (isMeasuring
                                    ? const Color.fromARGB(255, 220, 53, 69)
                                    : const Color.fromARGB(255, 1, 25, 59))
                                .withOpacity(0.3),
                          ),
                        ),
                      ),

                      if (!isMeasuring && finalBpm != null) ...[
                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 240, 255, 248),
                                Color.fromARGB(255, 250, 255, 252),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(
                                255,
                                25,
                                135,
                                84,
                              ).withOpacity(0.3),
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
                            ],
                          ),
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _getBPPrediction(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final prediction = snapshot.data!;
                                return Column(
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
                                              25,
                                              135,
                                              84,
                                            ).withOpacity(0.2),
                                          ),
                                          child: const Icon(
                                            Icons.bloodtype,
                                            color: Color.fromARGB(
                                              255,
                                              25,
                                              135,
                                              84,
                                            ),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Predicted Blood Pressure',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color.fromARGB(
                                                255,
                                                44,
                                                66,
                                                113,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              prediction['prediction'],
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                                color: Color.fromARGB(
                                                  255,
                                                  25,
                                                  135,
                                                  84,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              'Status: ${prediction['status']}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color.fromARGB(
                                                  255,
                                                  44,
                                                  66,
                                                  113,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            '${(prediction['confidence'] * 100).round()}% Confidence',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color.fromARGB(
                                                255,
                                                25,
                                                135,
                                                84,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Based on ${prediction['similarCases']} similar medical cases',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color.fromARGB(255, 25, 135, 84),
                                ),
                              );
                            },
                          ),
                        ),
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
                              'Take Another Measurement',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                44,
                                66,
                                113,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
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
                      ],
                    ],
                  ),

                  const SizedBox(height: 30),

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
