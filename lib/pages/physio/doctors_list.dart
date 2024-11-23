import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'dart:ui' as ui;

import 'package:heritage_soft/datamodels/users_model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/physio/doctors_profile.dart';
import 'package:provider/provider.dart';

class DoctorsList extends StatefulWidget {
  const DoctorsList({super.key, this.from_clinic = false});

  final bool from_clinic;

  @override
  State<DoctorsList> createState() => _DoctorsListState();
}

class _DoctorsListState extends State<DoctorsList> {
  final GlobalKey<ScaffoldState> sc_key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width * 0.8;
    double height = MediaQuery.of(context).size.height * 0.7;
    return Scaffold(
      key: sc_key,
      drawer:
          active_doctor != null ? DoctorsProfile(doc: active_doctor!) : null,
      body: Stack(
        children: [
          // background
          Positioned.fill(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.asset(
                'images/background1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // background cover box
          Positioned.fill(
            child: Container(
              decoration:
                  BoxDecoration(color: Color(0xFFe0d9d2).withOpacity(0.20)),
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
                          'images/doctors.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // background cover box
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF202020).withOpacity(0.69),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),

                    // main content
                    Column(
                      children: [
                        // main content
                        Expanded(child: main_page()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGETS
  Widget main_page() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
          // top bar
          topBar(),

          // subtitle
          if (widget.from_clinic)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Select one to the doctors to proceed to clinic',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    BoxShadow(
                      offset: Offset(0.7, 0.7),
                      blurRadius: 5,
                      color: Colors.black12,
                    ),
                  ],
                ),
              ),
            ),

          // main box
          Expanded(child: main_box()),
        ],
      ),
    );
  }

  // top bar
  Widget topBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFd1cfcf)),
        ),
      ),
      child: Stack(
        children: [
          // heading
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Center(
              child: Text(
                'Physiotherapist\'s',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  height: 1,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.7,
                  fontSize: 20,
                  shadows: [
                    Shadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // close button
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.cancel,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // main box
  Widget main_box() {
    List<DoctorModel> doctors = Provider.of<AppData>(context).all_doctors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // doctors
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                // scrollDirection: Axis.horizontal,
                child: Wrap(
                  runSpacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceAround,
                  runAlignment: WrapAlignment.center,
                  children: doctors.map((e) => doctors_tile(e)).toList(),
                ),
              ),
            ),
          ),

          if (widget.from_clinic) SizedBox(height: 20),

          if (widget.from_clinic) proceed_button(),
        ],
      ),
    );
  }

  DoctorModel? active_doctor;

  // doctors tile
  Widget doctors_tile(DoctorModel doctor) {
    bool active = doctor.is_available && doctor.active_patients == 0;
    bool wating = doctor.is_available && doctor.active_patients == 1;
    bool not_active = doctor.is_available && doctor.active_patients >= 2;

    return InkWell(
      onTap: () {
        // from clinic tab
        if (widget.from_clinic) {
          if (active_doctor == doctor) {
            active_doctor = null;
          } else {
            active_doctor = doctor;
          }

          setState(() {});
        }
        // from homepage
        else {
          active_doctor = doctor;
          setState(() {});
          Future.delayed(
            Duration(milliseconds: 200),
            () => sc_key.currentState!.openDrawer(),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 1,
            color: (active_doctor == doctor)
                ? Colors.greenAccent
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            // profile image
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: not_active
                      ? Colors.redAccent
                      : wating
                          ? Colors.orange.shade300
                          : active
                              ? Colors.green
                              : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Color.fromARGB(79, 132, 126, 249),
              ),
              width: 120,
              height: 120,
              child: Center(
                child: doctor.user_image.isEmpty
                    ? Image.asset(
                        'images/icon/user-alt.png',
                        width: 60,
                        height: 60,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          doctor.user_image,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 10),

            // name
            Text(
              doctor.fullname,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),

            SizedBox(height: 2),

            // status
            Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: not_active
                    ? Colors.redAccent
                    : wating
                        ? Colors.orange.shade300
                        : active
                            ? Colors.green
                            : Colors.grey,
              ),
              child: Center(
                child: Text(
                  not_active
                      ? 'Occupied'
                      : wating
                          ? '1 Patient'
                          : active
                              ? 'Available'
                              : 'Not Available',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // select doctor button (if from clinic)
  Widget proceed_button() {
    if (active_doctor == null || !active_doctor!.is_available)
      return Container(height: 45);

    bool active =
        active_doctor!.is_available && active_doctor!.active_patients == 0;
    bool wating =
        active_doctor!.is_available && active_doctor!.active_patients == 1;
    bool not_active =
        active_doctor!.is_available && active_doctor!.active_patients >= 2;

    return InkWell(
      onTap: () async {
        if (active || wating) {
          Navigator.pop(context, active_doctor);
        } else {
          Helpers.showToast(
            context: context,
            color: Colors.redAccent,
            toastText: 'Try a different doctor',
            icon: Icons.error,
          );
        }
      },
      child: Container(
        width: 200,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            active
                ? 'Send to Clinic'
                : wating
                    ? 'Join Waitlist'
                    : not_active
                        ? ''
                        : '',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  //
}
