import 'package:flutter/material.dart';
import 'package:heritage_soft/db_helpers/db_helpers.dart';
import 'package:heritage_soft/global_variables.dart';

class GymApi {
  // ! GETTERS

  // get all clients
  static Future get_all_clients(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${gymUrl}/get_all_clients');
  }

  static Future get_hmo(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${gymUrl}/get_hmo');
  }

  static Future get_gym_income(BuildContext context, month) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${gymUrl}/get_gym_income/${month}');
  }

  //?

  // ! SETTERS

  static Future register_client(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${gymUrl}/register_client',
      data: data,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  //
  static Future update_client(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${gymUrl}/update_client',
      data: data,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  static Future add_to_sub_history(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${gymUrl}/add_to_sub_history',
      data: data,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  static Future add_update_hmo(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${gymUrl}/add_update_hmo',
      data: data,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  static Future update_health_details(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${gymUrl}/update_health_details',
      data: data,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  static Future verify_indemnity(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${gymUrl}/verify_indemnity',
      data: data,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  //?

  // ! REMOVALS
  // delete_client
  static Future delete_client(
    BuildContext context, {
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.deleteFromServer(context,
        route: '${gymUrl}/delete_client',
        data: {},
        id: id,
        showLoading: showLoading,
        showToast: showToast);
  }

  // delete_hmo
  static Future delete_hmo(
    BuildContext context, {
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.deleteFromServer(context,
        route: '${gymUrl}/delete_hmo',
        data: {},
        id: id,
        showLoading: showLoading,
        showToast: showToast);
  }

// ! UTILS

// generate_client_id
  static Future generate_client_id(BuildContext context) async {
    return await DBHelpers.postDataToServer(context,
        route: '${gymUrl}/generate_client_id', data: {}, showToast: true);
  }
}
