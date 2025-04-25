import 'package:flutter/material.dart';
import 'package:heritage_soft/db_helpers/db_helpers.dart';
import 'package:heritage_soft/global_variables.dart';

class UserApi {
  // ? GETTERS

  // get_all_doctors
  static Future get_all_doctors(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${userUrl}/get_all_doctors');
  }

  // get_all_users
  static Future get_all_users(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${userUrl}/get_all_users');
  }

  // get doctor by id
  static Future get_doctor_by_id(BuildContext context,
      {required String user}) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${userUrl}/get_doctor_by_id/${user}');
  }

  // generate_user_id
  static Future generate_user_id(
    BuildContext context, {
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${userUrl}/generate_user_id', data: {}, showToast: showToast);
  }

  // add_update_user
  static Future add_update_user(
    BuildContext context, {
    required Map data,
    bool showToast = false,
    bool showLoading = false,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${userUrl}/add_update_user',
      data: data,
      showToast: showToast,
      showLoading: showLoading,
    );
  }

  // add_update_doctor
  static Future add_update_doctor(
    BuildContext context, {
    required Map data,
    bool showToast = false,
    bool showLoading = false,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${userUrl}/add_update_doctor',
      data: data,
      showToast: showToast,
      showLoading: showLoading,
    );
  }

  // delete_user
  static Future delete_user(
    BuildContext context, {
    required String id,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.deleteFromServer(
      context,
      route: '${userUrl}/delete_user',
      data: {},
      id: id,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  //
}
