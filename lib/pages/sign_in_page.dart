import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/users_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/staff_database_helpers.dart';
import 'package:heritage_soft/helpers/utils.dart';
import 'package:heritage_soft/maintree.dart';
import 'package:heritage_soft/pages/other/attendance_page.dart';
import 'package:heritage_soft/pages/other/mobile_tab.dart';
import 'package:heritage_soft/pages/staff/user_setup_page.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:provider/provider.dart';
import "package:universal_html/html.dart" as html;

import 'package:flutter/foundation.dart';

class SignInToApp extends StatefulWidget {
  const SignInToApp({super.key});

  @override
  State<SignInToApp> createState() => _SignInToAppState();
}

class _SignInToAppState extends State<SignInToApp> {
  TextEditingController user_controller = TextEditingController();
  TextEditingController pass_controller = TextEditingController();

  // sign in
  void signIn() async {
    double width = MediaQuery.of(context).size.width;

    String user_id = user_controller.text;
    String password = pass_controller.text;

    Helpers.showLoadingScreen(context: context);

    await StaffDatabaseHelpers.sign_in_to_app(user_id).then((snap) async {
      if (snap.docs.isNotEmpty) {
        var ref = snap.docs.first;

        // if no password set
        if (ref.data()['password'] == null || ref.data()['password'] == '') {
          // remove loading screen
          Navigator.pop(context);

          await StaffDatabaseHelpers.set_password(
            context: context,
            user_key: ref.id,
            password: password,
          );

          return;
        }

        // wrong password
        if (ref.data()['password'] != pass_controller.text) {
          Navigator.pop(context);
          Helpers.showToast(
            context: context,
            color: Colors.red,
            toastText: 'Incorrect password',
            icon: Icons.error,
          );
          return;
        }

        StaffModel staff = StaffModel.fromMap(ref.id, ref.data());
        active_staff = staff;

        // profile setup
        if (staff.f_name.isEmpty) {
          if (staff.app_role == 'Doctor') {
            app_role = 'doctor';

            active_doctor = DoctorModel.fromMap(ref.id, ref.data());
          }

          Navigator.pop(context);

          if (width >= 800) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => UserSetup(
                setup_profile: true,
                staff: staff,
              ),
            );
          } else {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserSetup(
                  setup_profile: true,
                  staff: staff,
                ),
              ),
            );
          }

          // reload windows
          html.window.location.reload();
          return;
        }

        // mobile
        if (!kIsWeb) if (Platform.isAndroid) {
          // admin
          if (staff.app_role == 'Admin') {
            app_role = 'admin';
          }

          // reception
          else if (staff.app_role == 'CSU') {
            app_role = 'desk';
          }

          // managemnet
          else if (staff.app_role == 'Management') {
            app_role = 'management';
          }

          // ict
          else if (staff.app_role == 'ICT') {
            app_role = 'ict';
            full_access = true;
          }

          // doctor or others
          else {
            Navigator.pop(context);
            return;
          }

          // save login
          await save_login(ref.id, ref.data()['password']);

          Navigator.pop(context);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MobileTab()),
            (route) => false,
          );
          return;
        }

        // small screen
        if (width < 800) {
          // save login
          await save_login(ref.id, ref.data()['password']);

          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserSetup(
                staff: staff,
              ),
            ),
          );
          return;
        }

        // doctor
        if (staff.app_role == 'Doctor') {
          app_role = 'doctor';

          await StaffDatabaseHelpers.get_doctor_details(ref.id).then((snap) {
            if (snap.exists) {
              active_doctor = DoctorModel.fromMap(snap.id, snap.data()!);
              active_doctor!.is_available = true;

              Provider.of<AppData>(context, listen: false)
                  .update_active_doctor(active_doctor!);
            }
          });

          await StaffDatabaseHelpers.set_doctor_status(ref.id, true);
        }

        // admin
        else if (staff.app_role == 'Admin') {
          app_role = 'admin';
        }

        // desk
        else if (staff.app_role == 'CSU') {
          app_role = 'desk';
        }

        // managemnt
        else if (staff.app_role == 'Management') {
          app_role = 'management';
        }

        // ict
        else if (staff.app_role == 'ICT') {
          app_role = 'ict';
          full_access = true;
        }

        // none
        else if (staff.app_role == 'None') {
          Navigator.pop(context);
          Helpers.showToast(
            context: context,
            color: Colors.red,
            toastText: 'Not allowed',
            icon: Icons.error,
          );
          return;
        }

        // invalid
        else {
          Navigator.pop(context);
          Helpers.showToast(
            context: context,
            color: Colors.red,
            toastText: 'Not allowed',
            icon: Icons.error,
          );
          return;
        }

        await save_login(ref.id, ref.data()['password']);

        Navigator.pop(context);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainTree()),
            (route) => false);
      }

      // user id not found
      else {
        Navigator.pop(context);
        Helpers.showToast(
          context: context,
          color: Colors.red,
          toastText: 'User ID not found',
          icon: Icons.error,
        );
        return;
      }
    });
  }

  // save the login
  save_login(String user_id, String password) async {
    await Utils.save_user_id(user_id);
    await Utils.save_user_pass(password);
    return;
  }

  @override
  Widget build(BuildContext context) {
    custom_context = context;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 3, 25, 43),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'images/logo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 50),

            // sign in
            sign_in_form(),

            SizedBox(height: 40),

            // sign in button
            sign_in_btn(),
          ],
        ),
      ),
    );
  }

  Widget sign_in_form() {
    double width = MediaQuery.of(context).size.width * 0.5;
    return Container(
      width: width,
      child:
          // big screen
          width > 500
              ? Row(
                  children: [
                    // user id
                    Expanded(
                      child: Text_field(
                        controller: user_controller,
                        label: 'User ID',
                      ),
                    ),

                    SizedBox(width: 40),

                    // password
                    Expanded(
                      child: Text_field(
                        controller: pass_controller,
                        label: 'Password',
                        obscure: true,
                      ),
                    )
                  ],
                )

              // small screen
              : Column(
                  children: [
                    // user id
                    Text_field(
                      controller: user_controller,
                      label: 'User ID',
                    ),

                    SizedBox(height: 20),

                    // password
                    Text_field(
                      controller: pass_controller,
                      label: 'Password',
                      obscure: true,
                    )
                  ],
                ),
    );
  }

  // sing in button
  Widget sign_in_btn() {
    return InkWell(
      onTap: () {
        if (user_controller.text.trim() == 'attendance') {
          send_notification = false;
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AttendancePage()),
              (route) => false);
          return;
        }

        if (user_controller.text.isEmpty || pass_controller.text.isEmpty) {
          Helpers.showToast(
            context: context,
            color: Colors.red,
            toastText: 'Enter a valid login detail',
            icon: Icons.error,
          );
          return;
        }

        signIn();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(6),
        ),
        width: 200,
        height: 38,
        child: Center(
          child: Text(
            'SIGN IN',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  //
}

class VerifyLogin extends StatefulWidget {
  const VerifyLogin({super.key});

  @override
  State<VerifyLogin> createState() => _VerifyLoginState();
}

class _VerifyLoginState extends State<VerifyLogin> {
  String? user_key;
  String? user_pass;

  bool error = false;

  bool curr_v = true;

  // check version
  check_version() async {
    var res = await AdminDatabaseHelpers.get_office_variables();

    if (res == null) {
      error = true;
      setState(() {});
      return;
    }

    String version = res.data()!['current_version'];

    curr_v = (version == current_version);

    if (curr_v) {
      get_login_details();
    }

    setState(() {});
  }

  // get login details
  void get_login_details() async {
    double width = MediaQuery.of(context).size.width;
    user_key = await Utils.get_user_id();
    user_pass = await Utils.get_user_pass();

    if (user_key != null && user_pass != null) {
      DocumentSnapshot res;
      try {
        res = await StaffDatabaseHelpers.get_staff_details(user_key!);
      } catch (e) {
        print(e);
        error = true;
        setState(() {});
        return;
      }

      if (res.exists) {
        Map map = res.data() as Map;

        StaffModel staff = StaffModel.fromMap(res.id, map);
        active_staff = staff;

        if (map['password'] != null && map['password'] == user_pass) {
          // mobile
          if (!kIsWeb) if (Platform.isAndroid) {
            // admin
            if (staff.app_role == 'Admin') {
              app_role = 'admin';
            }

            // reception
            else if (staff.app_role == 'CSU') {
              app_role = 'desk';
            }

            // managemnet
            else if (staff.app_role == 'Management') {
              app_role = 'management';
            }

            // ict
            else if (staff.app_role == 'ICT') {
              app_role = 'ict';
              full_access = true;
            }

            // doctor or others
            else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInToApp()),
                (route) => false,
              );
              return;
            }

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MobileTab()),
              (route) => false,
            );
            return;
          }

          // login
          // small screen
          if (width < 800) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserSetup(
                  staff: staff,
                ),
              ),
            );
            html.window.location.reload();
            return;
          }

          // doctor
          if (staff.app_role == 'Doctor') {
            app_role = 'doctor';

            await StaffDatabaseHelpers.get_doctor_details(res.id).then((snap) {
              if (snap.exists) {
                active_doctor = DoctorModel.fromMap(snap.id, snap.data()!);
                active_doctor!.is_available = true;

                Provider.of<AppData>(context, listen: false)
                    .update_active_doctor(active_doctor!);
              }
            });

            await StaffDatabaseHelpers.set_doctor_status(res.id, true);
          }

          // admin
          else if (staff.app_role == 'Admin') {
            app_role = 'admin';
          }

          // desk
          else if (staff.app_role == 'CSU') {
            app_role = 'desk';
          }

          // managemnt
          else if (staff.app_role == 'Management') {
            app_role = 'management';
          }

          // ict
          else if (staff.app_role == 'ICT') {
            app_role = 'ict';
            full_access = true;
          }

          // none
          else if (staff.app_role == 'None') {
            Helpers.showToast(
              context: context,
              color: Colors.red,
              toastText: 'Not allowed',
              icon: Icons.error,
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignInToApp()),
              (route) => false,
            );
            return;
          }

          // invalid
          else {
            Helpers.showToast(
              context: context,
              color: Colors.red,
              toastText: 'Not allowed',
              icon: Icons.error,
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => SignInToApp()),
              (route) => false,
            );
            return;
          }

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainTree()),
              (route) => false);
        }

        // wrong password
        else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SignInToApp()),
            (route) => false,
          );
        }
      }

      // user not found
      else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInToApp()),
          (route) => false,
        );
      }
    }

    // no user id / password
    else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInToApp()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    check_version();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color.fromARGB(255, 3, 25, 43),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children:
                  // outdated
                  !curr_v
                      ? [
                          // logo
                          Image.asset(
                            'images/logo.jpg',
                            width: 100,
                            height: 100,
                          ),

                          SizedBox(height: 100),

                          Text(
                            'Software is outdated\nGet the new Version',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ]

                      // current
                      : [
                          // logo
                          Image.asset(
                            'images/logo.jpg',
                            width: 100,
                            height: 100,
                          ),

                          SizedBox(height: 100),

                          !error ? CircularProgressIndicator() : Container(),

                          error ? SizedBox(height: 50) : SizedBox(),

                          // retry button
                          error
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      error = false;
                                    });
                                    check_version();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(.4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    width: 150,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Center(
                                      child: Text(
                                        'Retry',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ],
            ),
          ),
        ],
      ),
    );
  }
}

class PasswordSetup extends StatefulWidget {
  final String password;
  const PasswordSetup({super.key, required this.password});

  @override
  State<PasswordSetup> createState() => _PasswordSetupState();
}

class _PasswordSetupState extends State<PasswordSetup> {
  final TextEditingController pass_controler = TextEditingController();
  final TextEditingController pass_2_controler = TextEditingController();

  bool obscure = true;

  @override
  void initState() {
    pass_controler.text = widget.password;
    super.initState();
  }

  @override
  void dispose() {
    pass_2_controler.dispose();
    pass_controler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // main
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF000000),
                    offset: Offset(0.7, 0.7),
                    blurRadius: 6,
                  ),
                ],
                color: Color.fromARGB(255, 37, 22, 10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 2),

                  // heading
                  Stack(
                    children: [
                      // heading
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Setup Password',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      // close button
                      Positioned(
                        top: 5,
                        right: 5,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // horizontal line
                  Container(
                    height: 1,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),

                  SizedBox(height: 4),

                  // subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: Text(
                      'Enter a password you would like to use for your account',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                  SizedBox(height: 15),

                  // password 1
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // label
                        Text(
                          'Enter new Password',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),

                        SizedBox(height: 5),

                        // textfield
                        TextField(
                          controller: pass_controler,
                          obscureText: obscure,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // password 2
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // label
                        Text(
                          'Confirm Password',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),

                        SizedBox(height: 5),

                        // textfield
                        TextField(
                          controller: pass_2_controler,
                          obscureText: obscure,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // show/hide password
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                        child: Text(
                          obscure ? 'Show Password' : 'Hide Password',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // submit button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: InkWell(
                      onTap: () async {
                        if (pass_controler.text.isEmpty ||
                            pass_2_controler.text.isEmpty) {
                          Helpers.showToast(
                            context: context,
                            color: Colors.red,
                            toastText: 'Enter a password',
                            icon: Icons.error,
                          );
                          return;
                        }

                        if (pass_controler.text != pass_2_controler.text) {
                          Helpers.showToast(
                            context: context,
                            color: Colors.red,
                            toastText: 'Passwords do not match',
                            icon: Icons.error,
                          );
                          return;
                        }

                        var conf = await showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: 'Confirm password',
                            subtitle: 'Would you like to save this password?',
                          ),
                        );

                        if (conf) {
                          Navigator.pop(context, pass_controler.text.trim());
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        height: 42,
                        // width: ,
                        child: Center(
                          child: Text(
                            'Set Password',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
