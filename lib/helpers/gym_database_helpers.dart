import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/gym_models/client.model.dart';
import 'package:heritage_soft/datamodels/hmo_model.dart';
import 'package:heritage_soft/datamodels/income_model.dart';
import 'package:heritage_soft/db_helpers/gym_api.dart';
import 'package:provider/provider.dart';

class GymDatabaseHelpers {
  // ! GETTERS

  // get_all_clients
  static Future get_all_clients(BuildContext context) async {
    var response = await GymApi.get_all_clients(context);

    if (response != null) {
      List data = response['clients'];

      List<ClientModel> clients = [];

      data.forEach((e) {
        ClientModel cl_1 = ClientModel.fromMap(e);
        clients.add(cl_1);
      });

      Provider.of<AppData>(context, listen: false).update_all_clients(clients);
    }
  }

  // get_hmo
  static Future get_hmo(BuildContext context) async {
    var response = await GymApi.get_hmo(context);

    if (response != null) {
      List data = response['hmo'];

      List<HMO_Model> hmo = [];

      data.forEach((e) {
        HMO_Model cl_1 = HMO_Model.fromMap(e);
        hmo.add(cl_1);
      });

      Provider.of<AppData>(context, listen: false).update_gym_hmo(hmo);
    }
  }

  // get_gym_income
  static Future<List<GymIncomeModel>> get_gym_income(
      BuildContext context, String month) async {
    var response = await GymApi.get_gym_income(context, month);

    if (response != null) {
      List data = response['gym_income'];

      List<GymIncomeModel> income = [];

      data.forEach((e) {
        GymIncomeModel cl_1 = GymIncomeModel.fromMap(e);
        income.add(cl_1);
      });

      return income;
    }

    return [];
  }

  // ! SETTERS

  // register_client
  static Future<Map> register_client(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    var response = await GymApi.register_client(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (response != null && response['client'] != null) {
      ClientModel client = ClientModel.fromMap(response['client']);

      return {'status': true, 'client': client};
    } else
      return {'status': false};
  }

  // update_client_details
  static Future<Map> update_client_details(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    // {
    //           'data_type': 'name',
    //           'client_key': widget.cl_id,
    //           'client_details': client_update_details
    //         }
    var response = await GymApi.update_client(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (response != null && response['client'] != null) {
      ClientModel client = ClientModel.fromMap(response['client']);

      return {'status': true, 'client': client};
    } else
      return {'status': false};
  }

  // add to sub history
  static Future<bool> add_to_sub_history(
    BuildContext context, {
    required Map data,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    // {
    //   'client_key': '', 'sub_details': {},
    // }
    var response = await GymApi.add_to_sub_history(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (response != null && response['client'] != null) {
      // ClientModel client = ClientModel.fromMap(response['client']);

      return true;
    } else
      return false;
  }

  // add_update_hmo
  static Future<bool> add_update_hmo(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    // {key, hmo_name, days_week, hmo_amount}
    var response = await GymApi.add_update_hmo(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (response != null) {
      return true;
    } else
      return false;
  }

  //! set health details
  static Future<bool> update_health_details(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    var response = await GymApi.add_to_sub_history(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (response != null && response['client'] != null) {
      // ClientModel client = ClientModel.fromMap(response['client']);

      return true;
    } else
      return false;
  }

  //! verify indemnity
  static Future<bool> verify_indemnity(
    BuildContext context, {
    required Map data,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    var response = await GymApi.add_to_sub_history(context,
        data: data, showLoading: showLoading, showToast: showToast);

    if (response != null && response['client'] != null) {
      // ClientModel client = ClientModel.fromMap(response['client']);

      return true;
    } else
      return false;
  }

  // generate_client_id
  static Future<String> generate_client_id(BuildContext context) async {
    var response = await GymApi.generate_client_id(context);

    if (response != null)
      return response['client_id'].toString();
    else
      return '';
  }

  // ! REMOVALS

  // delete_client
  static Future<Map> delete_client(
    BuildContext context, {
    required String client_id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    var response = await GymApi.delete_client(context,
        showLoading: showLoading, showToast: showToast, id: client_id);

    if (response != null && response['id'] != null) {
      return {'status': true, 'id': response['id']};
    } else {
      return {'status': false};
    }
  }

  // delete_hmo
  static Future<Map> delete_hmo(
    BuildContext context, {
    required String hmo_id,
    bool showLoading = true,
    bool showToast = true,
  }) async {
    var response = await GymApi.delete_hmo(context,
        showLoading: showLoading, showToast: showToast, id: hmo_id);

    if (response != null && response['id'] != null) {
      return {'status': true, 'id': response['id']};
    } else {
      return {'status': false};
    }
  }

  //?

  //!

// get all clients from stream
  // static get_gym_clients(context) {
  //   GymDatabaseHelpers.clients_stream().listen((event) {
  //     List<ClientListModel> clients = [];
  //     List<ClientSignInModel> client_list = [];
  //     event.docs.forEach((e) {
  //       ClientListModel cl_1 = ClientListModel.fromMap(e.id, e.data());
  //       clients.add(cl_1);
  //       ClientSignInModel cl_2 = ClientSignInModel.fromMap(e.id, e.data());
  //       client_list.add(cl_2);
  //       // check for expired subscriptions
  //       if (!cl_2.sub_paused) {
  //         // expired sub plan
  //         if ((cl_2.sub_date.isNotEmpty) &&
  //             (cl_2.sub_status) &&
  //             Helpers.getDate(cl_2.sub_date).isBefore(DateTime.now())) {
  //           update_client_details(
  //             e.id,
  //             {'sub_status': false},
  //           );
  //         }
  //         // expired pt status
  //         if ((cl_2.pt_date.isNotEmpty) &&
  //             (cl_2.pt_status) &&
  //             Helpers.getDate(cl_2.pt_date).isBefore(DateTime.now())) {
  //           update_client_details(
  //             e.id,
  //             {'pt_status': false},
  //           );
  //         }
  //         // expired boxing
  //         if ((cl_2.bx_date.isNotEmpty) &&
  //             (cl_2.boxing) &&
  //             Helpers.getDate(cl_2.bx_date).isBefore(DateTime.now())) {
  //           update_client_details(
  //             e.id,
  //             {'boxing': false},
  //           );
  //         }
  //       }
  //       // if client failed to sign out
  //       if (!cl_2.in_out) {
  //         String in_time = e.data()['in_time'] ?? '';
  //         if (in_time != '') {
  //           DateTime in_t = DateTime.parse(in_time);
  //           bool is_tod = (DateTime.now().year == in_t.year) &&
  //               (DateTime.now().month == in_t.month) &&
  //               (DateTime.now().day == in_t.day);
  //           if (!is_tod) {
  //             update_client_details(e.id, {
  //               'in_out': true,
  //               'in_time': '',
  //               'last_activity': {'date_time': 'absent'},
  //             });
  //           }
  //         }
  //       }
  //     });
  //     // update clients for attendance
  //     Provider.of<AppData>(context, listen: false)
  //         .update_client_list(client_list);
  //     // update all clients
  //     Provider.of<AppData>(context, listen: false).update_clients(clients);
  //   });
  // }
//

  // get client personal attendance by month
  static Future get_client_personal_attendance_by_key(String key) async {}

  // get general attendance
  static Future get_daily_attendance_list(String month, String date) async {}

  // reset week for hmo plan clients
  // static reset_week_for_hmo_plan_clients(context) {
  //   dynamic hmo_week_ref =
  //       "'FirebaseFirestore.instance.collection('Office').doc('hmo_week')'";
  //   hmo_week_ref.get().then((snap) {
  //     if (snap.exists) {
  //       // add 6 days to the last date
  //       DateTime last_date =
  //           DateTime.parse(snap.data()!['last_week']).add(Duration(days: 6));
  //       // if the previous week is complete
  //       if (last_date.isBefore(DateTime.now())) {
  //         // get all client on hmo plan
  //         var cls = Provider.of<AppData>(context, listen: false)
  //             .clients
  //             .where((element) => element.sub_plan == 'HMO Plan')
  //             .toList();
  //         // reset the days checked in for each clinet
  //         cls.forEach((element) {
  //           GymDatabaseHelpers.update_client_details(
  //               element.key!, {'days_in': 0});
  //         });
  //         // reset last week
  //         hmo_week_ref.set({'last_week': DateTime.now().toString()});
  //       }
  //     }
  //   });
  // }

  ///
}
