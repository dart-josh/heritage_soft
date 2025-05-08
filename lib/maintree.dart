import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/store_models/accessory.model.dart';
import 'package:heritage_soft/datamodels/store_models/accessory_request.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/helpers/clinic_database_helpers.dart';
import 'package:heritage_soft/helpers/store_database_helpers.dart';
import 'package:heritage_soft/helpers/server_helpers.dart';
import 'package:heritage_soft/helpers/user_helpers.dart';
import 'package:heritage_soft/pages/homepage.dart';
import 'package:heritage_soft/pages/clinic/doctors_homepage.dart';

class MainTree extends StatefulWidget {
  const MainTree({super.key});

  @override
  State<MainTree> createState() => _MainTreeState();
}

class _MainTreeState extends State<MainTree> {
  UserModel? active_user;

  initators() async {
    active_user = AppData.get(context, listen: false).active_user ?? null;
    ServerHelpers.start_socket_listerners();

    // get doctors
    if (active_user?.app_role != 'Doctor') UserHelpers.get_doctors(context);

    // get accessories
    StoreDatabaseHelpers.get_all_accessories(context);

    // get_all_accessory_requests
    if (active_user?.app_role == 'CSU' || active_user?.full_access == true)
      ClinicDatabaseHelpers.get_all_accessory_requests(context);

    // // get hmos
    // AdminDatabaseHelpers.get_hmos(context);

    // // get passwords
    // AdminDatabaseHelpers.get_passwords(context);

    // // get office variables
    // AdminDatabaseHelpers.get_office_var();

    // // get news
    // AdminDatabaseHelpers.get_news();
  }

  //? ACCESSORY
  // update accessory from stream
  dynamic update_accessory(dynamic data) async {
    AccessoryModel acc = AccessoryModel.fromMap(data);

    AppData.set(context).update_accessory(acc);
  }

  // remove accessory from stream
  dynamic remove_accessory(dynamic id) async {
    AppData.set(context).delete_accessory(id);
  }

  // start accessory listener
  start_accessory_listener() {
    ServerHelpers.socket!.on('Accessory', (data) {
      update_accessory(data);
    });
    ServerHelpers.socket!.on('AccessoryD', (data) {
      remove_accessory(data);
    });
  }

  // end accessory listener
  end_accessory_listener() {
    ServerHelpers.socket!.off('Accessory');
    ServerHelpers.socket!.off('AccessoryD');
  }

  //? ACCESSORY REQUEST
  // update accessory from stream
  dynamic update_accessory_request(dynamic data) async {
    AccessoryRequestModel acc = AccessoryRequestModel.fromMap(data);

    AppData.set(context).update_accessory_request(acc);
  }

  // remove accessory_request from stream
  dynamic remove_accessory_request(dynamic id) async {
    AppData.set(context).delete_accessory_request(id);
  }

  // remove all accessory_request from stream
  dynamic remove_all_accessory_request() async {
    AppData.set(context).delete_all_accessory_request();
  }

  // start accessory_request listener
  start_accessory_request_listener() {
    ServerHelpers.socket!.on('AccessoryRequest', (data) {
      update_accessory_request(data);
    });
    ServerHelpers.socket!.on('AccessoryRequestD', (data) {
      remove_accessory_request(data);
    });
    ServerHelpers.socket!.on('AccessoryRequestDA', (data) {
      remove_all_accessory_request();
    });
  }

  // end accessory_request listener
  end_accessory_request_listener() {
    ServerHelpers.socket!.off('AccessoryRequest');
    ServerHelpers.socket!.off('AccessoryRequestD');
    ServerHelpers.socket!.off('AccessoryRequestDA');
  }

  @override
  void initState() {
    initators();
    start_accessory_listener();
    if (active_user?.app_role == 'CSU' || active_user?.full_access == true)
      start_accessory_request_listener();

    super.initState();
  }

  @override
  void dispose() {
    end_accessory_listener();
    if (active_user?.app_role == 'CSU' || active_user?.full_access == true)
      end_accessory_request_listener();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    active_user = AppData.get(context).active_user ?? null;
    return (active_user?.app_role == 'Doctor') ? DoctorsHomepage() : HomePage();
  }
}
