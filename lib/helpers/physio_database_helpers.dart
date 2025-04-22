import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/casefile.model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/db_helpers/clinic_api.dart';
import 'package:provider/provider.dart';

class PhysioDatabaseHelpers {
  // get all patients
  static Future get_all_patients(BuildContext context) async {
    var response = await ClinicApi.get_all_patients(context);

    if (response != null) {
      List data = response['patients'];

      List<PatientModel> patients = [];

      data.forEach((e) {
        PatientModel cl_1 = PatientModel.fromMap(e);
        patients.add(cl_1);
      });

      Provider.of<AppData>(context, listen: false)
          .update_all_patients(patients);
    }
  }

  // get all doctors
  static Future get_all_doctors(BuildContext context) async {
    var response = await ClinicApi.get_all_doctors(context);

    if (response != null) {
      List data = response['doctors'];

      List<DoctorModel> doctors = [];

      data.forEach((e) {
        DoctorModel doc = DoctorModel.fromMap(e);
        doctors.add(doc);
      });

      Provider.of<AppData>(context, listen: false).update_all_doctors(doctors);
    }
  }

  // get case file by patient
  static Future<List<CaseFileModel>?> get_case_file_by_patient(
      BuildContext context, String patient_id) async {
    List<CaseFileModel> files = [];
    var response = await ClinicApi.get_case_file_by_patient(context,
        data: {'patient': patient_id});

    if (response != null) {
      List data = response['caseFiles'];
      data.forEach((e) {
        CaseFileModel cl_1 = CaseFileModel.fromMap(e);
        files.add(cl_1);
      });

      return files;
    }

    return null;
  }

  // get_case_file_by_date
  static Future<List<CaseFileModel>?> get_case_file_by_date(
      BuildContext context,
      {required Map data}) async {
    List<CaseFileModel> files = [];
    var response = await ClinicApi.get_case_file_by_date(context, data: data);

    if (response != null) {
      List data = response['caseFiles'];
      data.forEach((e) {
        CaseFileModel cl_1 = CaseFileModel.fromMap(e);
        files.add(cl_1);
      });

      return files;
    }

    return null;
  }

  //

  // ! SETTERS

  // add_update_accessory_request
  static Future add_update_accessory_request(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await ClinicApi.add_update_accessory_request(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  // add_update_patient
  static Future<Map<String, dynamic>> add_update_patient(
    BuildContext context, {
    required Map<String, dynamic> data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    var response = await ClinicApi.add_update_patient(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (response != null && response['patient'] != null) {
      PatientModel patient = PatientModel.fromMap(response['patient']);

      // AppData.set(context)
      //     .update_patient(patient);
      return {'status': true, 'patient': patient};
    } else
      return {'status': false};
  }

  // add_update_case_file
  static Future add_update_case_file(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await ClinicApi.add_update_case_file(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  // update_treatment_info
  static Future update_treatment_info(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await ClinicApi.update_assessment_info(context,
        data: data, showLoading: showLoading, showToast: showToast, loadingText: loadingText);
  }

  // update_assessment_info
  static Future update_assessment_info(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await ClinicApi.update_assessment_info(context,
        data: data, showLoading: showLoading, showToast: showToast, loadingText: loadingText);
  }

  // update_clinic_info
  static Future update_clinic_info(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await ClinicApi.update_clinic_info(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  // update_clinic_variables
  static Future update_clinic_variables(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await ClinicApi.update_clinic_variables(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  // update_clinic_history
  static Future update_clinic_history(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await ClinicApi.update_clinic_history(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  // send to clinic
  static Future send_to_clinic(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await ClinicApi.update_ong_patients(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  // remove from clinic
  static Future remove_from_clinic(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await ClinicApi.remove_pen_patients(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  // add to doctor ong patient
  static Future update_doc_ongoing_patient(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    var res1 = await ClinicApi.update_ong_patients(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (res1 != null) {
      return await ClinicApi.remove_pen_patients(context,
          data: data, showLoading: showLoading, showToast: showToast);
    } else
      return null;
  }

  // generate_patient_id
  static Future<String> generate_patient_id(BuildContext context) async {
    var response = await ClinicApi.generate_patient_id(context);

    if (response != null)
      return response['patient_id'].toString();
    else
      return '';
  }

  //

  // ! REMOVALS
  // delete patient
  static Future<Map> delete_patient(
    BuildContext context, {
    required String patient_id,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    var response = await ClinicApi.delete_patient(context,
        showLoading: showLoading, showToast: showToast, id: patient_id);

    if (response != null && response['id'] != null) {
      return {'status': true, 'id': response['id']};
    } else {
      return {'status': false};
    }
  }
}
