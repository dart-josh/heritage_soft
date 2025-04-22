import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/db_helpers/user_api.dart';

class UserHelpers {
  
  // get doctor by id
  static Future<Map?> get_doctor_by_id(BuildContext context, {required String user}) async {
    var response = await UserApi.get_doctor_by_id(context, user: user);
       

    if (response != null && response['doctor'] != null) {
      DoctorModel doctor = DoctorModel.fromMap(response['doctor']);
      return {'status': 'Doctor', 'doctor': doctor};
    } else if (response != null &&
        response['message'] != null &&
        response['message'] == 'Doctor not found') {
      return {'status': 'Setup'};
    } else
      return null;
  }

  // add_update_doctor
  // add_update_user
  // add_update_customer
}