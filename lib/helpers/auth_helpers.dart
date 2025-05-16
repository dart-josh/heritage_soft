import 'package:flutter/widgets.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/db_helpers/db_helpers.dart';
import 'package:heritage_soft/global_variables.dart';

class AuthHelpers {
  // login
  static Future<UserModel?> login(BuildContext context,
      {required String user_id, required String password}) async {
    var response = await DBHelpers.postDataToServer(context,
        route: '${authUrl}/login',
        data: {'user_id': user_id, 'password': password},
        requireUser: false,
        showToast: true);

    if (response != null &&
        response['login'] != null &&
        response['login'] == true) {
      UserModel user = UserModel.fromMap(response['user']);
      return user;
    } else
      return null;
  }

  // check_pin
  static Future<bool> check_pin(BuildContext context,
      {required String user_id, required String pin}) async {
    var response = await DBHelpers.postDataToServer(context,
        route: '${authUrl}/check_pin',
        data: {'user_id': user_id, 'pin': pin},
        requireUser: false,
        showToast: true);

    if (response != null &&
        response['login'] != null &&
        response['login'] == true) {
      return true;
    } else
      return false;
  }

  // reset_password
  static Future<bool> reset_password(BuildContext context,
      {required String user_id}) async {
    var response = await DBHelpers.postDataToServer(
      context,
      route: '${authUrl}/reset_password/${user_id}',
      data: {},
      showLoading: true,
      requireUser: true,
      showToast: true,
    );

    if (response != null &&
        response['success'] != null &&
        response['success'] == true) {
      return true;
    } else
      return false;
  }

  // reset_pin
  static Future<bool> reset_pin(BuildContext context,
      {required String user_id}) async {
    var response = await DBHelpers.postDataToServer(
      context,
      route: '${authUrl}/reset_pin/${user_id}',
      data: {},
      showLoading: true,
      requireUser: true,
      showToast: true,
    );

    if (response != null &&
        response['success'] != null &&
        response['success'] == true) {
      return true;
    } else
      return false;
  }

  //
}
