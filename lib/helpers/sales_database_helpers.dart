import 'package:flutter/material.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/db_helpers/db_helpers.dart';

class SalesDatabaseHelpers {
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

  // add_update_sales_record
  static Future add_update_sales_record(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${salesUrl}/add_update_sales_record',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

}