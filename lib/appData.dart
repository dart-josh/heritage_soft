import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/accessories_shop_model.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/datamodels/clinic_models/patient.model.dart';
import 'package:heritage_soft/datamodels/hmo_model.dart';
import 'package:heritage_soft/datamodels/password_model.dart';
import 'package:heritage_soft/datamodels/physio_client_model.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/datamodels/users_model.dart';
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

  List<A_ShopModel> accessory_request = [];

  List<DoctorModel> all_doctors = [];

  List<PhysioClientListModel> doctors_patients = [];
  List<PhysioClientListModel> doctors_ong_patients = [];

  List<StaffModel> staffs = [];

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

  void update_staffs(List<StaffModel> value) {
    staffs = value;
    notifyListeners();
  }

  void update_clients(List<ClientListModel> value) {
    clients = value;
    notifyListeners();
  }

  void update_client_list(List<ClientSignInModel> value) {
    client_list = value;
    notifyListeners();
  }

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

  void update_accessories(List<AccessoryModel> value) {
    accessories = value;
    notifyListeners();
  }

  void update_accessory_request(List<A_ShopModel> value) {
    accessory_request = value;
    notifyListeners();
  }

  void update_active_user(UserModel value) {
    active_user = value;
    notifyListeners();
  }

  void update_all_doctors(List<DoctorModel> value) {
    all_doctors = value;
    notifyListeners();
  }

  void update_single_doctor(DoctorModel value) {
    all_doctors.where((e) => e.key == value.key).toList().first = value;
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
