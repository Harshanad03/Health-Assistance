class HealthDataService {
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  static HealthDataService get instance => _instance;

  final Map<String, Map<String, dynamic>> _healthData = {
    '29-30': {
      'heartRate': {'min': 64, 'max': 90},
      'systolic': {'min': 101, 'max': 150},
      'diastolic': {'min': 63, 'max': 98},
    },
    '31-35': {
      'heartRate': {'min': 65, 'max': 85},
      'systolic': {'min': 110, 'max': 145},
      'diastolic': {'min': 65, 'max': 95},
    },
    '36-40': {
      'heartRate': {'min': 70, 'max': 90},
      'systolic': {'min': 115, 'max': 155},
      'diastolic': {'min': 70, 'max': 95},
    },
    '41-45': {
      'heartRate': {'min': 72, 'max': 92},
      'systolic': {'min': 120, 'max': 160},
      'diastolic': {'min': 75, 'max': 100},
    },
    '46-50': {
      'heartRate': {'min': 75, 'max': 95},
      'systolic': {'min': 125, 'max': 165},
      'diastolic': {'min': 80, 'max': 105},
    },
    '51+': {
      'heartRate': {'min': 78, 'max': 98},
      'systolic': {'min': 130, 'max': 170},
      'diastolic': {'min': 85, 'max': 110},
    },
  };

  int calculateAge(String dob) {
    if (dob.isEmpty) {
      return 0; // Return 0 for empty DOB
    }

    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int age = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      print('Error parsing DOB: $dob. Error: $e');
      return 0; // Return 0 if date parsing fails
    }
  }

  String _getAgeRange(int age) {
    if (age >= 29 && age <= 30) return '29-30';
    if (age >= 31 && age <= 35) return '31-35';
    if (age >= 36 && age <= 40) return '36-40';
    if (age >= 41 && age <= 45) return '41-45';
    if (age >= 46 && age <= 50) return '46-50';
    if (age >= 51) return '51+';
    return '29-30'; // Default range
  }

  Map<String, int> getExpectedBloodPressure(int age) {
    final ageRange = _getAgeRange(age);
    final data = _healthData[ageRange]!;

    return {
      'systolicMin': data['systolic']['min'],
      'systolicMax': data['systolic']['max'],
      'diastolicMin': data['diastolic']['min'],
      'diastolicMax': data['diastolic']['max'],
    };
  }

  Map<String, int> getExpectedHeartRate(int age) {
    final ageRange = _getAgeRange(age);
    final data = _healthData[ageRange]!;

    return {'min': data['heartRate']['min'], 'max': data['heartRate']['max']};
  }

  String getFormattedBloodPressureRange(int age) {
    final bp = getExpectedBloodPressure(age);
    return '${bp['systolicMin']}-${bp['systolicMax']}/${bp['diastolicMin']}-${bp['diastolicMax']}';
  }

  String getFormattedHeartRateRange(int age) {
    final hr = getExpectedHeartRate(age);
    return '${hr['min']}-${hr['max']} BPM';
  }

  Map<String, bool> checkHealthStatus(
    int age,
    int? heartRate,
    int? systolic,
    int? diastolic,
  ) {
    final expectedHR = getExpectedHeartRate(age);
    final expectedBP = getExpectedBloodPressure(age);

    bool heartRateNormal = true;
    bool systolicNormal = true;
    bool diastolicNormal = true;
    bool bloodPressureNormal = true;

    if (heartRate != null) {
      heartRateNormal =
          heartRate >= expectedHR['min']! && heartRate <= expectedHR['max']!;
    }

    if (systolic != null) {
      systolicNormal =
          systolic >= expectedBP['systolicMin']! &&
          systolic <= expectedBP['systolicMax']!;
    }

    if (diastolic != null) {
      diastolicNormal =
          diastolic >= expectedBP['diastolicMin']! &&
          diastolic <= expectedBP['diastolicMax']!;
    }

    if (systolic != null && diastolic != null) {
      bloodPressureNormal = systolicNormal && diastolicNormal;
    }

    return {
      'heartRateNormal': heartRateNormal,
      'systolicNormal': systolicNormal,
      'diastolicNormal': diastolicNormal,
      'bloodPressureNormal': bloodPressureNormal,
    };
  }
}
