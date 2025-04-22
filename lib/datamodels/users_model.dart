

// staff model
class StaffModel {
  String key;
  String f_name;
  String m_name;
  String l_name;
  String user_image;
  String user_id;
  bool user_status;
  String role;
  String section;
  bool auto_sign_in;
  bool in_out;
  bool full_access;
  Map? last_activity;
  bool fresh_day;
  String app_role;

  StaffModel({
    required this.key,
    required this.user_id,
    required this.f_name,
    required this.m_name,
    required this.l_name,
    required this.user_image,
    required this.user_status,
    required this.role,
    required this.section,
    this.auto_sign_in = false,
    this.in_out = true,
    this.last_activity,
    this.full_access = false,
    this.fresh_day = true,
    required this.app_role,
  });

  factory StaffModel.fromMap(String key, Map map) {
    return StaffModel(
      key: key,
      user_id: map['user_id'] ?? '',
      f_name: map['f_name'] ?? '',
      m_name: map['m_name'] ?? '',
      l_name: map['l_name'] ?? '',
      user_image: map['user_image'] ?? '',
      user_status: map['user_status'] ?? false,
      role: map['role'] ?? '',
      section: map['section'] ?? '',
      auto_sign_in: map['auto_sign_in'] ?? false,
      in_out: map['in_out'] ?? true,
      full_access: map['full_access'] ?? false,
      last_activity: map['last_activity'] ?? {},
      fresh_day: map['fresh_day'] ?? true,
      app_role: map['app_role'] ?? 'None',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': user_id,
        'f_name': f_name,
        'm_name': m_name,
        'l_name': l_name,
        'user_image': user_image,
        'user_status': user_status,
        'role': role,
        'section': section,
        'app_role': app_role,
      };
}


