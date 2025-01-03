class GymIncomeModel {
  String client_key;
  String? f_name;
  String? l_name;
  String? cl_id;
  String hist_type;
  int amount;
  int amt_b4_dis;
  String sub_plan;
  String sub_type;
  String sub_date;
  String exp_date;
  List<String> extras;

  GymIncomeModel({
    required this.client_key,
    this.f_name,
    this.l_name,
    this.cl_id,
    required this.hist_type,
    required this.amount,
    required this.amt_b4_dis,
    required this.sub_plan,
    required this.sub_type,
    required this.sub_date,
    required this.exp_date,
    required this.extras,
  });

  factory GymIncomeModel.fromJson(Map<String, dynamic> hist_json) =>
      GymIncomeModel(
        client_key: hist_json['client_key'] ?? '',
        hist_type: hist_json['hist_type'] ?? '',
        amount: hist_json['amount'] ?? 0,
        amt_b4_dis: hist_json['sub_amount_b4_discount'] ?? 0,
        sub_plan: hist_json['sub_plan'] ?? '',
        sub_type: hist_json['sub_type'] ?? '',
        sub_date: hist_json['sub_date'] ?? '',
        exp_date: hist_json['exp_date'] ?? '',
        extras: [
          if (hist_json['boxing']) 'Boxing',
          if (hist_json['pt_status']) 'Personal Trainer'
        ],
      );
}

class Group_GymIncomeModel {
  String month;
  List<GymIncomeModel> record;

  Group_GymIncomeModel({
    required this.month,
    required this.record,
  });
}
