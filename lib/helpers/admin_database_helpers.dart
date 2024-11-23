import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/accessories_shop_model.dart';
import 'package:heritage_soft/datamodels/client_model.dart';
import 'package:heritage_soft/datamodels/hmo_model.dart';
import 'package:heritage_soft/datamodels/password_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/gym_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:provider/provider.dart';

class AdminDatabaseHelpers {
  // get all accessory
  static get_accessories(context) {
    FirebaseFirestore.instance
        .collection('Accessories')
        .snapshots()
        .listen((event) {
      List<AccessoryModel> list = [];
      event.docs.forEach((element) {
        list.add(AccessoryModel.fromMap(element.id, element.data()));
      });

      Provider.of<AppData>(context, listen: false).update_accessories(list);
    });
  }

  // accessory request stream
  static get_accessory_request_stream(context) {
    return FirebaseDatabase.instance
        .ref('Accessory Request')
        .onValue
        .listen((event) {
      if (app_role == 'doctor') return;

      List<A_ShopModel> requests = [];
      if (event.snapshot.value != null) {
        Map map = event.snapshot.value as Map;

        map.forEach((key, value) {
          requests.add(A_ShopModel.fromMap(key, value));
        });
      }

      Provider.of<AppData>(context, listen: false)
          .update_accessory_request(requests);
    });
  }

  // add accessory sales record
  static Future<bool> add_accessory_sales_record(
      String key, Map<String, dynamic> data) async {
    try {
      await FirebaseDatabase.instance
          .ref('Accessory Sales Record')
          .child(key)
          .push()
          .set(data);

      return true;
    } catch (e) {
      return false;
    }
  }

  // get accessory sales record
  static Future<DataSnapshot> get_accessory_sales_record(String key) {
    return FirebaseDatabase.instance
        .ref('Accessory Sales Record')
        .child(key)
        .get();
  }

  // remove accessory request
  static Future<bool> remove_accessory_request(String key) async {
    try {
      await FirebaseDatabase.instance
          .ref('Accessory Request')
          .child(key)
          .remove();

      return true;
    } catch (e) {
      return false;
    }
  }

  // add/update accessory
  static Future<bool> add_update_accessory(Map<String, dynamic> data,
      {String key = '', bool sett = false}) async {
    try {
      if (sett)
        await FirebaseFirestore.instance.collection('Accessories').add(data);
      else
        await FirebaseFirestore.instance
            .collection('Accessories')
            .doc(key)
            .update(data);

      return true;
    } catch (e) {
      return false;
    }
  }

  // delete accessory
  static Future<bool> delete_accessory(String key) async {
    try {
      await FirebaseFirestore.instance
          .collection('Accessories')
          .doc(key)
          .delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // get visitors record
  static Future<DataSnapshot> get_visitors_record(String key) {
    return FirebaseDatabase.instance.ref('Visitors').child(key).get();
  }

  // add visitor to record
  static Future<bool> add_visitor_to_record(
      String key, Map<String, dynamic> data) async {
    try {
      await FirebaseDatabase.instance
          .ref('Visitors')
          .child(key)
          .push()
          .set(data);

      return true;
    } catch (e) {
      return false;
    }
  }

  // get office variables
  static Future<DocumentSnapshot<Map<String, dynamic>>>?
      get_office_variables() {
    try {
      return FirebaseFirestore.instance
          .collection('Office')
          .doc('Variables')
          .get();
    } catch (e) {
      return null;
    }
  }

  // clear accessory request
  static Future<bool> clear_accessory_request() async {
    try {
      await FirebaseDatabase.instance.ref('Accessory Request').remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  // remove accessory request from db
  static Future<bool> delete_accessory_request(String key) async {
    try {
      await FirebaseDatabase.instance
          .ref('Accessory Request')
          .child(key)
          .remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  // add hmo
  static Future<bool> add_hmo(
      String collection_key, Map<String, dynamic> map, String key,
      {bool sett = false}) async {
    try {
      if (sett)
        await FirebaseFirestore.instance.collection(collection_key).add(map);
      else
        await FirebaseFirestore.instance
            .collection(collection_key)
            .doc(key)
            .update(map);

      return true;
    } catch (e) {
      return false;
    }
  }

  // delete hmo
  static Future<bool> delete_hmo(String collection_key, String key) async {
    try {
      FirebaseFirestore.instance.collection(collection_key).doc(key).delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  // set admin password
  static Future<bool> set_admin_passwords(
      String key, Map<String, dynamic> data) async {
    try {
      FirebaseFirestore.instance
          .collection('Admin Passwords')
          .doc(key)
          .update(data);

      return true;
    } catch (e) {
      return false;
    }
  }

  // upload image to storage
  static Future<String?> uploadFile(Uint8List file, String id, bool gym,
      {bool staff = false}) async {
    // String fileName = Path.basename(file.path);

    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child(staff
              ? 'Staff'
              : gym
                  ? 'FT_Clients'
                  : 'PT_Clients')
          .child(id);
      UploadTask uploadTask = storageReference.putData(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      if (taskSnapshot.state == TaskState.success) {
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        print(downloadUrl);
        return downloadUrl;
      }
    } catch (e) {
      print(e.toString());
    }

    return null;
  }

  // get news for staff
  static get_news() {
    FirebaseFirestore.instance
        .collection('Office')
        .doc('News')
        .get()
        .then((value) {
      if (value.exists) {
        news = value.data()!['news'];
      } else {
        news = 'No news';
      }
    });
  }

  // get hmos
  static get_hmos(context) {
    // gym
    FirebaseFirestore.instance
        .collection('Gym HMO')
        .snapshots()
        .listen((event) {
      List<HMO_Model> hmos = [];
      event.docs.forEach((element) {
        hmos.add(HMO_Model.fromMap(element.id, element.data()));
      });

      Provider.of<AppData>(context, listen: false).update_gym_hmo(hmos);
      gym_hmo = hmos;
    });

    // physio
    FirebaseFirestore.instance
        .collection('Physio HMO')
        .snapshots()
        .listen((event) {
      List<HMO_Model> hmos = [];
      event.docs.forEach((element) {
        hmos.add(HMO_Model.fromMap(element.id, element.data()));
      });

      Provider.of<AppData>(context, listen: false).update_physio_hmo(hmos);
      physio_hmo = hmos;
    });
  }

  // audio player for attendance notification
  static final AudioPlayer player = AudioPlayer();

  // listen to attendance for sign in user
  static listen_to_sign_in_user(context) {
    if (!send_notification) return;

    FirebaseFirestore.instance
        .collection('Office')
        .doc('Sign_in_user')
        .snapshots()
        .listen((event) {
      if (event.exists) {
        if (event.data()!.isNotEmpty) {
          Provider.of<AppData>(context, listen: false).update_sign_in_cl(null);
          ClientSignInModel cl_2 = ClientSignInModel.fromMap_2(event.data()!);

          // display user
          notification_height.value = 0;
          player.play(AssetSource('alert_1.mp3'));
          Provider.of<AppData>(context, listen: false).update_sign_in_cl(cl_2);
          notification_height.value = 90;

          // clear sign in user
          FirebaseFirestore.instance
              .collection('Office')
              .doc('Sign_in_user')
              .delete();
        }
      }
    });
  }

  // get passwords
  static get_passwords(context) {
    FirebaseFirestore.instance
        .collection('Admin Passwords')
        .snapshots()
        .listen((event) {
      List<PasswordModel> passwords = [];

      event.docs.forEach((element) {
        passwords.add(PasswordModel.fromMap(element.id, element.data()));
      });

      Provider.of<AppData>(context, listen: false).update_passwords(passwords);
    });
  }

  // get office variables
  static get_office_var() {
    FirebaseFirestore.instance.collection('Office').snapshots().listen((event) {
      var doc = event.docs.where((element) => element.id == 'Last ID');

      if (doc.isNotEmpty) {
        var elem = doc.first;

        last_ft_id = elem.data()['last_ft_id'] ?? 0;
        last_pt_id = elem.data()['last_pt_id'] ?? 0;
        last_st_id = elem.data()['last_st_id'] ?? 0;
      }

      is_loaded = true;
    });
  }

  // !

  // loop
  loadJson() async {
    String data = await rootBundle.loadString('assets/data.json');
    var jsonResult = json.decode(data);
    print(jsonResult);
  }

  // ! register cl
  static register_client(context, ClientModel new_c) async {
    // assign new key
    var new_key = await GymDatabaseHelpers.assign_gym_registration_key();

    // check client id to ensure no duplicates
    List check_id = await GymDatabaseHelpers.check_gym_client_id(new_c.id!);

    // check for errors
    if (!check_id[0]) {
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: check_id[1],
        icon: Icons.error,
      );
      return;
    }

    // var newcl = ClientModel(
    //   key: new_key,
    //   id: widget.cl_id,
    //   reg_date: reg_date_controller.text.trim(),
    //   user_status: true,
    //   sub_type: sub_type_select,
    //   sub_plan: package_select,
    //   pt_plan: pt_plan,
    //   sub_status: sub_status,
    //   pt_status: pt,
    //   sub_date: sub_dt,
    //   pt_date: pt_dt,
    //   boxing: boxing,
    //   bx_date: bx_dt,
    //   f_name: first_name_controller.text.trim(),
    //   m_name: middle_name_controller.text.trim(),
    //   l_name: last_name_controller.text.trim(),
    //   user_image: '',
    //   phone_1: phone_1_controller.text.trim(),
    //   phone_2: phone_2_controller.text.trim(),
    //   email: email_controller.text.trim(),
    //   address: address_controller.text.trim(),
    //   ig_user: ig_controller.text.trim(),
    //   fb_user: fb_controller.text.trim(),
    //   gender: gender_select,
    //   dob: dob,
    //   show_age: show_age,
    //   occupation: occupation_select,
    //   program_type_select: program_type_select,
    //   corporate_type_select: corporate_type_select,
    //   company_name: company_name_controller.text.trim(),
    //   hmo: hmo_select,
    //   hmo_id: hmo_id_controller.text.trim(),
    //   hykau: hykau == 'Select' ? '' : hykau,
    //   hykau_others: hykau_controller.text.trim(),
    //   sub_paused: false,
    //   paused_date: '',
    //   sub_income: 0,
    //   baseline_done: false,
    //   physio_cl: false,
    //   physio_key: '',
    //   indemnity_verified: false,
    //   max_days: week_days,
    // );

    var cl_map = new_c.toJson();

    // register cleint
    bool registration =
        await GymDatabaseHelpers.register_gym_client(new_key, cl_map);

    // check for errors
    if (!registration) {
      Navigator.pop(context);
      Helpers.showToast(
        context: context,
        color: Colors.redAccent,
        toastText: 'Error, Try again',
        icon: Icons.error,
      );
      return;
    }

    // update last gym id
    await GymDatabaseHelpers.update_last_gym_id(new_c.id!);

    print(new_c.id!);
    return true;
  }

  //
}
