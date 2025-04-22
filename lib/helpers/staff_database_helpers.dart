// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/attendance_model.dart';
import 'package:heritage_soft/datamodels/users_model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/pages/sign_in_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StaffDatabaseHelpers {
  static final dynamic staff_ref = "FirebaseFirestore.instance.collection('Staffs')";

  // staff stream
  static Stream staff_stream() {
    return staff_ref.snapshots();
  }

  // get all staff from stream
  static get_all_staff(context) {
    StaffDatabaseHelpers.staff_stream().listen((event) {
      List<StaffModel> staffs = [];

      event.docs.forEach((e) {
        StaffModel staff = StaffModel.fromMap(e.id, e.data());
        staffs.add(staff);

        // if staff failed to sign out
        if (!staff.in_out) {
          String in_time = e.data()['in_time'] ?? '';
          if (in_time != '') {
            DateTime in_t = DateTime.parse(in_time);

            bool is_tod = (DateTime.now().year == in_t.year) &&
                (DateTime.now().month == in_t.month) &&
                (DateTime.now().day == in_t.day);

            if (!is_tod) {
              Map<String, dynamic> data = {
                'in_out': true,
                'in_time': '',
                'last_activity': {'time_in': 'absent'},
              };

              update_staff_details(e.id, data);
            }
          }
        }

        // set fresh day
        if (e.data()['last_check_in_date'] != null &&
            e.data()['last_check_in_date'] != '') {
          DateTime last_check_in_date =
              DateTime.parse(e.data()['last_check_in_date']);

          bool same_day = (DateTime.now().year == last_check_in_date.year) &&
              (DateTime.now().month == last_check_in_date.month) &&
              (DateTime.now().day == last_check_in_date.day);

          if (!same_day) {
            update_staff_details(e.id, {'fresh_day': true});
          }
        }
      });

      Provider.of<AppData>(context, listen: false).update_staffs(staffs);
    });
  }

  // get staff
  static Future get_staff() {
    return staff_ref.get();
  }

  // get staff attendance
  static Future get_staff_attendance_by_key(String key) async {
    // return FirebaseDatabase.instance
    //     .ref('Staff_Personal_attendance')
    //     .child(key)
    //     .get();
  }

  // update staff details
  static Future<bool> update_staff_details(
      String staff_key, Map<String, dynamic> data,
      {bool new_staff = false}) async {
    try {
      if (new_staff) {
        await staff_ref.add(data);

        // FirebaseFirestore.instance
        //     .collection('Office')
        //     .doc('Last ID')
        //     .update({'last_st_id': Helpers.strip_id(data['user_id'])});
      } else
        await staff_ref.doc(staff_key).update(data);

      return true;
    } catch (e) {
      return false;
    }
  }

  // update doctor details
  static Future<bool> update_doctor_details(
      String staff_key, Map<String, dynamic> data,
      {bool new_staff = false}) async {
     dynamic doctor_ref =
        "FirebaseFirestore.instance.collection('Doctors').doc(staff_key)";
    try {
      if (new_staff)
        await doctor_ref.set(data);
      else
        await doctor_ref.update(data);

      return true;
    } catch (e) {
      return false;
    }
  }

  // sign in to app
  static Future sign_in_to_app(
      String user_id)  async  {
    // return FirebaseFirestore.instance
    //     .collection('Staffs')
    //     .where('user_id', isEqualTo: user_id)
    //     .get();
  }

  // delete staff
  static Future<bool> delete_staff(String staff_key) async {
    try {
      await staff_ref.doc(staff_key).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // get staff details
  static Future get_staff_details(
      String staff_key) {
    return staff_ref.doc(staff_key).get();
  }

  // get doctor details
  static Future get_doctor_details(
      String doctor_key) async  {
    // return FirebaseFirestore.instance
    //     .collection('Doctors')
    //     .doc(doctor_key)
    //     .get();
  }

  // logout doctor
  static Future set_doctor_status(String doctor_key, bool status) async {
    // try {
    //   FirebaseFirestore.instance
    //       .collection('Doctors')
    //       .doc(doctor_key)
    //       .update({'is_available': status});
    //   return true;
    // } catch (e) {
    //   return false;
    // }
  }

  // set user password
  static Future<bool> set_password(
      {required context,
      required String user_key,
      required String password}) async {
    // setup password
    // var pass = await showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => PasswordSetup(password: password),
    // );

    // if (pass == null) return false;

    Helpers.showLoadingScreen(context: context);

    bool us = await update_staff_details(user_key, {'password': 'pass'});

    // remove loading screen
    Navigator.pop(context);

    if (!us) {
      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'An error occurred, Try again',
        icon: Icons.error,
      );
      return false;
    }

    Helpers.showToast(
      context: context,
      color: Colors.blue,
      toastText: 'Password set',
      icon: Icons.error,
    );

    return true;
  }

  // mark staff attendance
  static mark_staff_attendance(bool sign_in, String key, String in_time) async {
    DateTime tod_date = DateTime.now();

    int current_hour = tod_date.hour;
    String time = DateFormat.jm().format(tod_date);

    String month = DateFormat("MMMM, yyyy").format(tod_date);
    String date = DateFormat("d MMMM, yyyy").format(tod_date);

    // DatabaseReference patt_loc = FirebaseDatabase.instance
    //     .ref('Staff_Personal_attendance/$key/$month/$date');

    // DatabaseReference gatt_loc = FirebaseDatabase.instance
    //     .ref('Staff_General_attendance/$month/$date/$key');

    // // sign in
    // if (sign_in) {
    //   PAH? ss = null;

    //   // morning
    //   if (current_hour < 12) {
    //     ss = PAH(
    //       session: 'morning',
    //       time_in: time,
    //       time_out: '',
    //     );
    //   }

    //   // afternoon
    //   else if (current_hour >= 12 && current_hour < 16) {
    //     ss = PAH(
    //       session: 'afternoon',
    //       time_in: time,
    //       time_out: '',
    //     );
    //   }

    //   // evening
    //   else if (current_hour >= 16 && current_hour < 22) {
    //     ss = PAH(
    //       session: 'evening',
    //       time_in: time,
    //       time_out: '',
    //     );
    //   }

    //   // midnight
    //   else {
    //     ss = PAH(
    //       session: 'midnight',
    //       time_in: time,
    //       time_out: '',
    //     );
    //   }

    //   String dt = DateFormat("E, d MMM").format(tod_date);

    //   Map<String, dynamic> ss_map = ss.toJson();

    //   // save record to attendance
    //   await patt_loc.once().then((value) {
    //     if (value.snapshot.exists) {
    //       Map valu = value.snapshot.value as Map;
    //       Map ss_valu = valu['sessions'];

    //       int sv = ss_valu.length + 1;

    //       patt_loc.child('sessions/s$sv').set(ss_map);

    //       gatt_loc.child('sessions/s$sv').set(ss_map);
    //     } else {
    //       patt_loc.child('date').set(dt);
    //       patt_loc.child('sessions/s1').set(ss_map);

    //       gatt_loc.child('date').set(dt);
    //       gatt_loc.child('sessions/s1').set(ss_map);

    //       gatt_loc.child('daily_time_in').set(time);
    //     }
    //   });

    //   Map<String, dynamic> last_act = {
    //     'time_in': tod_date.toString(),
    //     'time_out': '',
    //   };

    //   Map<String, dynamic> upd_val = {
    //     'in_out': false,
    //     'in_time': tod_date.toString(),
    //     'last_activity': last_act,
    //     'last_check_in_date': tod_date.toString(),
    //     'fresh_day': false,
    //   };

    //   // update staff record
    //   staff_ref.doc(key).update(upd_val);
    // }

    // // sign out
    // else {
    //   // save record
    //   await patt_loc.once().then((value) {
    //     if (value.snapshot.exists) {
    //       Map valu = value.snapshot.value as Map;
    //       Map ss_valu = valu['sessions'];

    //       int sv = ss_valu.length;

    //       Map<String, dynamic> ss_map = {
    //         'time_out': time,
    //       };

    //       patt_loc.child('sessions/s$sv').update(ss_map);
    //       gatt_loc.child('sessions/s$sv').update(ss_map);

    //       gatt_loc.child('daily_time_out').set(time);
    //     }
    //   });

    //   Map<String, dynamic> last_act = {
    //     'time_in': in_time,
    //     'time_out': tod_date.toString(),
    //   };

    //   Map<String, dynamic> upd_val = {
    //     'in_out': true,
    //     'in_time': '',
    //     'last_activity': last_act,
    //   };

    //   // update staff record
    //   staff_ref.doc(key).update(upd_val);
    // }
  }

  //
}
