// client health model
class HealthModel {
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
  String sugar_level;

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
  String data_type;

  HealthModel({
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
    required this.sugar_level,
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
    required this.data_type,
  });

  factory HealthModel.fromMap(String key, Map map) {
    return HealthModel(
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
      sugar_level: map['sugar_level'] ?? '',
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
      data_type: map['data_type'] ?? 'basic',
    );
  }

  Map<String, dynamic> toJson() => {
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
        'sugar_level': sugar_level,
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
        'data_type': data_type,
      };
}

// client summary model
class HealthSummaryModel {
  String height;
  String weight;

  HealthSummaryModel({
    required this.height,
    required this.weight,
  });

  factory HealthSummaryModel.fromMap(Map map) {
    return HealthSummaryModel(
      height: map['height'],
      weight: map['weight'],
    );
  }
}

// health client model
class HealthClientModel {
  String key;
  String id;
  String name;
  String user_image;
  String hmo;
  bool baseline_done;
  String program_type;

  HealthClientModel({
    required this.key,
    required this.id,
    required this.name,
    required this.user_image,
    required this.hmo,
    required this.baseline_done,
    required this.program_type,
  });
}

// grouped health model
class G_HealthModel {
  String key;
  String type;
  HealthModel data;

  G_HealthModel({
    required this.key,
    required this.type,
    required this.data,
  });
}
