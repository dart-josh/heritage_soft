import 'package:flutter/material.dart';
import 'package:heritage_soft/db_helpers/db_helpers.dart';
import 'package:heritage_soft/global_variables.dart';

class StoreApi {
  //? GETTERS

  //  get_all_accessories
  static Future get_all_accessories(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${salesUrl}/get_all_accessories');
  }

  //  get_sales_record
  static Future get_sales_record(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${salesUrl}/get_sales_record');
  }

  //  get_accessory_restock_record
  static Future get_accessory_restock_record(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${salesUrl}/get_accessory_restock_record');
  }

  //?

  //? SETTERS

  // add_update_accessory
  static Future add_update_accessory(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${salesUrl}/add_update_accessory',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

  // add_sales_record
  static Future add_sales_record(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${salesUrl}/add_sales_record',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

// add_update_accessory_restock_record
  static Future add_update_accessory_restock_record(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${salesUrl}/add_update_accessory_restock_record',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

// verify_accessory_restock_record
  static Future verify_accessory_restock_record(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${salesUrl}/verify_accessory_restock_record',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

  //?

  //? REMOVALS

  // delete_accessory
  static Future delete_accessory(
    BuildContext context, {
    required Map data,
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.deleteFromServer(
      context,
      route: '${salesUrl}/delete_accessory',
      data: data,
      id: id,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  // delete_sales_record
  static Future delete_sales_record(
    BuildContext context, {
    required Map data,
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.deleteFromServer(
      context,
      route: '${salesUrl}/delete_sales_record',
      data: data,
      id: id,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  // delete_accessory_restock_record
  static Future delete_accessory_restock_record(
    BuildContext context, {
    required Map data,
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.deleteFromServer(
      context,
      route: '${salesUrl}/delete_accessory_restock_record',
      data: data,
      id: id,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  //?
}
