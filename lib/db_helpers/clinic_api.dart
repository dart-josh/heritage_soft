import 'package:flutter/material.dart';

import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/db_helpers/db_helpers.dart';

class ClinicApi {
  // ! GETTERS

  // get all patients
  static Future get_all_patients(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${clinicUrl}/get_all_patients');
  }

  static Future get_patient_by_id(BuildContext context,
      {required Map data}) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/get_patient_by_id', data: data);
  }

  // get all doctors
  static Future get_doctors(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${userUrl}/get_doctors');
  }

  // get_all_case_files
  static Future get_all_case_files(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${clinicUrl}/get_all_case_files');
  }

  // get case file by patient
  static Future get_case_file_by_patient(BuildContext context,
      {required Map data}) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/get_case_file_by_patient', data: data);
  }

  // get_case_file_by_id
  static Future get_case_file_by_id(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${clinicUrl}/get_case_file_by_id',
      data: data,
      showLoading: showLoading,
      showToast: showToast,
      loadingText: loadingText,
    );
  }

  //get_case_file_by_date
  static Future get_case_file_by_date(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/get_case_file_by_date',
        data: data,
        showLoading: showLoading,
        showToast: showToast,
        loadingText: loadingText);
  }

  // get_all_accessory_requests
  static Future get_all_accessory_requests(BuildContext context) async {
    return await DBHelpers.getDataFromServer(context,
        route: '${clinicUrl}/get_all_accessory_requests');
  }

  // get_payment_record
  static Future get_payment_record(BuildContext context) async {
    return await DBHelpers.getDataFromServer(
      context,
      route: '${clinicUrl}/get_payment_record',
      // showLoading: true,
      // showToast: true,
    );
  }

  // !

  // ! SETTERS

// add_update_accessory_request
  static Future add_update_accessory_request(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/add_update_accessory_request',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

// update_assessment_info
  static Future update_assessment_info(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/update_assessment_info',
        data: data,
        showLoading: showLoading,
        showToast: showToast,
        loadingText: loadingText);
  }

// update_clinic_info
  static Future update_clinic_info(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(
      context,
      route: '${clinicUrl}/update_clinic_info',
      data: data,
      showLoading: showLoading,
      showToast: showToast,
      loadingText: loadingText,
    );
  }

// update_treatment_info
  static Future update_treatment_info(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/update_treatment_info',
        data: data,
        showLoading: showLoading,
        showToast: showToast,
        loadingText: loadingText);
  }

// add_update_case_file
  static Future add_update_case_file(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/add_update_case_file',
        data: data,
        showLoading: showLoading,
        showToast: showToast,
        loadingText: loadingText);
  }

// assign_current_doctor
  static Future assign_current_doctor(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/assign_current_doctor',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

// send_patient_to_clinic[update_pen_patients]
  static Future update_pen_patients(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${userUrl}/update_pen_patients',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

// remove_patient_from_clinic[remove_pen_patients]
  static Future remove_pen_patients(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${userUrl}/remove_pen_patients',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

// update_ong_patients
  static Future update_ong_patients(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${userUrl}/update_ong_patients',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

  // remove_ong_patients
  static Future remove_ong_patients(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${userUrl}/remove_ong_patients',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

  // update_my_patients
  static Future update_my_patients(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${userUrl}/update_my_patients',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

// add_update_patient(update_patient-name,type[HMO]),
  static Future add_update_patient(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/add_update_patient',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

// make_payment[update_clinic_history]
  static Future update_clinic_history(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/update_clinic_history',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

// update_clinic_invoice
  static Future update_clinic_invoice(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/update_clinic_invoice',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }

  // update_clinic_variables
  static Future update_clinic_variables(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/update_clinic_variables',
        data: data,
        showLoading: showLoading,
        showToast: showToast);
  }
// !

// ! REMOVALS

// delete_accessory_request
  static Future delete_accessory_request(
    BuildContext context, {
    required Map data,
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.deleteFromServer(
      context,
      route: '${clinicUrl}/delete_accessory_request',
      data: data,
      id: id,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

// delete_all_accessory_request
  static Future delete_all_accessory_request(
    BuildContext context, {
    required Map data,
    required String id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await DBHelpers.deleteFromServer(
      context,
      route: '${clinicUrl}/delete_all_accessory_request',
      data: data,
      id: id,
      showLoading: showLoading,
      showToast: showToast,
    );
  }

  // delete_patient
  static Future delete_patient(
    BuildContext context, {
    required String id,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await DBHelpers.deleteFromServer(context,
        route: '${clinicUrl}/delete_patient',
        data: {},
        id: id,
        showLoading: showLoading,
        showToast: showToast);
  }

// ! UTILS

// generate_patient_id
  static Future generate_patient_id(BuildContext context) async {
    return await DBHelpers.postDataToServer(context,
        route: '${clinicUrl}/generate_patient_id', data: {}, showToast: true);
  }
}
