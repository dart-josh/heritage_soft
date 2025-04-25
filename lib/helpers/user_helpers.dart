import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/db_helpers/user_api.dart';

class UserHelpers {
  // get_all_doctors
  static Future get_all_doctors(BuildContext context) async {
    var response = await UserApi.get_all_doctors(context);

    List<DoctorModel> doctors = [];

    if (response != null && response['doctors'] != null) {
      List docs = response['doctors'];

      docs.forEach((doctor_) {
        DoctorModel doctor = DoctorModel.fromMap(doctor_);
        doctors.add(doctor);
      });

      AppData.set(context).update_all_doctors(doctors);
    }

    return doctors;
  }

  // get_all_users
  static Future get_all_users(BuildContext context) async {
    var response = await UserApi.get_all_users(context);

    List<UserModel> users = [];

    if (response != null && response['users'] != null) {
      List docs = response['users'];

      docs.forEach((user_) {
        UserModel user = UserModel.fromMap(user_);
        users.add(user);
      });

      // AppData.set(context)
    }
  }

  static Future<Map?> get_doctor_by_id(BuildContext context,
      {required String user}) async {
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

  // generate_user_id
  static Future<String> generate_user_id(BuildContext context) async {
    var response = await UserApi.generate_user_id(context);

    if (response != null)
      return response['user_id'].toString();
    else
      return '';
  }

  // add_update_user
  static Future<Map> add_update_user(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    var response = await UserApi.add_update_user(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (response != null && response['user'] != null) {
      UserModel user = UserModel.fromMap(response['user']);

      // AppData.set(context)
      //     .update_patient(patient);
      return {'status': true, 'user': user};
    } else
      return {'status': false};
  }

  // add_update_doctor
  static Future<Map> add_update_doctor(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    var response = await UserApi.add_update_doctor(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (response != null && response['doctor'] != null) {
      DoctorModel doctor = DoctorModel.fromMap(response['doctor']);

      // AppData.set(context)
      //     .update_patient(patient);
      return {'status': true, 'doctor': doctor};
    } else
      return {'status': false};
  }

  // delete_user
  static Future<Map> delete_user(
    BuildContext context, {
    required String user_id,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    var response = await UserApi.delete_user(context,
        showLoading: showLoading, showToast: showToast, id: user_id);

    if (response != null && response['id'] != null) {
      return {'status': true, 'id': response['id']};
    } else {
      return {'status': false};
    }
  }

  // add_update_doctor
  // add_update_user
  // add_update_customer
}
