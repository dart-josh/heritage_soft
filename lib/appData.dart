import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/hmo_model.dart';
import 'package:heritage_soft/datamodels/password_model.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';
import 'package:heritage_soft/datamodels/store_models/accessory_request.model.dart';
import 'package:heritage_soft/datamodels/store_models/restock_accessory_record.model.dart';
import 'package:heritage_soft/datamodels/store_models/sales_record.model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/datamodels/users_model.dart';
import 'package:heritage_soft/pages/store/sales_record_page.dart';
import 'package:provider/provider.dart';

class AppData extends ChangeNotifier {
  static AppData get(context, {bool listen = true}) {
    return Provider.of<AppData>(context, listen: listen);
  }

  static AppData set(context, {bool listen = false}) {
    return Provider.of<AppData>(context, listen: listen);
  }

  StaffModel? auth_staff;

  UserModel? active_user;
  DoctorModel? active_doctor;

  List<ClientListModel> clients = [];
  List<ClientSignInModel> client_list = [];

  List<PatientModel> patients = [];

  List<AccessoryModel> accessories = [];

  List<AccessoryRequestModel> accessory_request = [];

  List<SalesRecordModel> sales_record = [];
  List<RestockAccessoryRecordModel> restock_record = [];

  List<DoctorModel> doctors = [];

  List<PhysioClientListModel> doctors_patients = [];
  List<PhysioClientListModel> doctors_ong_patients = [];

  List<UserModel> users = [];

  List<HMO_Model> gym_hmo = [];
  List<HMO_Model> physio_hmo = [];

  ClientSignInModel? sign_in_cl;

  List<PasswordModel> passwords = [];

  void update_passwords(List<PasswordModel> value) {
    passwords = value;
    notifyListeners();
  }

  void update_sign_in_cl(ClientSignInModel? value) {
    sign_in_cl = value;
    notifyListeners();
  }

  void update_gym_hmo(List<HMO_Model> value) {
    gym_hmo = value;
    notifyListeners();
  }

  void update_physio_hmo(List<HMO_Model> value) {
    physio_hmo = value;
    notifyListeners();
  }

  // ? USERS
  void update_users(List<UserModel> value) {
    users = value;
    notifyListeners();
  }

  void update_user(UserModel value) {
    var user = users.indexWhere((p) => p.key == value.key);

    if (user != -1) {
      users[user] = value;
    } else {
      users.add(value);
    }

    notifyListeners();
  }

  void delete_user(String value) {
    var user = users.indexWhere((p) => p.key == value);

    if (user != -1) {
      users.removeAt(user);
    }

    notifyListeners();
  }

  void update_doctors(List<DoctorModel> value) {
    doctors = value;
    notifyListeners();
  }

  void update_doctor(DoctorModel value) {
    var doctor = doctors.indexWhere((p) => p.key == value.key);

    if (doctor != -1) {
      doctors[doctor] = value;
    } else {
      doctors.add(value);
    }

    notifyListeners();
  }

  void delete_doctor(String value) {
    var doctor = doctors.indexWhere((p) => p.key == value);

    if (doctor != -1) {
      doctors.removeAt(doctor);
    }

    notifyListeners();
  }

// ?

  void update_clients(List<ClientListModel> value) {
    clients = value;
    notifyListeners();
  }

  void update_client_list(List<ClientSignInModel> value) {
    client_list = value;
    notifyListeners();
  }

  //? CLINIC
  void update_all_patients(List<PatientModel> value) {
    patients = value;
    notifyListeners();
  }

  void update_patient(PatientModel value) {
    var pat = patients.indexWhere((p) => p.key == value.key);

    if (pat != -1) {
      patients[pat] = value;
    } else {
      patients.add(value);
    }

    notifyListeners();
  }

  void delete_patient(String value) {
    var pat = patients.indexWhere((p) => p.key == value);

    if (pat != -1) {
      patients.removeAt(pat);
    }

    notifyListeners();
  }

  void update_accessory_requests(List<AccessoryRequestModel> value) {
    accessory_request = value;
    notifyListeners();
  }

  void update_accessory_request(AccessoryRequestModel value) {
    var acc = accessory_request.indexWhere((p) => p.key == value.key);

    if (acc != -1) {
      accessory_request[acc] = value;
    } else {
      accessory_request.add(value);
    }

    notifyListeners();
  }

  void delete_accessory_request(String value) {
    var pat = accessory_request.indexWhere((p) => p.key == value);

    if (pat != -1) {
      accessory_request.removeAt(pat);
    }

    notifyListeners();
  }

  void delete_all_accessory_request() {
    accessory_request.clear();

    notifyListeners();
  }

  //?

  //? STORE
  
  void update_accessories(List<AccessoryModel> value) {
    accessories = value;
    notifyListeners();
  }

  void update_accessory(AccessoryModel value) {
    var acc = accessories.indexWhere((p) => p.key == value.key);

    if (acc != -1) {
      accessories[acc] = value;
    } else {
      accessories.add(value);
    }

    notifyListeners();
  }

  void delete_accessory(String value) {
    var pat = accessories.indexWhere((p) => p.key == value);

    if (pat != -1) {
      accessories.removeAt(pat);
    }

    notifyListeners();
  }

  void update_sales_record(List<SalesRecordModel> value) {
    sales_record = value;
    notifyListeners();
  }

  void update_restock_record(List<RestockAccessoryRecordModel> value) {
    restock_record = value;
    notifyListeners();
  }

  //?

  void update_active_user(UserModel value) {
    active_user = value;
    notifyListeners();
  }

  void update_single_doctor(DoctorModel value) {
    doctors.where((e) => e.key == value.key).toList().first = value;
    notifyListeners();
  }

  void update_active_doctor(DoctorModel value) {
    active_doctor = value;
    notifyListeners();
  }

  void update_doctors_patients(List<PhysioClientListModel> value) {
    doctors_patients = value;
    notifyListeners();
  }

  void update_doctors_ong_patients(List<PhysioClientListModel> value) {
    doctors_ong_patients = value;
    notifyListeners();
  }
}
