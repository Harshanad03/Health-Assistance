import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/measurement_history.dart';

class MeasurementHistoryService {
  static final MeasurementHistoryService _instance =
      MeasurementHistoryService._internal();
  factory MeasurementHistoryService() => _instance;
  MeasurementHistoryService._internal();

  static MeasurementHistoryService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _measurementsCollection =>
      _firestore.collection('measurements');

  String? get _currentUserId => _auth.currentUser?.uid;

  Future<bool> saveMeasurement(MeasurementRecord measurement) async {
    try {
      if (_currentUserId == null) {
        print('MeasurementHistoryService: No user logged in');
        return false;
      }

      final updatedMeasurement = MeasurementRecord(
        id: measurement.id,
        userId: _currentUserId!,
        type: measurement.type,
        timestamp: measurement.timestamp,
        values: measurement.values,
        metadata: measurement.metadata,
      );

      await _measurementsCollection
          .doc(measurement.id)
          .set(updatedMeasurement.toFirestore());

      print('MeasurementHistoryService: Saved measurement ${measurement.id}');
      return true;
    } catch (e) {
      print('MeasurementHistoryService: Error saving measurement: $e');
      return false;
    }
  }

  Future<bool> saveHeartRateMeasurement({
    required int heartRate,
    int? age,
    bool? isNormal,
    Map<String, dynamic> additionalMetadata = const {},
  }) async {
    try {
      if (_currentUserId == null) return false;

      final id = _generateMeasurementId();
      final measurement = MeasurementRecord.heartRate(
        id: id,
        userId: _currentUserId!,
        timestamp: DateTime.now(),
        heartRate: heartRate,
        age: age,
        isNormal: isNormal,
        additionalMetadata: additionalMetadata,
      );

      return await saveMeasurement(measurement);
    } catch (e) {
      print('MeasurementHistoryService: Error saving heart rate: $e');
      return false;
    }
  }

  Future<bool> saveBloodPressureMeasurement({
    required int systolic,
    required int diastolic,
    int? heartRate,
    int? age,
    bool? isNormal,
    Map<String, dynamic> additionalMetadata = const {},
  }) async {
    try {
      if (_currentUserId == null) return false;

      final id = _generateMeasurementId();
      final measurement = MeasurementRecord.bloodPressure(
        id: id,
        userId: _currentUserId!,
        timestamp: DateTime.now(),
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        age: age,
        isNormal: isNormal,
        additionalMetadata: additionalMetadata,
      );

      return await saveMeasurement(measurement);
    } catch (e) {
      print('MeasurementHistoryService: Error saving blood pressure: $e');
      return false;
    }
  }

  Future<List<MeasurementRecord>> getAllMeasurements() async {
    try {
      if (_currentUserId == null) {
        print('MeasurementHistoryService: No current user ID');
        return [];
      }

      print(
        'MeasurementHistoryService: Getting measurements for user: $_currentUserId',
      );

      final querySnapshot =
          await _measurementsCollection
              .where('userId', isEqualTo: _currentUserId)
              .orderBy('timestamp', descending: true)
              .get();

      print(
        'MeasurementHistoryService: Found ${querySnapshot.docs.length} documents',
      );

      final measurements =
          querySnapshot.docs.map((doc) {
            print(
              'MeasurementHistoryService: Processing doc ${doc.id}: ${doc.data()}',
            );
            return MeasurementRecord.fromFirestore(doc);
          }).toList();

      print(
        'MeasurementHistoryService: Returning ${measurements.length} measurements',
      );
      return measurements;
    } catch (e) {
      print('MeasurementHistoryService: Error getting measurements: $e');
      return [];
    }
  }

  Future<List<MeasurementRecord>> getMeasurementsByType(
    MeasurementType type,
  ) async {
    try {
      if (_currentUserId == null) return [];

      final querySnapshot =
          await _measurementsCollection
              .where('userId', isEqualTo: _currentUserId)
              .where('type', isEqualTo: type.name)
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => MeasurementRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      print(
        'MeasurementHistoryService: Error getting measurements by type: $e',
      );
      return [];
    }
  }

  Future<List<MeasurementRecord>> getRecentMeasurements({
    int limit = 10,
  }) async {
    try {
      if (_currentUserId == null) return [];

      final querySnapshot =
          await _measurementsCollection
              .where('userId', isEqualTo: _currentUserId)
              .orderBy('timestamp', descending: true)
              .limit(limit)
              .get();

      return querySnapshot.docs
          .map((doc) => MeasurementRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('MeasurementHistoryService: Error getting recent measurements: $e');
      return [];
    }
  }

  Future<List<MeasurementRecord>> getMeasurementsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (_currentUserId == null) return [];

      final querySnapshot =
          await _measurementsCollection
              .where('userId', isEqualTo: _currentUserId)
              .where(
                'timestamp',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
              )
              .where(
                'timestamp',
                isLessThanOrEqualTo: Timestamp.fromDate(endDate),
              )
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => MeasurementRecord.fromFirestore(doc))
          .toList();
    } catch (e) {
      print(
        'MeasurementHistoryService: Error getting measurements in range: $e',
      );
      return [];
    }
  }

  Future<List<MeasurementGroup>> getMeasurementsGroupedByDate() async {
    try {
      final measurements = await getAllMeasurements();
      final Map<String, List<MeasurementRecord>> groupedMeasurements = {};

      for (final measurement in measurements) {
        final dateKey = _getDateKey(measurement.timestamp);
        if (groupedMeasurements[dateKey] == null) {
          groupedMeasurements[dateKey] = [];
        }
        groupedMeasurements[dateKey]!.add(measurement);
      }

      final groups = <MeasurementGroup>[];
      for (final entry in groupedMeasurements.entries) {
        final date = _parseDateKey(entry.key);
        groups.add(MeasurementGroup(date: date, measurements: entry.value));
      }

      groups.sort((a, b) => b.date.compareTo(a.date));
      return groups;
    } catch (e) {
      print('MeasurementHistoryService: Error grouping measurements: $e');
      return [];
    }
  }

  Future<bool> deleteMeasurement(String measurementId) async {
    try {
      if (_currentUserId == null) return false;

      await _measurementsCollection.doc(measurementId).delete();
      print('MeasurementHistoryService: Deleted measurement $measurementId');
      return true;
    } catch (e) {
      print('MeasurementHistoryService: Error deleting measurement: $e');
      return false;
    }
  }

  Future<bool> deleteAllMeasurements() async {
    try {
      if (_currentUserId == null) return false;

      final querySnapshot =
          await _measurementsCollection
              .where('userId', isEqualTo: _currentUserId)
              .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('MeasurementHistoryService: Deleted all measurements for user');
      return true;
    } catch (e) {
      print('MeasurementHistoryService: Error deleting all measurements: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getMeasurementStatistics() async {
    try {
      final measurements = await getAllMeasurements();

      final heartRateMeasurements =
          measurements
              .where((m) => m.type == MeasurementType.heartRate)
              .toList();

      final bloodPressureMeasurements =
          measurements
              .where((m) => m.type == MeasurementType.bloodPressure)
              .toList();

      final stats = <String, dynamic>{
        'totalMeasurements': measurements.length,
        'heartRateCount': heartRateMeasurements.length,
        'bloodPressureCount': bloodPressureMeasurements.length,
        'lastMeasurementDate':
            measurements.isNotEmpty ? measurements.first.timestamp : null,
      };

      if (heartRateMeasurements.isNotEmpty) {
        final heartRates =
            heartRateMeasurements
                .map((m) => m.heartRate!)
                .where((hr) => hr > 0)
                .toList();

        if (heartRates.isNotEmpty) {
          stats['heartRate'] = {
            'average':
                (heartRates.reduce((a, b) => a + b) / heartRates.length)
                    .round(),
            'min': heartRates.reduce((a, b) => a < b ? a : b),
            'max': heartRates.reduce((a, b) => a > b ? a : b),
            'latest': heartRates.first,
          };
        }
      }

      if (bloodPressureMeasurements.isNotEmpty) {
        final systolicValues =
            bloodPressureMeasurements
                .map((m) => m.systolic!)
                .where((s) => s > 0)
                .toList();

        final diastolicValues =
            bloodPressureMeasurements
                .map((m) => m.diastolic!)
                .where((d) => d > 0)
                .toList();

        if (systolicValues.isNotEmpty && diastolicValues.isNotEmpty) {
          stats['bloodPressure'] = {
            'systolic': {
              'average':
                  (systolicValues.reduce((a, b) => a + b) /
                          systolicValues.length)
                      .round(),
              'min': systolicValues.reduce((a, b) => a < b ? a : b),
              'max': systolicValues.reduce((a, b) => a > b ? a : b),
              'latest': systolicValues.first,
            },
            'diastolic': {
              'average':
                  (diastolicValues.reduce((a, b) => a + b) /
                          diastolicValues.length)
                      .round(),
              'min': diastolicValues.reduce((a, b) => a < b ? a : b),
              'max': diastolicValues.reduce((a, b) => a > b ? a : b),
              'latest': diastolicValues.first,
            },
          };
        }
      }

      return stats;
    } catch (e) {
      print('MeasurementHistoryService: Error getting statistics: $e');
      return {};
    }
  }

  Stream<List<MeasurementRecord>> getMeasurementsStream() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    return _measurementsCollection
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MeasurementRecord.fromFirestore(doc))
                  .toList(),
        );
  }

  String _generateMeasurementId() {
    return '${_currentUserId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _parseDateKey(String dateKey) {
    final parts = dateKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
