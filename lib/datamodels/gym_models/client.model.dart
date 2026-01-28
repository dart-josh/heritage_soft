import 'package:heritage_soft/datamodels/gym_models/client_health.model.dart';

class ClientModel {
  String? key;

  // root
  String? clientId;
  String? regDate;
  bool? userStatus;

  // subscription details
  String? subType;
  String? subPlan;
  bool? subStatus;
  String? subDate;

  String? ptPlan;
  bool? ptStatus;
  String? ptDate;

  bool? boxing;
  String? bxDate;

  bool? subPaused;
  String? pausedDate;

  // client details
  String? fName;
  String? mName;
  String? lName;
  String? userImage;

  // contact details
  String? phone1;
  String? phone2;
  String? email;
  String? address;
  String? igUser;
  String? fbUser;

  // personal details
  String? gender;
  String? dob;
  bool showAge;
  String? occupation;

  // program details
  String? programTypeSelect;
  String? corporateTypeSelect;
  String? companyName;
  String? hmo;
  String? hmoId;
  String? hykau;
  String? hykauOthers;

  // misc
  int subIncome;
  bool physioCl;
  String? physioKey;
  bool indemnityVerified;

  int? maxDays;
  String? renewDates;
  String? registrationDates;
  bool registered;

  bool baselineDone;
  List<G_HealthModel>? healthData;
  List<Sub_History_Model>? sub_history;

  ClientModel({
    this.key,
    this.clientId,
    this.regDate,
    this.userStatus,
    this.subType,
    this.subPlan,
    this.subStatus,
    this.subDate,
    this.ptPlan,
    this.ptStatus,
    this.ptDate,
    this.boxing,
    this.bxDate,
    this.subPaused,
    this.pausedDate,
    this.fName,
    this.mName,
    this.lName,
    this.userImage,
    this.phone1,
    this.phone2,
    this.email,
    this.address,
    this.igUser,
    this.fbUser,
    this.gender,
    this.dob,
    this.showAge = true,
    this.occupation,
    this.programTypeSelect,
    this.corporateTypeSelect,
    this.companyName,
    this.hmo,
    this.hmoId,
    this.hykau,
    this.hykauOthers,
    this.subIncome = 0,
    this.baselineDone = false,
    this.physioCl = false,
    this.physioKey,
    this.indemnityVerified = false,
    this.maxDays,
    this.renewDates,
    this.registrationDates,
    this.registered = false,
    this.healthData,
    this.sub_history,
  });

  /// 🔁 FROM MAP (Mongo / API / Firebase)
  factory ClientModel.fromMap(Map<String, dynamic> map) {
    final client = map['client_details'] ?? {};
    final contact = map['contact_details'] ?? {};
    final personal = map['personal_details'] ?? {};
    final sub = map['sub_details'] ?? {};
    final program = map['program_details'] ?? {};

    return ClientModel(
      key: map['_id'] ?? "",
      clientId: map['client_id'],
      regDate: map['reg_date'],
      userStatus: map['user_status'] ?? false,
      subType: sub['sub_type'] ?? 'Individual',
      subPlan: sub['sub_plan'],
      subStatus: sub['sub_status'] ?? false,
      subDate: sub['sub_date'],
      ptPlan: sub['pt_plan'],
      ptStatus: sub['pt_status'] ?? false,
      ptDate: sub['pt_date'],
      boxing: sub['boxing'] ?? false,
      bxDate: sub['bx_date'],
      subPaused: sub['sub_paused'] ?? false,
      pausedDate: sub['paused_date'],
      fName: client['f_name'] ?? "",
      mName: client['m_name'] ?? "",
      lName: client['l_name'] ?? "",
      userImage: map['user_image'] ?? "",
      phone1: contact['phone_1'] ?? "",
      phone2: contact['phone_2'] ?? "",
      email: contact['email'] ?? "",
      address: contact['address'] ?? "",
      igUser: contact['ig_user'] ?? "",
      fbUser: contact['fb_user'] ?? "",
      gender: personal['gender'] ?? "",
      dob: personal['dob'] ?? "",
      showAge: personal['show_age'] ?? true,
      occupation: personal['occupation'] ?? "",
      programTypeSelect: program['program_type_select'] ?? "",
      corporateTypeSelect: program['corporate_type_select'] ?? "",
      companyName: program['company_name'] ?? "",
      hmo: program['hmo'] ?? "",
      hmoId: program['hmo_id'] ?? "",
      hykau: program['hykau'] ?? "",
      hykauOthers: program['hykau_others'] ?? "",
      subIncome: map['sub_income'] ?? 0,
      baselineDone: map['baseline_done'] ?? false,
      physioCl: map['physio_cl'] ?? false,
      physioKey: map['physio_key'] ?? "",
      indemnityVerified: map['indemnity_verified'] ?? false,
      maxDays: map['max_days'] ?? 0,
      renewDates: map['renew_dates'] ?? "",
      registrationDates: map['registration_dates'] ?? "",
      registered: map['registered'] ?? false,
      healthData: map['healthData'] ?? [],
      sub_history: List<Sub_History_Model>.from(
        map['sub_history']?.map((e) => Sub_History_Model.fromMap(e)) ??
            <Sub_History_Model>[],
      ),
    );
  }

  /// 🔼 TO JSON (send back to API)
  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'reg_date': regDate,
        'user_status': userStatus,
        'user_image': userImage,
        'client_details': {
          'f_name': fName,
          'm_name': mName,
          'l_name': lName,
        },
        'contact_details': {
          'phone_1': phone1,
          'phone_2': phone2,
          'email': email,
          'address': address,
          'ig_user': igUser,
          'fb_user': fbUser,
        },
        'personal_details': {
          'gender': gender,
          'dob': dob,
          'show_age': showAge,
          'occupation': occupation,
        },
        'sub_details': {
          'sub_type': subType,
          'sub_plan': subPlan,
          'sub_status': subStatus,
          'sub_date': subDate,
          'pt_plan': ptPlan,
          'pt_status': ptStatus,
          'pt_date': ptDate,
          'boxing': boxing,
          'bx_date': bxDate,
          'sub_paused': subPaused,
          'paused_date': pausedDate,
        },
        'program_details': {
          'program_type_select': programTypeSelect,
          'corporate_type_select': corporateTypeSelect,
          'company_name': companyName,
          'hmo': hmo,
          'hmo_id': hmoId,
          'hykau': hykau,
          'hykau_others': hykauOthers,
        },
        'sub_income': subIncome,
        'baseline_done': baselineDone,
        'physio_cl': physioCl,
        'physio_key': physioKey,
        'indemnity_verified': indemnityVerified,
        'max_days': maxDays,
        'renew_dates': renewDates,
        'registration_dates': registrationDates,
        'registered': registered,
      };
}

// client details for subscription
class RenewalModel {
  String key;
  String id;
  String reg_date;
  String user_image;
  String name;
  String sub_plan;
  String pt_plan;
  bool pt_status;
  bool boxing;
  String sub_type;
  String? hmo_name;
  int sub_income;
  String program_type;
  String renew_dates;
  String registration_dates;
  String sub_date;
  bool registered;

  RenewalModel({
    required this.key,
    required this.id,
    required this.reg_date,
    required this.registration_dates,
    required this.user_image,
    required this.name,
    required this.sub_plan,
    required this.pt_plan,
    required this.pt_status,
    required this.boxing,
    required this.sub_type,
    required this.hmo_name,
    required this.sub_income,
    required this.program_type,
    required this.renew_dates,
    required this.sub_date,
    required this.registered,
  });
}

// client subscription details
class ClientSubModel {
  String sub_plan;
  String pt_plan;
  bool sub_status;
  bool pt_status;
  String sub_date;
  String pt_date;
  bool boxing;
  String bx_date;
  bool sub_paused;
  String paused_date;

  ClientSubModel({
    required this.sub_plan,
    required this.pt_plan,
    required this.sub_status,
    required this.pt_status,
    required this.sub_date,
    required this.pt_date,
    required this.boxing,
    required this.bx_date,
    required this.sub_paused,
    required this.paused_date,
  });
}

// client sub history
class Sub_History_Model {
  String key;
  String sub_plan;
  String sub_type;
  String sub_date;
  String exp_date;
  int amount;
  int extras_amount;

  bool boxing;
  bool pt_status;
  String pt_plan;

  String hist_type;

  String? time_stamp;
  String history_id;

  int? sub_amount_b4_discount;

  Sub_History_Model({
    required this.key,
    required this.sub_plan,
    required this.sub_type,
    required this.sub_date,
    required this.exp_date,
    required this.amount,
    required this.extras_amount,
    required this.boxing,
    required this.pt_status,
    required this.pt_plan,
    required this.hist_type,
    required this.history_id,
    this.time_stamp,
    this.sub_amount_b4_discount,
  });

  factory Sub_History_Model.fromMap(Map map) {
    return Sub_History_Model(
      key: map['_id'] ?? "",
      sub_plan: map['sub_plan'] ?? "",
      sub_type: map['sub_type'] ?? "",
      sub_date: map['sub_date'] ?? "",
      exp_date: map['exp_date'] ?? "",
      amount: map['amount'] ?? 0,
      extras_amount: map['extras_amount'] ?? 0,
      boxing: map['boxing'] ?? false,
      pt_status: map['pt_status'] ?? false,
      pt_plan: map['pt_plan'] ?? '',
      hist_type: map['hist_type'] ?? '',
      time_stamp: map['time_stamp'] ?? null,
      history_id: map['history_id'] ?? '',
      sub_amount_b4_discount: map['sub_amount_b4_discount'] ?? null,
    );
  }

  Map toJson() => {
        'sub_plan': sub_plan,
        'sub_type': sub_type,
        'sub_date': sub_date,
        'exp_date': exp_date,
        'amount': amount,
        'extras_amount': extras_amount,
        'boxing': boxing,
        'pt_status': pt_status,
        'pt_plan': pt_plan,
        'hist_type': hist_type,
        'time_stamp': DateTime.now().toString(),
        'history_id': history_id,
        'sub_amount_b4_discount': sub_amount_b4_discount,
      };
}
