class EquipmentModel {
  String key;
  String equipmentName;
  String equipmentId;
  String category;
  double costing;
  String status;

  EquipmentModel({
    required this.key,
    required this.equipmentName,
    required this.equipmentId,
    required this.category,
    required this.costing,
    required this.status,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) => EquipmentModel(
        key: json["_id"] ?? "",
        equipmentName: json["equipmentName"] ?? "",
        equipmentId: json["equipmentId"] ?? "",
        category: json["category"] ?? "",
        costing: json["costing"] ?? 0,
        status: json["status"] ?? 'Available',
      );

  Map<String, dynamic> toJson() => {
        "id": key,
        "equipmentName": equipmentName,
        "equipmentId": equipmentId,
        "category": category,
        "costing": costing,
        "status": status,
      };
}
