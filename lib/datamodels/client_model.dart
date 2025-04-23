// client details model
class ClientModel {
  String? key;

  String? id;
  String? reg_date;
  bool? user_status;

  String? sub_type;
  String? sub_plan;
  String? pt_plan;
  bool? sub_status;
  bool? pt_status;
  String? sub_date;
  String? pt_date;
  bool? boxing;
  String? bx_date;
  bool? sub_paused;
  String? paused_date;

  String? f_name;
  String? m_name;
  String? l_name;
  String? user_image;

  String? phone_1;
  String? phone_2;
  String? email;
  String? address;
  String? ig_user;
  String? fb_user;

  String? gender;
  String? dob;
  bool show_age;
  String? occupation;
  String program_type_select;
  String corporate_type_select;
  String company_name;

  String? hykau;
  String? hykau_others;

  String? hmo;
  String? hmo_id;

  int sub_income;

  bool baseline_done;

  bool physio_cl;
  String physio_key;

  bool indemnity_verified;

  // !
  int? max_days;

  String renew_dates;
  String registration_dates;

  bool registered;

  ClientModel({
    required this.key,
    required this.id,
    required this.reg_date,
    required this.user_status,
    required this.sub_type,
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
    required this.f_name,
    required this.m_name,
    required this.l_name,
    required this.user_image,
    required this.phone_1,
    required this.phone_2,
    required this.email,
    required this.address,
    required this.ig_user,
    required this.fb_user,
    required this.gender,
    required this.dob,
    required this.show_age,
    required this.occupation,
    required this.program_type_select,
    required this.corporate_type_select,
    required this.company_name,
    required this.hykau,
    required this.hykau_others,
    required this.hmo,
    required this.hmo_id,
    required this.sub_income,
    required this.baseline_done,
    required this.physio_cl,
    required this.physio_key,
    required this.indemnity_verified,
    // !
    this.max_days,
    required this.renew_dates,
    required this.registration_dates,
    required this.registered,
  });

  factory ClientModel.fromMap(String key, Map map) {
    return ClientModel(
      key: key,
      id: map['id'] ?? '',
      reg_date: map['reg_date'] ?? '',
      user_status: map['user_status'] ?? false,
      sub_type: map['sub_type'] ?? 'Individual',
      sub_plan: map['sub_plan'] ?? '',
      pt_plan: map['pt_plan'] ?? '',
      sub_status: map['sub_status'] ?? false,
      pt_status: map['pt_status'] ?? false,
      sub_date: map['sub_date'] ?? '',
      pt_date: map['pt_date'] ?? '',
      boxing: map['boxing'] ?? false,
      bx_date: map['bx_date'] ?? '',
      sub_paused: map['sub_paused'] ?? false,
      paused_date: map['paused_date'] ?? '',
      f_name: map['f_name'] ?? '',
      m_name: map['m_name'] ?? '',
      l_name: map['l_name'] ?? '',
      user_image: map['user_image'] ?? '',
      phone_1: map['phone_1'] ?? '',
      phone_2: map['phone_2'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      ig_user: map['ig_user'] ?? '',
      fb_user: map['fb_user'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] ?? '',
      show_age: map['show_age'] ?? true,
      occupation: map['occupation'] ?? '',
      program_type_select: map['program_type_select'] ?? '',
      corporate_type_select: map['corporate_type_select'] ?? '',
      company_name: map['company_name'] ?? '',
      hykau: map['hykau'] ?? '',
      hykau_others: map['hykau_others'] ?? '',
      hmo: map['hmo'] ?? 'No HMO',
      hmo_id: map['hmo_id'] ?? '',
      sub_income: map['sub_income'] ?? 0,
      baseline_done: map['baseline_done'] ?? false,
      physio_cl: map['physio_cl'] ?? false,
      physio_key: map['physio_key'] ?? '',
      indemnity_verified: map['indemnity_verified'] ?? false,
      renew_dates: map['renew_dates'] ?? map['renew_date'] ?? '',
      registration_dates: map['registration_dates'] ?? '',
      registered: map['registered'] ?? false,
    );
  }

  Map toJson() => {
        'key': key,
        'id': id,
        'reg_date': reg_date,
        'user_status': user_status,
        'sub_type': sub_type,
        'sub_plan': sub_plan,
        'pt_plan': pt_plan,
        'sub_status': sub_status,
        'pt_status': pt_status,
        'sub_date': sub_date,
        'pt_date': pt_date,
        'boxing': boxing,
        'f_name': f_name,
        'm_name': m_name,
        'l_name': l_name,
        'user_image': user_image,
        'phone_1': phone_1,
        'phone_2': phone_2,
        'email': email,
        'address': address,
        'ig_user': ig_user,
        'fb_user': fb_user,
        'gender': gender,
        'dob': dob,
        'show_age': show_age,
        'occupation': occupation,
        'program_type_select': program_type_select,
        'corporate_type_select': corporate_type_select,
        'company_name': company_name,
        'hykau': hykau,
        'hykau_others': hykau_others,
        'hmo': hmo,
        'hmo_id': hmo_id,
        'sub_paused': sub_paused,
        'sub_income': sub_income,
        'baseline_done': baseline_done,
        'physio_cl': physio_cl,
        'physio_key': physio_key,
      };
}

// client details for list
class ClientListModel {
  String? key;
  String? id;
  bool? user_status;
  String? sub_type;
  String? sub_plan;
  bool? sub_status;
  String? sub_date;
  bool? pt_status;
  String? pt_plan;
  String? pt_date;
  bool? boxing;
  String? bx_date;
  String? f_name;
  String? m_name;
  String? l_name;
  String? user_image;
  String? hmo;
  String? dob;
  bool? physio_cl;

  String reg_date;
  String renew_dates;
  String registration_dates;

  ClientListModel({
    required this.key,
    required this.id,
    required this.user_status,
    required this.sub_type,
    required this.sub_plan,
    required this.sub_status,
    required this.sub_date,
    required this.pt_status,
    required this.pt_plan,
    required this.pt_date,
    required this.boxing,
    required this.bx_date,
    required this.f_name,
    required this.m_name,
    required this.l_name,
    required this.user_image,
    required this.hmo,
    required this.dob,
    required this.physio_cl,
    required this.reg_date,
    required this.renew_dates,
    required this.registration_dates,
  });

  factory ClientListModel.fromMap(String key, Map map) {
    return ClientListModel(
      key: key,
      id: map['id'],
      user_status: map['user_status'],
      sub_type: map['sub_type'] ?? 'Individual',
      sub_plan: map['sub_plan'],
      sub_status: map['sub_status'],
      sub_date: map['sub_date'] ?? '',
      pt_status: map['pt_status'] ?? false,
      pt_plan: map['pt_plan'] ?? '',
      pt_date: map['pt_date'] ?? '',
      boxing: map['boxing'] ?? false,
      bx_date: map['bx_date'] ?? '',
      f_name: map['f_name'],
      m_name: map['m_name'],
      l_name: map['l_name'],
      user_image: map['user_image'],
      hmo: map['hmo'] ?? 'No HMO',
      dob: map['dob'] ?? '',
      physio_cl: map['physio_cl'] ?? false,
      reg_date: map['reg_date'] ?? '',
      renew_dates: map['renew_dates'] ?? map['renew_date'] ?? '',
      registration_dates: map['registration_dates'] ?? '',
    );
  }
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

// client details for sign in
class ClientSignInModel {
  String key;
  String id;
  String name;
  String user_image;
  bool sub_status;
  String sub_type;
  String sub_plan;
  bool pt_status;
  String pt_plan;
  Map last_activity;
  bool in_out;
  bool boxing;
  bool auto_sign_in;
  String? dob;
  int max_days;
  int days_in;
  bool sub_paused;
  String paused_date;

  String sub_date;
  String pt_date;
  String bx_date;

  ClientSignInModel({
    required this.key,
    required this.id,
    required this.name,
    required this.user_image,
    required this.sub_status,
    required this.sub_type,
    required this.sub_plan,
    required this.pt_status,
    required this.pt_plan,
    required this.last_activity,
    required this.in_out,
    required this.boxing,
    required this.auto_sign_in,
    required this.dob,
    required this.max_days,
    required this.days_in,
    required this.sub_paused,
    required this.paused_date,
    required this.sub_date,
    required this.pt_date,
    required this.bx_date,
  });

  factory ClientSignInModel.fromMap(String key, Map map) {
    return ClientSignInModel(
      key: key,
      id: map['id'] ?? '',
      sub_plan: map['sub_plan'] ?? '',
      pt_plan: map['pt_plan'] ?? '',
      sub_status: map['sub_status'] ?? false,
      sub_type: map['sub_type'] ?? 'Individual',
      pt_status: map['pt_status'] ?? false,
      name:
          '${map['f_name'] ?? ''} ${map['m_name'] ?? ''} ${map['l_name'] ?? ''}',
      user_image: map['user_image'] ?? '',
      last_activity: map['last_activity'] ?? {},
      in_out: map['in_out'] ?? true,
      boxing: map['boxing'] ?? false,
      auto_sign_in: map['auto_sign_in'] ?? false,
      dob: map['dob'] ?? '',
      max_days: map['max_days'] ?? 2,
      days_in: map['days_in'] ?? 0,
      sub_paused: map['sub_paused'] ?? false,
      paused_date: map['paused_date'] ?? '',
      sub_date: map['sub_date'] ?? '',
      pt_date: map['pt_date'] ?? '',
      bx_date: map['bx_date'] ?? '',
    );
  }

  Map toJson() => {
        'key': key,
        'id': id,
        'name': name,
        'user_image': user_image,
        'sub_status': sub_status,
        'sub_plan': sub_plan,
        'pt_status': pt_status,
        'pt_plan': pt_plan,
        'boxing': boxing,
        'dob': dob,
      };

  factory ClientSignInModel.fromMap_2(Map map) {
    return ClientSignInModel(
      key: map['key'],
      id: map['id'] ?? '',
      sub_plan: map['sub_plan'] ?? '',
      pt_plan: map['pt_plan'] ?? '',
      sub_status: map['sub_status'] ?? false,
      sub_type: map['sub_type'] ?? 'Individual',
      pt_status: map['pt_status'] ?? false,
      name: map['name'] ?? '',
      user_image: map['user_image'] ?? '',
      last_activity: map['last_activity'] ?? {},
      in_out: map['in_out'] ?? true,
      boxing: map['boxing'] ?? false,
      auto_sign_in: map['auto_sign_in'] ?? false,
      dob: map['dob'] ?? '',
      max_days: map['max_days'] ?? 2,
      days_in: map['days_in'] ?? 0,
      sub_paused: map['sub_paused'] ?? false,
      paused_date: map['paused_date'] ?? '',
      sub_date: map['sub_date'] ?? '',
      pt_date: map['pt_date'] ?? '',
      bx_date: map['bx_date'] ?? '',
    );
  }
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

  factory Sub_History_Model.fromMap(String key, Map map) {
    return Sub_History_Model(
      key: key,
      sub_plan: map['sub_plan'],
      sub_type: map['sub_type'],
      sub_date: map['sub_date'],
      exp_date: map['exp_date'],
      amount: map['amount'],
      extras_amount: map['extras_amount'] ?? 0,
      boxing: map['boxing'],
      pt_status: map['pt_status'],
      pt_plan: map['pt_plan'],
      hist_type: map['hist_type'],
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
