import 'package:cloud_firestore/cloud_firestore.dart';

enum MeasurementType { heartRate, bloodPressure }

class MeasurementRecord {
  final String id;
  final String userId;
  final MeasurementType type;
  final DateTime timestamp;
  final Map<String, dynamic> values;
  final Map<String, dynamic> metadata;

  MeasurementRecord({
    required this.id,
    required this.userId,
    required this.type,
    required this.timestamp,
    required this.values,
    this.metadata = const {},
  });

  factory MeasurementRecord.heartRate({
    required String id,
    required String userId,
    required DateTime timestamp,
    required int heartRate,
    int? age,
    bool? isNormal,
    Map<String, dynamic> additionalMetadata = const {},
  }) {
    return MeasurementRecord(
      id: id,
      userId: userId,
      type: MeasurementType.heartRate,
      timestamp: timestamp,
      values: {'heartRate': heartRate},
      metadata: {'age': age, 'isNormal': isNormal, ...additionalMetadata},
    );
  }

  factory MeasurementRecord.bloodPressure({
    required String id,
    required String userId,
    required DateTime timestamp,
    required int systolic,
    required int diastolic,
    int? heartRate,
    int? age,
    bool? isNormal,
    Map<String, dynamic> additionalMetadata = const {},
  }) {
    return MeasurementRecord(
      id: id,
      userId: userId,
      type: MeasurementType.bloodPressure,
      timestamp: timestamp,
      values: {
        'systolic': systolic,
        'diastolic': diastolic,
        'heartRate': heartRate,
      },
      metadata: {'age': age, 'isNormal': isNormal, ...additionalMetadata},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'values': values,
      'metadata': metadata,
    };
  }

  factory MeasurementRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MeasurementRecord(
      id: data['id'] ?? doc.id,
      userId: data['userId'] ?? '',
      type: MeasurementType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MeasurementType.heartRate,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      values: Map<String, dynamic>.from(data['values'] ?? {}),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  factory MeasurementRecord.fromMap(Map<String, dynamic> data, String docId) {
    return MeasurementRecord(
      id: data['id'] ?? docId,
      userId: data['userId'] ?? '',
      type: MeasurementType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MeasurementType.heartRate,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      values: Map<String, dynamic>.from(data['values'] ?? {}),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  int? get heartRate => values['heartRate'] as int?;
  int? get systolic => values['systolic'] as int?;
  int? get diastolic => values['diastolic'] as int?;
  int? get age => metadata['age'] as int?;
  bool? get isNormal => metadata['isNormal'] as bool?;

  String get displayValue {
    switch (type) {
      case MeasurementType.heartRate:
        return '${heartRate ?? '--'} BPM';
      case MeasurementType.bloodPressure:
        return '${systolic ?? '--'}/${diastolic ?? '--'} mmHg';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case MeasurementType.heartRate:
        return 'Heart Rate';
      case MeasurementType.bloodPressure:
        return 'Blood Pressure';
    }
  }

  String get statusText {
    if (isNormal == null) return 'Unknown';
    return isNormal! ? 'Normal' : 'Outside Range';
  }

  @override
  String toString() {
    return 'MeasurementRecord(id: $id, type: ${type.name}, timestamp: $timestamp, values: $values)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MeasurementRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class MeasurementGroup {
  final DateTime date;
  final List<MeasurementRecord> measurements;

  MeasurementGroup({required this.date, required this.measurements});

  String get dateString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final measurementDate = DateTime(date.year, date.month, date.day);

    if (measurementDate == today) {
      return 'Today';
    } else if (measurementDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
