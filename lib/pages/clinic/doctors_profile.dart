import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/user_helpers.dart';
import 'package:heritage_soft/pages/clinic/doctor_patient_list.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:provider/provider.dart';

class DoctorsProfile extends StatefulWidget {
  final DoctorModel doc;
  const DoctorsProfile({super.key, required this.doc});

  @override
  State<DoctorsProfile> createState() => _DoctorsProfileState();
}

class _DoctorsProfileState extends State<DoctorsProfile> {
  UserModel? active_user;

  bool doc_availabilty = false;

  @override
  void initState() {
    doc_availabilty = widget.doc.is_available;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    active_user = AppData.get(context).active_user;

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
                          Helpers.format_amount(widget.doc.pen_patients.length),
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
                          Helpers.format_amount(widget.doc.ong_patients.length),
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
                          widget.doc.my_patients.isNotEmpty
                              ? Helpers.format_amount(widget.doc.my_patients
                                  .reduce((element, next) => MyPatientModel(
                                        patient:
                                            widget.doc.my_patients[0].patient,
                                        session_count: element.session_count +
                                            next.session_count,
                                      ))
                                  .session_count)
                              : '0',
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
                          Helpers.format_amount(widget.doc.my_patients.length),
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

                if (active_user?.app_role == 'Doctor' &&
                    (widget.doc.user.user_id == active_user?.user_id))
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
                            // update doctor availablity
                            widget.doc.is_available = false;

                            var res = await UserHelpers.add_update_doctor(
                                context,
                                data: widget.doc.toJson(),
                                showLoading: true,
                                showToast: true);
                            // logout

                            if (res['status']) {
                              Helpers.logout(context);
                            }
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
                            my_patients: widget.doc.my_patients,
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
                  backgroundImage: widget.doc.user.user_image.isNotEmpty
                      ? NetworkImage(
                          widget.doc.user.user_image,
                        )
                      : null,
                  child: Center(
                    child: widget.doc.user.user_image.isEmpty
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
                  widget.doc.user.f_name,
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
                    if ((active_user?.app_role != 'Doctor' ||
                            (widget.doc.user.user_id !=
                                active_user?.user_id)) &&
                        !active_user!.full_access) return;

                    int waiting_count =
                        Provider.of<AppData>(context, listen: false)
                            .doctors_ong_patients
                            .where((element) =>
                                element.pending_treatment ||
                                element.ongoing_treatment)
                            .length;

                    // go offline
                    if (doc_availabilty) {
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
                        // go offline
                        // update doctor availablity
                        widget.doc.is_available = false;

                        var res = await UserHelpers.add_update_doctor(context,
                            data: widget.doc.toJson(),
                            showLoading: true,
                            showToast: true);

                        if (res['status']) {
                          setState(() {
                            doc_availabilty = false;
                          });
                        }
                      }
                    }
                    // go online
                    else {
                      // go online
                      // update doctor availablity
                      widget.doc.is_available = true;

                      var res = await UserHelpers.add_update_doctor(context,
                          data: widget.doc.toJson(),
                          showLoading: true,
                          showToast: true);

                      if (res['status']) {
                        setState(() {
                          doc_availabilty = true;
                        });
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: doc_availabilty
                          ? Colors.green.withOpacity(.8)
                          : Colors.redAccent.withOpacity(.8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    width: 85,
                    height: 18,
                    child: Center(
                      child: Text(
                        doc_availabilty ? 'Available' : 'Unavailable',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ),
                    ),
                  ),
                ),

                // user id
                if ((active_user?.full_access ?? false) ||
                    (widget.doc.user.user_id == active_user?.user_id))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.doc.user.user_id,
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // delete button
                      if (active_user?.full_access ?? false)
                        IconButton(
                          onPressed: () async {
                            var conf = await Helpers.showConfirmation(
                                context: context,
                                title: 'Delete Doctor',
                                message:
                                    'You are about to delete this doctor from the database. Would you like to proceed?');

                            if (conf) {
                              Map del = await UserHelpers.delete_doctor(
                                context,
                                user_id: widget.doc.key ?? '',
                                showLoading: true,
                                showToast: true,
                              );

                              if (del['status'] == true) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
