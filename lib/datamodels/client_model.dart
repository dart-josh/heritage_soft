

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

