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
import 'package:heritage_soft/pages/pin_page.dart';
import 'package:heritage_soft/widgets/text_field.dart';

class SignInToApp extends StatefulWidget {
  final bool logout;
  const SignInToApp({super.key, this.logout = false});

  @override
  State<SignInToApp> createState() => _SignInToAppState();
}

class _SignInToAppState extends State<SignInToApp> {
  TextEditingController user_controller = TextEditingController();
  TextEditingController pass_controller = TextEditingController();

  bool isLoading = false;
  String loadingText = '';

  String? user_id;
  String? user_name;

  void login({required String user_id, required String password}) async {
    setState(() {
      isLoading = true;
      loadingText = 'Checking user details';
    });

    UserModel? user = await AuthHelpers.login(
      context,
      user_id: user_id,
      password: password,
    );

    if (user != null) {
      if (!user.can_sign_in) {
        setState(() {
          isLoading = false;
          loadingText = '';
        });

        Helpers.showToast(
            context: context,
            color: Colors.red,
            toastText: 'You are not allowed to Sign in',
            icon: Icons.error);
        return;
      }

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

            save_login(user_id, password, '${user.f_name} ${user.l_name}');

            // go to homepage
            goto_homepage(user: user, doctor: doctor);
          } else {
            setState(() {
              isLoading = false;
              loadingText = '';
            });
            //
            return Helpers.showToast(
                context: context,
                color: Colors.red,
                toastText: 'No Doctor Profile',
                icon: Icons.error);
          }
        } else {
          setState(() {
            isLoading = false;
            loadingText = '';
          });
        }
      } else {
        save_login(user_id, password, '${user.f_name} ${user.l_name}');
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

  Future<void> goto_homepage(
      {required UserModel user, DoctorModel? doctor}) async {
    setState(() {
      isLoading = false;
      loadingText = '';
    });

    if (!user.can_sign_in) {
      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'Not allowed',
        icon: Icons.error,
      );
      return;
    }

    user_id = user.user_id;
    user_name = '${user.f_name} ${user.l_name}';

    // enter PIN
    var pin = await showDialog(
      context: context,
      builder: (context) => PinPage(
        user_id: user_id ?? '',
        user_name: user_name ?? '',
        page_index: user.pin ? 0 : 1,
      ),
      barrierDismissible: false,
    );

    if (pin == null) return;

    bool user_pin = await AuthHelpers.check_pin(
      context,
      user_id: user_id ?? '',
      pin: pin,
    );

    if (!user_pin) return;

    AppData.set(context).update_active_user(user);

    // asign user
    if (doctor != null) {
      // update doctor availablity
      doctor.is_available = true;

      await UserHelpers.add_update_doctor(
        context,
        data: doctor.toJson(),
        showLoading: true,
        showToast: true,
      );
      AppData.set(context).update_active_doctor(doctor);
    }

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => MainTree()), (route) => false);
  }

  // save  login
  save_login(String user_id, String password, String user_name) async {
    await Utils.save_user_id(user_id);
    await Utils.save_user_pass(password);
    await Utils.save_user_name(user_name);
    return;
  }

  // get login
  void get_login_details() async {
    user_id = await Utils.get_user_id();
    String? password = await Utils.get_user_pass();
    user_name = await Utils.get_user_name();

    if (user_id != null && password != null) {
      user_controller.text = user_id ?? '';
      // pass_controller.text = password;

      login(user_id: user_id ?? '', password: password);
    }
  }

  @override
  initState() {
    super.initState();
    if (!widget.logout) get_login_details();
  }

  @override
  void dispose() {
    user_controller.dispose();
    pass_controller.dispose();

    super.dispose();
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

        int? id = int.tryParse(user_controller.text);

        if (id != null) {
          user_controller.text = 'DHI-${fine_id(id.toString())}-ST';
        } else {
          user_controller.text = user_controller.text.toUpperCase();

          if (!user_controller.text.toLowerCase().contains('dhi-'))
            user_controller.text = 'DHI-${user_controller.text}';

          if (!user_controller.text.toLowerCase().contains('-st'))
            user_controller.text = '${user_controller.text}-ST';
        }

        login(
            user_id: user_controller.text.trim(),
            password: pass_controller.text);
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

  //? FUNCTIONS

  // get fine_id
  String fine_id(String id) {
    if (id.length >= 4)
      return id;
    else if (id.length == 3)
      return '0$id';
    else if (id.length == 2)
      return '00$id';
    else if (id.length == 1)
      return '000$id';
    else
      return id;
  }

  //
}
