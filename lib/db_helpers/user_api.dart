import 'package:flutter/material.dart';
import 'package:heritage_soft/db_helpers/db_helpers.dart';
import 'package:heritage_soft/global_variables.dart';

class UserApi {
  // ? GETTERS

  // get doctor by id
  static Future get_doctor_by_id(BuildContext context, {required String user}) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${userUrl}/get_doctor_by_id/${user}');
  }

  //
}
