// accessory model
class AccessoryModel {
  String key;
  String itemId;
  String itemName;
  String category;
  String itemCode;
  int price;
  int quantity;
  bool isAvailable;
  int restockLimit;

  AccessoryModel({
    this.key = '',
    this.itemId = '',
    required this.itemName,
    required this.category,
    required this.itemCode,
    required this.price,
    required this.quantity,
    required this.isAvailable,
    required this.restockLimit,
  });

  factory AccessoryModel.fromMap(Map map) => AccessoryModel(
        key: map['_id'] ?? '',
        itemId: map['itemId'] ?? '',
        itemName: map['itemName'] ?? '',
        category: map['category'] ?? '',
        itemCode: map['itemCode'] ?? '',
        price: map['price'] ?? '',
        quantity: map['quantity'] ?? '',
        isAvailable: map['isAvailable'] ?? false,
        restockLimit: map['restockLimit'] ?? 0,
      );

  Map toJson() => {
        'id': key,
        'itemName': itemName,
        'category': category,
        'itemCode': itemCode,
        'price': price,
        'quantity': quantity,
        'isAvailable': isAvailable,
        'restockLimit': restockLimit,
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
        accessory: AccessoryModel.fromMap(map['accessory']),
        qty: map['qty'],
      );

  Map toJson() => {
        'accessory': accessory.key,
        'qty': qty,
      };
}
