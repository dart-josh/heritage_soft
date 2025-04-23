class GuestModel {
  String key;
  String name;
  String phone;
  String address;
  String purpose;
  String facility;
  String date;

  GuestModel({
    required this.key,
    required this.name,
    required this.phone,
    required this.address,
    required this.purpose,
    required this.facility,
    required this.date,
  });

  factory GuestModel.fromMap(String key, Map map) {
    return GuestModel(
      key: key,
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      purpose: map['purpose'],
      facility: map['facility'],
      date: map['date'],
    );
  }

  Map toJson() => {
        'name': name,
        'phone': phone,
        'address': address,
        'purpose': purpose,
        'facility': facility,
        'date': date,
      };
}

class GuestRecordModel {
  String date;
  List<GuestModel> record;

  GuestRecordModel({
    required this.date,
    required this.record,
  });
}
