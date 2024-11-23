import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/users_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/staff_database_helpers.dart';
import 'package:heritage_soft/helpers/utils.dart';
import 'package:heritage_soft/pages/physio/patient_list.dart';
import 'package:heritage_soft/pages/sign_in_page.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:provider/provider.dart';

class DoctorsProfile extends StatefulWidget {
  final DoctorModel doc;
  const DoctorsProfile({super.key, required this.doc});

  @override
  State<DoctorsProfile> createState() => _DoctorsProfileState();
}

class _DoctorsProfileState extends State<DoctorsProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      color: Colors.transparent,
      child: Stack(
        children: [
          Container(
            height: 40,
            width: 350,
            color: Colors.transparent,
          ),

          // main box
          Container(
            margin: EdgeInsets.only(top: 55),
            decoration: BoxDecoration(
              color: Color.fromARGB(219, 219, 213, 179),
              borderRadius: BorderRadius.only(topRight: Radius.circular(6)),
            ),
            padding: EdgeInsets.only(top: 100, left: 20, right: 20),
            child: Column(
              children: [
                SizedBox(height: 50),
                // pending & ongoing treatment counts
                Row(
                  children: [
                    // pending
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Helpers.format_amount(widget.doc.pen_treatment),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'Pending Treatments',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    Expanded(child: Container()),

                    // ongoing
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Helpers.format_amount(widget.doc.ong_treatment),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'Ongoing Treatment',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // session & patient counts
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // total sessions count
                        Text(
                          Helpers.format_amount(widget.doc.total_sessions),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),

                        // total session label
                        Text(
                          'Treatment Sessions',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        SizedBox(height: 30),

                        // patients count
                        Text(
                          Helpers.format_amount(widget.doc.patients),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),

                        // patients label
                        Text(
                          'Patients',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10),

                if (active_doctor != null &&
                    app_role == 'doctor' &&
                    (widget.doc.user_id == active_doctor!.user_id))
                  // logout
                  Row(
                    children: [
                      Expanded(child: Container()),

                      // logout
                      TextButton(
                        onPressed: () async {
                          int waiting_count =
                              Provider.of<AppData>(context, listen: false)
                                  .doctors_ong_patients
                                  .where((element) =>
                                      element.pending_treatment ||
                                      element.ongoing_treatment)
                                  .length;

                          // if pending patient or ongoing patient
                          if (waiting_count > 0) {
                            if (doctor_force_logout < 1) {
                              doctor_force_logout++;
                              Helpers.showToast(
                                context: context,
                                color: Colors.red.shade400,
                                toastText: 'You have a pending patient',
                                icon: Icons.warning,
                              );
                              return;
                            }
                          }

                          var conf = await showDialog(
                            context: context,
                            builder: (context) => ConfirmDialog(
                              title: 'Log Out',
                              subtitle:
                                  'You are about to log out and go offline. Would you like to proceed?',
                            ),
                          );

                          if (conf != null && conf) {
                            Helpers.showLoadingScreen(context: context);

                            bool dt =
                                await StaffDatabaseHelpers.set_doctor_status(
                                    widget.doc.key, false);

                            Navigator.pop(context);

                            // error
                            if (!dt) {
                              Helpers.showToast(
                                context: context,
                                color: Colors.red,
                                toastText: 'An Error occured, Try again',
                                icon: Icons.error,
                              );
                              return;
                            }

                            // removed saved user
                            await Utils.remove_user();

                            // remove drawer
                            Navigator.pop(context);

                            // go to sign in page
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInToApp(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: Text('Log Out'),
                      ),
                    ],
                  )

                // view patients
                else
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientList(
                            ongoing_patient: widget.doc.ong_patients,
                            my_patients: widget.doc.all_patients,
                            pending_patient: widget.doc.pen_patients,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      width: 180,
                      height: 35,
                      child: Center(
                        child: Text(
                          'View Patients',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
              ],
            ),
          ),

          // profile, name & title
          Positioned(
            top: 10,
            left: 15,
            child: Column(
              children: [
                // profile image
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromARGB(255, 164, 183, 209),
                  foregroundColor: Colors.white,
                  backgroundImage: widget.doc.user_image.isNotEmpty
                      ? NetworkImage(
                          widget.doc.user_image,
                        )
                      : null,
                  child: Center(
                    child: widget.doc.user_image.isEmpty
                        ? Image.asset(
                            'images/icon/health-person.png',
                            width: 45,
                            height: 45,
                          )
                        : Container(),
                  ),
                ),

                SizedBox(height: 10),

                // doctor name
                Text(
                  widget.doc.fullname,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                // doctor title
                Text(widget.doc.title, style: TextStyle(fontSize: 12)),
              ],
            ),
          ),

          // status & user id
          Positioned(
            top: 70,
            right: 15,
            child: Column(
              children: [
                // status
                InkWell(
                  onTap: () async {
                    if (active_doctor == null) return;

                    if (app_role != 'doctor' ||
                        (widget.doc.user_id != active_doctor!.user_id)) return;

                    int waiting_count =
                        Provider.of<AppData>(context, listen: false)
                            .doctors_ong_patients
                            .where((element) =>
                                element.pending_treatment ||
                                element.ongoing_treatment)
                            .length;

                    // go offline
                    if (widget.doc.is_available) {
                      if (waiting_count > 0) {
                        Helpers.showToast(
                          context: context,
                          color: Colors.amber.shade400,
                          toastText: 'You have a pending patient',
                          icon: Icons.warning,
                        );
                        return;
                      }

                      var conf = await showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                          title: 'GO OFFLINE',
                          subtitle:
                              'You are about to go offline. Would you like to proceed?',
                        ),
                      );

                      if (conf != null && conf) {
                        Helpers.showLoadingScreen(context: context);

                        // go offline
                        bool dt = await StaffDatabaseHelpers.set_doctor_status(
                            widget.doc.key, false);

                        Navigator.pop(context);

                        // error
                        if (!dt) {
                          Helpers.showToast(
                            context: context,
                            color: Colors.red,
                            toastText: 'An Error occured, Try again',
                            icon: Icons.error,
                          );
                          return;
                        }

                        setState(() {
                          widget.doc.is_available = false;
                        });
                      }
                    }
                    // go online
                    else {
                      Helpers.showLoadingScreen(context: context);

                      // go online
                      bool dt = await StaffDatabaseHelpers.set_doctor_status(
                          widget.doc.key, true);

                      Navigator.pop(context);

                      // error
                      if (!dt) {
                        Helpers.showToast(
                          context: context,
                          color: Colors.red,
                          toastText: 'An Error occured, Try again',
                          icon: Icons.error,
                        );
                        return;
                      }

                      setState(() {
                        widget.doc.is_available = true;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.doc.is_available
                          ? Colors.green.withOpacity(.8)
                          : Colors.redAccent.withOpacity(.8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    width: 85,
                    height: 18,
                    child: Center(
                      child: Text(
                        widget.doc.is_available ? 'Available' : 'Unavailable',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ),
                    ),
                  ),
                ),

                if (active_doctor != null &&
                    app_role == 'doctor' &&
                    (widget.doc.user_id != active_doctor!.user_id))
                  SizedBox(height: 5),
                if (active_doctor != null &&
                    app_role == 'doctor' &&
                    (widget.doc.user_id != active_doctor!.user_id))
                  Text(
                    widget.doc.user_id,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
