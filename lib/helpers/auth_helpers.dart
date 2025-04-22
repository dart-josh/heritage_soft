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

  //
}
