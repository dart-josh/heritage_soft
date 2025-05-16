import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/server_helpers.dart';
import 'package:heritage_soft/pages/clinic/doctors_profile.dart';
import 'package:heritage_soft/pages/clinic/doctor_patient_list.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/widgets/app_bar.dart';
import 'package:provider/provider.dart';

class DoctorsHomepage extends StatefulWidget {
  const DoctorsHomepage({super.key});

  @override
  State<DoctorsHomepage> createState() => _DoctorsHomepageState();
}

class _DoctorsHomepageState extends State<DoctorsHomepage> {
  dynamic get_doctor(dynamic data) async {
    DoctorModel doc = DoctorModel.fromMap(data);

    DoctorModel? active_doc = AppData.get(context, listen: false).active_doctor;

    if (active_doc != null && active_doc.key == doc.key) {
      AppData.set(context).update_active_doctor(doc);
    }
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () {
      ServerHelpers.socket!.on('Doctor', (data) {
        get_doctor(data);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    ServerHelpers.socket!.off('Doctor');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.75;
    double height = MediaQuery.of(context).size.height * 0.85;

    DoctorModel? doc = Provider.of<AppData>(context).active_doctor;

    return Scaffold(
      key: global_key,
      drawer: doc != null ? DoctorsProfile(doc: doc) : null,
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'images/clinic.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // background cover box
          Positioned.fill(
            child: Container(
              decoration:
                  BoxDecoration(color: Color(0xFF202020).withOpacity(0.20)),
            ),
          ),

          // blur cover box
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 2.0,
                sigmaY: 2.0,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // main content (dialog box)
          Container(
            margin: EdgeInsets.only(top: 45),
            child: Center(
              child: Container(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    // background
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          'images/clinic.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              Color.fromARGB(188, 43, 46, 50).withOpacity(0.83),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // main content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),

                        Expanded(child: main_page()),

                        // bottom text
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            'HERITAGE PHYSIOTHERAPY CLINIC',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'MsLineDraw',
                              color: Color(0xFFC6C6C6),
                              fontSize: 27,
                              shadows: [
                                Shadow(
                                  color: Color(0xFF000000),
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // app bar
          Positioned.fill(
            child: Container(
              child: MyAppBar(),
            ),
          ),

          //
        ],
      ),
    );
  }

  // WIDGETs

  // main page
  Widget main_page() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            pt_client(),
            SizedBox(width: 50),
            pt_profile(),
          ],
        ),
      ),
    );
  }

  // tiles
  Widget pt_client() {
    DoctorModel? active_doctor = AppData.get(context).active_doctor;
    int pen_ong_patient_count = 0;

    if (active_doctor != null) {
      pen_ong_patient_count = (active_doctor.pen_patients.length +
          active_doctor.ong_patients.length);
    }

    return InkWell(
      onTap: () {
        if (active_doctor != null) {
          doctor_force_logout = 0;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PatientList(
                      pending_patient: active_doctor.pen_patients,
                      ongoing_patient: active_doctor.ong_patients,
                      my_patients: active_doctor.my_patients,
                    )),
          );
        }
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // background
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'images/pt_clients.jpeg',
                      fit: BoxFit.cover,
                      width: 200,
                      height: 220,
                    ),
                  ),

                  // background cover box
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF01040A).withOpacity(0.53),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  // main content
                  Positioned.fill(
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 60, color: Colors.white),
                        SizedBox(height: 20),
                        Text(
                          'Physio Patients',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                // pending
                notification(
                  active_doctor,
                  count: active_doctor?.pen_patients.length ?? 0,
                  color: Colors.redAccent,
                  index: 1,
                ),

                // ongoing
                notification(
                  active_doctor,
                  count: active_doctor?.ong_patients.length ?? 0,
                  color: Colors.orange,
                  index: 0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget pt_profile() {
    return InkWell(
      onTap: () {
        doctor_force_logout = 0;
        global_key.currentState!.openDrawer();
      },
      child: Container(
        width: 220,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Stack(
          children: [
            // background
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                'images/doctor.jpg',
                fit: BoxFit.cover,
                width: 200,
                height: 220,
              ),
            ),

            // background cover box
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF01040A).withOpacity(0.53),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            // main content
            Positioned.fill(
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 60, color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'My Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  // notification
  Widget notification(DoctorModel? active_doctor,
      {required int count, required Color color, required int index}) {
    if (count == 0 || active_doctor == null) return Container();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PatientList(
                    pending_patient: active_doctor.pen_patients,
                    ongoing_patient: active_doctor.ong_patients,
                    my_patients: active_doctor.my_patients,
                    inital_index: index,
                  )),
        );
      },
      child: Container(
        height: 21,
        width: 21,
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            count.toString(),
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1),
          ),
        ),
      ),
    );
  }
  //
}
