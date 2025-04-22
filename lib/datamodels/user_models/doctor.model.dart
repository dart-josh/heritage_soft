// doctor model
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';

class DoctorModel {
  String? key;
  UserModel user;
  bool is_available;
  String title;
  List<MyPatientModel> my_patients = [];
  List<TreatmentPatientModel> ong_patients = [];
  List<TreatmentPatientModel> pen_patients = [];

  DoctorModel({
    this.key,
    required this.user,
    required this.is_available,
    required this.title,
    required this.my_patients,
    required this.ong_patients,
    required this.pen_patients,
  });

  factory DoctorModel.fromMap(Map map) {
    return DoctorModel(
      key: map['_id'] ?? '',
      user: UserModel.fromMap(map['user']),
      is_available: map['is_available'] ?? false,
      title: map['title'] ?? 'Physiotherapist',
      my_patients: map['my_patients'] != null
          ? List<MyPatientModel>.from(
              map['my_patients'].map((x) => MyPatientModel.fromMap(x)))
          : [],
      ong_patients: map['ong_patients'] != null
          ? List<TreatmentPatientModel>.from(
              map['ong_patients'].map((x) => TreatmentPatientModel.fromMap(x)))
          : [],
      pen_patients: map['pen_patients'] != null
          ? List<TreatmentPatientModel>.from(
              map['pen_patients'].map((x) => TreatmentPatientModel.fromMap(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': key,
        'user': user.key,
        'is_available': is_available,
        'title': title,
      };
}

// doctor's patient model
class TreatmentPatientModel {
  PatientModel patient;
  String treatment_type;
  String treatment_duration;

  TreatmentPatientModel({
    required this.patient,
    required this.treatment_type,
    required this.treatment_duration,
  });

  factory TreatmentPatientModel.fromMap(Map map) {
    return TreatmentPatientModel(
      patient: PatientModel.fromMap(map['patient']),
      treatment_type: map['treatment_type'] ?? 'Physiotherapy',
      treatment_duration: map['treatment_duration'] ?? '30 minutes',
    );
  }

  Map<String, dynamic> toJson() => {
        'patient': patient.key,
        'treatment_type': treatment_type,
        'treatment_duration': treatment_duration,
      };
}

// doctor's patient model
class MyPatientModel {
  PatientModel patient;
  int session_count;

  MyPatientModel({
    required this.patient,
    required this.session_count,
  });

  factory MyPatientModel.fromMap(Map map) {
    return MyPatientModel(
      patient: PatientModel.fromMap(map['patient']),
      session_count: map['session_count'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() => {
        'patient': patient.key,
        'session_count': session_count,
      };
}
