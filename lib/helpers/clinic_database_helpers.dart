import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/clinic_models/casefile.model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/clinic_models/payment.model.dart';
import 'package:heritage_soft/datamodels/store_models/accessory_request.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/db_helpers/clinic_api.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/clinic/clinic_tab.dart';
import 'package:provider/provider.dart';

class ClinicDatabaseHelpers {
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

  static Future<PatientModel?> get_patient_by_id(BuildContext context,
      {required String patient_key}) async {
    var response = await ClinicApi.get_patient_by_id(context, data: {
      'patient_key': patient_key,
    });

    if (response != null && response['patient'] != null) {
      Map data = response['patient'];

      return PatientModel.fromMap(data);
    } else
      return null;
  }

  // get all doctors
  static Future get_doctors(BuildContext context) async {
    var response = await ClinicApi.get_doctors(context);

    if (response != null) {
      List data = response['doctors'];

      List<DoctorModel> doctors = [];

      data.forEach((e) {
        DoctorModel doc = DoctorModel.fromMap(e);
        doctors.add(doc);
      });

      Provider.of<AppData>(context, listen: false).update_doctors(doctors);
    }
  }

  //get_all_case_files
  static Future<List<CaseFileModel>?> get_all_case_files(
      BuildContext context) async {
    List<CaseFileModel> files = [];
    var response = await ClinicApi.get_all_case_files(
      context,
    );

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
    BuildContext context, {
    required String patient_id,
    required DateTime treatment_date,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    List<CaseFileModel> files = [];
    var response = await ClinicApi.get_case_file_by_date(context, data: {
      'patient': patient_id,
      'treatment_date': treatment_date.toIso8601String()
    });

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

  // get_case_file_by_id
  static Future<CaseFileModel?> get_case_file_by_id(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    var response = await ClinicApi.get_case_file_by_id(context,
        data: data,
        showLoading: showLoading,
        showToast: showToast,
        loadingText: loadingText);

    if (response != null) {
      Map data = response['caseFile'];
      CaseFileModel caseFile = CaseFileModel.fromMap(data);

      return caseFile;
    }

    return null;
  }

  // check for case matches
  static bool check_cases_by_type(
      {required List<CaseFileModel> cases, required String case_type}) {
    var response =
        cases.where((caseFile) => caseFile.case_type == case_type).toList();

    if (response.isNotEmpty) {
      return true;
    }
    return false;
  }

  // get_all_accessory_requests
  static Future get_all_accessory_requests(BuildContext context) async {
    var response = await ClinicApi.get_all_accessory_requests(context);

    if (response != null) {
      List data = response['accessoryRequests'];

      List<AccessoryRequestModel> requests = [];

      data.forEach((e) {
        AccessoryRequestModel req = AccessoryRequestModel.fromMap(e);
        requests.add(req);
      });

      Provider.of<AppData>(context, listen: false)
          .update_accessory_requests(requests);
    }
  }

  // get_payment_record
  static Future<List<PaymentHistoryModel>> get_payment_record(
      BuildContext context) async {
    var response = await ClinicApi.get_payment_record(context);

    List<PaymentHistoryModel> payments = [];

    if (response != null) {
      List data = response['payments'];

      data.forEach((e) {
        PaymentHistoryModel req = PaymentHistoryModel.fromMap(e);
        payments.add(req);
      });
    }

    return payments;
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
  static Future<Map> add_update_patient(
    BuildContext context, {
    required Map data,
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
    String? loadingText,
    bool showToast = false,
  }) async {
    return await ClinicApi.add_update_case_file(context,
        data: data,
        showLoading: showLoading,
        showToast: showToast,
        loadingText: loadingText);
  }

  // update_treatment_info
  static Future update_treatment_info(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await ClinicApi.update_treatment_info(context,
        data: data,
        showLoading: showLoading,
        showToast: showToast,
        loadingText: loadingText);
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
        data: data,
        showLoading: showLoading,
        showToast: showToast,
        loadingText: loadingText);
  }

  // pay for assessment
  static Future<Map> pay_for_assessment(
    BuildContext context, {
    required PatientModel patient,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    var conf = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AssessmentPayment(),
    );

    if (conf != null) {
      TreatmentInfoModel tre =
          patient.treatment_info ?? TreatmentInfoModel.gen();

      tre.assessment_paid = true;

      // update assessment paid

      var res_T = await update_treatment_info(
        context,
        data: tre.toJson(patientKey: patient.key ?? '', update: false),
        loadingText: loadingText,
        showToast: showToast,
        showLoading: showLoading,
      );

      if (res_T != null && res_T['patient_data'] != null) {
        ClinicHistoryModel hist = ClinicHistoryModel(
          hist_type: 'Assessment payment',
          amount: conf,
          amount_b4_discount: 0,
          date: DateTime.now(),
          session_paid: 1,
          history_id: Helpers.generate_order_id(),
          cost_p_session: 0,
          old_float: 0,
          new_float: 0,
          session_frequency: '',
        );

        Map data_h = hist.toJson(patientKey: patient.key ?? '');

        update_clinic_history(context, data: data_h);

        return {'status': true, 'data': hist};
      } else
        return {'status': false};
    } else {
      return {'status': false};
    }
  }

  // go to treatment tab
  static Future<CaseFileModel?> start_treatment(BuildContext context,
      {required PatientModel patient,
      required DoctorModel doctor,
      required String case_type}) async {
    if (patient.current_case_id == null) {
      // open new case file
      CaseFileModel caseFile = CaseFileModel.open(
          patient: patient, doctor: doctor, case_type: case_type);

      var res = await add_update_case_file(
        context,
        data: caseFile.toJson_open(),
        showLoading: true,
        showToast: true,
        loadingText: 'Creating new case file...',
      );

      if (res != null && res['caseFile'] != null) {
        CaseFileModel caseFile = CaseFileModel.fromMap(res['caseFile']);

        // update clinic variable
        await ClinicDatabaseHelpers.update_clinic_variables(
          context,
          data: {
            'patient': patient.key,
            'case_type': patient.clinic_variables?.case_type,
            'treatment_duration': patient.clinic_variables?.treatment_duration,
            'start_time': DateTime.now().toIso8601String(),
          },
          showLoading: true,
        );

        // add patient to doctors tab
        await ClinicDatabaseHelpers.update_doc_ongoing_patient(
          context,
          data: {'doctor': doctor.key ?? '', 'patient': patient.key ?? ''},
          showLoading: true,
        );

        // go to treatment tab with new case file
        return caseFile;
      } else {
        // show error message
        return null;
      }

      // go to treatment tab with new case file
    } else {
      // check for case file
      var res = await get_case_file_by_id(context,
          data: {
            'patient': patient.key,
            'case_id': patient.current_case_id,
          },
          showLoading: true,
          showToast: true);

      if (res != null) {
        // get case file and open

        // go to treatment tab with case file
        return res;
      } else
        return null;
    }
  }

  // update_clinic_info
  static Future update_clinic_info(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    String? loadingText,
    bool showToast = false,
  }) async {
    return await ClinicApi.update_clinic_info(
      context,
      data: data,
      showLoading: showLoading,
      showToast: showToast,
      loadingText: loadingText,
    );
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

  // update_clinic_invoice
  static Future update_clinic_invoice(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await ClinicApi.update_clinic_invoice(context,
        data: data, showLoading: showLoading, showToast: showToast);
  }

  // send to clinic
  static Future<bool> send_to_clinic(
    BuildContext context, {
    required String doctor_key,
    required String patient_key,
    required String treatment_type,
    required String treatment_duration,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    var res_1 = await ClinicApi.update_pen_patients(context,
        data: {
          'doctor': doctor_key,
          'patient': patient_key,
        },
        showLoading: showLoading,
        showToast: showToast);

    if (res_1 == null || res_1['doctor'] == null) return false;

    var res_2 = await ClinicApi.assign_current_doctor(context,
        data: {'patient': patient_key, 'doctor': doctor_key, 'sett': true});

    if (res_2 != null) {
      if (res_2['patient_data'] != null) {
        var res_3 = await ClinicApi.update_clinic_variables(context,
            data: {
              'patient': patient_key,
              'case_type': treatment_type,
              'treatment_duration': treatment_duration,
            },
            showLoading: true);
        if (res_3 != null && res_3['patient_data'] != null)
          return true;
        else
          return false;
      } else
        return false;
    } else
      return false;
  }

  // change treatment_duration
  static Future<bool> change_treatment_duration(
    BuildContext context, {
    required String doctor_key,
    required String patient_key,
    required String treatment_type,
    required String treatment_duration,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    var res_1 = await ClinicApi.update_pen_patients(context,
        data: {
          'doctor': doctor_key,
          'patient': patient_key,
        },
        showLoading: showLoading,
        showToast: showToast);

    if (res_1 != null) {
      if (res_1['doctor'] != null) {
        var res_3 = await ClinicApi.update_clinic_variables(context,
            data: {
              'patient': patient_key,
              'case_type': treatment_type,
              'treatment_duration': treatment_duration,
            },
            showLoading: true);
        if (res_3 != null && res_3['patient_data'] != null)
          return true;
        else
          return false;
      } else
        return false;
    } else
      return false;
  }

  // remove from clinic
  static Future<bool> remove_from_clinic(
    BuildContext context, {
    required String doctor_key,
    required String patient_key,
    required String treatment_type,
    required String treatment_duration,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    var res_1 = await ClinicApi.remove_pen_patients(context,
        data: {
          'doctor': doctor_key,
          'patient': patient_key,
        },
        showLoading: showLoading,
        showToast: showToast);

    if (res_1 == null || res_1['doctor'] == null) return false;

    var res_2 = await ClinicApi.assign_current_doctor(context,
        data: {'patient': patient_key, 'doctor': doctor_key, 'sett': false});

    if (res_2 != null) {
      if (res_2['patient_data'] != null) {
        var res_3 = await ClinicApi.update_clinic_variables(context,
            data: {
              'patient': patient_key,
              'case_type': treatment_type,
              'treatment_duration': null,
            },
            showLoading: true);
        if (res_3 != null && res_3['patient_data'] != null)
          return true;
        else
          return false;
      } else
        return false;
    } else
      return false;
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

  // add to doctor my patient
  static Future<bool> end_treatment(
    BuildContext context, {
    required String doctor_key,
    required String patient_key,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    var res1 = await ClinicApi.update_my_patients(context,
        data: {
          'doctor': doctor_key,
          'patient': {
            'patient': patient_key,
          }
        },
        showLoading: showLoading,
        showToast: showToast);

    if (res1 != null && res1['doctor'] != null) {
      var res_2 = await ClinicApi.remove_ong_patients(context,
          data: {
            'doctor': doctor_key,
            'patient': patient_key,
          },
          showLoading: showLoading,
          showToast: showToast);

      if (res_2 != null && res_2['doctor'] != null) {
        var res_3 = await ClinicApi.update_clinic_variables(context,
            data: {
              'patient': patient_key,
              'case_type': '',
              'treatment_duration': null,
            },
            showLoading: true);
        await ClinicApi.assign_current_doctor(context, data: {
          'patient': patient_key,
          'doctor': doctor_key,
          'sett': false
        });
        if (res_3 != null && res_3['patient_data'] != null)
          return true;
        else
          return false;
      } else
        return false;
    } else
      return false;
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

  // delete_accessory_request
  static Future delete_accessory_request(
    BuildContext context, {
    required Map data,
    required String id,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    return await ClinicApi.delete_accessory_request(context,
        data: data, id: id, showLoading: showLoading, showToast: showToast);
  }

  // delete_all_accessory_request
  static Future delete_all_accessory_request(
    BuildContext context, {
    bool showLoading = true,
    bool showToast = true,
  }) async {
    return await ClinicApi.delete_all_accessory_request(context,
        data: {}, id: '', showLoading: showLoading, showToast: showToast);
  }

  //
}
