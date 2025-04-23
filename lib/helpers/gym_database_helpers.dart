// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/attendance_model.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GymDatabaseHelpers {
  static final dynamic ft_client_ref = '';

  // client stream
  static Stream clients_stream() {
    return ft_client_ref.snapshots();
  }

  // get all clients from stream
  static get_gym_clients(context) {
    GymDatabaseHelpers.clients_stream().listen((event) {
      List<ClientListModel> clients = [];
      List<ClientSignInModel> client_list = [];

      event.docs.forEach((e) {
        ClientListModel cl_1 = ClientListModel.fromMap(e.id, e.data());
        clients.add(cl_1);

        ClientSignInModel cl_2 = ClientSignInModel.fromMap(e.id, e.data());
        client_list.add(cl_2);

        // check for expired subscriptions
        if (!cl_2.sub_paused) {
          // expired sub plan
          if ((cl_2.sub_date.isNotEmpty) &&
              (cl_2.sub_status) &&
              Helpers.getDate(cl_2.sub_date).isBefore(DateTime.now())) {
            update_client_details(
              e.id,
              {'sub_status': false},
            );
          }

          // expired pt status
          if ((cl_2.pt_date.isNotEmpty) &&
              (cl_2.pt_status) &&
              Helpers.getDate(cl_2.pt_date).isBefore(DateTime.now())) {
            update_client_details(
              e.id,
              {'pt_status': false},
            );
          }

          // expired boxing
          if ((cl_2.bx_date.isNotEmpty) &&
              (cl_2.boxing) &&
              Helpers.getDate(cl_2.bx_date).isBefore(DateTime.now())) {
            update_client_details(
              e.id,
              {'boxing': false},
            );
          }
        }

        // if client failed to sign out
        if (!cl_2.in_out) {
          String in_time = e.data()['in_time'] ?? '';
          if (in_time != '') {
            DateTime in_t = DateTime.parse(in_time);

            bool is_tod = (DateTime.now().year == in_t.year) &&
                (DateTime.now().month == in_t.month) &&
                (DateTime.now().day == in_t.day);

            if (!is_tod) {
              update_client_details(e.id, {
                'in_out': true,
                'in_time': '',
                'last_activity': {'date_time': 'absent'},
              });
            }
          }
        }
      });

      // update clients for attendance
      Provider.of<AppData>(context, listen: false)
          .update_client_list(client_list);

      // update all clients
      Provider.of<AppData>(context, listen: false).update_clients(clients);
    });
  }

  // assign gym registration key
  static Future<String> assign_gym_registration_key() async {
    return await ft_client_ref.doc().id;
  }

  // check physio ID to ensure no duplicate
  static Future<List> check_gym_client_id(String client_id) async {
    try {
      var docs = await ft_client_ref.where('id', isEqualTo: client_id).get();

      if (docs.docs.isNotEmpty) {
        return [false, 'ID already exists, Reload software!'];
      }
    } catch (e) {
      return [false, 'An Error occurred'];
    }

    return [true, ''];
  }

  // register physio client
  static Future<bool> register_gym_client(String key, Map map) async {
    try {
      await ft_client_ref.doc(key).set(map);
    } catch (e) {
      return false;
    }

    return true;
  }

  // update last gym ID
  static update_last_gym_id(String client_id) async {
    // await FirebaseFirestore.instance
    //     .collection('Office')
    //     .doc('Last ID')
    //     .update({'last_ft_id': Helpers.strip_id(client_id)});
  }

  // set health details
  static Future<bool> set_health_details(String client_key, String health_key,
      Map health_data, Map summary_data) async {
    try {
      await GymDatabaseHelpers.ft_client_ref
          .doc(client_key)
          .collection('health_info')
          .doc(health_key)
          .set(health_data);
    } catch (e) {
      return false;
    }

    try {
      await GymDatabaseHelpers.ft_client_ref
          .doc(client_key)
          .collection('others')
          .doc('health_summary')
          .set(summary_data);
    } catch (e) {
      return false;
    }

    return true;
  }

  // client details stream
  static Stream client_details_stream(String client_key) {
    return ft_client_ref.doc(client_key).snapshots();
  }

  // get client details
  static Future get_client_details(String client_key) {
    return ft_client_ref.doc(client_key).get();
  }

  // client health summary stream
  static Stream client_health_summary_stream(String client_key) {
    return ft_client_ref
        .doc(client_key)
        .collection('others')
        .doc('health_summary')
        .snapshots();
  }

  // get health details
  static Future client_health_details(String client_key) {
    return ft_client_ref.doc(client_key).collection('health_info').get();
  }

  // add to sub history
  static Future<bool> add_to_sub_history(String client_key, Map data) async {
    try {
      data.addAll({'client_key': client_key});
      AdminDatabaseHelpers.sub_history_ref.push().set(data);
      await GymDatabaseHelpers.ft_client_ref
          .doc(client_key)
          .collection('Sub History')
          .add(data);

      return true;
    } catch (e) {
      return false;
    }
  }

  // get sub history
  static Future get_sub_history(String client_key) {
    return ft_client_ref.doc(client_key).collection('Sub History').get();
  }

  // delete client
  static Future<bool> delete_client(String client_key) async {
    try {
      await GymDatabaseHelpers.ft_client_ref.doc(client_key).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // get client personal attendance by month
  static Future get_client_personal_attendance_by_key(String key) async {
    // return FirebaseDatabase.instance
    //     .ref('Personal_attendance')
    //     .child(key)
    //     .get();
  }

  // get general attendance
  static Future get_daily_attendance_list(String month, String date) async {
    // return FirebaseDatabase.instance
    //     .ref('General_attendance')
    //     .child('$month/$date')
    //     .get();
  }

  // update client details
  static Future<bool> update_client_details(String key, Map map) async {
    try {
      await ft_client_ref.doc(key).update(map);
    } catch (e) {
      return false;
    }

    return true;
  }

  // reset week for hmo plan clients
  static reset_week_for_hmo_plan_clients(context) {
    dynamic hmo_week_ref =
        "'FirebaseFirestore.instance.collection('Office').doc('hmo_week')'";

    hmo_week_ref.get().then((snap) {
      if (snap.exists) {
        // add 6 days to the last date
        DateTime last_date =
            DateTime.parse(snap.data()!['last_week']).add(Duration(days: 6));

        // if the previous week is complete
        if (last_date.isBefore(DateTime.now())) {
          // get all client on hmo plan
          var cls = Provider.of<AppData>(context, listen: false)
              .clients
              .where((element) => element.sub_plan == 'HMO Plan')
              .toList();

          // reset the days checked in for each clinet
          cls.forEach((element) {
            GymDatabaseHelpers.update_client_details(
                element.key!, {'days_in': 0});
          });

          // reset last week
          hmo_week_ref.set({'last_week': DateTime.now().toString()});
        }
      }
    });
  }

  // mark attendance
  static mark_attendance(bool sign_in, String key, String in_time,
      {required String duration, required ClientSignInModel cl}) async {
    DateTime tod_date = DateTime.now();

    int current_hour = tod_date.hour;
    String time = DateFormat.jm().format(tod_date);

    String month = DateFormat("MMMM, yyyy").format(tod_date);
    String date = DateFormat("d MMMM, yyyy").format(tod_date);

    // DatabaseReference patt_loc =
    //     FirebaseDatabase.instance.ref('Personal_attendance/$key/$month/$date');

    // DatabaseReference gatt_loc =
    //     FirebaseDatabase.instance.ref('General_attendance/$month/$date/$key');

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

    //   Map ss_map = ss.toJson();

    //   // save attendance
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

    //   Map last_act = {
    //     'date_time': tod_date.toString(),
    //     'duration': '',
    //   };

    //   Map upd_val = {
    //     'in_out': false,
    //     'in_time': tod_date.toString(),
    //     'last_activity': last_act,
    //   };
    //   // update client
    //   update_client_details(key, upd_val);

    //   // notify desk
    //   Map mapp = cl.toJson();
    //   FirebaseFirestore.instance
    //       .collection('Office')
    //       .doc('Sign_in_user')
    //       .set(mapp);
    // }

    // // sign out
    // else {
    //   // save attendance
    //   await patt_loc.once().then((value) {
    //     if (value.snapshot.exists) {
    //       Map valu = value.snapshot.value as Map;
    //       Map ss_valu = valu['sessions'];

    //       int sv = ss_valu.length;

    //       Map ss_map = {
    //         'time_out': time,
    //       };

    //       patt_loc.child('sessions/s$sv').update(ss_map);
    //       gatt_loc.child('sessions/s$sv').update(ss_map);

    //       gatt_loc.child('daily_time_out').set(time);
    //     }
    //   });

    //   Map last_act = {
    //     'date_time': in_time,
    //     'duration': duration,
    //   };

    //   Map upd_val = {
    //     'in_out': true,
    //     'in_time': '',
    //     'last_activity': last_act,
    //   };

    //   // update client
    //   update_client_details(key, upd_val);
    // }
  }

  // verify indemnity
  static Future<bool> verify_indemnity(String key) async {
    try {
      await ft_client_ref.doc(key).update({'indemnity_verified': true});
      return true;
    } catch (e) {
      return false;
    }
  }

  static fix_db() async {
    var docs = await ft_client_ref.get();
    docs.docs.forEach((e) {
      if (e.data()['registered'] == true) {
        print('fixing ${e.data()['id']} - ${e.data()['sub_plan']}');
      }
    });
  }

  ///
}
