import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';

class RestockAccessoryRecordModel {
  String? key;
  String order_id;
  DateTime date;
  List<AccessoryItemModel> accessories;
  int order_qty;
  String shortNote;
  UserModel enteredBy;
  String supplier;
  bool verified;
  DateTime? verifiedDate;
  UserModel? verifiedBy;

  RestockAccessoryRecordModel({
    this.key,
    this.order_id = '',
    required this.date,
    required this.accessories,
    this.order_qty = 0,
    required this.shortNote,
    required this.enteredBy,
    required this.supplier,
    this.verified = false,
    this.verifiedDate,
    this.verifiedBy,
  });

  factory RestockAccessoryRecordModel.fromJson(Map map) =>
      RestockAccessoryRecordModel(
        key: map['_id'],
        order_id: map['order_id'],
        date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
        accessories: List<AccessoryItemModel>.from(
            map['accessories'].map((e) => AccessoryItemModel.fromMap(e))),
        order_qty: map['order_qty'] ?? 0,
        shortNote: map['shortNote'] ?? '',
        enteredBy: map['enteredBy'] != null
            ? UserModel.fromMap(map['enteredBy'])
            : UserModel.gen(''),
        supplier: map['supplier'] ?? '',
        verified: map['verified'] ?? false,
        verifiedDate: map['verifiedDate'] != null ? DateTime.parse(map['verifiedDate']) : null,
        verifiedBy: map['verifiedBy'] != null
            ? UserModel.fromMap(map['verifiedBy'])
            : null,
      );

  Map toJson({required String userKey}) => {
        'id': key,
        'date': date.toIso8601String(),
        'accessories': accessories.map((a) => a.toJson()).toList(),
        'shortNote': shortNote,
        'enteredBy': userKey,
        'supplier': supplier,
      };

  Map toJson_verify({required String userKey}) => {
        'id': key,
        'verifiedBy': userKey,
      };
}
