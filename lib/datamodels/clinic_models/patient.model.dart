import 'package:heritage_soft/datamodels/clinic_models/equipement.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';

class PatientModel {
  String? key;
  String patient_id;
  DateTime reg_date;
  bool user_status;
  String f_name;
  String m_name;
  String l_name;
  String user_image;
  String phone_1;
  String phone_2;
  String email;
  String address;
  String gender;
  String dob;
  String age;
  String occupation;
  String nature_of_work;
  String hykau;
  String hykau_others;
  String hmo;
  String hmo_id;
  bool baseline_done;
  List<SponsorModel> sponsors;
  String refferal_code;
  DoctorModel? current_doctor;
  DoctorModel? last_doctor;
  TreatmentInfoModel? treatment_info;
  ClinicInfoModel? clinic_info;
  ClinicVariable? clinic_variables;
  List<AssessmentInfoModel> assessment_info;
  List<ClinicHistoryModel> clinic_history;
  List<InvoiceModel> invoice_history;
  int total_amount_paid;

  PatientModel({
    this.key,
    required this.patient_id,
    required this.reg_date,
    required this.user_status,
    required this.f_name,
    required this.m_name,
    required this.l_name,
    required this.user_image,
    required this.phone_1,
    required this.phone_2,
    required this.email,
    required this.address,
    required this.gender,
    required this.dob,
    required this.age,
    required this.occupation,
    required this.nature_of_work,
    required this.hykau,
    required this.hykau_others,
    required this.hmo,
    required this.hmo_id,
    required this.baseline_done,
    required this.sponsors,
    required this.refferal_code,
    this.current_doctor,
    this.last_doctor,
    this.treatment_info,
    this.clinic_info,
    this.clinic_variables,
    this.assessment_info = const [],
    this.clinic_history = const [],
    this.invoice_history = const [],
    this.total_amount_paid = 0,
  });

  factory PatientModel.fromMap(Map map) {
    return PatientModel(
      key: map['_id'] ?? '',
      patient_id: map['patient_id'] ?? '',
      reg_date: DateTime.parse(map['reg_date']),
      user_status: map['user_status'] ?? false,
      f_name: map['f_name'] ?? '',
      m_name: map['m_name'] ?? '',
      l_name: map['l_name'] ?? '',
      user_image: map['user_image'] ?? '',
      phone_1: map['phone_1'] ?? '',
      phone_2: map['phone_2'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] ?? '',
      age: map['age'] ?? '',
      occupation: map['occupation'] ?? '',
      nature_of_work: map['nature_of_work'] ?? '',
      hykau: map['hykau'] ?? '',
      hykau_others: map['hykau_others'] ?? '',
      hmo: map['hmo'] ?? 'No HMO',
      hmo_id: map['hmo_id'] ?? 'No HMO',
      baseline_done: map['baseline_done'] ?? false,
      sponsors: List<SponsorModel>.from(
        map['sponsors']?.map((e) => SponsorModel.fromMap(e)) ??
            <SponsorModel>[],
      ),
      refferal_code: map['refferal_code'] ?? '',
      current_doctor: map['current_doctor'] == null
          ? null
          : DoctorModel.fromMap(map['current_doctor']),
      last_doctor: map['last_doctor'] == null
          ? null
          : DoctorModel.fromMap(map['last_doctor']),
      treatment_info: map['treatment_info'] == null
          ? null
          : TreatmentInfoModel.fromMap(map['treatment_info']),
      clinic_info: map['clinic_info'] == null
          ? null
          : ClinicInfoModel.fromMap(map['clinic_info']),
      clinic_variables: map['clinic_variables'] == null
          ? null
          : ClinicVariable.fromMap(map['clinic_variables']),
      assessment_info: List<AssessmentInfoModel>.from(
        map['assessment_info']
                ?.map((e) => AssessmentInfoModel.fromMap(e as Map)) ??
            <AssessmentInfoModel>[],
      ),
      clinic_history: List<ClinicHistoryModel>.from(
        map['clinic_history']
                ?.map((e) => ClinicHistoryModel.fromMap(e as Map)) ??
            <ClinicHistoryModel>[],
      ),
      invoice_history: List<InvoiceModel>.from(
        map['invoice_history']?.map((e) => InvoiceModel.fromMap(e as Map)) ??
            <InvoiceModel>[],
      ),
      total_amount_paid: map['total_amount_paid'] ?? 0,
    );
  }

  Map toJson() => {
        'id': key,
        'patient_id': patient_id,
        'reg_date': reg_date.toIso8601String(),
        'user_status': user_status,
        'f_name': f_name,
        'm_name': m_name,
        'l_name': l_name,
        'user_image': user_image,
        'phone_1': phone_1,
        'phone_2': phone_2,
        'email': email,
        'address': address,
        'gender': gender,
        'dob': dob,
        'age': age,
        'occupation': occupation,
        'nature_of_work': nature_of_work,
        'hykau': hykau,
        'hykau_others': hykau_others,
        'hmo': hmo,
        'hmo_id': hmo_id,
        'sponsors': sponsors.map((e) => e.toJson()).toList(),
        'refferal_code': refferal_code,
      };
}

class SponsorModel {
  String name;
  String phone;
  String address;
  String role;

  SponsorModel({
    required this.name,
    required this.phone,
    required this.address,
    required this.role,
  });

  factory SponsorModel.fromMap(Map map) {
    return SponsorModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Map toJson() => {
        'name': name,
        'phone': phone,
        'address': address,
        'role': role,
      };
}

// treatment model
class TreatmentInfoModel {
  String last_bp;
  String last_bp_p;
  DateTime? last_treatment_date;
  DateTime? last_treatment_date_p;
  DateTime? current_treatment_date;
  bool treatment_elapse;
  bool assessment_completed;
  bool ongoing_treatment;
  DateTime? assessment_date;
  bool assessment_paid;
  bool skip_assessment;

  TreatmentInfoModel({
    required this.last_bp,
    required this.last_bp_p,
    required this.last_treatment_date,
    required this.last_treatment_date_p,
    required this.current_treatment_date,
    required this.treatment_elapse,
    required this.assessment_completed,
    required this.ongoing_treatment,
    required this.assessment_date,
    required this.assessment_paid,
    required this.skip_assessment,
  });

  factory TreatmentInfoModel.gen() => TreatmentInfoModel(
        last_bp: '0',
        last_bp_p: '0',
        last_treatment_date: DateTime.now(),
        last_treatment_date_p: DateTime.now(),
        current_treatment_date: DateTime.now(),
        treatment_elapse: false,
        assessment_completed: true,
        ongoing_treatment: false,
        assessment_date: DateTime.now(),
        assessment_paid: false,
        skip_assessment: true,
      );

  factory TreatmentInfoModel.fromMap(Map map) => TreatmentInfoModel(
        last_bp: map['last_bp'] ?? '',
        last_bp_p: map['last_bp_p'] ?? '',
        last_treatment_date: map['last_treatment_date'] != null
            ? DateTime.parse(map['last_treatment_date'])
            : null,
        last_treatment_date_p: map['last_treatment_date_p'] != null
            ? DateTime.parse(map['last_treatment_date_p'])
            : null,
        current_treatment_date: map['current_treatment_date'] != null
            ? DateTime.parse(map['current_treatment_date'])
            : null,
        treatment_elapse: map['treatment_elapse'] ?? false,
        assessment_completed: map['assessment_completed'] ?? false,
        ongoing_treatment: map['ongoing_treatment'] ?? false,
        assessment_date: map['assessment_date'] != null
            ? DateTime.parse(map['assessment_date'])
            : null,
        assessment_paid: map['assessment_paid'] ?? false,
        skip_assessment: map['skip_assessment'] ?? false,
      );

  Map toJson({required String patientKey, required bool update}) => {
        'patient': patientKey,
        'update': update,
        'treatment_info': {
          'last_bp': last_bp,
          'last_bp_p': last_bp_p,
          'last_treatment_date': last_treatment_date?.toIso8601String(),
          'last_treatment_date_p': last_treatment_date_p?.toIso8601String(),
          'current_treatment_date': current_treatment_date?.toIso8601String(),
          'treatment_elapse': treatment_elapse,
          'assessment_completed': assessment_completed,
          'ongoing_treatment': ongoing_treatment,
          'assessment_date': assessment_date?.toIso8601String(),
          'assessment_paid': assessment_paid,
          'skip_assessment': skip_assessment,
        }
      };
}

class ClinicInfoModel {
  int total_session;
  String frequency;
  int completed_session;
  int paid_session;
  int cost_per_session;
  int amount_paid;
  int floating_amount;

  ClinicInfoModel({
    required this.total_session,
    required this.frequency,
    required this.completed_session,
    required this.paid_session,
    required this.cost_per_session,
    required this.amount_paid,
    required this.floating_amount,
  });

  factory ClinicInfoModel.gen() => ClinicInfoModel(
        total_session: 0,
        frequency: '',
        completed_session: 0,
        paid_session: 0,
        cost_per_session: 0,
        amount_paid: 0,
        floating_amount: 0,
      );

  factory ClinicInfoModel.fromMap(Map map) {
    return ClinicInfoModel(
      total_session: map['total_session'] ?? 0,
      frequency: map['frequency'] ?? '',
      completed_session: map['completed_session'] ?? 0,
      paid_session: map['paid_session'] ?? 0,
      cost_per_session: map['cost_per_session'] ?? 0,
      amount_paid: map['amount_paid'] ?? 0,
      floating_amount: map['floating_amount'] ?? 0,
    );
  }

  Map toJson({required String patientKey}) => {
        'patient': patientKey,
        'total_session': total_session,
        'frequency': frequency,
        'completed_session': completed_session,
        'paid_session': paid_session,
        'cost_per_session': cost_per_session,
        'amount_paid': amount_paid,
        'floating_amount': floating_amount,
      };
}

class ClinicVariable {
  bool can_treat;
  String treatment_duration;
  DateTime start_time;
  DateTime end_time;

  ClinicVariable({
    required this.can_treat,
    required this.treatment_duration,
    required this.start_time,
    required this.end_time,
  });

  factory ClinicVariable.fromMap(Map map) {
    return ClinicVariable(
      can_treat: map['can_treat'] ?? false,
      treatment_duration: map['treatment_duration'] ?? 0,
      start_time: DateTime.parse(map['start_time']),
      end_time: DateTime.parse(map['end_time']),
    );
  }

  Map toJson() {
    return {
      'can_treat': can_treat,
      'treatment_duration': treatment_duration,
      'start_time': start_time.toIso8601String(),
      'end_time': end_time.toIso8601String(),
    };
  }
}

class AssessmentInfoModel {
  String case_select;
  String? case_select_others;
  String case_description;
  String diagnosis;
  String case_type;
  String treatment_type;
  List<EquipmentModel> equipments;
  DateTime? assessment_date;

  AssessmentInfoModel({
    required this.case_select,
    required this.case_select_others,
    required this.case_description,
    required this.diagnosis,
    required this.case_type,
    required this.treatment_type,
    required this.equipments,
    required this.assessment_date,
  });

  factory AssessmentInfoModel.fromMap(Map map) {
    return AssessmentInfoModel(
      case_select: map['case_select'] ?? '',
      case_select_others: map['case_select_others'] ?? null,
      case_description: map['case_description'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      case_type: map['case_type'] ?? '',
      treatment_type: map['treatment_type'] ?? '',
      equipments: List<EquipmentModel>.from(
        map['equipment']?.map((e) => EquipmentModel.fromJson(e as Map)) ??
            <EquipmentModel>[],
      ),
      assessment_date: map['assessment_date'] != null
          ? DateTime.parse(map['assessment_date'])
          : null,
    );
  }

  Map toJson({required String patientKey}) => {
        'case_select': case_select,
        'case_select_others': case_select_others,
        'case_description': case_description,
        'diagnosis': diagnosis,
        'case_type': case_type,
        'treatment_type': treatment_type,
        'equipment': equipments.map((e) => e.key).toList(),
        'assessment_date': assessment_date?.toIso8601String(),
        'patient': patientKey,
      };
}

class ClinicHistoryModel {
  String history_id;
  String hist_type;
  int amount;
  int? amount_b4_discount;
  DateTime date;
  int session_paid;
  int cost_p_session;
  int old_float;
  int new_float;
  String session_frequency;

  ClinicHistoryModel({
    required this.history_id,
    required this.hist_type,
    required this.date,
    required this.amount,
    required this.amount_b4_discount,
    required this.session_paid,
    required this.cost_p_session,
    required this.old_float,
    required this.new_float,
    required this.session_frequency,
  });

  factory ClinicHistoryModel.fromMap(Map map) {
    return ClinicHistoryModel(
      history_id: map['history_id'] ?? '',
      hist_type: map['hist_type'] ?? '',
      amount: map['amount'] ?? 0,
      amount_b4_discount: map['amount_b4_discount'] ?? 0,
      date: DateTime.parse(map['date']),
      session_paid: map['session_paid'] ?? 0,
      cost_p_session: map['cost_p_session'] ?? 0,
      old_float: map['old_float'] ?? 0,
      new_float: map['new_float'] ?? 0,
      session_frequency: map['session_frequency'] ?? '',
    );
  }

  Map toJson({required String patientKey}) => {
        'patient': patientKey,
        'clinic_history': {
          'history_id': history_id,
          'hist_type': hist_type,
          'amount': amount,
          'amount_b4_discount': amount_b4_discount,
          'date': date.toIso8601String(),
          'session_paid': session_paid,
          'cost_p_session': cost_p_session,
          'old_float': old_float,
          'new_float': new_float,
          'session_frequency': session_frequency,
        }
      };
}

class InvoiceModel {
  String invoice_id;
  String invoice_type;
  double? amount;
  double? discount;
  DateTime date;
  int total_session;
  String frequency;
  int completed_session;
  int paid_session;
  double cost_per_session;
  double amount_paid;
  double floating_amount;

  InvoiceModel({
    required this.invoice_id,
    required this.invoice_type,
    this.amount,
    this.discount,
    required this.date,
    required this.total_session,
    required this.frequency,
    required this.completed_session,
    required this.paid_session,
    required this.cost_per_session,
    required this.amount_paid,
    required this.floating_amount,
  });

  factory InvoiceModel.fromMap(Map map) {
    return InvoiceModel(
      invoice_id: map['invoice_id'] ?? '',
      invoice_type: map['invoice_type'] ?? '',
      amount: map['amount']?.toDouble(),
      discount: map['discount']?.toDouble(),
      date: DateTime.parse(map['date']),
      total_session: map['total_session']?.toInt() ?? 0,
      frequency: map['frequency'] ?? '',
      completed_session: map['completed_session']?.toInt() ?? 0,
      paid_session: map['paid_session']?.toInt() ?? 0,
      cost_per_session: map['cost_per_session']?.toDouble() ?? 0,
      amount_paid: map['amount_paid']?.toDouble() ?? 0,
      floating_amount: map['floating_amount']?.toDouble() ?? 0,
    );
  }

  Map toJson() => {
        'invoice_id': invoice_id,
        'invoice_type': invoice_type,
        'amount': amount,
        'discount': discount,
        'date': date.toIso8601String(),
        'total_session': total_session,
        'frequency': frequency,
        'completed_session': completed_session,
        'paid_session': paid_session,
        'cost_per_session': cost_per_session,
        'amount_paid': amount_paid,
        'floating_amount': floating_amount,
      };
}
