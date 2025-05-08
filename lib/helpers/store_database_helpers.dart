import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';
import 'package:heritage_soft/datamodels/store_models/restock_accessory_record.model.dart';
import 'package:heritage_soft/datamodels/store_models/sales_record.model.dart';
import 'package:heritage_soft/db_helpers/store_api.dart';

class StoreDatabaseHelpers {
  // get_all_accessories
  static Future get_all_accessories(BuildContext context) async {
    var response = await StoreApi.get_all_accessories(context);

    if (response != null && response['accessories'] != null) {
      List data = response['accessories'];

      List<AccessoryModel> accessories = [];

      data.forEach((e) {
        AccessoryModel cl_1 = AccessoryModel.fromMap(e);
        accessories.add(cl_1);
      });

      AppData.set(context).update_accessories(accessories);
    }
  }

  // get_sales_record
  static Future<List<SalesRecordModel>> get_sales_record(
      BuildContext context) async {
    var response = await StoreApi.get_sales_record(context);

    if (response != null && response['salesRecord'] != null) {
      List data = response['salesRecord'];

      List<SalesRecordModel> record = [];

      data.forEach((e) {
        SalesRecordModel data = SalesRecordModel.fromJson(e);
        record.add(data);
      });

      // AppData.set(context).update_sales_record(record);
      return record;
    } else
      return [];
  }

// get_accessory_restock_record
  static Future<List<RestockAccessoryRecordModel>> get_accessory_restock_record(
      BuildContext context) async {
    var response = await StoreApi.get_accessory_restock_record(context);

    if (response != null && response['record'] != null) {
      List data = response['record'];

      List<RestockAccessoryRecordModel> record = [];

      data.forEach((e) {
        RestockAccessoryRecordModel data =
            RestockAccessoryRecordModel.fromJson(e);
        record.add(data);
      });

      // AppData.set(context).update_restock_record(record);
      return record;
    } else
      return [];
  }

  //?

  // add_update_accessory
  static Future add_update_accessory(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await StoreApi.add_update_accessory(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  // add_sales_record
  static Future add_sales_record(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await StoreApi.add_sales_record(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

// add_update_accessory_restock_record
  static Future add_update_accessory_restock_record(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await StoreApi.add_update_accessory_restock_record(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

// verify_accessory_restock_record
  static Future verify_accessory_restock_record(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await StoreApi.verify_accessory_restock_record(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  //?

  // delete_accessory
  static Future delete_accessory(
    BuildContext context, {
    required Map data,
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await StoreApi.delete_accessory(context,
        data: data, id: id, showLoading: showLoading, showToast: showToast);
  }

  // delete_sales_record
  static Future delete_sales_record(
    BuildContext context, {
    required Map data,
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await StoreApi.delete_sales_record(context,
        data: data, id: id, showLoading: showLoading, showToast: showToast);
  }

// delete_accessory_restock_record
  static Future delete_accessory_restock_record(
    BuildContext context, {
    required Map data,
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await StoreApi.delete_accessory_restock_record(context,
        data: data, id: id, showLoading: showLoading, showToast: showToast);
  }

  //
}
