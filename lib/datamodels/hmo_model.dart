class HMO_Model {
  String hmo_name;
  String key;
  int days_week;
  int hmo_amount;

  HMO_Model({
    required this.hmo_name,
    required this.key,
    required this.days_week,
    required this.hmo_amount,
  });

  factory HMO_Model.fromMap(String key, Map map) => HMO_Model(
      hmo_name: map['hmo_name'],
      key: key,
      days_week: (map['days_week'] != null && map['days_week'] != 0) ? map['days_week'] : 2,
      hmo_amount: (map['hmo_amount'] != null && map['hmo_amount'] != 0) ? map['hmo_amount'] : 12000);

  Map<String, dynamic> toJson() => {
    'hmo_name': hmo_name,
    'days_week': days_week,
    'hmo_amount': hmo_amount,
  };
}
