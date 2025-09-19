import 'dart:math';

class HealthPredictionService {
  static final HealthPredictionService _instance =
      HealthPredictionService._internal();
  factory HealthPredictionService() => _instance;
  HealthPredictionService._internal();

  static HealthPredictionService get instance => _instance;

  static const List<Map<String, dynamic>> _medicalData = [
    {'age': 29, 'heartRate': 90, 'systolic': 150, 'diastolic': 71},
    {'age': 29, 'heartRate': 77, 'systolic': 112, 'diastolic': 89},
    {'age': 30, 'heartRate': 101, 'systolic': 118, 'diastolic': 89},
    {'age': 30, 'heartRate': 98, 'systolic': 121, 'diastolic': 91},
    {'age': 30, 'heartRate': 64, 'systolic': 132, 'diastolic': 98},
    {'age': 30, 'heartRate': 79, 'systolic': 115, 'diastolic': 78},
    {'age': 31, 'heartRate': 76, 'systolic': 106, 'diastolic': 69},
    {'age': 31, 'heartRate': 95, 'systolic': 125, 'diastolic': 93},
    {'age': 31, 'heartRate': 92, 'systolic': 106, 'diastolic': 76},
    {'age': 32, 'heartRate': 99, 'systolic': 109, 'diastolic': 71},
    {'age': 32, 'heartRate': 68, 'systolic': 101, 'diastolic': 88},
    {'age': 32, 'heartRate': 101, 'systolic': 115, 'diastolic': 91},
    {'age': 33, 'heartRate': 97, 'systolic': 113, 'diastolic': 99},
    {'age': 33, 'heartRate': 91, 'systolic': 102, 'diastolic': 77},
    {'age': 34, 'heartRate': 93, 'systolic': 105, 'diastolic': 71},
    {'age': 35, 'heartRate': 87, 'systolic': 113, 'diastolic': 76},
    {'age': 35, 'heartRate': 91, 'systolic': 132, 'diastolic': 88},
    {'age': 37, 'heartRate': 73, 'systolic': 108, 'diastolic': 73},
    {'age': 37, 'heartRate': 77, 'systolic': 117, 'diastolic': 68},
    {'age': 37, 'heartRate': 85, 'systolic': 126, 'diastolic': 72},
    {'age': 38, 'heartRate': 99, 'systolic': 110, 'diastolic': 97},
    {'age': 38, 'heartRate': 101, 'systolic': 125, 'diastolic': 73},
    {'age': 39, 'heartRate': 97, 'systolic': 102, 'diastolic': 71},
    {'age': 39, 'heartRate': 89, 'systolic': 130, 'diastolic': 75},
    {'age': 40, 'heartRate': 79, 'systolic': 155, 'diastolic': 89},
    {'age': 43, 'heartRate': 88, 'systolic': 162, 'diastolic': 78},
    {'age': 45, 'heartRate': 77, 'systolic': 135, 'diastolic': 72},
    {'age': 45, 'heartRate': 98, 'systolic': 118, 'diastolic': 63},
    {'age': 45, 'heartRate': 82, 'systolic': 121, 'diastolic': 67},
    {'age': 46, 'heartRate': 76, 'systolic': 108, 'diastolic': 63},
    {'age': 46, 'heartRate': 67, 'systolic': 134, 'diastolic': 77},
    {'age': 47, 'heartRate': 91, 'systolic': 109, 'diastolic': 78},
    {'age': 47, 'heartRate': 93, 'systolic': 125, 'diastolic': 70},
    {'age': 47, 'heartRate': 92, 'systolic': 102, 'diastolic': 97},
    {'age': 48, 'heartRate': 88, 'systolic': 131, 'diastolic': 82},
    {'age': 48, 'heartRate': 101, 'systolic': 115, 'diastolic': 87},
    {'age': 48, 'heartRate': 105, 'systolic': 121, 'diastolic': 77},
    {'age': 49, 'heartRate': 87, 'systolic': 101, 'diastolic': 69},
    {'age': 49, 'heartRate': 92, 'systolic': 117, 'diastolic': 74},
    {'age': 49, 'heartRate': 77, 'systolic': 112, 'diastolic': 81},
    {'age': 51, 'heartRate': 90, 'systolic': 110, 'diastolic': 76},
    {'age': 51, 'heartRate': 89, 'systolic': 101, 'diastolic': 69},

    {'age': 21, 'heartRate': 88, 'systolic': 114, 'diastolic': 72},
    {'age': 21, 'heartRate': 81, 'systolic': 108, 'diastolic': 76},
    {'age': 25, 'heartRate': 92, 'systolic': 118, 'diastolic': 65},
    {'age': 25, 'heartRate': 69, 'systolic': 108, 'diastolic': 63},
    {'age': 25, 'heartRate': 93, 'systolic': 125, 'diastolic': 70},
    {'age': 26, 'heartRate': 99, 'systolic': 101, 'diastolic': 71},
    {'age': 27, 'heartRate': 85, 'systolic': 99, 'diastolic': 67},
    {'age': 27, 'heartRate': 95, 'systolic': 122, 'diastolic': 63},
    {'age': 30, 'heartRate': 105, 'systolic': 103, 'diastolic': 71},
    {'age': 30, 'heartRate': 75, 'systolic': 104, 'diastolic': 68},
    {'age': 30, 'heartRate': 101, 'systolic': 128, 'diastolic': 75},
    {'age': 31, 'heartRate': 79, 'systolic': 102, 'diastolic': 77},
    {'age': 33, 'heartRate': 83, 'systolic': 110, 'diastolic': 68},
    {'age': 34, 'heartRate': 92, 'systolic': 115, 'diastolic': 71},
    {'age': 37, 'heartRate': 96, 'systolic': 126, 'diastolic': 65},
    {'age': 37, 'heartRate': 101, 'systolic': 122, 'diastolic': 61},
    {'age': 38, 'heartRate': 108, 'systolic': 131, 'diastolic': 95},
    {'age': 39, 'heartRate': 99, 'systolic': 109, 'diastolic': 85},
    {'age': 39, 'heartRate': 84, 'systolic': 116, 'diastolic': 73},
    {'age': 39, 'heartRate': 79, 'systolic': 110, 'diastolic': 77},
    {'age': 39, 'heartRate': 86, 'systolic': 135, 'diastolic': 63},
    {'age': 40, 'heartRate': 97, 'systolic': 117, 'diastolic': 93},
    {'age': 40, 'heartRate': 68, 'systolic': 109, 'diastolic': 78},
    {'age': 40, 'heartRate': 75, 'systolic': 123, 'diastolic': 75},
    {'age': 41, 'heartRate': 81, 'systolic': 114, 'diastolic': 68},
    {'age': 42, 'heartRate': 97, 'systolic': 102, 'diastolic': 69},
    {'age': 42, 'heartRate': 103, 'systolic': 127, 'diastolic': 77},
    {'age': 43, 'heartRate': 77, 'systolic': 106, 'diastolic': 91},
    {'age': 44, 'heartRate': 92, 'systolic': 118, 'diastolic': 81},
    {'age': 45, 'heartRate': 68, 'systolic': 111, 'diastolic': 67},
    {'age': 45, 'heartRate': 98, 'systolic': 124, 'diastolic': 85},
    {'age': 45, 'heartRate': 82, 'systolic': 110, 'diastolic': 60},
    {'age': 45, 'heartRate': 101, 'systolic': 115, 'diastolic': 81},
    {'age': 46, 'heartRate': 95, 'systolic': 130, 'diastolic': 77},
    {'age': 46, 'heartRate': 78, 'systolic': 111, 'diastolic': 87},
    {'age': 47, 'heartRate': 88, 'systolic': 108, 'diastolic': 72},
    {'age': 47, 'heartRate': 92, 'systolic': 127, 'diastolic': 78},
    {'age': 47, 'heartRate': 101, 'systolic': 102, 'diastolic': 90},
    {'age': 47, 'heartRate': 66, 'systolic': 103, 'diastolic': 73},
    {'age': 49, 'heartRate': 95, 'systolic': 126, 'diastolic': 83},
    {'age': 51, 'heartRate': 72, 'systolic': 101, 'diastolic': 64},
    {'age': 51, 'heartRate': 81, 'systolic': 100, 'diastolic': 76},
    {'age': 52, 'heartRate': 99, 'systolic': 129, 'diastolic': 89},
    {'age': 53, 'heartRate': 80, 'systolic': 103, 'diastolic': 84},
    {'age': 53, 'heartRate': 85, 'systolic': 133, 'diastolic': 62},
    {'age': 55, 'heartRate': 92, 'systolic': 114, 'diastolic': 67},
    {'age': 55, 'heartRate': 81, 'systolic': 99, 'diastolic': 65},
    {'age': 55, 'heartRate': 98, 'systolic': 101, 'diastolic': 90},
    {'age': 59, 'heartRate': 94, 'systolic': 135, 'diastolic': 63},
    {'age': 59, 'heartRate': 67, 'systolic': 100, 'diastolic': 84},
    {'age': 60, 'heartRate': 92, 'systolic': 130, 'diastolic': 72},
    {'age': 61, 'heartRate': 74, 'systolic': 106, 'diastolic': 99},
    {'age': 61, 'heartRate': 99, 'systolic': 128, 'diastolic': 88},
    {'age': 63, 'heartRate': 62, 'systolic': 107, 'diastolic': 66},
    {'age': 64, 'heartRate': 78, 'systolic': 101, 'diastolic': 90},
    {'age': 65, 'heartRate': 87, 'systolic': 104, 'diastolic': 69},
    {'age': 65, 'heartRate': 101, 'systolic': 100, 'diastolic': 97},
    {'age': 65, 'heartRate': 77, 'systolic': 140, 'diastolic': 86},
    {'age': 68, 'heartRate': 93, 'systolic': 112, 'diastolic': 84},
    {'age': 70, 'heartRate': 78, 'systolic': 97, 'diastolic': 61},
    {'age': 70, 'heartRate': 84, 'systolic': 111, 'diastolic': 62},
    {'age': 72, 'heartRate': 77, 'systolic': 98, 'diastolic': 62},
    {'age': 72, 'heartRate': 95, 'systolic': 127, 'diastolic': 65},
    {'age': 72, 'heartRate': 59, 'systolic': 99, 'diastolic': 83},
    {'age': 75, 'heartRate': 66, 'systolic': 115, 'diastolic': 89},
    {'age': 75, 'heartRate': 94, 'systolic': 112, 'diastolic': 97},
    {'age': 75, 'heartRate': 89, 'systolic': 101, 'diastolic': 71},
    {'age': 76, 'heartRate': 84, 'systolic': 107, 'diastolic': 92},
    {'age': 79, 'heartRate': 73, 'systolic': 101, 'diastolic': 62},
    {'age': 80, 'heartRate': 101, 'systolic': 93, 'diastolic': 90},
    {'age': 81, 'heartRate': 94, 'systolic': 102, 'diastolic': 99},
  ];

  Map<String, dynamic> predictBloodPressure(int age, int heartRate) {
    try {
      print('HealthPrediction: Predicting BP for age=$age, HR=$heartRate');

      List<Map<String, dynamic>> similarCases = _findSimilarCases(
        age,
        heartRate,
      );

      if (similarCases.isEmpty) {
        return _estimateByAge(age);
      }

      double totalWeight = 0;
      double weightedSystolic = 0;
      double weightedDiastolic = 0;

      for (var case_ in similarCases) {
        double weight = _calculateSimilarityWeight(age, heartRate, case_);
        totalWeight += weight;
        weightedSystolic += case_['systolic'] * weight;
        weightedDiastolic += case_['diastolic'] * weight;
      }

      int predictedSystolic = (weightedSystolic / totalWeight).round();
      int predictedDiastolic = (weightedDiastolic / totalWeight).round();

      predictedSystolic = predictedSystolic.clamp(80, 200);
      predictedDiastolic = predictedDiastolic.clamp(50, 120);

      String status = _getBPStatus(predictedSystolic, predictedDiastolic);
      double confidence = _calculateConfidence(similarCases.length, age);

      print(
        'HealthPrediction: Predicted BP = $predictedSystolic/$predictedDiastolic ($status)',
      );

      return {
        'systolic': predictedSystolic,
        'diastolic': predictedDiastolic,
        'status': status,
        'confidence': confidence,
        'similarCases': similarCases.length,
        'prediction': '$predictedSystolic/$predictedDiastolic mmHg',
      };
    } catch (e) {
      print('Error in BP prediction: $e');
      return _estimateByAge(age);
    }
  }

  List<Map<String, dynamic>> _findSimilarCases(int targetAge, int targetHR) {
    List<Map<String, dynamic>> similar = [];

    for (var data in _medicalData) {
      int ageDistance = (data['age'] - targetAge).abs();
      int hrDistance = (data['heartRate'] - targetHR).abs();

      if (ageDistance <= 5 && hrDistance <= 15) {
        similar.add({
          ...data,
          'ageDistance': ageDistance,
          'hrDistance': hrDistance,
        });
      }
    }

    similar.sort((a, b) {
      int aScore = a['ageDistance'] + (a['hrDistance'] ~/ 3);
      int bScore = b['ageDistance'] + (b['hrDistance'] ~/ 3);
      return aScore.compareTo(bScore);
    });

    return similar.take(10).toList();
  }

  double _calculateSimilarityWeight(
    int targetAge,
    int targetHR,
    Map<String, dynamic> case_,
  ) {
    double ageDistance = (case_['age'] - targetAge).abs().toDouble();
    double hrDistance = (case_['heartRate'] - targetHR).abs().toDouble();

    double ageWeight = 1.0 / (1.0 + ageDistance);
    double hrWeight =
        1.0 / (1.0 + hrDistance / 5.0); // HR has less weight than age

    return ageWeight * hrWeight;
  }

  Map<String, dynamic> _estimateByAge(int age) {
    int baseSystolic = 90 + (age - 20) * 0.5.round();
    int baseDiastolic = 60 + (age - 20) * 0.3.round();

    baseSystolic = baseSystolic.clamp(90, 140);
    baseDiastolic = baseDiastolic.clamp(60, 90);

    return {
      'systolic': baseSystolic,
      'diastolic': baseDiastolic,
      'status': _getBPStatus(baseSystolic, baseDiastolic),
      'confidence': 0.6, // Lower confidence for age-only estimation
      'similarCases': 0,
      'prediction': '$baseSystolic/$baseDiastolic mmHg',
    };
  }

  String _getBPStatus(int systolic, int diastolic) {
    if (systolic < 90 || diastolic < 60) {
      return 'Low';
    } else if (systolic <= 120 && diastolic <= 80) {
      return 'Normal';
    } else if (systolic <= 129 && diastolic <= 80) {
      return 'Elevated';
    } else if (systolic <= 139 || diastolic <= 89) {
      return 'High Stage 1';
    } else if (systolic <= 180 || diastolic <= 120) {
      return 'High Stage 2';
    } else {
      return 'Crisis';
    }
  }

  double _calculateConfidence(int similarCasesCount, int age) {
    double baseConfidence = 0.7;

    double casesBonus = (similarCasesCount / 10.0) * 0.2;

    double ageBonus = (age >= 25 && age <= 65) ? 0.1 : 0.0;

    return (baseConfidence + casesBonus + ageBonus).clamp(0.5, 0.95);
  }

  List<String> getHealthInsights(
    int age,
    int heartRate,
    int? systolic,
    int? diastolic,
  ) {
    List<String> insights = [];

    if (heartRate < 60) {
      insights.add(
        'Your heart rate is below normal range. Consider consulting a doctor if this persists.',
      );
    } else if (heartRate > 100) {
      insights.add(
        'Your heart rate is elevated. Try relaxation techniques and avoid caffeine.',
      );
    } else {
      insights.add(
        'Your heart rate is within normal range. Great job maintaining cardiovascular health!',
      );
    }

    if (systolic != null && diastolic != null) {
      String bpStatus = _getBPStatus(systolic, diastolic);

      switch (bpStatus) {
        case 'Normal':
          insights.add(
            'Your blood pressure is excellent. Continue your healthy lifestyle.',
          );
          break;
        case 'Elevated':
          insights.add(
            'Your blood pressure is slightly elevated. Focus on diet and exercise.',
          );
          break;
        case 'High Stage 1':
          insights.add(
            'Your blood pressure is high. Consider lifestyle changes and consult your doctor.',
          );
          break;
        case 'High Stage 2':
        case 'Crisis':
          insights.add(
            'Your blood pressure requires immediate medical attention. Please consult a doctor.',
          );
          break;
        case 'Low':
          insights.add(
            'Your blood pressure is low. Stay hydrated and consult a doctor if you feel dizzy.',
          );
          break;
      }
    }

    if (age > 50) {
      insights.add(
        'Regular monitoring is especially important at your age. Keep tracking your health daily.',
      );
    } else if (age < 30) {
      insights.add(
        'Building healthy habits now will benefit you throughout life. Keep monitoring regularly.',
      );
    }

    return insights;
  }

  Map<String, dynamic> getHealthStatistics(
    int age,
    List<int> userHeartRates,
    List<int> userSystolic,
    List<int> userDiastolic,
  ) {
    if (userHeartRates.isEmpty) {
      return {'error': 'No measurement data available'};
    }

    double avgHR =
        userHeartRates.reduce((a, b) => a + b) / userHeartRates.length;
    double avgSystolic =
        userSystolic.isNotEmpty
            ? userSystolic.reduce((a, b) => a + b) / userSystolic.length
            : 0;
    double avgDiastolic =
        userDiastolic.isNotEmpty
            ? userDiastolic.reduce((a, b) => a + b) / userDiastolic.length
            : 0;

    List<Map<String, dynamic>> peerGroup =
        _medicalData.where((data) => (data['age'] - age).abs() <= 3).toList();

    if (peerGroup.isEmpty) {
      return {'error': 'No peer data available for comparison'};
    }

    double peerAvgHR =
        peerGroup.map((d) => d['heartRate']).reduce((a, b) => a + b) /
        peerGroup.length;
    double peerAvgSystolic =
        peerGroup.map((d) => d['systolic']).reduce((a, b) => a + b) /
        peerGroup.length;
    double peerAvgDiastolic =
        peerGroup.map((d) => d['diastolic']).reduce((a, b) => a + b) /
        peerGroup.length;

    return {
      'userAvgHR': avgHR.round(),
      'userAvgSystolic': avgSystolic.round(),
      'userAvgDiastolic': avgDiastolic.round(),
      'peerAvgHR': peerAvgHR.round(),
      'peerAvgSystolic': peerAvgSystolic.round(),
      'peerAvgDiastolic': peerAvgDiastolic.round(),
      'peerGroupSize': peerGroup.length,
      'hrComparison':
          avgHR < peerAvgHR
              ? 'below'
              : avgHR > peerAvgHR
              ? 'above'
              : 'similar',
      'bpComparison':
          avgSystolic < peerAvgSystolic
              ? 'below'
              : avgSystolic > peerAvgSystolic
              ? 'above'
              : 'similar',
    };
  }
}
