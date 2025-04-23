class UserModel {
  String? key;
  String user_id;
  String f_name;
  String l_name;
  String m_name;
  String user_image;
  bool user_status;
  String user_role;
  String section;
  bool full_access;
  Map last_activity;
  bool fresh_day;
  String app_role;
  bool can_sign_in;

  UserModel({
    this.key,
    required this.user_id,
    required this.f_name,
    required this.l_name,
    required this.m_name,
    required this.user_image,
    required this.user_status,
    required this.user_role,
    required this.section,
    required this.full_access,
    required this.last_activity,
    required this.fresh_day,
    required this.app_role,
    required this.can_sign_in,
  });

  factory UserModel.fromMap(Map map) {
    return UserModel(
      key: map['_id'],
      user_id: map['user_id'] ?? '',
      f_name: map['f_name'] ?? '',
      l_name: map['l_name'] ?? '',
      m_name: map['m_name'] ?? '',
      user_image: map['user_image'] ?? '',
      user_status: map['user_status'] ?? false,
      user_role: map['user_role'] ?? '',
      section: map['section'] ?? '',
      full_access: map['full_access'] ?? false,
      last_activity: map['last_activity'] ?? {},
      fresh_day: map['fresh_day'] ?? true,
      app_role: map['app_role'] ?? 'None',
      can_sign_in: map['can_sign_in'] ?? false,
    );
  }

  Map toJson() => {
        'id': key,
        'user_id': user_id,
        'f_name': f_name,
        'l_name': l_name,
        'm_name': m_name,
        'user_image': user_image,
        'user_status': user_status,
        'user_role': user_role,
        'section': section,
        'full_access': full_access,
        'can_sign_in': can_sign_in,
        'app_role': app_role,
      };
}
