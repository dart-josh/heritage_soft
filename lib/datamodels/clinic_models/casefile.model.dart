import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';

class CaseFileModel {
  String? key;
  PatientModel patient;
  DoctorModel doctor;
  String bp_reading;
  String note;
  String remarks;
  String case_type;

  DateTime? treatment_date;
  DateTime? start_time;
  DateTime? end_time;
  String treatment_decision;
  String refered_decision;
  String other_decision;

  bool expanded;

  CaseFileModel({
    this.key,
    required this.patient,
    required this.doctor,
    required this.bp_reading,
    required this.note,
    required this.remarks,
    required this.case_type,
    required this.treatment_date,
    required this.start_time,
    required this.end_time,
    required this.treatment_decision,
    required this.refered_decision,
    required this.other_decision,
    this.expanded = false,
  });

  factory CaseFileModel.open({required PatientModel patient, required DoctorModel doctor}) => CaseFileModel(
        patient: patient,
        doctor: doctor,
        bp_reading: '',
        note: '',
        remarks: '',
        case_type: '',
        treatment_date: DateTime.now(),
        start_time: DateTime.now(),
        end_time: null,
        treatment_decision: '',
        refered_decision: '',
        other_decision: '',
      );

  factory CaseFileModel.fromMap(Map map) => CaseFileModel(
        key: map['_id'] ?? '',
        patient: PatientModel.fromMap(map['patient'] ?? {}),
        doctor: DoctorModel.fromMap(map['doctor'] ?? {}),
        bp_reading: map['bp_reading'] ?? '',
        note: map['note'] ?? '',
        remarks: map['remarks'] ?? '',
        case_type: map['case_type'] ?? '',
        treatment_date: map['treatment_date'] != null
            ? DateTime.parse(map['treatment_date'])
            : null,
        start_time: map['start_time'] != null
            ? DateTime.parse(map['start_time'])
            : null,
        end_time:
            map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
        treatment_decision: map['treatment_decision'] ?? '',
        refered_decision: map['refered_decision'] ?? '',
        other_decision: map['other_decision'] ?? '',
      );

  Map toJson_open() => {
        // 'id': key,
        'patient': patient.key,
        'doctor': doctor.key,
        'bp_reading': bp_reading,
        'note': note,
        'remarks': remarks,
        'case_type': case_type,
        'treatment_date': treatment_date?.toIso8601String(),
        'treatment_decision': treatment_decision,
        'refered_decision': refered_decision,
        'other_decision': other_decision,
        'start_time': start_time?.toIso8601String(),
        // 'end_time': end_time?.toIso8601String(),
      };

      Map toJson_update() => {
        'id': key,
        // 'patient': patient.key,
        // 'doctor': doctor.key,
        'bp_reading': bp_reading,
        'note': note,
        'remarks': remarks,
        // 'case_type': case_type,
        // 'treatment_date': treatment_date?.toIso8601String(),
        'treatment_decision': treatment_decision,
        'refered_decision': refered_decision,
        'other_decision': other_decision,
        'start_time': start_time?.toIso8601String(),
        'end_time': end_time?.toIso8601String(),
      };
}
