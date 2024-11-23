

import 'package:flutter/material.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/helpers/physio_database_helpers.dart';
import 'package:heritage_soft/helpers/staff_database_helpers.dart';
import 'package:heritage_soft/pages/homepage.dart';
import 'package:heritage_soft/pages/physio/doctors_homepage.dart';

import "package:universal_html/html.dart" as html;

class MainTree extends StatefulWidget {
  const MainTree({super.key});

  @override
  State<MainTree> createState() => _MainTreeState();
}

class _MainTreeState extends State<MainTree> {
  @override
  void initState() {
    // check_network();

    // get gym clients
    if (app_role != 'doctor') GymDatabaseHelpers.get_gym_clients(context);

    // get all staff
    if (app_role != 'doctor') StaffDatabaseHelpers.get_all_staff(context);

    // get physio clients and lsiten to doctors
    PhysioDatabaseHelpers.get_physio_clients(context);

    // get accessories
    AdminDatabaseHelpers.get_accessories(context);

    // get accessory request
    if (app_role != 'doctor')
      AdminDatabaseHelpers.get_accessory_request_stream(context);

    // get hmos
    AdminDatabaseHelpers.get_hmos(context);

    // get passwords
    AdminDatabaseHelpers.get_passwords(context);

    // get office variables
    AdminDatabaseHelpers.get_office_var();

    // attendance listener for notification
    if (app_role == 'desk')
      AdminDatabaseHelpers.listen_to_sign_in_user(context);

    // free clinic space listener for notification
    if (app_role == 'desk') PhysioDatabaseHelpers.listen_to_free_doc(context);

    // get news
    AdminDatabaseHelpers.get_news();

    super.initState();
  }

  @override
  void dispose() {
    html.window.location.reload();
    super.dispose();
  }

  bool hasConnection = true;

  // check_network() async {
  //   try {
  //     await FirebaseFirestore.instance.runTransaction((Transaction tx) {
  //       return Future(() => null);
  //     }).timeout(Duration(seconds: 5));
  //     hasConnection = true;
  //   } on PlatformException catch (_) {
  //     // May be thrown on Airplane mode
  //     hasConnection = false;
  //   } on TimeoutException catch (_) {
  //     hasConnection = false;
  //   } catch (_) {
  //     hasConnection = false;
  //   }

  //   print(hasConnection);
  //   check_network();
  // }

  @override
  Widget build(BuildContext context) {
    return (app_role == 'doctor') ? DoctorsHomepage() : HomePage();
  }
}
