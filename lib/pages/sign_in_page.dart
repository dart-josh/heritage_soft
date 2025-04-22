import 'package:flutter/material.dart';
import 'package:heritage_soft/appData.dart';
import 'package:heritage_soft/datamodels/user_models/doctor.model.dart';
import 'package:heritage_soft/datamodels/user_models/user.model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/auth_helpers.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/user_helpers.dart';
import 'package:heritage_soft/helpers/utils.dart';
import 'package:heritage_soft/maintree.dart';
import 'package:heritage_soft/pages/other/attendance_page.dart';
import 'package:heritage_soft/pages/staff/user_setup_page.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:provider/provider.dart';

class SignInToApp extends StatefulWidget {
  const SignInToApp({super.key});

  @override
  State<SignInToApp> createState() => _SignInToAppState();
}

class _SignInToAppState extends State<SignInToApp> {
  TextEditingController user_controller = TextEditingController();
  TextEditingController pass_controller = TextEditingController();

  bool isLoading = false;
  String loadingText = '';

  void login() async {
    setState(() {
      isLoading = true;
      loadingText = 'Checking user details';
    });

    UserModel? user = await AuthHelpers.login(context,
        user_id: user_controller.text.trim(),
        password: pass_controller.text.trim());

    if (user != null) {
      save_login(user_controller.text.trim(), pass_controller.text.trim());

      if (user.app_role == 'Doctor') {
        setState(() {
          isLoading = true;
          loadingText = 'Fetching doctor profile';
        });

        Map? doc =
            await UserHelpers.get_doctor_by_id(context, user: user.key ?? '');

        if (doc != null) {
          if (doc['status'] == 'Doctor') {
            DoctorModel doctor = doc['doctor'];

            // go to homepage
            goto_homepage(user: user, doctor: doctor);
          } else {
            // go to setup
            setup_doctor(user: user);
          }
        } else {
          setState(() {
            isLoading = false;
            loadingText = '';
          });
        }
      } else {
        // go to homepage
        goto_homepage(user: user);
      }
    } else {
      setState(() {
        isLoading = false;
        loadingText = '';
      });
    }
  }

  void goto_homepage({required UserModel user, DoctorModel? doctor}) {
    if (!user.can_sign_in) {
      setState(() {
        isLoading = false;
        loadingText = '';
      });

      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'Not allowed',
        icon: Icons.error,
      );
      return;
    }

    // asign user
    if (doctor != null) AppData.set(context).update_active_doctor(doctor);
    AppData.set(context).update_active_user(user);

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => MainTree()), (route) => false);
  }

  void setup_doctor({required UserModel user}) async {
    var doctor = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UserSetup(
        setup_profile: true,
        user: user,
      ),
    );

    if (doctor != null) {
      goto_homepage(user: doctor, doctor: doctor);
    }
  }

  // save  login
  save_login(String user_id, String password) async {
    await Utils.save_user_id(user_id);
    await Utils.save_user_pass(password);
    return;
  }

  // get login
  void get_login_details() async {
    String? user_id = await Utils.get_user_id();
    String? password = await Utils.get_user_pass();
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

            if (isLoading)
              loadingPage()
            else
              Column(
                children: [
                  // sign in
                  sign_in_form(),

                  SizedBox(height: 40),

                  // sign in button
                  sign_in_btn(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // loading page
  Widget loadingPage() {
    return Container(
      child: Column(children: [
        CircularProgressIndicator(),
        SizedBox(height: 20),
        Text(
          loadingText,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ]),
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

        login();
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
