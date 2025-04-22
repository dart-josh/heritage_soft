import 'package:flutter/material.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:http/http.dart' as http;
import 'package:heritage_soft/appData.dart';
import 'dart:convert';

class DBHelpers {
  // Post Data to server
  static Future<dynamic> postDataToServer(
    context, {
    required String route,
    required Map data,
    bool showLoading = false,
    bool showToast = false,
    String? loadingText,
    bool requireUser = true,
  }) async {
    if (requireUser) {
      UserModel? active_user = AppData.get(context, listen: false).active_user;

      if (active_user == null && showToast) {
        Helpers.showToast(
          context: context,
          color: Colors.red,
          toastText: 'No User Found',
          icon: Icons.error,
        );
        return null;
      }

      // add current user to data
      data["user"] = active_user?.key ;
    }

    // Json encode data
    var body = jsonEncode(data);

    if (showLoading) Helpers.showLoadingScreen(context: context, loadingText: loadingText);
    try {
      var response = await http.post(Uri.parse('${route}'),
          headers: {"Content-Type": "application/json"}, body: body);

      var jsonResponse = jsonDecode(response.body);

      // throw error message
      if (response.statusCode != 200) {
        throw jsonResponse['message'];
      }

      if (showLoading) Navigator.pop(context);
      if (showToast)
        Helpers.showToast(
          context: context,
          color: Colors.green.shade500,
          toastText: jsonResponse['message'],
          icon: Icons.check,
        );

      return jsonResponse;
    } catch (e) {
      if (showLoading) Navigator.pop(context);
      if (showToast)
        Helpers.showToast(
          context: context,
          color: Colors.red,
          toastText: (e.toString().toLowerCase().contains('formatexception') ||
                  e.toString().toLowerCase().contains('clientexception') ||
                  e.toString().toLowerCase().contains('socketexception') ||
                  e.toString().toLowerCase().contains('connection'))
              ? 'Connection Error. Try again later'
              : e.toString(),
          icon: Icons.error,
        );

      return null;
    }
  }

  // Get Data from server
  static Future<dynamic> getDataFromServer(
    context, {
    required String route,
    bool showLoading = false,
    bool showToast = false,
  }) async {
    if (showLoading) Helpers.showLoadingScreen(context: context);
    try {
      var response = await http.get(Uri.parse('${route}'),
          headers: {"Content-Type": "application/json"});

      var jsonResponse = jsonDecode(response.body);

      // throw error message
      if (response.statusCode != 200) {
        return jsonResponse;
      }

      if (showLoading) Navigator.pop(context);
      if (showToast)
        Helpers.showToast(
          context: context,
          color: Colors.green.shade500,
          toastText: jsonResponse['message'],
          icon: Icons.check,
        );

      return jsonResponse;
    } catch (e) {
      if (showLoading) Navigator.pop(context);
      if (showToast)
        Helpers.showToast(
          context: context,
          color: Colors.red,
          toastText: (e.toString().toLowerCase().contains('formatexception') ||
                  e.toString().toLowerCase().contains('clientexception') ||
                  e.toString().toLowerCase().contains('socketexception') ||
                  e.toString().toLowerCase().contains('connection'))
              ? 'Connection Error. Try again later'
              : e.toString(),
          icon: Icons.error,
        );

      return null;
    }
  }

  // Delete Data from sever
  static Future<dynamic> deleteFromServer(context,
      {required String route, required Map data, required String id,
    bool showLoading = false,
    bool showToast = false,}) async {
    UserModel? active_user = AppData.get(context, listen: false).active_user;

    if (active_user == null) {
      if (showToast) Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'No User Found',
        icon: Icons.error,
      );
      return null;
    }

    // add current user to data
    data.addAll({"user": active_user.key});
    // Json encode data
    var body = jsonEncode(data);

    if (showLoading) Helpers.showLoadingScreen(context: context);
    try {
      var response = await http.delete(Uri.parse('${route}/$id'),
          headers: {"Content-Type": "application/json"}, body: body);

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw jsonResponse['message'];
      }

      if (showLoading) Navigator.pop(context);
      if (showToast) Helpers.showToast(
        context: context,
        color: Colors.green.shade500,
        toastText: jsonResponse['message'],
        icon: Icons.check,
      );

      return jsonResponse;
    } catch (e) {
      if (showLoading) Navigator.pop(context);
      if (showToast) Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: (e.toString().toLowerCase().contains('formatexception') ||
                e.toString().toLowerCase().contains('clientexception') ||
                e.toString().toLowerCase().contains('socketexception') ||
                e.toString().toLowerCase().contains('connection'))
            ? 'Connection Error. Try again later'
            : e.toString(),
        icon: Icons.error,
      );

      return null;
    }
  }
}
