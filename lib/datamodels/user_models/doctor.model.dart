// doctor model
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';

class DoctorModel {
  String? key;
  UserModel user;
  bool is_available;
  String title;
  List<MyPatientModel> my_patients = [];
  List<PatientModel> ong_patients = [];
  List<PatientModel> pen_patients = [];

  DoctorModel({
    this.key,
    required this.user,
    required this.is_available,
    required this.title,
    required this.my_patients,
    required this.ong_patients,
    required this.pen_patients,
  });

  factory DoctorModel.gen(String id) {
    return DoctorModel(
      key: id,
      user: UserModel.gen(id),
      is_available: true,
      title: '',
      my_patients: [],
      ong_patients: [],
      pen_patients: [],
    );
  }

  factory DoctorModel.fromMap(Map map) {
    var ty = map['user'].runtimeType;

    return DoctorModel(
      key: map['_id'] ?? '',
      user: (ty == String)
          ? UserModel.gen(map['user'])
          : UserModel.fromMap(map['user']),
      is_available: map['is_available'] ?? false,
      title: map['title'] ?? 'Physiotherapist',
      my_patients: map['my_patients'] != null
          ? List<MyPatientModel>.from(
              map['my_patients'].map((x) => MyPatientModel.fromMap(x)))
          : [],
      ong_patients: map['ong_patients'] != null
          ? List<PatientModel>.from(map['ong_patients'].map((x) {
              if (x.runtimeType == String) return PatientModel.gen(x);
              return PatientModel.fromMap(x);
            }))
          : [],
      pen_patients: map['pen_patients'] != null
          ? List<PatientModel>.from(map['pen_patients'].map((x) {
              if (x.runtimeType == String) return PatientModel.gen(x);
              return PatientModel.fromMap(x);
            }))
          : [],
    );
  }

  Map toJson() => {
        'id': key,
        'user': user.key,
        'is_available': is_available,
        'title': title,
      };
}

// doctor's patient model
class MyPatientModel {
  PatientModel? patient;
  int session_count;

  MyPatientModel({
    required this.patient,
    required this.session_count,
  });

  factory MyPatientModel.fromMap(Map map) {
    var pen = map['patient'].runtimeType;
    return MyPatientModel(
      patient: (pen == String) ? null : PatientModel.fromMap(map['patient']),
      session_count: map['session_count'] ?? 0,
    );
  }
  Map toJson() => {
        'patient': patient?.key,
        'session_count': session_count,
      };
}
