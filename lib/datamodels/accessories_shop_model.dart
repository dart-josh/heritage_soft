import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';

// accessory request model
class A_ShopModel {
  String? key;
  List<AccessoryItemModel> accessories;
  PatientModel? patient;
  DoctorModel? doctor;

  A_ShopModel({
    this.key,
    required this.accessories,
    this.patient,
    this.doctor,
  });

  factory A_ShopModel.fromMap(Map map) {
    return A_ShopModel(
      key: map['_id'],
      accessories: List<AccessoryItemModel>.from(
          map['accessories'].map((x) => AccessoryItemModel.fromMap(x))),
      patient: PatientModel.fromMap(
        map['patient'],
      ),
      doctor: DoctorModel.fromMap(map['doctor']),
    );
  }

  Map toJson() => {
        'id': key,
        'accessories': accessories.map((e) => e.toJson()).toList(),
        'patient': patient!.key,
        'doctor': doctor!.key,
      };
}

// shop model
class ShopOrderModel {
  String order_id;
  String date;
  List<AccessoryItemModel> items;
  int order_price;
  int order_qty;
  String customer;
  String payment_method;
  int discount_price;
  bool split;
  String payment_method2;
  int amount1;
  int amount2;
  String sold_by;

  ShopOrderModel({
    required this.order_id,
    required this.date,
    required this.items,
    required this.order_price,
    required this.order_qty,
    this.customer = '',
    this.payment_method = '',
    this.discount_price = 0,
    this.split = false,
    this.payment_method2 = '',
    this.amount1 = 0,
    this.amount2 = 0,
    required this.sold_by,
  });

  factory ShopOrderModel.fromMap(Map map) {
    List itm = map['items'];
    List<AccessoryItemModel> item_l = [];

    itm.forEach((value) {
      item_l.add(AccessoryItemModel.fromMap(value));
    });

    return ShopOrderModel(
      order_id: map['order_id'],
      date: map['date'],
      items: item_l,
      order_price: map['order_price'],
      order_qty: map['order_qty'],
      sold_by: map['sold_by'],
      customer: map['customer'],
      payment_method: map['payment_method'],
      discount_price: map['discount_price'],
      split: map['split'],
      payment_method2: map['payment_method2'],
      amount1: map['amount1'],
      amount2: map['amount2'],
    );
  }

  Map toJson() => {
        'order_id': order_id,
        'date': date,
        'items': items.map((e) => e.toJson()).toList(),
        'order_price': order_price,
        'order_qty': order_qty,
        'customer': customer,
        'payment_method': payment_method,
        'discount_price': discount_price,
        'split': split,
        'payment_method2': payment_method2,
        'amount1': amount1,
        'amount2': amount2,
        'sold_by': sold_by,
      };
}

// shop record
class ShopRecordModel {
  String date;
  List<ShopOrderModel> record;

  ShopRecordModel({
    required this.date,
    required this.record,
  });
}

// accessory model
class AccessoryModel {
  String key;
  String name;
  String code;
  String id;
  int qty;
  int price;
  bool isAvailable;
  String section;
  int limit;

  AccessoryModel({
    required this.key,
    required this.name,
    required this.code,
    required this.id,
    required this.qty,
    required this.price,
    required this.isAvailable,
    required this.section,
    this.limit = 0,
  });

  factory AccessoryModel.fromMap(String key, Map map) => AccessoryModel(
        key: key,
        name: map['name'],
        code: map['code'],
        id: map['id'] ?? '',
        qty: map['qty'],
        price: map['price'],
        isAvailable: map['isAvailable'],
        section: map['section'],
        limit: map['limit'] ?? 0,
      );

  Map toJson() => {
        'name': name,
        'code': code,
        'id': id,
        'qty': qty,
        'price': price,
        'isAvailable': isAvailable,
        'section': section,
        'limit': limit,
      };
}

// accessory item in shop record
class AccessoryItemModel {
  AccessoryModel accessory;
  int qty;

  AccessoryItemModel({
    required this.accessory,
    required this.qty,
  });

  factory AccessoryItemModel.fromMap(Map map) => AccessoryItemModel(
        accessory:
            AccessoryModel.fromMap(map['accessory']['_id'], map['accessory']),
        qty: map['qty'],
      );

  Map toJson() => {
        'accessory': accessory.key,
        'qty': qty,
      };
}
