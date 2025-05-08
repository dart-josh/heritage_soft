import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';

class SalesRecordModel {
  String? key;
  String order_id;
  DateTime date;
  List<AccessoryItemModel> accessories;
  int order_price;
  int order_qty;
  PatientModel? patient;
  int discount_price;
  String shortNote;
  String paymentMethod;
  List<PaymentMethodModel> splitPaymentMethod;
  UserModel soldBy;
  String saleType;

  SalesRecordModel({
    this.key,
    this.order_id = '',
    required this.date,
    required this.accessories,
    required this.order_price,
    this.order_qty = 0,
    required this.patient,
    required this.discount_price,
    required this.shortNote,
    required this.paymentMethod,
    required this.splitPaymentMethod,
    required this.soldBy,
    required this.saleType,
  });

  factory SalesRecordModel.fromJson(Map map) => SalesRecordModel(
        key: map['_id'],
        order_id: map['order_id'] ?? '',
        date:
            map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
        accessories: List<AccessoryItemModel>.from(
            map['accessories'].map((e) => AccessoryItemModel.fromMap(e))),
        order_price: map['order_price'] ?? 0,
        order_qty: map['order_qty'] ?? 0,
        patient: map['patient'] != null
            ? PatientModel.fromMap(map['patient'])
            : null,
        discount_price: map['discount_price'] ?? 0,
        shortNote: map['shortNote'] ?? '',
        paymentMethod: map['paymentMethod'] ?? '',
        splitPaymentMethod: List<PaymentMethodModel>.from(map['splitPaymentMethod']
            .map((e) => PaymentMethodModel.fromJson(e))),
        soldBy: map['soldBy'] != null
            ? UserModel.fromMap(map['soldBy'])
            : UserModel.gen(''),
        saleType: map['saleType'] ?? '',
      );

  Map toJson({required String soldByKey}) => {
        'date': date.toIso8601String(),
        'accessories': accessories.map((a) => a.toJson()).toList(),
        'order_price': order_price,
        'patient': patient?.key,
        'discount_price': discount_price,
        'shortNote': shortNote,
        'paymentMethod': paymentMethod,
        'splitPaymentMethod':
            splitPaymentMethod.map((p) => p.toJson()).toList(),
        'soldBy': soldByKey,
        'saleType': saleType,
      };
}

class PaymentMethodModel {
  String? paymentMethod;
  int amount;

  PaymentMethodModel({
    required this.paymentMethod,
    required this.amount,
  });

  // get model from json
  factory PaymentMethodModel.fromJson(Map json) {
    return PaymentMethodModel(
      paymentMethod: json['paymentMethod'] ?? '',
      amount: json['amount'] ?? 0,
    );
  }

  // get json from model
  Map toJson() {
    return {
      'paymentMethod': paymentMethod,
      'amount': amount,
    };
  }
}
