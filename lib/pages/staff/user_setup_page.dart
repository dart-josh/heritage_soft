import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_soft/datamodels/users_model.dart';
import 'package:heritage_soft/global_variables.dart';
import 'package:heritage_soft/helpers/helper_methods.dart';
import 'package:heritage_soft/helpers/staff_database_helpers.dart';
import 'package:heritage_soft/widgets/confirm_dailog.dart';
import 'package:heritage_soft/widgets/image_box.dart';
import 'package:heritage_soft/widgets/select_form.dart';
import 'package:heritage_soft/widgets/text_field.dart';
import 'package:heritage_soft/helpers/admin_database_helpers.dart';

class UserSetup extends StatefulWidget {
  final bool setup_profile;
  final bool new_setup;
  final StaffModel? staff;

  const UserSetup({
    super.key,
    this.setup_profile = false,
    this.new_setup = false,
    this.staff,
  });

  @override
  State<UserSetup> createState() => _UserSetupState();
}

class _UserSetupState extends State<UserSetup> {
  final TextEditingController id_controller = TextEditingController();

  // bool user_active = true;
  String staff_role = '';
  String staff_section = '';
  String app_role = '';

  String first_name = '';
  String middle_name = '';
  String last_name = '';
  String user_image = '';

  List<String> office_section = [
    'General Staff',
    'Heritage Physiotherapy clinic',
    'Heritage fitness',
    'Delightsome Juice & Smoothies'
  ];

  List<String> roles = [
    'Management',
    'Admin/Accounting',
    'Customer Service Unit',
    'ICT',
    'Physiotherapist',
    'Production',
    'Sales',
  ];

  TextStyle labelStyle = TextStyle(
    color: Color(0xFFc3c3c3),
    fontSize: 11,
  );
  TextStyle nameStyle = TextStyle(
    color: Colors.white,
    height: 1,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    fontSize: 20,
    shadows: [
      Shadow(
        color: Color(0xFF000000),
        offset: Offset(0.7, 0.7),
        blurRadius: 6,
      ),
    ],
  );

  bool edit = false;

  Uint8List? image_file;

  get_values() async {
    // new staff
    if (widget.new_setup) {
      id_controller.text = Helpers.generate_id('stf', false);
    }

    // setup staff
    if (widget.setup_profile) {
      edit = true;

      Future.delayed(Duration(seconds: 1), () async {
        var res = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => EditNameDailog(
            fn: '',
            mn: '',
            ln: '',
          ),
        );

        if (res != null) {
          first_name = res['first_name'];
          middle_name = res['middle_name'];
          last_name = res['last_name'];

          if (mounted) setState(() {});
        }
      });
    }

    // staff details
    if (widget.staff != null) {
      staff_role = widget.staff!.role;
      staff_section = widget.staff!.section;
      first_name = widget.staff!.f_name;
      middle_name = widget.staff!.m_name;
      last_name = widget.staff!.l_name;
      user_image = widget.staff!.user_image;
      app_role = widget.staff!.app_role;
    }
  }

  @override
  void initState() {
    get_values();
    super.initState();
  }

  @override
  void dispose() {
    id_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width >= 800)
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            main_body(width),
          ],
        ),
      );
    else
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 10, 63, 124),
        body: main_body(width),
      );
  }

  // WIDGETs

  // main body
  Widget main_body(double width) {
    return Container(
      width: width >= 800 ? width * 0.60 : width,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 10, 63, 124).withOpacity(.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // top bar
          top_bar(),

          SizedBox(height: 8),

          // details
          widget.new_setup || widget.staff == null ? Container() : id_con(),

          SizedBox(height: 10),

          // form
          widget.new_setup ? new_staff_setup() : form(),

          width >= 800 ? SizedBox(height: 20) : Expanded(child: Container()),

          edit || widget.new_setup ? submit_button() : Container(height: 40),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  // top bar
  Widget top_bar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white60,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Stack(
        children: [
          // heading
          Center(
            child: Text(
              widget.new_setup
                  ? 'New Staff Account'
                  : widget.setup_profile
                      ? 'Setup Profile'
                      : edit
                          ? 'Edit Profile'
                          : 'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),

          // action buttons
          Row(
            children: [
              // close button
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              Expanded(child: Container()),

              // settings button
              widget.new_setup || widget.setup_profile || !active_staff!.full_access
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: edit
                          ? InkWell(
                              onTap: () {
                                edit = false;
                                setState(() {});
                              },
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 28,
                              ),
                            )
                          : settings_menu(
                              child: Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                    ),

              // delete button
              widget.new_setup || widget.setup_profile || !active_staff!.full_access
                  ? Container()
                  : IconButton(
                      onPressed: () async {
                        var conf = await showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: 'Delete User',
                            subtitle:
                                'You are about to delete this user from the database. Would you like to proceed?',
                          ),
                        );

                        if (conf != null && conf) {
                          Helpers.showLoadingScreen(context: context);

                          bool ds = await StaffDatabaseHelpers.delete_staff(
                              widget.staff!.key);

                          Navigator.pop(context);

                          if (!ds) {
                            Helpers.showToast(
                              context: context,
                              color: Colors.red,
                              toastText: 'An Error Occurred, Try again',
                              icon: Icons.error,
                            );
                            return;
                          }

                          // remove page
                          Navigator.pop(context);

                          Helpers.showToast(
                            context: context,
                            color: Colors.blue,
                            toastText: 'User Deleted',
                            icon: Icons.check,
                          );
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
    );
  }

  // id
  Widget id_con() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // id label
          Text(
            'ID',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              height: 1,
            ),
          ),

          SizedBox(height: 2),

          // id
          Text(
            widget.staff!.user_id,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // form
  Widget form() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
      child: Column(
        children: [
          // main details
          Stack(
            children: [
              // image & name
              Container(
                padding: EdgeInsets.only(top: 15, right: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // profile image
                    Stack(
                      children: [
                        // selected image
                        edit && image_file != null
                            ? Container(
                                margin: EdgeInsets.only(bottom: 6, right: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.memory(
                                    image_file!,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )

                            // no image
                            : user_image.isEmpty
                                ? Container(
                                    margin:
                                        EdgeInsets.only(bottom: 6, right: 6),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFf3f0da).withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.all(30),
                                    child: Center(
                                      child: Image.asset(
                                        'images/icon/material-person.png',
                                        width: 90,
                                        height: 90,
                                      ),
                                    ),
                                  )

                                // image from db
                                : Container(
                                    margin:
                                        EdgeInsets.only(bottom: 6, right: 6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        user_image,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                        // edit image
                        if (edit)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                var res = await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => EditProfileImage(
                                    is_edit: true,
                                    user_image: user_image.isNotEmpty
                                        ? user_image
                                        : null,
                                  ),
                                );

                                if (res != null) {
                                  if (res == 'del') {
                                    user_image = '';
                                    image_file = null;
                                  } else {
                                    image_file = res;
                                  }

                                  setState(() {});
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.edit,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(width: 30),

                    // profile area
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // first name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // label
                              Text(
                                'First name',
                                style: labelStyle,
                              ),

                              // name
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 8, top: 2, bottom: 5),
                                child: Text(
                                  first_name,
                                  style: nameStyle,
                                ),
                              )
                            ],
                          ),

                          // middle name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // label
                              Text(
                                'Middle name',
                                style: labelStyle,
                              ),

                              // name
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 8, top: 2, bottom: 5),
                                child: Text(
                                  middle_name,
                                  style: nameStyle,
                                ),
                              )
                            ],
                          ),

                          // last name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // label
                              Text(
                                'Last name',
                                style: labelStyle,
                              ),

                              // name
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 8, top: 2, bottom: 5),
                                child: Text(
                                  last_name,
                                  style: nameStyle,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // edit name
              Positioned(
                top: 0,
                right: 0,
                child: !edit
                    ? Container(
                        width: 35,
                        height: 35,
                      )

                    // edit name
                    : InkWell(
                        onTap: () async {
                          var res = await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => EditNameDailog(
                              fn: first_name,
                              mn: middle_name,
                              ln: last_name,
                            ),
                          );

                          if (res != null) {
                            first_name = res['first_name'];
                            middle_name = res['middle_name'];
                            last_name = res['last_name'];

                            setState(() {});
                          }
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: Center(
                            child:
                                Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // role & section
          Row(
            children: [
              // role
              Expanded(
                child: Select_form(
                  label: 'Job Title',
                  options: roles,
                  text_value: staff_role,
                  setval: (val) {
                    staff_role = val;
                    setState(() {});
                  },
                  edit: active_staff!.full_access && edit,
                ),
              ),

              Container(width: 30),

              // section
              Expanded(
                child: Select_form(
                  label: 'Office section',
                  options: office_section,
                  text_value: staff_section,
                  setval: (val) {
                    staff_section = val;
                    setState(() {});
                  },
                  edit: active_staff!.full_access && edit,
                ),
              ),
            ],
          ),

          SizedBox(height: 15),

          // role
          Container(
            width: 200,
            child: Select_form(
              label: 'App role',
              options: app_roles,
              text_value: app_role,
              setval: (val) {
                app_role = val;
                setState(() {});
              },
              edit: active_staff!.full_access && edit,
            ),
          ),
        ],
      ),
    );
  }

  Widget submit_button() {
    return InkWell(
      onTap: () async {
        if (widget.new_setup)
          create_new_account();
        else
          update_profile();
      },
      child: Container(
        width: 300,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.new_setup ? 'Create Account' : 'Update Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  // settings pop up menu
  Widget settings_menu({required child}) {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(0),
      offset: Offset(0, 30),
      child: child,
      enabled: !edit,
      elevation: 8,
      onSelected: (value) async {
        // edit name
        if (value == 1) {
          setState(() {
            edit = true;
          });
        }
      },
      itemBuilder: (context) => [
        // edit profile
        PopupMenuItem(
          value: 1,
          child: Container(
            child: Row(
              children: [
                Icon(Icons.edit, size: 22),
                SizedBox(width: 4),
                Text(
                  'Edit profile',
                  style: TextStyle(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // new staff setup
  Widget new_staff_setup() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              // profile image
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFf3f0da).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Image.asset(
                    'images/icon/material-person.png',
                    width: 90,
                    height: 90,
                  ),
                ),
              ),

              SizedBox(width: 50),

              // details
              Expanded(
                child: Column(
                  children: [
                    // id
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text_field(
                        controller: id_controller,
                        label: 'User ID',
                        edit: !active_staff!.full_access,
                      ),
                    ),

                    // role
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Select_form(
                        label: 'Office section',
                        options: office_section,
                        text_value: staff_section,
                        setval: (val) {
                          staff_section = val;
                          setState(() {});
                        },
                      ),
                    ),

                    // section
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Select_form(
                        label: 'Job Title',
                        options: roles,
                        text_value: staff_role,
                        setval: (val) {
                          staff_role = val;
                          setState(() {});
                        },
                      ),
                    ),

                    // app role
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      width: 200,
                      child: Select_form(
                        label: 'App role',
                        options: app_roles,
                        text_value: app_role,
                        setval: (val) {
                          app_role = val;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // FUNCTIONS
  // new staff
  void create_new_account() async {
    if (id_controller.text.trim().isEmpty) {
      Helpers.showToast(
        context: context,
        color: Colors.red,
        toastText: 'Enter user id',
        icon: Icons.error,
      );
      return;
    }

    var conf = await showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Create new account',
        subtitle: 'Make sure you entered the correct info before proceeding.',
      ),
    );

    if (conf != null && conf) {
      Helpers.showLoadingScreen(context: context);

      Map<String, dynamic> data = StaffModel(
        key: '',
        user_id: id_controller.text.trim(),
        f_name: first_name,
        m_name: middle_name,
        l_name: last_name,
        user_image: user_image,
        user_status: true,
        role: staff_role,
        section: staff_section,
        app_role: app_role,
      ).toJson();

      bool ns = await StaffDatabaseHelpers.update_staff_details('', data,
          new_staff: true);

      Navigator.pop(context);

      if (!ns) {
        Helpers.showToast(
          context: context,
          color: Colors.red,
          toastText: 'An Error Occurred, Try again',
          icon: Icons.error,
        );
        return;
      }

      // remove page
      Navigator.pop(context);
    }
  }

  // update staff
  void update_profile() async {
    var conf = await showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'Update Profile',
        subtitle:
            'Make sure you entered the correct details before proceeding.',
      ),
    );

    if (conf != null && conf) {
      Helpers.showLoadingScreen(context: context);

      // upload image
      if (image_file != null) {
        user_image = await AdminDatabaseHelpers.uploadFile(
                image_file!, widget.staff!.user_id, false,
                staff: true) ??
            '';
      }

      Map<String, dynamic> data = StaffModel(
        key: '',
        user_id: widget.staff!.user_id,
        f_name: first_name,
        m_name: middle_name,
        l_name: last_name,
        user_image: user_image,
        user_status: widget.staff!.user_status,
        role: staff_role,
        section: staff_section,
        app_role: app_role,
      ).toJson();

      if (staff_role == 'Physiotherapist') {
        Map<String, dynamic> data2 = DoctorModel(
          key: active_doctor?.key ?? widget.staff!.key,
          user_id: widget.staff!.user_id,
          fullname: '${first_name} ${middle_name} ${last_name}',
          is_available: true,
          active_patients: active_doctor?.active_patients ?? 0,
          total_sessions: active_doctor?.total_sessions ?? 0,
          patients: active_doctor?.patients ?? 0,
          ong_treatment: active_doctor?.ong_treatment ?? 0,
          pen_treatment: active_doctor?.pen_treatment ?? 0,
          user_image: user_image,
          title: staff_role,
        ).toJson();

        bool sd = await StaffDatabaseHelpers.update_doctor_details(
          widget.staff!.key,
          data2,
          new_staff: widget.setup_profile,
        );

        if (!sd) {
          Navigator.pop(context);
          Helpers.showToast(
            context: context,
            color: Colors.red,
            toastText: 'An Error Occurred, Try again',
            icon: Icons.error,
          );
          return;
        }
      }

      bool st = await StaffDatabaseHelpers.update_staff_details(
          widget.staff!.key, data);

      if (!st) {
        Navigator.pop(context);
        Helpers.showToast(
          context: context,
          color: Colors.red,
          toastText: 'An Error Occurred, Try again',
          icon: Icons.error,
        );
        return;
      }

      Navigator.pop(context);

      if (widget.setup_profile)
        // remove page
        Navigator.pop(context);
      else
        setState(() {
          edit = false;
        });

      Helpers.showToast(
        context: context,
        color: Colors.blue,
        toastText: 'Profile Updated',
        icon: Icons.check,
      );
    }
  }

  //
}

// edit name dialog
class EditNameDailog extends StatefulWidget {
  final String fn;
  final String mn;
  final String ln;
  const EditNameDailog({
    super.key,
    required this.fn,
    required this.mn,
    required this.ln,
  });

  @override
  State<EditNameDailog> createState() => _EditNameDailogState();
}

class _EditNameDailogState extends State<EditNameDailog> {
  final TextEditingController fn_controller = TextEditingController();
  final TextEditingController mn_controller = TextEditingController();
  final TextEditingController ln_controller = TextEditingController();

  @override
  void dispose() {
    fn_controller.dispose();
    mn_controller.dispose();
    ln_controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    assignName();
    super.initState();
  }

  void assignName() {
    fn_controller.text = widget.fn;
    mn_controller.text = widget.mn;
    ln_controller.text = widget.ln;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 500,
        ),
        child: Container(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // heading
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF000000),
                      offset: Offset(0.7, 0.7),
                      blurRadius: 6,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2),

                    // title
                    Stack(
                      children: [
                        // title
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'User Fullname',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        // close button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 22,
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
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                    ),

                    SizedBox(height: 4),

                    // subtitle
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      child: Text(
                        'Use the form below to setup your name',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 5),

              // first name text field
              Container(
                color: Colors.black.withOpacity(0.6),
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text_field(
                  label: 'First name',
                  controller: fn_controller,
                  require: true,
                ),
              ),

              // middle name text field
              Container(
                color: Colors.black.withOpacity(0.6),
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text_field(
                  label: 'Middle name',
                  controller: mn_controller,
                ),
              ),

              // last name text field
              Container(
                color: Colors.black.withOpacity(0.6),
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text_field(
                  label: 'Last name',
                  controller: ln_controller,
                  require: true,
                ),
              ),

              SizedBox(height: 10),

              // submit button
              InkWell(
                onTap: () {
                  if (fn_controller.text.isEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'First name empty',
                      icon: Icons.error,
                    );
                    return;
                  }

                  if (ln_controller.text.isEmpty) {
                    Helpers.showToast(
                      context: context,
                      color: Colors.redAccent,
                      toastText: 'Last name empty',
                      icon: Icons.error,
                    );
                    return;
                  }

                  Map name = {
                    'first_name': fn_controller.text.trim(),
                    'middle_name': mn_controller.text.trim(),
                    'last_name': ln_controller.text.trim(),
                  };

                  Navigator.pop(context, name);
                },
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF3c5bff).withOpacity(0.6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
