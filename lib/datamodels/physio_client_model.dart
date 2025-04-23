// physio client details
class PhysioClientModel {
  String? key;

  String? id;
  String? reg_date;
  bool? user_status;

  String? f_name;
  String? m_name;
  String? l_name;
  String? user_image;

  String? phone_1;
  String? phone_2;
  String? email;
  String? address;

  String? gender;
  String dob;
  String age;
  String? occupation;
  String? nature_of_work;

  String? hykau;
  String? hykau_others;

  String? hmo;

  bool baseline_done;

  String sponsor_name;
  String sponsor_phone;
  String sponsor_addr;
  String sponsor_role;
  bool sponsor;
  String refferal_code;

  String current_doctor;

  PhysioClientModel({
    required this.key,
    required this.id,
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
    required this.baseline_done,
    required this.sponsor_name,
    required this.sponsor_phone,
    required this.sponsor_addr,
    required this.sponsor_role,
    required this.sponsor,
    required this.refferal_code,
    required this.current_doctor,
  });

  factory PhysioClientModel.fromMap(String key, Map map) {
    return PhysioClientModel(
      key: key,
      id: map['id'] ?? '',
      reg_date: map['reg_date'] ?? '',
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
      baseline_done: map['baseline_done'] ?? false,
      sponsor_name: map['sponsor_name'] ?? '',
      sponsor_phone: map['sponsor_phone'] ?? '',
      sponsor_addr: map['sponsor_addr'] ?? '',
      sponsor_role: map['sponsor_role'] ?? '',
      sponsor: map['sponsor'] ?? false,
      refferal_code: map['refferal_code'] ?? '',
      current_doctor: map['current_doctor'] ?? '',
    );
  }

  Map toJson() => {
        'key': key,
        'id': id,
        'reg_date': reg_date,
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
        'baseline_done': baseline_done,
        'sponsor_name': sponsor_name,
        'sponsor_phone': sponsor_phone,
        'sponsor_addr': sponsor_addr,
        'sponsor_role': sponsor_role,
        'sponsor': sponsor,
        'refferal_code': refferal_code,
      };
}

// physio sponsor details
// class SponsorModel {
//   String? key;
//   String sponsor_name;
//   String sponsor_phone;
//   String sponsor_addr;
//   String sponsor_role;

//   SponsorModel({
//     this.key,
//     required this.sponsor_name,
//     required this.sponsor_phone,
//     required this.sponsor_addr,
//     required this.sponsor_role,
//   });

//   factory SponsorModel.fromMap(String key, Map map) => SponsorModel(
//         key: key,
//         sponsor_name: map['sponsor_name'] ?? '',
//         sponsor_phone: map['sponsor_phone'] ?? '',
//         sponsor_addr: map['sponsor_addr'] ?? '',
//         sponsor_role: map['sponsor_role'] ?? '',
//       );

//   Map toJson() => {
//         'sponsor_name': sponsor_name,
//         'sponsor_phone': sponsor_phone,
//         'sponsor_addr': sponsor_addr,
//         'sponsor_role': sponsor_role,
//       };
// }

// physio client health details
class PhysioHealthModel {
  String height;
  String weight;
  String ideal_weight;
  String fat_rate;
  String weight_gap;
  String weight_target;
  String waist;
  String arm;
  String chest;
  String thighs;
  String hips;
  String pulse_rate;
  String blood_pressure;

  String chl_ov;
  String chl_nv;
  String chl_rm;
  String hdl_ov;
  String hdl_nv;
  String hdl_rm;
  String ldl_ov;
  String ldl_nv;
  String ldl_rm;
  String trg_ov;
  String trg_nv;
  String trg_rm;

  bool blood_sugar;

  String eh_finding;
  String eh_recommend;
  String sh_finding;
  String sh_recommend;
  String ah_finding;
  String ah_recommend;
  String other_finding;
  String other_recommend;

  String ft_obj_1;
  String ft_obj_2;
  String ft_obj_3;
  String ft_obj_4;
  String ft_obj_5;

  String key;
  String date;
  bool done;

  PhysioHealthModel({
    required this.height,
    required this.weight,
    required this.ideal_weight,
    required this.fat_rate,
    required this.weight_gap,
    required this.weight_target,
    required this.waist,
    required this.arm,
    required this.chest,
    required this.thighs,
    required this.hips,
    required this.pulse_rate,
    required this.blood_pressure,
    required this.chl_ov,
    required this.chl_nv,
    required this.chl_rm,
    required this.hdl_ov,
    required this.hdl_nv,
    required this.hdl_rm,
    required this.ldl_ov,
    required this.ldl_nv,
    required this.ldl_rm,
    required this.trg_ov,
    required this.trg_nv,
    required this.trg_rm,
    required this.blood_sugar,
    required this.eh_finding,
    required this.eh_recommend,
    required this.sh_finding,
    required this.sh_recommend,
    required this.ah_finding,
    required this.ah_recommend,
    required this.other_finding,
    required this.other_recommend,
    required this.ft_obj_1,
    required this.ft_obj_2,
    required this.ft_obj_3,
    required this.ft_obj_4,
    required this.ft_obj_5,
    required this.key,
    required this.date,
    required this.done,
  });

  factory PhysioHealthModel.fromMap(String key, Map map) {
    return PhysioHealthModel(
      height: map['height'] ?? '',
      weight: map['weight'] ?? '',
      ideal_weight: map['ideal_weight'] ?? '',
      fat_rate: map['fat_rate'] ?? '',
      weight_gap: map['weight_gap'] ?? '',
      weight_target: map['weight_target'] ?? '',
      waist: map['waist'] ?? '',
      arm: map['arm'] ?? '',
      chest: map['chest'] ?? '',
      thighs: map['thighs'] ?? '',
      hips: map['hips'] ?? '',
      pulse_rate: map['pulse_rate'] ?? '',
      blood_pressure: map['blood_pressure'] ?? '',
      chl_ov: map['chl_ov'] ?? '',
      chl_nv: map['chl_nv'] ?? '',
      chl_rm: map['chl_rm'] ?? '',
      hdl_ov: map['hdl_ov'] ?? '',
      hdl_nv: map['hdl_nv'] ?? '',
      hdl_rm: map['hdl_rm'] ?? '',
      ldl_ov: map['ldl_ov'] ?? '',
      ldl_nv: map['ldl_nv'] ?? '',
      ldl_rm: map['ldl_rm'] ?? '',
      trg_ov: map['trg_ov'] ?? '',
      trg_nv: map['trg_nv'] ?? '',
      trg_rm: map['trg_rm'] ?? '',
      blood_sugar: map['blood_sugar'] ?? false,
      eh_finding: map['eh_finding'] ?? '',
      eh_recommend: map['eh_recommend'] ?? '',
      sh_finding: map['sh_finding'] ?? '',
      sh_recommend: map['sh_recommend'] ?? '',
      ah_finding: map['ah_finding'] ?? '',
      ah_recommend: map['ah_recommend'] ?? '',
      other_finding: map['other_finding'] ?? '',
      other_recommend: map['other_recommend'] ?? '',
      ft_obj_1: map['ft_obj_1'] ?? '',
      ft_obj_2: map['ft_obj_2'] ?? '',
      ft_obj_3: map['ft_obj_3'] ?? '',
      ft_obj_4: map['ft_obj_4'] ?? '',
      ft_obj_5: map['ft_obj_5'] ?? '',
      key: key,
      date: map['date'] ?? '',
      done: map['done'] ?? false,
    );
  }

  Map toJson() => {
        'height': height,
        'weight': weight,
        'ideal_weight': ideal_weight,
        'fat_rate': fat_rate,
        'weight_gap': weight_gap,
        'weight_target': weight_target,
        'waist': waist,
        'arm': arm,
        'chest': chest,
        'thighs': thighs,
        'hips': hips,
        'pulse_rate': pulse_rate,
        'blood_pressure': blood_pressure,
        'chl_ov': chl_ov,
        'chl_nv': chl_nv,
        'chl_rm': chl_rm,
        'hdl_ov': hdl_ov,
        'hdl_nv': hdl_nv,
        'hdl_rm': hdl_rm,
        'ldl_ov': ldl_ov,
        'ldl_nv': ldl_nv,
        'ldl_rm': ldl_rm,
        'trg_ov': trg_ov,
        'trg_nv': trg_nv,
        'trg_rm': trg_rm,
        'blood_sugar': blood_sugar,
        'eh_finding': eh_finding,
        'eh_recommend': eh_recommend,
        'sh_finding': sh_finding,
        'sh_recommend': sh_recommend,
        'ah_finding': ah_finding,
        'ah_recommend': ah_recommend,
        'other_finding': other_finding,
        'other_recommend': other_recommend,
        'ft_obj_1': ft_obj_1,
        'ft_obj_2': ft_obj_2,
        'ft_obj_3': ft_obj_3,
        'ft_obj_4': ft_obj_4,
        'ft_obj_5': ft_obj_5,
        'date': date,
        'done': done,
      };
}

// grouped physio client health details
class G_PhysioHealthModel {
  String key;
  PhysioHealthModel data;

  G_PhysioHealthModel({
    required this.key,
    required this.data,
  });
}

// physio client details for list
class PhysioClientListModel {
  String? key;
  String? id;
  bool? user_status;
  String? f_name;
  String? m_name;
  String? l_name;
  String? user_image;
  String? hmo;
  String? dob;
  bool pending_treatment;
  bool ongoing_treatment;
  int treatment_sessions;
  bool baseline_done;

  PhysioClientListModel({
    required this.key,
    required this.id,
    required this.user_status,
    required this.f_name,
    required this.m_name,
    required this.l_name,
    required this.user_image,
    required this.hmo,
    required this.dob,
    this.pending_treatment = false,
    this.ongoing_treatment = false,
    this.treatment_sessions = 0,
    required this.baseline_done,
  });

  factory PhysioClientListModel.fromMap(String key, Map map) {
    return PhysioClientListModel(
      key: key,
      id: map['id'],
      user_status: map['user_status'],
      f_name: map['f_name'],
      m_name: map['m_name'],
      l_name: map['l_name'],
      user_image: map['user_image'],
      hmo: map['hmo'] ?? 'No HMO',
      dob: map['dob'] ?? '',
      baseline_done: map['baseline_done'] ?? false,
    );
  }
}

// client details for health page
class PhysioHealthClientModel {
  String key;
  String id;
  String name;
  String user_image;
  String hmo;
  bool baseline_done;

  PhysioHealthClientModel({
    required this.key,
    required this.id,
    required this.name,
    required this.user_image,
    required this.hmo,
    required this.baseline_done,
  });

  factory PhysioHealthClientModel.fromMap(Map map) => PhysioHealthClientModel(
        key: map['key'],
        id: map['id'],
        name: map['name'],
        user_image: map['user_image'],
        hmo: map['hmo'] ?? 'No HMO',
        baseline_done: map['baseline_done'] ?? false,
      );

  Map toJson() => {
        'key': key,
        'id': id,
        'name': name,
        'user_image': user_image,
        'hmo': hmo,
      };
}

// assessment model
// class AssessmentModel {
//   String case_select;
//   String diagnosis;
//   String case_type;
//   String treatment_type;
//   String equipment;

//   AssessmentModel({
//     required this.case_select,
//     required this.diagnosis,
//     required this.case_type,
//     required this.treatment_type,
//     required this.equipment,
//   });

//   factory AssessmentModel.fromMap(Map map) {
//     return AssessmentModel(
//       case_select: map['case_select'] ?? '',
//       diagnosis: map['diagnosis'] ?? '',
//       case_type: map['case_type'] ?? '',
//       treatment_type: map['treatment_type'] ?? '',
//       equipment: map['equipment'] ?? '',
//     );
//   }

//   Map toJson() => {
//         'case_select': case_select,
//         'diagnosis': diagnosis,
//         'case_type': case_type,
//         'treatment_type': treatment_type,
//         'equipment': equipment,
//       };
// }

// case file details

// history model
class PhysioHistoryModel {
  String? key;
  String history_id;
  String hist_type; // assessment payment, session payment, session setup
  int amount;
  int amount_b4_discount;
  DateTime date;
  int session_paid;
  int cost_p_session;
  int old_float;
  int new_float;
  String? session_frequency;

  PhysioHistoryModel({
    this.key,
    required this.history_id,
    required this.hist_type,
    required this.amount,
    required this.amount_b4_discount,
    required this.date,
    required this.session_paid,
    required this.cost_p_session,
    required this.old_float,
    required this.new_float,
    this.session_frequency,
  });

  factory PhysioHistoryModel.fromMap(String key, Map map) => PhysioHistoryModel(
        key: key,
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

  Map toJson() => {
        'hist_type': hist_type,
        'history_id': history_id,
        'amount': amount,
        'amount_b4_discount': amount_b4_discount,
        'date': date.toString(),
        'session_paid': session_paid,
        'cost_p_session': cost_p_session,
        'old_float': old_float,
        'new_float': new_float,
        'session_frequency': session_frequency,
      };
}
