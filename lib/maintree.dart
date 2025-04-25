import 'package:flutter/material.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/server_helpers.dart';
import 'package:heritage_soft/helpers/user_helpers.dart';
import 'package:heritage_soft/pages/homepage.dart';
import 'package:heritage_soft/pages/physio/doctors_homepage.dart';

class MainTree extends StatefulWidget {
  const MainTree({super.key});

  @override
  State<MainTree> createState() => _MainTreeState();
}

class _MainTreeState extends State<MainTree> {
  @override
  void initState() {
    ServerHelpers.start_socket_listerners();

    // get accessories
    AdminDatabaseHelpers.get_accessories(context);

    // get doctors
    if (app_role != 'doctor') UserHelpers.get_all_doctors(context);

    // get accessory request
    if (app_role != 'doctor')
      AdminDatabaseHelpers.get_accessory_request_stream(context);

    // get hmos
    AdminDatabaseHelpers.get_hmos(context);

    // get passwords
    AdminDatabaseHelpers.get_passwords(context);

    // get office variables
    AdminDatabaseHelpers.get_office_var();

    // get news
    AdminDatabaseHelpers.get_news();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (app_role == 'Doctor') ? DoctorsHomepage() : HomePage();
  }
}
