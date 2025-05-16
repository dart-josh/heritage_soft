import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static String saved_user_id_key = 'USER_ID';
  static String saved_user_pass_key = 'USER_PASS';
  static String saved_user_name_key = 'USER_NAME';

  // save user id
  static Future<bool> save_user_id(String user_id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(saved_user_id_key, user_id);
  }

  // save user password
  static Future<bool> save_user_pass(String password) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(saved_user_pass_key, password);
  }

  // save user name
  static Future<bool> save_user_name(String user_name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(saved_user_name_key, user_name);
  }

  // get user id
  static Future<String?> get_user_id() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(saved_user_id_key);
  }

  // get user password
  static Future<String?> get_user_pass() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(saved_user_pass_key);
  }

  // get user name
  static Future<String?> get_user_name() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getString(saved_user_name_key);
  }

  // remove user
  static Future<bool?> remove_user() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(saved_user_pass_key);
    await preferences.remove(saved_user_name_key);
    return await preferences.remove(saved_user_id_key);
  }
}
